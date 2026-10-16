const std = @import("std");

pub const Prompter = struct {
    process: std.process.Init,
    gum_enabled: bool,
    gum_missing: bool = false,
    replace_view: bool,

    pub fn init(process: std.process.Init, plain: bool) Prompter {
        const io = process.io;
        const term = process.environ_map.get("TERM") orelse "";
        const tty = (std.Io.File.stdin().isTty(io) catch false) and (std.Io.File.stdout().isTty(io) catch false) and (std.Io.File.stderr().isTty(io) catch false);
        return .{ .process = process, .gum_enabled = !plain and tty and !std.mem.eql(u8, term, "dumb"), .replace_view = tty and !std.mem.eql(u8, term, "dumb") };
    }

    pub fn usingGum(self: *const Prompter) bool {
        return self.gum_enabled and !self.gum_missing;
    }

    pub fn beginView(self: *const Prompter, stdout: *std.Io.Writer) !void {
        if (self.replace_view) try stdout.writeAll("\x1b[2J\x1b[H");
    }

    pub fn renderView(self: *Prompter, stdout: *std.Io.Writer, heading: []const u8, title: []const u8, body: []const u8) !void {
        try self.beginView(stdout);
        if (self.usingGum()) {
            self.style(stdout, &.{ "--foreground=212", "--bold", "--margin=0 0 1 1", "REPOLICENSE  /  license guidance" }) catch |err| switch (err) {
                error.FileNotFound => self.gum_missing = true,
                else => return err,
            };
        }
        if (self.usingGum()) {
            var content_buffer: [8192]u8 = undefined;
            const content = try std.fmt.bufPrint(&content_buffer, "{s}\n\n{s}\n\n{s}", .{ heading, title, body });
            var width_buffer: [32]u8 = undefined;
            const columns = if (self.process.environ_map.get("COLUMNS")) |value| std.fmt.parseInt(usize, value, 10) catch 80 else 80;
            const width = try std.fmt.bufPrint(&width_buffer, "--width={d}", .{@min(72, columns -| 8)});
            try self.style(stdout, &.{ "--border=rounded", "--border-foreground=99", "--padding=1 2", "--margin=0 1", width, content });
            try self.style(stdout, &.{ "--foreground=245", "--margin=1 1", "General guidance, not legal advice. Existing third-party grants remain in force." });
        } else {
            try stdout.print("\n=== Repolicense CLI ===\nGeneral guidance, not legal advice. Existing third-party grants remain in force.\n\n--- {s} ---\n{s}\n\n{s}\n", .{ heading, title, body });
        }
    }

    pub fn overview(self: *Prompter, stdout: *std.Io.Writer, title: []const u8, body: []const u8, color: []const u8) !void {
        try self.beginView(stdout);
        try self.style(stdout, &.{ "--foreground=212", "--bold", "REPOLICENSE  /  compatibility" });
        var content_buffer: [4096]u8 = undefined;
        const content = try std.fmt.bufPrint(&content_buffer, "{s}\n\n{s}", .{ title, body });
        var color_buffer: [48]u8 = undefined;
        const border = try std.fmt.bufPrint(&color_buffer, "--border-foreground={s}", .{color});
        try self.style(stdout, &.{ "--border=rounded", border, "--padding=0 1", "--width=68", content });
    }

    fn style(self: *const Prompter, stdout: *std.Io.Writer, args: []const []const u8) !void {
        try stdout.flush();
        var argv: [24][]const u8 = undefined;
        argv[0] = "gum";
        argv[1] = "style";
        @memcpy(argv[2 .. args.len + 2], args);
        var child = try std.process.spawn(self.process.io, .{ .argv = argv[0 .. args.len + 2], .stdin = .ignore, .stdout = .inherit, .stderr = .inherit, .create_no_window = false });
        defer child.kill(self.process.io);
        if (!(try child.wait(self.process.io)).success()) return error.GumStyleFailed;
    }

    pub fn page(self: *const Prompter, stdout: *std.Io.Writer, content: []const u8) !void {
        try stdout.flush();
        var child = try std.process.spawn(self.process.io, .{ .argv = &.{ "gum", "pager", "--soft-wrap" }, .stdin = .pipe, .stdout = .inherit, .stderr = .inherit, .create_no_window = false });
        defer child.kill(self.process.io);
        var buffer: [4096]u8 = undefined;
        var input = child.stdin.?.writer(self.process.io, &buffer);
        try input.interface.writeAll(content);
        try input.interface.flush();
        child.stdin.?.close(self.process.io);
        child.stdin = null;
        const term = try child.wait(self.process.io);
        if (!term.success() and !(term == .exited and (term.exited == 1 or term.exited == 130))) return error.GumFailed;
    }

    pub fn choose(self: *Prompter, stdout: *std.Io.Writer, stdin: *std.Io.Reader, labels: []const []const u8) !?usize {
        if (self.usingGum()) {
            const result = self.runGumChoose(stdout, labels) catch |err| switch (err) {
                error.FileNotFound => {
                    self.gum_missing = true;
                    return plainChoose(stdout, stdin, labels);
                },
                else => return err,
            };
            return switch (result) {
                .selected => |i| i,
                .cancelled => null,
            };
        }
        return plainChoose(stdout, stdin, labels);
    }

    pub fn pickMany(self: *Prompter, stdout: *std.Io.Writer, stdin: *std.Io.Reader, labels: []const []const u8, selected: []usize) !?[]const usize {
        if (self.usingGum()) {
            const result = self.runGumMany(stdout, labels, selected) catch |err| switch (err) {
                error.FileNotFound => {
                    self.gum_missing = true;
                    return plainMany(stdout, stdin, labels, selected);
                },
                else => return err,
            };
            return switch (result) {
                .selected => |items| items,
                .cancelled => null,
            };
        }
        return plainMany(stdout, stdin, labels, selected);
    }

    const GumChoice = union(enum) { selected: usize, cancelled };
    const GumMany = union(enum) { selected: []const usize, cancelled };

    fn runGumChoose(self: *Prompter, stdout: *std.Io.Writer, labels: []const []const u8) !GumChoice {
        try stdout.flush();
        var argv_buffer: [64][]const u8 = undefined;
        const flags = [_][]const u8{ "gum", "choose", "--limit=1", "--label-delimiter=", "--header=Choose an option", "--header.foreground=99", "--cursor=❯ ", "--cursor.foreground=212", "--selected.foreground=212", "--padding=0 2", "--height=10" };
        if (labels.len + flags.len > argv_buffer.len) return error.TooManyOptions;
        const argv = argv_buffer[0 .. labels.len + flags.len];
        @memcpy(argv[0..flags.len], &flags);
        @memcpy(argv[flags.len..], labels);
        var output_buffer: [16384]u8 = undefined;
        const result = try runGumProcess(self.process, argv, &output_buffer);
        if (result.term == .exited and result.term.exited == 0) {
            const selection = std.mem.trim(u8, result.output, "\r\n");
            if (selection.len == 0) return .cancelled;
            return .{ .selected = findLabel(labels, selection) orelse findDisplayLabel(labels, selection) orelse return error.InvalidGumSelection };
        }
        // Gum v2 also uses exit 1 for runtime errors; its stderr is inherited, so classify exit 1 conservatively as cancellation.
        if (result.term == .exited and (result.term.exited == 1 or result.term.exited == 130)) return .cancelled;
        return error.GumFailed;
    }

    fn runGumMany(self: *Prompter, stdout: *std.Io.Writer, labels: []const []const u8, selected: []usize) !GumMany {
        try stdout.flush();
        var argv_buffer: [64][]const u8 = undefined;
        if (labels.len + 4 > argv_buffer.len) return error.TooManyOptions;
        const argv = argv_buffer[0 .. labels.len + 4];
        argv[0] = "gum";
        argv[1] = "filter";
        argv[2] = "--no-limit";
        argv[3] = "--output-delimiter=\n";
        @memcpy(argv[4..], labels);
        var output_buffer: [16384]u8 = undefined;
        const result = try runGumProcess(self.process, argv, &output_buffer);
        if (result.term == .exited and (result.term.exited == 1 or result.term.exited == 130)) return .cancelled;
        if (result.term != .exited or result.term.exited != 0) return error.GumFailed;
        var count: usize = 0;
        var lines = std.mem.tokenizeScalar(u8, result.output, '\n');
        while (lines.next()) |raw| {
            const line = std.mem.trimEnd(u8, raw, "\r");
            const index = findLabel(labels, line) orelse findDisplayLabel(labels, line) orelse return error.InvalidGumSelection;
            if (!contains(selected[0..count], index)) {
                if (count == selected.len) return error.SelectionBufferTooSmall;
                selected[count] = index;
                count += 1;
            }
        }
        return .{ .selected = selected[0..count] };
    }
};

const GumProcessResult = struct { term: std.process.Child.Term, output: []u8 };

fn runGumProcess(process: std.process.Init, argv: []const []const u8, output_buffer: []u8) !GumProcessResult {
    var child = try std.process.spawn(process.io, .{ .argv = argv, .stdin = .inherit, .stdout = .pipe, .stderr = .inherit, .create_no_window = false });
    defer child.kill(process.io);
    var buffer: [1024]u8 = undefined;
    var reader = child.stdout.?.reader(process.io, &buffer);
    const count = try reader.interface.readSliceShort(output_buffer);
    if (count == output_buffer.len) {
        if (reader.interface.takeByte()) |_| {
            return error.StreamTooLong;
        } else |err| switch (err) {
            error.EndOfStream => {},
            else => return err,
        }
    }
    const term = try child.wait(process.io);
    return .{ .term = term, .output = output_buffer[0..count] };
}

pub fn parseChoice(input: []const u8, labels: []const []const u8) error{InvalidSelection}!?usize {
    const value = std.mem.trim(u8, input, &std.ascii.whitespace);
    if (value.len == 0) return error.InvalidSelection;
    if (std.ascii.eqlIgnoreCase(value, "q") or std.ascii.eqlIgnoreCase(value, "quit") or std.ascii.eqlIgnoreCase(value, "exit")) return actionIndex(labels, "Quit");
    if (std.ascii.eqlIgnoreCase(value, "b") or std.ascii.eqlIgnoreCase(value, "back")) if (actionIndex(labels, "Back")) |i| return i;
    if (std.ascii.eqlIgnoreCase(value, "r") or std.ascii.eqlIgnoreCase(value, "reset") or std.ascii.eqlIgnoreCase(value, "restart")) if (actionIndex(labels, "Restart")) |i| return i;
    if (value.len == 1 and (value[0] == 'y' or value[0] == 'Y')) if (findDisplayLabelIgnoreCase(labels, "Yes")) |i| return i;
    if (value.len == 1 and (value[0] == 'n' or value[0] == 'N')) if (findDisplayLabelIgnoreCase(labels, "No")) |i| return i;
    if (findDisplayLabelIgnoreCase(labels, value)) |i| return i;
    const number = std.fmt.parseInt(usize, value, 10) catch return error.InvalidSelection;
    if (number == 0 or number > labels.len) return error.InvalidSelection;
    return number - 1;
}

pub fn parseMany(input: []const u8, labels: []const []const u8, output: []usize) error{ InvalidSelection, SelectionBufferTooSmall }!?[]const usize {
    const value = std.mem.trim(u8, input, &std.ascii.whitespace);
    if (value.len == 0 or std.ascii.eqlIgnoreCase(value, "q") or std.ascii.eqlIgnoreCase(value, "quit") or std.ascii.eqlIgnoreCase(value, "exit")) return null;
    var count: usize = 0;
    var entries = std.mem.tokenizeScalar(u8, value, ',');
    while (entries.next()) |raw| {
        const entry = std.mem.trim(u8, raw, &std.ascii.whitespace);
        if (entry.len == 0) return error.InvalidSelection;
        const i = if (findLabel(labels, entry) orelse findDisplayLabel(labels, entry)) |matched| matched else blk: {
            const number = std.fmt.parseInt(usize, entry, 10) catch return error.InvalidSelection;
            if (number == 0 or number > labels.len) return error.InvalidSelection;
            break :blk number - 1;
        };
        if (!contains(output[0..count], i)) {
            if (count == output.len) return error.SelectionBufferTooSmall;
            output[count] = i;
            count += 1;
        }
    }
    return output[0..count];
}

fn plainChoose(stdout: *std.Io.Writer, stdin: *std.Io.Reader, labels: []const []const u8) !?usize {
    while (true) {
        for (labels, 0..) |label, i| try stdout.print("{d}. {s}\n", .{ i + 1, label });
        try stdout.writeAll("Select an option: ");
        try stdout.flush();
        const line = (try stdin.takeDelimiter('\n')) orelse return null;
        const value = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (value.len == 0) {
            try stdout.writeAll("Invalid selection. Try again.\n");
            continue;
        }
        if (parseChoice(value, labels)) |choice| {
            return choice;
        } else |err| switch (err) {
            error.InvalidSelection => try stdout.writeAll("Invalid selection. Try again.\n"),
        }
    }
}

fn plainMany(stdout: *std.Io.Writer, stdin: *std.Io.Reader, labels: []const []const u8, selected: []usize) !?[]const usize {
    while (true) {
        for (labels, 0..) |label, i| try stdout.print("{d}. {s}\n", .{ i + 1, label });
        try stdout.writeAll("Select comma-separated options (or q to cancel): ");
        try stdout.flush();
        const line = (try stdin.takeDelimiter('\n')) orelse return null;
        if (parseMany(line, labels, selected)) |result| {
            return result;
        } else |err| switch (err) {
            error.InvalidSelection => try stdout.writeAll("Invalid selection. Try again.\n"),
            error.SelectionBufferTooSmall => return error.SelectionBufferTooSmall,
        }
    }
}

fn contains(items: []const usize, needle: usize) bool {
    for (items) |item| if (item == needle) return true;
    return false;
}
fn findLabel(labels: []const []const u8, needle: []const u8) ?usize {
    for (labels, 0..) |label, i| if (std.mem.eql(u8, label, needle)) return i;
    return null;
}
fn findDisplayLabel(labels: []const []const u8, needle: []const u8) ?usize {
    for (labels, 0..) |label, i| {
        const short = if (std.mem.indexOf(u8, label, " — ")) |split| label[0..split] else label;
        if (std.mem.eql(u8, short, needle)) return i;
    }
    return null;
}
fn findDisplayLabelIgnoreCase(labels: []const []const u8, needle: []const u8) ?usize {
    for (labels, 0..) |label, i| {
        const short = if (std.mem.indexOf(u8, label, " — ")) |split| label[0..split] else label;
        if (std.ascii.eqlIgnoreCase(short, needle)) return i;
    }
    return null;
}
fn actionIndex(labels: []const []const u8, action: []const u8) ?usize {
    return findDisplayLabelIgnoreCase(labels, action);
}

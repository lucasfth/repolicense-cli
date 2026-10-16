const std = @import("std");
const mem = std.mem;
const tree = @import("tree.zig");
const ui = @import("ui.zig");
const compatibility = @import("compatibility.zig");
const catalog = @import("licenses.zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_file.interface;
    var args = try init.minimal.args.iterateAllocator(init.gpa);
    defer args.deinit();
    _ = args.next();
    var is_compat = false;
    var plain = false;
    var help = false;
    while (args.next()) |arg| {
        if (mem.eql(u8, arg, "--compat") or mem.eql(u8, arg, "-c")) {
            is_compat = true;
        } else if (mem.eql(u8, arg, "--plain")) {
            plain = true;
        } else if (mem.eql(u8, arg, "--help") or mem.eql(u8, arg, "-h")) {
            help = true;
        } else {
            try stdout.print("Unknown argument: {s}\nUse repolicense --help for usage.\n", .{arg});
            try stdout.flush();
            std.process.exit(2);
        }
    }
    if (help) {
        try stdout.writeAll(
            \\Usage: repolicense [--compat | -c] [--plain]
            \\       repolicense --help
            \\
            \\Choose a license for work you can license, or assess existing license combinations.
            \\Start without flags to choose license guidance or compatibility checking.
            \\Gum menus are optional and used only in an interactive terminal when gum is on PATH.
            \\--plain disables Gum. Redirected input/output always uses plain text.
            \\Plain menus accept a number or label; back/b, reset/r, and quit/q remain available.
            \\Plain --compat accepts comma-separated canonical SPDX identifiers.
            \\This tool provides general guidance, not legal advice.
            \\
        );
    } else {
        var prompts = ui.Prompter.init(init, plain);
        var stdin_buffer: [4096]u8 = undefined;
        var stdin_file = std.Io.File.stdin().reader(init.io, &stdin_buffer);
        const stdin = &stdin_file.interface;
        if (is_compat) {
            try runCompatibilityMode(stdin, stdout, &prompts);
        } else {
            try prompts.renderView(stdout, "WELCOME", "What would you like to do?", "Choose a license for your own work, or check combinations of existing licenses. You can also open the checker directly with --compat.");
            const mode = try prompts.choose(stdout, stdin, &.{ "Choose a license", "Check compatibility", "Quit" });
            if (mode) |selected| switch (selected) {
                0 => try runDecisionTree(init.gpa, stdin, stdout, &prompts),
                1 => try runCompatibilityMode(stdin, stdout, &prompts),
                else => try stdout.writeAll("\nThank you for using Repolicense\n"),
            };
        }
    }
    try stdout.flush();
}

fn readLine(stdin: *std.Io.Reader, stdout: *std.Io.Writer) !?[]u8 {
    try stdout.flush();
    return stdin.takeDelimiter('\n');
}

fn runCompatibilityMode(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompts: *ui.Prompter) !void {
    try prompts.renderView(stdout, "COMPATIBILITY", "Check existing license combinations", "Assess a covered combined work, not merely separate projects in one repository. Original notices and component obligations remain. Conditional results require the stated conditions. Exceptions, compound expressions, jurisdiction, and unlisted versions are not modeled.");
    if (!prompts.usingGum()) {
        try stdout.writeAll("Enter comma-separated canonical SPDX identifiers, for example: MIT, Apache-2.0\nGNU identifiers must specify '-only' or '-or-later'.\n\nSupported licenses:\n");
        for ([_]catalog.Category{ .Permissive, .StrongCopyleft, .WeakCopyleft, .PublicDomain, .Font }) |category| {
            try stdout.print("  {s}: ", .{@tagName(category)});
            var first = true;
            for (catalog.all) |license| {
                if (license.getCategory() != category) continue;
                if (!first) try stdout.writeAll(", ");
                try stdout.writeAll(license.toString());
                first = false;
            }
            try stdout.writeByte('\n');
        }
    }
    while (true) {
        var selected: [catalog.all.len]catalog.License = undefined;
        var count: usize = 0;
        if (prompts.usingGum()) {
            var labels: [catalog.all.len][]const u8 = undefined;
            for (catalog.all, 0..) |license, i| labels[i] = license.toString();
            var indices: [catalog.all.len]usize = undefined;
            try stdout.writeAll("\nSelect existing licenses (type to search; Tab toggles and advances; Enter checks; Ctrl-C cancels).\n");
            const chosen = (try prompts.pickMany(stdout, stdin, &labels, &indices)) orelse break;
            for (chosen) |index| {
                selected[count] = catalog.all[index];
                count += 1;
            }
        } else {
            try stdout.writeAll("\nEnter licenses (or 'quit' to exit): ");
            const line = (try readLine(stdin, stdout)) orelse break;
            const trimmed = mem.trim(u8, line, &std.ascii.whitespace);
            if (std.ascii.eqlIgnoreCase(trimmed, "quit") or std.ascii.eqlIgnoreCase(trimmed, "q") or std.ascii.eqlIgnoreCase(trimmed, "exit")) break;
            if (trimmed.len == 0) continue;
            var iter = mem.tokenizeAny(u8, trimmed, ",");
            var has_error = false;
            while (iter.next()) |license_str| {
                const clean = mem.trim(u8, license_str, &std.ascii.whitespace);
                const license = catalog.License.fromString(clean) orelse {
                    try stdout.print("\nError: Unknown or ambiguous license '{s}'. Use a supported canonical identifier; GNU licenses require '-only' or '-or-later'.\n", .{clean});
                    has_error = true;
                    break;
                };
                var duplicate = false;
                for (selected[0..count]) |previous| {
                    if (previous == license) {
                        duplicate = true;
                        break;
                    }
                }
                if (!duplicate) {
                    selected[count] = license;
                    count += 1;
                }
            }
            if (has_error) continue;
        }
        if (count == 0) {
            try stdout.writeAll("\nError: No valid licenses entered\n");
            continue;
        }
        if (prompts.usingGum()) {
            var candidates_buffer: [catalog.all.len]compatibility.Candidate = undefined;
            const candidates = compatibility.findCandidates(selected[0..count], &candidates_buffer);
            var ordinary: usize = 0;
            for (candidates) |candidate| {
                if (candidate.status == .compatible) ordinary += 1;
            }
            var summary_buffer: [2048]u8 = undefined;
            var summary = std.Io.Writer.fixed(&summary_buffer);
            try summary.writeAll("Selected: ");
            for (selected[0..count], 0..) |license, i| {
                if (i > 0) try summary.writeAll(", ");
                try summary.writeAll(license.toString());
            }
            try summary.print("\n\n{d} ordinary targets    {d} conditional targets\n\nOrdinary: standard obligations still apply.\nConditional: additional prerequisites must be checked.\nComponent licenses and notices remain in force.", .{ ordinary, candidates.len - ordinary });
            const title = if (ordinary > 0) "COMMON TARGETS AVAILABLE" else if (candidates.len > 0) "ONLY CONDITIONAL TARGETS FOUND" else "NO SUPPORTED COMMON TARGET";
            const color: []const u8 = if (ordinary > 0) "42" else if (candidates.len > 0) "214" else "196";
            var another = false;
            while (true) {
                try prompts.overview(stdout, title, summary.buffered(), color);
                const action = (try prompts.choose(stdout, stdin, &.{ "View targets and conditions", "Check another combination", "Quit" })) orelse break;
                if (action == 0) {
                    var details = std.Io.Writer.Allocating.init(prompts.process.gpa);
                    defer details.deinit();
                    try printCompatibility(&details.writer, selected[0..count]);
                    try prompts.page(stdout, details.written());
                } else {
                    another = action == 1;
                    break;
                }
            }
            if (!another) break;
            try prompts.renderView(stdout, "COMPATIBILITY", "Check another combination", "Select existing licenses. The next screen summarizes common targets; full conditions remain available in the detail viewer.");
        } else {
            try printCompatibility(stdout, selected[0..count]);
        }
    }
    try stdout.writeAll("\nThank you for using the compatibility checker of Repolicense\n");
}

fn printCompatibility(stdout: *std.Io.Writer, input_licenses: []const catalog.License) !void {
    var candidates_buffer: [catalog.all.len]compatibility.Candidate = undefined;
    const candidates = compatibility.findCandidates(input_licenses, &candidates_buffer);
    try stdout.writeAll("\n--- Results ---\nGiven licenses: ");
    for (input_licenses, 0..) |license, i| {
        if (i > 0) try stdout.writeAll(", ");
        try stdout.writeAll(license.toString());
    }
    try stdout.writeAll("\n\n");
    if (candidates.len == 0) {
        try stdout.writeAll("No combined-work target found under these rules.\nThis does not rule out independent aggregation or separately granted permissions.\n\n");
    } else {
        try stdout.writeAll("Combined-work targets; retain required notices and applicable component obligations:\n");
        for (candidates) |candidate| {
            try stdout.print("  [{s}] {s}\n", .{ @tagName(candidate.status), candidate.license.toString() });
            if (candidate.status == .conditional) {
                for (input_licenses) |source| {
                    const assessment = compatibility.assess(source, candidate.license);
                    if (assessment.status == .conditional) try stdout.print("    {s}: {s}\n", .{ source.toString(), assessment.reason });
                }
            }
        }
        try stdout.writeByte('\n');
    }
    if (input_licenses.len > 1) {
        try stdout.writeAll("Pairwise common-target checks (not permission to relicense either component):\n");
        for (input_licenses, 0..) |a, i| {
            for (input_licenses[i + 1 ..]) |b| {
                const assessment = compatibility.assessPair(a, b);
                try stdout.print("  [{s}] {s} + {s}: {s}\n", .{ @tagName(assessment.status), a.toString(), b.toString(), assessment.reason });
            }
        }
        try stdout.writeByte('\n');
    }
}

fn runDecisionTree(allocator: mem.Allocator, stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompts: *ui.Prompter) !void {
    var history = try std.ArrayList(tree.Id).initCapacity(allocator, 16);
    defer history.deinit(allocator);
    try history.append(allocator, .work_type);
    while (true) {
        const current = tree.node(history.items[history.items.len - 1]);
        var content_buffer: [8192]u8 = undefined;
        if (current.choices.len > 0) {
            var heading_buffer: [48]u8 = undefined;
            const heading = try std.fmt.bufPrint(&heading_buffer, "QUESTION {d}", .{history.items.len});
            try prompts.renderView(stdout, heading, current.title, current.detail);
        } else if (current.license) |license| {
            const content = try std.fmt.bufPrint(&content_buffer, "Why it fits: {s}\n\nObligations and limitations: {s}\n\nLicense text: {s}", .{ current.detail, license.description(), license.url() });
            var title_buffer: [64]u8 = undefined;
            const title = try std.fmt.bufPrint(&title_buffer, "License: {s}", .{license.toString()});
            try prompts.renderView(stdout, "RECOMMENDATION", title, content);
        } else {
            try prompts.renderView(stdout, "GUIDANCE", current.title, current.detail);
        }
        var labels: [std.meta.tags(tree.Id).len + 3][]const u8 = undefined;
        var label_buffer: [16384]u8 = undefined;
        var used: usize = 0;
        for (current.choices, 0..) |choice, i| {
            if (choice.detail.len == 0) {
                labels[i] = choice.label;
            } else {
                labels[i] = try std.fmt.bufPrint(label_buffer[used..], "{s} — {s}", .{ choice.label, choice.detail });
                used += labels[i].len;
            }
        }
        const back = current.choices.len;
        labels[back] = "Back";
        labels[back + 1] = "Restart";
        labels[back + 2] = "Quit";
        const chosen = (try prompts.choose(stdout, stdin, labels[0 .. back + 3])) orelse break;
        if (chosen < back) {
            try history.append(allocator, current.choices[chosen].next);
        } else if (chosen == back) {
            if (history.items.len > 1) {
                _ = history.pop();
            } else {
                try stdout.writeAll("\nAlready at the beginning.\n");
            }
        } else if (chosen == back + 1) {
            history.clearRetainingCapacity();
            try history.append(allocator, .work_type);
        } else break;
    }
    try stdout.writeAll("\nThank you for using Repolicense\n");
}

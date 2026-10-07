const std = @import("std");
const mem = std.mem;
const tree = @import("tree.zig");
const compatibility = @import("compatibility.zig");
const catalog = @import("licenses.zig");

const Node = tree.Node;
const decision_tree = tree.decision_tree;

const History = std.ArrayList(*const Node);

const BOLD = "\x1b[1m";
const ITALIC = "\x1b[3m";
const DIM = "\x1b[2m";
const UNDERLINE = "\x1b[4m";
const RESET = "\x1b[0m";

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_file.interface;

    var args = try init.minimal.args.iterateAllocator(allocator);
    defer args.deinit();
    _ = args.next();

    // Check if compatibility mode is requested via flag (`--compat` or `-c`)
    var is_compat: bool = false;
    while (args.next()) |arg| {
        if (mem.eql(u8, arg, "--compat") or mem.eql(u8, arg, "-c")) {
            is_compat = true;
            break;
        }
    }

    if (is_compat) {
        try runCompatibilityMode(init.io, stdout);
    } else {
        // Run normal decision tree mode
        try runDecisionTree(allocator, init.io, stdout);
    }
    try stdout.flush();
}

fn readLine(stdin: *std.Io.Reader, stdout: *std.Io.Writer) !?[]u8 {
    try stdout.flush();
    return stdin.takeDelimiter('\n');
}

fn runCompatibilityMode(io: std.Io, stdout: anytype) !void {
    var buf: [1024]u8 = undefined;
    var stdin_file = std.Io.File.stdin().reader(io, &buf);
    const stdin = &stdin_file.interface;

    try stdout.print("\n=== {s}License Compatibility Checker{s} ===\n", .{ BOLD, RESET });
    try stdout.print("Check licenses for a covered combined work, not merely separate projects in one repository.\n", .{});
    try stdout.print("Original notices and component obligations remain. Conditional results require the stated conditions.\n", .{});
    try stdout.print("Exceptions, dual-license expressions, jurisdiction, and unlisted versions are not modeled; this is not legal advice.\n\n", .{});
    try stdout.print("Enter comma-separated canonical SPDX identifiers, for example: MIT, Apache-2.0\n", .{});
    try stdout.print("GNU identifiers must specify '-only' or '-or-later'.\n\nSupported licenses:\n", .{});
    for ([_]catalog.Category{ .Permissive, .StrongCopyleft, .WeakCopyleft, .PublicDomain, .Font }) |category| {
        try stdout.print("  {s}: ", .{@tagName(category)});
        var first = true;
        for (catalog.all) |license| {
            if (license.getCategory() != category) continue;
            if (!first) try stdout.print(", ", .{});
            try stdout.print("{s}", .{license.toString()});
            first = false;
        }
        try stdout.print("\n", .{});
    }
    try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});

    while (true) {
        const line = (try readLine(stdin, stdout)) orelse break;
        const trimmed = mem.trim(u8, line, &std.ascii.whitespace);
        if (std.ascii.eqlIgnoreCase(trimmed, "quit") or std.ascii.eqlIgnoreCase(trimmed, "q")) {
            try stdout.print("\nThank you for using the compatibility checker of Repolicense\n", .{});
            break;
        }
        if (trimmed.len == 0) {
            try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});
            continue;
        }

        var selected: [catalog.all.len]catalog.License = undefined;
        var count: usize = 0;
        var iter = mem.tokenizeAny(u8, trimmed, ",");
        var has_error = false;
        while (iter.next()) |license_str| {
            const clean = mem.trim(u8, license_str, &std.ascii.whitespace);
            if (clean.len == 0) continue;
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
        if (has_error or count == 0) {
            if (!has_error) try stdout.print("\nError: No valid licenses entered\n", .{});
            try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});
            continue;
        }

        const input_licenses = selected[0..count];
        var candidates_buffer: [catalog.all.len]compatibility.Candidate = undefined;
        const candidates = compatibility.findCandidates(input_licenses, &candidates_buffer);

        try stdout.print("\n--- {s}Results{s} ---\nGiven licenses: ", .{ BOLD, RESET });
        for (input_licenses, 0..) |license, i| {
            if (i > 0) try stdout.print(", ", .{});
            try stdout.print("{s}", .{license.toString()});
        }
        try stdout.print("\n\n", .{});
        if (candidates.len == 0) {
            try stdout.print("No combined-work target found under these rules.\n", .{});
            try stdout.print("This does not rule out independent aggregation or separately granted permissions.\n\n", .{});
        } else {
            try stdout.print("Combined-work targets; retain required notices and applicable component obligations:\n", .{});
            for (candidates) |candidate| {
                try stdout.print("  [{s}] {s}\n", .{ @tagName(candidate.status), candidate.license.toString() });
                if (candidate.status == .conditional) {
                    for (input_licenses) |source| {
                        const assessment = compatibility.assess(source, candidate.license);
                        if (assessment.status == .conditional) {
                            try stdout.print("    {s}: {s}\n", .{ source.toString(), assessment.reason });
                        }
                    }
                }
            }
            try stdout.print("\n", .{});
        }

        if (count > 1) {
            try stdout.print("Pairwise common-target checks (not permission to relicense either component):\n", .{});
            for (input_licenses, 0..) |a, i| {
                for (input_licenses[i + 1 ..]) |b| {
                    const assessment = compatibility.assessPair(a, b);
                    try stdout.print("  [{s}] {s} + {s}: {s}\n", .{ @tagName(assessment.status), a.toString(), b.toString(), assessment.reason });
                }
            }
            try stdout.print("\n", .{});
        }
        try stdout.print("Enter licenses (or 'quit' to exit): ", .{});
    }
}

fn runDecisionTree(allocator: std.mem.Allocator, io: std.Io, stdout: anytype) !void {
    var buf: [256]u8 = undefined;
    var stdin_file = std.Io.File.stdin().reader(io, &buf);
    const stdin = &stdin_file.interface;
    const ui = @import("ui.zig");

    var screen = ui.Screen.init();

    var history = try History.initCapacity(allocator, 0);
    defer history.deinit(allocator);

    var current_node = &decision_tree;
    try history.append(allocator, current_node);

    // Print welcome message (kept as regular prints so it doesn't get cleared)
    try stdout.print("\n=== {s}Repolicense CLI{s} ===\n", .{ BOLD, RESET });
    try stdout.print("Answer with 'yes', 'no', 'back', 'reset', or 'quit' to explore a suitable license.\n", .{});
    try stdout.print("Recommendations explain obligations; they are not legal advice or permission to replace third-party licenses.\n", .{});
    try stdout.print("\nRun with {s}'--compat'{s} (or {s}'-c'{s}) to check combinations of existing licenses.\n\n", .{ UNDERLINE, RESET, UNDERLINE, RESET });

    while (true) {
        if (current_node.node_type == .Question) {
            const content = if (current_node.elaboration.len > 0)
                try allocator.print("\n--- {s}Question{s} ---\n{s}\n\n{s}Elaboration: {s}\n{s}\nYour answer (yes/no/back/reset/quit): ", .{ ITALIC, RESET, current_node.content, DIM, current_node.elaboration, RESET })
            else
                try allocator.print("\n--- {s}Question{s} ---\n{s}\nYour answer (yes/no/back/reset/quit): ", .{ ITALIC, RESET, current_node.content });

            try screen.render(stdout, content);
            allocator.free(content);
        } else {
            const content = if (current_node.license) |license|
                try allocator.print("\n--- {s}RESULT{s} ---\nLicense: {s}{s}{s}\n\n{s}\n\nLicense text: {s}\n\nOptions: back/reset/quit: ", .{ BOLD, RESET, BOLD, license.toString(), RESET, current_node.elaboration, license.url() })
            else
                try allocator.print("\n--- {s}GUIDANCE{s} ---\n{s}{s}{s}\n\n{s}\n\nOptions: back/reset/quit: ", .{ BOLD, RESET, BOLD, current_node.content, RESET, current_node.elaboration });
            try screen.render(stdout, content);
            allocator.free(content);
        }

        const line = (try readLine(stdin, stdout)) orelse break;
        const trimmed = mem.trim(u8, line, &std.ascii.whitespace);
        const answer = trimmed;

        // Clear previous rendered block and the input line the user just entered
        try screen.clearIncludingInput(stdout);

        if (std.ascii.eqlIgnoreCase(answer, "quit") or std.ascii.eqlIgnoreCase(answer, "q") or std.ascii.eqlIgnoreCase(answer, "exit")) {
            // Clear last rendered block before exiting
            try screen.clear(stdout);
            try stdout.print("\nThank you for using Repolicense\n", .{});
            break;
        } else if (std.ascii.eqlIgnoreCase(answer, "back") or std.ascii.eqlIgnoreCase(answer, "b")) {
            if (history.items.len > 1) {
                _ = history.pop();
                current_node = history.items[history.items.len - 1];
                // Show a short status message inside the same screen block so it will be overwritten next render
                try screen.render(stdout, "[Moved back]\n");
            } else {
                try screen.render(stdout, "[Already at the beginning]\n");
            }
        } else if (std.ascii.eqlIgnoreCase(answer, "reset") or std.ascii.eqlIgnoreCase(answer, "r")) {
            history.clearRetainingCapacity();
            current_node = &decision_tree;
            try history.append(allocator, current_node);
            try screen.render(stdout, "[Reset to beginning]\n");
        } else if (current_node.node_type == .Question) {
            if (std.ascii.eqlIgnoreCase(answer, "yes") or std.ascii.eqlIgnoreCase(answer, "y")) {
                if (current_node.yes) |next_node| {
                    current_node = next_node;
                    try history.append(allocator, current_node);
                }
            } else if (std.ascii.eqlIgnoreCase(answer, "no") or std.ascii.eqlIgnoreCase(answer, "n")) {
                if (current_node.no) |next_node| {
                    current_node = next_node;
                    try history.append(allocator, current_node);
                }
            } else {
                try screen.render(stdout, "[Invalid input. Please enter yes, no, back, reset, or quit]\n");
            }
        } else {
            try screen.render(stdout, "[Invalid command. Use back, reset, or quit]\n");
        }
    }
}

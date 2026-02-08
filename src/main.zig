const std = @import("std");
const mem = std.mem;
const tree = @import("tree.zig");
const compatibility = @import("compatibility.zig");

const Node = tree.Node;
const NodeType = tree.NodeType;
const decision_tree = tree.decision_tree;

const History = std.ArrayList(*const Node);

const BOLD = "\x1b[1m";
const ITALIC = "\x1b[3m";
const DIM = "\x1b[2m";
const UNDERLINE = "\x1b[4m";
const RESET = "\x1b[0m";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.fs.File.stdout().deprecatedWriter();

    // Check for command-line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Check if compatibility mode is requested via flag (`--compat` or `-c`)
    var is_compat: bool = false;
    for (args[1..]) |a| {
        if (mem.eql(u8, a, "--compat") or mem.eql(u8, a, "-c")) {
            is_compat = true;
            break;
        }
    }

    if (is_compat) {
        try runCompatibilityMode(allocator, stdout);
        return;
    }

    // Run normal decision tree mode
    try runDecisionTree(allocator, stdout);
}

fn runCompatibilityMode(allocator: std.mem.Allocator, stdout: anytype) !void {
    const stdin = std.fs.File.stdin().deprecatedReader();

    try stdout.print("\n=== {s}License Compatibility Checker{s} ===\n", .{ BOLD, RESET });
    try stdout.print("This tool helps you find compatible licenses when forking or combining projects.\n\n", .{});
    try stdout.print("Enter the licenses of the projects you want to combine (comma-separated).\n", .{});
    try stdout.print("Example: MIT, Apache-2.0, BSD-3-Clause\n\n", .{});
    try stdout.print("Supported licenses:\n", .{});
    try stdout.print("  Permissive: MIT, BSD-2-Clause, BSD-3-Clause, Apache-2.0, 0BSD, ISC\n", .{});
    try stdout.print("  Copyleft: GPL-2.0, GPL-3.0, AGPL-3.0, LGPL-3.0\n", .{});
    try stdout.print("  Weak Copyleft: MPL-2.0, EPL-2.0, EPL-1.0\n", .{});
    try stdout.print("  Other: Unlicense, OFL-1.1\n\n", .{});
    try stdout.print("Enter licenses (or 'quit' to exit): ", .{});

    var buf: [1024]u8 = undefined;

    while (true) {
        const line = (try stdin.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
        const trimmed = mem.trim(u8, line, &std.ascii.whitespace);

        if (trimmed.len == 0) {
            try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});
            continue;
        }

        if (mem.eql(u8, trimmed, "quit") or mem.eql(u8, trimmed, "q")) {
            try stdout.print("\nThank you for using the compatibility checker of Repolicense\n", .{});
            break;
        }

        // Parse comma-separated licenses
        var licenses = try std.ArrayList(compatibility.License).initCapacity(allocator, 0);
        defer licenses.deinit(allocator);

        var iter = std.mem.tokenizeAny(u8, trimmed, ",");
        var has_error = false;

        while (iter.next()) |license_str| {
            const clean = mem.trim(u8, license_str, &std.ascii.whitespace);
            if (clean.len == 0) continue;

            if (compatibility.License.fromString(clean)) |lic| {
                try licenses.append(allocator, lic);
            } else {
                try stdout.print("\nError: Unknown license '{s}'\n", .{clean});
                has_error = true;
                break;
            }
        }

        if (has_error) {
            try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});
            continue;
        }

        if (licenses.items.len == 0) {
            try stdout.print("\nError: No valid licenses entered\n", .{});
            try stdout.print("\nEnter licenses (or 'quit' to exit): ", .{});
            continue;
        }

        // Find compatible licenses
        const compatible_licenses = try compatibility.findCompatibleLicenses(allocator, licenses.items);
        defer allocator.free(compatible_licenses);

        try stdout.print("\n--- {s}Results{s} ---\n", .{ BOLD, RESET });
        try stdout.print("Given licenses: ", .{});
        for (licenses.items, 0..) |lic, i| {
            if (i > 0) try stdout.print(", ", .{});
            try stdout.print("{s}", .{lic.toString()});
        }
        try stdout.print("\n\n", .{});

        if (compatible_licenses.len == 0) {
            try stdout.print("No compatible licenses found!\n", .{});
            try stdout.print("The licenses you selected have conflicting requirements.\n\n", .{});
        } else {
            try stdout.print("You can use any of these licenses for your combined work:\n\n", .{});
            for (compatible_licenses) |lic| {
                try stdout.print("  • {s}\n", .{lic.toString()});
            }
            try stdout.print("\n", .{});
        }

        // Show pairwise compatibility details for better understanding
        if (licenses.items.len > 1) {
            try stdout.print("Compatibility details:\n", .{});
            var i: usize = 0;
            while (i < licenses.items.len - 1) : (i += 1) {
                var j: usize = i + 1;
                while (j < licenses.items.len) : (j += 1) {
                    const compat = compatibility.isCompatible(licenses.items[i], licenses.items[j]);
                    const reason = compatibility.getCompatibilityReason(licenses.items[i], licenses.items[j]);
                    const symbol = if (compat) "✓" else "✗";
                    try stdout.print("  {s} {s} + {s}: {s}\n", .{
                        symbol,
                        licenses.items[i].toString(),
                        licenses.items[j].toString(),
                        reason,
                    });
                }
            }
            try stdout.print("\n", .{});
        }

        try stdout.print("Enter licenses (or 'quit' to exit): ", .{});
    }
}

fn runDecisionTree(allocator: std.mem.Allocator, stdout: anytype) !void {
    const stdin = std.fs.File.stdin().deprecatedReader();
    const ui = @import("ui.zig");

    var screen = ui.Screen.init();

    var history = try History.initCapacity(allocator, 0);
    defer history.deinit(allocator);

    var current_node = &decision_tree;
    try history.append(allocator, current_node);

    // Print welcome message (kept as regular prints so it doesn't get cleared)
    try stdout.print("\n=== {s}Repolicense CLI{s} ===\n", .{ BOLD, RESET });
    try stdout.print("Answer the questions with 'yes', 'no', 'back', 'reset', or 'quit'\n to find the best license for your project.\n", .{});
    try stdout.print("\nRun with {s}'--compat'{s} flag (or {s}'-c'{s}) to check license compatibility for forking projects.\n\n", .{ UNDERLINE, RESET, UNDERLINE, RESET });

    var buf: [256]u8 = undefined;

    while (true) {
        if (current_node.node_type == .Question) {
            const content = if (current_node.elaboration.len > 0)
                try std.fmt.allocPrint(allocator, "\n--- {s}Question{s} ---\n{s}\n\n{s}Elaboration: {s}\n{s}\nYour answer (yes/no/back/reset/quit): ", .{ ITALIC, RESET, current_node.content, DIM, current_node.elaboration, RESET })
            else
                try std.fmt.allocPrint(allocator, "\n--- {s}Question{s} ---\n{s}\nYour answer (yes/no/back/reset/quit): ", .{ ITALIC, RESET, current_node.content });

            try screen.render(stdout, content);
            allocator.free(content);
        } else {
            var content = if (current_node.elaboration.len > 0)
                try std.fmt.allocPrint(allocator, "\n--- {s}RESULT{s} ---\nLicense: {s}{s}{s}\n\n{s}{s}{s}\n", .{ BOLD, RESET, BOLD, current_node.content, RESET, DIM, current_node.elaboration, RESET })
            else
                try std.fmt.allocPrint(allocator, "\n--- {s}RESULT{s} ---\nLicense: {s}{s}{s}\n", .{ BOLD, RESET, BOLD, current_node.content, RESET });

            if (!mem.startsWith(u8, current_node.content, "Consider") and !mem.startsWith(u8, current_node.content, "You should")) {
                const links = try std.fmt.allocPrint(allocator, "\nFor more information, visit:\nhttps://api.github.com/licenses/{s}\nhttps://docs.github.com/en/rest/licenses/licenses\n", .{current_node.content});
                const combined = try std.fmt.allocPrint(allocator, "{s}{s}", .{ content, links });
                allocator.free(content);
                allocator.free(links);
                content = combined;
            }

            const content_with_options = try std.fmt.allocPrint(allocator, "{s}\nOptions: back/reset/quit: ", .{content});
            allocator.free(content);
            content = content_with_options;

            try screen.render(stdout, content);
            allocator.free(content);
        }

        const line = (try stdin.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
        const trimmed = mem.trim(u8, line, &std.ascii.whitespace);
        const lower = try std.ascii.allocLowerString(allocator, trimmed);
        defer allocator.free(lower);

        // Clear previous rendered block and the input line the user just entered
        try screen.clearIncludingInput(stdout);

        if (mem.eql(u8, lower, "quit") or mem.eql(u8, lower, "q") or mem.eql(u8, lower, "exit")) {
            // Clear last rendered block before exiting
            try screen.clear(stdout);
            try stdout.print("\nThank you for using Repolicense\n", .{});
            break;
        } else if (mem.eql(u8, lower, "back") or mem.eql(u8, lower, "b")) {
            if (history.items.len > 1) {
                _ = history.pop();
                current_node = history.items[history.items.len - 1];
                // Show a short status message inside the same screen block so it will be overwritten next render
                try screen.render(stdout, "[Moved back]\n");
            } else {
                try screen.render(stdout, "[Already at the beginning]\n");
            }
        } else if (mem.eql(u8, lower, "reset") or mem.eql(u8, lower, "r")) {
            history.clearRetainingCapacity();
            current_node = &decision_tree;
            try history.append(allocator, current_node);
            try screen.render(stdout, "[Reset to beginning]\n");
        } else if (current_node.node_type == .Question) {
            if (mem.eql(u8, lower, "yes") or mem.eql(u8, lower, "y")) {
                if (current_node.yes) |next_node| {
                    current_node = next_node;
                    try history.append(allocator, current_node);
                }
            } else if (mem.eql(u8, lower, "no") or mem.eql(u8, lower, "n")) {
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

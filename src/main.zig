const std = @import("std");
const io = std.io;
const mem = std.mem;
const http = std.http;

// Node types in the decision tree
const NodeType = enum {
    Question,
    Answer,
};

const Node = struct {
    node_type: NodeType,
    content: []const u8,
    elaboration: []const u8,
    yes: ?*const Node,
    no: ?*const Node,
};

// Decision tree structure matching the original JavaScript logic
const decision_tree = buildDecisionTree();

fn buildDecisionTree() Node {
    // Leaf nodes (answers)
    const mit_node = Node{
        .node_type = .Answer,
        .content = "MIT",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const bsd_2_clause = Node{
        .node_type = .Answer,
        .content = "BSD-2-Clause",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const apache_2_0 = Node{
        .node_type = .Answer,
        .content = "Apache-2.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const bsd_3_clause = Node{
        .node_type = .Answer,
        .content = "BSD-3-Clause",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const zero_bsd = Node{
        .node_type = .Answer,
        .content = "0BSD",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const isc = Node{
        .node_type = .Answer,
        .content = "ISC",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const agpl_3_0 = Node{
        .node_type = .Answer,
        .content = "AGPL-3.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const gpl_3_0 = Node{
        .node_type = .Answer,
        .content = "GPL-3.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const gpl_2_0 = Node{
        .node_type = .Answer,
        .content = "GPL-2.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const lgpl_3_0 = Node{
        .node_type = .Answer,
        .content = "LGPL-3.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const mpl_2_0 = Node{
        .node_type = .Answer,
        .content = "MPL-2.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const epl_2_0 = Node{
        .node_type = .Answer,
        .content = "EPL-2.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const epl_1_0 = Node{
        .node_type = .Answer,
        .content = "EPL-1.0",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const unlicense = Node{
        .node_type = .Answer,
        .content = "Unlicense",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const ofl_1_1 = Node{
        .node_type = .Answer,
        .content = "OFL-1.1",
        .elaboration = "",
        .yes = null,
        .no = null,
    };

    const proprietary = Node{
        .node_type = .Answer,
        .content = "Consider using a proprietary license or another specialized license.",
        .elaboration = "You should consider using a proprietary license or another specialized license by consulting with a legal expert.",
        .yes = null,
        .no = null,
    };

    const closed_source = Node{
        .node_type = .Answer,
        .content = "You should consider keeping your project closed-source.",
        .elaboration = "You should consider keeping your project closed-source to protect your intellectual property by not sharing the source code.",
        .yes = null,
        .no = null,
    };

    // Build tree from bottom up
    const simplest_permissive = Node{
        .node_type = .Question,
        .content = "Do you want the simplest and most permissive license possible?",
        .elaboration = "Do you want a license that is very permissive and has minimal requirements, making it as simple as possible for others to use your code.",
        .yes = &mit_node,
        .no = &bsd_2_clause,
    };

    const simplest_no_conditions = Node{
        .node_type = .Question,
        .content = "Do you want the simplest permissive license with no conditions?",
        .elaboration = "Do you want the simplest permissive license with no conditions, providing complete freedom to use the code without any restrictions.",
        .yes = &zero_bsd,
        .no = &isc,
    };

    const permissive_with_conditions = Node{
        .node_type = .Question,
        .content = "Do you want a permissive license with some conditions?",
        .elaboration = "Do you want a permissive license that includes some conditions such as providing attribution and not using the name of the project or its contributors for promotion without permission.",
        .yes = &bsd_3_clause,
        .no = &simplest_no_conditions,
    };

    const explicit_patent_grants = Node{
        .node_type = .Question,
        .content = "Do you want explicit patent grants?",
        .elaboration = "Do you want to include explicit grants of patent rights, which can protect users from patent litigation. This is an important consideration for projects that may involve patented technology.",
        .yes = &apache_2_0,
        .no = &permissive_with_conditions,
    };

    const minimal_conditions = Node{
        .node_type = .Question,
        .content = "Do you require minimal conditions?",
        .elaboration = "Do you want minimal conditions meaning that there are very few requirements placed on the use of your code. This typically includes providing attribution to the original authors.",
        .yes = &simplest_permissive,
        .no = &explicit_patent_grants,
    };

    const latest_gpl = Node{
        .node_type = .Question,
        .content = "Do you want to use the latest version of the GPL license?",
        .elaboration = "Do you prefer using the latest version of the GPL license, which includes additional protections and clarifications compared to older versions.",
        .yes = &gpl_3_0,
        .no = &gpl_2_0,
    };

    const network_server_protection = Node{
        .node_type = .Question,
        .content = "Do you want network server protection?",
        .elaboration = "Do you want to extend copyleft requirements to software provided over a network. This means that users who interact with the software over a network (e.g., web applications) must also have access to the source code.",
        .yes = &agpl_3_0,
        .no = &latest_gpl,
    };

    const business_friendly_copyleft = Node{
        .node_type = .Question,
        .content = "Do you prefer a copyleft license with a focus on business-friendly terms?",
        .elaboration = "Do you prefer a copyleft license that has a focus on business-friendly terms, making it easier for companies to adopt.",
        .yes = &epl_2_0,
        .no = &epl_1_0,
    };

    const weaker_copyleft = Node{
        .node_type = .Question,
        .content = "Do you want a copyleft license with weaker requirements?",
        .elaboration = "Do you want a copyleft license that has weaker requirements compared to the GPL, such as allowing proprietary modules in your project.",
        .yes = &mpl_2_0,
        .no = &business_friendly_copyleft,
    };

    const allow_linking = Node{
        .node_type = .Question,
        .content = "Do you want to allow linking with non-(L)GPL software?",
        .elaboration = "Do you want to allow linking with non-(L)GPL software, making it easier to use your code as a library in proprietary software while keeping modifications to the library itself open source.",
        .yes = &lgpl_3_0,
        .no = &weaker_copyleft,
    };

    const strong_copyleft = Node{
        .node_type = .Question,
        .content = "Do you want strong copyleft?",
        .elaboration = "Do you want to require that any distributed modifications (or in some cases, software that interacts with the copylefted code) also be open-sourced. This ensures that improvements to the code are shared with the community.",
        .yes = &network_server_protection,
        .no = &allow_linking,
    };

    const font_license = Node{
        .node_type = .Question,
        .content = "Do you want a license for fonts?",
        .elaboration = "Do you want a license specifically designed for fonts, allowing embedding, modifying, and redistributing the font.",
        .yes = &ofl_1_1,
        .no = &proprietary,
    };

    const public_domain = Node{
        .node_type = .Question,
        .content = "Do you want to dedicate your work to the public domain?",
        .elaboration = "Do you want to dedicate your work to the public domain, allowing anyone to use, modify, and distribute your work without any restrictions.",
        .yes = &unlicense,
        .no = &font_license,
    };

    const copyleft_license = Node{
        .node_type = .Question,
        .content = "Do you want a copyleft license?",
        .elaboration = "Do you want to require that any modified versions of your code be distributed under the same license, ensuring that the code (and its derivatives) remain open source.",
        .yes = &strong_copyleft,
        .no = &public_domain,
    };

    const permissive_license = Node{
        .node_type = .Question,
        .content = "Do you want a permissive license?",
        .elaboration = "Do you want a more lenient license and allow others to use, modify, and distribute your code with minimal restrictions. These licenses are generally business-friendly and encourage wider use.",
        .yes = &minimal_conditions,
        .no = &copyleft_license,
    };

    const root = Node{
        .node_type = .Question,
        .content = "Do you want to open-source your project?",
        .elaboration = "Do you want to make your source code publicly available and allow others to use, modify, and distribute it.",
        .yes = &permissive_license,
        .no = &closed_source,
    };

    return root;
}

const History = std.ArrayList(*const Node);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();

    var history = History.init(allocator);
    defer history.deinit();

    var current_node = &decision_tree;
    try history.append(current_node);

    // Print welcome message
    try stdout.print("\n=== Repolicense CLI ===\n", .{});
    try stdout.print("Welcome to Repolicense! This tool helps you choose the right open-source license.\n", .{});
    try stdout.print("Answer the questions with 'yes', 'no', 'back', 'reset', or 'quit'.\n\n", .{});

    var buf: [256]u8 = undefined;

    while (true) {
        if (current_node.node_type == .Question) {
            try stdout.print("\n--- Question ---\n", .{});
            try stdout.print("{s}\n", .{current_node.content});
            if (current_node.elaboration.len > 0) {
                try stdout.print("\nElaboration: {s}\n", .{current_node.elaboration});
            }
            try stdout.print("\nYour answer (yes/no/back/reset/quit): ", .{});
        } else {
            try stdout.print("\n=== RESULT ===\n", .{});
            try stdout.print("License: {s}\n", .{current_node.content});
            if (current_node.elaboration.len > 0) {
                try stdout.print("\n{s}\n", .{current_node.elaboration});
            }
            
            // For official licenses, provide GitHub API link
            if (!mem.startsWith(u8, current_node.content, "Consider") and 
                !mem.startsWith(u8, current_node.content, "You should")) {
                try stdout.print("\nFor more information, visit:\n", .{});
                try stdout.print("https://api.github.com/licenses/{s}\n", .{current_node.content});
                try stdout.print("https://docs.github.com/en/rest/licenses/licenses\n", .{});
            }
            
            try stdout.print("\nOptions: back/reset/quit: ", .{});
        }

        const line = (try stdin.readUntilDelimiterOrEof(&buf, '\n')) orelse break;
        const trimmed = mem.trim(u8, line, &std.ascii.whitespace);
        const lower = try std.ascii.allocLowerString(allocator, trimmed);
        defer allocator.free(lower);

        if (mem.eql(u8, lower, "quit") or mem.eql(u8, lower, "q") or mem.eql(u8, lower, "exit")) {
            try stdout.print("\nThank you for using Repolicense!\n", .{});
            break;
        } else if (mem.eql(u8, lower, "back") or mem.eql(u8, lower, "b")) {
            if (history.items.len > 1) {
                _ = history.pop();
                current_node = history.items[history.items.len - 1];
                try stdout.print("\n[Moved back]\n", .{});
            } else {
                try stdout.print("\n[Already at the beginning]\n", .{});
            }
        } else if (mem.eql(u8, lower, "reset") or mem.eql(u8, lower, "r")) {
            history.clearRetainingCapacity();
            current_node = &decision_tree;
            try history.append(current_node);
            try stdout.print("\n[Reset to beginning]\n", .{});
        } else if (current_node.node_type == .Question) {
            if (mem.eql(u8, lower, "yes") or mem.eql(u8, lower, "y")) {
                if (current_node.yes) |next_node| {
                    current_node = next_node;
                    try history.append(current_node);
                }
            } else if (mem.eql(u8, lower, "no") or mem.eql(u8, lower, "n")) {
                if (current_node.no) |next_node| {
                    current_node = next_node;
                    try history.append(current_node);
                }
            } else {
                try stdout.print("\n[Invalid input. Please enter yes, no, back, reset, or quit]\n", .{});
            }
        } else {
            try stdout.print("\n[Invalid command. Use back, reset, or quit]\n", .{});
        }
    }
}

const std = @import("std");
const testing = std.testing;
const tree = @import("tree.zig");
const catalog = @import("licenses.zig");

const Expected = union(enum) { license: []const u8, advice: void };
const PathCase = struct { path: []const bool, expected: Expected };

const path_cases = [_]PathCase{
    .{ .path = &.{ true, true }, .expected = .{ .license = "OFL-1.1" } },
    .{ .path = &.{ true, false }, .expected = .{ .advice = {} } },
    .{ .path = &.{ false, false }, .expected = .{ .advice = {} } },
    .{ .path = &.{ false, true, false }, .expected = .{ .advice = {} } },
    .{ .path = &.{ false, true, true, false, true }, .expected = .{ .license = "Apache-2.0" } },
    .{ .path = &.{ false, true, true, false, false, true }, .expected = .{ .license = "Unlicense" } },
    .{ .path = &.{ false, true, true, false, false, false, true }, .expected = .{ .license = "0BSD" } },
    .{ .path = &.{ false, true, true, false, false, false, false, true, false }, .expected = .{ .license = "BSL-1.0" } },
    .{ .path = &.{ false, true, true, false, false, false, false, true, true }, .expected = .{ .license = "Zlib" } },
    .{ .path = &.{ false, true, true, false, false, false, false, false, true }, .expected = .{ .license = "BSD-3-Clause" } },
    .{ .path = &.{ false, true, true, false, false, false, false, false, false, true }, .expected = .{ .license = "BSD-2-Clause" } },
    .{ .path = &.{ false, true, true, false, false, false, false, false, false, false, true }, .expected = .{ .license = "ISC" } },
    .{ .path = &.{ false, true, true, false, false, false, false, false, false, false, false }, .expected = .{ .license = "MIT" } },
    .{ .path = &.{ false, true, true, true, true, true }, .expected = .{ .license = "AGPL-3.0-or-later" } },
    .{ .path = &.{ false, true, true, true, true, false }, .expected = .{ .license = "AGPL-3.0-only" } },
    .{ .path = &.{ false, true, true, true, false, true, true, true }, .expected = .{ .license = "GPL-2.0-or-later" } },
    .{ .path = &.{ false, true, true, true, false, true, true, false }, .expected = .{ .license = "GPL-2.0-only" } },
    .{ .path = &.{ false, true, true, true, false, true, false, true }, .expected = .{ .license = "GPL-3.0-or-later" } },
    .{ .path = &.{ false, true, true, true, false, true, false, false }, .expected = .{ .license = "GPL-3.0-only" } },
    .{ .path = &.{ false, true, true, true, false, false, true, true, true }, .expected = .{ .license = "LGPL-2.1-or-later" } },
    .{ .path = &.{ false, true, true, true, false, false, true, true, false }, .expected = .{ .license = "LGPL-2.1-only" } },
    .{ .path = &.{ false, true, true, true, false, false, true, false, true }, .expected = .{ .license = "LGPL-3.0-or-later" } },
    .{ .path = &.{ false, true, true, true, false, false, true, false, false }, .expected = .{ .license = "LGPL-3.0-only" } },
    .{ .path = &.{ false, true, true, true, false, false, false, true }, .expected = .{ .license = "MPL-2.0" } },
    .{ .path = &.{ false, true, true, true, false, false, false, false, true, true }, .expected = .{ .license = "EPL-1.0" } },
    .{ .path = &.{ false, true, true, true, false, false, false, false, true, false }, .expected = .{ .license = "EPL-2.0" } },
    .{ .path = &.{ false, true, true, true, false, false, false, false, false }, .expected = .{ .advice = {} } },
};

test "preference paths reach every recommendation and advisory" {
    for (path_cases) |case| {
        var node: *const tree.Node = &tree.decision_tree;
        for (case.path) |answer| {
            try testing.expectEqual(tree.NodeType.Question, node.node_type);
            node = if (answer) node.yes orelse return error.MissingQuestionBranch else node.no orelse return error.MissingQuestionBranch;
        }
        try testing.expectEqual(tree.NodeType.Answer, node.node_type);
        switch (case.expected) {
            .license => |identifier| {
                const license = catalog.License.fromString(identifier) orelse return error.UnknownExpectedLicense;
                try testing.expectEqual(license, node.license.?);
            },
            .advice => try testing.expect(node.license == null),
        }
    }
}

fn countTrue(values: []const bool) usize {
    var count: usize = 0;
    for (values) |value| if (value) {
        count += 1;
    };
    return count;
}

test "decision graph has complete branches, valid leaves, reachability, and no cycles" {
    var stack: [128]*const tree.Node = undefined;
    var recommendations: [catalog.all.len]bool = @splat(false);
    try inspect(&tree.decision_tree, &stack, 0, &recommendations);
    try testing.expectEqual(catalog.all.len, countTrue(&recommendations));
}

fn inspect(node: *const tree.Node, stack: *[128]*const tree.Node, depth: usize, recommendations: *[catalog.all.len]bool) !void {
    try testing.expect(depth < stack.len);
    for (stack[0..depth]) |ancestor| try testing.expect(ancestor != node);
    stack[depth] = node;

    switch (node.node_type) {
        .Question => {
            try testing.expect(node.license == null);
            try inspect(node.yes orelse return error.MissingQuestionBranch, stack, depth + 1, recommendations);
            try inspect(node.no orelse return error.MissingQuestionBranch, stack, depth + 1, recommendations);
        },
        .Answer => {
            try testing.expect(node.yes == null);
            try testing.expect(node.no == null);
            if (node.license) |license| {
                inline for (catalog.all, 0..) |known, index| {
                    if (known == license) recommendations[index] = true;
                }
            }
        },
    }
}

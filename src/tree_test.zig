const std = @import("std");
const testing = std.testing;
const tree = @import("tree.zig");

test "decision tree root exists and is a question" {
    try testing.expect(tree.decision_tree.node_type == .Question);
    try testing.expect(tree.decision_tree.content.len > 0);
}

test "decision tree root has both yes and no branches" {
    try testing.expect(tree.decision_tree.yes != null);
    try testing.expect(tree.decision_tree.no != null);
}

test "all answer nodes have null yes/no pointers" {
    // Test some known answer nodes by traversing the tree
    const closed_source = tree.decision_tree.no.?;
    try testing.expect(closed_source.node_type == .Answer);
    try testing.expect(closed_source.yes == null);
    try testing.expect(closed_source.no == null);
}

test "MIT license is reachable from root" {
    // Path: yes > yes > yes > yes
    const permissive = tree.decision_tree.yes.?;
    try testing.expect(permissive.node_type == .Question);

    const minimal = permissive.yes.?;
    try testing.expect(minimal.node_type == .Question);

    const simplest = minimal.yes.?;
    try testing.expect(simplest.node_type == .Question);

    const mit = simplest.yes.?;
    try testing.expect(mit.node_type == .Answer);
    try testing.expect(std.mem.eql(u8, mit.content, "MIT"));
}

test "Apache-2.0 license is reachable from root" {
    // Path: yes > yes > no > yes
    const permissive = tree.decision_tree.yes.?;
    const minimal = permissive.yes.?;
    const explicit_patents = minimal.no.?;
    try testing.expect(explicit_patents.node_type == .Question);

    const apache = explicit_patents.yes.?;
    try testing.expect(apache.node_type == .Answer);
    try testing.expect(std.mem.eql(u8, apache.content, "Apache-2.0"));
}

test "GPL-3.0 license is reachable from root" {
    // Path: yes > no > yes > yes > no > yes
    const permissive = tree.decision_tree.yes.?;
    const copyleft = permissive.no.?;
    try testing.expect(copyleft.node_type == .Question);

    const strong = copyleft.yes.?;
    try testing.expect(strong.node_type == .Question);

    const network = strong.yes.?;
    try testing.expect(network.node_type == .Question);

    const latest_gpl = network.no.?;
    try testing.expect(latest_gpl.node_type == .Question);

    const gpl3 = latest_gpl.yes.?;
    try testing.expect(gpl3.node_type == .Answer);
    try testing.expect(std.mem.eql(u8, gpl3.content, "GPL-3.0"));
}

test "tree has proper structure with no null dereferencing" {
    // Walk through several paths to ensure no crashes
    var paths_tested: usize = 0;

    // Test permissive branch
    if (tree.decision_tree.yes) |permissive| {
        paths_tested += 1;
        try testing.expect(permissive.node_type == .Question);

        if (permissive.yes) |minimal| {
            paths_tested += 1;
            try testing.expect(minimal.node_type == .Question);
        }

        if (permissive.no) |copyleft| {
            paths_tested += 1;
            try testing.expect(copyleft.node_type == .Question);
        }
    }

    // Test closed source branch
    if (tree.decision_tree.no) |closed| {
        paths_tested += 1;
        try testing.expect(closed.node_type == .Answer);
    }

    try testing.expect(paths_tested == 4);
}

test "all question nodes have content and elaboration" {
    // Test root node
    try testing.expect(tree.decision_tree.content.len > 0);
    try testing.expect(tree.decision_tree.elaboration.len > 0);

    // Test a few more nodes
    const permissive = tree.decision_tree.yes.?;
    try testing.expect(permissive.content.len > 0);
    try testing.expect(permissive.elaboration.len > 0);
}

test "NodeType enum has correct values" {
    try testing.expect(@TypeOf(tree.NodeType.Question) == tree.NodeType);
    try testing.expect(@TypeOf(tree.NodeType.Answer) == tree.NodeType);
}

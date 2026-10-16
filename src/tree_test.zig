const std = @import("std");
const testing = std.testing;
const tree = @import("tree.zig");
const catalog = @import("licenses.zig");

test "all catalog licenses have reachable recommendation outcomes" {
    var reached: [catalog.all.len]bool = @splat(false);
    var seen: [std.meta.tags(tree.Id).len]bool = @splat(false);
    var stack: [std.meta.tags(tree.Id).len]bool = @splat(false);
    try visit(.work_type, &seen, &stack, &reached);
    for (reached) |value| try testing.expect(value);
}

fn visit(id: tree.Id, seen: *[std.meta.tags(tree.Id).len]bool, stack: *[std.meta.tags(tree.Id).len]bool, reached: *[catalog.all.len]bool) !void {
    const index = @backingInt(id);
    try testing.expect(!stack[index]);
    if (seen[index]) return;
    stack[index] = true;
    seen[index] = true;
    const current = tree.node(id);
    if (current.license) |license| {
        var found = false;
        inline for (catalog.all, 0..) |known, license_index| {
            if (known == license) {
                reached[license_index] = true;
                found = true;
            }
        }
        try testing.expect(found);
        try testing.expect(current.choices.len == 0);
        try testing.expect(current.advisory == null);
    } else if (current.advisory != null) {
        try testing.expect(current.choices.len == 0);
    } else {
        try testing.expect(current.choices.len > 0);
        for (current.choices) |choice| try visit(choice.next, seen, stack, reached);
    }
    stack[index] = false;
}

fn route(ids: []const tree.Id) !tree.Id {
    var current = ids[0];
    for (ids[1..]) |destination| {
        var found = false;
        for (tree.node(current).choices) |choice| {
            if (choice.next == destination) {
                current = destination;
                found = true;
                break;
            }
        }
        if (!found) return error.NonEdgeRoute;
    }
    return current;
}

test "unsupported assets, ownership, existing terms, and font mismatch are distinct outcomes" {
    try testing.expectEqual(tree.Advice.out_of_scope, tree.node(try route(&.{ .work_type, .out_of_scope })).advisory.?);
    try testing.expectEqual(tree.Advice.ownership, tree.node(try route(&.{ .work_type, .software, .ownership })).advisory.?);
    try testing.expectEqual(tree.Advice.existing_terms, tree.node(try route(&.{ .work_type, .software, .owned, .existing_terms })).advisory.?);
    try testing.expectEqual(tree.Advice.font_mismatch, tree.node(try route(&.{ .work_type, .font, .font_owned, .font_terms, .font_mismatch })).advisory.?);
    try testing.expectEqual(tree.Advice.reserved_rights, tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .reserved_rights })).advisory.?);
}

test "font help preserves the explicit acceptance boundary" {
    try testing.expectEqual(tree.Advice.font_mismatch, tree.node(try route(&.{ .work_type, .font, .font_owned, .font_terms, .font_help, .font_mismatch })).advisory.?);
    try testing.expectEqual(catalog.License.@"OFL-1.1", tree.node(try route(&.{ .work_type, .font, .font_owned, .font_terms, .font_help, .ofl })).license.?);
}

test "common new software path reaches MIT within six actual selections" {
    const ids = [_]tree.Id{ .work_type, .software, .owned, .new_work, .open_source, .permissive, .mit };
    try testing.expectEqual(catalog.License.MIT, tree.node(try route(&ids)).license.?);
    try testing.expect(ids.len - 1 <= 6);
}

test "advanced permissive routes remain reachable" {
    try testing.expectEqual(catalog.License.Zlib, tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .permissive, .advanced_permissive, .zlib })).license.?);
    try testing.expectEqual(catalog.License.@"EPL-1.0", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .eclipse_scope, .epl1 })).license.?);
}

test "copyleft scope and network preference select distinct families" {
    try testing.expectEqual(catalog.License.@"AGPL-3.0-only", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .whole_program, .network, .agpl_only })).license.?);
    try testing.expectEqual(catalog.License.@"GPL-3.0-only", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .whole_program, .ordinary, .gpl3_only })).license.?);
    try testing.expectEqual(catalog.License.@"MPL-2.0", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .file_scope, .mpl })).license.?);
    try testing.expectEqual(catalog.License.@"LGPL-3.0-only", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .library_scope, .lgpl3_only })).license.?);
}

test "GNU later-version grants are explicit choices" {
    try testing.expectEqual(catalog.License.@"GPL-3.0-only", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .whole_program, .ordinary, .gpl3_only })).license.?);
    try testing.expectEqual(catalog.License.@"GPL-3.0-or-later", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .whole_program, .ordinary, .gpl3_later })).license.?);
    try testing.expectEqual(catalog.License.@"LGPL-2.1-only", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .library_scope, .lgpl21_version, .lgpl21_only })).license.?);
    try testing.expectEqual(catalog.License.@"LGPL-2.1-or-later", tree.node(try route(&.{ .work_type, .software, .owned, .new_work, .open_source, .copyleft, .library_scope, .lgpl21_version, .lgpl21_later })).license.?);
}

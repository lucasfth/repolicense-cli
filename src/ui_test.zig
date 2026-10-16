const std = @import("std");
const testing = std.testing;
const ui = @import("ui.zig");

const labels = [_][]const u8{ "Yes", "No", "Back", "Restart", "Quit" };

test "choice parser accepts one-based numbers and exact labels" {
    try testing.expectEqual(@as(?usize, 0), try ui.parseChoice("1", &labels));
    try testing.expectEqual(@as(?usize, 2), try ui.parseChoice("3", &labels));
    try testing.expectEqual(@as(?usize, 4), try ui.parseChoice("5", &labels));
    try testing.expectEqual(@as(?usize, 1), try ui.parseChoice("No", &labels));
}

test "choice parser accepts yes, no, and navigation shortcuts" {
    try testing.expectEqual(@as(?usize, 0), try ui.parseChoice("y", &labels));
    try testing.expectEqual(@as(?usize, 1), try ui.parseChoice("N", &labels));
    try testing.expectEqual(@as(?usize, 2), try ui.parseChoice("b", &labels));
    try testing.expectEqual(@as(?usize, 3), try ui.parseChoice("reset", &labels));
    try testing.expectEqual(@as(?usize, 4), try ui.parseChoice("exit", &labels));
    try testing.expectError(error.InvalidSelection, ui.parseChoice("y", labels[2..]));
}

test "choice parser rejects blank, invalid, and out-of-range selections" {
    try testing.expectError(error.InvalidSelection, ui.parseChoice("", &labels));
    try testing.expectError(error.InvalidSelection, ui.parseChoice("0", &labels));
    try testing.expectError(error.InvalidSelection, ui.parseChoice("6", &labels));
    try testing.expectError(error.InvalidSelection, ui.parseChoice("maybe", &labels));
}

test "multiple parser maps labels and numbers while removing duplicates" {
    const choices = [_][]const u8{ "MIT", "Apache-2.0", "MPL-2.0" };
    var output: [3]usize = undefined;
    const result = try ui.parseMany("MPL-2.0, 2, MPL-2.0", &choices, &output);
    try testing.expectEqualSlices(usize, &.{ 2, 1 }, result.?);
}

test "multiple parser accepts cancellation and rejects invalid bounds" {
    var output: [4]usize = undefined;
    try testing.expectEqual(@as(?[]const usize, null), try ui.parseMany("q", &labels, &output));
    try testing.expectError(error.InvalidSelection, ui.parseMany("1,6", &labels, &output));
}

test "multiple parser rejects selections that exceed output capacity" {
    var output: [1]usize = undefined;
    try testing.expectError(error.SelectionBufferTooSmall, ui.parseMany("1,2", &labels, &output));
}

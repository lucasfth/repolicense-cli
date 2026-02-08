const std = @import("std");
const testing = std.testing;
const ui = @import("ui.zig");

// A tiny writer that collects printed bytes into an ArrayList(u8).
const CaptureWriter = struct {
    allocator: std.mem.Allocator,
    buf: *std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, buf: *std.ArrayList(u8)) CaptureWriter {
        return CaptureWriter{ .allocator = allocator, .buf = buf };
    }

    pub fn print(self: *CaptureWriter, comptime fmt: []const u8, args: anytype) !void {
        const s = try std.fmt.allocPrint(self.allocator, fmt, args);
        defer self.allocator.free(s);
        for (s) |c| {
            try self.buf.append(self.allocator, c);
        }
    }
};

test "Screen.render overwrites previous content" {
    const allocator = testing.allocator;

    var buf = try std.ArrayList(u8).initCapacity(allocator, 0);
    defer buf.deinit(allocator);

    var writer = CaptureWriter.init(allocator, &buf);

    var screen = ui.Screen.init();

    // First render: should simply print the content (no clear sequences)
    try screen.render(&writer, "first line\nsecond line\n");
    const out1 = try buf.toOwnedSlice(allocator);
    defer allocator.free(out1);

    try testing.expect(std.mem.indexOf(u8, out1, "first line\n") != null);

    // Second render: should include clear sequences before printing new content
    try screen.render(&writer, "only line\n");
    const out2 = try buf.toOwnedSlice(allocator);
    defer allocator.free(out2);

    const esc = "\x1b[1A\x1b[2K";
    try testing.expect(std.mem.indexOf(u8, out2, esc) != null);
    try testing.expect(std.mem.indexOf(u8, out2, "only line\n") != null);
}

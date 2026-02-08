const std = @import("std");

pub const Screen = struct {
    lines_printed: usize,

    pub fn init() Screen {
        return Screen{ .lines_printed = 0 };
    }

    /// Render the given content by clearing the previously-rendered
    /// block and printing the new content. This uses simple ANSI
    /// escape sequences and assumes a terminal supporting them.
    pub fn render(self: *Screen, stdout: anytype, content: []const u8) !void {
        // Clear previous block by moving the cursor up and clearing lines
        if (self.lines_printed > 0) {
            var i: usize = 0;
            while (i < self.lines_printed) : (i += 1) {
                // Move cursor up 1 line, then clear the entire line
                try stdout.print("\x1b[1A\x1b[2K", .{});
            }
        }

        // Print new content
        try stdout.print("{s}", .{content});

        // Count lines in content to know how many to clear next time.
        var count: usize = 1;
        for (content) |c| {
            if (c == '\n') count += 1;
        }
        self.lines_printed = count;
    }

    /// Explicitly clear the currently-rendered block.
    pub fn clear(self: *Screen, stdout: anytype) !void {
        if (self.lines_printed > 0) {
            var i: usize = 0;
            while (i < self.lines_printed) : (i += 1) {
                try stdout.print("\x1b[1A\x1b[2K", .{});
            }
            self.lines_printed = 0;
        }
    }

    /// Clear the rendered block and the user input line that followed it.
    pub fn clearIncludingInput(self: *Screen, stdout: anytype) !void {
        // Always clear the previously-rendered block lines first
        if (self.lines_printed > 0) {
            var i: usize = 0;
            while (i < self.lines_printed) : (i += 1) {
                try stdout.print("\x1b[1A\x1b[2K", .{});
            }
            self.lines_printed = 0;
        }
        // Also clear the user's input line (the line after the rendered block)
        try stdout.print("\x1b[1A\x1b[2K", .{});
    }
};

const std = @import("std");

const input = @embedFile("input/day01.txt").*;

pub fn main() !void {
    std.debug.print("Hello from day01!\n", .{});
    std.debug.print("{s}\n", .{input});
    std.debug.print("input length: {}\n", .{input.len});
}

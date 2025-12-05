const std = @import("std");

const input_data = @embedFile("input/day05.txt");
const test_input_data = @embedFile("input/test/day05.txt");

var fresh_ingredient_ranges: std.ArrayList([2]i64) = undefined;
var ingredient_ids: std.ArrayList(i64) = undefined;
var allocator: std.mem.Allocator = undefined;

fn parse_input(comptime input: []const u8) !void {
    allocator = std.heap.page_allocator;
    fresh_ingredient_ranges = .{};
    ingredient_ids = .{};

    // I dislike windows line endings
    var lines = std.mem.splitSequence(u8, input, "\r\n");
    while (lines.next()) |line| {
        if (line.len == 0) break;

        var range = std.mem.tokenizeAny(u8, line, "-");
        const range_start = try std.fmt.parseInt(i64, range.next().?, 10);
        const range_end = try std.fmt.parseInt(i64, range.next().?, 10);

        try fresh_ingredient_ranges.append(allocator, .{ range_start, range_end });
    }

    while (lines.next()) |line| {
        if (line.len == 0) break;

        const ingredient_id = try std.fmt.parseInt(i64, line, 10);
        try ingredient_ids.append(allocator, ingredient_id);
    }
}

pub fn main() !void {
    try parse_input(input_data);
    defer fresh_ingredient_ranges.deinit(allocator);
    defer ingredient_ids.deinit(allocator);

    const num_fresh_ingredients = try part1();
    std.debug.print("The number of fresh ingredients for part1 is: {d}\n", .{num_fresh_ingredients});

    const num_unique_ingredients = try part2();
    std.debug.print("The number of fresh unique ingredient ids for part2 is: {d}\n", .{num_unique_ingredients});
}

fn part1() !i64 {
    var num_fresh_ingredients: isize = 0;
    for (ingredient_ids.items) |ingredient_id| {
        for (fresh_ingredient_ranges.items) |fresh_ingredient_range| {
            const range_start = fresh_ingredient_range[0];
            const range_end = fresh_ingredient_range[1];
            if (range_start <= ingredient_id and ingredient_id <= range_end) {
                num_fresh_ingredients += 1;
                break;
            }
        }
    }

    return num_fresh_ingredients;
}

fn part2() !i64 {
    // Sort by range begin
    std.mem.sort([2]i64, fresh_ingredient_ranges.items, {}, struct {
        pub fn lessThan(ctx: void, a: [2]i64, b: [2]i64) bool {
            _ = ctx;
            return a[0] < b[0];
        }
    }.lessThan);

    var num_unique: i64 = 0;
    var prev_end: i64 = 0;
    for (fresh_ingredient_ranges.items) |range| {
        const start = range[0];
        const end = range[1];

        if (end <= prev_end) continue;

        const left = if (prev_end >= start) prev_end else blk: {
            num_unique += 1;
            break :blk start;
        };

        num_unique += end - left;
        prev_end = end;
    }

    return num_unique;
}

test "day05 part1" {
    try parse_input(test_input_data);
    defer fresh_ingredient_ranges.deinit(allocator);
    defer ingredient_ids.deinit(allocator);

    const num_fresh = try part1();
    try std.testing.expect(num_fresh == 3);
}

test "day05 part2" {
    try parse_input(test_input_data);
    defer fresh_ingredient_ranges.deinit(allocator);
    defer ingredient_ids.deinit(allocator);

    const num_unique = try part2();
    try std.testing.expect(num_unique == 14);
}

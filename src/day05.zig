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

    var lines = std.mem.splitAny(u8, input, "\n");
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

    const num_fresh_ingredients1 = try part1();
    std.debug.print("The number of fresh ingredients for part1 is: {d}\n", .{num_fresh_ingredients1});

    const num_fresh_ingredients2 = try part2();
    std.debug.print("The number of fresh ingredients for part2 is: {d}\n", .{num_fresh_ingredients2});
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
    // // need a way to either combine the ranges, or reduce them to
    // // be non-overlapping
    // var non_overlapping_ranges = std.ArrayList([2]i64){};
    // defer non_overlapping_ranges.deinit(allocator);
    //
    // outer: for (fresh_ingredient_ranges.items) |range| {
    //     var range_start = range[0];
    //     var range_end = range[1];
    //
    //     // split
    //
    //     for (non_overlapping_ranges.items) |non_overlapping_range| {
    //         const non_overlapping_start = non_overlapping_range[0];
    //         const non_overlapping_end = non_overlapping_range[1];
    //
    //         // completely to the right
    //         if (non_overlapping_end <= range_start) continue;
    //
    //         // completely to the left
    //         if (range_end <= non_overlapping_start) continue;
    //
    //         // lies completely in the middle of the range, don't need it
    //         if (non_overlapping_start <= range_start and range_end <= non_overlapping_end) continue :outer;
    //
    //         // lies on the left
    //         if (range_start <= non_overlapping_start and range_end <= non_overlapping_end) {
    //             range_end = non_overlapping_start - 1;
    //             //range[1] = non_overlapping_start - 1;
    //             continue;
    //         }
    //
    //         // lies on the right
    //         if (non_overlapping_start <= range_start and non_overlapping_end <= range_end) {
    //             range_start = non_overlapping_end + 1;
    //             //range[0] = non_overlapping_end + 1;
    //             continue;
    //         }
    //
    //         std.debug.print("range: {d}-{d}\n", .{ range_start, range_end });
    //         std.debug.print("non_overlapping_range: {d}-{d}\n", .{ non_overlapping_start, non_overlapping_end });
    //
    //         unreachable;
    //     }
    //
    //     try non_overlapping_ranges.append(allocator, .{ range_start, range_end });
    // }
    //
    // std.debug.print("non_overlapping_ranges\n", .{});
    // for (non_overlapping_ranges.items) |range| {
    //     std.debug.print("{d}-{d}\n", .{ range[0], range[1] });
    // }
    //
    // var num: isize = 0;
    // for (non_overlapping_ranges.items) |range| {
    //     const num_in_range = range[1] - range[0] + 1;
    //     num += num_in_range;
    // }
    //
    // return num;

    var valid_ingredient_ids = std.AutoHashMap(i64, void).init(allocator);
    defer valid_ingredient_ids.deinit();
    for (fresh_ingredient_ranges.items) |fresh_ingredient_range| {
        std.debug.print("hit range\n", .{});
        const range_start = fresh_ingredient_range[0];
        const range_end = fresh_ingredient_range[1];

        var current_id = range_start;
        while (current_id <= range_end) : (current_id += 1) {
            try valid_ingredient_ids.put(current_id, {});
        }
    }

    return valid_ingredient_ids.count();
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

    const num_fresh = try part2();
    try std.testing.expect(num_fresh == 14);
}

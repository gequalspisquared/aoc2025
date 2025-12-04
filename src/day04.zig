const std = @import("std");

const input_data = @embedFile("input/day04.txt");
const test_input_data = @embedFile("input/test/day04.txt");

pub fn main() !void {
    const accessible_rolls1 = try part1(input_data);
    std.debug.print("The number of accessible rolls for part1 is: {d}\n", .{accessible_rolls1});

    const accessible_rolls2 = try part2(input_data);
    std.debug.print("The number of accessible rolls for part2 is: {d}\n", .{accessible_rolls2});
}

const Grid = struct {
    cols: usize,
    rows: usize,
    data: []u8,

    const Self = @This();

    pub fn init(comptime input: []const u8, allocator: std.mem.Allocator) !Self {
        var grid_rows = std.mem.tokenizeAny(u8, input, "\n");
        const num_cols = grid_rows.peek().?.len;
        const num_rows = input.len / (num_cols + 1);

        // load into an array
        var grid = try allocator.alloc(u8, num_cols * num_rows);

        var cur_row: usize = 0;
        while (grid_rows.next()) |grid_row| {
            for (grid_row, 0..) |val, cur_col| {
                grid[cur_row * num_cols + cur_col] = val;
            }

            cur_row += 1;
        }

        return .{ .cols = num_cols, .rows = num_rows, .data = grid };
    }

    pub fn deinit(self: Self, allocator: std.mem.Allocator) void {
        // NEEDS TO BE THE SAME ALLOCATOR FROM .init()!
        allocator.free(self.data);
    }

    pub fn at(self: Self, x: usize, y: usize) u8 {
        return self.data[y * self.cols + x];
    }

    pub fn setAt(self: *Self, x: usize, y: usize, val: u8) void {
        self.data[y * self.cols + x] = val;
    }

    pub fn printAt(self: Self, x: usize, y: usize) void {
        std.debug.print("[{d}, {d}] = {c}\n", .{ x, y, self.at(x, y) });
    }

    pub fn inBounds(self: Self, x: isize, y: isize) bool {
        return x >= 0 and x < self.cols and y >= 0 and y < self.rows;
    }
};

fn part1(comptime input: []const u8) !i64 {
    var buffer: [139 * 139]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const grid = try Grid.init(input, allocator);
    defer grid.deinit(allocator);

    var num_accessible: i64 = 0;
    var y: isize = 0;
    while (y < grid.rows) : (y += 1) {
        var x: isize = 0;
        outer: while (x < grid.cols) : (x += 1) {
            if (grid.at(@intCast(x), @intCast(y)) != '@') continue;

            var num_surrounding_rolls: usize = 0;
            var check_y: isize = -1;
            while (check_y <= 1) : (check_y += 1) {
                var check_x: isize = -1;
                while (check_x <= 1) : (check_x += 1) {
                    if (check_x == 0 and check_y == 0) continue;

                    const _x = x + check_x;
                    const _y = y + check_y;

                    if (grid.inBounds(_x, _y) and grid.at(@intCast(_x), @intCast(_y)) == '@') {
                        num_surrounding_rolls += 1;
                        if (num_surrounding_rolls >= 4) {
                            continue :outer;
                        }
                    }
                }
            }

            num_accessible += 1;
        }
    }

    return num_accessible;
}

fn part2(comptime input: []const u8) !i64 {
    var buffer: [139 * 139]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var grid = try Grid.init(input, allocator);
    defer grid.deinit(allocator);

    var num_accessible: i64 = 0;
    while (true) {
        const initial_num_accessible: i64 = num_accessible;
        var y: isize = 0;
        while (y < grid.rows) : (y += 1) {
            var x: isize = 0;
            outer: while (x < grid.cols) : (x += 1) {
                if (grid.at(@intCast(x), @intCast(y)) != '@') continue;

                var num_surrounding_rolls: usize = 0;
                var check_y: isize = -1;
                while (check_y <= 1) : (check_y += 1) {
                    var check_x: isize = -1;
                    while (check_x <= 1) : (check_x += 1) {
                        if (check_x == 0 and check_y == 0) continue;

                        const _x = x + check_x;
                        const _y = y + check_y;

                        if (grid.inBounds(_x, _y) and (grid.at(@intCast(_x), @intCast(_y)) == '@' or grid.at(@intCast(_x), @intCast(_y)) == 'x')) {
                            num_surrounding_rolls += 1;
                            if (num_surrounding_rolls >= 4) {
                                // mark for removal
                                continue :outer;
                            }
                        }
                    }
                }

                grid.setAt(@intCast(x), @intCast(y), 'x');
                num_accessible += 1;
            }
        }

        if (num_accessible == initial_num_accessible) {
            break;
        }

        // remove marked rolls
        y = 0;
        while (y < grid.rows) : (y += 1) {
            var x: isize = 0;
            while (x < grid.cols) : (x += 1) {
                if (grid.at(@intCast(x), @intCast(y)) == 'x') {
                    grid.setAt(@intCast(x), @intCast(y), '.');
                }
            }
        }
    }

    return num_accessible;
}

test "day04 part1" {
    const num_accessible = try part1(test_input_data);
    try std.testing.expect(num_accessible == 13);
}

test "day04 part2" {
    const num_accessible = try part2(test_input_data);
    try std.testing.expect(num_accessible == 43);
}

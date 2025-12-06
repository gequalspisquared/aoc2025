const std = @import("std");

const input_data = @embedFile("input/day06.txt");
const test_input_data = @embedFile("input/test/day06.txt");

const Operator = enum { mul, add };

var numbers: std.ArrayList(std.ArrayList(i64)) = undefined;
var num_cols: usize = 0;
var operators: std.ArrayList(Operator) = undefined;
var allocator: std.mem.Allocator = undefined;

fn parse_input(comptime input: []const u8) !void {
    allocator = std.heap.page_allocator;
    numbers = .{};
    operators = .{};

    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (line[0] == '*') {
            num_cols = line.len;
            var row_operators = std.mem.tokenizeAny(u8, line, " ");

            while (row_operators.next()) |operator_str| {
                if (operator_str[0] == '*') {
                    try operators.append(allocator, .mul);
                } else {
                    try operators.append(allocator, .add);
                }
            }

            break;
        }

        var row_numbers = std.mem.tokenizeSequence(u8, line, " ");

        try numbers.append(allocator, .{});
        while (row_numbers.next()) |number_str| {
            const number = try std.fmt.parseInt(i64, number_str, 10);
            try numbers.items[numbers.items.len - 1].append(allocator, number);
        }
    }
}

pub fn main() !void {
    try parse_input(input_data);
    defer numbers.deinit(allocator);
    defer operators.deinit(allocator);

    const sum1 = try part1();
    std.debug.print("The grand total sum for part1 is: {d}\n", .{sum1});

    const sum2 = try part2(input_data);
    std.debug.print("The grand total sum for part2 is: {d}\n", .{sum2});
}

fn part1() !i64 {
    var sum: isize = 0;
    for (operators.items, 0..) |operator, index| {
        var local_sum: isize = if (operator == .mul) 1 else 0;
        for (numbers.items) |row| {
            if (operator == .mul) {
                local_sum *= row.items[index];
            } else {
                local_sum += row.items[index];
            }
        }

        sum += local_sum;
    }

    return sum;
}

fn part2(comptime input: []const u8) !i64 {
    const num_rows = numbers.items.len;
    var local_num = [_]u8{' '} ** 4;
    // num_cols: usize
    var local_nums: std.ArrayList(i64) = .{};
    defer local_nums.deinit(allocator);

    var sum: isize = 0;
    var col: usize = 0;
    var cur_operator_index: usize = 0;
    while (col < num_cols) : (col += 1) {
        // reset local_num
        @memset(&local_num, ' ');

        // build num string
        var row: usize = 0;
        while (row < num_rows) : (row += 1) {
            const cur_char = input[row * (num_cols + 1) + col];
            local_num[row] = cur_char;
        }

        // if local_nums is empty, do op and clear local_nums
        if (std.mem.eql(u8, &local_num, " " ** 4) == true) {
            const operator = operators.items[cur_operator_index];
            var local_sum: isize = if (operator == .mul) 1 else 0;
            for (local_nums.items) |num| {
                if (operator == .mul) {
                    local_sum *= num;
                } else {
                    local_sum += num;
                }
            }

            sum += local_sum;
            cur_operator_index += 1;

            local_nums.clearRetainingCapacity();
            continue;
        }

        // append num to local_nums
        const trimmed_num = std.mem.trim(u8, &local_num, " ");
        const num = try std.fmt.parseInt(i64, trimmed_num, 10);
        try local_nums.append(allocator, num);
    }

    // copy of inner loop, could be moved to separate fn
    const operator = operators.items[cur_operator_index];
    var local_sum: isize = if (operator == .mul) 1 else 0;
    for (local_nums.items) |num| {
        if (operator == .mul) {
            local_sum *= num;
        } else {
            local_sum += num;
        }
    }

    sum += local_sum;

    return sum;
}

test "day06 part1" {
    try parse_input(test_input_data);
    defer numbers.deinit(allocator);
    defer operators.deinit(allocator);

    const sum = try part1();
    try std.testing.expect(sum == 4277556);
}

test "day06 part2" {
    try parse_input(test_input_data);
    defer numbers.deinit(allocator);
    defer operators.deinit(allocator);

    const sum = try part2(test_input_data);
    try std.testing.expect(sum == 3263827);
}

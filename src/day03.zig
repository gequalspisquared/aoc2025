const std = @import("std");

const input_data = @embedFile("input/day03.txt");
const test_input_data = @embedFile("input/test/day03.txt");

pub fn main() !void {
    const sum_joltage1 = try part1(input_data);
    std.debug.print("The sum of joltages for part1 is: {}\n", .{sum_joltage1});

    const sum_joltage2 = try part2(input_data);
    std.debug.print("The sum of joltages for part2 is: {}\n", .{sum_joltage2});
}

fn part1(comptime input: []const u8) !i64 {
    var banks = std.mem.tokenizeAny(u8, input, "\n");
    var sum: i64 = 0;
    while (banks.next()) |bank| {
        var max: i64 = 0;
        var buf = [_]u8{0} ** 2;

        var l: usize = 0;
        while (l < bank.len - 1) : (l += 1) {
            var r: usize = l + 1;
            while (r < bank.len) : (r += 1) {
                buf[0] = bank[l];
                buf[1] = bank[r];

                const joltage = try std.fmt.parseInt(i64, &buf, 10);

                if (joltage > max) {
                    max = joltage;
                }
            }
        }

        sum += max;
    }

    return sum;
}

fn part2(comptime input: []const u8) !i64 {
    var banks = std.mem.tokenizeAny(u8, input, "\n");
    var sum: i64 = 0;
    while (banks.next()) |bank| {
        var max: i64 = 0;
        var buf = [_]u8{0} ** 12;

        var buf_index: usize = 0;
        var start_index: usize = 0;
        for (buf) |_| {
            var i: usize = start_index;
            while (i <= bank.len - buf.len + buf_index) : (i += 1) {
                const rating = bank[i];
                const cur_rating = buf[buf_index];
                if (rating > cur_rating) {
                    buf[buf_index] = rating;
                    start_index = i + 1;
                }
            }
            buf_index += 1;
        }

        const joltage = try std.fmt.parseInt(i64, &buf, 10);

        if (joltage > max) {
            max = joltage;
        }

        sum += max;
    }

    return sum;
}

test "day03 part1" {
    const joltage_sum = try part1(test_input_data);
    try std.testing.expect(joltage_sum == 357);
}

test "day03 part2" {
    const joltage_sum = try part2(test_input_data);
    try std.testing.expect(joltage_sum == 3121910778619);
}

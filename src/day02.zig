const std = @import("std");

const input_data = @embedFile("input/day02.txt");
const test_input_data = @embedFile("input/test/day02.txt");

pub fn main() !void {
    const invalid_id_sum_part1 = try part1(input_data);
    std.debug.print("The sum of invalid ids for part1 is: {}\n", .{invalid_id_sum_part1});

    const invalid_id_sum_part2 = try part2(input_data);
    std.debug.print("The sum of invalid ids for part2 is: {}\n", .{invalid_id_sum_part2});
}

fn part1(comptime input: []const u8) !i64 {
    var ranges = std.mem.tokenizeAny(u8, input, ",\n");
    var sum: i64 = 0;
    while (ranges.next()) |range| {
        var bounds = std.mem.tokenizeAny(u8, range, "-");
        const lower_bound_string = bounds.next().?;
        const upper_bound_string = bounds.next().?;

        const lower_bound = try std.fmt.parseInt(i64, lower_bound_string, 10);
        const upper_bound = try std.fmt.parseInt(i64, upper_bound_string, 10);

        // check if invalid
        var i = lower_bound;
        var buf = [_]u8{0} ** 32;
        while (i <= upper_bound) : (i += 1) {
            const num_string = try std.fmt.bufPrint(&buf, "{d}", .{i});

            if (num_string.len % 2 != 0) {
                continue;
            }

            if (std.mem.eql(u8, num_string[0 .. num_string.len / 2], num_string[num_string.len / 2 ..])) {
                sum += i;
            }
        }
    }

    return sum;
}

fn part2(comptime input: []const u8) !i64 {
    var ranges = std.mem.tokenizeAny(u8, input, ",\n");
    var sum: i64 = 0;
    while (ranges.next()) |range| {
        var bounds = std.mem.tokenizeAny(u8, range, "-");
        const lower_bound_string = bounds.next().?;
        const upper_bound_string = bounds.next().?;

        const lower_bound = try std.fmt.parseInt(i64, lower_bound_string, 10);
        const upper_bound = try std.fmt.parseInt(i64, upper_bound_string, 10);

        // check if invalid
        var i = lower_bound;
        var buf = [_]u8{0} ** 32;
        while (i <= upper_bound) : (i += 1) {
            const num_string = try std.fmt.bufPrint(&buf, "{d}", .{i});

            if (num_string.len < 2) continue;

            var j: usize = 1;
            while (j <= (num_string.len + 1) / 2) : (j += 1) {
                if (num_string.len % j != 0) continue;

                const num_segments = num_string.len / j;
                var segment: usize = 0;
                const segment_len = j;
                var invalid = true;
                while (segment < num_segments - 1) : (segment += 1) {
                    const start = segment * segment_len;
                    if (!std.mem.eql(u8, num_string[start .. start + segment_len], num_string[start + segment_len .. start + 2 * segment_len])) {
                        invalid = false;
                        break;
                    }
                }

                // is invalid, no need to check further
                if (invalid) {
                    sum += i;
                    break;
                }
            }
        }
    }

    return sum;
}

test "day02 part1" {
    const invalid_id_sum = try part1(test_input_data);
    try std.testing.expect(invalid_id_sum == 1227775554);
}

test "day02 part2" {
    const invalid_id_sum = try part2(test_input_data);
    try std.testing.expect(invalid_id_sum == 4174379265);
}

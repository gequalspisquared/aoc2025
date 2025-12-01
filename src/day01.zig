const std = @import("std");

const input_data = @embedFile("input/day01.txt");
const test_input_data = @embedFile("input/test/day01.txt");

pub fn main() !void {
    const password_part1 = try part1(input_data);
    std.debug.print("The password for part1 is: {}\n", .{password_part1});

    const password_part2 = try part2(input_data);
    std.debug.print("The password for part2 is: {}\n", .{password_part2});
}

fn part1(comptime input: []const u8) !i32 {
    var password: i32 = 0;
    var dial: i32 = 50;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        const parsed_distance = try std.fmt.parseInt(i32, line[1..], 10);
        const distance = if (line[0] == 'L') -1 * parsed_distance else parsed_distance;

        dial += distance;
        dial = @mod(dial, 100);
        if (dial == 0) {
            password += 1;
        }
    }
    return password;
}

fn part2(comptime input: []const u8) !i32 {
    var password: i32 = 0;
    var dial: i32 = 50;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        const parsed_distance = try std.fmt.parseInt(i32, line[1..], 10);

        // just simulate the rotation
        var i: i32 = 0;
        while (i < parsed_distance) : (i += 1) {
            if (line[0] == 'L') {
                dial -= 1;
            } else {
                dial += 1;
            }

            dial = @mod(dial, 100);
            if (dial == 0) {
                password += 1;
            }
        }
    }
    return password;
}

test "day01 part1" {
    const password = try part1(test_input_data);
    try std.testing.expect(password == 3);
}

test "day01 part2" {
    const password = try part2(test_input_data);
    try std.testing.expect(password == 6);
}

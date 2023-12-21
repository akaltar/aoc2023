const std = @import("std");
const common = @import("common.zig");

const schema_size: usize = 140;
const SchemaBool = [schema_size][schema_size]bool;
const SchemaChar = [schema_size][schema_size]u8;
var is_part_number: SchemaBool = std.mem.zeroes(SchemaBool);
var digits_only: SchemaChar = undefined;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status) @panic("Leak");
    }

    var input = common.readFile("sample3.txt", allocator) catch @panic("rip reading file");
    defer allocator.free(input);

    var lines_iter = std.mem.split(u8, input, "\n");

    const SchemaNumber = struct { x: usize, y: usize, len: usize, value: u32 };
    var numbers = std.ArrayList(SchemaNumber).init(allocator);
    defer numbers.deinit();

    var y: usize = 0;
    while (lines_iter.next()) |line| {
        var x: usize = 0;
        for (line) |char| {
            const is_digit = std.ascii.isDigit(char);
            digits_only[y][x] = if (is_digit) char else ' ';

            if (is_digit) {
                var is_continuation = false;
                if (numbers.items.len > 0) {
                    const last = numbers.getLast();
                    is_continuation = last.y == y and last.x + last.len == x;
                    if (is_continuation) {
                        last.len += 1;
                        last.value *= 10;
                        last.value += char - '0';
                    }
                }

                if (!is_continuation) {
                    numbers.append(SchemaNumber{ .x = x, .y = y, .len = 1, .value = char - '0' });
                }
            }

            if (!is_digit) {
                const is_part_indicator = char != '.';
                if (is_part_indicator) {
                    const x_big = x > 0;
                    const y_big = y > 0;

                    const x_small = x < schema_size - 1;
                    const y_small = y < schema_size - 1;
                    if (x_big) {
                        is_part_number[y][x - 1] = true;
                        if (y_big) is_part_number[y - 1][x - 1] = true;
                        if (y_small) is_part_number[y + 1][x - 1] = true;
                    }

                    is_part_number[y][x] = true;
                    if (y_big) is_part_number[y - 1][x] = true;
                    if (y_small) is_part_number[y + 1][x] = true;

                    if (x_small) {
                        is_part_number[y][x + 1] = true;
                        if (y_big) is_part_number[y - 1][x + 1] = true;
                        if (y_small) is_part_number[y + 1][x + 1] = true;
                    }
                }
            }

            x += 1;
        }
        y += 1;
    }

    var sum: u32 = 0;
    for (numbers.items) |number| {
        var is_this_a_part_number = false;

        var current_x = number.x;
        while (current_x < number.x + number.len) {
            if (is_part_number[number.y][current_x]) is_this_a_part_number = true;
            current_x += 1;
        }
        if (is_this_a_part_number) {
            sum += number.value;
        }
    }
}

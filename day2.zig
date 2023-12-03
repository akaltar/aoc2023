const std = @import("std");
const common = @import("common.zig");

const Draw = struct { red: u32 = 0, green: u32 = 0, blue: u32 = 0 };

fn parse_draw(str: []const u8) !Draw {
    var rgb_part_iter = std.mem.split(u8, str, ",");

    var draw = Draw{};

    while (rgb_part_iter.next()) |one_color_draw| {
        var number_color_iter = std.mem.split(u8, one_color_draw, " ");
        _ = number_color_iter.next(); // throw away first space
        const number_part = number_color_iter.next() orelse return error.Oops;
        const color_part = number_color_iter.next() orelse return error.Oops;

        const number = try std.fmt.parseInt(u32, number_part, 10);
        switch (color_part[0]) {
            'r' => draw.red = number,
            'g' => draw.green = number,
            'b' => draw.blue = number,
            else => {},
        }
    }
    return draw;
}

fn is_draw_possible(draw: Draw) bool {
    return draw.red <= 12 and draw.green <= 13 and draw.blue <= 14;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status) @panic("Leak");
    }

    var input = common.readFile("day2.txt", allocator) catch @panic("rip reading file");
    defer allocator.free(input);

    var sum: u32 = 0;
    var power_sum: u32 = 0;

    var lines_iter = std.mem.split(u8, input, "\n");
    var game_index: u32 = 1;
    while (lines_iter.next()) |line| {
        var game_parts_iter = std.mem.split(u8, line, ":");
        _ = game_parts_iter.next(); // discard part before ':';
        const draw_part = game_parts_iter.next() orelse @panic("Game has no definition");

        var min_draw = Draw{};

        var draws_iter = std.mem.split(u8, draw_part, ";");
        var is_possible = true;
        while (draws_iter.next()) |draw_string| {
            std.debug.print("Full draw: {s}\n", .{draw_string});
            const draw = parse_draw(draw_string) catch @panic("Can't parse a draw");

            std.debug.print("parsed: R:{}, G:{}, B:{}\n", .{ draw.red, draw.green, draw.blue });
            if (!is_draw_possible(draw)) is_possible = false;

            if (draw.red > min_draw.red) min_draw.red = draw.red;
            if (draw.green > min_draw.green) min_draw.green = draw.green;
            if (draw.blue > min_draw.blue) min_draw.blue = draw.blue;
        }

        std.debug.print("\n", .{});
        if (is_possible) sum += game_index;

        const power = min_draw.red * min_draw.green * min_draw.blue;
        power_sum += power;

        game_index += 1;
    }

    std.debug.print("sum: {any}\n", .{sum});
    std.debug.print("power_sum: {any}\n", .{power_sum});
}

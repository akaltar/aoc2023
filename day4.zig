const std = @import("std");
const common = @import("common.zig");

fn parse_number_list(str: []const u8, allocator: anytype) !std.ArrayList(u32) {
    // std.debug.print("\noriginal\'{s}\'\n", .{str});
    var list = std.ArrayList(u32).init(allocator);
    var iter = std.mem.split(u8, str, " ");
    _ = iter.next(); // skip first space
    //std.debug.print("\nskipping\'{?s}\'\n", .{skipped});

    while (iter.next()) |one_number| {
        var string_to_process = one_number;

        if (string_to_process.len == 0) continue;
        if (string_to_process[string_to_process.len - 1] == '\r') {
            // std.debug.print("\nasdf\'{s}\'\n", .{string_to_process});
            string_to_process = string_to_process[0 .. string_to_process.len - 1];
            // std.debug.print("\nasdf\'{s}\'\n", .{string_to_process});
        }
        if (string_to_process.len == 0) continue;
        if (string_to_process[0] == ' ') {
            string_to_process = string_to_process[1..];
        }
        if (string_to_process.len == 0) continue;

        //std.debug.print("\nfiltered\'{s}\'\n", .{string_to_process});
        const number = try std.fmt.parseInt(u32, string_to_process, 10);
        try list.append(number);
    }
    return list;
}

fn parse_card(str: []const u8, allocator: anytype) !u32 {
    var parts = std.mem.split(u8, str, "|");
    const our_numbers_string = parts.next();
    const winning_numbers_string = parts.next();

    if (our_numbers_string == null) @panic("our numbers Not string");
    if (winning_numbers_string == null) @panic("our numbers Not string");

    const our_numbers = try parse_number_list(our_numbers_string.?, allocator);
    defer our_numbers.deinit();
    const winning_numbers = try parse_number_list(winning_numbers_string.?, allocator);
    defer winning_numbers.deinit();

    var score: u32 = 0;
    for (our_numbers.items) |our_number| {
        for (winning_numbers.items) |winning_number| {
            if (our_number != winning_number) continue;
            if (score == 0) {
                score += 1;
            } else score *= 2;
        }
    }

    return score;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status) @panic("Leak");
    }

    var input = common.readFile("day4.txt", allocator) catch @panic("rip reading file");
    defer allocator.free(input);

    var sum: u32 = 0;

    var lines_iter = std.mem.split(u8, input, "\n");
    var game_index: u32 = 1;
    while (lines_iter.next()) |line| {
        var game_parts_iter = std.mem.split(u8, line, ":");
        _ = game_parts_iter.next(); // discard part before ':';
        const card = game_parts_iter.next() orelse @panic("Game has no definition");

        const score = parse_card(card, allocator) catch @panic("Can't parse a draw");

        std.debug.print("Game {}: {}\n", .{ game_index, score });

        std.debug.print("\n", .{});
        sum += score;

        game_index += 1;
    }

    std.debug.print("sum: {any}\n", .{sum});
}

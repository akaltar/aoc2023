const std = @import("std");

fn readFile(relativeFilename: []const u8, allocator: anytype) ![]u8 {
    const file = try std.fs.cwd().openFile(relativeFilename, .{});

    return try file.reader().readAllAlloc(allocator, 10 * 1024 * 1024);
}

// Convert 'one' to 1ne, two to 2wo, etc.
fn digitizeNumbers(text: []u8, allocator: anytype) !void {
    const textNumbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    // Doing this as a separate step is needed becuase of cases like "eightwo"
    const Replacement = struct { loc: usize, digit: u8 };
    var replacements = std.ArrayList(Replacement).init(allocator);
    defer replacements.deinit();

    var numberIndex: u8 = 1;
    for (textNumbers) |textNumber| {
        var lastIndex: usize = 0;
        while (std.mem.indexOfPos(u8, text, lastIndex, textNumber)) |numberPos| {
            lastIndex = numberPos + 1;
            const digit = numberIndex + '0';
            try replacements.append(Replacement{ .loc = numberPos, .digit = digit });
        }
        numberIndex += 1;
    }

    for (replacements.items) |replacement| {
        text[replacement.loc] = replacement.digit;
    }
}

fn getFirstDigit(line: []const u8) u64 {
    for (line) |char| {
        if (std.ascii.isDigit(char)) {
            return char - '0';
        }
    }
    return 0;
}

fn getLastDigit(line: []const u8) u64 {
    var i: usize = line.len;
    while (i > 0) {
        i -= 1;
        const char = line[i];
        if (std.ascii.isDigit(char)) {
            return char - '0';
        }
    }
    return 0;
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status) @panic("Leak");
    }

    var input = readFile("day1.txt", allocator) catch @panic("rip reading file");
    digitizeNumbers(input, allocator) catch @panic("rip digitizing"); // Comment this for part 1
    defer allocator.free(input);

    var lines_iter = std.mem.split(u8, input, "\n");

    var sum: u64 = 0;

    while (lines_iter.next()) |line| {
        sum += getFirstDigit(line) * 10;
        sum += getLastDigit(line);
    }

    std.debug.print("{}\n", .{sum});
}

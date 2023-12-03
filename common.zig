const std = @import("std");
pub fn readFile(relativeFilename: []const u8, allocator: anytype) ![]u8 {
    const file = try std.fs.cwd().openFile(relativeFilename, .{});

    return try file.reader().readAllAlloc(allocator, 10 * 1024 * 1024);
}

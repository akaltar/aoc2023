const std = @import("std");
const common = @import("common.zig");

const Draw = struct { red: u32 = 0, green: u32 = 0, blue: u32 = 0 };

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status) @panic("Leak");
    }

    var input = common.readFile("sample2.txt", allocator) catch @panic("rip reading file");

    //std.debug.print("{}\n", .{sum});
}

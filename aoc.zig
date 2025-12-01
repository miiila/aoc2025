const std = @import("std");

pub fn readFileByLines(allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile("day1_input", .{});
    defer file.close();

    const res = try file.readToEndAlloc(allocator, 1_000_000);

    return res;
}

const std = @import("std");

pub fn readFileByLines(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(input, .{});
    defer file.close();

    const res = try file.readToEndAlloc(allocator, 1_000_000);

    return res;
}

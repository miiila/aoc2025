const std = @import("std");
const aoc = @import("aoc.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day3_input");
    defer allocator.free(buf);

    var lines = std.mem.splitScalar(u8, buf, '\n');

    const res1 = try part1(&lines);
    lines.reset();
    const res2 = try part2(&lines);

    std.debug.print("{any}\n", .{res1});
    std.debug.print("{any}\n", .{res2});
}

pub fn part1(lines:  *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !i32 {
    var res: i32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var maxa: i32 = 0;
        var maxi: usize = 0;
        for (0..line.len - 1) |i| {
            const n = try std.fmt.charToDigit(line[i], 10);
            if (n > maxa) {
                maxa = n;
                maxi = i;
            }
        }
        var maxb: i32 = 0;
        for (maxi+1..line.len) |i| {
            const n = try std.fmt.charToDigit(line[i], 10);
            if (n > maxb) {
                maxb = n;
            }
        }

        res += maxa*10 + maxb;
    }

    return res;
}

fn findMax(line: []const u8, start: i8, limit: i8) struct {u8, i8} {
    var max: u8 = 0;
    var maxi: i8 = 0;
    const ll: i8 = @intCast(line.len);
    var i = start;
    while (i < ll - limit) : (i+=1) {
        const ii: u64 = @intCast(i);
        const n = std.fmt.charToDigit(line[ii], 10) catch @panic("boom");
        if (n > max) {
            max = n;
            maxi = i;
        }
    }

    return .{max, maxi};
}

pub fn part2(lines:  *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !u64 {
    var res: u64 = 0;
    while (lines.next()) |line| {
        var r: u64 = 0;
        if (line.len == 0) {
            break;
        }
        var maxi: i8 = -1;
        var max: u8 = 0;
        for (0..12) |i| {
            const ii:i8 =@intCast(i); 
            const l = 11-ii;
            max, maxi = findMax(line, maxi+1, l);
            const maxx: u64 = @intCast(max);
            const ll: u64 = @intCast(l);
            r += try std.math.mul(u64, maxx, std.math.pow(u64, 10, ll));
        }
        res += r;
    }

    return res;
}

const std = @import("std");
const aoc = @import("aoc.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator);
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
    var cur: i32 = 50;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const dir = line[0];
        var rot = try std.fmt.parseInt(i32, line[1..], 10);
        rot = @mod(rot, 100);
        if (dir == 'L') rot = rot * -1;
        cur += rot;
        cur = @mod(cur+100, 100);
        if (cur == 0) {
            res += 1;
        }
    }

    return res;
}

pub fn part2(lines:  *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !i32 {
    var res: i32 = 0;
    var cur: i32 = 50;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const dir = line[0];
        var rot = try std.fmt.parseInt(i32, line[1..], 10);
        res = res + @divFloor(rot, 100);
        rot = @mod(rot, 100);
        if (dir == 'L') {
            rot = rot * -1;
            cur += rot;
            if (cur < 0) {
                if (cur - rot > 0) {
                    res += 1;
                }
                cur += 100;
            }
            if (cur == 0) {
                res += 1;
            }
        } else {
            cur += rot;
            res = res + @divFloor(cur, 100);
            cur = @mod(cur, 100);
        }
    }

    return res;
}

const std = @import("std");

pub fn main() !void {
    var lines = try readFileByLines();
    const res1 = try part1(&lines);
    var lines2 = try readFileByLines();
    const res2 = try part2(&lines2);

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
        if (dir == 'L') {
            rot = rot * -1;
        }
        cur += rot;
        if (cur < 0) {
            cur += 100;
        }
        cur = @mod(cur, 100);
        if (cur == 0) {
            res += 1;
        }
    }
    lines.reset();

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

pub fn readFileByLines() !std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar) {
    const file = try std.fs.cwd().openFile("day1_input", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const res = try file.readToEndAlloc(allocator,1000000);

    return std.mem.splitScalar(u8, res, '\n');
}

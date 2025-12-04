const std = @import("std");
const aoc = @import("aoc.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day4_input");
    defer allocator.free(buf);


    var lines = std.mem.splitScalar(u8, buf, '\n');
    var inp = std.ArrayList([]const u8){};
    defer inp.deinit(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        try inp.append(allocator, line);
    }


    const res1 = try part1(inp.items);
    lines.reset();
    const res2 = try part2(inp.items);

    std.debug.print("{any}\n", .{res1});
    std.debug.print("{any}\n", .{res2});
}

fn isMovable(lines: [][] const u8, y: usize, x: usize) bool {
    var r: i32 = 0;
    for ([_]i32{ -1, 0, 1 }) |dx| {
        for ([_]i32{ -1, 0, 1 }) |dy| {
            const yy:i32 = @intCast(y);
            const xx:i32 = @intCast(x);
            if (((yy + dy) < 0) or ((yy + dy) >= lines.len) or ((xx + dx) < 0) or ((xx + dx) >= lines[y].len) or (dy == 0 and dx == 0)) continue;
            const yyy: usize = @intCast(yy+dy);
            const xxx: usize = @intCast(xx+dx);
            if (lines[yyy][xxx] == '@') r += 1;
        }
    }
    return (r < 4);
}

pub fn part1(lines:  [][] const u8) !i32 {
    var res: i32 = 0;
    for (0..lines.len) |y| {
        for (0..lines[y].len) |x| {
            if (lines[y][x] != '@') continue;
            if (isMovable(lines, y, x)) res += 1;
        }
    }
    return res;
}



const Coords = struct {x: i32, y: i32};

pub fn part2(lines:  [][] const u8) !i32 {
    var res: i32 = 0;
    var moved = true;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    var grid = std.AutoArrayHashMap(Coords, u8).init(allocator);
    defer grid.deinit();

    for (0..lines.len) |y| {
        for (0..lines[y].len) |x| {
            try grid.put(Coords{.x = @intCast(x), .y = @intCast(y)}, lines[y][x]);
        }
    }

    while (moved) {
        moved = false;
        var it =grid.iterator();
        while (it.next()) |e| {
            const k = e.key_ptr.*;
            const v = e.value_ptr.*;
            if (v != '@') continue;
            if (isMovable2(grid, k.y, k.x)) {
                moved = true;
                res += 1;
                // this is fine, we don't have to remove and wait for next iteration
                try grid.put(k, '.');
            }
        }
    }
    return res;
}

fn isMovable2(lines: std.AutoArrayHashMap(Coords, u8), y: i32, x: i32) bool {
    var r: i32 = 0;
    for ([_]i32{ -1, 0, 1 }) |dx| {
        for ([_]i32{ -1, 0, 1 }) |dy| {
            if (dy == 0 and dx == 0) continue;
            if (lines.get(Coords{.x= x+dx, .y= y+dy}) == '@') r += 1;
        }
    }
    return (r < 4);
}

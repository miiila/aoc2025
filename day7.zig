const std = @import("std");
const aoc = @import("aoc.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day7_input");
    //const buf = try aoc.readFileByLines(allocator, "day7_input_test");
    defer allocator.free(buf);

    var lines = std.mem.splitScalar(u8, buf, '\n');

    var inps = std.ArrayList([]u8){};
    defer inps.deinit(allocator);
    
    const w = lines.peek().?.len;
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var row = try allocator.alloc(u8, w);
        for (line, 0..) |c, i| {
           row[i] = c;
        }
        try inps.append(allocator, row);
    }

    var inps2 = std.ArrayList([]u8){};

    defer inps2.deinit(allocator);
    for (inps.items) |it| {
        const row = try allocator.alloc(u8, w);
        @memcpy(row, it);
        try inps2.append(allocator, row);
    }

    const res1 = try part1(inps.items);
    for (inps.items) |it| {
        allocator.free(it);
    }
    std.debug.print("{any}\n", .{res1});

    const res2 = try part2(inps2.items, allocator);
    for (inps2.items) |it| {
        allocator.free(it);
    }

    std.debug.print("{any}\n", .{res2});
}

pub fn part1(lines:  [][]u8) !i32 {
    var res: i32 = 0;
    for (lines,0..) |r, y| {
        if (y == 0) continue;
        for (r, 0..) |c, x| {
            const dy = y - 1;
            switch (c) {
                '.' => {if (lines[dy][x] == 'S') lines[y][x] = 'S';},
                '^' => {if (lines[dy][x] == 'S') {
                    res += 1;
                    lines[y][x-1] = 'S';
                    lines[y][x+1] = 'S';
                    }
                },
                else => continue,
            }
        }
    }
    return res;
}


pub fn part2(lines:  [][]u8, allocator: std.mem.Allocator) !u64 {
    var res: u64 = 0;
    const Coords = struct {x: usize, y: usize};
    var hm = std.AutoHashMap(Coords, u64).init(allocator);

    for (lines,0..) |r, y| {
        if (y == 0) continue;
        for (r, 0..) |c, x| {
            const dy = y - 1;
            const prev = hm.get(Coords{.x=x, .y=dy}) orelse 1;
            switch (c) {
                '.' => {if (lines[dy][x] == 'S') {
                    lines[y][x] = 'S';
                    const v = try hm.getOrPut(Coords{.x=x, .y=y});
                    if (v.found_existing) {v.value_ptr.* +=prev;} else {v.value_ptr.* = prev;}
                    }
                },
                '^' => {if (lines[dy][x] == 'S') {
                    var v = try hm.getOrPut(Coords{.x=x-1, .y=y});
                    if (v.found_existing) {v.value_ptr.* +=prev;} else {v.value_ptr.* = prev;}
                    v = try hm.getOrPut(Coords{.x=x+1, .y=y});
                    if (v.found_existing) {v.value_ptr.* +=prev;} else {
                        const prevv = hm.get(Coords{.x=x+1, .y=dy}) orelse 0;
                        v.value_ptr.* = prev + prevv;
                    }
                    lines[y][x-1] = 'S';
                    lines[y][x+1] = 'S';
                    }
                },
                else => continue,
            }
        }
    }

    var hmi = hm.iterator();
    while (hmi.next()) |k| {
        //if (k.key_ptr.*.y != 12) continue;
        if (k.key_ptr.*.y != lines.len - 1) continue;
        //std.debug.print("{any}: {d}\n", .{k.key_ptr.*, k.value_ptr.*});
        res += k.value_ptr.*;
    }

    return res;
}

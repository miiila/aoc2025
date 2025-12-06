const std = @import("std");
const aoc = @import("aoc.zig");

const Range = struct {from: usize, to: usize};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day6_input");
    defer allocator.free(buf);

    var lines = std.mem.splitScalar(u8, buf, '\n');
    var inps = std.ArrayList([]u64){};
    defer inps.deinit(allocator);
    var ops: []u8 = &.{};
    defer allocator.free(ops);

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        if (lines.peek() != null and lines.peek().?.len > 0) {
            const r = try parseNums(line, allocator);
            try inps.append(allocator, r);
        } else {
            ops = try parseOps(line, allocator);
        }
    }


    const res1 = try part1(inps.items, ops);
    std.debug.print("{any}\n", .{res1});

    lines.reset();

    const res2 = try part2(&lines);
    std.debug.print("{any}\n", .{res2});

    for (inps.items) |row| {
        allocator.free(row);
    }
}

pub fn part1(inps: [][]u64, ops: []u8) !u64 {
    var res: u64 = 0; 
    for (0..inps[0].len) |i| {
        var r: u64 = 0;
        if (ops[i] == '*') r = 1;
        for (inps) |inp| {
           if (ops[i] == '*') {
               r *= inp[i];
           } else {
               r += inp[i];
           }
        }
        res += r;
    }
    return res;
}

pub fn part2(lines: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ops: []u8 = &.{};
    defer allocator.free(ops);

    var res: []u64 = try allocator.alloc(u64, lines.peek().?.len);
    defer allocator.free(res);
    for (res) |*v| v.* = 0;

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        if (lines.peek() != null and lines.peek().?.len > 0) {
            for (1..line.len + 1) |i| {
                const j = line.len - i;
                if (line[j] != ' ') {
                    const d = try std.fmt.charToDigit(line[j], 10);
                    res[j] = res[j]*10 + d;
                }
            }
        } else {
            ops = try parseOps(line, allocator);
        }
    }

    var ress: u64 = 0;
    var i: u64 = 0; 

    var rt: u64 = 0;
    if (ops[i] == '*') rt = 1;
    for (res) |r| {
        if (i == ops.len) break;
        if (r == 0) {
            i += 1;
            ress += rt;
            rt = 0;
            if (i == ops.len) break;
            if (ops[i] == '*') rt = 1;
            continue;
        }
        if (ops[i] == '*') {
            rt *= r;
        } else {
            rt += r;
        }   
    }
    return ress;
}

fn parseOps(inp: [] const u8, allocator: std.mem.Allocator) ![]u8 {
    var r = std.ArrayList(u8){};

    for (0..inp.len) |i| {
        if (inp[i] != ' ') {
             try r.append(allocator, inp[i]);
        }
    }

    return r.toOwnedSlice(allocator);
    
}

fn parseNums(inp: [] const u8, allocator: std.mem.Allocator) ![]u64 {
    var r = std.ArrayList(u64){};

    var cur: u64 = 0;
    for (0..inp.len) |i| {
        if (inp[i] == ' ') {
            if (cur > 0) try r.append(allocator, cur);
            cur = 0;
        } else {
            const d = try std.fmt.charToDigit(inp[i], 10);
            if (d == 0) @panic("Zero found");
            cur = cur * 10;
            cur += d;
        }
    }
    if (cur > 0) try r.append(allocator, cur);

    return r.toOwnedSlice(allocator);
    
}






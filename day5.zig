const std = @import("std");
const aoc = @import("aoc.zig");

const Range = struct {from: usize, to: usize};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day5_input");
    defer allocator.free(buf);

    

    var lines = std.mem.splitScalar(u8, buf, '\n');
    var ranges = std.ArrayList(Range){};
    defer ranges.deinit(allocator);
    var inp = std.ArrayList(usize){};
    defer inp.deinit(allocator);

    var pR = true;
    while (lines.next()) |line| {
        if (line.len == 0) {
            pR = false;
            continue;
        }
        if (pR) {
            var r = std.mem.splitScalar(u8, line, '-');
            const f = try std.fmt.parseInt(usize, r.next().?, 10);
            const t = try std.fmt.parseInt(usize, r.next().?, 10);
            try ranges.append(allocator, Range{.from=f, .to=t});
        } else {
            const i = try std.fmt.parseInt(usize, line, 10);
            try inp.append(allocator, i);
        }
    }


    const res1 = try part1(ranges.items, inp.items);
    std.debug.print("{any}\n", .{res1});

    const res2 = try part2(ranges.items);
    std.debug.print("{any}\n", .{res2});
}

pub fn part1(ranges: []Range, inp: []usize) !i32 {
    var res: i32 = 0;
    for (inp) |i| {
        for (ranges) |r| {
            if (i >= r.from and i <= r.to) {
                res += 1;
                break;
            }
        }
    }
    return res;
}

pub fn part2(ranges: []Range) !usize {
    var res: usize = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var fresh = std.ArrayList(Range){};

    // stupid leftover, that caused me headache
    for (ranges) |r| {
        try fresh.append(allocator, r);
    }

    var merged  = std.ArrayList(Range){};
    defer merged.deinit(allocator);

    while (fresh.pop()) |f| {
        var new  = std.ArrayList(Range){};
        var moved = false;
        var f1 = f;
        while (fresh.pop()) |f2| {
            if (f1.from <= f2.to and f1.to >= f2.from) {
                moved = true;
                f1 = Range{.from = @min(f1.from, f2.from), .to = @max(f1.to, f2.to)};
            } else {
                try new.append(allocator, f2);
            }
        }
        if (moved) {
            try new.append(allocator, f1);
        } else {
            try merged.append(allocator, f1);
        }
        fresh.deinit(allocator);
        fresh = new;
    }

    for (merged.items) |ff| {
        res += 1 + ff.to - ff.from;
    }

    return res;
}




const std = @import("std");
const aoc = @import("aoc.zig");

const Range = struct  {
    a: u64,
    b: u64
};

pub fn main() !void {
    const input = "6161588270-6161664791,128091420-128157776,306-494,510-1079,10977-20613,64552-123011,33-46,28076-52796,371150-418737,691122-766624,115-221,7426210-7504719,819350-954677,7713444-7877541,63622006-63661895,1370-1981,538116-596342,5371-8580,8850407-8965070,156363-325896,47-86,452615-473272,2012-4265,73181182-73335464,1102265-1119187,3343315615-3343342551,8388258268-8388317065,632952-689504,3-22,988344-1007943";
    var ranges = std.mem.splitScalar(u8, input, ',');

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var rs = std.ArrayList(Range){};
    defer rs.deinit(allocator);

    while (ranges.next()) |r| {
        var rr = std.mem.splitScalar(u8, r, '-');
        const a=try std.fmt.parseInt(u64, rr.next().?, 10);
        const b=try std.fmt.parseInt(u64, rr.next().?, 10);
        try rs.append(allocator, Range{.a=a, .b=b});

    }
    const res1 = try part1(rs.items);
    const res2 = try part2(rs.items);

    std.debug.print("{any}\n", .{res1});
    std.debug.print("{any}\n", .{res2});
}

pub fn part1(input: [] const Range) !u64 {
    var res: u64 = 0;
    for (input) |r| {
        for (r.a..r.b+1) |u| {
            const l = std.math.log10(u)+1;
            if (l%2 == 1) continue;
            const t = std.math.pow(u64, 10, l/2);
            if (@divFloor(u, t) == @rem(u, t)) res += u;
        }
    }

    return res;
}

pub fn part2(input: [] const Range) !u64 {
    var res: u64 = 0;
    for (input) |r| {
        for (r.a..r.b+1) |u| {
            const l = std.math.log10(u)+1;
            var i = l/2;
            while (i > 0) : (i -= 1) {
                if (l%i > 0) continue;
                const div = std.math.pow(u64, 10, i);
                if (recEq(@divFloor(u, div), u%div, div)) {
                    res += u;
                    break;
                }
            }
        }
    }

    return res;
}

fn recEq(rem: u64, pat: u64, div: u64) bool { 
   if (rem == 0) return true;
   if (rem%div != pat) return false;

   return recEq(@divFloor(rem, div), pat, div);
}

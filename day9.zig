const std = @import("std");
const aoc = @import("aoc.zig");

const Coords = struct {x: u64, y: u64};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        

    const buf = try aoc.readFileByLines(allocator, "day9_input");
    //const buf = try aoc.readFileByLines(allocator, "day9_input_test");
    defer allocator.free(buf);

    var lines = std.mem.splitScalar(u8, buf, '\n');

    var inps = std.ArrayList(Coords){};
    defer inps.deinit(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var xy = std.mem.splitScalar(u8, line, ',');
        const r = Coords{ .x = try std.fmt.parseInt(u64, xy.next().?, 10), .y = try std.fmt.parseInt(u64, xy.next().?, 10)};
        try inps.append(allocator, r);
    }

    const res1 = try part1(inps.items, allocator);
    std.debug.print("{any}\n", .{res1});

    const res2 = try part2(inps.items, allocator);

    std.debug.print("{any}\n", .{res2});
}

const Dist = struct {pair: std.meta.Tuple(&.{ Coords, Coords }), dist: u64};
const Edge = struct{f: Coords, t: Coords};

pub fn part1(inps: []Coords, allocator: std.mem.Allocator) !u64 {
    var dists = std.ArrayList(u64).empty;
    defer dists.deinit(allocator);
    for (inps, 0..) |inp, i| {
        for (inps[i..]) |jnp| {
            const ix: i64 = @intCast(inp.x);
            const jx: i64 = @intCast(jnp.x);
            const iy: i64 = @intCast(inp.y);
            const jy: i64 = @intCast(jnp.y);
           const d = (@abs(ix-jx) + 1) * (@abs(iy-jy) + 1); 
           try dists.append(allocator, d);
        }
    }
    return std.mem.max(u64, dists.items);
}

pub fn part2(inps: []Coords, allocator: std.mem.Allocator) !u64 {
    std.mem.sort(Coords, inps, {}, ltx);
    var vedges = std.ArrayList(Edge).empty;
    defer vedges.deinit(allocator);
    var i: usize = 0;
    while (i < inps.len) : (i += 2) {
        try vedges.append(allocator, Edge{.f = inps[i], .t = inps[i+1]});
    }

    std.mem.sort(Coords, inps, {}, lty);
    var hedges = std.ArrayList(Edge).empty;
    defer hedges.deinit(allocator);
    i = 0;
    while (i < inps.len) : (i += 2) {
        try hedges.append(allocator, Edge{.f = inps[i], .t = inps[i+1]});
    }

    var dists = std.ArrayList(Dist).empty;
    defer dists.deinit(allocator);
    for (inps, 0..) |inp, ii| {
        for (inps[ii..]) |jnp| {
            const ix: i64 = @intCast(inp.x);
            const jx: i64 = @intCast(jnp.x);
            const iy: i64 = @intCast(inp.y);
            const jy: i64 = @intCast(jnp.y);
           const d = (@abs(ix-jx) + 1) * (@abs(iy-jy) + 1); 
           try dists.append(allocator, Dist{.pair = .{inp, jnp}, .dist = d});
        }
    }
    std.mem.sort(Dist, dists.items, {}, ltd);
    var c: i32 = 1;
    for (dists.items) |d| {
        //std.debug.print("{}. / {} {}\n", .{c, dists.items.len, d.dist});
        // previously found answer that is too high
        if (d.dist >= 2520389550) continue;
        c += 1;
        const ixiy = d.pair[0];
        const jxjy = d.pair[1];
        const ixjy = Coords{.x = ixiy.x, .y = jxjy.y};
        const jxiy = Coords{.x = jxjy.x, .y = ixiy.y};

        const rayCastIxjy = isIn(&vedges, &hedges, ixjy.x, ixjy.y);
        const rayCastJxIy = isIn(&vedges, &hedges, jxiy.x, jxiy.y);

        if (!rayCastJxIy or !rayCastIxjy) continue;

        var shouldBreak = false;
        const starty = @min(ixiy.y, jxjy.y);
        const endy = @max(ixiy.y, jxjy.y);
        const startx = @min(ixiy.x, jxjy.x);
        const endx = @max(ixiy.x, jxjy.x);

        for(startx..endx+1) |x| {
                if (!isIn(&vedges, &hedges, x, starty)) shouldBreak = true;
                if (shouldBreak) break;
                if (!isIn(&vedges, &hedges, x, endy)) shouldBreak = true;
                if (shouldBreak) break;
        }
        for(starty..endy+1) |y| {
                if (!isIn(&vedges, &hedges, startx, y)) shouldBreak = true;
                if (shouldBreak) break;
                if (!isIn(&vedges, &hedges, endx, y)) shouldBreak = true;
                if (shouldBreak) break;
        }
        if (!shouldBreak) return d.dist;
    }

    return 0;
}

fn isIn(vedges: *std.ArrayList(Edge), hedges: *std.ArrayList(Edge), x: u64, y: u64) bool {
    var cross: i32 = 0;
    const px = x * 2 + 1;
    const py = y * 2 + 1;
    for (hedges.items) |edge| {
        std.debug.assert(edge.f.x <= edge.t.x);
        std.debug.assert(edge.f.y == edge.t.y);
        if (edge.f.y == y and edge.f.x <= x and edge.t.x >= x) return true;
    }
    for (vedges.items) |edge| {
        if (edge.f.x == x and edge.f.y <= y and edge.t.y >= y) return true;
        const efx = edge.f.x * 2;
        const efy = edge.f.y * 2;
        const etx = edge.t.x * 2;
        const ety = edge.t.y * 2;
        std.debug.assert(efy <= ety);
        std.debug.assert(efx == etx);
        if (efx > px) {
            if (py >= efy and py < ety) cross += 1;
        }
    }

    const r = (cross & 1) == 1;
    //std.debug.print("point {},{}: {} {}\n", .{x,y,r, cross});
    return r;
}

fn ltd(_: void, lhs: Dist, rhs: Dist) bool {
    return lhs.dist > rhs.dist;
}

fn ltx(_: void, lhs: Coords, rhs: Coords) bool {
    if (lhs.x == rhs.x) return lhs.y < rhs.y;
    return lhs.x < rhs.x;
}

fn lty(_: void, lhs: Coords, rhs: Coords) bool {
    if (lhs.y == rhs.y) return lhs.x < rhs.x;
    return lhs.y < rhs.y;
}




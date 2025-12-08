const std = @import("std");
const aoc = @import("aoc.zig");

const Coords = struct {x: u64, y: u64, z: u64};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
        
    const buf = try aoc.readFileByLines(allocator, "day8_input");
    //const buf = try aoc.readFileByLines(allocator, "day8_input_test");
    defer allocator.free(buf);

    var lines = std.mem.splitScalar(u8, buf, '\n');

    var inps = std.ArrayList(Coords){};
    defer inps.deinit(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var xyz = std.mem.splitScalar(u8, line, ',');
        const r = Coords{ .x = try std.fmt.parseInt(u64, xyz.next().?, 10), .y = try std.fmt.parseInt(u64, xyz.next().?, 10), .z = try std.fmt.parseInt(u64, xyz.next().?, 10)};
        try inps.append(allocator, r);
    }

    const res1 = try part1(inps.items, allocator);
    std.debug.print("{any}\n", .{res1});

    const res2 = try part2(inps.items, allocator);

    std.debug.print("{any}\n", .{res2});
}

const Dist = struct {pair: std.meta.Tuple(&.{ Coords, Coords }), dist: u64};
pub fn part1(inps: []Coords, allocator: std.mem.Allocator) !u32 {

    var dists = std.ArrayList(Dist){};
    defer dists.deinit(allocator);
    for (inps, 0..) |it, i| {
        for (inps[i+1..]) |jt| {
            const d = Dist{.pair = .{it, jt}, .dist = countDist(it,jt)};
            try dists.append(allocator, d);
        }
    }

    std.mem.sort(Dist, dists.items, {}, lt);
    const k = dists.items[0..1000];
    //const k = dists.items[0..10];
    
    var c = std.ArrayList(std.AutoHashMap(Coords, void)){};
    try c.ensureTotalCapacity(allocator, 1_000_000);
    defer c.deinit(allocator);

    for (k) |d| {
        const c1 = d.pair[0];
        const c2 = d.pair[1];
        var firstFound: ?*std.AutoHashMap(Coords, void) = null;
        var secondFound: ?*std.AutoHashMap(Coords, void) = null;
        for (c.items) |*cc| {
            if (cc.contains(c1)) {
               firstFound = cc;
            }
            if (cc.contains(c2)) {
               secondFound = cc;
            }
        }
        if (firstFound == null and secondFound == null) {
            var circuit = std.AutoHashMap(Coords, void).init(allocator);
            try circuit.ensureTotalCapacity(1000);
            try circuit.put(c1, {});
            try circuit.put(c2, {});
            try c.append(allocator, circuit);
            continue;
        }
        if (firstFound == secondFound) continue;
        if (firstFound == null) {
            try secondFound.?.put(c1, {});
            continue;
        }
        if (secondFound == null) {
            try firstFound.?.put(c2, {});
            continue;
        }
        var kit = secondFound.?.keyIterator();
        var rem = std.ArrayList(Coords){};
        defer rem.deinit(allocator);
        while (kit.next()) |key| {
            try firstFound.?.put(key.*, {});
            try rem.append(allocator, key.*);
        }
        for (rem.items) |r| {
            _ = secondFound.?.remove(r);
        }
    }

    var sizes = std.ArrayList(u32){};
    defer sizes.deinit(allocator);
    for (c.items) |*circ| try sizes.append(allocator, circ.count());

    std.mem.sort(u32, sizes.items, {}, std.sort.desc(u32));

    var res: u32 = 1;
    for (sizes.items[0..3]) |si| {
        res *= si; 
    }

    for (c.items) |*it| {
        it.deinit();
    }

    return res;
}

fn lt(_: void, lhs: Dist, rhs: Dist) bool {
    return lhs.dist < rhs.dist;
}


pub fn part2(inps: []Coords, allocator: std.mem.Allocator) !u64 {

    var dists = std.ArrayList(Dist){};
    defer dists.deinit(allocator);
    for (inps, 0..) |it, i| {
        for (inps[i+1..]) |jt| {
            const d = Dist{.pair = .{it, jt}, .dist = countDist(it,jt)};
            try dists.append(allocator, d);
        }
    }

    std.mem.sort(Dist, dists.items, {}, lt);
    const k = dists.items[0..];
    
    var c = std.ArrayList(std.AutoArrayHashMap(Coords, void)){};
    try c.ensureTotalCapacity(allocator, 1_000_000);
    defer c.deinit(allocator);

    defer {
        for (c.items) |*it| {
            it.deinit();
        }
    }
    for (k) |d| {
        const c1 = d.pair[0];
        const c2 = d.pair[1];
        var firstFound: ?*std.AutoArrayHashMap(Coords, void) = null;
        var secondFound: ?*std.AutoArrayHashMap(Coords, void) = null;
        for (c.items) |*cc| {
            if (cc.contains(c1)) {
               firstFound = cc;
            }
            if (cc.contains(c2)) {
               secondFound = cc;
            }
        }
        if (firstFound == null and secondFound == null) {
            var circuit = std.AutoArrayHashMap(Coords, void).init(allocator);
            try circuit.ensureTotalCapacity(1000);
            try circuit.put(c1, {});
            try circuit.put(c2, {});
            try c.append(allocator, circuit);
            continue;
        }
        if (firstFound == secondFound) continue;
        if (firstFound == null) {
            try secondFound.?.put(c1, {});
            if (secondFound.?.count() == 1000) return c1.x * c2.x;
            continue;
        }
        if (secondFound == null) {
            try firstFound.?.put(c2, {});
            if (firstFound.?.count() == 1000) return c1.x * c2.x;
            continue;
        }
        var rem = std.ArrayList(Coords){};
        defer rem.deinit(allocator);
        for (secondFound.?.keys()) |key| {
            try firstFound.?.put(key, {});
            try rem.append(allocator, key);
        }
        if (firstFound.?.count() == 1000) return c1.x * c2.x;
        for (rem.items) |r| {
            _ = secondFound.?.orderedRemove(r);
        }
    }

    return 0;
}

fn countDist(c1: Coords, c2: Coords) u64 {
    const c1xi: i64 = @intCast(c1.x);
    const c2xi: i64 = @intCast(c2.x);
    const c1yi: i64 = @intCast(c1.y);
    const c2yi: i64 = @intCast(c2.y);
    const c1zi: i64 = @intCast(c1.z);
    const c2zi: i64 = @intCast(c2.z);

    const xsq: u64 = @intCast(std.math.pow(i64, c1xi - c2xi, 2));
    const ysq: u64 = @intCast(std.math.pow(i64, c1yi - c2yi, 2));
    const zsq: u64 = @intCast(std.math.pow(i64, c1zi - c2zi, 2));

    return std.math.sqrt(xsq + ysq + zsq);
}


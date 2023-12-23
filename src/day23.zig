const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const Part = enum { one, two };

//const data = @embedFile("data/day23.txt");
const data = @embedFile("data/day23.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const w = std.mem.indexOfScalar(u8, data, '\n').?;

    const start = std.mem.indexOfScalar(u8, data, '.').?;
    const end = std.mem.lastIndexOfScalar(u8, data, '.').?;

    var visited = std.AutoArrayHashMap(usize, void).init(alloc);
    defer visited.deinit();

    const part1 = try dfs(.{ .next = start, .weight = 0 }, w, end, &visited, Part.one);
    const part2 = try dfs(.{ .next = start, .weight = 0 }, w, end, &visited, Part.two);

    print("day23: part1: {}\n", .{part1.?});
    print("day23: part2: {}\n", .{part2.?});
    print("day23: all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn dfs(e: Edge, w: usize, end: usize, visited: *std.AutoArrayHashMap(usize, void), part: Part) !?usize {
    if (e.next == end) {
        return 1;
    }

    try visited.put(e.next, {});
    defer _ = visited.swapRemove(e.next);

    var out: usize = 0;
    var ok = false;
    for (moves(e.next, w, part)) |m| {
        if (m == null) continue;
        if (visited.get(m.?.next) != null) continue;
        if (m == null) break;
        const x = try dfs(m.?, w, end, visited, part);
        if (x != null) {
            ok = true;
            out = @max(out, x.?);
        }
    }

    return if (ok) out + e.weight else null;
}

const Edge = struct {
    next: usize,
    weight: usize,
};

fn moves(i: usize, w: usize, part: Part) [4]?Edge {
    var out: [4]?Edge = .{null} ** 4;
    var n: usize = 0;

    var west = false;
    var east = false;
    var north = false;
    var south = false;

    switch (if (part == .one) data[i] else '.') {
        '>' => east = true,
        'v' => south = true,
        '<' => west = true,
        '^' => north = true,
        else => {
            east = true;
            south = true;
            west = true;
            north = true;
        },
    }

    // west
    if (west and i % (w + 1) != 0) {
        if (data[i - 1] != '#') {
            out[n] = .{ .next = i - 1, .weight = 1 };
            n += 1;
        }
    }

    // east
    if (east and i % (w + 1) != w) {
        if (data[i + 1] != '#') {
            out[n] = .{ .next = i + 1, .weight = 1 };
            n += 1;
        }
    }

    // north
    if (north and i > (w + 1)) {
        if (data[i - (w + 1)] != '#') {
            out[n] = .{ .next = i - (w + 1), .weight = 1 };
            n += 1;
        }
    }

    // south
    if (south and i + (w + 1) < data.len) {
        if (data[i + (w + 1)] != '#') {
            out[n] = .{ .next = i + (w + 1), .weight = 1 };
            n += 1;
        }
    }

    return out;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

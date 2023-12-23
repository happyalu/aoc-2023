const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day23.txt");
//const data = @embedFile("data/day23.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var q = std.PriorityQueue(PointCost, void, PointCost.lessThan).init(alloc, {});
    defer q.deinit();

    const w = std.mem.indexOfScalar(u8, data, '\n').?;

    const start = std.mem.indexOfScalar(u8, data, '.').?;
    const end = std.mem.lastIndexOfScalar(u8, data, '.').?;

    var visited = std.AutoHashMap(usize, void).init(alloc);
    defer visited.deinit();

    const part1 = try dfs(start, w, end, &visited);

    print("day23: part1: {}\n", .{part1});
    print("day23: all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn dfs(i: usize, w: usize, end: usize, visited: *std.AutoHashMap(usize, void)) !usize {
    if (i == end) return 0;

    try visited.put(i, {});
    defer _ = visited.remove(i);

    var out: usize = 0;
    for (moves(i, w)) |m| {
        if (m == null) break;
        if (visited.get(m.?) != null) continue;
        out = @max(out, try dfs(m.?, w, end, visited));
    }

    return out + 1;
}

fn moves(i: usize, w: usize) [4]?usize {
    var out: [4]?usize = .{null} ** 4;
    var n: usize = 0;

    var west = false;
    var east = false;
    var north = false;
    var south = false;

    switch (data[i]) {
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
            out[n] = i - 1;
            n += 1;
        }
    }

    // east
    if (east and i % (w + 1) != w) {
        if (data[i + 1] != '#') {
            out[n] = i + 1;
            n += 1;
        }
    }

    // north
    if (north and i > (w + 1)) {
        if (data[i - (w + 1)] != '#') {
            out[n] = i - (w + 1);
            n += 1;
        }
    }

    // south
    if (south and i + (w + 1) < data.len) {
        if (data[i + (w + 1)] != '#') {
            out[n] = i + (w + 1);
            n += 1;
        }
    }

    return out;
}

const PointCost = struct {
    idx: usize,
    cost: isize,
    visited: *std.AutoHashMap(usize, void),

    fn lessThan(_: void, a: PointCost, b: PointCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

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

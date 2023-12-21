const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data_actual = @embedFile("data/day21.txt");
const data_example = @embedFile("data/day21.example.txt");

const debug = true;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    if (debug) {
        //        assert(try solve(alloc, data_example, 6, Part.one) == 16);
    }

    //const part1 = try solve(alloc, data_actual, 64, Part.one);

    if (debug) {
        //assert(try solve(alloc, data_example, 6, Part.two) == 16);
        //assert(try solve(alloc, data_example, 10, Part.two) == 50);
        //print("{}\n", .{try solve(alloc, data_example, 50, Part.two)});
        assert(try solve(alloc, data_example, 50, Part.two) == 1594);
        assert(try solve(alloc, data_example, 100, Part.two) == 6536);
        assert(try solve(alloc, data_example, 500, Part.two) == 167004);
        assert(try solve(alloc, data_example, 1000, Part.two) == 668697);
        //assert(try solve(alloc, data_example, 5000, Part.two) == 16733044);
    }

    //print("day21 part1: {}\n", .{part1});
    print("day21 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const InfiniteField = struct {
    x_off: isize,
    y_off: isize,
    k: usize,
};

fn solve(alloc: std.mem.Allocator, data: []const u8, step_count: usize, part: Part) !usize {
    var cur_places = std.AutoArrayHashMap(InfiniteField, void).init(alloc);
    var next_places = std.AutoArrayHashMap(InfiniteField, void).init(alloc);

    defer cur_places.deinit();
    defer next_places.deinit();

    try cur_places.put(.{ .x_off = 0, .y_off = 0, .k = std.mem.indexOfScalar(u8, data, 'S').? }, {});

    const w = std.mem.indexOfScalar(u8, data, '\n').?;

    for (0..step_count) |step| {
        _ = step;
        next_places.clearRetainingCapacity();

        for (cur_places.keys()) |key| {
            const k = key.k;
            switch (part) {
                .one => {
                    // west?
                    if ((k) % (w + 1) > 0 and data[k - 1] != '#') {
                        try next_places.put(.{ .x_off = key.x_off, .y_off = key.y_off, .k = k - 1 }, {});
                    }

                    // east?
                    if ((k + 1) % (w + 1) < w and data[k + 1] != '#') {
                        try next_places.put(.{ .x_off = key.x_off, .y_off = key.y_off, .k = k + 1 }, {});
                    }

                    // north?
                    if (k > (w + 1) and data[k - (w + 1)] != '#') {
                        try next_places.put(.{ .x_off = key.x_off, .y_off = key.y_off, .k = k - (w + 1) }, {});
                    }

                    // south?
                    if ((k + (w + 1)) < data.len and data[k + (w + 1)] != '#') {
                        try next_places.put(.{ .x_off = key.x_off, .y_off = key.y_off, .k = k + (w + 1) }, {});
                    }
                },
                .two => {
                    var n: usize = undefined;
                    var x: isize = undefined;
                    var y: isize = undefined;

                    // west
                    if (k % (w + 1) == 0) {
                        n = k + w - 1;
                        x = key.x_off - 1;
                        y = key.y_off;
                    } else {
                        n = k - 1;
                        x = key.x_off;
                        y = key.y_off;
                    }

                    if (data[n] != '#') {
                        try next_places.put(.{ .x_off = x, .y_off = y, .k = n }, {});
                        //print("{} {} -> {} {}\n", .{ k / (w + 1), k % (w + 1), n / (w + 1), n % (w + 1) });
                    }

                    // east
                    if ((k + 1) % (w + 1) == w) {
                        n = (k + 1) - w;
                        x = key.x_off + 1;
                        y = key.y_off;
                    } else {
                        n = k + 1;
                        x = key.x_off;
                        y = key.y_off;
                    }

                    if (data[n] != '#') {
                        try next_places.put(.{ .x_off = x, .y_off = y, .k = n }, {});
                        //print("{} {} -> {} {}\n", .{ k / (w + 1), k % (w + 1), n / (w + 1), n % (w + 1) });
                    }

                    // north?
                    if (k < w) {
                        n = data.len - (w + 1) + k;
                        x = key.x_off;
                        y = key.y_off - 1;
                    } else {
                        n = (k - (w + 1));
                        x = key.x_off;
                        y = key.y_off;
                    }

                    if (data[n] != '#') {
                        try next_places.put(.{ .x_off = x, .y_off = y, .k = n }, {});
                        //print("{} {} -> {} {}\n", .{ k / (w + 1), k % (w + 1), n / (w + 1), n % (w + 1) });
                    }

                    // south?
                    if (k + (w + 1) >= data.len) {
                        n = (k + (w + 1)) % data.len;
                        x = key.x_off;
                        y = key.y_off + 1;
                    } else {
                        n = (k + (w + 1));
                        x = key.x_off;
                        y = key.y_off;
                    }

                    if (data[n] != '#') {
                        try next_places.put(.{ .x_off = x, .y_off = y, .k = n }, {});
                        //print("{} {} -> {} {}\n", .{ k / (w + 1), k % (w + 1), n / (w + 1), n % (w + 1) });
                    }
                },
            }
        }

        //print("after step {}\n{any}\n", .{ step, next_places.keys() });
        const tmp = cur_places;
        cur_places = next_places;
        next_places = tmp;
    }

    return cur_places.keys().len;
}

const Part = enum { one, two };

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

const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day14.txt");
//const data = @embedFile("data/day14.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var part1: usize = 0;

    const w = std.mem.indexOfScalar(u8, data, '\n').?;
    print("width={}\n", .{w});

    const h = data.len / (w + 1);
    print("h={}\n", .{h});

    for (0..w) |x| {
        var next_load = h;
        for (0..h) |y| {
            var ch = data[y * (w + 1) + x];
            switch (ch) {
                'O' => {
                    print("char: {} {} = {}\n", .{ x, y, next_load });
                    part1 += next_load;
                    next_load -= 1;
                },
                '#' => {
                    next_load = h - y - 1;
                },
                '.' => continue,
                else => {
                    print("failed {c}\n", .{ch});
                    unreachable;
                },
            }
        }
    }

    print("day 14 part1: {}\n", .{part1});
    print("day 14 main() total: {}\n", .{std.fmt.fmtDuration(timer.read())});
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

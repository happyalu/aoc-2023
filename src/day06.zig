const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.example.txt");
//const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var iter = tokenizeAny(u8, data, ":\n");
    _ = iter.next(); // Time:
    var iter_time = tokenizeAny(u8, iter.next().?, " ");
    _ = iter.next(); // Distance;
    var iter_dist = tokenizeAny(u8, iter.next().?, " ");

    // part1
    var part1: u32 = 1;
    while (true) {
        var t_str = iter_time.next() orelse break;
        var d_str = iter_dist.next() orelse unreachable;

        var t = try parseInt(u32, t_str, 10);
        var d = try parseInt(u32, d_str, 10);

        var matches: u32 = 0;

        var i: u32 = 1;
        while (i < t) : (i += 1) {
            if (i * (t - i) > d) {
                matches += 1;
            }
        }

        part1 *= matches;
    }

    const part2 = 0;

    std.debug.print("part1 {} part2 {}\nmain() total time {}\n", .{ part1, part2, std.fmt.fmtDuration(timer.read()) });
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

const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("data/day04.txt");
const data = @embedFile("data/day04.example.txt");

pub fn main() !void {
    var iter = tokenizeSeq(u8, data, "\n");

    var ans1: u32 = 0;
    var ans2: u32 = 0;

    const max_matches = 64;
    var next_card_extra_count: [max_matches]u32 = [_]u32{0} ** max_matches;

    while (iter.next()) |line| {
        var matches = getCardMatches(line);
        ans2 += 1 + next_card_extra_count[0];

        if (matches > 0) {
            ans1 += std.math.pow(u32, 2, matches - 1);

            var i: u32 = 0;
            while (i <= next_card_extra_count[0]) : (i += 1) {
                for (next_card_extra_count[1 .. matches + 1], 1..) |_, idx| {
                    next_card_extra_count[idx] += 1;
                }
            }
        }
        std.mem.copy(u32, next_card_extra_count[0..], next_card_extra_count[1..]);
        next_card_extra_count[next_card_extra_count.len - 1] = 0;
    }

    print("ans1 = {d}\n", .{ans1});
    print("ans2 = {d}\n", .{ans2});
}

const Card = struct {
    count: u32,
    line: []const u8,
};

fn getCardMatches(line: []const u8) u32 {
    var x = splitSeq(u8, line, ": ");
    _ = x.first();
    var parts = x.rest();

    x = splitSeq(u8, parts, " | ");
    var part1 = x.first();
    var part2 = x.rest();

    var winning = tokenizeSeq(u8, part1, " ");
    var owned = tokenizeSeq(u8, part2, " ");

    var matches: u32 = 0;

    while (owned.next()) |o| {
        winning.reset();
        while (winning.next()) |w| {
            if (std.mem.eql(u8, o, w)) {
                matches += 1;
            }
        }
    }

    return matches;
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

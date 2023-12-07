const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("data/day07.txt");
const data = @embedFile("data/day07.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var iter = tokenizeAny(u8, data, "\n");

    var hands = std.ArrayList(Hand).init(gpa);
    defer hands.deinit();

    while (iter.next()) |line| {
        if (line.len == 0) continue;

        try hands.append(try Hand.parse(line));
    }

    var part1: usize = 0;
    var part2: usize = 0;

    std.sort.block(Hand, hands.items, {}, cmpHandsPart1);
    for (hands.items, 0..) |h, idx| {
        part1 += h.bid * (idx + 1);
    }

    std.sort.block(Hand, hands.items, {}, cmpHandsPart2);
    for (hands.items, 0..) |h, idx| {
        part2 += h.bid * (idx + 1);
    }

    std.debug.print("part1 {} part2 {}\nmain() total time {}\n", .{ part1, part2, std.fmt.fmtDuration(timer.read()) });
}

fn cmpHandsPart1(_: void, a: Hand, b: Hand) bool {
    return a.isLessThan(b, 1);
}

fn cmpHandsPart2(_: void, a: Hand, b: Hand) bool {
    return a.isLessThan(b, 2);
}

const Hand = struct {
    seq: []const u8,
    cards: [5]u8,
    part1_type: HandType,
    part2_type: HandType,
    bid: u32,

    fn parse(line: []const u8) !Hand {
        var h: Hand = undefined;

        var card_count: [13]u8 = [_]u8{0} ** 13;

        h.seq = line[0..5];

        for (line[0..5], 0..) |ch, idx| {
            var card: u8 = if (std.ascii.isDigit(ch)) ch - '2' else switch (ch) {
                'A' => 12,
                'K' => 11,
                'Q' => 10,
                'J' => 9,
                'T' => 8,
                else => unreachable,
            };

            card_count[card] += 1;
            h.cards[idx] = card;
        }

        h.bid = try parseInt(u32, line[6..], 10);

        // assign part 1 type
        h.part1_type = HandType.HighCard;
        for (card_count[0..]) |c| {
            switch (c) {
                5 => {
                    h.part1_type = HandType.FiveKind;
                    break;
                },
                4 => {
                    h.part1_type = HandType.FourKind;
                    break;
                },
                3 => {
                    h.part1_type = if (h.part1_type == HandType.OnePair) HandType.FullHouse else HandType.ThreeKind;
                },
                2 => {
                    h.part1_type = if (h.part1_type == HandType.ThreeKind) HandType.FullHouse else if (h.part1_type == HandType.OnePair) HandType.TwoPair else HandType.OnePair;
                },
                else => continue,
            }
        }

        // assign part 2 type
        h.part2_type = h.part1_type;
        var j = card_count[9];
        if (j == 0) return h;

        switch (h.part1_type) {
            HandType.FiveKind => { // nothing to do
            },

            HandType.FourKind => {
                h.part2_type = HandType.FiveKind;
            },

            HandType.FullHouse => {
                h.part2_type = HandType.FiveKind;
            },

            HandType.ThreeKind => {
                h.part2_type = HandType.FourKind;
            },

            HandType.TwoPair => {
                h.part2_type = if (j == 2) HandType.FourKind else HandType.FullHouse;
            },

            HandType.OnePair => {
                h.part2_type = HandType.ThreeKind;
            },

            HandType.HighCard => {
                h.part2_type = HandType.OnePair;
            },
        }

        return h;
    }

    fn isLessThan(self: Hand, other: Hand, typ: u8) bool {
        var tx = if (typ == 1) self.part1_type else self.part2_type;
        var ty = if (typ == 1) other.part1_type else other.part2_type;

        if (tx == ty) {
            for (self.cards[0..], other.cards[0..]) |x, y| {
                if (x == y) continue;

                if (typ == 1) {
                    return x < y;
                }

                var m = if (x == 9) 0 else x + 1;
                var n = if (y == 9) 0 else y + 1;
                return m < n;
            }
        }
        return @intFromEnum(tx) < @intFromEnum(ty);
    }
};

const HandType = enum {
    HighCard,
    OnePair,
    TwoPair,
    ThreeKind,
    FullHouse,
    FourKind,
    FiveKind,
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

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
    const part2 = 0;

    var iter = tokenizeAny(u8, data, "\n");

    var hands = std.ArrayList(Hand).init(gpa);
    defer hands.deinit();

    while (iter.next()) |line| {
        if (line.len == 0) continue;

        try hands.append(try Hand.parse(line));
    }

    std.sort.block(Hand, hands.items, {}, cmpHands);

    var part1: usize = 0;

    for (hands.items, 0..) |h, idx| {
        part1 += h.bid * (idx + 1);
    }

    //print("{any}\n", .{hands.items});
    std.debug.print("part1 {} part2 {}\nmain() total time {}\n", .{ part1, part2, std.fmt.fmtDuration(timer.read()) });
}

fn cmpHands(_: void, a: Hand, b: Hand) bool {
    return a.isLessThan(b);
}

const Hand = struct {
    cards: [5]u8,
    type: HandType,
    bid: u32,

    fn parse(line: []const u8) !Hand {
        var h: Hand = undefined;

        var card_count: [13]u8 = [_]u8{0} ** 13;

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
        h.type = HandType.HighCard;

        std.sort.block(u8, card_count[0..], {}, std.sort.desc(u8));

        for (card_count[0..]) |c| {
            switch (c) {
                5 => {
                    h.type = HandType.FiveKind;
                    break;
                },
                4 => {
                    h.type = HandType.FourKind;
                    break;
                },
                3 => {
                    h.type = HandType.ThreeKind;
                },
                2 => {
                    h.type = if (h.type == HandType.ThreeKind) HandType.FullHouse else if (h.type == HandType.OnePair) HandType.TwoPair else HandType.OnePair;
                },
                else => continue,
            }
        }

        return h;
    }

    fn isLessThan(self: Hand, other: Hand) bool {
        if (self.type == other.type) {
            for (self.cards[0..], other.cards[0..]) |x, y| {
                if (x == y) continue;
                return x < y;
            }
        }
        return @intFromEnum(self.type) < @intFromEnum(other.type);
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

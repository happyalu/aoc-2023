const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const CubeSet = struct {
    red: u32,
    green: u32,
    blue: u32,

    pub fn init(r: u32, g: u32, b: u32) CubeSet {
        return CubeSet{
            .red = r,
            .green = g,
            .blue = b,
        };
    }

    pub fn parse(str: []const u8) !CubeSet {
        var cs = CubeSet.init(0, 0, 0);
        var iter = tokenizeSeq(u8, str, ",");
        while (iter.next()) |part| {
            var part_iter = tokenizeSeq(u8, part, " ");

            var count_str = part_iter.next() orelse return ParseErr.InvalidItem;
            var color = part_iter.next() orelse return ParseErr.InvalidItem;

            // there should be no other part
            if (part_iter.next() != null) return ParseErr.TooManyParts;

            var count = try parseInt(u32, count_str, 10);

            if (std.mem.eql(u8, color, "red")) {
                cs.red = count;
            }

            if (std.mem.eql(u8, color, "green")) {
                cs.green = count;
            }

            if (std.mem.eql(u8, color, "blue")) {
                cs.blue = count;
            }
        }

        return cs;
    }

    pub fn contains(self: CubeSet, other: CubeSet) bool {
        if (self.red >= other.red and self.green >= other.green and self.blue >= other.blue) {
            return true;
        }
        return false;
    }

    pub fn power(self: CubeSet) u32 {
        return self.red * self.green * self.blue;
    }
};

const ParseErr = error{
    TooManyParts,
    InvalidItem,
};

const Game = struct {
    id: u32,
    sets: [20]CubeSet,

    pub fn parse(line: []const u8) !Game {
        // example line:
        // Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green

        var g = Game{
            .id = 0,
            .sets = [_]CubeSet{CubeSet.init(0, 0, 0)} ** 20,
        };

        var iter = tokenizeSeq(u8, line, ":");

        var game_str = iter.next() orelse return ParseErr.InvalidItem;
        var sets_str = iter.next() orelse return ParseErr.InvalidItem;
        if (iter.next() != null) return ParseErr.TooManyParts;

        if (!std.mem.startsWith(u8, game_str, "Game ")) {
            return ParseErr.InvalidItem;
        }

        g.id = try parseInt(u32, game_str[5..], 10);

        var sets_iter = tokenizeSeq(u8, sets_str, ";");
        var i: usize = 0;
        while (sets_iter.next()) |set_str| : (i += 1) {
            g.sets[i] = try CubeSet.parse(set_str);
        }

        return g;
    }

    pub fn isPossible(self: Game, bag: CubeSet) bool {
        for (self.sets) |s| {
            if (!bag.contains(s)) {
                return false;
            }
        }

        return true;
    }

    pub fn requiredBag(self: Game) CubeSet {
        var b = CubeSet.init(0, 0, 0);

        for (self.sets) |s| {
            if (b.red < s.red) {
                b.red = s.red;
            }
            if (b.green < s.green) {
                b.green = s.green;
            }
            if (b.blue < s.blue) {
                b.blue = s.blue;
            }
        }
        return b;
    }
};

pub fn main() !void {
    var iter = splitSeq(u8, data, "\n");

    const bag = CubeSet.init(12, 13, 14);
    var id_sum: u32 = 0;
    var power_sum: u32 = 0;

    while (iter.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var g = try Game.parse(line);

        if (g.isPossible(bag)) {
            id_sum += g.id;
        }

        power_sum += g.requiredBag().power();
    }

    print("id sum = {d}\n", .{id_sum});
    print("power sum = {d}\n", .{power_sum});
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

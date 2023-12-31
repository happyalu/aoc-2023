const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("data/day03.example.txt");
const data = @embedFile("data/day03.txt");

pub fn main() !void {
    // look at 3 lines at a time to check for symbols.
    var lineBuf: [3][]const u8 = undefined;
    var gearBuf: [3][1024]Gear = undefined;

    var part_sum: u32 = 0;
    var gear_ratio: u32 = 0;

    var iter = tokenizeSeq(u8, data, "\n");

    lineBuf[1] = "." ** 1024;
    lineBuf[2] = iter.next().?;

    for (&gearBuf) |*gb| {
        for (gb) |*x| {
            x.* = Gear{
                .part_count = 0,
                .ratio = 1,
            };
        }
    }

    while (iter.next()) |line| {
        // read next input
        lineBuf[0] = lineBuf[1];
        lineBuf[1] = lineBuf[2];
        lineBuf[2] = line;

        try processParts(lineBuf, &gearBuf, &part_sum, &gear_ratio);

        for (gearBuf[0]) |g| {
            if (g.part_count == 2) {
                gear_ratio += g.ratio;
            }
        }

        std.mem.copy(Gear, &gearBuf[0], &gearBuf[1]);
        std.mem.copy(Gear, &gearBuf[1], &gearBuf[2]);
        for (&gearBuf[2]) |*gb| {
            gb.* = Gear{
                .part_count = 0,
                .ratio = 1,
            };
        }
    }

    lineBuf[0] = lineBuf[1];
    lineBuf[1] = lineBuf[2];
    lineBuf[2] = "." ** 1024;

    try processParts(lineBuf, &gearBuf, &part_sum, &gear_ratio);

    for (gearBuf[0]) |g| {
        if (g.part_count == 2) {
            gear_ratio += g.ratio;
        }
    }

    print("part_sum: {d}\n", .{part_sum});
    print("gear_ratio: {d}\n", .{gear_ratio});
}

const Gear = struct {
    part_count: u32,
    ratio: u32,
};

fn isSymbol(c: u8) bool {
    if (c != '.' and !std.ascii.isDigit(c)) {
        return true;
    }
    return false;
}

fn processParts(lineBuf: [3][]const u8, gearBuf: *[3][1024]Gear, part_sum: *u32, gear_ratio: *u32) !void {
    _ = gear_ratio;
    var b_pos: ?usize = null;
    var e_pos: usize = 0;

    var cl = lineBuf[1];

    while (e_pos <= cl.len) : (e_pos += 1) {
        if (e_pos < cl.len and std.ascii.isDigit(cl[e_pos])) {
            b_pos = b_pos orelse e_pos;
            continue;
        }

        if (b_pos != null) {
            // a full number has been matched; let's see if it is a part number.

            blk: for (lineBuf, 0..) |l, idx1| {
                var i = if (b_pos.? > 0) b_pos.? - 1 else 0;
                var j = if (e_pos < l.len) e_pos + 1 else l.len;
                for (l[i..j], 0..) |c, idx2| {
                    if (isSymbol(c)) {
                        var num = try parseInt(u32, cl[b_pos.?..e_pos], 10);
                        part_sum.* += num;

                        if (c == '*') {
                            gearBuf[idx1][idx2 + i].part_count += 1;
                            gearBuf[idx1][idx2 + i].ratio *= num;
                        }

                        break :blk;
                    }
                }
            }

            b_pos = null;
        }
    }
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

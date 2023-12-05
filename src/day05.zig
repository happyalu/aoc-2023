const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("data/day05.txt");
const data = @embedFile("data/day05.example.txt");

pub fn main() !void {
    var iter = splitSeq(u8, data, "\n\n");
    var line = iter.first();

    var idx = std.mem.indexOf(u8, line, ": ").?;
    var seeds = std.mem.tokenize(u8, line[idx + 1 ..], " ");

    var seed_to_soil_map = try AlmanacMap.read(iter.next().?);
    var soil_to_fertilizer_map = try AlmanacMap.read(iter.next().?);
    var fertilizer_to_water_map = try AlmanacMap.read(iter.next().?);
    var water_to_light_map = try AlmanacMap.read(iter.next().?);
    var light_to_temperature_map = try AlmanacMap.read(iter.next().?);
    var temperature_to_humidity_map = try AlmanacMap.read(iter.next().?);
    var humidity_to_location_map = try AlmanacMap.read(iter.next().?);

    var ans1: usize = std.math.maxInt(usize);

    // problem 1
    while (seeds.next()) |s| {
        var seed = try parseInt(usize, s, 10);
        var out: usize = seed;
        for ([_]AlmanacMap{ seed_to_soil_map, soil_to_fertilizer_map, fertilizer_to_water_map, water_to_light_map, light_to_temperature_map, temperature_to_humidity_map, humidity_to_location_map }) |m| {
            out = m.map(out);
        }

        ans1 = if (ans1 < out) ans1 else out;
        print("seed: {d} => location: {d}\n", .{ seed, out });
    }

    print("min_location: {d}\n", .{ans1});
}

const Range = struct {
    dest_start: usize,
    src_start: usize,
    range_length: usize,

    fn map(self: Range, x: usize) ?usize {
        if (x < self.src_start) return null;
        if (x >= self.src_start + self.range_length) return null;

        return self.dest_start + (x - self.src_start);
    }
};

const AlmanacMap = struct {
    name: []const u8,
    ranges: std.BoundedArray(Range, 64),

    fn read(str: []const u8) !AlmanacMap {
        var out: AlmanacMap = .{
            .name = undefined,
            .ranges = try std.BoundedArray(Range, 64).init(0),
        };

        var iter = tokenizeSeq(u8, str, "\n");

        out.name = iter.next().?;
        if (!std.mem.endsWith(u8, out.name, "map:")) {
            return error.ParseError;
        }

        while (iter.next()) |line| {
            var x = std.mem.split(u8, line, " ");
            var p1 = try parseInt(usize, x.next().?, 10);
            var p2 = try parseInt(usize, x.next().?, 10);
            var p3 = try parseInt(usize, x.next().?, 10);

            try out.ranges.append(Range{ .dest_start = p1, .src_start = p2, .range_length = p3 });
        }

        return out;
    }

    fn map(self: AlmanacMap, x: usize) usize {
        var out: ?usize = null;

        for (self.ranges.buffer) |r| {
            out = r.map(x);
            if (out != null) return out.?;
        }

        return x;
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

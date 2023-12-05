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

    var allMaps = [_]AlmanacMap{ seed_to_soil_map, soil_to_fertilizer_map, fertilizer_to_water_map, water_to_light_map, light_to_temperature_map, temperature_to_humidity_map, humidity_to_location_map };

    var finalMap: AlmanacMap = allMaps[0];
    for (allMaps[1..]) |m| {
        finalMap = try finalMap.compose(m);
    }

    var ans1: usize = std.math.maxInt(usize);

    // problem 1
    while (seeds.next()) |s| {
        var seed = try parseInt(usize, s, 10);
        var out: usize = finalMap.map(seed);
        ans1 = if (ans1 < out) ans1 else out;
    }

    print("ans1: {d}\n", .{ans1});

    // problem 2
    var ans2: usize = std.math.maxInt(usize);
    seeds.reset();

    while (seeds.next()) |begin| {
        var range = seeds.next().?;

        var x = try parseInt(usize, begin, 10);
        var y = try parseInt(usize, range, 10);

        var r = Range{
            .dest_start = x,
            .src_start = x,
            .range_length = y,
        };

        var am = AlmanacMap{
            .name = "seed",
            .ranges = std.ArrayList(Range).init(gpa),
        };

        try am.ranges.append(r);
        var locations = try am.compose(finalMap);

        var out: usize = std.math.maxInt(usize);
        for (locations.ranges.items) |i| {
            if (i.dest_start < out) {
                out = i.dest_start;
            }
        }

        ans2 = if (ans2 < out) ans2 else out;
    }

    print("ans2: {d}\n", .{ans2});
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

    pub fn format(value: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) std.os.WriteError!void {
        return writer.print("[{d}--{d}) => [{d}--{d})", .{ value.src_start, value.src_start + value.range_length, value.dest_start, value.dest_start + value.range_length });
    }

    fn overlapOffset(self: Range, other: Range) ?usize {
        var a = self.src_start;
        var b = self.src_start + self.range_length;
        var c = other.src_start;
        var d = other.src_start + other.range_length;

        if (a >= d or b <= c) {
            return null;
        }

        if (a < c) {
            return c - a;
        }

        if (d < b) {
            return d - a;
        }

        if (a >= c and b <= d) {
            return b - a;
        }

        return null;
    }
};

const AlmanacMap = struct {
    name: []const u8,
    ranges: std.ArrayList(Range),

    fn read(str: []const u8) !AlmanacMap {
        var out: AlmanacMap = .{
            .name = undefined,
            .ranges = std.ArrayList(Range).init(gpa),
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

        out.sortRanges();

        if (out.ranges.items[0].src_start != 0) {
            try out.ranges.insert(0, Range{
                .src_start = 0,
                .dest_start = 0,
                .range_length = out.ranges.items[0].src_start,
            });
        }

        var x = out.ranges.items[out.ranges.items.len - 1];

        try out.ranges.append(Range{
            .dest_start = x.src_start + x.range_length,
            .src_start = x.src_start + x.range_length,
            .range_length = std.math.maxInt(usize) - x.src_start - x.range_length,
        });

        return out;
    }

    fn map(self: AlmanacMap, x: usize) usize {
        var out: ?usize = null;

        for (self.ranges.items) |r| {
            out = r.map(x);
            if (out != null) return out.?;
        }

        return x;
    }

    fn compareRanges(_: void, a: Range, b: Range) bool {
        return if (a.src_start < b.src_start) true else false;
    }

    fn sortRanges(self: AlmanacMap) void {
        std.sort.heap(Range, self.ranges.items, {}, compareRanges);
    }

    fn compose(self: AlmanacMap, other: AlmanacMap) !AlmanacMap {
        var out = AlmanacMap{
            .name = "composed",
            .ranges = std.ArrayList(Range).init(gpa),
        };

        for (self.ranges.items) |x| {
            var y = Range{
                .src_start = x.dest_start,
                .range_length = x.range_length,
                .dest_start = 0,
            };

            for (other.ranges.items) |z| {
                var o = y.overlapOffset(z);
                if (o != null) {
                    var r = Range{
                        .src_start = x.src_start + (y.src_start - x.dest_start),
                        .dest_start = other.map(self.map(x.src_start + y.src_start - x.dest_start)),
                        .range_length = o.?,
                    };

                    try out.ranges.append(r);
                    y.src_start += o.?;
                    y.range_length -= o.?;
                }
            }
        }

        out.sortRanges();
        return out;
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

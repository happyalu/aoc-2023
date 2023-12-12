const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");
//const data = @embedFile("data/day12.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var align_memo = std.ArrayHashMap(GivenTarget, usize, MappingContext, true).init(alloc);

    var iter = std.mem.tokenize(u8, data, "\n");

    var parts = [2]usize{ 0, 0 };

    while (iter.next()) |line| {
        if (line.len == 0) continue;
        var split = std.mem.tokenize(u8, line, " ");

        var x = split.next().?;
        var y = split.next().?;

        for ([_]Part{ Part.one, Part.two }, 0..) |part, idx| {
            var given = try givenString(alloc, x, part);
            defer alloc.free(given);

            var target = try targetString(alloc, y, part);
            defer alloc.free(target);

            var count = try countAlignments(&align_memo, given, target);
            //print("{s} <==> {s} part {} = {}\n", .{ given, target, part, count });
            parts[idx] += count;
        }
    }

    print("part1: {}\n", .{parts[0]});
    print("part2: {}\n", .{parts[1]});
    print("day 12 main() time: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Part = enum { one, two };

const MappingContext = struct {
    pub fn hash(self: @This(), key: GivenTarget) u32 {
        _ = self;

        var hasher = std.hash.Wyhash.init(0);

        hasher.update(key.given);
        hasher.update(key.target);

        return @truncate(hasher.final());
    }

    pub fn eql(self: @This(), key_1: GivenTarget, key_2: GivenTarget, b_size: usize) bool {
        _ = b_size;
        _ = self;

        return std.mem.eql(u8, key_1.given, key_2.given) and std.mem.eql(u8, key_2.target, key_2.target);
    }
};
const GivenTarget = struct {
    given: []u8,
    target: []u8,
};

fn countAlignments(align_memo: *std.ArrayHashMap(GivenTarget, usize, MappingContext, true), x: []u8, y: []u8) !usize {
    //print("matching {s} with {s}\n", .{ x, y });

    var kv = .{ .given = x, .target = y };

    var memoized = align_memo.get(kv);
    if (memoized != null) return memoized.?;

    if (x.len == 0) {
        return 0;
    }

    if (y.len == 0) {
        for (x) |c| {
            if (c != '.' and c != '?') {
                return 0;
            }
        }
        return 1;
    }

    switch (x[0]) {
        '#' => {
            // we are in a group; so both x and y must match as long as both have # or ?
            var group_len: usize = 0;
            for (y) |c| {
                if (c == '#') group_len += 1 else break;
            }

            if (group_len == 0) {
                return 0;
            }

            //print("{}\n", .{group_len});

            if (x.len < group_len) {
                return 0;
            }

            for (x[0..group_len]) |c| {
                if (c != '#' and c != '?') {
                    return 0;
                }
            }

            if (x.len == group_len and y.len == group_len) {
                return 1;
            }

            var out = try countAlignments(align_memo, x[group_len..], y[group_len..]);
            return out;
        },
        '.' => {
            var out: usize = undefined;

            if (y[0] == '.') {
                out = try countAlignments(align_memo, x[1..], y[1..]);
            } else out = try countAlignments(align_memo, x[1..], y);

            return out;
        },
        '?' => {
            x[0] = '.';
            var a = try countAlignments(align_memo, x, y);

            x[0] = '#';
            var b = try countAlignments(align_memo, x, y);

            x[0] = '?';

            try align_memo.put(kv, a + b);
            //print("foo: {s} with {s} = {} {}\n", .{ x, y, a, b });
            return a + b;
        },
        else => unreachable,
    }

    return 0;
}

fn givenString(alloc: std.mem.Allocator, s: []const u8, part: Part) ![]u8 {
    if (part == Part.one) {
        return alloc.dupe(u8, s);
    } else {
        var len = s.len * 5 + 4;
        var out = try alloc.alloc(u8, len);
        var i: usize = 0;
        for (0..5) |_| {
            std.mem.copy(u8, out[i..], s);
            i += s.len;
            if (i < out.len) {
                out[i] = '?';
                i += 1;
            }
        }
        return out;
    }
}

fn targetString(alloc: std.mem.Allocator, str: []const u8, part: Part) ![]u8 {
    var iter = std.mem.tokenize(u8, str, ",");
    var n = std.ArrayList(u32).init(alloc);
    defer n.deinit();

    var count: usize = 0;
    while (iter.next()) |s| {
        var i = try parseInt(u8, s, 10);
        try n.append(i);
        count += i;
    }

    //print("{any} count {}\n", .{ n.items, count });

    if (part == Part.two) {
        var n_len = n.items.len;
        for (0..4) |_| {
            for (0..n_len) |i| {
                try n.append(n.items[i]);
                count += n.items[i];
            }
        }
    }
    //print("{any}\n", .{n.items});

    var l = count + n.items.len - 1;
    var out = try alloc.alloc(u8, l);

    var i: usize = 0;
    for (n.items, 0..) |x, idx| {
        if (idx > 0) {
            out[i] = '.';
            i += 1;
        }

        for (0..x) |_| {
            out[i] = '#';
            i += 1;
        }
    }
    return out;
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

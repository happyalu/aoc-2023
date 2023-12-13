const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");
//const data = @embedFile("data/day13.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var h = std.ArrayList(bool).init(alloc);
    var v = std.ArrayList(bool).init(alloc);
    var linelist = std.ArrayList([]const u8).init(alloc);
    var iter = std.mem.tokenizeSequence(u8, data, "\n\n");

    var part1: usize = 0;
    while (iter.next()) |pattern| {
        h.clearRetainingCapacity();
        v.clearRetainingCapacity();
        linelist.clearRetainingCapacity();

        var lines = std.mem.tokenize(u8, pattern, "\n");
        var h_len = lines.peek().?.len;

        try h.appendNTimes(true, h_len);

        var v_idx: usize = 0;
        while (lines.next()) |line| : (v_idx += 1) {
            try linelist.append(line);
            try v.append(true);

            //print("{s}\n", .{line});
            for (1..h_len) |i| {
                var ref_len = @min(i, h_len - i);
                for (0..ref_len) |j| {
                    //print("{} {} {c} {c}\n", .{ i, j, line[i - j - 1], line[i + j] });
                    if (line[i - j - 1] != line[i + j]) {
                        h.items[i] = false;
                    }
                }
            }
        }

        for (1..linelist.items.len) |i| {
            var ref_len = @min(i, linelist.items.len - i);
            for (0..ref_len) |j| {
                if (!std.mem.eql(u8, linelist.items[i - j - 1], linelist.items[i + j])) {
                    v.items[i] = false;
                }
            }
        }

        for (h.items[1..h.items.len], 1..) |x, idx| {
            if (x) {
                part1 += idx;
            }
        }

        for (v.items[1..v.items.len], 1..) |x, idx| {
            if (x) {
                part1 += 100 * idx;
            }
        }

        //print("v: {any}\n", .{v.items});
        //print("h: {any}\n", .{h.items});
    }

    print("day 13: part1 = {}\n", .{part1});
    print("day 13: main() total: {}\n", .{std.fmt.fmtDuration(timer.read())});
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

const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day14.txt");
//const data = @embedFile("data/day14.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const w = std.mem.indexOfScalar(u8, data, '\n').?;
    const h = data.len / (w + 1);
    assert(w == h);

    var board = try alloc.alloc(u8, w * w);

    for (0..w) |i| {
        for (0..w) |j| {
            board[i * w + j] = data[i * (w + 1) + j];
        }
    }

    var boardSeen = std.StringArrayHashMap(usize).init(alloc);
    defer boardSeen.deinit();

    var part1: usize = 0;
    const num_cycles = 1000000000;
    var c: usize = 1;
    var cycle_length: ?usize = null;
    cycles: while (c <= num_cycles) {
        // north tilt
        rotateClockwise(w, &board);
        tiltEast(w, &board);
        if (c == 1) {
            part1 = getEastLoad(w, board);
        }

        // west tilt
        rotateClockwise(w, &board);
        tiltEast(w, &board);

        // south tilt
        rotateClockwise(w, &board);
        tiltEast(w, &board);

        // east tilt
        rotateClockwise(w, &board);
        tiltEast(w, &board);

        if (cycle_length == null) {
            var f = try alloc.dupe(u8, board);
            var s = try boardSeen.getOrPut(f);
            if (s.found_existing) {
                var idx = s.value_ptr.*;
                cycle_length = c - idx;

                idx = (num_cycles - idx) % (cycle_length.?) + idx;

                var it = boardSeen.iterator();
                while (it.next()) |b| {
                    if (b.value_ptr.* == idx) {
                        std.mem.copy(u8, board, b.key_ptr.*);
                        break :cycles;
                    }
                }
            } else {
                s.value_ptr.* = c;
            }
        }

        c += 1;
    }

    rotateClockwise(w, &board);
    var part2 = getEastLoad(w, board);

    print("day 14 part1: {}\n", .{part1});
    print("day 14 part2: {}\n", .{part2});
    print("day 14 main() total: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn tiltEast(n: usize, board: *[]u8) void {
    for (0..n) |i| {
        var line = board.*[i * n .. (i + 1) * n];
        var next_free: usize = line.len - 1;
        for (0..line.len) |jx| {
            var j = line.len - jx - 1;
            var ch = line[j];
            switch (ch) {
                'O' => {
                    if (next_free != j) {
                        line[next_free] = 'O';
                        line[j] = '.';
                    }
                    if (j > 0) next_free -= 1;
                },
                '.' => {
                    continue;
                },
                '#' => {
                    next_free = if (j > 0) j - 1 else 0;
                },
                else => unreachable,
            }
        }
    }
}

fn rotateClockwise(n: usize, board: *[]u8) void {
    var a = board.*;

    for (0..n) |i| {
        for (0..i) |j| {
            var temp = a[i * n + j];
            a[i * n + j] = a[j * n + i];
            a[j * n + i] = temp;
        }
    }

    for (0..n) |i| {
        std.mem.reverse(u8, a[i * n .. (i + 1) * n]);
    }
}

fn getEastLoad(n: usize, board: []u8) usize {
    var out: usize = 0;
    for (0..n) |i| {
        for (0..n) |j| {
            if (board[i * n + j] == 'O') {
                out += 1 + j;
            }
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

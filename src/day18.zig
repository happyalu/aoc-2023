const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day18.txt");
//const data = @embedFile("data/day18.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const w = 1000;
    const h = 1000;
    var ground: [h][w]Node = undefined;

    for (0..h) |y| {
        for (0..w) |x| {
            ground[y][x] = .{ .hole = false, .label = '.' };
        }
    }

    ground[300][300].hole = true;
    ground[300][300].label = '.';

    var x: usize = 300;
    var y: usize = 300;

    var prev_dir: u8 = '0';
    var iter = std.mem.tokenize(u8, data, "\n");
    var prev_line_end: ?*Node = null;
    while (iter.next()) |line| {
        var part_iter = std.mem.tokenize(u8, line, " ");
        var dir = part_iter.next().?;
        var count = try std.fmt.parseInt(usize, part_iter.next().?, 10);
        var color = part_iter.next().?;
        _ = color;

        var p: *usize = undefined;
        var step: isize = 0;
        switch (dir[0]) {
            'R' => {
                p = &x;
                step = 1;
            },
            'L' => {
                p = &x;
                step = -1;
            },
            'D' => {
                p = &y;
                step = 1;
            },
            'U' => {
                p = &y;
                step = -1;
            },
            else => unreachable,
        }

        var end: *Node = undefined;
        for (0..count) |i| {
            print("{c}\n", .{dir[0]});
            if (step == 1) p.* += 1 else p.* -= 1;
            ground[y][x].hole = true;
            //ground[y][x].label = '.';

            if (i == 0 and prev_line_end != null) {
                if (prev_dir == 'D' and dir[0] == 'R') prev_line_end.?.label = 'L' else if (prev_dir == 'L' and dir[0] == 'U') prev_line_end.?.label = 'L' else if (prev_dir == 'D' and dir[0] == 'L') prev_line_end.?.label = 'J' else if (prev_dir == 'R' and dir[0] == 'U') prev_line_end.?.label = 'J' else prev_line_end.?.label = '.';
            }
            if (dir[0] == 'D' or dir[0] == 'U') ground[y][x].label = '|';

            end = &ground[y][x];
        }
        prev_line_end = end;
        prev_dir = dir[0];
    }

    ground[300][300].label = '.';
    var part1: usize = 0;
    for (0..h) |i| {
        var inside: bool = false;

        for (0..w) |j| {
            if (ground[i][j].label != '.') {
                inside = !inside;
            }
            if (ground[i][j].hole) {
                part1 += 1;
            } else {
                if (inside) {
                    print("{} {}\n", .{ i, j });
                    part1 += 1;
                }
            }
        }
    }

    for (0..h) |i| {
        for (0..w) |j| {
            print("{c}", .{ground[i][j].label});
        }
        print("\n", .{});
    }

    //print("{any}\n", .{ground});
    print("day 18 part1: {}\n", .{part1});
    print("day 18 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Node = struct {
    hole: bool,
    label: u8,
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

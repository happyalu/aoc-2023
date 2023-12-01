const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var lines = splitSeq(u8, data, "\n");

    var sum_calibration_part1: u32 = 0;
    var sum_calibration_part2: u32 = 0;

    while (lines.next()) |line| {
        sum_calibration_part1 += getCalibrationPart1(line);
        sum_calibration_part2 += getCalibrationPart2(line);
    }

    print("sum calibration_part1: {d}\n", .{sum_calibration_part1});
    print("sum calibration_part2: {d}\n", .{sum_calibration_part2});
}

fn getCalibrationPart1(line: []const u8) u32 {
    var calibration: u32 = 0;
    var firstFound: bool = false;

    var prevDigit: u8 = '0';

    for (line) |c| {
        if (std.ascii.isDigit(c)) {
            prevDigit = c;

            if (!firstFound) {
                calibration += 10 * (c - '0');
                firstFound = true;
            }
        }
    }

    calibration += prevDigit - '0';

    //print("line: {s}\tdigits={d}\n", .{ line, calibration });

    return calibration;
}

fn getCalibrationPart2(line: []const u8) u32 {
    var calibration: u32 = 0;

    var firstFound: bool = false;
    var prevDigit: ?u8 = null;
    var i: usize = 0;

    const digit_names = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    while (i < line.len) : (i += 1) {
        var c: u8 = line[i];
        if (std.ascii.isDigit(c)) {
            prevDigit = c - '0';
        } else {
            for (digit_names, 0..) |name, num| {
                if (std.mem.startsWith(u8, line[i..], name)) {
                    prevDigit = @as(u8, @intCast(num));
                    break;
                }
            }
        }

        if (prevDigit != null) {
            if (!firstFound) {
                calibration += 10 * (prevDigit.?);
                firstFound = true;
            }
        }
    }

    calibration += (prevDigit orelse 0);
    return calibration;
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

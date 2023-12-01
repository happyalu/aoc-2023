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

    while (i < line.len) {
        //print("{s} {d}\n", .{ line, i });
        var c: u8 = line[i];
        if (std.ascii.isDigit(c)) {
            prevDigit = c;
        } else {
            switch (c) {
                'o' => {
                    if (i + 3 <= line.len and (std.mem.eql(u8, line[i .. i + 3], "one"))) {
                        prevDigit = '1';
                        //i += 2;
                        //print("found one\n", .{});
                    }
                },
                't' => {
                    if (i + 3 <= line.len and std.mem.eql(u8, line[i .. i + 3], "two")) {
                        prevDigit = '2';
                        //i += 2;
                        //print("found two\n", .{});
                    } else if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "three")) {
                        prevDigit = '3';
                        //i += 4;
                        //print("found three\n", .{});
                    }
                },
                'f' => {
                    if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "four")) {
                        prevDigit = '4';
                        //i += 3;
                        //print("found four\n", .{});
                    } else if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "five")) {
                        prevDigit = '5';
                        //i += 3;
                        //print("found five\n", .{});
                    }
                },
                's' => {
                    if (i + 3 <= line.len and std.mem.eql(u8, line[i .. i + 3], "six")) {
                        prevDigit = '6';
                        //i += 2;
                        //print("found six\n", .{});
                    } else if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "seven")) {
                        prevDigit = '7';
                        //i += 4;
                        //print("found seven\n", .{});
                    }
                },
                'e' => {
                    if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "eight")) {
                        prevDigit = '8';
                        //i += 4;
                        //print("found eight\n", .{});
                    }
                },
                'n' => {
                    if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "nine")) {
                        prevDigit = '9';
                        //i += 3;
                        //print("found nine\n", .{});
                    }
                },
                else => {},
            }
        }
        i += 1;

        if (prevDigit != null) {
            if (!firstFound) {
                calibration += 10 * (prevDigit.? - '0');
                firstFound = true;
            }
        }
    }

    calibration += (prevDigit orelse '0') - '0';

    print("line {s} calib2 = {d}\n", .{ line, calibration });

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

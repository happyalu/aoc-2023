const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day24.txt");
const limits: [2]Pf = .{ .{ 200000000000000, 200000000000000, 200000000000000 }, .{ 400000000000000, 400000000000000, 400000000000000 } };

//const data = @embedFile("data/day24.example.txt");
//const limits: [2]Pf = .{ .{ 7, 7, 0 }, .{ 27, 27, 0 } };

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stones = try read_stones(alloc);

    var part1: usize = 0;
    for (0..stones.items.len) |i| {
        const a = stones.items[i];
        for (i + 1..stones.items.len) |j| {
            const b = stones.items[j];

            if (a.pathsCrossXY(b, limits, true)) {
                part1 += 1;
            }
        }
    }

    print("day24: part1: {}\n", .{part1});

    print("day24: all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn read_stones(alloc: std.mem.Allocator) !std.ArrayList(Stone) {
    var out = std.ArrayList(Stone).init(alloc);

    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        var points: [2]P = undefined;
        const idx_at = std.mem.indexOfScalar(u8, line, '@').?;
        for ([_][]const u8{ line[0..idx_at], line[idx_at + 1 ..] }, 0..) |col, idx| {
            var iter2 = std.mem.tokenizeAny(u8, col, ", ");
            points[idx][0] = try std.fmt.parseInt(isize, iter2.next().?, 10);
            points[idx][1] = try std.fmt.parseInt(isize, iter2.next().?, 10);
            points[idx][2] = try std.fmt.parseInt(isize, iter2.next().?, 10);
        }

        try out.append(.{ .pos = points[0], .vel = points[1] });
    }

    return out;
}

const Stone = struct {
    pos: P,
    vel: P,

    fn pathsCrossXY(self: Stone, other: Stone, lim: [2]Pf, noz: bool) bool {
        //print("comparing {} with {}\n", .{ self, other });
        var a = self;
        var b = other;
        var l = lim;
        if (noz) {
            a.pos[2] = 0;
            a.vel[2] = 0;
            b.pos[2] = 0;
            b.vel[2] = 0;
            l[0][2] = 0;
            l[1][2] = 0;
        }

        const d: f64 = @floatFromInt((a.vel[0] * b.vel[1]) - (a.vel[1] * b.vel[0]));
        if (d == 0) {
            print("{} and {}\n", .{ self, other });
            return false; // parallel paths
        }

        const c1 = b.pos - a.pos;

        const t1: f64 = @as(f64, @floatFromInt((c1[0] * b.vel[1] - c1[1] * b.vel[0]))) / d;
        const t2: f64 = @as(f64, @floatFromInt((c1[0] * a.vel[1] - c1[1] * a.vel[0]))) / d;

        if (t1 < 0 or t2 < 0) return false; // collision in the past

        const cx: f64 = @as(f64, @floatFromInt(a.pos[0])) + t1 * @as(f64, @floatFromInt(a.vel[0]));
        const cy: f64 = @as(f64, @floatFromInt(a.pos[1])) + t1 * @as(f64, @floatFromInt(a.vel[1]));
        const cz: f64 = @as(f64, @floatFromInt(a.pos[2])) + t1 * @as(f64, @floatFromInt(a.vel[2]));

        const collision = Pf{ cx, cy, if (noz) 0 else cz };

        if (@reduce(.Or, collision < l[0])) return false; // outside area
        if (@reduce(.Or, collision > l[1])) return false; // outside area

        //print("true {}\n", .{collision});
        return true;
    }
};

const P = @Vector(3, isize);
const Pf = @Vector(3, f64);

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

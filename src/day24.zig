const std = @import("std");

const data = @embedFile("data/day24.txt");
const limits: [2]Pf = .{ .{ 200000000000000, 200000000000000, 0 }, .{ 400000000000000, 400000000000000, 0 } };

//const data = @embedFile("data/day24.example.txt");
//const limits: [2]Pf = .{ .{ 7, 7, 0 }, .{ 27, 27, 0 } };

const P = @Vector(3, isize);
const Pf = @Vector(3, f64);

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

            if (a.pathsCrossXY(b)) {
                part1 += 1;
            }
        }
    }

    // part2
    var part2: isize = 0;
    var vel_range = try std.BoundedArray(isize, 1000).init(0);
    for (0..500) |u| {
        const i: isize = @intCast(u);
        try vel_range.append(i);
        try vel_range.append(-1 * i);
    }

    const s1 = stones.items[0];
    const s2 = stones.items[1];
    const s3 = stones.items[2];
    vxloop: for (vel_range.slice()) |vx| {
        for (vel_range.slice()) |vy| {
            for (vel_range.slice()) |vz| {
                var s1_new = s1;
                var s2_new = s2;
                s1_new.vel -= .{ vx, vy, vz };
                s2_new.vel -= .{ vx, vy, vz };

                const x1 = s1_new.integerIntersect(s2_new) orelse continue;

                var s3_new = s3;
                s3_new.vel -= .{ vx, vy, vz };

                const x2 = s2_new.integerIntersect(s3_new) orelse continue;
                if (@reduce(.And, x1 == x2)) {
                    part2 = @reduce(.Add, x1);
                    break :vxloop;
                }
            }
        }
    }

    print("day24: part1: {}\n", .{part1});
    print("day24: part2: {}\n", .{part2});
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

    fn pathsCrossXY(self: Stone, other: Stone) bool {
        //print("comparing {} with {}\n", .{ self, other });
        var a = self;
        var b = other;
        a.pos[2] = 0;
        a.vel[2] = 0;
        b.pos[2] = 0;
        b.vel[2] = 0;

        const d: f64 = @floatFromInt((a.vel[0] * b.vel[1]) - (a.vel[1] * b.vel[0]));
        if (d == 0) {
            //print("{} and {}\n", .{ self, other });
            return false; // parallel paths
        }

        const c1 = b.pos - a.pos;

        const t1: f64 = @as(f64, @floatFromInt((c1[0] * b.vel[1] - c1[1] * b.vel[0]))) / d;
        const t2: f64 = @as(f64, @floatFromInt((c1[0] * a.vel[1] - c1[1] * a.vel[0]))) / d;

        if (t1 < 0 or t2 < 0) return false; // collision in the past

        const cx: f64 = @as(f64, @floatFromInt(a.pos[0])) + t1 * @as(f64, @floatFromInt(a.vel[0]));
        const cy: f64 = @as(f64, @floatFromInt(a.pos[1])) + t1 * @as(f64, @floatFromInt(a.vel[1]));

        const collision = Pf{ cx, cy, 0 };

        if (@reduce(.Or, collision < limits[0])) return false; // outside area
        if (@reduce(.Or, collision > limits[1])) return false; // outside area

        //print("true {}\n", .{collision});
        return true;
    }

    fn integerIntersect(self: Stone, other: Stone) ?P {
        const a = self;
        const b = other;

        const d = a.vel[0] * b.vel[1] - a.vel[1] * b.vel[0];
        if (d == 0) return null;

        const c1 = b.pos - a.pos;

        const t1_num = (c1[0] * b.vel[1] - c1[1] * b.vel[0]);
        const t2_num = (c1[0] * a.vel[1] - c1[1] * a.vel[0]);

        if (@mod(t1_num, d) != 0) return null;
        if (@mod(t2_num, d) != 0) return null;

        const t1: P = @splat(@divExact(t1_num, d));
        const t2: P = @splat(@divExact(t2_num, d));

        if (t1[0] < 0 or t2[0] < 0) return null;

        const intersect = a.pos + t1 * a.vel;
        return intersect;
    }
};

// Useful stdlib functions
const print = std.debug.print;

const std = @import("std");

const data = @embedFile("data/day22.txt");
//const data = @embedFile("data/day22.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var bricks = try readBricks(alloc);
    try bricks.append(try Brick.init(alloc, .{ .{ 0, 0, 0 }, .{ std.math.maxInt(u16), std.math.maxInt(u16), 0 } }));
    std.sort.block(Brick, bricks.items, {}, Brick.lowerThan);

    // make all bricks fall down
    for (1..bricks.items.len) |i| {
        var rest: u16 = 0;
        for (1..i) |j| {
            if (bricks.items[j].overlaps(bricks.items[i])) {
                rest = @max(rest, bricks.items[j].p[1][2]);
            }
        }
        const diff = bricks.items[i].p[0][2] - rest - 1;

        for (0..2) |j| {
            bricks.items[i].p[j] -= .{ 0, 0, diff };
        }
    }

    std.sort.block(Brick, bricks.items, {}, Brick.lowerThan);

    for (1..bricks.items.len) |i| {
        for (1..i) |j| {
            if (bricks.items[j].p[1][2] == bricks.items[i].p[0][2] - 1 and bricks.items[j].overlaps(bricks.items[i])) {
                try bricks.items[j].supports.append(i);
                try bricks.items[i].supportedBy.append(j);
            }
        }
    }

    var part1: usize = 0;
    for (1..bricks.items.len) |i| {
        const x = bricks.items[i].supports.items;
        if (x.len == 0) {
            part1 += 1;
            continue;
        }

        var can_remove = true;
        for (x) |v| {
            if (bricks.items[v].supportedBy.items.len == 1) {
                can_remove = false;
            } else {}
        }

        if (can_remove) {
            part1 += 1;
        }
    }

    var part2: usize = 0;
    var q = std.ArrayList(usize).init(alloc);
    var fallen = std.AutoArrayHashMap(usize, void).init(alloc);

    for (1..bricks.items.len) |idx| {
        fallen.clearRetainingCapacity();
        q.clearRetainingCapacity();
        const i = bricks.items.len - idx;
        try fallen.put(i, {});
        try q.appendSlice(bricks.items[i].supports.items);

        while (q.popOrNull()) |v| {
            const b = bricks.items[v];
            for (b.supportedBy.items) |s| {
                if (fallen.get(s) == null) break;
            } else {
                try fallen.put(v, {});
                try q.appendSlice(bricks.items[v].supports.items);
            }
        }

        part2 += fallen.count() - 1;
    }

    print("day22 part1: {}\n", .{part1});
    print("day22 part2: {}\n", .{part2});
    print("day22 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Brick = struct {
    p: [2]Point,
    supportedBy: std.ArrayList(usize),
    supports: std.ArrayList(usize),

    fn init(alloc: std.mem.Allocator, p: [2]Point) !Brick {
        return .{
            .p = p,
            .supportedBy = std.ArrayList(usize).init(alloc),
            .supports = std.ArrayList(usize).init(alloc),
        };
    }

    fn lowerThan(_: void, a: Brick, b: Brick) bool {
        return a.p[0][2] < b.p[0][2];
    }

    fn overlaps(self: Brick, b: Brick) bool {
        var r11 = self.p[0];
        r11[2] = 0;
        var r12 = self.p[1];
        r12[2] = 0;

        var r21 = b.p[0];
        r21[2] = 0;

        var r22 = b.p[1];
        r22[2] = 0;

        return @reduce(.And, r11 <= r22) and @reduce(.And, r21 <= r12);
    }
};

const Point = @Vector(3, u16);

fn readBricks(alloc: std.mem.Allocator) !std.ArrayList(Brick) {
    var bricks = std.ArrayList(Brick).init(alloc);

    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        var p: [2]Point = undefined;

        const t = std.mem.indexOfScalar(u8, line, '~').?;

        for ([_][]const u8{ line[0..t], line[t + 1 ..] }, 0..) |x, idx| {
            var it = std.mem.tokenizeScalar(u8, x, ',');
            p[idx][0] = try std.fmt.parseInt(u16, it.next().?, 10);
            p[idx][1] = try std.fmt.parseInt(u16, it.next().?, 10);
            p[idx][2] = try std.fmt.parseInt(u16, it.next().?, 10);
        }

        if (p[0][2] > p[1][2]) {
            const tmp = p[0];
            p[0] = p[1];
            p[1] = tmp;
        }

        try bricks.append(try Brick.init(alloc, p));
    }

    return bricks;
}

const print = std.debug.print;

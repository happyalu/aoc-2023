const std = @import("std");

//const data = @embedFile("data/day17.txt");
const data = @embedFile("data/day17.example.txt");
//const data = @embedFile("data/day17.example2.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const w = std.mem.indexOf(u8, data, "\n").?;
    const h = @divExact(data.len, w + 1);

    var visited = std.AutoHashMap(Point, usize).init(alloc);
    var part1 = try solve(alloc, &visited, w, h, 1, 3);
    visited.clearRetainingCapacity();
    var part2 = try solve(alloc, &visited, w, h, 4, 10);

    print("day17 part1: {}\n", .{part1});
    print("day17 part2: {}\n", .{part2});
    print("day17 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn solve(alloc: std.mem.Allocator, visited: *std.AutoHashMap(Point, usize), w: usize, h: usize, min_straight: usize, max_straight: usize) !usize {
    var q = std.PriorityQueue(PointCost, void, PointCost.lessThan).init(alloc, {});
    defer q.deinit();

    // bfs
    try q.add(.{ .point = .{ .x = 0, .y = 0, .dir = .none, .straight = 0 }, .cost = 0 });
    while (q.removeOrNull()) |ps| {
        var p = ps.point;
        if (p.x == w - 1 and p.y == h - 1) {
            if (p.straight >= min_straight) return ps.cost;
        }

        var res = try visited.getOrPut(p);
        if (res.found_existing) {
            if (res.value_ptr.* <= ps.cost)
                continue;
        }

        res.value_ptr.* = ps.cost;

        // add adjacent nodes.
        for ([_]Dir{ .up, .down, .left, .right }) |d| {
            if (p.dir != Dir.none) {
                // path should have min_straight
                if (p.straight < min_straight and p.dir != d) continue;

                // but not above max_straight
                if (p.straight == max_straight and p.dir == d) continue;

                // Don't allow reversal of previous path
                if (p.dir == Dir.right and d == Dir.left) continue;
                if (p.dir == Dir.left and d == Dir.right) continue;
                if (p.dir == Dir.up and d == Dir.down) continue;
                if (p.dir == Dir.down and d == Dir.up) continue;
            }

            var straight = if (p.dir == d or p.dir == Dir.none) p.straight + 1 else 1;

            switch (d) {
                .up => if (p.y != 0) {
                    try q.add(.{
                        .point = .{
                            .x = p.x,
                            .y = p.y - 1,
                            .dir = d,
                            .straight = straight,
                        },
                        .cost = ps.cost + data[(p.y - 1) * (w + 1) + p.x] - '0',
                    });
                },
                .down => if (p.y != h - 1) {
                    try q.add(.{
                        .point = .{
                            .x = p.x,
                            .y = p.y + 1,
                            .dir = d,
                            .straight = straight,
                        },
                        .cost = ps.cost + data[(p.y + 1) * (w + 1) + p.x] - '0',
                    });
                },
                .left => if (p.x != 0) {
                    try q.add(.{
                        .point = .{
                            .x = p.x - 1,
                            .y = p.y,
                            .dir = d,
                            .straight = straight,
                        },
                        .cost = ps.cost + data[p.y * (w + 1) + p.x - 1] - '0',
                    });
                },
                .right => if (p.x != w - 1) {
                    try q.add(.{
                        .point = .{
                            .x = p.x + 1,
                            .y = p.y,
                            .dir = d,
                            .straight = straight,
                        },
                        .cost = ps.cost + data[p.y * (w + 1) + p.x + 1] - '0',
                    });
                },
                else => unreachable,
            }
        }
    }

    unreachable;
}

const Point = struct {
    x: usize,
    y: usize,
    dir: Dir,
    straight: usize,
};

const PointCost = struct {
    point: Point,
    cost: usize,
    fn lessThan(_: void, a: PointCost, b: PointCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

const Dir = enum { none, left, right, up, down };

const print = std.debug.print;

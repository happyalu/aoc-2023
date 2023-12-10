const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

//const data = @embedFile("data/day10.example1.txt");
//const data = @embedFile("data/day10.example2.txt");
//const data = @embedFile("data/day10.example3.txt");
//const data = @embedFile("data/day10.example4.txt");
const data = @embedFile("data/day10.example5.txt");
//const data = @embedFile("data/day10.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var iter = std.mem.tokenize(u8, data, "\n");
    var n = iter.peek().?.len;

    var nodes = try std.ArrayList(Node).initCapacity(alloc, n * n);
    defer nodes.deinit();
    nodes.appendNTimesAssumeCapacity(.{}, n * n);

    var start_node: *Node = undefined;

    {
        var i: usize = 0;
        while (iter.next()) |line| : (i += 1) {
            const y: usize = i;
            for (line, 0..) |c, x| {
                var cur_node = &nodes.items[y * n + x];
                var north_node = if (y == 0) null else &nodes.items[(y - 1) * n + x];
                var south_node = if (y == n - 1) null else &nodes.items[(y + 1) * n + x];
                var west_node = if (x == 0) null else &nodes.items[y * n + (x - 1)];
                var east_node = if (x == n - 1) null else &nodes.items[y * n + (x + 1)];

                switch (c) {
                    '|' => {
                        cur_node.north = north_node;
                        cur_node.south = south_node;
                    },
                    '-' => {
                        cur_node.west = west_node;
                        cur_node.east = east_node;
                    },
                    'L' => {
                        cur_node.north = north_node;
                        cur_node.east = east_node;
                    },
                    'J' => {
                        cur_node.north = north_node;
                        cur_node.west = west_node;
                    },
                    '7' => {
                        cur_node.west = west_node;
                        cur_node.south = south_node;
                    },
                    'F' => {
                        cur_node.south = south_node;
                        cur_node.east = east_node;
                    },
                    '.' => {},
                    'S' => {
                        //print("start at {d}, {d} for i={d}, n={d}\n", .{ x, y, i, n });
                        start_node = cur_node;
                        cur_node.north = north_node;
                        cur_node.east = east_node;
                        cur_node.south = south_node;
                        cur_node.west = west_node;
                    },
                    else => unreachable,
                }
            }
        }
    }

    // correct connections of start node
    if (start_node.north != null and start_node.north.?.south == null) start_node.north = null;
    if (start_node.south != null and start_node.south.?.north == null) start_node.south = null;
    if (start_node.east != null and start_node.east.?.west == null) start_node.east = null;
    if (start_node.west != null and start_node.west.?.east == null) start_node.west = null;

    start_node.dfs(0);
    var max_dist: usize = 0;

    for ([_]?*Node{ start_node.north, start_node.east, start_node.south, start_node.west }) |x| {
        if (x != null) {
            max_dist = @max(max_dist, x.?.distance orelse 0);
        }
    }

    const part1 = (1 + max_dist) / 2;

    var part2: usize = 0;

    // horizontal ray tracing to count for | L and J connections.
    for (0..n) |y| {
        var cross_count: usize = 0;
        for (0..n) |x| {
            const idx = n * y + x;
            var cn = nodes.items[idx];
            if (cn.visited) {
                if ((cn.north != null and cn.south != null) or
                    (cn.north != null and cn.east != null) or
                    (cn.west != null and cn.north != null))
                {
                    cross_count += 1;
                }
            } else {
                part2 += (cross_count % 2);
            }
        }
    }

    print("part1: {}\n", .{part1});
    print("part2: {}\n", .{part2});
    print("day10 main() total time: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Node = struct {
    north: ?*Node = null,
    south: ?*Node = null,
    west: ?*Node = null,
    east: ?*Node = null,
    distance: ?usize = null,
    visited: bool = false,

    fn dfs(self: *Node, dist: usize) void {
        if (self.visited) return;

        if (self.distance == null) {
            self.distance = dist;
        } else {
            self.distance = @min(self.distance.?, dist);
        }

        self.visited = true;

        if (self.north != null) self.north.?.dfs(self.distance.? + 1);
        if (self.east != null) self.east.?.dfs(self.distance.? + 1);
        if (self.south != null) self.south.?.dfs(self.distance.? + 1);
        if (self.west != null) self.west.?.dfs(self.distance.? + 1);
    }
};

// Useful stdlib functions
const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

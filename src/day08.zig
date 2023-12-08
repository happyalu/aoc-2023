const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
//const data = @embedFile("data/day08.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var lines = tokenizeAny(u8, data, "\n");
    var turn = TurnIterator.init(lines.next().?);

    var nodes = std.StringHashMap(*Node).init(alloc);
    var part2_start_nodes = std.ArrayList(*Node).init(alloc);

    // read the nodes
    while (lines.next()) |line| {
        var from = line[0..3];
        var left = line[7..10];
        var right = line[12..15];

        //print("{s} {s} {s}\n", .{ from, left, right });

        var f = try getOrCreateNode(alloc, &nodes, from);
        var l = try getOrCreateNode(alloc, &nodes, left);
        var r = try getOrCreateNode(alloc, &nodes, right);

        f.left = l;
        f.right = r;

        if (from[2] == 'A') {
            try part2_start_nodes.append(f);
        }

        //print("built node {s}\n", .{f.label});
    }

    // part 1
    var start_node = nodes.get("AAA") orelse unreachable;
    var part1 = getTurnsToFinal(start_node, &turn, Part.one);

    std.debug.print("part1={}, time={}\n", .{ part1, std.fmt.fmtDuration(timer.read()) });

    timer.reset();

    var next_nodes = part2_start_nodes;
    var loop_lengths = std.ArrayList(usize).init(alloc);

    for (next_nodes.items) |n| {
        try loop_lengths.append(getTurnsToFinal(n, &turn, Part.two));
    }

    var part2: usize = 1;
    for (loop_lengths.items) |x| {
        part2 = lcm(part2, x);
    }

    std.debug.print("part2={}, time={}\n", .{ part2, std.fmt.fmtDuration(timer.read()) });
}

const Part = enum { one, two };

const Node = struct {
    label: []const u8,
    left: *Node,
    right: *Node,

    fn init(alloc: std.mem.Allocator, label: []const u8) !*Node {
        var n = try alloc.create(Node);
        n.label = label;
        return n;
    }
};

const TurnIterator = struct {
    buf: []const u8,
    next_idx: usize = 0,
    count: usize = 0,

    fn init(str: []const u8) TurnIterator {
        return TurnIterator{
            .buf = str,
        };
    }

    fn next(self: *TurnIterator) ?u8 {
        if (self.next_idx >= self.buf.len) {
            self.next_idx = 0;
        }

        self.count += 1;
        var out = self.buf[self.next_idx];
        self.next_idx += 1;
        return out;
    }

    fn reset(self: *TurnIterator) void {
        self.next_idx = 0;
        self.count = 0;
    }
};

fn getOrCreateNode(alloc: std.mem.Allocator, nodes: *std.StringHashMap(*Node), label: []const u8) !*Node {
    var x = try nodes.getOrPut(label);
    if (!x.found_existing) {
        x.value_ptr.* = try Node.init(alloc, label);
    }
    return x.value_ptr.*;
}

fn getTurnsToFinal(start_node: *Node, turn: *TurnIterator, part: Part) usize {
    var next_node = start_node;

    turn.reset();

    while (turn.next()) |t| {
        next_node = switch (t) {
            'L' => next_node.left,
            'R' => next_node.right,
            else => unreachable,
        };
        switch (part) {
            Part.one => if (std.mem.eql(u8, next_node.label, "ZZZ")) return turn.count,
            Part.two => if (next_node.label[2] == 'Z') return turn.count,
        }
    }

    unreachable;
}

fn lcm(a: usize, b: usize) usize {
    var gcd = a;
    var tmp = b;

    while (tmp != 0) {
        var x = gcd;
        gcd = tmp;
        tmp = x % tmp;
    }

    return a * b / gcd;
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

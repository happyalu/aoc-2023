const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day25.txt");
//const data = @embedFile("data/day25.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var g = try Graph.init(alloc);

    var iter = std.mem.tokenizeScalar(u8, data, '\n');

    while (iter.next()) |line| {
        var iter2 = std.mem.tokenizeAny(u8, line, ": ");
        const from = iter2.next().?;
        while (iter2.next()) |to| {
            try g.addEdge(from, to);
        }
    }

    //g.display();

    var rand = std.rand.DefaultPrng.init(25);

    const need_cuts = 3;
    const part1 = try g.min_cut(rand.random(), need_cuts);

    print("day25 part1: {}\n", .{part1});
    print("day25 all main: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Edge = struct {
    a: usize,
    b: usize,
};

const Graph = struct {
    alloc: std.mem.Allocator,
    symbols: std.AutoHashMap(usize, []const u8),
    nodes: std.StringArrayHashMap(usize),
    edges: std.ArrayList(Edge),
    node_group: std.AutoArrayHashMap(usize, usize),

    fn init(alloc: std.mem.Allocator) !Graph {
        return .{
            .alloc = alloc,
            .nodes = std.StringArrayHashMap(usize).init(alloc),
            .edges = std.ArrayList(Edge).init(alloc),
            .symbols = std.AutoHashMap(usize, []const u8).init(alloc),
            .node_group = std.AutoArrayHashMap(usize, usize).init(alloc),
        };
    }

    fn getOrAddNode(self: *Graph, name: []const u8) !usize {
        const node_count = self.nodes.count();
        const res = try self.nodes.getOrPut(name);
        if (!res.found_existing) {
            res.value_ptr.* = node_count;
            try self.symbols.put(node_count, name);
            try self.node_group.put(node_count, node_count);
        }
        return res.value_ptr.*;
    }

    fn addEdge(self: *Graph, from: []const u8, to: []const u8) !void {
        const f = try self.getOrAddNode(from);
        const t = try self.getOrAddNode(to);

        try self.edges.append(.{ .a = @min(f, t), .b = @max(f, t) });
    }

    fn clone(self: Graph) !Graph {
        return .{
            .alloc = self.alloc,
            .nodes = try self.nodes.clone(),
            .symbols = try self.symbols.clone(),
            .edges = try self.edges.clone(),
            .node_group = try self.node_group.clone(),
        };
    }

    fn display(self: Graph) void {
        for (self.edges.items) |e| {
            print("{s} => {s}\n", .{ self.symbols.get(e.from).?, self.symbols.get(e.to).? });
        }
    }

    fn min_cut(oldself: *Graph, rand: std.rand.Random, need_cuts: usize) !usize {
        var cuts: usize = 0;
        var self = try oldself.clone();
        while (cuts != need_cuts) {
            for (self.nodes.values()) |v| {
                try self.node_group.put(v, v);
            }
            var node_count = self.nodes.count();
            while (node_count > 2) {
                const idx = rand.intRangeLessThan(usize, 0, self.edges.items.len);

                const merge = self.edges.items[idx];
                const nga = self.node_group.get(merge.a).?;
                const ngb = self.node_group.get(merge.b).?;

                if (nga == ngb) continue;

                //print("merging node {} into {}\n", .{ merge.a, merge.b });
                node_count -= 1;

                try self.node_group.put(ngb, nga);

                for (self.node_group.keys()) |k| {
                    if (self.node_group.get(k).? == nga) {
                        try self.node_group.put(k, ngb);
                    }
                }

                //for (self.node_group.keys()) |k| {
                //                    print("ng {} => {}\n", .{ k, self.node_group.get(k).? });
                //                }
            }

            //for (self.node_group.keys()) |k| {
            //print("ng {} => {}\n", .{ k, self.node_group.get(k).? });
            //}

            cuts = 0;
            for (self.edges.items) |e| {
                const nga = self.node_group.get(e.a).?;
                const ngb = self.node_group.get(e.b).?;

                if (nga != ngb) cuts += 1;
            }

            //print("{any} {any}\n", .{ node_count, cuts });
        }

        var c = std.AutoArrayHashMap(usize, usize).init(oldself.alloc);
        defer c.deinit();

        for (self.node_group.values()) |v| {
            const res = try c.getOrPut(v);
            if (!res.found_existing) {
                res.value_ptr.* = 1;
            } else res.value_ptr.* += 1;
        }

        var out: usize = 1;
        for (c.values()) |v|
            out *= v;

        return out;
    }
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

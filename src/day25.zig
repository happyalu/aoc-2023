const std = @import("std");

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

    fn init(alloc: std.mem.Allocator) !Graph {
        return .{
            .alloc = alloc,
            .nodes = std.StringArrayHashMap(usize).init(alloc),
            .edges = std.ArrayList(Edge).init(alloc),
            .symbols = std.AutoHashMap(usize, []const u8).init(alloc),
        };
    }

    fn getOrAddNode(self: *Graph, name: []const u8) !usize {
        const node_count = self.nodes.count();
        const res = try self.nodes.getOrPut(name);
        if (!res.found_existing) {
            res.value_ptr.* = node_count;
            try self.symbols.put(node_count, name);
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
        };
    }

    fn display(self: Graph) void {
        for (self.edges.items) |e| {
            print("{s} => {s}\n", .{ self.symbols.get(e.from).?, self.symbols.get(e.to).? });
        }
    }

    fn min_cut(oldself: Graph, rand: std.rand.Random, need_cuts: usize) !usize {
        var cuts: usize = 0;
        var self = try oldself.clone();
        var subsets = try std.ArrayList(Subset).initCapacity(oldself.alloc, self.nodes.count());

        while (cuts != need_cuts) {
            subsets.clearRetainingCapacity();
            subsets.expandToCapacity();

            for (subsets.items, 0..) |*s, idx| {
                s.parent = idx;
                s.rank = 0;
            }

            var node_count = self.nodes.count();
            while (node_count > 2) {
                const idx = rand.intRangeLessThan(usize, 0, self.edges.items.len);
                const merge = self.edges.items[idx];

                const subset1 = subsetFind(subsets.items, merge.a);
                const subset2 = subsetFind(subsets.items, merge.b);

                if (subset1 == subset2) continue;

                node_count -= 1;
                subsetUnion(subsets.items, subset1, subset2);
            }

            cuts = 0;
            for (self.edges.items) |e| {
                const subset1 = subsetFind(subsets.items, e.a);
                const subset2 = subsetFind(subsets.items, e.b);

                if (subset1 != subset2) cuts += 1;
            }
        }

        var c = std.AutoArrayHashMap(usize, usize).init(oldself.alloc);
        defer c.deinit();

        for (subsets.items) |s| {
            const res = try c.getOrPut(s.parent);
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

const Subset = struct {
    parent: usize,
    rank: usize,
};

fn subsetFind(subsets: []Subset, i: usize) usize {
    if (subsets[i].parent != i) {
        subsets[i].parent = subsetFind(subsets, subsets[i].parent);
    }

    return subsets[i].parent;
}

fn subsetUnion(subsets: []Subset, x: usize, y: usize) void {
    const xroot = subsetFind(subsets, x);
    const yroot = subsetFind(subsets, y);

    if (subsets[xroot].rank < subsets[yroot].rank) {
        subsets[xroot].parent = yroot;
    } else if (subsets[xroot].rank > subsets[yroot].rank) {
        subsets[yroot].parent = xroot;
    } else {
        subsets[yroot].parent = xroot;
        subsets[xroot].rank += 1;
    }
}

const print = std.debug.print;

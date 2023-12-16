const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day16.txt");
//const data = @embedFile("data/day16.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var grid = struct {
        const Self = @This();
        w: usize = std.mem.indexOf(u8, data, "\n").?,

        fn at(self: Self, x: usize, y: usize) u8 {
            return data[y * (self.w + 1) + x];
        }
    }{};

    //print("w: {}\n", .{grid.w});

    var energized = std.AutoHashMap(usize, void).init(alloc);
    var visited = std.AutoHashMap(Ray, void).init(alloc);

    var rays = std.ArrayList(Ray).init(alloc);
    try rays.append(.{});

    while (rays.popOrNull()) |item| {
        var r = item;
        while (true) {
            //print("{any}\n", .{r});
            var res = try visited.getOrPut(r);
            if (res.found_existing) break;
            res.value_ptr.* = {};
            try energized.put(r.y * grid.w + r.x, {});
            const cell = grid.at(r.x, r.y);
            switch (cell) {
                '.' => {
                    r = r.move(r.dir, grid.w) orelse break;
                },
                '\\' => {
                    switch (r.dir) {
                        Dir.Up => r = r.move(Dir.Left, grid.w) orelse break,
                        Dir.Down => r = r.move(Dir.Right, grid.w) orelse break,
                        Dir.Left => r = r.move(Dir.Up, grid.w) orelse break,
                        Dir.Right => r = r.move(Dir.Down, grid.w) orelse break,
                    }
                },
                '/' => {
                    switch (r.dir) {
                        Dir.Up => r = r.move(Dir.Right, grid.w) orelse break,
                        Dir.Down => r = r.move(Dir.Left, grid.w) orelse break,
                        Dir.Left => r = r.move(Dir.Down, grid.w) orelse break,
                        Dir.Right => r = r.move(Dir.Up, grid.w) orelse break,
                    }
                },
                '-' => {
                    switch (r.dir) {
                        Dir.Left => r = r.move(Dir.Left, grid.w) orelse break,
                        Dir.Right => r = r.move(Dir.Right, grid.w) orelse break,
                        else => {
                            try rays.append(r.move(Dir.Right, grid.w) orelse break);
                            r = r.move(Dir.Left, grid.w) orelse break;
                        },
                    }
                },
                '|' => {
                    switch (r.dir) {
                        Dir.Up => r = r.move(Dir.Up, grid.w) orelse break,
                        Dir.Down => r = r.move(Dir.Down, grid.w) orelse break,
                        else => {
                            var r2 = r.move(Dir.Up, grid.w);
                            if (r2 != null) {
                                try rays.append(r2.?);
                            }
                            r = r.move(Dir.Down, grid.w) orelse break;
                            //print("{any}\n", .{r});
                        },
                    }
                },
                else => unreachable,
            }
        }
    }

    print("day16 part1: {}\n", .{energized.count()});
    print("day16 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Ray = struct {
    x: usize = 0,
    y: usize = 0,
    dir: Dir = Dir.Right,

    fn move(self: Ray, d: Dir, w: usize) ?Ray {
        switch (d) {
            Dir.Up => {
                if (self.y == 0) return null;
                return .{ .x = self.x, .y = self.y - 1, .dir = d };
            },
            Dir.Down => {
                if (self.y == w - 1) return null;
                return .{ .x = self.x, .y = self.y + 1, .dir = d };
            },
            Dir.Left => {
                if (self.x == 0) return null;
                return .{ .x = self.x - 1, .y = self.y, .dir = d };
            },
            Dir.Right => {
                if (self.x == w - 1) return null;
                return .{ .x = self.x + 1, .y = self.y, .dir = d };
            },
        }
    }
};

const Dir = enum { Left, Right, Up, Down };

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

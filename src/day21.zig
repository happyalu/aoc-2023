const std = @import("std");

const data_actual = Data.init(@embedFile("data/day21.txt"));
const data_example = Data.init(@embedFile("data/day21.example.txt"));

const Part = enum { one, two };

const Move = struct { idx: usize, off: FieldOffset };

const Fields = std.AutoArrayHashMap(FieldOffset, void);

const FieldOffset = @Vector(2, isize);

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var moves = std.AutoHashMap(usize, [4]?Move).init(alloc);
    defer moves.deinit();

    const part1 = try solve(alloc, data_actual, 64, Part.one, &moves);

    // part2:
    // 26501365 = 202300 * 131 + 65 for grid of square 131
    assert(data_actual.w == 131);
    assert(@divExact(data_actual.data.len, data_actual.w) == 132);
    // f(n) f(n+2W), f(n+3W) is quadratic (found this hint somewhere).
    const f0 = try solve(alloc, data_actual, 65, Part.two, &moves);
    const f1 = try solve(alloc, data_actual, 65 + 131, Part.two, &moves);
    const f2 = try solve(alloc, data_actual, 65 + 131 * 2, Part.two, &moves);

    const b0 = f0;
    const b1 = f1 - f0;
    const b2 = f2 - f1;
    const n: usize = 202300;
    const part2 = b0 + b1 * n + (n * (n - 1) / 2) * (b2 - b1);

    print("day21 part1: {}\n", .{part1});
    print("day21 part2: {}\n", .{part2});
    print("day21 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn solve(alloc: std.mem.Allocator, data: Data, steps: usize, part: Part, moves: *std.AutoHashMap(usize, [4]?Move)) !usize {
    var cur_places = std.AutoArrayHashMap(usize, Fields).init(alloc);
    var next_places = std.AutoArrayHashMap(usize, Fields).init(alloc);

    for (0..data.data.len) |i| {
        try cur_places.put(i, Fields.init(alloc));
        try next_places.put(i, Fields.init(alloc));
    }

    defer cur_places.deinit();
    defer next_places.deinit();

    var start = Fields.init(alloc);
    try start.put(.{ 0, 0 }, {});
    try cur_places.put(std.mem.indexOfScalar(u8, data.data, 'S').?, start);

    for (0..steps) |_| {
        for (next_places.keys()) |k| {
            next_places.getPtr(k).?.clearRetainingCapacity();
        }

        for (cur_places.keys()) |key| {
            if (cur_places.get(key).?.count() == 0) continue;
            const res = try moves.getOrPut(key);
            if (!res.found_existing) {
                const m = data.move(key, part);
                res.value_ptr.* = m;
            }

            const mlist = res.value_ptr.*;

            for (mlist) |m| {
                if (m == null) continue;

                const n = m.?.idx;
                //print("{}\n", .{n});
                const res2 = next_places.getPtr(n).?;
                for (cur_places.get(key).?.keys()) |cur_item| {
                    //print("{any}\n", .{cur_item});
                    try res2.put(m.?.off + cur_item, {});
                }
            }
        }

        const tmp = cur_places;
        cur_places = next_places;
        next_places = tmp;
    }

    var ans: usize = 0;

    for (cur_places.keys()) |k| {
        ans += cur_places.get(k).?.keys().len;
    }

    return ans;
}

const Data = struct {
    data: []const u8,
    w: usize,

    fn init(d: []const u8) Data {
        const w = std.mem.indexOfScalar(u8, d, '\n').?;
        return .{ .data = d, .w = w };
    }

    fn trymove(self: Data, m: Move) ?Move {
        return if (self.data[m.idx] != '#') m else null;
    }

    fn move(self: Data, k: usize, part: Part) [4]?Move {
        var out: [4]?Move = [_]?Move{null} ** 4;

        switch (part) {
            .one => {
                // west?
                if ((k) % (self.w + 1) > 0 and self.data[k - 1] != '#') {
                    out[0] = self.trymove(.{ .idx = k - 1, .off = .{ 0, 0 } });
                }

                // east?
                if ((k + 1) % (self.w + 1) < self.w and self.data[k + 1] != '#') {
                    out[1] = self.trymove(.{ .idx = k + 1, .off = .{ 0, 0 } });
                }

                // north?
                if (k > (self.w + 1) and self.data[k - (self.w + 1)] != '#') {
                    out[2] = self.trymove(.{ .idx = k - (self.w + 1), .off = .{ 0, 0 } });
                }

                // south?
                if ((k + (self.w + 1)) < self.data.len and self.data[k + (self.w + 1)] != '#') {
                    out[3] = self.trymove(.{ .idx = k + (self.w + 1), .off = .{ 0, 0 } });
                }
            },
            .two => {
                //west
                if (k % (self.w + 1) == 0) {
                    out[0] = self.trymove(.{ .idx = k + self.w - 1, .off = .{ -1, 0 } });
                } else {
                    out[0] = self.trymove(.{ .idx = k - 1, .off = .{ 0, 0 } });
                }

                //east
                if ((k + 1) % (self.w + 1) == self.w) {
                    out[1] = self.trymove(.{ .idx = k + 1 - self.w, .off = .{ 1, 0 } });
                } else {
                    out[1] = self.trymove(.{ .idx = k + 1, .off = .{ 0, 0 } });
                }

                //north
                if (k < self.w) {
                    out[2] = self.trymove(.{ .idx = self.data.len - (self.w + 1) + k, .off = .{ 0, -1 } });
                } else {
                    out[2] = self.trymove(.{ .idx = k - (self.w + 1), .off = .{ 0, 0 } });
                }

                //south
                if (k + self.w + 1 >= self.data.len) {
                    out[3] = self.trymove(.{ .idx = (k + self.w + 1) % self.data.len, .off = .{ 0, 1 } });
                } else {
                    out[3] = self.trymove(.{ .idx = k + (self.w + 1), .off = .{ 0, 0 } });
                }
            },
        }

        return out;
    }
};

const print = std.debug.print;
const assert = std.debug.assert;

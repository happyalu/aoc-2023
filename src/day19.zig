const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");
//const data = @embedFile("data/day19.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var wf = std.StringHashMap(*Workflow).init(alloc);
    defer wf.deinit();

    var iter = std.mem.splitScalar(u8, data, '\n');

    var part1: usize = 0;

    while (iter.next()) |line| {
        if (line.len == 0) break;
        var idx = std.mem.indexOfScalar(u8, line, '{').?;
        var name = line[0..idx];
        //print("{s}\n", .{name});

        var w = try alloc.create(Workflow);
        w.* = .{ .name = name, .rules = undefined, .n = 0 };

        var ridx: usize = 0;
        var it = std.mem.tokenizeScalar(u8, line[idx + 1 .. line.len - 1], ',');
        while (it.next()) |r| {
            var rule = Rule{
                .passthru = undefined,
                .cat = undefined,
                .op = undefined,
                .val = undefined,
                .next = undefined,
            };
            var idxc = std.mem.indexOfScalar(u8, r, ':');

            if (idxc != null) {
                rule.passthru = false;
                rule.cat = switch (r[0]) {
                    'x' => .x,
                    'm' => .m,
                    'a' => .a,
                    's' => .s,
                    else => unreachable,
                };

                rule.op = switch (r[1]) {
                    '<' => .lt,
                    '>' => .gt,
                    else => unreachable,
                };
                rule.val = try std.fmt.parseInt(usize, r[2..idxc.?], 10);
                rule.next = r[idxc.? + 1 ..];
            } else {
                rule.passthru = true;
                rule.next = r;
            }

            w.rules[ridx] = rule;
            ridx += 1;
            //print("{s}\n", .{r});
        }

        w.n = ridx;
        try wf.put(name, w);
    }

    var in = wf.get("in") orelse unreachable;

    while (iter.next()) |line| {
        if (line.len == 0) continue;
        //print("{s}\n", .{line});
        var it = std.mem.tokenize(u8, line[1 .. line.len - 1], ",");
        var p: Part = undefined;
        while (it.next()) |item| {
            //print("{s}\n", .{item});
            var val = try std.fmt.parseInt(usize, item[2..], 10);
            switch (item[0]) {
                'x' => p.x = val,
                'm' => p.m = val,
                'a' => p.a = val,
                's' => p.s = val,
                else => unreachable,
            }
        }
        //print("{}\n", .{p});
        var w = in;
        while (true) {
            var res = w.apply(p);
            if (res[0] == 'R') break;
            if (res[0] == 'A') {
                part1 += p.rating();
                break;
            }
            w = wf.get(res) orelse unreachable;
        }
    }

    print("day 19 part1: {}\n", .{part1});

    var part2: usize = 0;

    var rangelist = std.ArrayList(PartRange).init(alloc);

    try rangelist.append(.{
        .start_wf = "in",
        .start = .{ .x = 1, .m = 1, .a = 1, .s = 1 },
        .end = .{ .x = 4000, .m = 4000, .a = 4000, .s = 4000 },
    });

    while (rangelist.popOrNull()) |range| {
        if (range.start_wf[0] == 'R') continue;
        if (range.start_wf[0] == 'A') {
            //print("{}\n", .{range});
            //print("{}\n", .{range.count()});
            part2 += range.count();
            continue;
        }

        var w = wf.get(range.start_wf).?;
        try w.applyRange(range, &rangelist);
    }

    print("day 19 part2: {}\n", .{part2});
    print("day 19 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const PartRange = struct {
    start_wf: []const u8,
    start: Part,
    end: Part,

    fn count(self: PartRange) usize {
        if (self.end.x < self.start.x) return 0;
        if (self.end.m < self.start.m) return 0;
        if (self.end.a < self.start.a) return 0;
        if (self.end.s < self.start.s) return 0;

        var out = self.end.x - self.start.x + 1;
        out *= self.end.m - self.start.m + 1;
        out *= self.end.a - self.start.a + 1;
        out *= self.end.s - self.start.s + 1;

        return out;
    }
};

const Workflow = struct {
    name: []const u8,
    rules: [10]Rule,
    n: usize,

    fn apply(self: Workflow, part: Part) []const u8 {
        //print("applying {s}\n", .{self.name});
        for (0..self.n) |i| {
            var w = self.rules[i].apply(part);
            if (w != null) return w.?;
        }

        unreachable;
    }

    fn applyRange(self: Workflow, rng: PartRange, rangelist: *std.ArrayList(PartRange)) !void {
        var range = rng;

        for (0..self.n) |i| {
            var r = self.rules[i];

            if (r.passthru) {
                try rangelist.append(.{
                    .start_wf = r.next,
                    .start = range.start,
                    .end = range.end,
                });
            }

            var newrange = range;
            var newrange2 = range;
            var val1: usize = undefined;
            var val2: usize = undefined;

            var mod1: *Part = undefined;
            var mod2: *Part = undefined;
            switch (r.op) {
                .lt => {
                    mod1 = &newrange.end;
                    mod2 = &newrange2.start;
                    val1 = if (r.val > 0) r.val - 1 else 0;
                    val2 = r.val;
                },
                .gt => {
                    mod1 = &newrange.start;
                    mod2 = &newrange2.end;
                    val1 = r.val + 1;
                    val2 = r.val;
                },
            }

            switch (r.cat) {
                .x => {
                    mod1.x = val1;
                    mod2.x = val2;
                },
                .m => {
                    mod1.m = val1;
                    mod2.m = val2;
                },
                .a => {
                    mod1.a = val1;
                    mod2.a = val2;
                },
                .s => {
                    mod1.s = val1;
                    mod2.s = val2;
                },
            }

            newrange.start_wf = r.next;

            //print("rule: {s} {s} {}\npart1={}\npart2={}\n\n", .{ @tagName(r.cat), @tagName(r.op), r.val, newrange, newrange2 });

            if (newrange.count() > 0)
                try rangelist.append(newrange);

            range = newrange2;
        }
    }
};

const Rule = struct {
    passthru: bool,
    cat: Category,
    op: Op,
    val: usize,
    next: []const u8,

    fn apply(self: Rule, part: Part) ?[]const u8 {
        //print("applying rule {s} {s} {}\n", .{ @tagName(self.cat), @tagName(self.op), self.val });
        if (self.passthru) {
            return self.next;
        }

        var val = switch (self.cat) {
            .x => part.x,
            .m => part.m,
            .a => part.a,
            .s => part.s,
        };

        switch (self.op) {
            .lt => if (val < self.val) return self.next,
            .gt => if (val > self.val) return self.next,
        }

        return null;
    }
};

const Category = enum { x, m, a, s };
const Op = enum { lt, gt };

const Part = struct {
    x: usize,
    m: usize,
    a: usize,
    s: usize,

    fn rating(self: Part) usize {
        return self.x + self.m + self.a + self.s;
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

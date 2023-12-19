const std = @import("std");

//const data = @embedFile("data/day19.txt");
const data = @embedFile("data/day19.example.txt");

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

        var w = try alloc.create(Workflow);
        w.* = .{ .name = name, .rules = undefined, .n = 0 };

        var ridx: usize = 0;
        var it = std.mem.tokenizeScalar(u8, line[idx + 1 .. line.len - 1], ',');
        while (it.next()) |r| {
            var rule: Rule = undefined;
            var idxc = std.mem.indexOfScalar(u8, r, ':');

            if (idxc != null) {
                rule.passthru = false;
                rule.cat = r[0];

                rule.op = r[1];
                rule.val = try std.fmt.parseInt(usize, r[2..idxc.?], 10);
                rule.next = r[idxc.? + 1 ..];
            } else {
                rule.passthru = true;
                rule.next = r;
            }

            w.rules[ridx] = rule;
            ridx += 1;
        }

        w.n = ridx;
        try wf.put(name, w);
    }

    var in = wf.get("in") orelse unreachable;

    while (iter.next()) |line| {
        if (line.len == 0) continue;
        var it = std.mem.tokenize(u8, line[1 .. line.len - 1], ",");
        var p = Part{ 0, 0, 0, 0 };
        while (it.next()) |item| {
            var idx = std.mem.indexOfScalar(u8, "xmas", item[0]).?;
            var val = try std.fmt.parseInt(usize, item[2..], 10);
            p[idx] = val;
        }
        var w = in;
        while (true) {
            var res = w.apply(p);
            if (res[0] == 'R') break;
            if (res[0] == 'A') {
                part1 += rating(p);
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
        .start = .{ 1, 1, 1, 1 },
        .end = .{ 4000, 4000, 4000, 4000 },
    });

    while (rangelist.popOrNull()) |range| {
        if (range.start_wf[0] == 'R') continue;
        if (range.start_wf[0] == 'A') {
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
        var es = self.end < self.start;
        if (@reduce(.Or, es)) return 0;

        var diff = self.end - self.start;
        diff += Part{ 1, 1, 1, 1 };

        return @reduce(.Mul, diff);
    }
};

const Workflow = struct {
    name: []const u8,
    rules: [10]Rule,
    n: usize,

    fn apply(self: Workflow, part: Part) []const u8 {
        for (0..self.n) |i| {
            var w = self.rules[i].apply(part);
            if (w != null) return w.?;
        }

        unreachable;
    }

    fn applyRange(self: Workflow, range: PartRange, rangelist: *std.ArrayList(PartRange)) !void {
        var rng = range;
        for (0..self.n) |i| {
            var r = self.rules[i];

            var splits = r.splitRange(rng);
            if (splits[0] != null) {
                try rangelist.append(splits[0].?);
            }

            if (splits[1] != null) {
                rng = splits[1].?;
            }
        }
    }
};

const Rule = struct {
    passthru: bool,
    cat: u8,
    op: u8,
    val: usize,
    next: []const u8,

    fn apply(self: Rule, part: Part) ?[]const u8 {
        if (self.passthru) {
            return self.next;
        }

        var idx = std.mem.indexOfScalar(u8, "xmas", self.cat).?;
        var val = part[idx];

        switch (self.op) {
            '<' => if (val < self.val) return self.next,
            '>' => if (val > self.val) return self.next,
            else => unreachable,
        }

        return null;
    }

    fn splitRange(self: Rule, pr: PartRange) [2]?PartRange {
        var out1 = pr;
        var out2 = pr;

        if (self.passthru) {
            out1.start_wf = self.next;
            return .{ out1, null };
        }

        var idx = std.mem.indexOfScalar(u8, "xmas", self.cat).?;

        switch (self.op) {
            '<' => {
                out1.end[idx] = if (self.val > 0) self.val - 1 else 0;
                out2.start[idx] = self.val;
            },
            '>' => {
                out1.start[idx] = self.val + 1;
                out2.end[idx] = self.val;
            },
            else => unreachable,
        }

        out1.start_wf = self.next;

        return .{ out1, out2 };
    }
};

const Part = @Vector(4, usize);

fn rating(p: Part) usize {
    return @reduce(.Add, p);
}

const print = std.debug.print;

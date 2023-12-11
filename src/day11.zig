const std = @import("std");

const data = @embedFile("data/day11.example1.txt");
//const data = @embedFile("data/day11.txt");

const part1_expand = 2;
const part2_expand = 1000000;

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var iter = std.mem.tokenize(u8, data, "\n");
    var n = iter.peek().?.len;

    var column_spacer_part1 = try std.ArrayList(usize).initCapacity(alloc, n);
    for (0..n) |_| {
        column_spacer_part1.appendAssumeCapacity(part1_expand - 1);
    }

    var column_spacer_part2 = try std.ArrayList(usize).initCapacity(alloc, n);
    for (0..n) |_| {
        column_spacer_part2.appendAssumeCapacity(part2_expand - 1);
    }

    var galaxies = std.ArrayList(Galaxy).init(alloc);

    var x: usize = 0;
    var y: usize = 0;
    var y_part1: usize = 0;
    var y_part2: usize = 0;
    while (iter.next()) |line| : ({
        y += 1;
        y_part1 += 1;
        y_part2 += 1;
    }) {
        x = 0;
        if (line.len == 0) continue;

        if (std.mem.allEqual(u8, line, '.')) {
            // extra y offset to expand space
            y_part1 += part1_expand - 1;
            y_part2 += part2_expand - 1;
            continue;
        }

        while (x < n) {
            var idx = std.mem.indexOf(u8, line[x..], "#") orelse break;
            var g = Galaxy{
                .x = x + idx,
                .x_part1 = x + idx,
                .x_part2 = x + idx,
                .y = y,
                .y_part1 = y_part1,
                .y_part2 = y_part2,
            };
            try galaxies.append(g);
            column_spacer_part1.items[g.x] = 0;
            column_spacer_part2.items[g.x] = 0;
            x += idx + 1;
        }
    }

    for (1..n) |i| {
        column_spacer_part1.items[i] += column_spacer_part1.items[i - 1];
        column_spacer_part2.items[i] += column_spacer_part2.items[i - 1];
    }

    for (galaxies.items) |*g| {
        g.x_part1 += column_spacer_part1.items[g.x_part1];
        g.x_part2 += column_spacer_part2.items[g.x_part2];
        //print("{}\n", .{g});
    }

    var part1: usize = 0;
    var part2: usize = 0;
    for (0..galaxies.items.len - 1) |i| {
        for (i + 1..galaxies.items.len) |j| {
            var g1 = galaxies.items[i];
            var g2 = galaxies.items[j];
            part1 += g1.dist_l1_part1(g2);
            part2 += g1.dist_l1_part2(g2);
        }
    }

    print("part1: {}\n", .{part1});
    print("part2: {}\n", .{part2});
    print("day11 main() time: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const Galaxy = struct {
    x: usize,
    y: usize,

    x_part1: usize,
    y_part1: usize,

    x_part2: usize,
    y_part2: usize,

    fn dist_l1_part1(self: Galaxy, other: Galaxy) usize {
        var a = if (self.x_part1 > other.x_part1) (self.x_part1 - other.x_part1) else (other.x_part1 - self.x_part1);
        var b = if (self.y_part1 > other.y_part1) (self.y_part1 - other.y_part1) else (other.y_part1 - self.y_part1);
        return a + b;
    }

    fn dist_l1_part2(self: Galaxy, other: Galaxy) usize {
        var a = if (self.x_part2 > other.x_part2) (self.x_part2 - other.x_part2) else (other.x_part2 - self.x_part2);
        var b = if (self.y_part2 > other.y_part2) (self.y_part2 - other.y_part2) else (other.y_part2 - self.y_part2);
        return a + b;
    }
};

const Part = enum { one, two };

const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

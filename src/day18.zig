const std = @import("std");

const data = @embedFile("data/day18.txt");
//const data = @embedFile("data/day18.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var corners = std.ArrayList(Node).init(alloc);

    try read_input(&corners, Part.one);
    print("day 18 part1: {}\n", .{try solve(corners)});

    try read_input(&corners, Part.two);
    print("day 18 part2: {}\n", .{try solve(corners)});

    print("day 18 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn read_input(corners: *std.ArrayList(Node), part: Part) !void {
    corners.clearRetainingCapacity();

    var prev_corner = Node{
        .x = 0,
        .y = 0,
    };
    try corners.append(prev_corner);

    var iter = std.mem.tokenize(u8, data, "\n");
    while (iter.next()) |line| {
        var part_iter = std.mem.tokenize(u8, line, " ");
        var dir_str = part_iter.next().?;
        var count_str = part_iter.next().?;
        var color = part_iter.next().?;

        var count: isize = undefined;
        var dir: u8 = undefined;

        switch (part) {
            .one => {
                count = try std.fmt.parseInt(isize, count_str, 10);
                dir = dir_str[0];
            },
            .two => {
                count = try std.fmt.parseInt(isize, color[2..7], 16);
                dir = switch (color[7]) {
                    '0' => 'R',
                    '1' => 'D',
                    '2' => 'L',
                    '3' => 'U',
                    else => unreachable,
                };
            },
        }

        var c = prev_corner;
        switch (dir) {
            'R' => c.x += count,
            'L' => c.x -= count,
            'U' => c.y -= count,
            'D' => c.y += count,
            else => unreachable,
        }

        try corners.append(c);
        prev_corner = c;
    }
}

fn solve(corners: std.ArrayList(Node)) !isize {
    var n = corners.items.len;
    var area: isize = 0;
    var perimeter: isize = 0;

    // calculate area using shoelace formula
    for (0..n) |i| {
        var p1 = corners.items[i];
        var p2 = corners.items[(i + 1) % n];
        area += (p1.y + p2.y) * (p1.x - p2.x);
        perimeter += try std.math.absInt(p1.y - p2.y) + try std.math.absInt(p1.x - p2.x);
    }

    area = @divExact(area, 2);

    // use Pick's theorem to calculate all the points
    return area + 1 + @divExact(perimeter, 2);
}

const Part = enum { one, two };

const Node = struct {
    x: isize,
    y: isize,
};

const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

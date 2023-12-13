const std = @import("std");

const data = @embedFile("data/day13.txt");
//const data = @embedFile("data/day13.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var h = std.ArrayList(usize).init(alloc);
    defer h.deinit();

    var v = std.ArrayList(usize).init(alloc);
    defer v.deinit();

    var linelist = std.ArrayList([]const u8).init(alloc);
    defer linelist.deinit();

    var iter = std.mem.tokenizeSequence(u8, data, "\n\n");

    var part1: usize = 0;
    var part2: usize = 0;

    while (iter.next()) |pattern| {
        h.clearRetainingCapacity();
        v.clearRetainingCapacity();
        linelist.clearRetainingCapacity();

        var lines = std.mem.tokenize(u8, pattern, "\n");
        var h_len = lines.peek().?.len;

        try h.appendNTimes(0, h_len);

        var v_idx: usize = 0;
        while (lines.next()) |line| : (v_idx += 1) {
            try linelist.append(line);
            try v.append(0);

            //print("{s}\n", .{line});
            for (1..h_len) |i| {
                var ref_len = @min(i, h_len - i);
                for (0..ref_len) |j| {
                    //print("{} {} {c} {c}\n", .{ i, j, line[i - j - 1], line[i + j] });
                    if (line[i - j - 1] != line[i + j]) {
                        h.items[i] += 1;
                    }
                }
            }
        }

        for (1..linelist.items.len) |i| {
            var ref_len = @min(i, linelist.items.len - i);
            for (0..ref_len) |j| {
                var a = linelist.items[i - j - 1];
                var b = linelist.items[i + j];
                for (a, b) |c1, c2| {
                    if (c1 != c2) {
                        v.items[i] += 1;
                    }
                }
            }
        }

        for (h.items[1..h.items.len], 1..) |x, idx| {
            switch (x) {
                0 => part1 += idx,
                1 => part2 += idx,
                else => continue,
            }
        }

        for (v.items[1..v.items.len], 1..) |x, idx| {
            switch (x) {
                0 => part1 += 100 * idx,
                1 => part2 += 100 * idx,
                else => continue,
            }
        }

        //print("v: {any}\n", .{v.items});
        //print("h: {any}\n", .{h.items});
    }

    print("day 13: part1 = {}\n", .{part1});
    print("day 13: part2 = {}\n", .{part2});
    print("day 13: main() total: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

const std = @import("std");

const data = @embedFile("data/day09.txt");
//const data = @embedFile("data/day09.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var nums = std.ArrayList(i32).init(alloc);
    defer nums.deinit();

    var parts = [2]isize{ 0, 0 };

    var iter = tokenizeAny(u8, data, "\n");
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try processLine(line, &nums, &parts);
    }

    std.debug.print("part1 = {}, part2 = {}, time={}\n", .{ parts[0], parts[1], std.fmt.fmtDuration(timer.read()) });
}

fn processLine(line: []const u8, nums: *std.ArrayList(i32), parts: *[2]isize) !void {
    nums.clearRetainingCapacity();
    var iter = tokenizeAny(u8, line, " ");

    while (iter.next()) |n| {
        var n_int = try parseInt(i32, n, 10);
        try nums.append(n_int);
    }

    //print("{any}\n", .{nums.items});

    var n: usize = nums.items.len;
    var part1: isize = 0;
    var part2: isize = 0;
    var sign: isize = 1;
    for (1..n) |i| {
        //  print("last: {d}\n", .{nums.items[n - i]});
        part1 += nums.items[n - i];
        part2 += nums.items[0] * sign;
        sign *= -1;
        var all_zeros = true;
        for (0..(n - i)) |j| {
            var x = nums.items[j + 1] - nums.items[j];
            if (x != 0) {
                all_zeros = false;
            }
            nums.items[j] = x;
        }
        //print("{any}\n", .{nums.items});

        if (all_zeros) break;
    }

    //print("part1: {d} part2: {}\n\n", .{ part1, part2 });

    parts[0] += part1;
    parts[1] += part2;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

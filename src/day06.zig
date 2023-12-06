const std = @import("std");

//const data = @embedFile("data/day06.example.txt");
const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var iter = tokenizeAny(u8, data, ":\n");
    _ = iter.next(); // Time:
    var iter_time = tokenizeAny(u8, iter.next().?, " ");
    _ = iter.next(); // Distance;
    var iter_dist = tokenizeAny(u8, iter.next().?, " ");

    var part1: usize = 1;
    var part2: usize = 0;

    // hold the unsplit numbers (part 2 input).
    // max usize is a 20 digit number
    var t_buf = try std.BoundedArray(u8, 21).init(0);
    var d_buf = try std.BoundedArray(u8, 21).init(0);

    // solve part1 first.
    while (true) {
        var t_str = iter_time.next() orelse break;
        var d_str = iter_dist.next() orelse unreachable;

        try t_buf.appendSlice(t_str);
        try d_buf.appendSlice(d_str);

        var t = try parseInt(u32, t_str, 10);
        var d = try parseInt(u32, d_str, 10);

        part1 *= findMatches(t, d);
    }

    // part2
    var t = try parseInt(usize, t_buf.slice(), 10);
    var d = try parseInt(usize, d_buf.slice(), 10);

    part2 += findMatches(t, d);

    std.debug.print("part1 {} part2 {}\nmain() total time {}\n", .{ part1, part2, std.fmt.fmtDuration(timer.read()) });
}

fn findMatches(t: usize, d: usize) usize {
    // the match starting point is very close to the quadratic solution of i * (t-i) > d.
    var i: usize = (t - std.math.sqrt(t * t - 4 * d)) / 2 - 1;

    // find the first match
    while (i < t) : (i += 1) {
        if (i * (t - i) > d) {
            break;
        }
    }

    // count numbers from i to (t-i)
    return (t - 2 * i + 1);
}

const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

const std = @import("std");

const data = @embedFile("data/day13.txt");
//const data = @embedFile("data/day13.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var iter = std.mem.tokenizeSequence(u8, data, "\n\n");

    var part1: usize = 0;
    var part2: usize = 0;

    while (iter.next()) |pattern| {
        if (pattern.len == 0) continue;
        var width = std.mem.indexOfScalar(u8, pattern, '\n').?;
        part1 += @reduce(.Add, process(width, pattern, 0) * usize2{ 1, 100 });
        part2 += @reduce(.Add, process(width, pattern, 1) * usize2{ 1, 100 });
    }

    print("day 13: part1 = {}\n", .{part1});
    print("day 13: part2 = {}\n", .{part2});
    print("day 13: main() total: {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn process(w: usize, pattern: []const u8, num_smudges: usize) usize2 {
    var out = usize2{ 0, 0 };

    // look for vertical mirrors
    x: for (1..w) |i| {
        var ref_len = @min(i, w - i);
        var diff: usize = 0;
        var y: usize = 0;
        while (y <= pattern.len - w) : (y += w + 1) {
            var line = pattern[y .. y + w];

            for (0..ref_len) |j| {
                //print("{} {} {c} {c}\n", .{ i, j, line[i - j - 1], line[i + j] });
                if (line[i - j - 1] != line[i + j]) {
                    diff += 1;
                    if (diff > num_smudges) {
                        continue :x;
                    }
                }
            }
        }

        if (diff == num_smudges) {
            out[0] = i;
            break;
        }
    }

    var num_lines = (pattern.len + 1) / (w + 1);
    y: for (1..num_lines) |i| {
        var diff: usize = 0;
        var ref_len = @min(i, num_lines - i);
        for (0..ref_len) |j| {
            var a_idx = (i - j - 1) * (w + 1);
            var b_idx = (i + j) * (w + 1);

            var a = pattern[a_idx .. a_idx + w];
            var b = pattern[b_idx .. b_idx + w];

            //print("{}\n{s}\n{s}\n\n", .{ i, a, b });
            for (a, b) |c1, c2| {
                if (c1 != c2) {
                    diff += 1;
                    if (diff > num_smudges) continue :y;
                }
            }
        }

        if (diff == num_smudges) {
            out[1] = i;
            break;
        }
    }

    return out;
}

const usize2 = @Vector(2, usize);

const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

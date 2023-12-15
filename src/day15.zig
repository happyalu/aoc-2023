const std = @import("std");

const data = @embedFile("data/day15.txt");
//const data = @embedFile("data/day15.example.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var iter = std.mem.tokenize(u8, data, ",\n");

    var part1: usize = 0;

    var hm: HashMap = .{
        .slots = [1]std.ArrayListUnmanaged(Lens){.{}} ** 256,
    };
    while (iter.next()) |x| {
        if (x.len == 0) continue;
        var res = hash(x);
        part1 += res;

        try hm.runStep(alloc, x);
    }

    print("day15 part1: {}\n", .{part1});
    print("day15 part2: {}\n", .{hm.power()});
    print("day15 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn hash(s: []const u8) u8 {
    var out: u16 = 0;
    for (s) |c| {
        out += c;
        out *= 17;
        out %= 256;
    }
    return @intCast(out);
}

const Lens = struct {
    label: []const u8,
    power: u8,
};

const HashMap = struct {
    slots: [256]std.ArrayListUnmanaged(Lens),

    fn runStep(self: *HashMap, alloc: std.mem.Allocator, step: []const u8) !void {
        var opIdx = std.mem.indexOfAny(u8, step, "=-") orelse unreachable;
        var label = step[0..opIdx];
        var slot = hash(label);
        var op = step[opIdx];
        switch (op) {
            '=' => {
                var p_str = step[opIdx + 1 ..];
                var p = try std.fmt.parseInt(u8, p_str, 10);
                for (self.slots[slot].items) |*l| {
                    if (std.mem.eql(u8, l.label, label)) {
                        l.power = p;
                        break;
                    }
                } else {
                    try self.slots[slot].append(alloc, .{ .label = label, .power = p });
                }
            },
            '-' => {
                var list = self.slots[slot].items;
                for (list, 0..) |l, i| {
                    if (std.mem.eql(u8, l.label, label)) {
                        _ = self.slots[slot].orderedRemove(i);
                        break;
                    }
                }
            },
            else => unreachable,
        }
    }

    fn power(self: HashMap) usize {
        var out: usize = 0;
        for (self.slots, 1..) |s, slotIdx| {
            for (s.items, 1..) |l, lensIdx| {
                out += slotIdx * lensIdx * l.power;
            }
        }
        return out;
    }
};

test "hash(HASH)" {
    try std.testing.expect(hash("HASH") == 52);
}

const print = std.debug.print;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.

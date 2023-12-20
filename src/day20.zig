const std = @import("std");

const data = @embedFile("data/day20.txt");
//const data = @embedFile("data/day20.example1.txt");
//const data = @embedFile("data/day20.example2.txt");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var modules = std.StringHashMap(*Module).init(alloc);
    defer modules.deinit();

    // first read all the module names and create nodes.
    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        const idx = std.mem.indexOfScalar(u8, line, ' ') orelse unreachable;
        const name = if (line[0] == '&' or line[0] == '%') line[1..idx] else line[0..idx];
        const typ = switch (line[0]) {
            'b' => ModuleType.broadcaster,
            '%' => ModuleType.flipflop,
            '&' => ModuleType.conjunction,
            else => unreachable,
        };

        const m = try alloc.create(Module);
        m.name = name;
        m.typ = typ;
        m.inputs = try @TypeOf(m.inputs).init(0);
        m.connections = try @TypeOf(m.connections).init(0);
        m.back_connections = try @TypeOf(m.back_connections).init(0);

        if (m.typ == .broadcaster or m.typ == .flipflop) {
            _ = try m.inputs.addOne();
        }

        try modules.put(name, m);
    }

    // now make the connections
    iter.reset();
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        const idx = std.mem.indexOfScalar(u8, line, ' ') orelse unreachable;
        const name = if (line[0] == '&' or line[0] == '%') line[1..idx] else line[0..idx];
        const m = modules.get(name) orelse unreachable;

        var conn_iter = std.mem.tokenizeAny(u8, line[idx + 4 ..], ", ");
        while (conn_iter.next()) |conn| {
            const res = try modules.getOrPut(conn);
            if (!res.found_existing) {
                const x = try alloc.create(Module);
                x.name = conn;
                x.typ = .output;
                x.inputs = try @TypeOf(x.inputs).init(1);
                x.connections = try @TypeOf(x.connections).init(0);
                x.back_connections = try @TypeOf(x.back_connections).init(0);
                res.value_ptr.* = x;
            }

            const n = res.value_ptr.*;
            if (n.typ == .conjunction) {
                const v = try n.inputs.addOne();
                v.* = .low;
            }

            try m.connections.append(.{
                .module = n,
                .inputIdx = n.inputs.len - 1,
            });

            try n.back_connections.append(m);
        }
    }

    const bc = modules.get("broadcaster") orelse unreachable;

    const rx = modules.get("rx") orelse unreachable;
    assert(rx.back_connections.len == 1);
    const conj_modules = rx.back_connections.get(0).back_connections;
    for (conj_modules.slice()) |x| {
        assert(x.typ == .conjunction);
    }

    const parts = try solve(bc, conj_modules);

    print("day20 part1: {} part2: {}\n", .{ parts[0], parts[1] });
    print("day20 all main(): {}\n", .{std.fmt.fmtDuration(timer.read())});
}

fn solve(broadcast_mod: *Module, rx_conj_modules: std.BoundedArray(*Module, 10)) ![2]usize {
    const counter = struct {
        var out = [_]usize{ 0, 0 };

        fn add(im: Impulse) void {
            out[@intFromEnum(im.pulse)] += 1;
        }

        fn value() usize {
            return out[0] * out[1];
        }
    };

    var conj_cycle = try std.BoundedArray(?usize, 64).init(rx_conj_modules.len);

    for (0..rx_conj_modules.len) |i| {
        conj_cycle.set(i, null);
    }

    var out = [2]usize{ 0, 0 };

    var q = try std.BoundedArray(Impulse, 100).init(0);
    var btn_count: usize = 1;
    btn_loop: while (true) : (btn_count += 1) {
        if (btn_count == 1001) out[0] = counter.value();
        //print("{s} to {s} at {}\n", .{ "button", broadcast_mod.name, .low });
        const button_imp = Impulse{
            .conn = .{ .module = broadcast_mod, .inputIdx = 0 },
            .pulse = .low,
        };

        counter.add(button_imp);

        try q.insert(0, button_imp);

        while (q.popOrNull()) |imp| {
            const m = imp.conn.module;
            m.inputs.set(imp.conn.inputIdx, imp.pulse);

            const output = m.output();
            if (output == null) continue;

            if (output.? == .high) {
                var all_set = true;
                for (0..conj_cycle.len) |i| {
                    if (conj_cycle.get(i) == null) {
                        if (m == rx_conj_modules.get(i)) {
                            conj_cycle.set(i, btn_count);
                        } else all_set = false;
                    }
                }

                if (all_set) break :btn_loop;
            }

            for (m.connections.slice()) |c| {
                const im = Impulse{ .conn = c, .pulse = output.? };
                counter.add(im);

                if (std.mem.eql(u8, c.module.name, "rx") and output.? == .low) {
                    out[1] = btn_count;
                    return out;
                }

                try q.insert(0, im);
            }
        }
    }

    out[0] = counter.value();
    out[1] = 1;
    for (conj_cycle.slice()) |c| {
        out[1] *= c.?;
    }

    return out;
}

const Impulse = struct {
    conn: Connection,
    pulse: Pulse,
};

const Module = struct {
    name: []const u8,
    typ: ModuleType,
    inputs: std.BoundedArray(Pulse, 10),
    connections: std.BoundedArray(Connection, 10),
    back_connections: std.BoundedArray(*Module, 10),

    ff_state: bool = false,

    fn reset(self: *Module) void {
        self.ff_state = false;
        for (self.inputs.slice()) |*s| {
            s = .low;
        }
    }

    fn output(self: *Module) ?Pulse {
        switch (self.typ) {
            .flipflop => {
                if (self.inputs.get(0) == .high) return null;

                if (!self.ff_state) {
                    self.ff_state = true;
                    return .high;
                } else {
                    self.ff_state = false;
                    return .low;
                }
            },
            .broadcaster => {
                return self.inputs.get(0);
            },
            .conjunction => {
                if (std.mem.allEqual(Pulse, self.inputs.slice(), .high)) {
                    return .low;
                }
                return .high;
            },
            .button => {},
            .output => {},
        }
        return .low;
    }
};

const ModuleType = enum { button, broadcaster, flipflop, conjunction, output };

const Connection = struct {
    module: *Module,
    inputIdx: usize,
};

const Pulse = enum { low, high };

const print = std.debug.print;
const assert = std.debug.assert;

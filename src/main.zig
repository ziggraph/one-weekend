const std = @import("std");

pub fn main() !void {
    const image_width = 256;
    const image_height = 256;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{image_height - j});

        for (0..image_width) |i| {
            const fi: f32 = @floatFromInt(i);
            const fj: f32 = @floatFromInt(j);

            const r = fi / (image_width - 1);
            const g = fj / (image_height - 1);
            const b = 0;

            const ir: i32 = @intFromFloat(255.999 * r);
            const ig: i32 = @intFromFloat(255.999 * g);
            const ib: i32 = @intFromFloat(255.999 * b);

            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }

        try bw.flush();
    }

    std.debug.print("\rDone.                 \n", .{});
}

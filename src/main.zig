const std = @import("std");
const Color = @import("vec3.zig").Color;

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

            const color = Color.init(
                fi / (image_width - 1),
                fj / (image_height - 1),
                0,
            );

            try color.write_color(stdout);
        }

        try bw.flush();
    }

    std.debug.print("\rDone.                 \n", .{});
}

const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Color = vec3.Color;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;

fn hit_sphere(center: *const Point3, radius: f32, r: *const Ray) bool {
    const oc = r.o.sub(center.*);
    const a = r.d.mag2();
    const b = 2.0 * oc.dot(r.d);
    const c = oc.mag2() - radius * radius;
    const discriminant = b * b - 4 * a * c;
    return discriminant >= 0;
}

fn ray_color(r: *const Ray) Color {
    if (hit_sphere(&Point3.init(0, 0, -1), 0.5, r)) return Color.init(1, 0, 0);

    const unit_direction = r.d.unit();
    const a = 0.5 * (unit_direction.y + 1);
    return Color.init(1, 1, 1).mul(1 - a).add(Color.init(0.5, 0.7, 1.0).mul(a));
}

pub fn main() !void {
    const aspect_ratio = 16.0 / 9.0;

    const image_width = 400;
    const image_height: comptime_int = @max(1, @as(comptime_float, image_width) / aspect_ratio);

    const actual_aspect_ratio = @as(comptime_float, image_width) / @as(comptime_float, image_height);

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * actual_aspect_ratio;
    const camera_center = Point3.zero();

    const viewport_u = Vec3{ .x = viewport_width };
    const viewport_v = Vec3{ .y = -viewport_height };

    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    const viewport_upper_left = camera_center.sub(Vec3{ .z = focal_length }).sub(viewport_u.div(2)).sub(viewport_v.div(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mul(0.5));

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{image_height - j});

        for (0..image_width) |i| {
            const fi: f32 = @floatFromInt(i);
            const fj: f32 = @floatFromInt(j);

            const pixel_center = pixel00_loc.add(pixel_delta_u.mul(fi)).add(pixel_delta_v.mul(fj));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray{ .o = camera_center, .d = ray_direction };

            const color = ray_color(&r);
            try color.write_color(stdout);
        }

        try bw.flush();
    }

    std.debug.print("\rDone.                 \n", .{});
}

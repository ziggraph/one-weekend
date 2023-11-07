const float = @import("config.zig").float;
const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Color = vec3.Color;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;
const hit = @import("hit.zig");
const HitRecord = hit.HitRecord;
const HitLists = hit.HitLists;
const math = std.math;
const Sphere = @import("sphere.zig").Sphere;
const Interval = @import("interval.zig").Interval;

fn ray_color(r: *const Ray, world: *const HitLists) Color {
    var rec = HitRecord{};
    if (world.hit(r, Interval.init(0, math.inf(float)), &rec)) {
        return rec.n.add(Color.one()).mul(0.5);
    }

    const unit_direction = r.d.unit();
    const a = 0.5 * (unit_direction.y + 1);
    return Color.init(1, 1, 1).mul(1 - a).add(Color.init(0.5, 0.7, 1.0).mul(a));
}

pub fn main() !void {

    // Image

    const aspect_ratio = 16.0 / 9.0;

    const image_width = 400;
    const image_height: comptime_int = @max(1, @as(comptime_float, image_width) / aspect_ratio);

    // Allocator

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // World

    var world = HitLists.init(allocator);

    try world.addSphere(Sphere{ .center = Point3{ .z = -1 }, .radius = 0.5 });
    try world.addSphere(Sphere{ .center = Point3{ .y = -100.5, .z = -1 }, .radius = 100 });

    // Camera

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
            const fi: float = @floatFromInt(i);
            const fj: float = @floatFromInt(j);

            const pixel_center = pixel00_loc.add(pixel_delta_u.mul(fi)).add(pixel_delta_v.mul(fj));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray{ .o = camera_center, .d = ray_direction };

            const color = ray_color(&r, &world);
            try color.write_color(stdout);
        }

        try bw.flush();
    }

    std.debug.print("\rDone.                 \n", .{});
}

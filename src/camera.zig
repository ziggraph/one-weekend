const std = @import("std");

const Ray = @import("ray.zig").Ray;

const hit = @import("hit.zig");
const HitLists = hit.HitLists;
const HitRecord = hit.HitRecord;

const interval = @import("interval.zig");
const Interval = interval.Interval;
const inf = interval.inf;

const vec3 = @import("vec3.zig");
const Color = vec3.Color;
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;

const Sphere = @import("sphere.zig").Sphere;

const float = @import("config.zig").float;

pub const Camera = struct {
    // Image
    aspect_ratio: float = 16.0 / 9.0,
    image_width: i32 = 400,
    _image_height: i32 = undefined,
    _pixel_delta_u: Vec3 = undefined,
    _pixel_delta_v: Vec3 = undefined,
    _pixel00_loc: Point3 = undefined,
    _camera_center: Point3 = undefined,

    pub fn render(self: *Camera, world: HitLists) !void {
        try self.init();

        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, self._image_height });
        for (0..@intCast(self._image_height)) |j| {
            std.debug.print("\rScanlines remaining: {d} ", .{self._image_height - @as(i32, @intCast(j))});

            for (0..@intCast(self.image_width)) |i| {
                const fi: float = @floatFromInt(i);
                const fj: float = @floatFromInt(j);

                const pixel_center = self._pixel00_loc.add(self._pixel_delta_u.scale(fi)).add(self._pixel_delta_v.scale(fj));
                const ray_direction = pixel_center.sub(self._camera_center);
                const r = Ray{ .o = self._camera_center, .d = ray_direction };

                const color = ray_color(&r, &world);
                try color.write_color(stdout);
            }

            try bw.flush();
        }

        std.debug.print("\rDone.                 \n", .{});
    }

    fn init(self: *Camera) !void {
        self._image_height = @intFromFloat(@max(1.0, @as(float, @floatFromInt(self.image_width)) / self.aspect_ratio));
        self._camera_center = Point3.zero();
        const actual_aspect_ratio = @as(float, @floatFromInt(self.image_width)) / @as(float, @floatFromInt(self._image_height));

        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * actual_aspect_ratio;
        const camera_center = Point3.zero();

        const viewport_u = Vec3{ .x = viewport_width };
        const viewport_v = Vec3{ .y = -viewport_height };

        self._pixel_delta_u = viewport_u.div(@floatFromInt(self.image_width));
        self._pixel_delta_v = viewport_v.div(@floatFromInt(self._image_height));

        const viewport_upper_left = camera_center.sub(Vec3{ .z = focal_length }).sub(viewport_u.div(2)).sub(viewport_v.div(2));
        self._pixel00_loc = viewport_upper_left.add(self._pixel_delta_u.add(self._pixel_delta_v).scale(0.5));
    }

    fn ray_color(r: *const Ray, world: *const HitLists) Color {
        var rec = HitRecord{};

        if (world.hit(r, Interval.init(0, inf), &rec)) {
            return rec.n.add(Color.one()).scale(0.5);
        }

        const unit_direction = r.d.unit();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Color.one().scale(1.0 - a).add(Color.init(0.5, 0.7, 1.0).scale(a));
    }
};

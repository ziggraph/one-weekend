const std = @import("std");

const Ray = @import("ray.zig").Ray;

const hit = @import("hit.zig");
const HitLists = hit.HitLists;
const HitRecord = hit.HitRecord;

const interval = @import("interval.zig");
const Interval = interval.Interval;

const vec3 = @import("vec3.zig");
const Color = vec3.Color;
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;

const Sphere = @import("sphere.zig").Sphere;

const config = @import("config.zig");
const float = config.float;
const inf = config.inf;

pub const Camera = struct {
    aspect_ratio: float = 16.0 / 9.0,
    image_width: usize = 400,
    samples_per_pixel: usize = 10,
    seed: u64 = 0,
    _rnd: std.rand.Xoshiro256 = undefined,
    _image_height: usize = undefined,
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
        for (0..self._image_height) |j| {
            std.debug.print("\rScanlines remaining: {d} ", .{self._image_height - j});

            for (0..self.image_width) |i| {
                var pixel_color = Color.zero();
                for (0..self.samples_per_pixel) |_| {
                    const r = self.get_ray(i, j);
                    pixel_color = pixel_color.add(self.ray_color(&r, &world));
                }
                try pixel_color.writeColor(stdout, self.samples_per_pixel);
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

        self._rnd = std.rand.DefaultPrng.init(self.seed);
    }

    fn get_ray(self: *Camera, i: usize, j: usize) Ray {
        const fi: float = @floatFromInt(i);
        const fj: float = @floatFromInt(j);

        const pixel_center = self._pixel00_loc.add(self._pixel_delta_u.scale(fi)).add(self._pixel_delta_v.scale(fj));
        const pixel_sample = pixel_center.add(self.pixel_sample_square());

        const ray_direction = pixel_sample.sub(self._camera_center);
        return Ray{ .o = self._camera_center, .d = ray_direction };
    }

    fn pixel_sample_square(self: *Camera) Vec3 {
        const px = -0.5 + self._rnd.random().float(float);
        const py = -0.5 + self._rnd.random().float(float);
        return self._pixel_delta_u.scale(px).add(self._pixel_delta_v.scale(py));
    }

    fn ray_color(self: *Camera, r: *const Ray, world: *const HitLists) Color {
        var rec = HitRecord{};

        if (world.hit(r, Interval.init(0, inf), &rec)) {
            const direction = Vec3.randomOnHemisphere(&self._rnd, &rec.n);
            return self.ray_color(&Ray.init(rec.p, direction), world).scale(0.5);
        }

        const unit_direction = r.d.unit();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Color.one().scale(1.0 - a).add(Color.init(0.5, 0.7, 1.0).scale(a));
    }
};

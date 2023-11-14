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

const material = @import("material.zig");
const Material = material.Material;
const Lambertian = material.Lambertian;

pub const Camera = struct {
    aspect_ratio: float = 16.0 / 9.0,
    image_width: usize = 400,
    samples_per_pixel: usize = 10,
    max_depth: usize = 10,
    seed: u64 = 0,

    vfov: float = 90,
    lookfrom: Point3 = Point3.init(0, 0, -1),
    lookat: Point3 = Point3.init(0, 0, 0),
    vup: Vec3 = Vec3.init(0, 1, 0),

    defocus_angle: float = 0,
    focus_dist: float = 10,

    _rnd: std.rand.Xoshiro256 = undefined,
    _image_height: usize = undefined,
    _pixel_delta_u: Vec3 = undefined,
    _pixel_delta_v: Vec3 = undefined,
    _pixel00_loc: Point3 = undefined,
    _center: Point3 = undefined,
    _u: Vec3 = undefined,
    _v: Vec3 = undefined,
    _w: Vec3 = undefined,
    _defocus_disk_u: Vec3 = undefined,
    _defocus_disk_v: Vec3 = undefined,

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
                    const r = self.getRay(i, j);
                    pixel_color = pixel_color.add(self.rayColor(&r, self.max_depth, &world));
                }
                try pixel_color.writeColor(stdout, self.samples_per_pixel);
            }

            try bw.flush();
        }

        std.debug.print("\rDone.                 \n", .{});
    }

    fn init(self: *Camera) !void {
        self._image_height = @intFromFloat(@max(1.0, @as(float, @floatFromInt(self.image_width)) / self.aspect_ratio));
        self._center = self.lookfrom;
        const actual_aspect_ratio = @as(float, @floatFromInt(self.image_width)) / @as(float, @floatFromInt(self._image_height));

        const theta = std.math.degreesToRadians(float, self.vfov);
        const h = @tan(theta / 2);
        const viewport_height = 2 * h * self.focus_dist;
        const viewport_width = viewport_height * actual_aspect_ratio;

        self._w = self.lookfrom.sub(self.lookat).unit();
        self._u = self.vup.cross(self._w).unit();
        self._v = self._w.cross(self._u);

        const viewport_u = self._u.scale(viewport_width);
        const viewport_v = self._v.scale(-viewport_height);

        self._pixel_delta_u = viewport_u.div(@floatFromInt(self.image_width));
        self._pixel_delta_v = viewport_v.div(@floatFromInt(self._image_height));

        const viewport_upper_left = self._center.sub(self._w.scale(self.focus_dist)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
        self._pixel00_loc = viewport_upper_left.add(self._pixel_delta_u.add(self._pixel_delta_v).scale(0.5));

        const defocus_radius = self.focus_dist * @tan(std.math.degreesToRadians(float, self.defocus_angle / 2));
        self._defocus_disk_u = self._u.scale(defocus_radius);
        self._defocus_disk_v = self._v.scale(defocus_radius);
        self._rnd = std.rand.DefaultPrng.init(self.seed);
    }

    fn getRay(self: *Camera, i: usize, j: usize) Ray {
        const fi: float = @floatFromInt(i);
        const fj: float = @floatFromInt(j);

        const pixel_center = self._pixel00_loc.add(self._pixel_delta_u.scale(fi)).add(self._pixel_delta_v.scale(fj));
        const pixel_sample = pixel_center.add(self.pixelSampleSquare());

        const ray_origin = if (self.defocus_angle <= 0) self._center else self.defocus_disk_sample();
        const ray_direction = pixel_sample.sub(ray_origin);
        return Ray{ .o = ray_origin, .d = ray_direction };
    }

    fn pixelSampleSquare(self: *Camera) Vec3 {
        const px = -0.5 + self._rnd.random().float(float);
        const py = -0.5 + self._rnd.random().float(float);
        return self._pixel_delta_u.scale(px).add(self._pixel_delta_v.scale(py));
    }

    fn defocus_disk_sample(self: *Camera) Point3 {
        const p = Vec3.randomInUnitDisk(&self._rnd);
        return self._center.add(self._defocus_disk_u.scale(p.x)).add(self._defocus_disk_v.scale(p.y));
    }

    fn rayColor(self: *Camera, r: *const Ray, depth: usize, world: *const HitLists) Color {
        if (depth <= 0) {
            return Color.zero();
        }

        var rec = HitRecord{};

        if (world.hit(r, Interval.init(0.001, inf), &rec)) {
            var scattered = Ray{};
            var attenuation = Color{};
            if (rec.mat.scatter(&self._rnd, r, &rec, &attenuation, &scattered)) {
                return attenuation.mul(self.rayColor(&scattered, depth - 1, world));
            }
            return Color.zero();
        }

        const unit_direction = r.d.unit();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Color.one().scale(1.0 - a).add(Color.init(0.5, 0.7, 1.0).scale(a));
    }
};

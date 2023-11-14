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
const Camera = @import("camera.zig").Camera;
const material = @import("material.zig");
const Material = material.Material;
const Lambertian = material.Lambertian;
const Metal = material.Metal;
const Dielectric = material.Dielectric;

pub fn main() !void {
    // Allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // World
    var world = HitLists.init(allocator);

    const mat_ground = Material{ .lambertian = Lambertian{ .albedo = Color.init(0.5, 0.5, 0.5) } };
    try world.addSphere(Sphere.init(Point3.init(0.0, -1000, 0), 1000, mat_ground));

    const seed = 0;
    var rng = std.rand.DefaultPrng.init(seed);

    var a: float = -11;
    while (a < 11) : (a += 1) {
        var b: float = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = r(&rng);
            const center = Point3.init(a + 0.9 * r(&rng), 0.2, b + 0.9 * r(&rng));

            if (center.sub(Point3.init(4, 0.2, 0)).mag() > 0.9) {
                if (choose_mat < 0.8) {
                    const albedo = Color.random(&rng).mul(Color.random(&rng));
                    const mat = Material{ .lambertian = Lambertian{ .albedo = albedo } };
                    try world.addSphere(Sphere.init(center, 0.2, mat));
                } else if (choose_mat < 0.95) {
                    const albedo = Color.random(&rng).div(2).add(Color.all(0.5));
                    const fuzz = r(&rng) / 2;
                    const mat = Material{ .metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
                    try world.addSphere(Sphere.init(center, 0.2, mat));
                } else {
                    const mat = Material{ .dielectric = Dielectric{ .ir = 1.5 } };
                    try world.addSphere(Sphere.init(center, 0.2, mat));
                }
            }
        }
    }

    const mat_1 = Material{ .dielectric = Dielectric{ .ir = 1.5 } };
    try world.addSphere(Sphere.init(Point3.init(0, 1, 0), 1.0, mat_1));

    const mat_2 = Material{ .lambertian = Lambertian{ .albedo = Color.init(0.4, 0.2, 0.1) } };
    try world.addSphere(Sphere.init(Point3.init(-4, 1, 0), 1.0, mat_2));

    const mat_3 = Material{ .metal = Metal{ .albedo = Color.init(0.7, 0.6, 0.5), .fuzz = 0.0 } };
    try world.addSphere(Sphere.init(Point3.init(4, 1, 0), 1.0, mat_3));

    // Camera
    var camera = Camera{ .image_width = 1200, .samples_per_pixel = 10, .max_depth = 50, .lookfrom = Point3.init(13, 2, 3), .lookat = Point3.init(0, 0, 0), .vup = Vec3.init(0, 1, 0), .vfov = 20, .defocus_angle = 0.6, .focus_dist = 10.0 };

    try camera.render(world);
}

fn r(rng: *std.rand.Xoshiro256) float {
    return rng.random().float(float);
}

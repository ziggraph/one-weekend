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

    const mat_ground = Material{ .lambertian = Lambertian{ .albedo = Color.init(0.8, 0.8, 0.0) } };
    const mat_center = Material{ .lambertian = Lambertian{ .albedo = Color.init(0.1, 0.2, 0.5) } };
    const mat_left = Material{ .dielectric = Dielectric{ .ir = 1.5 } };
    const mat_right = Material{ .metal = Metal{ .albedo = Color.init(0.8, 0.6, 0.2), .fuzz = 0.0 } };

    try world.addSphere(Sphere.init(Point3.init(0.0, -100.5, -1.0), 100.0, mat_ground));
    try world.addSphere(Sphere.init(Point3.init(0.0, 0.0, -1.0), 0.5, mat_center));
    try world.addSphere(Sphere.init(Point3.init(-1.0, 0.0, -1.0), 0.5, mat_left));
    try world.addSphere(Sphere.init(Point3.init(-1.0, 0.0, -1.0), -0.4, mat_left));
    try world.addSphere(Sphere.init(Point3.init(1.0, 0.0, -1.0), 0.5, mat_right));

    // Camera
    var camera = Camera{ .samples_per_pixel = 100, .max_depth = 50 };
    try camera.render(world);
}

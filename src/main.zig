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

pub fn main() !void {
    // Allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // World
    var world = HitLists.init(allocator);
    try world.addSphere(Sphere{ .center = Point3{ .z = -1 }, .radius = 0.5 });
    try world.addSphere(Sphere{ .center = Point3{ .y = -100.5, .z = -1 }, .radius = 100 });

    // Camera
    var camera = Camera{ .samples_per_pixel = 100 };
    try camera.render(world);
}

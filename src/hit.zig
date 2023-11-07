const float = @import("config.zig").float;
const vec3 = @import("vec3.zig");
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Interval = @import("interval.zig").Interval;

pub const HitRecord = struct {
    p: Point3 = undefined,
    n: Vec3 = undefined,
    t: float = undefined,
    front_face: bool = undefined,

    pub fn setFaceNormal(self: *HitRecord, r: *const Ray, outward_normal: *const Vec3) void {
        self.front_face = r.d.dot(outward_normal.*) < 0;
        self.n = if (self.front_face) outward_normal.* else outward_normal.neg();
    }
};

pub const HitLists = struct {
    spheres: ArrayList(Sphere),

    pub fn init(allocator: Allocator) HitLists {
        return HitLists{ .spheres = ArrayList(Sphere).init(allocator) };
    }

    pub fn clearAndFree(self: HitLists) !void {
        try self.spheres.clearAndFree();
    }

    pub fn addSphere(self: *HitLists, sphere: Sphere) Allocator.Error!void {
        try self.spheres.append(sphere);
    }

    pub fn hit(self: HitLists, r: *const Ray, ray_t: Interval, rec: *HitRecord) bool {
        var temp_rec = HitRecord{};
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.spheres.items) |sphere| {
            if (sphere.hit(r, Interval.init(ray_t.min, closest_so_far), &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};

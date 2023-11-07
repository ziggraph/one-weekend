const vec3 = @import("vec3.zig");
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub const HitRecord = struct {
    p: Point3,
    n: Vec3,
    t: f32,
    front_face: bool,

    fn setFaceNormal(self: HitRecord, r: *const Ray, outward_normal: *const Vec3) void {
        self.front_face = r.d.dot(outward_normal) < 0;
        self.n = if (self.front_face) outward_normal else -outward_normal;
    }
};

pub const HitList = struct {
    spheres: ArrayList(Sphere),

    fn init(allocator: Allocator) HitList {
        return HitList{ .spheres = ArrayList(Sphere).init(allocator) };
    }

    fn clearAndFree(self: HitList) !void {
        try self.spheres.clearAndFree();
    }

    fn addSphere(self: HitList, sphere: Sphere) !void {
        try self.spheres.append(sphere);
    }

    fn hit(self: HitList, r: *const Ray, ray_tmin: f32, ray_tmax: f32, rec: *HitRecord) bool {
        var temp_rec = HitRecord{};
        var hit_anything = false;
        var closest_so_far = ray_tmax;

        for (self.spheres) |sphere| {
            if (sphere.hit(r, ray_tmin, closest_so_far, temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
        }

        return hit_anything;
    }
};

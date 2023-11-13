const float = @import("config.zig").float;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hit.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;

pub const Sphere = struct {
    center: Point3,
    radius: float,
    mat: Material,

    pub fn init(center: Point3, radius: float, mat: Material) Sphere {
        return Sphere{ .center = center, .radius = radius, .mat = mat };
    }

    pub fn hit(self: Sphere, r: *const Ray, ray_t: Interval, rec: *HitRecord) bool {
        const oc = r.o.sub(self.center);
        const a = r.d.mag2();
        const half_b = oc.dot(r.d);
        const c = oc.mag2() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false;
        const sqrtd = @sqrt(discriminant);

        var root = (-half_b - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (-half_b + sqrtd) / a;
            if (!ray_t.surrounds(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).div(self.radius);
        rec.setFaceNormal(r, &outward_normal);
        rec.mat = self.mat;

        return true;
    }
};

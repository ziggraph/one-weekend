const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hit.zig").HitRecord;
const vec3 = @import("vec3.zig");
const Color = vec3.Color;
const Vec3 = vec3.Vec3;
const Xoshiro256 = @import("std").rand.Xoshiro256;
const float = @import("config.zig").float;

pub const MaterialTag = enum {
    lambertian,
    metal,
};

pub const Material = union(MaterialTag) {
    lambertian: Lambertian,
    metal: Metal,

    pub fn scatter(self: Material, rnd: *Xoshiro256, r_in: *const Ray, rec: *const HitRecord, attenuation: *Color, scattered: *Ray) bool {
        switch (self) {
            .lambertian => |m| {
                var scatter_direction = rec.n.add(Vec3.randomUnitVec3(rnd));
                if (scatter_direction.near_zero()) scatter_direction = rec.n;
                scattered.* = Ray.init(rec.p, scatter_direction);
                attenuation.* = m.albedo;
                return true;
            },
            .metal => |m| {
                const reflected = Vec3.reflect(&r_in.d.unit(), &rec.n);
                scattered.* = Ray.init(rec.p, reflected);
                attenuation.* = m.albedo;
                return true;
            },
        }
    }
};

pub const Lambertian = struct { albedo: Color };

pub const Metal = struct { albedo: Color };

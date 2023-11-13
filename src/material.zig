const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hit.zig").HitRecord;
const vec3 = @import("vec3.zig");
const Color = vec3.Color;
const Vec3 = vec3.Vec3;
const std = @import("std");
const Xoshiro256 = std.rand.Xoshiro256;
const float = @import("config.zig").float;

pub const MaterialTag = enum {
    lambertian,
    metal,
    dielectric,
};

pub const Material = union(MaterialTag) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

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
                scattered.* = Ray.init(rec.p, reflected.add(Vec3.randomUnitVec3(rnd).scale(m.fuzz)));
                attenuation.* = m.albedo;
                return scattered.d.dot(rec.n) > 0;
            },

            .dielectric => |m| {
                attenuation.* = Color.one();
                const refraction_ratio = if (rec.front_face) 1.0 / m.ir else m.ir;
                const unit_direction = r_in.d.unit();
                const cos_theta = @min(-unit_direction.dot(rec.n), 1.0);
                const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);
                const cannot_refract = refraction_ratio * sin_theta > 1.0;
                const direction = if (cannot_refract or reflectance(cos_theta, refraction_ratio) > rnd.random().float(float)) Vec3.reflect(&unit_direction, &rec.n) else Vec3.refract(&unit_direction, &rec.n, refraction_ratio);
                scattered.* = Ray.init(rec.p, direction);
                return true;
            },
        }
    }

    fn reflectance(cosine: float, ref_idx: float) float {
        var r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(float, 1 - cosine, 5);
    }
};

pub const Lambertian = struct { albedo: Color };

pub const Metal = struct { albedo: Color, fuzz: float };

pub const Dielectric = struct { ir: float };

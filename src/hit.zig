const vec3 = @import("vec3.zig");
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;

pub const HitRecord = struct {
    p: Point3,
    n: Vec3,
    t: f32,
};

const vec3 = @import("vec3.zig");
const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;
const Ray = @import("ray.zig").Ray;

pub const HitRecord = struct {
    p: Point3,
    n: Vec3,
    t: f32,
    front_face: bool,

    fn set_face_normal(self: HitRecord, r: *const Ray, outward_normal: *const Vec3) void {
        self.front_face = r.d.dot(outward_normal) < 0;
        self.n = if (self.front_face) outward_normal else -outward_normal;
    }
};

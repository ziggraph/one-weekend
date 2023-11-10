const float = @import("config.zig").float;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point3 = vec3.Point3;

pub const Ray = struct {
    o: Point3,
    d: Vec3,

    pub fn at(self: Ray, t: float) Point3 {
        return self.o.add(self.d.scale(t));
    }
};

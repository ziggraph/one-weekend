const float = @import("config.zig").float;
const std = @import("std");

const Interval = @import("interval.zig").Interval;

pub const Vec3 = struct {
    x: float = 0,
    y: float = 0,
    z: float = 0,

    pub fn zero() Vec3 {
        return Vec3{};
    }

    pub fn one() Vec3 {
        return Vec3{
            .x = 1,
            .y = 1,
            .z = 1,
        };
    }

    pub fn init(x: float, y: float, z: float) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn eq(self: Vec3, other: Vec3) bool {
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }

    pub fn dot(self: Vec3, other: Vec3) float {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn mag2(self: Vec3) float {
        return self.dot(self);
    }

    pub fn mag(self: Vec3) float {
        return @sqrt(self.mag2());
    }

    pub fn scale(self: Vec3, k: float) Vec3 {
        return Vec3{
            .x = k * self.x,
            .y = k * self.y,
            .z = k * self.z,
        };
    }

    pub fn neg(self: Vec3) Vec3 {
        return self.scale(-1);
    }

    pub fn div(self: Vec3, k: float) Vec3 {
        return self.scale(1 / k);
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return self.add(other.neg());
    }

    pub fn unit(self: Vec3) Vec3 {
        return self.div(self.mag());
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x,
        };
    }

    pub fn write_color(self: Vec3, w: anytype, sample_per_pixel: usize) !void {
        const weight = 1.0 / @as(float, @floatFromInt(sample_per_pixel));
        const weighted = self.scale(weight);

        const intensity = Interval.init(0.000, 0.999);
        const clamped = Color.init(intensity.clamp(weighted.x), intensity.clamp(weighted.y), intensity.clamp(weighted.z));

        try w.print("{d} {d} {d}\n", .{
            @as(i32, @intFromFloat(clamped.x * 256)),
            @as(i32, @intFromFloat(clamped.y * 256)),
            @as(i32, @intFromFloat(clamped.z * 256)),
        });
    }
};

pub const Point3 = Vec3;
pub const Color = Vec3;

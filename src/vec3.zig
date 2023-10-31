const std = @import("std");

pub const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn zero() Vec3 {
        return Vec3{};
    }

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn eq(self: Vec3, other: Vec3) bool {
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn mag2(self: Vec3) f32 {
        return self.dot(self);
    }

    pub fn mag(self: Vec3) f32 {
        return @sqrt(self.mag2());
    }

    pub fn mul(self: Vec3, k: f32) Vec3 {
        return Vec3{
            .x = k * self.x,
            .y = k * self.y,
            .z = k * self.z,
        };
    }

    pub fn neg(self: Vec3) Vec3 {
        return self.mul(-1);
    }

    pub fn div(self: Vec3, k: f32) Vec3 {
        return self.mul(1 / k);
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

    pub fn write_color(self: Vec3, w: anytype) !void {
        try w.print("{d} {d} {d}\n", .{
            @as(i32, @intFromFloat(self.x * 255.999)),
            @as(i32, @intFromFloat(self.y * 255.999)),
            @as(i32, @intFromFloat(self.z * 255.999)),
        });
    }
};

pub const Point3 = Vec3;
pub const Color = Vec3;

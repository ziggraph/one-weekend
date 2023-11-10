const float = @import("config.zig").float;
pub const inf = @import("std").math.inf(float);

pub const Interval = struct {
    min: float = inf,
    max: float = -inf,

    pub fn init(min: float, max: float) Interval {
        return Interval{ .min = min, .max = max };
    }

    pub fn contains(self: Interval, x: float) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: float) bool {
        return self.min < x and x < self.max;
    }
};

pub const empty = Interval.init(inf, -inf);
pub const universe = Interval.init(-inf, inf);

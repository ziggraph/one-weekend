const config = @import("config.zig");
const float = config.float;
const inf = config.inf;

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

    pub fn clamp(self: Interval, x: float) float {
        if (x < self.min) return self.min;
        if (x > self.max) return self.max;
        return x;
    }
};

pub const empty = Interval.init(inf, -inf);
pub const universe = Interval.init(-inf, inf);

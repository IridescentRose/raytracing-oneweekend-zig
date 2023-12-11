const std = @import("std");

const Interval = @This();

max: f64,
min: f64,

pub fn empty() Interval {
    return .{ .min = std.math.inf(f64), .max = -std.math.inf(f64) };
}

pub fn universe() Interval {
    return .{ .min = -std.math.inf(f64), .max = std.math.inf(f64) };
}

pub fn contains(self: *const Interval, x: f64) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: *const Interval, x: f64) bool {
    return self.min < x and x < self.max;
}

pub fn clamp(self: *const Interval, x: f64) f64 {
    if (x < self.min) {
        return self.min;
    } else if (x > self.max) {
        return self.max;
    }

    return x;
}

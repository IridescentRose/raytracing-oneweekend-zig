const std = @import("std");
const hittable = @import("hit.zig");
const vec = @import("vec.zig");
const Vec3 = vec.Vec3;
const HittableList = hittable.HittableList;
const Sphere = hittable.Sphere;
const Camera = @import("camera.zig");
const material = @import("material.zig");
const LambertianMaterial = material.LambertianMaterial;
const MetalMaterial = material.MetalMaterial;
const DialectricMaterial = material.DialectricMaterial;
const Material = material.Material;
const Interval = @import("interval.zig");

pub fn main() !void {
    // Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = try HittableList.init(allocator);
    var ground_mat = LambertianMaterial.init(Vec3.init(0.5, 0.5, 0.5));
    var ground = Sphere.init(Vec3.init(0, -1000, 0), 1000, ground_mat.material());
    try world.objects.append(ground.hittable());

    // Camera
    var camera = Camera.init();

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            var mat_choose: f64 = camera.random.float(f64);

            var center = Vec3.init(@as(f64, @floatFromInt(a)) + 0.9 * camera.random.float(f64), 0.2, @as(f64, @floatFromInt(b)) + 0.9 * camera.random.float(f64));

            if (center.sub(Vec3.init(4, 0.2, 0)).length() > 0.9) {
                var materials: Material = undefined;

                if (mat_choose < 0.8) {
                    var color = Vec3.random(camera.random);
                    var mat = try allocator.create(LambertianMaterial);
                    mat.* = LambertianMaterial.init(color);
                    materials = mat.material();
                } else if (mat_choose < 0.95) {
                    var color = Vec3.random_interval(camera.random, Interval{ .min = 0.5, .max = 1.0 });
                    var fuzz = camera.random.float(f64) * 0.5;

                    var mat = try allocator.create(MetalMaterial);
                    mat.* = MetalMaterial.init(color, fuzz);
                    materials = mat.material();
                } else {
                    var mat = try allocator.create(DialectricMaterial);
                    mat.* = DialectricMaterial.init(1.5);
                    materials = mat.material();
                }

                var sphere = try allocator.create(Sphere);
                sphere.* = Sphere.init(center, 0.2, materials);

                try world.objects.append(sphere.hittable());
            }
        }
    }

    var material1 = DialectricMaterial.init(1.5);
    var material2 = LambertianMaterial.init(Vec3.init(0.4, 0.2, 0.1));
    var material3 = MetalMaterial.init(Vec3.init(0.7, 0.6, 0.5), 0.0);

    var sphere1 = Sphere.init(Vec3.init(0, 1, 0), 1.0, material1.material());
    var sphere2 = Sphere.init(Vec3.init(-4, 1, 0), 1.0, material2.material());
    var sphere3 = Sphere.init(Vec3.init(4, 1, 0), 1.0, material3.material());

    try world.objects.append(sphere1.hittable());
    try world.objects.append(sphere2.hittable());
    try world.objects.append(sphere3.hittable());

    try camera.render(allocator, &world);
}

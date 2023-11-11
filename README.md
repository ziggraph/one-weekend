# *Ray Tracing in One Weekend* in Zig

To learn ray tracing and Zig in one go.

[The book](https://raytracing.github.io/books/RayTracingInOneWeekend.html), version be *4.0.0-alpha.1*

Zig version 0.11.0

## Build and Render

It takes a little while to build, but runs much faster,

    zig build run -Doptimize=ReleaseFast > image.ppm

View image,

    feh image.ppm

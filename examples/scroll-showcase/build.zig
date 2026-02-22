const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Módulo principal do exemplo
    const showcase = b.addModule("scroll-showcase", .{
        .root_source_file = b.path("src/main.zig"),
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    // Referencia o framework forbear como dependência (path = "../..")
    const forbear = b.dependency("forbear", .{
        .target = target,
        .optimize = optimize,
    });
    showcase.addImport("forbear", forbear.module("forbear"));

    const exe = b.addExecutable(.{
        .name = "scroll-showcase",
        .root_module = showcase,
        .use_llvm = true,
    });
    b.installArtifact(exe);

    // `zig build run` — compila e executa o exemplo
    const run_command = b.addRunArtifact(exe);
    run_command.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the scroll showcase");
    run_step.dependOn(&run_command.step);
}

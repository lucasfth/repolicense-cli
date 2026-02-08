const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_module = b.addModule("repolicense", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "repolicense",
        .root_module = exe_module,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Test step
    const tree_test_module = b.addModule("tree_test", .{
        .root_source_file = b.path("src/tree_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tree_tests = b.addTest(.{
        .name = "tree_test",
        .root_module = tree_test_module,
    });

    const compatibility_test_module = b.addModule("compatibility_test", .{
        .root_source_file = b.path("src/compatibility_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const compatibility_tests = b.addTest(.{
        .name = "compatibility_test",
        .root_module = compatibility_test_module,
    });

    const run_tree_tests = b.addRunArtifact(tree_tests);
    const run_compatibility_tests = b.addRunArtifact(compatibility_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tree_tests.step);
    test_step.dependOn(&run_compatibility_tests.step);
}

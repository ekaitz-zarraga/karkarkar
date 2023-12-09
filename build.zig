const std           = @import("std");
const Build         = std.Build;
const Step          = std.Build.Step;
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn addConfig(step: *Step.Compile) !void {
    step.addIncludePath(.{ .path="ahotts_c" });
    step.addCSourceFiles(&.{
        "ahotts_c/htts.cpp"
    }, &.{});
    step.linkLibC();
    step.linkLibCpp();
    step.linkSystemLibrary("m");

    const targetinfo = try NativeTargetInfo.detect(step.target);
    if (targetinfo.target.os.tag == .windows) {
        // Add library paths for windows, as we are building in linux...
        // We have the prebuilt libs in a folder called 'windows'
        step.addSystemIncludePath(.{.path="windows/include"});
        step.addLibraryPath(.{.path="windows/lib"});
        step.linkSystemLibrary("OpenAL32");
        step.linkSystemLibrary("htts");
    } else {
        step.linkSystemLibrary("openal");
        step.linkSystemLibrary("htts");
    }
    step.linker_allow_shlib_undefined = true;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "karkarkar",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    try addConfig(exe);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    try addConfig(unit_tests);
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

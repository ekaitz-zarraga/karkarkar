const std           = @import("std");
const Builder       = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn addConfig(step: *LibExeObjStep) !void {
    step.addIncludePath("ahotts_c");
    step.addCSourceFiles(&.{
        "ahotts_c/htts.cpp"
    }, &.{});
    step.linkLibCpp();
    step.linkSystemLibrary("c");
    step.linkSystemLibrary("m");

    const targetinfo = try NativeTargetInfo.detect(step.target);
    if (targetinfo.target.os.tag == .windows) {
        // Add library paths for windows, as we are building in linux...
        // We have the prebuilt libs in a folder called 'windows'
        step.addIncludePath("windows/include");
        step.addLibraryPath("windows/lib");
        step.linkSystemLibrary("OpenAL32");
    } else {
        step.linkSystemLibrary("openal");
    }
    step.linkSystemLibrary("htts");
}

pub fn build(b: *Builder) !void {

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable( "karkarkar", "src/main.zig",);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    try addConfig(exe);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);
    try addConfig(exe_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

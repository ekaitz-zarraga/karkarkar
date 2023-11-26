const Builder = @import("std").build.Builder;
const LibExeObjStep = @import("std").build.LibExeObjStep;

pub fn addConfig(step: *LibExeObjStep) void {
    step.addIncludePath("ahotts_c");

    // Submodule ftw :S
    step.addIncludePath("AhoTTS/src");
    step.addLibraryPath("AhoTTS/build/src/");

    step.linkLibCpp();
    step.linkSystemLibrary("ao");
    step.linkSystemLibrary("c");
    step.linkSystemLibrary("m");
    step.linkSystemLibrary("htts");
    step.addCSourceFiles(&.{
        "ahotts_c/htts.cpp"
    }, &.{});
}

pub fn build(b: *Builder) void {

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable( "karkarkar", "src/main.zig",);
    addConfig(exe);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    addConfig(exe_tests);
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

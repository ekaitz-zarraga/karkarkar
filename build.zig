const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {

    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable( "karkarkar", "src/main.zig",);
    exe.addIncludePath("ahotts_c");

    // Submodule ftw :S
    exe.addIncludePath("AhoTTS/src");
    exe.addLibraryPath("AhoTTS/build/src/");

    exe.linkLibCpp();
    exe.linkSystemLibrary("ao");
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("m");
    exe.linkSystemLibrary("htts");
    exe.addCSourceFiles(&.{
        "ahotts_c/htts.cpp"
    }, &.{});
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
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

// https://ziglang.org/learn/build-system/
const std              = @import("std");
const Build            = std.Build;
const Step             = std.Build.Step;
const OptimizeMode     = std.builtin.OptimizeMode;

pub fn makeAhotts(b: *std.Build, target: Build.ResolvedTarget, optimize: OptimizeMode) *Step.Compile{
    const ahotts = b.addStaticLibrary(.{
        .name = "htts",
        .target = target,
        .optimize = optimize
    });
    ahotts.linkLibC();
    ahotts.linkLibCpp();
    ahotts.addCSourceFiles(.{
        .files = &.{
            "AhoTTS/src/strl_3.cpp",
            "AhoTTS/src/clargs.c",
            "AhoTTS/src/mark_3.cpp",
            "AhoTTS/src/symbolexp.c",
            "AhoTTS/src/strl_0.cpp",
            "AhoTTS/src/aftxh.cpp",
            "AhoTTS/src/uti_misc.c",
            "AhoTTS/src/eu_stuti.cpp",
            "AhoTTS/src/afwav.cpp",
            "AhoTTS/src/afwav_1.cpp",
            "AhoTTS/src/afauto.cpp",
            "AhoTTS/src/afaho1.cpp",
            "AhoTTS/src/afnist.cpp",
            "AhoTTS/src/afraw.cpp",
            "AhoTTS/src/afhak.cpp",
            "AhoTTS/src/listt.cpp",
            "AhoTTS/src/listt_0.cpp",
            "AhoTTS/src/listt_1.cpp",
            "AhoTTS/src/listt_2.cpp",
            "AhoTTS/src/uti_end.c",
            "AhoTTS/src/mark.cpp",
            "AhoTTS/src/uti_file.c",
            "AhoTTS/src/uti_math.c",
            "AhoTTS/src/spl10.c",
            "AhoTTS/src/cabecer.c",
            "AhoTTS/src/cabctrl.c",
            "AhoTTS/src/afaho2.cpp",
            "AhoTTS/src/aftei.cpp",
            "AhoTTS/src/afwav_0.cpp",
            "AhoTTS/src/callback.cpp",
            "AhoTTS/src/caudio.cpp",
            "AhoTTS/src/caudiof.cpp",
            "AhoTTS/src/chartype.c",
            "AhoTTS/src/choputi.c",
            "AhoTTS/src/chset.c",
            "AhoTTS/src/comp.cpp",
            "AhoTTS/src/ctlist.cpp",
            "AhoTTS/src/decli.cpp",
            "AhoTTS/src/es_abbacr.cpp",
            "AhoTTS/src/es_apost.cpp",
            "AhoTTS/src/es_cap.cpp",
            "AhoTTS/src/es_categ.cpp",
            "AhoTTS/src/es_comp.cpp",
            "AhoTTS/src/es_dateexp.cpp",
            "AhoTTS/src/es_datehilvl.cpp",
            "AhoTTS/src/es_emph.cpp",
            "AhoTTS/src/es_gf.cpp",
            "AhoTTS/src/es_hdic.cpp",
            "AhoTTS/src/es_ling.cpp",
            "AhoTTS/src/es_normal.cpp",
            "AhoTTS/src/es_numexp.cpp",
            "AhoTTS/src/es_numhilvl.cpp",
            "AhoTTS/src/es_pau2.cpp",
            "AhoTTS/src/es_pause.cpp",
            "AhoTTS/src/es_percent.cpp",
            "AhoTTS/src/es_phtr.cpp",
            "AhoTTS/src/es_pos.cpp",
            "AhoTTS/src/es_pronun.cpp",
            "AhoTTS/src/es_romanhilvl.cpp",
            "AhoTTS/src/es_speller.cpp",
            "AhoTTS/src/es_stre.cpp",
            "AhoTTS/src/es_syl.cpp",
            "AhoTTS/src/es_timeexp.cpp",
            "AhoTTS/src/es_units.cpp",
            "AhoTTS/src/es_uti.cpp",
            "AhoTTS/src/es_w2ph.cpp",
            "AhoTTS/src/es_wrdch.cpp",
            "AhoTTS/src/eu_abbacr.cpp",
            "AhoTTS/src/eu_apost.cpp",
            "AhoTTS/src/eu_cap.cpp",
            "AhoTTS/src/eu_categ.cpp",
            "AhoTTS/src/eu_comp.cpp",
            "AhoTTS/src/eu_dateexp.cpp",
            "AhoTTS/src/eu_datehilvl.cpp",
            "AhoTTS/src/eu_decli.cpp",
            "AhoTTS/src/eu_emph.cpp",
            "AhoTTS/src/eu_gf.cpp",
            "AhoTTS/src/eu_hdic.cpp",
            "AhoTTS/src/eu_ling.cpp",
            "AhoTTS/src/eu_mrk_tf.cpp",
            "AhoTTS/src/eu_normal.cpp",
            "AhoTTS/src/eu_numexpafterpoint.cpp",
            "AhoTTS/src/eu_numexp.cpp",
            "AhoTTS/src/eu_numhilvl.cpp",
            "AhoTTS/src/eu_pau1.cpp",
            "AhoTTS/src/eu_pause.cpp",
            "AhoTTS/src/eu_percent.cpp",
            "AhoTTS/src/eu_phtr.cpp",
            "AhoTTS/src/eu_pos.cpp",
            "AhoTTS/src/eu_pronun.cpp",
            "AhoTTS/src/eu_ptuti.cpp",
            "AhoTTS/src/eu_romanhilvl.cpp",
            "AhoTTS/src/eu_speller.cpp",
            "AhoTTS/src/eu_stre.cpp",
            "AhoTTS/src/eu_syl.cpp",
            "AhoTTS/src/eu_timeexp.cpp",
            "AhoTTS/src/eu_units.cpp",
            "AhoTTS/src/eu_uti.cpp",
            "AhoTTS/src/eu_w2ph.cpp",
            "AhoTTS/src/eu_wrdch.cpp",
            "AhoTTS/src/fblock.cpp",
            "AhoTTS/src/galdeg.cpp",
            "AhoTTS/src/gfadi.cpp",
            "AhoTTS/src/gfize.cpp",
            "AhoTTS/src/gfpau.cpp",
            "AhoTTS/src/hdic_do.cpp",
            "AhoTTS/src/hdic_io.cpp",
            "AhoTTS/src/HTS_ahocoder.c",
            "AhoTTS/src/HTS_audio.c",
            "AhoTTS/src/HTS_engine.c",
            "AhoTTS/src/HTS_gstream.c",
            "AhoTTS/src/HTS_label.c",
            "AhoTTS/src/HTS_misc.c",
            "AhoTTS/src/HTS_model.c",
            "AhoTTS/src/HTS_pstream.c",
            "AhoTTS/src/HTS_sstream.c",
            "AhoTTS/src/HTS_vocoder.c",
            "AhoTTS/src/hts.cpp",
            "AhoTTS/src/httsdo.cpp",
            "AhoTTS/src/htts_io.cpp",
            "AhoTTS/src/httsmsg.c",
            "AhoTTS/src/io.cpp",
            "AhoTTS/src/isofilt.c",
            "AhoTTS/src/mark_0.cpp",
            "AhoTTS/src/numhilvl.cpp",
            "AhoTTS/src/percent.cpp",
            "AhoTTS/src/phmap.cpp",
            "AhoTTS/src/phone.c",
            "AhoTTS/src/pos1.cpp",
            "AhoTTS/src/poscases.cpp",
            "AhoTTS/src/roman.c",
            "AhoTTS/src/romanhilvl.cpp",
            "AhoTTS/src/samp_0.cpp",
            "AhoTTS/src/samp.cpp",
            "AhoTTS/src/sca_pau.cpp",
            "AhoTTS/src/scapedo.cpp",
            "AhoTTS/src/scapeseq.cpp",
            "AhoTTS/src/string.cpp",
            "AhoTTS/src/string_gcc.cpp",
            "AhoTTS/src/strl.cpp",
            "AhoTTS/src/strl_2.cpp",
            "AhoTTS/src/symbolexp.c",
            "AhoTTS/src/t2l.cpp",
            "AhoTTS/src/t2u_do.cpp",
            "AhoTTS/src/t2u_io.cpp",
            "AhoTTS/src/timehilvl.cpp",
            "AhoTTS/src/u2w.cpp",
            "AhoTTS/src/units.cpp",
            "AhoTTS/src/uti_die.c",
            "AhoTTS/src/uti_path.c",
            "AhoTTS/src/uti_str.c",
            "AhoTTS/src/utt.cpp",
            "AhoTTS/src/uttph.cpp",
            "AhoTTS/src/uttws.cpp",
            "AhoTTS/src/virtual.cpp",
            "AhoTTS/src/wordchop.cpp",
            "AhoTTS/src/wrkbuff.c",
            "AhoTTS/src/wsdump.cpp",
            "AhoTTS/src/xx_uti.cpp",
            "AhoTTS/src/eu_dur1.cpp",
            "AhoTTS/src/eu_proso.cpp",
            "AhoTTS/src/eu_dur2.cpp",
            "AhoTTS/src/eu_pth1.cpp",
            "AhoTTS/src/eu_pow1.cpp",
            "AhoTTS/src/es_proso.cpp",
            "AhoTTS/src/es_dur1.cpp",
            "AhoTTS/src/es_dur2.cpp",
            "AhoTTS/src/es_pth1.cpp",
            "AhoTTS/src/es_pow1.cpp",
        },
        .flags=&.{"-IAhoTTS/src/"}
    });
    return ahotts;
}

pub fn addConfig(step: *Step.Compile) !void {
    const b = step.step.owner;
    step.addIncludePath(b.path("ahotts_c"));
    step.addCSourceFiles(.{
        .files=&.{"ahotts_c/htts.cpp" },
        .flags=&.{"-IAhoTTS/src/"}
    });
    step.linkLibC();
    step.linkLibCpp();
    step.linkSystemLibrary("m");

    const target = step.rootModuleTarget();
    if (target.os.tag == .windows) {
        // Add library paths for windows, as we are building in linux...
        // We have the prebuilt libs in a folder called 'windows'
        step.addSystemIncludePath(b.path("windows/include"));
        step.addLibraryPath(b.path("windows/lib"));
        step.linkSystemLibrary("OpenAL32");
    } else {
        step.linkSystemLibrary("openal");
    }
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "karkarkar",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const ahotts = makeAhotts(b, target, optimize);
    try addConfig(exe);
    exe.linkLibrary(ahotts);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.linkLibrary(ahotts);
    try addConfig(unit_tests);
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

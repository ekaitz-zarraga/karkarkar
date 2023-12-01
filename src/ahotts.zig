const std = @import("std");
const debug = std.debug;
const path  = std.fs.path;
const fmt   = std.fmt;
const c = @cImport({
    @cInclude("htts.h");
    @cInclude("malloc.h");
});

const HttsError = error {
    Allocation,
    Creation,
    Prepare,
};

const HttsConfig = struct {
    alloc:    std.mem.Allocator,
    datadir:  [] const u8,
    voicedir: [] const u8,
    dicdir:   [] const u8,

    fn init(alloc: std.mem.Allocator, datadir: []const u8, lang: []const u8)
        !HttsConfig
    {
        var voice_dir = try fmt.allocPrint(alloc, "aholab_{s}_female", .{lang});
        defer alloc.free(voice_dir);

        var dicts_dir = try fmt.allocPrint(alloc, "{s}_dicc", .{lang});
        defer alloc.free(dicts_dir);

        var main_dir  = try path.join(alloc, &[_][]const u8{datadir, "data_tts"});
        return HttsConfig{
            .datadir  = main_dir,
            .voicedir = try path.join(alloc, &[_][]const u8{main_dir, "voices", voice_dir}),
            .dicdir   = try path.join(alloc, &[_][]const u8{main_dir, "dicts", dicts_dir}),
            .alloc    = alloc,
        };
    }
    fn deinit(self: *HttsConfig) void{
        self.alloc.free(self.datadir);
        self.alloc.free(self.voicedir);
        self.alloc.free(self.dicdir);
    }
};

pub const Htts = struct {
    config: HttsConfig,
    internal: *anyopaque,
    datadir: []const u8,
    lang: [*]const u8,

    pub fn init(alloc: std.mem.Allocator, datadir: []const u8, lang:[]const u8) !Htts {
        var htts = c.HTTS_new() orelse return HttsError.Allocation;
        var config = try HttsConfig.init(alloc, datadir, lang);

        // NOTE: The order is relevant. CAREFUL
        _ = c.HTTS_set(htts, "Lang", lang.ptr);
        _ = c.HTTS_set(htts, "HDicDBName", config.dicdir.ptr);
        if(0 == c.HTTS_create(htts)){ return HttsError.Creation; }
        _ = c.HTTS_set(htts, "PthModel", "Pth1");
        _ = c.HTTS_set(htts, "Method", "HTS");
        _ = c.HTTS_set(htts, "vp", "yes");
        _ = c.HTTS_set(htts, "voice_path", config.voicedir.ptr);
        return Htts {
            .config = config,
            .internal = htts,
            .datadir = datadir,
            .lang = lang.ptr
        };
    }

    pub fn prepare(self:*Htts, text:[*c]const u8) !void {
        if(0 == c.HTTS_input_multilingual(self.internal, text, self.lang, self.datadir.ptr)){
            return HttsError.Prepare;
        }
    }

    pub fn consume(self: *Htts) ![]c_short{
        var samples: [*c]c_short = undefined;
        var res = c.HTTS_output_multilingual(self.internal, self.lang, &samples);
        var len = @intCast(usize, if (res < 0) -res else res);
        return samples[0..len];
    }

    pub fn deinit(self:*Htts) void {
        self.config.deinit();
        c.HTTS_delete(self.internal);
    }
};

const debug = @import("std").debug;
const c = @cImport({
    @cInclude("htts.h");
    @cInclude("malloc.h");
});

const DATADIR = "AhoTTS/data_tts/";
const VOICEDIR = "AhoTTS/data_tts/voices/aholab_eu_female/";
const DICDIR = "AhoTTS/data_tts/dicts/";
const DICPATH = DICDIR ++ "/eu_dicc";

const HttsError = error {
    Allocation,
    Creation,
    Prepare,
};

pub const Htts = struct {
    internal: *anyopaque,
    datadir: []const u8,
    lang: []const u8,

    pub fn init(datadir: []const u8, lang:[]const u8) !Htts {
        _ = datadir; // TODO use the input better


        var htts = c.HTTS_new() orelse return HttsError.Allocation;

        // NOTE: The order is relevant. CAREFUL
        _ = c.HTTS_set(htts, "HDicDBName", DICPATH);
        if(0 == c.HTTS_create(htts)){ return HttsError.Creation; }
        _ = c.HTTS_set(htts, "PthModel", "Pth1");
        _ = c.HTTS_set(htts, "Method", "HTS");
        _ = c.HTTS_set(htts, "Lang", lang.ptr);
        _ = c.HTTS_set(htts, "vp", "yes");
        _ = c.HTTS_set(htts, "voice_path", VOICEDIR);
        return Htts {
            .internal = htts,
            .datadir = DATADIR,
            .lang = lang
        };
    }

    pub fn prepare(self:*Htts, text:[*c]const u8) !void {
        if(0 == c.HTTS_input_multilingual(self.internal, text, "eu", DATADIR)){
            return HttsError.Prepare;
        }
    }

    pub fn consume(self: *Htts) ![]c_short{
        var samples: [*c]c_short = undefined;
        var res = c.HTTS_output_multilingual(self.internal, "eu", &samples);
        var len = @intCast(usize, if (res < 0) -res else res);
        return samples[0..len];
    }

    pub fn deinit(self:*Htts) void {
        c.HTTS_delete(self.internal);
    }
};

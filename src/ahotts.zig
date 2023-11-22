const debug = @import("std").debug;
const c = @cImport({
    @cInclude("htts.h");
    @cInclude("malloc.h");
});

const DATADIR = "AhoTTS/data_tts/";
const VOICEDIR = "AhoTTS/data_tts/voices/aholab_eu_female/";
const DICDIR = "AhoTTS/data_tts/dicts/";
const DICPATH = DICDIR ++ "/eu_dicc";

pub const Htts = struct {
    internal: *anyopaque,
    datadir: []const u8,
    lang: []const u8,

    pub fn init(datadir: []const u8, lang:[]const u8) ?Htts {
        _ = datadir; // TODO use the input better


        var htts = c.HTTS_new();

        // NOTE: The order is relevant. CAREFUL
        _ = c.HTTS_set(htts, "HDicDBName", DICPATH);
        if(0 == c.HTTS_create(htts)){ return null; } // THIS SHOULD BE AN ERROR
        _ = c.HTTS_set(htts, "PthModel", "Pth1");
        _ = c.HTTS_set(htts, "Method", "HTS");
        _ = c.HTTS_set(htts, "Lang", lang.ptr);
        _ = c.HTTS_set(htts, "vp", "yes");
        _ = c.HTTS_set(htts, "voice_path", VOICEDIR);
        return Htts {
            .internal = htts.?,
            .datadir = DATADIR,
            .lang = lang
        };
    }

    pub fn say(self:*Htts, text:[*c]const u8) ?[]c_short {
        if(0 != c.HTTS_input_multilingual(self.internal, text, "eu", DATADIR)){
            var samples: [*c]c_short = undefined;
            var res = c.HTTS_output_multilingual(self.internal, "eu", &samples);
            var len = @intCast(usize, if (res < 0) -res else res);
            _ = c.HTTS_flush(self.internal);
            return samples[0..len];
        }
        return null;
    }

    pub fn deinit(self:*Htts) void {
        c.HTTS_delete(self.internal);
    }
};

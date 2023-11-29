const Htts = @import("ahotts.zig").Htts;
// const Ao = @import("play/ao.zig").Ao;
const OpenAl = @import("play/openal.zig").OpenAl;
const c = @cImport({
    @cInclude("malloc.h");
});

pub const Talker = struct {
    // ao: *Ao,
    audio: *OpenAl,
    htts: *Htts,

    pub fn say(self: *Talker, str: [*c]const u8) !void {
        try self.htts.prepare(str);
        var samples = try self.htts.consume();
        while (samples.len != 0) : (samples = try self.htts.consume()){
            errdefer c.free(samples.ptr);
            try self.audio.play(samples);
            c.free(samples.ptr);
        }
    }
};

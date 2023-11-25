const Htts = @import("ahotts.zig").Htts;
const Ao = @import("ao.zig").Ao;
const c = @cImport({
    @cInclude("malloc.h");
});

pub const Talker = struct {
    ao: *Ao,
    htts: *Htts,

    pub fn say(self: *Talker, str: [*c]const u8) !void {
        try self.htts.prepare(str);
        var samples = try self.htts.consume();
        while (samples.len != 0) : (samples = try self.htts.consume()){
            errdefer c.free(samples.ptr);
            try self.ao.play(samples);
            c.free(samples.ptr);
        }
    }
};

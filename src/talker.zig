const Htts = @import("ahotts.zig").Htts;
const Ao = @import("ao.zig").Ao;
const c = @cImport({
    @cInclude("malloc.h");
});

pub const Talker = struct {
    ao: *Ao,
    htts: *Htts,

    pub fn say(self: *Talker, str: [*c]const u8) !void {
        var samples = self.htts.say(str).?;
        defer c.free(samples.ptr);
        try self.ao.play(samples);
    }
};

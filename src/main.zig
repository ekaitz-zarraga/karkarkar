const std = @import("std");
const Htts = @import("ahotts.zig").Htts;
const c = @cImport({
    @cInclude("ao/ao.h");
});


pub fn main() !void {
    c.ao_initialize();
    defer c.ao_shutdown();

    var default_driver = c.ao_default_driver_id();
    var format : c.ao_sample_format = .{
        .bits = 16,
        .channels = 1,
        .rate = 16000,
        .byte_format = c.AO_FMT_LITTLE,
        .matrix = undefined,
    };
    var device = c.ao_open_live(default_driver, &format, null);
    defer _ = c.ao_close(device);

    var htts = Htts.create("AhoTTS/data_tts/", "eu").?;
    defer htts.delete();

    var samples = htts.say("Kaixo Zitalko zelan dena?").?;
    defer c.free(samples.ptr);
    _ = c.ao_play(device, @intToPtr([*c]u8, @ptrToInt(samples.ptr)), @truncate(c_uint, samples.len*@sizeOf(c_short)));
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

const std    = @import("std");
const Htts   = @import("ahotts.zig").Htts;
const Ao     = @import("ao.zig").Ao;
const Talker = @import("talker.zig").Talker;

pub fn main() !void {
    var ao = try Ao.init();
    defer ao.deinit();

    var htts = Htts.init("AhoTTS/data_tts/", "eu").?;
    defer htts.deinit();

    var talker = Talker {
        .ao   = &ao,
        .htts = &htts,
    };

    try talker.say("Kaixo Zitalko zelan dena?");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

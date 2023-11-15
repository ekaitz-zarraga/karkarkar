const std = @import("std");
const c = @cImport({
    @cInclude("htts.h");
    @cInclude("ao/ao.h");
    @cInclude("malloc.h");
});


pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    const htts = c.HTTS_new();
    defer c.HTTS_delete(htts);

    _ = c.HTTS_set(htts, "PthModel", "Pth1");
    _ = c.HTTS_set(htts, "Method", "HTS");
    _ = c.HTTS_set(htts, "Lang", "eu");
    _ = c.HTTS_set(htts, "HDicDBName", "/gnu/store/bpqm6njc0bczhmn9zi4qwsyr0hp1imgy-ahotts-master/share/AhoTTS/data_tts/dicts/eu_dicc");

    if(0 == c.HTTS_create(htts)){ return; } // THIS SHOULD BE AN ERROR
    _ = c.HTTS_set(htts, "voice_path", "/gnu/store/bpqm6njc0bczhmn9zi4qwsyr0hp1imgy-ahotts-master/share/AhoTTS/data_tts/voices/aholab_eu_female/");
    _ = c.HTTS_set(htts, "vp", "yes");


    const text = "Putaseme halakoa";
    if(0 != c.HTTS_input_multilingual(htts, text, "eu", "")){
        var samples: [*c]c_short = undefined;
        _ = c.HTTS_output_multilingual(htts, "eu", &samples);
        defer c.free(samples);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

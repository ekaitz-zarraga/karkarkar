const std    = @import("std");
const Htts   = @import("ahotts.zig").Htts;
const Ao     = @import("ao.zig").Ao;
const Talker = @import("talker.zig").Talker;

pub fn main() !void {
    var argv = std.os.argv;
    if (argv.len != 3){
        const stderr = std.io.getStdErr();
        try stderr.writer().print("2 arguments needed: \n\t{s} es|eu MESSAGE", .{argv[0]});
        return error.ArgumentCount;
    }

    const lang    = std.mem.span(argv[1]);
    if (!std.mem.eql(u8, lang, "es") and !std.mem.eql(u8, lang, "eu")){
        return error.InvalidLang;
    }
    const message = argv[2];

    var ao = try Ao.init();
    defer ao.deinit();

    var htts = try Htts.init(std.heap.page_allocator,  "AhoTTS/data_tts", lang);
    defer htts.deinit();

    var talker = Talker {
        .ao   = &ao,
        .htts = &htts,
    };

    try talker.say(message);
}

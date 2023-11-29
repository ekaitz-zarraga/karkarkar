const std           = @import("std");
const Htts          = @import("ahotts.zig").Htts;
const Ao            = @import("play/ao.zig").Ao;
const OpenAl        = @import("play/openal.zig").OpenAl;
const Talker        = @import("talker.zig").Talker;
const findDataDir   = @import("datadir.zig").findDataDir;
const _Irc          = @import("irc.zig");
const Irc           = _Irc.Irc;
const IrcCommandTag = _Irc.IrcCommandTag;
const IrcMessage    = _Irc.IrcMessage;

pub fn main() !void {
    // TODO parameterize these
    const lang    = "eu";
    const channel = "#ekaitzza";

    var allocator = std.heap.page_allocator;
    const datadir = try findDataDir(allocator, "AhoTTS");
    defer allocator.free(datadir);

    var irc = try Irc.init(allocator, "irc.chat.twitch.tv", 6667);
    try irc.login();
    try irc.join(channel);

    // var ao = try Ao.init();
    // defer ao.deinit();
    var audio = try OpenAl.init();
    defer audio.deinit();

    var htts = try Htts.init(allocator, datadir, lang);
    defer htts.deinit();

    var talker = Talker {
        .audio = &audio,
        .htts  = &htts,
    };

    // TODO: graceful shutdown with SIGINT
    while (true) {
        var answer = try irc.rec();
        var message = IrcMessage.parse(answer);

        switch (message.command) {
            IrcCommandTag.Ping    => {
                std.debug.print("PING {s}", .{message.parameters.?});
                try irc.pong(message.parameters orelse "");
            },
            IrcCommandTag.Privmsg => |v| {
                std.debug.print("{s}: Message received\n", .{v});
                var body = try allocator.dupeZ(u8, message.parameters.?);
                try talker.say(body.ptr);
            },
            IrcCommandTag.Cap     => |v| std.debug.print("CAP {} \n", .{v}),
            IrcCommandTag.Other   => std.debug.print("Unknown command: {s}\n", .{message.raw_command}),
        }
        allocator.free(answer);
    }
    try irc.send("PART");
}

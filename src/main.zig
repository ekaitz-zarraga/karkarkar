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

const MainError = error {
    ChannelDoesNotExist,
    BadInput,
    WrongArguments
};

pub fn isHelp(argv: [*:0]u8) bool {
    const arg = std.mem.span(argv);
    return std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h");
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    const argv = std.os.argv;

    const progname = std.fs.path.basename(std.mem.span(argv[0]));
    if (argv.len == 2 and isHelp(argv[1])) {
        try stderr.print("Help: \n\t{s} [username]\n\n" ++
        "If username not provided, it will be queried interactively\n",
        .{progname});
        return;
    }

    // Get channel ID
    var channel_argv : []u8 = undefined;
    if (argv.len == 1) {
        std.debug.print("Username not provided in command line...\n", .{});
        var buf: [100]u8 = undefined;
        try stdout.print("Enter your Twitch username please: ", .{});
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            channel_argv = user_input;
            try stdout.print("Got it!\n\n", .{});
        } else {
            return MainError.BadInput;
        }
    } else if (argv.len == 2){
        channel_argv = std.mem.span(argv[1]);
    } else {
        return MainError.WrongArguments;
    }

    const lang = "eu"; // TODO: Spanish support in AhoTTS is garbage and
                       // requires utf-8 to latin-1 conversion
    var channel = try allocator.alloc(u8, channel_argv.len+1);
    defer allocator.free(channel);
    channel = try std.fmt.bufPrint(channel, "#{s}", .{channel_argv});
    std.debug.print("Listening to: {s}\n", .{channel});


    const datadir = try findDataDir(allocator, "AhoTTS");
    defer allocator.free(datadir);

    // TODO: check if joined properly and channel exists
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

    // TODO: graceful shutdown with SIGINT?? we don't have cross platform ways
    // to do it...
    while (true) {
        const answer = try irc.rec();
        const message = IrcMessage.parse(answer);

        switch (message.command) {
            IrcCommandTag.Ping    => {
                std.debug.print("PING {s}", .{message.parameters.?});
                try irc.pong(message.parameters orelse "");
            },
            IrcCommandTag.Privmsg => |v| {
                std.debug.print("{s}: Message received\n", .{v});
                const body = try allocator.dupeZ(u8, message.parameters.?);
                try talker.say(body.ptr);
            },
            IrcCommandTag.Cap     => |v| std.debug.print("CAP {} \n", .{v}),
            IrcCommandTag.Other   =>
                std.debug.print("Unknown command: {s}\n", .{message.raw_command}),
        }
        allocator.free(answer);
    }
    try irc.send("PART");
}

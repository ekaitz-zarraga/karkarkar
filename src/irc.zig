// https://github.com/ctmnz/twitchtvpythonbot/tree/master
const std = @import("std");
const net = @import("std").net;

pub const IrcCommandTag = @import("irc/message.zig").IrcCommandTag;
pub const IrcMessage = @import("irc/message.zig").IrcMessage;

pub const Irc = struct {
    allocator: std.mem.Allocator,
    stream: net.Stream,

    pub fn init(allocator: std.mem.Allocator, hostname: []const u8, port: u16) !Irc {
        var stream = try net.tcpConnectToHost(allocator, hostname, port);
        return Irc {
            .allocator = allocator,
            .stream = stream,
        };
    }

    pub fn login(self: *Irc) !void {
        try self.send("CAP REQ :twitch.tv/tags twitch.tv/commands");
        try self.send("PASS SCHMOOPIIE");
        try self.send("NICK justinfan121021");
    }

    pub fn join(self: *Irc, channel: []const u8) !void {
        var writer = self.stream.writer();
        _ = try writer.writeAll("JOIN ");
        _ = try writer.writeAll(channel);
        _ = try writer.writeAll("\r\n");
    }
    /// Send a message to the server. It's a blocking call.
    /// It automatically inserts \n\r
    pub fn send(self: *Irc, text: []const u8) !void {
        var writer = self.stream.writer();
        _ = try writer.writeAll(text);
        _ = try writer.writeAll("\r\n");
    }

    /// Send PONG message. It's a blocking call.
    pub fn pong(self: *Irc, content: []const u8) !void {
        var writer = self.stream.writer();
        _ = try writer.writeAll("PONG ");
        _ = try writer.writeAll(content);
        _ = try writer.writeAll("\r\n");
    }

    /// Receive a message from server. It's a blocking call.
    /// Returned response must be freed later.
    pub fn rec(self: *Irc) ![]u8{
        var reader = self.stream.reader();
        var message = try reader.readUntilDelimiterAlloc(self.allocator, '\r', 1024);
        _ = try reader.readByte(); // discard \r
        return message;
    }

    pub fn deinit(self: *Irc) void {
        self.stream.close();
    }
};


// pub fn main () !void {
//     const allocator = std.heap.page_allocator;
//     var irc = try Irc.init(allocator, "irc.chat.twitch.tv", 6667);
//     defer irc.deinit();
//     // https://discuss.dev.twitch.com/t/anonymous-connection-to-twitch-chat/20392
//     try irc.login();
//     try irc.join("#ekaitzza");
//     while (true) {
//         var answer = try irc.rec();
//         var message = IrcMessage.parse(answer);
//
//         switch (message.command) {
//             IrcCommandTag.Ping    => {
//                 std.debug.print("PING {s}", .{message.parameters.?});
//                 try irc.pong(message.parameters orelse "");
//             },
//             IrcCommandTag.Privmsg => |v| std.debug.print("{s}: Message received\n", .{v}),
//             IrcCommandTag.Cap     => |v| std.debug.print("CAP {} \n", .{v}),
//             IrcCommandTag.Other   => std.debug.print("Unknown command: {s}\n", .{message.raw_command}),
//         }
//         if (message.source) |s| {
//             std.debug.print("source: {s}\n", .{s});
//         }
//
//         if (message.tags) |_| {
//             var tags = try message.parseTags(allocator);
//             defer tags.deinit();
//             std.debug.print("tags:\n", .{});
//             var it = tags.iterator();
//             while(it.next()) |entry| {
//                 std.debug.print("- {s} = {s}\n", .{entry.key_ptr.*, entry.value_ptr.*});
//             }
//         }
//
//         if (message.parameters) |p| {
//             std.debug.print("parameters: {s}\n", .{p});
//         }
//         allocator.free(answer);
//     }
//     //things
//     try irc.send("PART");
// }

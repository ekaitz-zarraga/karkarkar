const std = @import("std");

pub const IrcError = error {
    ParseError
};

pub const IrcCommandTag = enum {
    Ping,
    Privmsg,
    Cap,
    Other
};
pub const IrcCommand = union(IrcCommandTag) {
    Ping:  void,
    Privmsg: []const u8,
    Cap: bool,
    Other: void,
};

pub const IrcSource = struct {
    nick: []u8,
    host: []u8
};

pub const IrcTags = std.StringHashMap([]const u8);

pub const IrcMessage = struct {
    command: IrcCommand,
    raw_command: []u8,
    parameters: ?[]u8,

    tags: ?[]const u8,

    //source: IrcSource,
    source: ?[]u8,

    fn parseCommand(command: []u8) IrcCommand {
        var iterator = std.mem.splitSequence(u8, command, " ");
        const comm =  iterator.next() orelse unreachable;
        if ( std.mem.eql(u8, comm, "PING") ){
            return .{ .Ping = undefined };
        }

        if ( std.mem.eql(u8, comm, "PRIVMSG") ){
            return .{ .Privmsg = iterator.next() orelse unreachable };
        }

        if ( std.mem.eql(u8, comm, "CAP") ){
            _ = iterator.next() orelse "";
            return .{ .Cap = std.mem.eql(u8, iterator.next() orelse "", "ACK") };
        }
        return .{ .Other = undefined };
    }

    /// Call this function manually, because in many cases is not needed so why
    /// bother?
    /// How to:
    ///   if (message.tags) |_| {
    ///       var tags = try message.parseTags(allocator);
    ///       defer tags.deinit();
    ///       std.debug.print("tags:\n", .{});
    ///       var it = tags.iterator();
    ///       while(it.next()) |entry| {
    ///           std.debug.print("- {s} = {s}\n", .{entry.key_ptr.*, entry.value_ptr.*});
    ///       }
    ///   }
    pub fn parseTags(self: IrcMessage, allocator: std.mem.Allocator) !IrcTags {
        // https://dev.twitch.tv/docs/irc/tags/
        var hm = IrcTags.init(allocator);
        var iterator = std.mem.splitSequence(u8, self.tags orelse return hm, ";");
        while (iterator.next()) |t|{
            var parts = std.mem.splitSequence(u8, t, "=");
            const k = parts.next() orelse unreachable;
            const v = parts.next() orelse unreachable;
            try hm.put(k, v);
        }
        return hm;
    }

    /// Parse an irc message string and return a IrcMessage, allocator is
    /// needed for the tags hashmap (will be removed later).
    pub fn parse(message: []u8) IrcMessage {
        var res : IrcMessage = undefined;

        var remaining = message[0..];

        // Tags
        if ( remaining[0] == '@' ) {
            remaining = remaining[1..];
            var index = std.mem.indexOfScalar(u8, remaining, ' ') orelse unreachable;
            res.tags = remaining[0..index];
            index += 1;
            remaining = remaining[index..];
        } else {
            res.tags = null;
        }

        // Source
        if ( remaining[0] == ':' ){
            remaining = remaining[1..];
            var index = std.mem.indexOfScalar(u8, remaining, ' ') orelse unreachable;
            res.source = remaining[0..index];
            index += 1;
            remaining = remaining[index..];
        } else {
            res.source= null;
        }

        // Command & parameters
        if ( std.mem.indexOfScalar(u8, remaining, ':') ) |index| {
            res.command = parseCommand(remaining[0..index]);
            res.raw_command = remaining[0..index];
            res.parameters = remaining[index+1..];
        } else {
            res.command = parseCommand(remaining[0..]);
            res.raw_command = remaining[0..];
            res.parameters = null;
        }
        return res;
    }
};

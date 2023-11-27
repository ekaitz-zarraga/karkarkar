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
    Other: void,
    Privmsg: []const u8,
    Cap: bool,
};

pub const IrcSource = struct {
    nick: []u8,
    host: []u8
};

pub const IrcMessage = struct {
    command: IrcCommand,
    raw_command: []u8,
    parameters: ?[]u8,

    //tags: std.HashMap([]u8, []u8),
    tags: ?[]u8,

    //source: IrcSource,
    source: ?[]u8,

    fn parseCommand(command: []u8) IrcCommand {
        var iterator = std.mem.split(u8, command, " ");
        var comm =  iterator.next() orelse unreachable;
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
    /// Parse an irc message string and return a IrcMessage, allocator is
    /// needed for the tags hashmap (will be removed later).
    pub fn parse(message: []u8) IrcMessage {
        var res : IrcMessage = undefined;

        var remaining = message[0..];

        // Tags
        if ( remaining[0] == '@' ) {
            remaining = remaining[1..];
            var index = std.mem.indexOfScalar(u8, remaining, ' ') orelse unreachable;
            // TODO parse tags
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

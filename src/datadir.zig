const builtin   = @import("builtin");
const std       = @import("std");
const fs        = std.fs;
const Allocator = std.mem.Allocator;
const getAppDataDir = std.fs.getAppDataDir; // REIMPLEMENT THIS AND USE IT TO
                                            // FIND THE DIRS IF THEY EXIST

fn exists(directory: []const u8) bool{
    const options = .{
        .access_sub_paths = false,
        .no_follow = false,
    };
    var dir = fs.openDirAbsolute(directory, options) catch return false;
    defer dir.close();
    return true;
}


fn findLinuxDataDirs (allocator: Allocator, appname: []const u8) ![]u8 {
    const datadirs = try std.process.getEnvVarOwned(allocator, "XDG_DATA_DIRS");
    // TODO: Maybe try in /usr/share?
    defer allocator.free(datadirs);
    var it = std.mem.tokenize(u8, datadirs, ":");
    while (it.next()) |dir| {
        var directory = try fs.path.join(allocator, &[_][]const u8{ dir, appname });
        std.debug.print("trying: {s}\n", .{directory});
        if ( !exists(directory) ){
            std.debug.print("Does not exist\n", .{});
            allocator.free(directory);
            continue;
        }
        return directory;
    }
    return error.NotFound;
}

/// Our data will be installed in LocalAppData in Windows and /share/ or
/// similar in Linux (Guix uses /share and stores it in XDG_DATA_DIRS).
pub fn findDataDir(allocator: Allocator, appname: []const u8) ![]u8 {
    return switch (builtin.os.tag) {
        .linux   => return try findLinuxDataDirs(allocator, appname),
        .windows => return try getAppDataDir(allocator, appname),
        else     => error.NotImplemented,
    };
}

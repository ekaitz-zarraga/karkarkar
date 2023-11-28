const builtin   = @import("builtin");
const std       = @import("std");
const fs        = std.fs;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn exists(directory: []const u8) bool{
    const options = .{
        .access_sub_paths = false,
        .no_follow = false,
    };
    var dir = fs.openDirAbsolute(directory, options) catch return false;
    defer dir.close();
    return true;
}

fn populateWindowsDirs(allocator: Allocator, dirs: *ArrayList([]const u8)) !void {
    const local_app_data_dir = try std.process.getEnvVarOwned(allocator, "LOCALAPPDATA");
    try dirs.append(local_app_data_dir);
}

fn populateLinuxDirs(allocator: Allocator, dirs: *ArrayList([]const u8)) !void {
    const xdg_data_home = std.process.getEnvVarOwned(allocator, "XDG_DATA_HOME") catch null;
    if (xdg_data_home) |x|{
        try dirs.append(x);
    }

    const xdg_data_dirs = std.process.getEnvVarOwned(allocator, "XDG_DATA_DIRS") catch null;
    if (xdg_data_dirs) |x| {
        defer allocator.free(x);
        var it = std.mem.tokenize(u8, x, ":");
        while (it.next()) |dir| {
            try dirs.append(try allocator.dupe(u8, dir));
        }
    }

    try dirs.append(try allocator.dupe(u8, "/usr/share"));
    try dirs.append(try allocator.dupe(u8, "/share"));
}

fn cleanDirs (allocator: Allocator, dirs: *ArrayList([]const u8)) void{
    for (dirs.items) |dir| {
        allocator.free(dir);
    }
}

/// Our data will be installed in LocalAppData in Windows and /share/ or
/// similar in Linux (Guix uses /share and stores it in XDG_DATA_DIRS).
pub fn findDataDir(allocator: Allocator, appname: []const u8) ![]u8 {
    var dirs = ArrayList([]const u8).init(allocator);
    defer dirs.deinit();

    switch (builtin.os.tag) {
        .linux   => try populateLinuxDirs(allocator, &dirs),
        .windows => try populateWindowsDirs(allocator, &dirs),
        else     => error.NotImplemented,
    }
    defer cleanDirs(allocator, &dirs);

    for (dirs.items) |dir| {
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

test "See if it explodes" {
    const allocator = std.testing.allocator;
    var dirs = ArrayList([]const u8).init(allocator);
    defer dirs.deinit();

    switch (builtin.os.tag) {
        .linux   => try populateLinuxDirs(allocator, &dirs),
        .windows => try populateWindowsDirs(allocator, &dirs),
        else     => error.NotImplemented,
    }
    defer cleanDirs(allocator, &dirs);

}

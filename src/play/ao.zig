const c = @cImport({
    @cInclude("ao/ao.h");
});

var format : c.ao_sample_format = .{
    .bits = 16,
    .channels = 1,
    .rate = 16000,
    .byte_format = c.AO_FMT_NATIVE, // TODO: make sure this is ok
    .matrix = undefined,
};

const AoError = error {
    DriverSelection,
    DeviceOpen,
    Playback,
};

pub const Ao = struct {
    device : *c.ao_device,

    pub fn init() !Ao {
        c.ao_initialize();
        errdefer c.ao_shutdown();

        const driver = c.ao_default_driver_id();
        if ( driver == -1 ) {
            return AoError.DriverSelection;
        }
        var device = c.ao_open_live(driver, &format, null)
            orelse return AoError.DeviceOpen;

        return Ao {
            .device = device,
        };
    }

    pub fn play(self: *Ao, samples: []c_short) !void{
        errdefer self.deinit();
        const res = c.ao_play(self.device,
            @intToPtr([*c]u8, @ptrToInt(samples.ptr)),
            @truncate(c_uint, samples.len*@sizeOf(c_short)));
        if ( res == 0 ) {
            return AoError.Playback;
        }
    }

    pub fn deinit(self: *Ao) void {
        _ = c.ao_close(self.device); // Ignore error, because we are playing to
                                     // audio device (it's not a file, no
                                     // chance for corruption)
        c.ao_shutdown();
    }
};

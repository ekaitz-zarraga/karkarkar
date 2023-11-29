// MAYBE USE OPENAL???
//
// https://ffainelli.github.io/openal-example/
// https://github.com/ohwada/MAC_cpp_Samples/blob/master/OpenAL/play_tone.cpp
//
//
// https://open-activewrl.sourceforge.net/data/OpenAL_PGuide.pdf
// https://www.openal.org/documentation/OpenAL_Programmers_Guide.pdf
const c = @cImport({
    @cInclude("time.h");
    @cInclude("AL/al.h");
    @cInclude("AL/alc.h");
});

const OpenAlError = error {
    OpenDevice,
    CreateContext,
    CurrentContext,
    GenBuffers,
    GenSources,
    BufferData
};

pub const OpenAl = struct {
    context: *c.ALCcontext,
    device: *c.ALCdevice,

    pub fn init() !OpenAl {
        var device = c.alcOpenDevice(null)
            orelse return OpenAlError.OpenDevice;

        var context = c.alcCreateContext(device, null)
            orelse return OpenAlError.CreateContext;

        var curcontext = c.alcMakeContextCurrent(context);
        if (curcontext == 0){
            return OpenAlError.CurrentContext;
        }

        return OpenAl {
            .device = device,
            .context = context,
        };
    }

    pub fn play(self: *OpenAl, samples: []c_short) !void{
        _ = self;
        var buffer: c.ALuint = undefined;
        var source: c.ALuint = undefined;
        c.alGenBuffers(1, &buffer);
        if (c.alGetError() != c.AL_NO_ERROR){
            return OpenAlError.GenBuffers;
        }
        c.alGenSources(1, &source);
        if (c.alGetError() != c.AL_NO_ERROR){
            return OpenAlError.GenSources;
        }
        c.alBufferData(buffer, c.AL_FORMAT_MONO16, samples.ptr,
            @truncate(u16, samples.len*@sizeOf(c_short)), 16000);
        if (c.alGetError() != c.AL_NO_ERROR){
            return OpenAlError.BufferData;
        }
        c.alSourcei(source, c.AL_BUFFER, @truncate(u16, buffer));
        c.alSourcePlay(source);

        // TODO Remove me =>
        var source_state : c.ALint = undefined;
        c.alGetSourcei(source, c.AL_SOURCE_STATE, &source_state);
        while (source_state == c.AL_PLAYING) {
            c.alGetSourcei(source, c.AL_SOURCE_STATE, &source_state);
        }
        // => Remove me

        c.alSourcePause(source);
        c.alDeleteSources(1, &source);
        c.alDeleteBuffers(1, &buffer);
    }

    pub fn deinit(self: *OpenAl) void {
        c.alcDestroyContext(self.context);
        _ = c.alcCloseDevice(self.device);
    }
};

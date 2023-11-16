#include <stdio.h>
#include <string.h>
#include <ao/ao.h>
#include <math.h>
#define BUF_SIZE 4096

#include <AhoTTS/htts.hpp>

int main (int argc, char* argv[]){

	ao_device *device;
	ao_sample_format format;
	int default_driver;
	char *buffer;
	int buf_size;
	int sample;
	float freq = 440.0;
	int i;
	/* -- Initialize -- */
	ao_initialize();
	/* -- Setup for default driver -- */
	default_driver = ao_default_driver_id();
	memset(&format, 0, sizeof(format));
	format.bits = 16;
	format.channels = 1;
	format.rate = 16000;
	format.byte_format = AO_FMT_LITTLE;
	device = ao_open_live(default_driver, &format, NULL /* no options */);
	if (device == NULL) {
		fprintf(stderr, "Error opening device.\n");
		return 1;
	}



    HTTS *tts = new HTTS;
    tts->set("PthModel", "Pth1"); //not used but must be defined
    tts->set("Method", "HTS"); //HTS -> HMM-based method
    if (!argc >= 2){
         fprintf(stderr, "Error, no language selected.\n");
         return 1;
     }
    char *lang = argv[1];
    tts->set("Lang", lang);
    char data_path[]="/gnu/store/xw30zlydxavds7xfrwxkdmwbq5ng8djr-ahotts-master/share/AhoTTS/data_tts";
    char dic_path[1024];
    sprintf(dic_path, "%s/dicts/%s_dicc", data_path, lang);
    tts->set("HDicDBName",dic_path);

    if (!tts->create()) {
            delete tts;
            return 0;
    }

    char voice_path[1024];
    sprintf(voice_path, "%s/voices/aholab_%s_female/", data_path, lang);// TODO Female Basque Voice
    // SET THE VOICE PATH
    tts->set("voice_path", voice_path);
    tts->set("vp", "yes");

    // CAudioFile fout;
    // fout.open(output_file,"w", "SRate=16000.0 NChan=1 FFormat=Wav"); //Mono, 16kHz

    if (argc != 3){
        fprintf(stderr, "Error, no input text.\n");
        return 1;
    }
    char *str = argv[2];
    if(tts->input_multilingual(str, lang, data_path, FALSE)){ //FALSE => str contains the input text
        short *samples;
        int len=0;
        //PROCESS A SENTENCE FROM THE TEXT AND GET "len" samples
        while((len = tts->output_multilingual(lang, &samples)) != 0){
            //samples are stored in the audio file, but could also be directed to the soundcard
            // fout.setBlk(samples, len);
            ao_play(device, (char *)samples, len*sizeof(short));
            free(samples); // Free the samples: they are allocated on the
                           // output_multilingual function!
        }
    }

	ao_close(device);

	ao_shutdown();
    return 0;
}

#include "htts.h"
#include <AhoTTS/htts.hpp>

// TODO use booleans where booleans are needed

extern "C" {
    void * HTTS_new( void ) {
        HTTS *htts = new HTTS;
        return static_cast<void*>( htts );
    }

    void HTTS_delete( void * v ) {
        HTTS *htts = static_cast<HTTS*>(v);
        delete htts;
    }

    int HTTS_set( void * v, const char* key, const char* val ) {
        HTTS *htts = static_cast<HTTS*>(v);
        return static_cast<int>(htts->set(key, val));
    }

    int HTTS_create( void * v ) {
        HTTS *htts = static_cast<HTTS*>(v);
        return static_cast<int>(htts->create());
    }

    int HTTS_flush( void * v ) {
        HTTS *htts = static_cast<HTTS*>(v);
        return static_cast<int>(htts->flush());
    }

    int HTTS_input_multilingual( void * v, const char *text, const char *lang, const char *datapath ) {
        HTTS *htts = static_cast<HTTS*>(v);
        return htts->input_multilingual(text, lang, datapath, false);
    }

    // This allocates `samples`
    int HTTS_output_multilingual( void * v, const char *lang, short **samples) {
        HTTS *htts = static_cast<HTTS*>(v);
        return htts->output_multilingual(lang, samples);
    }
}

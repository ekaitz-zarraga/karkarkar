#ifdef __cplusplus

// TODO use booleans where booleans are needed

extern "C"
{
#endif
void * HTTS_new( void );
void HTTS_delete( void * v );
int HTTS_set( void * v, const char* key, const char* val );
int HTTS_create( void * v );
int HTTS_flush( void * v );
int HTTS_input_multilingual( void * v, const char *text, const char *lang, const char *datapath );
int HTTS_output_multilingual( void * v,  const char *lang, short **samples);
#ifdef __cplusplus
}
#endif


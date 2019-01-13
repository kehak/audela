#if defined __cplusplus
#define XTERNE extern "C"
#else
#define XTERNE extern 
#endif

XTERNE void __bzero(void *s, unsigned int l)
{
   char *p = (char*)s;
   while(l--) *p++=0;
}


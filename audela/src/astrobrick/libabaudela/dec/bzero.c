extern "C" void __bzero(void *s, unsigned int l)
{
   char *p = (char*)s;
   while(l--) *p++=0;
}


#ifndef __DEBUG_C__
#define __DEBUG_C__

//#include <stdarg.h>
//#include <stdio.h>

static void dm_debug(char *fichier, int ligne, const char *format, ...)
{
   char buffer[1000], *p = buffer;
   FILE *f;
   va_list marqueur;
   va_start(marqueur,format);
   p += sprintf(buffer,"%s[%d]: ",fichier,ligne);
   vsprintf(p,format,marqueur);
   va_end(marqueur);
   f = fopen("d:\\denis.log","at");
   fprintf(f,"%s\n",buffer);
   fclose(f);
}

#define DM_DEBUG(format) dm_debug(__FILE__,__LINE__,format)
#define DM_DEBUG1(format,a1) dm_debug(__FILE__,__LINE__,format,a1)
#define DM_DEBUG2(format,a1,a2) dm_debug(__FILE__,__LINE__,format,a1,a2)
#define DM_DEBUG3(format,a1,a2,a3) dm_debug(__FILE__,__LINE__,format,a1,a2,a3)
#define DM_DEBUG4(format,a1,a2,a3,a4) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4)
#define DM_DEBUG5(format,a1,a2,a3,a4,a5) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5)
#define DM_DEBUG6(format,a1,a2,a3,a4,a5,a6) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5,a6)
#define DM_DEBUG7(format,a1,a2,a3,a4,a5,a6,a7) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5,a6,a7)
#define DM_DEBUG8(format,a1,a2,a3,a4,a5,a6,a7,a8) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5,a6,a7,a8)
#define DM_DEBUG9(format,a1,a2,a3,a4,a5,a6,a7,a8,a9) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#define DM_DEBUG10(format,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10) dm_debug(__FILE__,__LINE__,format,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

#endif
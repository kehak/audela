

#ifndef _INC_LIBESHEL_LINE_GAP
#define _INC_LIBESHEL_LINE_GAP

typedef struct LINE_GAP
{
   int    order;
   double l_obs;
   double l_calc;
   double l_diff;
   double l_posx;   
   double l_posy; 
   int  valid;
} LINE_GAP;


#endif
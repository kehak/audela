// libdigicam_canon.cpp :
//

#include <stdlib.h>  // pour NULL
#include <string.h>  // 

struct canonValueStruct
{
      int value;
      const char *label;
      float fvalue;
};

const struct canonValueStruct canonShutterValues[] =
{
      { 0x0010, "30"     , (float)30.0  },
      { 0x0013, "25"     , (float)25.0  },
      { 0x0015, "20"     , (float)20.0  },
      { 0x0018, "15"     , (float)15.0  },
      { 0x001b, "13"     , (float)13.0  },
      { 0x001d, "10"     , (float)10.0  },
      { 0x0020, "8"      , (float)8.0   },
      { 0x0023, "6"      , (float)6.0   },
      { 0x0025, "5"      , (float)5.0   },
      { 0x0028, "4"      , (float)4.0   },
      { 0x002b, "3.2"    , (float)3.2   },
      { 0x002d, "2.5"    , (float)2.5   },
      { 0x0030, "2"      , (float)2.0   },
      { 0x0033, "1.6"    , (float)1.6   },
      { 0x0035, "1.3"    , (float)1.3   },
      { 0x0038, "1"      , (float)1.0   },
      { 0x003b, "0.8"    , (float)0.8   },
      { 0x003d, "0.6"    , (float)0.6   },
      { 0x0040, "0.5"    , (float)0.5   },
      { 0x0043, "0.4"    , (float)0.4   },
      { 0x0045, "0.3"    , (float)0.3   },
      { 0x0048, "1/4"    , (float)0.25000   },
      { 0x004b, "1/5"    , (float)0.20000   },
      { 0x004d, "1/6"    , (float)0.16667   },
      { 0x0050, "1/8"    , (float)0.12500   },
      { 0x0053, "1/10"   , (float)0.10000   },
      { 0x0055, "1/13"   , (float)0.07692   },
      { 0x0058, "1/15"   , (float)0.06667   },
      { 0x005b, "1/20"   , (float)0.05000   },
      { 0x005d, "1/25"   , (float)0.04000   },
      { 0x0060, "1/30"   , (float)0.03333   },
      { 0x0063, "1/40"   , (float)0.02500   },
      { 0x0065, "1/50"   , (float)0.02000   },
      { 0x0068, "1/60"   , (float)0.01667   },
      { 0x006b, "1/80"   , (float)0.01250   },
      { 0x006d, "1/100"  , (float)0.01000   },
      { 0x0070, "1/125"  , (float)0.00800   },
      { 0x0073, "1/160"  , (float)0.00625   },
      { 0x0075, "1/200"  , (float)0.00500   },
      { 0x0078, "1/250"  , (float)0.00400   },
      { 0x007b, "1/320"  , (float)0.003125  },
      { 0x007d, "1/400"  , (float)0.00250   },
      { 0x0080, "1/500"  , (float)0.00200   },
      { 0x0083, "1/640"  , (float)0.0015625 },
      { 0x0085, "1/800"  , (float)0.00125   },
      { 0x0088, "1/1000" , (float)0.00100   },
      { 0x008b, "1/1250" , (float)0.00080   },
      { 0x008d, "1/1600" , (float)0.000625  },
      { 0x0090, "1/2000" , (float)0.00050   },
      { 0x0093, "1/2500" , (float)0.00040   },
      { 0x0095, "1/3200" , (float)0.0003125 },
      { 0x0098, "1/4000" , (float)0.00025   },
      { 0x009b, "1/5000" , (float)0.00020   },
      { 0x009d, "1/6400" , (float)0.00015625},
      { 0x00a0, "1/8000" , (float)0.000125  },
      { 0xffff, "auto"   , (float)0.000 },
      { 0x0004, "bulb"   , (float)-1.0  },
      { 0, NULL , (float)0.0 },
};

const struct canonValueStruct canonDriveMode[] =
{
      { 0xff00, "single"     , (float)0.0  },
      { 0xff01, "continuous" , (float)1.0  },
      { 0xff02, "timer"      , (float)2.0  },
      { 0, NULL , (float)0 }
};


const struct canonValueStruct canonValueQuality[] =
{
      { 1 , "RAW"        , (float)0.0  },
      { 1 , "RAW 2"        , (float)0.0  },
      { 1 , "Small Normal JPEG" , (float)0.0  },
      { 1 , "Small Fine JPEG" , (float)0.0  },
      { 1 , "Medium Normal JPEG" , (float)0.0  },
      { 1 , "Medium Fine JPEG" , (float)0.0  },
      { 1 , "Large Normal JPEG" , (float)0.0  },
      { 1 , "Large Fine JPEG" , (float)0.0  },
      { 0, NULL , (float)0 }
};





float canonShutterValueIndexToTime(int shutterIndex) {
   float timeValue = 1; 
   int i = 0; 
   while ( canonShutterValues[i].value != 0 ) {
      if( canonShutterValues[i].value == shutterIndex ) {
         timeValue = canonShutterValues[i].fvalue;
         break;
      }
      i++;
   }
   if( canonShutterValues[i].value == 0 ) {
      timeValue = 1;
   }

   return timeValue;
}

int canonShutterValueTimeToIndex(float timeValue) {
   int shutterIndex = 0; 
   int i = 0; 
   while ( canonShutterValues[i].value != 0 ) {
      if( canonShutterValues[i].fvalue <= timeValue  ) {
         shutterIndex = canonShutterValues[i].value;
         break;
      }
      i++;
   }

   return shutterIndex;
}

float canonShutterValueLabelToTime(char* exposureTimeLabel) {
   float timeValue = 1; 
   int i = 0; 
   while ( canonShutterValues[i].value != 0 ) {
      if( strcmp(canonShutterValues[i].label, exposureTimeLabel) == 0 ) {
         timeValue = canonShutterValues[i].fvalue;
         break;
      }
      i++;
   }

   return timeValue;
}

const char * canonShutterValueTimeToLabel(float timeValue) {
   const char * shutterSpeedLabel = canonShutterValues[0].label; 
   int i = 0; 
   while ( canonShutterValues[i].value != 0 ) {
      if( canonShutterValues[i].fvalue <= timeValue  ) {
         shutterSpeedLabel = canonShutterValues[i].label;
         break;
      }
      i++;
   }

   return shutterSpeedLabel;
}


/**
 * canon_getQualityList 
 *    returns quality list values
 * 
 * Returns value:
 *  0 
 *  
*/
int  canon_getQualityList(char *list)
{
   int i = 0;
   strcpy(list, "");
   while ( canonValueQuality[i].label != NULL ) {
      strcat( list, "{");
      strcat( list, canonValueQuality[i].label);
      strcat( list, "} ");
      i++;
   }

   return 0;
}

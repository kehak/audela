#pragma once

#include "cvisu.h"

class CVisuPool {
      protected:
   char *ClassName;
   int LibererDevices();
   int AjouterDev(CVisu *after, CVisu *visu ,int device_no);

      public:
   CVisu *dev;
   CVisuPool(const char*classname);
   ~CVisuPool();
   CVisu* Ajouter(int device_no, CVisu *visu);
   int RetirerDev(CVisu *visu);
   CVisu* Chercher(int device_no);
   char* GetClassname();
};

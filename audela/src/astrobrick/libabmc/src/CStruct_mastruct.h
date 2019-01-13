#pragma once

#include <vector>
#include <abcommon.h>
using namespace ::abcommon;

#include "abmc.h"
#include "mc.h"


class CStruct_mastruct
{

public:

	// Accessors
   int size(void);
	abmc::mastruct *at(int index);
	void append(abmc::mastruct item);

private:

   std::vector<abmc::mastruct> mastruct_tab;
   
};

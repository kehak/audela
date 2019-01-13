// CCatalog.cpp

#include <stdlib.h> // pour free
#ifdef _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
_CrtMemState startState;
_CrtMemState endState;
_CrtMemState stateDiff;
#endif

#include "CCatalog.h"
#include "AllExceptions.h"


CCatalog::CCatalog(){
   errorCallback = NULL;

#ifdef _CRTDBG_MAP_ALLOC
_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
_crtBreakAlloc = 2789812;
_CrtMemCheckpoint(&startState);
#endif

}

CCatalog::CCatalog( ErrorCallbackType applicationCallback) {
   errorCallback = applicationCallback;

}

void CCatalog::release() {
   delete this;

#ifdef _CRTDBG_MAP_ALLOC
_CrtDumpMemoryLeaks();
_CrtMemCheckpoint(&endState);
_CrtMemDifference(&stateDiff, &startState, &endState);
_CrtMemDumpStatistics(&stateDiff);
_CrtMemDumpAllObjectsSince(&startState);
#endif
}

void CCatalog::throwCallbackError(IAllExceptions &exception) {
   if( errorCallback != NULL) {
      errorCallback(exception.getCode(), exception.getTheMessage());
   } else {
      throw AllExceptions(exception.getCode(), exception.getTheMessage());
   }
}

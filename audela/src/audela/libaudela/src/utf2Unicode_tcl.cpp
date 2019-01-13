#include "utf2Unicode_tcl.h"
#include "string.h"

void utf2Unicode(Tcl_Interp *interp, const char * inString, char * outString) {
   // je convertis les caracteres accentues
   int length;
   Tcl_DString sourceFileName;
   Tcl_DStringInit(&sourceFileName);
   char * stringPtr = (char *) Tcl_GetByteArrayFromObj(Tcl_NewStringObj(inString,strlen(inString)), &length);
   Tcl_ExternalToUtfDString(Tcl_GetEncoding(interp, "identity"), stringPtr, length, &sourceFileName);
   strcpy(outString, sourceFileName.string);
   Tcl_DStringFree(&sourceFileName);
}

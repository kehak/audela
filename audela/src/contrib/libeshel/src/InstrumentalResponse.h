#ifndef _INC_CINSTRUMENTALRESPONSE
#define _INC_CINSTRUMENTALRESPONSE

#include <valarray>
#include <string>
#include <list>

class CKeyword {
public:
   std::string name;
   std::string value;
   std::string comment;
};

class CInstrumentalResponse {
public:
   CInstrumentalResponse(void);
   virtual ~CInstrumentalResponse(void);

   static void makeNullResponse( const char* objectFileName, const char * responseFileName );
   static void makeResponse( const char* genericDatName, int firstOrder , int lastOrder, const char * responseFileName, ::std::list<CKeyword> );

private:
   static void loadDatResponse( const char* datFileName, ::std::valarray<double> &linearProfile, double &lambda1b, double &step);
};

#endif

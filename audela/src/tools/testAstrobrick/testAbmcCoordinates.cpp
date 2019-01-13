#include "stdafx.h"
#include "CppUnitTest.h"
using namespace Microsoft::VisualStudio::CppUnitTestFramework;
#include <abmc.h>
using namespace ::abmc;

namespace testabmc
{		
	TEST_CLASS(abmc_IAngle)
	{
	public:
		
		TEST_METHOD(TestAngleConstructor)
		{
         IAngle* a1 = IAngle_createInstance_from_deg(10);
         Assert::IsNotNull(a1, L"a1 ne doit pas etre NULL"); 
         Assert::AreEqual(10.0, a1->get_deg(0), L"a1 doit etre egal a 10");

		}

	};
}
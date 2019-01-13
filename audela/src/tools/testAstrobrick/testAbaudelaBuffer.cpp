#include "stdafx.h"
#include "CppUnitTest.h"
#include <abaudela.h>
using namespace ::abaudela;


using namespace Microsoft::VisualStudio::CppUnitTestFramework;

namespace testabaudelaBuffer
{		
	TEST_CLASS(abaudela_IBuffer)
	{
	public:
		
		TEST_METHOD(TestBufferConstructor)
		{
         
         IBuffer* buf1 = IBuffer_createInstance();
         Assert::IsNotNull(buf1);

		}

	};
}
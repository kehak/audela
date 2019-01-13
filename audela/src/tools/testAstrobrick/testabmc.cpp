#include "stdafx.h"
#include <memory>       // pour shared_ptr
using namespace std;
#include <abmc.h>
using namespace abmc;

#include "CppUnitTest.h"
using namespace Microsoft::VisualStudio::CppUnitTestFramework;

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

      TEST_METHOD(hip2tel)
      {
         // j'intialise une instance de mc
         shared_ptr<IHome> home(IHome_createInstance(), &IHome_deleteInstance);
         home->set(0.5, Sense::EAST, 42.0, 200);
         IMc* mc1 = IMcPool::createInstance();
         mc1->setHome(*(home.get()));
         mc1->setFixedDate(mc1->getDate());

         // je crée des coordonnees J2000
         shared_ptr<ICoordinates> coord1(mc1->createCoordinates_from_string("3h 2d", Equinox::J2000), &ICoordinates_deleteInstance);
         double ra1 = coord1->getRa(Equinox::J2000);
         double dec1 = coord1->getDec(Equinox::J2000);
         // je crée des coordonnees NOW
         shared_ptr<ICoordinates> coord2(mc1->createCoordinates(), &ICoordinates_deleteInstance);
         double raJ2000, decJ2000;

         for (int i = 0; i < 500; i++) {
            

            coord1->setRaDec(ra1, dec1, Equinox::J2000);

            // je convertis en  NOW
            double raNow = coord1->getRa(Equinox::NOW);
            double decNow = coord1->getDec(Equinox::NOW);

            coord2->setRaDec(raNow, decNow, Equinox::NOW);

            // je convertis en J2000
            raJ2000 = coord2->getRa(Equinox::J2000);
            decJ2000 = coord2->getDec(Equinox::J2000);
         }

         // je verifie que les coordonnnes sont egales aux coordonnées initiales ( avec une tolerance de 1 mas )
         Assert::AreEqual(coord1->getRa(Equinox::J2000), raJ2000, 1. / 360000., L"coord2.ra  doit etre egal a coord1.ra");
         Assert::AreEqual(coord1->getDec(Equinox::J2000), decJ2000, 1. / 360000., L"coord2.dec doit etre egal a coord1.dec");

         mc1->unsetFixedDate();
         IMcPool::deleteInstance(mc1);

      }

	};
}
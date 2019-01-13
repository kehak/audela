#include "stdafx.h"
#include <windows.h>    // pour SetCurrentDirectory

#include <memory>       // pour shared_ptr
#include <functional>
#include <thread>       // pour thread
#include <cstdlib>      // pour mbstowcs 
using namespace ::std;

#include <abaudela.h>
using namespace ::abaudela;
using namespace ::abmc;

#include "CppUnitTest.h"


using namespace Microsoft::VisualStudio::CppUnitTestFramework;



namespace Microsoft{
   namespace VisualStudio    {
      namespace CppUnitTestFramework {
         template<> static std::wstring ToString<ITelescope> (ITelescope* t) { 
            RETURN_WIDE_STRING(t);
         }
      }
   }
}




namespace testAbaudelaTelescope
{		
   static ITelescope* m_tel1;

   TEST_CLASS(abaudela_ITelescope)
	{

	public:

      ///@brief  cree  une instance de telescope qui sert pour les tests des methodes
      TEST_CLASS_INITIALIZE(ClassInitialize)
      {
         try {
            WCHAR currentDir[1024];
            GetCurrentDirectory(1024, (LPWSTR)currentDir);
            SetCurrentDirectory(L"..\\bin");
            const char*  argv[] = { "equat" , "-log_level" , "4" , "-log_file" , "telescope.log"};
            m_tel1 = ITelescope::createInstance(".", "simulator", sizeof(argv) / sizeof(char*), (const char**)&argv);

            //const char*  argv[] = { "ASCOM.Simulator.Telescope", "-log_level" , "4" };
            //m_tel1 = ITelescope::createInstance(".", "ascom", sizeof(argv) / sizeof(char*), (const char**)&argv);

            Assert::IsNotNull(m_tel1, L"createIntance m_tel1 ne doit pas etre null");
            Logger::WriteMessage("abaudela_ITelescope m_tel1 created ");
         }
         catch (IError &ex) {
            Logger::WriteMessage(ex.getMessage());
            wchar_t message[2048];
            size_t nbConverted;
            mbstowcs_s(&nbConverted, message, ex.getMessage(), 2048);
            Assert::Fail(message);
         }
      }

      ///@brief  supprime l'instance de telescope
      TEST_CLASS_CLEANUP(ClassCleanup)
      {
         ITelescope::deleteInstance(m_tel1);
         Logger::WriteMessage("abaudela_ITelescope m_tel1 deleted");
      }

		TEST_METHOD(createInstance)
		{
         const char*  argv[] = { "equat" };
         int argc = sizeof(argv) / sizeof(char*);

         // cas passant : libcamsimulator.dll
         ITelescope* tel2 = ITelescope_createInstance(".", "simulator", argc, (const char**) &argv);
         Assert::IsNotNull(tel2);
         ITelescope_deleteInstance(tel2);

         // test erreur : libcamxxx.dll
         tel2 = ITelescope_createInstance(".", "xxxxx", argc, (const char**)&argv);
         Assert::AreEqual(100, abcommon::getLastErrorCode(), L"error code from create telescope xxx");
         Assert::AreEqual("cannot open .\\libtelxxxxx.dll : lt_dlopen error=Windows Error", abcommon::getLastErrorMessage(), L"error message from create telescope xxx");
		}

      TEST_METHOD(getInstance)
      {
         Assert::AreEqual<ITelescope*>((ITelescope*) m_tel1, ITelescope::getInstance(1),L"getInstance");
      }

      TEST_METHOD(getInstanceNo)
      {
         Assert::AreEqual(1, ITelescope::getInstanceNo(m_tel1), L"le numero du telescope doit etre 1");
      }

      TEST_METHOD(getIntanceNoList)
      {
         shared_ptr<IIntArray> telList(ITelescope::getIntanceNoList() , &abaudela::IArray_deleteInstance);
         //IIntArray* telList = ITelescope::getIntanceNoList();
         Assert::AreEqual(1, telList->size(), L"doit contenir un element");
         Assert::AreEqual(1, telList->at(0), L"le premier element doit etre 1");
         //abcommon::IArray_deleteInstance(telList);
      }


      TEST_METHOD(aligment_get)
      {
         //Assert::AreEqual<int>(Alignment::EQUATORIAL, m_tel1->alignment_get(), L"alignment doit être egal a EQUATORIAL");
      }

      TEST_METHOD(aligment_set)
      {
         m_tel1->alignment_set(Alignment::ALTAZ);
         Assert::AreEqual<int>(Alignment::ALTAZ, m_tel1->alignment_get(), L"alignment doit être egal a ALTAZ");
         m_tel1->alignment_set(Alignment::EQUATORIAL);
         Assert::AreEqual<int>(Alignment::EQUATORIAL, m_tel1->alignment_get(), L"alignment doit être egal a EQUATORIAL");
      }

      TEST_METHOD(date_get)
      {
         shared_ptr<IDate> date(abmc::IDate_createInstance(), &abmc::IDate_deleteInstance);
         m_tel1->date_get(date.get());
         Assert::AreEqual((size_t) 22, strlen( date->get_iso(Frame::TR) ), L"la date au format ISO doit avoir 22 caracteres");
      }

      TEST_METHOD(date_set)
      {
         shared_ptr<IDate> date(abmc::IDate_createInstance(), &abmc::IDate_deleteInstance);

         // cas passant
         date->set("NOW");
         m_tel1->date_set(date.get());
         Assert::AreEqual((size_t)22, strlen(date->get_iso(Frame::TR)), L"la date au format ISO doit avoir 22 caracteres");

         // cas d'erreur date.jd=0 
         try {
            date->set((double)0);
            m_tel1->date_set(date.get());
            Assert::Fail(L"tel1->date_set(0) doit retourner une exception");
         } catch ( IError &ex) {
            Assert::AreEqual((unsigned long)103, ex.getCode(),L"tel1->date_set(0) doit retourner une exception");
            Assert::AreEqual("jd null", ex.getMessage());
         }
         
      }

      TEST_METHOD(foclen_set)
      {
         double foclen = 0.900;
         m_tel1->foclen_set(foclen);
         Assert::AreEqual(foclen, m_tel1->foclen_get(), L"foclen doit être egal a 0.900 m");
      }

      TEST_METHOD(guiding_set)
      {
         m_tel1->radec_guiding_set(true);
         Assert::AreEqual(true, m_tel1->radec_guiding_get(), L"guiding doit être egal a true");
         m_tel1->radec_guiding_set(false);
         Assert::AreEqual(false, m_tel1->radec_guiding_get(), L"guiding doit être egal a false");
      }

      TEST_METHOD(home_get)
      {
         shared_ptr<IHome> home(IHome_createInstance(), &IHome_deleteInstance);
         m_tel1->home_get(home.get());
         Assert::AreEqual(0.1423, home->get_longitude(Frame::TR), 0.0001, L"longitude doit être egal a 0.1423 avec une tolerance de 0.0001");
      }

      TEST_METHOD(home_set)
      {
         shared_ptr<IHome> home(IHome_createInstance(), &IHome_deleteInstance);
         home->set(0.5, Sense::EAST, 42.0, 200);
         m_tel1->home_set(home.get());
         Assert::IsTrue(true, L"pas d'exception apres home_set() ");
      }

      TEST_METHOD(library_name_get)
      {
         Assert::AreEqual("simulator", m_tel1->library_name_get(), L"library name doit être egal a simulator");
      }

      TEST_METHOD(name_get)
      {         
         Assert::AreEqual("simu bleu", m_tel1->name_get(), L"name doit être egal simu bleu");
      }

      TEST_METHOD(port_name_get)
      {
         Assert::AreEqual("equat", m_tel1->port_name_get(), L"port name doit être egal a usb");
      }

      TEST_METHOD(product_get)
      {
         Assert::AreEqual("simu product", m_tel1->product_get(), L"product doit être egal simu product");
      }

      TEST_METHOD(radec_coord_get)
      {
         Assert::AreEqual(0.0, m_tel1->radec_coord_get()->getAngle1().get_deg(0), L"coord.angle1 doit être egal 0°");
      }

      TEST_METHOD(radec_coord_monitor_get)
      {
         Assert::AreEqual(false, m_tel1->radec_coord_monitor_get(), L"radec_coord_monitor doit etre false");
      }

      // callback pour  radec_coord_monitor_start
      static void radecCoordMonitorCallback(void *clientData, ICoordinates* coordinates) {
         int* counter = (int*)clientData;
         (*counter)++;
         Logger::WriteMessage("radecCoordMonitorCallback");
      }

      //static void radecCoordMonitorStop() {
      //   std::this_thread::sleep_for(1200ms);
      //   m_tel1->radec_coord_monitor_stop();
      //}

      TEST_METHOD(radec_coord_monitor_start)
      {
         m_tel1->getLogger()->setLogLevel(ILogger::LOG_DEBUG);
         int counter =0;
         m_tel1->radec_coord_monitor_start(radecCoordMonitorCallback, &counter);
         Assert::AreEqual(true, m_tel1->radec_coord_monitor_get(), L"apres radec_coord_monitor_start()  radec_coord_monitor doit etre true");
         //std::thread stop(radecCoordMonitorStop);
         //stop.join();
         // j'attends un peu plus d'une seconde pour verifier si les coordonnees ont ete mises a jour 1 fois
         std::this_thread::sleep_for(1200ms);
         m_tel1->radec_coord_monitor_stop();
         Assert::AreEqual(false, m_tel1->radec_coord_monitor_get(), L"apres radec_coord_monitor_stop()  radec_coord_monitor doit etre false");
         Assert::AreEqual(1, counter, L"apres radec_coord_monitor_stop() counter");
      }

      TEST_METHOD(refraction_correction_get)
      {
         Assert::AreEqual(false, m_tel1->refraction_correction_get(), L"refraction_correction_get doit etre false");
      }

      TEST_METHOD(radec_init)
      {
         shared_ptr<IHome> home(IHome_createInstance(), &IHome_deleteInstance);
         home->set(0.5, Sense::EAST, 42.0, 200);
         abaudela::getMc()->setHome(*(home.get()));
         abaudela::getMc()->setFixedDate(abaudela::getMc()->getDate());
         
         // j'initialise les coordonnees du telescope
         shared_ptr<ICoordinates> coord1(abaudela::getMc()->createCoordinates_from_string("3h 2d", Equinox::J2000), &ICoordinates_deleteInstance);
         
         // je recupere les coordonnees du telescope
         m_tel1->radec_init(coord1.get(), ITelescope::MountSide::MOUNT_SIDE_AUTO);
         ICoordinates * coord2 = m_tel1->radec_coord_get();

         // je verifie que les coordonnnes sont egales aus coordonnées initiales ( avec une tolerance de 1 mas )
         Assert::AreEqual(coord1->getRa(Equinox::J2000), coord2->getRa(Equinox::J2000), 1./3600., L"coord2.ra  doit etre egal a coord1.ra");
         Assert::AreEqual(coord1->getDec(Equinox::J2000), coord2->getDec(Equinox::J2000), 1./3600., L"coord2.dec doit etre egal a coord1.dec");

         abaudela::getMc()->unsetFixedDate();
      }

      TEST_METHOD(radec_guide_pulse_duration)
      {
         Direction raDirection = Direction::NORTH;
         double raDuration = 100;  //milliseconds
         Direction decDirection = Direction::EAST;
         double decDuration = 200; //milliseconds

         double raRate = 10;
         double decRate = 10;  // arsec/millisec
         m_tel1->radec_guide_rate_set(raRate, decRate);

         // j'initialise les coordonnees du telescope
         shared_ptr<ICoordinates> coord1(abaudela::getMc()->createCoordinates_from_string("0h 0d", Equinox::NOW), &ICoordinates_deleteInstance);
         m_tel1->radec_init(coord1.get(), ITelescope::MountSide::MOUNT_SIDE_AUTO);
         
         m_tel1->radec_guide_pulse_duration(raDirection, raDuration, decDirection, decDuration);

         // j'attends que le mouvement soit terminé 
         while (m_tel1->radec_guide_pulse_moving_get() == true) {
            std::this_thread::sleep_for(10ms);
         }

         ICoordinates* coord2 = m_tel1->radec_coord_get();

         double ra = raDuration*raRate ;
         double dec = decDuration*decRate ;
         // je verfie que les coordonnnes sont egales aux coordonnées initiales
         Assert::AreEqual(ra,  (coord2->getRa(Equinox::NOW)  - coord1->getRa(Equinox::NOW)  ) *3600. *15., 0.0001,  L"coord2.ra  doit etre egal a coord1.ra");
         Assert::AreEqual(dec, (coord2->getDec(Equinox::NOW) - coord1->getDec(Equinox::NOW) ) *3600., L"coord2.dec doit etre egal a coord1.dec");
      }


      TEST_METHOD(radec_guide_pulse_distance)
      {
         Direction raDirection = Direction::NORTH;
         double raDistance = 1000;  //arcsec
         Direction decDirection = Direction::EAST;
         double decDistance = 2000; //arcsec

         double raRate = 10;
         double decRate = 10;  // arsec/millisec
         m_tel1->radec_guide_rate_set(raRate, decRate);

         // j'initialise les coordonnees du telescope
         shared_ptr<ICoordinates> coord1(abaudela::getMc()->createCoordinates_from_string("0h 0d", Equinox::NOW), &ICoordinates_deleteInstance);
         m_tel1->radec_init(coord1.get(), ITelescope::MountSide::MOUNT_SIDE_AUTO);

         m_tel1->radec_guide_pulse_distance(raDirection, raDistance, decDirection, decDistance);

         // j'attends que le mouvement soit terminé 
         while (m_tel1->radec_guide_pulse_moving_get() == true) {
            std::this_thread::sleep_for(10ms);
         }

         ICoordinates* coord2 = m_tel1->radec_coord_get();

         // je verfie que les coordonnnes sont egales aux coordonnées initiales
         Assert::AreEqual(raDistance, (coord2->getRa(Equinox::NOW) - coord1->getRa(Equinox::NOW)) *3600. *15., 0.0001, L"coord2.ra  doit etre egal a coord1.ra");
         Assert::AreEqual(decDistance, (coord2->getDec(Equinox::NOW) - coord1->getDec(Equinox::NOW)) *3600., L"coord2.dec doit etre egal a coord1.dec");
      }



   };

}
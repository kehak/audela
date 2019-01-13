#include "stdafx.h"

#include <windows.h>    // pour SetCurrentDirectory
#include <memory>       // pour shared_ptr
#include <functional>
#include <thread>       // pour thread
#include <mutex>       // pour mutex , unique lock

using namespace ::std;

#include <abaudela.h>
using namespace ::abaudela;
using namespace ::abmc;

#include "CppUnitTest.h"


using namespace Microsoft::VisualStudio::CppUnitTestFramework;



namespace Microsoft{
   namespace VisualStudio    {
      namespace CppUnitTestFramework {
         template<> static std::wstring ToString<ICamera> (ICamera* t) { 
            RETURN_WIDE_STRING(t);
         }
      }
   }
}




namespace testAbaudelaCamera
{		
   static ICamera* m_cam1;

   TEST_CLASS(abaudela_ICamera)
	{

	public:

      ///@brief  cree  une instance de telescope qui sert pour les tests des methodes
      TEST_CLASS_INITIALIZE(ClassInitialize)
      {
         const char*  argv[] = { "usb" , "-log_level" , "4"};
         int argc = sizeof(argv) / sizeof(char*);
         SetCurrentDirectory(L"..\\bin");

         m_cam1 = ICamera::createInstance(".", "simulator", argc, (const char**)&argv);
         Assert::IsNotNull(m_cam1, L"createIntance m_cam1 ne doit pas etre null");
         Logger::WriteMessage("abaudela_ICamera m_cam1 created ");
      }

      ///@brief  supprime l'instance de telescope
      TEST_CLASS_CLEANUP(ClassCleanup)
      {
         ICamera::deleteInstance(m_cam1);
         Logger::WriteMessage("abaudela_ICamera m_cam1 deleted");
      }

		TEST_METHOD(createInstance)
		{
         int argc = 1;
         char arg0[] = "sim2";
         const char*  argv[] = { "sim2" };
         
         // cas passant : libcamsimulator.dll
         ICamera* tel2 = ICamera_createInstance(".", "simulator", argc, (const char**) &argv);
         Assert::IsNotNull(tel2);
         ICamera_deleteInstance(tel2);

         // test erreur : libcamxxx.dll
         tel2 = ICamera_createInstance(".", "xxxxx", argc, (const char**)&argv);
         Assert::IsNull(tel2);
         Assert::AreEqual(100, abcommon::getLastErrorCode(), L"error code from create telescope xxx");
         Assert::AreEqual("cannot open .\\libcamxxxxx.dll : lt_dlopen error=Windows Error", abcommon::getLastErrorMessage(), L"error message from create telescope xxx");
		}

      TEST_METHOD(getInstance)
      {
         Assert::AreEqual<ICamera*>((ICamera*) m_cam1, ICamera::getInstance(1),L"getInstance");
      }

      TEST_METHOD(getInstanceNo)
      {
         Assert::AreEqual(1, ICamera::getInstanceNo(m_cam1), L"le numero de la camera doit etre 1");
      }

      TEST_METHOD(getIntanceNoList)
      {
         shared_ptr<IIntArray> camList(ICamera::getIntanceNoList() , &abaudela::IArray_deleteInstance);
         //IIntArray* telList = ICamera::getIntanceNoList();
         Assert::AreEqual(1, camList->size(), L"doit contenir un element");
         Assert::AreEqual(1, camList->at(0), L"le premier element doit etre 1");
         //abcommon::IArray_deleteInstance(telList);
      }


      static void acqCallback(void *clientData, ICamera::AcquisitionStatus status) {
         condition_variable* acqCv = (condition_variable*)clientData;

         switch (status) {
         case ICamera::AcquisitionStatus::AcquisitionExp:
            Logger::WriteMessage("abaudela_ICamera cameraCallback  AcquisitionExp");
            break;
         case ICamera::AcquisitionStatus::AcquisitionRead:
            Logger::WriteMessage("abaudela_ICamera cameraCallback  AcquisitionRead");
            break;
         case ICamera::AcquisitionStatus::AcquisitionStand:
            Logger::WriteMessage("abaudela_ICamera cameraCallback  AcquisitionStand");
            acqCv->notify_all();
            break;
         }
      }


      TEST_METHOD(acq)
      {
         condition_variable acqCv;

         double exptime = 1;
         m_cam1->setSatusCallback(&acqCv, acqCallback);
         m_cam1->setExptime(exptime);
         m_cam1->acq();

         // j'attends le status AcquisitionStand de fin d'acquisition 
         std::mutex m_acqMutex;
         std::unique_lock<std::mutex> lk(m_acqMutex);
         std::cv_status  status = acqCv.wait_for(lk, std::chrono::milliseconds((long) 1500));
         Assert::AreEqual((int) cv_status::no_timeout, (int)status, L"attente du status AcquisitionStand");

      }    

      TEST_METHOD(setBinning)
      {
         int binx =2;
         int biny =3;
         m_cam1->setBinning(binx, biny);
         m_cam1->getBinning(&binx, &biny);
         Assert::AreEqual(2, binx, L"binx doit etre egal a 2");
         Assert::AreEqual(3, biny, L"biny doit etre egal a 3");
      }

      TEST_METHOD(getBinningMax)
      {
         int binMaxX, binMaxY;
         m_cam1->getBinningMax(&binMaxX, &binMaxY);
         Assert::AreEqual(4, binMaxX, L"binMaxX doit etre egal a 4");
         Assert::AreEqual(5, binMaxY, L"binMaxY doit etre egal a 5");
      }

      TEST_METHOD(setBuffer)
      {
         IBuffer* buf1 = IBuffer::createInstance();
         m_cam1->setBuffer(buf1);
         IBuffer* buf2 = m_cam1->getBuffer();
         Assert::AreEqual(buf1->getNo(), buf2->getNo(), L"getBuffer doit retourner le meme buffer que setBuffer");

      }

      TEST_METHOD(getCcd)
      {
         Assert::AreEqual("Kaf400", m_cam1->getCcd());
      }

      TEST_METHOD(getCellDim)
      {
         double celldimx, celldimy;
         m_cam1->getCellDim(&celldimx, &celldimy);
         Assert::AreEqual(9e-6, celldimx, L"binMaxX doit etre egal a 4");
         Assert::AreEqual(9e-6, celldimy, L"binMaxY doit etre egal a 5");
      }

      TEST_METHOD(getCellNb)
      {
         int cellx, celly;
         m_cam1->getCellNb(&cellx, &celly);
         Assert::AreEqual(768, cellx);
         Assert::AreEqual(512, celly);
      }

      TEST_METHOD(setCooler)
      {
         m_cam1->setCooler(true);
         Assert::AreEqual(true, m_cam1->getCooler());
         m_cam1->setCooler(false);
         Assert::AreEqual(false, m_cam1->getCooler());
      }

      TEST_METHOD(setCoolerCheckTemperature)
      {
         m_cam1->setCoolerCheckTemperature(10.0);
         Assert::AreEqual(-20.0, m_cam1->getCoolerCcdTemperature());
      }

      TEST_METHOD(setDebug)
      {
         m_cam1->setDebug(4);
         Assert::AreEqual(4, m_cam1->getDebug());
         m_cam1->setDebug(1);
         Assert::AreEqual(1, m_cam1->getDebug());
         try {
            m_cam1->setDebug(0);
            Assert::Fail(L"setDebug(0) doit générer une erreur");
         } catch (IError &ex) {
            Assert::AreEqual(103, (int) ex.getCode(), L"setDebug(0) doit générer une erreur");
         }
      }

      TEST_METHOD(getDriverName)
      {
         Assert::AreEqual("simulator", m_cam1->getDriverName());
      }

      TEST_METHOD(setExptime)
      {
         m_cam1->setExptime(10.0);
         Assert::AreEqual(10.0, m_cam1->getExptime());
      }

      TEST_METHOD(getFillFactor)
      {
         Assert::AreEqual(0.9, m_cam1->getFillFactor());
      }

      TEST_METHOD(getGain)
      {
         Assert::AreEqual(11., m_cam1->getGain());
      }

      TEST_METHOD(getLibraryName)
      {
         Assert::AreEqual("simulator", m_cam1->getLibraryName());
      }

      TEST_METHOD(getMaxDyn)
      {
         Assert::AreEqual(65535.0, m_cam1->getMaxDyn());
      }

      TEST_METHOD(setMirrorH)
      {
         m_cam1->setMirrorH(true);
         Assert::AreEqual(true, m_cam1->getMirrorH());
         m_cam1->setMirrorH(false);
         Assert::AreEqual(false, m_cam1->getMirrorH());
      }

      TEST_METHOD(setMirrorV)
      {
         m_cam1->setMirrorV(true);
         Assert::AreEqual(true, m_cam1->getMirrorV());
         m_cam1->setMirrorV(false);
         Assert::AreEqual(false, m_cam1->getMirrorV());
      }

      TEST_METHOD(getCameraName)
      {
         Assert::AreEqual("simulator", m_cam1->getCameraName());
      }

      TEST_METHOD(getPixDim)
      {
         double dimx, dimy;
         m_cam1->setBinning(2, 3);
         m_cam1->getPixDim(&dimx, &dimy);
         Assert::AreEqual(9e-6 * 2, dimx);
         Assert::AreEqual(9e-6 * 3, dimy);
      }

      TEST_METHOD(getPixNb)
      {
         int pixx, pixy;
         m_cam1->setBinning(2, 3);
         m_cam1->getPixNb(&pixx, &pixy);
         Assert::AreEqual(768 / 2, pixx);
         Assert::AreEqual(512 / 3, pixy);
      }

      TEST_METHOD(setOverScan)
      {
         m_cam1->setOverScan(true);
         Assert::AreEqual(true, m_cam1->getOverScan());
         m_cam1->setOverScan(false);
         Assert::AreEqual(false, m_cam1->getOverScan());
      }

      TEST_METHOD(getProduct)
      {
         Assert::AreEqual("camsim", m_cam1->getProduct());
      }

      TEST_METHOD(getPortName)
      {
         Assert::AreEqual("usb", m_cam1->getPortName());
      }

      TEST_METHOD(setRadecFromTel)
      {
         m_cam1->setRadecFromTel(true);
         Assert::AreEqual(true, m_cam1->getRadecFromTel());
         m_cam1->setRadecFromTel(false);
         Assert::AreEqual(false, m_cam1->getRadecFromTel());
      }

      TEST_METHOD(getReadNoise)
      {
         Assert::AreEqual(13., m_cam1->getReadNoise());
      }

      TEST_METHOD(setShutter)
      {
         m_cam1->setShutterClosed();
         Assert::AreEqual((int)ICamera::ShutterMode::ShutterClosed, (int)m_cam1->getShutterMode(), L"doit être fermé");
         m_cam1->setShutterOpened();
         Assert::AreEqual((int)ICamera::ShutterMode::ShutterOpened, (int)m_cam1->getShutterMode(), L"doit être ouvert" );
         m_cam1->setShutterSyncho();
         Assert::AreEqual((int)ICamera::ShutterMode::ShutterSynchro, (int)m_cam1->getShutterMode(), L"doit être syncho");
      }

      TEST_METHOD(setStopMode)
      {
         m_cam1->setStopMode(true);
         Assert::AreEqual(true, m_cam1->getStopMode());
         m_cam1->setStopMode(false);
         Assert::AreEqual(false, m_cam1->getStopMode());
      }

      TEST_METHOD(setTelescope)
      {
         const char*  argv[] = { "equat" , "-param1" , "aa" };
         int argc = sizeof(argv) / sizeof(char*);
         ITelescope* tel1 = ITelescope::createInstance(".","simulator", argc, argv);

         m_cam1->setTelescope(tel1);
         ITelescope* tel2 = m_cam1->getTelescope();
         Assert::AreEqual(tel1->getNo(), tel2->getNo(), L"getTelescope doit retourner le meme telescope");

         m_cam1->setTelescope(NULL);
         ITelescope::deleteInstance(tel1);
      }

      TEST_METHOD(getTimer)
      {
         //TODO
      }

      TEST_METHOD(setWindow)
      {
         int x1=50;
         int y1=10;
         int x2=100;
         int y2=20;
         m_cam1->setWindow(x1, y1, x2, y2);
         int rx1;
         int ry1;
         int rx2;
         int ry2;
         m_cam1->getWindow(&rx1, &ry1, &rx2, &ry2);
         Assert::AreEqual(x1, rx1, L"verfication x1");
         Assert::AreEqual(y1, ry1, L"verfication y1");
         Assert::AreEqual(x2, rx2, L"verfication x2");
         Assert::AreEqual(y2, ry2, L"verfication y2");

      }


      TEST_METHOD(getAvailableCamera)
      {
         try {
            abcommon::IStructArray* availableList = ICamera::getAvailableCamera(".", "libcamsimulator.dll");
            //abcommon::IStructArray* availableList = ICamera::getAvailableCamera(".", "libcamascom.dll");
            Assert::AreEqual(2, availableList->size(), L"libcamsimulator a 2 cameras");
            abcommon::IAvailable* available;
            available = (abcommon::IAvailable*)availableList->at(0);
            Assert::AreEqual("equat", available->getId());
            Assert::AreEqual("Equatorial", available->getName());
            available = (abcommon::IAvailable*)availableList->at(1);
            Assert::AreEqual("altaz", available->getId());
            Assert::AreEqual("Altazimutal", available->getName());
            abaudela::IArray_deleteInstance(availableList);
         }  catch (IError &ex) {
            Logger::WriteMessage(ex.getMessage());
            wchar_t message[2048];
            size_t nbConverted;
            mbstowcs_s(&nbConverted, message, ex.getMessage(), 2048);
            Assert::Fail(message);
         }
      }



   };

}
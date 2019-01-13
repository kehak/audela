///@file tclTelescopeCmd.cpp
//
// This file is part of the AudeLA project : <http://software.audela.free.fr>
// Copyright (C) 1998-2004 The AudeLA Core Team
//
// @author Michel Pujol
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// $Id: $
#include <sstream>  // pour ostringstream
#include <string>
#include <cstring>
#include <memory>
#include <functional>
using namespace ::std;
#include <tcl.h>
#include <abcommon.h>
using namespace ::abcommon;
#include <tclcommon.h>
using namespace ::tclcommon;
#include <abaudela.h>
using namespace ::abaudela;
#include <abmc.h> 
using namespace ::abmc;
#include "tclTel.h"   

typedef struct {
   ITelescope *itel; 
   Tcl_Interp *interp;
   //Tcl_AsyncHandler telStatusAsyncHandle;
   Tcl_AsyncHandler radecCoordMonitorAsyncHandle;
   abmc::ICoordinates*  coordinates;
   std::string callbackTcl;
} TelData;


abmc::Equinox convertCharToEquinox(const char* equinoxChar) {
   Equinox equinox(Equinox::NOW); 
   string equinoxStr;
   utils_strupr(string(equinoxChar), equinoxStr);
   if( equinoxStr.compare("J2000.0")==0 ) {
      equinox=Equinox::J2000;
   }
   return equinox;
}


abaudela::ITelescope::MountSide convertCharToMountSide(char charMountSide) {
   ITelescope::MountSide  mountSide(ITelescope::MountSide::MOUNT_SIDE_AUTO);
   switch (toupper(charMountSide)) {
   case 'A':
      mountSide = ITelescope::MountSide::MOUNT_SIDE_AUTO;
      break;
   case 'E':
      mountSide = ITelescope::MountSide::MOUNT_SIDE_EAST;
      break;
   case 'W':
      mountSide = ITelescope::MountSide::MOUNTSIDE_WEST;
      break;
   default:
      throw CError(CError::ErrorInput, "invalid mount side =%s", charMountSide);
   }
   return mountSide;
}


abmc::Sense convertCharToSense(char charSense) {
   Sense sense(Sense::EAST); 
   switch (toupper(charSense)) {
         case 'E':
            sense=Sense::EAST;
            break;
         case 'W':
            sense=Sense::WEST;
            break;
         default:
            throw CError(CError::ErrorInput, "invalid sense =%s",charSense);
   }
   return sense;
}




abaudela::Alignment convertCharToAlignment(char charAlignmentMode) {
   Alignment alignment(Alignment::EQUATORIAL);
   switch (toupper(charAlignmentMode)) {
   case 'A':
      alignment = Alignment::ALTAZ;
      break;
   case 'E':
      alignment = Alignment::EQUATORIAL;
      break;
   case 'P':
      alignment = Alignment::POLAR;
      break;
   default:
      throw CError(CError::ErrorInput, "invalid alignment =%s", charAlignmentMode);
   }
   return alignment;
}

abaudela::Direction convertCharToDirection(char charDirection) {
   Direction direction(Direction::NORTH);
   switch (toupper(charDirection)) {
   case 'N':
      direction = Direction::NORTH;
      break;
   case 'S':
      direction = Direction::SOUTH;
      break;
   case 'E':
      direction = Direction::EAST;
      break;
   case 'W':
      direction = Direction::WEST;
      break;
   default:
      throw CError(CError::ErrorInput, "invalid direction =%s", charDirection);
   }
   return direction;
}

char convertSenseToChar(Sense sense) {
   if( sense == Sense::EAST) {
      return 'E';
   } else {
      return 'W';
   }
}

//ICoordinates* convertRadecToCoordinates(Tcl_Interp *interp, char *tcllist, abmc::Equinox equinox)
//{
//   const char **listArgv;
//   int listArgc;
//   int result = TCL_OK;
//   if (Tcl_SplitList(interp, tcllist, &listArgc, &listArgv) != TCL_OK) {
//      throw CError(CError::ErrorInput, "Angle struct not valid: must be {angle_ra angle_dec}");
//   } else if (listArgc != 2) {
//      throw CError(CError::ErrorInput, "Angle struct not valid: must be {angle_ra angle_dec}");
//   } 
//   ICoordinates::
//   IAngle* ra = IAngle_createInstance_from_string(listArgv[0]);
//   IAngle* dec = IAngle_createInstance_from_string(listArgv[1]);
//   ICoordinates* coords = ICoordinates_createInstance_from_angle(ra, dec);
//   return  coords;
//}






//=============================================================================
// radecCoordMonitorCallback
//=============================================================================

/// @brief  met a jour les coordonnes dans l'interpreteur TCL
// cette fonction est declenchee par la commande Tcl_AsyncMark dans  radecCoordMonitorCallback()
// Tcl_AsyncMark  appelle radecCoordMonitorAsyncProc  en mode asynchone.  
void radecCoordMonitorCallback(void* clientData, ICoordinates* coordinates) {
   TelData * telData = (TelData *)clientData;
   // je memorise les coordonnées
   telData->coordinates = coordinates;
   // je declenche la procedure asynchone de l'interpreteur TCL
   Tcl_AsyncMark(telData->radecCoordMonitorAsyncHandle);
}


///@brief met a jour les coordonnes dans l'interpreteur TCL
// cette fonction est declenchee par la commande Tcl_AsyncMark dans radecCoordMonitorCallback()
int radecCoordMonitorAsyncProc(ClientData clientData, Tcl_Interp *, int code) {
   TelData * telData = (TelData *) clientData;  
   string ra  = telData->coordinates->getAngle1().getSexagesimal(string("H 03.2"));
   string dec = telData->coordinates->getAngle1().getSexagesimal(string("D 3.2"));
   Tcl_SetVar2(telData->interp, "::audace", "telescope,getra", ra.c_str(), TCL_GLOBAL_ONLY);
   Tcl_SetVar2(telData->interp, "::audace", "telescope,getdec", dec.c_str(), TCL_GLOBAL_ONLY);
   return code;
}


//=============================================================================
// commands 
//=============================================================================

// prototype des procedures de commande 
typedef int (Tel_CmdProc)(TelData* telData, Tcl_Interp *interp, int argc, const char *argv[]);

///@brief get/set foclen du telescope 
int cmdTelAlignment(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try {
      if ((argc != 2) && (argc != 3)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ?ALTAZ|EQUATORIAL|POLAR?", argv[0], argv[1]);
      }

      if (argc == 2) {
         // alignment get
         Alignment alignment = telData->itel->alignment_get();
         if (alignment == Alignment::ALTAZ) {
            Tcl_SetResult(interp, "ALTAZ", TCL_VOLATILE);
         } else if (alignment == Alignment::EQUATORIAL) {
            Tcl_SetResult(interp, "EQUATORIAL", TCL_VOLATILE);
         } else {
            Tcl_SetResult(interp, "POLAR", TCL_VOLATILE);
         }
         result = TCL_OK;

      } else {
         // date_set
         Alignment alignment = convertCharToAlignment(argv[2][0]);
         telData->itel->alignment_set(alignment);
         result = TCL_OK;
      }
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}




///@brief get/set date du telescope 
int cmdTelDate(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try { 
      if((argc!=2)&&(argc!=3)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ?Date?",argv[0],argv[1]);
      } 
      
      if(argc==2) {
         // date_get
         shared_ptr<abmc::IDate> date(abmc::IDate_createInstance(), &abmc::IDate_deleteInstance);
         telData->itel->date_get(date.get() );
         
         // je copie le resultat dans le TCL
         const char* dateIso = date->get_iso(Frame::TR);
         Tcl_SetResult(interp, (char*)dateIso, TCL_VOLATILE );

         // je libere la memoire
         result = TCL_OK;

       } else {
         // date_set
         shared_ptr<abmc::IDate> date(abmc::IDate_createInstance(), abmc::IDate_deleteInstance);
         date->set(argv[2]);
         telData->itel->date_set(date.get());
         // copie le resultat dans le TCL
         const char* dateIso = date->get_iso(Frame::TR);
         Tcl_SetResult(interp, (char*) dateIso ,TCL_VOLATILE );
         result = TCL_OK;
      }
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;		         
   }
   
   
   return result;
}

//@brief nom de la libriairie  du telescope 
int cmdTelDriverName(TelData* telData, Tcl_Interp *interp, int, char *[]) {
   int result;

   try {
      Tcl_SetResult(interp, (char*)telData->itel->library_name_get(), TCL_VOLATILE);
      result = TCL_OK;
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}


///@brief get/set foclen du telescope 
int cmdTelFoclen(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try {
      if ((argc != 2) && (argc != 3)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ?focal_length_(meters)?", argv[0], argv[1]);
      }

      if (argc == 2) {
         // foclen get
         double foclen = telData->itel->foclen_get();
         Tcl_SetObjResult(interp, Tcl_NewDoubleObj(foclen));
         result = TCL_OK;

      } else {
         // date_set
         double foclen = copyArgToDouble(interp, argv[2], "foclen");
         telData->itel->foclen_set(foclen);
         Tcl_SetObjResult(interp, Tcl_NewDoubleObj(foclen));
         result = TCL_OK;
      }
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}


// @TODO verifier si Frame est OK  get_GPS(ABMC_IERS_FRAME_TRF)
//
int cmdTelHome(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try { 
      double longitude,latitude,altitude;
      if((argc!=2)&&(argc!=3)&&(argc!=4)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ?{GPS long e|w lat alt}? ?{-name xxx}",argv[0],argv[1]);
      } 
      
      if(argc==2) {
         abmc::IHome* home = abmc::IHome_createInstance();
         telData->itel->home_get(home);
         Tcl_SetResult(interp,(char*)home->get_GPS(Frame::TR),TCL_VOLATILE);
         abmc::IHome_deleteInstance(home);
         result = TCL_OK;
   
      } else if ( strcmp(argv[2],"name") == 0) {
         if ( argc == 3) {
            // je retourne le nom du site
            Tcl_SetResult(interp,(char*)telData->itel->home_name_get(),TCL_VOLATILE);
            result = TCL_OK;
         } else {
            // je memorise le nom du site
            telData->itel->home_name_set(argv[3]);
            Tcl_ResetResult(interp);
            result = TCL_OK;
         }
            
       } else {
         int homeArgc;
         const char **homeArgv;
      
         if(Tcl_SplitList(interp,argv[2],&homeArgc,&homeArgv)!=TCL_OK) {
            throw CError(CError::ErrorInput, "invalid home %s", argv[2]);
         } 
         if(homeArgc!=5) {
            throw CError(CError::ErrorInput, "invalid home %s . Found %d arguments instead of %d", argv[2], homeArgc, 5);
         } 
         result = TCL_OK;
         longitude = copyArgToDouble(interp, homeArgv[1], "longitude");
         latitude  = copyArgToDouble(interp, homeArgv[3], "latitude");
         altitude  = copyArgToDouble(interp, homeArgv[4], "altitude");
         Tcl_Free((char*)homeArgv);
         Sense sense = convertCharToSense(homeArgv[2][0]);
         abmc::IHome* home = abmc::IHome_createInstance_from_GPS(longitude, sense, latitude, altitude); 
         telData->itel->home_set(home);
         abmc::IHome_deleteInstance(home);
         Tcl_ResetResult(interp);
         result = TCL_OK;
      }
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;		
   }      
   
   return result;
}

///@brief nom du telescope 
int cmdTelName(TelData* telData, Tcl_Interp *interp, int , char *[]) {
   int result;

   try { 
      Tcl_SetResult(interp,(char*) telData->itel->name_get() ,TCL_VOLATILE);
      result = TCL_OK;		         
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;		         
   }
   
   return result;
}


//@brief nom du port du telescope (usb, com1, com2,   ...) 
int cmdTelPort(TelData* telData, Tcl_Interp *interp, int, char *[]) {
   int result;

   try {
      Tcl_SetResult(interp, (char*)telData->itel->port_name_get(), TCL_VOLATILE);
      result = TCL_OK;
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}


///@brief get telescope product name
int cmdTelProduct(TelData* telData, Tcl_Interp *interp, int , char *[]) {
   int result;

   try { 
      Tcl_SetResult(interp,(char*) telData->itel->name_get() ,TCL_VOLATILE);
      result = TCL_OK;		         
   } catch(abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;		         
   }
   
   return result;
}


///@brief commandes des moteurs ra et dec
// TODO traiter le parametre equinox
int cmdTelRadec(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try {
      if ((argc < 3)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ?coord|goto|guiding|init|motor|model|move|pulse|state|stop|survey?", argv[0], argv[1]);
      }
      
      if (strcmp(argv[2], "coord") == 0) {

         // je lis les parametres optionnels
         abmc::Equinox equinox(Equinox::NOW);
         for (int k = 3; k < argc - 2; k++) {
            if (strcmp(argv[k], "-equinox") == 0) {
               // je recupere la valeur de l'equinoxe et je la convertis en majuscule systematiquement
               equinox = convertCharToEquinox(argv[k + 1]);
            }
         }

         ICoordinates* coord = telData->itel->radec_coord_get();
         string charRa  = coord->getAngle1().getSexagesimal(std::string("H 03.2"));
         string charDec = coord->getAngle2().getSexagesimal(std::string("D 3.2"));
         string charCoord = utils_format("{%s} {%s}", charRa.c_str(), charDec.c_str() );
         ICoordinates_deleteInstance(coord);
         Tcl_SetResult(interp, (char*)charCoord.c_str(), TCL_VOLATILE);
         result = TCL_OK;

      } else if (strcmp(argv[2], "goto") == 0) {
         
         if ((argc < 4)) {
            throw CError(CError::ErrorInput, "Usage: %s %s goto {angle_ra angle_dec} ?-rate value? ?-blocking boolean? ?-backlash boolean? ?-equinox Jxxxx.x|now?", argv[0], argv[1]);
         }

         abmc::Equinox equinox(Equinox::NOW);
         bool blocking = false;
         bool backlash = false;

         for (int k = 4; k <= argc - 1; k++) {
            if (strcmp(argv[k], "-rate") == 0) {
               double gotoRate = copyArgToDouble(interp, argv[k + 1], "rate");
               telData->itel->radec_goto_rate_set(gotoRate);

            }
            if (strcmp(argv[k], "-blocking") == 0) {
               blocking = copyArgToBoolean(interp, argv[k + 1], "blocking");
            }
            if (strcmp(argv[k], "-backlash") == 0) {
               backlash = copyArgToBoolean(interp, argv[k + 1], "backlash");
            }
            if (strcmp(argv[k], "-equinox") == 0) {
               // je recupere la valeur de l'equinoxe et je la convertis en majuscule systematiquement
               equinox = convertCharToEquinox(argv[k + 1]);
            }
         }

         // je recupere les coordonnees de la cible 
         ICoordinates* coords = abaudela::getMc()->createCoordinates_from_string(argv[3], equinox);

         telData->itel->radec_goto(coords, blocking, backlash);
         Tcl_ResetResult(interp);
         result = TCL_OK;

      } else if (strcmp(argv[2], "guiding") == 0) {
         // --- survey --
         // recupere les coordonnées J2000.0 toutes les secondes et les copie dans les 
         // variables globales audace(telescope,getra) et audace(telescope,getdec) 
         // du thread principal
         if (argc >= 4) {
            bool guiding = tclcommon::copyArgToBoolean(interp, argv[3], "guiding");
            telData->itel->radec_guiding_set(guiding);
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(guiding));
            result = TCL_OK;
         } else {
            // je retourne l'état "0" ou "1" dans le resultat de la commande
            bool guiding = telData->itel->radec_guiding_get();
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(guiding));
            result = TCL_OK;
         }

      } else if (strcmp(argv[2], "init") == 0) {
         // --- survey --
         // je lis les parametres optionnels
         abmc::Equinox equinox(Equinox::NOW);
         ITelescope::MountSide mountSide(ITelescope::MountSide::MOUNT_SIDE_AUTO);
         for (int k = 3; k < argc - 2; k++) {
            if (strcmp(argv[k], "-equinox") == 0) {
               equinox = convertCharToEquinox(argv[k + 1]);
            }
            if (strcmp(argv[k], "-mountside") == 0) {
               mountSide = convertCharToMountSide(argv[k + 1][0]);
            }
         }

         // je recupere les coordonnees de la cible 
         shared_ptr<ICoordinates>  coords(abaudela::getMc()->createCoordinates_from_string(argv[3], equinox), ICoordinates_deleteInstance);
         telData->itel->radec_init(coords.get(), mountSide);
         Tcl_ResetResult(interp);
         result = TCL_OK;

      
      } else if (strcmp(argv[2], "model") == 0) {
         /* --- model ---*/
         if (argc >= 5) {
            Tcl_ResetResult(interp);
            result = TCL_OK;
            for (int k = 3; k <= argc - 1; k++) {
               //if (strcmp(argv[k],"-coefficients")==0) {
               //   if ( strlen(argv[k+1]) < sizeof(tel->radec_model_coefficients) ) {
               //      strcpy(tel->radec_model_coefficients, argv[k+1]);
               //   } else {
               //      sprintf(ligne,"error: value length>%d for %s %s",
               //         sizeof(tel->radec_model_symbols), argv[k], argv[k+1]);
               //      Tcl_AppendResult(interp, ligne, NULL);
               //      result = TCL_ERROR;
               //   }
               //}
               if (strcmp(argv[k], "-enabled") == 0) {
                  bool enabled = copyArgToBoolean(interp, argv[k + 1], "-enabled");
                  telData->itel->radec_model_enabled_set(enabled);
                  Tcl_ResetResult(interp);
                  result = TCL_OK;
               }
               //if (strcmp(argv[k],"-name")==0) {
               //   if ( strlen(argv[k+1]) < sizeof(tel->radec_model_name) ) {
               //      strcpy(tel->radec_model_name, argv[k+1]);
               //   } else {
               //      sprintf(ligne,"error: value length>%d for %s %s",
               //         sizeof(tel->radec_model_name), argv[k], argv[k+1]);
               //      Tcl_AppendResult(interp, ligne, NULL);
               //      result = TCL_ERROR;
               //   }
               //}
               //if (strcmp(argv[k],"-date")==0) {
               //   if ( strlen(argv[k+1]) < sizeof(tel->radec_model_date) ) {
               //      strcpy(tel->radec_model_date, argv[k+1]);
               //   } else {
               //      sprintf(ligne,"error: value length>%d for %s %s",
               //         sizeof(tel->radec_model_date), argv[k], argv[k+1]);
               //      Tcl_AppendResult(interp, ligne, NULL);
               //      result = TCL_ERROR;
               //   }
               //}
               //if (strcmp(argv[k],"-pressure")==0) {
               //   tel->radec_model_pressure =atoi(argv[k+1]);
               //}
               //if (strcmp(argv[k],"-symbols")==0) {
               //   if ( strlen(argv[k+1]) < sizeof(tel->radec_model_symbols) ) {
               //      strcpy(tel->radec_model_symbols, argv[k+1]);
               //   } else {
               //      sprintf(ligne,"error: value length>%d for %s %s",
               //         sizeof(tel->radec_model_symbols), argv[k], argv[k+1]);
               //      Tcl_AppendResult(interp, ligne, NULL);
               //      result = TCL_ERROR;
               //   }
               //}
               //if (strcmp(argv[k],"-temperature")==0) {
               //   tel->radec_model_temperature =atoi(argv[k+1]);
               //}
            }

         } else if (argc == 4) {
            // je retourne les valeurs des parametres
            if (strcmp(argv[3], "-enabled") == 0) {
               bool enabled = telData->itel->radec_model_enabled_get();
               Tcl_SetObjResult(interp, Tcl_NewBooleanObj(enabled));
               result = TCL_OK;
               //} else if (strcmp(argv[3],"-coefficients")==0) {
               //   Tcl_SetResult(interp,tel->radec_model_coefficients,TCL_VOLATILE);  
               //   result =  TCL_OK;
               //} else if (strcmp(argv[3],"-name")==0) {
               //   Tcl_SetResult(interp,tel->radec_model_name,TCL_VOLATILE);  
               //   result =  TCL_OK;
               //} else if (strcmp(argv[3],"-date")==0) {
               //   Tcl_SetResult(interp,tel->radec_model_date,TCL_VOLATILE);  
               //   result =  TCL_OK;
               //} else if (strcmp(argv[3],"-pressure")==0) {
               //   sprintf(ligne,"%d",tel->radec_model_pressure);
               //   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
               //   result =  TCL_OK;
               //} else if ( strcmp(argv[3],"-symbols")==0) {
               //   Tcl_SetResult(interp,tel->radec_model_symbols,TCL_VOLATILE); 
               //   result =  TCL_OK;
               //} else if (strcmp(argv[3],"-temperature")==0) {
               //   sprintf(ligne,"%d",tel->radec_model_temperature);
               //   result =  TCL_OK;
               //   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
            } else {
               throw CError(CError::ErrorInput, "Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?", argv[0], argv[1]);
            }

         } else {
            throw CError(CError::ErrorInput, "Usage: %s %s model -enabled 0|1 -name ?value? -date ?value? -symbols {IH ID ... } -coefficients ?values? -temperature ?value? -pressure ?value?", argv[0], argv[1]);
         }

      } else if (strcmp(argv[2], "motor") == 0) {
         if (argc < 3) {
            throw CError(CError::ErrorInput, "Usage: %s %s motor on|off", argv[0], argv[1]);
         }
         
         if (argc >= 4) {
            bool radecMotor = true;
            if ((strcmp(argv[3], "off") == 0) || (strcmp(argv[3], "0") == 0)) {
               radecMotor = false;
            }
            telData->itel->radec_tracking_set(radecMotor);
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(radecMotor));
            result = TCL_OK;
         } else {
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(telData->itel->radec_tracking_get() ));
            result = TCL_OK;
         }

      } else if (strcmp(argv[2], "move") == 0) {
         /* --- move ---*/
         if (argc < 4) {
            throw CError(CError::ErrorInput, "Usage: %s %s move n|s|e|w ?rate?", argv[0], argv[1]);
         }
         Direction direction = convertCharToDirection(argv[3][0]);
         double radec_move_rate = 0;
         if (argc >= 5) {
            radec_move_rate = copyArgToDouble(interp, argv[4], "rate");
         }
         telData->itel->radec_move_start(direction, radec_move_rate);
         Tcl_ResetResult(interp);
         result = TCL_OK;
         
      } else if (strcmp(argv[2], "pulse") == 0) {
         /* --- move ---*/
         const char * usage = "Usage: %s %s %s { duration  e|w raDuration(ms) n|s decDuration(ms) } | { distance e|w raDistance(arsec) n|s decDistance(arsec) } | { rate value(arsec/s) }";
         if (argc != 5 && argc != 8) {
            throw CError(CError::ErrorInput, usage, argv[0], argv[1], argv[2]);
         }

         if (argc == 4 && strcmp(argv[3], "rate") == 0) {
            // je retourne la vitesse de impulsions
            double raRate;
            double decRate;
            telData->itel->radec_guide_rate_get(&raRate, &decRate);
            std::stringstream line;
            line << raRate << " " << decRate;
            Tcl_SetResult(interp, (char*)line.str().c_str(), TCL_VOLATILE);
            result = TCL_OK;

         } else if (argc == 6 && strcmp(argv[3], "rate") == 0) {
            // je configure la vitesse de impulsions
            double raRate = copyArgToDouble(interp, argv[4], "raRate");
            double decRate = copyArgToDouble(interp, argv[5], "decRate");
            telData->itel->radec_guide_rate_set(raRate, decRate);
            Tcl_ResetResult(interp);
            result = TCL_OK;

         } else if (argc == 8 && strcmp(argv[3], "duration") == 0) {
            Direction raDirection = convertCharToDirection(argv[4][0]);
            double raDuration = copyArgToDouble(interp, argv[5], "raDuration");
            Direction decDirection = convertCharToDirection(argv[6][0]);
            double decDuration = copyArgToDouble(interp, argv[7], "decDuration");

            telData->itel->radec_guide_pulse_duration(raDirection, raDuration, decDirection, decDuration );

            // j'attends que le telescope ait fini de bouger
            while (telData->itel->radec_guide_pulse_moving_get() == true) {
               Tcl_DoOneEvent(TCL_ALL_EVENTS);
            }
            
            Tcl_ResetResult(interp);
            result = TCL_OK;

         } else if (argc == 8 && strcmp(argv[3], "distance") == 0) {
            Direction raDirection = convertCharToDirection(argv[4][0]);
            double raDistance = copyArgToDouble(interp, argv[5], "raDistance");
            Direction decDirection = convertCharToDirection(argv[6][0]);
            double decDistance = copyArgToDouble(interp, argv[7], "decDistance");

            telData->itel->radec_guide_pulse_distance(raDirection, raDistance, decDirection, decDistance);
            Tcl_ResetResult(interp);
            result = TCL_OK;

         } else {
            throw CError(CError::ErrorInput, usage, argv[0], argv[1], argv[2]);
         }


      } else if (strcmp(argv[2], "stop") == 0) {

         Direction direction = Direction::ALL;
         if (argc >= 4) {
            direction = convertCharToDirection(argv[3][0]);
         } 
         telData->itel->radec_move_stop(direction);
         Tcl_ResetResult(interp);
         result = TCL_OK;

      } else if (strcmp(argv[2], "survey") == 0) {
         // --- survey --
         // recupere les coordonnées J2000.0 toutes les secondes et les copie dans les 
         // variables globales audace(telescope,getra) et audace(telescope,getdec) 
         // du thread principal
         if (argc >= 4) {
            bool state = tclcommon::copyArgToBoolean(interp, argv[3], "surveyState");
            if (state) {
               telData->itel->radec_coord_monitor_start(radecCoordMonitorCallback, telData);
            } else {
               telData->itel->radec_coord_monitor_stop();
            }
            Tcl_SetResult(interp, argv[3], TCL_VOLATILE);
            result = TCL_OK;
         } else {
            // je retourne l'état "0" ou "1" dans le resultat de la commande
            bool state = telData->itel->radec_coord_monitor_get();
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(state));
            result = TCL_OK;
         }
      } else {
         throw CError(CError::ErrorInput, "Command %s not found", argv[2]);
      }
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}

///@brief has refraction correction
int cmdTelRefraction(TelData* telData, Tcl_Interp *interp, int, char *[]) {
   int result;

   try {
      Tcl_SetObjResult(interp, Tcl_NewBooleanObj(telData->itel->refraction_correction_get()));
      result = TCL_OK;
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}

/*
///@brief manage focuser
int cmdTelFocus(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try {

      if ((argc < 3)) {
         throw CError(CError::ErrorInput, "Usage: %s %s ? goto | stop | move | coord | motor | init ? ? options ?", argv[0], argv[1]);
      }

      if (strcmp(argv[2], "init") == 0) {
         if (argc >= 3) {
            double position = copyArgToDouble(interp, argv[2], "position");
            telData->itel->focus_init(position);
            Tcl_SetObjResult(interp, Tcl_NewDoubleObj(position));
            result = TCL_OK;
         } else {
            throw CError(CError::ErrorInput, "Usage: %s %s init number", argv[0], argv[1]);
         }
      } else if (strcmp(argv[2], "coord") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewDoubleObj(telData->itel->focus_coord()));
         result = TCL_OK;
      } else if (strcmp(argv[2], "goto") == 0) {
         if (argc >= 3) {
            if (argc >= 5) {
               for (int k = 4; k <= argc - 1; k++) {
                  if (strcmp(argv[k], "-rate") == 0) {
                     double rate = copyArgToDouble(interp, argv[k + 1], "rate");
                     telData->itel->focus_rate_set(rate);
                  } else if (strcmp(argv[k], "-blocking") == 0) {
                     boolean blocking = copyArgToBoolean(interp, argv[k + 1], "blocking");
                     telData->itel->focus_blocking_set(blocking);
                  }
               }
            }
            double position = copyArgToDouble(interp, argv[2], "position");
            telData->itel->focus_goto(position);
            Tcl_SetObjResult(interp, Tcl_NewDoubleObj(position));
            result = TCL_OK;
         } else if (strcmp(argv[2], "move") == 0) {
            if (argc >= 4) {
               if (argc >= 5) {
                  double rate = copyArgToDouble(interp, argv[4], "rate");
                  telData->itel->focus_rate_set(rate);
               }
               if (strcmp(argv[3], "+")) {
                  telData->itel->focus_move(true);
               } else {
                  telData->itel->focus_move(false);
               }
               Tcl_ResetResult(interp);
               result = TCL_OK;
            } else {
               throw CError(CError::ErrorInput, "Usage: %s %s move +|- ?rate?", argv[0], argv[1]);
            }
         } else {
            throw CError(CError::ErrorInput, "Usage: %s %s goto position ?-rate value? ?-blocking boolean?", argv[0], argv[1]);
         }
         result = TCL_OK;
      } else if (strcmp(argv[2], "stop") == 0) {
         telData->itel->focus_stop();
         Tcl_ResetResult(interp);
         result = TCL_OK;

      } else if (strcmp(argv[2], "motor") == 0) {
         if (argc >= 4) {
            if ((strcmp(argv[3], "off") == 0) || (strcmp(argv[3], "0") == 0)) {
               telData->itel->focus_motor_set(false);
               Tcl_ResetResult(interp);
               result = TCL_OK;
            } if ((strcmp(argv[3], "on") == 0) || (strcmp(argv[3], "1") == 0)) {
               telData->itel->focus_motor_set(true);
               Tcl_ResetResult(interp);
               result = TCL_OK;
            } else {
               throw CError(CError::ErrorInput, "Usage: %s %s motor on|off", argv[0], argv[1]);
            }
         } else {
            Tcl_SetObjResult(interp, Tcl_NewBooleanObj(telData->itel->focus_motor_get()));
            result = TCL_OK;
         }
      } else {
         throw CError(CError::ErrorInput, "Usage: %s %s ? goto | stop | move | coord | motor | init ? ? options ?", argv[0], argv[1]);
      }
   } catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}
*/

///@brief get/set move speed
int cmdTelSpeed(TelData* telData, Tcl_Interp *interp, int argc, char *argv[]) {
   int result;

   try {
      if (argc >= 3) {
         double speed = 1; 

         if (strcmp(argv[2], "guide") == 0) {
            speed = 0.25;
            Tcl_SetResult(interp, argv[2], TCL_VOLATILE);
         } else if (strcmp(argv[2], "center") == 0) {
            speed = 0.5;
            Tcl_SetResult(interp, argv[2], TCL_VOLATILE);
         } else if (strcmp(argv[2], "find") == 0) {
            speed = 0.75;
            Tcl_SetResult(interp, argv[2], TCL_VOLATILE);
         } else {
            speed = 1.;
            Tcl_SetResult(interp, "slew", TCL_VOLATILE);
         }
         telData->itel->radec_goto_rate_set(speed);
         result = TCL_OK;
      } else {
         double speed = telData->itel->radec_goto_rate_get();
         
         if (speed <= 0.25) {
            Tcl_SetResult(interp, "guide", TCL_VOLATILE);
         } else if (speed <= 0.5) {
            Tcl_SetResult(interp, "center", TCL_VOLATILE);
         } else if (speed <= 0.75) {
            Tcl_SetResult(interp, "find", TCL_VOLATILE);
         } else {
            Tcl_SetResult(interp, "slew", TCL_VOLATILE);
         }
         result = TCL_OK;
      }
   }
   catch (abcommon::IError& e) {
      // je copie le message d'erreur dans le resultat TCL
      Tcl_SetResult(interp, (char*)e.getMessage(), TCL_VOLATILE);
      result = TCL_ERROR;
   }

   return result;
}


//=============================================================================
// commands list
//=============================================================================
struct cmditem {
    const char *cmd;
    Tel_CmdProc *func;
};

///@brief liste des commandes TCL du telescope associées aux fonctions C 
static struct cmditem commonCmdList[] = {
   { "alignmentmode" , (Tel_CmdProc*) cmdTelAlignment },
   { "date"          , (Tel_CmdProc*) cmdTelDate },
   { "drivername"    , (Tel_CmdProc*) cmdTelDriverName },
   { "foclen"        , (Tel_CmdProc*) cmdTelFoclen },
   //{ "focus"         , (Tel_CmdProc*) cmdTelFocus },
   { "home"          , (Tel_CmdProc*) cmdTelHome },
   { "name"          , (Tel_CmdProc*) cmdTelName },
   { "port"          , (Tel_CmdProc*) cmdTelPort },
   { "product"       , (Tel_CmdProc*) cmdTelProduct },
   { "radec"         , (Tel_CmdProc*) cmdTelRadec },
   { "refraction"    , (Tel_CmdProc*) cmdTelRefraction },
   { "speed"         , (Tel_CmdProc*) cmdTelSpeed },
   // === Last function terminated by NULL pointers ===
   {NULL, NULL}
};

#define libtel_log telData->itel->getLogger()->log 

///@brief point d'entrée unique des commandes TCL du telescope
//
//  execute une commande qui peut être 
//    - une commande generique 
//    - une commande specifique C
//    - une commande specifique TCL 
// 
int tclTelescopeCmd(TelData* telData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[1024], ss[50];
   int retour = TCL_OK, k, i;

   if (argc == 1) {
     sprintf(s, "%s choose sub-command among ", argv[0]);
      k = 0;
      while (commonCmdList[k].cmd != NULL) {
         sprintf(ss, " %s", commonCmdList[k].cmd);
         strcat(s, ss);
         k++;
      }
      Tcl_SetResult(interp, s, TCL_VOLATILE);
      retour = TCL_ERROR;
   } else {

      // je trace les parametres si le niveau LOG_DEBUG est active
      if (telData->itel->getLogger()->getLogLevel() <= ILogger::LOG_DEBUG ) {
         char s1[1024], *s2;
         s2 = s1;
         s2 += sprintf(s2,"Enter cmdTel argc=%d", argc);
         for (i = 0; i < argc; i++) {
            s2 += sprintf(s2, ",argv[%d]=%s", i, argv[i]);
         }
         s2 += sprintf(s2, ")");
         libtel_log(ILogger::LOG_DEBUG, "%s", s1);
      }

      // commande TCL generique 
      struct cmditem *genericCmd;
      for (genericCmd = commonCmdList; genericCmd->cmd != NULL; genericCmd++) {
         if (strcmp(genericCmd->cmd, argv[1]) == 0) {
            retour = (*genericCmd->func) (telData, interp, argc, argv);
            break;
         }
      }

      // j'execute la  command specifique C
      int specificCommandResult = 1;
      if (genericCmd->cmd == NULL) {
         char * result; 
         specificCommandResult = telData->itel->executeSpecificCommand(argc, argv, &result);
         if (specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_OK;
            telData->itel->freeSpecificCommandResult(result);
         } else if( specificCommandResult == 0) {
            Tcl_SetResult(interp, result, TCL_VOLATILE);
            retour = TCL_ERROR;
            telData->itel->freeSpecificCommandResult(result);
         }
      }

      // j'execute la  command specifique TCL
      int specificTclCommandResult = 1;
      if (genericCmd->cmd == NULL && specificCommandResult== -1) {
         specificTclCommandResult = telData->itel->executeTclSpecificCommand(interp, argc, argv);
         if( specificTclCommandResult == -1 ) {
            retour = TCL_ERROR;
         } else {
            retour = specificTclCommandResult;
         }
      }

      // je trace la fin d'execution de la commande si LOG_DEBUG
      libtel_log(ILogger::LOG_DEBUG, "EXIT cmdTel result=%s", Tcl_GetStringResult(interp) );

      // je trace une erreur si la commande n'a pas ete trouvee
      if (genericCmd->cmd == NULL && specificCommandResult == -1 && specificTclCommandResult == -1) {
         sprintf(s, "%s %s : sub-command not found among ", argv[0], argv[1]);
         k = 0;
         while (commonCmdList[k].cmd != NULL) {
            sprintf(ss, " %s", commonCmdList[k].cmd);
            strcat(s, ss);
            k++;
         }
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         retour = TCL_ERROR;
      }
   }
   return retour;
}




//=============================================================================
// gestion du pool des Telescopes
//=============================================================================

///@brief cree une instance Telescope
// implemente la commande ::tel::create
//
// @param clientData  not used
// @param argc argument number => 2
// @param argv 
//    - argv[0] = ::tel::create
//    - argv[1] = libray short name. Exemple: "lx200"  for library "libtellx200.dll"
//    - argv[n] = specifics parameters
//   
//
// @return telNo
//
int tclTelescopeCreate(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s library ", argv[0]);
      } 
     
      // je recupere le nom du repertoire des librairies
      auto_ptr<string> libraryPath = tclcommon::getLibraryPath(interp);
   
      // je cree l'instance C++ en passant les parametres arg[2] ... argv[n]
      ITelescope* itel = abaudela::ITelescope::createInstance(libraryPath->c_str(), argv[1], argc-2, &argv[2]);

      // je cree l'instance TelData
      TelData * telData = new TelData();
      telData->itel    = itel;
      telData->interp  = interp;

      // je cree la commande TCL
      int telNo = itel->getNo();
      std::ostringstream instanceName ;
      instanceName << "tel" << telNo;
      Tcl_CreateCommand(interp, instanceName.str().c_str(), (Tcl_CmdProc *)tclTelescopeCmd, (ClientData) telData,(Tcl_CmdDeleteProc *)NULL);

      // j'intialise le handle pour mettre a jour le status dans les interpreteurs TCL en mode asynchone
      telData->radecCoordMonitorAsyncHandle = Tcl_AsyncCreate(radecCoordMonitorAsyncProc, telData);

      // je retourne telNo
      Tcl_SetObjResult(interp, Tcl_NewIntObj(telNo));
      result = TCL_OK; 
   } catch(IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}

///@brief supprime un telescope
// implemente la commande ::tel::delete
// 
// @param clientData  TelData* 
// @param argc argument number = 2
// @param argv 
//    - arvv[0] = ::tel::delete
//    - argv[1] = telNo
//
int tclTelescopeDelete(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 2) {
         throw CError(CError::ErrorInput, "Usage: %s telNo", argv[0]);
      } 

      // je recupere le nom de la commande 
      int telNo = copyArgToInt(interp, argv[1], "telNo");
      std::string commandName = "tel"+ std::to_string(telNo);

      // je recupere telData 
      Tcl_CmdInfo cmdInfo;
      result = Tcl_GetCommandInfo(interp, commandName.c_str(), &cmdInfo);
      if (result == 0) {
         throw CError(CError::ErrorGeneric, "tclTelescopeDelete: Tcl_GetCommandInfo: %s not found" , commandName.c_str());
      }
      TelData * telData = (TelData*)cmdInfo.clientData;

      // je supprime le handle asynchone
      Tcl_AsyncDelete(telData->radecCoordMonitorAsyncHandle);

      // je supprime la commande TCL
      Tcl_DeleteCommand(interp, commandName.c_str());

      // je supprime l'instance C++
      abaudela::ITelescope* tel = abaudela::ITelescope::getInstance(telNo);
      abaudela::ITelescope::deleteInstance(tel);

      // je supprime la structure TelData
      delete telData;

      Tcl_ResetResult(interp);
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}


///@brief liste des telNo
//
// @param clientData  not used
// @param argc argument number = 1
// @param argv 
//    - arvv[0] = ::tel::list
//
// @return list of telNo
//
int tclTelescopeList(ClientData , Tcl_Interp *interp, int argc, const char *argv[]) {
   int result;

   try {
      if(argc < 1) {
         throw CError(CError::ErrorInput, "Usage: %s", argv[0]);
      } 
      abcommon::IIntArray* instanceNoList = abaudela::ITelescope::getIntanceNoList();
      Tcl_Obj *  listObj = Tcl_NewListObj( 0, NULL );
      for(int i=0; i< instanceNoList->size(); i++ ) {
         Tcl_ListObjAppendList(interp, listObj, Tcl_NewIntObj(instanceNoList->at(i)) );
      }
      Tcl_SetObjResult(interp, listObj );
      result = TCL_OK;
   } catch(abcommon::IError &e ) {
      Tcl_SetResult(interp,(char*)e.getMessage(),TCL_VOLATILE);
      result = TCL_ERROR;
   }
  
   return result;
}



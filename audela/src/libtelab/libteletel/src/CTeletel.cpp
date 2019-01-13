/* 
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
 
 // $Id:  $
 
#include "sysexp.h"

#include <exception>
#include <stdio.h>      // sprintf
#include <exception>
#include <string>
using namespace std;


#include <libtelab/libtel.h>
#include <libtelab/libtelcommon.h>
#include <abmc.h>
using namespace abmc;

#include "CTeletel.h"


/// @ brief  create instance (main enty point of libetletel )
//
libtel::ILibtel* libtel::createTelescopeInstance(int argc, const char *argv[])  {
   return CLibtelCommon::createTelescopeInstance (new CTeletel(), argc, argv);
};

struct_etel_type CTeletel::m_typs[] = {
   //int 32
   { "X", DMD_TYP_USER_INT32,  ETEL_VAL_INT32 },
   { "K", DMD_TYP_PPK_INT32,  ETEL_VAL_INT32 },
   { "M", DMD_TYP_MONITOR_INT32,  ETEL_VAL_INT32 },
   { "C", DMD_TYP_COMMON_INT32,  ETEL_VAL_INT32 },
   { "P", DMD_TYP_MAPPING_INT32,  ETEL_VAL_INT32 },
   // double
   { "XL", DMD_TYP_USER_INT64,  ETEL_VAL_INT64 },
   { "KL", DMD_TYP_PPK_INT64,  ETEL_VAL_INT64 },
   { "ML", DMD_TYP_MONITOR_INT64,  ETEL_VAL_INT64 },
   { "CL", DMD_TYP_COMMON_INT64,  ETEL_VAL_INT64 },
   { "EL", DMD_TYP_TRIGGER_INT64,  ETEL_VAL_INT64 },
   //float
   { "XF", DMD_TYP_USER_FLOAT32,  ETEL_VAL_FLOAT32 },
   { "KF", DMD_TYP_PPK_FLOAT32,  ETEL_VAL_FLOAT32 },
   { "MF", DMD_TYP_MONITOR_FLOAT32,  ETEL_VAL_FLOAT32 },
   { "CF", DMD_TYP_COMMON_FLOAT32,  ETEL_VAL_FLOAT32 },
   // double
   { "XD", DMD_TYP_USER_FLOAT64,  ETEL_VAL_FLOAT64 },
   { "KD", DMD_TYP_USER_FLOAT64,  ETEL_VAL_FLOAT64 },
   { "MD", DMD_TYP_USER_FLOAT64,  ETEL_VAL_FLOAT64 },
   { "CD", DMD_TYP_COMMON_FLOAT64,  ETEL_VAL_FLOAT64 },
   { "LD", DMD_TYP_LKT_FLOAT64,  ETEL_VAL_FLOAT64 },
};


/// @ brief  init device
//
void CTeletel::init(int argc, const char *argv[])
{  
   m_etel_driver = "DSTEB3";

   // je recupere les parametres specifiques
   int kkk = 0;
   for (int kk = 3; kk < argc - 1; kk++) {
      if (strcmp(argv[kk], "-driver") == 0) {
         m_etel_driver = argv[kk + 1];
      }
      if (strcmp(argv[kk], "-axis") == 0) {
         if (kkk<ETEL_NAXIS_MAXI) {
            m_axis[kkk] = AxisState::TO_BE_OPENED;
            m_axisno[kkk] = atoi(argv[kk + 1]);
            kkk++;
         } else {
            throw CError(CError::ErrorInput, "too many -axis  ");
         }
      }
   }

   // --- boucle de creation des axes ---
   for (int k = 0; k<ETEL_NAXIS_MAXI; k++) {
      if (m_axis[k] != AxisState::TO_BE_OPENED) {
         continue;
      }
      m_drv[k] = NULL;
      int err = 0;
      // --- create drive
      if (err = dsa_create_drive(&m_drv[k])) {
         std::string msg;
         throw CError(CError::ErrorInput, "Error axis=%d dsa_create_drive %s", k, getError(k, err, msg));
      }
      std::string ss = abcommon::utils_format("etb:%s:%d", m_etel_driver.c_str() , m_axisno[k]);
      if (err = dsa_open_u(m_drv[k], ss.c_str() )) {
         std::string msg;
         throw CError(CError::ErrorInput, "Error axis=%d dsa_open_u(%s) %s", m_axisno[k], ss, getError(k, err, msg));
      }
      /* Reset error */
      /*
      if (err = dsa_reset_error_s(etel.drv[k], 1000)) {
      sprintf(s,"Error axis=%d dsa_reset_error_s error=%d",k,err);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
      }
      */
      /* power on */
      /*
      if (err = dsa_power_on_s(etel.drv[k], 10000)) {
      sprintf(s,"Error axis=%d dsa_power_on_s error=%d",k,err);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
      }
      */
      m_axis[k] = AxisState::OPENED;
   }

   //intialisation des autres attributs de CTelEtel
   m_name = "etel";
   m_product = m_etel_driver;
   m_refractionCorrection = true;
   m_connected = false;
   m_home = abmc::IHome_createInstance();


}

void CTeletel::close()
{
   //delete mytel;
}


bool CTeletel::connected_get()
{
   //TODO 
   return m_connected;
}



void CTeletel::date_get(IDate* date)
{
   // retourne la date courante du PC
   date->set("NOW");
}

void CTeletel::date_set(IDate* date)
{
   // rien a faire 
}

void CTeletel::home_get(IHome* home)
{
   home->set(
      m_home->get_longitude(Frame::TR), 
      m_home->get_sense(Frame::TR), 
      m_home->get_latitude(Frame::TR), 
      m_home->get_altitude(Frame::TR)
   );
}

void CTeletel::home_set(IHome* home)
{
   m_home->set(
      home->get_longitude(Frame::TR), 
      home->get_sense(Frame::TR), 
      home->get_latitude(Frame::TR), 
      home->get_altitude(Frame::TR)
   );
}

void CTeletel::park()
{
   // TODO
}

void CTeletel::radec_coord_get(ICoordinates * radec)
{
   // TODO
   // je retourne des coordonnées courantes
   // radec->setRaDec(mytel->getRa(), mytel->getDec(), abmc::Equinox::NOW);
}

void CTeletel::radec_coord_sync(ICoordinates* radec, abaudela::ITelescope::MountSide MountSide)
{
   // TODO
   // je retourne des coordonnées courantes
   //    mytel->syncRadec(radec->getRa(Equinox::NOW), radec->getDec(Equinox::NOW));
}

void CTeletel::radec_guide_rate_get(double* raRate, double* decRate)
{
   // TODO
   //mytel->radec_guide_rate_get(raRate, decRate);
   
}

void CTeletel::radec_guide_rate_set(double raRate, double decRate)
{
   //TODO
}


//-------------------------------------------------------------
// envoie une impulsion en ascension droite et en declinaison
// avec une duree donne en millisecondes  
//
// @param tel   pointeur structure telprop
// @param alphaDuration   direction de l'impulsion sur l'axe alpha E, W  
// @param alphaDirection  durée de l'impulsion sur l'axe alpha en milliseconde  
// @param deltaDirection  direction de l'impulsion sur l'axe delta N ,S  
// @param deltaDuration   durée de l'impulsion sur l'axe delta en milliseconde  
// @return  0 = ,  -1= erreur
//-------------------------------------------------------------
void CTeletel::radec_guide_pulse_duration(abaudela::Direction alphaDirection, double alphaDuration,
   abaudela::Direction deltaDirection, double deltaDuration)
{
   //TODO
}

//-------------------------------------------------------------
// envoie une impulsion en ascension droite et en declinaison
// avec une distance donnee en arcseconde   
//
// @param tel   pointeur structure telprop
// @param alphaDirection direction de l'impulsion sur l'axe alpha E, W  
// @param alphaDistance  distance de l'impulsion sur l'axe alpha en arcsec
// @param deltaDirection direction de l'impulsion sur l'axe delta N ,S  
// @param deltaDuration  distance de l'impulsion sur l'axe delta en arcsec
// @return  0 = ,  -1= erreur
//-------------------------------------------------------------
void CTeletel::radec_guide_pulse_distance(abaudela::Direction alphaDirection, double alphaDistance,
   abaudela::Direction deltaDirection, double deltaDistance)
{
   //TODO
}

bool CTeletel::radec_guide_pulse_moving_get() {
   //TODO
   return false;
}


bool CTeletel::radec_slewing_get()
{
   //TODO
   return false;
}


void CTeletel::radec_goto(ICoordinates* radec, bool blocking)
{
   //TODO
}

void CTeletel::radec_move_start(abaudela::Direction direction, double rate)
{
   //TODO
}

void CTeletel::radec_move_stop(abaudela::Direction direction)
{
   //TODO
}

IIntArray*  CTeletel::radec_rate_list_get(int axis)
{
   CIntArray* rateList = new CIntArray();
   //TODO
   return rateList;
}

bool CTeletel::radec_tracking_get()
{
   //TODO
   return false;
}

void CTeletel::radec_tracking_set(bool tracking)
{
   //TODO
}

bool CTeletel::refraction_correction_get() {
   return m_refractionCorrection;
}

void CTeletel::unpark()
{
  //TODO
}

//=============================================================================
//  specificCmd
//=============================================================================
int CTeletel::getRegisterS(int argc, const char *argv[], std::string &line) {
   int result = SPEC_OK;
   int err = 0, axisno, k;
   int typ, idx, sidx = 0, ks, ctype;
   long val;
   double vald;
   float valf;
   long long vall;

   if (argc<4) {
      std::string line1 = abcommon::utils_format("usage: %s axisno typ(", argv[0]);
      line = line1;
      for (k = 0; k<NB_TYP; k++) {
         if (k>0) {
            line += "|";
         }
         line += m_typs[k].type_symbol;
      }
      line += ") idx ?sidx?";
      return SPEC_ERROR;

   }
   //axisno = atoi(argv[1]);
   axisno = argumentToInt(argv[1], "axisno");
   ks = symbol2type(argv[2]);
   if (ks == -1) {
      typ = argumentToInt(argv[2], "type");
   } else {
      typ = m_typs[ks].typ;
      ctype = m_typs[ks].ctype;
   }
   idx = argumentToInt(argv[3], "idx");
   if (argc >= 5) {
      sidx = argumentToInt(argv[4], "sidx");
   }
   if (ctype == ETEL_VAL_INT32) {
      err = dsa_get_register_int32_s(m_drv[axisno], typ, idx, sidx, &val, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
      line = std::to_string(val);
   } else if (ctype == ETEL_VAL_INT64) {
         err = dsa_get_register_int64_s(m_drv[axisno], typ, idx, sidx, &vall, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
         line = std::to_string(val);
      } else if (ctype == ETEL_VAL_FLOAT32) {
         err = dsa_get_register_float32_s(m_drv[axisno], typ, idx, sidx, &valf, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
         line = std::to_string(val);
      } else if (ctype == ETEL_VAL_FLOAT64) {
         err = dsa_get_register_float64_s(m_drv[axisno], typ, idx, sidx, &vald, DSA_GET_CURRENT, DSA_DEF_TIMEOUT);
         line = std::to_string(val);
      }
      if (err != 0) {
         string msg;
         line = getError(axisno, err, msg);
         return SPEC_ERROR;
      }
      return result;

}

int CTeletel::setRegisterS(int argc, const char *argv[], std::string &result) {
   int typ, idx, sidx = 0, ks, ctype;
   long val;
   double vald;
   float valf;
   __int64 vall;
   if (argc<6) {
      result = abcommon::utils_format( "usage: %s axisno typ(", argv[0]);
      for (int k = 0; k<NB_TYP; k++) {
         if (k>0) {
            result += "|";
         }
         result += m_typs[k].type_symbol;
      }
      result += ") idx sidx val";
      return SPEC_ERROR;
   }
   int axisno = argumentToInt(argv[1], "axisno");
   ks = symbol2type(argv[2]);
   if (ks == -1) {
      typ = argumentToInt(argv[2], "axisno");
   } else {
      typ = m_typs[ks].typ;
      ctype = m_typs[ks].ctype;
   }
   idx = argumentToInt(argv[3], "idx");
   sidx = argumentToInt(argv[4], "sidx");
   int err = 0;
   if (ctype == ETEL_VAL_INT32) {
      val = std::stoi(argv[5]);
      err = dsa_set_register_int32_s(m_drv[axisno], typ, idx, sidx, val, DSA_DEF_TIMEOUT);
   } else if (ctype == ETEL_VAL_INT64) {
      vall = std::stoll(argv[5]);
      err = dsa_set_register_int64_s(m_drv[axisno], typ, idx, sidx, vall, DSA_DEF_TIMEOUT);
   } else if (ctype == ETEL_VAL_FLOAT32) {
      valf =std::stof(argv[5]);
      err = dsa_set_register_float32_s(m_drv[axisno], typ, idx, sidx, valf, DSA_DEF_TIMEOUT);
   } else if (ctype == ETEL_VAL_FLOAT64) {
      vald = std::stod(argv[5]);
      err = dsa_set_register_float64_s(m_drv[axisno], typ, idx, sidx, vald, DSA_DEF_TIMEOUT);
   }
   if (err != 0) {
      getError(axisno, err, result);
      return SPEC_ERROR;
   }

   return SPEC_OK;
}

//=============================================================================
//  specificCmd delclaration
//=============================================================================

int cmdGetRegisterS(CTeletel* tel, int argc, const char *argv[], std::string &result) {
   return tel->getRegisterS(argc, argv, result);
}

int cmdSetRegisterS(CTeletel* tel, int argc, const char *argv[], std::string &result) {
   return tel->setRegisterS(argc, argv, result);
}


SpecificCommand CLibtelCommon::specificCommansList[] = {
    // === Specific commands for that telescope === 
   {"get", (Spec_CmdProc *)cmdGetRegisterS },
   {"set", (Spec_CmdProc *)cmdSetRegisterS },
    /* === Last function terminated by NULL pointers === */
    {NULL, NULL}
};

//=============================================================================
//  utilitaires
//=============================================================================

int CTeletel::symbol2type(const char *symbol)
{
   int k, kk = -1;
   for (k = 0; k<NB_TYP; k++) {
      if (strcmp(m_typs[k].type_symbol, symbol) == 0) {
         kk = k;
         break;
      }
   }
   return kk;
}

const char* CTeletel::getError(int axisno, int err, std::string &msg)
{
   msg = abcommon::utils_format("error %d: %s.\n", err, dsa_translate_error(err));
   return msg.c_str();
}

std::string CTeletel::getError(int axisno, int err)
{
   std::string  msg =  abcommon::utils_format("error %d: %s.\n", err, dsa_translate_error(err));
   return msg;
}








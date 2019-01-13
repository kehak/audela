#
## @file etc_tools.tcl
#  @brief Exposure Time Calculation
#  @author Alain KLOTZ
#  $Id: etc_tools.tcl 14040 2016-09-12 11:08:31Z fredvachier $
#

#  source "$audace(rep_install)/gui/audace/etc_tools.tcl"
#

## @defgroup simul_cam_image Imagerie avec caméra virtuelle
#
# La fonction @ref simulimage du fichier @ref surchaud.tcl permet de simuler
# la prise de vue d'image par une caméra virtuelle, à l'exemple des outils
# @ref ::collector and @ref ::foc and @ref ::eye.
# Pour ce faire il faut connaître ses paramètres électroniques et d'environnement.
# L'interface @ref ::echip mobilise la fonction @ref electronic_chip  @ref surchaud.tcl
# pour mesurer les paramètres électroniques d'une nouvelle caméra ou d'une caméra
# spécifique à partir d'images réelles (offset, dark et flat).
#
# La fonction @ref simulimage2 créé des séquences d'images,
# par exemple pour des étoiles variables : CF proc @ref photrel_demo
#
# Deux tutoriels sont disponibles :
# - @ref tuto_simulimage
# - @ref tuto_electronic
#

#---------------------------------------------------------
## @brief display ETC variables
#  @remark useful to check settings
#  @param disptype (default) ""
#
proc etc_disp { {disptype ""} } {
   global audace

   set names [lsort [array names audace]]
   set ns ""
   set topic0 ""
   foreach name $names {
      set sname [split $name ,]
      set key [lindex $sname 0]
      if {$key!="etc"} { continue }
      set topic "[lindex $sname 1]"
      if {($topic!="comp1")&&($topic!="compsnr")} {
         set topic "[lindex $sname 1]-[lindex $sname 2]"
      }
      if {$topic!=$topic0} {
         ::console::affiche_resultat "\n===== $topic\n"
         set topic0 $topic
      }
      set key [lindex $sname end]
      if {$key=="comment"} { continue }
      set texte "$key = $audace($name) : $audace($name,comment)"
      ::console::affiche_resultat "$texte\n"
   }
   return ""
}

#---------------------------------------------------------
#  brief initializations
#  param band (default) V
#  param moon_age (devault) 0
#
proc etc_init { {band V} {moon_age 0} } {
   global audace

   set audace(etc,compsnr,t,comment)       "Exposure time computer from a SNR value constrained"
   set audace(etc,compsnr,m,comment)       "Apparent magnitude computed from a SNR and exposure value constrained"
   set audace(etc,compsnr,SNR_obj,comment) "SNR computed from a exposure and a apparent magnitude value constrained"
   etc_params_set_defaults $band $moon_age
   etc_inputs_set_defaults
}

#---------------------------------------------------------
## @brief array des caméras avec leurs spécifications
#  @warning pour ajouter une caméra respecter impérativement la structure et l'ordre des paramètres dans
#  [list camName  {naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em}]
#  - naxis1     == Number of pixels on axis1
#  - naxis2     == Number of pixels on axis2
#  - photocell1 == Pixel size (m)
#  - photocell2 == Pixel size (m)
#  - C_th       == Thermic coefficient (electrons/sec/photocell)
#  - G          == CCD gain (electrons/ADU)
#  - N_ro       == Readout noise (electrons)
#  - eta        == CCD Quantum efficiency in the photometric band (electron/photon)
#  - Em         == Electron multiplier (>1 if EMCCD, else =1)
#  @remark called by etc_set_camera
#  @remark pour définir les paramètres électroniques d'une nouvelle caméra, utiliser l'outil ::echip
#
proc etc_set_array_cameras { } {
   global cameras

   #--   respecter imperativemznt l'ordre [list caName  {naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em}]
   #   naxis1     == Number of pixels on axis1
   #   naxis2     == Number of pixels on axis2
   #   photocell1 == Pixel size (m)
   #   photocell2 == Pixel size (m)
   #   C_th       == Thermic coefficient (electrons/sec/photocell)
   #   G          == CCD gain (electrons/ADU)
   #   N_ro       == Readout noise (electrons)
   #   eta        == CCD Quantum efficiency in the photometric band (electron/photon)
   #   Em         == Electron multiplier (>1 if EMCCD, else =1)

   # --- Andor
   array set cameras [list {Andor DW436}          {2048 2048 13.5e-6 13.5e-6 0.045 2.8   9.2 0.85 1}] ; # measured on TAROT at 1MHz
   array set cameras [list {Andor Neo sCMOS}      {2560 2160  6.5e-6  6.5e-6 0.07  4.    1.4 0.57 1}]
   array set cameras [list {Andor Lucas R DL-604} {1004 1002  8e-6    8e-6   0.07  3.   18   0.65 1}]
   array set cameras [list {Andor iKon-L 936 Z-BV} {2048 2048 13.5e-6 13.5e-6 0.00013 2.8   2.9 0.9 1}] ; # 20s redout time
   array set cameras [list {Andor DW936 BV}       {2048 2048 13.5e-6 13.5e-6 0.045 1.8   6.8 0.85 1}] ; # measured on Zadko at 1 MHz

   # --- Audine
   array set cameras [list {Audine Kaf401ME}      { 768  512  9e-6    9e-6   0.2   2.1  12   0.5  1}]
   array set cameras [list {Audine Kaf1600}       {1536 1024  9e-6    9e-6   0.2   2.1  12   0.5  1}]

   # --- SBig
   array set cameras [list {ST-402ME}             { 765  510  9e-6    9e-6   0.1   1.5  13.8 0.75 1}]
   array set cameras [list {ST-1603ME}            {1530 1020  9e-6    9e-6   0.1   1.7  18.0 0.75 1}]
   array set cameras [list {ST-3200ME}            {2184 1472  6.8e-6  6.8e-6 0.1   1.0  10.0 0.75 1}]
   #
   array set cameras [list {STF-8300M}            {3326 2504  5.4e-6  5.4e-6 0.05  1.0  15.0 0.45 1}]
   array set cameras [list {STT-8300M}            {3326 2504  5.4e-6  5.4e-6 0.02  0.37  9.3 0.45 1}]
   array set cameras [list {STT-1603ME}           {1536 1024  9e-6    9e-6   0.1   2.3  15.0 0.75 1}]
   array set cameras [list {STT-3200ME}           {2184 1472  6.8e-6  6.8e-6 0.06  1.0  10.0 0.75 1}]
   #
   array set cameras [list {STXL-11002}           {4008 2672  9e-6    9e-6   0.07  0.80 12.0 0.45 1}] ; # measured Les Makes bin1x1 -20°C
   array set cameras [list {STXL-6303E}           {3072 2048  9e-6    9e-6   0.3   1.47 11   0.65 1}]
   #
   array set cameras [list {STX-16803}            {4096 4096  9e-6    9e-6   0.02  1.27 10   0.6  1}]
   #
   array set cameras [list {ST-2000XM}            {1600 1200  7.4e-6  7.4e-6 0.1   0.6   7.9 0.35 1}]

   # --- Princeton
   array set cameras [list {Peregrine 486}        {4096 4096 15e-6   15e-6   0.01  1.8  10   0.9  1}]

   # --- Apogee
   array set cameras [list {Alta F230}            {2048 2048 15e-6   15e-6   0.4   1.5  12   0.85 1}]
   array set cameras [list {Alta F42}             {2048 2048 13.5e-6 13.5e-6 1     1.5   9   0.85 1}]
   #
   array set cameras [list {Alta F16M}            {4096 4096  9e-6    9e-6   0.2   1.5   9   0.6  1}]
   array set cameras [list {Alta F9000}           {3056 3056 12e-6   12e-6   0.6   1.29 11   0.6  1}] ; # measured. readout time 1MHz -35°C
   array set cameras [list {Alta F4320}           {2048 2048 24e-6   24e-6   2     1.5  12   0.6  1}]
   array set cameras [list {Alta F6}              {1024 1024 24e-6   24e-6   0.5   1.5   8   0.6  1}]
   #
   array set cameras [list {Alta F16000}          {4872 3248  7.4e-6  7.4e-6 0.01  1.5   9   0.4  1}]
   array set cameras [list {Alta F29050}          {6576 4384  5.5e-6  5.5e-6 0.15  1.5   6   0.4  1}]

   # --- FLI
   array set cameras [list {ProLine PL09000}      {3056 3056 12e-6   12e-6   0.1   1.5  10   0.65 1}]
   array set cameras [list {ProLine 16801}        {4096 4096  9e-6    9e-6   0.08  1.5   9   0.6  1}] ; # readout time 8 MHz -35°C
   array set cameras [list {ProLine 16803}        {4096 4096  9e-6    9e-6   0.005 1.5  10   0.6  1}]
   array set cameras [list {ProLine 4301}         {2084 2084 24e-6   24e-6   0.4   1.5   8   0.6  1}]
   array set cameras [list {ProLine 50100}        {8176 6132  6e-6    6e-6   0.003 1.5  11.5 0.2  1}]
   #
   array set cameras [list {ProLine 230 Midband}  {2048 2048 15e-6   15e-6   0.4   1.5   9.5 0.85 1}]
   array set cameras [list {ProLine 3041 Broadband} {2048 2048 15e-6 15e-6   0.3   1.5   8   0.85 1}]
   array set cameras [list {ProLine 4240 Midband} {2048 2048 13.5e-6 13.5e-6 0.2   1.5   8   0.85 1}]
   array set cameras [list {ProLine 4720}         {1024 1024 13e-6   13e-6   0.02  1.5  10   0.85 1}]
   array set cameras [list {ProLine 4710 Deep D.} {1024 1024 13e-6   13e-6   7     1.5  10   0.9  1}]

   # --- Atik
   array set cameras [list {Atik Titan}           {659 494   7.4e-6  7.4e-6   0.2   1.5   5   0.6  1}]
   array set cameras [list {Atik 314E}            {1392 1040 4.65e-6 4.65e-6  0.2   1.5   3   0.6  1}]
   array set cameras [list {Atik 320E}            {1620 1220 4.40e-6 4.40e-6  0.2   1.5   3   0.6  1}]
   array set cameras [list {Atik 314L+}           {1392 1040 6.45e-6 6.45e-6  0.0005 0.267  3.7   0.6  1}] ; # T=0°C http://www.dangl.at/ausruest/atik_314/atik_314_e.htm
   array set cameras [list {Atik 383L+}           {3362 2504 5.40e-6 5.40e-6  0.2   1.5   7   0.6  1}]
   array set cameras [list {Atik 420}             {1620 1220 4.40e-6 4.40e-6  0.1   1.5   4   0.6  1}]
   array set cameras [list {Atik 450}             {2448 2050 3.45e-6 3.45e-6  0.1   1.5   5   0.6  1}]
   array set cameras [list {Atik 428EX}           {1932 1452 4.54e-6 4.54e-6  0.1   1.5   5   0.6  1}]
   array set cameras [list {Atik 460EX}           {2750 2200 4.54e-6 4.54e-6  0.1   1.5   5   0.6  1}]
   array set cameras [list {Atik 490EX}           {3380 2704 3.69e-6 3.69e-6  0.1   1.5   5   0.6  1}]
   array set cameras [list {Atik 4000LE}          {2048 2048 7.4e-6  7.4e-6   0.01  1.5  11   0.6  1}]
   array set cameras [list {Atik 11000}           {4008 2672 9e-6    9e-6     0.03  1.5  13   0.6  1}]

   # --- Raptor Photonics
   array set cameras [list {OWL VIS-SWIR 320 0deg}    { 320  256 30e-6   30e-6    264000   6.55  131   0.8 1}] ; # T=0°C
   array set cameras [list {OWL VIS-SWIR 320 -40deg}  { 320  256 30e-6   30e-6    131      6.55  131   0.8 1}] ; # T=-40°C
   array set cameras [list {OWL SWIR 640 0deg}        { 640  512 15e-6   15e-6    [expr 264000/4.]   6.55  [expr 131/4.]   0.75 1}] ; # T=0°C
   array set cameras [list {OWL SWIR 640 -40deg}      { 640  512 15e-6   15e-6    [expr 131/4.]      6.55  [expr 131/4.]   0.75 1}] ; # T=-40°C

   #--   Point Grey U3->USB3 Capteurs CCD Sony
   array set cameras [list {GS-U3-28S4M ICX687}    { 1928  1448 3.69e-6   3.69e-6   0.79   0.16  11.01   0.71 1}] ; # WellDepth=9387 e-
   array set cameras [list {GS-U3-28S5M ICX674}    { 1920  1440 4.54e-6   4.54e-6   1.27   0.24   9.39   0.67 1}] ; # WellDepth=14693 e-
   array set cameras [list {GS-U3-60S6M ICX694}    { 2736  2192 4.54e-6   4.54e-6   0.82   0.23  10.54   0.73 1}] ; # WellDepth=14446 e-
   array set cameras [list {GS-U3-91S6M ICX814}    { 3376  2704 3.69e-6   3.69e-6   0.42   0.16   9.43   0.75 1}] ; # WellDepth=9996 e-

   # --- Spectral instruments
   array set cameras [list {Spectral Instruments 230-84 500KHz}  {4112 4096 15e-6 15e-6 0.01  1.5  7.0 0.92 1}]
   array set cameras [list {Spectral Instruments 230-84 2MHz}    {4112 4096 15e-6 15e-6 0.01  1.5 14.7 0.92 1}]
   array set cameras [list {Spectral Instruments 231-84 100KHz}  {4112 4096 15e-6 15e-6 0.0003  1.5  2.1 0.92 1}]
   array set cameras [list {Spectral Instruments 231-84 1.5MHz}  {4112 4096 15e-6 15e-6 0.0003  1.5  9.7 0.92 1}]

   # --- Watec
   array set cameras [list {Watec 120N+}  {720 576 8.6e-6 8.3e-6 10  5  30 0.7 1}]

}

#---------------------------------------------------------
#  brief sets the parameters of the camera from its name
#  param typecam (default) ""
#  return
#  - none in case of known camera
#  - or list of camera names if typecam = "" or unknown
#  code
#  example 1
#  etc_set_camera "Atik 450" (return nothing)
#  example 2
#  etc_set_camera
#  # {Alta F6} {Alta F16M} {Alta F42} {Alta F230} {Alta F4320} ....
#  endcode
#
proc etc_set_camera { {typecam ""} } {
   global audace cameras

   etc_set_array_cameras

   #--   liste des parametres
   set list_of_params {naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em}
   set list_of_of_cam [lsort -dictionary [array names cameras]]

   if {$typecam in $list_of_of_cam} {
      lassign [array get cameras $typecam] -> data
      foreach var $list_of_params val $data {
         etc_params_set $var $val
      }
      return ""
   } else {
      return $list_of_of_cam
   }

}

#---------------------------------------------------------
#  brief set default input parameters
#  remark called by etc_init
#  param band (default) V
#  param moon_age (default) 0
#  private
#
proc etc_params_set_defaults { {band V} {moon_age 0} } {
   global audace

   set names [lsort [array names audace]]
   foreach name $names {
      set sname [split $name ,]
      set key [lindex $sname 0]
      if {$key!="etc"} { continue }
      unset audace($name)
   }

   set audace(etc,param,local,moon_age,comment) "Age of the Moon (day)"
   set audace(etc,param,local,moon_age) 0

   set audace(etc,param,object,band,comment) "Photometric system symbol"
   set audace(etc,param,object,band) $band

   etc_modify_band

   set audace(etc,param,local,Elev,comment) "Elevation above horizon (deg)"
   set audace(etc,param,local,Elev) 65

   set audace(etc,param,local,Tatm0,comment) "Zenith transmission of the atmosphere in the photometric band"
   set audace(etc,param,local,Tatm0) [etc_params_set_Tatm0 300 0.10]

   set audace(etc,param,local,seeing,comment) "Fwhm of the seeing (arcsec)"
   set audace(etc,param,local,seeing) 3.0

   set audace(etc,param,optic,D,comment) "Optic diameter (m)"
   set audace(etc,param,optic,D) 0.3

   set audace(etc,param,optic,FonD,comment) "Focal diameter ratio"
   set audace(etc,param,optic,FonD) 4

   set audace(etc,param,optic,Topt,comment) "Transmission of the optics in the photometric band (Reflec=0.8, Refrac=0.95)"
   set audace(etc,param,optic,Topt) [expr 0.8*0.8*0.95*0.95]

   set audace(etc,param,optic,Fwhm_psf_opt,comment) "Fwhm of the point spread function in the image plane (m)"
   set audace(etc,param,optic,Fwhm_psf_opt) 15e-6

   set audace(etc,param,ccd,naxis1,comment) "Number of pixels on an axis1"
   set audace(etc,param,ccd,naxis1) 2048

   set audace(etc,param,ccd,naxis2,comment) "Number of pixels on an axis2"
   set audace(etc,param,ccd,naxis2) $audace(etc,param,ccd,naxis1)

   set audace(etc,param,ccd,photocell1,comment) "Photocell size on axis1 (m)"
   set audace(etc,param,ccd,photocell1) 13.5e-6

   set audace(etc,param,ccd,photocell2,comment) "Photocell size on axis2 (m)"
   set audace(etc,param,ccd,photocell2) $audace(etc,param,ccd,photocell1)

   set audace(etc,param,ccd,bin1,comment) "Binning on axis1 (photocells/pixel)"
   set audace(etc,param,ccd,bin1) 1

   set audace(etc,param,ccd,bin2,comment) "Binning on axis2 (photocells/pixel)"
   set audace(etc,param,ccd,bin2) $audace(etc,param,ccd,bin1)

   set audace(etc,param,ccd,eta,comment) "CCD Quantum efficiency in the photometric band (electron/photon)"
   set audace(etc,param,ccd,eta) 0.9

   set audace(etc,param,ccd,N_ro,comment) "Readout noise (electrons/pixel)"
   set audace(etc,param,ccd,N_ro) 8.5

   set audace(etc,param,ccd,C_th,comment) "Thermic coefficient (electrons/sec/photocell)"
   set audace(etc,param,ccd,C_th) 0.002

   set audace(etc,param,ccd,G,comment) "CCD gain (electrons/ADU)"
   set audace(etc,param,ccd,G) 1.8

   set audace(etc,param,ccd,Em,comment) "Electron multiplier (>1 if EMCCD, else =1)"
   set audace(etc,param,ccd,Em) 1

   return ""
}

#---------------------------------------------------------
#  brief set zenith transmission of the atmosphere in the photometric band
#  param altitude altitude (m) 300 par défaut
#  param Aerosol_Optical_Depth 0.10 par défaut
#  return Tatm0 value
#
proc etc_params_set_Tatm0 { {altitude_m 300} {Aerosol_Optical_Depth 0.10} } {
   global audace

   set z 1.
   set h [expr $altitude_m*1e-3]
   set AOD $Aerosol_Optical_Depth ; # 0.07=hiver 0.21=ete : Aerosol Optical Depth (AOD)
   set wvl $audace(etc,param,filter,l)
   set convert_unit 1.
   set lmu [expr 1.*$wvl*$convert_unit]
   set n1n1 [expr 0.23465+(1.076e2/(146-1/$lmu/$lmu))+(0.93161/(41-1/$lmu/$lmu))]
   set Ar [expr 9.4977e-3*pow($lmu,-4)*$n1n1*$n1n1*exp(-$h/7.996)]
   set Tz [expr exp(-2*0.0168*exp(-15*abs($lmu-0.59)))]
   set Ao [expr -2.5*log10($Tz)]
   set Ao0 [expr 1.5*exp(-pow(($lmu-0.300)/0.012,2))]
   set Ao1 [expr 0.03/(1+pow(($lmu-0.59)/0.07,2))]
   set Ao2 [expr 0.011/(1+pow(($lmu-0.576)/0.006,2))]
   set Ao3 [expr 0.009/(1+pow(($lmu-0.604)/0.01,2))]
   set Ao4 [expr 0.01/(1+pow(($lmu-0.630)/0.013,2))]
   set Ao5 [expr 0.0048/(1+pow(($lmu-0.531)/0.006,2))]
   set Ao6 [expr 0.003/(1+pow(($lmu-0.545)/0.009,2))]
   set Ao7 [expr 0.003/(1+pow(($lmu-0.564)/0.01,2))]
   set Ao8 [expr 0.004/(1+pow(($lmu-0.572)/0.01,2))]
   set Ao9 [expr 0.003/(1+pow(($lmu-0.506)/0.003,2))]
   set Ao10 [expr 0.004/(1+pow(($lmu-0.477)/0.0025,2))]
   set Ao [expr $Ao0+$Ao1+$Ao2+$Ao3+$Ao4+$Ao5+$Ao6+$Ao7+$Ao8+$Ao9+$Ao10]
   set Aa [expr 2.5*log10( exp($AOD*pow($lmu/0.55,-1.3)))]
   set AA [expr $Ar+$Ao+$Aa]
   set TT [expr pow(10,-0.4*$AA*$z)]

   return $TT
}

#---------------------------------------------------------
#  brief set msky parameter from band and moon_age
#  code etc_params_set_msky 20
#  endcode
#  param band (default) V
#  param moon_age (default) 0
#
proc etc_params_set_msky { {band V} {moon_age 0} } {
   global audace

   set audace(etc,param,local,msky,comment) "Sky brightness in the $band band at moon age $moon_age day (mag/arcsec2)"
   if {$moon_age<=1.5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 22.0 }
      if {$band=="B"} { set audace(etc,param,local,msky) 22.7 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.8 }
      if {$band=="C"} { set audace(etc,param,local,msky) 21.4 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.9 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.9 }
   } elseif {$moon_age<=5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 21.5 }
      if {$band=="B"} { set audace(etc,param,local,msky) 22.4 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.7 }
      if {$band=="C"} { set audace(etc,param,local,msky) 21.3 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.8 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.9 }
   } elseif {$moon_age<=8.5} {
      if {$band=="U"} { set audace(etc,param,local,msky) 19.9 }
      if {$band=="B"} { set audace(etc,param,local,msky) 21.6 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 21.4 }
      if {$band=="C"} { set audace(etc,param,local,msky) 21.0 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.6 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.7 }
   } elseif {$moon_age<=12} {
      if {$band=="U"} { set audace(etc,param,local,msky) 18.5 }
      if {$band=="B"} { set audace(etc,param,local,msky) 20.7 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 20.7 }
      if {$band=="C"} { set audace(etc,param,local,msky) 20.5 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 20.3 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.5 }
   } else {
      if {$band=="U"} { set audace(etc,param,local,msky) 17.0 }
      if {$band=="B"} { set audace(etc,param,local,msky) 19.5 }
      if {($band=="V")||($band=="g")} { set audace(etc,param,local,msky) 20.0 }
      if {$band=="C"} { set audace(etc,param,local,msky) 19.9 }
      if {($band=="R")||($band=="r")} { set audace(etc,param,local,msky) 19.9 }
      if {($band=="I")||($band=="i")} { set audace(etc,param,local,msky) 19.2 }
   }
   if {$band=="z"} { set audace(etc,param,local,msky) 17.0 }
   if {$band=="J"} { set audace(etc,param,local,msky) 15.7 }
   if {$band=="H"} { set audace(etc,param,local,msky) 14.1 }
   if {$band=="K"} { set audace(etc,param,local,msky) 13.0 }

   return ""
}

#---------------------------------------------------------
#  brief set a filter from band
#  remark called by etc_modify_band
#  param band (default) V
#  private
#
proc etc_params_set_filter { {band V} } {
   global audace

   set audace(etc,param,filter,l,comment) "Central wavelength of the filter (micrometers)"
   set audace(etc,param,filter,Dl,comment) "Wavelength bandpass of the filter (micrometers)"
   set audace(etc,param,filter,Fm0,comment) "Flux for magnitude zero for the filter (Jy)"
   if {$band=="C"} {
      set audace(etc,param,filter,l) 0.6
      set audace(etc,param,filter,Dl) 0.3
      set audace(etc,param,filter,Fm0) 3100
   } elseif {$band=="U"} {
      set audace(etc,param,filter,l) 0.36
      set audace(etc,param,filter,Dl) [expr 0.15*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1810
   } elseif {$band=="B"} {
      set audace(etc,param,filter,l) 0.44
      set audace(etc,param,filter,Dl) [expr 0.22*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4260
   } elseif {$band=="V"} {
      set audace(etc,param,filter,l) 0.55
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3640
   } elseif {$band=="R"} {
      set audace(etc,param,filter,l) 0.64
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3080
   } elseif {$band=="I"} {
      set audace(etc,param,filter,l) 0.79
      set audace(etc,param,filter,Dl) [expr 0.19*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 2550
   } elseif {$band=="J"} {
      set audace(etc,param,filter,l) 1.26
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1600
   } elseif {$band=="H"} {
      set audace(etc,param,filter,l) 1.60
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 1080
   } elseif {$band=="K"} {
      set audace(etc,param,filter,l) 2.22
      set audace(etc,param,filter,Dl) [expr 0.23*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 670
   } elseif {$band=="g"} {
      set audace(etc,param,filter,l) 0.52
      set audace(etc,param,filter,Dl) [expr 0.14*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 3730
   } elseif {$band=="r"} {
      set audace(etc,param,filter,l) 0.67
      set audace(etc,param,filter,Dl) [expr 0.14*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4490
   } elseif {$band=="i"} {
      set audace(etc,param,filter,l) 0.79
      set audace(etc,param,filter,Dl) [expr 0.16*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4760
   } elseif {$band=="z"} {
      set audace(etc,param,filter,l) 0.91
      set audace(etc,param,filter,Dl) [expr 0.13*$audace(etc,param,filter,l)]
      set audace(etc,param,filter,Fm0) 4810
   } else {
      error "Filter $band not found"
   }
}

#---------------------------------------------------------
## @brief get input list
#  @code Exemples :
#  - etc_inputs_set m 12.5
#  - etc_inputs_set t 120
#  @endcode
#  @param args list of {key value}
#
proc etc_inputs_set { args } {
   global audace

   set names [lsort [array names audace]]
   set topic0 ""
   set res ""
   set name0 ""

   if {[llength $args] > 0} {

      set key0 [lindex $args 0]
      set val0 [lindex $args 1]

      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="input"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         if {$key==$key0} {
            set name0 $name
             if {[catch {expr $val0}]==0} {
                set audace($name) $val0
               if {$key0 in [list M m DL_pc] } {
                  set delta [expr 5. * log10 ($audace(etc,input,object,DL_pc) / 10.)]
                  switch -exact $key0 {
                     "M"      { set audace(etc,input,object,m) [expr $audace(etc,input,object,M)+$delta] }
                     "m"      { set audace(etc,input,object,M) [expr $audace(etc,input,object,m)-$delta] }
                     "DL_pc"  { set audace(etc,input,object,m) [expr $audace(etc,input,object,M)+$delta] }
                  }
               }
            } elseif {$val0=="?"} {
               return $audace($name,comment)
            }
            return "$audace($name) \"$audace($name,comment)\""
         }
      }
   }

   if {$name0==""} {

      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="input"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         append res "$key "
      }
      return $res

   }

}

#---------------------------------------------------------
#  brief set default parameters
#  remark called by etc_init
#  private
#
proc etc_inputs_set_defaults { } {
   global audace

   set band $audace(etc,param,object,band)

   set audace(etc,input,object,M,comment) "Absolute stellar magnitude in the $band band"
   set audace(etc,input,object,M) -21

   set audace(etc,input,object,DL_pc,comment) "Distance luminosity (pc)"
   set audace(etc,input,object,DL_pc) 40e6

   set audace(etc,input,object,m,comment) "Apparent stellar magnitude in the $band band"
   set audace(etc,input,object,m) [expr $audace(etc,input,object,M) + 5. * log10 ($audace(etc,input,object,DL_pc) / 10.)]

   set audace(etc,input,ccd,t,comment) "Exposure time (sec)"
   set audace(etc,input,ccd,t) 30

   set audace(etc,input,constraint,snr,comment) "SNR constrained"
   set audace(etc,input,constraint,snr) 5

   return ""
}

#---------------------------------------------------------
#  brief set parameters
#  param args list of {key value}
#  private
#
proc etc_params_set { args } {
   global audace

   set names [lsort [array names audace]]
   set topic0 ""
   set res ""
   set name0 ""

   if {[llength $args] > 0} {

      set key0 [lindex $args 0]
      set val0 [lindex $args 1]
     foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="param"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         if {$key==$key0} {
            set name0 $name
            if {$key0 eq "moon_age" && [catch {expr $val0}]==0} {
               set audace($name) $val0
               etc_params_set_msky $audace(etc,param,object,band) $val0
            } elseif {$key0 eq "band" && $val0 in [list B C H I J K R U V z]} {
                set audace($name) $val0
                etc_modify_band $val0
            } elseif {[catch {expr $val0}]==0} {
               set audace($name) $val0
            } elseif {$val0=="?"} {
               return $audace($name,comment)
            }
           return "$audace($name) \"$audace($name,comment)\""
         }
      }
   }
   if {$name0==""} {

      foreach name $names {
         set sname [split $name ,]
         set key [lindex $sname 0]
         if {$key!="etc"} { continue }
         set key [lindex $sname 1]
         if {$key!="param"} { continue }
         set key [lindex $sname end]
         if {$key=="comment"} { continue }
         set key [lindex $sname 3]
         append res "$key "
      }
      return $res

   }

}

#---------------------------------------------------------
#  brief modify band
#  param band (default) V
#
proc etc_modify_band { {band V} } {
   global audace

   #---  calcul des cofficients L, Dl et Fm0
   etc_params_set_filter $band

   #--- calcul de Tatm0
   set audace(etc,param,local,Tatm0) [etc_params_set_Tatm0 300 0.10]

   #---  calcul de msky
   etc_params_set_msky $band $audace(etc,param,local,moon_age)

   #---  modification des commentaires
   set audace(etc,input,object,M,comment) "Absolute stellar magnitude in the $band band"
   set audace(etc,input,object,m,comment) "Apparent stellar magnitude in the $band band"

}

#---------------------------------------------------------
#  brief preliminary comptutations
#
proc etc_preliminary_computations { } {
   global audace

   set pi [expr 4*atan(1)]

   # --- Optics
   set audace(etc,comp1,Foclen,comment) "Focal length (m)"
   set audace(etc,comp1,Foclen) [expr $audace(etc,param,optic,FonD) * $audace(etc,param,optic,D)]

   set audace(etc,comp1,pixsize1,comment) "Pixel length on axis1 (m)"
   set audace(etc,comp1,pixsize1) [expr $audace(etc,param,ccd,photocell1) * $audace(etc,param,ccd,bin1)]

   set audace(etc,comp1,pixsize2,comment) "Pixel length on axis2 (m)"
   set audace(etc,comp1,pixsize2) [expr $audace(etc,param,ccd,photocell2) * $audace(etc,param,ccd,bin2)]

   set audace(etc,comp1,cdelt1,comment) "Pixel spatial sampling on axis1 (arcsec/pix)"
   set audace(etc,comp1,cdelt1) [expr 2 * atan ( $audace(etc,comp1,pixsize1) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi * 3600.]

   set audace(etc,comp1,cdelt2,comment) "Pixel spatial sampling on axis2 (arcsec/pix)"
   set audace(etc,comp1,cdelt2) [expr 2 * atan ( $audace(etc,comp1,pixsize2) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi * 3600.]

   set audace(etc,comp1,W,comment) "Pixel solid angle (arcsec2/pix)"
   set audace(etc,comp1,W) [expr $audace(etc,comp1,cdelt1) * $audace(etc,comp1,cdelt2)]

   set audace(etc,comp1,FoV1,comment) "Field of view of the CCD image on axis1 (deg)"
   set audace(etc,comp1,FoV1) [expr 2 * atan ( $audace(etc,param,ccd,naxis1) * $audace(etc,param,ccd,photocell1) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi]

   set audace(etc,comp1,FoV2,comment) "Field of view of the CCD image on axis2 (deg)"
   set audace(etc,comp1,FoV2) [expr 2 * atan ( $audace(etc,param,ccd,naxis2) * $audace(etc,param,ccd,photocell2) / $audace(etc,comp1,Foclen) / 2.) * 180. / $pi]

   set audace(etc,comp1,Fwhm_psf_seeing,comment) "Fwhm of the seeing in the image plane (m)"
   set audace(etc,comp1,Fwhm_psf_seeing) [expr $audace(etc,param,local,seeing) / 3600. * $pi / 180 * $audace(etc,comp1,Foclen)]

   set audace(etc,comp1,Fwhm_psf,comment) "Fwhm of the PSF in the image plane (m)"
   set audace(etc,comp1,Fwhm_psf) [expr sqrt ( $audace(etc,param,optic,Fwhm_psf_opt)*$audace(etc,param,optic,Fwhm_psf_opt) + $audace(etc,comp1,Fwhm_psf_seeing)*$audace(etc,comp1,Fwhm_psf_seeing) )]

   # --- Optics : computation of the gaussian fraction covered by the brightest pixel
   set oversampling 12 ; # must be even and >10 to ensure a good resolution
   if {$audace(etc,comp1,pixsize1)>=$audace(etc,comp1,pixsize2)} {
      set p $audace(etc,comp1,pixsize2)
      set P $audace(etc,comp1,pixsize1)
   } else {
      set p $audace(etc,comp1,pixsize1)
      set P $audace(etc,comp1,pixsize2)
   }
   set dp [expr $p/$oversampling]
   set sigma [expr $audace(etc,comp1,Fwhm_psf) / (2*sqrt(2*log(2)))]
   set sigma2 [expr $sigma*$sigma]
   set a1d [expr 1 / $sigma / sqrt(2*$pi)]
   set a2d [expr $a1d*$a1d]

   set audace(etc,comp1,fpix1,comment) "Flux fraction in the brightest pixel in the favorable case (max flux at the center of the pixel)"
   set x1 [expr -$p/2.] ; set x2 [expr $x1+$p]
   set y1 [expr -$P/2.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix1) [expr $a2d*$dp*$dp*$som]

   set audace(etc,comp1,fpix3,comment) "Flux fraction in the brightest pixel in the worst case (max flux at the corner of the pixel)"
   set x1 [expr 0.] ; set x2 [expr $x1+$p]
   set y1 [expr 0.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix3) [expr $a2d*$dp*$dp*$som]

   set audace(etc,comp1,fpix2,comment) "Flux fraction in the brightest pixel in the intermediate case"
   set x1 [expr 0.] ; set x2 [expr $x1+$p]
   set y1 [expr -$P/2.] ; set y2 [expr $y1+$P]
   set som 0
   for {set x $x1} {$x<=$x2} {set x [expr $x+$dp]} {
      set dx2 [expr $x*$x]
      for {set y $y1} {$y<=$y2} {set y [expr $y+$dp]} {
         set dy2 [expr $y*$y]
         set d2 [expr $dx2+$dy2]
         set som [expr $som+exp(-0.5*$d2/$sigma2)]
      }
   }
   set audace(etc,comp1,fpix2) [expr $a2d*$dp*$dp*$som]

   # --- Object
   set audace(etc,comp1,F_Jy,comment) "Total flux of the object outside atmosphere (Jy)"
   set audace(etc,comp1,F_Jy) [expr $audace(etc,param,filter,Fm0) * pow(10,-0.4 * $audace(etc,input,object,m)) ]

   set audace(etc,comp1,F_ph,comment) "Total flux of the object outside atmosphere (photons / sec /m2)"
   set audace(etc,comp1,F_ph) [expr $audace(etc,comp1,F_Jy) * 1.51e7 * $audace(etc,param,filter,Dl)/$audace(etc,param,filter,l)]

   set audace(etc,comp1,Tatm,comment) "Transmission of the atmosphere at elevation"
   set audace(etc,comp1,Tatm) [expr $audace(etc,param,local,Tatm0) * sin($audace(etc,param,local,Elev)*$pi/180.)]

   set audace(etc,comp1,Ftot_ph,comment) "Total flux of the object after passed thru the optics (photons / object)"
   set audace(etc,comp1,Ftot_ph) [expr $audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,input,ccd,t)]

   set audace(etc,comp1,Ftot_el,comment) "Total flux of the object after passed thru the optics (electrons / object)"
   set audace(etc,comp1,Ftot_el) [expr $audace(etc,comp1,Ftot_ph) * $audace(etc,param,ccd,eta)]

   set audace(etc,comp1,Fpix_el,comment) "Brightest pixel flux of the object after passed thru the optics (electrons / pixel)"
   set audace(etc,comp1,Fpix_el) [expr $audace(etc,comp1,Ftot_el) * $audace(etc,comp1,fpix1)]

   # --- Sky brightness

   set audace(etc,comp1,Sky_Jy,comment) "Brightness of the sky (Jy/arsec2)"
   set audace(etc,comp1,Sky_Jy) [expr $audace(etc,param,filter,Fm0) * pow(10,-0.4 * $audace(etc,param,local,msky)) ]

   set audace(etc,comp1,Sky_ph,comment) "Brightness of the sky (photons / sec /m2)"
   set audace(etc,comp1,Sky_ph) [expr $audace(etc,comp1,Sky_Jy) * 1.51e7 * $audace(etc,param,filter,Dl)/$audace(etc,param,filter,l)]

   set audace(etc,comp1,Skypix_ph,comment) "Brightness of the sky after passed thru the optics (photons / pixel)"
   set audace(etc,comp1,Skypix_ph) [expr $audace(etc,comp1,Sky_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,W) * $audace(etc,param,optic,Topt) * $audace(etc,input,ccd,t)]

   set audace(etc,comp1,Skypix_el,comment) "Brightness of the sky after passed thru the optics (electrons / pixel)"
   set audace(etc,comp1,Skypix_el) [expr $audace(etc,comp1,Skypix_ph) * $audace(etc,param,ccd,eta)]

   # --- EMCCD
   set audace(etc,comp1,fex,comment) "EMCCD excess noise factor (empirical formula derived from a figure of a paper)"
   set audace(etc,comp1,fex) [expr 1. + pow( 2./$pi * atan( ($audace(etc,param,ccd,Em)-1)*3 ) ,3)]

   return ""
}

#---------------------------------------------------------
## @brief compute SNR from a given time
#  @code What is the SNR for t=20s ?
#  etc_init
#  etc_inputs_set t 20
#  etc_disp
#  etc_t2snr_computations
#  @endcode
#  @return SNR ratio
#
proc etc_t2snr_computations {} {
   global audace

   etc_preliminary_computations

   set audace(etc,compsnr,S_th,comment) "Thermic signal (electrons/pixel)"
   set audace(etc,compsnr,S_th) [expr $audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,input,ccd,t) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,S_sk,comment) "Sky signal (electrons/pixel)"
   set audace(etc,compsnr,S_sk) [expr $audace(etc,comp1,Skypix_el) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,S_ph,comment) "Object signal (electrons/pixel)"
   set audace(etc,compsnr,S_ph) [expr $audace(etc,comp1,Fpix_el) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_th,comment) "Thermic noise (electrons/pixel)"
   set audace(etc,compsnr,N_th) [expr sqrt($audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,input,ccd,t) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_sk,comment) "Sky noise (electrons/pixel)"
   set audace(etc,compsnr,N_sk) [expr sqrt($audace(etc,comp1,Skypix_el) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_ph,comment) "Object noise (electrons/pixel) = shot noise"
   set audace(etc,compsnr,N_ph) [expr sqrt($audace(etc,comp1,Fpix_el) * $audace(etc,comp1,fex)) * $audace(etc,param,ccd,Em)]

   set audace(etc,compsnr,N_tot,comment) "Total noise (electrons/pixels)"
   set audace(etc,compsnr,N_tot) [expr sqrt ( $audace(etc,param,ccd,N_ro)*$audace(etc,param,ccd,N_ro) + $audace(etc,compsnr,N_th)*$audace(etc,compsnr,N_th) + $audace(etc,compsnr,N_sk)*$audace(etc,compsnr,N_sk) + $audace(etc,compsnr,N_ph)*$audace(etc,compsnr,N_ph) )]

   set audace(etc,compsnr,SNR_obj,comment) "Object signal/noise at the brightest pixel"
   set audace(etc,compsnr,SNR_obj) [expr $audace(etc,compsnr,S_ph) / $audace(etc,compsnr,N_tot)]

   set audace(etc,compsnr,S_th_adu,comment) "Thermic signal (ADU/pixel)"
   set audace(etc,compsnr,S_th_adu) [expr $audace(etc,compsnr,S_th) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,S_sk_adu,comment) "Sky signal (ADU/pixel)"
   set audace(etc,compsnr,S_sk_adu) [expr $audace(etc,compsnr,S_sk) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,S_ph_adu,comment) "Object signal (ADU/pixel)"
   set audace(etc,compsnr,S_ph_adu) [expr $audace(etc,compsnr,S_ph) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_th_adu,comment) "Thermic noise (ADU/pixel)"
   set audace(etc,compsnr,N_th_adu) [expr $audace(etc,compsnr,N_th) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_sk_adu,comment) "Sky noise (ADU/pixel)"
   set audace(etc,compsnr,N_sk_adu) [expr $audace(etc,compsnr,N_sk) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_ph_adu,comment) "Object noise (ADU/pixel) = shot noise"
   set audace(etc,compsnr,N_ph_adu) [expr $audace(etc,compsnr,N_ph) / $audace(etc,param,ccd,G)]

   set audace(etc,compsnr,N_tot_adu,comment) "Total noise (ADU/pixels)"
   set audace(etc,compsnr,N_tot_adu) [expr $audace(etc,compsnr,N_tot) / $audace(etc,param,ccd,G)]

   return $audace(etc,compsnr,SNR_obj)
}

#---------------------------------------------------------
## @brief compute time from a given SNR
#  @code What is the exposure time for SNR = 5 and magnitude = 18 ?
#  etc_init
#  etc_inputs_set snr 5
#  etc_inputs_set m 18
#  etc_disp
#  etc_snr2t_computations
#  @endcode
#  @return exposure time
#
proc etc_snr2t_computations {} {
   global audace

   etc_preliminary_computations

   set pi [expr 4*atan(1)]
   set C [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * $audace(etc,param,ccd,N_ro)*$audace(etc,param,ccd,N_ro)]
   set B [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * ( ($audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) + ($audace(etc,comp1,Sky_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,W) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) + ($audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)) )]
   set A [expr -pow( $audace(etc,comp1,F_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,param,ccd,Em) , 2) ]
   # We have A<0, B>0 and C >0. From the equation A*t^2 + B*t + C = 0, we can find the t value:
   set D [expr $B*$B - 4*$A*$C] ; # (always positive)
   set t [expr ( -$B - sqrt($D) ) / (2.*$A)]
   set audace(etc,compsnr,t,comment) "Exposure time computer from a SNR value constrained"
   set audace(etc,compsnr,t) $t
   return $t
}

#---------------------------------------------------------
## @brief compute apparent magnitude from a given SNR
#  @code What is the magnitude for SNR = 5 and exposure time 1 sec ?
#  etc_init
#  etc_inputs_set snr 5
#  etc_inputs_set t 1
#  etc_disp
#  etc_snr2m_computations
#  @endcode
#  @return apparent magnitude
#
proc etc_snr2m_computations {} {
   global audace

   etc_preliminary_computations

   set pi [expr 4*atan(1)]
   set C [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * ( $audace(etc,param,ccd,N_ro)*$audace(etc,param,ccd,N_ro) +  $audace(etc,param,ccd,C_th) * $audace(etc,param,ccd,bin1) * $audace(etc,param,ccd,bin2) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)*$audace(etc,input,ccd,t) + $audace(etc,comp1,Sky_ph) * $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,W) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)*$audace(etc,input,ccd,t))]
   set B [expr $audace(etc,input,constraint,snr)*$audace(etc,input,constraint,snr) * ( $pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,comp1,fex) * $audace(etc,param,ccd,Em)*$audace(etc,param,ccd,Em)*$audace(etc,input,ccd,t)) ]
   set A [expr -pow($pi * $audace(etc,param,optic,D)*$audace(etc,param,optic,D) / 4. * $audace(etc,comp1,Tatm) * $audace(etc,param,optic,Topt) * $audace(etc,param,ccd,eta) * $audace(etc,comp1,fpix1) * $audace(etc,param,ccd,Em) * $audace(etc,input,ccd,t) , 2) ]
   # We have A<0, B>0 and C >0. From the equation A*t^2 + B*t + C = 0, we can find the t value:
   set D [expr $B*$B - 4*$A*$C] ; # (always positive)
   set F_ph [expr ( -$B - sqrt($D) ) / (2.*$A)]
   set F_Jy [expr $F_ph / (1.51e7 * $audace(etc,param,filter,Dl)/$audace(etc,param,filter,l))]
   set m [expr -2.5 *log10( $F_Jy / $audace(etc,param,filter,Fm0))]
   set audace(etc,compsnr,m,comment) "Apparent magnitude computed from a SNR and exposure value constrained"
   set audace(etc,compsnr,m) $m
   return $m
}


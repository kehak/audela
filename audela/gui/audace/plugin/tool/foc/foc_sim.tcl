#
## @file foc_sim.tcl
#  @brief Scripts pour la simulation de focalisation et défocalisation avec simulimage (surchaud.tcl)
#  @author Raymond ZACHANTKE
#  $Id: foc_sim.tcl 12892 2016-01-24 22:52:53Z rzachantke $
#

#------------------------------------------------------------
## @brief créé une image avec une caméra virtuelle pour alimenter la simulation
#  @details invoque les proc de etc_tools.tcl et simulimage de surchaud.tcl
#  @param bin binning
#  @param seeing 3.0 par défaut
#  @param exposure 10 sec par défaut
#  @param dfoc 0.0 par défaut
#
proc ::foc::createImage { bin {seeing 3.0} {exposure 10} { dfoc 0.0 } } {
   global panneau

   #--   raccourcis
   set bin1 $bin
   set bin2 $bin
   set bufNo $::audace(bufNo)
   set ext $::conf(extension,defaut)
   set cat_format MICROCAT
   set cat_folder $::audace(rep_userCatalogMicrocat)
   set observer $panneau(foc,focuser)
   set object "Star"
   set home $::audace(posobs,observateur,gps)
   lassign $home -> obs_long sens obs_lat obs_elev
   if {$sens eq "W"} {
      set obs-long -${obs-long}
   }
   #--   recupere les parametres optiques
   lassign [::confOptic::getConfOptic A] telescop aptdia foclen
   set foclen [expr { $foclen*(1+$dfoc) }]

   set datetu [::audace::date_sys2ut now]

   #--   impose la camera
   set typeCam "Audine Kaf401ME"
   #--   impose l'angle de rotation
   set crota2 0.0
   #--   definit le filtre
   set filtre C
   #--   definit l'age de la Lune
   set moon_age 0

   #--   parametres de simulimage
   set sky_brightness 21.8
   set shutter_mode 1
   set bias_level 0
   set flat_type 0

   #--   HIP 13367 ra 02h51m59s dec 68d53m19s mag 5.94
   set objname "HIP 13367"
   #--   Decentre l'etoile
   set ra 02h51m40s
   set dec 68d52m30s
   lassign [mc_radec2altaz $ra $dec $home $datetu] azimuth elev
   set ra_angle [mc_angle2deg $ra]
   set dec_angle [mc_angle2deg $dec]

   etc_init $filtre $moon_age
   etc_params_set seeing $seeing #--   arcsec
   etc_params_set Elev $elev

   set fond [format %.2f [expr {$foclen*1./$aptdia}]]
   etc_params_set D [format %0.3f $aptdia]
   etc_params_set FonD $fond

   #--   definit une camera Audine
   etc_set_camera $typeCam

   #--   extrait les caracteristiques de cette camera
   foreach key [list naxis1 naxis2 photocell1 photocell2 C_th G N_ro eta Em ] {
      set $key $::audace(etc,param,ccd,$key)
   }

   etc_params_set bin1 $bin1
   etc_params_set bin2 $bin2
   set naxis1 [expr { $naxis1/$bin1 }]
   set naxis2 [expr { $naxis2/$bin2 }]
   etc_params_set naxis1 $naxis1
   etc_params_set naxis2 $naxis2
   etc_preliminary_computations

   set fwhm [expr { $::audace(etc,comp1,Fwhm_psf) / $::audace(etc,comp1,Foclen) * 180 / 4 / atan(1) * 3600 } ]

   #--   Debug
   #etc_disp

   set pixsize1 [expr  { $photocell1*1e6*$bin1 }]
   set pixsize2 [expr  { $photocell2*1e6*$bin2 }]
   set crpix1 [expr { $naxis1/2 }]
   set crpix2 [expr { $naxis2/2 }]
   set cdeltx -$::audace(etc,comp1,cdelt1)
   set cdelty $::audace(etc,comp1,cdelt2)

   #--   cree l'image grise
   buf$bufNo setpixels CLASS_GRAY $naxis1 $naxis2 FORMAT_USHORT COMPRESS_NONE 0

   #--   complete avec les mots cles
   buf$bufNo setkwd [list APTDIA $aptdia float Diameter m]
   buf$bufNo setkwd [list BIN1 $bin1 int {} {}]
   buf$bufNo setkwd [list BIN2 $bin2 int {} {}]
   buf$bufNo setkwd [list CDELT1 $cdeltx double {Scale along Naxis1} deg/pixel]
   buf$bufNo setkwd [list CDELT2 $cdelty double {Scale along Naxis2} deg/pixel]
   buf$bufNo setkwd [list CRPIX1 $crpix1 double {Reference pixel for Naxis1} pixel]
   buf$bufNo setkwd [list CRPIX2 $crpix2 double {Reference pixel for Naxis2} pixel]
   buf$bufNo setkwd [list CRVAL1 $ra_angle double {Reference coordinate for Naxis1} deg]
   buf$bufNo setkwd [list CRVAL2 $$dec_angle double {Reference coordinate for Naxis2} deg]
   buf$bufNo setkwd [list CROTA2 $crota2 double {Position angle of North} deg]
   buf$bufNo setkwd [list DATE-OBS $datetu string {Start of exposure.FITS standard} {ISO 8601}]
   buf$bufNo setkwd [list DEC $dec_angle double {Expected DEC asked to telescope} deg]
   buf$bufNo setkwd [list DETNAM "Audine Kaf401ME" string {Camera used} {}]
   buf$bufNo setkwd [list EXPOSURE $exposure float {Total time of exposure} s]
   buf$bufNo setkwd [list FILTER "$filtre" string {C U B V R I J H K z} {}]
   buf$bufNo setkwd [list FOCLEN $foclen float {Resulting Focal length} m]
   buf$bufNo setkwd [list FWHM $fwhm float {Full Width at Half Maximum} pixels]
   buf$bufNo setkwd [list OBJECT "$object" string {Object observed} {}]
   buf$bufNo setkwd [list OBJNAME "$objname" string {Object Name} {}]
   buf$bufNo setkwd [list OBS-ELEV $obs_elev float {Elevation above sea of observatory} m]
   buf$bufNo setkwd [list OBS-LAT $obs_lat float {Geodetic observatory latitude} deg]
   buf$bufNo setkwd [list OBS-LONG $obs_long float {East-positive observatory longitude} deg]
   buf$bufNo setkwd [list OBSERVER "$observer" string {Observers Names} {}]
   buf$bufNo setkwd [list PIXSIZE1 $pixsize1 float {Pixel Width (with binning)} mum]
   buf$bufNo setkwd [list PIXSIZE2 $pixsize2 float {Pixel Height (with binning)} mum]
   buf$bufNo setkwd [list RA $ra_angle double {Expected RA asked to telescope} deg]
   buf$bufNo setkwd [list SWCREATE "AudeLA" string {Acquisition Software} {}]
   buf$bufNo setkwd [list TELESCOP "$telescop" string {Telescope (name barlow reducer)} {}]

   simulimage $ra_angle $dec_angle $pixsize1 $pixsize2 $foclen \
      $cat_format $cat_folder $exposure $fwhm $aptdia $filtre \
      $sky_brightness $eta $G $N_ro $shutter_mode $bias_level \
      $C_th $::audace(etc,comp1,Tatm) $::audace(etc,param,optic,Topt) $Em $flat_type

   buf$bufNo delkwd RADESYS
}

#------------------------------------------------------------
#  brief calcule un seeing en fonction de la position du focuser
#
#  invoqué par la proc ::foc::createImage
#
#  return seeing
#
proc ::foc::computeSeeing { } {
   global panneau

   lassign [::foc::getLimits $panneau(foc,focuser)] limite1 limite2
   set ratio [expr { 1.85*$panneau(foc,seeing)/($limite2-$limite1) }]
   set seeing [expr { $panneau(foc,seeing)-$ratio*($panneau(foc,start)-$limite1) } ]
   if {$seeing < 0} {
      set seeing [expr { abs($seeing) }]
   }

   return $seeing
}


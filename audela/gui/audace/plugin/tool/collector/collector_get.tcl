#
## @file collector_get.tcl
#  @brief Scripts de lecture des mots clés et de calcul
#  @author Raymond Zachantke
#  $Id: collector_get.tcl 14236 2017-07-03 17:53:34Z rzachantke $
#

   # nom proc                                onglet      utilisee par

   # ::collector::getImgData                 Cible       initTarget
   # ::collector::getTelPosition             Local       initLocal
   # ::collector::getDateExposure            Local       initLocal
   # ::collector::getTPW                     Atmosphere  initAtm
   # ::collector::getKwdOptic                Optique     onChangeOptique
   # ::collector::getCamName                 Camera      onChangeCam
   # ::collector::getObserv                  Mots cles   onChangeObserver
   # ::collector::getObject                  Mots cles   onChangeObjName
   # ::collector::getCoordJ2000              Cible       initTarget
   # ::collector::getTrueCoordinates         Cible       computeTelCoord
   # ::collector::getCdeltFov                Vue         computeCdeltFov
   # ::collector::getImgCenterRaDec          Vue         getImgData
   # ::collector::getMatchWCS                Vue         initPose
   # ::collector::getDateTUJD                Local       initLocal
   # ::collector::getTsl                     Local       computeTslMoon
   # ::collector::getMoonAge                 Local       computeTslMoon
   # ::collector::getSecz                    Atmosphere  computeCoordApp
   # ::collector::getFonDResolution          Optique     computeOptic
   # ::collector::getCamSpec                 Camera      onChangeCam
   # ::collector::getTelConnexion            Monture     onChangeTelescop
   # ::collector::getSpeed                   Monture     refreshSpeed
   # ::collector::getCD                                  getSpeed, getImgCenterRaDec et createKeywords
   # ::collector::obsCoord2SiteCoord                     magic
   # ::collector::getHrzDec                  Allemande   refreshMyTel
   # ::collector::getNewCriticalFocusZone

   #--------------------- proc exploitant les mots cles -----------------------

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste de ra dec equinox naxis1 naxis2 bin1 bin2 xpixsz ypixsz crota2 crval1 crval2 crpix1 crpix2 pixsize1 pixsize2 ou des valeurs par défaut
   #
   proc ::collector::getImgData { bufNo } {

      set naxis1 [expr {[lindex [buf$bufNo getkwd NAXIS1] 1]}]
      if {$naxis1 eq ""} {set naxis1 1}

      set naxis2 [expr {[lindex [buf$bufNo getkwd NAXIS2] 1]}]
      if {$naxis2 eq ""} {set naxis2 1}

      set crota2 [expr {[lindex [buf$bufNo getkwd CROTA2] 1]}]
      if {$crota2 eq ""} {
         set crota2 0
         buf$bufNo setkwd [list CROTA2 $crota2 double "\[deg\] position angle of North" deg]
      }

      set cdelt1 [expr {[lindex [buf$bufNo getkwd CDELT1] 1]}]
      if {$cdelt1 eq ""} {set cdelt1 "-"}

      set cdelt2 [expr {[lindex [buf$bufNo getkwd CDELT2] 1]}]
      if {$cdelt2 eq ""} {set cdelt2 "-"}

      set crpix1 [expr {[lindex [buf$bufNo getkwd CRPIX1] 1]}]
      if {$crpix1 eq ""} {set crpix1 "-"}

      set crpix2 [expr {[lindex [buf$bufNo getkwd CRPIX2] 1]}]
      if {$crpix2 eq ""} {set crpix2 "-"}

      set crval1 [expr {[lindex [buf$bufNo getkwd CRVAL1] 1]}]
      if {$crval1 eq ""} {set crval1 "-"}

      set crval2 [expr {[lindex [buf$bufNo getkwd CRVAL2] 1]}]
      if {$crval2 eq ""} {set crval2 "-"}

      set bin1 [expr {[lindex [buf$bufNo getkwd BIN1] 1]}]
      if {$bin1 eq ""} {set bin1 1}

      set bin2 [expr {[lindex [buf$bufNo getkwd BIN2] 1]}]
      if {$bin2 eq ""} {set bin2 1}

      set equinox [expr {[lindex [buf$bufNo getkwd EQUINOX] 1]}]
      if {$equinox eq ""} {set equinox "J2000.0"}

      set xpixsz [expr {[lindex [buf$bufNo getkwd XPIXSZ] 1]}]
      if {$xpixsz eq ""} {set xpixsz "-"}

      set ypixsz [expr {[lindex [buf$bufNo getkwd YPIXSZ] 1]}]
      if {$ypixsz eq ""} {set ypixsz "-"}

      set pixsize1 [expr {[lindex [buf$bufNo getkwd PIXSIZE1] 1]}]
      if {$pixsize1 eq ""} {
         if {$bin1 ne "" && $xpixsz ne "-"} {
            set pixsize1 [expr { $xpixsz * $bin1 }]
         } else {
            set pixsize1 "-"
         }
      }

      set pixsize2 [expr {[lindex [buf$bufNo getkwd PIXSIZE2] 1]}]
      if {$pixsize2 eq ""} {
         if {$bin2 ne "" && $ypixsz ne "-"} {
            set pixsize2 [expr { $ypixsz * $bin2 }]
         } else {
            set pixsize2 "-"
         }
      }

      set ra [expr {[lindex [buf$bufNo getkwd RA] 1]}]
      if {$ra eq ""} {set ra "-"}

      set dec [expr {[lindex [buf$bufNo getkwd DEC] 1]}]
      if {$dec eq ""} {set dec "-"}

      #--   recalcule les coordonnees au centre de l'immage
      set result [getImgCenterRaDec $naxis1 $naxis2 $crota2 $cdelt1 $cdelt2 $crpix1 $crpix2 $ra $dec]
      lassign $result crpix1 crpix2 crval1 crval2

      set ra [mc_angle2hms $crval1 360 zero 2 auto string]
      set dec [mc_angle2dms $crval2 90 zero 2 + string]

      set result [list $ra $dec $equinox $naxis1 $naxis2 $bin1 $bin2 $xpixsz $ypixsz \
         $crota2 $crval1 $crval2 $crpix1 $crpix2 $pixsize1 $pixsize2]

      return $result
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return la position GPS au format home
   #
   proc ::collector::getTelPosition { bufNo } {

      set tel_gps "-"

      set obs_elev [expr {[lindex [buf$bufNo getkwd OBS-ELEV] 1]}]
      set obs_lat [expr {[lindex [buf$bufNo getkwd OBS-LAT] 1]}]
      set obs_long [expr {[lindex [buf$bufNo getkwd OBS-LONG] 1]}]

      if {$obs_elev ne "" && $obs_lat ne "" && $obs_long ne "" } {

         if {$obs_long > 0} {
            set sens E
         }  else {
            set obs_long [expr {-1.*$obs_long}]
            set sens W
         }
         set tel_gps "GPS $obs_long $sens $obs_lat $obs_elev"

      } else {

         set siteelev [lindex [buf$bufNo getkwd SITEELEV] 1]
         set sitelat [lindex [buf$bufNo getkwd SITELAT] 1]
         set sitelong [lindex [buf$bufNo getkwd SITELONG] 1]

         if {$siteelev ne "" && $sitelat ne "" && $sitelong ne ""} {
            #--   extrait E ou W
            set sens [string index $sitelong 0]
            #--   transforme la longitude en angle
            set sitelong [string range $sitelong 1 end]
            set longitude [mc_angle2deg $sitelong]

            #--   transforme la latitude en angle
            set sitelat [string range $sitelat 1 end]
            set latitude [mc_angle2deg $sitelat]

            set tel_gps "GPS $longitude $sens $latitude $siteelev"
         }
      }

      return $tel_gps
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #
   #          s'applique aux images Tarot et aux autres
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste de la durée d'exposition et la date (temps julien) du milieu de la pose
   #
   #  la durée d'exposition vaut 1 si pas defini ou =0 ; datejd = "" si pas DATE-OBS
   #
   proc ::collector::getDateExposure { bufNo } {

      set exposure [lindex [buf$bufNo getkwd EXPOSURE] 1]
      if {$exposure eq ""} {
         set exposure [lindex [buf$bufNo getkwd EXPTIME] 1]
         if {$exposure eq ""} {
            set exposure 1
         }
      }

      set date-obs [lindex [buf$bufNo getkwd DATE-OBS] 1]
      if { ${date-obs} ne "" } {
         set datejd [mc_datescomp ${date-obs} + [expr $exposure/2./86400.]]
      } else {
         set date-obs "-"
         set datejd "-"
      }

      return [list $exposure ${date-obs} $datejd ]
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste de la température °C, température de rosée °C, hygrométrie %, direction (degrés) et vitesse du vent (m/s), pression atmosphérique Pa
   #
   proc ::collector::getTPW { bufNo } {

      set temperature    [lindex [buf$bufNo getkwd TEMP] 1]
      if {$temperature eq ""} {
         set temperature [lindex [buf$bufNo getkwd TEMPAIR] 1]
         if {$temperature eq ""} {
            set temperature [expr {290-273.15}]
         }
      }
      set temperature [format %0.2f $temperature]

      set temprose [lindex [buf$bufNo getkwd TEMPROSE] 1]
      if {$temprose eq ""} {set temprose "-"}

      set humidity [lindex [buf$bufNo getkwd HUMIDITY] 1]
      if {$humidity eq ""} {
         set humidity [lindex [buf$bufNo getkwd HYGRO] 1]
         if {$humidity eq ""} {
            set humidity [lindex [buf$bufNo getkwd HYDRO] 1]
            if {$humidity eq ""} {
               set humidity "0"
            }
         }
      }

      set winddir [lindex [buf$bufNo getkwd WINDDIR] 1]
      if {$winddir eq ""} {set winddir "-"}

      set windsp [lindex [buf$bufNo getkwd WINDSP] 1]
      if {$windsp eq ""} {set windsp "-"}

      set pressure [lindex [buf$bufNo getkwd PRESSURE] 1]
      if {$pressure eq ""} {
         set pressure [lindex [buf$bufNo getkwd AIRPRESS] 1]
         if {$pressure ne ""} {
            set unit [string trim [lindex [buf$bufNo getkwd AIRPRESS] 4]]
            if {$unit eq "hPa"} {
               set pressure [expr {$pressure*100}]
            }
         } else {
            set pressure 101325
         }
      }

      return [list $temperature $temprose $humidity $windsp $winddir $pressure]
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste du nom du télescope, diamètre, longueur focale, F/D et filtre
   #
   proc ::collector::getKwdOptic { bufNo } {

      set aptdia [lindex [buf$bufNo getkwd APTDIA] 1]
      if {$aptdia eq ""} {set aptdia "-"}

      set filter [string trim [lindex [buf$bufNo getkwd FILTER] 1]]
      if {$filter eq ""} {set filter "C"}

      set foclen [lindex [buf$bufNo getkwd FOCLEN] 1]
      if {$foclen eq ""} {
         set foclen "-"
      } else {
         set foclen [format %0.3f $foclen]
      }

      set telescop [lindex [buf$bufNo getkwd TELESCOP] 1]
      if {$telescop eq ""} {set telescop "-"}

      #--   definition de APTDIA pour les telescopes Tarot
      if {$aptdia eq "-" && ($telescop eq "TAROT CALERN" || $telescop eq "TAROT CHILI")} {
         set aptdia 0.250
      }
      if {$aptdia ne "-"} {set aptdia [format %0.3f $aptdia]}

      return [list $telescop $aptdia $foclen $filter]
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #
   #          s'applique aux images Tarot et aux autres
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste du nom de la cam à partir de CAMERA, DETNAM ou INSTRUME ou un tiret, xpixsz et ypixsz
   #
   proc ::collector::getCamName { bufNo } {

      set cam "-"

      foreach kwd [list CAMERA DETNAM INSTRUME] {
         set data [buf$bufNo getkwd $kwd]
         if {[lindex $data 0] ne ""} {
               #--   des fois que le nom soit un string avec des espaces
               set detnam [string trimleft [lindex $data 1] " "]
               set detnam [string trimright $detnam " "]
               if {$detnam ne ""} {
                  set cam $detnam
                  break
               }
         }
      }

      if {$cam ne "-"} {
         if {$cam in [etc_set_camera]} {
            #--
         } else {
            if {[string first DV436 $cam] ne "-1"} {
               set cam  "Andor DW436"
            }
         }
      }

      set xpixsz [lindex [buf$bufNo getkwd XPIXSZ] 1]
      set ypixsz [lindex [buf$bufNo getkwd YPIXSZ] 1]
      if {$xpixsz eq ""} {set xpixsz "-"}
      if {$ypixsz eq ""} {set ypixsz "-"}

      return [list $cam $xpixsz $ypixsz]
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste du nom de l'observateur et du nom du site
   #
   proc ::collector::getObserv { bufNo } {

      set observer [lindex [buf$bufNo getkwd OBSERVER] 1]
      if {$observer eq ""} {set observer "-"}
      set sitename [lindex [buf$bufNo getkwd SITENAME] 1]
      if {$sitename eq ""} {set sitename "-"}

      return [list $observer $sitename]
   }

   #------------------------------------------------------------
   #  brief  exploite l'entête d'une image dans la visu
   #  param  bufNo numéro du buffer contenant l'image
   #  return liste du type d'image et du nom de l'objet
   #
   proc ::collector::getObject { bufNo } {

      set imagetyp [lindex [buf$bufNo getkwd IMAGETYP] 1]
      if {$imagetyp eq ""} {set imagetyp "-"}
      set objname [lindex [buf$bufNo getkwd OBJNAME] 1]
      if {$objname eq ""} {set objname "-"}

      return [list $imagetyp $objname]
   }

   #--------------------- proc de calcul --------------------------------------

   #------------------------------------------------------------
   #  brief calcule Ra et Dec J2000.0 formatées
   #  details contenu du paramère "record" :
   #  - deux coordonnees et TypeObs, couples :  {ra dec} EQUATORIAL ou {az elev} ALTAZ ou {hour_angle dec} HADEC
   #  - dateTU                   : date TU
   #  - home                     : position GPS
   #  - pressin atmosphérique    : pression atmosphérique (Pa)
   #  - température              : °C
   #  - humidité                 : % (en absence -> par defaut =0%, mieux 40%)
   #  param record liste unique (CF liste ci-dessus)
   #  return liste ra2000 (hms) dec2000 (dms)
   #
   proc ::collector::getCoordJ2000 { record } {

      lassign $record angle1 angle2 TypeObs dateTu home pressure temperature humidity

      #--   pm avec les options -model_only 1 -refraction 1, les coordonnees sont corrigees de
      #  la nutation, de l'aberration diurne, de la precession, de l'aberration annuelle et de le refraction
      #set symbols  { IH ID NP CH ME MA FO HF DAF TF }
      #set nulCoeff [list 0 0 0 0 0 0 0 0 0 0]

      #--   passe en °K
      set temperature [expr { $temperature+273.15 }]
      lassign [mc_tel2cat [list $angle1 $angle2] $TypeObs $dateTu $home $pressure $temperature -model_only 1 -refraction 1 -humidity $humidity] \
         raDeg decDeg

      set ra2000 [mc_angle2hms $raDeg 360 zero 2 auto string]
      set dec2000 [mc_angle2dms $decDeg 90 zero 2 + string]

      return [list $ra2000 $dec2000]
   }

   #------------------------------------------------------------
   #  brief retourne AD, DEC, azimuth, élévation et angle horaire à viser par le télescope
   #  details dérive de viseur_polaire_taka.tcl/viseurPolaireTaka/HA_Polaire
   #  param data         liste de coordonnées J2000.0, date JD, position GPS, pression atmosphérique (Pa), température (°C),  humidité % (en absence -> par defaut =0%, mieux 40%)
   #  param coefNames    liste des noms des coefficients de modpoi (mode ALTAZ : {IA IE NPAE CA AN AW} ou EQUATORIAL : {IH ID NP CH ME MA FO HF DAF TF}
   #  param coefValues   liste des valeurs des coefficients ci-dessus (en arcmin) ; par défaut les valeurs sont nulles {0 0 0 0 0 0 0 0 0 0}
   #  return liste des coordonnées corrigées raTel (hms) decTel (dms) haTel (degrés) azTel (degrés) elevTel (degrés)
   #
   #  Note définitions des codes pour EQUATORIAL :
   #- IH         : Décalage du codeur H
   #- ID         : Décalage du codeur D
   #- NP         : Non perpendicularité H/D
   #- CH         : Erreur de collimation
   #- ME         : Désalignement N/S de l'axe polaire
   #- MA         : Désalignement E/O de l'axe polaire
   #- FO         : Flexion de la fourche ; Fork Flexure
   #- MT  (=HF?) : Flexion de la monture ; Mount Flexure
   #- DAF        : Flexion de l'axe delta ; Delta Axis Flexure
   #- TF         : Flexion du tube optique ; Tube Flexure
   #
   proc ::collector::getTrueCoordinates { data {coefNames {IH ID NP CH ME MA FO HF DAF TF} } { coefValues {0 0 0 0 0 0 0 0 0 0} } } {

      #--   reponse par defaut
      lassign [list - - - - -] raTel decTel haTel azTel elevTel

      lassign $data ra_hms dec_dms datejd home pressure temperature humidity

      #::console::disp "$ra_hms $dec_dms $datejd\n"

      set hipRecord [list 1 1 [mc_angle2deg $ra_hms] [mc_angle2deg $dec_dms 90] J2000.0 J2000.0 0 0 0]
      set drift 0
      #--   passe en °K
      set temperature [expr { $temperature+273.15 }]
      set result [mc_hip2tel $hipRecord $datejd $home $pressure $temperature \
         $coefNames $coefValues -model_only 1 -refraction 1 -drift $drift -humidity $humidity]
      lassign [lrange $result 10 14] ra_angle dec_angle ha az elev

      #--- formate les resultats
      if {$ra_angle ni [list "-1.#IND" "1.#QNAN"]} {
         set raTel [mc_angle2hms $ra_angle 360 zero 2 auto string]
         set decTel [mc_angle2dms $dec_angle 90 zero 2 + string]
         set haTel [format "%0.4f" $ha]
         set azTel [format %.2f $az]
         set elevTel [format %.2f $elev]
      }

      return [list $raTel $decTel $haTel $azTel $elevTel]
   }

   #------------------------------------------------------------
   #  brief calcule cdelt et fov en x et en y
   #  details dérive de surchaud.tcl/simulimage
   #  param naxis1 nombre de pixels en x dans l'image
   #  param naxis2 nombre de pixels en y dans l'image
   #  param pixsize1 dimension des pixels en x (avec bining) en mum
   #  param pixsize2 dimension des pixels en y (avec bining) en mum
   #  param foclen  longueur (focale en m)
   #  return liste de cdeltx cdelty (en arcsec/pixel) fovx fovy (en degrés)
   #
   proc ::collector::getCdeltFov { naxis1 naxis2 pixsize1 pixsize2 foclen } {

      #--   test OR
      if {"-" in [list $naxis1 $naxis2 $pixsize1 $pixsize2 $foclen]} {
         return [lrepeat 4 -]
      }

      set factor [expr { 360. / (4*atan(1.)) }]

      set tgx [expr { $pixsize1 * 1e-6 / $foclen / 2. }]
      set tgy [expr { $pixsize2 * 1e-6 / $foclen / 2. }]

      set cdeltx [expr { -atan ($tgx) * $factor * 3600. }]
      set cdelty [expr { atan ($tgy) * $factor * 3600. }]

      set fovx [expr { atan ( $naxis1 * $tgx ) * $factor }]
      set fovy [expr { atan ( $naxis2 * $tgy ) * $factor }]

      return [list $cdeltx $cdelty $fovx $fovy]
   }

   #------------------------------------------------------------
   #  brief retourne la liste des coordonnées RaDec du centre de l'image
   #  details dérive de sn_tarot_macros.tcl/getImgCenterRaDec
   #  param naxis1 valeurs des mots cles de l'entête
   #  param naxis2 valeurs des mots cles de l'entête
   #  param crota2 valeurs des mots cles de l'entête (degrés)
   #  param cdelt1 valeurs des mots cles de l'entête
   #  param cdelt2 valeurs des mots cles de l'entête
   #  param crpix1 valeurs des mots cles de l'entête
   #  param crpix2 valeurs des mots cles de l'entête
   #  param ra     valeurs des mots cles de l'entête (degrés)
   #  param dec    valeurs des mots cles de l'entête (degrés)
   #  return liste des coordonnées du center_x, center_y, ra et dec
   #
   proc ::collector::getImgCenterRaDec { naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 ra dec } {

      #--   test OR
      if {"-" in [list $naxis1 $naxis2 $crota2 $cdelt1 $cdelt2 $crpix1 $crpix2 $ra $dec]} {
         return [lrepeat 4 -]
      }

      set crval1 [mc_angle2deg $ra]
      set crval2 [mc_angle2deg $dec]

      set pi [ expr { 4 * atan(1) } ]

      set center_x [ expr { $naxis1 / 2. }]
      set center_y [ expr { $naxis2 / 2. }]

      lassign [::collector::getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2

      set dra  [expr { $cd1_1 * ($center_x - ($crpix1-0.5)) + $cd1_2 * ($center_y - ($crpix2-0.5)) }]
      set ddec [expr { $cd2_1 * ($center_x - ($crpix1-0.5)) + $cd2_2 * ($center_y - ($crpix2-0.5)) }]

      set coscrval2 [expr { cos( $crval2 * $pi / 180. ) }]
      set sincrval2 [expr { sin( $crval2 * $pi / 180. ) }]

      set delta [expr { $coscrval2 - $ddec * $sincrval2 }]
      set gamma [expr { hypot($dra,$delta) }]

      set ra [expr { $crval1 + 180./ $pi * atan( $dra / $delta ) }]
      set dec [expr { 180. / $pi * atan( ( $sincrval2 + $ddec* $coscrval2 ) / $gamma ) }]

      return [list $center_x $center_y $ra $dec]
   }

   #------------------------------------------------------------
   #  brief  retourne le code match_wcs et les valeurs pour simulimage
   #  details surchaud.tcl/simulimage
   #  param  ra
   #  param  dec
   #  param  pixsize1
   #  param  pixsize2
   #  param  foclen
   #  param  cdelt1
   #  param  cdelt2
   #  param  crpix1
   #  param  crpix2
   #  param  crval1
   #  param  crval2
   #  return matchwcs formaté
   #
   proc ::collector::getMatchWCS { ra dec pixsize1 pixsize2 foclen cdelt1 cdelt2 crpix1 crpix2 crval1 crval2 } {

      set  match_wcs 0

      if {$foclen ne ""} {
         if {"-" ni [list $cdelt1 $cdelt2 $crpix1 $crpix2 $crval1 $crval2]} {
            #--   contient tous les mots cles WCS pour simulimage * * * * *
            set  match_wcs [list 2 * * * * * ]
         } else {
            if {"-" ni [list $ra $dec $pixsize1 $pixsize2]} {
               #--   peut etre traite par simulimage mais il faut passer les parametres
               set match_wcs [list 1 $ra $dec $pixsize1 $pixsize2 $foclen]
            }
         }
      }

      return $match_wcs
   }

   #------------------------------------------------------------
   #  brief  date TU et JD correctement formatées
   #  param  date date TU
   #  return liste de TU et JD
   #
   proc ::collector::getDateTUJD { date } {

      set tu [mc_date2iso8601 $date]
      set jd [mc_date2jd $tu]

      return [list $tu $jd]
   }

   #------------------------------------------------------------
   #  brief  calcule temps sidéral local
   #  param  datetu date TU
   #  param  home coordonnées GPS
   #  return temps sidéral local formaté (dms)
   #
   proc ::collector::getTsl { datetu home } {

      set tsl "-"

      if {"-" ni [list $datetu $home]} {
         lassign [mc_date2lst $datetu $home -format hms] h m s
         set tsl [format "%02dh%02dm%02ds" $h $m [expr {int($s)}]]
      }

      return $tsl
   }

   #------------------------------------------------------------
   #  brief  calcule "l'âge" de la Lune en fonction du lieu et de la date de prise de vue
   #  param  datejd date JD
   #  param  home position GPS
   #  return liste de la phase, de l'élévation et moon_age
   #
   proc ::collector::getMoonAge { datejd home } {

      if {"-" in [list $datejd $home]} {return [list - - 0]}

      #--   calcule l'ephemeride de la Lune
      lassign [lindex [mc_ephem moon $datejd {PHASE ALTITUDE} -topo $home] 0] phase elev

      #--   calcule l'age de la lune
      set moon_age 0
      if {$elev > 0} {
         set moon_age [expr {(180-$phase)/180.*14.}]
      }
      foreach v [list phase elev moon_age] {
         set $v [format %.2f [set $v]]
      }

      return [list $phase $elev $moon_age]
   }

   #------------------------------------------------------------
   #  brief  calcule secz et airmass
   #  param  elev élévation du télescope (corrigée de le réfraction, etc.)
   #  return liste de secz et airmass ou un tiret pour une valeur vide
   #
   proc ::collector::getSecz { elev } {

      lassign [list -1 -1] secz airmass

      set elev_deg [mc_angle2deg $elev]

      if {$elev_deg > 0} {
         set z [expr {90.-$elev_deg}]
         set z [mc_angle2rad $z]
         set secz [expr {1./cos($z)}]
         set airmass [expr { $secz-0.0018167*$secz+0.02875*$secz*$secz+0.0008083*$secz*$secz*$secz }]
         set secz [format %0.3f $secz]
         set airmass [format %0.3f $airmass]
      }

      return [list $secz $airmass]
   }

   #------------------------------------------------------------
   #  brief  retourne F/D et la résolution ou un tiret pour une valeur vide
   #  details inspiré de confoptic.tcl/Calculette
   #  param  aptdia  diamètre en m
   #  param  foclen  longueur focale en m
   #  return liste de F/D et la résolution ou un tiret pour une valeur vide
   #
   proc ::collector::getFonDResolution { aptdia foclen } {

      if {$aptdia > 0 && $foclen > 0} {
         set fond [format %.2f [expr {$foclen*1./$aptdia}]]
         set resolution [format %.3f [expr {0.120/$aptdia}]]
      } else {
         #--   valeurs par defaut
         lassign [list - -] fond resolution
      }

      return [list $fond $resolution]
   }

   #------------------------------------------------------------
   #  brief  retourne le nom de la caméra connectée et les dimensions du capteur et des pixels
   #  param  visuNo numéro de la visu
   #  return liste du nom de la cam, de son item, du nombre de pixels en x et y et des dimensions des pixels
   #
   proc ::collector::getCamSpec { {visuNo 1} } {

      set camItem [::confVisu::getCamItem $visuNo]
      set camNo  [::confCam::getCamNo $camItem]
      if {$camNo == 0} {return [lrepeat 5 -]}

      lassign [cam$camNo info] -> camName detector
      lassign [cam$camNo nbpix] naxis1 naxis2
      lassign [cam$camNo celldim] celldim1 celldim2
      set photocell1 [expr { $celldim1 * 1e6 }]
      set photocell2 [expr { $celldim2 * 1e6 }]

      return [list $camName $camItem $naxis1 $naxis2 $photocell1 $photocell2]
   }

   #------------------------------------------------------------
   #  brief  évalue les propriétés du télescope
   #  param  telNo numéro du télescope
   #  return liste de product, nom et des propriétés hasCoordinates et hasControlSuivi
   #
   proc ::collector::getTelConnexion { telNo } {
      global conf caption

      lassign [list - - 0 0 0] product name hasCoordinates hasControlSuivi

      if {$telNo != 0} {

         #--   passe en minuscules
         set product [string tolower [tel$telNo product]]
         #--   supprime les espaces dans 'delta tau'
         set product [string map -nocase [list " " ""] $product]

         foreach propertyName [list name hasCoordinates hasControlSuivi] {
            set $propertyName [::${product}::getPluginProperty $propertyName]
         }

         if {[::${product}::getPluginProperty hasModel] == 1} {
            switch -exact $name {
               ASCOM {  set model [lindex $conf(ascom,modele) 1 ]}
               LX200 {  set model $conf(lx200,modele)}
               Temma {  set modelNo $conf(temma,modele)
                        incr modelNo
                        set model $caption(temma,modele_$modelNo)
                     }
            }
            append name " ($model)"
         }
      }

      return [list $product "$name" $hasCoordinates $hasControlSuivi]
   }

   #------------------------------------------------------------
   #  brief  calcule les vitesse de déplacement
   #  param  deltaRA   variation de RA en degrés
   #  param  deltaDEC  variation de DEC en degrés
   #  param  deltaTime variation de temps en secondes
   #  param  cdelt1    (degrés/pixel)
   #  param  cdelt2    (degrés/pixel)
   #  param  crota2    (degrés)
   #  return liste des vitesses de déplacement en deg/sec et en pix/sec
   #
   proc ::collector::getMountSpeed { deltaRA deltaDEC deltaTime cdelt1 cdelt2 crota2 } {

      set vra [expr { $deltaRA/$deltaTime }]
      set vdec [expr { $deltaDEC/$deltaTime }]

       #--   initialisation
      lassign [list 0 0] vxPix vyPix

      if {"-" ni [list $cdelt1 $cdelt2 $crota2]} {
         #--   repasse en degres
         set cdelt1 [expr { $cdelt1 / 3600. }]
         set cdelt2 [expr { $cdelt2 / 3600. }]
         lassign [::collector::getCD $cdelt1 $cdelt2 $crota2] cd1_1 cd1_2 cd2_1 cd2_2
         if {$cd1_1 !=0} {set vxPix [expr { $vxPix + ($vra / $cd1_1) }]}
         if {$cd1_2 !=0} {set vxPix [expr { $vxPix + ($vdec / $cd1_2) }]}
         if {$cd2_1 !=0} {set vyPix [expr { $vyPix + ($vra / $cd2_1) }]}
         if {$cd2_2 !=0} {set vyPix [expr { $vyPix + ($vdec / $cd2_2) }]}
      }

      return [list $vra $vdec $vxPix $vyPix]
   }

   #------------------------------------------------------------
   #  brief  calcule les coefficients CD
   #  details dérive de sn_tarot_macros.tcl/getImgCenterRaDec
   #  param  cdelt1 (degrés/pixel)
   #  param  cdelt2 (degrés/pixel)
   #  param  crota2 (degrés)
   #  return liste cd1_1 cd1_2 cd2_1 cd2_2 en degré/pixel
   #
   proc ::collector::getCD { cdelt1 cdelt2 crota2 } {

      set factor [expr { 4 * atan(1) / 180. } ]
      set coscrota2 [expr { cos($crota2 * $factor ) }]
      set sincrota2 [expr { sin($crota2 * $factor ) }]

      set cd1_1 [expr { $cdelt1 * $coscrota2 }]
      set cd1_2 [expr { abs($cdelt2) * $cdelt1 / abs($cdelt1) * $sincrota2 }]
      set cd2_1 [expr { -abs($cdelt1) * $cdelt2 / abs($cdelt2) * $sincrota2 }]
      set cd2_2 [expr { $cdelt2 * $coscrota2 }]

      return [list $cd1_1 $cd1_2 $cd2_1 $cd2_2]
   }

   #------------------------------------------------------------
   #  brief  calcule les valeurs des mots clés SITExxxx
   #  param  home position GPS
   #  return liste de sitelong sitelat siteelev
   #
   proc ::collector::obsCoord2SiteCoord { home } {

      lassign $home -> obs-long sens obs-lat siteelev

      set sitelong [mc_angle2dms ${obs-long} 180 zero 2 auto string]
      set sitelong $sens$sitelong

      set sitelat [mc_angle2dms ${obs-lat} 90 zero 2 auto string]
      if {${obs-lat} >0} {
         set sitelat "N${sitelat}"
      } else {
         set sitelat [expr {-1*${obs-lat}}]
         set sitelat [mc_angle2dms ${obs-lat} 90 zero 2 auto string]
         set sitelat "S$sitelat"
      }

      return [list $sitelong $sitelat $siteelev]
   }

   #------------------------------------------------------------
   #  brief  calcule la zone de mise au point au point du télescope
   #  param  fond   F/D
   #  param  aptdia diamètre (m)
   #  param  seeing seeing (arcsec)
   #  param  error  erreur% sur le seeing
   #  return retourne la zone (um)
   #
   proc ::collector::getNewCriticalFocusZone { fond aptdia seeing error } {

      set ncfz "-"
      if {$fond ne "-" && $aptdia ne "-"} {
         set constante 0.00225 ; # micrometers/arc second/millimeter
         set ncfz [format %0.1f [expr { $constante*$seeing*sqrt($error)*$fond*$fond*$aptdia*1000 } ]] ;#-- mum : micron
      }

      return $ncfz
   }


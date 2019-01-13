#
## @file catalog_tools.tcl
#  @brief Tools for reading catalogs
#  @author Alain KLOTZ
#  $Id: catalog_tools.tcl 14282 2017-11-05 17:27:17Z alainklotz $
#

# source "$audace(rep_install)/gui/audace/catalog_tools.tcl"
#

#--------------------------------------------------
## @brief fonction qui ajoute des ronds des sources du catalogue par dessus une image affichée dans le buffer de la visu
#  @details
#  - cette fonction peut être utilisée avec les catalogues USNOA2|TYCHO2|TYCHO2_Fast|UCAC4|NOMAD1 qui donnent la magnitude R et la magnitude B
#  - le nom du catalogue est accepté en majuscules ou en minuscules
#  @code
#  catalog_overlay USNOA2 Path_of_Catalog mag_faint
#  @endcode
#  @param cat_format cat_folder mag_faint
#
proc catalog_overlay { cat_format cat_folder mag_faint } {
   global audace
   set stars [catalog2buf * * * * * $cat_format $cat_folder -conv_sigma 0 -mag_faint $mag_faint]
   catch {
      #--- Efface les reperes des objets
      $audace(hCanvas) delete catalog_overlay
   }
   foreach star $stars {
      lassign $star ra dec magr x y val
      set can_xy [ ::audace::picture2Canvas [list $x $y] ]
      set x [lindex $can_xy 0]
      set y [lindex $can_xy 1]
      if {$val>10} { set val 10 }
      set radius $val
      set color #FF0000
      set width 2
      $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] -outline $color -tags catalog_overlay -width $width
   }
}

#--------------------------------------------------
## @brief fonction de création d'une image des sources du catalogue dans le buffer de la visu
#  @details
#  - cette fonction peut être utilisée avec les catalogues USNOA2|TYCHO2|TYCHO2_Fast|UCAC4|NOMAD1 qui donnent la magnitude R et la magnitude B
#  - le nom du catalogue est accepté en majuscules ou en minuscules
#  - la date "now" est utilisée en interne
#  @code
#  catalog2buf ra dec pixsize1 pixsize2 foclen USNO Path_of_Catalog
#  ou en utilisant les mots cles du header de l'image :
#  catalog2buf * * * * * USNOA2 Path_of_Catalog
#  ou en combinant :
#  catalog2buf ra * * * foclen USNOA2 Path_of_Catalog
#  Options éventuelles :
#  -mag_faint -mag_bright -zmag -crota2 -naxis1 -naxis2 -conv_sigma -debug accompagnées de leur valeur
#  @endcode
#  @param args arguments (CF ci-dessus)
#
proc catalog2buf {args} {
   global audace

   set bufNo $::audace(bufNo)
   set argc [llength $args]
   set listonly 0

   if {$argc >= 5} {

      #--- Lecture des arguments de la ligne de commande
      set Angle_ra    [lindex $args 0]
      set Angle_dec   [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen   [lindex $args 4]
      set cat_format  [lindex $args 5]
      set cat_folder  [lindex $args 6]
      set mag_faint   10
      set mag_bright  -10
      set zmag *
      set crota2 0
      set conv_sigma 2
      set debug 0
      set naxis1 [lindex [buf$bufNo getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$bufNo getkwd NAXIS2] 1]

      if {$argc > 7} {

         #--  isole les options
         set options [lrange $args 7 end]

         #--  si elles sont en paires (option valeur)
         if {[expr { fmod([llength $options],2) }] =="0.0"} {
            set keyList [list mag_faint mag_bright zmag \
               crota2 naxis1 naxis2 conv_sigma debug]
            #--   recherche les options
            foreach key $keyList {
               set index [lsearch -exact $options -$key]
               if {$index ne "-1"} {
                  set $key [lindex $options [incr index]]
               }
            }
         } else {
            console::affiche_erreur "Les paramètres optionels doivent être des paires \"-option valeur\"\n"
         }
      }
      if {$zmag=="*"} {
         set zmag $mag_faint
      }
      if {$conv_sigma<=0} {
         set listonly 1
      }

      #--- Dimension de l'image
      if {($naxis1==0)||($naxis2==0)} {
         error "Use the options -naxis1 and -naxis2 to define the size of the image"
      }

      #--- Lecture des parametres WCS de la ligne de commande et conversion vers le buffer
      set etoile 0

      if {$Angle_ra=="*"} {
         set crpix1 [lindex [buf$bufNo getkwd CRPIX1] 1]
         set Angle_ra [lindex [buf$bufNo getkwd CRVAL1] 1]
         incr etoile
      } else {
         set ra [mc_angle2deg $Angle_ra 360]
         buf$bufNo setkwd [list CRVAL1 $ra double "RA for CRPIX1" "deg"]
         set crpix1 [expr $naxis1/2]
         buf$bufNo setkwd [list CRPIX1 $crpix1 float "X ref pixel" "pixel"]
      }

      if {$Angle_dec=="*"} {
         set crpix2 [lindex [buf$bufNo getkwd CRPIX2] 1]
         set Angle_dec [lindex [buf$bufNo getkwd CRVAL2] 1]
         incr etoile
      } else {
         set dec [mc_angle2deg $Angle_dec 90]
         buf$bufNo setkwd [list CRVAL2 $dec double "DEC for CRPIX2" "deg"]
         set crpix2 [expr $naxis2/2]
         buf$bufNo setkwd [list CRPIX2 $crpix2 float "Y ref pixel" "pixel"]
      }

      if {$valpixsize1=="*"} {
         set valpixsize1 [lindex [buf$bufNo getkwd PIXSIZE1] 1]
         incr etoile
      } else {
         buf$bufNo setkwd [list PIXSIZE1 $valpixsize1 float "X pixel size binning included" "mum"]
      }

      if {$valpixsize2=="*"} {
         set valpixsize2 [lindex [buf$bufNo getkwd PIXSIZE2] 1]
         incr etoile
      } else {
         buf$bufNo setkwd [list PIXSIZE2 $valpixsize2 float "Y pixel size binning included" "mum"]
      }

      if {$valfoclen=="*"} {
         set valfoclen [lindex [buf$bufNo getkwd FOCLEN] 1]
         incr etoile
      } else {
         buf$bufNo setkwd [list FOCLEN $valfoclen float "Focal length" "m"]
      }

      if {$etoile==0} {
         #--- Creation des parametres WCS du buffer a partir des mots cle d'optique
         if {$debug==1} {
            console::affiche_resultat "wcs_optic2wcs $crpix1 $crpix2 $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen $crota2\n"
         }
         set wcs [wcs_optic2wcs $crpix1 $crpix2 $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen $crota2]
      } else {
         #--- Lecture des parametres WCS du buffer
         set wcs [wcs_buf2wcs $bufNo]
      }
      #wcs_dispkwd $wcs "" public
      #return

      #--- Calcul du champ diagonal de l'image
      lassign [wcs_p2radec $wcs 1 1] ra1 dec1
      lassign [wcs_p2radec $wcs $naxis1 $naxis2] ra2 dec2
      lassign [mc_sepangle $ra1 $dec1 $ra2 $dec2] fov_deg posangle
      set fov_arcmin [expr $fov_deg*60]
      set radius_arcmin [expr $fov_arcmin/2.]

      #--- Calcul des coordonnées du centre de l'image
      lassign [wcs_p2radec $wcs [expr $naxis1/2.] [expr $naxis2/2.]] ra dec

      #--   passage eventuel en minsucules pour la commade cs
      set catalog [string tolower $cat_format]

      # --- Crée une image vide
      if {$listonly==0} {
         buf$bufNo new CLASS_GRAY $naxis1 $naxis2 FORMAT_FLOAT COMPRESS_NONE
         set dateobs  [mc_date2iso8601 now]
         set commande "buf$bufNo setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
         set err1     [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
         set err1     [catch {eval $commande} msg]
         set commande "buf$bufNo setkwd \{ \"TELESCOP\" \"$cat_format\" \"string\" \"${catalog} simulation\" \"\" \}"
         set err1     [catch {eval $commande} msg]
         wcs_wcs2buf  $wcs $bufNo
      }

      # --- Lecture du catalogue
      set path    $cat_folder
      set nbStars 0 ; # nombre d'etoiles dans l'image

      load [file join $audace(rep_install) bin libcatalog_tcl[info sharedlibextension]]
      set command "cs${catalog} $path [mc_angle2deg $ra] [mc_angle2deg $dec 90] $radius_arcmin $mag_faint $mag_bright"
      console::affiche_resultat "$command\n"
      set res [eval $command]
      lassign $res infos stars
      if {$debug==1} {
         console::affiche_resultat "infos=$infos\n"
         console::affiche_resultat "nbstars=[llength $stars]\n"
      }
      set catalog_stars ""
      foreach star $stars {
         set star [lindex $star 0]
         set infs [lindex $star 2]
         if {$catalog=="usnoa2"} {
            set ra   [lindex $infs 1]
            set dec  [lindex $infs 2]
            set magb [lindex $infs 6]
            set magr [lindex $infs 7]
         }
         if {$catalog=="ucac4"} {
            set ra   [lindex $infs 1]
            set dec  [lindex $infs 2]
            set magb [lindex $infs 3]
            set magr [lindex $infs 4]
         }
         if {$catalog=="tycho2"} {
            set ra   [lindex $infs 28]
            set dec  [lindex $infs 29]
            set magb [lindex $infs 20]
            set magr [lindex $infs 22]
         }
         if {$catalog=="tycho2_fast"} {
            set ra   [lindex $infs 28]
            set dec  [lindex $infs 29]
            set magb [lindex $infs 20]
            set magr [lindex $infs 22]
         }
         if {$catalog=="nomad1"} {
            set ra   [lindex $infs 2]
            set dec  [lindex $infs 3]
            set magb [lindex $infs 13]
            set magr [lindex $infs 17]
         }
         lassign [buf1 radec2xy [list $ra $dec]] x y
         set val [expr pow(10,-0.4*($magr-$zmag))]

         set xx      [expr round($x)]
         set yy      [expr round($y)]

         if {$xx >=1 && $xx <= $naxis1 && $yy >= 1 && $yy <= $naxis2} {
            incr nbStars
            if {$listonly==0} {
               buf$bufNo setpix [list $xx $yy] $val
            } else {
               set catalog_star "$ra $dec $magr [format %.3f $x] [format %.3f $y] [format %.4f $val]"
               lappend catalog_stars $catalog_star
            }
            if {$debug==1} {
               console::affiche_resultat "RADEC = ($ra $dec) MAG=($magr) XY=($xx $yy) $val\n"
            }
         }
      }
      if {$listonly==1} {
         return $catalog_stars
      }

      set commande "buf$bufNo setkwd \{ \"WCSMATCH\" \"$nbStars\" \"int\" \"Nb catalog stars matched\" \"\" \}"
      catch {eval $commande} msg

      if {$conv_sigma>0} {
         convgauss $conv_sigma
      }
      buf$bufNo bitpix float

   } else {
      # csppmxl csppmx cswfibc cstycho2 cstycho2_fast csucac2 csucac3 csucac4 cs2mass csnomad1 csusnoa2
      set line "Usage: \n"
      append line "catalog2buf Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m usnoa2|tycho2|ucac4|nomad1 cat_folder ?-mag_faint value? ?-mag_bright value?\n"
      append line "# ou en utilisant les mots cles du header de l'image :\n"
      append line "catalog2buf * * * * * usnoa2|tycho2|ucac4|nomad1 cat_folder \n"
      append line "# Parametres optionels :\n"
      append line "# -mag_bright value : Limit of the brightest stars (-10 defaut)\n"
      append line "# -mag_faint value : Limit of the faintest stars (10 defaut)\n"
      append line "# -naxis1 value : X pixel size (from buf1 by defaut)\n"
      append line "# -naxis2 value : Y pixel size (from buf1 by defaut)\n"
      append line "# -zmag value : zero point of magnitudes (=mag_faint by defaut)\n"
      append line "# -crota2 value : North position angle degrees (not used when * parameters)\n"
      append line "# -conv_sigma value : Gaussian convolution (=2.0 by defaut)\n"
      append line "# -debug value : =0 no debug (=0 by defaut)\n"
      error $line
   }
}

#--------------------------------------------------
## @brief application de catalog2buf créer l'image du pôle Nord
#  @details des informations détaillées (dont les coordonnées J2000) sont affichées dans la console
#  @param date date
#  @param home position GPS de l'observateur ou, par défaut, la valeur de audace(posobs,observateur,gps)
#  @remark les calculs sont effectués avec les paramètres suivants :
#  - température et pression atmosphérique se référant à l'altitude du lieu
#  - humidité 50%
#  - longueur d'onde 550 nm
#  - longueur focale 0.5 m
#  - capteur 1100 x 1100 pixels
#  - taille de chaque pixel 12 x 12 mum
#  - magnitude limite 18
#  - catalogue UCAC4
#  - chemin du catalog $conf(rep_userCatalogUcac4)
#
proc pole2buf { date {home ""} } {
   global audace

   if {$home==""} {
      set home $::audace(posobs,observateur,gps)
   }
   console::affiche_resultat "==== HOME\n"
   set latitude [lindex $home 3]
   set altitude [lindex $home 4]
   console::affiche_resultat "latitude = [mc_angle2dms $latitude 90 zero 1 + string]\n"
   set res [mc_altitude2tp $altitude]
   set Temperature_K [lindex $res 0]
   set Pressure_Pa [lindex $res 1]
   set refraction 1
   set wavelength 550
   set humidity 50

   # --- Apparent position of Polaris
   set ra_j2000 [mc_angle2deg 2h31m48.7s 360]
   set dec_j2000 [mc_angle2deg +89d15m51s 90]
   set ramu 44.22 ; # mas/yr
   set decmu -11.74 ; # mas/yr
   set parallax 7.56 ; # mas
   set epoch J2000
   set refraction 1
   set res [mc_hip2tel [list 1 2.5 $ra_j2000 $dec_j2000 J2000 $epoch $ramu $decmu $parallax] $date $home $Pressure_Pa $Temperature_K -refraction $refraction -humidity $humidity -wavelength $wavelength]
   lassign $res ra_app dec_app ha_app az_app elev_app
   console::affiche_resultat "==== POLARIS réfractée\n"
   console::affiche_resultat "J2000 RA,DEC = [mc_angle2hms $ra_j2000 360 zero 2 auto string] [mc_angle2dms $dec_j2000 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent RA,DEC = [mc_angle2hms $ra_app 360 zero 2 auto string] [mc_angle2dms $dec_app 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent HA = $ha_app\n"
   console::affiche_resultat "Apparent AZ,ELEV = [mc_angle2dms $az_app 360 zero 1 auto string] [mc_angle2dms $elev_app 90 zero 1 + string]\n"
   set radec_polaris [list $ra_j2000 $dec_j2000]

if {1==0} {
   # --- on calcule les coordonnées J2000 du pole a la date
   set ra_app 0
   set dec_app 90
   set az_app 180
   set elev_app $latitude
   set type ALTAZ
   set refraction 0
   if {$type=="EQUATORIAL"} {
      set res [mc_tel2cat [list $ra_app $dec_app] EQUATORIAL $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   } else {
      set res [mc_tel2cat [list $az_app $elev_app] ALTAZ $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   }
   lassign $res ra_j2000 dec_j2000

   # --- Apparent position of the pole
   set ramu 0 ; # mas/yr
   set decmu 0 ; # mas/yr
   set parallax 0 ; # mas
   set refraction 0
   set res [mc_hip2tel [list 1 2.5 $ra_j2000 $dec_j2000 J2000 now $ramu $decmu $parallax] $date $home $Pressure_Pa $Temperature_K -refraction $refraction -humidity $humidity -wavelength $wavelength]
   lassign $res ra_app dec_app ha_app az_app elev_app
   console::affiche_resultat "==== POLE sans atmosphère\n"
   console::affiche_resultat "J2000 RA,DEC = [mc_angle2hms $ra_j2000 360 zero 2 auto string] [mc_angle2dms $dec_j2000 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent RA,DEC = [mc_angle2hms $ra_app 360 zero 2 auto string] [mc_angle2dms $dec_app 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent HA = $ha_app\n"
   console::affiche_resultat "Apparent AZ,ELEV = [mc_angle2dms $az_app 360 zero 1 auto string] [mc_angle2dms $elev_app 90 zero 1 + string]\n"
}

   # --- on calcule les coordonnées J2000 du pole a la date
   set ra_app 0
   set dec_app 90
   set az_app 180
   set elev_app $latitude
   set type ALTAZ
   set refraction 0
   if {$type=="EQUATORIAL"} {
      set res [mc_tel2cat [list $ra_app $dec_app] EQUATORIAL $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   } else {
      set res [mc_tel2cat [list $az_app $elev_app] ALTAZ $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   }
   lassign $res ra_j2000 dec_j2000

   # --- Apparent position of the pole
   set ramu 0 ; # mas/yr
   set decmu 0 ; # mas/yr
   set parallax 0 ; # mas
   set refraction 1
   set res [mc_hip2tel [list 1 2.5 $ra_j2000 $dec_j2000 J2000 now $ramu $decmu $parallax] $date $home $Pressure_Pa $Temperature_K -refraction $refraction -humidity $humidity -wavelength $wavelength]
   lassign $res ra_app dec_app ha_app az_app elev_app
   console::affiche_resultat "==== POLE réfracté\n"
   console::affiche_resultat "J2000 RA,DEC = [mc_angle2hms $ra_j2000 360 zero 2 auto string] [mc_angle2dms $dec_j2000 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent RA,DEC = [mc_angle2hms $ra_app 360 zero 2 auto string] [mc_angle2dms $dec_app 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent HA = $ha_app\n"
   console::affiche_resultat "Apparent AZ,ELEV = [mc_angle2dms $az_app 360 zero 1 auto string] [mc_angle2dms $elev_app 90 zero 1 + string]\n"
   set radec_pole [list $ra_j2000 $dec_j2000]

   # --- on calcule les coordonnées J2000 du pole a la date
   set res [mc_refraction $latitude out2in $Temperature_K $Pressure_Pa $wavelength $humidity $home]
   set ra_app 0
   set dec_app 90
   set az_app 180
   set elev_app [expr $latitude-$res]
   set type ALTAZ
   set refraction 0
   if {$type=="EQUATORIAL"} {
      set res [mc_tel2cat [list $ra_app $dec_app] EQUATORIAL $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   } else {
      set res [mc_tel2cat [list $az_app $elev_app] ALTAZ $date $home $Pressure_Pa $Temperature_K -refraction $refraction -wavelength $wavelength -humidity $humidity]
   }
   lassign $res ra_j2000 dec_j2000

   # --- Apparent position of the pole
   set ramu 0 ; # mas/yr
   set decmu 0 ; # mas/yr
   set parallax 0 ; # mas
   set refraction 1
   set res [mc_hip2tel [list 1 2.5 $ra_j2000 $dec_j2000 J2000 now $ramu $decmu $parallax] $date $home $Pressure_Pa $Temperature_K -refraction $refraction -humidity $humidity -wavelength $wavelength]
   lassign $res ra_app dec_app ha_app az_app elev_app
   console::affiche_resultat "==== POLE geometrique\n"
   console::affiche_resultat "J2000 RA,DEC = [mc_angle2hms $ra_j2000 360 zero 2 auto string] [mc_angle2dms $dec_j2000 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent RA,DEC = [mc_angle2hms $ra_app 360 zero 2 auto string] [mc_angle2dms $dec_app 90 zero 1 + string]\n"
   console::affiche_resultat "Apparent HA = $ha_app\n"
   console::affiche_resultat "Apparent AZ,ELEV = [mc_angle2dms $az_app 360 zero 1 auto string] [mc_angle2dms $elev_app 90 zero 1 + string]\n"
   set radec_polemeca [list $ra_j2000 $dec_j2000]

   # --- Image
   #set ra_j2000 0
   #set dec_j2000 90
   set pixsize1 12
   set pixsize2 12
   set foclen 0.500
   set naxis1 1100
   set naxis2 1100
   set crota2 180
   if {[info exists ::conf(rep_userCatalogUcac4)] eq "1" && $::conf(rep_userCatalogUcac4) ne ""} {
      #--   prise en compte des chemins des catalogues définis par l'utilisateur
      set Path_of_Catalog $::conf(rep_userCatalogUcac4)
   } else {
      #--- premiere rédaction
      set Path_of_Catalog c:/catalogs/UCAC4
   }
   set Type_of_Catalog ucac4
   set mag_faint 18
   set conv_sigma 2
   catalog2buf $ra_j2000 $dec_j2000 $pixsize1 $pixsize2 $foclen $Type_of_Catalog $Path_of_Catalog -naxis1 $naxis1 -naxis2 $naxis2 -crota2 $crota2 -mag_faint $mag_faint -conv_sigma $conv_sigma

   # --- wcs
   set wcs [wcs_buf2wcs]
   lassign $radec_polaris ra dec
   set xy [wcs_radec2xy $wcs $ra $dec]
   console::affiche_resultat "==== POLARIS réfractée\n"
   console::affiche_resultat "==== xy = $xy\n"
   lassign $radec_pole ra dec
   set xy [wcs_radec2xy $wcs $ra $dec]
   console::affiche_resultat "==== POLE réfracté\n"
   console::affiche_resultat "==== xy = $xy\n"
   lassign $radec_polemeca ra dec
   set xy [wcs_radec2xy $wcs $ra $dec]
   console::affiche_resultat "==== POLE geometrique\n"
   console::affiche_resultat "==== xy = $xy\n"

   return
}

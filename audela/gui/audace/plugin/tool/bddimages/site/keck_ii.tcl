#
# Mise à jour $Id: eso-vlt-u4.tcl 8220 2012-04-12 13:30:11Z jberthier $
#

#--------------------------------------------------
#
#  Structure du tabkey
#
# { {TELESCOP { {TELESCOP} {TAROT CHILI} string {Observatory name} } }
#   {NAXIS2   { {NAXIS2}   {1024}        int    {}                 } }
#    etc ...
# }
#
#--------------------------------------------------
#     0         1         2
#       0123456789012345678901
# date <2006-06-23T20:22:36.08>
#--------------------------------------------------

proc chg_tabkey { tabkey } {
   
   # DATE-OBS
   if {! [::bddimages_liste::lexist $tabkey "date-obs"]} {
      return [list 1 "????-??-??T??:??:??"] 
   }
   set dateobs [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee [string range $dateobs 6 9]
      set mois  [string range $dateobs 3 4]
      set jour  [string range $dateobs 0 1]

      if {! [::bddimages_liste::lexist $tabkey "expstart"]} {
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
      }
      set expstart [lindex [::bddimages_liste::lget $tabkey "expstart"] 1]
      set expstop [lindex [::bddimages_liste::lget $tabkey "expstop"] 1]

      set exposure [expr $expstop - $expstart]

      set heure [expr int($duree/3600.)]
      set minute [expr int($duree/60. - $heure*60.)]
      set seconde [expr int($duree - $heure*3600. - $minute*60.)]
      set millisec [expr int((($duree - $heure*3600. - $minute*60.) - $seconde)*100)]

      if {$millisec == 0} {
         set dateiso [format "%04d-%02d-%02dT%02d:%02d:%02d.00" $annee $mois $jour $heure $minute $seconde]
      } else {
         set dateiso [format "%04d-%02d-%02dT%02d:%02d:%02d.%2d" $annee $mois $jour $heure $minute $seconde $millisec]
      }

   }
   set l_dateiso [list "date-obs" $dateiso "string" "" ""]   
   set tabkey [ ::bddimages_liste::lupdate $tabkey "date-obs" $l_dateiso ]

   # EXPOSURE
   if {! [::bddimages_liste::lexist $tabkey "exposure"]} {
      if {[::bddimages_liste::lexist $tabkey "explens"]} {
         set cle [::bddimages_liste::lget $tabkey "explens"]
         set exposure [lreplace $cle 0 0 "exposure"]
         set tabkey [::bddimages_liste::ladd $tabkey "exposure" $exposure]
      } elseif {[::bddimages_liste::lexist $tabkey "itime"] && [::bddimages_liste::lexist $tabkey "coadds"]} {
         set itime [lindex [::bddimages_liste::lget $tabkey "itime"] 1]
         set coadds [lindex [::bddimages_liste::lget $tabkey "coadds"] 1]
         set exposure [expr $itime * $coadds]
         set tabkey [::bddimages_liste::ladd $tabkey "exposure" [list EXPOSURE $exposure double "Total exposure time" "sec"]]
      }
   }

   # BIN1
   if {! [::bddimages_liste::lexist $tabkey "bin1"]} {
      set bin1 1
      set tabkey [::bddimages_liste::ladd $tabkey "bin1" [list BIN1 $bin1 int "Binning in X coordinate" ""]]
   }

   # BIN2
   if {! [::bddimages_liste::lexist $tabkey "bin2"]} {
      set bin2 1
      set tabkey [::bddimages_liste::ladd $tabkey "bin2" [list BIN2 $bin2 int "Binning in Y coordinate" ""]]
   }

   # FOCLEN
   if {! [::bddimages_liste::lexist $tabkey "foclen"]} {
      set foclen 17.5
      set tabkey [::bddimages_liste::ladd $tabkey "foclen" [list FOCLEN $foclen double "Focal length" "m"]]
   }

   # PIXSIZE1
   if {! [::bddimages_liste::lexist $tabkey "pixsize1"]} {
      set pixsize1 27
      set tabkey [::bddimages_liste::ladd $tabkey "pixsize1" [list PIXSIZE1 $pixsize1 double "Pixel dimension" "m"]]
   }

   # PIXSIZE2
   if {! [::bddimages_liste::lexist $tabkey "pixsize2"]} {
      set pixsize2 27
      set tabkey [::bddimages_liste::ladd $tabkey "pixsize2" [list PIXSIZE2 $pixsize2 double "Pixel dimension" "m"]]
   }

   # PRESSURE
   if {! [::bddimages_liste::lexist $tabkey "pressure"]} {
      if {[::bddimages_liste::lexist $tabkey "wxpress"]} {
         set cle [::bddimages_liste::lget $tabkey "wxpress"]
         set pressure [lreplace $cle 0 0 "pressure"]
         set tabkey [::bddimages_liste::ladd $tabkey "pressure" $pressure]
      }
   }
   
   # HUMIDITY
   if {! [::bddimages_liste::lexist $tabkey "humidity"]} {
      if {[::bddimages_liste::lexist $tabkey "wxouthum"]} {
         set cle [::bddimages_liste::lget $tabkey "wxouthum"]
         set humidity [lreplace $cle 0 0 "humidity"]
         set tabkey [::bddimages_liste::ladd $tabkey "humidity" $humidity]
      }
   }

   # TEMP
   if {! [::bddimages_liste::lexist $tabkey "temp"]} {
      if {[::bddimages_liste::lexist $tabkey "wxouttmp"]} {
         set cle [::bddimages_liste::lget $tabkey "wxouttmp"]
         set temp [lreplace $cle 0 0 "temp"]
         set tabkey [::bddimages_liste::ladd $tabkey "temp" $temp]
      }
   }

   # BANDWID
   if {! [::bddimages_liste::lexist $tabkey "bandwid"]} {
      if {[::bddimages_liste::lexist $tabkey "wavecntr"]} {
         set cle [::bddimages_liste::lget $tabkey "wavecntr"]
         set bandwidth [lreplace $cle 0 0 "bandwid"]
         set tabkey [::bddimages_liste::ladd $tabkey "bandwid" $bandwidth]
      }
   }
   
#   set fullname [lindex $files $k]
#   set dirname [file dirname $fullname]
#   set tail [file tail $fullname]
#   set shortname [file rootname $tail]
#   set fullname2 ${dirname}/c_${shortname}${extout}
#   
#::console::affiche_resultat "::OhpT120::convert: processing $fullname -> $fullname2 \n"
#
#   catch {file copy -force $fullname $fullname2}
#   buf$audace(bufNo) load $fullname2
#   set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
#   set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
#   catch {buf$audace(bufNo) delkwd COMMENT=}
#   set pixsize 24e-6
#   set foclen 7.2
#   set crota 0.
#   set cdelt [expr $pixsize/$foclen*180./$pi]
#   buf$audace(bufNo) setkwd [list PIXSIZE1 $pixsize double "Pixel dimension" "m"]
#   buf$audace(bufNo) setkwd [list PIXSIZE2 $pixsize double "Pixel dimension" "m"]
#   buf$audace(bufNo) setkwd [list FOCLEN  $foclen    double "Focal length" "m"]
#   buf$audace(bufNo) setkwd [list CDELT1 [expr -$cdelt] double "X scale" "deg/pix"]
#   buf$audace(bufNo) setkwd [list CDELT2 $cdelt double "Y scale" "deg/pix"]
#   buf$audace(bufNo) setkwd [list CROTA2 $crota double "" "deg"]
#   buf$audace(bufNo) setkwd [list CRPIX1 [expr $naxis1/2] double "" "pix"]
#   buf$audace(bufNo) setkwd [list CRPIX2 [expr $naxis2/2] double "" "pix"]
#   set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
#   set kk [string first T $date_obs]
#   if {$kk<0} {
#      set jour [string range $date_obs 0 1]
#      set mois [string range $date_obs 3 4]
#      set annee [string range $date_obs 6 9]
#      set instant [lindex [buf$audace(bufNo) getkwd TM-START] 1]
#      set instant [mc_angle2hms [expr $instant/240.]]
#      set heure [format %02d [lindex $instant 0]]
#      set minute [format %02d [lindex $instant 1]]
#      set seconde [format %05.2f [lindex $instant 2]]
#      set date_obs ${annee}-${mois}-${jour}T${heure}:${minute}:${seconde}
#      buf$audace(bufNo) setkwd [list DATE-OBS $date_obs string "debut de pose" "iso8601"]
#      set exposure [lindex [buf$audace(bufNo) getkwd TM-EXPOS] 1]
#      buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
#      set ra [lindex [buf$audace(bufNo) getkwd POSTN-RA] 1]
#      set dec [lindex [buf$audace(bufNo) getkwd POSTN-DE] 1]
#   } else {
#      set exposure [lindex [buf$audace(bufNo) getkwd EXPTIME] 1]
#      buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
#   }
#   buf$audace(bufNo) setkwd [list RA $ra double "RA J2000.0" "deg"]
#   buf$audace(bufNo) setkwd [list DEC $dec double "DEC J2000.0" "deg"]
#   buf$audace(bufNo) setkwd [list CRVAL1 $ra double "" "deg"]
#   buf$audace(bufNo) setkwd [list CRVAL2 $dec double "" "deg"]
#   buf$audace(bufNo) save $fullname2

   return [list 0 $tabkey]
}

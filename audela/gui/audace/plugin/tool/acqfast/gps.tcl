#
# Fichier : gps.tcl
# Description : Pilotage de la datation GPS
# Auteur : Frederic Vachier
# Mise à jour $Id: gps.tcl 12737 2016-01-19 20:17:00Z robertdelmas $
#
# source audace/plugin/tool/acqt1m/gps.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::acqfast::gps {

   variable flag
   variable sync
   variable flagsync
   variable antenna
   variable flagantenna


   proc ::acqfast::gps::openGPS { } {

      gren_info "GPS::OPEN\n"
      set r [meinberg_gps open -channel]
      set e [split $r ";"]
      #::console::affiche_resultat "r = $r\n"
      #::console::affiche_resultat "e = $e\n"
      #gren_info "r0 = [lindex $r 0]\n"
      foreach a $e {
         gren_info "O:$a\n"
      }

      set ::acqfast::gps::flag 0
      set s [string first "Antenna is connected" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Antenna is not connected\n"
         set ::acqfast::gps::antenna        "Antenna is not connected"
         set ::acqfast::gps::flagantenna    0
         return 1
      } else {
         set ::acqfast::gps::antenna      "Antenna is connected"
         set ::acqfast::gps::flagantenna  1
      }

      set s [string first "Time is synchronized" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Time not synchronized\n"
         set ::acqfast::gps::sync        "Time not synchronized"
         set ::acqfast::gps::flagsync    0
         return 1
      } else {
         set ::acqfast::gps::sync        "Time is synchronized"
         set ::acqfast::gps::flagsync    1
      }
      # reset buffer
      set r [meinberg_gps reset]
      ::console::affiche_resultat "reset => $r\n"
      set s [string first "Capture buffer cleared for meinberg" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Buffer not cleared\n"
         return 1
      }
      set ::acqfast::gps::flag 1
      gren_info "GPS::OPEN END\n\n"

      return 0
   }


   proc ::acqfast::gps::reset { } {
      if { ! [ info exists ::acqfast::gps::flag ] } {
        ::console::affiche_resultat "GPS not present\n"
        return 2
      }

      set r [meinberg_gps reset]
      ::console::affiche_resultat "reset => $r\n"
      set s [string first "Capture buffer cleared for meinberg" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Buffer not cleared\n"
         return 1
      }

      return 0
   }


   proc ::acqfast::gps::fastread { } {

      set result [ catch { set r [meinberg_gps fastread] } msg ]
      if { $result == "1" } {
         ::console::disp "meinberg_gps fastread error=$msg \n"
         return ERROR
      }

      set e [split $r ";"]
      set date [lindex $e 0]

      set ::acqfast::gps::flag 0
      set s [string first "Antenna is connected" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Antenna is not connected\n"
         set ::acqfast::gps::antenna        "Antenna is not connected"
         set ::acqfast::gps::flagantenna    0
      } else {
         set ::acqfast::gps::antenna      "Antenna is connected"
         set ::acqfast::gps::flagantenna  1
      }

      set s [string first "Time is synchronized" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Time not synchronized\n"
         set ::acqfast::gps::sync        "Time not synchronized"
         set ::acqfast::gps::flagsync    0
      } else {
         set ::acqfast::gps::sync        "Time is synchronized"
         set ::acqfast::gps::flagsync    1
      }
      if { $::acqfast::gps::flagsync == 1 && $::acqfast::gps::flagantenna == 1} { set ::acqfast::gps::flag 1 }

      return $date
   }


   proc ::acqfast::gps::readGPS { } {

      set result [ catch { set r [meinberg_gps read] } msg ]
      if { $result == "1" } {
         ::console::disp "meinberg_gps read error=$msg \n"
         return ERROR
      } else {
         #::console::disp "meinberg_gps read OK\n"
      }

      set e [split $r ";"]
      #foreach a $e {
      #   gren_info "R:$a\n"
      #}
      set date [lindex $e 0]

      set ::acqfast::gps::flag 0
      set s [string first "Antenna is connected" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Antenna is not connected\n"
         set ::acqfast::gps::antenna        "Antenna is not connected"
         set ::acqfast::gps::flagantenna    0
      } else {
         set ::acqfast::gps::antenna      "Antenna is connected"
         set ::acqfast::gps::flagantenna  1
      }

      set s [string first "Time is synchronized" $r]
      if { $s==-1 } {
         ::console::affiche_erreur "Time not synchronized\n"
         set ::acqfast::gps::sync        "Time not synchronized"
         set ::acqfast::gps::flagsync    0
      } else {
         set ::acqfast::gps::sync        "Time is synchronized"
         set ::acqfast::gps::flagsync    1
      }
      if { $::acqfast::gps::flagsync == 1 && $::acqfast::gps::flagantenna == 1} { set ::acqfast::gps::flag 1 }
      return $date
   }


   proc ::acqfast::gps::getdate { bufNo gpsend pcend exposure {gpsbg ""} } {

      set log 0

      if {$log} {gren_info "gpsend=$gpsend\ngpsbeg=$gpsbg\n"}

      set pcendjd    [ mc_date2jd $pcend ]
      set pcbegjd    [ expr $pcendjd - double($exposure)/86400.0]
      set pcbegusec  [expr int($pcbegjd*86400.*1000000)%1000]
      set pcbeg      [ mc_date2iso8601 $pcbegjd ]

      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $gpsend dateiso aa mm jj sep h m s sd] } {
         # Si date ISO
         set gpsend     "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set gpsendjd   [ mc_date2jd $gpsend ]
         set gpsbegjd   [expr $gpsendjd - double($exposure)/86400.0]
         set gpsbeg     [ mc_date2iso8601 $gpsbegjd ]
         set gpsbegusec [expr int($gpsbegjd*86400.*1000000)%1000]
         set gpspc      [format "%.6f" [ expr ($gpsendjd - $pcendjd)*86400. ]]
         set gpsbeg     $gpsbeg$gpsbegusec
         set dateobs    $gpsbeg
         set dateend    $gpsend
         set infogps    "END"
      } else {
         set gpsend               ""
         set gpsbeg               ""
         set gpsbegusec           ""
         set ::acqfast::gps::flag 0
         set gpspc                -99999
         set dateobs              $pcbeg$pcbegusec
         set dateend              $pcend
      }

      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $gpsbg dateiso aa mm jj sep h m s sd] } {
         # Si date ISO
         set gpsbeg  "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set dateobs $gpsbeg
         set infogps "BEGIN-END"
      }

      if {$log} {
         gren_info "** HEADER \n"
         gren_info "EXPOSURE=$exposure         \n"
         gren_info "GPS-OBS=$gpsbeg          \n"
         gren_info "GPS-END=$gpsend          \n"
         #gren_info "PC-OBS=$pcbeg$pcbegusec           \n"
         gren_info "PC-END=$pcend          \n"
         gren_info "DATE-OBS=$dateobs           \n"
         gren_info "DATE-END=$dateend          \n"
         gren_info "FLAG-GPS=$::acqfast::gps::flag          \n"
         gren_info "GPS-PC  =$gpspc            \n"
         if {[info exists ::acqfast::gps::antenna]}     {gren_info "GPS-ANTE=$::acqfast::gps::antenna       \n"}
         if {[info exists ::acqfast::gps::sync]}        {gren_info "GPS-SYNC=$::acqfast::gps::sync          \n"}
         if {[info exists ::acqfast::gps::flagantenna]} {gren_info "GPS-FANT=$::acqfast::gps::flagantenna   \n"}
         if {[info exists ::acqfast::gps::flagsync]}    {gren_info "GPS-FSYN=$::acqfast::gps::flagsync      \n"}
         if {[info exists infogps]}                     {gren_info "GPS-INFO=$infogps     \n"}
      }

      buf$bufNo setkwd [list DATE-OBS $dateobs               string  "Begining date of the observation"                     "Date ISO8601"]
      buf$bufNo setkwd [list DATE-END $dateend               string  "End date of the observation"                          "Date ISO8601"]
      buf$bufNo setkwd [list GPS-OBS  $gpsbeg                string  "Beginning date of the observation from GPS Clock"     "Date ISO8601"]
      buf$bufNo setkwd [list GPS-END $gpsend                 string  "End date of the observation from GPS Clock"           "Date ISO8601"]
     #buf$bufNo setkwd [list PC-OBS $pcbeg$pcbegusec         string  "Beginning date of the observation from PC Clock"      "Date ISO8601"]
      buf$bufNo setkwd [list PC-END $pcend                   string  "End date of the observation from PC Clock"            "Date ISO8601"]
      buf$bufNo setkwd [list GPS-FLAG $::acqfast::gps::flag  boolean "flag = 1 if GPS datation is valid, 0 otherwise"       none]
      buf$bufNo setkwd [list GPS-PC   $gpspc                 float   "Difference between GPS Clock and Computer Clock"      second]
      if {[info exists ::acqfast::gps::antenna]}     {buf$bufNo setkwd [list GPS-ANTE $::acqfast::gps::antenna      string   "Status of GPS Antenna" ""]}
      if {[info exists ::acqfast::gps::sync]}        {buf$bufNo setkwd [list GPS-SYNC $::acqfast::gps::sync         string   "Status of GPS Synchronization" ""]}
      if {[info exists ::acqfast::gps::flagantenna]} {buf$bufNo setkwd [list GPS-FANT $::acqfast::gps::flagantenna  boolean  "flag = 1 if GPS Antenna is connected, 0 otherwise" ""]}
      if {[info exists ::acqfast::gps::flagsync]}    {buf$bufNo setkwd [list GPS-FSYN $::acqfast::gps::flagsync     boolean  "flag = 1 if GPS Time is synchronized, 0 otherwise" ""]}
      if {[info exists infogps]}                     {buf$bufNo setkwd [list GPS-INFO $infogps                      string   "Date issued by the GPS Clock" ""]}
      buf$bufNo delkwd GPS-DATE

      return $::acqfast::gps::flag
   }


   proc ::acqfast::gps::timejd { } {

      set result [ catch { set r [meinberg_gps time] } msg ]
      if { $result == "1" } {
         ::console::disp "meinberg_gps read error=$msg \n"
         return
      }


      set rs [split $r " "]
      set r "[lindex $rs 1] [lindex $rs 3]"
      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $r dateiso aa mm jj sep h m s sd] } {
         set time "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"
         set timejd [ mc_date2jd $time ]
         #::console::disp "$timejd \n"
         return $timejd
      } else {
         ::console::disp "Wrong time format, r=$r\n"
         return
      }

   }


# Fin NameSpace
}


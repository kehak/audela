## @file tools_planif_parse.tcl
#  @brief     Lecture des fichiers csv
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages scripts console planif tools_planif_parse.tcl]
#  @endcode

# $Id: tools_planif_parse.tcl 14516 2018-10-19 16:36:46Z fredvachier $


#------------------------------------------------------------
## Cette fonction lit le fichier lst de la liste des asteroides
# @return void
#
#   Type,    Num,        Nom, Magnitude, Period(h), Binning, Expo(s), Score
proc ::tools_planif::read_lst { filelst } {

   array unset ::tools_planif::tabephem
   set f [open $filelst "r"]
   set data [read $f]
   close $f
   set cpt 0
   set r [split [string trim $data] "\n"]
   set ::tools_planif::tabephem(lst,target) ""
   set ::tools_planif::tabephem(lst,all) ""
   foreach line $r {
      if {[string range $line 0 0]=="#"} {continue} 
      if {[string trim $line ]==""} {continue} 
      
      lassign [csv:parse $line] otype b c d e f g h i
      
      switch $otype {
      "asteroid" - "star" {

         #    Type,    Num,              Nom,   Mag, PeriodeRotation (h), Binning, Exposure, Priority
         #asteroid,     22,         Kalliope,  12.4,               4.120,       1,       60,        0

         #otype b    c     d   e      f       g        h
         #otype cnum cname mag period binning exposure priority

         incr cpt
         set key [::bddimages_imgcorrection::cleanEntities "${b}_${c}"]
         lappend ::tools_planif::tabephem(lst,target) $key
         lappend ::tools_planif::tabephem(lst,all)    $key
         set ::tools_planif::tabephem($key,otype)     $otype
         set ::tools_planif::tabephem($key,cnum)      $b
         set ::tools_planif::tabephem($key,cname)     $c
         set ::tools_planif::tabephem($key,vmag)      $d
         set ::tools_planif::tabephem($key,period)    $e
         set ::tools_planif::tabephem($key,binning)   $f
         set ::tools_planif::tabephem($key,exposure)  $g
         set ::tools_planif::tabephem($key,priority)  $h
         if {0} {
            gren_info "   $cpt=$::tools_planif::tabephem($key,otype) \
                          $::tools_planif::tabephem($key,cnum) \
                          $::tools_planif::tabephem($key,cname) \
                          $::tools_planif::tabephem($key,priority) \
                          $::tools_planif::tabephem($key,period) \
                          $::tools_planif::tabephem($key,exposure) \
                          $::tools_planif::tabephem($key,binning)"
         }
      }

      "stationary" - "linear" {

         #       Type,      Nom,    Mag, Binning, Exposure, Step(h), NbImg, Priority, { a b c d }
         #linear,       K18N12N,   20.4,       3,      300,     0.5,     2,      -10, { -257689.70033804086 0.10494463738584785 -210190.43612795824 0.085500072368930133}

         #stationary, AT2018cow,  20.1,       3,      300,     0.5,     2,      -10, { -21.4354265 45.235423 }

#       Type,      Nom,    Mag, Binning, Exposure, Step(h), NbImg, Priority, { ra dec }
#stationary, AT2018cow,  20.1,       3,      300,     24,     10,      -10, { 244.000916667  22.2681111111 }

         #otype b     c   d       e        f         g     h        i
         #otype cname mag binning exposure hinterval nbimg priority coord

         incr cpt
         set key [::bddimages_imgcorrection::cleanEntities "${b}"]
         lappend ::tools_planif::tabephem(lst,target) $key
         lappend ::tools_planif::tabephem(lst,all)    $key
         set ::tools_planif::tabephem($key,otype)     $otype
         set ::tools_planif::tabephem($key,cname)     $b
         set ::tools_planif::tabephem($key,cnum)      "0"
         set ::tools_planif::tabephem($key,vmag)      $c
         set ::tools_planif::tabephem($key,binning)   $d
         set ::tools_planif::tabephem($key,exposure)  $e
         set ::tools_planif::tabephem($key,hinterval) $f
         set ::tools_planif::tabephem($key,nbimg)     $g
         set ::tools_planif::tabephem($key,priority)  $h
         set ::tools_planif::tabephem($key,coord)     $i
         if {0} {
            gren_info "   $cpt=$::tools_planif::tabephem($key,otype) \
                          $::tools_planif::tabephem($key,cname)      \
                          $::tools_planif::tabephem($key,vmag)       \
                          $::tools_planif::tabephem($key,binning)    \
                          $::tools_planif::tabephem($key,exposure)   \
                          $::tools_planif::tabephem($key,hinterval)  \
                          $::tools_planif::tabephem($key,nbimg)      \
                          $::tools_planif::tabephem($key,priority)   \
                          $::tools_planif::tabephem($key,coord)"
         }
         
      }

      "keplerian" {
         
         #       Type,      Nom,    Mag, Binning, Exposure, Step(h), NbImg, Priority, { MJD a e i Omega omegap am }
         #keplerian,    M2018A6, -9.990,       3,      300,     0.5,     2,      -10, {58341.751016105 3.2275803452238740E+00 0.052114399992232 4.4427209086903 248.7236715091047 85.6672163782663 345.3463108186460}
         
         incr cpt
         set key [::bddimages_imgcorrection::cleanEntities "${b}"]
         lappend ::tools_planif::tabephem(lst,target) $key
         lappend ::tools_planif::tabephem(lst,all)    $key
         set ::tools_planif::tabephem($key,otype)     $otype
         set ::tools_planif::tabephem($key,cname)     $b
         set ::tools_planif::tabephem($key,cnum)      "0"
         set ::tools_planif::tabephem($key,vmag)      $c
         set ::tools_planif::tabephem($key,binning)   $d
         set ::tools_planif::tabephem($key,exposure)  $e
         set ::tools_planif::tabephem($key,hinterval) $f
         set ::tools_planif::tabephem($key,nbimg)     $g
         set ::tools_planif::tabephem($key,priority)  $h
         lassign [lindex $i 0] ::tools_planif::tabephem($key,mjd) \
                    ::tools_planif::tabephem($key,a) \
                    ::tools_planif::tabephem($key,e) \
                    ::tools_planif::tabephem($key,i) \
                    ::tools_planif::tabephem($key,longnode) \
                    ::tools_planif::tabephem($key,argperic) \
                    ::tools_planif::tabephem($key,meananomaly)

         if {0} {
            gren_info "   $cpt=$::tools_planif::tabephem($key,otype) \
                          $::tools_planif::tabephem($key,cname)      \
                          $::tools_planif::tabephem($key,vmag)       \
                          $::tools_planif::tabephem($key,binning)    \
                          $::tools_planif::tabephem($key,exposure)   \
                          $::tools_planif::tabephem($key,hinterval)  \
                          $::tools_planif::tabephem($key,nbimg)      \
                          $::tools_planif::tabephem($key,priority)   \
                          $::tools_planif::tabephem($key,mjd)        \
                          $::tools_planif::tabephem($key,a)          \
                          $::tools_planif::tabephem($key,e)          \
                          $::tools_planif::tabephem($key,i)          \
                          $::tools_planif::tabephem($key,longnode)   \
                          $::tools_planif::tabephem($key,argperic)   \
                          $::tools_planif::tabephem($key,meananomaly)"
         }

      }

      default {
         return -code 1 "OBJECT TYPE Inconnu: $otype"
      }
      
      }

      gren_info [format "     %3s = %-10s %-30s" $cpt $::tools_planif::tabephem($key,otype) $key]

   }
   set ::tools_planif::tabephem(nb) [llength $::tools_planif::tabephem(lst,target)]
   lappend ::tools_planif::tabephem(lst,all)  "sun"
   set ::tools_planif::tabephem(sun,otype)    "sun"
   set ::tools_planif::tabephem(sun,cnum)     11
   set ::tools_planif::tabephem(sun,cname)    "Sun"
   lappend ::tools_planif::tabephem(lst,all)  "moon"
   set ::tools_planif::tabephem(moon,otype)   "moon"
   set ::tools_planif::tabephem(moon,cnum)    10
   set ::tools_planif::tabephem(moon,cname)   "Moon"
}








#------------------------------------------------------------
## Cette fonction lit le fichier lst de la liste des asteroides
# @return void
#
proc ::tools_planif::read_spec { filespec } {

   array unset ::tools_planif::tabephemspec
   set f [open $filespec "r"]
   set data [read $f]
   close $f
   set cpt 0
   set r [split [string trim $data] "\n"]
   set ::tools_planif::tabephemspec(lst,target) ""
   foreach line $r {
      if {[string range $line 0 0]=="#"} {continue} 
      incr cpt
      lassign [csv:parse $line] cnum cname dmin dmax pc
      set key [::bddimages_imgcorrection::cleanEntities "${cnum}_${cname}"]
      lappend ::tools_planif::tabephemspec(lst,target) $key
      set ::tools_planif::tabephemspec($key,nb)        $cpt
      set ::tools_planif::tabephemspec($key,$cpt,dmin) $dmin
      set ::tools_planif::tabephemspec($key,$cpt,dmax) $dmax
      gren_info [format "%3s = %-7s %-20s %-23s %-23s %4s" $cpt $cnum $cname $::tools_planif::tabephemspec($key,$cpt,dmin) $::tools_planif::tabephemspec($key,$cpt,dmax) $pc]
   }
}












#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride d'un Sso
# @return void
#
#
# Lecture eproc4
#   2018-09-24T16:32:20.023  12 40 59.11472  +03 24 43.1234     4.5954   -0.4506   -999.000      8.54       0.1023E+01      -0.4743E+00
proc ::tools_planif::read_eph_sso { key file } {

   set cpt 0
   set cpte 0
   set f [open $file "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}

      # Chargement
      set res     [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [string range [lindex $res 0] 0 21]
      set ra      "[lindex $res 1]h[lindex $res 2]m[lindex $res 3]s"
      set dec     "[lindex $res 4]d[lindex $res 5]m[lindex $res 6]s"
      set az      [expr 180.0 + [lindex $res 7] ]
      if {$az >= 360.0} {set az [expr $az - 360.0]}
      set h       [lindex $res 8]
      set am      [lindex $res 9]
      set mura    [lindex $res 10]
      set mudec   [lindex $res 11]
      set vmag    [lindex $res 12]
      
      if {0} {
         gren_info "dateiso = $dateiso"
         gren_info "ra = $ra"
         gren_info "dec = $dec"
         gren_info "az = $az"
         gren_info "h = $h"
         gren_info "am = $am"
         gren_info "vmag = $vmag"
         gren_info "mura = $mura"
         gren_info "mudec = $mudec"
         exit
      }
      
      # Selection

      # le soleil n est pas levé
      if {![info exists ::tools_planif::tabephem(sun,ephem,$dateiso,h)]} {
           continue
        }
      # la hauteur de l objet est sous la valeur min
      if {$h<$::tools_planif::target_hmin} {
           #gren_info "$dateiso => hmin : $h<$::tools_planif::target_hmin "
           continue
        }
      # distance a la lune
      if {[info exists ::tools_planif::tabephem(moon,ephem,$dateiso,h)]} {
        set distmoon [lindex [ mc_anglesep [ list $ra $dec $::tools_planif::tabephem(moon,ephem,$dateiso,ra) $::tools_planif::tabephem(moon,ephem,$dateiso,dec)] ] 0]
        if {$distmoon<$::tools_planif::moon_dist} {
           #gren_info "$dateiso => Moon"
           continue
        }
      }
      # Horizon local
      if {[::tools_planif::horizon_telescope $az $h]==0} {
           #gren_info "$dateiso => horizon"
           continue
        }

      #gren_info "$dateiso => ok"
      # mag limite atteinte
      if { ! [info exists ::tools_planif::maglimit($::tools_planif::tabephem($key,binning)) ] } {
         gren_info "   - [file tail $file] : maglimit non definie -> ::tools_planif::maglimit($::tools_planif::tabephem($key,binning))"
         continue
      } else {
         if {$vmag > $::tools_planif::maglimit($::tools_planif::tabephem($key,binning)) } {
           if {$cpte==0} {
              gren_info "   - $key Mag trop faible pour ce binning"
              incr cpte
           }
           continue
         }
      }
      
      # Existe dans la liste SPEC
      if {[info exists ::tools_planif::tabephemspec(lst,target)]} {
         if {$key in $::tools_planif::tabephemspec(lst,target)} {
            set jd [mc_date2jd $dateiso]
            set pass "no"
            for {set cpt 1} {$cpt<=$::tools_planif::tabephemspec($key,nb)} {incr cpt} {
               set dmin [mc_date2jd $::tools_planif::tabephemspec($key,$cpt,dmin)]
               set dmax [mc_date2jd $::tools_planif::tabephemspec($key,$cpt,dmax)]
               if {$jd>$dmin && $jd<$dmax} {
                  set pass "yes"
                  break
               }
            }
            if {$pass=="no"} { continue }
         }
      
      
      }

      # Finalisation
      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    $ra
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   $dec
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      set ::tools_planif::tabephem($key,ephem,$dateiso,am)    $am
      set ::tools_planif::tabephem($key,ephem,$dateiso,vmag)  $vmag
      set ::tools_planif::tabephem($key,ephem,$dateiso,mura)  $mura
      set ::tools_planif::tabephem($key,ephem,$dateiso,mudec) $mudec
      incr cpt
   }
   close $f
   set ::tools_planif::tabephem($key,nbephem) $cpt
   gren_info "       READ: Lecture du fichier [file tail $file] : $cpt pts"
}






#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride d'un Sso
# @return void
#
proc ::tools_planif::read_eph_sso_obsolete { key file } {

   set cpt 0
   set cpte 0
   set f [open $file "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}

      # Chargement
      set res [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [lindex $res 0]
      set ra    "[lindex $res 2]h[lindex $res 3]m[lindex $res 4]s"
      set dec   "[lindex $res 5]d[lindex $res 6]m[lindex $res 7]s"
      set az    [expr 180.0 + [mc_angle2deg "[lindex $res 14]d[lindex $res 15]m[lindex $res 16]s"] ]
      if {$az >= 360.0} {set az [expr $az - 360.0]}
      set h     [mc_angle2deg "[lindex $res 17]d[lindex $res 18]m[lindex $res 19]s"]
      set am    [lindex $res 20]
      set vmag  [lindex $res 23]
      set mura  [lindex $res 26]
      set mudec [lindex $res 27]
      
      # Selection

      # le soleil n est pas levé
      if {![info exists ::tools_planif::tabephem(sun,ephem,$dateiso,h)]} {continue}
      # la hauteur de l objet est sous la valeur min
      if {$h<$::tools_planif::target_hmin} {continue}
      # distance a la lune
      if {[info exists ::tools_planif::tabephem(moon,ephem,$dateiso,h)]} {
        set distmoon [lindex [ mc_anglesep [ list $ra $dec $::tools_planif::tabephem(moon,ephem,$dateiso,ra) $::tools_planif::tabephem(moon,ephem,$dateiso,dec)] ] 0]
        if {$distmoon<$::tools_planif::moon_dist} {continue}
      }
      # Horizon local
      if {[::tools_planif::horizon_telescope $az $h]==0} {continue}

      # mag limite atteinte
      if { ! [info exists ::tools_planif::maglimit($::tools_planif::tabephem($key,binning)) ] } {
         gren_info "   - [file tail $file] : maglimit non definie -> ::tools_planif::maglimit($::tools_planif::tabephem($key,binning))"
         continue
      } else {
         if {$vmag > $::tools_planif::maglimit($::tools_planif::tabephem($key,binning)) } {
           if {$cpte==0} {
              gren_info "   - $key Mag trop faible pour ce binning"
              incr cpte
           }
           continue
         }
      }
      
      # Existe dans la liste SPEC
      if {[info exists ::tools_planif::tabephemspec(lst,target)]} {
         if {$key in $::tools_planif::tabephemspec(lst,target)} {
            set jd [mc_date2jd $dateiso]
            set pass "no"
            for {set cpt 1} {$cpt<=$::tools_planif::tabephemspec($key,nb)} {incr cpt} {
               set dmin [mc_date2jd $::tools_planif::tabephemspec($key,$cpt,dmin)]
               set dmax [mc_date2jd $::tools_planif::tabephemspec($key,$cpt,dmax)]
               if {$jd>$dmin && $jd<$dmax} {
                  set pass "yes"
                  break
               }
            }
            if {$pass=="no"} { continue }
         }
      
      
      }

      # Finalisation
      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    $ra
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   $dec
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      set ::tools_planif::tabephem($key,ephem,$dateiso,am)    $am
      set ::tools_planif::tabephem($key,ephem,$dateiso,vmag)  $vmag
      set ::tools_planif::tabephem($key,ephem,$dateiso,mura)  $mura
      set ::tools_planif::tabephem($key,ephem,$dateiso,mudec) $mudec
      incr cpt
   }
   close $f
   set ::tools_planif::tabephem($key,nbephem) $cpt
   gren_info "       READ: Lecture du fichier [file tail $file] : $cpt pts"
}














#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride d'une etoile
# @return void
#
proc ::tools_planif::read_eph_star { key file } {

   set cpt 0
   set cpte 0
   set f [open $file "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}

      # Chargement
      set res [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [lindex $res 0]
      set ra    "[lindex $res 2]h[lindex $res 3]m[lindex $res 4]s"
      set dec   "[lindex $res 5]d[lindex $res 6]m[lindex $res 7]s"
      set az    [expr 180.0 + [mc_angle2deg "[lindex $res 14]d[lindex $res 15]m[lindex $res 16]s"] ]
      if {$az >= 360.0} {set az [expr $az - 360.0]}
      set h     [mc_angle2deg "[lindex $res 17]d[lindex $res 18]m[lindex $res 19]s"]
      set vmag  [lindex $res 20]
      set am    [lindex $res 21]
 
      set mura  0.0
      set mudec 0.0
      
      # Selection

      # le soleil n est pas levé
      if {![info exists ::tools_planif::tabephem(sun,ephem,$dateiso,h)]} {continue}
      # la hauteur de l objet est sous la valeur min
      if {$h<$::tools_planif::target_hmin} {continue}
      # distance a la lune
      if {[info exists ::tools_planif::tabephem(moon,ephem,$dateiso,h)]} {
        set distmoon [lindex [ mc_anglesep [ list $ra $dec $::tools_planif::tabephem(moon,ephem,$dateiso,ra) $::tools_planif::tabephem(moon,ephem,$dateiso,dec)] ] 0]
        if {$distmoon<$::tools_planif::moon_dist} {continue}
      }
      # Horizon local
      if {[::tools_planif::horizon_telescope $az $h]==0} {continue}

      # mag limite atteinte
      if {$vmag > $::tools_planif::maglimit($::tools_planif::tabephem($key,binning)) } {
        if {$cpte==0} {
           gren_info "   $key Mag trop faible pour ce binning"
           incr cpte
        }
        continue
      }
      
      # Finalisation
      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    $ra
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   $dec
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      set ::tools_planif::tabephem($key,ephem,$dateiso,am)    $am
      set ::tools_planif::tabephem($key,ephem,$dateiso,vmag)  $vmag
      set ::tools_planif::tabephem($key,ephem,$dateiso,mura)  $mura
      set ::tools_planif::tabephem($key,ephem,$dateiso,mudec) $mudec
      incr cpt
   }
   close $f
   set ::tools_planif::tabephem($key,nbephem) $cpt
   gren_info "       READ: Lecture du fichier [file tail $file] : $cpt pts"
}







#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride
# @return void
#
proc ::tools_planif::read_eph_sun { key file } {

   gren_info "   + Lecture du fichier [file tail $file]"
   set ::tools_planif::alldate "" 
   set f [open $file "r"]
   
   set chg_nuit 0
   set ::tools_planif::tab_sunrise ""
   
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}
      
      # Chargement
      set res     [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [string range [lindex $res 0] 0 21]
      set h       [lindex $res 8]
      
      # Selection
      if {$h>$::tools_planif::sun_hmax} {
         if {$chg_nuit == 0} {
            lappend ::tools_planif::tab_sunrise $dateiso
            set chg_nuit 1
         }
         continue
      } else {
         set chg_nuit 0
      }
      
      # Finalisation
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      lappend ::tools_planif::alldate $dateiso

   }
   
   array unset ::tools_planif::resume
   foreach dateiso $::tools_planif::alldate {
      set ::tools_planif::resume($dateiso,planified) 0
      set ::tools_planif::resume($dateiso,sunrise) [::tools_planif::get_next_sunrise $dateiso]
   }
   
   close $f
}












proc ::tools_planif::get_next_sunrise { dateiso } {
   
   foreach l $::tools_planif::tab_sunrise {
      if {[ mc_date2jd $dateiso ]<[ mc_date2jd $l ]} {
         return $l 
      }
   }
   return 0
}








#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride
# @return void
#
proc ::tools_planif::read_eph_moon { key file } {

   gren_info "   + Lecture du fichier [file tail $file]"
   set f [open $file "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}

      # Chargement
      set res     [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [string range [lindex $res 0] 0 21]
      set h       [lindex $res 8]

      set ra      "[lindex $res 1]h[lindex $res 2]m[lindex $res 3]s"
      set dec     "[lindex $res 4]d[lindex $res 5]m[lindex $res 6]s"

      # Selection
      if {$h<$::tools_planif::moon_hmin} {continue}
      
      # Finalisation
      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    $ra
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   $dec
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h

   }
   close $f

}

#------------------------------------------------------------
## Cette fonction calcule la table des ephemerides pour un position fixe du ciel
# @return void
#
proc ::tools_planif::get_eph_stationary { key } {
   
   lassign [lindex $::tools_planif::tabephem($key,coord) 0] ra dec
   set cpt 0
   foreach dateiso $::tools_planif::alldate {
      
      # le soleil n est pas levé
      if {![info exists ::tools_planif::tabephem(sun,ephem,$dateiso,h)]} {continue}
      
      # calcul de la hauteur de l objet
      set h [lindex [mc_radec2altaz $ra $dec $::tools_planif::home [mc_date2jd $dateiso] ] 1]
      
      # la hauteur de l objet est sous la valeur min
      if {$h<$::tools_planif::target_hmin} {continue}
      
      # distance a la lune
      if {[info exists ::tools_planif::tabephem(moon,ephem,$dateiso,h)]} {
        set distmoon [lindex [ mc_anglesep [ list $ra $dec $::tools_planif::tabephem(moon,ephem,$dateiso,ra) $::tools_planif::tabephem(moon,ephem,$dateiso,dec)] ] 0]
        if {$distmoon<$::tools_planif::moon_dist} {continue}
      }

      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    [mc_angle2hms $ra 360 zero 1 auto string]
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   [mc_angle2dms $dec 90 zero 1 + string]
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      set ::tools_planif::tabephem($key,ephem,$dateiso,vmag)  $::tools_planif::tabephem($key,vmag)
      set ::tools_planif::tabephem($key,ephem,$dateiso,mura)  0.0
      set ::tools_planif::tabephem($key,ephem,$dateiso,mudec) 0.0
      incr cpt
   }
   set ::tools_planif::tabephem($key,nbephem) $cpt

}

#------------------------------------------------------------
## Cette fonction calcule la table des ephemerides pour un deplacement lineaire sur le ciel
# @return void
#
proc ::tools_planif::get_eph_linear { key } {

   lassign [lindex $::tools_planif::tabephem($key,coord) 0] ra_a ra_b dec_a dec_b

   set pi [expr atan(1)*4.0]

   set cpt 0
   foreach dateiso $::tools_planif::alldate {
      
      # le soleil n est pas levé
      if {![info exists ::tools_planif::tabephem(sun,ephem,$dateiso,h)]} {continue}
      
      # Calcul des coordonnees de l objet
      set jd [mc_date2jd $dateiso]
      set ra  [expr  $ra_a  + $ra_b  * $jd ]
      set dec [expr  $dec_a + $dec_b * $jd ]
      set dra  [expr $ra_b  * 3600.0 / 86400.0 * cos($dec * $pi /180.0)]
      set ddec [expr $dec_b * 3600.0 / 86400.0]
      
      # calcul de la hauteur de l objet
      set h [lindex [mc_radec2altaz $ra $dec $::tools_planif::home $jd ] 1]
      
      # la hauteur de l objet est sous la valeur min
      if {$h<$::tools_planif::target_hmin} {continue}

      # distance a la lune
      if {[info exists ::tools_planif::tabephem(moon,ephem,$dateiso,h)]} {
        set distmoon [lindex [ mc_anglesep [ list $ra $dec $::tools_planif::tabephem(moon,ephem,$dateiso,ra) $::tools_planif::tabephem(moon,ephem,$dateiso,dec)] ] 0]
        if {$distmoon<$::tools_planif::moon_dist} {continue}
      }

      set ::tools_planif::tabephem($key,ephem,$dateiso,ra)    [mc_angle2hms $ra 360 zero 3 auto string]
      set ::tools_planif::tabephem($key,ephem,$dateiso,dec)   [mc_angle2dms $dec 90 zero 3 + string]
      set ::tools_planif::tabephem($key,ephem,$dateiso,h)     $h
      set ::tools_planif::tabephem($key,ephem,$dateiso,vmag)  $::tools_planif::tabephem($key,vmag)
      set ::tools_planif::tabephem($key,ephem,$dateiso,mura)  $dra
      set ::tools_planif::tabephem($key,ephem,$dateiso,mudec) $ddec
      incr cpt
   }
   set ::tools_planif::tabephem($key,nbephem) $cpt




}





#------------------------------------------------------------
## Cette fonction lit une ligne d un fichier csv
# @return void
#
proc csv:parse {line {sepa ,}} {
   set lst [split $line $sepa]
   set nlst {}
   set l [llength $lst]
   for {set i 0} {$i < $l} {incr i} {
       if {[string index [lindex $lst $i] 0] == "\""} {
          # start of a stringhttp://purl.org/thecliff/tcl/wiki/721.html
          if {[string index [lindex $lst $i] end] == "\""} {
             # check for completeness, on our way we repair double double quotes
             set c1 [string range [lindex $lst $i] 1 end]
             set n1 [regsub -all {""} $c1 {"} c2]
             set n2 [regsub -all {"} $c2 {"} c3]
             if {$n1 == $n2} {
                # string extents to next list element
                set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
                set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
                incr i -1
                incr l -1
                continue
                } else {
                # we are done with this element
                lappend nlst [string trim [string range $c2 0 [expr {[string length $c2] - 2}]]]
                continue
                }
             } else {
             # string extents to next list element
             set new_el [join [lrange $lst $i [expr {$i + 1}]] $sepa]
             set lst [lreplace $lst $i [expr {$i + 1}] $new_el]
             incr i -1
             incr l -1
             continue
             }
          } else {
          # the most simple case
          lappend nlst [string trim [lindex $lst $i]]
          continue
          }
       }
   return $nlst
 }

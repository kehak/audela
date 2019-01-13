#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils prediction main.tcl]
#--------------------------------------------------
#
# Fichier        : main.tcl
# Description    : lecture d un fichier de mesure pour calculer les offset sur l asteroide
# Auteur         : Frederic Vachier
# Mise à jour $Id: main.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

   proc suppr_zero { x } {
      set y ""
      set nb [string length $x]
      for {set i 0} {$i<$nb} {incr i} {
         set c [string range $x $i $i]
         if {$c == 0} {
            continue
         } else {
            append y $c
         }
      }
      if {$y==""} {
         set y 0
      }
      return $y
   }

   proc date2jd { x } {

      set ye [lindex $x 0]
      set mo [lindex $x 1]
      set jdec [lindex $x 2]
      set day  [expr floor($jdec)]
      set jdec [expr $jdec - $day ]
      set dateiso "$ye-$mo-${day}T00:00:00"
      set datejd [ expr [mc_date2jd $dateiso] + $jdec ]
      return $datejd
   }


   proc read_file { } {

      global bddconf
      global audace 


      array unset mesure
      array unset ephem
      
      set dir [ file join $audace(rep_plugin) tool bddimages utils prediction ]
      # creation du fichier de mesures
      set filemes [ file join $dir astrometry.dat]
      set chan0 [open $filemes r]
      set data ""
      while {[gets $chan0 line] >= 0} {
         lappend data $line
      }
      close $chan0
      set filedate [ file join $dir dateforephem.dat]
      set chan1 [open $filedate w]
      set i 0
      foreach line $data {
         gren_info "\n"
         set aster [ suppr_zero [string trim [string range $line 0 4]] ]
         set aster 136108
         gren_info "aster = ($aster) \n"
        
         set datejd [ date2jd [ string range $line 15 31] ]
         gren_info "dateiso = ([ mc_date2iso8601 $datejd]) $datejd \n"
         
         
         puts $chan1 "$datejd"
         
         
         set ra [ string range $line 32 43]
         set ra [expr [mc_angle2deg $ra ] * 15.0]
         gren_info "ra = $ra \n"

         set dec [ string range $line 44 55]
         set dec [expr [mc_angle2deg $dec ] ]
         gren_info "dec = $dec \n"

         set uai [ string range $line 77 79]
         gren_info "uai = $uai \n"
         
         set mesure($i) [list $datejd $ra $dec $uai]
         incr i
      }
      set nbdate $i
      
      close $chan1
   
      set cmdfile [file join $dir cmdephem_${aster}.sh]
      set chan0 [open $cmdfile w]

      #set cmd "$::bdi_tools_astrometry::imcce_ephemcc asteroide -n $aster -j $filedate 1 -tp 1 -te 1 -tc 5 -uai 181 -d 1 -e utc --julien"
      #set cmd "$::bdi_tools_astrometry::imcce_ephemcc asteroide -n $aster -j $filedate 1 -tp 1 -te 1 -tc 5 -d 1 -e utc --julien -g -0.413962962963 47.02666666666 680"
      
      set cmd "$::bdi_tools_astrometry::imcce_ephemcc asteroide -n $aster -j $filedate 1 -tp 1 -te 1 -tc 5 -d 1 -e utc --julien -uai I95"
      gren_info "cmd = $cmd\n"
      puts $chan0 "#!/bin/sh"
      puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib:$::bdi_tools_astrometry::ifortlib"
      puts $chan0 "export LD_LIBRARY_PATH"
      puts $chan0 $cmd
      close $chan0

      set err [catch {exec sh $cmdfile} msg]
      if { $err } {
         gren_erreur "Erreur de calcul des ephemerides : $err $msg\n"
         return
      } else {
         set cpt 0
         set i 0
         foreach line [split $msg "\n"] {
            incr cpt
            if {$cpt == 1} {continue}
            set c [string index $line 0]
            if {$c == "#"} {continue}
            set rd [regexp -inline -all -- {\S+} $line]
            set tab [split $rd " "]
            set jd [lindex $tab 0]
            set ra [::bdi_tools::sexa2dec [list [lindex $tab  2] [lindex $tab  3] [lindex $tab  4]] 15.0]
            set dec [::bdi_tools::sexa2dec [list [lindex $tab  5] [lindex $tab  6] [lindex $tab  7]] 1.0]
            set ephem($i) [list $jd $ra $dec]
            incr i
         }
      }
      
      set a [array get ephem]
      if {$a==""} {
         gren_erreur "No ephemeris for this body\n"
         continue
      }



      gren_info "OFFSET : \n"

      set fileres [ file join $dir residus.csv]
      set chan0 [open $fileres w]
      puts $chan0 "jd,residux,residuy,uai"
      
      set offx ""
      set offy ""

      for {set i 0} {$i<$nbdate} {incr i} {
         
         set diffjdsec [expr abs([lindex $mesure($i) 0]-[lindex $ephem($i) 0])]
         set diffra    [format "%.1f" [expr ([lindex $mesure($i) 1]-[lindex $ephem($i) 1])*3600000.0] ]
         set diffdec   [format "%.1f" [expr ([lindex $mesure($i) 2]-[lindex $ephem($i) 2])*3600000.0] ]
         lappend offx $diffra
         lappend offy $diffdec
         gren_info "$diffjdsec $diffra $diffdec\n"
         
         puts $chan0 "[lindex $mesure($i) 0],$diffra,$diffdec,[lindex $mesure($i) 3]"
      }
      
      close $chan0

      set moffx [format "%.0f" [ ::math::statistics::mean $offx ] ]
      set soffx [format "%.0f" [ ::math::statistics::stdev $offx] ]
      set moffy [format "%.0f" [ ::math::statistics::mean $offy ] ]
      set soffy [format "%.0f" [ ::math::statistics::stdev $offy] ]

      gren_info "Mean OFFSET RA  = $moffx +- $soffx\n"
      gren_info "Mean OFFSET DEC = $moffy +- $soffy\n"
      
   }


   # le programme debute :
   
   read_file

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils prediction star.tcl]
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
      set filemes [ file join $dir star.dat]
      set chan0 [open $filemes r]
      set data ""
      while {[gets $chan0 line] >= 0} {
         if {[string trim $line]!=""} {
            lappend data $line
         }
      }
      close $chan0
      
      set tabra ""
      set tabdec ""
      
      set i 0
      foreach line $data {
          
         gren_info "line=$line\n"
      
         gren_info "\[$i\]\n"
        
         set datejd [ date2jd [ string range $line 15 31] ]
         gren_info "dateiso = ([ mc_date2iso8601 $datejd]) $datejd \n"
         
         set ra [ string range $line 32 43]
         set ra [expr [mc_angle2deg $ra ] * 15.0]
         lappend tabra $ra
         gren_info "ra = $ra \n"

         set dec [ string range $line 44 55]
         set dec [expr [mc_angle2deg $dec ] ]
         lappend tabdec $dec
         gren_info "dec = $dec \n"

         set uai [ string range $line 77 79]
         gren_info "uai = $uai \n"
         
         set mesure($i) [list $datejd $ra $dec $uai]
         incr i
         
      }
      set nbdate $i
      
      gren_info "statistics :\n"
      set ra   [ ::math::statistics::mean  $tabra  ]
      set dec  [ ::math::statistics::mean  $tabdec ]
      set sra  [expr [ ::math::statistics::stdev $tabra  ] * 3600000.0]
      set sdec [expr [ ::math::statistics::stdev $tabdec ] * 3600000.0]

      gren_info "RESULTS FOR STAR :\n"
      gren_info "Mean RA  decimal = $ra  deg +- $sra mas\n"
      gren_info "Mean DEC decimal = $dec deg +- $sdec mas\n"
      
      set ra   [ mc_angle2hms $ra ]
      set dec  [ mc_angle2dms $dec ]
      
      gren_info "Mean RA  sexagesimal = $ra  \n"
      gren_info "Mean DEC sexagesimal = $dec \n"
      
      return
      
   }


   # le programme debute :
   
   read_file 

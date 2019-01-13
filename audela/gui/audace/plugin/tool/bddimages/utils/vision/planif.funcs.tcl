
# tc 1 :
#         Date TT               R.A            Dec.          Distance     V.Mag   Phase   Elong.  muRAcosDE     muDE      Dist_dot   
#       jour julien         h  m  s         o  '  "            ua.                  o        o      "/min       "/min       km/s       
#  
# tc 2 :
#         Date TT                X                 Y                 Z                Distance      Phase   Elong.      Xp                Yp                Zp                VR
#       jour julien             ua.               ua.               ua.                  ua.          o       o        ua/j              ua/j              ua/j              km/s
#  
# tc 3 :
#  Date TT Azimut Hauteur Distance   V.Mag   Phase   Elong.
#
# tc 4 : 
# Date TT Azimut Hauteur Distance   V.Mag   Phase   Elong.
#
# tc 5 : 
#    Date TT     TSL  RA/DEC J2000     H         Dec.           Az           h          AM        dg        dh     V.Mag  Phase Elong.  muRAcosDE     muDE      Dist_dot   
#  jour julien    h     h  m   s   o  '   "   h  m   s      o  '   "      o  '   "     o  '   "               ua.       ua.             o      o      "/min       "/min       km/s      
#


proc jd2key { jd } {
   return [string range [mc_date2iso8601 $jd] 0 15]
} 

proc criter_obs {  p_tpargs p_timeline p_ephem p_planif} {

   upvar $p_tpargs   tpargs
   upvar $p_timeline timeline
   upvar $p_ephem    ephem
   upvar $p_planif   planif

   foreach {key y} [array get timeline] {
      if {$ephem($key,sun,elev) > $tpargs(sun_elev)} {
         unset timeline($key)
      }
   }

   foreach {key y} [array get timeline] {
      
      # On boucle sur les asteroides
      set is_observable ""
      foreach target  [split $tpargs(targets) "," ] { 
         if {$ephem($key,$target,elev) > $tpargs(target_elev)} {
            # l objet est assez haut
            if {$ephem($key,$target,distmoon) > $tpargs(moon_sep)} {
               # l objet est assez loin de la lune
               lappend is_observable [list $target $ephem($key,${target},elev)]
            }
         }
      }
      
      # s il n y a pas d objet visible
      if {[llength $is_observable]==0} {
         unset timeline($key)
         continue
      }
   
      # s il y a plusieurs objets visibles 
      if {[llength $is_observable]>1} {
         set is_observable [lsort -index 1 -decreasing $is_observable]
      }

      set target [lindex $is_observable {0 0}]

      set planif($key,target)   $ephem($key,$target,name)
      set planif($key,ra)       $ephem($key,$target,ra)
      set planif($key,dec)      $ephem($key,$target,dec)
      set planif($key,elev)     $ephem($key,$target,elev)
      set planif($key,distmoon) $ephem($key,$target,distmoon)
      set planif($key,sunelev)  $ephem($key,sun,elev)
      set planif($key,moonelev) $ephem($key,moon,elev)

   }

      
} 

proc ephem { jdnow p_tpargs p_timeline p_ephem} { 

   upvar $p_tpargs   tpargs
   upvar $p_timeline timeline
   upvar $p_ephem    ephem
      
   global audace
   set nbdates 4320
   #set nbdates 150
   set outputdir [ file join $audace(rep_plugin) tool bddimages utils vision]  
      
      # Sun & Timeline
      set out [exec ephemcc planete -n 11  \
                               -uai $tpargs(iaucode)  \
                               -j $jdnow  \
                               --julian  \
                               -te 1  \
                               -tp 1  \
                               -tc 3  \
                               -s fichier  \
                               -r $outputdir \
                               -p 0.0006944444444  \
                               -d $nbdates  \
                               -f ephem_sun.dat
              ]

      set filename [ file join $audace(rep_plugin) tool bddimages utils vision ephem_sun.dat]
      set chan [open $filename r]
      while {![eof $chan]} {
         set line [gets $chan]
         if {[string length $line] == 0} {continue}
         if {[string range $line 0 0] == "#"} {
            #gren_info "No : $line\n"
            continue
         } else {
            #gren_info "Yes : $line\n"
         } 
         lappend text $line
      }
      close $chan

      foreach line $text {
         set a [regexp -inline -all -- {\S+} $line]
         lassign $a jd azd azm azs elevd elevm elevs
         set key [jd2key $jd]
         set sunelev [mc_angle2deg "${elevd}d${elevm}m${elevs}s" 90]
         set ephem($key,sun,elev) $sunelev
         set timeline($key) 1
      }
   
      # Moon tc 5 pour ra dec h, 
      set out [exec ephemcc planete -n 10  \
                               -uai $tpargs(iaucode)  \
                               -j $jdnow  \
                               --julian  \
                               -te 1  \
                               -tp 1  \
                               -tc 5  \
                               -s fichier  \
                               -r $outputdir \
                               -p 0.0006944444444  \
                               -d $nbdates  \
                               -f ephem_moon.dat
              ]

      set filename [ file join $audace(rep_plugin) tool bddimages utils vision ephem_moon.dat]
      set chan [open $filename r]
      while {![eof $chan]} {
         set line [gets $chan]
         if {[string length $line] == 0} {continue}
         if {[string range $line 0 0] == "#"} {
            #gren_info "No : $line\n"
            continue
         } else {
            #gren_info "Yes : $line\n"
         } 
         lappend text $line
      }
      close $chan

      foreach line $text {
         set a [regexp -inline -all -- {\S+} $line]
         lassign $a jd z moon_ra_h moon_ra_m moon_ra_s moon_dec_d moon_dec_m moon_dec_s b c d e f g h i j  moon_elev_d moon_elev_m moon_elev_s
         set key [jd2key $jd]
         set moon_ra   [mc_angle2deg "${moon_ra_h}h${moon_ra_m}m${moon_ra_s}s" ]
         set moon_dec  [mc_angle2deg "${moon_dec_d}d${moon_dec_m}m${moon_dec_s}s" 90]
         set moon_elev [mc_angle2deg "${moon_elev_d}d${moon_elev_m}m${moon_elev_s}s" 90]
         set ephem($key,moon,ra)   $moon_ra
         set ephem($key,moon,dec)  $moon_dec
         set ephem($key,moon,elev) $moon_elev
      }
      
      # Asteroides 
      foreach target  [split $tpargs(targets) "," ] {
         set target_name $target
         
         set out [exec ephemcc asteroide -n $target  \
                                  -uai $tpargs(iaucode)  \
                                  -j $jdnow  \
                                  --julian  \
                                  -te 1  \
                                  -tp 1  \
                                  -tc 5  \
                                  -s fichier  \
                                  -r $outputdir \
                                  -p 0.0006944444444  \
                                  -d $nbdates  \
                                  -f ephem_${target}.dat
                 ]

         set filename [ file join $audace(rep_plugin) tool bddimages utils vision ephem_${target}.dat]
         set chan [open $filename r]
         while {![eof $chan]} {
            set line [gets $chan]
            if {[string length $line] == 0} {continue}
            if {[string range $line 0 0] == "#"} {
               #gren_info "No : $line\n"
               
               if { [regexp {.*Asteroide *\d+ *(.*)} $line u name] } {
                  set target_name $name
               }
               
               continue
            } else {
               #gren_info "Yes : $line\n"
            } 
            lappend text $line
         }
         close $chan

         foreach line $text {
            set a [regexp -inline -all -- {\S+} $line]
            lassign $a jd z ra_h ra_m ra_s dec_d dec_m dec_s b c d e f g h i j elev_d elev_m elev_s
            set key [jd2key $jd]
            set ra   [mc_angle2deg "${ra_h}h${ra_m}m${ra_s}s" ]
            set dec  [mc_angle2deg "${dec_d}d${dec_m}m${dec_s}s" 90]
            set elev [mc_angle2deg "${elev_d}d${elev_m}m${elev_s}s" 90]

            set ephem($key,$target,name) $target_name
            set ephem($key,$target,ra)   $ra
            set ephem($key,$target,dec)  $dec
            set ephem($key,$target,elev) $elev
            
            set distmoon [lindex [mc_anglesep [list $ephem($key,moon,ra) $ephem($key,moon,dec) $ephem($key,${target},ra) $ephem($key,${target},dec)] degrees] 0]
            set ephem($key,${target},distmoon) $distmoon
            
         }
      
      }
   return 

}

#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils vision planif.tcl]
#--------------------------------------------------
#
# Fichier        : main.tcl
# Description    : lecture d un fichier de mesure pour calculer les offset sur l asteroide
# Auteur         : Frederic Vachier
# Mise à jour $Id: main.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#


   source [ file join $audace(rep_plugin) tool bddimages utils vision planif.funcs.tcl]

   array unset tpargs
   array unset timeline
   array unset ephem
   set tpargs(iaucode)  181
   set tpargs(targets)  "22,41,45,617"
   set tpargs(moon_illum)  90
   set tpargs(moon_sep)  30
   set tpargs(sun_elev)  -18
   set tpargs(target_elev)  40

   set isonow [mc_date2iso8601 now]
   set jdnow  [mc_date2jd $isonow]

   # Calcul des ephem pour tous les corps
   ephem $jdnow tpargs timeline ephem 
   
   # Criteres
   criter_obs tpargs timeline ephem planif


   # Affichage final

   set filename [ file join $audace(rep_plugin) tool bddimages utils vision planif.dat]
   set chan [open $filename w]

   gren_info "Time line : \n"
   set cpt 0
   set lst [lsort -uniq -index 0 [array get timeline]]
   puts $chan "# key            target               raJ2000    decJ2000   Expo   Elev      SunElev    MoonDist   MoonElev" 

   foreach key $lst {
      if {$key == 1 } {continue}
      gren_info "$key $ephem($key,sun,elev) $ephem($key,moon,elev)\n"

      puts $chan [format "%15s %-20s %10.6f %10.6f %5.1f %10.6f %10.6f %10.6f %10.6f" \
                    $key   \
                    $planif($key,target)  \
                    $planif($key,ra)      \
                    $planif($key,dec)     \
                    120 \
                    $planif($key,elev)    \
                    $planif($key,sunelev) \
                    $planif($key,distmoon)\
                    $planif($key,moonelev)\
           ]
      incr cpt
   }
   close $chan
   
   gren_info "nb dates : $cpt \n"

   # Fin
   return
   
   

   foreach key $timeline(lkeys) {

      if {$timeline($key,night) == 0} { continue }
      if {$timeline($key,moon,is_up) == 1} { 
         if {$timeline($key,moon,illum) > $tpargs(moon_illum)} { 
            continue
         }
      }
   
   }
   
   
   
   t jd [expr $jdnow + $i/1440.0]

   set observe [can_we_observe $jd data_struct]
   if {$observe == 0} {
      continue
   }

   if {[is_observable 22 $jd data_struct]} {
      gren_info "oui\n"
   }


}


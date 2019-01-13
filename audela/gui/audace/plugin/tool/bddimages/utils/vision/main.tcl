#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages utils vision main.tcl]
#--------------------------------------------------
#
# Fichier        : main.tcl
# Description    : lecture d un fichier de mesure pour calculer les offset sur l asteroide
# Auteur         : Frederic Vachier
# Mise à jour $Id: main.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#


source [ file join $audace(rep_plugin) tool bddimages utils vision vision.funcs.tcl]


array unset tvargs
set tvargs(iaucode)  007
set tvargs(date)     "1 10 2015"
set tvargs(step)     1
set tvargs(nb)       1
set tvargs(targets)  "a:22,a:41,a:45,a:617"
set tvargs(filename) [ file join $audace(rep_plugin) tool bddimages utils vision "ephevision_bdi.dat"]

# Genere le fichier de donnees
#set err [vision tvargs]

# Lit le fichier
set err [read_ephevision $tvargs(filename) data_struct]

if {$err == 1} { return }

set jdnow [mc_date2jd [mc_date2iso8601 now]]

for {set i 0} {$i < 1440} {incr i} {
   set jd [expr $jdnow + $i/1440.0]

   set observe [can_we_observe $jd data_struct]
   if {$observe == 0} {
      continue
   }

   if {[is_observable 22 $jd data_struct]} {
      gren_info "oui\n"
   }


}

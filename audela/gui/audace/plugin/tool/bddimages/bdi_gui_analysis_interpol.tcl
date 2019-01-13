## @file bdi_gui_analysis_interpol.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI d'analyse des donn&eacute;es observationnelles
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_analysis_interpol.tcl]
#  @endcode

# $Id: bdi_gui_analysis_interpol.tcl 13117 2016-05-21 02:00:00Z jberthier $

#----------------------------------------------------------------------------
proc ::bdi_gui_analysis::ephem_calcul_one_date { } {
  
   gren_info "Extrapolation : \n"
   

   if {$::bdi_gui_analysis::widget(famous,ephem,isodate) == "now"} {
      set datejd [ mc_date2jd now ]
   } else {
      set datejd [ mc_date2jd $::bdi_gui_analysis::widget(famous,ephem,isodate) ]
   }
   gren_info "Date iso $::bdi_gui_analysis::widget(famous,ephem,isodate) -> $datejd\n"
   
   set ::bdi_gui_analysis::widget(famous,ephem,sol) [format "%.4f" [::bdi_gui_famous::extrapole $datejd]]

   return     
}








proc ::bdi_gui_analysis::ephem_calcul_courbe { } {

   global bddconf

   gren_info "Courbe synthetique : \n"

   set period [expr $::bdi_gui_analysis::widget(graph,repli,period) / 24.0]

   set datejd0 [expr  [ mc_date2jd $::bdi_gui_analysis::widget(famous,ephem,isodate,first) ] - $::bdi_gui_analysis::widget(data,origin) ]
   set datejd1 [expr  [ mc_date2jd $::bdi_gui_analysis::widget(famous,ephem,isodate,end) ]   - $::bdi_gui_analysis::widget(data,origin) ]
   set tdiff [expr $datejd1 - $datejd0]
   
   gren_info "Nb de points pour l'interpolation -> $::bdi_gui_analysis::widget(famous,ephem,nbpts)\n"

   set filename [file join $bddconf(dirtmp) "synt.dat"]
   set f [open $filename "w"]

   set ::bdi_gui_analysis::widget(data,int,x) ""
   set ::bdi_gui_analysis::widget(data,int,xrep) ""
   set ::bdi_gui_analysis::widget(data,int,y) ""
   for {set i 0} {$i<=$::bdi_gui_analysis::widget(famous,ephem,nbpts)} {incr i} {
   
      set t [expr $::bdi_gui_analysis::widget(data,origin) + $i * $tdiff / $::bdi_gui_analysis::widget(famous,ephem,nbpts)]
      set x [::bdi_gui_analysis::jd_to_repli $t]
      set y [::bdi_gui_famous::extrapole $t ]
 
      puts $f "$t $y"
      lappend ::bdi_gui_analysis::widget(data,int,x) [expr $t-$::bdi_gui_analysis::widget(data,origin)]
      lappend ::bdi_gui_analysis::widget(data,int,xrep) [expr $x*24.0]
      lappend ::bdi_gui_analysis::widget(data,int,y) $y
   }


   close $f

   $::bdi_gui_analysis::widget(famous,graph,ordonnee,int) configure -relief sunken -state normal

   ::bdi_gui_analysis::graph

   gren_info "Fin\n"

   return     
}

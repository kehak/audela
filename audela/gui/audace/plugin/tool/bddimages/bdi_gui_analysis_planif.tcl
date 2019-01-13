## @file bdi_gui_analysis_planif.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI d'analyse des donn&eacute;es observationnelles
#             Fonctions dediees a la replanification d observation
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2017
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_analysis_planif.tcl]
#  @endcode

# $Id: bdi_gui_analysis_planif.tcl 13117 2016-05-21 02:00:00Z jberthier $
   
#----------------------------------------------------------------------------





#------------------------------------------------------------
## Rafraichi la liste des observatoires
#  @return void
proc ::bdi_gui_analysis::refresh_obs_list {  } {
   
   global conf
   global bddconf
   
   set ::bdi_gui_analysis::widget(planif,observatory,spinbox)  ""
   for {set i 0} {$i<=100} {incr i} {
      if {! [info exists conf(posobs,config_observatoire,$i)]} { break }
      if {$conf(posobs,config_observatoire,$i)==""} { continue }
      gren_info "[lindex $conf(posobs,config_observatoire,$i) 11]\n"
      lappend ::bdi_gui_analysis::widget(planif,observatory,spinbox) [lindex $conf(posobs,config_observatoire,$i) 11]
   }
   if {[info exists ::bdi_gui_analysis::widget(planif,observatory,frm)]} {
      if {[winfo exists ::bdi_gui_analysis::widget(planif,observatory,frm)]} {
         $::bdi_gui_analysis::widget(planif,observatory,frm) configure 
      }
   }
   return
}

#------------------------------------------------------------
## Grab sur le graphe repli les periodes min et max
#  @return void
proc ::bdi_gui_analysis::planif_grab_period {  } {

   set ::bdi_gui_analysis::widget(planif,period,min) ""
   set ::bdi_gui_analysis::widget(planif,period,max) ""

   set li [ ::plotxy::getgcf 1 ]
   if {$li == ""} {
      tk_messageBox -message "Veuillez ouvrir le graphe REPLI, pour proceder au GRAB" -type ok
   }
   
   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err!=0} {
      gren_info "err  = $err\n"
      gren_info "msg = $msg\n"
      tk_messageBox -message "Erreur GRAB : $msg" -type ok
      return
   }

   gren_info "rect = $rect\n"

   set xmin [format "%0.2f" [lindex $rect 0]]
   set xmax [format "%0.2f" [lindex $rect 2]]
   if {$xmin > $xmax} {
      set r $xmax
      set xmax $xmin
      set xmin $r
   }
      
   gren_info "xmin = $xmin\n"
   gren_info "xmax = $xmax\n"
   set ::bdi_gui_analysis::widget(planif,period,min) $xmin
   set ::bdi_gui_analysis::widget(planif,period,max) $xmax
   set ::bdi_gui_analysis::widget(planif,period,duree) [format "%0.2f" [expr $xmax-$xmin]]
   
   return
}

proc ::bdi_gui_analysis::get_xperiod { datejd } {

   set period $::bdi_gui_analysis::widget(graph,repli,period)
   set period  [expr $period/24.0]
   set x [expr $datejd - $::bdi_gui_analysis::widget(data,origin)]
   set p [expr $x - int($x/$period) * $period]

   return $p
}


#------------------------------------------------------------
## Calcul de la planif
#  @return void
proc ::bdi_gui_analysis::planif_calcul {  } {
   
   global bddconf
   
   # Init
   set ::bdi_gui_analysis::widget(planif,event,nb) ""

   # Verif
   if { $::bdi_gui_analysis::widget(planif,period,min) == "" } {
      tk_messageBox -message "Veuillez ouvrir le graphe REPLI, et proceder au GRAB" -type ok
      return
   }
   if { $::bdi_gui_analysis::widget(planif,period,max) == "" } {
      tk_messageBox -message "Veuillez ouvrir le graphe REPLI, et proceder au GRAB" -type ok
      return
   }
   set date0 [mc_date2jd now]
   set date1 [expr $date0 + 60]
   set ::bdi_gui_analysis::widget(planif,observatory,uaicode) "181"
   set home [::bdi_gui_cdl::uai2home $::bdi_gui_analysis::widget(planif,observatory,uaicode)]

   set name_aster $::bdi_gui_analysis::widget(data,aster,name)
   set id_aster $::bdi_gui_analysis::widget(data,aster,id)
   set pmin $::bdi_gui_analysis::widget(planif,period,min)
   set pmax $::bdi_gui_analysis::widget(planif,period,max)
   set period $::bdi_gui_analysis::widget(graph,repli,period)
   set duree [expr $pmax - $pmin]
   
   gren_info "t origin = $::bdi_gui_analysis::widget(data,origin)\n"
   gren_info "periode min = $pmin\n"
   gren_info "periode max = $pmax\n"
   gren_info "duree = $duree\n"
   gren_info "periode = $period\n"
   gren_info "date debut = [ mc_date2iso8601 $date0 ]\n"
   gren_info "date fin = [ mc_date2iso8601 $date1 ]\n"
   gren_info "UAI = $::bdi_gui_analysis::widget(planif,observatory,uaicode)\n"
   gren_info "home = $home\n"
   gren_info "Asteroid Name = $name_aster\n"
   gren_info "Asteroid ID   = $id_aster\n"

   set period  [expr $period/24.0]
   set pmin    [expr $pmin/24.0]
   set pmax    [expr $pmax/24.0]
   set duree   [expr $duree/24.0]
   set pmin    [expr $pmin - 10.0/60.0/24.0]
   set pmax    [expr $pmax + 10.0/60.0/24.0]
   
   gren_info "vo_getmpcephem $id_aster $date0  { $home }  10 m 4000\n"
   set r [vo_getmpcephem $id_aster $date0 $home 10 m 4000]
   #set r [vo_getmpcephem $id_aster $date0 $home 10 m 144]

   set list_obs ""
   set list_night ""
   set dmin ""
   set dminn ""
   foreach ephem $r {
      lassign $ephem obj_name obj_date obj_ra obj_dec obj_drift_ra obj_drift_dec obj_magv obj_az obj_elev obj_elong obj_phase obj_r obj_delta sun_elev
      set datejd [mc_date2jd $obj_date]
      set p [::bdi_gui_analysis::get_xperiod $datejd]
      #gren_info "$obj_date   obj_elev   = $obj_elev    sun_elev   = $sun_elev  period= [expr $p*24.0]\n"

      # nights
      if {$sun_elev < -12 && $obj_elev > 30} {
         # L objet est observable
         if {$dminn == ""} {
            # debut d observation
            set dminn $obj_date
         }
         set dsavn $obj_date
      } else {
         # L objet n est pas observable
         if {$dminn != ""} {
            # fin d observation
            set t0 [mc_date2jd $dminn]
            set t1 [mc_date2jd $dsavn]
            lappend list_night [list $id_aster $name_aster $dminn $dsavn]
            set dminn ""
         }
      }
      
      # Trous
      if {$sun_elev < -12 && $obj_elev > 30 && $p > $pmin && $p < $pmax} {
         # L objet est observable
         if {$dmin == ""} {
            # debut d observation
            set dmin $obj_date
            #gren_info "DEBUT : $obj_date   obj_elev= $obj_elev    sun_elev   = $sun_elev  period= [expr $p*24.0] [expr $pmin*24.0] [expr $pmax*24.0] \n"
         }
         set psav $p
         set dsav $obj_date
         #gren_info "Fin : $obj_date [expr $p*24.0]\n"
      } else {
         # L objet n est pas observable
         if {$dmin != ""} {
            # fin d observation
            set t0 [mc_date2jd $dmin]
            set t1 [mc_date2jd $dsav]
            #gren_info "DEBUT : $obj_date   obj_elev= $obj_elev    sun_elev   = $sun_elev  period= [expr $p*24.0] [expr $pmin*24.0] [expr $pmax*24.0] \n"
            #gren_info " pc : $t0 $dmin $t1 $dsav $duree  \n"
            set pc [format "%d" [expr int(($t1-$t0)/$duree*100.0)]]
            if {$pc>100} {set pc 100}
            if {$pc>0} {lappend list_obs [list $id_aster $name_aster $dmin $dsav $pc]}
            set dmin ""
         }
      }
   }
   set ::bdi_gui_analysis::widget(planif,nights) $list_night
   set ::bdi_gui_analysis::widget(planif,results) $list_obs
   #gren_info "obs : \n"
   set nb 0
   foreach d $list_obs {
      incr nb
      set x0 [format "%0.2f" [expr [::bdi_gui_analysis::get_xperiod [mc_date2jd [lindex $d 2]]] * 24.0]]
      set x1 [format "%0.2f" [expr [::bdi_gui_analysis::get_xperiod [mc_date2jd [lindex $d 3]]] * 24.0]]
      
      gren_info "[lindex $d 2] -> [lindex $d 3] :: [lindex $d 4]% :: $x0 :: $x1\n"
   }
   set ::bdi_gui_analysis::widget(planif,scale) 0
   set ::bdi_gui_analysis::widget(planif,event,nb) $nb
   
   gren_info "fin\n"
   
   return
}

#------------------------------------------------------------
## Visualisation des resultats
#  @return void
proc ::bdi_gui_analysis::planif_view_results {  } {

   global bddconf

   set ::bdi_gui_analysis::widget(planif,event,frm) .bdi_analysis_planif
   if { [winfo exists $::bdi_gui_analysis::widget(planif,event,frm)] } {
      wm withdraw $::bdi_gui_analysis::widget(planif,event,frm)
      wm deiconify $::bdi_gui_analysis::widget(planif,event,frm)
      focus $::bdi_gui_analysis::widget(planif,event,frm)
      ::bdi_gui_analysis::planif_view_results_work -1
      return
   }

   toplevel $::bdi_gui_analysis::widget(planif,event,frm) -class Toplevel
   if {[ info exists bddconf(analysis_planif_event,geometry)]} {
      wm geometry $::bdi_gui_analysis::widget(planif,event,frm) $bddconf(analysis_planif_event,geometry)
   }
   wm resizable $::bdi_gui_analysis::widget(planif,event,frm) 1 1
   wm title $::bdi_gui_analysis::widget(planif,event,frm) "Resultats de la Planification"
   wm protocol $::bdi_gui_analysis::widget(planif,event,frm) WM_DELETE_WINDOW "::bdi_gui_analysis::planif_view_close"

   set frm [frame $::bdi_gui_analysis::widget(planif,event,frm).appli -borderwidth 1 -cursor arrow -relief groove]
   grid $frm -in $::bdi_gui_analysis::widget(planif,event,frm) -sticky news
   
      text $::bdi_gui_analysis::widget(planif,event,frm).txt  -width 70 -height 25
      grid $::bdi_gui_analysis::widget(planif,event,frm).txt  -in $::bdi_gui_analysis::widget(planif,event,frm) -sticky news


   ::bdi_gui_analysis::planif_view_results_work -1
   return
}





proc ::bdi_gui_analysis::planif_view_results_work { w } {
   
   if {![info exists ::bdi_gui_analysis::widget(planif,event,frm)]}  { return }
   if {![winfo exists $::bdi_gui_analysis::widget(planif,event,frm)]}  { return }
   
   $::bdi_gui_analysis::widget(planif,event,frm).txt delete 0.0 end 
   set nb 0
   foreach d $::bdi_gui_analysis::widget(planif,results) {
      lassign $d id_aster name_aster dmin dmax pc
      if {$pc>=$::bdi_gui_analysis::widget(planif,scale)} {
         incr nb
         $::bdi_gui_analysis::widget(planif,event,frm).txt insert end "$id_aster, $name_aster, $dmin, $dmax, $pc%\n"
      }
   }
   set ::bdi_gui_analysis::widget(planif,event,nb) $nb
      
   return
}






proc ::bdi_gui_analysis::planif_view_close {  } {
   global bddconf
   set bddconf(analysis_planif_event,geometry) [wm geometry $::bdi_gui_analysis::widget(planif,event,frm)]
   destroy $::bdi_gui_analysis::widget(planif,event,frm)
   return
}







proc ::bdi_gui_analysis::planif_view_nights_close {  } {
   global bddconf
   set bddconf(analysis_nights,geometry) [wm geometry $::bdi_gui_analysis::fenan]
   destroy $::bdi_gui_analysis::fenan
   return
}






# Fenetre boutons de la liste des prochaines nuits d observation
proc ::bdi_gui_analysis::planif_view_nights {  } {

   global bddconf
   
   if {[llength $::bdi_gui_analysis::widget(planif,nights)]==0} {
      tk_messageBox -message "Veuillez proceder au calcul" -type ok
      return
   }
   set d [lindex $::bdi_gui_analysis::widget(planif,nights) 0]
   lassign $d id_aster name_aster dmin dmax

   
   set ::bdi_gui_analysis::fenan .bdi_analysis_nights
   if { [winfo exists $::bdi_gui_analysis::fenan] } {
      ::bdi_gui_analysis::planif_view_nights_close
   }

   toplevel $::bdi_gui_analysis::fenan -class Toplevel
   if {[ info exists bddconf(analysis_nights,geometry)]} {
      wm geometry $::bdi_gui_analysis::fenan $bddconf(analysis_nights,geometry)
   }
   wm resizable $::bdi_gui_analysis::fenan 1 1
   wm title $::bdi_gui_analysis::fenan "Next nights for ($id_aster) $name_aster"
   wm protocol $::bdi_gui_analysis::fenan WM_DELETE_WINDOW "::bdi_gui_analysis::planif_view_nights_close"

   set frm [frame $::bdi_gui_analysis::fenan.appli -borderwidth 1 -cursor arrow -relief groove]
   grid $frm -in $::bdi_gui_analysis::fenan -sticky news
   
   set cpt 0
   
   foreach d $::bdi_gui_analysis::widget(planif,nights) {
      incr cpt
      set ::bdi_gui_analysis::widget(planif,nights,cbutton,$cpt) 0
      lassign $d id_aster name_aster dmin dmax
      checkbutton $frm.c$cpt -highlightthickness 0 -variable ::bdi_gui_analysis::widget(planif,nights,cbutton,$cpt)
      Button  $frm.b$cpt -text "$dmin - $dmax" -command "::bdi_gui_analysis::planif_view_nights_trace $cpt"
      grid $frm.c$cpt $frm.b$cpt -in $frm -sticky news
      if {$cpt>=10} {break}
   }
   set frm2 [frame $::bdi_gui_analysis::fenan.action -borderwidth 1 -cursor arrow -relief groove]
   grid $frm2 -in $::bdi_gui_analysis::fenan -sticky news
   Button  $frm2.b -text "View Result" -command "::bdi_gui_analysis::planif_view_results_night"
   grid $frm2.b -in $frm2 -sticky news
      
   return
}






# Liste dans la fenetre resultat les prochaines nuit d observation pour l asteroide
proc ::bdi_gui_analysis::planif_view_results_night { } {

   set ::bdi_gui_analysis::widget(planif,results) ""
   for {set cpt 1} {$cpt<=10} {incr cpt} {
      if {$::bdi_gui_analysis::widget(planif,nights,cbutton,$cpt)==1} {
         gren_info "button : $cpt : Checked\n"
         set d [lindex $::bdi_gui_analysis::widget(planif,nights) [expr $cpt-1]]
         lassign $d id_aster name_aster dmin dmax
         lappend ::bdi_gui_analysis::widget(planif,results) [list $id_aster $name_aster $dmin $dmax 100]
      }
   }

   if {![winfo exists $::bdi_gui_analysis::widget(planif,event,frm)]}  { 
      ::bdi_gui_analysis::planif_view_results
   } else {
      ::bdi_gui_analysis::planif_view_results_work -1
   }
}


# Trace sur le graphe la planif d une nuit d observation
proc ::bdi_gui_analysis::planif_view_nights_trace { cpt } {

   # verification de la presence du graphe REPLI   
   set li [ ::plotxy::getgcf 1 ]
   if {$li != ""} {
      set title [::plotxy::title]
      set p [string first "turn back time" $title]
      if {$p==-1} {
         tk_messageBox -message "Veuillez ouvrir le graphe REPLI" -type ok
         return
      }
   } else {
      tk_messageBox -message "Veuillez ouvrir le graphe REPLI" -type ok
      return
   }
   
   array set solu $::bdi_tools_famous::lsolu
   set period [expr $::bdi_gui_analysis::widget(graph,repli,period) / 24.0]
   gren_info "period = $::bdi_gui_analysis::widget(graph,repli,period) h\n"
   
   set d [lindex $::bdi_gui_analysis::widget(planif,nights) [expr $cpt-1]]
   lassign $d id_aster name_aster dmin dmax
   set dminjd [mc_date2jd $dmin]
   set dmaxjd [mc_date2jd $dmax]
   gren_info "$dmin <> $dmax\n"
   gren_info "$dminjd <> $dmaxjd\n"
   set x ""
   set y ""
   set nbpts 100
   for {set i 0} {$i<$nbpts} {incr i} {
      set t [expr ($dmaxjd-$dminjd)/($nbpts-1)*double($i)+$dminjd]
      set to [expr $t - $::bdi_gui_analysis::widget(data,origin)]
      set p [::bdi_gui_analysis::get_xperiod $t]
      set u [::bdi_gui_famous::extrapole $t]
      lappend x [expr $p*24.0]
      lappend y $u
   }
   ::bdi_gui_analysis::graph   
   
   set hnight [::plotxy::plot $x $y ro. 20]
   plotxy::sethandler $hnight [list -color cyan -linewidth 0]
   
   return
}

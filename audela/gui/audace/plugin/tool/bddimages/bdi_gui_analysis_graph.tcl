## @file bdi_gui_analysis_data.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI d'analyse des donn&eacute;es observationnelles
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_analysis_data.tcl]
#  @endcode

# $Id: bdi_gui_analysis_data.tcl 13117 2016-05-21 02:00:00Z jberthier $
   
#----------------------------------------------------------------------------



#------------------------------------------------------------
## Applique seulement le relief sur le bouton 
#  @param w  :  selection du type
#  @return void
proc ::bdi_gui_analysis::graph_but_ordonnee { w } {
   gren_info "w= $w selected = $::bdi_gui_analysis::widget(famous,graph,ordonnee,selected) \n"

   if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,$w) cget -relief]=="raised"} {
      $::bdi_gui_analysis::widget(famous,graph,ordonnee,$w) configure -relief sunken
   } else {
      $::bdi_gui_analysis::widget(famous,graph,ordonnee,$w) configure -relief raised
   }
   
   ::bdi_gui_analysis::graph
   
   return
}





proc ::bdi_gui_analysis::graph_but_abscisse { w } {
   
   gren_info "w= $w\n"
   #if {$w == $::bdi_gui_analysis::widget(famous,graph,abscisse,selected)} {return}
   set ::bdi_gui_analysis::widget(famous,graph,abscisse,selected) $w

   switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
      "tjjo"   { 
         $::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  configure -relief sunken
         $::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,repli) configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,pack)  configure -relief raised
      }
      "idx"    { 
         $::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   configure -relief sunken
         $::bdi_gui_analysis::widget(famous,graph,abscisse,repli) configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,pack)  configure -relief raised
      }
      "repli"  { 
         $::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,repli) configure -relief sunken
         $::bdi_gui_analysis::widget(famous,graph,abscisse,pack)  configure -relief raised
      }
      "pack"  { 
         $::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,repli) configure -relief raised
         $::bdi_gui_analysis::widget(famous,graph,abscisse,pack)  configure -relief sunken
      }
   }

   ::bdi_gui_analysis::graph
   
   return
}

proc ::bdi_gui_analysis::graph_close { } {

   set li [ ::plotxy::getgcf 1 ]
   if {$li != ""} {
      ::plotxy::clf 1
   }
   return
}

#------------------------------------------------------------
## affiche le graphe des donnees
#  @return void
#
proc ::bdi_gui_analysis::graph_init { } {

   set li [ ::plotxy::getgcf 1 ]
   if {$li != ""} {
      set p  [lsearch -index 0 $li parent] 
      set parent [lindex [ ::plotxy::getgcf 1 ] [lsearch -index 0 $li parent] 1 ]
      set geom [wm geometry $parent]
      set r [split $geom "+"]
      set size [lindex $r 0]
      set posx [lindex $r 1]
      set posy [lindex $r 2]
      set r [split $size "x"]
      set sizex [lindex $r 0]
      set sizey [lindex $r 1]
      set pos [list $posx $posy $sizex $sizey]
   } else {
      set pos {0 0 600 400}
   }
         
   ::plotxy::clf 1
   ::plotxy::figure 1 
   ::plotxy::hold on 
   ::plotxy::position $pos
   ::plotxy::title ""
   ::plotxy::xlabel "" 
   ::plotxy::ylabel $::bdi_gui_analysis::widget(famous,ephem,typeofdata)
   ::plotxy::ydir reverse
}



proc ::bdi_gui_analysis::graph { } {
   
   ::bdi_gui_analysis::graph_init
   #::bdi_gui_analysis::trace_data
   ::bdi_gui_analysis::trace
   
}



proc ::bdi_gui_analysis::trace { } {
   
   if {![info exists ::bdi_gui_analysis::widget(famous,graph,abscisse,selected)]} {return}
   
# Selection des abscisses
   ::plotxy::ylabel "mag" 
   switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
      "tjjo"   { 
         ::plotxy::title "Light curve (Mag vs julian date)"
         ::plotxy::xlabel "Time (julian date)" 
      }
      "idx"    { 
         ::plotxy::title "Light curve (Mag vs index)"
         ::plotxy::xlabel "index" 
      }
      "repli"  { 
         ::plotxy::xlabel "hours" 
         set period [ expr $::bdi_gui_analysis::widget(graph,repli,period) / 24.0]
         set xperiod [expr $period * 20.0 / 100.0]
         set title "$::bdi_gui_analysis::widget(data,aster,idname) : "
         append title "Light curve (Mag vs turn back time) "
         append title "Period = $::bdi_tools_famous::result(period) "
         append title "+- $::bdi_tools_famous::result(err_period) h "
         ::plotxy::title $title
      }
      "pack"  { 
         ::plotxy::title "Light curve (Mag vs time) packed"
         ::plotxy::xlabel "Time (julian date)" 
      }
   }

# Selection des ordonnees


# int

   # raw : Donnees brutes
   if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,raw) cget -relief] == "sunken"} {
      

      switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {

         "tjjo"   { 
            set x ""
            set y ""
            set xs ""
            set ys ""
            set xg ""
            set yg ""
            foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
               set id  [lindex $r 0]
               if {$::bdi_gui_analysis::widget(data,$id,batch) in $::bdi_gui_analysis::widget(data,batch,selected)} {
                  lappend xs $::bdi_gui_analysis::widget(data,$id,tjjo)
                  lappend ys $::bdi_gui_analysis::widget(data,$id,raw)
               } else {
                  lappend x $::bdi_gui_analysis::widget(data,$id,tjjo)
                  lappend y $::bdi_gui_analysis::widget(data,$id,raw)
               }
            }
            if { [llength $x] >0 } {
               set hraw [::plotxy::plot $x $y ro. 2 ]
               plotxy::sethandler $hraw [list -color red -linewidth 0]
            }
            if { [llength $xs] >0 } {
               set hraws [::plotxy::plot $xs $ys ro. 2 ]
               plotxy::sethandler $hraws [list -color green -linewidth 0]
            }
         }

         "idx"    { 
            set x ""
            set y ""
            foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
               set id  [lindex $r 0]
               lappend x $::bdi_gui_analysis::widget(data,$id,idx)
               lappend y $::bdi_gui_analysis::widget(data,$id,raw)
            }
            if { [llength $x] >0 } {
               set hsol [::plotxy::plot $x $y ro. 2 ]
               plotxy::sethandler $hsol [list -color red -linewidth 0]
            }
         }

         "repli"  { 
            set x ""
            set y ""
            set xs ""
            set ys ""
            foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
               set id  [lindex $r 0]
               if {$::bdi_gui_analysis::widget(data,$id,batch) in $::bdi_gui_analysis::widget(data,batch,selected)} {
                  lappend xs [expr $::bdi_gui_analysis::widget(data,$id,repli)*24.0]
                  lappend ys $::bdi_gui_analysis::widget(data,$id,raw)
               } else {
                  lappend x [expr $::bdi_gui_analysis::widget(data,$id,repli)*24.0]
                  lappend y $::bdi_gui_analysis::widget(data,$id,raw)
               }
               if {$::bdi_gui_analysis::widget(data,$id,repli) < $xperiod} {
                  lappend xg [expr ($::bdi_gui_analysis::widget(data,$id,repli) + $period)*24.0]
                  lappend yg $::bdi_gui_analysis::widget(data,$id,raw)
               }
               if {$::bdi_gui_analysis::widget(data,$id,repli) > [expr $period-$xperiod]} {
                  lappend xg [expr ($::bdi_gui_analysis::widget(data,$id,repli) - $period)*24.0]
                  lappend yg $::bdi_gui_analysis::widget(data,$id,raw)
               }
            }
            if { [llength $xs] >0 } {
               set hraws [::plotxy::plot $xs $ys ro. 2 ]
               plotxy::sethandler $hraws [list -color green -linewidth 0]
            }
            if { [llength $x] >0 } {
               set hraw [::plotxy::plot $x $y ro. 2 ]
               plotxy::sethandler $hraw [list -color red -linewidth 0]
            }
            if { [llength $xg] >0 } {
               set hrawg [::plotxy::plot $xg $yg ro. 2 ]
               plotxy::sethandler $hrawg [list -color yellow -linewidth 0]
            }
         }

         "pack"  { 
            set x ""
            set y ""
            foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
               set id  [lindex $r 0]
               lappend x $::bdi_gui_analysis::widget(data,$id,xpack)
               lappend y $::bdi_gui_analysis::widget(data,$id,raw)
            }
            if { [llength $x] >0 } {
               set hsol [::plotxy::plot $x $y ro. 2 ]
               plotxy::sethandler $hsol [list -color red -linewidth 0]
            }
         }
      }

      
   }

   # sol : Donnees Simulee
   if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) cget -relief] == "sunken"} {
      if {[info exists ::bdi_gui_analysis::widget(famous,graph,abscisse,selected)]} {
         switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
            "tjjo"   {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,tjjo)
                  lappend y $::bdi_gui_analysis::widget(data,$id,sol)
               }
               if { [llength $x] >0 } {
                  set hsol [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hsol [list -color black -linewidth 0]
               }
            }
            "idx"    {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,idx)
                  lappend y $::bdi_gui_analysis::widget(data,$id,sol)
               }
               if { [llength $x] >0 } {
                  set hsol [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hsol [list -color black -linewidth 0]
               }
            }
            "repli"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x [expr $::bdi_gui_analysis::widget(data,$id,repli)*24.0]
                  lappend y $::bdi_gui_analysis::widget(data,$id,sol)
               }
               if { [llength $x] >0 } {
                  set hsol [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hsol [list -color black -linewidth 0]
               }
            }
            "pack"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,xpack)
                  lappend y $::bdi_gui_analysis::widget(data,$id,sol)
               }
               if { [llength $x] >0 } {
                  set hsol [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hsol [list -color black -linewidth 0]
               }
            }
         }
      }
   }

   # int : Donnees interpolees
   if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,int) cget -relief] == "sunken"} {
      switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
         "tjjo"   {
            set hint [::plotxy::plot $::bdi_gui_analysis::widget(data,int,x) $::bdi_gui_analysis::widget(data,int,y) ro. 2 ]
            plotxy::sethandler $hint [list -color grey -linewidth 1]
         }
         "repli"  {
            set hint [::plotxy::plot $::bdi_gui_analysis::widget(data,int,xrep) $::bdi_gui_analysis::widget(data,int,y) ro. 2 ]
            plotxy::sethandler $hint [list -color grey -linewidth 0]
         }
      }
   }

   # res : Residus
   if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,res) cget -relief] == "sunken"} {

      if {[$::bdi_gui_analysis::widget(famous,graph,ordonnee,raw) cget -relief] == "sunken" || \
          [$::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) cget -relief] == "sunken" } {
         # si residu et raw ou sol aussi
         
         # calcul de la magnitude moyenne
         set tab ""
         foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
            lappend tab $::bdi_gui_analysis::widget(data,[lindex $r 0],raw)
         }
         set meanraw [::math::statistics::mean $tab]
         
         # calcul du graphe
         switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
            "tjjo"   {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,tjjo)
                  lappend y [expr $::bdi_gui_analysis::widget(data,$id,res) + $meanraw]
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "idx"    {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,idx)
                  lappend y [expr $::bdi_gui_analysis::widget(data,$id,res) + $meanraw]
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "repli"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x [expr $::bdi_gui_analysis::widget(data,$id,repli)*24.0]
                  lappend y [expr $::bdi_gui_analysis::widget(data,$id,res) + $meanraw]
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "pack"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,xpack)
                  lappend y [expr $::bdi_gui_analysis::widget(data,$id,res) + $meanraw]
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
         }




      } else {
         # seulement residu        
         switch $::bdi_gui_analysis::widget(famous,graph,abscisse,selected) {
            "tjjo"   {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,tjjo)
                  lappend y $::bdi_gui_analysis::widget(data,$id,res)
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "idx"    {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,idx)
                  lappend y $::bdi_gui_analysis::widget(data,$id,res)
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "repli"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x [expr $::bdi_gui_analysis::widget(data,$id,repli)*24.0]
                  lappend y $::bdi_gui_analysis::widget(data,$id,res)
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
            "pack"  {
               set x ""
               set y ""
               foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
                  set id  [lindex $r 0]
                  lappend x $::bdi_gui_analysis::widget(data,$id,xpack)
                  lappend y $::bdi_gui_analysis::widget(data,$id,res)
               }
               if { [llength $x] >0 } {
                  set hres [::plotxy::plot $x $y ro. 2 ]
                  plotxy::sethandler $hres [list -color blue -linewidth 0]
               }
            }
         }
      
      }

   }
   
 
}



proc ::bdi_gui_analysis::residus_to_widget {  } {

}



proc ::bdi_gui_analysis::trace_data {  } {

   set h [::plotxy::plot $::bdi_gui_analysis::widget(data,x) $::bdi_gui_analysis::widget(data,y) ro. 2 ]
   plotxy::sethandler $h [list -color red -linewidth 0]

}



proc ::bdi_gui_analysis::trace_residus {  } {

   global bddconf
    
   $::bdi_gui_analysis::widget(famous,button,residus)   configure -relief "sunken"
   $::bdi_gui_analysis::widget(famous,button,solution)  configure -relief "raised"
   $::bdi_gui_analysis::widget(famous,button,both)      configure -relief "raised"

   ::bdi_gui_analysis::graph_init

   set file_res [file join $bddconf(dirtmp) "resid_final.txt"]
   set xo ""
   set yo ""
   set f [open $file_res "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      set line [regsub -all \[\s\] $line ,]
      set r [split [string trim $line] ","]
 #     gren_info "r = [lindex $r 0]  [lindex $r 1]  \n"
      lappend xo [lindex [lindex $r 0] 0 ]  
      lappend yo [expr [lindex [lindex $r 0] 1 ]]
   }
   close $f
   
   set hres [::plotxy::plot $xo $yo 0]
   plotxy::sethandler $hres [list -color blue -linewidth 2]

}






proc ::bdi_gui_analysis::point_trace_one_date {  } {
   
   gren_info "Trace un point\n"
   gren_info "Date ISO : $::bdi_gui_analysis::widget(famous,point,isodate) \n"
   gren_info "Colonne : $::bdi_gui_analysis::widget(famous,ephem,typeofdata) \n"
   gren_info "Valeur : $::bdi_gui_analysis::widget(famous,point,sol)  \n"

   set datejd [ mc_date2jd $::bdi_gui_analysis::widget(famous,point,isodate) ]
   set x [expr $datejd - $::bdi_gui_analysis::widget(data,origin)]
   set y $::bdi_gui_analysis::widget(famous,point,sol)
   
   set hpnt [::plotxy::plot $x $y ro. 5]
   plotxy::sethandler $hpnt [list -color green -linewidth 0]

}

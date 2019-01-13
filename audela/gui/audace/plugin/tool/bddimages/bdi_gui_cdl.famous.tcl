## @file bdi_gui_cdl.famous.tcl
#  @brief     GUI de lancement de Famous dans l appli de Photometrie
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cdl.famous.tcl]
#  @endcode

# $Id: bdi_gui_cdl.famous.tcl 13117 2016-05-21 02:00:00Z jberthier $


#------------------------------------------------------------
## Appuie du bouton GO dans le Frame de GUI
#  @return void
#
proc ::bdi_gui_cdl::famous_widget_go { frm } {
   $frm.setup.action.r.go configure -relief sunken
   set ::bdi_gui_cdl::widget(famous,status) "data creating"
   ::bdi_gui_cdl::famous_crea_data
   ::bdi_gui_cdl::famous_launch
   set ::bdi_gui_cdl::widget(famous,status) "Graphic"
   ::bdi_gui_cdl::famous_graph   
   $frm.setup.action.r.go configure -relief raised
   set ::bdi_gui_cdl::widget(famous,status) "END"
}
#------------------------------------------------------------
## FAMOUS: mise a jour de l table cata_list en prevision d'une
#  sauvegarde dans les fichiers cata.xml
#  @return void
#
proc ::bdi_gui_cdl::update_error { } {
   foreach listsources $::bdi_gui_cata::cata_list($idcata) {
      
      set sources [lindex  $::tools_cata::current_listsources 1]
      set ids -1
      foreach s $sources {
         incr ids

         set name [::manage_source::namincata $s]
         if {$name == ""} {continue}
   
      }
   }
}
#------------------------------------------------------------
## FAMOUS: Creation du fichier de data pour le lancement de Famous
#  @return void
#
proc ::bdi_gui_cdl::famous_crea_data { } {

   global bddconf

   # Selection de l objet science
   set i 0
   foreach l [$::bdi_gui_cdl::data_science get 0 end] {
      set name [lindex $l 1]
      if {$name == $::bdi_gui_cdl::widget(objsel,combo,value)} {
         break
      }
      incr i
   }

   # RAZ du resultat Famous
   if {[info exists ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std)]} {
      unset ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std)
   }

   # Selection dans l onglet science
   $::bdi_gui_cdl::data_science selection clear 0 end
   $::bdi_gui_cdl::data_science selection set $i $i
   $::bdi_gui_cdl::data_science see $i

   # Verification des erreurs
   set nb_err_psf [lindex [$::bdi_gui_cdl::data_science get $i $i] 0 6]
   if {$nb_err_psf !=0 } {
      tk_messageBox -message "La table presente $nb_err_psf erreur(s) de mesure\nCorrigez la table des donnees" -type ok
      ::bdi_gui_cdl::table_popup sci
      return
   }
   
   # Chargement des gui
   ::bdi_gui_cdl::table_popup sci
   $::bdi_gui_cdl::data_source  sortbycolumn 4 -increasing
   $::bdi_gui_cdl::data_source  see 0
   
   
   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 0 } {
#      ::bdi_gui_cdl::graph_science_mag_popup_exec
   }
   ::plotxy::clf $::bdi_gui_cdl::figScimag
   ::bdi_gui_cdl::graph_science_mag_popup_exec
   
   # Creation du fichier de donnees
   set filename [file join $bddconf(dirtmp) "famous.dat"]
   set f [open $filename "w"]
   
   set txtfile ""      
   for {set i 0} {$i<[$::bdi_gui_cdl::data_source size]} {incr i} {
      set ids    [lindex [$::bdi_gui_cdl::data_source get $i] 0]
      set idcata [lindex [$::bdi_gui_cdl::data_source get $i] 3]
      
      set err [catch {set y  $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)} msg]
      if {$err==0} {
         set x  $::bdi_tools_cdl::idcata_to_jdc($idcata)
         puts $f "$x $y"
      } else {
         gren_erreur "Valeur de mag non definie => ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)\n"
      }
   }
   close $f
   
   set ::bdi_gui_cdl::widget(famous,stats,nb_dates)       ""
   set ::bdi_gui_cdl::widget(famous,stats,time_span)      ""
   set ::bdi_gui_cdl::widget(famous,stats,idm)            ""
   set ::bdi_gui_cdl::widget(famous,stats,residuals_mean) ""
   set ::bdi_gui_cdl::widget(famous,stats,residuals_std)  ""
   set ::bdi_gui_cdl::widget(famous,typeofsolu)           ""

   set err [catch {file delete [file join $bddconf(dirtmp) famous.res] } msg]
   if {$err} {
      gren_info "famous : delete out file famous.res : error #$err: $msg\n" 
      return
   } 
   set err [catch {file delete [file join $bddconf(dirtmp) resid_final.txt] } msg]
   if {$err} {
      gren_info "famous : delete out file resid_final.txt : error #$err: $msg\n" 
      return
   } 


}

#------------------------------------------------------------
## Appuie du bouton GO dans le Frame de GUI
#  @return void
#
#   il existe   ::bdi_tools_famous::solu  <- ::bdi_tools_famous::lsolu
proc ::bdi_gui_cdl::famous_launch { } {
   
   # Lancement du programme
   set ::bdi_gui_cdl::widget(famous,status) "Launching Famous"
   ::bdi_tools_famous::famous

   # Lecture des residus
   set ::bdi_gui_cdl::widget(famous,status) "Residus reading"
   ::bdi_tools_famous::read_residus ::bdi_gui_cdl::widget(famous,data,x) \
                                    ::bdi_gui_cdl::widget(famous,data,res) \
                                    ::bdi_gui_cdl::widget(famous,data,sol) \
                                    ::bdi_gui_cdl::widget(famous,stats,nb_dates) \
                                    ::bdi_gui_cdl::widget(famous,stats,time_span_jd) \
                                    ::bdi_gui_cdl::widget(famous,stats,residuals_mean) \
                                    ::bdi_gui_cdl::widget(famous,stats,residuals_std) \
                                    ::bdi_gui_cdl::widget(famous,stats,residuals_ampl)

   set ::bdi_gui_cdl::widget(famous,typeofsolu)               $::bdi_tools_famous::typeofsolu
   
   if {$::bdi_gui_cdl::widget(famous,stats,time_span_jd) < 1 } {
      set ::bdi_gui_cdl::widget(famous,stats,time_span) [format "%.2f hours" [expr $::bdi_gui_cdl::widget(famous,stats,time_span_jd) * 24.0]]
   } else {
      set ::bdi_gui_cdl::widget(famous,stats,time_span) [format "%.2f days" $::bdi_gui_cdl::widget(famous,stats,time_span_jd)]
   }

   # Modification des format
   set ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std) $::bdi_gui_cdl::widget(famous,stats,residuals_std)
   set ::bdi_gui_cdl::widget(famous,stats,residuals_mean) [format "%.1f millimag" [ expr $::bdi_gui_cdl::widget(famous,stats,residuals_mean) * 1000.0 ] ]
   set ::bdi_gui_cdl::widget(famous,stats,residuals_std)  [format "%.1f millimag" [ expr $::bdi_gui_cdl::widget(famous,stats,residuals_std)  * 1000.0 ] ]
   set ::bdi_gui_cdl::widget(famous,stats,residuals_ampl) [format "%.1f mag" $::bdi_gui_cdl::widget(famous,stats,residuals_ampl) ]



}

#------------------------------------------------------------
## Permet de voir dans la console l expression de la solution
#  @return void
proc ::bdi_gui_cdl::famous_view_sol  { } {

   array set solu $::bdi_tools_famous::lsolu
   
   ::bdi_gui_famous::view_sol solu
}

#------------------------------------------------------------
## Frame de GUI pour le parametrage de Famous
#  @return void
#
proc ::bdi_gui_cdl::famous_widget_create { frm } {


   TitleFrame $frm.setup -borderwidth 2 -text "Famous : Setup"
   grid $frm.setup -in $frm -sticky news

      frame $frm.setup.param 
      grid $frm.setup.param -in [$frm.setup getframe] -sticky news 
   
         label   $frm.setup.param.lpd -text "Periodic decomposition :"
         spinbox $frm.setup.param.pd -values [list "Simply" "Multi" ] \
                              -textvariable ::bdi_tools_famous::param(periodic_decomposition)
         grid $frm.setup.param.lpd $frm.setup.param.pd -in $frm.setup.param -sticky news 

      frame $frm.setup.action 
      grid $frm.setup.action -in [$frm.setup getframe] -sticky news 

         frame $frm.setup.action.l 
         frame $frm.setup.action.r 
         pack $frm.setup.action.l -in $frm.setup.action -side left -expand yes -fill both -padx 10 -pady 5
         pack $frm.setup.action.r -in $frm.setup.action -side right -expand yes -fill both -padx 10 -pady 5

#         grid $frm.setup.action.l $frm.setup.action.r -in $frm.setup.action -sticky news 

            Button $frm.setup.action.l.crea  -text "Setup" -command "::bdi_gui_famous::crea_setup"
            Button $frm.setup.action.l.edit  -text "Edit"  -command "::bdi_gui_famous::edit_setup"
            grid $frm.setup.action.l.crea   $frm.setup.action.l.edit -in $frm.setup.action.l -sticky news 

            Button $frm.setup.action.r.go   -text "Go" \
                                            -command "::bdi_gui_cdl::famous_widget_go $frm"
            Button $frm.setup.action.r.view -text "Voir Sol"  \
                                            -command "::bdi_gui_cdl::famous_view_sol"
            grid $frm.setup.action.r.go   $frm.setup.action.r.view -in $frm.setup.action.r -sticky news 


}

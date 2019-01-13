## @file bdi_gui_analysis.tcl
#  @brief     GUI d'analyse des donn&eacute;es observationnelles
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_analysis.tcl]
#  @endcode

# Mise à jour $Id: bdi_gui_analysis.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_analysis
# @brief GUI d'analyse des donn&eacute;es observationnelles
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_analysis {

    variable checkedImg
    variable uncheckedImg


}

#----------------------------------------------------------------------------
## Initialisation des variables de namespace
# @details Si la variable n'existe pas alors on va chercher dans la variable globale \c conf
# @return void
proc ::bdi_gui_analysis::inittoconf { } {


    set ::bdi_gui_analysis::checkedImg [image create bitmap tablelist_checkedImg -data "
            #define checked_width 9
            #define checked_height 9
            static unsigned char checked_bits[] = {
               0x00, 0x00, 0x80, 0x00, 0xc0, 0x00, 0xe2, 0x00, 0x76, 0x00, 0x3e, 0x00,
               0x1c, 0x00, 0x08, 0x00, 0x00, 0x00};
            "]
    set ::bdi_gui_analysis::uncheckedImg [image create bitmap tablelist_uncheckedImg -data "
            #define unchecked_width 9
            #define unchecked_height 9
            static unsigned char unchecked_bits[] = {
               0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
               0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
            "]


   # Relatif a Famous
   set ::bdi_gui_analysis::widget(graph,repli,period) ""

   set ::bdi_gui_analysis::idm 3
   set ::bdi_tools_famous::typeofsolu ""
   set ::bdi_gui_analysis::widget(famous,nbpts) 200
   set ::bdi_gui_analysis::widget(famous,stats,nb_dates)       ""
   set ::bdi_gui_analysis::widget(famous,stats,time_span)      ""
   set ::bdi_gui_analysis::widget(famous,stats,time_span_jd)   ""
   set ::bdi_gui_analysis::widget(famous,stats,idm)            ""
   set ::bdi_gui_analysis::widget(famous,stats,residuals_mean) ""
   set ::bdi_gui_analysis::widget(famous,stats,residuals_std)  ""
   set ::bdi_gui_analysis::widget(famous,ephem,nbpts) 1000      
   set ::bdi_gui_analysis::widget(famous,typeofdata,spinbox) [list "Raw data" "Repli obs" "Repli sol" ]

   set ::bdi_gui_analysis::widget(planif,event,nb) ""
   set ::bdi_gui_analysis::widget(planif,scale) 100
   set ::bdi_gui_analysis::widget(planif,period,min) ""
   set ::bdi_gui_analysis::widget(planif,period,max) ""

   ::bdi_gui_analysis::refresh_obs_list

   return
}



#----------------------------------------------------------------------------
## Sauvegarde des variables de namespace
# Destruction de toutes les variables de l appli
# @return void
proc ::bdi_gui_analysis::closetoconf {  } {

   global conf
   # set conf(bddimages,famous,var)  $::bdi_gui_analysis::var

   return

}



#----------------------------------------------------------------------------
## Fermeture de la fenetre Analyse.
# Les variables utilisees sont affectees a la variable globale
# @return void
proc ::bdi_gui_analysis::fermer {  } {

   ::bdi_gui_analysis::closetoconf
   ::bdi_gui_analysis::recup_position

   ::bdi_gui_analysis::graph_close
   destroy $::bdi_gui_analysis::fen

   # Destruction des variables
   array unset ::bdi_gui_analysis::widget
   catch {
      unset ::bdi_gui_analysis::column_selected
      unset ::bdi_gui_analysis::data_obs
   }


   return
}




#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
proc ::bdi_gui_analysis::recup_position { } {

   global conf bddconf

   set bddconf(analysis,geometry) [wm geometry $::bdi_gui_analysis::fen]
   set conf(bddimages,analysis,geometry) $bddconf(analysis,geometry)
   return
}





#------------------------------------------------------------
## Permet de voir dans la console l expression de la solution
#  @return void
proc ::bdi_gui_analysis::view_sol  { } {

   array set solu $::bdi_tools_famous::lsolu
   
   ::bdi_gui_famous::view_sol solu
}





#------------------------------------------------------------
## Charge les donnees recues de l appli reports
#   reset tout ce qui a ete effectue
#  @return void
proc ::bdi_gui_analysis::data_reset { } {

   $::bdi_gui_analysis::data_obs delete 0 end
   set ::bdi_gui_analysis::widget(data,aster,nbpts) 0
   foreach l $::bdi_gui_analysis::infiles {
      lassign $l batch firstdate obj type iau duree fwhm mag prec nbpts expo bin  
      $::bdi_gui_analysis::data_obs insert end [list 1 $firstdate $iau $duree $fwhm $mag $prec $nbpts $expo $bin $batch $obj $type]
      $::bdi_gui_analysis::data_obs rowconfigure end -fg grey
      $::bdi_gui_analysis::data_obs cellconfigure end,available -image $::bdi_gui_analysis::checkedImg
      set ::bdi_gui_analysis::widget(data,aster,nbpts) [expr $::bdi_gui_analysis::widget(data,aster,nbpts) + $nbpts]
   }
   
   # On definit le type d analyse (pour l instant seulement photometrique
   set ::bdi_gui_analysis::widget(data,aster,type) $type
   set ::bdi_gui_analysis::widget(data,type) "photom"
   set ::bdi_gui_analysis::column_selected "mag"
   
   # On construit le nom de l asteroide et identifiant
   lassign [::manage_source::extract_skybot_id_name $obj]  ::bdi_gui_analysis::widget(data,aster,id) ::bdi_gui_analysis::widget(data,aster,name)
   set ::bdi_gui_analysis::widget(data,aster,idname) "($::bdi_gui_analysis::widget(data,aster,id)) $::bdi_gui_analysis::widget(data,aster,name)"

   # On met en place les boutons des graphes par defaut 'tjjo' + 'raw'
   set ::bdi_gui_analysis::widget(famous,graph,abscisse,selected) "tjjo"
   $::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  configure -relief sunken
   $::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   configure -relief raised
   $::bdi_gui_analysis::widget(famous,graph,abscisse,repli) configure -relief raised -state normal

   set ::bdi_gui_analysis::widget(famous,graph,ordonnee,selected) "raw"
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,raw) configure -relief sunken
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,res) configure -relief raised -state disabled
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) configure -relief raised -state disabled
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,int) configure -relief raised -state disabled
   
   # Tri par date croissante
   $::bdi_gui_analysis::data_obs sortbycolumn firstdate  
   return
}




#------------------------------------------------------------
## Charge les donnees recues de l appli reports
#  @return void
proc ::bdi_gui_analysis::data_charge_list { } {

   global  bddconf

   gren_info "Chargement des fichiers :\n"

   # Tri par date croissante
   $::bdi_gui_analysis::data_obs sortbycolumn firstdate  
   # On peut enleve le  oneclic sur une ligne
   bind $::bdi_gui_analysis::data_obs <<ListboxSelect>> [ list ]
   # On empeche le tri des colonnes
   $::bdi_gui_analysis::data_obs configure -labelcommand ""
   # On grise tout
   set idtablelist 0
   foreach l [$::bdi_gui_analysis::data_obs get 0 end] {
      $::bdi_gui_analysis::data_obs rowconfigure $idtablelist -fg grey
      incr idtablelist
   }



   set ::bdi_gui_analysis::widget(data,origin) 9999999
   
   set cpt 0
   set pack 0
   set idtablelist 0

   foreach l [$::bdi_gui_analysis::data_obs get 0 end] {

      lassign $l available firstdate iau duree fwhm mag prec nbpts expo bin batch obj type
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]

      set filename "${obj}.${firstdate}.${batch}.photom.xml"
      set fullname [file join $dir $filename]
      set exist    [file exist $fullname]

      gren_info "Lecture de : $exist $filename  \n"
      ::bdi_tools_cdl::load_report_xml mydata $fullname
      
      incr pack
      set exposure ""
      set filter ""
      for {set i 0} {$i < $mydata(nbrows)} {incr i} {
         
         if {$mydata(table,$i,jddate)<$::bdi_gui_analysis::widget(data,origin)} {
            set ::bdi_gui_analysis::widget(data,origin) $mydata(table,$i,jddate)
         }
         
         lappend exposure $mydata(table,$i,exposure)
         lappend filter   $mydata(table,$i,filter)
      
         set ::bdi_gui_analysis::widget(file,$batch,$i,tjj)  $mydata(table,$i,jddate)
         set ::bdi_gui_analysis::widget(file,$batch,$i,raw)  $mydata(table,$i,mag)
         set ::bdi_gui_analysis::widget(file,$batch,$i,err)  $mydata(table,$i,mag_err)
         set ::bdi_gui_analysis::widget(file,$batch,$i,pack) $pack

         incr cpt

      }
      set ::bdi_gui_analysis::widget(file,$batch,nbpts) $i
      
      $::bdi_gui_analysis::data_obs rowconfigure $idtablelist -fg black
      incr idtablelist
   }

   # On peut trier les colonnes
   $::bdi_gui_analysis::data_obs configure -labelcommand tablelist::sortByColumn
   
   # On peut faire un oneclic sur une ligne
   bind $::bdi_gui_analysis::data_obs <<ListboxSelect>> [ list ::bdi_gui_analysis::cmdButton1Click_data_obs %W ]
   
   # RAZ Temps de lumiere
   $::bdi_gui_analysis::widget(move,button,lighttime) configure -relief raised -state normal
   set ::bdi_gui_analysis::widget(data,tempslumiere) 0

   
   gren_info "Nb de points charges : $cpt\n"
   gren_info "JD origin : $::bdi_gui_analysis::widget(data,origin)\n"


   return
}










#------------------------------------------------------------
## Fonction apres un click dans la table
#  @return void
proc ::bdi_gui_analysis::cmdButton1Click_data_obs { w } {

   set curselection [$::bdi_gui_analysis::data_obs curselection]
   set nb [llength $curselection]
   set ::bdi_gui_analysis::widget(data,batch,selected) ""      
   foreach select $curselection {
      set batch [$::bdi_gui_analysis::data_obs cellcget $select,batch -text]
      lappend ::bdi_gui_analysis::widget(data,batch,selected) $batch
   }
   ::bdi_gui_analysis::graph
}






#------------------------------------------------------------
## Fonction pour le checkbutton du tablelist
#  @return void
proc emptyStr   val { return "" }






#------------------------------------------------------------
## Relance l interface graphique apres avoir recharge les sources tcl
#  @return void
proc ::bdi_gui_analysis::recharge_appli {  } {
   
   ::bddimages::ressource
   ::console::clear
   ::bdi_gui_analysis::fermer
   ::bdi_gui_analysis::run  $::bdi_gui_analysis::infiles
   return
}


#------------------------------------------------------------
## Maj du nb de pts considere
#  @return void
proc ::bdi_gui_analysis::update_nbpts   {  } {

   set i 0
   set ::bdi_gui_analysis::widget(data,aster,nbpts) 0
   foreach s [$::bdi_gui_analysis::data_obs columncget 0 -text] {
      if {$s == 1} {
         set ::bdi_gui_analysis::widget(data,aster,nbpts) [expr $::bdi_gui_analysis::widget(data,aster,nbpts) + [$::bdi_gui_analysis::data_obs cellcget $i,nbpts -text] ]
      }
      incr i
   }
   return
}


#------------------------------------------------------------
## Selectionne des observations dans la liste
#  @return void
proc ::bdi_gui_analysis::data_obs_sel   {  } {

   set l [lsort -decreasing [$::bdi_gui_analysis::data_obs curselection]]
   foreach i $l {
      $::bdi_gui_analysis::data_obs cellconfigure $i,available -image $::bdi_gui_analysis::checkedImg -text 1
   }
   
   # Maj du nb de pts considere
   ::bdi_gui_analysis::update_nbpts
   
   # Maj des graphes
   ::bdi_gui_analysis::data_charge_valeur   

   return
}




#------------------------------------------------------------
## De-selectionne des observations dans la liste
#  @return void
proc ::bdi_gui_analysis::data_obs_unsel {  } {

   set l [lsort -decreasing [$::bdi_gui_analysis::data_obs curselection]]
   foreach i $l {
      $::bdi_gui_analysis::data_obs cellconfigure $i,available -image $::bdi_gui_analysis::uncheckedImg -text 0
   }
   
   # Maj du nb de pts considere
   ::bdi_gui_analysis::update_nbpts

   # Maj des graphes
   ::bdi_gui_analysis::data_charge_valeur   

   return
}



#------------------------------------------------------------
## Appuie du bouton GO dans le Frame de GUI
#  @return void
#
proc ::bdi_gui_analysis::widget_go { frm } {
   $frm.setup.action.r.go configure -relief sunken
   ::bdi_gui_analysis::crea_data_new
   ::bdi_gui_analysis::launch
   $frm.setup.action.r.go configure -relief raised
}


#------------------------------------------------------------
## FAMOUS: Creation du fichier de data pour le lancement de Famous
#  @return void
#
proc ::bdi_gui_analysis::crea_data_new { } {

   global bddconf
   if {$::bdi_gui_analysis::widget(famous,typeofdata)=="Repli obs"} {
      set period [ expr $::bdi_gui_analysis::widget(graph,repli,period) / 24.0]
      # on prend un % de points supplementaires de part et d autre pour avoir un joli repli sur les bords.
      set xperiod [expr $period * 20.0 / 100.0]
   }
   
   set txtfile ""
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      # Depend du type de donnee choisie
      switch $::bdi_gui_analysis::widget(famous,typeofdata) {
         "Raw data" {
            set x $::bdi_gui_analysis::widget(data,$id,tjjo)
            set y $::bdi_gui_analysis::widget(data,$id,raw)
            lappend txtfile [list $x $y]
         }
         
         "Repli obs" {
            set x $::bdi_gui_analysis::widget(data,$id,repli)
            set y $::bdi_gui_analysis::widget(data,$id,raw)
            lappend txtfile [list $x $y]

            if {$::bdi_gui_analysis::widget(data,$id,repli) < $xperiod} {
               set x [expr $::bdi_gui_analysis::widget(data,$id,repli) + $period]
               set y $::bdi_gui_analysis::widget(data,$id,raw)
               lappend txtfile [list $x $y]
            }
            if {$::bdi_gui_analysis::widget(data,$id,repli) > [expr $period-$xperiod]} {
               set x [expr $::bdi_gui_analysis::widget(data,$id,repli) - $period]
               set y $::bdi_gui_analysis::widget(data,$id,raw)
               lappend txtfile [list $x $y]
            }

         }
         
         "Repli sol" {
            set x $::bdi_gui_analysis::widget(data,$id,repli)
            set y $::bdi_gui_analysis::widget(data,$id,sol)
            lappend txtfile [list $x $y]
         }

      }
      if {$x == "" || $y == ""} { gren_erreur "X = ($x) Y = ($y)\n"}
   }

   set txtfile [lsort -index 0 $txtfile]

   set filename [file join $bddconf(dirtmp) "famous.dat"]
   set f [open $filename "w"]
   foreach r $txtfile {
      set x [lindex $r 0]
      set y [lindex $r 1]
      if {$x!="" && $y != ""} {puts $f "$x $y"}
   }
   close $f

   set ::bdi_gui_analysis::widget(famous,stats,nb_dates)       ""
   set ::bdi_gui_analysis::widget(famous,stats,time_span)      ""
   set ::bdi_gui_analysis::widget(famous,stats,idm)            ""
   set ::bdi_gui_analysis::widget(famous,stats,residuals_mean) ""
   set ::bdi_gui_analysis::widget(famous,stats,residuals_std)  ""
   set ::bdi_gui_analysis::widget(famous,typeofsolu)           ""

   # on desactive le bouton voir
   #$::bdi_gui_analysis::widget(famous,button,view) configure -state disabled

}



#------------------------------------------------------------
## Appuie du bouton GO dans le Frame de GUI
#  @return void
#
#   il existe   ::bdi_tools_famous::solu  <- ::bdi_tools_famous::lsolu
proc ::bdi_gui_analysis::launch { } {
   
   
   # Lancement du programme
   ::bdi_tools_famous::famous

   # Lecture des residus
   ::bdi_tools_famous::read_residus xo \
                                    ::bdi_gui_analysis::widget(data,res) \
                                    ysol \
                                    ::bdi_gui_analysis::widget(famous,stats,nb_dates) \
                                    ::bdi_gui_analysis::widget(famous,stats,time_span_jd) \
                                    ::bdi_gui_analysis::widget(famous,stats,residuals_mean) \
                                    ::bdi_gui_analysis::widget(famous,stats,residuals_std) \
                                    ::bdi_gui_analysis::widget(famous,stats,residuals_ampl)
                                 
   set ::bdi_gui_analysis::widget(famous,stats,typeofdata)         $::bdi_gui_analysis::widget(famous,typeofdata)

   if {$::bdi_gui_analysis::widget(famous,stats,time_span_jd) < 1 } {
      set ::bdi_gui_analysis::widget(famous,stats,time_span) [format "%.2f hours" [expr $::bdi_gui_analysis::widget(famous,stats,time_span_jd) * 24.0]]
   } else {
      set ::bdi_gui_analysis::widget(famous,stats,time_span) [format "%.2f days" $::bdi_gui_analysis::widget(famous,stats,time_span_jd)]
   }
 
   # Modification au niveau GUI de la periode obtenue
  # if {$::bdi_tools_famous::result(period) != ""} {
  #    set ::bdi_gui_analysis::widget(graph,repli,period) $::bdi_tools_famous::result(period)
  #    #::bdi_gui_analysis::calc_repli
  # }

   # Modification des format
   switch $::bdi_gui_analysis::column_selected {
      "mag" {
         set ::bdi_gui_analysis::widget(famous,stats,residuals_mean) [format "%.1f millimag" [ expr $::bdi_gui_analysis::widget(famous,stats,residuals_mean) * 1000.0 ] ]
         set ::bdi_gui_analysis::widget(famous,stats,residuals_std)  [format "%.1f millimag" [ expr $::bdi_gui_analysis::widget(famous,stats,residuals_std)  * 1000.0 ] ]
         set ::bdi_gui_analysis::widget(famous,stats,residuals_ampl) [format "%.1f mag"      $::bdi_gui_analysis::widget(famous,stats,residuals_ampl)  ]
      }
      default {
         set ::bdi_gui_analysis::widget(famous,stats,residuals_mean) [format "%.3f" $::bdi_gui_analysis::widget(famous,stats,residuals_mean) ]
         set ::bdi_gui_analysis::widget(famous,stats,residuals_std)  [format "%.3f" $::bdi_gui_analysis::widget(famous,stats,residuals_std)  ]
         set ::bdi_gui_analysis::widget(famous,stats,residuals_ampl) [format "%.3f" $::bdi_gui_analysis::widget(famous,stats,residuals_ampl) ]
      }
   }

   # mise a jour pour les plot
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set tjj  [lindex $r 1]
      set ::bdi_gui_analysis::widget(data,$id,sol) [::bdi_gui_famous::extrapole $tjj]
      set ::bdi_gui_analysis::widget(data,$id,res) [expr $::bdi_gui_analysis::widget(data,$id,raw) - $::bdi_gui_analysis::widget(data,$id,sol)]
   }

   # on libere les boutons 
   #$::bdi_gui_analysis::widget(famous,button,view)        configure -state normal
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,res) configure -relief sunken -state normal
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) configure -relief sunken -state normal


   ::bdi_gui_analysis::graph

}



#------------------------------------------------------------
## Frame de GUI pour le parametrage de Famous
#  @return void
#
proc ::bdi_gui_analysis::famous_widget_create { frm } {

   set ::bdi_gui_analysis::widget(famous,typeofdata,spinbox) [list "Raw data" "Repli obs" "Repli sol" ]

   TitleFrame $frm.setup -borderwidth 2 -text "Famous : Setup"
   grid $frm.setup -in $frm -sticky news

      frame $frm.setup.param 
      grid $frm.setup.param -in [$frm.setup getframe] -sticky news 
   
         label   $frm.setup.param.lpd -text "Periodic decomposition :"
         spinbox $frm.setup.param.pd -values [list "Simply" "Multi" ] \
                              -textvariable ::bdi_tools_famous::param(periodic_decomposition)
         grid $frm.setup.param.lpd $frm.setup.param.pd -in $frm.setup.param -sticky news 

         label   $frm.setup.param.ltod -text "Type of Data :"
         spinbox $frm.setup.param.tod  -values $::bdi_gui_analysis::widget(famous,typeofdata,spinbox) \
                           -textvariable ::bdi_gui_analysis::widget(famous,typeofdata)
         grid $frm.setup.param.ltod $frm.setup.param.tod -in $frm.setup.param -sticky news

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
                                            -command "::bdi_gui_analysis::widget_go $frm"
            Button $frm.setup.action.r.view -text "Voir Sol"  \
                                            -command "::bdi_gui_analysis::view_sol"
            grid $frm.setup.action.r.go   $frm.setup.action.r.view -in $frm.setup.action.r -sticky news 


}

proc ::bdi_gui_analysis::widget_hmm {  } {
   
   $::bdi_gui_analysis::fen.appli.onglets.nb.f_ymov.frm.r.fft configure -relief sunken
   ::bdi_gui_analysis::hmm
   $::bdi_gui_analysis::fen.appli.onglets.nb.f_ymov.frm.r.fft configure -relief raised
   ::bdi_gui_analysis::calc_repli
   ::bdi_gui_analysis::graph_but_abscisse repli
}

#------------------------------------------------------------
## Creation de la fenetre principale 
#  @param  infile  : fichier d'entree representant les donnees
#  @return void
proc ::bdi_gui_analysis::run { infiles } {

   global audace
   global conf bddconf

   set ::bdi_gui_analysis::infiles $infiles
   
   ::bdi_gui_analysis::inittoconf
   
   #--- Geometry
   if { ! [ info exists conf(bddimages,analysis,geometry) ] } { set conf(bddimages,analysis,geometry) "+300+55" }
   set bddconf(analysis,geometry) $conf(bddimages,analysis,geometry)

   set ::bdi_gui_analysis::fen .bdi_analysis
   if { [winfo exists $::bdi_gui_analysis::fen] } {
      wm withdraw $::bdi_gui_analysis::fen
      wm deiconify $::bdi_gui_analysis::fen
      focus $::bdi_gui_analysis::fen
      return
   }

   toplevel $::bdi_gui_analysis::fen -class Toplevel
   wm geometry $::bdi_gui_analysis::fen $bddconf(analysis,geometry)
   wm resizable $::bdi_gui_analysis::fen 1 1
   wm title $::bdi_gui_analysis::fen "Analyse"
   wm protocol $::bdi_gui_analysis::fen WM_DELETE_WINDOW "::bdi_gui_analysis::fermer"

   #--- Cree un frame general
   set frm [frame $::bdi_gui_analysis::fen.appli -borderwidth 1 -cursor arrow -relief groove]
   grid $frm -in $::bdi_gui_analysis::fen -sticky news

      #--- Cree un frame pour afficher bouton fermeture
      set actions [frame $frm.actions  -borderwidth 0 -cursor arrow -relief groove]
      grid $actions  -in $frm 

           button $actions.recharge -text "Recharge" -borderwidth 2 -takefocus 1 -relief "raised" \
                       -command "::bdi_gui_analysis::recharge_appli"
           button $actions.ressource -text "Ressource" -borderwidth 2 -takefocus 1 -relief "raised" \
                       -command "::bddimages::ressource ; ::console::clear"
           grid $actions.recharge $actions.ressource
           
      #---  Cree un frame pour afficher les onglets
      set onglets [frame $frm.onglets -borderwidth 1 -cursor arrow -relief groove]
      # pack obligatoire
     # pack $onglets -in $frm -side top -expand yes -fill both -padx 10 -pady 5
     grid $onglets -in $frm  -sticky news


      grid [ttk::notebook $onglets.nb ]  -row 0 -column 0

         set f_data   [frame $onglets.nb.f_data]
         set f_ymov   [frame $onglets.nb.f_ymov]
         set f_famous [frame $onglets.nb.f_famous]
         set f_graph  [frame $onglets.nb.f_graph]
         set f_ephem  [frame $onglets.nb.f_ephem]
         set f_point  [frame $onglets.nb.f_point]
         set f_planif [frame $onglets.nb.f_planif]
         set f_anoise [frame $onglets.nb.f_anoise]
         set f_pack   [frame $onglets.nb.f_pack]

         $onglets.nb add $f_data   -text "Data"    -underline 0
         $onglets.nb add $f_ymov   -text "Move"    -underline 0
         $onglets.nb add $f_famous -text "Famous"  -underline 0
         $onglets.nb add $f_graph  -text "Graphes" -underline 0
         $onglets.nb add $f_ephem  -text "Ephem"   -underline 0
         $onglets.nb add $f_point  -text "Point"   -underline 0
         $onglets.nb add $f_planif -text "Planif"  -underline 0
#         $onglets.nb add $f_anoise -text "Bruit"   -underline 0
#         $onglets.nb add $f_pack   -text "Pack"    -underline 0

         $onglets.nb select $f_data
#            $onglets.nb select $f_famous
         ttk::notebook::enableTraversal $onglets.nb

      set results [frame $onglets.results  -borderwidth 0 -cursor arrow -relief groove]
      grid $results -row 1 -column 0 -sticky nw

         TitleFrame $results.left  -borderwidth 2 -text "Systeme"

            label $results.left.labast -text "Body : "
            label $results.left.valast -textvariable ::bdi_gui_analysis::widget(data,aster,idname)
            label $results.left.labtyp -text "Type : "
            label $results.left.valtyp -textvariable ::bdi_gui_analysis::widget(data,aster,type)
            label $results.left.labnbp -text "Nbpts : "
            label $results.left.valnbp -textvariable ::bdi_gui_analysis::widget(data,aster,nbpts)
            label $results.left.labper -text "Periode (h) : "
            label $results.left.valper -textvariable ::bdi_gui_analysis::widget(graph,repli,period)
            label $results.left.labori -text "Origin (jd) : "
            label $results.left.valori -textvariable ::bdi_gui_analysis::widget(data,origin)

         TitleFrame $results.right -borderwidth 2 -text "Solu"
            label $results.right.labidm -text "Deg of polynom : "
            label $results.right.validm -textvariable ::bdi_gui_analysis::widget(famous,stats,idm)
            label $results.right.labnbd -text "Nb dates : "
            label $results.right.valnbd -textvariable ::bdi_gui_analysis::widget(famous,stats,nb_dates)
            label $results.right.labtsp -text "Time Span : "
            label $results.right.valtsp -textvariable ::bdi_gui_analysis::widget(famous,stats,time_span)
            label $results.right.labam  -text "Amplitude : "
            label $results.right.valam  -textvariable ::bdi_gui_analysis::widget(famous,stats,residuals_ampl)
            label $results.right.labrm  -text "Residus Mean : "
            label $results.right.valrm  -textvariable ::bdi_gui_analysis::widget(famous,stats,residuals_mean)
            label $results.right.labrs  -text "Residus Stdev : "
            label $results.right.valrs  -textvariable ::bdi_gui_analysis::widget(famous,stats,residuals_std)

         grid $results.left $results.right -in $results -sticky news

            grid $results.left.labast $results.left.valast   -in [$results.left getframe]  -sticky nw 
            grid $results.left.labtyp $results.left.valtyp   -in [$results.left getframe]  -sticky nw 
            grid $results.left.labnbp $results.left.valnbp   -in [$results.left getframe]  -sticky nw 
            grid $results.left.labper $results.left.valper   -in [$results.left getframe]  -sticky nw 
            grid $results.left.labori $results.left.valori   -in [$results.left getframe]  -sticky nw 

            grid $results.right.labidm $results.right.validm -in [$results.right getframe] -sticky ne
            grid $results.right.labnbd $results.right.valnbd -in [$results.right getframe] -sticky ne
            grid $results.right.labtsp $results.right.valtsp -in [$results.right getframe] -sticky ne
            grid $results.right.labam  $results.right.valam  -in [$results.right getframe] -sticky ne
            grid $results.right.labrm  $results.right.valrm  -in [$results.right getframe] -sticky ne
            grid $results.right.labrs  $results.right.valrs  -in [$results.right getframe] -sticky ne


         

   # DATA

         set frmnb [frame $f_data.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_data -sticky news 

         TitleFrame $frmnb.sel -borderwidth 2 -text "Selection des donnees a analyser"
         grid $frmnb.sel -in $frmnb -sticky news 

            set frml [frame $frmnb.sel.frml]
            grid $frml -in [$frmnb.sel getframe] -sticky news 

               # Colonnes
               set cols [list 0 ""       center \
                              0 "Date"   left   \
                              0 "IAU"    left   \
                              0 "Duree"  left   \
                              0 "FWHM"   left   \
                              0 "Mag"    left   \
                              0 "Prec"   left   \
                              0 "Nb Pts" right  \
                              0 "Expo"   left   \
                              0 "Bin"    left   \
                              0 "batch"  left   \
                              0 "obj"    left   \
                              0 "type"   left   \
                              
                     ]

               # Table
               set ::bdi_gui_analysis::data_obs $frml.table
               tablelist::tablelist $::bdi_gui_analysis::data_obs \
                 -columns $cols \
                 -labelcommand "" \
                 -selectmode extended \
                 -activestyle none \
                 -stripebackground "#e0e8f0" \
                 -height 0 -width 0 \
                 -state normal \
                 -showseparators 1

               # Gestion des colonnes
               $::bdi_gui_analysis::data_obs columnconfigure 0 -name available \
                             -editable no -editwindow checkbutton \
                             -formatcommand emptyStr
               $::bdi_gui_analysis::data_obs columnconfigure  1 -name firstdate -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  2 -name iau       -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  3 -name duree     -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  4 -name fwhm      -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  5 -name mag       -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  6 -name prec      -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  7 -name nbpts     -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  8 -name expo      -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure  9 -name bin       -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure 10 -name batch     -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure 11 -name obj       -editable no 
               $::bdi_gui_analysis::data_obs columnconfigure 12 -name type      -editable no 

               foreach ncol [list "batch" "obj" "type"] {
                  set pcol [expr int ([lsearch $cols $ncol]/3)]
                  $::bdi_gui_analysis::data_obs columnconfigure $pcol -hide yes
               }
                                
               # Popup
               set popupTbl $::bdi_gui_analysis::data_obs.popupTbl
               menu $popupTbl -title "Selection"
                  $popupTbl add command -label "Select"   -command "::bdi_gui_analysis::data_obs_sel  "
                  $popupTbl add command -label "Unselect" -command "::bdi_gui_analysis::data_obs_unsel"

               # Binding
               bind $::bdi_gui_analysis::data_obs <<ListboxSelect>> [ list  ]
               bind [$::bdi_gui_analysis::data_obs bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]

               #grid $::bdi_gui_analysis::data_obs -in $frml -sticky news 
               pack $::bdi_gui_analysis::data_obs -in $frml -expand yes -fill both

            set frmb [frame $frmnb.sel.frmb]
            grid $frmb -in [$frmnb.sel getframe] -sticky news 

               Button $frmb.reset   -text "Reset"         -command "::bdi_gui_analysis::data_reset"
               Button $frmb.chargel -text "Charge List"   -command "::bdi_gui_analysis::data_charge_list"
               Button $frmb.chargev -text "Charge Valeur" -command "::bdi_gui_analysis::data_charge_valeur"
               Button $frmb.charget -text "Charge Tout"   -command "::bdi_gui_analysis::data_charge_tout"
               grid $frmb.reset $frmb.chargel $frmb.chargev $frmb.charget -in $frmb -sticky news 
             
         TitleFrame $frmnb.simu -borderwidth 2 -text "Export"
         grid $frmnb.simu -in $frmnb -sticky news

            Button $frmnb.simu.cos     -text "Yassine"    -width 8 -command "::bdi_gui_analysis::export_1"
            grid $frmnb.simu.cos -in [$frmnb.simu getframe] -sticky news

   # Ymove

         set frmnb [frame $f_ymov.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_ymov -sticky news

         TitleFrame $frmnb.p -borderwidth 2 -text "Deplacement sur l'axe Y"
         grid $frmnb.p -in $frmnb -sticky news
            
            Button $frmnb.p.mean  -text "Se caler sur la moyenne generale"  -command "::bdi_gui_analysis::ymov_allmean"
            Button $frmnb.p.solu   -text "Se caler sur la solution"  -command "::bdi_gui_analysis::ymov_solution"
            Button $frmnb.p.manu  -text "Calage manuel"  -command "::bdi_gui_analysis::ymov_manual"

            grid $frmnb.p.mean -in [$frmnb.p getframe] -sticky nwes -row 0 -column 0
            grid $frmnb.p.solu -in [$frmnb.p getframe] -sticky nwes  -row 0 -column 1
            grid $frmnb.p.manu -in [$frmnb.p getframe] -sticky nwes  -row 1 -column 0

         TitleFrame $frmnb.q -borderwidth 2 -text "Correction Temporelle"
         grid $frmnb.q -in $frmnb -sticky news

            set ::bdi_gui_analysis::widget(move,button,lighttime) [Button $frmnb.q.tl \
                              -text "Corriger du temps de lumiere" \
                              -command "::bdi_gui_analysis::light_time" ]
            grid $frmnb.q.tl -in [$frmnb.q getframe] -sticky nwes 

         TitleFrame $frmnb.r -borderwidth 2 -text "Correction Temporelle"
         grid $frmnb.r -in $frmnb -sticky news
            
            entry  $frmnb.r.per  -textvariable ::bdi_gui_analysis::widget(graph,repli,period) -width 30 -justify center
            Button $frmnb.r.but  -text "Periode de rotation"  -command "::bdi_gui_analysis::calc_repli"
            Button $frmnb.r.fft  -text "hmm"  \
                     -command "::bdi_gui_analysis::widget_hmm"
            grid $frmnb.r.but $frmnb.r.per $frmnb.r.fft -in [$frmnb.r getframe] -sticky nwes 

   # FAMOUS

         set frmnb [frame $f_famous.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_famous -sticky news

         ::bdi_gui_analysis::famous_widget_create $frmnb


         TitleFrame $frmnb.p -borderwidth 2 -text "Deplacement sur l'axe Y"
         grid $frmnb.p -in $frmnb -sticky news
            
            Button $frmnb.p.solu   -text "Se caler sur la solution"  -command "::bdi_gui_analysis::ymov_solution"
            grid $frmnb.p.solu -in [$frmnb.p getframe] -sticky news 

         TitleFrame $frmnb.res -borderwidth 2 -text "Type of Solution"
         grid $frmnb.res -in $frmnb -sticky news

            label $frmnb.res.tosres -textvariable ::bdi_tools_famous::typeofsolu
            grid $frmnb.res.tosres -in [$frmnb.res getframe] -sticky news -row 1 -column 2 

   # Graph

         set frmnb [frame $f_graph.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_graph -sticky news

         TitleFrame $frmnb.abs -borderwidth 2 -text "Abscisses"
         grid $frmnb.abs -in $frmnb -sticky news
            
            Button $frmnb.abs.tjjo  -text "Jour julien"  -width 8 -command "::bdi_gui_analysis::graph_but_abscisse tjjo"
            Button $frmnb.abs.idx   -text "Index"  -width 4 -command "::bdi_gui_analysis::graph_but_abscisse idx" -state disabled
            Button $frmnb.abs.repli -text "Repli"  -width 4 -command "::bdi_gui_analysis::graph_but_abscisse repli"
            Button $frmnb.abs.pack -text "Paquet"  -width 4 -command "::bdi_gui_analysis::graph_but_abscisse pack" -state disabled
            grid $frmnb.abs.tjjo $frmnb.abs.idx $frmnb.abs.repli $frmnb.abs.pack -in [$frmnb.abs getframe] -sticky nes 
            
            set ::bdi_gui_analysis::widget(famous,graph,abscisse,tjjo)  $frmnb.abs.tjjo 
            set ::bdi_gui_analysis::widget(famous,graph,abscisse,idx)   $frmnb.abs.idx 
            set ::bdi_gui_analysis::widget(famous,graph,abscisse,repli) $frmnb.abs.repli 
            set ::bdi_gui_analysis::widget(famous,graph,abscisse,pack)  $frmnb.abs.pack 

         TitleFrame $frmnb.ord -borderwidth 2 -text "Ordonnees"
         grid $frmnb.ord -in $frmnb -sticky news
            
            Button $frmnb.ord.raw   -text "Donnees Brutes"  -width 10 \
                                    -command "::bdi_gui_analysis::graph_but_ordonnee raw"
            Button $frmnb.ord.res   -text "Residus"  -width 7 \
                                    -command "::bdi_gui_analysis::graph_but_ordonnee res"
            Button $frmnb.ord.sol   -text "Solution"  -width 7 \
                                    -command "::bdi_gui_analysis::graph_but_ordonnee sol"
            Button $frmnb.ord.int   -text "Interpol"  -width 7 \
                                    -command "::bdi_gui_analysis::graph_but_ordonnee int"
            grid $frmnb.ord.raw $frmnb.ord.res $frmnb.ord.sol $frmnb.ord.int -in [$frmnb.ord getframe] -sticky nes 
            
            set ::bdi_gui_analysis::widget(famous,graph,ordonnee,raw) $frmnb.ord.raw
            set ::bdi_gui_analysis::widget(famous,graph,ordonnee,res) $frmnb.ord.res 
            set ::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) $frmnb.ord.sol 
            set ::bdi_gui_analysis::widget(famous,graph,ordonnee,int) $frmnb.ord.int 

   # Ephem

         set frmnb [frame $f_ephem.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_ephem -sticky news

         TitleFrame $frmnb.onedate -borderwidth 2 -text "Donne une date ISO"
         grid $frmnb.onedate -in $frmnb -sticky news

            entry  $frmnb.onedate.dat  -textvariable ::bdi_gui_analysis::widget(famous,ephem,isodate) -width 30 -justify center
            Button $frmnb.onedate.cal  -text "Calcul"  -width 4 -command "::bdi_gui_analysis::ephem_calcul_one_date"
            label  $frmnb.onedate.tod  -textvariable ::bdi_gui_analysis::widget(famous,ephem,typeofdata)
            entry  $frmnb.onedate.sol  -textvariable ::bdi_gui_analysis::widget(famous,ephem,sol) -width 10 -justify center

            grid $frmnb.onedate.dat $frmnb.onedate.cal $frmnb.onedate.tod $frmnb.onedate.sol -in [$frmnb.onedate getframe] -sticky news

         TitleFrame $frmnb.synth -borderwidth 2 -text "Calcule une courbe synthetique"
         grid $frmnb.synth -in $frmnb -sticky news

            label  $frmnb.synth.ld1  -text "Date de debut :"
            entry  $frmnb.synth.ed1  -textvariable ::bdi_gui_analysis::widget(famous,ephem,isodate,first) -width 30 -justify center
            label  $frmnb.synth.ld2  -text "Date de fin :"
            entry  $frmnb.synth.ed2  -textvariable ::bdi_gui_analysis::widget(famous,ephem,isodate,end) -width 30 -justify center
            label  $frmnb.synth.lnb  -text "Nb de points :"
            entry  $frmnb.synth.enb  -textvariable ::bdi_gui_analysis::widget(famous,ephem,nbpts) -width 30 -justify center
            Button $frmnb.synth.cal  -text "Calcul"  -width 4 -command "::bdi_gui_analysis::ephem_calcul_courbe"
            label  $frmnb.synth.tod  -textvariable ::bdi_gui_analysis::widget(famous,ephem,typeofdata)

            grid $frmnb.synth.ld1 $frmnb.synth.ed1 -in [$frmnb.synth getframe] -sticky news
            grid $frmnb.synth.ld2 $frmnb.synth.ed2 -in [$frmnb.synth getframe] -sticky news
            grid $frmnb.synth.lnb $frmnb.synth.enb -in [$frmnb.synth getframe] -sticky news
            grid $frmnb.synth.cal $frmnb.synth.tod -in [$frmnb.synth getframe] -sticky news

   # Point

         set frmnb [frame $f_point.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_point -sticky news

         TitleFrame $frmnb.onedate -borderwidth 2 -text "Donne une date ISO"
         grid $frmnb.onedate -in $frmnb -sticky news

            entry  $frmnb.onedate.dat  -textvariable ::bdi_gui_analysis::widget(famous,point,isodate) -width 30 -justify center
            label  $frmnb.onedate.tod  -textvariable ::bdi_gui_analysis::widget(famous,ephem,typeofdata)
            entry  $frmnb.onedate.sol  -textvariable ::bdi_gui_analysis::widget(famous,point,sol) -width 10 -justify center
            Button $frmnb.onedate.tra  -text "Trace"  -width 4 -command "::bdi_gui_analysis::point_trace_one_date"

            grid $frmnb.onedate.dat $frmnb.onedate.tod $frmnb.onedate.sol $frmnb.onedate.tra -in [$frmnb.onedate getframe] -sticky news

   # Planification des observations en fonction du choix sur la periode

         set frmnb [frame $f_planif.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         grid $frmnb -in $f_planif -sticky news

         TitleFrame $frmnb.sele -borderwidth 2 -text "Select Observatoire & Periode"
         grid $frmnb.sele -in $frmnb -sticky news

            set frml [frame $frmnb.sele.frmline1]
            grid $frml -in [$frmnb.sele getframe] -sticky news
               
               label   $frml.lab1  -text "Observatoire :"
               spinbox $frml.obs   -values $::bdi_gui_analysis::widget(planif,observatory,spinbox) \
                                         -textvariable ::bdi_gui_analysis::widget(planif,observatory,select)
               set ::bdi_gui_analysis::widget(planif,observatory,frm) $frml.obs

               Button  $frml.refr  -text "Refresh" -command "::bdi_gui_analysis::refresh_obs_list"

               grid $frml.lab1 $frml.obs $frml.refr -in $frml -sticky news

            set frml [frame $frmnb.sele.frmline2]
            grid $frml -in [$frmnb.sele getframe] -sticky news

               label   $frml.lab1  -text "Periode :"
               Button  $frml.grab  -text "Grab" -command "::bdi_gui_analysis::planif_grab_period"
               label   $frml.lab2  -text "pmin:"
               label   $frml.dbeg  -textvariable ::bdi_gui_analysis::widget(planif,period,min)
               label   $frml.lab3  -text "pmax:"
               label   $frml.dend  -textvariable ::bdi_gui_analysis::widget(planif,period,max)
               label   $frml.lab4  -text "duree:"
               label   $frml.duree -textvariable ::bdi_gui_analysis::widget(planif,period,duree)

               grid $frml.lab1 $frml.grab $frml.lab2 $frml.dbeg $frml.lab3 $frml.dend $frml.lab4 $frml.duree -in $frml -sticky news


         TitleFrame $frmnb.calc -borderwidth 2 -text "Results"
         grid $frmnb.calc -in $frmnb -sticky news

            set frml [frame $frmnb.calc.frmline1]
            grid $frml -in [$frmnb.calc getframe] -sticky news

               set ::bdi_gui_analysis::widget(planif,button,calcul) [Button  $frml.calc  -text "Calcul" \
                        -command "$frml.calc configure -relief sunken
                                  ::bdi_gui_analysis::planif_calcul
                                  $frml.calc configure -relief raised
                                  "]
               
               label   $frml.lab1  -text "Nb event :" 
               label   $frml.nbe   -textvariable ::bdi_gui_analysis::widget(planif,event,nb)
               scale   $frml.scale -from 0 -to 100  -variable ::bdi_gui_analysis::widget(planif,scale) \
                                   -orient horizontal -tick 25 -length 200 \
                                   -command "::bdi_gui_analysis::planif_view_results_work"
               Button  $frml.res   -text "View Result" -command "::bdi_gui_analysis::planif_view_results"
               Button  $frml.nig   -text "Nights" -command "::bdi_gui_analysis::planif_view_nights"

               grid $frml.calc           -in $frml -sticky nw
               grid $frml.lab1 $frml.nbe -in $frml -sticky new
               grid $frml.scale          -in $frml -sticky ne
               grid $frml.res $frml.nig  -in $frml -sticky nw


   return
}








## @file bdi_gui_reports.tcl 
#  @brief     GUI dedi&eacute;e &agrave; la gestion des rapports d'analyse
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports.tcl]
#  @endcode

# $Id: bdi_gui_reports.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_reports
# @brief GUI dedi&eacute;e &agrave; la gestion des rapports d'analyse
# @pre Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_reports {

}


#------------------------------------------------------------
## Creation de la GUI de gestion des configurations
#  @return void
#
proc ::bdi_gui_reports::inittoconf {  } {


}

#------------------------------------------------------------
## Fermeture et destruction de la GUI
#  @return void
#
proc ::bdi_gui_reports::fermer { } {

   #::bdi_gui_reports::closetoconf
   ::bdi_gui_reports::recup_position
   destroy $::bdi_gui_reports::fen

}

#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_reports::recup_position { } {

   global conf bddconf

   set bddconf(geometry_reports) [ wm geometry $::bdi_gui_reports::fen ]
   set conf(bddimages,geometry_reports) $bddconf(geometry_reports)

}

#----------------------------------------------------------------------------
## Relance l outil
# Les variables utilisees sont affectees a la variable globale
# \c conf
proc ::bdi_gui_reports::relance {  } {

   ::console::clear
   ::bddimages::ressource
   ::bdi_gui_reports::fermer
   ::bdi_gui_reports::run

}





#------------------------------------------------------------
## Lancement de la GUI
#  @return void
#
proc ::bdi_gui_reports::run { } {

   global audace caption color
   global conf bddconf

   set widthlab 30
   set widthentry 30
   set ::bdi_gui_reports::fen .reports

   #--- Initialisation des parametres
   ::bdi_gui_reports::inittoconf
   set ::bdi_tools_reports::viewmode normal

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_reports) ] } {
      set conf(bddimages,geometry_reports) "+400+800"
   }
   set bddconf(geometry_reports) $conf(bddimages,geometry_reports)

   #--- Declare la GUI
   if { [ winfo exists $::bdi_gui_reports::fen ] } {
      wm withdraw $::bdi_gui_reports::fen
      wm deiconify $::bdi_gui_reports::fen
      focus $::bdi_gui_reports::fen.buttons.but_fermer
      return
   }

   #--- GUI
   toplevel $::bdi_gui_reports::fen -class Toplevel
   wm geometry $::bdi_gui_reports::fen $bddconf(geometry_reports)
   wm resizable $::bdi_gui_reports::fen 1 1
   wm title $::bdi_gui_reports::fen $caption(bddimages_go,reports)
   wm protocol $::bdi_gui_reports::fen WM_DELETE_WINDOW { ::bdi_gui_reports::fermer }

   set frm $::bdi_gui_reports::fen.appli
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_reports::fen -side top -expand yes -fill both 

      # Develop
      set actions [frame $frm.actions]
      pack $actions -in $frm -side top 
      #grid $actions -in $frm 

         button $actions.ressource -text "Ressource les scripts"  \
            -command "::console::clear ; ::bddimages::ressource"
         button $actions.relance -text "Relance la GUI"\
            -command "::bdi_gui_reports::relance"
         button $actions.clean -text "Efface le contenu de la console" \
            -command "console::clear"
         button $actions.quit -text "Fermer" \
            -command "::bdi_gui_reports::fermer"

         grid $actions.ressource $actions.relance $actions.clean $actions.quit -sticky news


      set onglets [frame $frm.onglets -borderwidth 1]
      pack $onglets -in $frm -anchor n  -side top -expand yes -fill both -padx 10 -pady 10
      #grid $onglets -in $frm -sticky news

         pack [ttk::notebook $onglets.nb ]  -side top -expand yes -fill both 
         #grid [ttk::notebook $onglets.nb ]  -row 0 -column 0

         set f_asph   [frame $onglets.nb.f_asph]
         set f_nwas   [frame $onglets.nb.f_nwas]

         $onglets.nb add $f_asph   -text "Astrom/Photom" -underline 0
         $onglets.nb add $f_nwas   -text "New Aster"     -underline 0

         $onglets.nb select $f_nwas
         ttk::notebook::enableTraversal $onglets.nb


         set frmnb [frame $f_asph.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_asph -side top -expand yes -fill both -padx 10 -pady 10
         #grid $frmnb -in $f_asph -sticky news 

            ::bdi_gui_reports::build_gui_astrophotom $frmnb

         set frmnb [frame $f_nwas.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_nwas -side top -expand yes -fill both -padx 10 -pady 10

            ::bdi_gui_reports::build_gui_newaster $frmnb



   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_reports::fen

}





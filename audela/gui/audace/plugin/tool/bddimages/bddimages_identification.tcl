## @file bddimages_identification.tcl
#  @brief     Anciennes fonctions d'identification
#  @deprecated
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_identification.tcl]
#  @endcode

# $Id: bddimages_identification.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @namespace bddimages_identification
# @brief Anciennes fonctions d'identification
# @warning Outil en d&eacute;veloppement
# @deprecated
#
namespace eval ::bddimages_identification {

   global audace
   global bddconf

}


proc ::bddimages_identification::run { this } {
   variable This

   set entetelog "identification"
   set This $this
   createDialog
   return
}

proc ::bddimages_identification::fermer { } {

   variable This
   global audace
   destroy $This
   $audace(hCanvas) delete marks
   return

}


proc ::bddimages_identification::createDialog { } {

   variable This
   global audace
   global caption
   global color
   global conf
   global bddconf

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   #---
   toplevel $This -class Toplevel
#   wm geometry $This $bddconf(position_status)
   wm resizable $This 1 1
#   wm title $This $caption(bddimages_identification,main_title)
   wm protocol $This WM_DELETE_WINDOW { ::bddimages_identification::fermer }

   #--- Cree un menu pour le panneau
   frame $This.frame0 -borderwidth 1 -relief raised
   pack $This.frame0 -side top -fill x

   #--- Cree un frame pour afficher le status de la base
   frame $This.frame1 -borderwidth 0 -cursor arrow
   pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x

     #--- Cree un label pour le titre
     label $This.frame1.titre -text "Hello"
     pack $This.frame1.titre -in $This.frame1 -side top -padx 3 -pady 3

     #--- Cree un label pour le titre
     text $This.frame1.txt
     pack $This.frame1.txt -in $This.frame1 -side top -padx 3 -pady 3

     #--- Cree un label pour le titre
     button $This.frame1.update -text "UPDATE" -command { ::bddimages_identification::update }
     pack $This.frame1.update -in $This.frame1 -side top -padx 3 -pady 3

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}


proc ::bddimages_identification::update { } {

   variable This
   global audace
   global caption
   global color
   global conf
   global bddconf

   $audace(hCanvas) delete marks

   set txt [$This.frame1.txt get 0.1 end]
   foreach line [split $txt "\n"] {
      if { [regexp {(\d+\.\d+)\s+(\d+\.\d+)} $line all ra decl] } {
         puts "$ra ; $decl"
         set img_xy [ buf$audace(bufNo) radec2xy [ list $ra $decl ] ]
         set can_xy [ ::audace::picture2Canvas $img_xy ]
         set x [lindex $can_xy 0]
         set y [lindex $can_xy 1]
         $audace(hCanvas) create oval [expr $x - 3.0] [expr $y - 3.0] [expr $x + 3.0] [expr $y + 3.0] -tags marks -outline green
      }
   }

            #--- Coordonnees images de l'objet
#            set img_xy [ buf$audace(bufNo) radec2xy [ list [expr (7 + 16.0/60.0) * 15.0 ] [expr 9 + 10.0/60.0] ] ]
            #--- Transformation des coordonnees image en coordonnees canvas
#            set can_xy [ ::audace::picture2Canvas $img_xy ]
#     set x [lindex $can_xy 0]
#     set y [lindex $can_xy 1]

#            $audace(hCanvas) create text $x [expr $y - 20. ] -text "LABEL" -justify center -tags marks -fill green
#            $audace(hCanvas) create text 10 10 -text "LABEL" -justify center -tags marks -fill red

}


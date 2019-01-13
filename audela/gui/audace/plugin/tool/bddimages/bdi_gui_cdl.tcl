## @file bdi_gui_cdl.tcl
#  @brief     GUI de cr&eacute;ation des courbes de lumi&egrave;re
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cdl.tcl]
#  @endcode

# $Id: bdi_gui_cdl.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_cdl
# @brief GUI de cr&eacute;ation des courbes de lumi&egrave;re
# @pre Requiert \c bdi_tools_cdl .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cdl {

   # Variable definissant la racine de la fenetre de l'outil
   variable fen
   # Table des donnees des etoiles de reference
   variable data_reference
   # Variable contenant la liste des sources selectionnees
   variable selectedTableList
   # Index des figures
   variable figConst     1
   variable figStars     2
   variable figTimeline  3
   variable figScimag    4
   variable figscifamous 5
   # Figure courante
   variable currentFig 0

}


#----------------------------------------------------------------------------
## Initialisation des variables de namespace
#  \details   Si la variable n'existe pas alors on va chercher
#             dans la variable globale \c conf
proc ::bdi_gui_cdl::inittoconf {  } {

   ::bdi_tools_cdl::inittoconf
   ::bdi_gui_cdl::free_memory
}

#----------------------------------------------------------------------------
## Fermeture de la fenetre .
# Les variables utilisees sont affectees a la variable globale
# \c conf
proc ::bdi_gui_cdl::fermer {  } {

   # fermeture des graphes
   if {[::plotxy::exists $::bdi_gui_cdl::figConst] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figConst
   }
   if {[::plotxy::exists $::bdi_gui_cdl::figStars] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figStars
   }
   if {[::plotxy::exists $::bdi_gui_cdl::figTimeline] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figTimeline
   }
   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figScimag
   }
   if {[::plotxy::exists $::bdi_gui_cdl::figscifamous] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figscifamous
   }
   if {[::plotxy::exists $::bdi_gui_cdl::currentFig] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::currentFig
   }
   
   # fermeture de la table de donnees
   if {[info exists ::bdi_gui_cdl::fentable]} {
      destroy $::bdi_gui_cdl::fentable   
   }
   
   # fermeture de la gui gestion
   ::bdi_gui_gestion_source::fermer
   ::bdi_gui_cata_gestion::fermer "yes"
   array unset ::bdi_gui_cdl::widget

   # Cloture de la session
   ::bdi_tools_cdl::closetoconf
   ::bdi_gui_cdl::recup_position
   destroy $::bdi_gui_cdl::fen
   unset ::bdi_gui_cdl::fen
   
}

#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_cdl::recup_position { } {

   global conf bddconf

   set bddconf(geometry_bdi_gui_cdl) [wm geometry $::bdi_gui_cdl::fen]
   set conf(bddimages,geometry_bdi_gui_cdl) $bddconf(geometry_bdi_gui_cdl)

}

#----------------------------------------------------------------------------
## Relance l outil
# Les variables utilisees sont affectees a la variable globale
# \c conf
proc ::bdi_gui_cdl::relance {  } {

   ::bddimages::ressource
   ::bdi_gui_cdl::fermer
   ::bdi_gui_cdl::run
   foreach img $::tools_cata::img_list {
      gren_info "IMG = [llength $img]\n"
      break
   }
   ::bdi_tools_cdl::get_memory

}



# On click
proc ::bdi_gui_cdl::cmdButton1Click_data_reference { w args } {

}

proc ::bdi_gui_cdl::cmdButton1Click_data_science { w args } {

}

proc ::bdi_gui_cdl::cmdButton1Click_data_rejected { w args } {

}

proc ::bdi_gui_cdl::cmdButton1Click_starstar { w args } {

}

proc ::bdi_gui_cdl::cmdButton1Click_classif { w args } {

}

proc ::bdi_gui_cdl::cmdButton1Click_timeline { w args } {

}


#----------------------------------------------------------------------------
## Demarrage de l'outil
proc ::bdi_gui_cdl::run { } {

   ::bdi_gui_cdl::inittoconf

   set ::bdi_tools_cdl::memory(memview) 0
   ::bdi_tools_cdl::get_memory

   ::bdi_gui_cdl::create_dialog

}

#===========================================================================
proc ::bdi_gui_cdl::clean_gui_photometry { } {

   $::bdi_gui_cdl::data_reference delete 0 end
   $::bdi_gui_cdl::data_science   delete 0 end
   $::bdi_gui_cdl::data_rejected  delete 0 end
   $::bdi_gui_cdl::classif        delete 0 end
   $::bdi_gui_cdl::ss_mag_stdev   delete 0 end

   catch { $::bdi_gui_cdl::ss_mag_stdev deletecolumns 0 end }

}


#----------------------------------------------------------------------------
## Retire de la liste des sources selectionnees une source definie par son nom
#
proc ::bdi_gui_cdl::lremove {listVariable value} {

   upvar 1 $listVariable var
   set i 0
   foreach l $var {
      if {[lindex $l 1] == $value} {
         set var [lreplace $var $i $i]
      }
      incr i
   }

}

#----------------------------------------------------------------------------
## Retire de la liste des sources selectionnees une source definie par son nom
#
proc ::bdi_gui_cdl::free_memory { } {

#   set a $::bdi_gui_cdl::widget(objsel,menu)

#   array unset ::bdi_gui_cdl::widget
   
#   set ::bdi_gui_cdl::widget(objsel,menu) $a

   ::bdi_tools_cdl::free_memory

}

#===========================================================================
proc ::bdi_gui_cdl::charge_from_gestion { } {

   set tt0 [clock clicks -milliseconds]
   ::bdi_gui_cdl::free_memory
   ::bdi_gui_cdl::clean_gui_photometry
   ::bdi_gui_cdl::affich_gestion
   ::bdi_tools_cdl::charge_from_gestion

   ::bdi_gui_cdl::calcule_tout
   set tt [format "%.0f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   
   tk_messageBox -message "Chargement des donnees en $tt sec" -type ok
}

#----------------------------------------------------------------------------
## Affichage de l outil de gestion des cata
proc ::bdi_gui_cdl::affich_gestion { } {

   if {![info exists ::bdi_gui_cata_gestion::fen]} {
      ::bdi_gui_cata_gestion::go $::tools_cata::img_list
   } else {
      if {[winfo exists $::bdi_gui_cata_gestion::fen] == 0} {
         ::bdi_gui_cata_gestion::go $::tools_cata::img_list
      }
   }
   return
}


#----------------------------------------------------------------------------
## Creation de la boite de dialogue.
proc ::bdi_gui_cdl::create_dialog { } {

   global audace
   global conf bddconf


   set ::bdi_gui_cdl::widget(objsel,combo,list)  ""
   set ::bdi_gui_cdl::widget(objsel,combo,value) ""



   if { ! [info exists conf(bddimages,geometry_bdi_gui_cdl)] } { set conf(bddimages,geometry_bdi_gui_cdl) "+165+55" }
   set bddconf(geometry_bdi_gui_cdl) $conf(bddimages,geometry_bdi_gui_cdl)

   set ::bdi_gui_cdl::fen .photometry
   if { [winfo exists $::bdi_gui_cdl::fen] } {
      wm withdraw $::bdi_gui_cdl::fen
      wm deiconify $::bdi_gui_cdl::fen
      focus $::bdi_gui_cdl::fen
      return
   }
   toplevel $::bdi_gui_cdl::fen -class Toplevel
   wm geometry $::bdi_gui_cdl::fen $bddconf(geometry_bdi_gui_cdl)
   wm resizable $::bdi_gui_cdl::fen 1 1
   wm title $::bdi_gui_cdl::fen "Photometrie V3"
   wm protocol $::bdi_gui_cdl::fen WM_DELETE_WINDOW "::bdi_gui_cdl::fermer"

   set frm $::bdi_gui_cdl::fen.appli
   #--- Cree un frame general
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cdl::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      set onglets [frame $frm.onglets]
      pack $onglets -in $frm  -expand yes -fill both

         pack [ttk::notebook $onglets.nb] -expand yes -fill both
         set f_data_reference [frame $onglets.nb.f_data_reference]
         set f_data_science   [frame $onglets.nb.f_data_science]
         set f_data_rejected  [frame $onglets.nb.f_data_rejected]
         set f_starstar       [frame $onglets.nb.f_starstar]
         set f_classif        [frame $onglets.nb.f_classif]
         set f_vign           [frame $onglets.nb.f_vign]
         set f_famous         [frame $onglets.nb.f_famous]
         set f_results        [frame $onglets.nb.f_results]
         set f_bigdata        [frame $onglets.nb.f_bigdata]
         set f_develop        [frame $onglets.nb.f_develop]

         $onglets.nb add $f_data_reference -text "References"
         $onglets.nb add $f_data_science   -text "Sciences"
         $onglets.nb add $f_data_rejected  -text "Rejetees"
         $onglets.nb add $f_starstar       -text "Variations"
         $onglets.nb add $f_classif        -text "Classification"
         $onglets.nb add $f_vign           -text "Vignettes"
         $onglets.nb add $f_famous         -text "Famous"
         $onglets.nb add $f_results        -text "Rapport"
         $onglets.nb add $f_bigdata        -text "Big Data"
         $onglets.nb add $f_develop        -text "Develop"

         #$onglets.nb select $f_data_reference
         ttk::notebook::enableTraversal $onglets.nb
         $onglets.nb select $f_data_reference

      # References
      set results [frame $f_data_reference.data_reference  -borderwidth 1 -relief groove]
      pack $results -in $f_data_reference -expand yes -fill both

         set cols [list 0 "Id"         left  \
                        0 "Name"       left  \
                        0 "Nb img"     right \
                        0 "Nb mes"     right \
                        0 "Moy Mag"    right \
                        0 "StDev Mag"  right \
                        0 "Nb Err PSF" right \
                        0 "Radius min" right \
                        0 "Flux min"   right \
                  ]
         # Table
         set ::bdi_gui_cdl::data_reference $results.table
         tablelist::tablelist $::bdi_gui_cdl::data_reference \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $results.hsb set ] \
           -yscrollcommand [ list $results.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_reference xview]
         pack $results.hsb -in $results -side bottom -fill x
         scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_reference yview]
         pack $results.vsb -in $results -side right -fill y

         # Pack la Table
         pack $::bdi_gui_cdl::data_reference -in $results -expand yes -fill both

         # Popup
         menu $results.popupTbl -title "Actions"

            $results.popupTbl add command -label "(v)oir l'objet dans une image" \
                -command "::bdi_gui_cata::voirobj_photom_ref"
            $results.popupTbl add command -label "(d)efinir comme Science" \
                -command "::bdi_gui_cdl::set_to_science_data_reference"
            $results.popupTbl add command -label "(r)ejeter les sources selectionnees" \
                -command "::bdi_gui_cdl::unset_data_reference"
            $results.popupTbl add command -label "(t)able des sources selectionnees" \
                -command "::bdi_gui_cdl::table_popup ref"

         # Binding
         bind $::bdi_gui_cdl::data_reference <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_reference %W ]
         bind [$::bdi_gui_cdl::data_reference bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]
         bind [$::bdi_gui_cdl::data_reference bodypath] <Key-v> "::bdi_gui_cata::voirobj_photom_ref"
         bind [$::bdi_gui_cdl::data_reference bodypath] <Key-d> "::bdi_gui_cdl::set_to_science_data_reference"
         bind [$::bdi_gui_cdl::data_reference bodypath] <Key-r> "::bdi_gui_cdl::unset_data_reference"
         bind [$::bdi_gui_cdl::data_reference bodypath] <Key-t> "::bdi_gui_cdl::table_popup ref"

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Name"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_reference columnconfigure $pcol -sortmode ascii
         }
         #    Reel
         foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag" "Flux min"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_reference columnconfigure $pcol -sortmode real
         }
         #    Reel
         foreach ncol [list "Radius min" "Nb Err PSF"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_reference columnconfigure $pcol -sortmode integer
         }




      # Sciences
      set results [frame $f_data_science.data_science  -borderwidth 1 -relief groove]
      pack $results -in $f_data_science -expand yes -fill both

         set cols [list 0 "Id"         left  \
                        0 "Name"       left  \
                        0 "Nb img"     right \
                        0 "Nb mes"     right \
                        0 "Moy Mag"    right \
                        0 "StDev Mag"  right \
                        0 "Nb Err PSF" right \
                        0 "Radius min" right \
                        0 "Flux min"   right \
                  ]
         # Table
         set ::bdi_gui_cdl::data_science $results.table
         tablelist::tablelist $::bdi_gui_cdl::data_science \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $results.hsb set ] \
           -yscrollcommand [ list $results.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_science xview]
         pack $results.hsb -in $results -side bottom -fill x
         scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_science yview]
         pack $results.vsb -in $results -side right -fill y

         # Pack la Table
         pack $::bdi_gui_cdl::data_science -in $results -expand yes -fill both

         # Popup
         menu $results.popupTbl -title "Actions"

            $results.popupTbl add command -label "Voir l'objet dans une image" \
                -command "" -state disabled
            $results.popupTbl add command -label "(d)efinir comme Reference" \
                -command "::bdi_gui_cdl::set_to_reference_data_science"
            $results.popupTbl add command -label "(r)ejeter les sources selectionnees" \
                -command "::bdi_gui_cdl::unset_data_science"
            $results.popupTbl add command -label "(t)able des sources selectionnees" \
                -command "::bdi_gui_cdl::table_popup sci"
            $results.popupTbl add command -label "(g)raphe de la source" \
                -command "::bdi_gui_cdl::graph_science_mag_popup"
            $results.popupTbl add command -label "(v)ignettes" \
                -command "::bdi_gui_cdl::vignette"
            $results.popupTbl add command -label "(f)amous" \
                -command "::bdi_gui_cdl::famous_appli"

         # Binding
         bind $::bdi_gui_cdl::data_science <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_science %W ]
         bind [$::bdi_gui_cdl::data_science bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-d> "::bdi_gui_cdl::set_to_reference_data_science"
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-r> "::bdi_gui_cdl::unset_data_science"
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-t> "::bdi_gui_cdl::table_popup sci"
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-g> "::bdi_gui_cdl::graph_science_mag_popup"
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-v> "::bdi_gui_cdl::vignette"
         bind [$::bdi_gui_cdl::data_science bodypath] <Key-f> "::bdi_gui_cdl::famous_appli"

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Name"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_science columnconfigure $pcol -sortmode ascii
         }
         #    Reel
         foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag" "Flux min" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_science columnconfigure $pcol -sortmode real
         }
         #    Integer
         foreach ncol [list "Radius min" "Nb Err PSF"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_science columnconfigure $pcol -sortmode integer
         }




      # Rejetes
      set results [frame $f_data_rejected.data_rejected  -borderwidth 1 -relief groove]
      pack $results -in $f_data_rejected -expand yes -fill both

         set cols [list 0 "Id"         left  \
                        0 "Name"       left  \
                        0 "Nb img"     right \
                        0 "Nb mes"     right \
                        0 "Moy Mag"    right \
                        0 "StDev Mag"  right \
                        0 "Nb Err PSF" right \
                        0 "Radius min" right \
                        0 "Flux min"   right \
                  ]
         # Table
         set ::bdi_gui_cdl::data_rejected $results.table
         tablelist::tablelist $::bdi_gui_cdl::data_rejected \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $results.hsb set ] \
           -yscrollcommand [ list $results.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_rejected xview]
         pack $results.hsb -in $results -side bottom -fill x
         scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::data_rejected yview]
         pack $results.vsb -in $results -side right -fill y

         # Pack la Table
         pack $::bdi_gui_cdl::data_rejected -in $results -expand yes -fill both

         # Popup
         menu $results.popupTbl -title "Actions"

            $results.popupTbl add command -label "Voir l'objet dans une image" \
                -command "" -state disabled
            $results.popupTbl add command -label "Definir comme Reference" \
                -command "::bdi_gui_cdl::set_to_reference_data_rejected"
            $results.popupTbl add command -label "Definir comme Science" \
                -command "::bdi_gui_cdl::set_to_science_data_rejected"

         # Binding
         bind $::bdi_gui_cdl::data_rejected <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_rejected %W ]
         bind [$::bdi_gui_cdl::data_rejected bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Name"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_rejected columnconfigure $pcol -sortmode ascii
         }
         #    Reel
         foreach ncol [list "Id" "Nb img" "Nb mes" "Moy Mag" "StDev Mag" "Flux min"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_rejected columnconfigure $pcol -sortmode real
         }
         #    Integer
         foreach ncol [list "Radius min" "Nb Err PSF"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::data_rejected columnconfigure $pcol -sortmode integer
         }





      # Variations
      set results [frame $f_starstar.starstar  -borderwidth 1 -relief groove]
      pack $results -in $f_starstar -expand yes -fill both


               set cols [list 0 " " left ]
               # Table
               set ::bdi_gui_cdl::ss_mag_stdev $results.table
               tablelist::tablelist $::bdi_gui_cdl::ss_mag_stdev \
                 -columns $cols \
                 -labelcommand tablelist::sortByColumn \
                 -xscrollcommand [ list $results.hsb set ] \
                 -yscrollcommand [ list $results.vsb set ] \
                 -selectmode extended \
                 -activestyle none \
                 -stripebackground "#e0e8f0" \
                 -showseparators 1

               # Scrollbar
               scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::ss_mag_stdev xview]
               pack $results.hsb -in $results -side bottom -fill x
               scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::ss_mag_stdev yview]
               pack $results.vsb -in $results -side right -fill y

               # Pack la Table
               pack $::bdi_gui_cdl::ss_mag_stdev -in $results -expand yes -fill both

               # Popup
               menu $results.popupTbl -title "Actions"

                  $results.popupTbl add command -label "Voir l'objet dans une image" \
                      -command "" -state disabled
                  $results.popupTbl add command -label "(r)ejeter" \
                      -command "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_mag_stdev"


               # Binding
               bind $::bdi_gui_cdl::ss_mag_stdev <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_starstar %W ]
               bind [$::bdi_gui_cdl::ss_mag_stdev bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]
               bind [$::bdi_gui_cdl::ss_mag_stdev bodypath] <Key-r> "::bdi_gui_cdl::unset_starstar $::bdi_gui_cdl::ss_mag_stdev"




      # Classification
      set results [frame $f_classif.classif  -borderwidth 1 -relief groove]
      pack $results -in $f_classif -expand yes -fill both


         global audace
         package require Img
         set photo [image create photo -file [ file join $audace(rep_plugin) tool bddimages images classification_spectrale.png ]]
         label $results.cs -image $photo -borderwidth 2 -width 850 -height 81
         pack $results.cs -in $results -side top -expand no


         set cols [list 0 "Id"             left  \
                        0 "Name"           left  \
                        0 "Class"          left  \
                        0 "USNOA2_magB"    left  \
                        0 "USNOA2_magR"    left  \
                        0 "UCAC4_im1_mag"  left  \
                        0 "UCAC4_im2_mag"  left  \
                        0 "NOMAD1_magB"    left  \
                        0 "NOMAD1_magV"    left  \
                        0 "NOMAD1_magR"    left  \
                        0 "NOMAD1_magJ"    left  \
                        0 "NOMAD1_magH"    left  \
                        0 "NOMAD1_magK"    left  \
                  ]

         # Table
         set ::bdi_gui_cdl::classif $results.table
         tablelist::tablelist $::bdi_gui_cdl::classif \
           -columns $cols \
           -labelcommand tablelist::sortByColumn \
           -xscrollcommand [ list $results.hsb set ] \
           -yscrollcommand [ list $results.vsb set ] \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -showseparators 1

         # Scrollbar
         scrollbar $results.hsb -orient horizontal -command [list $::bdi_gui_cdl::classif xview]
         pack $results.hsb -in $results -side bottom -fill x
         scrollbar $results.vsb -orient vertical -command [list $::bdi_gui_cdl::classif yview]
         pack $results.vsb -in $results -side right -fill y

         # Pack la Table
         pack $::bdi_gui_cdl::classif -in $results -side top -expand yes -fill both

         # Popup
         menu $results.popupTbl -title "Actions"

            $results.popupTbl add command -label "Voir l'objet dans une image" \
                -command "" -state disabled
            $results.popupTbl add command -label "Supprimer" \
                -command "::bdi_gui_cdl::unset_classif"

         # Binding
         bind $::bdi_gui_cdl::classif <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_classif %W ]
         bind [$::bdi_gui_cdl::classif bodypath] <ButtonPress-3> [ list tk_popup $results.popupTbl %X %Y ]

         # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
         #    Ascii
         foreach ncol [list "Name" "Class"] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode ascii
         }
         #    Reel
         foreach ncol [list "Id" "USNOA2_magB" "USNOA2_magR" "UCAC4_im1_mag" "UCAC4_im2_mag" "NOMAD1_magB" \
                            "NOMAD1_magV" "NOMAD1_magR"  "NOMAD1_magJ" "NOMAD1_magH" "NOMAD1_magK" ] {
            set pcol [expr int ([lsearch $cols $ncol]/3)]
            $::bdi_gui_cdl::classif columnconfigure $pcol -sortmode real
         }





      # Vignettes


      set block [frame $f_vign.frm  -borderwidth 1 -relief groove]
      pack $block -in $f_vign -expand yes -fill both

         if {1==0} {
            $onglets.nb select $f_vign
            # buttons Dev
            set butdev [frame $block.butdev  -borderwidth 1 -relief groove]
            pack $butdev -in $block -expand no -fill both

                button $butdev.ressource -text "Ressource" -borderwidth 2 -takefocus 1 \
                   -command "::console::clear ; ::bddimages::ressource"
                button $butdev.relance -text "Relance" -borderwidth 2 -takefocus 1 \
                   -command "::bdi_gui_cdl::relance"

                grid $butdev.ressource $butdev.relance -sticky news
         }

         # config famous
         set f0 [frame $block.f0 -borderwidth 1 -cursor arrow -relief sunken -background white ]
         pack $f0 -in $block -expand no

         set fl [frame $f0.fl -borderwidth 0 -cursor arrow -relief sunken -background white ]
         pack $fl -in $f0 -side left
         set fr [frame $f0.fr -borderwidth 0 -cursor arrow -relief sunken -background white ]
         pack $fr -in $f0 -side right


         # frame de gauche
            TitleFrame $fl.obj -borderwidth 2 -text "Selection de l'objet"
            grid $fl.obj -in $fl -sticky news

               set ::bdi_gui_cdl::widget(vignette,combo) [ComboBox $fl.obj.combo \
                  -width 20 -height 3 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_cdl::widget(objsel,combo,value) \
                  -values $::bdi_gui_cdl::widget(objsel,combo,list) ]
               grid $fl.obj.combo -in [$fl.obj getframe] -sticky news

            Button $fl.go    -text "Build"      -width 1 -command "::bdi_gui_cdl::vignette_build"
            grid $fl.go -in $fl -sticky news  -columnspan 4

            TitleFrame $fl.pts -borderwidth 2 -text "Selection des points"
            grid $fl.pts -in $fl -sticky news
               set ::bdi_gui_cdl::widget(vignette,select,nb) 0
               label   $fl.pts.lps -text "Nb pts Selected :"
               label   $fl.pts.vps -textvariable ::bdi_gui_cdl::widget(vignette,select,nb)
               Button $fl.pts.clear -text "Clear"  -command "::bdi_gui_cdl::vignette_selection_clear"
               Button $fl.pts.del   -text "Delete"  -command "::bdi_gui_cdl::vignette_suppression_finale"

               grid $fl.pts.lps $fl.pts.vps -in [$fl.pts getframe] -sticky news
               grid $fl.pts.clear -in [$fl.pts getframe] -sticky news
               grid $fl.pts.del -in [$fl.pts getframe] -sticky news

            TitleFrame $fl.img -borderwidth 2 -text "Defilement des images"
            grid $fl.img -in $fl -sticky news

               set ::bdi_gui_cdl::widget(vignette,scale) [scale $fl.img.scale -from 0 -to 0 \
                      -length 300 -variable ::bdi_gui_cdl::widget(vignette,idimg) \
                      -label "Images" -orient horizontal -state normal -showvalue 0 ]
               bind $fl.img.scale <Motion> "::bdi_gui_cdl::vignette_view"
               grid $fl.img.scale -in [$fl.img getframe] -sticky news

         # frame de droite
         # image
            set ::bdi_gui_cdl::widget(vignette,can) [canvas $fr.canv -borderwidth 0 -highlightthickness 0]
            grid $::bdi_gui_cdl::widget(vignette,can) -in $fr -row 0 -column 0 -sticky news
            set ::bdi_gui_cdl::widget(vignette,photo) [image create photo -gamma 2]
            $::bdi_gui_cdl::widget(vignette,can) create image 0 0 -anchor nw -tag photo
            $::bdi_gui_cdl::widget(vignette,can) itemconfigure photo -image $::bdi_gui_cdl::widget(vignette,photo)


      # Famous


      set block [frame $f_famous.frm  -borderwidth 1 -relief groove]
      pack $block -in $f_famous -expand yes -fill both

         
         # config famous
         set famous [frame $block.famous_config -borderwidth 1 -cursor arrow -relief sunken -background white ]
         pack $famous -in $block


            TitleFrame $famous.obj -borderwidth 2 -text "Selection de l'objet"
            grid $famous.obj -in $famous -sticky news

               set ::bdi_gui_cdl::widget(vignette,combo) [ComboBox $famous.obj.combo \
                  -width 20 -height 3 \
                  -relief sunken -borderwidth 1 -editable 0 \
                  -textvariable ::bdi_gui_cdl::widget(objsel,combo,value) \
                  -values $::bdi_gui_cdl::widget(objsel,combo,list) ]
               grid $famous.obj.combo  -in [$famous.obj getframe] -sticky news

            ::bdi_gui_cdl::famous_widget_create $famous

            TitleFrame $famous.res -borderwidth 2 -text "Results"
            grid $famous.res -in $famous -sticky news

               label $famous.res.labsta -text "Status : "
               label $famous.res.valsta -textvariable ::bdi_gui_cdl::widget(famous,status)

               label $famous.res.labtos -text "Type of Solu : "
               label $famous.res.valtos -textvariable ::bdi_gui_cdl::widget(famous,typeofsolu)

               label $famous.res.labnbd -text "Nb dates : "
               label $famous.res.valnbd -textvariable ::bdi_gui_cdl::widget(famous,stats,nb_dates)

               label $famous.res.labtsp -text "Time Span : "
               label $famous.res.valtsp -textvariable ::bdi_gui_cdl::widget(famous,stats,time_span)

               label $famous.res.labam  -text "Amplitude : "
               label $famous.res.valam  -textvariable ::bdi_gui_cdl::widget(famous,stats,residuals_ampl)

               label $famous.res.labrm  -text "Residus Mean : "
               label $famous.res.valrm  -textvariable ::bdi_gui_cdl::widget(famous,stats,residuals_mean)

               label $famous.res.labrs  -text "Residus Stdev : "
               label $famous.res.valrs  -textvariable ::bdi_gui_cdl::widget(famous,stats,residuals_std)

               grid $famous.res.labsta $famous.res.valsta -in [$famous.res getframe] -sticky nw
               grid $famous.res.labtos $famous.res.valtos -in [$famous.res getframe] -sticky nw
               grid $famous.res.labnbd $famous.res.valnbd -in [$famous.res getframe] -sticky nw
               grid $famous.res.labtsp $famous.res.valtsp -in [$famous.res getframe] -sticky nw
               grid $famous.res.labam  $famous.res.valam  -in [$famous.res getframe] -sticky nw
               grid $famous.res.labrm  $famous.res.valrm  -in [$famous.res getframe] -sticky nw
               grid $famous.res.labrs  $famous.res.valrs  -in [$famous.res getframe] -sticky nw


      # Resultats
      set wdth 13
      set results [frame $f_results.rapports  -borderwidth 1 -relief groove]
      pack $results -in $f_results -expand yes -fill both

         if {1==0} {
            $onglets.nb select $f_results
            # buttons Dev
            set butdev [frame $results.butdev  -borderwidth 1 -relief groove]
            pack $butdev -in $results -expand no -fill both

                button $butdev.ressource -text "Ressource" -borderwidth 2 -takefocus 1 \
                   -command "::console::clear ; ::bddimages::ressource"
                button $butdev.relance -text "Relance" -borderwidth 2 -takefocus 1 \
                   -command "::bdi_gui_cdl::relance"

                grid $butdev.ressource $butdev.relance -sticky news
         }

         #--- Onglet RAPPORT - Entetes
         set ongl [frame $results.ongl  -borderwidth 0 -cursor arrow -relief groove]
         pack $ongl  -in $results -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

            pack [ttk::notebook $ongl.nb] -expand yes -fill both
            set f_obs [frame $ongl.nb.f_obs]
            set f_sci [frame $ongl.nb.f_sci]
            $ongl.nb add $f_obs -text "Observation"
            $ongl.nb add $f_sci -text "Objets"
            ttk::notebook::enableTraversal $ongl.nb
            $ongl.nb select $f_obs

            set oblock [frame $f_obs.frm  -borderwidth 1 -relief groove]
            pack $oblock -in $f_obs -expand yes -fill both

               #--- Onglet RAPPORT - Entetes
               set block [frame $oblock.uai_code  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "IAU Code : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 5 -textvariable ::bdi_tools_cdl::rapport_uai_code
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

                     label  $block.loc -textvariable ::bdi_tools_astrometry::rapport_uai_location -borderwidth 1 -width $wdth
                     pack   $block.loc -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.rapporteur  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Rapporteur : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_rapporteur
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.adresse  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Adresse : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_adresse
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.mail  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Mail : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80  -textvariable ::bdi_tools_cdl::rapport_mail
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.observ  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Observateurs : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_observ
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.reduc  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Reduction : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_reduc
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.instru  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Instrument : " -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_instru
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w

               set block [frame $oblock.labcom  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "Commentaire pour le rapport final : " -borderwidth 1
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

              set block [frame $oblock.comment  -borderwidth 0 -cursor arrow -relief groove]
               pack $block  -in $oblock -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

                     label  $block.lab -text "" -borderwidth 1 -width $wdth
                     pack   $block.lab -side left -padx 3 -pady 3 -anchor w

                     entry  $block.val -relief sunken -width 80 -textvariable ::bdi_tools_cdl::rapport_comment
                     pack   $block.val -side left -padx 3 -pady 3 -anchor w


         # Bloc Objets
            set sblock [frame $f_sci.frm  -borderwidth 1 -relief groove]
            pack $sblock -in $f_sci -expand yes -fill both

               TitleFrame $sblock.obj -borderwidth 2 -text "Selection de l'objet"
               pack $sblock.obj -in $sblock -expand no -fill both

                  set ::bdi_gui_cdl::widget(objsel,menu) [menubutton $sblock.obj.combo \
                     -menu $sblock.obj.combo.m \
                     -width 20 -height 1 \
                     -relief sunken -borderwidth 1 \
                     -textvariable ::bdi_gui_cdl::widget(objsel,combo,value)]
                  menu $sblock.obj.combo.m -tearoff 0
                  
                  #set ::bdi_gui_cdl::widget(vignette,combo) [ComboBox $sblock.obj.combo \
                  #   -width 20 -height 3 \
                  #   -relief sunken -borderwidth 1 -editable 0 \
                  #   -textvariable ::bdi_gui_cdl::widget(objsel,combo,value) \
                  #   -values $::bdi_gui_cdl::widget(objsel,combo,list) ]
                  #bind $::bdi_gui_cdl::widget(vignette,combo) <<ComboboxSelected>> "::bdi_gui_cdl::resume"
                  #$::bdi_gui_cdl::widget(vignette,combo) add command -command [list ::bdi_gui_cdl::resume ]
                  grid $sblock.obj.combo  -in [$sblock.obj getframe] -sticky news


               set block [frame $sblock.tbl  -borderwidth 1 -relief groove]
               pack $block -in $sblock -expand yes -fill both

                     set cols [list 0 "Key" left  \
                                    0 "Value" left  \
                                    0 "Comment" left  \
                              ]

                     # Table
                     set ::bdi_gui_cdl::final_data $block.table
                     tablelist::tablelist $::bdi_gui_cdl::final_data \
                       -columns $cols \
                       -xscrollcommand [ list $block.hsb set ] \
                       -yscrollcommand [ list $block.vsb set ] \
                       -selectmode extended \
                       -activestyle none \
                       -stripebackground "#e0e8f0" \
                       -showseparators 1

                     # Scrollbar
                     scrollbar $block.hsb -orient horizontal -command [list $::bdi_gui_cdl::final_data xview]
                     pack $block.hsb -in $block -side bottom -fill x
                     scrollbar $block.vsb -orient vertical -command [list $::bdi_gui_cdl::final_data yview]
                     pack $block.vsb -in $block -side right -fill y

                     # Pack la Table
                     pack $::bdi_gui_cdl::final_data -in $block -side top -expand yes -fill both



         # Sauve tous les rapports
         set block [frame $results.actionsave  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $results -anchor s -side top -expand 1 -padx 10 -pady 5


#                  button $block.submit_result -text "Soumettre" -borderwidth 2 -takefocus 1 \
#                     -command "::bdi_gui_cdl::submit_reports"
#
#                  checkbutton $block.flag_submit -highlightthickness 0 -text " Le rapport a ete soumis  " \
#                     -font $bddconf(font,arial_10_b) -variable ::bdi_tools_cdl::reports_photom_submit


               button $block.sauve_result -text "Sauver tous les rapports" -borderwidth 2 -takefocus 1 \
                  -command "::bdi_gui_cdl::save_reports"

#                  grid $block.submit_result  $block.flag_submit $block.sauve_result  -sticky news
               grid $block.sauve_result -sticky news


      # Big DATA
      set center [frame $f_bigdata.frm  -borderwidth 1 -relief groove]
      pack $center -in $f_bigdata -expand yes -fill both

         set actions [frame $center.center  -borderwidth 0 -relief sunken]
         pack $actions -in $center -expand no -fill y

           checkbutton $actions.check -variable ::bdi_tools_cdl::bigdata  -justify left \
             -text "Activer BigData pour reduire l'utilisation de la memoire"

           label $actions.labcharge -text "Chargement"  -justify left
           button $actions.charge_alavolee -text "A la volee" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::charge_cata_alavolee"
           button $actions.stop -text "STOP" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::stop_charge_cata_alavolee"
           button $actions.chargelist -text "Charge LIST" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::charge_cata_list"

          grid $actions.check           -row 0 -column 0  -columnspan 3 -sticky news -ipadx 10 -ipady 10
          grid $actions.labcharge       -row 1 -column 0 -sticky news -ipady 10
          grid $actions.charge_alavolee -row 2 -column 0 -sticky news
          grid $actions.stop            -row 3 -column 0 -sticky news
          grid $actions.chargelist      -row 4 -column 0 -sticky news

           label $actions.labcalc -text "Calculs"  -justify left
           button $actions.magcst -text "Constante des Mag" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::calcul_const_mags"
           button $actions.calcsci -text "Sources Science" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::calcul_science"
           button $actions.calcrej -text "Sources Rejetes" -borderwidth 2 -takefocus 1 \
              -command "::bdi_tools_cdl::calcul_rejected"
           button $actions.variation -text "Table de variations" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::calcul_variation"
           button $actions.typspec -text "Type spectral" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::calcul_classification"

          grid $actions.labcalc    -row 1 -column 1 -sticky news -ipady 10
          grid $actions.magcst     -row 2 -column 1 -sticky news
          grid $actions.calcsci    -row 3 -column 1 -sticky news
          grid $actions.calcrej    -row 4 -column 1 -sticky news
          grid $actions.variation  -row 5 -column 1 -sticky news
          grid $actions.typspec    -row 6 -column 1 -sticky news

           label $actions.labvoir -text "Affichage"  -justify left
           button $actions.voir -text "Tables" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::affiche_data"

          grid $actions.labvoir      -row 1 -column 2 -sticky news -ipady 10
          grid $actions.voir         -row 2 -column 2 -sticky news



      # Develop
      set actions [frame $f_develop.frm  -borderwidth 1 -relief groove]
      pack $actions -in $f_develop -expand yes -fill both


           button $actions.ressource -text "Ressource les scripts" -borderwidth 2 -takefocus 1 \
              -command "::bddimages::ressource"
           button $actions.relance -text "Relance la GUI" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::relance"
           button $actions.clean -text "Efface le contenu de la console" -borderwidth 2 -takefocus 1 \
              -command "console::clear"
           button $actions.testgui -text "Test GUI" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::test_gui" -state disabled


          grid $actions.ressource -row 1 -column 0 -sticky news
          grid $actions.relance   -row 2 -column 0 -sticky news
          grid $actions.clean     -row 3 -column 0 -sticky news
          grid $actions.testgui   -row 4 -column 0 -sticky news



      #--- Cree un frame
      set pb [frame $frm.pb  -borderwidth 0 -cursor arrow -relief groove]
      pack $pb  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          set ::bdi_tools_cdl::progress 0
          set    pf [ ttk::progressbar $pb.p -variable ::bdi_tools_cdl::progress -orient horizontal -mode determinate]
          pack   $pf -in $pb -side left -expand 1 -fill x


      #--- Cree un frame pour afficher les boutons
      set center [frame $frm.cnbsources  -borderwidth 2 -cursor arrow -relief groove]
      pack $center  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un frame
      set nbsources [frame $center.nbsources  -borderwidth 0 -cursor arrow -relief groove]
      pack $nbsources  -in $center -anchor s -side top -expand 0 -padx 10 -pady 5

           label $nbsources.labref -text "Nb References :"
           label $nbsources.nbref  -textvariable ::bdi_tools_cdl::nbref
           label $nbsources.labsci -text " - Nb Sciences :"
           label $nbsources.nbsci  -textvariable ::bdi_tools_cdl::nbscience
           label $nbsources.labrej -text " - Nb Rejetees :"
           label $nbsources.nbrej  -textvariable ::bdi_tools_cdl::nbrej

           grid $nbsources.labref $nbsources.nbref  $nbsources.labsci $nbsources.nbsci  $nbsources.labrej $nbsources.nbrej -sticky news

      #--- Cree un frame pour afficher les boutons
      set center [frame $frm.actions  -borderwidth 2 -cursor arrow -relief groove]
      pack $center  -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un frame pour afficher les boutons
      set actions [frame $center.actions  -borderwidth 4 -cursor arrow -relief groove]
      pack $actions  -in $center -anchor s -side top -expand 0 -fill y -padx 10 -pady 5


           label $actions.labgestion -text "Gestion"  -justify left
           button $actions.charge_gestion -text "Charge" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::charge_from_gestion"
           button $actions.sauve_gestion -text "Sauve" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::save_image_cata"

           label $actions.labref -text "References"  -justify left
           button $actions.const_mag -text "Constantes" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::graph_const_mag"
           button $actions.stars_mag -text "Stars" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::graph_stars_mag"
           button $actions.timeline  -text "Timeline" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::graph_timeline"

           label $actions.labscience -text "Sciences"  -justify left
           button $actions.science_mag -text "Mag" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::graph_science_mag"
           button $actions.science_unset -text "Clean graph" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::unset_science_in_graph"

           button $actions.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
              -command "::bdi_gui_cdl::fermer"
           button $actions.aide -text "Aide" -borderwidth 2 -takefocus 1 \
              -command "" -state disabled


          grid $actions.labgestion      -row 0 -column 2 -sticky news
          grid $actions.charge_gestion  -row 1 -column 2 -sticky news
          grid $actions.sauve_gestion   -row 2 -column 2 -sticky news

          grid $actions.labref       -row 0 -column 6 -sticky news
          grid $actions.const_mag    -row 1 -column 6 -sticky news
          grid $actions.stars_mag    -row 2 -column 6 -sticky news
          grid $actions.timeline     -row 3 -column 6 -sticky news

          grid $actions.labscience    -row 0 -column 8 -sticky news
          grid $actions.science_mag   -row 1 -column 8 -sticky news
          grid $actions.science_unset -row 2 -column 8 -sticky news

          grid $actions.aide         -row 2 -column 10 -sticky news
          grid $actions.fermer       -row 3 -column 10 -sticky news



      #--- Cree un frame pour afficher les boutons
      set center [frame $frm.info  -borderwidth 2 -cursor arrow -relief groove]
      pack $center  -in $frm -anchor s -side bottom -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un frame pour afficher les boutons
      set info [frame $center.info  -borderwidth 0 -cursor arrow -relief groove]
      pack $info  -in $center -anchor s -side top -expand 0 -padx 10 -pady 5


          checkbutton $info.check -variable ::bdi_tools_cdl::memory(memview)  -justify left \
             -command "::bdi_tools_cdl::get_memory"
          label $info.labjob -text "Mem Job :"  -justify left
          label $info.valjob -textvariable ::bdi_tools_cdl::memory(mempid)  -justify left
          label $info.labmem -text "Mem Free % :"  -justify left
          label $info.valmem -textvariable ::bdi_tools_cdl::memory(mem)  -justify left
          label $info.labswa -text "Swap Free % :"  -justify left
          label $info.valswa -textvariable ::bdi_tools_cdl::memory(swap)  -justify left

          grid $info.check $info.labjob $info.valjob $info.labmem $info.valmem $info.labswa $info.valswa


   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_cdl::fen

}






#-------------------------------------------------------------------
## Effectue un test de la GUI
# \ l idee est d afficher un grand nombre de ligne pour voir
# evoluer la memoire
#  \return void
proc ::bdi_gui_cdl::test_gui { } {


}





#-------------------------------------------------------------------
## Affiche les valeurs dans les tables Science References et Rejets
# \brief
# Structure ASTROID :
#  0    "xsm"
#  1    "ysm"
#  2    "err_xsm"
#  3    "err_ysm"
#  4    "fwhmx"
#  5    "fwhmy"
#  6    "fwhm"
#  7    "flux"
#  8    "err_flux"
#  9    "pixmax"
#  10   "intensity"
#  11   "sky"
#  12   "err_sky"
#  13   "snint"
#  14   "radius"
#  15   "rdiff"
#  16   "err_psf"
#  17   "ra"
#  18   "dec"
#  19   "res_ra"
#  20   "res_dec"
#  21   "omc_ra"
#  22   "omc_dec"
#  23   "mag"
#  24   "err_mag"
#  25   "name"
#  26   "flagastrom"
#  27   "flagphotom"
#  28   "cataastrom"
#  29   "cataphotom"
#
#  \return void
proc ::bdi_gui_cdl::affiche_data { } {

   set tt0 [clock clicks -milliseconds]

   if {[info exists ::bdi_tools_cdl::list_of_stars]} {unset ::bdi_tools_cdl::list_of_stars}

   if {![info exists ::bdi_tools_cdl::table_data_source]} {return}

   # Onglet References

   $::bdi_gui_cdl::data_reference delete 0 end

   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$y != 1} {continue}
      $::bdi_gui_cdl::data_reference insert end $::bdi_tools_cdl::table_data_source($name)
      lappend ::bdi_tools_cdl::list_of_stars $ids
   }

   # Onglet Science
  
   $::bdi_gui_cdl::widget(objsel,menu).m delete 0 end
   $::bdi_gui_cdl::data_science delete 0 end
   set ::bdi_gui_cdl::widget(objsel,combo,list) ""
   set ::bdi_gui_cdl::widget(objsel,combo,value) ""

   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$y != 2} {continue}
      lappend ::bdi_gui_cdl::widget(objsel,combo,list) $name
      $::bdi_gui_cdl::widget(objsel,menu).m add command -label $name -command [list ::bdi_gui_cdl::resume $name]
      $::bdi_gui_cdl::data_science insert end $::bdi_tools_cdl::table_data_source($name)
   }

   # Onglet Rejected

   $::bdi_gui_cdl::data_rejected delete 0 end

   set ids 0
   foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$y != 0} {continue}
      if { [lindex $::bdi_tools_cdl::table_data_source($name) 3] == 0 } {continue}
      if { [lindex $::bdi_tools_cdl::table_data_source($name) 4] <  0 } {continue}
      
      $::bdi_gui_cdl::data_rejected insert end $::bdi_tools_cdl::table_data_source($name)
   }
   
   # Selection de l objet Science
   $::bdi_gui_cdl::widget(vignette,combo) configure -values $::bdi_gui_cdl::widget(objsel,combo,list)
   if {[llength $::bdi_gui_cdl::widget(objsel,combo,list)] == 1} {
      set ::bdi_gui_cdl::widget(objsel,combo,value) [lindex $::bdi_gui_cdl::widget(objsel,combo,list) 0]
   }
   
   # Fin de visualisation des donnees
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Affichage complet en $tt sec \n"

   return

}


#----------------------------------------------------------------------------
## Effectue tous les calculs
#  \return void
#
proc ::bdi_gui_cdl::calcule_tout { } {

   if {$::bdi_tools_cdl::bigdata == 0} {
      ::bdi_tools_cdl::charge_cata_list
      ::bdi_tools_cdl::calcul_const_mags
      ::bdi_tools_cdl::calcul_science
      ::bdi_tools_cdl::calcul_rejected
      ::bdi_gui_cdl::calcul_variation
      ::bdi_gui_cdl::calcul_classification
      ::bdi_gui_cdl::resume $::bdi_gui_cdl::widget(objsel,combo,value)
      ::bdi_gui_cdl::affiche_data

      if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 1 } {
         ::bdi_gui_cdl::graph_science_mag_popup_exec
      }

   } else {
      ::bdi_gui_cdl::affiche_data
   }

}


#----------------------------------------------------------------------------
## Effectue le rapport des valeurs finales
#  \return void
#
proc ::bdi_gui_cdl::resume { obj } {

   $::bdi_gui_cdl::final_data delete 0 end
   set ::bdi_gui_cdl::widget(objsel,combo,value) $obj
   gren_info "RUN: $::bdi_gui_cdl::widget(objsel,combo,value)\n"
   
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {

      incr ids
      if {$o != 2} {continue}
      set obj $name
      gren_info "obj = $obj\n"
      gren_info "$::bdi_gui_cdl::widget(objsel,combo,value)\n"
      if {$obj != $::bdi_gui_cdl::widget(objsel,combo,value)} {continue}
      gren_info "ok\n"

      set tab_mag ""
      set tab_err_mag ""
      set tab_ra  ""
      set tab_dec ""
      set tab_jd ""
      set cpt 0
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         set othf $::bdi_tools_cdl::table_othf($obj,$idcata,othf)

         set midexpo_jd  $::bdi_tools_cdl::table_jdmidexpo($idcata)
         set mag         $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
         set ra          [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($obj,$idcata,othf) ra        ]
         set dec         [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($obj,$idcata,othf) dec       ]
         set flux        [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($obj,$idcata,othf) flux      ]
         set err_flux    [::bdi_tools_psf::get_val ::bdi_tools_cdl::table_othf($obj,$idcata,othf) err_flux  ]

         # Filtre
         set current_image [lindex $::tools_cata::img_list [expr $idcata-1]]
         set tabkey      [::bddimages_liste::lget $current_image "tabkey"]
         set filter      [string trim [lindex [::bddimages_liste::lget $tabkey "FILTER"]   1] ]

         set mag         [format "%7.4f"  $mag         ]
         set filter      [format "%-10s"  $filter      ]
         set ra          [format "%10.6f" $ra          ]
         set dec         [format "%10.6f" $dec         ]

         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]} {
            set err_mag     "-     "
         } else {
            set err_mag     [format "%0.4f" $::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]
            lappend tab_err_mag $err_mag
         }
         if {$flux!="" && [string is double $flux] && $flux+1 != $flux && $flux > 0} {
            set flux [format "%15.2f" $flux ]
         } else {
            set flux [format "%17s" "Nan"]
         }
         if {$err_flux!="" && [string is double $err_flux] && $err_flux+1 != $err_flux && $err_flux > 0} {
            #gren_erreur "err_flux = $err_flux \n"
            set err_flux [format "%15.2f" $err_flux ]
         } else {
            set err_flux [format "%15s" "Nan"]
         }

         incr cpt

         lappend tab_mag $mag
         lappend tab_ra  $ra
         lappend tab_dec $dec
         lappend tab_jd  $midexpo_jd
      }

      set nb_dates  $cpt
      set duration  [format "%.1f" [expr ([::math::statistics::max $tab_jd]-[::math::statistics::min $tab_jd])*24.0] ]
      set mag_mean  [format "%.3f" [::math::statistics::mean  $tab_mag] ]
      set mag_std   [format "%.3f" [::math::statistics::stdev $tab_mag] ]

      # le resultat de famous
      if {![info exists ::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]} {
         set mag_prec "-"
      } else {
         set mag_prec [format "%.3f" $::bdi_gui_cdl::widget(famous,stats,$obj,residuals_std)]
      }
      #set mag_prec  [format "%.3f" [::math::statistics::mean  $tab_err_mag] ]
      
      set mag_amp   [format "%.3f" [expr [::math::statistics::max $tab_mag]-[::math::statistics::min $tab_mag]]]
      set nb_ref_stars [llength $::bdi_tools_cdl::list_of_stars]
      set ra_mean   [::bdi_tools_astrometry::convert_txt_hms  [::math::statistics::mean  $tab_ra ] ]
      set dec_mean  [::bdi_tools_astrometry::convert_txt_dms  [::math::statistics::mean  $tab_dec] ]

      $::bdi_gui_cdl::final_data insert end [list "nb_dates"     $nb_dates                          [::bdi_tools_reports::file_info_comment "nb_dates"]]
      $::bdi_gui_cdl::final_data insert end [list "duration"     $duration                          [::bdi_tools_reports::file_info_comment "duration"]]
      $::bdi_gui_cdl::final_data insert end [list "nb_ref_stars" $nb_ref_stars                      [::bdi_tools_reports::file_info_comment "nb_ref_stars"]]
      $::bdi_gui_cdl::final_data insert end [list "cm_var_max"   $::bdi_tools_cdl::var_constmag_max [::bdi_tools_reports::file_info_comment "cm_var_max"]]
      $::bdi_gui_cdl::final_data insert end [list "cm_var_moy"   $::bdi_tools_cdl::var_constmag_moy [::bdi_tools_reports::file_info_comment "cm_var_moy"]]
      $::bdi_gui_cdl::final_data insert end [list "cm_var_med"   $::bdi_tools_cdl::var_constmag_med [::bdi_tools_reports::file_info_comment "cm_var_med"]]
      $::bdi_gui_cdl::final_data insert end [list "cm_var_std"   $::bdi_tools_cdl::var_constmag_std [::bdi_tools_reports::file_info_comment "cm_var_std"]]
      $::bdi_gui_cdl::final_data insert end [list "fwhm_mean"    $::bdi_tools_cdl::fwhm             [::bdi_tools_reports::file_info_comment "fwhm_mean"]]
      $::bdi_gui_cdl::final_data insert end [list "fwhm_std"     $::bdi_tools_cdl::fwhm_std         [::bdi_tools_reports::file_info_comment "fwhm_std"]]
      $::bdi_gui_cdl::final_data insert end [list "mag_mean"     $mag_mean                          [::bdi_tools_reports::file_info_comment "mag_mean"]]
      $::bdi_gui_cdl::final_data insert end [list "mag_std"      $mag_std                           [::bdi_tools_reports::file_info_comment "mag_std"]]
      $::bdi_gui_cdl::final_data insert end [list "mag_prec"     $mag_prec                          [::bdi_tools_reports::file_info_comment "mag_prec"]]
      $::bdi_gui_cdl::final_data insert end [list "mag_amp"      $mag_amp                           [::bdi_tools_reports::file_info_comment "mag_amp"]]
      $::bdi_gui_cdl::final_data insert end [list "ra_mean"      $ra_mean                           [::bdi_tools_reports::file_info_comment "ra_mean" ]]
      $::bdi_gui_cdl::final_data insert end [list "dec_mean"     $dec_mean                          [::bdi_tools_reports::file_info_comment "dec_mean"]]

   }

}

#----------------------------------------------------------------------------
## Affiche le calcul de la variation etoile a etoile de reference
#  \return void
#
proc ::bdi_gui_cdl::calcul_variation { } {

   set tt0 [clock clicks -milliseconds]

   # Onglet variation

   $::bdi_gui_cdl::ss_mag_stdev    delete 0 end

   catch { $::bdi_gui_cdl::ss_mag_stdev deletecolumns 0 end }

   $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 "" left
   $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 "sum" center


   if {[info exists ::bdi_tools_cdl::list_of_stars]} {

      set pcol 0
      foreach ids $::bdi_tools_cdl::list_of_stars {
         $::bdi_gui_cdl::ss_mag_stdev    insertcolumns end 0 $ids right
         $::bdi_gui_cdl::ss_mag_stdev    columnconfigure $pcol -sortmode real
         incr pcol
      }
      set tab_var_constmag ""
      set magmax -1
      set col 0
      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         set line_mag_stdev [list $ids1 "-"]
         set row 2
         set sum 0
         set pcols ""
         foreach ids2 $::bdi_tools_cdl::list_of_stars {
            set mag $::bdi_tools_cdl::table_variations($ids1,$ids2,mag,stdev)
            if {$mag==-99} {
               set mag 0.000
               lappend pcols $row
            }
            lappend tab_var_constmag $mag
            set sum [expr $sum + $mag]
            if {$mag>$magmax} {
              # gren_info "$mag>$magmax $row,$col\n"
               set magmax $mag
               set colmax $col
               set rowmax $row
            }
            lappend line_mag_stdev [format "%.3f" $mag]
            incr row
         }
         
         set line_mag_stdev [lreplace $line_mag_stdev 1 1 [format "%.3f" $sum]]
         $::bdi_gui_cdl::ss_mag_stdev    insert end $line_mag_stdev
         foreach pcol $pcols {
            $::bdi_gui_cdl::ss_mag_stdev cellconfigure end,$pcol -background "#FFFF00"
         }
         incr col
      }

      $::bdi_gui_cdl::ss_mag_stdev cellconfigure $colmax,$rowmax -background red
      set pcol 0
      foreach ids1 $::bdi_tools_cdl::list_of_stars {
         $::bdi_gui_cdl::ss_mag_stdev    cellconfigure $pcol,[expr $pcol+2] -background darkgrey
         $::bdi_gui_cdl::ss_mag_stdev    cellconfigure $pcol,1 -background ivory
         incr pcol
      }
      $::bdi_gui_cdl::ss_mag_stdev sortbycolumn 1 -decreasing

      set ::bdi_tools_cdl::var_constmag_max [format "%.3f" $magmax]
      set ::bdi_tools_cdl::var_constmag_moy [format "%.3f" [::math::statistics::mean   $tab_var_constmag]]
      set ::bdi_tools_cdl::var_constmag_med [format "%.3f" [::math::statistics::median $tab_var_constmag]]
      set ::bdi_tools_cdl::var_constmag_std [format "%.3f" [::math::statistics::stdev  $tab_var_constmag]]

      gren_info "--\n"
      gren_info "Variation maximum des binomes = $::bdi_tools_cdl::var_constmag_max\n"
      gren_info "Variation moyenne des binomes = $::bdi_tools_cdl::var_constmag_moy\n"
      gren_info "Variation mediane des binomes = $::bdi_tools_cdl::var_constmag_med\n"
      gren_info "Ecart Type de la variation    = $::bdi_tools_cdl::var_constmag_std\n"
      gren_info "--\n"
   }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Calcul des variations en $tt sec \n"

}





#----------------------------------------------------------------------------
## Affiche la classification spectrale des etoiles
#  \return void
#
proc ::bdi_gui_cdl::calcul_classification { } {

   set tt0 [clock clicks -milliseconds]

   if {[info exists ::bdi_tools_cdl::list_of_stars]} {

      # Onglet Classification
      $::bdi_gui_cdl::classif delete 0 end
      set ids 0
      foreach {name y} [array get ::bdi_tools_cdl::table_noms] {
         incr ids
         if {$y != 1} {continue}
         if {![info exists ::bdi_tools_cdl::table_values($name,sptype)]} {
            continue
         }
         set line [list $ids $name $::bdi_tools_cdl::table_values($name,sptype)]
         gren_info "name class = $name\n"
         if { ![info exists ::bdi_tools_cdl::table_mag($name,USNOA2_magB)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,USNOA2_magB)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,USNOA2_magR)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,USNOA2_magR)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag)] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,UCAC4_im1_mag) }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag)] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,UCAC4_im2_mag) }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magB)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magB)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magV)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magV)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magR)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magR)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magJ)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magH)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magH)   }
         if { ![info exists ::bdi_tools_cdl::table_mag($name,NOMAD1_magK)  ] } { lappend line "-99" } else { lappend line $::bdi_tools_cdl::table_mag($name,NOMAD1_magK)   }
         $::bdi_gui_cdl::classif insert end $line
      }
      $::bdi_gui_cdl::classif columnconfigure 2 -sortmode ascii
      $::bdi_gui_cdl::classif sortbycolumn 2


   # fin test : if {![info exists ::bdi_tools_cdl::list_of_stars]} {}
   }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Calcul des Classifications en $tt sec \n"

}



#----------------------------------------------------------------------------
## Definit un objet science dans la tables des objets references
#  \return void
#
proc ::bdi_gui_cdl::set_to_science_data_reference { } {

   foreach select [$::bdi_gui_cdl::data_reference curselection] {

      incr ::bdi_tools_cdl::nbscience
      incr ::bdi_tools_cdl::nbref -1

      set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 2
      gren_info "$name to Science\n"
   }
   ::bdi_gui_cdl::calcule_tout

}


#----------------------------------------------------------------------------
## Definit un objet reference dans la tables des objets sciences
#  \return void
#
proc ::bdi_gui_cdl::set_to_reference_data_science { } {

   foreach select [$::bdi_gui_cdl::data_science curselection] {
      incr ::bdi_tools_cdl::nbref
      incr ::bdi_tools_cdl::nbscience -1
      set idps [lindex [$::bdi_gui_cdl::data_science get $select] 0]
      set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 1

      # RAZ du resultat Famous
      if {[info exists ::bdi_gui_cdl::widget(famous,stats,$name,residuals_std)]} {
         unset ::bdi_gui_cdl::widget(famous,stats,$name,residuals_std)
      }

   }
   ::bdi_tools_cdl::add_to_ref $name $idps
   ::bdi_gui_cdl::calcule_tout

}


#----------------------------------------------------------------------------
## Definit un objet reference dans la tables des objets rejetes
#  \return void
#
proc ::bdi_gui_cdl::set_to_reference_data_rejected { } {

   foreach select [$::bdi_gui_cdl::data_rejected curselection] {
      incr ::bdi_tools_cdl::nbref
      incr ::bdi_tools_cdl::nbrej -1
      set idps [lindex [$::bdi_gui_cdl::data_rejected get $select] 0]
      set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 1
   }
   ::bdi_tools_cdl::add_to_ref $name $idps
   ::bdi_gui_cdl::calcule_tout
}


#----------------------------------------------------------------------------
## Definit un objet science dans la tables des objets rejetes
#  \return void
#
proc ::bdi_gui_cdl::set_to_science_data_rejected { } {

   foreach select [$::bdi_gui_cdl::data_rejected curselection] {
      incr ::bdi_tools_cdl::nbscience
      incr ::bdi_tools_cdl::nbrej -1
      set name [lindex [$::bdi_gui_cdl::data_rejected get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 2
   }
   ::bdi_gui_cdl::calcule_tout
}


#----------------------------------------------------------------------------
## Rejete une source dans la table des objets references
#  \return void
#
proc ::bdi_gui_cdl::unset_data_reference { } {

   set toremove {}
   foreach select [$::bdi_gui_cdl::data_reference curselection] {
      incr ::bdi_tools_cdl::nbrej
      incr ::bdi_tools_cdl::nbref -1
      set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 0
      lappend toremove $name
   }

   ::bdi_gui_cdl::calcule_tout

   # Re-affichage de la table des data des sources si elle existe
   set err [catch {winfo exists $::bdi_gui_cdl::fentable} status]
   if {$status == 1} {
      foreach n $toremove {
         ::bdi_gui_cdl::lremove ::bdi_gui_cdl::selectedTableList $n
      }
      ::bdi_gui_cdl::table_popup_view
   }

}


#----------------------------------------------------------------------------
## Rejete une source dans la table des objets sciences
#  \return void
#
proc ::bdi_gui_cdl::unset_data_science { } {

   set toremove {}
   foreach select [$::bdi_gui_cdl::data_science curselection] {
      incr ::bdi_tools_cdl::nbrej
      incr ::bdi_tools_cdl::nbscience -1
      set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 0
      lappend toremove $name

      # RAZ du resultat Famous
      if {[info exists ::bdi_gui_cdl::widget(famous,stats,$name,residuals_std)]} {
         unset ::bdi_gui_cdl::widget(famous,stats,$name,residuals_std)
      }

   }

   ::bdi_gui_cdl::calcule_tout

   # Re-affichage de la table des data des sources si elle existe
   set err [catch {winfo exists $::bdi_gui_cdl::fentable} status]
   if {$status == 1} {
      foreach n $toremove {
         ::bdi_gui_cdl::lremove ::bdi_gui_cdl::selectedTableList $n
      }
      ::bdi_gui_cdl::table_popup_view
   }

}


#----------------------------------------------------------------------------
## Rejete une source dans la table des types spectraux
#  \return void
#
proc ::bdi_gui_cdl::unset_classif { } {

   foreach select [$::bdi_gui_cdl::classif curselection] {
      incr ::bdi_tools_cdl::nbrej
      incr ::bdi_tools_cdl::nbref -1
      set name [lindex [$::bdi_gui_cdl::classif get $select] 1]
      set ::bdi_tools_cdl::table_noms($name) 0
   }
   ::bdi_gui_cdl::calcule_tout

}


#----------------------------------------------------------------------------
## Rejete une source dans la table des variations
#  \return void
#
proc ::bdi_gui_cdl::unset_starstar { tbl } {

   foreach select [$tbl curselection] {
      incr ::bdi_tools_cdl::nbrej
      incr ::bdi_tools_cdl::nbref -1
      set ids [lindex [$tbl get $select] 0]
      set name $::bdi_tools_cdl::id_to_name($ids)
      set ::bdi_tools_cdl::table_noms($name) 0
   }
   ::bdi_gui_cdl::calcule_tout

}


#----------------------------------------------------------------------------
## Enregistre les images et cata en affichant une barre de pregression
# et un bouton d'annulation du traitement
#  \return void
#
proc ::bdi_gui_cdl::save_image_cata {  } {

#      $::bdi_gui_astrometry::fen.appli.info.fermer configure -state disabled
#      $::bdi_gui_astrometry::fen.appli.info.enregistrer configure -state disabled

   set tt0 [clock clicks -milliseconds]

   set ::bdi_tools_cdl::savprogress 0
   set ::bdi_tools_cdl::savannul 0

   set ::bdi_gui_cdl::fensav .savprogress
   if { [winfo exists $::bdi_gui_cdl::fensav] } {
      wm withdraw $::bdi_gui_cdl::fensav
      wm deiconify $::bdi_gui_cdl::fensav
      focus $::bdi_gui_cdl::fensav
      return
   }

   toplevel $::bdi_gui_cdl::fensav -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fensav ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fensav ] "+" ] 2 ]
   wm geometry $::bdi_gui_cdl::fensav +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_cdl::fensav 1 1
   wm title $::bdi_gui_cdl::fensav "Enregistrement"
   wm protocol $::bdi_gui_cdl::fensav WM_DELETE_WINDOW ""

   set frm $::bdi_gui_cdl::fensav.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cdl::fensav -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          set    pf [ ttk::progressbar $data.p -variable ::bdi_tools_cdl::savprogress -orient horizontal -length 200 -mode determinate]
          pack   $pf -in $data -side top

      set data  [frame $frm.boutons -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          button $data.annul -state active -text "Annuler" -relief "raised" \
             -command "::bdi_gui_cdl::annul_save_images"
          pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

   update
   ::bdi_tools_cdl::save_images

   # on met a jour les table de la gui de gestion
   for {set ::tools_cata::id_current_image 1} {$::tools_cata::id_current_image <= $::tools_cata::nb_img_list} { incr ::tools_cata::id_current_image } {
      set ::tools_cata::current_listsources $::bdi_gui_cata::cata_list($::tools_cata::id_current_image)
      ::tools_cata::current_listsources_to_tklist
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,tklist)          [array get ::bdi_gui_cata::tklist]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,list_of_columns) [array get ::bdi_gui_cata::tklist_list_of_columns]
      set ::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)        [array get ::bdi_gui_cata::cataname]
   }

   # On reaffiche gestion
   ::bdi_gui_cata_gestion::charge_image_directaccess

   destroy $::bdi_gui_cdl::fensav

#      $::bdi_gui_cdl::fen.appli.info.fermer configure -state normal
#      $::bdi_gui_cdl::fen.appli.info.enregistrer configure -state normal
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Sauvegarde des images et cata en $tt sec \n"
   set res [tk_messageBox -message "Sauvegarde des images et cata en $tt sec \nVoulez vous quitter l'outil photometrie ?" -type yesno]
   if {$res=="no"} {return}
   ::bdi_gui_cdl::fermer
   
}


#----------------------------------------------------------------------------
## Annule l'enregistrement en cours, des images et cata
#  \return void
#
proc ::bdi_gui_cdl::annul_save_images { } {

   $::bdi_gui_cdl::fensav.appli.boutons.annul configure -state disabled
   set ::bdi_tools_cdl::savannul 1

}


#----------------------------------------------------------------------------
## Enregistre les resultats sous forme de rapport Texte et XML/VOTABLE
#  \return void
#
proc ::bdi_gui_cdl::save_reports {  } {

   ::bdi_tools_cdl::closetoconf

   ::bdi_tools_cdl::save_reports

   set err [ catch {  } msg]
   if {$err} {
      tk_messageBox -message "Erreur : $msg" -type ok
   }
}


#----------------------------------------------------------------------------
## Affichage du graphe de la constante des magnitudes
#  \return void
#
proc ::bdi_gui_cdl::graph_const_mag {  } {

   set err [catch {::plotxy::getgeometry $::bdi_gui_cdl::figConst} pfig]
   if {$err == 1} {
      set pfig {0 0 600 400}
   }

   ::plotxy::clf $::bdi_gui_cdl::figConst
   ::plotxy::figure $::bdi_gui_cdl::figConst
   ::plotxy::hold on
   ::plotxy::position $pfig
   ::plotxy::title "Constantes des magnitudes au cours du temps"
   ::plotxy::xlabel "Time (jd)"
   ::plotxy::ylabel "Mag"

   array unset x
   array unset y
   set pass "no"
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

      if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
      set pass "yes"
      set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)
      foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {

         set name  $::bdi_tools_cdl::id_to_name($ids)
         set mag   [lindex $::bdi_tools_cdl::table_data_source($name) 4]
         set flux  $::bdi_tools_cdl::table_star_flux($name,$idcata,flux)

         set magss [expr $mag -2.5 * log10(1.0 * $::bdi_tools_cdl::table_superstar_flux($id_superstar,$idcata) / $flux) ]

         lappend x($id_superstar) $::bdi_tools_cdl::idcata_to_jdc($idcata)
         lappend y($id_superstar) $magss

      }
   }

   if {$pass=="no"} {
      tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
      return
   }

   set color [list black blue red green yellow grey ]
   set cpt 0
   foreach {indice_superstar id_superstar} [array get ::bdi_tools_cdl::table_superstar_exist] {
      #gren_info "id_superstar $id_superstar mag = $::bdi_tools_cdl::table_superstar_solu($id_superstar,mag) stdev = $::bdi_tools_cdl::table_superstar_solu($id_superstar,stdevmag) \n"
      set h [::plotxy::plot $x($id_superstar) $y($id_superstar) .]
      plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 0]
      incr cpt
      if { $cpt >= [llength $color] } {
         set cpt 0
      }
   }

   set ::bdi_gui_cdl::currentFig $::bdi_gui_cdl::figConst
   return
}


#----------------------------------------------------------------------------
## Affichage du graphe qui presente la magnitude des etoiles de reference
# au cours du temps
#  \return void
#
proc ::bdi_gui_cdl::graph_stars_mag {  } {

   set err [catch {::plotxy::getgeometry $::bdi_gui_cdl::figStars} pfig]
   if {$err == 1} {
      set pfig {0 0 600 400}
   }

   ::plotxy::clf $::bdi_gui_cdl::figStars
   ::plotxy::figure $::bdi_gui_cdl::figStars
   ::plotxy::hold on
   ::plotxy::position $pfig
   ::plotxy::title "Magnitude des etoiles de reference au cours du temps"
   ::plotxy::xlabel "Time (jd)"
   ::plotxy::ylabel "Mag"

   array unset x
   array unset y
   array unset list_star
   set pass "no"

   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

      if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
      set pass "yes"
      set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)

      foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
         lappend x($ids) $::bdi_tools_cdl::idcata_to_jdc($idcata)
         lappend y($ids) $::bdi_tools_cdl::table_star_mag($ids,$idcata)
         set list_star($ids) 1
      }
   }

   if {$pass=="no"} {
      tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
      return
   }

   set color [list black blue red green yellow grey ]
   set cpt 0
   foreach { ids o } [array get list_star] {
      set h [::plotxy::plot $x($ids) $y($ids) .]
      plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 1]
      incr cpt
      if { $cpt >= [llength $color] } {
         set cpt 0
      }
   }

   set ::bdi_gui_cdl::currentFig $::bdi_gui_cdl::figStars
   return
}



#----------------------------------------------------------------------------
## Affichage du graphe Timeline
# ce graphe represente la presence au cours du temps des etoiles de reference
#  \return void
#
proc ::bdi_gui_cdl::graph_timeline { } {

   set err [catch {::plotxy::getgeometry $::bdi_gui_cdl::figTimeline} pfig]
   if {$err == 1} {
      set pfig {0 0 600 400}
   }

   ::plotxy::clf $::bdi_gui_cdl::figTimeline
   ::plotxy::figure $::bdi_gui_cdl::figTimeline
   ::plotxy::hold on
   ::plotxy::position $pfig
   ::plotxy::title "Timeline"
   ::plotxy::xlabel "Time"
   ::plotxy::ylabel "Id Stars"

   array unset x
   array unset y
   array unset list_star
   set pass "no"

   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

      if {![info exists ::bdi_tools_cdl::table_superstar_idcata($idcata)]} {continue}
      set pass "yes"
      set id_superstar $::bdi_tools_cdl::table_superstar_idcata($idcata)

      foreach ids $::bdi_tools_cdl::table_superstar_id($id_superstar) {
         lappend x($ids) $::bdi_tools_cdl::idcata_to_jdc($idcata)
         lappend y($ids) $ids
         set list_star($ids) 1
      }
   }

   if {$pass=="no"} {
      tk_messageBox -message "Veuillez ajouter des sources de references" -type ok
      return
   }

   set color [list black blue red green yellow grey ]
   set cpt 0
   foreach { ids o } [array get list_star] {
      set h [::plotxy::plot $x($ids) $y($ids) o]
      plotxy::sethandler $h [list -color [lindex $color $cpt] -linewidth 0]
      incr cpt
      if { $cpt >= [llength $color] } {
         set cpt 0
      }
   }

   set ::bdi_gui_cdl::currentFig $::bdi_gui_cdl::figTimeline
   return

}


#----------------------------------------------------------------------------
## Affiche un graphe representant les magnitudes differentielles des objets
#  sciences. Les moyennes des magnitudes sont les magnitudes absolues
#-
proc ::bdi_gui_cdl::graph_science_mag_popup {  } {

   set ::bdi_gui_cdl::graph_science ""
   foreach select [$::bdi_gui_cdl::data_science curselection] {
      set ids [lindex [$::bdi_gui_cdl::data_science get $select] 0]
      set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
      lappend ::bdi_gui_cdl::graph_science [list $ids $name]
   }

   ::bdi_gui_cdl::graph_science_mag_popup_exec

}



proc ::bdi_gui_cdl::graph_science_mag_popup_exec {  } {

   set err [catch {::plotxy::getgeometry $::bdi_gui_cdl::figScimag} pfig]
   if {$err == 1} {
      set pfig {0 0 600 400}
   }

   #set num $plotxy(currentfigure)
   #set baseplotxy $plotxy(fig$num,parent)
   #destroy $baseplotxy

   ::plotxy::clf $::bdi_gui_cdl::figScimag
   ::plotxy::figure $::bdi_gui_cdl::figScimag
   ::plotxy::hold on
   ::plotxy::position $pfig
   ::plotxy::title "Courbe de lumiere des objets sciences\n Magnitudes absolues"
   ::plotxy::xlabel "Time (jd)"
   ::plotxy::ylabel "Mag"
   ::plotxy::ydir reverse

   array unset x
   array unset y
   set colors [list blue red green yellow grey black ]
   set cpt 0
   foreach select $::bdi_gui_cdl::graph_science {
      set ids   [lindex $select 0]
      set name  [lindex $select 1]
      set color [lindex $colors $cpt]
      incr cpt
      if { $cpt >= [llength $colors] } {
         set cpt 0
      }

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         lappend x($ids)  $::bdi_tools_cdl::idcata_to_jdc($idcata)
         lappend y($ids)  $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)]} {
            lappend by($ids) 0
         } else {
            lappend by($ids) $::bdi_tools_cdl::table_science_mag($ids,$idcata,err_mag)
         }
      }

      catch { 
         set h [::plotxy::plot $x($ids) $y($ids) ro. 1.5 [list -ybars $by($ids)] ]
         plotxy::sethandler $h [list -color $color -linewidth 0]
      }
   }

   set ::bdi_gui_cdl::currentFig $::bdi_gui_cdl::figScimag

}



#----------------------------------------------------------------------------
## Affiche un graphe representant les magnitudes differentielles des objets
#  sciences. Les moyennes des magnitudes sont centrees sur zero
#
proc ::bdi_gui_cdl::graph_science_mag {  } {

   set err [catch {::plotxy::getgeometry $::bdi_gui_cdl::figScimag} pfig]
   if {$err == 1} {
      set pfig {0 0 600 400}
   }

   ::plotxy::clf $::bdi_gui_cdl::figScimag
   ::plotxy::figure $::bdi_gui_cdl::figScimag
   ::plotxy::hold on
   ::plotxy::position $pfig
   ::plotxy::title "Courbe de lumiere des objets sciences\n Magnitudes centrees sur zero"
   ::plotxy::xlabel "Time (jd)"
   ::plotxy::ylabel "Diff Mag"
   ::plotxy::ydir reverse

   array unset x
   array unset y
   set colors [list blue red green yellow grey black ]
   set cpt 0


   set ids 0
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$o != 2} {continue}

      set color [lindex $colors $cpt]
      gren_info "Graph $name color : $color\n"
      incr cpt
      if { $cpt >= [llength $colors] } {
         set cpt 0
      }

      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         lappend x($ids)  $::bdi_tools_cdl::idcata_to_jdc($idcata)
         lappend y($ids)  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]
      }
      set h [::plotxy::plot $x($ids) $y($ids) .]
      plotxy::sethandler $h [list -color $color -linewidth 0]

   }

   set ::bdi_gui_cdl::currentFig $::bdi_gui_cdl::figScimag

}


#----------------------------------------------------------------------------
## Supprime partiellement un point de mesure et le rejete pour le rapport
#  Mais les points supprimes ne le sont pas dans les fichiers cata
#
proc ::bdi_gui_cdl::unset_science_in_graph {  } {

   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 0 } {
      gren_erreur "Pas de graphe actif des objets sciences\n"
      return
   }
   ::plotxy::figure $::bdi_gui_cdl::figScimag

   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err} {
      return
   }
   set x1 [lindex $rect 0]
   set x2 [lindex $rect 2]
   set y1 [lindex $rect 1]
   set y2 [lindex $rect 3]

   if {$x1>$x2} {
      set t $x1
      set x1 $x2
      set x2 $t
   }
   if {$y1>$y2} {
      set t $y1
      set y1 $y2
      set y2 $t
   }

#      gren_info "Crop Zone = $x1 : $x2 / $y1 : $y2\n"

   set ids 0
   foreach {name o} [array get ::bdi_tools_cdl::table_noms] {
      incr ids
      if {$o != 2} {continue}
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {
         if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}
         set x  $::bdi_tools_cdl::idcata_to_jdc($idcata)
         set y  [expr $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) - [lindex $::bdi_tools_cdl::table_data_source($name) 4] ]

         if {$x >= $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            unset ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
            gren_info "Suppression idcata = $idcata, midepoch = [mc_date2iso8601 $::bdi_tools_cdl::table_jdmidexpo($idcata)] name=$name \n"
         }
      }

   }

   ::bdi_gui_cdl::graph_science_mag
}




#----------------------------------------------------------------------------
## Affiche une fenetre representant les donnees des sources selectionnees
#  sur l'ensemble des images
#
proc ::bdi_gui_cdl::table_popup { onglet } {

   set ::bdi_gui_cdl::selectedTableList {}
   set ::bdi_gui_cdl::widget(table,onglet) $onglet

   if {$onglet == "sci" } {
      if {[llength [$::bdi_gui_cdl::data_science curselection]] < 1} {
         tk_messageBox -message "Veuillez selectionner au moins 1 source" -type ok
         return
      }
      if {[llength [$::bdi_gui_cdl::data_science curselection]] > 1} {
         tk_messageBox -message "Veuillez selectionner 1 seule source" -type ok
         return
      }
      foreach select [$::bdi_gui_cdl::data_science curselection] {
         set id   [lindex [$::bdi_gui_cdl::data_science get $select] 0]
         set name [lindex [$::bdi_gui_cdl::data_science get $select] 1]
         lappend ::bdi_gui_cdl::selectedTableList [list $id $name]
      }
   }

   if {$onglet == "ref" } {
      if {[llength [$::bdi_gui_cdl::data_reference curselection]] < 1} {
         tk_messageBox -message "Veuillez selectionner au moins 1 source" -type ok
         return
      }
      foreach select [$::bdi_gui_cdl::data_reference curselection] {
         set id   [lindex [$::bdi_gui_cdl::data_reference get $select] 0]
         set name [lindex [$::bdi_gui_cdl::data_reference get $select] 1]
         lappend ::bdi_gui_cdl::selectedTableList [list $id $name]
      }
   }

   set ::bdi_gui_cdl::fentable .photometry_table
   if { [winfo exists $::bdi_gui_cdl::fentable] } {
      set geom [winfo geometry $::bdi_gui_cdl::fentable]
      destroy $::bdi_gui_cdl::fentable
   }
   toplevel $::bdi_gui_cdl::fentable -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fentable ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cdl::fentable ] "+" ] 2 ]
   
   if {[info exists geom]} {
      wm geometry $::bdi_gui_cdl::fentable $geom
   } else {
      #wm geometry $::bdi_gui_cdl::fentable 1000x600+[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm geometry $::bdi_gui_cdl::fentable 1000x600+602+427
   }
   wm resizable $::bdi_gui_cdl::fentable 1 1
   if {[llength $::bdi_gui_cdl::selectedTableList] > 1} {
      set title "Table of [llength $::bdi_gui_cdl::selectedTableList] selected $onglet objects"
   } else {
      set title "Table of $onglet [lindex [lindex $::bdi_gui_cdl::selectedTableList 0] 1]"
   }
   wm title $::bdi_gui_cdl::fentable $title
   wm protocol $::bdi_gui_cdl::fentable WM_DELETE_WINDOW "destroy $::bdi_gui_cdl::fentable"

   set frm $::bdi_gui_cdl::fentable.appli
   #--- Cree un frame general
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cdl::fentable -anchor s -side top -expand yes -fill both -padx 10 -pady 5

   set cols [list 0 "id"         left  \
                  0 "name"       left  \
                  0 "ids"        left  \
                  0 "idcata"     left  \
                  0 "date-obs"   left  \
                  0 "flux"       right \
                  0 "err_flux"   right \
                  0 "mag"        right \
                  0 "err_mag"    right \
                  0 "pixmax"     right \
                  0 "sky"        right \
                  0 "snint"      right \
                  0 "fwhm"       right \
                  0 "radius"     right \
                  0 "err_psf"    right \
                  0 "psf_method" right \
                  0 "globale"    right \
                  0 "Azimuth"    right \
                  0 "Elevation"  right \
            ]

   set ::bdi_gui_cdl::data_source $frm.table
   tablelist::tablelist $::bdi_gui_cdl::data_source \
     -columns $cols \
     -labelcommand tablelist::sortByColumn \
     -xscrollcommand [ list $frm.hsb set ] \
     -yscrollcommand [ list $frm.vsb set ] \
     -selectmode extended \
     -activestyle none \
     -stripebackground "#e0e8f0" \
     -showseparators 1

   # Scrollbar
   scrollbar $frm.hsb -orient horizontal -command [list $::bdi_gui_cdl::data_source xview]
   pack $frm.hsb -in $frm -side bottom -fill x
   scrollbar $frm.vsb -orient vertical -command [list $::bdi_gui_cdl::data_source yview]
   pack $frm.vsb -in $frm -side right -fill y

   # Pack la Table
   pack $::bdi_gui_cdl::data_source -in $frm -expand yes -fill both

   # Popup
   menu $frm.popupTbl -title "Actions"

      $frm.popupTbl add command -label "(v) Voir l'objet dans l'image" \
          -command "::bdi_gui_cdl::table_voir"
      $frm.popupTbl add command -label "(s) Selection par le graphe" \
          -command "::bdi_gui_cdl::table_select_from_graph"
      $frm.popupTbl add command -label "Mesurer Manuel" \
          -command "::bdi_gui_cdl::table_mesure_manuel"
      $frm.popupTbl add command -label "Mesurer Auto" \
          -command "::bdi_gui_cdl::table_mesure_auto"
      $frm.popupTbl add command -label "(r) Rejeter" \
          -command "::bdi_gui_cdl::table_rejet"

   # Binding
   # bind $::bdi_gui_cdl::data_source <<ListboxSelect>> [ list ::bdi_gui_cdl::cmdButton1Click_data_source %W ]
   bind [$::bdi_gui_cdl::data_source bodypath] <ButtonPress-3> [ list tk_popup $frm.popupTbl %X %Y ]
   bind [$::bdi_gui_cdl::data_source bodypath] <Key-v> [ list ::bdi_gui_cdl::table_voir ]
   bind [$::bdi_gui_cdl::data_source bodypath] <Key-s> [ list ::bdi_gui_cdl::table_select_from_graph ]
   bind [$::bdi_gui_cdl::data_source bodypath] <Key-r> "::bdi_gui_cdl::table_rejet"

   # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
   #    Ascii
   foreach ncol [list "name" "date-obs" "err_psf" "psf_method" "globale"] {
      set pcol [expr int ([lsearch $cols $ncol]/3)]
      $::bdi_gui_cdl::data_source columnconfigure $pcol -sortmode ascii
   }
   #    Reel
   foreach ncol [list "id" "ids" "idcata" "flux" "err_flux" "mag" "err_mag" "pixmax" "sky" "snint" "fwhm" "radius" ] {
      set pcol [expr int ([lsearch $cols $ncol]/3)]
      $::bdi_gui_cdl::data_source columnconfigure $pcol -sortmode real
   }

   # Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_cdl::fentable

   # Affichage de la table
   ::bdi_gui_cdl::table_popup_view 

}









   proc ::bdi_gui_cdl::uai2home { uai } {

      global conf audace
      
      set f [open [file join $audace(rep_install) gui audace catalogues obscodes.txt] r]

      set mpc [split [read $f] "\n"]
      set long [llength $mpc]
      for {set j 0} {$j <= $long} {incr j} {
         set ligne_station_mpc [lindex $mpc $j]
         if { [string compare [lindex $ligne_station_mpc 0] "000"] == "0" } {
            break
         }
      }
      set mpc [lreplace $mpc 0 [expr $j-1]]
      for {set i 0} {$i <= $long} {incr i} {
         set ligne_station_mpc [lindex $mpc $i]
         if { [string compare [lindex $ligne_station_mpc 0] $uai] == "0" } {
            set nom ""
            for {set i 4} {$i <= [ llength $ligne_station_mpc ]} {incr i} {
               set nom "$nom[lindex $ligne_station_mpc $i] "
            }
            set mpc "MPC [lindex $ligne_station_mpc 1] [lindex $ligne_station_mpc 2] [lindex $ligne_station_mpc 3]"
            set gps [mc_home2gps $mpc]
            return $gps
            break       
         }
      }
        
   }


#----------------------------------------------------------------------------
## Rempli la table des donnees des sources selectionnees sur l'ensemble des images
#
proc ::bdi_gui_cdl::table_popup_view {  } {

   # Effacement de la table
   $::bdi_gui_cdl::data_source delete 0 end
   
   set locale "no"
   if {$::bdi_tools_cdl::rapport_uai_code!=""} {
      set posobs [::bdi_gui_cdl::uai2home $::bdi_tools_cdl::rapport_uai_code]
      if {$posobs != ""} {
         set locale "yes"
      }
   }
   if {$locale=="no"} {
      gren_erreur "UAI CODE non reconnu\n"
      tk_messageBox -message "Veuillez inscrire un code UAI de l observatoire dans le header de l image : IAU_CODE=..." -type ok
      return
   }
   
   # Affichage des sources selectionnees
   foreach l $::bdi_gui_cdl::selectedTableList {
      set id   [lindex $l 0]
      set name [lindex $l 1]
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {

         if {[info exists ::bdi_tools_cdl::table_othf($name,$idcata,othf)]} {
            set othf       $::bdi_tools_cdl::table_othf($name,$idcata,othf)
            set ids        [expr $::bdi_tools_cdl::table_star_ids($name,$idcata) +1]
            set dateobs    $::bdi_tools_cdl::table_date($idcata)
            set flux       [::bdi_tools_psf::get_val othf "flux"]
            set err_flux   [::bdi_tools_psf::get_val othf "err_flux"]
            #set mag        [::bdi_tools_psf::get_val othf "mag"]
            #set err_mag    [::bdi_tools_psf::get_val othf "err_mag"]
            set pixmax     [::bdi_tools_psf::get_val othf "pixmax"]
            set sky        [::bdi_tools_psf::get_val othf "sky"]
            set snint      [::bdi_tools_psf::get_val othf "snint"]
            set fwhm       [::bdi_tools_psf::get_val othf "fwhm"]
            set radius     [::bdi_tools_psf::get_val othf "radius"]
            set err_psf    [::bdi_tools_psf::get_val othf "err_psf"]
            set psf_method [::bdi_tools_psf::get_val othf "psf_method"]
            set globale    [::bdi_tools_psf::get_val othf "globale"]
            
            if {$locale=="yes"} {
               set ra         [::bdi_tools_psf::get_val othf "ra"]
               set dec        [::bdi_tools_psf::get_val othf "dec"]
               set err [catch { set x [mc_radec2altaz $ra $dec $posobs $dateobs] } msg ]
               if {$err==0} {
                  lassign $x elev azim
                  set elev [format "%.0f" $elev]
                  set azim [format "%.0f" $azim]
               } else {
                  set elev -1
                  set azim -1
               }
            }
  

            
            if {$::bdi_gui_cdl::widget(table,onglet) == "sci"} {
               if {![info exists ::bdi_tools_cdl::table_science_mag($id,$idcata,mag)]} {
                  set mag -1
               } else {
                  set mag        $::bdi_tools_cdl::table_science_mag($id,$idcata,mag)
               }
               if {![info exists ::bdi_tools_cdl::table_science_mag($id,$idcata,err_mag)]} {
                  set err_mag -1
               } else {
                  set err_mag    $::bdi_tools_cdl::table_science_mag($id,$idcata,err_mag)
               }
            }
            if {$::bdi_gui_cdl::widget(table,onglet) == "ref"} {
               set mag     [::bdi_tools_psf::get_val othf "mag"]
               set err_mag [::bdi_tools_psf::get_val othf "err_mag"]
            }
            #gren_erreur "id, ids, idcata = $id, $ids, $idcata, ($mag) $::bdi_tools_cdl::table_science_mag($id,$idcata,mag)\n"

            if {![string is double $flux]||$flux==""} {
               set flux -1
            }
            if {![string is double $err_flux]||$err_flux==""} {
               set err_flux -1
            }
            if {![string is double $mag]||$mag==""||$mag==-1} {
               set mag -1
            } else {
               set mag [format "%0.4f" $mag]
            }
            if {![string is double $err_mag]||$err_mag==""||$err_mag==-1} {
               set err_mag -1
            } else {
               set err_mag [format "%0.4f" $err_mag]
            }
            if {![string is double $pixmax]||$pixmax==""} {
               set pixmax -1
            }
            if {![string is double $sky]||$sky==""} {
               set sky -1
            }
            if {![string is double $snint]||$snint==""} {
               set snint -1
            }
            if {![string is double $fwhm]||$fwhm==""} {
               set fwhm -1
            }
            if {![string is double $radius]||$radius==""} {
               set radius -1
            }

            $::bdi_gui_cdl::data_source insert end [list $id $name $ids $idcata $dateobs $flux \
                $err_flux $mag $err_mag $pixmax $sky $snint $fwhm $radius $err_psf $psf_method $globale $elev $azim]
         }
      }
   }
}


#----------------------------------------------------------------------------
## Affiche un rond dans l'image de la source a la date selectionnee
#
proc ::bdi_gui_cdl::table_voir {  } {

   set color red
   set width 2

   if {[llength [$::bdi_gui_cdl::data_source curselection]]!=1} {
      tk_messageBox -message "Veuillez selectionner 1 date" -type ok
      return
   }
   set select [$::bdi_gui_cdl::data_source curselection]
   set ids [lindex [$::bdi_gui_cdl::data_source get $select] 2]
   set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 3]

   set ::bdi_gui_cata_gestion::directaccess $idcata
   ::bdi_gui_cata_gestion::charge_image_directaccess
   set ids [expr $ids -1]
   set s [lindex  $::tools_cata::current_listsources 1 $ids]
   set xy [::bdi_tools_psf::get_xy s]
   set radec [buf$::audace(bufNo) xy2radec [list [lindex $xy 0] [lindex $xy 1] ]]

   cleanmark
   affich_un_rond [lindex $radec 0] [lindex $radec 1] $color $width

}
#----------------------------------------------------------------------------
## selectionne dans la table les lignes qui ont ete selectionnee dans le graphe
#
proc ::bdi_gui_cdl::table_select_from_graph { } {

   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 0 } {
      gren_erreur "Pas de graphe actif des objets sciences\n"
      return
   }
   ::plotxy::figure $::bdi_gui_cdl::figScimag

   #if {[llength [$::bdi_gui_cdl::data_source curselection]]!=1} {
   #   tk_messageBox -message "Veuillez selectionner 1 date" -type ok
   #   return
   #}
   #set select [$::bdi_gui_cdl::data_source curselection]
   set name [lindex [$::bdi_gui_cdl::data_source get 0] 1]

   set err [ catch {set rect [::plotxy::get_selected_region]} msg]
   if {$err} {
      return
   }

   set x1 [lindex $rect 0]
   set x2 [lindex $rect 2]
   set y1 [lindex $rect 1]
   set y2 [lindex $rect 3]

   if {$x1>$x2} {
      set t $x1
      set x1 $x2
      set x2 $t
   }
   if {$y1>$y2} {
      set t $y1
      set y1 $y2
      set y2 $t
   }

   gren_erreur "Object = $name\n"
   gren_info "rect = $rect\n"
   set ids $::bdi_tools_cdl::name_to_id($name)
   gren_info "ids = $ids\n"

   # Transfert de $ids et $idcata vers idrow de la table popup
   array unset transfert
   set l [$::bdi_gui_cdl::data_source get 0 end]
   set select -1
   foreach x $l {
      incr select
      set idcata [lindex $x 3]
      gren_info "transfert($idcata) = $select\n"
      set transfert($idcata) $select
   }

   $::bdi_gui_cdl::data_source selection clear 0 end

   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} { incr idcata } {

      if {![info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)]} {continue}

      #gren_info "[info exists ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)] set ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag) \n"

      set x  $::bdi_tools_cdl::idcata_to_jdc($idcata)
      #gren_info "$::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)\n"
      #gren_info "[lindex $::bdi_tools_cdl::table_data_source($name) 4]\n"
      set y  $::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)

      if {$x >= $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
         #unset ::bdi_tools_cdl::table_science_mag($ids,$idcata,mag)
         gren_info "Visu idcata = $idcata, midepoch = [mc_date2iso8601 $::bdi_tools_cdl::table_jdmidexpo($idcata)] name=$name \n"
         $::bdi_gui_cdl::data_source selection set $transfert($idcata)
         $::bdi_gui_cdl::data_source see $transfert($idcata)
      }

   }

}

#----------------------------------------------------------------------------
## Effectue une mesure de photocentre manuelle sur la source
# aux dates/images selectionnees
#
proc ::bdi_gui_cdl::table_mesure_manuel {  } {

   foreach select [$::bdi_gui_cdl::data_source curselection] {
      set ids [lindex [$::bdi_gui_cdl::data_source get $select] 2]
      set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 3]
      lappend worklist [list $idcata $ids]
   }
   set ::bdi_gui_gestion_source::variable_cloture 1

   ::bdi_gui_gestion_source::run $worklist

   vwait ::bdi_gui_gestion_source::variable_cloture
   
   # Sauve la selection ref/science
   set table_noms_sav [array get ::bdi_tools_cdl::table_noms]

   ::bdi_tools_cdl::charge_from_gestion

   # Recupere la selection ref/science
   array set ::bdi_tools_cdl::table_noms $table_noms_sav

   ::bdi_gui_cdl::calcule_tout
   if {[winfo exists $::bdi_gui_cdl::fentable]} {
      ::bdi_gui_cdl::table_popup_view
   }
}

#----------------------------------------------------------------------------
## Effectue une mesure de photocentre automatique sur la source
# aux dates/images selectionnees
#
proc ::bdi_gui_cdl::table_mesure_auto {  } {

   global bddconf

   set ::bdi_gui_cata_gestion::variable_cloture 1

   ::bdi_gui_cata_gestion::psf_auto "popup_photom_table"

   vwait ::bdi_gui_cata_gestion::variable_cloture

   # sauvegarde les fichiers dans la base
   foreach id_current_image $::bdi_gui_cata_gestion::worklist(list_id) {
      set current_image [lindex $::tools_cata::img_list $id_current_image]
      # Tabkey
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      # Liste des sources
      set listsources $::bdi_gui_cata::cata_list($id_current_image)
      # Noms du fichier cata
      set imgfilename [::bddimages_liste::lget $current_image filename]
      set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      ::tools_cata::save_cata $listsources $tabkey $cataxml

   }

   # Sauve la selection ref/science
   set table_noms_sav [array get ::bdi_tools_cdl::table_noms]

   ::bdi_tools_cdl::charge_from_gestion

   # Recupere la selection ref/science
   array set ::bdi_tools_cdl::table_noms $table_noms_sav

   ::bdi_gui_cdl::calcule_tout

   if {[winfo exists $::bdi_gui_cdl::fentable]} {
      ::bdi_gui_cdl::table_popup_view
   }
}

#----------------------------------------------------------------------------
## supprime le flag de la source
# aux dates/images selectionnees
#
proc ::bdi_gui_cdl::table_rejet { } {

   # Rejette les sources selectionnees
   foreach select [$::bdi_gui_cdl::data_source curselection] {

      set name [lindex [$::bdi_gui_cdl::data_source get $select] 1]
      set ids [lindex [$::bdi_gui_cdl::data_source get $select] 2]
      set idcata [lindex [$::bdi_gui_cdl::data_source get $select] 3]

      # effacement de la memoire
      unset ::bdi_tools_cdl::table_othf($name,$idcata,othf)

      # effacement dans le catalist
      set listsource $::bdi_gui_cata::cata_list($idcata)
      set fields  [lindex $listsource 0]
      set sources [lindex $listsource 1]
      set s [lindex $sources [expr $ids -1] ]
      ::manage_source::delete_catalog_in_source s "ASTROID"
      set sources [lreplace  $sources [expr $ids -1] [expr $ids -1] $s]
      set ::bdi_gui_cata::cata_list($idcata) [list $fields $sources]
   }

   # Recalcul des data
   ::bdi_gui_cdl::calcule_tout

   # Re-affichage de la table
   if {[winfo exists $::bdi_gui_cdl::fentable]} {
      ::bdi_gui_cdl::table_popup_view
   }

}



proc ::bdi_gui_cdl::vignette_binding { } {
   
   global plotxy

   set frm_list ""
   set frm ""

   if {[::plotxy::exists $::bdi_gui_cdl::figscifamous] == 1 } {
      ::plotxy::figure $::bdi_gui_cdl::figscifamous
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      set frm $baseplotxy
      gren_info "*** BINDING : $frm\n"
      bind $frm  <Left>       "::bdi_gui_cdl::vignette_left"  
      bind $frm  <Right>      "::bdi_gui_cdl::vignette_right"
      bind $frm  <MouseWheel> "::bdi_gui_cdl::vignette_mouse %W %D"
      bind $frm  <s>          "::bdi_gui_cdl::vignette_select"
      bind $frm  <d>          "::bdi_gui_cdl::vignette_delete"
      bind $frm  <l>          "::bdi_gui_cdl::vignette_log"
   }
   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 1 } {
      ::plotxy::figure $::bdi_gui_cdl::figScimag
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      set frm $baseplotxy
      gren_info "*** BINDING : $frm\n"
      bind $frm  <Left>       "::bdi_gui_cdl::vignette_left"  
      bind $frm  <Right>      "::bdi_gui_cdl::vignette_right"
      bind $frm  <MouseWheel> "::bdi_gui_cdl::vignette_mouse %W %D"
      bind $frm  <s>          "::bdi_gui_cdl::vignette_select"
      bind $frm  <d>          "::bdi_gui_cdl::vignette_delete"
      bind $frm  <l>          "::bdi_gui_cdl::vignette_log"
   } 

   #set frm $::bdi_gui_cdl::widget(vignette,scale)
   #gren_info "*** BINDING : $frm\n"
   #bind $frm  <Left>       "::bdi_gui_cdl::vignette_left"  
   #bind $frm  <Right>      "::bdi_gui_cdl::vignette_right"
   #bind $frm  <MouseWheel> "::bdi_gui_cdl::vignette_mouse %W %D"
   #bind $frm  <s>          "::bdi_gui_cdl::vignette_select"
   #bind $frm  <d>          "::bdi_gui_cdl::vignette_delete"
   #
   #set frm $::bdi_gui_cdl::fen.appli.onglets.nb.f_vign.frm
   #gren_info "*** BINDING : $frm\n"
   #bind $frm  <Left>       "::bdi_gui_cdl::vignette_left"  
   #bind $frm  <Right>      "::bdi_gui_cdl::vignette_right"
   #bind $frm  <MouseWheel> "::bdi_gui_cdl::vignette_mouse %W %D"
   #bind $frm  <s>          "::bdi_gui_cdl::vignette_select"
   #bind $frm  <d>          "::bdi_gui_cdl::vignette_delete"
   #
   #set frm $::bdi_gui_cdl::fen.appli.onglets.nb.f_famous.frm
   #gren_info "*** BINDING : $frm\n"
   #bind $frm  <Left>       "::bdi_gui_cdl::vignette_left"  
   #bind $frm  <Right>      "::bdi_gui_cdl::vignette_right"
   #bind $frm  <MouseWheel> "::bdi_gui_cdl::vignette_mouse %W %D"
   #bind $frm  <s>          "::bdi_gui_cdl::vignette_select"
   #bind $frm  <d>          "::bdi_gui_cdl::vignette_delete"
   
}






proc ::bdi_gui_cdl::vignette_suppression_finale { } {
   
   global plotxy
   

   # RAZ du resultat Famous
   if {[info exists ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std)]} {
      unset ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std)
   }

   #set res [tk_messageBox -message "Etes vous sur de vouloir effacer ces points ?" -type yesno]
   #if {$res=="no"} {return}
   $::bdi_gui_cdl::data_source selection clear 0 end

   for {set i 0} {$i<$::bdi_gui_cdl::widget(vignette,nbimg)} {incr i} {
      if {$i in $::bdi_gui_cdl::widget(vignette,select)} {
         $::bdi_gui_cdl::data_source selection set $i $i
         $::bdi_gui_cdl::data_source see $i
         
      }
   }
   ::bdi_gui_cdl::table_rejet
   
   $::bdi_gui_cdl::widget(vignette,photo) blank

   if {[::plotxy::exists $::bdi_gui_cdl::figscifamous] == 1 } {
      ::plotxy::clf $::bdi_gui_cdl::figscifamous
   }
   
   # Re affichage du graphe
   set i 0
   foreach l [$::bdi_gui_cdl::data_science get 0 end] {
      set name [lindex $l 1]
      if {$name == $::bdi_gui_cdl::widget(objsel,combo,value)} {
         break
      }
      incr i
   }
   $::bdi_gui_cdl::data_science selection clear 0 end
   $::bdi_gui_cdl::data_science selection set $i $i
   $::bdi_gui_cdl::data_science see $i
   ::bdi_gui_cdl::graph_science_mag_popup      

   ::bdi_gui_cdl::vignette_selection_clear 
   
   unset ::bdi_gui_cdl::widget(vignette,nbimg)

}






proc ::bdi_gui_cdl::vignette_selection_clear { } {

   set ::bdi_gui_cdl::widget(vignette,select,nb) 0
   set ::bdi_gui_cdl::widget(vignette,select) ""
   ::bdi_gui_cdl::vignette_view_selection
   
}






proc ::bdi_gui_cdl::vignette_view_selection { } {

   global plotxy

   # selection dans le graphe des magnitudes
   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 1 } {

      # Selection du frame
      ::plotxy::figure $::bdi_gui_cdl::figScimag
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      
      #gren_info "baseplotxy = $baseplotxy"
      #gren_info "Elements = [${baseplotxy}.xy element show]"
      
      # Chargement des donnees jd, mag
      set x ""
      set y ""
      for {set i 0} {$i<$::bdi_gui_cdl::widget(vignette,nbimg)} {incr i} {
         if {$i in $::bdi_gui_cdl::widget(vignette,select)} {
            lassign $::bdi_gui_cdl::widget(vignette,values,$i) -> -> jd
            lappend x $jd
            lappend y [lindex [$::bdi_gui_cdl::data_source get $i] 7]
         }
      }

      # affichage dans le graphe
      set h_sel_0 "vignette_selection_mag"
      set err  [ catch {::plotxy::plot $x $y "" 0 "" $h_sel_0} msg ]
      if {$err!=0} {
         ::blt::vector create vx_sel_0
         ::blt::vector create vy_sel_0
         vx_sel_0 set $x
         vy_sel_0 set $y
         $baseplotxy.xy element configure $h_sel_0 -xdata vx_sel_0 -ydata vy_sel_0 -color "#1BFB03" -pixel 7 -symbol circle -linewidth 0
      } else {
         plotxy::sethandler $h_sel_0 
      }
   }

   # selection dans le graphe des magnitudes
   if {[::plotxy::exists $::bdi_gui_cdl::figscifamous] == 1 } {

      # Selection du frame
      ::plotxy::figure $::bdi_gui_cdl::figscifamous
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      
      # Chargement des donnees jd, mag
      set x ""
      set y ""
      for {set i 0} {$i<$::bdi_gui_cdl::widget(vignette,nbimg)} {incr i} {
         if {$i in $::bdi_gui_cdl::widget(vignette,select)} {
            lappend x [lindex $::bdi_gui_cdl::widget(famous,data,x)   $i]
            lappend y [lindex $::bdi_gui_cdl::widget(famous,data,res) $i]
         }
      }

      # affichage dans le graphe
      set h_sel_1 "vignette_selection_res"
      set err  [ catch {::plotxy::plot $x $y "" 0 "" $h_sel_1} msg ]
      if {$err!=0} {
         ::blt::vector create vx_sel_1
         ::blt::vector create vy_sel_1
         vx_sel_1 set $x
         vy_sel_1 set $y
         $baseplotxy.xy element configure $h_sel_1 -xdata vx_sel_1 -ydata vy_sel_1 -color "#1BFB03" -pixel 7 -symbol circle -linewidth 0
      } else {
         plotxy::sethandler $h_sel_1 
      }
   }




}


proc ::bdi_gui_cdl::vignette_log { } {

   global bddconf
   
   set filename [file join $bddconf(dirlog) tel_pos_log.csv]
   if {![file exists $filename]} {
      set f [open $filename w]
      puts $f "azim,elev"
   } else {
      set f [open $filename a+]
   }
   set azim [lindex [$::bdi_gui_cdl::data_source get $::bdi_gui_cdl::widget(vignette,idimg)] 17]
   set elev [lindex [$::bdi_gui_cdl::data_source get $::bdi_gui_cdl::widget(vignette,idimg)] 18]
   puts $f "$azim,$elev"
   gren_info "azim = $azim , elev = $elev\n"
   
   close $f
}





proc ::bdi_gui_cdl::vignette_select { } {
   gren_info "Ressource\n"
   ::bddimages::ressource
   #::console::clear
   gren_info "--------------\n"
   if {$::bdi_gui_cdl::widget(vignette,idimg) in $::bdi_gui_cdl::widget(vignette,select)} {
      gren_info "Selected\n"
   } else {
      gren_info "Add selection\n"
      lappend ::bdi_gui_cdl::widget(vignette,select) $::bdi_gui_cdl::widget(vignette,idimg)
      incr  ::bdi_gui_cdl::widget(vignette,select,nb)
   }
   ::bdi_gui_cdl::vignette_view_selection      
   
}





proc ::bdi_gui_cdl::vignette_delete { } {

   
   if {$::bdi_gui_cdl::widget(vignette,idimg) in $::bdi_gui_cdl::widget(vignette,select)} {
      set p [lsearch $::bdi_gui_cdl::widget(vignette,select) $::bdi_gui_cdl::widget(vignette,idimg)]
      set ::bdi_gui_cdl::widget(vignette,select) [lreplace $::bdi_gui_cdl::widget(vignette,select) $p $p]
      incr  ::bdi_gui_cdl::widget(vignette,select,nb) -1
   }      
   ::bdi_gui_cdl::vignette_view_selection      
}





proc ::bdi_gui_cdl::vignette_left { } {

   if {$::bdi_gui_cdl::widget(vignette,idimg) == 0} { return }
   incr ::bdi_gui_cdl::widget(vignette,idimg) -1
   ::bdi_gui_cdl::vignette_view
   
   
}





proc ::bdi_gui_cdl::vignette_right { } {

   if {$::bdi_gui_cdl::widget(vignette,idimg) == [expr $::bdi_gui_cdl::widget(vignette,nbimg)-1]} { return }
   incr ::bdi_gui_cdl::widget(vignette,idimg) 
   ::bdi_gui_cdl::vignette_view
}





proc ::bdi_gui_cdl::vignette_mouse { widget delta } {
   gren_info "mouse $widget $delta \n"
}







proc ::bdi_gui_cdl::vignette_build { } {

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
   
   $::bdi_gui_cdl::data_science selection clear 0 end
   $::bdi_gui_cdl::data_science selection set $i $i
   $::bdi_gui_cdl::data_science see $i
   
   set nb_err_psf [lindex [$::bdi_gui_cdl::data_science get $i $i] 0 6]
   if {$nb_err_psf !=0 } {
      tk_messageBox -message "La table presente $nb_err_psf erreur(s) de mesure\nCorrigez la table des donnees" -type ok
      ::bdi_gui_cdl::table_popup sci
      return
   }
   ::bdi_gui_cdl::graph_science_mag_popup

   # Table de mesure
   ::bdi_gui_cdl::table_popup sci
   $::bdi_gui_cdl::data_source  sortbycolumn 4 -increasing
   $::bdi_gui_cdl::data_source  see 0

   set ::bdi_gui_cdl::widget(vignette,nbimg) [$::bdi_gui_cdl::data_source size]
   $::bdi_gui_cdl::widget(vignette,scale) configure -to [expr $::bdi_gui_cdl::widget(vignette,nbimg)-1]

   ::bdi_gui_cdl::vignette_binding       
   set ::bdi_gui_cdl::widget(vignette,select) ""

   gren_info "Nb Cata = $::bdi_gui_cdl::widget(vignette,nbimg)\n"

   set radius 100
   set bf      [buf::create]
   set ::bdi_gui_cdl::widget(vignette,idimg) 0
   set ::bdi_gui_cdl::widget(vignette,inview) 0

   for {set i 0} {$i<$::bdi_gui_cdl::widget(vignette,nbimg)} {incr i} {
   
      set ids    [expr [lindex [$::bdi_gui_cdl::data_source get $i] 2]-1]
      set idcata [lindex [$::bdi_gui_cdl::data_source get $i] 3]
      set current_image [lindex $::tools_cata::img_list [expr $idcata - 1]]
      set listsources $::bdi_gui_cata::cata_list($idcata)
      set dirfilename [::bddimages_liste::lget $current_image dirfilename]
      set filename    [::bddimages_liste::lget $current_image filename]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]
      
      buf$bf load $file
      set s [lindex  $listsources 1 $ids]
      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]
      
      set err [ catch { 
            set x [expr int([::bdi_tools_psf::get_val othf "xsm"])]
            set y [expr int([::bdi_tools_psf::get_val othf "ysm"])]
         } msg ]
      if {$err != 0} {
         tk_messageBox -message "Erreur PSF : $msg\nCorrigez la table des donnees" -type ok
         return
      }

      set jd  $::bdi_tools_cdl::idcata_to_jdc($idcata)
      set ::bdi_gui_cdl::widget(vignette,values,$i) [list $x $y $jd $idcata]
      
      set naxis1 [lindex [buf$bf getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$bf getkwd NAXIS2] 1]
      set x1 [expr $x - $radius]
      set y1 [expr $y - $radius]
      set x2 [expr $x + $radius]
      set y2 [expr $y + $radius]
      if {$x1<1} {set x1 1}
      if {$y1<1} {set y1 1}
      if {$x2>$naxis1} {set x2 $naxis1}
      if {$y2>$naxis2} {set y2 $naxis2}

      buf$bf window [list $x1 $y1 $x2 $y2 ]
      #gren_info "VIGNETTES: $file :: $x1 $y1 $x2 $y2\n"
      set fileout [file join $bddconf(dirtmp) vig_$i.jpg]
      set stat [buf$bf stat]
      buf$bf savejpeg $fileout 75 [lindex $stat 1] [lindex $stat 0] 
      #buf$bf save $fileout -quality 75
      #gren_info "SAVE $idcata : $fileout\n"
      
      #$::bdi_gui_cdl::widget(vignette,photo) configure -format JPEG -file $fileout
      set ::bdi_gui_cdl::widget(vignette,idimg) $i
      ::bdi_gui_cdl::vignette_view


   }
   buf::delete $bf 
   set ::bdi_gui_cdl::widget(vignette,idimg) 0
   ::bdi_gui_cdl::vignette_view
   gren_info "BUILD END\n"
   
   return
}







proc ::bdi_gui_cdl::vignette_view { } {

   global bddconf
   global plotxy

   # Verification d usage
   if {![info exists ::bdi_gui_cdl::widget(vignette,inview)]} {
      set ::bdi_gui_cdl::widget(vignette,inview) 0
   }
   if {$::bdi_gui_cdl::widget(vignette,inview)==1} {return}
   if { ! [info exists ::bdi_gui_cdl::widget(vignette,idimg_sav)] } {set ::bdi_gui_cdl::widget(vignette,idimg_sav) 0}
   if { $::bdi_gui_cdl::widget(vignette,idimg_sav) == $::bdi_gui_cdl::widget(vignette,idimg)} {return}
   
   # debut de visualisation
   set ::bdi_gui_cdl::widget(vignette,inview) 1
   set ::bdi_gui_cdl::widget(vignette,idimg_sav) $::bdi_gui_cdl::widget(vignette,idimg)
   update
   #gren_info "view $::bdi_gui_cdl::widget(vignette,idimg) / $::bdi_gui_cdl::widget(vignette,nbimg)\n"

   set fileout [file join $bddconf(dirtmp) vig_$::bdi_gui_cdl::widget(vignette,idimg).jpg]
   $::bdi_gui_cdl::widget(vignette,photo) configure -format JPEG -file $fileout
   
   lassign $::bdi_gui_cdl::widget(vignette,values,$::bdi_gui_cdl::widget(vignette,idimg)) x y jd idcata
           
   set mag [lindex [$::bdi_gui_cdl::data_source get $::bdi_gui_cdl::widget(vignette,idimg)] 7]
   $::bdi_gui_cdl::data_source selection clear 0 end
   $::bdi_gui_cdl::data_source selection set $::bdi_gui_cdl::widget(vignette,idimg) $::bdi_gui_cdl::widget(vignette,idimg)
   $::bdi_gui_cdl::data_source see $::bdi_gui_cdl::widget(vignette,idimg)

   # selection dans le graphe des magnitudes
   if {[::plotxy::exists $::bdi_gui_cdl::figScimag] == 1 } {

      ::plotxy::figure $::bdi_gui_cdl::figScimag
      set num0 $plotxy(currentfigure)
      set baseplotxy0 $plotxy(fig$num0,parent)

      set x [list $jd]
      set y [list $mag]

      set h0 "vignettep"
      set err  [ catch {::plotxy::plot $x $y "" 0 "" $h0} msg ]
      if {$err!=0} {
         #gren_erreur "ERROR : $msg\n"
         ::blt::vector create vx0
         ::blt::vector create vy0
         vx0 set $x
         vy0 set $y
         $baseplotxy0.xy element configure $h0 -xdata vx0 -ydata vy0 -color "#FFA100" -pixel 15 -symbol diamond
         #gren_info "set x $x ; set y $y ; ::blt::vector create vx0 ; ::blt::vector create vy0 ; vx0 set \$x ; vy0 set \$y\n"
         #gren_info "$baseplotxy0.xy element configure $h0 -xdata vx0 -ydata vy0\n"
      } else {
         plotxy::sethandler $h0 
      }
   }

   # selection dans le graphe des residus
   if {[::plotxy::exists $::bdi_gui_cdl::figscifamous] == 1 } {

      ::plotxy::figure $::bdi_gui_cdl::figscifamous
      set num1 $plotxy(currentfigure)
      set baseplotxy1 $plotxy(fig$num1,parent)
      #gren_info "figure famous = $num1 $baseplotxy1 [winfo exists $baseplotxy1.xy]\n"

      set x [list [lindex $::bdi_gui_cdl::widget(famous,data,x) $::bdi_gui_cdl::widget(vignette,idimg)  ]]
      set y [list [lindex $::bdi_gui_cdl::widget(famous,data,res) $::bdi_gui_cdl::widget(vignette,idimg)]]

      set h1 "vignetteres"
      set err  [ catch {::plotxy::plot $x $y "" 0 "" $h1} msg ]
      if {$err!=0} {
         #gren_erreur "ERROR : $msg\n"
         ::blt::vector create vx1
         ::blt::vector create vy1
         vx1 set $x
         vy1 set $y
         $baseplotxy1.xy element configure $h1 -xdata vx1 -ydata vy1 -color "#FF00F3" -pixel 10  -symbol diamond
      } else {
         plotxy::sethandler $h1 
      }

   }

   # cloture de la visualisation
   set ::bdi_gui_cdl::widget(vignette,inview) 0
   return
}






























#------------------------------------------------------------
## affiche le graphe des donnees
#  @return void
#
proc ::bdi_gui_cdl::famous_graph_init { } {
   
   set li [ ::plotxy::getgcf $::bdi_gui_cdl::figscifamous ]
   if {$li != ""} {
      set p  [lsearch -index 0 $li parent] 
      set parent [lindex $li [lsearch -index 0 $li parent] 1 ]
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
         
   ::plotxy::clf $::bdi_gui_cdl::figscifamous
   ::plotxy::figure $::bdi_gui_cdl::figscifamous 
   ::plotxy::hold on 
   ::plotxy::position $pos
   ::plotxy::title "Famous Residuals"
   ::plotxy::xlabel "Time (jd)" 
   ::plotxy::ylabel "Residus (Mag)"
   ::plotxy::ydir reverse
}



#------------------------------------------------------------
## 
#  @return void
#
proc ::bdi_gui_cdl::famous_graph { } {
   
   ::bdi_gui_cdl::famous_graph_init
   ::bdi_gui_cdl::famous_trace
   
}

#------------------------------------------------------------
## 
#  @return void
#
proc ::bdi_gui_cdl::famous_trace { } {

   global plotxy
   
   set hres [::plotxy::plot $::bdi_gui_cdl::widget(famous,data,x) $::bdi_gui_cdl::widget(famous,data,res) ro. 2 ]
   plotxy::sethandler $hres [list -color red -linewidth 0]

   ::plotxy::figure $::bdi_gui_cdl::figScimag
   set hsol "famous_sol"
   set err  [ catch {::plotxy::plot $::bdi_gui_cdl::widget(famous,data,x) $::bdi_gui_cdl::widget(famous,data,sol) "" 1 0 $hsol} msg ]
   if {$err!=0} {
      #gren_erreur "ERROR: $msg\n"
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      set x $::bdi_gui_cdl::widget(famous,data,x)
      set y $::bdi_gui_cdl::widget(famous,data,sol)
      ::blt::vector create vx
      ::blt::vector create vy
      vx set $x
      vy set $y
      $baseplotxy.xy element configure $hsol -xdata vx -ydata vy -linewidth 1 -color grey
   } else {
      #gren_erreur "NO ERROR: \n"
      plotxy::sethandler $hsol [list -linewidth 1 -color grey]
   }

}












#############################################################################################



#------------------------------------------------------------
## 
#  @return void
#
proc ::bdi_gui_cdl::famous_launch_obsolete { } {

   global bddconf

   cd $bddconf(dirtmp)
   set err [catch {exec Famous_driver } msg]
   if {$err} {
      gren_erreur "famous_launch: error #$err\n"
      gren_erreur "               msg $msg\n" 
      return
   } 
   #gren_info "toto $msg\n"

   # Lit la solution
   set ::bdi_tools_famous::lsolu [ ::bdi_tools_famous::read_solu_direct ]
   array set solu $::bdi_tools_famous::lsolu

   # Lecture des residus
   gren_info "Lecture des residus\n"
   set file_res [file join $bddconf(dirtmp) "resid_final.txt"]
   set xo ""
   set yo ""
   set ::bdi_gui_cdl::widget(famous,data,x)   ""
   set ::bdi_gui_cdl::widget(famous,data,res) ""
   set ::bdi_gui_cdl::widget(famous,data,sol) ""
   set f [open $file_res "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      set line [regsub -all \[\s\] $line ,]
      set r [split [string trim $line] ","]
      set x [lindex [lindex $r 0] 0 ] 
      set y [expr [lindex [lindex $r 0] 1 ]]
      lappend xo $x
      lappend yo $y
      lappend ::bdi_gui_cdl::widget(famous,data,x)   $x
      lappend ::bdi_gui_cdl::widget(famous,data,res) $y
      lappend ::bdi_gui_cdl::widget(famous,data,sol) [::bdi_tools_famous::extrapole $x solu]
      
   }
   close $f
   set time_span [expr [::math::statistics::max $xo] - [::math::statistics::min $xo]]
   set time_span_jd $time_span
   if {$time_span < 1 } {
      set time_span [format "%.2f hours" [expr $time_span * 24.0]]
   } else {
      set time_span [format "%.2f days" [expr $time_span]]
   }

   set residuals_mean [format "%.1f millimag" [ expr [::math::statistics::mean  $yo] *1000.0 ] ]
   set residuals_std  [format "%.1f millimag" [ expr [::math::statistics::stdev $yo] *1000.0 ] ]
   
   
   set ::bdi_gui_cdl::widget(famous,stats,nb_dates)       [::math::statistics::number $yo]
   set ::bdi_gui_cdl::widget(famous,stats,time_span)      $time_span
   set ::bdi_gui_cdl::widget(famous,stats,time_span_jd)   $time_span_jd
   set ::bdi_gui_cdl::widget(famous,stats,idm)            $::bdi_gui_cdl::widget(famous,idm)
   set ::bdi_gui_cdl::widget(famous,stats,residuals_mean) $residuals_mean
   set ::bdi_gui_cdl::widget(famous,stats,residuals_std)  $residuals_std
   gren_info "nbdates : $::bdi_gui_cdl::widget(famous,stats,nb_dates)\n"
   set ::bdi_gui_cdl::widget(famous,stats,$::bdi_gui_cdl::widget(objsel,combo,value),residuals_std) [ expr [::math::statistics::stdev  $yo] ]

   return      

}





proc ::bdi_gui_cdl::famous_edit_setup_obsolete { } {
   global bddconf
   set filename [file join $bddconf(dirtmp) "setting.txt"]
   catch { exec ne $filename }
}



proc ::bdi_gui_cdl::famous_view_sol_obsolete { } {

   array set solu $::bdi_tools_famous::lsolu

   for {set k 0} {$k<$solu(nbk)} {incr k} {
         gren_info "k  $k \n"

      for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
         gren_info "k  $k "
         gren_info "ex $exp)      "
         gren_info "fr $solu($k,$exp,frequency)"
         gren_info "pe $solu($k,$exp,period)   "
         gren_info "co $solu($k,$exp,costerm)  "
         gren_info "si $solu($k,$exp,sineterm) "
         gren_info "si $solu($k,$exp,sigmaf)   "
         gren_info "si $solu($k,$exp,sigmacos) "
         gren_info "si $solu($k,$exp,sigmasin) "
         gren_info "am $solu($k,$exp,amplitude)"
         gren_info "ph $solu($k,$exp,phase)    "
         gren_info "sn $solu($k,$exp,sn)       \n"
      }
   }
   
   ::bdi_gui_cdl::famous_graph   
}



proc ::bdi_gui_cdl::famous_crea_setup_obsolete { } {

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
   
   # Creation du fichier de config famous
   if {$::bdi_gui_cdl::widget(famous,periodic_decomposition) == "Multi"} {
      set decomp ".true."
   } else {
      set decomp ".false."
   }

   set filename [file join $bddconf(dirtmp) "setting.txt"]
   set f [open $filename "w"]
   puts $f "'famous.dat'    input file with the data"
   puts $f "1               field with time data in input file"
   puts $f "2               field with observation data in input file"
   puts $f "'famous.res'    ouptut file with the frequencies and power"
   puts $f "3               numf : number of lines searched"
   puts $f "$decomp          flmulti : flag for the multi or simply periodic decomposition."
   puts $f ".true.          flauto : flag for the frequency range .true. = automatic .false. : with preset frequencies"
   puts $f "0.01d0          frbeg  : lowest  frequency analysed in the periodograms (disabled if flauto =true)"
   puts $f "0.45d0          frend  : largest frequency analysed in the periodograms (disabled if flauto =true)"
   puts $f ".true.          fltime : flag for the origin of time  :: .true. : automatic  .false. : with preset value"
   puts $f "0.d0            tzero  : your origin of time if fltime = .false. in unit of the time signal read in the input file"
   puts $f "3.0d0           Threshold in S/N to reject non statistically significant lines"
   puts $f ".true.          Flag for the output of the  periodograms and successive residuals (true = output)"
   puts $f "0               iprint in freqsearch : 0 : setting and results, 1 : intermediate results, 2 : extended with correlations"
   puts $f "1               iresid : = 1 residuals are printed. 0 : not printed"
   puts $f ".true.          flagdeg : uniform degree for the mixed term (.true.) or not (.false.)"
   puts $f "$::bdi_gui_cdl::widget(famous,idm)               idm : Value of the degree in terms like a +bt + ... ct^idm (used if flagdeg = .true.)"
   close $f
   
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

   global bddconf

   cd $bddconf(dirtmp)
   set err [catch {file delete famous.res resid_final.txt } msg]
   if {$err} {
      gren_info "famous : delete out file : error #$err: $msg\n" 
      return
   } 

}


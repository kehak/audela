#
## @file select.tcl
#  @brief Interface permettant la sélection d'images
#  $Id: select.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#

#============================================================
# Declaration du namespace select
#    initialise le namespace
#============================================================

## @namespace select
#  @brief Interface permettant la sélection d'images
namespace eval ::select {
   package provide select 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] select.cap ]

   #------------------------------------------------------------
   # brief     retourne le titre du plugin dans la langue de l'utilisateur
   # return    titre du plugin
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(select,menu)"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du fichier d'aide principal
   # return    nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "select.htm"
   }

   #------------------------------------------------------------
   # brief     retourne le type de plugin
   # return    type de plugin
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # brief     retourne le nom du répertoire du plugin
   # return    nom du répertoire du plugin : "select"
   #
   proc getPluginDirectory { } {
      return "select"
   }

   #------------------------------------------------------------
   ## @brief    retourne le ou les OS de fonctionnement du plugin
   #  @return   liste des OS : "Windows Linux Darwin"
   #
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   ## @brief    retourne les propriétés de l'outil
   #
   #            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
   #  @param    propertyName nom de la propriété
   #  @return   valeur de la propriété ou "" si la propriété n'existe pas
   #
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "file" }
         subfunction1 { return "select" }
         display      { return "window" }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief   créé une nouvelle instance de l'outil
   #  @param   base   base tk
   #  @param   visuNo numéro de la visu
   #  @return  chemin de la fenêtre
   #
   proc createPluginInstance { base { visuNo 1 } } {
      variable This

      #--- Inititalisation du nom de la fenetre
      set This "$base.select"

      #--- J'ouvre la fenetre
      ::select::run

      #---
      return $This
   }

   #------------------------------------------------------------
   ## @brief   suppprime l'instance du plugin
   #  @param   visuNo numéro de la visu
   #
   proc deletePluginInstance { visuNo } {
      variable This

      if { [ winfo exists $This ] } {
         #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
         ::select::cmdClose
      }
   }

   #------------------------------------------------------------
   #  brief créé l'interface graphique
   #
   proc run { } {
      variable This
      global audace caption select

      #--- Initialisation des variables
      set select(nomEntree)   ""
      set select(nomSortie)   ""
      set select(indexEntree) ""
      set select(indexSortie) ""

      toplevel $This
      wm title $This "$caption(select,titre)"
      wm geometry $This +0+70
      wm resizable $This 1 1
      wm protocol $This WM_DELETE_WINDOW ::select::cmdClose

      #--- Je cree la visu de la fenetre de selection
      set select(visuNo) [::confVisu::create $This]

      #--- j'ajoute l'ouil de selection
      frame $This.tool.fra2 -bd 2 -relief groove

      frame $This.tool.fra2.f -bd 2 -relief groove
         label $This.tool.fra2.f.titre -text "$caption(select,entree)"
         label $This.tool.fra2.f.lne -text "$caption(select,nom)"
         entry $This.tool.fra2.f.ene -width 15 -textvariable select(nomEntree)
         button $This.tool.fra2.f.explore -text "$caption(select,parcourir)" -width 1 -command "::select::parcourir 1"
         label $This.tool.fra2.f.lie -text "$caption(select,index)"
         entry $This.tool.fra2.f.eie -width 3 -textvariable select(indexEntree)
         grid $This.tool.fra2.f.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.tool.fra2.f.lne -row 1 -column 0 -sticky w
         grid $This.tool.fra2.f.ene -row 1 -column 1 -sticky e
         grid $This.tool.fra2.f.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.tool.fra2.f.lie -row 2 -column 0 -sticky w
         grid $This.tool.fra2.f.eie -row 2 -column 1 -sticky e

      frame $This.tool.fra2.g -bd 2 -relief groove
         label $This.tool.fra2.g.titre -text "$caption(select,sortie)"
         label $This.tool.fra2.g.lne -text "$caption(select,nom)"
         entry $This.tool.fra2.g.ene -width 15 -textvariable select(nomSortie)
         button $This.tool.fra2.g.explore -text "$caption(select,parcourir)" -width 1 -command "::select::parcourir 2"
         label $This.tool.fra2.g.lie -text "$caption(select,index)"
         entry $This.tool.fra2.g.eie -width 3 -textvariable select(indexSortie)
         grid $This.tool.fra2.g.titre -row 0 -column 0 -columnspan 2 -sticky {}
         grid $This.tool.fra2.g.lne -row 1 -column 0 -sticky w
         grid $This.tool.fra2.g.ene -row 1 -column 1 -sticky e
         grid $This.tool.fra2.g.explore -row 1 -column 2 -sticky e -padx 10 -ipady 5
         grid $This.tool.fra2.g.lie -row 2 -column 0 -sticky w
         grid $This.tool.fra2.g.eie -row 2 -column 1 -sticky e

      frame $This.tool.fra2.h -bd 2 -relief groove
         button $This.tool.fra2.h.b0 -text "$caption(select,demarrer)" -command "::select::start"
         button $This.tool.fra2.h.b1 -text "$caption(select,inf)" -command "::select::prev" -state disabled
         entry  $This.tool.fra2.h.e0 -textvariable select(indexEntree) -width 3
         button $This.tool.fra2.h.b2 -text "$caption(select,sup)" -command "::select::next" -state disabled
         button $This.tool.fra2.h.b4 -text "$caption(select,auto)" -command "::select::auto" -state disabled
         button $This.tool.fra2.h.b5 -text "$caption(select,aide)" -command "::audace::showHelpPlugin \
            [ ::audace::getPluginTypeDirectory [ ::select::getPluginType ] ] \
            [ ::select::getPluginDirectory ] [ ::select::getPluginHelp ]" -state normal
         button $This.tool.fra2.h.b3 -text "$caption(select,record)" -command "::select::record" -state disabled
         pack $This.tool.fra2.h.b0 $This.tool.fra2.h.b1 $This.tool.fra2.h.e0 $This.tool.fra2.h.b2 $This.tool.fra2.h.b4 -side left -padx 4 -pady 4 -ipady 5
         pack $This.tool.fra2.h.b3 $This.tool.fra2.h.b5 -side right -padx 4 -pady 4 -ipady 5

      frame $This.tool.fra2.i
         scrollbar $This.tool.fra2.i.vsb -orient vertical -command "$This.tool.fra2.i.t yview"
         scrollbar $This.tool.fra2.i.hsb -orient horizontal -command "$This.tool.fra2.i.t xview"
         text $This.tool.fra2.i.t -yscrollcommand "$This.tool.fra2.i.vsb set" -xscrollcommand "$This.tool.fra2.i.hsb set" -width 0 -height 0
         grid $This.tool.fra2.i.t $This.tool.fra2.i.vsb -sticky news
         grid $This.tool.fra2.i.hsb -sticky ew
         grid rowconfigure $This.tool.fra2.i 0 -weight 1
         grid columnconfigure $This.tool.fra2.i 0 -weight 1

      grid $This.tool.fra2.f -row 0 -column 0 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.tool.fra2.g -row 0 -column 1 -padx 2 -pady 4 -ipadx 4 -ipady 4 -sticky ew
      grid $This.tool.fra2.h -row 1 -column 0 -columnspan 2 -padx 2 -pady 0 -sticky ew
      grid $This.tool.fra2.i -row 2 -column 0 -columnspan 2 -padx 2 -pady 4 -sticky news; #-sticky ew
      grid columnconfigure $This.tool.fra2 0 -weight 1
      grid rowconfigure $This.tool.fra2 2 -weight 1

      pack $This.tool.fra2 -anchor center -expand 0 -fill y -side left

      #--- Creation des variables locales dependant de la visu
      set select(buffer) [visu$select(visuNo) buf]
      set select(canvas) $::confVisu::private($select(visuNo),hCanvas)

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   # brief explore le répertoire des images
   # param Entree_Sortie 1 pour les images d'entrée et 2 pour les images de sortie
   #
   proc parcourir { Entree_Sortie } {
      variable This
      global audace select

      #--- Fenetre parent
      set fenetre "$This"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $select(buffer) "1" ]
      #--- Extraction du nom generique
      if { $filename != "" } {
         if { $Entree_Sortie == "1" } {
            set select(nomEntree) [ lindex [ decomp $filename ] 1 ]
         } else {
            set select(nomSortie) [ lindex [ decomp $filename ] 1 ]
         }
      } else {
         return
      }
   }

   #------------------------------------------------------------
   ## @brief affiche l'image suivante
   #
   proc next { } {
      global select

      dispima [ incr select(index) ]
   }

   #------------------------------------------------------------
   ## @brief affiche l'image précédente
   #
   proc prev { } {
      global select

      dispima [ incr select(index) -1 ]
   }

   #------------------------------------------------------------
   ## @brief lance la sélection automatique des images selon la fwhm
   #
   proc auto { } {
      variable This
      global audace conf select

      if { ( $select(nomSortie) != "" ) && ( $select(indexSortie) != "" ) } {
         set in    $select(nomEntree)
         set nb    [ llength $select(liste_entree) ]
         set liste ""
         #--- Cette boucle cree une liste dont les elements sont des listes a 2 elems : [ list fwhm nom_image ]
         foreach img $select(liste_entree) {
            buf$select(buffer) load "$img"
            buf$select(buffer) imaseries "STAT fwhm"
            set fwhm [ lindex [ buf$select(buffer) getkwd FWHM ] 1 ]
            set dfwhm [ lindex [ buf$select(buffer) getkwd D_FWHM ] 1 ]
            lappend liste [ list $fwhm $img $dfwhm ]
         }
         set liste [ lsort $liste ]
         $This.tool.fra2.i.t insert insert "# $liste\n\n"
         set cmp [ buf$select(buffer) compress ]
         if { $cmp == "none" } {
            set cmp ""
         } else {
            set cmp ".gz"
         }
         foreach elem $liste {
            $This.tool.fra2.i.t insert insert "# $elem\n"
            set org "[ lindex $elem 1 ]"
            set dest [ file join $audace(rep_images) $select(nomSortie)$select(indexSortie)$conf(extension,defaut)$cmp ]
            file copy -force "$org" "$dest"
            $This.tool.fra2.i.t insert insert "file copy -force $org $dest\n\n"
            incr select(indexSortie)
         }
         $This.tool.fra2.i.t insert insert "---------------------------------------------------------------------------------------------------------\n\n"
         $This.tool.fra2.i.t see insert
      }
   }

   #------------------------------------------------------------
   ## @brief sauve le résultat de la sélection
   #
   proc record { } {
      variable This
      global audace caption conf select

      if { ( $select(nomSortie) != "" ) && ( $select(indexSortie) != "" ) } {
         $This.tool.fra2.h.b3 configure -state disabled
         set cmp [ buf$select(buffer) compress ]
         if { $cmp == "none" } {
            set cmp ""
         } else {
            set cmp ".gz"
         }
         #--- Copie du fichier
         set org "[ lindex $select(liste_entree) $select(index) ]"
         set dest [ file join $audace(rep_images) $select(nomSortie)$select(indexSortie)$conf(extension,defaut)$cmp ]
         file copy -force $org $dest
         $This.tool.fra2.i.t insert insert "file copy -force $org $dest\n"
         #--- Incrementation de l'index de sortie
         incr select(indexSortie)
         #--- L'image recopiee est supprimee de la liste de depart
         set select(liste_entree) [ lreplace $select(liste_entree) $select(index) $select(index) ]
         if { $select(index) == [ llength $select(liste_entree) ] } {
            incr select(index) -1
         }
         if { $select(index) < "0" } {
            set select(indexEntree) "$caption(select,tiret)"
            $This.tool.fra2.h.b1 configure -state disabled
            $This.tool.fra2.h.b2 configure -state disabled
         }
         dispima $select(index)
      }
   }

   #------------------------------------------------------------
   ## @brief affiche l'image et rafraichit l'interface graphique
   #  @param index numéro de l'image dans la série
   #
   proc dispima { index } {
      variable This
      global audace conf select

      if { $index >= "0" } {
         set nom [ lindex $select(liste_entree) $index ]
         catch {
            buf$select(buffer) load $nom
         }
         ::audace::autovisu $select(visuNo)
         set a [ scan $nom [ file join $audace(rep_images) $select(nomEntree)%d$conf(extension,defaut) ] val ]
         set num [ catch { set select(indexEntree) $val } msg ]
         if { $num == "1" } {
            ::select::start
         }
         wm title $This [ lindex $select(liste_entree) $select(index) ]
         #--- Validation des boutons de navigation et enregistrement
         $This.tool.fra2.h.b3 configure -state normal
         if { $select(index) == [ expr [ llength $select(liste_entree) ] -1 ] } {
            $This.tool.fra2.h.b2 configure -state disabled
         } else {
            $This.tool.fra2.h.b2 configure -state normal
         }
         if { $select(index) == "0" } {
            $This.tool.fra2.h.b1 configure -state disabled
         } else {
            $This.tool.fra2.h.b1 configure -state normal
         }
      }
   }

   #------------------------------------------------------------
   ## @brief affiche la première image et rafraichit l'interface graphique
   #
   proc start { } {
      variable This
      global audace caption select

      #--- Nettoyage de l'affichage des images
      visu$select(visuNo) clear

      set cmp [ buf$select(buffer) compress ]
      if { $cmp == "none" } {
         set comp ""
      } else {
         set comp ".gz"
      }
      if { [ catch { lsort -dictionary [ glob [ file join $audace(rep_images) $select(nomEntree)\[0-9\]*[ buf$select(buffer) extension]$comp ] ] } m ] == "1" } {
         tk_messageBox -message "$caption(select,pas_image)" -title "$caption(select,menu)"
      } else {
         set select(liste_entree) $m
         set select(index) 0
         unset select(indexEntree)
         dispima $select(index)
         set w [ buf$select(buffer) getpixelswidth ]
         $select(canvas) configure -width $w
         if { [buf$select(buffer) getnaxis] == 1 } {
            set h [ visu$select(visuNo) thickness ]
         } else {
            set h [ buf$select(buffer) getpixelsheight ]
         }
         $select(canvas) configure -height $h
         if { [ llength $select(liste_entree) ] != "1" } {
            $This.tool.fra2.h.b2 configure -state normal
         } else {
            $This.tool.fra2.h.b2 configure -state disabled
         }
         $This.tool.fra2.h.b3 configure -state normal
         $This.tool.fra2.h.b4 configure -state normal
         foreach elem $select(liste_entree) {
            $This.tool.fra2.i.t insert insert "# $elem\n"
         }
         $This.tool.fra2.i.t insert insert "\n"
         $This.tool.fra2.i.t see insert
      }
   }

   #------------------------------------------------------------
   ## @brief ferme l'outil
   #
   proc cmdClose { } {
      global select

      ::confVisu::close $select(visuNo)
   }

}


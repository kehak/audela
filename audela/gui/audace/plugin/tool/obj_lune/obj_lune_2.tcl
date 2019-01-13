#
# Fichier : obj_lune_2.tcl
# Description : Programme pour la partie graphique de l'outil Objectif Lune
# Auteur : Robert DELMAS
# Mise à jour $Id: obj_lune_2.tcl 12600 2016-01-11 20:41:56Z robertdelmas $
#

namespace eval ::obj_lune {

   #
   # obj_lune::Lune_Scrolled_Canvas
   # Cree un canvas scrollable, ainsi que les deux scrollbars pour le deplacer
   # Ref : Brent Welsh, Practical Programming in TCL/TK, rev.2, page 392
   #
   proc Lune_Scrolled_Canvas { c args } {
      frame $c
      eval {canvas $c.canvas \
         -xscrollcommand [list $c.xscroll set] \
         -yscrollcommand [list $c.yscroll set] \
         -highlightthickness 0 \
         -borderwidth 0} $args
      scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
      scrollbar $c.yscroll -orient vertical -command [list $c.canvas yview]
      grid $c.canvas $c.yscroll -sticky news
      grid $c.xscroll -sticky ew
      grid rowconfigure $c 0 -weight 1
      grid columnconfigure $c 0 -weight 1
      return $c.canvas
   }

   #
   # obj_lune::LitCataChoisi
   # Lit le catalogue des sites choisis
   #
   proc LitCataChoisi { } {
      global audace obj_lune site zone

      #--- Gestion du bouton Calculer les meilleures dates d'observation
      $obj_lune(onglet5).frame7.calcul configure -state disabled
      #--- Nettoyage de la listbox avant l'affichage du nouveau catalogue
      $zone(list_site) delete 0 end
      #--- Nettoyage de la zone texte avant l'affichage de l'origine du nom
      $zone(list_histoire) delete 0.0 end
      #--- Efface les rectangles et les numeros des precedentes cartes selectionnees
      for {set i 1} {$i <= "10" } {incr i} {
         set obj_lune(n$i) "0"
      }
      set obj_lune(nbre_carte) "0"
      for {set i 1} {$i <= "2" } {incr i} {
         set obj_lune(lib_n$i) "0"
      }
      set obj_lune(nbre_carte_lib) "0"
      ::obj_lune::EffaceRectangleBleu_Rouge
      #--- Nettoyage des infos latitude et longitude selenes, dimension et du ou des numeros des cartes du site
      $obj_lune(onglet1).frame13.lab2a configure -text "-"
      $obj_lune(onglet1).frame14.lab3a configure -text "-"
      $obj_lune(onglet1).frame15.lab4a configure -text "-"
      $obj_lune(onglet1).frame9.labURL8a configure -text "-"
      $obj_lune(onglet3).frame5.labURL3 configure -text "-"
      $obj_lune(onglet4).frame5.labURL3 configure -text "-"
      #--- Nettoyage des infos nom, latitude et longitude selenes, dates, heures, longitudes du terminateur,
      #--- librations et fraction eclairee
      $obj_lune(onglet5).frame4.lab1a configure -text "-"
      $obj_lune(onglet5).frame5.lab2a configure -text "-"
      $obj_lune(onglet5).frame6.lab3a configure -text "-"
      $obj_lune(onglet5).frame8.labURL4a configure -text "-"
      $obj_lune(onglet5).frame9.labURL5a configure -text "-"
      $obj_lune(onglet5).frame10.labURL6a configure -text "-"
      $obj_lune(onglet5).frame11.labURL7a configure -text "-"
      $obj_lune(onglet5).frame12.labURL8a configure -text "-"
      $obj_lune(onglet5).frame13.labURL9a configure -text "-"
      $obj_lune(onglet5).frame15.labURL11a configure -text "-"
      $obj_lune(onglet5).frame16.labURL12a configure -text "-"
      $obj_lune(onglet5).frame17.labURL13a configure -text "-"
      $obj_lune(onglet5).frame18.labURL14a configure -text "-"
      $obj_lune(onglet5).frame19.labURL15a configure -text "-"
      $obj_lune(onglet5).frame20.labURL16a configure -text "-"
      #--- Efface le dessin du terminateur sur la Lune
      $obj_lune(onglet5).frame3.image5a delete cadres
      #--- Ouverture du catalogue des sites choisis
      set f [open [file join $audace(rep_plugin) tool obj_lune cata_obj_lune $obj_lune(cata_choisi)] r]
      #--- Creation d'une liste de sites
      set site [split [read $f] "\n"]
      #--- Determine le nombre d'elements de la liste
      set long [llength $site]
      set long [expr $long-2]
      #--- Met chaque ligne du catalogue dans une variable et acceleration de l'affichage
      pack forget $obj_lune(onglet1).frame3.lb1
      pack forget $obj_lune(onglet1).frame3.scrollbar
      pack forget $obj_lune(onglet1).frame3
      for {set i 0} {$i <= $long} {incr i} {
         $zone(list_site) insert end "[lindex $site $i]"
      }
      pack $obj_lune(onglet1).frame3.lb1 -side left -anchor nw
      pack $obj_lune(onglet1).frame3.scrollbar -side left -fill y
      pack $obj_lune(onglet1).frame3 -side top -fill both -expand 1
      #--- Ferme le catalogue des sites choisis
      close $f
   }

   #
   # obj_lune::AfficheInfoSite
   # Affichage des infos du site choisi
   #
   proc AfficheInfoSite { } {
      variable This
      global audace color obj_lune thissite_lune zone

      #--- Definition du bind de selection du site choisi
      bind $zone(list_site) <Double-ButtonRelease-1> { }
      bind $zone(list_site) <ButtonRelease-1> {
         #--- Gestion du bouton Calculer les meilleures dates d'observation
         $obj_lune(onglet5).frame7.calcul configure -state normal
         #--- Initialisation numero de cartes
         set obj_lune(n1)     ""
         set obj_lune(n2)     ""
         set obj_lune(n3)     ""
         set obj_lune(n4)     ""
         set obj_lune(n5)     ""
         set obj_lune(n6)     ""
         set obj_lune(n7)     ""
         set obj_lune(n8)     ""
         set obj_lune(n9)     ""
         set obj_lune(n10)    ""
         set obj_lune(lib_n1) ""
         set obj_lune(lib_n2) ""
         #--- Nettoyage de la zone texte avant l'affichage de l'origine du nom
         $zone(list_histoire) delete 0.0 end
         #--- Nettoyage des informations de date, heure, longitude du terminateur, librations et fraction eclairee
         #--- de l'onglet meilleure date d'observation
         $obj_lune(onglet5).frame8.labURL4a configure -text "-"
         $obj_lune(onglet5).frame9.labURL5a configure -text "-"
         $obj_lune(onglet5).frame10.labURL6a configure -text "-"
         $obj_lune(onglet5).frame11.labURL7a configure -text "-"
         $obj_lune(onglet5).frame12.labURL8a configure -text "-"
         $obj_lune(onglet5).frame13.labURL9a configure -text "-"
         $obj_lune(onglet5).frame15.labURL11a configure -text "-"
         $obj_lune(onglet5).frame16.labURL12a configure -text "-"
         $obj_lune(onglet5).frame17.labURL13a configure -text "-"
         $obj_lune(onglet5).frame18.labURL14a configure -text "-"
         $obj_lune(onglet5).frame19.labURL15a configure -text "-"
         $obj_lune(onglet5).frame20.labURL16a configure -text "-"
         #--- Efface le dessin du terminateur sur la Lune
         $obj_lune(onglet5).frame3.image5a delete cadres
         #--- Efface les rectangles et les numeros des precedentes selections
         ::obj_lune::EffaceRectangleBleu_Rouge
         set obj_lune(n_carte) "-"
         set obj_lune(n_carte_lib) "-"
         #--- Saisie du site
         set thissite_lune [lindex $site [%W curselection]]
         #--- Preparation de l'affichage du nom
         set obj_lune(nom_site) "[string range $thissite_lune 0 25]"
         $obj_lune(onglet5).frame4.lab1a configure -text "$obj_lune(nom_site)"
         #--- Preparation de l'affichage de la latitude selene
         for {set i 0} {$i <= 7} {incr i} {
            if { [string compare [string range $thissite_lune [expr 26+$i] [expr 26+$i]] "N"] == "0" } {
               set obj_lune(lat_selene) "[string range $thissite_lune 26 33]"
            } elseif { [string compare [string range $thissite_lune [expr 26+$i] [expr 26+$i]] "S"] == "0" } {
               set obj_lune(lat_selene) "-[string range $thissite_lune 26 33]"
            }
         }
         $obj_lune(onglet1).frame13.lab2a configure -text "$obj_lune(lat_selene)"
         $obj_lune(onglet5).frame5.lab2a configure -text "$obj_lune(lat_selene)"
         #--- Preparation de l'affichage de la longitude selene
         for {set i 0} {$i <= 7} {incr i} {
            if { [string compare [string range $thissite_lune [expr 34+$i] [expr 34+$i]] "E"] == "0" } {
               set obj_lune(long_selene) "[string range $thissite_lune 34 41]"
            } elseif { [string compare [string range $thissite_lune [expr 34+$i] [expr 34+$i]] "W"] == "0" } {
               set obj_lune(long_selene) "-[string range $thissite_lune 34 41]"
            }
         }
         $obj_lune(onglet1).frame14.lab3a configure -text "$obj_lune(long_selene)"
         $obj_lune(onglet5).frame6.lab3a configure -text "$obj_lune(long_selene)"
         #--- Preparation de l'affichage de la dimension en km
         $obj_lune(onglet1).frame15.lab4a configure -text "[string range $thissite_lune 42 49]"
         #--- Preparation de l'affichage du ou des numeros des cartes de l'atlas dans l'onglet GOTO
         if { [string range $thissite_lune 86 89] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81] [string range $thissite_lune 82 85] [string range $thissite_lune 86 89]\
                 [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "10"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            set obj_lune(n6) "[string trimright [string range $thissite_lune 70 73] " "]"
            set obj_lune(n7) "[string trimright [string range $thissite_lune 74 77] " "]"
            set obj_lune(n8) "[string trimright [string range $thissite_lune 78 81] " "]"
            set obj_lune(n9) "[string trimright [string range $thissite_lune 82 85] " "]"
            set obj_lune(n10) "[string trimright [string range $thissite_lune 86 89] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 82 85] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81] [string range $thissite_lune 82 85] [string range $thissite_lune 90 93]\
                 [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "9"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            set obj_lune(n6) "[string trimright [string range $thissite_lune 70 73] " "]"
            set obj_lune(n7) "[string trimright [string range $thissite_lune 74 77] " "]"
            set obj_lune(n8) "[string trimright [string range $thissite_lune 78 81] " "]"
            set obj_lune(n9) "[string trimright [string range $thissite_lune 82 85] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 78 81] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81] [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "8"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            set obj_lune(n6) "[string trimright [string range $thissite_lune 70 73] " "]"
            set obj_lune(n7) "[string trimright [string range $thissite_lune 74 77] " "]"
            set obj_lune(n8) "[string trimright [string range $thissite_lune 78 81] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 74 77] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "7"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            set obj_lune(n6) "[string trimright [string range $thissite_lune 70 73] " "]"
            set obj_lune(n7) "[string trimright [string range $thissite_lune 74 77] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 70 73] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "6"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            set obj_lune(n6) "[string trimright [string range $thissite_lune 70 73] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 66 69] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 90 93]
                  [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "5"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            set obj_lune(n5) "[string trimright [string range $thissite_lune 66 69] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 62 65] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "4"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            set obj_lune(n4) "[string trimright [string range $thissite_lune 62 65] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 58 61] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "3"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            set obj_lune(n3) "[string trimright [string range $thissite_lune 58 61] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 54 57] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "2"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            set obj_lune(n2) "[string trimright [string range $thissite_lune 54 57] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 50 53] != "    " } {
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 90 93]\
                 [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte) "1"
            set obj_lune(n1) "[string trimright [string range $thissite_lune 50 53] " "]"
            ::obj_lune::AfficheRepereSite
            ::obj_lune::Trait_Carte_lib_et_autres
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 94 97] != "    " } {
            #--- Traitement de l'affichage des cartes de librations seules
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
            set obj_lune(nbre_carte_lib) "2"
            set obj_lune(lib_n1) "[string trimright [string range $thissite_lune 90 93] " "]"
            set obj_lune(lib_n2) "[string trimright [string range $thissite_lune 94 97] " "]"
            ::obj_lune::ConversionNumeroCarte_lib1
            ::obj_lune::ConversionNumeroCarte_lib2
            ::obj_lune::AffichePremiereCarte
         } elseif { [string range $thissite_lune 90 93] != "    " } {
            #--- Traitement de l'affichage des cartes de librations seules
            $obj_lune(onglet1).frame9.labURL8a configure -text "[string range $thissite_lune 90 93]" -fg $color(blue)
            set obj_lune(nbre_carte_lib) "1"
            set obj_lune(lib_n1) "[string trimright [string range $thissite_lune 90 93] " "]"
            ::obj_lune::ConversionNumeroCarte_lib1
            ::obj_lune::AffichePremiereCarte
         } else {
            set obj_lune(n1)     ""
            set obj_lune(lib_n1) ""
            $obj_lune(onglet1).frame9.labURL8a configure -text "-"
         }
         #--- Preparation de l'affichage du ou des numeros des cartes de l'atlas dans l'onglet Cartographie
         if { [string range $thissite_lune 86 89] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81] [string range $thissite_lune 82 85] [string range $thissite_lune 86 89]" -fg $color(blue)
         } elseif { [string range $thissite_lune 82 85] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81] [string range $thissite_lune 82 85]" -fg $color(blue)
         } elseif { [string range $thissite_lune 78 81] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77] [string range $thissite_lune 78 81]" -fg $color(blue)
         } elseif { [string range $thissite_lune 74 77] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]\
                 [string range $thissite_lune 74 77]" -fg $color(blue)
         } elseif { [string range $thissite_lune 70 73] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69] [string range $thissite_lune 70 73]" -fg $color(blue)
         } elseif { [string range $thissite_lune 66 69] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65] [string range $thissite_lune 66 69]" -fg $color(blue)
         } elseif { [string range $thissite_lune 62 65] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61] [string range $thissite_lune 62 65]" -fg $color(blue)
         } elseif { [string range $thissite_lune 58 61] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]\
                 [string range $thissite_lune 58 61]" -fg $color(blue)
         } elseif { [string range $thissite_lune 54 57] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53] [string range $thissite_lune 54 57]" -fg $color(blue)
         } elseif { [string range $thissite_lune 50 53] != "    " } {
            $obj_lune(onglet3).frame5.labURL3 configure -text "[string range $thissite_lune 50 53]" -fg $color(blue)
         } else {
            $obj_lune(onglet3).frame5.labURL3 configure -text "-"
         }
         #--- Preparation de l'affichage du ou des numeros des cartes de l'atlas dans l'onglet Cartes de librations
         if { [string range $thissite_lune 94 97] != "    " } {
            $obj_lune(onglet4).frame5.labURL3 configure -text "[string range $thissite_lune 90 93] [string range $thissite_lune 94 97]" -fg $color(blue)
         } elseif { [string range $thissite_lune 90 93] != "    " } {
            $obj_lune(onglet4).frame5.labURL3 configure -text "[string range $thissite_lune 90 93]" -fg $color(blue)
         } else {
            $obj_lune(onglet4).frame5.labURL3 configure -text "-"
         }
         #--- Visibilite du site choisi (librations + fraction eclairee/fraction non eclairee de la Lune)
         set visibilite "1"
############## A developper (le site peut etre visible avec les librations)
         #--- Visibilite en longitude (libration - est/ouest)
         set limite_est [expr 90.0 + $obj_lune(Lib_longitude)]
         set limite_ouest [expr -90.0 + $obj_lune(Lib_longitude)]
         if { [string trimright [string trimright $obj_lune(long_selene) " "] E] == [string trimright $obj_lune(long_selene) " "] } {
            set long_selene_site [string trimright [string trimright $obj_lune(long_selene) " "] W]
         } else {
            set long_selene_site [string trimright [string trimright $obj_lune(long_selene) " "] E]
         }
         if { $long_selene_site > $limite_est } {
            set visibilite "0"
            $zone(list_histoire) insert end "$caption(obj_lune2,face_cachee)\n\n"
         } elseif { $long_selene_site < $limite_ouest } {
            set visibilite "0"
            $zone(list_histoire) insert end "$caption(obj_lune2,face_cachee)\n\n"
         }
         #--- Visibilite en latitude (libration - nord/sud)
         set limite_nord [expr 90.0 + $obj_lune(Lib_latitude)]
         if { $limite_nord > 90.0 } {
            set limite_nord "90.0"
         }
         set limite_sud [expr -90.0 + $obj_lune(Lib_latitude)]
         if { $limite_sud < -90.0 } {
            set limite_sud "-90.0"
         }
         if { [string trimright [string trimright $obj_lune(lat_selene) " "] N] == [string trimright $obj_lune(lat_selene) " "] } {
            set lat_selene_site [string trimright [string trimright $obj_lune(lat_selene) " "] S]
         } else {
            set lat_selene_site [string trimright [string trimright $obj_lune(lat_selene) " "] N]
         }
         if { $lat_selene_site > $limite_nord } {
            $zone(list_histoire) insert end "$caption(obj_lune2,face_cachee)\n\n"
            set visibilite "0"
         } elseif { $lat_selene_site < $limite_sud } {
            $zone(list_histoire) insert end "$caption(obj_lune2,face_cachee)\n\n"
            set visibilite "0"
         }
         #--- Gestion des boutons Goto et Match actifs/inactifs avec la visibilite du site
         if { $visibilite == "1" } {
            $::obj_lune::This.cmd.goto configure -relief raised -state normal
            $::obj_lune::This.cmd.match configure -relief raised -state normal
            update
         } else {
            $::obj_lune::This.cmd.goto configure -relief raised -state disabled
            $::obj_lune::This.cmd.match configure -relief raised -state disabled
            update
         }
         #--- Site visible mais non eclaire
         if { $visibilite == "1" } {
            if { $obj_lune(age_lune) < [expr 29.53058868/2.0] } {
               if { $long_selene_site < $obj_lune(Long_terminateur) } {
                  $zone(list_histoire) insert end "$caption(obj_lune2,visible_ombre)\n\n"
               }
            } else {
               if { $long_selene_site > $obj_lune(Long_terminateur) } {
                  $zone(list_histoire) insert end "$caption(obj_lune2,visible_ombre)\n\n"
               }
            }
         }
         #--- Preparation de l'affichage de l'origine du nom du site dans la zone texte
         $zone(list_histoire) insert end "[string range $thissite_lune 98 end]"
      }
   }

   #
   # obj_lune::Lune_Dessine_Phase
   # Dessine la phase de la Lune en fonction de la fraction illuminee de son disque
   #
   proc Lune_Dessine_Phase { } {
      global color obj_lune

      #--- Initialisation pour le diametre de l'image de la Lune
      set EB [expr (287.0-12.0)/2.0]
      #--- Initialisation de la demi-revolution synodique de la Lune
      set demi_rev_syno [expr 29.53058868/2.0]
      #--- Calcul du segment definissant le croissant
      set EC [expr (1-2*$obj_lune(fraction_illu))*$EB]
      #--- Verifie l'existance du widget
      if { [ winfo exists $obj_lune(onglet2) ] } {
         #--- Cas particulier de la Nouvelle Lune
         if { $obj_lune(fraction_illu) == "0.0" } {
            $obj_lune(onglet2).frame23.image2a create oval 12 12 287 287 -outline $color(red) -tags cadres -width 4.0
         #--- Cas particulier de la Pleine Lune
         } elseif { $obj_lune(fraction_illu) == "1.0" } {
            $obj_lune(onglet2).frame23.image2a create oval 12 12 287 287 -outline $color(yellow) -tags cadres -width 4.0
         } else {
            #--- Traitement du croissant ascendant ou descendant
            #--- Croissant ascendant
            if { $obj_lune(age_lune) < $demi_rev_syno } {
               $obj_lune(onglet2).frame23.image2a create arc 12 12 287 287 -outline $color(yellow) -tags cadres -width 4.0 -start 90 -extent -180 -style arc
               if { $obj_lune(fraction_illu) < 0.5 } {
                  $obj_lune(onglet2).frame23.image2a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color(yellow) -tags cadres -width 2.0 -start 90 -extent -180 -style arc
               } else {
                  $obj_lune(onglet2).frame23.image2a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color(yellow) -tags cadres -width 2.0 -start 90 -extent 180 -style arc
               }
            #--- Croissant descendant
            } else {
               $obj_lune(onglet2).frame23.image2a create arc 12 12 287 287 -outline $color(yellow) -tags cadres -width 4.0 -start 90 -extent 180 -style arc
               if { $obj_lune(fraction_illu) > 0.5 } {
                  $obj_lune(onglet2).frame23.image2a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color(yellow) -tags cadres -width 2.0 -start 90 -extent -180 -style arc
               } else {
                  $obj_lune(onglet2).frame23.image2a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color(yellow) -tags cadres -width 2.0 -start 90 -extent 180 -style arc
               }
            }
         }
      }
   }

   #
   # obj_lune::Lune_Dessine_Phase_Meilleure_Date
   # Dessine le terminateur et la phase de la Lune pour les meilleures date d'observation du site
   #
   proc Lune_Dessine_Phase_Meilleure_Date { fraction_illu age_lune color_pmd } {
      global color obj_lune

      #--- Inintialisation des variables
      set obj_lune(fraction_illu) $fraction_illu
      set obj_lune(age_lune) $age_lune
      #--- Initialisation pour le diametre de l'image de la Lune
      set EB [expr (287.0-12.0)/2.0]
      #--- Initialisation de la demi-revolution synodique de la Lune
      set demi_rev_syno [expr 29.53058868/2.0]
      #--- Calcul du segment definissant le croissant
      set EC [expr (1-2*$obj_lune(fraction_illu))*$EB]
      #--- Cas particulier de la Nouvelle Lune
      if { $obj_lune(fraction_illu) == "0.0" } {
         $obj_lune(onglet5).frame3.image5a create oval 12 12 287 287 -outline $color(red) -tags cadres -width 4.0
      #--- Cas particulier de la Pleine Lune
      } elseif { $obj_lune(fraction_illu) == "1.0" } {
         $obj_lune(onglet5).frame3.image5a create oval 12 12 287 287 -outline $color_pmd -tags cadres -width 4.0
      } else {
         #--- Traitement du croissant ascendant ou descendant
         #--- Croissant ascendant
         if { $obj_lune(age_lune) < $demi_rev_syno } {
            $obj_lune(onglet5).frame3.image5a create arc 12 12 287 287 -outline $color_pmd -tags cadres -width 4.0 -start 90 -extent -180 -style arc
            if { $obj_lune(fraction_illu) < 0.5 } {
               $obj_lune(onglet5).frame3.image5a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color_pmd -tags cadres -width 2.0 -start 90 -extent -180 -style arc
            } else {
               $obj_lune(onglet5).frame3.image5a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color_pmd -tags cadres -width 2.0 -start 90 -extent 180 -style arc
            }
         #--- Croissant descendant
         } else {
            $obj_lune(onglet5).frame3.image5a create arc 12 12 287 287 -outline $color_pmd -tags cadres -width 4.0 -start 90 -extent 180 -style arc
            if { $obj_lune(fraction_illu) > 0.5 } {
               $obj_lune(onglet5).frame3.image5a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color_pmd -tags cadres -width 2.0 -start 90 -extent -180 -style arc
            } else {
               $obj_lune(onglet5).frame3.image5a create arc [expr 12.0+abs($EB-$EC)] 12 [expr 287.0-abs($EB-$EC)] 287 -outline $color_pmd -tags cadres -width 2.0 -start 90 -extent 180 -style arc
            }
         }
      }
   }

   #
   # obj_lune::affiche_cata_choisi
   # Affichage du catalogue des sites choisis
   #
   proc affiche_cata_choisi { } {
      global langage obj_lune

      #--- Efface l'AD et la Dec. du site lunaire a chaque changement de catalogue
      $obj_lune(onglet1).frame17.lab6a configure -text "-"
      $obj_lune(onglet1).frame18.lab7a configure -text "-"
      #--- Efface la variable obj_lune(long_selene) a chaque changement de catalogue
      catch { unset obj_lune(long_selene) }
      #--- Charge le catalogue choisi
      if {[string compare $langage "french"] ==0 } {
         switch -exact -- $obj_lune(goto) {
         1 { set obj_lune(cata_choisi) "lune_reference_fr.txt"
              obj_lune::LitCataChoisi
           }
         2 { set obj_lune(cata_choisi) "lune_crateres_fr.txt"
              obj_lune::LitCataChoisi
           }
         3 { set obj_lune(cata_choisi) "lune_ch_crater_fr.txt"
              obj_lune::LitCataChoisi
           }
         4 { set obj_lune(cata_choisi) "lune_monts_fr.txt"
              obj_lune::LitCataChoisi
           }
         5 { set obj_lune(cata_choisi) "lune_ch_monts_fr.txt"
              obj_lune::LitCataChoisi
           }
         6 { set obj_lune(cata_choisi) "lune_vallees_fr.txt"
              obj_lune::LitCataChoisi
           }
         7 { set obj_lune(cata_choisi) "lune_rainures_fr.txt"
              obj_lune::LitCataChoisi
           }
         8 { set obj_lune(cata_choisi) "lune_sys_rainu_fr.txt"
              obj_lune::LitCataChoisi
           }
         9 { set obj_lune(cata_choisi) "lune_failles_fr.txt"
              obj_lune::LitCataChoisi
           }
         10 { set obj_lune(cata_choisi) "lune_dorsales_fr.txt"
              obj_lune::LitCataChoisi
           }
         11 { set obj_lune(cata_choisi) "lune_sys_dor_fr.txt"
              obj_lune::LitCataChoisi
           }
         12 { set obj_lune(cata_choisi) "lune_domes_fr.txt"
              obj_lune::LitCataChoisi
           }
         13 { set obj_lune(cata_choisi) "lune_caps_fr.txt"
              obj_lune::LitCataChoisi
           }
         14 { set obj_lune(cata_choisi) "lune_marais_fr.txt"
              obj_lune::LitCataChoisi
           }
         15 { set obj_lune(cata_choisi) "lune_lacs_fr.txt"
              obj_lune::LitCataChoisi
           }
         16 { set obj_lune(cata_choisi) "lune_golfes_fr.txt"
              obj_lune::LitCataChoisi
           }
         17 { set obj_lune(cata_choisi) "lune_mers_fr.txt"
              obj_lune::LitCataChoisi
           }
         18 { set obj_lune(cata_choisi) "lune_ocean_fr.txt"
              obj_lune::LitCataChoisi
           }
         19 { set obj_lune(cata_choisi) "lune_plaine_fr.txt"
              obj_lune::LitCataChoisi
           }
         20 { set obj_lune(cata_choisi) "lune_site_alun_fr.txt"
              obj_lune::LitCataChoisi
           }
         21 { set obj_lune(cata_choisi) "lune_albedo_fr.txt"
              obj_lune::LitCataChoisi
           }
         22 { set obj_lune(cata_choisi) "lune_phenom_transitoires_fr.txt"
              obj_lune::LitCataChoisi
           }
         }
      } else {
         switch -exact -- $obj_lune(goto) {
         1 { set obj_lune(cata_choisi) "lune_reference_gb.txt"
              obj_lune::LitCataChoisi
           }
         2 { set obj_lune(cata_choisi) "lune_crateres_gb.txt"
              obj_lune::LitCataChoisi
           }
         3 { set obj_lune(cata_choisi) "lune_ch_crater_gb.txt"
              obj_lune::LitCataChoisi
           }
         4 { set obj_lune(cata_choisi) "lune_monts_gb.txt"
              obj_lune::LitCataChoisi
           }
         5 { set obj_lune(cata_choisi) "lune_ch_monts_gb.txt"
              obj_lune::LitCataChoisi
           }
         6 { set obj_lune(cata_choisi) "lune_vallees_gb.txt"
              obj_lune::LitCataChoisi
           }
         7 { set obj_lune(cata_choisi) "lune_rainures_gb.txt"
              obj_lune::LitCataChoisi
           }
         8 { set obj_lune(cata_choisi) "lune_sys_rainu_gb.txt"
              obj_lune::LitCataChoisi
           }
         9 { set obj_lune(cata_choisi) "lune_failles_gb.txt"
              obj_lune::LitCataChoisi
           }
         10 { set obj_lune(cata_choisi) "lune_dorsales_gb.txt"
              obj_lune::LitCataChoisi
           }
         11 { set obj_lune(cata_choisi) "lune_sys_dor_gb.txt"
              obj_lune::LitCataChoisi
           }
         12 { set obj_lune(cata_choisi) "lune_domes_gb.txt"
              obj_lune::LitCataChoisi
           }
         13 { set obj_lune(cata_choisi) "lune_caps_gb.txt"
              obj_lune::LitCataChoisi
           }
         14 { set obj_lune(cata_choisi) "lune_marais_gb.txt"
              obj_lune::LitCataChoisi
           }
         15 { set obj_lune(cata_choisi) "lune_lacs_gb.txt"
              obj_lune::LitCataChoisi
           }
         16 { set obj_lune(cata_choisi) "lune_golfes_gb.txt"
              obj_lune::LitCataChoisi
           }
         17 { set obj_lune(cata_choisi) "lune_mers_gb.txt"
              obj_lune::LitCataChoisi
           }
         18 { set obj_lune(cata_choisi) "lune_ocean_gb.txt"
              obj_lune::LitCataChoisi
           }
         19 { set obj_lune(cata_choisi) "lune_plaine_gb.txt"
              obj_lune::LitCataChoisi
           }
         20 { set obj_lune(cata_choisi) "lune_site_alun_gb.txt"
              obj_lune::LitCataChoisi
           }
         21 { set obj_lune(cata_choisi) "lune_albedo_gb.txt"
              obj_lune::LitCataChoisi
            }
         22 { set obj_lune(cata_choisi) "lune_phenom_transitoires_gb.txt"
              obj_lune::LitCataChoisi
           }
         }
      }
   }

   #
   # obj_lune::AfficheRectangleCarteChoisie
   # Affichage du rectangle et de la carte du site choisi
   #
   proc AfficheRectangleCarteChoisie { } {
      global color obj_lune zone

      #--- Charge les coordonnees pointees dans l'image image_cartes_lune
      bind $zone(image_cartes_lune) <Motion> {
         #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
         set xy [::audace::screen2Canvas [list %x %y]]
         set x [lindex $xy 0]
         set y [lindex $xy 1]
         #--- Traitement des coordonnees x et y
         if { ($y>"4") && ($y<"40") } {
            if { ($x>"54") && ($x<"83") } {
               set obj_lune(n_carte) "1"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar01$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 57 7 81 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "2"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar02$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 7 108 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "3"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar03$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 7 134 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "4"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar04$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 7 161 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "5"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar05$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 7 187 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "6"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar06$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 7 214 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"245") } {
               set obj_lune(n_carte) "7"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar07$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 7 243 38] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"40") && ($y<"77") } {
            if { ($x>"23") && ($x<"57") } {
               set obj_lune(n_carte) "8"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar08$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 26 43 55 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "9"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar09$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 43 81 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "10"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar10$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 43 108 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "11"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar11$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 43 134 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "12"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar12$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 43 161 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "13"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar13$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 43 187 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "14"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar14$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 43 214 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "15"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar15$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 43 240 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"275") } {
               set obj_lune(n_carte) "16"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar16$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 43 273 75] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"77") && ($y<"112") } {
            if { ($x>"4") && ($x<"30") } {
               set obj_lune(n_carte) "17"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar17$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 7 80 28 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"30") && ($x<"57") } {
               set obj_lune(n_carte) "18"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar18$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 33 80 55 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "19"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar19$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 80 81 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "20"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar20$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 80 108 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "21"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar21$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 80 134 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "22"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar22$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 80 161 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "23"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar23$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 80 187 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "24"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar24$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 80 214 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "25"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar25$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 80 240 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"269") } {
               set obj_lune(n_carte) "26"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar26$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 80 267 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"269") && ($x<"295") } {
               set obj_lune(n_carte) "27"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar27$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 272 80 293 110] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"112") && ($y<"148") } {
            if { ($x>"4") && ($x<"30") } {
               set obj_lune(n_carte) "28"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar28$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 7 115 28 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"30") && ($x<"57") } {
               set obj_lune(n_carte) "29"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar29$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 33 115 55 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "30"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar30$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 115 81 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "31"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar31$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 115 108 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "32"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar32$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 115 134 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "33"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar33$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 115 161 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "34"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar34$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 165 115 187 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "35"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar35$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 115 214 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "36"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar36$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 115 240 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"269") } {
               set obj_lune(n_carte) "37"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar37$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 115 267 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"269") && ($x<"295") } {
               set obj_lune(n_carte) "38"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar38$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 272 115 293 146] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"148") && ($y<"185") } {
            if { ($x>"4") && ($x<"30") } {
               set obj_lune(n_carte) "39"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar39$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 7 151 28 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"30") && ($x<"57") } {
               set obj_lune(n_carte) "40"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar40$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 33 151 55 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "41"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar41$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 151 81 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "42"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar42$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 151 108 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "43"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar43$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 151 134 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "44"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar44$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 151 161 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "45"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar45$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 151 187 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "46"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar46$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 151 214 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "47"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar47$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 151 240 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"269") } {
               set obj_lune(n_carte) "48"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar48$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 151 267 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"269") && ($x<"295") } {
               set obj_lune(n_carte) "49"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar49$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 272 151 293 183] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"185") && ($y<"221") } {
            if { ($x>"4") && ($x<"30") } {
               set obj_lune(n_carte) "50"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar50$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 7 188 28 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"30") && ($x<"57") } {
               set obj_lune(n_carte) "51"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar51$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 33 188 55 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "52"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar52$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 188 81 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "53"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar53$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 188 108 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "54"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar54$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 188 134 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "55"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar55$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 188 161 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "56"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar56$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 188 187 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "57"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar57$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 188 214 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "58"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar58$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 188 240 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"269") } {
               set obj_lune(n_carte) "59"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar59$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 188 267 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"269") && ($x<"295") } {
               set obj_lune(n_carte) "60"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar60$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 272 188 293 219] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"221") && ($y<"257") } {
            if { ($x>"23") && ($x<"57") } {
               set obj_lune(n_carte) "61"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar61$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 27 224 55 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"57") && ($x<"83") } {
               set obj_lune(n_carte) "62"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar62$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 60 224 81 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "63"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar63$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 224 108 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "64"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar64$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 224 134 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "65"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar65$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 224 161 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "66"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar66$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 224 187 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "67"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar67$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 224 214 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"242") } {
               set obj_lune(n_carte) "68"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar68$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 224 240 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"242") && ($x<"275") } {
               set obj_lune(n_carte) "69"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar69$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 245 224 274 255] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"257") && ($y<"293") } {
            if { ($x>"54") && ($x<"83") } {
               set obj_lune(n_carte) "70"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar70$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 57 260 81 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"83") && ($x<"110") } {
               set obj_lune(n_carte) "71"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar71$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 86 260 108 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"110") && ($x<"136") } {
               set obj_lune(n_carte) "72"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar72$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 113 260 134 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"136") && ($x<"163") } {
               set obj_lune(n_carte) "73"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar73$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 139 260 161 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"163") && ($x<"189") } {
               set obj_lune(n_carte) "74"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar74$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 166 260 187 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"189") && ($x<"216") } {
               set obj_lune(n_carte) "75"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar75$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 192 260 214 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } elseif { ($x>"216") && ($x<"245") } {
               set obj_lune(n_carte) "76"
               $obj_lune(onglet3).frame8.labURL7 configure -text "$obj_lune(n_carte)" -fg $color(red)
               bind $zone(image_cartes_lune) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie) $obj_lune(n_carte)
                  set obj_lune(carte_choisie) "ar76$obj_lune(extension_cartes)"
                  ::obj_lune::DessineRectangle [list 219 260 243 291] $color(red)
                  ::obj_lune::AfficheRepereSite
                  ::obj_lune::AfficheCarteChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } else {
            $obj_lune(onglet3).frame8.labURL7 configure -text "-"
         }
      }
   }

   #
   # obj_lune::AffichePolygoneCarteChoisie
   # Affichage du polygone et de la carte du site choisi
   #
   proc AffichePolygoneCarteChoisie { } {
      global color obj_lune zone

      #--- Charge les coordonnees pointees dans l'image_cartes_lune
      bind $zone(image4a) <Motion> {
         #--- Transforme les coordonnees de la souris (%x,%y) en coordonnees canvas (x,y)
         set xy [::audace::screen2Canvas [list %x %y]]
         set x [lindex $xy 0]
         set y [lindex $xy 1]
         #--- Traitement des coordonnees x et y
         if { ($y>"8") && ($y<"54") } {
            if { ($x>"56") && ($x<"149") } {
               set obj_lune(n_carte_lib) "I"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib77$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 46 40 95 18 147 10 147 34 107 43 71 65 46 40] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } elseif { ($x>"149") && ($x<"242") } {
               set obj_lune(n_carte_lib) "II"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib78$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 151 10 207 20 251 40 227 65 194 43 151 34 151 10] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } else {
               $obj_lune(onglet4).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"54") && ($y<"148") } {
            if { ($x>"10") && ($x<"56") } {
               set obj_lune(n_carte_lib) "VIII"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib84$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 12 146 22 91 41 45 66 69 43 101 34 146 12 146] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } elseif { ($x>"242") && ($x<"288") } {
               set obj_lune(n_carte_lib) "III"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib79$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 256 45 278 91 286 146 264 146 257 105 232 69 256 45] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } else {
               $obj_lune(onglet4).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"148") && ($y<"242") } {
            if { ($x>"10") && ($x<"56") } {
               set obj_lune(n_carte_lib) "VII"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib83$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 42 251 21 207 12 150 34 150 42 193 66 227 42 251] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } elseif { ($x>"242") && ($x<"288") } {
               set obj_lune(n_carte_lib) "IV"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib80$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 286 150 279 202 257 252 233 227 257 191 264 150 286 150] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } else {
               $obj_lune(onglet4).frame8.labURL7 configure -text "-"
            }
         } elseif { ($y>"242") && ($y<"288") } {
            if { ($x>"56") && ($x<"149") } {
               set obj_lune(n_carte_lib) "VI"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib82$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 147 286 95 277 47 256 72 232 104 255 147 263 147 286] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } elseif { ($x>"149") && ($x<"242") } {
               set obj_lune(n_carte_lib) "V"
               $obj_lune(onglet4).frame8.labURL7 configure -text "$obj_lune(n_carte_lib)" -fg $color(red)
               bind $zone(image4a) <ButtonPress-1> {
                  set obj_lune(n_carte_choisie_lib) $obj_lune(n_carte_lib)
                  set obj_lune(carte_choisie_lib) "lib81$obj_lune(extension_cartes)"
                  ::obj_lune::DessinePolygone [list 252 257 207 277 151 286 151 263 197 254 228 231 252 257] $color(red)
                  ::obj_lune::AfficheRepereSite_lib
                  ::obj_lune::AfficheCarte_libChoisie
               }
            } else {
               $obj_lune(onglet3).frame8.labURL7 configure -text "-"
            }
         } else {
            $obj_lune(onglet3).frame8.labURL7 configure -text "-"
         }
      }
   }

   #
   # obj_lune::AffichePremiereCarte
   # Affichage de la premiere carte de la liste dans le bon onglet
   #
   proc AffichePremiereCarte { } {
      global obj_lune

      for {set i 1} {$i <= 84} {incr i} {
         if { $i <= 76 } {
            if { $obj_lune(n1) == "$i" } {
               if { ($i >= "1") && ($i <= "9") } {
                  set obj_lune(carte_choisie) "ar0$obj_lune(n1)$obj_lune(extension_cartes)"
               } else {
                  set obj_lune(carte_choisie) "ar$obj_lune(n1)$obj_lune(extension_cartes)"
               }
               ::obj_lune::EffaceRectangleBleu_Rouge_Carto
               ::obj_lune::AfficheRepereSite
               ::obj_lune::AfficheCarteChoisie
               ::obj_lune::AfficheRepereSite_Bind
            }
         } else {
            if { $obj_lune(lib_n1) == "$i" } {
               set obj_lune(carte_choisie_lib) "lib$obj_lune(lib_n1)$obj_lune(extension_cartes)"
               ::obj_lune::EffaceRectangleBleu_Rouge_Lib
               ::obj_lune::AfficheRepereSite_lib
               ::obj_lune::AfficheCarte_libChoisie
               ::obj_lune::AfficheRepereSite_lib_Bind
            }
         }
      }
   }

   #
   # obj_lune::AfficheCarteChoisie
   # Affichage de la carte du site choisi
   #
   proc AfficheCarteChoisie { } {
      global audace obj_lune zone

      #--- Chargement de l'image dans le buffer
      set num [ catch { buf$obj_lune(bufNoCartePage) \
         load [ file join $audace(rep_userCatalog) $obj_lune(rep_cartes) $obj_lune(carte_choisie) ] } msg ]
      #--- Gestion des erreurs
      if { $num == "1" } {
         #--- Les cartes de la Lune ne sont pas disponibles
         ::obj_lune::Manque_Cartes
      } else {
         #--- Calcul des dimensions de l'image
         set largeur [ buf$obj_lune(bufNoCartePage) getpixelswidth ]
         set hauteur [ buf$obj_lune(bufNoCartePage) getpixelsheight ]
         #--- Affichage de l'image dans le canvas
         $zone(image1) create image 0 0 -anchor nw -tag display
         $zone(image1) itemconfigure display -image imagevisu10000
         $zone(image1) configure -scrollregion [list 0 0 $largeur $hauteur ]
         visu$obj_lune(visuNoCartePage) cut { 255 0 255 0 255 0 }
         visu$obj_lune(visuNoCartePage) disp
      }
   }

   #
   # obj_lune::AfficheCarte_libChoisie
   # Affichage de la carte de librations du site choisi
   #
   proc AfficheCarte_libChoisie { } {
      global audace obj_lune zone

      #--- Chargement de l'image dans le buffer
      set num [ catch { buf$obj_lune(bufNoCarteLibrationPage) \
         load [ file join $audace(rep_userCatalog) $obj_lune(rep_cartes) $obj_lune(carte_choisie_lib) ] } msg ]
      #--- Gestion des erreurs
      if { $num == "1" } {
         #--- Les cartes de la Lune ne sont pas disponibles
         ::obj_lune::Manque_Cartes
      } else {
         #--- Calcul des dimensions de l'image
         set largeur [ buf$obj_lune(bufNoCarteLibrationPage) getpixelswidth ]
         set hauteur [ buf$obj_lune(bufNoCarteLibrationPage) getpixelsheight ]
         #--- Affichage de l'image dans le canvas
         $zone(image4b) create image 0 0 -anchor nw -tag display
         $zone(image4b) itemconfigure display -image imagevisu10001
         $zone(image4b) configure -scrollregion [list 0 0 $largeur $hauteur ]
         visu$obj_lune(visuNoCarteLibrationPage) cut { 255 0 255 0 255 0 }
         visu$obj_lune(visuNoCarteLibrationPage) disp
      }
   }

   #
   # ::obj_lune::Manque_Cartes
   # Invite au telechargement des cartes de la Lune
   #
   proc Manque_Cartes { } {
      variable This
      global audace caption color obj_lune

      if [ winfo exists $This.manque_cartes ] {
         destroy $This.manque_cartes
      }
      toplevel $This.manque_cartes
      wm transient $This.manque_cartes $This
      wm title $This.manque_cartes "$caption(obj_lune2,cartographie)"
      set posx_maj [ lindex [ split [ wm geometry $This ] "+" ] 1 ]
      set posy_maj [ lindex [ split [ wm geometry $This ] "+" ] 2 ]
      wm geometry $This.manque_cartes +[ expr $posx_maj + 150 ]+[ expr $posy_maj + 190 ]
      wm resizable $This.manque_cartes 0 0
      set fg $color(blue)

      #--- Cree l'affichage du message
      label $This.manque_cartes.lab1 -text "$caption(obj_lune2,manque_cartes_1)"
      pack $This.manque_cartes.lab1 -padx 10 -pady 2
      label $This.manque_cartes.labURL2 -text "$caption(obj_lune2,manque_cartes_2)" -fg $fg
      pack $This.manque_cartes.labURL2 -padx 10 -pady 2
      label $This.manque_cartes.lab3 -text "$caption(obj_lune2,manque_cartes_3)"
      pack $This.manque_cartes.lab3 -padx 10 -pady 2
      label $This.manque_cartes.lab4 -text \
         [ format $caption(obj_lune2,manque_cartes_4) $audace(rep_userCatalog) ]
      pack $This.manque_cartes.lab4 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $This.manque_cartes

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $This.manque_cartes.labURL2 <ButtonPress-1> {
         set filename "$caption(obj_lune2,manque_cartes_2)"
         ::audace::Lance_Site_htm $filename
      }
      bind $This.manque_cartes.labURL2 <Enter> {
         set fg2 $color(purple)
         $::obj_lune::This.manque_cartes.labURL2 configure -fg $fg2
      }
      bind $This.manque_cartes.labURL2 <Leave> {
         set fg3 $color(blue)
         $::obj_lune::This.manque_cartes.labURL2 configure -fg $fg3
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This.manque_cartes
   }

   #
   # obj_lune::AfficheRepereSite
   # Affichage du rectangle de la carte du site choisi et de son numero
   #
   proc AfficheRepereSite { } {
      global color obj_lune

      #--- Affichage du numero de la carte choisie
      catch {
         if { $obj_lune(n_carte) != "-" } {
            $obj_lune(onglet3).frame7.labURL5 configure -text "$obj_lune(n_carte_choisie)" -fg $color(red)
         }
      }

      catch {
         for {set i 1} {$i <= $obj_lune(nbre_carte) } {incr i} {
            switch -exact -- $obj_lune(n$i) {
            0 {
              }
            1 { ::obj_lune::DessineRectangle [list 54 4 83 40] $color(blue)
              }
            2 { ::obj_lune::DessineRectangle [list 83 4 110 40] $color(blue)
              }
            3 { ::obj_lune::DessineRectangle [list 110 4 136 40] $color(blue)
              }
            4 { ::obj_lune::DessineRectangle [list 136 4 163 40] $color(blue)
              }
            5 { ::obj_lune::DessineRectangle [list 163 4 189 40] $color(blue)
              }
            6 { ::obj_lune::DessineRectangle [list 189 4 216 40] $color(blue)
              }
            7 { ::obj_lune::DessineRectangle [list 216 4 245 40] $color(blue)
              }
            8 { ::obj_lune::DessineRectangle [list 23 40 57 77] $color(blue)
              }
            9 { ::obj_lune::DessineRectangle [list 57 40 83 77] $color(blue)
              }
            10 { ::obj_lune::DessineRectangle [list 83 40 110 77] $color(blue)
              }
            11 { ::obj_lune::DessineRectangle [list 110 40 136 77] $color(blue)
              }
            12 { ::obj_lune::DessineRectangle [list 136 40 163 77] $color(blue)
              }
            13 { ::obj_lune::DessineRectangle [list 163 40 189 77] $color(blue)
              }
            14 { ::obj_lune::DessineRectangle [list 189 40 216 77] $color(blue)
              }
            15 { ::obj_lune::DessineRectangle [list 216 40 242 77] $color(blue)
              }
            16 { ::obj_lune::DessineRectangle [list 242 40 275 77] $color(blue)
              }
            17 { ::obj_lune::DessineRectangle [list 4 77 30 112] $color(blue)
              }
            18 { ::obj_lune::DessineRectangle [list 30 77 57 112] $color(blue)
              }
            19 { ::obj_lune::DessineRectangle [list 57 77 83 112] $color(blue)
              }
            20 { ::obj_lune::DessineRectangle [list 83 77 110 112] $color(blue)
              }
            21 { ::obj_lune::DessineRectangle [list 110 77 136 112] $color(blue)
              }
            22 { ::obj_lune::DessineRectangle [list 136 77 163 112] $color(blue)
              }
            23 { ::obj_lune::DessineRectangle [list 163 77 189 112] $color(blue)
              }
            24 { ::obj_lune::DessineRectangle [list 189 77 216 112] $color(blue)
              }
            25 { ::obj_lune::DessineRectangle [list 216 77 242 112] $color(blue)
              }
            26 { ::obj_lune::DessineRectangle [list 242 77 269 112] $color(blue)
              }
            27 { ::obj_lune::DessineRectangle [list 269 77 295 112] $color(blue)
              }
            28 { ::obj_lune::DessineRectangle [list 4 112 30 148] $color(blue)
              }
            29 { ::obj_lune::DessineRectangle [list 30 112 57 148] $color(blue)
              }
            30 { ::obj_lune::DessineRectangle [list 57 112 83 148] $color(blue)
              }
            31 { ::obj_lune::DessineRectangle [list 83 112 110 148] $color(blue)
              }
            32 { ::obj_lune::DessineRectangle [list 110 112 136 148] $color(blue)
              }
            33 { ::obj_lune::DessineRectangle [list 136 112 163 148] $color(blue)
              }
            34 { ::obj_lune::DessineRectangle [list 163 112 189 148] $color(blue)
              }
            35 { ::obj_lune::DessineRectangle [list 189 112 216 148] $color(blue)
              }
            36 { ::obj_lune::DessineRectangle [list 216 112 242 148] $color(blue)
              }
            37 { ::obj_lune::DessineRectangle [list 242 112 269 148] $color(blue)
              }
            38 { ::obj_lune::DessineRectangle [list 269 112 295 148] $color(blue)
              }
            39 { ::obj_lune::DessineRectangle [list 4 148 30 185] $color(blue)
              }
            40 { ::obj_lune::DessineRectangle [list 30 148 57 185] $color(blue)
              }
            41 { ::obj_lune::DessineRectangle [list 57 148 83 185] $color(blue)
              }
            42 { ::obj_lune::DessineRectangle [list 83 148 110 185] $color(blue)
              }
            43 { ::obj_lune::DessineRectangle [list 110 148 136 185] $color(blue)
              }
            44 { ::obj_lune::DessineRectangle [list 136 148 163 185] $color(blue)
              }
            45 { ::obj_lune::DessineRectangle [list 163 148 189 185] $color(blue)
              }
            46 { ::obj_lune::DessineRectangle [list 189 148 216 185] $color(blue)
              }
            47 { ::obj_lune::DessineRectangle [list 216 148 242 185] $color(blue)
              }
            48 { ::obj_lune::DessineRectangle [list 242 148 269 185] $color(blue)
              }
            49 { ::obj_lune::DessineRectangle [list 269 148 295 185] $color(blue)
              }
            50 { ::obj_lune::DessineRectangle [list 4 185 30 221] $color(blue)
              }
            51 { ::obj_lune::DessineRectangle [list 30 185 57 221] $color(blue)
              }
            52 { ::obj_lune::DessineRectangle [list 57 185 83 221] $color(blue)
              }
            53 { ::obj_lune::DessineRectangle [list 83 185 110 221] $color(blue)
              }
            54 { ::obj_lune::DessineRectangle [list 110 185 136 221] $color(blue)
              }
            55 { ::obj_lune::DessineRectangle [list 136 185 163 221] $color(blue)
              }
            56 { ::obj_lune::DessineRectangle [list 163 185 189 221] $color(blue)
              }
            57 { ::obj_lune::DessineRectangle [list 189 185 216 221] $color(blue)
              }
            58 { ::obj_lune::DessineRectangle [list 216 185 242 221] $color(blue)
              }
            59 { ::obj_lune::DessineRectangle [list 242 185 269 221] $color(blue)
              }
            60 { ::obj_lune::DessineRectangle [list 269 185 295 221] $color(blue)
              }
            61 { ::obj_lune::DessineRectangle [list 24 221 57 257] $color(blue)
              }
            62 { ::obj_lune::DessineRectangle [list 57 221 83 257] $color(blue)
              }
            63 { ::obj_lune::DessineRectangle [list 83 221 110 257] $color(blue)
              }
            64 { ::obj_lune::DessineRectangle [list 110 221 136 257] $color(blue)
              }
            65 { ::obj_lune::DessineRectangle [list 136 221 163 257] $color(blue)
              }
            66 { ::obj_lune::DessineRectangle [list 163 221 189 257] $color(blue)
              }
            67 { ::obj_lune::DessineRectangle [list 189 221 216 257] $color(blue)
              }
            68 { ::obj_lune::DessineRectangle [list 216 221 242 257] $color(blue)
              }
            69 { ::obj_lune::DessineRectangle [list 242 221 276 257] $color(blue)
              }
            70 { ::obj_lune::DessineRectangle [list 54 257 83 293] $color(blue)
              }
            71 { ::obj_lune::DessineRectangle [list 83 257 110 293] $color(blue)
              }
            72 { ::obj_lune::DessineRectangle [list 110 257 136 293] $color(blue)
              }
            73 { ::obj_lune::DessineRectangle [list 136 257 163 293] $color(blue)
              }
            74 { ::obj_lune::DessineRectangle [list 163 257 189 293] $color(blue)
              }
            75 { ::obj_lune::DessineRectangle [list 189 257 216 293] $color(blue)
              }
            76 { ::obj_lune::DessineRectangle [list 216 257 245 293] $color(blue)
              }
            }
         }
      }
   }

   #
   # obj_lune::AfficheRepereSite_Bind
   # Affichage du rectangle de la carte choisie et de son numero
   #
   proc AfficheRepereSite_Bind { } {
      global color obj_lune

      catch {
         for {set i 1} {$i <= $obj_lune(nbre_carte) } {incr i} {
            switch -exact -- $obj_lune(n1) {
            0 {
              }
            1 { ::obj_lune::DessineRectangle_Bind [list 57 7 81 38] $color(red)
              }
            2 { ::obj_lune::DessineRectangle_Bind [list 86 7 108 38] $color(red)
              }
            3 { ::obj_lune::DessineRectangle_Bind [list 113 7 134 38] $color(red)
              }
            4 { ::obj_lune::DessineRectangle_Bind [list 139 7 161 38] $color(red)
              }
            5 { ::obj_lune::DessineRectangle_Bind [list 166 7 187 38] $color(red)
              }
            6 { ::obj_lune::DessineRectangle_Bind [list 192 7 214 38] $color(red)
              }
            7 { ::obj_lune::DessineRectangle_Bind [list 219 7 243 38] $color(red)
              }
            8 { ::obj_lune::DessineRectangle_Bind [list 26 43 55 75] $color(red)
              }
            9 { ::obj_lune::DessineRectangle_Bind [list 60 43 81 75] $color(red)
              }
            10 { ::obj_lune::DessineRectangle_Bind [list 86 43 108 75] $color(red)
              }
            11 { ::obj_lune::DessineRectangle_Bind [list 113 43 134 75] $color(red)
              }
            12 { ::obj_lune::DessineRectangle_Bind [list 139 43 161 75] $color(red)
              }
            13 { ::obj_lune::DessineRectangle_Bind [list 166 43 187 75] $color(red)
              }
            14 { ::obj_lune::DessineRectangle_Bind [list 192 43 214 75] $color(red)
              }
            15 { ::obj_lune::DessineRectangle_Bind [list 219 43 240 75] $color(red)
              }
            16 { ::obj_lune::DessineRectangle_Bind [list 245 43 273 75] $color(red)
              }
            17 { ::obj_lune::DessineRectangle_Bind [list 7 80 28 110] $color(red)
              }
            18 { ::obj_lune::DessineRectangle_Bind [list 33 80 55 110] $color(red)
              }
            19 { ::obj_lune::DessineRectangle_Bind [list 60 80 81 110] $color(red)
              }
            20 { ::obj_lune::DessineRectangle_Bind [list 86 80 108 110] $color(red)
              }
            21 { ::obj_lune::DessineRectangle_Bind [list 113 80 134 110] $color(red)
              }
            22 { ::obj_lune::DessineRectangle_Bind [list 139 80 161 110] $color(red)
              }
            23 { ::obj_lune::DessineRectangle_Bind [list 166 80 187 110] $color(red)
              }
            24 { ::obj_lune::DessineRectangle_Bind [list 192 80 214 110] $color(red)
              }
            25 { ::obj_lune::DessineRectangle_Bind [list 219 80 240 110] $color(red)
              }
            26 { ::obj_lune::DessineRectangle_Bind [list 245 80 267 110] $color(red)
              }
            27 { ::obj_lune::DessineRectangle_Bind [list 272 80 293 110] $color(red)
              }
            28 { ::obj_lune::DessineRectangle_Bind [list 7 115 28 146] $color(red)
              }
            29 { ::obj_lune::DessineRectangle_Bind [list 33 115 55 146] $color(red)
              }
            30 { ::obj_lune::DessineRectangle_Bind [list 60 115 81 146] $color(red)
              }
            31 { ::obj_lune::DessineRectangle_Bind [list 86 115 108 146] $color(red)
              }
            32 { ::obj_lune::DessineRectangle_Bind [list 113 115 134 146] $color(red)
              }
            33 { ::obj_lune::DessineRectangle_Bind [list 139 115 161 146] $color(red)
              }
            34 { ::obj_lune::DessineRectangle_Bind [list 165 115 187 146] $color(red)
              }
            35 { ::obj_lune::DessineRectangle_Bind [list 192 115 214 146] $color(red)
              }
            36 { ::obj_lune::DessineRectangle_Bind [list 219 115 240 146] $color(red)
              }
            37 { ::obj_lune::DessineRectangle_Bind [list 245 115 267 146] $color(red)
              }
            38 { ::obj_lune::DessineRectangle_Bind [list 272 115 293 146] $color(red)
              }
            39 { ::obj_lune::DessineRectangle_Bind [list 7 151 28 183] $color(red)
              }
            40 { ::obj_lune::DessineRectangle_Bind [list 33 151 55 183] $color(red)
              }
            41 { ::obj_lune::DessineRectangle_Bind [list 60 151 81 183] $color(red)
              }
            42 { ::obj_lune::DessineRectangle_Bind [list 86 151 108 183] $color(red)
              }
            43 { ::obj_lune::DessineRectangle_Bind [list 113 151 134 183] $color(red)
              }
            44 { ::obj_lune::DessineRectangle_Bind [list 139 151 161 183] $color(red)
              }
            45 { ::obj_lune::DessineRectangle_Bind [list 166 151 187 183] $color(red)
              }
            46 { ::obj_lune::DessineRectangle_Bind [list 192 151 214 183] $color(red)
              }
            47 { ::obj_lune::DessineRectangle_Bind [list 219 151 240 183] $color(red)
              }
            48 { ::obj_lune::DessineRectangle_Bind [list 245 151 267 183] $color(red)
              }
            49 { ::obj_lune::DessineRectangle_Bind [list 272 151 293 183] $color(red)
              }
            50 { ::obj_lune::DessineRectangle_Bind [list 7 188 28 219] $color(red)
              }
            51 { ::obj_lune::DessineRectangle_Bind [list 33 188 55 219] $color(red)
              }
            52 { ::obj_lune::DessineRectangle_Bind [list 60 188 81 219] $color(red)
              }
            53 { ::obj_lune::DessineRectangle_Bind [list 86 188 108 219] $color(red)
              }
            54 { ::obj_lune::DessineRectangle_Bind [list 113 188 134 219] $color(red)
              }
            55 { ::obj_lune::DessineRectangle_Bind [list 139 188 161 219] $color(red)
              }
            56 { ::obj_lune::DessineRectangle_Bind [list 166 188 187 219] $color(red)
              }
            57 { ::obj_lune::DessineRectangle_Bind [list 192 188 214 219] $color(red)
              }
            58 { ::obj_lune::DessineRectangle_Bind [list 219 188 240 219] $color(red)
              }
            59 { ::obj_lune::DessineRectangle_Bind [list 245 188 267 219] $color(red)
              }
            60 { ::obj_lune::DessineRectangle_Bind [list 272 188 293 219] $color(red)
              }
            61 { ::obj_lune::DessineRectangle_Bind [list 27 224 55 255] $color(red)
              }
            62 { ::obj_lune::DessineRectangle_Bind [list 60 224 81 255] $color(red)
              }
            63 { ::obj_lune::DessineRectangle_Bind [list 86 224 108 255] $color(red)
              }
            64 { ::obj_lune::DessineRectangle_Bind [list 113 224 134 255] $color(red)
              }
            65 { ::obj_lune::DessineRectangle_Bind [list 139 224 161 255] $color(red)
              }
            66 { ::obj_lune::DessineRectangle_Bind [list 166 224 187 255] $color(red)
              }
            67 { ::obj_lune::DessineRectangle_Bind [list 192 224 214 255] $color(red)
              }
            68 { ::obj_lune::DessineRectangle_Bind [list 219 224 240 255] $color(red)
              }
            69 { ::obj_lune::DessineRectangle_Bind [list 245 224 274 255] $color(red)
              }
            70 { ::obj_lune::DessineRectangle_Bind [list 57 260 81 291] $color(red)
              }
            71 { ::obj_lune::DessineRectangle_Bind [list 86 260 108 291] $color(red)
              }
            72 { ::obj_lune::DessineRectangle_Bind [list 113 260 134 291] $color(red)
              }
            73 { ::obj_lune::DessineRectangle_Bind [list 139 260 161 291] $color(red)
              }
            74 { ::obj_lune::DessineRectangle_Bind [list 166 260 187 291] $color(red)
              }
            75 { ::obj_lune::DessineRectangle_Bind [list 192 260 214 291] $color(red)
              }
            76 { ::obj_lune::DessineRectangle_Bind [list 219 260 243 291] $color(red)
              }
            }
         }
         $obj_lune(onglet3).frame7.labURL5 configure -text "$obj_lune(n1)" -fg $color(red)
         set obj_lune(n_carte_choisie) $obj_lune(n1)
      }
   }

   #
   # obj_lune::AfficheRepereSite_lib
   # Affichage du polygone de la carte de librations du site choisi et de son numero
   #
   proc AfficheRepereSite_lib { } {
      global color obj_lune

      #--- Affichage du numero de la carte de librations choisie
      catch {
         if { $obj_lune(n_carte_lib) != "-" } {
            $obj_lune(onglet4).frame7.labURL5 configure -text "$obj_lune(n_carte_choisie_lib)" -fg $color(red)
         }
      }

      catch {
         for {set i 1} {$i <= $obj_lune(nbre_carte_lib) } {incr i} {
            switch -exact -- $obj_lune(lib_n$i) {
            0 {
              }
            77 { ::obj_lune::DessinePolygone [list 43 40 95 16 149 8 149 36 107 45 71 67 43 40] $color(blue)
              }
            78 { ::obj_lune::DessinePolygone [list 149 8 207 18 254 39 227 67 194 45 149 36 149 8] $color(blue)
              }
            79 { ::obj_lune::DessinePolygone [list 256 42 280 91 288 148 262 148 255 105 229 69 256 42] $color(blue)
              }
            80 { ::obj_lune::DessinePolygone [list 288 148 281 202 257 255 230 227 255 191 262 148 288 148] $color(blue)
              }
            81 { ::obj_lune::DessinePolygone [list 254 257 207 279 149 288 149 261 197 252 228 229 254 257] $color(blue)
              }
            82 { ::obj_lune::DessinePolygone [list 149 288 95 279 44 256 72 229 104 253 149 261 149 288] $color(blue)
              }
            83 { ::obj_lune::DessinePolygone [list 42 254 19 207 10 148 36 148 44 193 69 227 42 254] $color(blue)
              }
            84 { ::obj_lune::DessinePolygone [list 10 148 19 91 40 42 69 69 45 101 36 148 10 148] $color(blue)
              }
            }
         }
      }
   }

   #
   # obj_lune::AfficheRepereSite_lib_Bind
   # Affichage du polygone de la carte de librations choisie et de son numero
   #
   proc AfficheRepereSite_lib_Bind { } {
      global color obj_lune

      catch {
         for {set i 1} {$i <= $obj_lune(nbre_carte_lib) } {incr i} {
            switch -exact -- $obj_lune(lib_n1) {
            0 {
              }
            77 { ::obj_lune::DessinePolygone_Bind [list 46 40 95 18 147 10 147 34 107 43 71 65 46 40] $color(red)
              }
            78 { ::obj_lune::DessinePolygone_Bind [list 151 10 207 20 251 40 227 65 194 43 151 34 151 10] $color(red)
              }
            79 { ::obj_lune::DessinePolygone_Bind [list 256 45 278 91 286 146 264 146 257 105 232 69 256 45] $color(red)
              }
            80 { ::obj_lune::DessinePolygone_Bind [list 286 150 279 202 257 252 233 227 257 191 264 150 286 150] $color(red)
              }
            81 { ::obj_lune::DessinePolygone_Bind [list 252 257 207 277 151 286 151 263 197 254 228 231 252 257] $color(red)
              }
            82 { ::obj_lune::DessinePolygone_Bind [list 147 286 95 277 47 256 72 232 104 255 147 263 147 286] $color(red)
              }
            83 { ::obj_lune::DessinePolygone_Bind [list 42 251 21 207 12 150 34 150 42 193 66 227 42 251] $color(red)
              }
            84 { ::obj_lune::DessinePolygone_Bind [list 12 146 22 91 41 45 66 69 43 101 34 146 12 146] $color(red)
              }
            }
         }
         ::obj_lune::ConversionNumeroCarte_lib1_Bind
         $obj_lune(onglet4).frame7.labURL5 configure -text "$obj_lune(lib_n1)" -fg $color(red)
         set obj_lune(n_carte_choisie_lib) $obj_lune(lib_n1)
         ::obj_lune::ConversionNumeroCarte_lib1
      }
   }

   #
   # obj_lune::EffaceRectangleBleu_Rouge
   # Efface les cadres bleus et/ou rouges de la precedente selection de tous les onglets
   #
   proc EffaceRectangleBleu_Rouge { } {
      global obj_lune

      #--- Efface les rectangles des precedentes cartes selectionnees
      $obj_lune(onglet3).frame4.image_cartes_lune delete cadres
      $obj_lune(onglet4).frame4.image4a delete cadres

      #--- Efface les numeros des cartes choisies et de la carte courante
      $obj_lune(onglet3).frame7.labURL5 configure -text "-"
      $obj_lune(onglet3).frame8.labURL7 configure -text "-"
      $obj_lune(onglet4).frame7.labURL5 configure -text "-"
      $obj_lune(onglet4).frame8.labURL7 configure -text "-"
   }

   #
   # obj_lune::EffaceRectangleBleu_Rouge_Carto
   # Efface les cadres bleus et/ou rouges de la precedente selection de l'onglet cartographie
   #
   proc EffaceRectangleBleu_Rouge_Carto { } {
      global obj_lune

      #--- Efface les rectangles des precedentes cartes selectionnees
      $obj_lune(onglet3).frame4.image_cartes_lune delete cadres

      #--- Efface les numeros des cartes choisies et de la carte courante
      $obj_lune(onglet3).frame7.labURL5 configure -text "-"
      $obj_lune(onglet3).frame8.labURL7 configure -text "-"
   }

   #
   # obj_lune::EffaceRectangleBleu_Rouge_Lib
   # Efface les cadres bleus et/ou rouges de la precedente selection de l'onglet carte de librations
   #
   proc EffaceRectangleBleu_Rouge_Lib { } {
      global obj_lune

      #--- Efface les rectangles des precedentes cartes selectionnees
      $obj_lune(onglet4).frame4.image4a delete cadres

      #--- Efface les numeros des cartes choisies et de la carte courante
      $obj_lune(onglet4).frame7.labURL5 configure -text "-"
      $obj_lune(onglet4).frame8.labURL7 configure -text "-"
   }

   #
   # obj_lune::DessineRectangle
   # Encadre la carte choisie d'un rectangle
   #
   proc DessineRectangle { rect couleur } {
      global color obj_lune

      #--- Recupere les coordonnees
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]

      if { $couleur == "$color(red)" } {
         #--- Efface les rectangles des precedentes cartes selectionnees
         $obj_lune(onglet3).frame4.image_cartes_lune delete cadres
      }
      #--- Creation du cadre, le tag "cadres" permettra par la suite de l'effacer facilement
      $obj_lune(onglet3).frame4.image_cartes_lune create rectangle [expr $x1] [expr $y1] \
            [expr $x2] [expr $y2] -outline $couleur -tags cadres -width 2.0
   }

   #
   # obj_lune::DessineRectangle_Bind
   # Encadre la carte choisie d'un rectangle
   #
   proc DessineRectangle_Bind { rect couleur } {
      global obj_lune

      #--- Recupere les coordonnees
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]

      #--- Creation du cadre, le tag "cadres" permettra par la suite de l'effacer facilement
      $obj_lune(onglet3).frame4.image_cartes_lune create rectangle [expr $x1] [expr $y1] \
            [expr $x2] [expr $y2] -outline $couleur -tags cadres -width 2.0
   }

   #
   # obj_lune::DessinePolygone
   # Encadre la carte choisie d'un polygone
   #
   proc DessinePolygone { rect_lib couleur_lib } {
      global color obj_lune

      #--- Recupere les coordonnees
      set x1 [lindex $rect_lib 0]
      set y1 [lindex $rect_lib 1]
      set x2 [lindex $rect_lib 2]
      set y2 [lindex $rect_lib 3]
      set x3 [lindex $rect_lib 4]
      set y3 [lindex $rect_lib 5]
      set x4 [lindex $rect_lib 6]
      set y4 [lindex $rect_lib 7]
      set x5 [lindex $rect_lib 8]
      set y5 [lindex $rect_lib 9]
      set x6 [lindex $rect_lib 10]
      set y6 [lindex $rect_lib 11]
      set x7 [lindex $rect_lib 12]
      set y7 [lindex $rect_lib 13]

      if { $couleur_lib == "$color(red)" } {
         #--- Efface les polygones des precedentes cartes selectionnees
         $obj_lune(onglet4).frame4.image4a delete cadres
      }
      #--- Creation du cadre, le tag "cadres" permettra par la suite de l'effacer facilement
      $obj_lune(onglet4).frame4.image4a create line [expr $x1] [expr $y1] [expr $x2] [expr $y2] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x2] [expr $y2] [expr $x3] [expr $y3] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x3] [expr $y3] [expr $x4] [expr $y4] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x4] [expr $y4] [expr $x5] [expr $y5] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x5] [expr $y5] [expr $x6] [expr $y6] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x6] [expr $y6] [expr $x7] [expr $y7] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x7] [expr $y7] [expr $x1] [expr $y1] -fill $couleur_lib -tags cadres -width 2.0
   }

   #
   # obj_lune::DessinePolygone_Bind
   # Encadre la carte choisie d'un polygone
   #
   proc DessinePolygone_Bind { rect_lib couleur_lib } {
      global obj_lune

      #--- Recupere les coordonnees
      set x1 [lindex $rect_lib 0]
      set y1 [lindex $rect_lib 1]
      set x2 [lindex $rect_lib 2]
      set y2 [lindex $rect_lib 3]
      set x3 [lindex $rect_lib 4]
      set y3 [lindex $rect_lib 5]
      set x4 [lindex $rect_lib 6]
      set y4 [lindex $rect_lib 7]
      set x5 [lindex $rect_lib 8]
      set y5 [lindex $rect_lib 9]
      set x6 [lindex $rect_lib 10]
      set y6 [lindex $rect_lib 11]
      set x7 [lindex $rect_lib 12]
      set y7 [lindex $rect_lib 13]

      #--- Creation du cadre, le tag "cadres" permettra par la suite de l'effacer facilement
      $obj_lune(onglet4).frame4.image4a create line [expr $x1] [expr $y1] [expr $x2] [expr $y2] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x2] [expr $y2] [expr $x3] [expr $y3] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x3] [expr $y3] [expr $x4] [expr $y4] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x4] [expr $y4] [expr $x5] [expr $y5] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x5] [expr $y5] [expr $x6] [expr $y6] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x6] [expr $y6] [expr $x7] [expr $y7] -fill $couleur_lib -tags cadres -width 2.0
      $obj_lune(onglet4).frame4.image4a create line [expr $x7] [expr $y7] [expr $x1] [expr $y1] -fill $couleur_lib -tags cadres -width 2.0
   }

   #
   # obj_lune::ConversionNumeroCarte_lib1
   # Converti les numeros romains et numeros arabes (pour la premiere carte de la ligne texte)
   #
   proc ConversionNumeroCarte_lib1 { } {
      global obj_lune

      if { $obj_lune(lib_n1) == "I" } {
         set obj_lune(lib_n1) "77"
      } elseif { $obj_lune(lib_n1) == "II" } {
         set obj_lune(lib_n1) "78"
      } elseif { $obj_lune(lib_n1) == "III" } {
         set obj_lune(lib_n1) "79"
      } elseif { $obj_lune(lib_n1) == "IV" } {
         set obj_lune(lib_n1) "80"
      } elseif { $obj_lune(lib_n1) == "V" } {
         set obj_lune(lib_n1) "81"
      } elseif { $obj_lune(lib_n1) == "VI" } {
         set obj_lune(lib_n1) "82"
      } elseif { $obj_lune(lib_n1) == "VII" } {
         set obj_lune(lib_n1) "83"
      } else {
         set obj_lune(lib_n1) "84"
      }
   }

   #
   # obj_lune::ConversionNumeroCarte_lib1_Bind
   # Converti les numeros arabes et numeros romains (pour la premiere carte de la ligne texte)
   #
   proc ConversionNumeroCarte_lib1_Bind { } {
      global obj_lune

      if { $obj_lune(lib_n1) == "77" } {
         set obj_lune(lib_n1) "I"
      } elseif { $obj_lune(lib_n1) == "78" } {
         set obj_lune(lib_n1) "II"
      } elseif { $obj_lune(lib_n1) == "79" } {
         set obj_lune(lib_n1) "III"
      } elseif { $obj_lune(lib_n1) == "80" } {
         set obj_lune(lib_n1) "IV"
      } elseif { $obj_lune(lib_n1) == "81" } {
         set obj_lune(lib_n1) "V"
      } elseif { $obj_lune(lib_n1) == "82" } {
         set obj_lune(lib_n1) "VI"
      } elseif { $obj_lune(lib_n1) == "83" } {
         set obj_lune(lib_n1) "VII"
      } else {
         set obj_lune(lib_n1) "VIII"
      }
   }

   #
   # obj_lune::ConversionNumeroCarte_lib2
   # Converti les numeros romains et numeros arabes (pour la deuxieme carte de la ligne texte)
   #
   proc ConversionNumeroCarte_lib2 { } {
      global obj_lune

      if { $obj_lune(lib_n2) == "I" } {
         set obj_lune(lib_n2) "77"
      } elseif { $obj_lune(lib_n2) == "II" } {
         set obj_lune(lib_n2) "78"
      } elseif { $obj_lune(lib_n2) == "III" } {
         set obj_lune(lib_n2) "79"
      } elseif { $obj_lune(lib_n2) == "IV" } {
         set obj_lune(lib_n2) "80"
      } elseif { $obj_lune(lib_n2) == "V" } {
         set obj_lune(lib_n2) "81"
      } elseif { $obj_lune(lib_n2) == "VI" } {
         set obj_lune(lib_n2) "82"
      } elseif { $obj_lune(lib_n2) == "VII" } {
         set obj_lune(lib_n2) "83"
      } else {
         set obj_lune(lib_n2) "84"
      }
   }

   #
   # obj_lune::Trait_Carte_lib_et_autres
   # Traitement de l'affichage des cartes de librations avec les cartes normales
   #
   proc Trait_Carte_lib_et_autres { } {
      global obj_lune thissite_lune

      if { ([string range $thissite_lune 90 93] != "    ") & ([string range $thissite_lune 94 97] != "    ") } {
         set obj_lune(nbre_carte_lib) "2"
         set obj_lune(lib_n1) "[string trimright [string range $thissite_lune 90 93] " "]"
         set obj_lune(lib_n2) "[string trimright [string range $thissite_lune 94 97] " "]"
         ::obj_lune::ConversionNumeroCarte_lib1
         ::obj_lune::ConversionNumeroCarte_lib2
         ::obj_lune::AfficheRepereSite_lib
      } elseif { [string range $thissite_lune 90 93] != "    " } {
         set obj_lune(nbre_carte_lib) "1"
         set obj_lune(lib_n1) "[string trimright [string range $thissite_lune 90 93] " "]"
         ::obj_lune::ConversionNumeroCarte_lib1
         ::obj_lune::AfficheRepereSite_lib
      }
   }

}


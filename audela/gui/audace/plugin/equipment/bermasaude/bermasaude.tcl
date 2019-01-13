#
# Fichier : bermasaude.tcl
# Description : Gere la roue a filtres de Laurent BERNASCONI et Robert DELMAS
# Auteur : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: bermasaude.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

#
# Procedures generiques obligatoires (pour configurer tous les plugins camera, telescope, equipement) :
#     initPlugin      : Initialise le plugin
#     getStartFlag    : Retourne l'indicateur de lancement au demarrage
#     getPluginHelp   : Retourne la documentation htm associee
#     getPluginTitle  : Retourne le titre du plugin dans la langue de l'utilisateur
#     getPluginType   : Retourne le type de plugin
#     getPluginOS     : Retourne les OS sous lesquels le plugin fonctionne
#     fillConfigPage  : Affiche la fenetre de configuration de ce plugin
#     createPlugin    : Cree une instance du plugin
#     deletePlugin    : Arrete une instance du plugin et libere les ressources occupees
#     configurePlugin : Configure le plugin
#     isReady         : Informe de l'etat de fonctionnement du plugin
#

# Procedures specifiques a ce plugin :
#     representationRoueAFiltres : Representation graphique de la roue a filtres
#     choixNomBouton             : Choix du nom des boutons (couleur des filtres)
#     choixCouleur               : Choix des couleurs des filtres
#     filtreInit                 : Initialisation de la roue a filtres
#     cmdRoueFiltres             : Commande la roue a filtres
#     filtre_1                   : Positionne le filtre n°1 sur le chemin optique
#     filtre_2                   : Positionne le filtre n°2 sur le chemin optique
#     filtre_3                   : Positionne le filtre n°3 sur le chemin optique
#     filtre_4                   : Positionne le filtre n°4 sur le chemin optique
#     filtre_5                   : Positionne le filtre n°5 sur le chemin optique
#     connectBerMasAude          : Permet de rendre actifs ou inactifs les boutons
#     configureEtatBoutons       : Configure l'etat des boutons de commande des filtres
#     bermasaude_create          : Creation de la liaison serie
#     bermasaude_delete          : Fermeture de la liaison serie
#     bermasaude_reset           : Reset de l'electronique de la roue a filtres
#     bermasaude_v_firmware      : Retourne la version du firmware
#     bermasaude_etat_roue       : Retourne l'etat de la roue (0 a l'arret - 1 en rotation)
#     bermasaude_nbr_filtres     : Retourne le nombre de filtres de la roue
#     bermasaude_aller_a         : Permet d'aller au filtre n
#     bermasaude_position        : Retourne la position du filtre sur le chemin optique
#

namespace eval ::bermasaude {
   package provide bermasaude 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] bermasaude.cap ]

   #------------------------------------------------------------
   #  initPlugin
   #     initialise le plugin
   #------------------------------------------------------------
   proc initPlugin { } {
      global bermasaude conf

      #--- Initialisation
      set bermasaude(connect) "0"
      set bermasaude(attente) "50"

      #--- Cree les variables dans conf(...) si elles n'existent pas
      if { ! [ info exists conf(bermasaude,port) ] }  { set conf(bermasaude,port)  "" }
      if { ! [ info exists conf(bermasaude,combi) ] } { set conf(bermasaude,combi) "0" }
      if { ! [ info exists conf(bermasaude,start) ] } { set conf(bermasaude,start) "0" }
   }

   #------------------------------------------------------------
   #  getPluginTitle
   #     retourne le titre du plugin dans la langue de l'utilisateur
   #
   #  return "Titre du plugin"
   #------------------------------------------------------------
   proc getPluginTitle { } {
      global caption

      return "$caption(bermasaude,titre)"
   }

   #------------------------------------------------------------
   #  getPluginHelp
   #     retourne la documentation du plugin
   #
   #  return "nom_plugin.htm"
   #------------------------------------------------------------
   proc getPluginHelp { } {
      return "bermasaude.htm"
   }

   #------------------------------------------------------------
   #  getPluginType
   #     retourne le type de plugin
   #
   #  return "equipment"
   #------------------------------------------------------------
   proc getPluginType { } {
      return "equipment"
   }

   #------------------------------------------------------------
   #  getPluginOS
   #     retourne le ou les OS de fonctionnement du plugin
   #------------------------------------------------------------
   proc getPluginOS { } {
      return [ list Windows Linux Darwin ]
   }

   #------------------------------------------------------------
   #  getPluginProperty
   #     retourne la valeur de la propriete
   #
   # parametre :
   #    propertyName : nom de la propriete
   # return : valeur de la propriete , ou "" si la propriete n'existe pas
   #------------------------------------------------------------
   proc getPluginProperty { propertyName } {
      switch $propertyName {
         function { return "acquisition" }
      }
   }

   #------------------------------------------------------------
   #  getStartFlag
   #     retourne l'indicateur de lancement au demarrage de Audela
   #
   #  return 0 ou 1
   #------------------------------------------------------------
   proc getStartFlag { } {
      return $::conf(bermasaude,start)
   }

   #------------------------------------------------------------
   #  fillConfigPage
   #     fenetre de configuration du plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc fillConfigPage { frm } {
      variable widget
      global bermasaude caption conf zone

      #--- Je memorise la reference de la frame
      set widget(frm) $frm

      #--- Prise en compte des liaisons
      set widget(list_connexion) [::confLink::getLinkLabels { "serialport" } ]
      if { $conf(bermasaude,port) == "" } {
         set conf(bermasaude,port) [ lindex $widget(list_connexion) 0 ]
      }

      #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
      if { $bermasaude(connect) != 0 && [ lsearch $widget(list_connexion) $conf(bermasaude,port) ] == -1 } {
         lappend widget(list_connexion) $conf(bermasaude,port)
      }

      #--- Copie de conf(...) dans la variable widget
      set widget(port)  $conf(bermasaude,port)
      set widget(combi) [ lindex "$caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj)" \
         $conf(bermasaude,combi) ]

      #--- Choix des couleurs
      ::bermasaude::choixCouleur

      #--- Choix du nom des boutons (couleur des filtres)
      ::bermasaude::choixNomBouton

      #--- Je verifie le contenu de la liste
      if { [ llength $widget(list_connexion) ] > 0 } {
         #--- Si la liste n'est pas vide,
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [ lsearch -exact $widget(list_connexion) $::bermasaude::widget(port) ] == -1 } {
            #--- Si la valeur par defaut n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set ::bermasaude::widget(port) [ lindex $widget(list_connexion) 0 ]
         }
      } else {
         #--- Si la liste est vide, on continue quand meme
      }

      #--- Frame pour le choix de la liaison et de la combinaison
      frame $frm.frame1 -borderwidth 0 -relief raised

         #--- Label du port
         label $frm.frame1.lab1 -text "$caption(bermasaude,port)"
         pack $frm.frame1.lab1 -anchor center -side left -padx 20 -pady 10

         #--- Bouton de configuration des liaisons
         button $frm.frame1.configure -text "$caption(bermasaude,configurer)" -relief raised \
            -command {
               ::confLink::run ::bermasaude::widget(port) { serialport } \
                  "- $caption(bermasaude,controle) - $caption(bermasaude,titre)"
            }
         pack $frm.frame1.configure -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

         #--- Choix du port ou de la liaison
         ComboBox $frm.frame1.port \
            -width [ ::tkutil::lgEntryComboBox $widget(list_connexion) ] \
            -height [ llength $widget(list_connexion) ] \
            -relief sunken         \
            -borderwidth 1         \
            -textvariable ::bermasaude::widget(port) \
            -editable 0            \
            -values $widget(list_connexion)
         pack $frm.frame1.port -anchor center -side left -padx 20 -pady 10

         #--- Definition de la combinaison des filtres
         set list_combobox [ list $caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj) ]
         ComboBox $frm.frame1.combi \
            -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
            -height [ llength $list_combobox ] \
            -relief sunken          \
            -borderwidth 1          \
            -textvariable ::bermasaude::widget(combi) \
            -editable 0             \
            -values $list_combobox
         pack $frm.frame1.combi -anchor center -side right -padx 20 -pady 10

         #--- Label de la combinaison
         label $frm.frame1.lab2 -text "$caption(bermasaude,bermasaude_combinaison)"
         pack $frm.frame1.lab2 -anchor center -side right -pady 10

      pack $frm.frame1 -side top -fill x

      #--- Frame des boutons de commande et de la representation de la roue a filtres
      frame $frm.frame2 -borderwidth 0 -relief raised

         #--- Frame des boutons de commande
         frame $frm.frame2.frame4 -borderwidth 0 -relief raised

            #--- Gestion des boutons de commande
            button $frm.frame2.frame4.but_1 -text "$bermasaude(caption_position_1)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_1 }
            pack $frm.frame2.frame4.but_1 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
            button $frm.frame2.frame4.but_2 -text "$bermasaude(caption_position_2)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_2 }
            pack $frm.frame2.frame4.but_2 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
            button $frm.frame2.frame4.but_3 -text "$bermasaude(caption_position_3)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_3 }
            pack $frm.frame2.frame4.but_3 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
            button $frm.frame2.frame4.but_4 -text "$bermasaude(caption_position_4)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_4 }
            pack $frm.frame2.frame4.but_4 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1
            button $frm.frame2.frame4.but_5 -text "$bermasaude(caption_position_5)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_5 }
            pack $frm.frame2.frame4.but_5 -anchor center -side top -padx 30 -pady 5 -ipady 5 -fill x -expand 1

         pack $frm.frame2.frame4 -side left -fill both -expand 1

         #--- Frame de la representation de la roue a filtres
         frame $frm.frame2.frame5 -borderwidth 0 -relief raised

            #--- Creation d'un canvas pour affichage de cette representation
            canvas $frm.frame2.frame5.image2a_color_invariant -width 180 -height 180 -highlightthickness 0
            pack $frm.frame2.frame5.image2a_color_invariant
            set zone(image2a) $frm.frame2.frame5.image2a_color_invariant

            #--- Representation de la couleur du filtre
            if { $bermasaude(connect) == "1" } {
               $zone(image2a) create oval 65 105 115 155 -fill $bermasaude(color_filtre) -tags cadres -width 2.0
            }

         pack $frm.frame2.frame5 -side left -fill both -expand 1

      pack $frm.frame2 -side top -fill both -expand 1

      #--- Frame pour le site web et le checkbutton creer au demarrage
      frame $frm.frame3 -borderwidth 0 -relief raised

         #--- Site web officiel de la roue a filtres BerMasAude
         label $frm.frame3.lab103 -text "$caption(bermasaude,site_web)"
         pack $frm.frame3.lab103 -side top -fill x -pady 2

         set labelName [ ::confEqt::createUrlLabel $frm.frame3 "$caption(bermasaude,site_web_ref)" \
            "$caption(bermasaude,site_web_ref)" ]
         pack $labelName -side top -fill x -pady 2

         #--- Frame du bouton Arreter et du checkbutton creer au demarrage
         frame $frm.frame3.start -borderwidth 0 -relief flat

            #--- Bouton Arreter
            button $frm.frame3.start.stop -text "$caption(bermasaude,arreter)" -relief raised \
               -command { ::bermasaude::deletePlugin }
            pack $frm.frame3.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

            #--- Checkbutton demarrage automatique
            checkbutton $frm.frame3.start.chk -text "$caption(bermasaude,creer_au_demarrage)" \
               -highlightthickness 0 -variable conf(bermasaude,start)
            pack $frm.frame3.start.chk -side top -padx 10 -pady 3 -expand 1

         pack $frm.frame3.start -side left -expand 1

      pack $frm.frame3 -side bottom -fill x

      #--- Affichage de la representation
      ::bermasaude::representationRoueAFiltres

      #--- Gestion des boutons actifs/inactifs
      ::bermasaude::configureEtatBoutons

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }

   #------------------------------------------------------------
   # representationRoueAFiltres
   #    Representation graphique de la roue a filtres
   #------------------------------------------------------------
   proc representationRoueAFiltres { } {
      global audace zone

      #--- Affichage de la representation
      if { [ winfo exists $audace(base).confeqt ] } {
         $zone(image2a) create arc 10 10 170 170 -outline $audace(color,textColor) -tags cadres -width 2.0 \
            -start 90 -extent -270 -style arc
         $zone(image2a) create line 10 10 90 10 -fill $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) create line 10 10 10 90 -fill $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -tags cadres -width 2.0
         $zone(image2a) configure -bg $audace(color,backColor)
      }
   }

   #------------------------------------------------------------
   #  configurePlugin
   #     configure le plugin
   #
   #  return nothing
   #------------------------------------------------------------
   proc configurePlugin { } {
      variable widget
      global bermasaude caption conf

      #--- Memorise la configuration de la roue a filtres BerMasAude dans le tableau conf(bermasaude,...)
      set conf(bermasaude,port)  $widget(port)
      set conf(bermasaude,combi) [ lsearch "$caption(bermasaude,bermasaude_bvri) $caption(bermasaude,bermasaude_cmj)" \
         "$widget(combi)" ]
   }

   #------------------------------------------------------------
   #  createPlugin
   #     configure la roue a filtre
   #
   #  return nothing
   #------------------------------------------------------------
   proc createPlugin { } {
      global audace bermasaude caption conf ttybermasaude zone

      #--- Ferme le port comx de communication de la roue a filtres BerMasAude
      ::bermasaude::deletePlugin

      #--- Ouvre le port comx de communication de la roue a filtres BerMasAude
      set catchResult [ catch {
         set ttybermasaude [ ::bermasaude::bermasaude_create $conf(bermasaude,port) ]
         if { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "0" } {
            ::bermasaude::bermasaude_reset $ttybermasaude
            #--- Attente de l'arret en rotation de la roue a filtres
            after 1000
            while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
               after 1000
            }
            console::affiche_entete "$caption(bermasaude,bermasaude_port)\
               $caption(bermasaude,caractere_2points) $conf(bermasaude,port)\n"
            console::affiche_entete "$caption(bermasaude,bermasaude_combinaison)\
               $caption(bermasaude,caractere_2points) [ lindex "$caption(bermasaude,bermasaude_bvri) \
               $caption(bermasaude,bermasaude_cmj)" $conf(bermasaude,combi) ]\n"
            #--- Demande et affiche la version du logiciel du microcontroleur
            set v_firmware [ ::bermasaude::bermasaude_v_firmware $ttybermasaude ]
            console::affiche_entete "$caption(bermasaude,bermasaude_version_micro) $v_firmware\n"
            #--- Demande et affiche le nombre de filtres de la roue
            set nbr_filtres [ ::bermasaude::bermasaude_nbr_filtres $ttybermasaude ]
            console::affiche_entete "[ format $caption(bermasaude,bermasaude_nbr_filtres)\
               $nbr_filtres ]\n\n"
            set bermasaude(connect) "1"
            #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par l'equipement)
            set linkNo [ ::confLink::create $conf(bermasaude,port) "bermasaude" "control" "" -noopen ]
            #--- Gestion des boutons actifs/inactifs
            ::bermasaude::connectBerMasAude
         } else {
            ::bermasaude::deletePlugin
            set bermasaude(connect) "0"
            #--- Configure l'etat des boutons (normal ou disabled)
            ::bermasaude::configureEtatBoutons
         }
      } catchMessage ]

      if { $catchResult == "1" } {
         #--- En cas d'erreur, je libere toutes les ressources allouees
         ::bermasaude::deletePlugin
         set bermasaude(connect) "0"
         #--- Configure l'etat des boutons (normal ou disabled)
         ::bermasaude::configureEtatBoutons
         #--- Je transmets l'erreur a la procedure appelante
         ::console::affiche_erreur "Error start equipment bermasaude: $catchMessage\n\n"
      }

      #--- Effacement du message d'alerte s'il existe
      if [ winfo exists $audace(base).connectEquipement ] {
         destroy $audace(base).connectEquipement
      }
   }

   #------------------------------------------------------------
   #  deletePlugin
   #     arrete le plugin et libere les ressources occupees
   #
   #  return nothing
   #------------------------------------------------------------
   proc deletePlugin { } {
      global audace bermasaude conf ttybermasaude zone

      if { [ info exists ttybermasaude ] } {
         #--- Je re-initialisation la variable de l'etat de la roue a filtres
         set bermasaude(connect) "0"
         #--- Je desactive les boutons
         ::bermasaude::configureEtatBoutons
         #--- Representation de l'absence de filtre (blanc --> rien sur le chemin optique)
         if { [ info exists zone(image2a) ] } {
            $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) \
               -fill $audace(color,backColor) -tags cadres -width 2.0
         }
         update
         #--- Je memorise le port
         set eqtPort $conf(bermasaude,port)
         #--- Je ferme le port serie
         ::bermasaude::bermasaude_delete $ttybermasaude
         unset ttybermasaude
         #--- Je ferme le link
         ::confLink::delete $eqtPort "bermasaude" "control"
      }
   }

   #------------------------------------------------------------
   #  isReady
   #     informe de l'etat de fonctionnement du plugin
   #
   #  return 0 (ready) , 1 (not ready)
   #------------------------------------------------------------
   proc isReady { } {
      return 0
   }

   #==============================================================
   # Procedures specifiques du plugin
   #==============================================================

   #------------------------------------------------------------
   # connectBerMasAude
   #    Permet de rendre actifs ou inactifs les boutons 'Position 1', 'Position 2', 'Position 3',
   #    'Position 4' et 'Position 5' quand on passe d'un onglet 'Equipement' a un autre en evitant
   #    les erreurs dues a un appui 'curieux' sur ces boutons
   #------------------------------------------------------------
   proc connectBerMasAude { } {
      global bermasaude

      #--- Initialisation du graphisme de la roue a filtres
      ::bermasaude::filtreInit

      #--- Configure l'etat des boutons (normal ou disabled)
      ::bermasaude::configureEtatBoutons
   }

   #------------------------------------------------------------
   # configureEtatBoutons
   #    Configure l'etat des boutons
   #------------------------------------------------------------
   proc configureEtatBoutons { } {
      variable widget
      global bermasaude

      if { [ info exists widget(frm) ] } {
         set frm $widget(frm)
         if { $bermasaude(connect) == "1" } {
            $frm.frame2.frame4.but_1 configure -text "$bermasaude(caption_position_1)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_1 }
            $frm.frame2.frame4.but_2 configure -text "$bermasaude(caption_position_2)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_2 }
            $frm.frame2.frame4.but_3 configure -text "$bermasaude(caption_position_3)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_3 }
            $frm.frame2.frame4.but_4 configure -text "$bermasaude(caption_position_4)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_4 }
            $frm.frame2.frame4.but_5 configure -text "$bermasaude(caption_position_5)" -width 10 -relief raised \
               -state normal -command { ::bermasaude::filtre_5 }
         } else {
            $frm.frame2.frame4.but_1 configure -text "$bermasaude(caption_position_1)" -width 10 -relief raised \
               -state disabled
            $frm.frame2.frame4.but_2 configure -text "$bermasaude(caption_position_2)" -width 10 -relief raised \
               -state disabled
            $frm.frame2.frame4.but_3 configure -text "$bermasaude(caption_position_3)" -width 10 -relief raised \
               -state disabled
            $frm.frame2.frame4.but_4 configure -text "$bermasaude(caption_position_4)" -width 10 -relief raised \
               -state disabled
            $frm.frame2.frame4.but_5 configure -text "$bermasaude(caption_position_5)" -width 10 -relief raised \
               -state disabled
         }
      }
   }

   #------------------------------------------------------------
   # choixCouleur
   #    Choix des couleurs des filtres
   #------------------------------------------------------------
   proc choixCouleur { } {
      global audace conf

      #--- Ouverture du fichier de parametrage des positions de la roue avec les couleurs des filtres
      if { $conf(bermasaude,combi) == "0" } {
         set fichier [ file join $audace(rep_plugin) equipment bermasaude bermasaude_bvri.tcl ]
      } elseif { $conf(bermasaude,combi) == "1" } {
         set fichier [ file join $audace(rep_plugin) equipment bermasaude bermasaude_cmj.tcl ]
      }

      #--- Lancement du script
      if { [ file exists $fichier ] } {
         source $fichier
      }
   }

   #------------------------------------------------------------
   # choixNomBouton
   #    Choix du nom des boutons (couleur des filtres)
   #------------------------------------------------------------
   proc choixNomBouton { } {
      global bermasaude caption color

      for { set i 1 } { $i <= 5 } { incr i } {
         if { $bermasaude(color_filtre_$i) == "$color(white)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_vide)
         } elseif { $bermasaude(color_filtre_$i) == "$color(blue)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_bleu)
         } elseif { $bermasaude(color_filtre_$i) == "$color(green)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_vert)
         } elseif { $bermasaude(color_filtre_$i) == "$color(red)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_rouge)
         } elseif { $bermasaude(color_filtre_$i) == "$color(infra-red)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_infrarouge)
         } elseif { $bermasaude(color_filtre_$i) == "$color(cyan)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_cyan)
         } elseif { $bermasaude(color_filtre_$i) == "$color(magenta)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_magenta)
         } elseif { $bermasaude(color_filtre_$i) == "$color(yellow)" } {
            set bermasaude(caption_position_$i) $caption(bermasaude,bermasaude_jaune)
         }
      }
   }

   #------------------------------------------------------------
   # filtreInit
   #    Initialisation de la roue a filtres
   #------------------------------------------------------------
   proc filtreInit { } {
      global audace bermasaude caption ttybermasaude zone

      #--- Choix des couleurs
      ::bermasaude::choixCouleur

      #--- Choix du nom des boutons (couleur des filtres)
      ::bermasaude::choixNomBouton

      #--- Initialisation des variables
      set bermasaude(position) "1"
      set bermasaude(color_filtre) $bermasaude(color_filtre_1)

      if { [ info exists zone(image2a) ] } {
         #--- Representation de l'absence de filtre (blanc --> rien sur le chemin optique)
         $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -fill $bermasaude(color_filtre) \
            -tags cadres -width 2.0
         #--- Demande la position courante de la roue a filtres
         while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
            after 1000
         }
         set num_filtre_position [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_resultat "[ format $caption(bermasaude,bermasaude_filtre_arrive)\
            $bermasaude(caption_position_$num_filtre_position) ]\n\n"
         bell
      }
   }

   #------------------------------------------------------------
   # filtre_1
   #    Positionne le filtre n°1 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_1 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "1"
      set bermasaude(color_filtre) $bermasaude(color_filtre_1)

      #--- Commande de la roue a filtres
      ::bermasaude::cmdRoueFiltres
   }

   #------------------------------------------------------------
   # filtre_2
   #    Positionne le filtre n°2 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_2 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "2"
      set bermasaude(color_filtre) $bermasaude(color_filtre_2)

      #--- Commande de la roue a filtres
      ::bermasaude::cmdRoueFiltres
   }

   #------------------------------------------------------------
   # filtre_3
   #    Positionne le filtre n°3 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_3 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "3"
      set bermasaude(color_filtre) $bermasaude(color_filtre_3)

      #--- Commande de la roue a filtres
      ::bermasaude::cmdRoueFiltres
   }

   #------------------------------------------------------------
   # filtre_4
   #    Positionne le filtre n°4 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_4 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "4"
      set bermasaude(color_filtre) $bermasaude(color_filtre_4)

      #--- Commande de la roue a filtres
      ::bermasaude::cmdRoueFiltres
   }

   #------------------------------------------------------------
   # filtre_5
   #    Positionne le filtre n°5 sur le chemin optique
   #------------------------------------------------------------
   proc filtre_5 { } {
      global bermasaude

      #--- Initialisation des variables
      set bermasaude(position) "5"
      set bermasaude(color_filtre) $bermasaude(color_filtre_5)

      #--- Commande de la roue a filtres
      ::bermasaude::cmdRoueFiltres
   }

   #------------------------------------------------------------
   # cmdRoueFiltres
   #    Commande la roue a filtres
   #------------------------------------------------------------
   proc cmdRoueFiltres { } {
      variable widget
      global audace bermasaude caption ttybermasaude zone

         #--- Gestion des boutons actifs/inactifs
         if { [ winfo exists $widget(frm).frame2.frame4.but_$bermasaude(position) ] } {
            for { set i 1 } { $i <= 5 } { incr i } {
               $widget(frm).frame2.frame4.but_$i configure -state disabled
            }
            $widget(frm).frame2.frame4.but_$bermasaude(position) configure -relief groove
         }

         #--- Representation de la couleur du filtre
         if { [ info exists zone(image2a) ] } {
            $zone(image2a) create oval 65 105 115 155 -outline $audace(color,textColor) -fill $bermasaude(color_filtre) \
               -tags cadres -width 2.0
         }

         #--- Demande la position courante de la roue a filtres
         set num_filtre_position [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_resultat "[ format $caption(bermasaude,bermasaude_filtre_depart)\
            $bermasaude(caption_position_$num_filtre_position) ]\n"

         #--- Envoi l'ordre a la roue a filtres
         ::console::affiche_resultat "[ format $caption(bermasaude,bermasaude_filtre_encours)\
            $bermasaude(caption_position_$bermasaude(position)) ]\n"
         set num_filtre_arrive [ ::bermasaude::bermasaude_aller_a $ttybermasaude [ list $bermasaude(position) ] ]

         #--- Affichage de la position de destination
         while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
            after 1000
         }
         set num_filtre_position_arrivee [ ::bermasaude::bermasaude_position $ttybermasaude ]
         ::console::affiche_entete "[ format $caption(bermasaude,bermasaude_filtre_arrive)\
            $bermasaude(caption_position_$num_filtre_position_arrivee) ]\n\n"
         bell

         #--- Gestion des boutons actifs/inactifs
         if { [ winfo exists $widget(frm).frame2.frame4.but_$bermasaude(position) ] } {
            $widget(frm).frame2.frame4.but_$bermasaude(position) configure -relief raised
            for {set i 1} {$i <= 5} {incr i} {
               $widget(frm).frame2.frame4.but_$i configure -state normal
            }
         }
   }

#------------------------------------------------------------
# Procedures du plugin de la roue a filtres (BerMasAude)
#------------------------------------------------------------

    proc bermasaude_create { port } {
       global bermasaude

       #--- Etablit la liaison
       if { $::tcl_platform(platform) == "unix" } {
          set port [ string tolower [ string trim $port ] ]
          set num [ expr [ string index $port 3 ] - 1 ]
          set port /dev/ttyS$num
       }
       set ttybermasaude [ open $port r+ ]
       fconfigure $ttybermasaude -mode "9600,n,8,1" -buffering none -blocking 0
       after [ expr $bermasaude(attente) ]
       return $ttybermasaude
    }

    proc bermasaude_v_firmware { ttybermasaude } {
       global bermasaude

       #--- Retourne la version du logiciel du microcontroleur
       #--- Demande le numero de la version
       puts -nonewline $ttybermasaude "V\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la version sur le port serie
       set v_firmware [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $v_firmware
    }

    proc bermasaude_reset { ttybermasaude } {
       global bermasaude

       #--- Execute un Reset de la roue a filtres
       puts -nonewline $ttybermasaude "R\r"
       after [ expr $bermasaude(attente) ]
    }

    proc bermasaude_etat_roue { ttybermasaude } {
       global bermasaude

       #--- Retourne l'etat de la roue a filtres
       #--- 1 : Si la roue a filtres est en rotation
       #--- 0 : Si la roue a filtres est a l'arret
       puts -nonewline $ttybermasaude "E\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la version sur le port serie
       set etat_roue [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $etat_roue
    }

    proc bermasaude_nbr_filtres { ttybermasaude } {
       global bermasaude

       #--- Retourne le nombre de filtres de la roue
       #--- Demande le nombre de filtres
       puts -nonewline $ttybermasaude "n\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit le nombre de filtres sur le port serie
       set nbr_filtres [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $nbr_filtres
    }

    proc bermasaude_aller_a { ttybermasaude num_filtre } {
       global bermasaude

       #--- Positionne le filtre demande sur le faisceau optique
       puts -nonewline $ttybermasaude "$num_filtre\r"
       after [ expr $bermasaude(attente) ]
       #--- Boucle jusqu'au positionnement du filtre destination
       after 1000
       while { [ ::bermasaude::bermasaude_etat_roue $ttybermasaude ] == "1" } {
          after 1000
       }
       return $num_filtre
    }

    proc bermasaude_position { ttybermasaude } {
       global bermasaude

       #--- Retourne la position courante de la roue
       #--- Demande la position courante
       puts -nonewline $ttybermasaude "f\r"
       after [ expr $bermasaude(attente) ]
       #--- Lit la position courante sur le port serie
       set num_filtre_position [ read $ttybermasaude 11 ]
       after [ expr $bermasaude(attente) ]
       return $num_filtre_position
    }

    proc bermasaude_delete { ttybermasaude } {
       #--- Ferme la liaison
       close $ttybermasaude
    }

}


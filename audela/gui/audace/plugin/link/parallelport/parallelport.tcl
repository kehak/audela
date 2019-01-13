#
# Fichier : parallelport.tcl
# Description : Interface de liaison Port Parallele
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: parallelport.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::parallelport {
   package provide parallelport 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] parallelport.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::parallelport::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libparallelport.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::parallelport::getPluginType]] "parallelport" "libparallelport.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(parallelport,installNewVersion) $sourceFileName [package version parallelport] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     Retourne la valeur de la propriete
#
#  Parametres :
#     propertyName : Nom de la propriete
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::getPluginProperty { propertyName } {
   switch $propertyName {
      bitList {
         return [list 0 1 2 3 4 5 6 7]
      }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     Retourne le titre du plugin dans la langue de l'utilisateur
#
#  Parametres :
#     Aucun
#  Return :
#     caption(nom_plugin,titre)
#------------------------------------------------------------
proc ::parallelport::getPluginTitle { } {
   global caption

   return "$caption(parallelport,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     Retourne la documentation du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     nom_plugin.htm
#------------------------------------------------------------
proc ::parallelport::getPluginHelp { } {
   return "parallelport.htm"
}

#------------------------------------------------------------
#  getPluginType
#     Retourne le type du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     link
#------------------------------------------------------------
proc ::parallelport::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     Retourne le ou les OS de fonctionnement du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     La liste des OS supportes par le plugin
#------------------------------------------------------------
proc ::parallelport::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin
#     Initialise le plugin
#     initPlugin est lance automatiquement au chargement de ce fichier tcl
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::initPlugin { } {
   variable private

   #--- Initialisation
   set private(frm) ""
   if { ! [ info exists ::conf(parallelport,porttalkQuestion) ] } { set ::conf(parallelport,porttalkQuestion) "1" }

   #--- Verification de la presence de allowio.txt pour la compatibilite avec les versions precedentes
   if { [ file exist [ file join $::audace(rep_home) allowio.txt ] ] } {
      set ::conf(parallelport,porttalkQuestion) "0"
      file delete [ file join $::audace(rep_home) allowio.txt ]
   }

   if { $::tcl_platform(os) == "Windows NT" } {
      set private(porttalkInstalled) 0
   }
   #--- je recupere le nom generique de la liaison
   if { $::tcl_platform(os) == "Linux" } {
      set private(genericName) "/dev/parport"
   } else {
      set private(genericName) "LPT";
   }
}

#------------------------------------------------------------
#  configurePlugin
#     Configure le plugin
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### ::parallelport::run "$audace(base).parallelport"

   return
}

#------------------------------------------------------------
#  confToWidget
#     Copie les parametres du tableau conf() dans les variables des widgets
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  createPluginInstance
#     installe porttalk si necessaire
#     Cree une liaison et retourne le numero du link
#       Le numero du link est attribue automatiquement
#       Si ce link est deja cree, on retourne le numero du link existant
#
#  Parametres :
#     linkLabel : Par exemple "LPT1:"
#     deviceId  : Par exemple "cam1"
#     usage     : Type d'utilisation
#     comment   : Commentaire
#  Return :
#     Numero du link
#
#  Exemple :
#     ::parallelport::createPluginInstance "LPT1:" "cam1" "acquisition" "bit 1"
#       1
#     ::parallelport::createPluginInstance "LPT2:" "cam1" "longuepose" "bit 1"
#       2
#     ::parallelport::createPluginInstance "LPT2:" "cam2" "longuepose" "bit 2"
#       2
#------------------------------------------------------------
proc ::parallelport::createPluginInstance { linkLabel deviceId usage comment args } {
   variable private

   if { $::tcl_platform(os) == "Windows NT" } {
      #--- je charge le package registry pour chercher une cle dans la base de registre de windows
      package require registry

      #--- je verifie que l'OS est une version 32 bits (allowio n'est pas compatible 64 bits)
      set version [ lindex [ ::registry get "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0" Identifier] 0 ]
      if { $version == "x86" } {
         #--- j'installe porttalk si ce n'est pas deja fait
         if { $private(porttalkInstalled) == 0 } {
            #--- j'installe porttalk
            set res [ catch { set result [ porttalk open all ] } msg ]
            set no_administrator "PortTalk: You do not have rights to access"
            if { $res == "1" } {
               #--- l'installation de porttalk n'a pas reussi parce que l'utilisateur
               #--- n'est pas administrateur de la machine.
               if { [ string range $msg 0 41 ] != "$no_administrator" } {
                  ::console::affiche_erreur "$msg\n\n$::caption(parallelport,porttalk_msg_erreur)\n"
               } else {
                  ::console::affiche_erreur "$msg\n"
               }
               if { $::conf(parallelport,porttalkQuestion) == "1" } {
                  #--- je demande a l'utilisateur s'il ne veut plus que Audela essaie
                  #--- d'installer porttalk
                  set base ".allowio"
                  toplevel $base
                  wm geometry $base +50+100
                  wm resizable $base 0 0
                  wm deiconify $base
                  wm title $base "$::caption(parallelport,porttalk_erreur)"
                  if { [ string range $msg 0 41 ] != "$no_administrator" } {
                     message $base.msg -text "$msg\n\n$::caption(parallelport,porttalk_msg_erreur)\n" -justify center -width 350
                  } else {
                     message $base.msg -text "$msg\n" -justify center -width 350
                  }
                  pack $base.msg -in $base -anchor center -side top -fill x -padx 0 -pady 0 -expand 0
                  frame $base.frame1
                     set saveallowio "0"
                     checkbutton $base.frame1.check1 -variable saveallowio
                     pack $base.frame1.check1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
                     label $base.frame1.lab1 -text "$::caption(parallelport,porttalk_message)"
                     pack $base.frame1.lab1 -anchor w -side left -fill x -padx 1 -pady 1 -expand 1
                  pack $base.frame1 -in $base -anchor center -side top -fill none -padx 0 -pady 0 -expand 0
                  button $base.but1 -text "$::caption(parallelport,ok)" \
                     -command {
                        if { $saveallowio == "1" } {
                           set ::conf(parallelport,porttalkQuestion) "0"
                        }
                        destroy .allowio
                     }
                  pack $base.but1 -in $base -anchor center -side top -padx 5 -pady 5 -ipadx 10 -ipady 5
                  focus -force $base
                  tkwait window $base
               }
            } else {
                #--- l'installation de porttalk a reussi
                set private(porttalkInstalled) 1
                ::console::affiche_prompt "$::caption(parallelport,porttalk_titre) $result\n\n"
            }
         }
      }
   }

   #--- je cree le lien
   set linkno [::link::create parallelport $linkLabel]
   #--- j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment
   #--- je rafraichis la liste
   refreshAvailableList
   #--- je selectionne le link
   selectConfigLink $linkLabel
   #---
   return $linkno
}

#------------------------------------------------------------
#  deletePluginInstance
#     Supprime une utilisation d'une liaison
#     et supprime la liaison si elle n'est plus utilises par aucun autre peripherique
#     Ne fait rien si la liaison n'est pas ouverte
#
#  Parametres :
#     linkLabel : Par exemple "LPT1:"
#     deviceId  : Par exemple "cam1"
#     usage     : Type d'utilisation
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::deletePluginInstance { linkLabel deviceId usage } {
   set linkNo [::confLink::getLinkNo $linkLabel]
   if { $linkNo != "" } {
      link$linkNo use remove $deviceId $usage
      if { [link$linkNo use get] == "" } {
         #--- je supprime la liaison si elle n'est plus utilisee par aucun peripherique
         ::link::delete $linkNo
      }
      #--- je rafraichis la liste
      refreshAvailableList
   }
}

#------------------------------------------------------------
#  fillConfigPage
#     Fenetre de configuration du plugin
#
#  Parametres :
#     frm : Widget de l'onglet
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- J'affiche la liste des links et le bouton pour rafraichir cette liste
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(parallelport,available)

      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true

      Button $frm.available.refresh -highlightthickness 0 -padx 10 -pady 3 -state normal \
         -text "$caption(parallelport,refresh)" -command "::parallelport::refreshAvailableList"
      pack $frm.available.refresh -in [$frm.available getframe] -side left

   pack $frm.available -side top -fill both -expand true

   #--- J'affiche le frame de Porttalk uniquement pour Windows
   if { $::tcl_platform(os) == "Windows NT" } {

      #--- J'affiche les labels et le bouton associes au message Porttalk
      frame $frm.porttalk -borderwidth 0 -relief raised

         label $frm.porttalk.lab1 -text "$caption(parallelport,texte)"
         pack $frm.porttalk.lab1 -in $frm.porttalk -side top -anchor w -padx 5 -pady 5

         label $frm.porttalk.lab2 -anchor nw -highlightthickness 0 -text "$caption(parallelport,porttalk)" -padx 0 -pady 0
         pack $frm.porttalk.lab2 -in $frm.porttalk -side left -padx 40 -pady 5

         if { $::conf(parallelport,porttalkQuestion) == "0" } {
            set porttalkButton "$caption(parallelport,non)"
         } else {
            set porttalkButton "$caption(parallelport,oui)"
         }

         button $frm.porttalk.but -text $porttalkButton -relief raised -state normal \
            -command "::parallelport::afficheMsgPorttalk"
         pack $frm.porttalk.but -in $frm.porttalk -side left -padx 0 -pady 5 -ipadx 5 -ipady 5

      pack $frm.porttalk -side top -fill x

   }

   #--- Je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  afficheMsgPorttalk
#     Affiche le message de Porttalk
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::afficheMsgPorttalk { } {
   variable private
   global caption

   set frm $private(frm)
   if { $::conf(parallelport,porttalkQuestion) == "0" } {
      #--- Acces au message d'erreur Porttalk au prochain demarrage
      $frm.porttalk.but configure -text "$caption(parallelport,oui)"
       set ::conf(parallelport,porttalkQuestion) "1"
   } else {
      $frm.porttalk.but configure -text "$caption(parallelport,non)"
       set ::conf(parallelport,porttalkQuestion) "0"
   }
}

#------------------------------------------------------------
#  getLinkLabels
#     Retourne les libelles des ports paralleles disponibles
#
#  Parametres :
#     Aucun
#  Return :
#     linkLabels : Par exemple { "LPT1:" "LPT2:" "LPT3:" }
#------------------------------------------------------------
proc ::parallelport::getLinkLabels { } {
   set linkLabels [list]
   set instances [link::available parallelport ]
   foreach instance $instances {
      lappend linkLabels "[lindex $instance 1]"
   }
   return $linkLabels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     Retourne le link choisi
#
#  Parametres :
#     Aucun
#  Return :
#     linkLabel : Par exemple "LPT1:"
#------------------------------------------------------------
proc ::parallelport::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "LPT1:"   retourne 1
#     exemple :  isValidLabel "XXX1:"   retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::parallelport::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  isReady
#     Informe de l'etat de fonctionnement du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     0 (ready) ou 1 (not ready)
#------------------------------------------------------------
proc ::parallelport::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     Rafraichit la liste des link disponibles
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::refreshAvailableList { } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   set selectedLinkLabel [getSelectedLinkLabel]

   #--- j'efface le contenu de la liste
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   #--- je remplis la liste
   foreach linkLabel [getLinkLabels] {
      set linkText ""
      #--- je recherche si ce link est ouvert
      foreach linkNo $linkNoList {
         if { $linkLabel == [link$linkNo name] } {
            #--- si le link est ouvert, j'affiche son label, linkNo et les utilisations
            set linkText "$linkLabel link$linkNo [link$linkNo use get]"
         }
      }
      #--- si le link est ferme, j'affiche son label seulement
      if { $linkText == "" } {
         set linkText "$linkLabel"
      }
      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel

   return
}

#------------------------------------------------------------
#  selectConfigLink
#     Selectionne un link dans la fenetre de configuration
#
#  Parametres :
#     linkLabel : Par exemple "LPT1:"
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::selectConfigLink { linkLabel } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   $private(frm).available.list selection clear 0 end

   #--- je recherche linkLabel dans la listbox  (linkLabel est le premier element de chaque ligne)
   for {set i 0} {$i<[$private(frm).available.list size]} {incr i} {
      if { [lindex [$private(frm).available.list get $i] 0] == $linkLabel } {
         $private(frm).available.list selection set $i
         return
      }
   }
   if { [$private(frm).available.list size] > 0 } {
      #--- sinon je selectionne le premier linkLabel
      $private(frm).available.list selection set 0
   }
}

#------------------------------------------------------------
#  widgetToConf
#     Copie les variables des widgets dans le tableau conf()
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::parallelport::widgetToConf { } {
   variable widget
   global conf

}


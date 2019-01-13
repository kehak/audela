#
## @file sn_tarot_go.tcl
#  @brief Gestion de la mise à jour et du panneau
#  @author Alain KLOTZ et Raymond ZACHANTKE
#  @namespace sn_tarot
#  @brief Gestion de la mise à jour et du panneau
#  $Id: sn_tarot_go.tcl 14427 2018-05-04 09:31:52Z alainklotz $
#  @defgroup sn_tarot_notice Découvrir des supernovae
#  Références :
#  - présentation pdf <A HREF="sn_tarot.pdf"><B>Découvrir des supernovae en utilisant les images des télescopes TAROT</B></A>
#  - fonctions @ref ::sn_tarot
#

#  source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_go.tcl
#

#============================================================
# Declaration du namespace sn_tarot
#    initialise le namespace
#============================================================

namespace eval ::sn_tarot {
   package provide sn_tarot 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] sn_tarot_go.cap ]
}

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::sn_tarot::getPluginTitle { } {
   global caption

   return "$caption(sn_tarot_go,supernovae)"
}

#------------------------------------------------------------
# brief    retourne le nom du fichier d'aide principal
# return   nom du fichier d'aide principal
#
proc ::sn_tarot::getPluginHelp { } {
   return "sn_tarot.htm"
}

#------------------------------------------------------------
# brief    retourne le type de plugin
# return   type de plugin
#
proc ::sn_tarot::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief    retourne le nom du répertoire du plugin
# return   nom du répertoire du plugin : "sn_tarot"
#
proc ::sn_tarot::getPluginDirectory { } {
   return "sn_tarot"
}

#------------------------------------------------------------
## @brief  retourne le ou les OS de fonctionnement du plugin
#  @return liste des OS : "Windows Linux Darwin"
#
proc ::sn_tarot::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::sn_tarot::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "display" }
      display      { return "panel" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin du panneau
#
proc ::sn_tarot::createPluginInstance { base { visuNo 1 } } {
   variable This

   package require http
   package require twapi

   source [ file join $::audace(rep_plugin) tool sn_tarot sn_tarot.cap ]
   source [ file join $::audace(rep_plugin) tool sn_tarot sn_tarot.tcl ]
   source [ file join $::audace(rep_plugin) tool sn_tarot sn_tarot_update.tcl ]
   source [ file join $::audace(rep_plugin) tool sn_tarot sn_tarot_macros.tcl ]
   source [ file join $::audace(rep_plugin) tool sn_tarot sn_tarot_http.tcl ]

   #-- chemin du panneau
   set This "$base.sn_tarot"

   #-- pour mémoire
   # fenêtre "Tarot Supernovae - Mise à jour"                        $This.update
   # fenêtre "Tarot SN Visu"                                         $This.snvisu
   #--   descendants de $This.snvisu
   # fenêtre "Aller à" de "Tarot SN Visu"                            $This.snvisu.allera
   # fenêtre de configuration "Tarot SN Visu"                        $This.snvisu.config
   # barre de progression du téléchargement des images DSS           $This.snvisu.progr
   # fenêtre affichant les mots clés des images de "Tarot SN Visu"   $This.snvisu.snheader
   # fenêtre de rapport pour une candidate                           $This.snvisu.cand
   # fenêtre de rapport pour une ancienne candidate                  $This.snvisu.ancand
   # fenêtre de confirmation de téléchargement de fichier            $This.confirm

   #--   initialise les variables locales
   ::sn_tarot::configVar

   #--- Create the panel $This
   #--- Cree le panneau $This
   frame $This

   #--   ouvre la fenetre "Tarot Supernovae - Mise à jour"
   ::sn_tarot::updateFiles

   return $This
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::sn_tarot::deletePluginInstance { visuNo } {
   variable This

   #--   destruction de la fenêtre d'exploration et des annexes
   #if {[ winfo exists $This.snvisu ] == 1} {
   #   ::sn_tarot::cmdClose
   #}
}

#------------------------------------------------------------
#  brief initialise les variables locales
#
proc ::sn_tarot::configVar { } {
   global audace panneau rep

   ::sn_tarot::initConf

   set dir "$::conf(rep_archives)"
   set panneau(init_dir) [ file join $dir tarot ]
   set rep(archives) "[ file join $panneau(init_dir) archives ]"    ; # chemin du repertoire des archives
   set rep(name1)    "[ file join $panneau(init_dir) night ]"       ; # chemin du repertoire images de la nuit
   set rep(name2)    "[ file join $panneau(init_dir) references ] " ; # chemin du repertoire images de reference galtarot
   set rep(name3)    "[ file join $panneau(init_dir) dss ]"         ; # chemin du repertoire images de reference dss

   #--   Initialisation des variables de la combobox de selection du site
   set panneau(list_prefix) [ list Tarot_Calern Tarot_Chili ]
   set panneau(sn_tarot,prefix) [lindex $panneau(list_prefix) 0]

   set panneau(sn_tarot,Tarot_Calern,url)    "http://tarot6.oca.eu/ros/supernovae/zip/"
   set panneau(sn_tarot,Tarot_Chili,url)     "http://tarotchili4.osupytheas.fr/ros/supernovae/zip/"
   set panneau(sn_tarot,Zadko_Australia,url) "http://121.200.43.11/ros/supernovae/zip/"
   set panneau(sn_tarot,ohp,url)             "http://cador.obs-hp.fr/tarot/"

   set panneau(sn_tarot,init) 0 ; #  temoin d'initialisation

   set audace(sn_tarot,ok_zadko) 0
   set hostname [lindex [hostaddress] end]
   #if {($hostname=="astrostar")||($hostname=="PC-de-Manue")||([string compare $hostname "HÜSNE-HÜSNE"])||($hostname=="dhcp3-45")||($hostname=="Onelda-PC")}
   set test [string compare $hostname "HÜSNE-HÜSNE"]
   set authorized [list "astrostar" "PC-de-Manue" "dhcp3-45" "Onelda-PC" "$test" ]
   if {$hostname in "$authorized"} {
      set audace(sn_tarot,ok_zadko) 1
      lappend panneau(list_prefix) Zadko_Australia
   }

   #-- fait l'inventaire des archives locales dans rep(list_archives)
   # et complete les variables panneau(sn_tarot,$prefix) avec la liste des dates
   ::sn_tarot::listArchives
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Tarot SN Visu"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(sn_tarot,geometry)     définit les dimensions et la position de la fenêtre
#  - conf(sn_tarot,last_archive) mémorise la dernière archive explorée au moment de la fermeture
#  - conf(sn_tarot)              liste un ensemble de paramètres utilisateur, collectés par ::sn_tarot::snSaveConfig
#
proc ::sn_tarot::initConf { } {
   global conf

   if { ![ info exists conf(sn_tarot,geometry) ] } {
      if { $::tcl_platform(os) == "Linux" } {
         set conf(sn_tarot,geometry) "800x600+150+70"
      } else {
         set conf(sn_tarot,geometry) "660x548+150+70"
      }
   }
   if { ![ info exists conf(sn_tarot,last_archive) ]} {
      set conf(sn_tarot,last_archive) "-"
   }
   if { ![ info exists conf(sn_tarot) ] } {
      set conf(sn_tarot) [ list motion 250 5 0 no ]
   }
}


#------------------------------------------------------------
#  brief créé le panneau principal
#
proc ::sn_tarot::tarotBuildIF { } {
   variable This
   global caption panneau

   #--   Deplace vers createPluginInstance
   #frame $This -borderwidth 2 -relief groove

   $This configure -borderwidth 2 -relief groove

   #--- Frame du titre
   frame $This.fra1 -borderwidth 2 -relief groove

   #--- Bouton du titre
   Button $This.fra1.but -borderwidth 1 \
      -text "$caption(sn_tarot_go,help,titre1)\n$caption(sn_tarot_go,supernovae)" \
      -command "::sn_tarot::snHelp"
   pack $This.fra1.but -anchor center -expand 1 -fill both -side top -ipadx 5
   DynamicHelp::add $This.fra1.but -text "$caption(sn_tarot_go,help,titre)"

   pack $This.fra1 -side top -fill x

   #--- Frame de Recherche
   frame $This.fra2 -borderwidth 1 -relief groove

   #--- Combobox de selection du site
   set width [expr {int([::tkutil::lgEntryComboBox $panneau(list_prefix)]*6/7)}]
   ComboBox $This.fra2.site -width $width -relief sunken -borderwidth 1 \
      -textvariable panneau(sn_tarot,prefix) \
      -values $panneau(list_prefix) -editable 0 \
      -modifycmd "::sn_tarot::selectSiteDates"
   pack $This.fra2.site -anchor center -fill none -pady 5

   #--- Combobox de selection de la date ; les 'values' sont configurees par ::sn_tarot::selectSiteDates
   ComboBox $This.fra2.file -width $width  -height 2 -relief sunken -borderwidth 1 \
      -textvariable panneau(sn_tarot,date) -editable 0 \
      -modifycmd "::sn_tarot::defineFileZip"
   pack $This.fra2.file -anchor center -fill none -pady 5

   #--- Bouton Rafraichir
   #button $This.fra2.but0 -borderwidth 2
   ::ttk::button $This.fra2.but0 -state normal -width $width \
      -text "$caption(sn_tarot_go,refresh)" \
      -command "catch {unset panneau(sn_tarot,init)} ; ::sn_tarot::updateFiles ; vwait panneau(sn_tarot,init) ; ::sn_tarot::listArchives"
   pack $This.fra2.but0 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Telecharger
   #button $This.fra2.but1 -borderwidth 2
   ::ttk::button $This.fra2.but1 -state normal -width $width \
      -text "$caption(sn_tarot_go,telecharger)" \
      -command "::sn_tarot::cmdApplyTelecharge"
   pack $This.fra2.but1 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Recherche supernovae
   #button $This.fra2.but2 -borderwidth 2
   ::ttk::button $This.fra2.but2 -state normal -width $width \
      -text "$caption(sn_tarot_go,recherche_sn)" \
      -command "::sn_tarot::Explore"
   pack $This.fra2.but2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   #--- Bouton Status candidates
   #button $This.fra2.but3 -borderwidth 2
   ::ttk::button $This.fra2.but3 -state normal -width $width \
      -text "$caption(sn_tarot_go,status_candidates)" \
      -command "::sn_tarot::cmdAnalyzeCandidateId"
   pack $This.fra2.but3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 5

   pack $This.fra2 -side top -fill x

   #--   pour definir le fichier courant
   ::sn_tarot::defineFileZip

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#-----------------------------------------------------
#  brief commande des boutons "Aide"
#  de la fenêtre "Tarot Supernovae - Mise à jour" et du panneau
#  param item (optionnel) nom de l'item dans la page htm
#
proc ::sn_tarot::snHelp { { item "" } } {

  ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::sn_tarot::getPluginType ] ] \
      [ ::sn_tarot::getPluginDirectory ] [ ::sn_tarot::getPluginHelp ] $item
}

#------------------------------------------------------------
## @brief commande associée à la combobox de sélection du site dans le panneau
#  @details rafraichît la liste des dates affichées pour le site sélectionné ;
#  inhibe la combobox si la liste est vide
#
proc ::sn_tarot::selectSiteDates { } {
   variable This
   global panneau caption rep

   #--   identifie le site selectionne
   set prefix $panneau(sn_tarot,prefix)
   #--   met a jour l'url correspondant a la selection en vue du telechargement
   set panneau(sn_tarot,url0) "$panneau(sn_tarot,${prefix},url)"

   #--   met a jour la liste de la combobox de selection des dates
   $This.fra2.file configure -values $panneau(sn_tarot,$prefix)

   #--   gere l'etat de la combobox en fonction du contenu
   if {[llength $panneau(sn_tarot,$prefix)] eq "0"} {
      #--   vide l'affichage des dates
      set panneau(sn_tarot,date) ""
      #--   inhibe la combobox si la liste est vide
      $This.fra2.file configure -state disabled
   } else {
      #--   pointe le premier de la liste
      $This.fra2.file setvalue @0
      $This.fra2.file configure -state normal
      #---
      ::sn_tarot::defineFileZip
   }
   update
}

#------------------------------------------------------------
## @brief commande associée à la combobox de sélection de la date du panneau ;
# définit le nom du fichier à télécharger
#
proc ::sn_tarot::defineFileZip { } {
   global panneau snconfvisu

   #-- positionne la combobox sur le fichier
   set snconfvisu(night) "${panneau(sn_tarot,prefix)}_${panneau(sn_tarot,date)}"
   set panneau(sn_tarot,file_zip) "$snconfvisu(night).zip"
}

#------------------------------------------------------------
## @brief commande du bouton "Télécharger" du panneau
#
proc ::sn_tarot::cmdApplyTelecharge { } {
   variable This
   global caption panneau rep

   #--   si l'utilisateur n'a pas fait de selection
   if { ![ info exists panneau(sn_tarot,url0) ] || ![ info exists panneau(sn_tarot,file_zip) ] } {
      ::sn_tarot::selectSiteDates
   }

   #--   raccourci
   set file_zip $panneau(sn_tarot,file_zip)

   #--   confirmation
   if { [ tk_dialog $This.confirm "$caption(sn_tarot_go,telecharger)" \
      [ format $caption(sn_tarot_go,telecharge) $file_zip ] questhead 0 \
      $caption(sn_tarot_go,yes) $caption(sn_tarot_go,no) ] == 1 } {
      return
   }

   #--   inhibe les selecteurs et les boutons du panneau
   foreach child [ list site file but0 but1 but2 but3 ] {
      $This.fra2.$child configure -state disabled
   }

   $This.fra2.but1 configure -text "$caption(sn_tarot_go,telechargement)"
   update

   if { [ ::sn_tarot::downloadFile $panneau(sn_tarot,url0) $file_zip [ file join $rep(archives) $file_zip ] ] } {
      ::sn_tarot::listArchives
   }

   $This.fra2.but1 configure -text "$caption(sn_tarot_go,telecharger)"

   #--   desinhibe
   foreach child [ list site file but0 but1 but2 but3 ] {
      $This.fra2.$child configure -state normal
   }
   update
}

#------------------------------------------------------------
## @brief commande du bouton "Recherche supernovae" du panneau
#
proc ::sn_tarot::Explore { } {
   global caption rep

   if { $rep(list_archives) ne "" } {
      ::sn_tarot::createTarotVisu
   } else {
      tk_messageBox -title $caption(sn_tarot_go,attention) -icon error \
         -type ok -message $caption(sn_tarot_go,nozip_error)
   }
}

#------------------------------------------------------------
## @brief liste les fichiers du dossier archives en excluant refgaltarot, refgalzadko et dss
#  et peuple les variables panneau(sn_tarot,$prefix) avec les dates triées par ordre décroissant
#
proc ::sn_tarot::listArchives { } {
   variable This
   global panneau rep snconfvisu

   #--   masque l'extension .zip
   regsub -all ".zip" [ glob -nocomplain -type f -tails -dir $rep(archives) *.zip ] "" list_archives

   #--   s'ils existent, masque refgalzadko, refgaltarot et dss
   regsub -all {(refgalzadko)|(refgaltarot)|(dss)} $list_archives "" list_archives
   set rep(list_archives) [ lsort -decreasing $list_archives ]

   #--   peuple les variables panneau(sn_tarot,$prefix) (combobox) avec les dates correspondantes
   foreach prefix $panneau(list_prefix) {
      set pattern ${prefix}_
      regsub -all "$pattern" [lsearch -all -inline -decreasing -regexp $rep(list_archives) "${pattern}.+" ] "" panneau(sn_tarot,$prefix)
   }

   #--   met à jour la liste de "Tarot SN Visu"
   if { [ winfo exists $This.snvisu.fr5.select ] == 1 } {
      if {[llength $rep(list_archives)] ne "0"} {
         $This.snvisu.fr5.select configure -values $rep(list_archives)
         #-- positionne la combobox sur le fichier
         regsub -all ".zip" $panneau(sn_tarot,file_zip) "" snconfvisu(night)
      }
   }
}



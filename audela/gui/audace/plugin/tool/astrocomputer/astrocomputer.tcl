#
## @file astrocomputer.tcl
#  @brief Calculatrice pour l'astronomie
#  @author Alain KLOTZ
#  $Id: astrocomputer.tcl 13713 2016-04-16 17:29:03Z robertdelmas $
#

# source "$::audace(rep_install)/gui/audace/plugin/tool/astrocomputer/astrocomputer.tcl"
#

#============================================================
# Declaration du namespace astrocomputer
#    initialise le namespace
#============================================================

## @namespace astrocomputer
#  @brief Calculatrice pour l'astronomie
namespace eval ::astrocomputer {
   package provide astrocomputer 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] astrocomputer.cap ]
}

#------------------------------------------------------------
## @brief  Retourne le titre du plugin dans la langue de l'utilisateur
#  @return Titre du plugin
#
proc ::astrocomputer::getPluginTitle { } {
   return "$::caption(astrocomputer,astrocomputer)"
}

#------------------------------------------------------------
## @brief  Retourne le nom du fichier d'aide principal
#  @return Nom du fichier d'aide principal : "astrocomputer.htm"
#
proc ::astrocomputer::getPluginHelp { } {
   return "astrocomputer.htm"
}

#------------------------------------------------------------
## @brief  Retourne le type de plugin
#  @return Type de plugin : "tool"
#
proc ::astrocomputer::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## @brief  Retourne le nom du répertoire du plugin
#  @return Nom du répertoire du plugin : "astrocomputer"
#
proc ::astrocomputer::getPluginDirectory { } {
   return "astrocomputer"
}

#------------------------------------------------------------
## @brief  Retourne le ou les OS de fonctionnement du plugin
#  @return Liste des OS : "Windows Linux Darwin"
#
proc ::astrocomputer::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief  Retourne les propriétés de l'outil
#
#          Cet outil s'ouvre dans une fenêtre indépendante à partir du menu Affichage
#  @param  propertyName Nom de la propriété
#  @return Valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::astrocomputer::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "display" }
      subfunction1 { return "calculator" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief  Creé une nouvelle instance de l'outil
#  @param  base   Base Tk
#  @param  visuNo Numéro de la visu
#  @return Chemin de la fenêtre
#
proc ::astrocomputer::createPluginInstance { base { visuNo 1 } } {
   variable wbase

   set wbase $base.astcmpt

   ::astrocomputer::confToWidget

   # --- default values
   set ::astrocomputer(formula)                      "3"
   set ::astrocomputer(formatmenuinp1)               "nombres dates angles distances"
   set ::astrocomputer(formatinp1,index)             0
   set ::astrocomputer(formatinp1,lastindex)         $::astrocomputer(formatinp1,index)
   set ::astrocomputer(result)                       ""

   set ::astrocomputer(redshift)                     "3"
   # --- Planck +Wmap + HighL + BAO
   set ::astrocomputer(hubble)                       "67.80"
   set ::astrocomputer(omegav)                       "0.692"
   set ::astrocomputer(omegam)                       [expr 1.-$::astrocomputer(omegav)]

   set ::astrocomputer(coordinp)                     "12 34 51.234 +34 10 10 J2000.0"
   set ::astrocomputer(siteinp)                      $::audace(posobs,observateur,gps)
   set ::astrocomputer(dateinp)                      ""

   set ::astrocomputer(formatnombresout1)            "10 2 8 16 ascii"
   set ::astrocomputer(formatnombreout1,index)       0
   set ::astrocomputer(formatnombreout1,lastindex)   $::astrocomputer(formatnombreout1,index)

   set ::astrocomputer(formatdatesout1)              "jd mjd iso8601 ymdhms"
   set ::astrocomputer(formatdateout1,index)         0
   set ::astrocomputer(formatdateout1,lastindex)     $::astrocomputer(formatdateout1,index)

   set ::astrocomputer(formatanglesout1)             "deg dms hms sigdms rad"
   set ::astrocomputer(formatangleout1,index)        0
   set ::astrocomputer(formatangleout1,lastindex)    $::astrocomputer(formatangleout1,index)

   set ::astrocomputer(formatdistancesout1)          "parsec ly ua plx dm m"
   set ::astrocomputer(formatdistanceout1,index)     0
   set ::astrocomputer(formatdistanceout1,lastindex) $::astrocomputer(formatdistanceout1,index)

   #--- J'ouvre la fenetre
   ::astrocomputer::astrocomputer_ihm

   #---
   return $wbase
}

#------------------------------------------------------------
## @brief Suppprime l'instance du plugin
#  @param visuNo Numéro de la visu
#
proc ::astrocomputer::deletePluginInstance { visuNo } {
   variable wbase

   if { [ winfo exists $wbase ] } {
      #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::astrocomputer::cmdClose
   }
}

#------------------------------------------------------------
## @brief Initialise les variables de l'outil "Calculatrice astronomique"
#  @details Les variables \::conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - \::conf(astrocomputer,geometry) définit les dimensions et la position de la fenêtre
#
proc ::astrocomputer::initConf { } {
   if { ! [ info exists ::conf(astrocomputer,geometry) ] } { set ::conf(astrocomputer,geometry) "380x590+400+5" }
}

#------------------------------------------------------------
## @brief Charge les variables de configuration dans des variables locales
#
proc ::astrocomputer::confToWidget { } {
   variable widget

   ::astrocomputer::initConf
   set widget(astrocomputer,geometry) $::conf(astrocomputer,geometry)
}

#------------------------------------------------------------
## @brief Charge les variables locales dans des variables de configuration
#
proc ::astrocomputer::widgetToConf { } {
   variable wbase
   variable widget

   set widget(astrocomputer,geometry) [ wm geometry $wbase ]
   set ::conf(astrocomputer,geometry) $widget(astrocomputer,geometry)
}

#------------------------------------------------------------
## @brief Commande du bouton "Fermer"
#
proc ::astrocomputer::cmdClose { } {
   variable wbase

   #--- Recupere la position de la fenetre
   ::astrocomputer::widgetToConf
   #--- Detruit la fenetre
   destroy $wbase
}

#------------------------------------------------------------
## @brief Crée l'interface graphique pour les onglets
#
proc ::astrocomputer::astrocomputer_ihm { { mode "" } } {
   variable wbase
   variable widget

   #--- Cree la fenetre .ohp de niveau le plus haut
   toplevel $wbase -class Toplevel
   wm geometry $wbase $widget(astrocomputer,geometry)
   wm resizable $wbase 1 1
   wm minsize $wbase 380 600
   wm title $wbase $::caption(astrocomputer,astrocomputer)
   wm protocol $wbase WM_DELETE_WINDOW ::astrocomputer::cmdClose

   #--- Met la fenetre au premier plan
   wm attributes $wbase -topmost 1

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $wbase.cmd -borderwidth 1 -relief raised

      button $wbase.cmd.fermer -text $::caption(astrocomputer,fermer) -width 7 \
          -command "::astrocomputer::cmdClose"
      pack $wbase.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $wbase.cmd.aide -text $::caption(astrocomputer,aide) -width 7 \
          -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::astrocomputer::getPluginType ] ] \
             [ ::astrocomputer::getPluginDirectory ] [ ::astrocomputer::getPluginHelp ]"
      pack $wbase.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $wbase.cmd -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $wbase.f -borderwidth 0 -relief raised

   #--- Creation de la fenetre a onglets
   set notebook [ NoteBook $wbase.f.onglet ]
   set k 0
   foreach onglet $::caption(astrocomputer,onglets) {
      set frm [ $notebook insert end $k -text "$onglet " ]
      set ::astrocomputer(onglets,widget,$k) $wbase.f.onglet.$k
      set ::astrocomputer(onglets,widget,$k) [$notebook getframe $k]
      incr k
   }
   pack $notebook -fill both -expand 1 -padx 0 -pady 0
   $notebook raise 0

   pack $wbase.f -side top -fill both -expand 1

   if {$mode=="conversion"} {
      ::astrocomputer::astrocomputer_conversion
   } elseif {$mode=="cosmology"} {
      ::astrocomputer::cmdApplyAstrocomputer_cosmology
   } elseif {$mode=="coordinateapp"} {
      ::astrocomputer::cmdApplyAstrocomputer_coordinatesapp
   } else {
      ::astrocomputer::astrocomputer_conversion
      ::astrocomputer::cmdApplyAstrocomputer_cosmology
      ::astrocomputer::cmdApplyAstrocomputer_coordinatesapp
   }

   #--- La fenetre est active
   focus $wbase

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $wbase <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $wbase
}

#################################################################################################
#### CONVERSION
#################################################################################################

#------------------------------------------------------------
## @brief Crée l'interface graphique de l'onglet "Conversion"
#
proc ::astrocomputer::astrocomputer_conversion { } {
   set wbase $::astrocomputer(onglets,widget,0)
   frame $wbase.conversion -bg #123456
   pack $wbase.conversion \
      -in $wbase -fill both -side top
   #--- Cree le titre
   label $wbase.conversion.title \
      -font [ list {Arial} 16 bold ] -text "==== $::caption(astrocomputer,conversion) ====" \
      -borderwidth 0 -relief flat
   pack $wbase.conversion.title \
      -in $wbase.conversion -fill x -side top -pady 10
   # ----
   label $wbase.conversion.bline0 \
      -font [ list {Arial} 5 bold ] -text " " \
      -borderwidth 0 -relief flat
   pack $wbase.conversion.bline0 \
      -in $wbase.conversion -fill x -side top
   # ---- Cree le champ de la formule de calcul
   label $wbase.conversion.acq1_labl \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,exprConvertir) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.conversion.acq1_labl \
      -in $wbase.conversion -fill x -side top -pady 5
   entry $wbase.conversion.acq1_ent1 \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(formula) \
      -borderwidth 0 -width 30
   pack $wbase.conversion.acq1_ent1 \
      -in $wbase.conversion -side top -pady 6 -padx 6
   label $wbase.conversion.acq1_lab2 \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,formatExpr) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.conversion.acq1_lab2 \
      -in $wbase.conversion -fill x -side top -pady 5
   set k 0
   foreach formatinp1 $::caption(astrocomputer,formatinp1) {
      radiobutton $wbase.conversion.acq1_rb$k \
         -font [ list {Arial} 10 bold ] -var ::astrocomputer(formatinp1,index) \
         -text $formatinp1 -value $k -indicatoron 0 -command { after 100 ; ::astrocomputer::astrocomputer_conversion_menu $::astrocomputer(formatinp1,index) }
      pack $wbase.conversion.acq1_rb$k \
         -in $wbase.conversion -fill x -side top -pady 0 -padx 40
      incr k
   }
   # ----
   label $wbase.conversion.nombres1_labl \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,formatConversion) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.conversion.nombres1_labl \
      -in $wbase.conversion -fill x -side top -pady 5
   # ----
   ::astrocomputer::astrocomputer_conversion_menu $::astrocomputer(formatinp1,index)
}

#------------------------------------------------------------
## @brief Configure les boutons de l'onglet "Conversion" en fonction du choix
#  @param index Numéro du bouton
#  @param destroyonly Option pour sortir
#
proc ::astrocomputer::astrocomputer_conversion_menu { index { destroyonly 0 } } {
   set wbase $::astrocomputer(onglets,widget,0)
   set prev [lindex $::astrocomputer(formatmenuinp1) $::astrocomputer(formatinp1,lastindex)]
   set curr [lindex $::astrocomputer(formatmenuinp1) $::astrocomputer(formatinp1,index)]
   #::console::affiche_resultat "MENU prev=$prev curr=$curr\n"
   # === masque les boutons existants
   # --- masque les nombres
   set k 0
   foreach formatout1 $::caption(astrocomputer,formatnombreout1) {
      if {[info commands $wbase.conversion.nombres1_rb$k]!=""} {
         destroy $wbase.conversion.nombres1_rb$k
      }
      incr k
   }
   # --- masque les dates
   set k 0
   foreach formatdatesout1 $::caption(astrocomputer,formatdateout1) {
      if {[info commands $wbase.conversion.dates1_rb$k]!=""} {
         destroy $wbase.conversion.dates1_rb$k
      }
      incr k
   }
   # --- masque les angles
   set k 0
   foreach formatanglesout1 $::caption(astrocomputer,formatangleout1) {
      if {[info commands $wbase.conversion.angles1_rb$k]!=""} {
         destroy $wbase.conversion.angles1_rb$k
      }
      incr k
   }
   # --- masque les distances
   set k 0
   foreach formatdistancesout1 $::caption(astrocomputer,formatdistanceout1) {
      if {[info commands $wbase.conversion.distances1_rb$k]!=""} {
         destroy $wbase.conversion.distances1_rb$k
      }
      incr k
   }
   # --- masque la zone de resultats
   if {[info commands $wbase.conversion.res1_labl]!=""} {
      destroy $wbase.conversion.res1_labl
   }
   if {[info commands $wbase.conversion.res1_ent1]!=""} {
      destroy $wbase.conversion.res1_ent1
   }
   if {[info commands $wbase.conversion.res1_b1]!=""} {
      destroy $wbase.conversion.res1_b1
   }
   if {$destroyonly==1} {
      return
   }
   # === cree et affiche les boutons
   if {$curr=="nombres"} {
      # --- cree les nombres
      set k 0
      #::console::affiche_resultat "::astrocomputer(formatout1)=$::astrocomputer(formatout1)\n"
      foreach formatout1 $::caption(astrocomputer,formatnombreout1) {
         if {[info commands $wbase.nombres1_rb$k]==""} {
            radiobutton $wbase.conversion.nombres1_rb$k \
               -font [ list {Arial} 10 bold ] -var ::astrocomputer(formatnombreout1,index) \
               -text $formatout1 -value $k -indicatoron 0 -command { after 100 ; ::astrocomputer::astrocomputer_conversion_nombres $::astrocomputer(formatnombreout1,index) }
         }
         pack $wbase.conversion.nombres1_rb$k \
            -in $wbase.conversion -fill x -side top -pady 0 -padx 40
         incr k
      }
   }
   if {$curr=="dates"} {
      set k 0
      foreach formatdateout1 $::caption(astrocomputer,formatdateout1) {
         radiobutton $wbase.conversion.dates1_rb$k \
            -font [ list {Arial} 10 bold ] -var ::astrocomputer(formatdateout1,index) \
            -text $formatdateout1 -value $k -indicatoron 0 -command { after 100 ; ::astrocomputer::astrocomputer_conversion_dates $::astrocomputer(formatdateout1,index) }
         pack $wbase.conversion.dates1_rb$k \
            -in $wbase.conversion -fill x -side top -pady 0 -padx 40
         incr k
      }
   }
   if {$curr=="angles"} {
      set k 0
      #::console::affiche_resultat "::astrocomputer(formatout1)=$::astrocomputer(formatout1)\n"
      foreach formatangleout1 $::caption(astrocomputer,formatangleout1) {
         radiobutton $wbase.conversion.angles1_rb$k \
            -font [ list {Arial} 10 bold ] -var ::astrocomputer(formatangleout1,index) \
            -text $formatangleout1 -value $k -indicatoron 0 -command { after 100 ; ::astrocomputer::astrocomputer_conversion_angles $::astrocomputer(formatangleout1,index) }
         #::console::affiche_resultat "formatout1=$formatout1\n"
         pack $wbase.conversion.angles1_rb$k \
            -in $wbase.conversion -fill x -side top -pady 0 -padx 40
         incr k
      }
   }
   if {$curr=="distances"} {
      set k 0
      #::console::affiche_resultat "::astrocomputer(formatout1)=$::astrocomputer(formatout1)\n"
      foreach formatdistanceout1 $::caption(astrocomputer,formatdistanceout1) {
         radiobutton $wbase.conversion.distances1_rb$k \
            -font [ list {Arial} 10 bold ] -var ::astrocomputer(formatdistanceout1,index) \
            -text $formatdistanceout1 -value $k -indicatoron 0 -command { after 100 ; ::astrocomputer::astrocomputer_conversion_distances $::astrocomputer(formatdistanceout1,index) }
         #::console::affiche_resultat "formatout1=$formatout1\n"
         pack $wbase.conversion.distances1_rb$k \
            -in $wbase.conversion -fill x -side top -pady 0 -padx 40
         incr k
      }
   }
   # --- affichage du resultat
   # ---- Cree le champ de la formule de calcul
   label $wbase.conversion.res1_labl \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,resultConversion) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.conversion.res1_labl \
      -in $wbase.conversion -fill x -side top -pady 5
   entry $wbase.conversion.res1_ent1 \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(result) \
      -borderwidth 0 -width 30
   pack $wbase.conversion.res1_ent1 \
      -in $wbase.conversion -side top -pady 6 -padx 6
   #if {($curr=="dates")||($curr=="angles")} {
   #  button $wbase.conversion.res1_b1 \
   #     -font [ list {Arial} 10 bold ] \
   #     -text $::caption(astrocomputer,copierResult) -command { set ::astrocomputer(formula) $::astrocomputer(result) ; set ::astrocomputer(result) "" ; update }
   #  pack $wbase.conversion.res1_b1 \
   #     -in $wbase -fill x -side top -pady 5 -padx 40
   #}
   # ---
   ::confColor::applyColor $wbase
   update
   set ::astrocomputer(formatinp1,lastindex) $index
   set ::astrocomputer(formatnombreout1,index) 0
   set ::astrocomputer(formatnombreout1,lastindex) $::astrocomputer(formatnombreout1,index)
}

#------------------------------------------------------------
## @brief Réalise la conversion pour les nombres
#  @param index Valeur non utilisée
#
proc ::astrocomputer::astrocomputer_conversion_nombres { index } {
   set basein  [lindex $::astrocomputer(formatnombresout1) $::astrocomputer(formatnombreout1,lastindex)]
   set baseout [lindex $::astrocomputer(formatnombresout1) $::astrocomputer(formatnombreout1,index)]
   set formula0 $::astrocomputer(formula)
   set formula $::astrocomputer(formula)
   #::console::affiche_resultat "basein=$basein baseout=$baseout formula=$formula\n"
   set resultat ""
   if {$basein==10} {
      set toeval "expr $formula"
      set err [catch {
         set resultat [eval $toeval]
      } msg]
      if {$err==1} {
         set resultat "Syntax error : $msg"
      }
      set formula $resultat
      if {$baseout==10} {
         set resultat "$msg"
      }
   }
   if {($basein!=10)||($baseout!=10)} {
      set toeval "::astrocomputer::astrocomputer_convert_base \"$formula\" $basein $baseout"
      set resultat [eval $toeval]
   }
   ::console::affiche_resultat "$::caption(astrocomputer,conversion)\n $formula0 ([lindex $::caption(astrocomputer,formatnombreout1) $::astrocomputer(formatnombreout1,lastindex)]) => $resultat ([lindex $::caption(astrocomputer,formatnombreout1) $::astrocomputer(formatnombreout1,index)])\n"
   set ::astrocomputer(formula) $resultat
   set ::astrocomputer(result)  $resultat
   update
   set ::astrocomputer(formatnombreout1,lastindex) $index
}

#------------------------------------------------------------
## @brief Réalise la conversion pour les dates
#  @param index Valeur non utilisée
#
proc ::astrocomputer::astrocomputer_conversion_dates { index } {
   set formatin  [lindex $::astrocomputer(formatdatesout1) $::astrocomputer(formatdateout1,lastindex)]
   set formatout [lindex $::astrocomputer(formatdatesout1) $::astrocomputer(formatdateout1,index)]
   set formula $::astrocomputer(formula)
   #::console::affiche_resultat "formatin=$formatin formatout=$formatout formula=$formula\n"
   set resultat [::astrocomputer::astrocomputer_convert_date $formula $formatin $formatout]
   set ::astrocomputer(result) $resultat
   ::console::affiche_resultat "$::caption(astrocomputer,conversion)\n $formula => $resultat ([lindex $::caption(astrocomputer,formatdateout1) $::astrocomputer(formatdateout1,index)])\n"
   update
   set ::astrocomputer(formatdateout1,lastindex) $::astrocomputer(formatdateout1,index)
}

#------------------------------------------------------------
## @brief Réalise la conversion pour les angles
#  @param index Valeur non utilisée
#
proc ::astrocomputer::astrocomputer_conversion_angles { index } {
   set formatin  [lindex $::astrocomputer(formatanglesout1) $::astrocomputer(formatangleout1,lastindex)]
   set formatout [lindex $::astrocomputer(formatanglesout1) $::astrocomputer(formatangleout1,index)]
   set formula $::astrocomputer(formula)
   #::console::affiche_resultat "formatin=$formatin formatout=$formatout formula=$formula\n"
   set resultat [::astrocomputer::astrocomputer_convert_angle $formula $formatin $formatout]
   set ::astrocomputer(result) $resultat
   ::console::affiche_resultat "$::caption(astrocomputer,conversion)\n $formula => $resultat ([lindex $::astrocomputer(formatanglesout1) $::astrocomputer(formatangleout1,index)])\n"
   update
   set ::astrocomputer(formatangleout1,lastindex) $::astrocomputer(formatangleout1,index)
}

#------------------------------------------------------------
## @brief Formate le résultat de la conversion pour les dates
#  @param date      Valeur de la date
#  @param formatin  Format d'entrée de la date
#  @param formatout Format de sortie de la date
#
proc ::astrocomputer::astrocomputer_convert_date { date formatin formatout } {
   # --- conversion en jour julien
   set jd [mc_date2jd $date]
   # --- conversion au format de sortie
   if {$formatout=="jd"} {
      set resultat $jd
   }
   if {$formatout=="mjd"} {
      set resultat [expr $jd-2400000.5]
   }
   if {$formatout=="iso8601"} {
      set resultat [mc_date2iso8601 $jd]
   }
   if {$formatout=="ymdhms"} {
      set res [mc_date2ymdhms $jd]
      set resultat "[format %d [lindex $res 0]] [format %02d [lindex $res 1]] [format %02d [lindex $res 2]] [format %02d [lindex $res 3]] [format %02d [lindex $res 4]] [format %06.3f [lindex $res 5]]"
   }
   return $resultat
}

#------------------------------------------------------------
## @brief Formate le résultat de la conversion pour les angles
#  @param angle     Valeur de l'angle
#  @param formatin  Format d'entrée de l'angle
#  @param formatout Format de sortie de l'angle
#
proc ::astrocomputer::astrocomputer_convert_angle { angle formatin formatout } {
   # --- conversion en deg
   set k1 [string first + $angle]
   set k2 [string first - $angle]
   if {($k1>=0)||($k2>=0)} {
      set modulo 90
      set sign +
   } else {
      set modulo ""
      set sign auto
   }
   #if {$formatin=="rad"} {
   #   set angle ${angle}r
   #}
   set deg [mc_angle2deg $angle $modulo]
   # --- conversion au format de sortie
   set resultat $deg
   if {$formatout=="deg"} {
      set res [string trimleft [string trim $deg] 0]
      set res [string trimright $res 0]
      if {[string index $res 0]=="."} {
         set res "0${res}"
      }
      if {[string index $res end]=="."} {
         append res "0"
      }
      set resultat $res
   }
   set sig ""
   if {$formatout=="dms"} {
      set res [mc_angle2dms $deg $modulo zero 3 $sign list]
      if {$sign=="auto"} {
         if {[string first - $res]>=0} {
            set sig -
            set deg [string trimleft [string range [lindex $res 0] 1 end] 0]
         } else {
            set sig ""
            set deg [string trimleft [string range [lindex $res 0] 0 end] 0]
         }
      } else {
         set sig [string index [lindex $res 0] 0]
         set deg [string trimleft [string range [lindex $res 0] 1 end] 0]
      }
      if {$deg==""} { set deg 0 }
      #::console::affiche_resultat "sig=$sig $deg=$deg res=$res sign=$sign\n"
      set res0 "${sig}[format %03d $deg]"
      set resultat "$res0 [lrange $res 1 end]"
   }
   if {$formatout=="hms"} {
      set res [mc_angle2hms $deg $modulo zero 3 $sign list]
      if {$sign=="auto"} {
         if {[string first - $res]>=0} {
            set sig -
            set deg [string trimleft [string range [lindex $res 0] 1 end] 0]
         } else {
            set sig ""
            set deg [string trimleft [string range [lindex $res 0] 0 end] 0]
         }
      } else {
         set sig [string index [lindex $res 0] 0]
         set deg [string trimleft [string range [lindex $res 0] 1 end] 0]
      }
      if {$deg==""} { set deg 0 }
      set res0 "[format %02d $deg]"
      set resultat "$res0 [lrange $res 1 end]"
   }
   if {$formatout=="sigdms"} {
      set res [mc_angle2dms $deg $modulo zero 3 + list]
      set sig [string index [lindex $res 0] 0]
      set deg [string trimleft [string range [lindex $res 0] 1 end] 0]
      if {$deg==""} { set deg 0 }
      set res0 "${sig}[format %03d $deg]"
      set resultat "$res0 [lrange $res 1 end]"
   }
   if {$formatout=="rad"} {
      set resultat [mc_angle2rad $deg $modulo]
   }
   return $resultat
}

#------------------------------------------------------------
## @brief Formate le résultat de la conversion pour les nombres
#  @param nombre  Valeur du nombre
#  @param basein  Système (base) d'entrée du nombre
#  @param baseout Système (base) de sortie du nombre
#
proc ::astrocomputer::astrocomputer_convert_base { nombre basein baseout } {
   set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}
   # --- conversion vers la base decimale
   if {$basein=="ascii"} {
      set nombre [string index $nombre 0]
      if {$nombre==""} {
         set nombre " "
      }
      for {set k 0} {$k<256} {incr k} {
         set car [format %c $k]
         if {$car==$nombre} {
            set integ_decimal $k
         }
      }
   } else {
      set symbins [lrange $symbols 0 [expr $basein-1]]
      set n [expr [string length $nombre]-1]
      set integ_decimal 0
      for {set k $n} {$k>=0} {incr k -1} {
         set mult [expr pow($basein,$n-$k)]
         set digit [string index $nombre $k]
         set kk [lsearch -exact $symbins $digit]
         if {$kk==-1} {
            break
         } else {
            set digit $kk
         }
         #::console::affiche_resultat "nombre=$nombre k=$k n-k=$n-$k digit=$digit mult=$mult\n"
         set integ_decimal [expr $integ_decimal+$digit*$mult]
      }
   }
   # --- conversion vers la base de sortie
   set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}
   set integ [expr abs(round($integ_decimal))]
   if {$baseout=="ascii"} {
      if {$integ>255} {
         set integ 255
      }
      set bb [format %c $integ]
   } else {
      set sortie 0
      set bb ""
      set k 0
      while {$sortie==0} {
         set b [expr round(floor($integ/$baseout))]
         set reste [lindex $symbols [expr $integ-$baseout*$b]]
         #::console::affiche_resultat "bb=$bb\n"
         set bb "${reste}${bb}"
         #::console::affiche_resultat "integ=$integ base=$base => b=$b reste=$reste bb=$bb\n"
         set integ $b
         if {$b<1} {
            set sortie 1
            break
         }
         incr k
      }
   }
   return $bb
}

#------------------------------------------------------------
## @brief Réalise la conversion pour les distances
#  @param index Valeur non utilisée
#
proc ::astrocomputer::astrocomputer_conversion_distances { index } {
   set formatin  [lindex $::astrocomputer(formatdistancesout1) $::astrocomputer(formatdistanceout1,lastindex)]
   set formatout [lindex $::astrocomputer(formatdistancesout1) $::astrocomputer(formatdistanceout1,index)]
   set formula $::astrocomputer(formula)
   #::console::affiche_resultat "formatin=$formatin formatout=$formatout formula=$formula\n"
   set resultat [::astrocomputer::astrocomputer_convert_distance $formula $formatin $formatout]
   set ::astrocomputer(formula) $resultat
   set ::astrocomputer(result)  $resultat
   ::console::affiche_resultat "$::caption(astrocomputer,conversion)\n $formula ([lindex $::astrocomputer(formatdistancesout1) $::astrocomputer(formatdistanceout1,lastindex)]) => $resultat ([lindex $::astrocomputer(formatdistancesout1) $::astrocomputer(formatdistanceout1,index)])\n"
   update
   set ::astrocomputer(formatdistanceout1,lastindex) $::astrocomputer(formatdistanceout1,index)
}

#------------------------------------------------------------
## @brief Formate le résultat de la conversion pour les distances
#  @param distance  Valeur de la distance
#  @param formatin  Format d'entrée de la distance
#  @param formatout Format de sortie de la distance
#
proc ::astrocomputer::astrocomputer_convert_distance { distance formatin formatout } {
   set pc1 3.08568025e16 ; # 1 pc -> m
   set ly1 9.460e15; # 1 ly -> m
   set au1 149597870691. ; # 1 AU -> m
   set pi [expr 4.*atan(1)]
   set resultat ""
   # --- conversion en metres
   if {$formatin=="parsec"} {
      set m [expr $distance*$pc1]
   }
   if {$formatin=="ly"} {
      set m [expr $distance*$ly1]
   }
   if {$formatin=="ua"} {
      set m [expr $distance*$au1]
   }
   if {$formatin=="plx"} {
      set plxrad [expr $distance*$pi/180*1e-3/60/60]
      set m [expr $au1/$plxrad]
   }
   if {$formatin=="dm"} {
      set d [expr pow(10,(($distance+5.)/5.))]
      set m [expr $d*$pc1]
   }
   if {$formatin=="m"} {
      set m [expr $distance]
   }
   # --- conversion au format de sortie
   if {$formatout=="parsec"} {
      set resultat [expr $m/$pc1]
   }
   if {$formatout=="ly"} {
      set resultat [expr $m/$ly1]
   }
   if {$formatout=="ua"} {
      set resultat [expr $m/$au1]
   }
   if {$formatout=="plx"} {
      set plxrad [expr $au1/$m]
      set resultat [expr $plxrad/$pi*180/1e-3*60*60]
   }
   if {$formatout=="dm"} {
      set d [expr $m/$pc1]
      set resultat [expr 5.*log10($d)-5]
   }
   if {$formatout=="m"} {
      set resultat $m
   }
   return $resultat
}

#################################################################################################
#### COSMOLOGY
#################################################################################################

#------------------------------------------------------------
## @brief Crée l'interface graphique de l'onglet "Cosmologie"
#
proc ::astrocomputer::cmdApplyAstrocomputer_cosmology { } {
   set wbase $::astrocomputer(onglets,widget,1)
   frame $wbase.cosmology -bg #123456
   pack $wbase.cosmology \
      -in $wbase -fill both -side top
   #--- Cree le titre
   label $wbase.cosmology.title \
      -font [ list {Arial} 16 bold ] -text "==== $::caption(astrocomputer,cosmologie) ====" \
      -borderwidth 0 -relief flat
   pack $wbase.cosmology.title \
      -in $wbase.cosmology -fill x -side top -pady 10
   # ----
   label $wbase.cosmology.bline0 \
      -font [ list {Arial} 5 bold ] -text " " \
      -borderwidth 0 -relief flat
   pack $wbase.cosmology.bline0 \
      -in $wbase.cosmology -fill x -side top
   # ---- Cree le champ du redshift
   label $wbase.cosmology.cos1_labz \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,redshift) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.cosmology.cos1_labz \
      -in $wbase.cosmology -fill x -side top -pady 5
   entry $wbase.cosmology.cos1_entz \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(redshift) \
      -borderwidth 0 -width 30
   pack $wbase.cosmology.cos1_entz \
      -in $wbase.cosmology -side top -pady 6 -padx 6
   # ---- Cree le champ de la constante de Hubble
   label $wbase.cosmology.cos1_labh0 \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,cteHubble) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.cosmology.cos1_labh0 \
      -in $wbase.cosmology -fill x -side top -pady 5
   entry $wbase.cosmology.cos1_enth0 \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(hubble) \
      -borderwidth 0 -width 30
   pack $wbase.cosmology.cos1_enth0 \
      -in $wbase.cosmology -side top -pady 6 -padx 6
   # ---- Cree le champ du Omega M
   label $wbase.cosmology.cos1_labom \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,omegaMatiere) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.cosmology.cos1_labom \
      -in $wbase.cosmology -fill x -side top -pady 5
   entry $wbase.cosmology.cos1_entom \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(omegam) \
      -borderwidth 0 -width 30
   pack $wbase.cosmology.cos1_entom \
      -in $wbase.cosmology -side top -pady 6 -padx 6
   # ---- Cree le champ du Omega V
   label $wbase.cosmology.cos1_labov \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,omegaVide) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.cosmology.cos1_labov \
      -in $wbase.cosmology -fill x -side top -pady 5
   entry $wbase.cosmology.cos1_entov \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(omegav) \
      -borderwidth 0 -width 30
   pack $wbase.cosmology.cos1_entov \
      -in $wbase.cosmology -side top -pady 6 -padx 6
   # === cree et affiche les boutons
   button $wbase.cosmology.cos1_b1 \
      -font [ list {Arial} 10 bold ] \
      -text $::caption(astrocomputer,result) -command { ::astrocomputer::astrocomputer_cosmo_wright ; update }
   pack $wbase.cosmology.cos1_b1 \
      -in $wbase.cosmology -fill x -side top -pady 5 -padx 40
   text $wbase.cosmology.cos1_ent2 \
      -font [ list {Arial} 8 bold ] -wrap word \
      -borderwidth 1
#     -yscrollcommand {$wbase.cosmology.cos1_ent2.scr1 set}
   pack $wbase.cosmology.cos1_ent2 \
      -in $wbase.cosmology -side top -pady 6 -padx 6 -fill both
#    scrollbar $wbase.cosmology.cos1_ent2.scr1 -orient vertical \
#       -command {$wbase.cosmology.cos1_ent2 yview} -takefocus 0 -borderwidth 1
#    pack $wbase.cosmology.cos1_ent2.scr1 \
#       -in $wbase.cosmology.cos1_ent2 -side right -fill y
}

#------------------------------------------------------------
## @brief Correspond à la commande du bouton "Résultats" de l'onglet "Cosmologie"
#
proc ::astrocomputer::astrocomputer_cosmo_wright { } {
   set wbase $::astrocomputer(onglets,widget,1)
   set z  $::astrocomputer(redshift)
   set h  $::astrocomputer(hubble)
   set om $::astrocomputer(omegam)
   set ov $::astrocomputer(omegav)
   set res [mc_cosmology_calculator $z $h $om $ov]
   set resultat ""
   foreach re $res {
      set val [lindex $re 1]
      set com [lindex $re 2]
      append resultat "$val $com\n"
   }
   ::console::affiche_resultat "$::caption(astrocomputer,cosmologie)\n$resultat"
   set res [lrange $res 4 end]
   set resultat ""
   foreach re $res {
      set val [lindex $re 1]
      set com [lindex $re 2]
      append resultat "$val $com\n"
   }
   #set ::astrocomputer(result) $resultat
   catch {$wbase.cosmology.cos1_ent2 delete 0.0 end}
   $wbase.cosmology.cos1_ent2 insert end "$resultat\n"
   $wbase.cosmology.cos1_ent2 yview moveto 1.0
}

#################################################################################################
#### APPARENT COORDINATES
#################################################################################################

#------------------------------------------------------------
## @brief Crée l'interface graphique de l'onglet "Coordonnées apparentes"
#
proc ::astrocomputer::cmdApplyAstrocomputer_coordinatesapp { } {
   set wbase $::astrocomputer(onglets,widget,2)
   frame $wbase.coordinateapp -bg #123456
   pack $wbase.coordinateapp \
      -in $wbase -fill both -side top
   #--- Cree le titre
   label $wbase.coordinateapp.title \
      -font [ list {Arial} 16 bold ] -text "==== $::caption(astrocomputer,coordApparentes) ====" \
      -borderwidth 0 -relief flat
   pack $wbase.coordinateapp.title \
      -in $wbase.coordinateapp -fill x -side top -pady 10
   # ----
   label $wbase.coordinateapp.bline0 \
      -font [ list {Arial} 5 bold ] -text " " \
      -borderwidth 0 -relief flat
   pack $wbase.coordinateapp.bline0 \
      -in $wbase.coordinateapp -fill x -side top
   # ---- Cree le champ d'entree des coordonnées
   label $wbase.coordinateapp.cos1_lab1 \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,coordRaDecEquinoxObj) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.coordinateapp.cos1_lab1 \
      -in $wbase.coordinateapp -fill x -side top -pady 5
   entry $wbase.coordinateapp.cos1_ent1 \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(coordinp) \
      -borderwidth 0 -width 30
   pack $wbase.coordinateapp.cos1_ent1 \
      -in $wbase.coordinateapp -side top -pady 6 -padx 6
   # ---- Cree le champ d'entree de la date
   label $wbase.coordinateapp.cos1_lab2 \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,dateUTC) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.coordinateapp.cos1_lab2 \
      -in $wbase.coordinateapp -fill x -side top -pady 5
   entry $wbase.coordinateapp.cos1_ent2 \
      -font [ list {Arial} 12 bold ] -textvariable ::astrocomputer(dateinp) \
      -borderwidth 0 -width 30
   pack $wbase.coordinateapp.cos1_ent2 \
      -in $wbase.coordinateapp -side top -pady 6 -padx 6
   # ---- Cree le champ d'entree du site
   label $wbase.coordinateapp.cos1_lab3 \
      -font [ list {Arial} 8 bold ] -text $::caption(astrocomputer,site) \
      -borderwidth 0 -relief flat -bg #123456 -fg #FFFFFF
   pack $wbase.coordinateapp.cos1_lab3 \
      -in $wbase.coordinateapp -fill x -side top -pady 5
   entry $wbase.coordinateapp.cos1_ent3 \
      -font [ list {Arial} 10 bold ] -textvariable ::astrocomputer(siteinp) \
      -borderwidth 0 -width 40
   pack $wbase.coordinateapp.cos1_ent3 \
      -in $wbase.coordinateapp -side top -pady 6 -padx 6
   # === cree et affiche les boutons
   button $wbase.coordinateapp.cos1_b10 \
      -font [ list {Arial} 10 bold ] \
      -text $::caption(astrocomputer,result) -command { ::astrocomputer::astrocomputer_coord_compute ; update }
   pack $wbase.coordinateapp.cos1_b10 \
      -in $wbase.coordinateapp -fill x -side top -pady 5 -padx 40
   text $wbase.coordinateapp.cos1_ent10 \
      -font [ list {Arial} 8 bold ] -wrap word \
      -borderwidth 1
#     -yscrollcommand {$wbase.coordinateapp.cos1_ent2.scr1 set}
   pack $wbase.coordinateapp.cos1_ent10 \
      -in $wbase.coordinateapp -side top -pady 6 -padx 6 -fill both
#    scrollbar $wbase.coordinateapp.cos1_ent2.scr1 -orient vertical \
#       -command {$wbase.coordinateapp.cos1_ent2 yview} -takefocus 0 -borderwidth 1
#    pack $wbase.coordinateapp.cos1_ent2.scr1 \
#       -in $wbase.coordinateapp.cos1_ent2 -side right -fill y
}

#------------------------------------------------------------
## @brief Correspond à la commande du bouton "Résultats" de l'onglet "Coordonnées apparentes"
#
proc ::astrocomputer::astrocomputer_coord_compute { } {
   set wbase $::astrocomputer(onglets,widget,2)
   # {id mag ra dec equinox epoch mura mudec plx}
   set objname ""
   set equinox ""
   if {$equinox==""} {
      set equinox J2000.0
      set epoch $equinox
   }
   if {$::astrocomputer(dateinp)==""} {
      set date [mc_date2jd [::audace::date_sys2ut now]]
   } else {
      set date [mc_date2jd $::astrocomputer(dateinp)]
   }
   if {$::astrocomputer(siteinp)==""} {
      set ::astrocomputer(siteinp) $::audace(posobs,observateur,gps)
   }
   set epoch J2000.0
   set mura 0
   set mudec 0
   set plx 0
   set r [string trim $::astrocomputer(coordinp)]
   set n [llength $r]
   set key [lindex $r 0]
   set valid 0
   set type ""
   #::console::affiche_resultat "key=$key\n"
   set err [ catch { expr $key } msg ]
   if {$err==1} {
      set res [mc_ephem $key]
      if {[llength $res]==1} {
         set res [satel_names $r]
         if {$res==""} {
            #::console::affiche_resultat "r=$r\n"
            set err2 [ catch {name2coord $r} msg2 ]
            #::console::affiche_resultat "msg2=$msg2\n"
            if {$err2==0} {
               set type "name2coord"
               set objname $r
               set ra [lindex $msg2 0]
               set dec [lindex $msg2 1]
               set equinox J2000.0
               set valid 1
            }
         } else {
            set type "satel_ephem"
            set objname [lindex [lindex $res 0] 0]
            set res [lindex [satel_ephem "$objname" $date $::astrocomputer(siteinp)] 0]
            set objname [lindex $res 0]
            set norad [string range [string trim [lindex $objname 1]] 0 end-1]
            set objname "[string trim [lindex $objname 0]] ([string trim [lindex $objname 1]]) ([string trim [lindex $objname 2]])"
            set ra  [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
            set dec [mc_angle2dms [lindex $res 2]  90 zero 1 + string]

            set elong [format %.2f [lindex $res 4]]
            set phase [format %.2f [lindex $res 5]]
            set fracill [lindex $res 6]
            set distkm [format %.2f [expr [lindex $res 3]*1e-3]]
            set sitezenith [lindex $res 7]
            set mag [::astrocomputer::astrocomputer_coord_satel_mag $norad $fracill $distkm $phase]
            set valid 1
         }
      } else {
         set type "mc_ephem"
         set res [lindex [mc_ephem $key $date {OBJENAME RA DEC DELTA MAG PHASE APPDIAMEQU LONGI LONGII ELONG} -topo $::astrocomputer(siteinp)] 0]
         set objname [lindex $res 0]
         set ra  [mc_angle2hms [lindex $res 1] 360 zero 2 auto string]
         set dec [mc_angle2dms [lindex $res 2]  90 zero 1 + string]
         set distua [format %.5f [lindex $res 3]]
         set mag [format %.2f [lindex $res 4]]
         set phase [format %.2f [lindex $res 5]]
         set d [lindex $res 6]
         set di [expr floor($d)]
         if {$di>0} {
            set diamapp $d
            set diamappu deg
         } else {
            set d [expr $d*60]
            set di [expr floor($d)]
            if {$di>0} {
               set diamapp $d
               set diamappu arcmin
            } else {
               set d [expr $d*60]
               set diamapp $d
               set diamappu arcsec
            }
         }
         set diamapp [format %.4f $diamapp]
         set longi [format %.2f [lindex $res 7]]
         set longii [format %.2f [lindex $res 8]]
         set elong [format %.2f [lindex $res 9]]
         set valid 1
      }
   }
   if {$valid==0} {
      if {$n<=3} {
         set ra [lindex $r 0]
         set dec [lindex $r 1]
         set equinox [lindex $r 2]
      } elseif {$n<=7} {
         set ra  [lindex $r 0]h[lindex $r 1]m[lindex $r 2]s
         set dec [lindex $r 3]d[lindex $r 4]m[lindex $r 5]s
         set equinox [lindex $r 6]
      }
   }
   set resultat ""
   if {($objname!="")} {
      append resultat "Object = $objname\n"
   }
   set hip [list 1 0 [mc_angle2deg $ra] [mc_angle2deg $dec 90] $equinox $epoch $mura $mudec $plx]
   #::console::affiche_resultat "hip=$hip\n\n"
   set res [ mc_hip2tel $hip $date $::astrocomputer(siteinp) $::audace(meteo,obs,pressure) [ expr $::audace(meteo,obs,temperature) + 273.15 ] ]
   append resultat "UTC Date = [mc_date2iso8601 $date]\n"
   append resultat "UTC Julian Day = [mc_date2jd $date]\n"
   append resultat "RA = $ra $equinox\nDEC = $dec $equinox\n\n"
   append resultat "RA = [mc_angle2hms [lindex $res 0] 360 zero 2 auto string] apparent\n"
   append resultat "DEC = [mc_angle2dms [lindex $res 1] 90 zero 2 + string] apparent\n"
   append resultat "HA = [mc_angle2hms [lindex $res 2] 360 zero 2 auto string] apparent\n"
   append resultat "Azimuth = [lindex $res 3] apparent\n"
   append resultat "Elevation = [lindex $res 4] apparent\n\n"
   # ---
   set res2 [mc_tt2bary [mc_date2tt $date] $ra $dec $equinox $::astrocomputer(siteinp)]
   append resultat "Barycentric Julian Day = $res2\n"
   if {$type=="mc_ephem"} {
      append resultat "Distance = $distua AU\n"
      append resultat "Magnitude = $mag\n"
      if {$objname!="Sun"} {
         append resultat "Phase = $phase deg\n"
         append resultat "Elongation = $elong deg\n"
      }
      append resultat "App. Diam. = $diamapp $diamappu\n"
      append resultat "Long I = $longi deg\n"
      if {$objname=="Jupiter"} {
         append resultat "Long II = $longii deg\n"
      }
   } elseif  {$type=="satel_ephem"} {
      append resultat "Distance = $distkm km\n"
      if {$mag!=99} {
         append resultat "Magnitude = [format %.2f $mag]\n"
      }
      append resultat "Sun illumination = $fracill\n"
      append resultat "Phase = $phase deg\n"
      append resultat "Elongation = $elong deg\n"
      append resultat "Seen at zenith = $sitezenith\n"
   } else {
      set res [mc_baryvel $date $ra $dec $equinox $::astrocomputer(siteinp)]
      append resultat "Topocentric velocity = [lindex $res 0] km/s\n"
      set res [mc_rvcor [list $ra $dec] $equinox KLSR] ; #|DLSR|GALC|LOG|COSM
      append resultat "KLSR velocity = [lindex $res 0] km/s\n"
      set res [mc_rvcor [list $ra $dec] $equinox GALC] ; #|DLSR|GALC|LOG|COSM
      append resultat "GALC velocity = [lindex $res 0] km/s\n"
      set res [mc_rvcor [list $ra $dec] $equinox COSM] ; #|DLSR|GALC|LOG|COSM
      append resultat "COSM velocity = [lindex $res 0] km/s\n"
   }
   # ---
   #append resultat "\n$res\n"
   #append resultat "\n$res\n"
   ::console::affiche_resultat "$::caption(astrocomputer,coordApparentes)\n$resultat\n"
   #set ::astrocomputer(result) $resultat
   catch {$wbase.coordinateapp.cos1_ent10 delete 0.0 end}
   $wbase.coordinateapp.cos1_ent10 insert end "$resultat\n"
   $wbase.coordinateapp.cos1_ent10 yview moveto 1.0
}

#------------------------------------------------------------
## @brief   Magnitude standard
#  @details La magnitude standard m0 est définie pour une distance de 1000 km et une illumination de 50%
#  @details La formule suivante donne la magnitude visuelle connaissant la distance d et l'illumination I :
#  @details m = m0 - 15.75 + 2.5 log10 (d2 / I)
#  @details La lettre qui suit la magnitude standard est :
#  @details Soit d lorsque la magnitude est calculée selon les dimensions du satellite
#  @details Soit v lorsque la magnitude est determinée visuellement
#  @details 25544  30.0 20.0  0.0 -0.5 v 404.00
#  @return  mag La magnitude standard
#
proc ::astrocomputer::astrocomputer_coord_satel_mag { norad fracill distkm phasedeg} {
   set mag 99
   if {$fracill==0} {
      set mag 99
   } else {
      if {[info exists ::astrocomputer(norad,mags)]==0} {
         set fname "$::audace(rep_catalogues)/satel_magnitudes.txt"
         set res [file exists $fname]
         if {$res==1} {
            set f [open $fname r]
            set ::astrocomputer(norad,mags) [split [read $f] \n]
            close $f
            set ::astrocomputer(norad,mags) [lrange $::astrocomputer(norad,mags) 0 end-1]
         }
      }
      if {[info exists ::astrocomputer(norad,mags)]==1} {
         foreach noradmags $::astrocomputer(norad,mags) {
            set noradid [lindex $noradmags 0]
            if {$noradid==$norad} {
               set m0 [lindex $noradmags 4]
               set d [expr $distkm/1000.]
               set i [expr $fracill*0.5*(1+cos($phasedeg*3.1416/180.))]
               #::console::affiche_resultat "MAG = expr $m0 - 2.5 * log10 (1. / 0.5) + 2.5 * log10 ($d*$d / $fracill)\n"
               set mag [expr $m0 - 2.5 * log10 (1. / 0.5) + 2.5 * log10 ($d*$d / $fracill)]
               break
            }
         }
      }
   }
   return $mag
}


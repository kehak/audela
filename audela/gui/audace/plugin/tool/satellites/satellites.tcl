#
## @file satellites.tcl
#  @brief Interface pour exploiter les satellites artificiels
#  @author Raymond Zachantke
#  $Id: satellites.tcl 13608 2016-04-04 14:08:51Z rzachantke $
#

#============================================================
# Declaration du namespace satellites
#    initialise le namespace
#============================================================

## @namespace satellites
#  @brief Interface pour exploiter les satellites artificiels
namespace eval ::satellites {
   package provide satellites 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] satellites.cap ]

}

#------------------------------------------------------------
# brief    retourne le titre du plugin dans la langue de l'utilisateur
# return   titre du plugin
#
proc ::satellites::getPluginTitle { } {
   global caption

   return "$caption(satellites,title)"
}

#------------------------------------------------------------
# brief    retourne le nom du fichier d'aide principal
# return   nom du fichier d'aide principal
#
proc ::satellites::getPluginHelp { } {
   return "satellites.htm"
}

#------------------------------------------------------------
# brief    retourne le type de plugin
# return   type de plugin
#
proc ::satellites::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief    retourne le nom du répertoire du plugin
# return   nom du répertoire du plugin : "satellites"
#
proc ::satellites::getPluginDirectory { } {
   return "satellites"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux Darwin"
#
proc ::satellites::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::satellites::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "satellites" }
      display      { return "window" }
      multivisu    { return 0 }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::satellites::createPluginInstance { base { visuNo 1 } } {
   variable This

   package require http
   package require struct::list

   set dirname [file join $::audace(rep_plugin) tool ]
   source [ file join $dirname satellites satellites_tech.tcl ]
   source [ file join $dirname satellites satellites_orbit.tcl ]
   source [ file join $dirname satellites satellites_radar.tcl ]

   set This "$base.satellites"

   #-- prepare et cree le notebook
   ::satellites::initDialog

   #--  cree la fenetre
   ::satellites::createMyNoteBook

   return "$This"
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::satellites::deletePluginInstance { {visuNo 1} } {
   variable This

   if {[winfo exists $This] ==1} {
      ::satellites::cmdClose
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Satellites"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(satellites,position)    définit la position de la fenêtre
#  - conf(satellites,options) définit les options de l'élévation minimale, du réglage du mode,
#    du zoom, de la vitesse de simulation, de l'affichage des grilles, de l'affichage du soleil et de la Lune.
#
proc ::satellites::initConf { } {
   global conf

   if {[ info exists conf(satellites,position)] ==0} { set conf(satellites,position) "+350+50" }
   if {[ info exists conf(satellites,options)] ==0}  { set conf(satellites,htmlOptions) [list 70 "Console" "1.0" "100" "1" "1"] }
}

#------------------------------------------------------------
#  brief   charge les variables de configuration dans des variables locales
#
proc ::satellites::confToWidget {} {
   variable private

   ::satellites::initConf

   set private(position) $::conf(satellites,position)
   #--   onglet orbit
   lassign $::conf(satellites,htmlOptions) private(elevMin) private(edition) private(zoom) \
      private(speed) private(grid) private(sunmoon)
}

#------------------------------------------------------------
#  brief   prépare la création de l'interface graphique
#
proc ::satellites::initDialog { } {
   variable private

   ::satellites::confToWidget

   #--   liste les variables 'entry' avec binding, modifiables par l'utilisateur
   set private(entry) [list gps tu satelra sateldec search]

   #--   liste les variables 'combobox'
   set private(combobox) [list edition speed zoom elevMin satname]

   #--   liste les variables 'checkbox'
   set private(checkbutton) [list grid sunmoon maj names]

   #--   preliminaires
   satel_names2 "" "" 0      ; #-- active la fabrication des listes  sans doublon
   set private(satname)      "ISS (ZARYA)"
   ::satellites::getTleFile  ; # definit private(tlefile) et verifie la mise a jour

   #--   valeurs par defaut
   lassign [coordofzenith]     private(satelra) private(sateldec)                                            ; # onglet near
   set private(listesatname)   "$::audace(satel,shortList)"                                                  ; # onglet coord
   set private(gps)            "$::audace(posobs,observateur,gps)"                                           ; # onglet near, orbit et radar
   set private(tu)             [ clock format [ clock seconds ] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC ] ; # onglet near, orbit et radar
   set private(listeedition)   [list $::caption(satellites,console) $::caption(satellites,htm)]              ; # onglet orbit
   set private(listespeed)     [list 1 100 200 400]                                                          ; # onglet orbit
   set private(listezoom)      [list 1.5 1.4 1.3 1.2 1.1 1.0 0.9 0.8 0.7 0.6 0.5]                            ; # onglet orbit
   set private(listeelevMin)   "[list 80 70 60 40 30 20 10]"                                                 ; # onglet radar
   set private(search)         "ISS"                                                                         ; # onglet TLE
}

#------------------------------------------------------------
#  brief   créé l'interface graphique
#
proc ::satellites::createMyNoteBook { } {
   variable This
   variable private
   global caption

   if {[winfo exists $This] ==1} {
      wm withdraw $This
      wm deiconify $This
      return
   }

   toplevel $This -class Toplevel
   wm title $This "$caption(satellites,title)"

   wm geometry $This "$private(position)"
   wm resizable $This 1 1
   wm protocol $This WM_DELETE_WINDOW "::satellites::cmdClose"

   ttk::style configure my.TEntry -foreground $::audace(color,entryTextColor)
   #ttk::style configure default.TEntry -foreground red

   pack [ttk::notebook $This.n]

   #--   liste et ordonnance les onglets
   set private(ltopic) [list coord near orbit radar names tle]
   set private(tabNames) ""
   foreach topic $private(ltopic) {
      lappend private(tabNames) "$caption(satellites,onglet_$topic)"
   }

   #--   liste des variables de chaque onglet
   set coordChildren [list gps tu satname]
   set nearChildren [list gps tu satelra sateldec]
   set orbitChildren [list gps tu satname edition speed zoom grid sunmoon]
   set radarChildren [list gps tu elevMin]
   set namesChildren [list search]
   set tleChildren [list ]

   #--   construit le notebook
   foreach topic $private(ltopic) title $private(tabNames) {
      set fr [frame $This.n.$topic]

      #--   ajoute un onglet
      $This.n add $fr -text "$title"

      #--   ajoute les lignes dans l'onglet
      set children [set ${topic}Children]
      set len [llength $children]
      for {set k 0} {$k < $len} {incr k} {
         set child [lindex $children $k]
         ::satellites::configLigne $fr $child $k
      }
      grid columnconfigure $fr {1} -pad 5 -weight 1
   }

   #--   boutons de commande principaux
   #--   ce frame est indépendant du notebook
   frame $This.cmd
      foreach {but side cmd} [list apply left cmdApply close right cmdClose hlp right cmdHelp]  {
         pack [ttk::button $This.cmd.$but -text "$caption(satellites,$but)" -width 10] \
            -side $side -padx 10 -pady 5 -ipady 5
         $This.cmd.$but configure -command "::satellites::$cmd"

         #--   memorise les widgets à inhiber/desinhiber
         lappend private(active) $This.cmd.$but
      }
   pack $This.cmd -in $This -side bottom -fill x

   ::satellites::configWidget !disabled

   ::satellites::displayOptions "$This.n.orbit"

   #--- La fenetre est active
   focus $This

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#------------------------------------------------------------
## @brief définit la commande du bouton "Appliquer"
#  en fonction de l'onglet
#
proc ::satellites::cmdApply { } {
   variable This
   variable private

   #--   inhibe tout
   ::satellites::configWidget disabled

   #--   identifie le nom de l'onglet
   set tabName [$This.n tab current -text]
   #--   identifie son index
   set tabIndex [lsearch -exact $private(tabNames) $tabName]

   switch -exact $tabIndex {
      0 {   #--  onglet "Coordonnées"
            set result [ catch { satel_coords $private(satname) $private(tu) $private(gps) } msg ]
            if {$result=="1"} {
               ::console::affiche_erreur "Error satel_coords : $msg\n"
            }  else {
               ::console::disp  "\n$msg\n"
            }
        }
      1 {   #--  onglet "Satellite le plus proche"
            set result [ catch { satel_nearest_radec $private(satelra) $private(sateldec) $private(tu) $private(gps) } msg ]
            if {$result=="1"} {
               ::console::affiche_erreur "Error satelnearest : $msg\n"
            }  else {
               ::console::disp  "\n$msg\n"
            }
        }
      2 {   #--  onglet "Orbites"
            set private(result) ""
            ::satellites::getSatelInfos
            if {$private(result) ne ""} {
               #--   Execute la commande d'edition
               set index [lsearch -exact $private(listeedition) $private(edition)]
               switch $index {
                  0 { ::satellites::writeConsole }
                  1 { ::satellites::createOrbitHtm }
               }
            }
        }
      3 {   #--  onglet "Radar"
            ::satellites::createRadar $private(tu) $private(gps) $private(elevMin)
        }
      4 {   #--  onglet "Noms"
            set result [ catch { satel_names $private(search) } msg ]
            if {$result=="1"} {
               ::console::affiche_erreur "$::caption(satellites,erreur) satel_names : $msg\n"
            }  else {
               ::console::disp  "\n$msg\n"
            }
        }
      5 {   #--  onglet "Fichiers TLE"
            satel_update
        }
   }

   #--   désinhibe tout
   ::satellites::configWidget !disabled
}

#------------------------------------------------------------
## @brief   commande du bouton "Fermer"
#
proc ::satellites::cmdClose { } {
   variable This
   variable private

    #--   detruit les variables volumineuses
   foreach v [list ::audace(satel,shortList) ::audace(satel,satel_names)] {
      if {[info exists $v] eq "1"} {
         unset $v
      }
   }

   set ::conf(satellites,options) [list $private(elevMin) $private(edition) \
      $private(zoom) $private(speed) $private(grid) $private(sunmoon) ]

   regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" ::conf(satellites,position)

   destroy $This
}

#------------------------------------------------------------
#   brief   commande du bouton "Aide"
#
proc ::satellites::cmdHelp { } {
  ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::satellites::getPluginType ] ] \
    [ ::satellites::getPluginDirectory ] satellites.htm
}

#------------------------------------------------------------
#  brief   construit une ligne d'un onglet
#  param topic  nom de longlet
#  param child  nom de l'enfant
#  param row    numéro de la ligne (row)
#  param visuNo numéro de la visu
#
proc ::satellites::configLigne { onglet child row } {
   variable private

   #--   raccourci
   set w $onglet.$child

   #--  toujous deux widgets en ligne avec un label en premier
   #--   definit le label en column 0
   label $onglet.lab_$child -text "$::caption(satellites,$child)" -justify left
   grid $onglet.lab_$child -row $row -column 0 -sticky w -padx 10 -pady 3

   if {$child in $private(entry)} {

      switch -exact $child {
         search   { set width 10 }
         default  { set width 30 }
      }

      ttk::entry $w -textvariable ::satellites::private($child) \
         -width $width -justify left
      grid $w -row $row -column 1 -sticky e -padx 10

      #--   configure la validation de la saisie
      bind $w <Leave> [list ::satellites::testPattern $child]

      #--   memorise la valeur
      set private(prev,$child) $private($child)

   } elseif {$child in $private(combobox)} {

      #--   largeur
      set width [::tkutil::lgEntryComboBox $private(liste$child)]
      if {$width > 10} {
         set width 27
      } else {
         set width 10
      }

      ttk::combobox $w -width $width -justify center -state readonly \
         -values $private(liste$child) -textvariable ::satellites::private($child)
      grid $w -row $row -column 1 -sticky e -padx 10
      if {$child eq "edition"} {
         #--   binding
         bind $w <<ComboboxSelected>> "::satellites::displayOptions $onglet"
      } elseif {$child eq "satname" } {
         bind $w <<ComboboxSelected>> "::satellites::getTleFile"
      }

   } elseif {$child in $private(checkbutton)} {

      ttk::checkbutton $w -variable ::satellites::private($child) \
         -onvalue "1" -offvalue "0"
      grid $w -row $row -column 1 -sticky e -padx 3

   }


   #--   memorise les widgets à inhiber/desinhiber
   lappend private(active) $w
}

#------------------------------------------------------------
#  brief inhibe/désinhibe tous les boutons, les entrées et les combobox
#  param state disabled ou !disabled
#
proc ::satellites::configWidget { state } {
   variable private

   foreach w $private(active) {
      catch {$w state $state}
   }
   update
}

#------------------------------------------------------------
#  brief   masque/demasque les options HTML selon le mode choisi
#  private
#
proc ::satellites::displayOptions { onglet } {
   variable private

   set index [lsearch -exact $private(listeedition) $private(edition)]
   switch -exact $index {
      0  {  #--   Console
            foreach child [list speed zoom grid sunmoon] {
               grid forget $onglet.lab_$child
               grid forget $onglet.$child
            }
         }
      1  {  #--   HTML
            set row 4
            foreach {child pad} [list speed 10 zoom 10 grid 3 sunmoon 3] {
               grid configure $onglet.lab_$child -row $row -column 0 -sticky w -padx 10 -pady 3
               grid configure $onglet.$child -row $row -column 1 -sticky e -padx $pad
               incr row
            }
         }
   }
   update
}

#------------------------------------------------------------
#  brief valide les saisies par test de pattern
#  param child nom de la variable modifiée
#
proc ::satellites::testPattern { child } {
   variable private

   if {$child ni [list tu gps satelra sateldec]} {return}

   set newValue $private($child)

   #--   controle le bon format
   set test 0
   switch -exact $child {
      tu        {  # teste une valeur de date iso 8601
                   set err_msg "[format $::caption(satellites,format)  $::caption(satellites,date)]"
                   set pattern {([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2})(|\.[0-9]+)?}
                   set test [regexp $pattern $newValue]
                }
      gps       {  # teste une valeur GPS
                   set err_msg "[format $::caption(satellites,format) GPS]"
                   lassign $newValue lab longitude sens latitude altitude
                   if {$lab eq "GPS" && $longitude <= 180.0 && $sens in [list E W] && ($latitude >= -90.0 && $latitude <= 90.0) && [regexp {^[-+]?([0-9]{1,4})} $altitude] == 1} {
                      set test 1
                   }
               }
      satelra  {   # teste une valeur hms
                   set err_msg "[format $::caption(satellites,format)  $::caption(satellites,ra)]"
                   set pattern {^([0-9]{1,2}h[0-9]{1,2}m[0-9]{1,2}s)([0-9]?)}
                   set test [regexp $pattern $newValue]
               }
      sateldec {   # teste une valeur dms
                   set err_msg "[format $::caption(satellites,format)  $::caption(satellites,dec)]"
                   set pattern {(^[-\+]{0,1}[0-9]{1,2}d[0-9]{1,2}m[0-9]{1,2}s[0-9]?)}
                   set test [regexp $pattern $newValue]
               }
   }

   if {$test == 1} {
      #--   memorise la nouvelle "ancienne valeur"
      set private(prev,$child) $newValue
   } else {
      tk_messageBox -message "$err_msg" -icon error -title "$::caption(satellites,erreur)"
      #--   retablit l'ancienne valeur
      set private($child) $private(prev,$child)
   }
}

#
## @file echip.tcl
#  @brief Interface graphique de la proc @ref electronic_chip du fichier @ref surchaud.tcl
#  @details définit les paramètres électroniques d'un capteur à partir de lots d'images
#  @namespace echip
#  @brief Interface graphique de la proc @ref electronic_chip du fichier @ref surchaud.tcl
#  @author Raymond Zachantke
#  $Id: echip.tcl 13979 2016-06-11 07:07:24Z rzachantke $
#

#============================================================
# Declaration du namespace echip
#    initialise le namespace
#============================================================

namespace eval ::echip {

   package provide echip 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] echip.cap ]

   #------------------------------------------------------------
   # brief      retourne le titre du plugin dans la langue de l'utilisateur
   # return     titre du plugin
   #
   proc getPluginTitle { } {
      global caption

      return "$caption(echip,title)"
   }

   #------------------------------------------------------------
   # brief      retourne le nom du fichier d'aide principal
   # return     nom du fichier d'aide principal
   #
   proc getPluginHelp { } {
      return "echip.htm"
   }

   #------------------------------------------------------------
   # brief      retourne le type de plugin
   # return     type de plugin
   #
   proc getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # brief      retourne le nom du répertoire du plugin
   # return     nom du répertoire du plugin : "echip"
   #
   proc getPluginDirectory { } {
      return "echip"
   }

   #------------------------------------------------------------
   ## @brief     retourne le ou les OS de fonctionnement du plugin
   #  @return    liste des OS : "Windows Linux Darwin"
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
         function     { return "analysis" }
         subfunction1 { return "echip" }
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
   proc createPluginInstance { base { visuNo 1 } } {
      variable This

      set This "$base.echip"

      #-- NB pas confToWidget ni de widgetToConf

      #--   J'ouvre la fenetre
      createWindow

      return $This
   }

   #------------------------------------------------------------
   ## @brief   suppprime l'instance du plugin
   #  @param   visuNo numéro de la visu
   #
   proc deletePluginInstance { { visuNo 1 } } {
      variable This

      if {[ winfo exists $This ] ==1} {
         cmdClose
      }
   }

   #------------------------------------------------------------
   #  brief   crée la fenêtre de l'outil
   #
   proc createWindow { } {
      variable This
      variable private
      global audace conf caption

      set this $This

      toplevel $this -class Toplevel
      wm title $this "$caption(echip,title)"
      wm geometry $this "+300+300"
      wm resizable $this 0 0
      wm protocol $this WM_DELETE_WINDOW "::echip::cmdClose"

      #--    cree trois frame (offset, dark, flat)
      pack [frame $this.fr] -side top
      set row 0
      foreach child [list offset dark flat] {
         label $this.fr.lab_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         ttk::entry $this.fr.$child -textvariable ::echip::private(${child}name) -justify left -width 15
         grid $this.fr.$child -row $row -column 1 -sticky w -padx 3 -pady 3
         ttk::button $this.fr.search$child -text "$caption(echip,search)" -width 4 \
            -command "::echip::getFileName $child"
         grid $this.fr.search$child -row $row -column 2 -padx 3 -pady 3
         label $this.fr.lab_nb$child -text "$caption(echip,nombre)" -justify left
         grid $this.fr.lab_nb$child -row $row -column 3 -sticky w -padx 3 -pady 3
         label $this.fr.nb$child -textvariable ::echip::private(${child}nb) -justify center -width 4
         grid $this.fr.nb$child -row $row -column 4 -sticky w -padx 3 -pady 3
         incr row
      }

      label $this.fr.lab_saturation -text "$caption(echip,saturation)" -justify left
      grid $this.fr.lab_saturation -row $row -column 0 -sticky w -padx 3 -pady 3
      ttk::entry $this.fr.saturation -textvariable ::echip::private(saturation) -justify center -width 8
      grid $this.fr.saturation -row $row -column 1 -sticky w -padx 3 -pady 3
      incr row
      checkbutton $this.fr.obt -text "$caption(echip,obt)" -variable ::echip::private(obt) \
         -offvalue 0 -onvalue 1
      grid $this.fr.obt -row $row -column 0 -padx 3 -pady 3 -sticky w
      incr row

      grid [ttk::separator $this.fr.sep1 -orient horizontal] \
         -row $row -column 0 -columnspan 5 -padx 3 -pady 5 -sticky ew
      incr row

      #--    cree les frame de resultats
      foreach child [list gain noise bias thermic_signal] {
         label $this.fr.lab_mean_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_mean_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         label $this.fr.mean_$child -textvariable ::echip::private(mean_$child) -justify center -width 8
         grid $this.fr.mean_$child -row $row -column 1 -sticky w -padx 3 -pady 3
         label $this.fr.lab_std_$child -text "$caption(echip,sigma)" -justify left
         grid $this.fr.lab_std_$child -row $row -column 2 -sticky w -padx 3 -pady 3
         label $this.fr.std_$child -textvariable ::echip::private(std_$child) -justify center -width 8
         grid $this.fr.std_$child -row $row -column 3 -sticky w -padx 3 -pady 3
         incr row
      }
      foreach child [list exp_critique exp_max dynamic] {
         label $this.fr.lab_$child -text "$caption(echip,$child)" -justify left
         grid $this.fr.lab_$child -row $row -column 0 -sticky w -padx 3 -pady 3
         label $this.fr.$child -textvariable ::echip::private($child) -justify center -width 8
         grid $this.fr.$child -row $row -column 1 -padx 3 -pady 3 -sticky w
         incr row
      }

      grid [ttk::separator $this.fr.sep2 -orient horizontal] \
         -row $row -column 0 -columnspan 5 -padx 3 -pady 5 -sticky ew

      #--   frame des boutons de commande
      pack [frame $this.cmd] -side bottom -fill x

      set listOfCmd [list \
         "::echip::cmdOk" \
         "::echip::cmdApply" \
         "::echip::cmdClose" \
         "::audace::showTutorials 1050tutoriel_electronic1.htm" \
         "::audace::showHelpPlugin tool echip echip.htm" \
      ]

      foreach {but side} [list ok left apply left close right hlpFunction right  hlpTool right] cmd $listOfCmd {
         ttk::button $this.cmd.$but -text "$caption(echip,$but)" -command $cmd \
            -width 10 -state !disabled
         pack $this.cmd.$but -side $side -padx 5 -pady 5 -ipady 5
         if {$but eq "ok" && $conf(ok+appliquer) eq 0} {
             pack forget $this.cmd.ok
         }
      }

      #--   initialise les variables
      lassign [list offset dark flat 0 ""] private(offsetname) private(darkname) \
         private(flatname) private(obt) private(saturation)

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   #  brief   commande des boutons '...'
   #
   #           ouvre un explorateur pour choisir une image opérande
   #  param   var (offset, dark, flat)
   #
   proc getFileName { var } {
      variable This
      variable private
      global conf

      #--   ouvre la fenetre de choix des images
      set file [::tkutil::box_load $This $::audace(rep_images) $::audace(bufNo) "1"]

      #--   arrete si pas de selection
      if {$file eq ""} {return}

      #--   verifie le repertoire et l'extension
      set dir [file dirname $file]
      set ext [file extension $file]
      if {$dir ne "$::audace(rep_images)" || $ext ne "$conf(extension,defaut)"} {
         return
      }

      #--   actualise les donnees
      lassign [::tkutil::afficherNomGenerique $file] private(${var}name) private(${var}nb) -> private(${var}indexes)

      #--   filtre les resultats
      if {$private(${var}nb) < 2} {
         lassign [list 0 ""] private(${var}nb) private(${var}name)
      }
   }

   #------------------------------------------------------------
   ## @brief   commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable private
      global audace

      if {![info exists private(offsetindexes)] || ![info exists private(darknb)] \
         || ![info exists private(flatindexes)] } {
         return
      }
      configButtons disabled

      #--   determine le gain et le bruit
      set cmd [list electronic_chip gainnoise]
      foreach k $private(offsetindexes) {
         lappend cmd $private(offsetname)$k
      }
      foreach k $private(flatindexes) {
         lappend cmd $private(flatname)$k
      }
      lassign [eval $cmd] mean_gain mean_noise std_gain std_noise

      #--   formate les resultats
      foreach var [list mean_gain std_gain mean_noise std_noise] {
         set private($var) [format %.2f [set $var]]
      }
      update

      #--   determine le bias et le bruit thermique
      set cmd [list electronic_chip lintherm]
      lappend cmd $private(darkname) $private(darknb) $mean_gain $mean_noise
      if {$private(saturation) ne ""} {
         lappend cmd $private(saturation)
      }
      lassign [eval $cmd] mean_thermic_signal mean_bias \
         std_thermic_signal std_bias exp_critique exp_max

      #--   formate les resultats
      foreach var [list std_thermic_signal mean_bias std_bias] {
         set private($var) [format %.2f [set $var]]
      }
      set private(mean_thermic_signal) [format %.4f $mean_thermic_signal]
      if {$exp_critique != ""} {
         set private(exp_critique) [format %.1f $exp_critique]
      }
      if {$exp_max != ""} {
         set private(exp_max) [format %.1f $exp_max]
      }
     if {$private(saturation) ne ""} {
         set private(dynamic) [expr { int(($private(saturation)-$mean_bias)*$mean_gain/(2*$mean_noise)) }]
      }
      update

      #--   cree une image de l'oburateur mecanique
      if {$private(obt) == 1} {
         electronic_chip shutter $private(flatname) $private(flatnb)
      }

      configButtons !disabled
   }

   #------------------------------------------------------------
   #  brief   commande du bouton "OK"
   #
   proc cmdOk { } {

      cmdApply
      cmdClose
   }

   #------------------------------------------------------------
   ## @brief   commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   # brief   inhibe/désinhibe tous les boutons
   # param   state (normal ou disabled)
   # @private
   #
   proc configButtons { state } {
      variable This

      foreach but  [list ok apply close hlpFunction hlpTool] {
         $This.cmd.$but state $state
      }
      update
   }

}


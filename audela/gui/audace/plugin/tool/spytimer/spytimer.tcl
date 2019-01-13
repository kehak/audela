
## @file spytimer.tcl
#  @brief Outil pour APN Canon non reconnu par libgphoto2
#  @author Raymond Zachantke
#  $Id: spytimer.tcl 13697 2016-04-14 09:02:16Z rzachantke $
#  @namespace spytimer
#  @brief Outil pour APN Canon non reconnu par libgphoto2
#

#============================================================
# Declaration du namespace spytimer
#    initialise le namespace
#============================================================

namespace eval ::spytimer {
   package provide spytimer 1.1

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]]  spytimer.cap ]

}

   #------------------------------------------------------------
   # brief   retourne le titre du plugin dans la langue de l'utilisateur
   # return  titre du plugin
   #
   proc ::spytimer::getPluginTitle { } {
      global caption

      return "$caption(spytimer,title)"
   }

   #------------------------------------------------------------
   # brief   retourne le nom du fichier d'aide principal
   # return  nom du fichier d'aide principal
   #
   proc ::spytimer::getPluginHelp { } {
      return "spytimer.htm"
   }

   #------------------------------------------------------------
   # brief   retourne le type de plugin
   # return  type de plugin
   #
   proc ::spytimer::getPluginType { } {
      return "tool"
   }

   #------------------------------------------------------------
   # brief   retourne le nom du répertoire du plugin
   # return  nom du répertoire du plugin : "spytimer"
   #
   proc ::spytimer::getPluginDirectory { } {
      return "spytimer"
   }

   #------------------------------------------------------------
   ## @brief  retourne le ou les OS de fonctionnement du plugin
   #  @return liste des OS : "Windows"
   #
   proc ::spytimer::getPluginOS { } {
      return [ list Windows ]
   }

   #------------------------------------------------------------
   ## @brief  retourne les propriétés de l'outil
   #
   #          cet outil s'ouvre dans un panneau
   #  @param  propertyName nom de la propriété
   #  @return valeur de la propriété ou "" si la propriété n'existe pas
   #
   proc ::spytimer::getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "acquisition" }
         subfunction  { return "dslr" }
         display      { return "panel" }
         multivisu    { return 1 }
         default      { return "" }
      }
   }

   #------------------------------------------------------------
   ## @brief  créé une nouvelle instance de l'outil
   #  @param  base   base tk
   #  @param  visuNo numéro de la visu
   #  @return chemin de la fenêtre
   #
   proc ::spytimer::createPluginInstance { base { visuNo 1 } } {
      variable This

      package require BLT

      source [ file join $::audace(rep_plugin) tool spytimer spytimerfoc.tcl ]

      #--- Inititalisation du nom de la fenetre
      set This $base.spytimer

      #--- Prepare les variables locales de l'interface graphique
      ::spytimer::createPanel $visuNo

      ::spytimer::spytimerBuildIF $visuNo

      #--   Lance Collector
      if {[::confVisu::getToolVisuNo ::collector] eq ""} {
         ::confVisu::selectTool $visuNo "::collector"
      }

      return $This
   }

   #------------------------------------------------------------
   ## @brief  suppprime l'instance du plugin
   #  @param  visuNo numéro de la visu
   #
   proc ::spytimer::deletePluginInstance { { visuNo 1 } } {
      variable This

      if {[winfo exists $This] ==1} {
         cmdClose $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief   initialise les variables de configuration
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(spytimer,visu$visuNo,keywordConfigName) définit la sélection de la configuration des mots clés
   #
   #  @param visuNo numéro de visu
   #
   proc ::spytimer::initConf { {visuNo 1 } } {
      global conf

      if { ![ info exists conf(spytimer,visu$visuNo,keywordConfigName) ] } { set conf(spytimer,visu$visuNo,keywordConfigName) "default" }
   }

   #------------------------------------------------------------
   #  brief   prépare les variables de configuration dans des variables locales
   #  param   visuNo numéro de la visu
   #
   proc ::spytimer::createPanel { { visuNo 1 } } {
      variable private
      global audace conf

      ::spytimer::initConf $visuNo

      set configName $conf(spytimer,visu$visuNo,keywordConfigName)

      set private(fichier_ini) [ file join $audace(rep_home) spytimer$visuNo.ini ]

      #--   obtient la liste des variables checkees
      set checked $conf(keyword,$configName,check)
      regsub -all "1,check," $checked " " checked

      #--   valide les mots cles checkes
      foreach kwd [ list aptdia crota2 foclen pixsize1 pixsize2 xpixsz ypixsz ] {
         if { [ string toupper $kwd ] in $checked } {
            set private($visuNo,opt_$kwd) 1
         } else {
            set private($visuNo,opt_$kwd) 0
         }
      }

      #--   initialise les autres variables
      set default_values [ list port "" bit "" cde "" xpixsz "" \
         ypixsz "" pixsize1 "" pixsize2 "" crota2 "" foclen "" aptdia "" ]

      if { [ file exists $private(fichier_ini) ] } {
         source $private(fichier_ini)
      }

      foreach { param value } $default_values {
         if { [ info exists parametres($param) ] }  {
            #--   affecte les valeurs initiales sauvegardees dans le fichier ini
            set private($visuNo,$param) $parametres($param)

            if { $param eq "aptdia" && $value ne ""} {
               #--   calcule le pouvoir separateur
               set private($visuNo,pouvoir_separateur) [format %.3f [expr {0.120/$private($visuNo,aptdia)}]]
            }

         } elseif { [ info exists parametres($param) ] == 0 && $param ni [ list port bit cde ] } {
            #--   sinon prend la valeur par defaut pour les autres variables
            set private($visuNo,$param) $value
         }
      }

      set private($visuNo,portLabels) [ ::confLink::getLinkLabels { "parallelport" "quickremote" "serialport" "external" } ]
      if { ![ info exists private($visuNo,port) ] } {
         set private($visuNo,port) [lindex $private($visuNo,portLabels) 0]
      }

      #--   arrete si aucun port
      if { $private($visuNo,portLabels) eq "" } {
         ::spytimer::stopTool
         ::spytimer::deletePluginInstance
      }

      set private($visuNo,bitLabels) [ ::confLink::getPluginProperty $private($visuNo,port) bitList ]
      if { ![ info exists private($visuNo,bit) ] } {
         set private($visuNo,bit) [ lindex $private($visuNo,bitLabels) 0 ]
      }

      set private($visuNo,cdeLabels) { 0 1 }
      if { ![ info exists private($visuNo,cde) ] } {
         set private($visuNo,cde) [ lindex $private($visuNo,cdeLabels) 1 ]
      }

      set private($visuNo,intervalle) 1
   }

   #---------------------------------------------------------------------------
   #  brief créé la fenêtre de l'outil
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::spytimerBuildIF { { visuNo 1 } } {
      variable This
      variable private
      global caption color

      frame $This -borderwidth 2 -relief groove

      #--- Frame du bouton d'aide
      frame $This.fra1 -borderwidth 2 -relief groove
         button $This.fra1.but -borderwidth 1 \
            -text "$caption(spytimer,help_titre1)\n$caption(spytimer,title)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::spytimer::getPluginType ] ] \
               [ ::spytimer::getPluginDirectory ] [ ::spytimer::getPluginHelp ]"
         pack $This.fra1.but -in $This.fra1 -anchor center -expand 1 -fill both -side top -ipadx 2
         DynamicHelp::add $This.fra1.but -text $caption(spytimer,help_titre)
      pack $This.fra1 -side top -fill x

      #-- frame de la configuration
      frame $This.fra2 -borderwidth 2 -relief groove
         button $This.fra2.but -borderwidth 2 -text $caption(spytimer,configuration) \
            -command "::spytimer::configParameters $visuNo"
         pack $This.fra2.but -side top -fill x -ipadx 2 -ipady 5
      pack $This.fra2 -side top -fill x

      #-- frame de la surveillance
      frame $This.fra3 -borderwidth 2 -relief groove
         checkbutton $This.fra3.opt -text "$caption(spytimer,survey)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private($visuNo,survey) \
            -command "::spytimer::initSurvey $visuNo"
         checkbutton $This.fra3.convert -text "$caption(spytimer,convert)" \
            -indicatoron 1 -onvalue 1 -offvalue 0 \
            -variable ::spytimer::private($visuNo,convert)
         pack $This.fra3.opt $This.fra3.convert -anchor w -pady 2
     pack $This.fra3 -side top -fill x

     #--   le frame des commandes du timer-intervallometre et le bouton GO
     set this [frame $This.fra4 -borderwidth 2 -relief groove]
     set private($visuNo,this) $this
     pack $this -side top -fill x

         label $this.mode_lab -text $caption(spytimer,mode)
         set private($visuNo,modeLabels) [ list "$caption(spytimer,mode,one)" "$caption(spytimer,mode,serie)" ]
         set private($visuNo,mode) [ lindex $private($visuNo,modeLabels) 0 ]
         ComboBox $this.mode -borderwidth 1 -width 5 \
            -height [ llength $private($visuNo,modeLabels) ] \
            -relief sunken -justify center \
            -textvariable ::spytimer::private($visuNo,mode) \
            -values "$private($visuNo,modeLabels)" \
            -modifycmd "::spytimer::configPanel $visuNo"

         #--   construit les entrees de donnees
         foreach child { nb_poses activtime delai periode } {
            LabelEntry $this.$child -label $caption(spytimer,$child) \
               -textvariable ::spytimer::private($visuNo,$child) -labelanchor w -labelwidth 8 \
               -borderwidth 1 -relief flat -padx 2 -justify right \
               -width 5 -relief sunken
            bind $this.$child <Leave> [ list ::spytimer::test $visuNo $this $child ]
         }

         #--   label pour afficher les etapes
         label $this.state -textvariable ::spytimer::private($visuNo,action) \
            -width 14 -borderwidth 2 -relief sunken

         #-- checkbutton pour la longuepose
         checkbutton $this.lp -text $caption(spytimer,lp) \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::spytimer::private($visuNo,lp) -command "::spytimer::configTime $visuNo"

         #--   configure le bouton de lancement d'acquisition
         button $this.but1 -borderwidth 2 -text "$caption(spytimer,go)" \
            -command "::spytimer::cmdApply $visuNo"

         checkbutton $this.auto -text "$caption(spytimer,auto)" \
            -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::spytimer::private($visuNo,auto) \
            -command "::spytimer::confTimeListener $::audace(visuNo)"

         frame $this.timer -borderwidth 2
         for {set i 1} {$i < 24} {incr i} {
            lappend lhr [format "%02.f" $i]
         }
         lappend lhr [format "%02.f" 0] $lhr
         tk::spinbox $this.timer.hr \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lhr -wrap 1 \
            -textvariable ::spytimer::private($visuNo,hr)

         label $this.timer.lab_hr -text "$caption(spytimer,hr)"

         for {set i 1} {$i < 60} {incr i} {
            lappend lmin [format "%02.f" $i]
         }
         lappend lmin [format "%02.f" 0] $lmin
         tk::spinbox $this.timer.min \
            -width 2 -relief sunken -borderwidth 1 \
            -state readonly -values $lmin -wrap 1 \
            -textvariable ::spytimer::private($visuNo,min)

         label $this.timer.lab_min -text "$caption(spytimer,min)"
         pack $this.timer.hr $this.timer.lab_hr $this.timer.min $this.timer.lab_min -side left

         ::blt::table $this \
            $this.mode_lab 0,0 \
            $this.mode 0,1 \
            $this.state 1,0 -cspan 2 \
            $this.nb_poses 2,0 -cspan 2 \
            $this.lp 3,0 -cspan 2 \
            $this.activtime 4,0 -cspan 2 \
            $this.delai 5,0 -cspan 2 \
            $this.periode 6,0 -cspan 2 \
            $this.but1 7,0 -cspan 2 -ipady 3 -fill x \
            $this.auto 8,0 -cspan 2 \
            $this.timer 9,0 -cspan 2
            blt::table configure $this r* -pady 2
         pack $this -side top -fill x

      #--   ajoute les aides
      foreach child { nb_poses activtime delai periode } {
         DynamicHelp::add $this.$child -text $caption(spytimer,help$child)
      }

      lassign { "1" "1" " " "0" "1" " " "0" "" "0" "0" } private($visuNo,intervalle) \
         private($visuNo,lp) private($visuNo,activtime) private($visuNo,delai) \
         private($visuNo,periode) private($visuNo,action) private($visuNo,serieNo) \
         private($visuNo,msgbox) private($visuNo,hr) private($visuNo,min)

      $this.lp invoke
      ::spytimer::configPanel $visuNo

      #--- Mise ajour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   ##  @brief commande du bouton "Go"
   #
   #   gère les prises de vue à partir des réglages utilisateur
   #   @param visuNo numéro de la visu
   #
   proc ::spytimer::cmdApply { visuNo } {
      variable private
      global caption

      foreach var [ list nb_poses periode activtime delai ] {
         ::spytimer::test $visuNo $private($visuNo,this) $var
      }

      #--   gele les commandes
      ::spytimer::setWindowState $visuNo disabled

      #--   affiche 'Attente'
      set private($visuNo,action) $caption(spytimer,action,wait)

      #--   memorise les valeurs initiales
      set private($visuNo,settings) [ list $private($visuNo,nb_poses) \
         $private($visuNo,periode) $private($visuNo,activtime) ]

      #--   raccourcis
      lassign $private($visuNo,settings) nb_poses periode activtime

      #--   cherche l'index de Une Image/Une série
      set mode [ lsearch $private($visuNo,modeLabels) $private($visuNo,mode) ]

      #---  si la pose est differee, affichage du temps restant
      if { $private($visuNo,delai) != 0 } {
         delay $visuNo delai
      }

      #--   compteur de shoot
      incr private($visuNo,serieNo) "1"

      #--   cree une liaison avec le port
      set linkNo [ ::confLink::create "$private($visuNo,port)" "camera inconnue" "pose" "" ]

      #--   compte les declenchements
      set count 1

      while { $private($visuNo,nb_poses) > 0 } {

         #--   prepare le message de log
         set private($visuNo,msg) [ format $caption(spytimer,prisedevue) $private($visuNo,serieNo) $count ]
         if { $activtime != " " } {
            append private($visuNo,msg) "  $activtime sec."
         }

         #--   affiche 'Acquisition'
         set private($visuNo,action) "$caption(spytimer,action,acq)"

         #--   declenche ; t = temps au debut du shoot en secondes,millisecondes
         set time_start [ shoot $visuNo $linkNo "$activtime" ]

         #--   decremente et affiche le nombre de poses qui reste a prendre
         incr private($visuNo,nb_poses) "-1"

         #--   recharge la duree
         set private($visuNo,activtime) $activtime

         #--   si c'est Une serie
         if { $mode == "1" } {
            if { $count == "1" } {
               set time_first $time_start
            }
            #--   si ce n'etait pas la derniere image
            if { $count < $nb_poses } {
               set private($visuNo,periode) [ expr { $time_first + $periode*$count - [ clock seconds ] } ]
               delay $visuNo periode
            }
         }

         #--   incremente le nombre de shoot
         incr count
      }

      #--- ferme la liaison
      ::confLink::delete "$private($visuNo,port)" "camera inconnue" "pose"

      #--   degele les commandes
      ::spytimer::setWindowState $visuNo normal

      #--   retablit les valeurs initiales
      lassign $private($visuNo,settings) private($visuNo,nb_poses) \
         private($visuNo,periode) private($visuNo,activtime)

      set private($visuNo,action) " "
   }

   #------------------------------------------------------------
   ## @brief  sauvegarde dans un fichier ini et ferme la fenêtre
   #  @param  visuNo numéro de la visu
   #
   proc ::spytimer::cmdClose { { visuNo 1 } } {
      variable This
      variable private

      #--   sauvegarde les parametres ans le fichier ini
      if [ catch { open $private(fichier_ini) w } fichier ] {
          Message console "%s\n" $fichier
      } else {

         #--   liste le nom des variables
         set variable_list [ list port bit cde xpixsz ypixsz pixsize1 pixsize2 crota2 foclen aptdia ]

         #--   liste leur valeur
         foreach var $variable_list {
            lappend value_list $private($visuNo,$var)
         }

         #--   sauve le nom et la valeur
         foreach var $variable_list val $value_list {
            puts $fichier "set parametres($var) \"$val\""
         }
         close $fichier
      }

      #--   desactive le timeListener
      if { [ trace info variable ::audace(hl,format,hm)]  ne "" } {
         trace remove variable ":::audace(hl,format,hm)" write "::spytimer::autoShoot $visuNo"
      }

      destroy $This
   }

   #---------------------------------------------------------------------------
   #  brief        déclenche un shoot
   #  param visuNo numéro de la visu
   #  param linkNo N° du lien
   #  param t      durée en secondes
   #
   proc ::spytimer::shoot { visuNo linkNo t } {
      variable private

      #--   definit les variables locales
      set start $private($visuNo,cde)
      set stop  [ expr { 1-$start } ]

      ::spytimer::majLog $visuNo

      #--   intercepte l'erreur sur le test
      #  et sur l'absence de liaison serie
      if { [ catch {
         #--- demarre une pose
         link$linkNo bit $private($visuNo,bit) $start
      } ErrInfo ] } {
         return
      }
      set time_start [ clock seconds ]

      if { $t != " " } {
         #--   decremente le compteur de largeur d'impulsion
         delay $visuNo activtime
      } else {
         #--   la duree minimale de l'impulsion est fixee a 500 msec
         after 500
      }

      #--- arrete la pose
      link$linkNo bit $private($visuNo,bit) $stop

      return $time_start
   }

   #---------------------------------------------------------------------------
   #  brief gère l'état des widgets
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::setWindowState { visuNo state } {
      variable private

      if { $state eq "disabled" } {
         foreach child [ list mode lp nb_poses activtime delai periode but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
      } else {
         foreach child [ list mode lp delai but1 ] {
            $private($visuNo,this).$child configure -state "$state"
         }
         ::spytimer::configPanel $visuNo
         #configTime $visuNo
      }
   }

   #---------------------------------------------------------------------------
   #  brief configure le panneau en fonction du mode appelé par le bouton de mode et par setWindowState
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::configPanel { visuNo } {
      variable private

      set indice [ lsearch $private($visuNo,modeLabels) $private($visuNo,mode) ]
      switch $indice {
         "0"   {  lassign { "1" " " } private($visuNo,nb_poses) private($visuNo,periode)
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state disabled
                  }
               }
         "1"   {  lassign [ list "2" "1" " " ] private($visuNo,nb_poses) \
                     private($visuNo,periode) private($visuNo,action)
                  foreach child { nb_poses periode } {
                     $private($visuNo,this).$child configure -state normal
                  }
               }
      }
      ::spytimer::configTime $visuNo
   }

   #---------------------------------------------------------------------------
   #  brief configure la saisie du temps appelée par le checkbutton
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::configTime { visuNo } {
      variable private

      set time $private($visuNo,activtime)
      if { $private($visuNo,lp) == "1" } {
         if { $time == " " } {
            set data [ list "normal" "1" ]
         } else {
            set data [ list "normal" "$time" ]
         }
      } else {
         set data [ list "disabled" " " ]
      }
      lassign $data state private($visuNo,activtime)
      $private($visuNo,this).activtime configure -state $state
   }

   #---------------------------------------------------------------------------
   #  brief teste si les valeurs entrées dans les fenêtres actives sont des entiers ;
   #  teste si la période > durée
   #  param visuNo numéro de la visu
   #  param w      chemin de la fenêtre
   #  param child  nom de la variable
   #
   proc ::spytimer::test { visuNo w child } {
      variable private

      #--   arrete si l'entree est disabled
      if { [ $w.$child cget -state ] == "disabled" } {
         return
      }

      #--   teste les valeurs entieres
      if { ![ TestEntier $private($visuNo,$child) ] } {
         ::spytimer::avertiUser $visuNo $child
         if { $child in [ list nb_poses activtime periode interval ] } {
            set private($visuNo,$child) "1"
         } elseif { $child == "delai" } {
            set private($visuNo,$child) "0"
         }
      }

      #--   compare la periode a la duree
      if { $child == "periode" && [ $w.activtime cget -state ] eq "normal" } {
         if { $private($visuNo,periode) <= $private($visuNo,activtime) } {
            ::spytimer::avertiUser $visuNo "periode"
            set private($visuNo,periode) [ expr { $private($visuNo,activtime)+1 } ]
         }
      }
      update
   }

   #---------------------------------------------------------------------------
   #  brief affiche une fenêtre d'avertissement
   #  param visuNo numéro de la visu
   #  param nom    variable de caption
   #
   proc ::spytimer::avertiUser { visuNo nom } {
      variable private
      global caption

      #--   pour eviter les ouvertures multiples
      if { $private($visuNo,msgbox) != "$nom" } {

         #--   memorise l'affichage de l'erreur
         set private($visuNo,msgbox) $nom

         tk_messageBox -title $caption(spytimer,attention)\
            -icon error -type ok -message $caption(spytimer,help$nom)

         #--   au retour annule la memoire
         set private($visuNo,msgbox) ""
      }
   }

   #---------------------------------------------------------------------------
   #  brief décompteur de secondes
   #  param visuNo numéro de la visu
   #  param var    nom de la variable à d&compter (délai ou période)
   #
   proc ::spytimer::delay { visuNo var } {

      upvar private($visuNo,$var) t
      while { $t > "0" } {
         after 1000
         incr t "-1"
         update
      }
      set t "0"
      update
   }

   #---------------------------------------------------------------------------
   #  brief met à jour le fichier log
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::majLog { visuNo } {
      variable private

      set file_log [ file join $::audace(rep_log) spytimer.log ]

      if {[info exists private(logmonitor)] ==0 || $private(logmonitor) ==1} {
         set private(logmonitor) [::logmonitor::run $file_log]
      }

      set msg "$::audace(tu,format,dmyhmsint) $private($visuNo,msg)"

      if { ![ catch { open $file_log a } fichier ] } {
         chan puts $fichier $msg
         chan close $fichier
      }
   }

   #------------------------------- fenetre de configuration ------------------

   #---------------------------------------------------------------------------
   #  brief créé la fenêtre de configuration $This.config
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::configParameters { visuNo } {
      variable This
      variable private
      global audace caption color

      set this $This.config
      if { [ winfo exists $this ] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }

      toplevel $this
      wm title $this "$caption(spytimer,titre)"
      wm geometry $this "+150+80"
      wm resizable $this 0 0
      wm protocol $this WM_DELETE_WINDOW ""

      set bordure "10"
      set result_width "12"

      #--   construction des combobox pour la com
      frame $this.com -borderwidth 2 -relief groove
         set l 0
         foreach child { port bit cde } {
            set len [ llength $private($visuNo,${child}Labels) ]
            label $this.com.${child}_lab -text $caption(spytimer,$child)
            grid $this.com.${child}_lab -row $l -column 0 -padx 10 -sticky w
            ComboBox $this.com.$child -borderwidth 1 -width 5 -height $len \
               -relief sunken -justify center \
               -textvariable ::spytimer::private($visuNo,$child) \
               -values "$private($visuNo,${child}Labels)"
            grid $this.com.$child -row $l -column 1 -sticky e
            incr l
         }
         grid columnconfigure $this.com {0} -minsize 100
         $this.com.port configure -modifycmd "::spytimer::configBit $visuNo" -width 9
         DynamicHelp::add $this.com.cde -text $caption(spytimer,helpcde)
      pack $this.com -anchor w -side top -fill x -expand 1

      frame $this.survey -borderwidth 2 -relief groove
         LabelEntry $this.survey.intervalle -labelanchor w \
            -label $caption(spytimer,intervalle) \
            -labelwidth [string length  $caption(spytimer,intervalle)] \
            -textvariable ::spytimer::private($visuNo,intervalle) \
            -borderwidth 1 -relief flat -justify right -width 5 -relief sunken
         pack $this.survey.intervalle -anchor w -padx 10
         bind $this.survey.intervalle <Leave> [ list ::spytimer::test $visuNo $this.survey intervalle ]
      pack $this.survey -anchor w -side top -fill x -expand 1

      frame $this.cmd -borderwidth 2 -relief groove
         set len [string length $caption(spytimer,focalisation)]
         button $this.cmd.foc -borderwidth 2 -text $caption(spytimer,focalisation) \
            -command "::spytimer::focGraphe $visuNo" -width $len
         pack $this.cmd.foc -anchor w -side left -padx 10
      pack $this.cmd -anchor w -side top -fill x -expand 1
   }

   #---------------------------------------------------------------------------
   #  brief configure l'entree de .bit en fonction du port
   #  param visuNo    numéro de la visu
   #
   proc ::spytimer::configBit { visuNo } {
      variable This
      variable private

      set w $This.config.com.bit
      set len [ llength $private($visuNo,bitLabels) ]
      $w configure -values "$private($visuNo,bitLabels)" -height $len
      $w setvalue @0
   }

   #----------------- fonction de surveillance du repertoire ------------------

   #---------------------------------------------------------------------------
   ## @brief initialise la surveillance du répertoire sélectionné
   #  @param visuNo numéro de la visu
   #
   proc ::spytimer::initSurvey { visuNo } {
      variable private

      if { $private($visuNo,survey) == 1 } {
         #--   fait et memorise la liste initiale des fichiers presents
         set private($visuNo,oldList) [ ::spytimer::listeFiles visuNo ]
         #--  lance la surveillance
         ::spytimer::surveyDirectory $visuNo
      } else {
         catch { after cancel $private(afterId) }
      }
   }

   #---------------------------------------------------------------------------
   #  brief détecte et charge une nouvelle image
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::surveyDirectory { visuNo } {
      variable This
      variable private
      global audace conf

      #--   arrete si la fenetre a ete fermee
      if { [ catch { set bufNo [ ::confVisu::getBufNo $visuNo ] } ErrInfo ] } {
         return
      }

      #--   fait la liste des fichiers presents
      ::spytimer::listeFiles $visuNo

      #--   oublie la liste des anciennes images
      regsub -all "$private($visuNo,oldList)" $private($visuNo,listFiles) "" newFile

      #--  en cas de plusieurs fichiers, retient le dernier
      set newFile [ lindex $newFile end ]

      if { $newFile ne "" } {

         set ext [ file extension $newFile ]
         set name [ file rootname $newFile ]
         set fileName [ file join $::audace(rep_images) $name$ext ]
         set time [ file atime $fileName ]
         set minuscules [ string tolower $conf(extension,defaut) ]
         set majuscules [ string toupper $conf(extension,defaut) ]

         #-- change la casse de l'extension FITS s'il y a discordance
         if {$ext in [list $minuscules $majuscules]} {
            if {[string match $conf(extension,defaut) $ext] == 0} {
               set fileName $name$conf(extension,defaut)
               file rename -force $name$ext $fileName
               set ext $conf(extension,defaut)
            }
         }

         #--   charge l'image
         loadima $fileName $visuNo

         #--- cree DATE-OBS pour les images jpeg et les FITS sans date
         if { [ lindex [ buf$bufNo getkwd "DATE-OBS" ] 1 ] eq ""}  {
            set time [ clock format $time -format "%Y-%m-%dT%H:%M:%Ss" -timezone :UTC ]
            buf$bufNo setkwd [ list DATE-OBS $time string "Start of exposure. FITS standard" "iso8601" ]
         }

         if { $private($visuNo,convert) == 1 } {
            #--- ajoute des mots cles
            ::collector::setKeywords $bufNo
            #--   sauve l'image avec l'extension par defaut
            set fileName [ file join $::audace(rep_images) $name$::conf(extension,defaut) ]
            buf$bufNo save $fileName
            loadima $fileName $visuNo
            #file delete [file join $::audace(rep_images) $newFile]
         }

         #--   rafraichit le graphique de derive
         if { [ winfo exists $This.qmes ] && [ file extension $fileName ] eq "$conf(extension,defaut)" } {
            set precedent [lindex $private($visuNo,listFiles) end-1]
            set img1 [ file rootname $precedent ]
            if { $img1 ne "" } {
               ::spytimer::verifData $visuNo [ list $img1 [ file rootname [ file tail $fileName ] ] ]
            }
         }

         #--   rafraichit le graphique de focalisation
         if { [ winfo exists $This.parafoc ] } {
            ::spytimer::refreshFocGraph $visuNo
         }
      }

      #--   memorise la nouvelle liste
      set private($visuNo,oldList) $private($visuNo,formatList)

      set intervalle [ expr { $private($visuNo,intervalle) * 1000 } ]
      set private(afterId) [ after $intervalle ::spytimer::surveyDirectory $visuNo ]
   }

   #---------------------------------------------------------------------------
   #  brief liste les nom courts des fichiers images d'extensions CR2 CRW JPG FIT FITS
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::listeFiles { visuNo } {
      variable private
      global audace

     set dir $audace(rep_images)

      set raw ""
      #--- sous Windows, la recherche de l'extension est insensible à la casse
      foreach extension [list CR2 CRW JPG FIT FITS] {
         set raw [ concat $raw [ glob -nocomplain -type f -join $dir *.$extension ] ]
      }

      lassign [ list "" "" ] private($visuNo,listFiles) private($visuNo,formatList)

      if { $raw ne "" } {
         set formatList "("
         foreach file [ lsort -dictionary  $raw ] {
            set short_name [ file tail $file ]
            lappend private($visuNo,listFiles) $short_name
            append formatList $short_name |
         }
         set private($visuNo,formatList) [ string trimright $formatList "|" ]
         append private($visuNo,formatList) ")"
      }

      return $private($visuNo,formatList)
   }

   #-----------------------fonction de lancement auto -------------------------

   #---------------------------------------------------------------------------
   #  brief met en place/arrête le listener de minuteur, commande du bouton de programmation de shoot 'Auto'
   #  param visuNo numéro de la visu
   #
   proc ::spytimer::confTimeListener { visuNo } {
      variable private

      if { $private($visuNo,auto) == "1" } {
         ::confVisu::addTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      } else {
         ::confVisu::removeTimeListener $visuNo "::spytimer::autoShoot $visuNo"
      }
   }

   #---------------------------------------------------------------------------
   #  brief lance le programme périodique
   #  param visuNo numéro de la visu
   #  param args   argument de trace
   #
   proc ::spytimer::autoShoot { visuNo args } {
      variable private

      set progr "$private($visuNo,hr) $private($visuNo,min)"

      if { $::audace(hl,format,hm) != "" && $::audace(hl,format,hm) eq "$progr" } {
         ::spytimer::cmdApply $visuNo
      }
   }


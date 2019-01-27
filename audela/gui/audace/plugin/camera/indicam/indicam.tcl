#
# Fichier : indicam.tcl
# Description : Configuration des caméras INDI
# Auteur : Damien BOUREILLE
# Mise à jour $Id: indicam.tcl 13153 2016-02-13 10:39:57Z robertdelmas $
#

namespace eval ::indicam {
   package provide indicam 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] indicam.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::indicam::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libindicam.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::indicam::getPluginType]] "indicam" "libindicam.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(indicam,installNewVersion) $sourceFileName [package version indicam] ]
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::indicam::getPluginTitle { } {
   global caption

   return "$caption(indicam,camera)"
}

#
# getPluginHelp
#    Retourne la documentation du plugin
#
proc ::indicam::getPluginHelp { } {
   return "indicam.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::indicam::getPluginType { } {
   return "camera"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::indicam::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#
proc ::indicam::getPluginDirectory { } {
   return "indicam"
}

#
# getCamNo
#    Retourne le numero de la camera
#
proc ::indicam::getCamNo { camItem } {
   variable private

   return $private($camItem,camNo)
}

#
# isReady
#    Indique que la camera est prete
#    Retourne "1" si la camera est prete, sinon retourne "0"
#
proc ::indicam::isReady { camItem } {
   variable private

   if { $private($camItem,camNo) == "0" } {
      #--- Camera KO
      return 0
   } else {
      #--- Camera OK
      return 1
   }
}

proc ::indicam::getCams { indiSocket } {

	set indiOutput ""
	set timeout 0
	flush stdout
	flush $indiSocket
	
	puts $indiSocket "<getProperties version=\"1.7\"/>"
	
	# Because INDI won't close the socket after the request
	# we need to close it manually after a scheduled timeout			
	while { $timeout < 250000 } {
		catch { gets $indiSocket output }
		if { $output != "" } { append indiOutput $output\n }
		incr timeout
	}
	
	close $indiSocket 

	# Since the regexp engine only outputs the last matched occurence,
	# we need to parse the list line by line
	set camOutput [split $indiOutput "\n"]
	
	set cams ""
	set cam ""
	
	foreach line $camOutput {
		regexp {.*device\=\"(.*CCD.*)\" name\=\"CONNECTION\".*} $line match cam
		if { $cam ne "" } { lappend cams $cam }
	}
			
	if { [ lindex $cams 0 ] ne "" } { return [ lsort -unique $cams ]
	} else { return "" }
}

proc ::indicam::checkConnection { } {
	
	global caption conf
	variable private
	variable widget
	
	catch { set sock [ socket $::indicam::widget(host) $::indicam::widget(port) ] }
	set readable [ catch { fconfigure $sock -peername } msg]
	if { ! $readable } {
		fconfigure $sock -blocking 0 -buffering line
		# Connect and retrieve the INDI camera list
		::console::affiche_resultat "INDI: connected to $::indicam::widget(host) $::indicam::widget(port)\n"
		set conf(indicam,camlist) [ ::indicam::getCams $sock ]
		} else { set conf(indicam,camlist) ""
	}
	
	if { $conf(indicam,camlist) ne "" } { ::console::affiche_resultat "INDI: found [ llength $conf(indicam,camlist) ] cameras\n"
	} else { ::console::affiche_erreur "Could not find any camera. Is this the right INDI host?\n" }
	
	set widget(device) [ lindex $conf(indicam,camlist) 0 ]
		
	# Update INDI conf with our new settings
	set camItem [ ::confCam::getCurrentCamItem ]
	::indicam::widgetToConf $camItem
		
	# Refresh the combo list
	if { [ info exists private(frm) ] } {
		set frm $private(frm)
				::indicam::fillConfigPage $frm $camItem
	}
		
	return 0
}

#
# initPlugin
#    Initialise les variables conf(indicam,...)
#
proc ::indicam::initPlugin { } {
   variable private
   global conf caption

   #--- Initialise les variables de la camera indicam
   if { ! [ info exists conf(indicam,cool) ] }              { set conf(indicam,cool)              "0" }
   if { ! [ info exists conf(indicam,host) ] }              { set conf(indicam,host)              "localhost" }
   if { ! [ info exists conf(indicam,mirh) ] }              { set conf(indicam,mirh)              "0" }
   if { ! [ info exists conf(indicam,mirv) ] }              { set conf(indicam,mirv)              "0" }
   if { ! [ info exists conf(indicam,port) ] }              { set conf(indicam,port)              "7624" }
   if { ! [ info exists conf(indicam,temp) ] }              { set conf(indicam,temp)              "0" }
   if { ! [ info exists conf(indicam,device) ] }            { set conf(indicam,device)            "" }

   #--- Initialisation
   set private(A,camNo) "0"
   set private(B,camNo) "0"
   set private(C,camNo) "0"
   set private(ccdTemp) "$caption(indicam,temp_ext)"
   
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::indicam::confToWidget { } {
   variable widget
   global caption conf
   set widget(cool)              $conf(indicam,cool)
   set widget(host)              $conf(indicam,host)
   set widget(mirh)              $conf(indicam,mirh)
   set widget(mirv)              $conf(indicam,mirv)
   set widget(port)              $conf(indicam,port)
   set widget(temp)              $conf(indicam,temp)
   set widget(device)            $conf(indicam,device)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::indicam::widgetToConf { camItem } {
   variable widget
   global caption conf

   #--- Memorise la configuration de la camera indicam dans le tableau conf(indicam,...)
 
   set conf(indicam,cool)              $widget(cool)
   set conf(indicam,host)              $widget(host)
   set conf(indicam,mirh)              $widget(mirh)
   set conf(indicam,mirv)              $widget(mirv)
   set conf(indicam,port)              $widget(port)
   set conf(indicam,temp)              $widget(temp)
   set conf(indicam,device)            $widget(device)
}

#
# fillConfigPage
#    Interface de configuration de la camera indicam
#
proc ::indicam::fillConfigPage { frm camItem } {

	variable private
	variable widget
	global caption conf

	#--- Initialise une variable locale
	set private(frm) $frm

	#--- confToWidget
	::indicam::confToWidget

	#--- Supprime tous les widgets de l'onglet
	foreach i [ winfo children $frm ] {
	  destroy $i
	}

	set list_combobox ""
	# Retrieve the camera list
	foreach cam $conf(indicam,camlist) {
		if { $cam ne "" } { lappend list_combobox $cam }
	}
	
   #--- Frame de la configuration de l'IP et port
   frame $frm.frame1 -borderwidth 1 -relief raised
	
	 # IP
     frame $frm.frame1.ip -borderwidth 0 -relief raised
     
            label $frm.frame1.ip.label -text "$caption(indicam,host)"
            pack  $frm.frame1.ip.label -side left -padx 10

            entry $frm.frame1.ip.entry -width 18 -textvariable ::indicam::widget(host)
            pack  $frm.frame1.ip.entry -side left -padx 10

      pack $frm.frame1.ip -anchor center -side left -padx 10 -fill both -expand 1
     
      # Port 
      frame $frm.frame1.port -borderwidth 0 -relief flat

            label $frm.frame1.port.label -text "$caption(indicam,port)" \
               -highlightthickness 0 
            pack  $frm.frame1.port.label -anchor center -side left -padx 10

            entry $frm.frame1.port.entry -width 18 -textvariable ::indicam::widget(port)
            pack  $frm.frame1.port.entry -anchor center -side right -padx 10

      pack $frm.frame1.port -anchor center -side left -padx 10 -fill both -expand 1

	pack $frm.frame1 -side top -fill both -expand 1
	
	frame $frm.frame2 -borderwidth 0 -relief raised
      
      #--- Definition de la camera
      label $frm.frame2.lab1 -text "$caption(indicam,device)"
      pack $frm.frame2.lab1 -anchor center -side left -padx 10

      #--- Choix de la camera
      ComboBox $frm.frame2.device \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -values $list_combobox \
         -textvariable ::indicam::widget(device)
      pack $frm.frame2.device -anchor center -side left -padx 10    
                     
	  button $frm.frame2.refresh -text "$caption(indicam,refresh)" -relief raised \
	 -command { ::indicam::checkConnection }
      pack $frm.frame2.refresh -anchor center -side left -padx 10    
     pack $frm.frame2.device -anchor center -side left -padx 10
               
   pack $frm.frame2 -side top -fill both -expand 1

   #--- Frame des miroirs en x et en y, du refroidissement et de la temperature (du capteur CCD et exterieure)
   frame $frm.frame3 -borderwidth 0 -relief raised

      #--- Frame des miroirs en x et en y
      frame $frm.frame3.frame5 -borderwidth 0 -relief raised

         #--- Miroirs en x et en y
         checkbutton $frm.frame3.frame5.mirx -text "$caption(indicam,miroir_x)" -highlightthickness 0 \
            -variable ::indicam::widget(mirh)
         pack $frm.frame3.frame5.mirx -anchor w -side top -padx 10 -pady 10

         checkbutton $frm.frame3.frame5.miry -text "$caption(indicam,miroir_y)" -highlightthickness 0 \
            -variable ::indicam::widget(mirv)
         pack $frm.frame3.frame5.miry -anchor w -side top -padx 10 -pady 10

      pack $frm.frame3.frame5 -side left -fill x -expand 0

      #--- Frame du refroidissement et de la temperature du capteur CCD
      frame $frm.frame3.frame6 -borderwidth 0 -relief raised

         #--- Frame du refroidissement
         frame $frm.frame3.frame6.frame7 -borderwidth 0 -relief raised

            #--- Definition du refroidissement
            checkbutton $frm.frame3.frame6.frame7.cool -text "$caption(indicam,refroidissement)" -highlightthickness 0 \
               -variable ::indicam::widget(cool) -command "::indicam::checkConfigRefroidissement"
            pack $frm.frame3.frame6.frame7.cool -anchor center -side left -padx 0 -pady 5

            entry $frm.frame3.frame6.frame7.temp -textvariable ::indicam::widget(temp) -width 4 \
               -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double -274 50 }
            pack $frm.frame3.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5

            label $frm.frame3.frame6.frame7.tempdeg -text "$caption(indicam,refroidissement_1)"
            pack $frm.frame3.frame6.frame7.tempdeg -anchor center -side left -padx 0 -pady 5

         pack $frm.frame3.frame6.frame7 -side top -fill none -padx 30

         frame $frm.frame3.frame6.frame9 -borderwidth 0 -relief raised

            label $frm.frame3.frame6.frame9.ccdtemp -textvariable ::indicam::private(ccdTemp)
            pack $frm.frame3.frame6.frame9.ccdtemp -side left -fill x -padx 20 -pady 5

         pack $frm.frame3.frame6.frame9 -side top -fill x -padx 30

      pack $frm.frame3.frame6 -side left -expand 0 -padx 60

   pack $frm.frame3 -side top -fill both -expand 1
   
      #--- Frame du site web officiel de la indicam
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(indicam,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confCam::createUrlLabel $frm.frame4 "$caption(indicam,site_web_ref)" \
         "$caption(indicam,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   #--- Gestion des widgets actifs/inactifs
   ::indicam::checkConfigRefroidissement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
   
}

#
# configureCamera
#    Configure la camera indicam en fonction des donnees contenues dans les variables conf(indicam,...)
#
proc ::indicam::configureCamera { camItem bufNo } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- je verifie que la camera n'est deja utilisee
      if { $private(A,camNo) != 0 || $private(B,camNo) != 0 || $private(C,camNo) != 0  } {
         # error "" "" "CameraUnique"
      }
     ### set conf(indicam,host) [ ::audace::verifip $conf(indicam,host) ]

      #--- Je cree la liaison utilisee par la camera pour l'acquisition (cette commande arctive porttalk si necessaire)
      set linkNo [ ::confLink::create $conf(indicam,port) "cam$camItem" "acquisition" "bits 1 to 8" ]
      #--- Je cree la camera
  
	 set camNo [ cam::create indicam $conf(indicam,device) $conf(indicam,host) $conf(indicam,port) \
		-log_file [::confCam::getLogFileName $camItem] \
		-log_level [::confCam::getLogLevel $camItem] \
	 ]

      console::affiche_entete "$caption(indicam,device) ([ cam$camNo name ]) $caption(indicam,2points) $conf(indicam,device)\n"
      console::affiche_saut "\n"
      #--- Je change de variable
      set private($camItem,camNo) $camNo
      #--- Je configure le refroidissement
      if { $conf(indicam,cool) == "1" } {
         cam$camNo cooler check $conf(indicam,temp)
      } else {
         cam$camNo cooler off
      }
      #--- J'associe le buffer de la visu
      cam$camNo buf $bufNo
      #--- Je configure l'oriention des miroirs par defaut
      cam$camNo mirrorh $conf(indicam,mirh)
      cam$camNo mirrorv $conf(indicam,mirv)
      #--- Je mesure la temperature du capteur CCD
#      if { [ info exists private(aftertemp) ] == "0" } {
#         ::indicam::dispTempindicam $camItem
#      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::indicam::stop $camItem
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la camera indicam
#
proc ::indicam::stop { camItem } {
   variable private
   global conf

   #--- Je ferme la liaison d'acquisition de la camera
   ::confLink::delete $conf(indicam,port) "cam$camItem" "acquisition"

   #--- J'arrete la camera
   if { $private($camItem,camNo) != 0 } {
      cam::delete $private($camItem,camNo)
      set private($camItem,camNo) 0
   }
}

#
# dispTempindicam
#    Affiche la temperature du CCD
#
proc ::indicam::dispTempindicam { camItem } {
   variable private
   global caption

   if { [ catch { set tempstatus [ cam$private($camItem,camNo) infotemp ] } ] == "0" } {
      set temp_check         [ format "%+5.2f" [ lindex $tempstatus 0 ] ]
      set temp_ccd           [ format "%+5.2f" [ lindex $tempstatus 1 ] ]
      set temp_ambiant       [ format "%+5.2f" [ lindex $tempstatus 2 ] ]
      set regulation         [ lindex $tempstatus 3 ]
      set private(ccdTemp)   "$caption(indicam,temp_ext) $temp_ccd $caption(indicam,deg_c) / $temp_ambiant $caption(indicam,deg_c)"
      set private(aftertemp) [ after 5000 ::indicam::dispTempindicam $camItem ]
   } else {
      set temp_check       ""
      set temp_ccd         ""
      set temp_ambiant     ""
      set regulation       ""
      set private(ccdTemp) "$caption(indicam,temp_ext) $temp_ccd"
      if { [ info exists private(aftertemp) ] == "1" } {
        unset private(aftertemp)
      }
   }
}

#
# checkConfigRefroidissement
#    Configure le widget de la consigne en temperature
#
proc ::indicam::checkConfigRefroidissement { } {
   variable private
   variable widget

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $::indicam::widget(cool) == "1" } {
            pack $frm.frame3.frame6.frame7.temp -anchor center -side left -padx 5 -pady 5
            pack $frm.frame3.frame6.frame7.tempdeg -side left -fill x -padx 0 -pady 5
            $frm.frame3.frame6.frame9.ccdtemp configure -state normal
         } else {
            pack forget $frm.frame3.frame6.frame7.temp
            pack forget $frm.frame3.frame6.frame7.tempdeg
            $frm.frame3.frame6.frame9.ccdtemp configure -state disabled
         }
      }
   }
}

#
# setTempCCD
#    Procedure pour retourner la consigne de temperature du CCD
#
proc ::indicam::setTempCCD { camItem } {
   global conf

   return "$conf(indicam,temp)"
}

#
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# binningList :      Retourne la liste des binnings disponibles
# binningXListScan : Retourne la liste des binnings en x disponibles en mode scan
# binningYListScan : Retourne la liste des binnings en y disponibles en mode scan
# dynamic :          Retourne la liste de la dynamique haute et basse
# hasBinning :       Retourne l'existence d'un binning (1 : Oui, 0 : Non)
# hasFormat :        Retourne l'existence d'un format (1 : Oui, 0 : Non)
# hasLongExposure :  Retourne l'existence du mode longue pose (1 : Oui, 0 : Non)
# hasScan :          Retourne l'existence du mode scan (1 : Oui, 0 : Non)
# hasTempSensor      Retourne l'existence du capteur de temperature (1 : Oui, 0 : Non)
# hasSetTemp         Retourne l'existence d'une consigne de temperature (1 : Oui, 0 : Non)
# hasVideo :         Retourne l'existence du mode video (1 : Oui, 0 : Non)
# hasWindow :        Retourne la possibilite de faire du fenetrage (1 : Oui, 0 : Non)
# longExposure :     Retourne l'etat du mode longue pose (1: Actif, 0 : Inactif)
# multiCamera :      Retourne la possibilite de connecter plusieurs cameras identiques (1 : Oui, 0 : Non)
# name :             Retourne le modele de la camera
# product :          Retourne le nom du produit
#
proc ::indicam::getPluginProperty { camItem propertyName } {
   variable private

   switch $propertyName {
      binningList      { return [ list 1x1 2x2 3x3 4x4 5x5 6x6 ] }
      binningXListScan { return [ list "" ] }
      binningYListScan { return [ list "" ] }
      dynamic          { return [ list 65535 0 ] }
      hasBinning       { return 1 }
      hasFormat        { return 0 }
      hasLongExposure  { return 0 }
      hasScan          { return 0 }
      hasShutter       { return 1 }
      hasTempSensor    { return 1 }
      hasSetTemp       { return 1 }
      hasVideo         { return 0 }
      hasWindow        { return 1 }
      longExposure     { return 1 }
      multiCamera      { return 0 }
      name             {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) name ]
         } else {
            return ""
         }
      }
      product          {
         if { $private($camItem,camNo) != "0" } {
            return [ cam$private($camItem,camNo) product ]
         } else {
            return ""
         }
      }
   }
}


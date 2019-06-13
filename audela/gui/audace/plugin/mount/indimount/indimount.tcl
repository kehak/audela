#
# Fichier : indimount.tcl
# Description : Configuration de la monture INDI
# Auteur : JB BUTET
# Mise à jour $Id: indimount.tcl 14486 2018-09-21 14:29:32Z jbbutet $
#

namespace eval ::indimount {
   package provide indimount 1.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] indimount.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::indimount::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libindimount.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::indimount::getPluginType]] "indimount" "libindimount.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(indimount,install_1) v[package version indimount]. $::caption(indimount,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::indimount::getPluginTitle { } {
   global caption

   return "$caption(indimount,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::indimount::getPluginHelp { } {
   return "indimount.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::indimount::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::indimount::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::indimount::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::indimount::isReady { } {
   variable private

   if { $private(telNo) == "0" } {
      #--- Monture KO
      return 0
   } else {
      #--- Monture OK
      return 1
   }
}



proc ::indimount::getTels { indiSocket } {

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
	set telOutput [split $indiOutput "\n"]
	
	set tels ""
	set tel ""
	
	foreach line $telOutput {
		regexp {.*device\=\"(.*Telescope.*)\" name\=\"CONNECTION\".*} $line match tel
		if { $tel ne "" } { lappend tels $tel }
	}
			
	if { [ lindex $tels 0 ] ne "" } { return [ lsort -unique $tels ]
	} else { return "" }
}

proc ::indimount::checkConnection { } {
	
	global caption conf
	variable private
	variable widget
	
	catch { set sock [ socket $::indimount::widget(host) $::indimount::widget(port) ] }
	set readable [ catch { fconfigure $sock -peername } msg]
	# if readable = 0 -> no error, let's proceed
	if { ! $readable } {
		fconfigure $sock -blocking 0 -buffering line
		# Connect and retrieve the INDI telescope list
		::console::affiche_resultat "INDI: connected to $::indimount::widget(host):$::indimount::widget(port)\n"
		set conf(indimount,tellist) [ ::indimount::getTels $sock ]
		} else { set conf(indimount,tellist) ""
	}
	
	if { $conf(indimount,tellist) ne "" } { ::console::affiche_resultat "INDI: found [ llength $conf(indimount,tellist) ] telescopes\n"
	} else { ::console::affiche_erreur "Could not find any mount. Is the INDI server on?\n" }
	
	set widget(device) [ lindex $conf(indimount,tellist) 0 ]
		
# 	# Update INDI conf with our new settings
# 	set telItem [ ::confTel::getCurrentTelItem ]
# 	::indimount::widgetToConf $telItem
		
	# Refresh the combo list
# 	if { [ info exists private(frm) ] } {
# 		set frm $private(frm)
# 		::indimount::fillConfigPage $frm $tel
# 	}
		
	return 0
}

#
# initPlugin
#    Initialise les variables conf(indimount,...)
#
proc ::indimount::initPlugin { } {
   variable private
   global conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Initialise les variables de la monture INDI
   if { ! [ info exists conf(indimount,host) ] }      { set conf(indimount,host)      "localhost" }
   if { ! [ info exists conf(indimount,port) ] }      { set conf(indimount,port)      "7624" }
   if { ! [ info exists conf(indimount,device) ] }    { set conf(indimount,device)            "" }
   if { ! [ info exists conf(indimount,tellist) ] }   { set conf(indimount,tellist)     "" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::indimount::confToWidget { } {
   variable widget
   global conf

   #--- Recupere la configuration de la monture INDI dans le tableau private(...)
   set widget(host)      $conf(indimount,host)
   set widget(port)      $conf(indimount,port)
   set widget(raquette)  $conf(raquette)
   set widget(device)    $conf(indimount,device)

}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::indimount::widgetToConf { } {
   variable widget
   global conf

   #--- Memorise la configuration de la monture INDI dans le tableau conf(indimount,...)
   set conf(indimount,host)      $widget(host)
   set conf(indimount,port)      $widget(port)
   set conf(raquette)         $private(raquette)
   set conf(indimount, device)  $widget(device)
}

#
# fillConfigPage
#    Interface de configuration de la monture INDI
#
proc ::indimount::fillConfigPage { frm } {
   variable private
   variable widget
   global caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   
   #--- confToWidget
   ::indimount::confToWidget
   
   #--- Supprime tous les widgets de l'onglet
	foreach i [ winfo children $frm ] {
	  destroy $i
	}

	set list_combobox ""
	# Retrieve the camera list
	foreach tel $conf(indimount,tellist) {
		if { $tel ne "" } { lappend list_combobox $tel }
	}
	
   #--- Frame de la configuration de l'IP et port
   frame $frm.frame1 -borderwidth 1 -relief raised
	
	 # IP
     frame $frm.frame1.ip -borderwidth 0 -relief raised
     
            label $frm.frame1.ip.label -text "$caption(indimount,host)"
            pack  $frm.frame1.ip.label -side left -padx 10

            entry $frm.frame1.ip.entry -width 18 -textvariable ::indimount::widget(host)
            pack  $frm.frame1.ip.entry -side left -padx 10

      pack $frm.frame1.ip -anchor center -side left -padx 10 -fill both -expand 1
     
      # Port 
      frame $frm.frame1.port -borderwidth 0 -relief flat

            label $frm.frame1.port.label -text "$caption(indimount,port)" \
               -highlightthickness 0 
            pack  $frm.frame1.port.label -anchor center -side left -padx 10

            entry $frm.frame1.port.entry -width 18 -textvariable ::indimount::widget(port)
            pack  $frm.frame1.port.entry -anchor center -side right -padx 10

      pack $frm.frame1.port -anchor center -side left -padx 10 -fill both -expand 1

      # INDI buttons
      button $frm.frame1.indistarter -text "INDI starter" -relief raised -command { exec indistarter & }
      pack  $frm.frame1.indistarter -anchor center -side right -padx 10
      button $frm.frame1.indigui -text "INDI GUI" -relief raised -command { exec indigui & }
      pack  $frm.frame1.indigui -anchor center -side right -padx 10

   pack $frm.frame1 -side top -fill both -expand 1
	
	frame $frm.frame2 -borderwidth 0 -relief raised
      
      #--- Definition de la camera
      label $frm.frame2.lab1 -text "$caption(indimount,device)"
      pack $frm.frame2.lab1 -anchor center -side left -padx 10

      #--- Choix de la camera
      ComboBox $frm.frame2.device \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -values $list_combobox \
         -textvariable ::indimount::widget(device)
      pack $frm.frame2.device -anchor center -side left -padx 10    
                     
	  button $frm.frame2.refresh -text "$caption(indimount,refresh)" -relief raised \
	 -command { ::indimount::checkConnection }
      pack $frm.frame2.refresh -anchor center -side left -padx 10    
     pack $frm.frame2.device -anchor center -side left -padx 10
               
   pack $frm.frame2 -side top -fill both -expand 1
   
   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side top -fill x
    #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(indimount,raquette_tel)" -highlightthickness 0 -variable ::indimount::widget(raquette)
   pack $frm.raquette -in $frm.frame3 -anchor center -side left -padx 10 -pady 10

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::widget(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame3 -anchor center -side left -padx 0 -pady 10
   
      #--- Frame du site web officiel de la indicam
   frame $frm.frame4 -borderwidth 0 -relief raised

      label $frm.frame4.lab103 -text "$caption(indimount,titre_site_web)"
      pack $frm.frame4.lab103 -side top -fill x -pady 2

      set labelName [ ::confTel::createUrlLabel $frm.frame4 "$caption(indimount,site_web_ref)" \
         "$caption(indimount,site_web_ref)" ]
      pack $labelName -side top -fill x -pady 2

   pack $frm.frame4 -side bottom -fill x -pady 2

   
}


# configureMonture
#    Configure la monture INDI en fonction des donnees contenues dans les variables conf(indimount,...)
#
proc ::indimount::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create indimount $conf(indimount,device) $conf(indimount,port) 
         -log_file [::confCam::getLogFileName $camItem] \
		-log_level [::confCam::getLogLevel $camItem] \
		]
      
      console::affiche_entete "Connected: [ cam$camNo name ]\n"
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      
      
      
      #--- Je change de variable
      set private(telNo) $telNo
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::indimount::stop
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture INDI
#
proc ::indimount::stop { } {
   variable private
   global conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

#    #--- Je memorise le port
#    if { $conf(indimount,hos) == "1" } {
#       #--- Mode RS232
#       set telPort [ tel$private(telNo) port ]
#    }
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
#    if { $conf(indimount,mode) == "1" } {
#       #--- Mode RS232
#       ::confLink::delete $telPort "tel$private(telNo)" "control"
#    }
   #--- Remise a zero du numero de monture
   set private(telNo) "0"
}

#
# getPluginProperty
#    Retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# return : Valeur de la propriete ou "" si la propriete n'existe pas
#
# multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
# name                    Retourne le modele de la monture
# product                 Retourne le nom du produit
# hasCoordinates          Retourne la possibilite d'afficher les coordonnees
# hasGoto                 Retourne la possibilite de faire un Goto
# hasMatch                Retourne la possibilite de faire un Match
# hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
# hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
# hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
# hasPark                 Retourne la possibilite de parquer la monture
# hasUnpark               Retourne la possibilite de de-parquer la monture
# hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
# backlash                Retourne la possibilite de faire un rattrapage des jeux
#
proc ::indimount::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              { return 0 }
      name                    {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) name ]
         } else {
            return ""
         }
      }
      product                 {
         if { $private(telNo) != "0" } {
            return [ tel$private(telNo) product ]
         } else {
            return ""
         }
      }
      hasCoordinates          { return 1 }
      hasGoto                 { return 1 }
      hasMatch                { return 1 }
      hasManualMotion         { return 1 }
      hasControlSuivi         { return 1 }
      hasModel                { return 0 }
      hasPark                 { return 1 }
      hasUnpark               { return 1 }
      hasUpdateDate           { return 1 }
      backlash                { return 0 }
   }
}


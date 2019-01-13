#
# Fichier : audecom.tcl
# Description : Parametrage et pilotage de la carte AudeCom (Ex-Kauffmann)
# Auteur : Robert DELMAS
# Mise à jour $Id: audecom.tcl 9942 2013-08-10 08:48:42Z robertdelmas $
#

namespace eval ::audecom {
   package provide audecom 3.0

   #--- Charge le fichier caption
   source [ file join [file dirname [info script]] audecom.cap ]
}

#
# install
#    installe le plugin et la dll
#
proc ::audecom::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libaudecom.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::audecom::getPluginType]] "audecom" "libaudecom.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage "$::caption(audecom,install_1) v[package version audecom]. $::caption(audecom,install_2)"
   }
}

#
# getPluginTitle
#    Retourne le label du plugin dans la langue de l'utilisateur
#
proc ::audecom::getPluginTitle { } {
   global caption

   return "$caption(audecom,monture)"
}

#
# getPluginHelp
#     Retourne la documentation du plugin
#
proc ::audecom::getPluginHelp { } {
   return "audecom.htm"
}

#
# getPluginType
#    Retourne le type du plugin
#
proc ::audecom::getPluginType { } {
   return "mount"
}

#
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
proc ::audecom::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#
# getTelNo
#    Retourne le numero de la monture
#
proc ::audecom::getTelNo { } {
   variable private

   return $private(telNo)
}

#
# isReady
#    Indique que la monture est prete
#    Retourne "1" si la monture est prete, sinon retourne "0"
#
proc ::audecom::isReady { } {
   variable private

   if { $private(telNo) == "0" } {
      #--- Monture KO
      return 0
   } else {
      #--- Monture OK
      return 1
   }
}

#
# getSecondaryTelNo
#    Retourne le numero de la monture secondaire, sinon retourne "0"
#
proc ::audecom::getSecondaryTelNo { } {
   set result [ ::ouranos::getTelNo ]
   return $result
}

#
# slewpathLong2Short
#    Commute le mode slewpath de long a short
#
proc ::audecom::slewpathLong2Short { } {
   variable private

   set slewpath [ tel$private(telNo) slewpath ]
   if { $slewpath == "long" } {
      tel$private(telNo) slewpath short
   }
}

#
# slewpathShort2Long
#    Commute le mode slewpath de short a long
#
proc ::audecom::slewpathShort2Long { } {
   variable private
   global conf

   set slewpath [ tel$private(telNo) slewpath ]
   if { $slewpath == "short" && $conf(audecom,gotopluslong) == "1" } {
      tel$private(telNo) slewpath long
   }
}

#
# setTrackSpeed
#    Parametre la vitesse de suivi pour le Soleil ou la Lune
#
proc ::audecom::setTrackSpeed { } {
   variable private
   global caption conf

   #--- Cas particulier du GOTO sur le Soleil et sur la Lune
   #--- Transfere les parametres de derive dans le microcontroleur
   set vit_der_alpha 0; set vit_der_delta 0
   catch {
      if { $catalogue(planete_choisie) == "$caption(audecom,soleil)" } {
         set vit_der_alpha 3548
         set vit_der_delta 0
      } elseif { $catalogue(planete_choisie) == "$caption(audecom,lune)" } {
         set vit_der_alpha 43636
         set vit_der_delta 0
      } else {
         set vit_der_alpha 0
         set vit_der_delta 0
      }
   }
   #--- Precaution pour ne jamais diviser par zero
   if { $vit_der_alpha == "0" } { set vit_der_alpha "1" }
   if { $vit_der_delta == "0" } { set vit_der_delta "1" }
   #--- Calcul de la correction
   set alpha [ expr $conf(audecom,dsuivinom)*1296000/$vit_der_alpha ]
   set alpha [ expr round($alpha) ]
   set delta [ expr $conf(audecom,dsuividelta)*1296000/$vit_der_delta ]
   set delta [ expr round($delta) ]
   #--- Bornage de la correction
   if { $alpha > "99999999" } { set alpha "99999999" }
   if { $alpha < "-99999999" } { set alpha "-99999999" }
   if { $delta > "99999999" } { set delta "99999999" }
   if { $delta < "-99999999" } { set delta "-99999999" }
   #--- Application de la correction solaire/lunaire ou annulation (suivi sideral)
   #--- Arret des moteurs + Application des corrections + Mise en marche des moteurs
   tel$private(telNo) radec motor off
   tel$private(telNo) driftspeed $alpha $delta
   tel$private(telNo) radec motor on
}

#
# initPlugin
#    Initialise les variables conf(audecom,...)
#
proc ::audecom::initPlugin { } {
   variable private
   global audace conf

   #--- Initialisation
   set private(telNo) "0"

   #--- Charge le fichier auxiliaire
   uplevel #0 "source \"[ file join $audace(rep_plugin) mount audecom audecomconfig.tcl ]\""

   #--- Initialise les variables de la monture AudeCom
   if { ! [ info exists conf(audecom,port) ] }         { set conf(audecom,port)         "" }
   if { ! [ info exists conf(audecom,ouranos) ] }      { set conf(audecom,ouranos)      "0" }
   if { ! [ info exists conf(audecom,ad) ] }           { set conf(audecom,ad)           "999999" }
   if { ! [ info exists conf(audecom,dec) ] }          { set conf(audecom,dec)          "999999" }
   if { ! [ info exists conf(audecom,dep_val) ] }      { set conf(audecom,dep_val)      "250" }
   if { ! [ info exists conf(audecom,german) ] }       { set conf(audecom,german)       "0" }
   if { ! [ info exists conf(audecom,intra_extra) ] }  { set conf(audecom,intra_extra)  "0" }
   if { ! [ info exists conf(audecom,inv_rot) ] }      { set conf(audecom,inv_rot)      "0" }
   if { ! [ info exists conf(audecom,gotopluslong) ] } { set conf(audecom,gotopluslong) "0" }
   if { ! [ info exists conf(audecom,king) ] }         { set conf(audecom,king)         "1" }
   if { ! [ info exists conf(audecom,limp) ] }         { set conf(audecom,limp)         "50" }
   if { ! [ info exists conf(audecom,maxad) ] }        { set conf(audecom,maxad)        "16" }
   if { ! [ info exists conf(audecom,maxdec) ] }       { set conf(audecom,maxdec)       "16" }
   if { ! [ info exists conf(audecom,mobile) ] }       { set conf(audecom,mobile)       "0" }
   if { ! [ info exists conf(audecom,pec) ] }          { set conf(audecom,pec)          "1" }
   if { ! [ info exists conf(audecom,rat_ad) ] }       { set conf(audecom,rat_ad)       "0.5" }
   if { ! [ info exists conf(audecom,rat_dec) ] }      { set conf(audecom,rat_dec)      "0.5" }
   if { ! [ info exists conf(audecom,rpec) ] }         { set conf(audecom,rpec)         "6" }
   if { ! [ info exists conf(audecom,type) ] }         { set conf(audecom,type)         "2" }
   if { ! [ info exists conf(audecom,t0) ] }           { set conf(audecom,t0)           "192" }
   if { ! [ info exists conf(audecom,t1) ] }           { set conf(audecom,t1)           "192" }
   if { ! [ info exists conf(audecom,t2) ] }           { set conf(audecom,t2)           "192" }
   if { ! [ info exists conf(audecom,t3) ] }           { set conf(audecom,t3)           "192" }
   if { ! [ info exists conf(audecom,t4) ] }           { set conf(audecom,t4)           "192" }
   if { ! [ info exists conf(audecom,t5) ] }           { set conf(audecom,t5)           "192" }
   if { ! [ info exists conf(audecom,t6) ] }           { set conf(audecom,t6)           "192" }
   if { ! [ info exists conf(audecom,t7) ] }           { set conf(audecom,t7)           "192" }
   if { ! [ info exists conf(audecom,t8) ] }           { set conf(audecom,t8)           "192" }
   if { ! [ info exists conf(audecom,t9) ] }           { set conf(audecom,t9)           "192" }
   if { ! [ info exists conf(audecom,t10) ] }          { set conf(audecom,t10)          "192" }
   if { ! [ info exists conf(audecom,t11) ] }          { set conf(audecom,t11)          "192" }
   if { ! [ info exists conf(audecom,t12) ] }          { set conf(audecom,t12)          "192" }
   if { ! [ info exists conf(audecom,t13) ] }          { set conf(audecom,t13)          "192" }
   if { ! [ info exists conf(audecom,t14) ] }          { set conf(audecom,t14)          "192" }
   if { ! [ info exists conf(audecom,t15) ] }          { set conf(audecom,t15)          "192" }
   if { ! [ info exists conf(audecom,t16) ] }          { set conf(audecom,t16)          "192" }
   if { ! [ info exists conf(audecom,t17) ] }          { set conf(audecom,t17)          "192" }
   if { ! [ info exists conf(audecom,t18) ] }          { set conf(audecom,t18)          "192" }
   if { ! [ info exists conf(audecom,t19) ] }          { set conf(audecom,t19)          "192" }
   if { ! [ info exists conf(audecom,vitesse) ] }      { set conf(audecom,vitesse)      "30" }

   #--- Initialisation des parametres de la monture lies a la reduction des axes AD et Dec. (par editeur de texte)
   if { ! [ info exists conf(audecom,dlimp) ] }        { set conf(audecom,dlimp)        "100" }
   if { ! [ info exists conf(audecom,dlimpmax) ] }     { set conf(audecom,dlimpmax)     "255" }
   if { ! [ info exists conf(audecom,dlimpmin) ] }     { set conf(audecom,dlimpmin)     "0" }
   if { ! [ info exists conf(audecom,dlimprecouv) ] }  { set conf(audecom,dlimprecouv)  "192" }
   if { ! [ info exists conf(audecom,dmaxad) ] }       { set conf(audecom,dmaxad)       "16" }
   if { ! [ info exists conf(audecom,dmaxadmax) ] }    { set conf(audecom,dmaxadmax)    "16" }
   if { ! [ info exists conf(audecom,dmaxadmin) ] }    { set conf(audecom,dmaxadmin)    "4" }
   if { ! [ info exists conf(audecom,dmaxdec) ] }      { set conf(audecom,dmaxdec)      "16" }
   if { ! [ info exists conf(audecom,dmaxdecmax) ] }   { set conf(audecom,dmaxdecmax)   "16" }
   if { ! [ info exists conf(audecom,dmaxdecmin) ] }   { set conf(audecom,dmaxdecmin)   "4" }
   if { ! [ info exists conf(audecom,dsuividelta) ] }  { set conf(audecom,dsuividelta)  "192" }
   if { ! [ info exists conf(audecom,dsuivinom) ] }    { set conf(audecom,dsuivinom)    "192" }
   if { ! [ info exists conf(audecom,dsuivinommax) ] } { set conf(audecom,dsuivinommax) "255" }
   if { ! [ info exists conf(audecom,dsuivinommin) ] } { set conf(audecom,dsuivinommin) "130" }
   if { ! [ info exists conf(audecom,dsuivinomxt0) ] } { set conf(audecom,dsuivinomxt0) "37.9159872" }
   if { ! [ info exists conf(audecom,internom) ] }     { set conf(audecom,internom)     "197.4791" }
}

#
# confToWidget
#    Copie les variables de configuration dans des variables locales
#
proc ::audecom::confToWidget { } {
   variable private
   global conf

   #--- Recupere la configuration de la monture AudeCom dans le tableau private(...)
   set private(port)        $conf(audecom,port)
   set private(ouranos)     $conf(audecom,ouranos)
   set private(pec)         $conf(audecom,pec)
   set private(king)        $conf(audecom,king)
   set private(mobile)      $conf(audecom,mobile)
   set private(german)      $conf(audecom,german)
   #--- Pour la fenetre de configuration des parametres moteurs
   set private(limp)        $conf(audecom,limp)
   set private(maxad)       $conf(audecom,maxad)
   set private(maxdec)      $conf(audecom,maxdec)
   set private(rat_ad)      $conf(audecom,rat_ad)
   set private(rat_dec)     $conf(audecom,rat_dec)
   #--- Pour la fenetre de configuration des parametres de la focalisation
   set private(dep_val)     $conf(audecom,dep_val)
   set private(intra_extra) $conf(audecom,intra_extra)
   set private(inv_rot)     $conf(audecom,inv_rot)
   set private(vitesse)     $conf(audecom,vitesse)
   #--- Pour la fenetre de configuration de la programmation du PEC
   set private(rpec)        $conf(audecom,rpec)
   set private(t0)          $conf(audecom,t0)
   set private(t1)          $conf(audecom,t1)
   set private(t2)          $conf(audecom,t2)
   set private(t3)          $conf(audecom,t3)
   set private(t4)          $conf(audecom,t4)
   set private(t5)          $conf(audecom,t5)
   set private(t6)          $conf(audecom,t6)
   set private(t7)          $conf(audecom,t7)
   set private(t8)          $conf(audecom,t8)
   set private(t9)          $conf(audecom,t9)
   set private(t10)         $conf(audecom,t10)
   set private(t11)         $conf(audecom,t11)
   set private(t12)         $conf(audecom,t12)
   set private(t13)         $conf(audecom,t13)
   set private(t14)         $conf(audecom,t14)
   set private(t15)         $conf(audecom,t15)
   set private(t16)         $conf(audecom,t16)
   set private(t17)         $conf(audecom,t17)
   set private(t18)         $conf(audecom,t18)
   set private(t19)         $conf(audecom,t19)
   #--- Pour la fenetre de configuration du suivi des objets mobiles
   set private(ad)          $conf(audecom,ad)
   set private(dec)         $conf(audecom,dec)
   set private(type)        $conf(audecom,type)
   set private(raquette)    $conf(raquette)
}

#
# widgetToConf
#    Copie les variables locales dans des variables de configuration
#
proc ::audecom::widgetToConf { } {
   variable private
   global conf

   #--- Memorise la configuration de la monture AudeCom dans le tableau conf(audecom,...)
   set conf(audecom,port)        $private(port)
   set conf(audecom,ouranos)     $private(ouranos)
   set conf(audecom,pec)         $private(pec)
   set conf(audecom,king)        $private(king)
   set conf(audecom,mobile)      $private(mobile)
   set conf(audecom,german)      $private(german)
   #--- Vient de la fenetre de configuration des parametres moteurs
   set conf(audecom,limp)        $private(limp)
   set conf(audecom,maxad)       $private(maxad)
   set conf(audecom,maxdec)      $private(maxdec)
   set conf(audecom,rat_ad)      $private(rat_ad)
   set conf(audecom,rat_dec)     $private(rat_dec)
   #--- Vient de la fenetre de configuration des parametres de la focalisation
   set conf(audecom,dep_val)     $private(dep_val)
   set conf(audecom,intra_extra) $private(intra_extra)
   set conf(audecom,inv_rot)     $private(inv_rot)
   set conf(audecom,vitesse)     $private(vitesse)
   #--- Vient de la fenetre de configuration de la programmation PEC
   set conf(audecom,rpec)        $private(rpec)
   set conf(audecom,t0)          $private(t0)
   set conf(audecom,t1)          $private(t1)
   set conf(audecom,t2)          $private(t2)
   set conf(audecom,t3)          $private(t3)
   set conf(audecom,t4)          $private(t4)
   set conf(audecom,t5)          $private(t5)
   set conf(audecom,t6)          $private(t6)
   set conf(audecom,t7)          $private(t7)
   set conf(audecom,t8)          $private(t8)
   set conf(audecom,t9)          $private(t9)
   set conf(audecom,t10)         $private(t10)
   set conf(audecom,t11)         $private(t11)
   set conf(audecom,t12)         $private(t12)
   set conf(audecom,t13)         $private(t13)
   set conf(audecom,t14)         $private(t14)
   set conf(audecom,t15)         $private(t15)
   set conf(audecom,t16)         $private(t16)
   set conf(audecom,t17)         $private(t17)
   set conf(audecom,t18)         $private(t18)
   set conf(audecom,t19)         $private(t19)
   #--- Vient de la fenetre de configuration de suivi
   set conf(audecom,ad)          $private(ad)
   set conf(audecom,dec)         $private(dec)
   set conf(audecom,type)        $private(type)
   set conf(raquette)            $private(raquette)
}

#
# fillConfigPage
#    Interface de configuration de la monture AudeCom
#
proc ::audecom::fillConfigPage { frm } {
   variable private
   global audace caption conf

   #--- Initialise une variable locale
   set private(frm) $frm

   #--- Prise en compte des liaisons
   set list_connexion [ ::confLink::getLinkLabels { "serialport" } ]
   if { $conf(audecom,port) == "" } {
      set conf(audecom,port) [ lindex $list_connexion 0 ]
   }

   #--- Rajoute le nom du port dans le cas d'une connexion automatique au demarrage
   if { $private(telNo) != 0 && [ lsearch $list_connexion $conf(audecom,port) ] == -1 } {
      lappend list_connexion $conf(audecom,port)
   }

   #--- confToWidget
   ::audecom::confToWidget

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised
   pack $frm.frame1 -side top -fill x

   frame $frm.frame2 -borderwidth 0 -relief raised
   pack $frm.frame2 -side top -fill both -expand 1

   frame $frm.frame3 -borderwidth 0 -relief raised
   pack $frm.frame3 -side bottom -fill x -pady 2

   frame $frm.frame4 -borderwidth 0 -relief raised
   pack $frm.frame4 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame5 -borderwidth 0 -relief raised
   pack $frm.frame5 -in $frm.frame1 -side left -fill both -expand 1

   frame $frm.frame6 -borderwidth 0 -relief raised
   pack $frm.frame6 -in $frm.frame4 -side top -fill x

   frame $frm.frame7 -borderwidth 0 -relief raised
   pack $frm.frame7 -in $frm.frame4 -side top -fill x

   frame $frm.frame16 -borderwidth 0 -relief raised
   pack $frm.frame16 -in $frm.frame4 -side bottom -fill x

   frame $frm.frame8 -borderwidth 0 -relief raised
   pack $frm.frame8 -in $frm.frame4 -side bottom -fill x

   frame $frm.frame9 -borderwidth 0 -relief raised
   pack $frm.frame9 -in $frm.frame4 -side bottom -fill x

   frame $frm.frame10 -borderwidth 0 -relief raised
   pack $frm.frame10 -in $frm.frame4 -side top -fill x

   frame $frm.frame11 -borderwidth 0 -relief raised
   pack $frm.frame11 -in $frm.frame5 -side top -fill x

   frame $frm.frame12 -borderwidth 0 -relief raised
   pack $frm.frame12 -in $frm.frame5 -side top -fill x

   frame $frm.frame13 -borderwidth 0 -relief raised
   pack $frm.frame13 -in $frm.frame5 -side top -fill x

   frame $frm.frame14 -borderwidth 0 -relief raised
   pack $frm.frame14 -in $frm.frame5 -side top -fill x

   #frame $frm.frame17 -borderwidth 0 -relief raised
   #pack $frm.frame17 -in $frm.frame5 -side bottom -fill x

   #frame $frm.frame15 -borderwidth 0 -relief raised
   #pack $frm.frame15 -in $frm.frame5 -side bottom -fill x

   frame $frm.frame18 -borderwidth 0 -relief raised
   pack $frm.frame18 -in $frm.frame2 -side bottom -fill x

   frame $frm.frame19 -borderwidth 0 -relief raised
   pack $frm.frame19 -in $frm.frame2 -side top -fill x

   #--- Definition du port
   label $frm.lab1 -text "$caption(audecom,port)"
     pack $frm.lab1 -in $frm.frame6 -anchor center -side left -padx 10 -pady 10

   #--- Je verifie le contenu de la liste
   if { [ llength $list_connexion ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $list_connexion $private(port) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set private(port) [ lindex $list_connexion 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   #--- Bouton de configuration des ports et liaisons
   button $frm.configure -text "$caption(audecom,configurer)" -relief raised \
      -command {
         ::confLink::run ::audecom::private(port) { serialport } \
            "- $caption(audecom,controle) - $caption(audecom,monture)"
      }
   pack $frm.configure -in $frm.frame6 -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   #--- Choix du port ou de la liaison
   ComboBox $frm.port \
      -width [ ::tkutil::lgEntryComboBox $list_connexion ] \
      -height [ llength $list_connexion ] \
      -relief sunken    \
      -borderwidth 1    \
      -textvariable ::audecom::private(port) \
      -editable 0       \
      -values $list_connexion
   pack $frm.port -in $frm.frame6 -anchor center -side left -padx 10 -pady 8

   #--- Le checkbutton du fonctionnement coordonne AudeCom + Ouranos
   if { [glob -nocomplain -type f -join "$audace(rep_plugin)" mount ouranos pkgIndex.tcl ] == "" } {
      set private(ouranos) "0"
      checkbutton $frm.ouranos -text "$caption(audecom,ouranos)" -highlightthickness 0 \
         -variable ::audecom::private(ouranos) -state disabled
      pack $frm.ouranos -in $frm.frame7 -anchor center -side left -padx 10 -pady 8
   } else {
      checkbutton $frm.ouranos -text "$caption(audecom,ouranos)" -highlightthickness 0 \
         -variable ::audecom::private(ouranos) -state normal
      pack $frm.ouranos -in $frm.frame7 -anchor center -side left -padx 10 -pady 8
   }

   #--- Les checkbuttons (PEC, objet mobile et vitesse de King)
   checkbutton $frm.king -text "$caption(audecom,king)" -highlightthickness 0 \
      -variable ::audecom::private(king)
   pack $frm.king -in $frm.frame8 -anchor center -side left -padx 10 -pady 8

   checkbutton $frm.mobile -text "$caption(audecom,mobile)" -highlightthickness 0 \
      -variable ::audecom::private(mobile)
   pack $frm.mobile -in $frm.frame9 -anchor center -side left -padx 10 -pady 8

   checkbutton $frm.pec -text "$caption(audecom,pec)" -highlightthickness 0 \
      -variable ::audecom::private(pec)
   pack $frm.pec -in $frm.frame10 -anchor center -side left -padx 10 -pady 8

   #--- Les boutons de commande
   button $frm.paramot -text "$caption(audecom,para_moteur)" \
      -command { ::confAudecomMot::run "$audace(base).confAudecomMot" }
   pack $frm.paramot -in $frm.frame11 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

   button $frm.parafoc -text "$caption(audecom,para_foc)" \
      -command { ::confAudecomFoc::run "$audace(base).confAudecomFoc" }
   pack $frm.parafoc -in $frm.frame12 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

   button $frm.progpec -text "$caption(audecom,prog_pec)" \
      -command { ::confAudecomPec::run "$audace(base).confAudecomPec" }
   pack $frm.progpec -in $frm.frame13 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

   button $frm.ctlmobile -text "$caption(audecom,ctl_mobile)" -state normal \
      -command { ::confAudecomMobile::run "$audace(base).confAudecomMobile" }
   pack $frm.ctlmobile -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true

   #--- Affiche le bouton de controle de la vitesse de King si la monture AudeCom est connecte
   if { [ ::audecom::isReady ] == 1 } {
      if { [ winfo exists $audace(base).confAudecomKing ] } {
         button $frm.ctlking -text "$caption(audecom,ctl_king)" -relief groove -state disabled \
            -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
         pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
      } else {
         button $frm.ctlking -text "$caption(audecom,ctl_king)" -relief raised -state normal \
            -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
         pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
      }
   }

   #--- Le checkbutton pour la visibilite de la raquette a l'ecran
   checkbutton $frm.raquette -text "$caption(audecom,raquette_tel)" \
      -highlightthickness 0 -variable ::audecom::private(raquette)
   pack $frm.raquette -in $frm.frame16 -anchor center -side left -padx 10 -pady 8

   #--- Frame raquette
   ::confPad::createFramePad $frm.nom_raquette "::confTel::private(nomRaquette)"
   pack $frm.nom_raquette -in $frm.frame16 -anchor center -side left -padx 0 -pady 8

   #--- Le checkbutton pour la monture equatoriale allemande
   checkbutton $frm.german -text "$caption(audecom,mont_allemande)" -highlightthickness 0 -state disabled \
      -variable ::audecom::private(german) -command { ::audecom::configEquatorialAudeCom }
   pack $frm.german -in $frm.frame18 -anchor nw -side left -padx 10 -pady 8

   #--- Gestion de l'option monture equatoriale allemande
   if { $private(german) == "1" } {
      #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
      label $frm.pos_tel -text "$caption(audecom,position_telescope)"
      pack $frm.pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3

      label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
      pack $frm.pos_tel_ew -in $frm.frame19 -anchor center -side left

      #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
      label $frm.pos_tel_est -text "$caption(audecom,change_position_telescope)"
      pack $frm.pos_tel_est -in $frm.frame19 -anchor center -side left -padx 10 -pady 3

      if { [ ::audecom::isReady ] == 1 } {
         button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
     ###       set pos_tel [ tel$::audecom::private(telNo) german ]
     ###       if { $pos_tel == "E" } {
     ###          tel$::audecom::private(telNo) german W
     ###       } elseif { $pos_tel == "W" } {
     ###          tel$::audecom::private(telNo) german E
     ###       }
     ###       ::telescope::monture_allemande
         }
         pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
      } else {
         button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
         pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
      }
   }

   #--- Document officiel d'AudeCom
   label $frm.lab103 -text "$caption(audecom,document_ref)"
   pack $frm.lab103 -in $frm.frame3 -side top -fill x -pady 2

   set labelName [ ::confTel::createPdfLabel $frm.frame3 "$caption(audecom,doc_audecom)" \
      "$caption(audecom,doc_audecom)" ]
   pack $labelName -side top -fill x -pady 2
}

#
# configureMonture
#    Configure la monture AudeCom en fonction des donnees contenues dans les variables conf(audecom,...)
#
proc ::audecom::configureMonture { } {
   variable private
   global caption conf

   set catchResult [ catch {
      #--- Je cree la monture
      set telNo [ tel::create audecom $conf(audecom,port) ]
      #--- Je configure la position geographique et le nom de la monture
      #--- (la position geographique est utilisee pour calculer le temps sideral)
      tel$telNo home $::audace(posobs,observateur,gps)
      tel$telNo home name $::conf(posobs,nom_observatoire)
      #--- J'active le rafraichissement automatique des coordonnees AD et Dec. (environ toutes les secondes)
      tel$telNo radec survey 1
      #--- J'affiche un message d'information dans la Console
      ::console::affiche_entete "$caption(audecom,port_audecom) $caption(audecom,2points)\
         $conf(audecom,port)\n"
      #--- Lit et affiche la version du firmware
      set v_firmware [ tel$telNo firmware ]
      set v_firmware "[ string range $v_firmware 0 0 ].[ string range $v_firmware 1 2 ]"
      ::console::affiche_entete "$caption(audecom,ver_firmware)$v_firmware\n"
      ::console::affiche_saut "\n"
      #--- Transfere les parametres des moteurs dans le microcontroleur
      tel$telNo slewspeed $conf(audecom,maxad) $conf(audecom,maxdec)
      tel$telNo pulse $conf(audecom,limp)
      tel$telNo backlash $conf(audecom,rat_ad) $conf(audecom,rat_dec)
      tel$telNo focspeed $conf(audecom,vitesse)
      #--- R : Inhibe le PEC
      tel$telNo pec_period 0
      #--- Transfere les corrections pour le PEC dans le microcontroleur
      for { set i 0 } { $i <= 19 } { incr i } {
         tel$telNo pec_speed $conf(audecom,t$i)
      }
      #--- r : Active ou non le PEC
      if { $conf(audecom,pec) == "1" } {
         tel$telNo pec_period $conf(audecom,rpec)
      }
      #--- Transfere les parametres de derive dans le microcontroleur
      set vit_der_alpha "0" ; set vit_der_delta "0"
      if { $::confAudecomMobile::private(fenetre,mobile,valider) == "1" } {
         if { $conf(audecom,mobile) == "1" } {
            switch -exact -- $conf(audecom,type) {
               0 { set vit_der_alpha "43636" ; set vit_der_delta "0" }                          ; #--- Lune
               1 { set vit_der_alpha "3548"  ; set vit_der_delta "0" }                          ; #--- Soleil
               2 { set vit_der_alpha $conf(audecom,ad) ; set vit_der_delta $conf(audecom,dec) } ; #--- Comete
               3 { set vit_der_alpha "0" ; set vit_der_delta "0" }                              ; #--- Etoile
            }
         }
      } else {
         catch { set frm $private(frm) }
         set private(mobile)      "0"
         set conf(audecom,mobile) "0"
         if { $conf(telescope,start) != "1" } {
            $frm.mobile configure -variable ::audecom::private(mobile)
         }
      }
      #--- Precaution pour ne jamais diviser par zero
      if { $vit_der_alpha == "0" } { set vit_der_alpha "1" }
      if { $vit_der_delta == "0" } { set vit_der_delta "1" }
      #--- Calcul de la correction
      set alpha [ expr $conf(audecom,dsuivinom)*1296000/$vit_der_alpha ]
      set alpha [ expr round($alpha) ]
      set delta [ expr $conf(audecom,dsuividelta)*1296000/$vit_der_delta ]
      set delta [ expr round($delta) ]
      #--- Bornage de la correction
      if { $alpha > "99999999" }  { set alpha "99999999" }
      if { $alpha < "-99999999" } { set alpha "-99999999" }
      if { $delta > "99999999" }  { set delta "99999999" }
      if { $delta < "-99999999" } { set delta "-99999999" }
      #--- Arret des moteurs + Application des corrections + Mise en marche des moteurs
      tel$telNo radec motor off
      tel$telNo driftspeed $alpha $delta
      tel$telNo radec motor on
      #--- Affichage de la position du telescope sur la monture
     ### ::telescope::monture_allemande
      #--- Je cree la liaison (ne sert qu'a afficher l'utilisation de cette liaison par la monture)
      set linkNo [ ::confLink::create $conf(audecom,port) "tel$telNo" "control" [ tel$telNo product ] -noopen ]
      #--- Je change de variable
      set private(telNo) $telNo
      #--- Gestion du bouton actif/inactif
      ::audecom::confAudeCom

      #--- Si connexion des codeurs Ouranos demandee en tant que monture secondaire
      if { $conf(audecom,ouranos) == "1" } {
         #--- Je copie les parametres Ouranos dans conf()
         ::ouranos::widgetToConf
         #--- Je configure la monture secondaire Ouranos
         ::ouranos::configureMonture
      }
   } ]

   if { $catchResult == "1" } {
      #--- En cas d'erreur, je libere toutes les ressources allouees
      ::audecom::stop
      if { $conf(audecom,ouranos) == "1" } {
         ::ouranos::stop
      }
      #--- Je transmets l'erreur a la procedure appelante
      return -code error -errorcode $::errorCode -errorinfo $::errorInfo
   }
}

#
# stop
#    Arrete la monture AudeCom
#
proc ::audecom::stop { } {
   variable private
   global audace conf

   #--- Sortie anticipee si le telescope n'existe pas
   if { $private(telNo) == "0" } {
      return
   }

   #--- Efface la fenetre de controle de la vitesse de King si elle existe
   if { [ winfo exists $audace(base).confAudecomKing ] } {
      destroy $audace(base).confAudecomKing
   }

   #--- Gestion du bouton actif/inactif
   ::audecom::confAudeComInactif

   #--- Initialisation d'une variable
   set ::confAudecomMobile::private(fenetre,mobile,valider) "0"

   #--- Je desactive le rafraichissement automatique des coordonnees AD et Dec.
   tel$private(telNo) radec survey 0
   #--- Je memorise le port
   set telPort [ tel$private(telNo) port ]
   #--- J'arrete la monture
   tel::delete $private(telNo)
   #--- J'arrete le link
   ::confLink::delete $telPort "tel$private(telNo)" "control"
   #--- Remise a zero du numero de monture
   set private(telNo) "0"

   #--- Deconnexion des codeurs Ouranos si la monture secondaire existe
   if { $conf(audecom,ouranos) == "1" } {
      ::ouranos::stop
   }
}

#
# confAudeCom
# Permet d'activer ou de desactiver le bouton 'Controle de la vitesse de King'
#
proc ::audecom::confAudeCom { } {
   variable private
   global audace caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::audecom::isReady ] == 1 } {
            if { [ winfo exists $frm.ctlking ] } {
               $frm.ctlking configure -text "$caption(audecom,ctl_king)" -relief groove -state disabled \
                  -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
            } else {
               button $frm.ctlking -text "$caption(audecom,ctl_king)" -relief raised -state normal \
                  -command { ::confAudecomKing::run "$audace(base).confAudecomKing" }
               pack $frm.ctlking -in $frm.frame14 -anchor center -side top -pady 3 -ipadx 10 -ipady 5 -expand true
            }
         } else {
            destroy $frm.ctlking
         }
      }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $frm
   }
   #--- Fonctionnalites d'une monture equatoriale allemande pilotee par AudeCom
   ::audecom::configEquatorialAudeCom
}

#
# confAudeComInactif
#    Permet de desactiver le bouton a l'arret de la monture
#
proc ::audecom::confAudeComInactif { } {
   variable private
   global caption

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { [ ::audecom::isReady ] == 1 } {
            #--- Boutons de la monture inactifs
            destroy $frm.ctlking
         }
      }
   }
}

#
# configEquatorialAudeCom
# Permet d'afficher les fonctionnalites d'une monture equatoriale allemande pilotee par AudeCom
#
proc ::audecom::configEquatorialAudeCom { } {
   variable private
   global audace caption conf

   if { [ info exists private(frm) ] } {
      set frm $private(frm)
      if { [ winfo exists $frm ] } {
         if { $private(german) == "1" } {
            #---
            destroy $frm.pos_tel
            destroy $frm.pos_tel_ew
            destroy $frm.pos_tel_est
            destroy $frm.chg_pos_tel
            #--- Position du telescope sur la monture equatoriale allemande : A l'est ou a l'ouest
            label $frm.pos_tel -text "$caption(audecom,position_telescope)"
            pack $frm.pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3
            #---
            label $frm.pos_tel_ew -width 15 -anchor w -textvariable audace(pos_tel_ew)
            pack $frm.pos_tel_ew -in $frm.frame19 -anchor center -side left
            #--- Nouvelle position d'origine du telescope : A l'est ou a l'ouest
            label $frm.pos_tel_est -text "$caption(audecom,change_position_telescope)"
            pack $frm.pos_tel_est -in $frm.frame19 -anchor center -side left -padx 10 -pady 3
            #---
            if { [ ::audecom::isReady ] == 1 } {
               button $frm.chg_pos_tel -relief raised -state normal -textvariable audace(chg_pos_tel) -command {
           ###       set pos_tel [ tel$::audecom::private(telNo) german ]
           ###       if { $pos_tel == "E" } {
           ###          tel$::audecom::private(telNo) german W
           ###       } elseif { $pos_tel == "W" } {
           ###          tel$::audecom::private(telNo) german E
           ###       }
           ###       ::telescope::monture_allemande
               }
               pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
            } else {
               button $frm.chg_pos_tel -text "  ?  " -relief raised -state disabled
               pack $frm.chg_pos_tel -in $frm.frame19 -anchor center -side left -padx 10 -pady 3 -ipadx 5 -ipady 5
            }
         } else {
            destroy $frm.pos_tel
            destroy $frm.pos_tel_ew
            destroy $frm.pos_tel_est
            destroy $frm.chg_pos_tel
         }
         #--- Mise a jour dynamique des couleurs
         ::confColor::applyColor $frm
      }
   }
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
proc ::audecom::getPluginProperty { propertyName } {
   variable private

   switch $propertyName {
      multiMount              { return 1 }
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
      hasPark                 { return 0 }
      hasUnpark               { return 0 }
      hasUpdateDate           { return 0 }
      backlash                { return 1 }
   }
}


## @file bdi_gui_config.tcl
#  @brief     GUI d&eacute;di&eacute;e &agrave; la gestion des configurations de bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_config.tcl]
#  @endcode

# $Id: bdi_gui_config.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_config
# @brief GUI d&eacute;di&eacute;e &agrave; la gestion des configurations de bddimages
# @pre Requiert le fichier d'internationalisation \c bdi_gui_config.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_config {

   package require bdi_tools_xml 1.0
   package require bddimagesAdmin 1.0

   global audace
   global bddconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_config.cap ]\""

}

#------------------------------------------------------------
## Creation de la GUI de gestion des configurations
#  @param this string pathName de la fenetre
#  @return void
#
proc ::bdi_gui_config::configuration { this } {

   variable This
   set This $this
   ::bdi_gui_config::createDialog

}

#------------------------------------------------------------
## Fermeture et destruction de la GUI
#  @return void
#
proc ::bdi_gui_config::fermer { } {

   variable This

   ::bdi_gui_cata_creation::closetoconf
   ::bdi_gui_config::recup_position
   ::bdi_gui_config::closetoconf
   
   destroy $This

}

proc ::bdi_gui_config::inittoconf { } {

   global conf

   if {! [info exists ::bdi_tools_astrometry::reports_astrom_mail] } {
      if {[info exists conf(bddimages,astrometry,reports,mail)]} {
         set ::bdi_tools_astrometry::reports_astrom_mail $conf(bddimages,astrometry,reports,mail)
      } else {
         set ::bdi_tools_astrometry::reports_astrom_mail ""
      }
   }
   if {! [info exists ::bdi_tools_astrometry::reports_photom_mail] } {
      if {[info exists conf(bddimages,photometry,reports,mail)]} {
         set ::bdi_tools_astrometry::reports_photom_mail $conf(bddimages,photometry,reports,mail)
      } else {
         set ::bdi_tools_astrometry::reports_photom_mail ""
      }
   }

}

proc ::bdi_gui_config::closetoconf { } {

   global conf

   set conf(bddimages,astrometry,reports,mail) $::bdi_tools_astrometry::reports_astrom_mail
   set conf(bddimages,photometry,reports,mail) $::bdi_tools_astrometry::reports_photom_mail
}

#------------------------------------------------------------
## Sauvegarde des config XML en cours d'edition, et chargement
# de la config courante (i.e. affichee).
#  @return void
#
proc ::bdi_gui_config::save_and_load { } {

   global bddconf

   # Sauve la config
   ::bdi_tools_config::save
   # Charge la coufig courante
   ::bdi_tools_config::load_config $bddconf(current_config)
   # Met a jour la GUI
   ::bdi_gui_config::handleBddState
   ::bddimages::handleBddState

}

#------------------------------------------------------------
## Configuration des boutons et autres widgets du panneau
# @return void
#
proc ::bdi_gui_config::handleBddState { } {

   global bddconf menuconfig

   $menuconfig delete 0 end

   foreach myconf $bddconf(list_config) {
      $menuconfig add radiobutton -label [lindex "$myconf" 1] -value [lindex "$myconf" 1] \
         -variable bddconf(current_config) \
         -command { set bddconf(current_config) [::bdi_tools_xml::load_config $bddconf(current_config)] }
   }

   ::bddimages::handleBddState

}

#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
#
proc ::bdi_gui_config::recup_position { } {

   variable This
   global conf bddconf

   set bddconf(geometry_config) [ wm geometry $This ]
   set conf(bddimages,geometry_config) $bddconf(geometry_config)

}

#------------------------------------------------------------
## Recuperation du nom d'un repertoire choisi par l'utilisateur
# @param path string repertoire de base
# @param title string titre a donner a la fenetre
# @return nom du repertoire selectionne ou une erreur (code 1)
#
proc ::bdi_gui_config::getDir { {path ""} {title ""} } {

   variable This
   global audace
   global caption

   # Defini un repertoire de base -> rep_images
   set initDir $audace(rep_images)
   if {[info exists path]} { set initDir $path }

   # Ouvre la fenetre de choix des repertoires
   set title [concat $caption(bdi_gui_config,getdir) $title]
   set workDir [tk_chooseDirectory -title $title -initialdir $initDir -parent $This]

   # Extraction et chargement du fichier
   if { $workDir != "" } {
     return $workDir
   } else {
     return -code error 
   }

}

#------------------------------------------------------------
## Affichage d'un message sur le format d'une saisie pour un 
# element de la structure de config XML de bddimages
# @param subject le sujet a documenter
# @return code 0
#
proc ::bdi_gui_config::GetInfo { subject } {

   global caption
   global voconf
   switch $subject {
      dbname      { set msg $caption(bdi_gui_config,info_dbname) }
      login       { set msg $caption(bdi_gui_config,info_login) }
      passwd      { set msg $caption(bdi_gui_config,info_passwd) }
      host        { set msg $caption(bdi_gui_config,info_host) }
      dir_base    { set msg $caption(bdi_gui_config,info_dirbase) }
      dir_inco    { set msg $caption(bdi_gui_config,info_dirinco) }
      dir_fits    { set msg $caption(bdi_gui_config,info_dirfits) }
      dir_cata    { set msg $caption(bdi_gui_config,info_dircata) }
      dir_err     { set msg $caption(bdi_gui_config,info_direrr) }
      dir_log     { set msg $caption(bdi_gui_config,info_dirlog) }
      dir_reports { set msg $caption(bdi_gui_config,info_dirreports) }
      dir_tmp     { set msg $caption(bdi_gui_config,info_dirtmp) }
      listlimit   { set msg $caption(bdi_gui_config,info_listlimit) }
   }
   tk_messageBox -title $caption(bdi_gui_config,info_title) -type ok -message $msg
   return -code 0

}

#------------------------------------------------------------
## Affichage d'une GUI pour saisir le nom d'une nouvelle config XML
# @return void
#
proc ::bdi_gui_config::new_config_name { } {

   variable This
   global caption bddconf menuconfig
   global new_config_name new_config_gui 

   set new_config_gui $This.configname
   if {[winfo exists $new_config_gui]} { destroy $new_config_gui }

   set new_geometry_xy [split $bddconf(geometry_config) "+"]
   set new_geometry "+[expr 50+[lindex $new_geometry_xy 1]]+[expr 50+[lindex $new_geometry_xy 2]]"
   toplevel $new_config_gui -class Toplevel
   wm geometry $new_config_gui $new_geometry
   wm resizable $new_config_gui 0 0
   wm title $new_config_gui "BddImages - Config name"
   wm protocol $new_config_gui WM_DELETE_WINDOW { destroy $configname }

   set f [frame $new_config_gui.f -borderwidth 0 -relief flat]
   pack $f -in $new_config_gui -anchor c -side top -expand 0 -fill x -padx 5 -pady 5

      label $f.lab -text "$caption(bdi_gui_config,configname)" 
      pack $f.lab -in $f -side top -anchor c -padx 5 -pady 5

      entry $f.name -textvariable new_config_name -borderwidth 1 -relief groove -width 25 -justify left
      pack $f.name -in $f -side top -anchor c -padx 5 -pady 5

   set b [frame $new_config_gui.b -borderwidth 0 -cursor arrow]
   pack $b -in $new_config_gui -anchor s -side bottom -expand 0 -fill x
      
      button $b.annuler -text "$caption(bdi_gui_config,cancel)" -borderwidth 2 \
       -command { destroy $new_config_gui }
      pack $b.annuler -in $b -side right -anchor e -padx 5 -pady 5 -expand 0

      button $b.ok -text "OK" -borderwidth 2 \
         -command {
            set previous_config $bddconf(current_config)
            if {[string length $new_config_name] > 0} {
               set new_config [::bdi_tools_xml::add_config $new_config_name]
               set bddconf(current_config) [::bdi_tools_xml::load_config $new_config]
               set bddconf(list_config) $::bdi_tools_xml::list_bddimages
               $menuconfig add radiobutton -label $bddconf(current_config) -value $bddconf(current_config) \
                  -variable bddconf(current_config) \
                  -command {
                     set ::bdi_tools_config::ok_mysql_connect 0
                     set bddconf(current_config) [::bdi_tools_xml::load_config $bddconf(current_config)]
                     ::bddimages::handleBddState
                  }
            }
            if {[string compare $previous_config "?"] == 0} {
               if {[catch {::bdi_tools_xml::delete_config $previous_config} new_config] == 0} {
                  $menuconfig delete $previous_config
               }
            }
            destroy $new_config_gui
         }
      pack $b.ok -in $b -side right -anchor e -padx 5 -pady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $new_config_gui
   #--- La fenetre est active
   focus $new_config_gui.f.name

}


#------------------------------------------------------------
## GUI de choix de la couleur pour l'affichage des catalogues
# @param color_cata string Couleur initiale
# @param button string pathName du bouton a colorer
# @return void
#
proc ::bdi_gui_config::choose_color { color_cata button } {

   upvar $color_cata color

   set new_color [tk_chooseColor -initialcolor $color -title "Choose color"]
   if {$new_color != ""} {
      set color $new_color
      $button configure -bg $color
   }
   
}


#------------------------------------------------------------
## Creation de la GUI de gestion des config de bddimages
# @return void
#
proc ::bdi_gui_config::createDialog { } {

   variable This

   global audace caption color
   global conf bddconf myconf
   global menuconfig

   set widthlab 30
   set widthentry 30

   #--- Initialisation des parametres
   ::bdi_gui_config::inittoconf
   ::bdi_gui_cata_creation::inittoconf 
   ::bdi_gui_astrometry::inittoconf

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_config) ] } {
      set conf(bddimages,geometry_config) "+100+100"
   }
   set bddconf(geometry_config) $conf(bddimages,geometry_config)

   #--- Declare la GUI
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This.buttons.but_fermer
      return
   }

   #--- GUI
   toplevel $This -class Toplevel
   wm geometry $This $bddconf(geometry_config)
   wm resizable $This 1 1
   wm title $This $caption(bdi_gui_config,main_title)
   wm protocol $This WM_DELETE_WINDOW { ::bdi_gui_config::fermer }

   #--- Cree un frame pour afficher les onglets
   set onglets [frame $This.onglets -borderwidth 0 -cursor arrow -relief groove]
   pack $onglets -in $This -side top -expand 1 -fill both -padx 5 -pady 5

      pack [ttk::notebook $onglets.list] -expand yes -fill both -padx 5 -pady 5

      set xml [frame $onglets.list.xml]
      pack $xml -in $onglets.list -expand yes -fill both 
      $onglets.list add $xml -text "$caption(bdi_gui_config,tab_xml)"
      
      set cata [frame $onglets.list.cata]
      pack $cata -in $onglets.list -expand yes -fill both 
      $onglets.list add $cata -text "$caption(bdi_gui_config,tab_cata)"

      set astrom [frame $onglets.list.astrom]
      pack $astrom -in $onglets.list -expand yes -fill both 
      $onglets.list add $astrom -text "$caption(bdi_gui_config,tab_astrom)"

      set reports [frame $onglets.list.reports]
      pack $reports -in $onglets.list -expand yes -fill both 
      $onglets.list add $reports -text "$caption(bdi_gui_config,tab_reports)"

      set others [frame $onglets.list.others]
      pack $others -in $onglets.list -expand yes -fill both 
      $onglets.list add $others -text "$caption(bdi_gui_config,tab_others)"

   #----------------------------------------------------------------------------
   #--- CONFIG XML
   #----------------------------------------------------------------------------

   #--- Cree un frame pour la liste des bddimages de l'utilisateur
   frame $xml.conf -borderwidth 1 -relief groove
   pack $xml.conf -in $xml -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

      #--- Cree un frame pour le titre et le menu deroulant
      frame $xml.conf.m -borderwidth 0 -relief solid
      pack $xml.conf.m -in $xml.conf -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

         #--- Cree un label pour le titre
         label $xml.conf.m.titre -text "$caption(bdi_gui_config,titleconfig)" -borderwidth 0 -relief flat
         pack $xml.conf.m.titre -in $xml.conf.m -side left -anchor w -padx 5 -pady 3

         #--- Cree un menu bouton pour choisir la config
         menubutton $xml.conf.m.menu -relief raised -borderwidth 2 -textvariable bddconf(current_config) -menu $xml.conf.m.menu.list
         pack $xml.conf.m.menu -in $xml.conf.m -side left -anchor w -padx 3 -pady 3
         set menuconfig [menu $xml.conf.m.menu.list -tearoff 0]
         foreach myconf $bddconf(list_config) {
            $menuconfig add radiobutton -label [lindex "$myconf" 1] -value [lindex "$myconf" 1] -variable bddconf(current_config) \
               -command {
                  set ::bdi_tools_config::ok_mysql_connect 0
                  set bddconf(current_config) [::bdi_tools_xml::load_config $bddconf(current_config)]
                  ::bddimages::handleBddState
               }
         }

      #--- Cree un frame pour les acces a la bdd
      frame $xml.bdd -borderwidth 1 -relief groove
      pack $xml.bdd -in $xml -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un label pour le titre
         label $xml.bdd.titre -text "$caption(bdi_gui_config,access)" -borderwidth 0 -relief flat
         pack $xml.bdd.titre -in $xml.bdd -side top -anchor w -padx 3 -pady 3
   
         #--- Cree un frame pour le nom de la BDD
         frame $xml.bdd.name -borderwidth 0 -relief solid
         pack $xml.bdd.name -in $xml.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $xml.bdd.name.lab -text "$caption(bdi_gui_config,dbname)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $xml.bdd.name.lab -in $xml.bdd.name -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.bdd.name.dat -textvariable bddconf(dbname) -borderwidth 1 -relief groove -width 25 -justify left 
            pack $xml.bdd.name.dat -in $xml.bdd.name -side left -anchor w -padx 1
            #--- Cree un bouton Create BDD
            button $xml.bdd.name.test -state active -relief groove -anchor c -width 4 -text "Create" \
              -command { ::bddimagesAdmin::RAZBdd }
            pack $xml.bdd.name.test -in $xml.bdd.name -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $xml.bdd.name.help -state active -relief groove -anchor c \
                 -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dbname" }
            pack $xml.bdd.name.help -in $xml.bdd.name -side left -anchor w -padx 1

         #--- Cree un frame pour le login
         frame $xml.bdd.login -borderwidth 0 -relief solid
         pack $xml.bdd.login -in $xml.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.bdd.login.lab -text "$caption(bdi_gui_config,login)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $xml.bdd.login.lab -in $xml.bdd.login -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.bdd.login.dat -textvariable bddconf(login) -borderwidth 1 -relief groove -width 25 -justify left
            pack $xml.bdd.login.dat -in $xml.bdd.login -side left -anchor w -padx 1
            #--- Cree un bouton vide
            button $xml.bdd.login.test -state disabled -relief flat -anchor c -width 4
            pack $xml.bdd.login.test -in $xml.bdd.login -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $xml.bdd.login.help -state active -relief groove -anchor c \
                 -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "login" }
            pack $xml.bdd.login.help -in $xml.bdd.login -side left -anchor w -padx 1

         #--- Cree un frame pour le mot de passe
         frame $xml.bdd.pass -borderwidth 0 -relief flat
         pack $xml.bdd.pass -in $xml.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.bdd.pass.lab -text "$caption(bdi_gui_config,pass)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $xml.bdd.pass.lab -in $xml.bdd.pass -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.bdd.pass.dat -textvariable bddconf(pass) -borderwidth 1 -relief groove -width 25 -justify left -show "*"
            pack $xml.bdd.pass.dat -in $xml.bdd.pass -side left -anchor w -padx 1
            #--- Cree un bouton vide
            button $xml.bdd.pass.test -state disabled -relief flat -anchor c -width 4
            pack $xml.bdd.pass.test -in $xml.bdd.pass -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $xml.bdd.pass.help -state active -relief groove -anchor c \
                 -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "passwd" }
            pack $xml.bdd.pass.help -in $xml.bdd.pass -side left -anchor w -padx 1

         #--- Cree un frame pour le serveur
         frame $xml.bdd.serv -borderwidth 0 -relief flat
         pack $xml.bdd.serv -in $xml.bdd -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.bdd.serv.lab -text "$caption(bdi_gui_config,server)" -width 30 -anchor w -borderwidth 0 -relief flat
            pack $xml.bdd.serv.lab -in $xml.bdd.serv -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.bdd.serv.dat -textvariable bddconf(server) -borderwidth 1 -relief groove -width 25 -justify left
            pack $xml.bdd.serv.dat -in $xml.bdd.serv -side left -anchor w -padx 1
            #--- Cree un bouton Test BDD
            button $xml.bdd.serv.test -state active -relief groove -anchor c -width 4 -text "Test" \
                 -command { set err [catch {::bddimagesAdmin::TestConnectBdd} status] }
            pack $xml.bdd.serv.test -in $xml.bdd.serv -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $xml.bdd.serv.help -state active -relief groove -anchor c \
                 -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "host" }
            pack $xml.bdd.serv.help -in $xml.bdd.serv -side left -anchor w -padx 1


      #--- Cree un frame pour les repertoires
      frame $xml.dir -borderwidth 1 -relief groove
      pack $xml.dir -in $xml -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un label pour le titre
         label $xml.dir.titre -text "$caption(bdi_gui_config,dir)" -borderwidth 0 -relief flat
         pack $xml.dir.titre -in $xml.dir -side top -anchor w -padx 3 -pady 3
   
         #--- Cree un frame pour le repertoire de base
         frame $xml.dir.dirbase -borderwidth 0 -relief flat
         pack $xml.dir.dirbase -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0

            #--- Cree un label
            label $xml.dir.dirbase.lab -text "$caption(bdi_gui_config,dirbase)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirbase.lab -in $xml.dir.dirbase -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirbase.dat -textvariable bddconf(dirbase) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirbase.dat -in $xml.dir.dirbase -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirbase.explore -text "..." -width 3 \
               -command {
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "de base"} wdir]} {
                     set bddconf(dirbase) $wdir 
                     ::bdi_tools_config::checkOtherDir $bddconf(dirbase)
                  }
               }
            pack $xml.dir.dirbase.explore -in $xml.dir.dirbase -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirbase.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_base" }
            pack $xml.dir.dirbase.help -in $xml.dir.dirbase -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire incoming
         frame $xml.dir.dirinco -borderwidth 0 -relief flat
         pack $xml.dir.dirinco -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dirinco.lab -text "$caption(bdi_gui_config,dirinco)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirinco.lab -in $xml.dir.dirinco -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirinco.dat -textvariable bddconf(dirinco) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirinco.dat -in $xml.dir.dirinco -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirinco.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "d'incoming"} wdir]} {
                     set bddconf(dirinco) $wdir
                  }
               }
            pack $xml.dir.dirinco.explore -in $xml.dir.dirinco -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirinco.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_inco" }
            pack $xml.dir.dirinco.help -in $xml.dir.dirinco -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire fits
         frame $xml.dir.dirfits -borderwidth 0 -relief flat
         pack $xml.dir.dirfits -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dirfits.lab -text "$caption(bdi_gui_config,dirfits)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirfits.lab -in $xml.dir.dirfits -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirfits.dat -textvariable bddconf(dirfits) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirfits.dat -in $xml.dir.dirfits -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirfits.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "des images FITS"} wdir]} {
                     set bddconf(dirfits) $wdir
                  }
               }
            pack $xml.dir.dirfits.explore -in $xml.dir.dirfits -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirfits.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_fits" }
            pack $xml.dir.dirfits.help -in $xml.dir.dirfits -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire cata
         frame $xml.dir.dircata -borderwidth 0 -relief flat
         pack $xml.dir.dircata -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dircata.lab -text "$caption(bdi_gui_config,dircata)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dircata.lab -in $xml.dir.dircata -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dircata.dat -textvariable bddconf(dircata) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dircata.dat -in $xml.dir.dircata -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dircata.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "des CATA"} wdir]} {
                     set bddconf(dircata) $wdir
                  }
               }
            pack $xml.dir.dircata.explore -in $xml.dir.dircata -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dircata.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_cata" }
            pack $xml.dir.dircata.help -in $xml.dir.dircata -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire d erreur
         frame $xml.dir.direrr -borderwidth 0 -relief flat
         pack $xml.dir.direrr -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.direrr.lab -text "$caption(bdi_gui_config,direrr)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.direrr.lab -in $xml.dir.direrr -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.direrr.dat -textvariable bddconf(direrr) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.direrr.dat -in $xml.dir.direrr -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.direrr.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "des erreurs"} wdir]} {
                     set bddconf(direrr) $wdir
                  }
               }
            pack $xml.dir.direrr.explore -in $xml.dir.direrr -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.direrr.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_err" }
            pack $xml.dir.direrr.help -in $xml.dir.direrr -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire de log
         frame $xml.dir.dirlog -borderwidth 0 -relief flat
         pack $xml.dir.dirlog -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dirlog.lab -text "$caption(bdi_gui_config,dirlog)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirlog.lab -in $xml.dir.dirlog -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirlog.dat -textvariable bddconf(dirlog) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirlog.dat -in $xml.dir.dirlog -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirlog.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "de log"} wdir]} {
                     set bddconf(dirlog) $wdir
                  }
               }
            pack $xml.dir.dirlog.explore -in $xml.dir.dirlog -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirlog.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_log" }
            pack $xml.dir.dirlog.help -in $xml.dir.dirlog -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire tmp
         frame $xml.dir.dirreports -borderwidth 0 -relief flat
         pack $xml.dir.dirreports -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dirreports.lab -text "$caption(bdi_gui_config,dirreports)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirreports.lab -in $xml.dir.dirreports -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirreports.dat -textvariable bddconf(dirreports) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirreports.dat -in $xml.dir.dirreports -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirreports.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "reports"} wdir]} {
                     set bddconf(dirreports) $wdir
                  }
               }
            pack $xml.dir.dirreports.explore -in $xml.dir.dirreports -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirreports.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_reports" }
            pack $xml.dir.dirreports.help -in $xml.dir.dirreports -side left -anchor w -padx 1

         #--- Cree un frame pour le repertoire tmp
         frame $xml.dir.dirtmp -borderwidth 0 -relief flat
         pack $xml.dir.dirtmp -in $xml.dir -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.dir.dirtmp.lab -text "$caption(bdi_gui_config,dirtmp)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.dir.dirtmp.lab -in $xml.dir.dirtmp -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.dir.dirtmp.dat -textvariable bddconf(dirtmp) -borderwidth 1 -relief groove -width $widthentry -justify left
            pack $xml.dir.dirtmp.dat -in $xml.dir.dirtmp -side left -anchor w -padx 1 -expand 1 -fill x
            #--- Cree un bouton charger
            button $xml.dir.dirtmp.explore -text "..." -width 3 \
               -command { 
                  if {! [catch {::bdi_gui_config::getDir $bddconf(dirbase) "temporaire"} wdir]} {
                     set bddconf(dirtmp) $wdir
                  }
               }
            pack $xml.dir.dirtmp.explore -in $xml.dir.dirtmp -side left -anchor c -fill x -padx 6
            #--- Cree un bouton info
            button $xml.dir.dirtmp.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "dir_tmp" }
            pack $xml.dir.dirtmp.help -in $xml.dir.dirtmp -side left -anchor w -padx 1

      #--- Cree un frame pour les variables
      frame $xml.var -borderwidth 1 -relief groove
      pack $xml.var -in $xml -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

         #--- Cree un label pour le titre
         label $xml.var.titre -text "$caption(bdi_gui_config,variables)" -borderwidth 0 -relief flat
         pack $xml.var.titre -in $xml.var -side top -anchor w -padx 3 -pady 3
   
         #--- Cree un frame pour la limite de liste
         frame $xml.var.lim -borderwidth 0 -relief flat
         pack $xml.var.lim -in $xml.var -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
            #--- Cree un label
            label $xml.var.lim.lab -text "$caption(bdi_gui_config,listlimit)" -width $widthlab -anchor w -borderwidth 0 -relief flat
            pack $xml.var.lim.lab -in $xml.var.lim -side left -anchor w -padx 1
            #--- Cree une ligne d'entree pour la variable
            entry $xml.var.lim.dat -textvariable bddconf(limit) -borderwidth 1 -relief groove -width 6 -justify left
            pack $xml.var.lim.dat -in $xml.var.lim -side left -anchor w -padx 1
            #--- Cree un bouton info
            button $xml.var.lim.help -state active -relief groove -anchor c \
                    -text "$caption(bdi_gui_config,info)" -command { ::bdi_gui_config::GetInfo "listlimit" }
            pack $xml.var.lim.help -in $xml.var.lim -side left -anchor w -padx 1

      #--- Cree un frame pour les boutons d'actions
      frame $xml.action -relief flat
      pack $xml.action -in $xml -anchor c -side top -expand 0 -padx 10 -pady 5

         #--- Cree un bouton pour ajouter une config
         button $xml.action.add -text "$caption(bdi_gui_config,add)" \
            -command { ::bdi_gui_config::new_config_name }
         pack $xml.action.add -in $xml.action -side left -anchor c -padx 3

         #--- Cree un bouton pour effacer la config courante
         button $xml.action.del -text "$caption(bdi_gui_config,delete)" \
            -command { 
               if {[catch {::bdi_tools_xml::delete_config $bddconf(current_config)} new_config] == 0} {
                  $menuconfig delete $bddconf(current_config)
                  set bddconf(current_config) [::bdi_tools_xml::load_config $new_config]
                  set bddconf(list_config) $::bdi_tools_xml::list_bddimages
               }
             }
         pack $xml.action.del -in $xml.action -side left -anchor c -padx 3

         #--- Cree un bouton pour sauver les configs
         button $xml.action.save -text "$caption(bdi_gui_config,save)" \
             -command { ::bdi_gui_config::save_and_load }
         pack $xml.action.save -in $xml.action -side left -anchor c -padx 3


   #----------------------------------------------------------------------------
   #--- CONFIG CATA
   #----------------------------------------------------------------------------

   #--- Cree un frame pour afficher les onglets
   set subonglets [frame $cata.onglets -borderwidth 0 -cursor arrow -relief groove]
   pack $subonglets -in $cata -side top -expand 1 -fill both -padx 5 -pady 5

      pack [ttk::notebook $subonglets.list] -expand yes -fill both -padx 5 -pady 5

      set conesearch [frame $subonglets.list.xml]
      pack $conesearch -in $subonglets.list -expand yes -fill both 
      $subonglets.list add $conesearch -text "Conesearch"
      
      set affichage [frame $subonglets.list.cata]
      pack $affichage -in $subonglets.list -expand yes -fill both 
      $subonglets.list add $affichage -text "Display"

      #--- Cree un frame pour la liste des cata
      set cataconftitre [frame $conesearch.titre -borderwidth 0 -relief groove]
      pack $cataconftitre -in $conesearch -anchor w -side top -expand 0 -fill x -padx 10 -pady 10
         label $cataconftitre.lab -text "$caption(bdi_gui_config,conesearchmsg)" -font $bddconf(font,arial_10_b)
         pack $cataconftitre.lab -in $cataconftitre -side top -fill x -anchor c -pady 10
   
      #--- Cree un frame pour la liste des cata
      set cataconf [frame $conesearch.conf -borderwidth 0 -relief groove]
      pack $cataconf -in $conesearch -anchor c -side top -expand 0 -padx 10 -pady 5
   
         checkbutton $cataconf.skybot_check -highlightthickness 0 -text "  SKYBOT" -variable ::tools_cata::use_skybot
            entry $cataconf.skybot_dir -relief sunken -textvariable ::tools_cata::catalog_skybot -width 50
         frame $cataconf.blank -height 15
         checkbutton $cataconf.usnoa2_check -highlightthickness 0 -text "  USNO-A2" -variable ::tools_cata::use_usnoa2 -state disabled
            entry $cataconf.usnoa2_dir -relief sunken -textvariable ::tools_cata::catalog_usnoa2 -width 50
         checkbutton $cataconf.gaia1_check -highlightthickness 0 -text "  GAIA1" -variable ::tools_cata::use_gaia
            entry $cataconf.gaia1_dir -relief sunken -textvariable ::tools_cata::catalog_gaia1 -width 50
         checkbutton $cataconf.tycho2_check -highlightthickness 0 -text "  TYCHO-2" -variable ::tools_cata::use_tycho2
            entry $cataconf.tycho2_dir -relief sunken -textvariable ::tools_cata::catalog_tycho2 -width 50
         checkbutton $cataconf.ucac2_check -highlightthickness 0 -text "  UCAC2" -variable ::tools_cata::use_ucac2
            entry $cataconf.ucac2_dir -relief sunken -textvariable ::tools_cata::catalog_ucac2 -width 50
         checkbutton $cataconf.ucac3_check -highlightthickness 0 -text "  UCAC3" -variable ::tools_cata::use_ucac3
            entry $cataconf.ucac3_dir -relief sunken -textvariable ::tools_cata::catalog_ucac3 -width 50
         checkbutton $cataconf.ucac4_check -highlightthickness 0 -text "  UCAC4" -variable ::tools_cata::use_ucac4
            entry $cataconf.ucac4_dir -relief sunken -textvariable ::tools_cata::catalog_ucac4 -width 50
         checkbutton $cataconf.ppmx_check -highlightthickness 0 -text "  PPMX" -variable ::tools_cata::use_ppmx
            entry $cataconf.ppmx_dir -relief sunken -textvariable ::tools_cata::catalog_ppmx -width 50
         checkbutton $cataconf.ppmxl_check -highlightthickness 0 -text "  PPMXL" -variable ::tools_cata::use_ppmxl
            entry $cataconf.ppmxl_dir -relief sunken -textvariable ::tools_cata::catalog_ppmxl -width 50
         checkbutton $cataconf.nomad1_check -highlightthickness 0 -text "  NOMAD1" -variable ::tools_cata::use_nomad1
            entry $cataconf.nomad1_dir -relief sunken -textvariable ::tools_cata::catalog_nomad1 -width 50
         checkbutton $cataconf.twomass_check -highlightthickness 0 -text "  2MASS" -variable ::tools_cata::use_2mass
            entry $cataconf.twomass_dir -relief sunken -textvariable ::tools_cata::catalog_2mass -width 50
         checkbutton $cataconf.wfibc_check -highlightthickness 0 -text "  WFIBC" -variable ::tools_cata::use_wfibc
            entry $cataconf.wfibc_dir -relief sunken -textvariable ::tools_cata::catalog_wfibc -width 50
         checkbutton $cataconf.sdss_check -highlightthickness 0 -text "  SDSS" -variable ::tools_cata::use_sdss
            entry $cataconf.sdss_dir -relief sunken -textvariable ::tools_cata::catalog_sdss -width 50
         checkbutton $cataconf.panstarrs_check -highlightthickness 0 -text "  PANSTARRS" -variable ::tools_cata::use_panstarrs
            entry $cataconf.panstarrs_dir -relief sunken -textvariable ::tools_cata::catalog_panstarrs -width 50

      grid $cataconf.skybot_check    $cataconf.skybot_dir    -sticky nsw -pady 3
      grid $cataconf.blank
      grid $cataconf.usnoa2_check    $cataconf.usnoa2_dir    -sticky nsw -pady 3
      grid $cataconf.gaia1_check     $cataconf.gaia1_dir     -sticky nsw -pady 3
      grid $cataconf.tycho2_check    $cataconf.tycho2_dir    -sticky nsw -pady 3
      grid $cataconf.ucac2_check     $cataconf.ucac2_dir     -sticky nsw -pady 3
      grid $cataconf.ucac3_check     $cataconf.ucac3_dir     -sticky nsw -pady 3
      grid $cataconf.ucac4_check     $cataconf.ucac4_dir     -sticky nsw -pady 3
      grid $cataconf.ppmx_check      $cataconf.ppmx_dir      -sticky nsw -pady 3
      grid $cataconf.ppmxl_check     $cataconf.ppmxl_dir     -sticky nsw -pady 3
      grid $cataconf.nomad1_check    $cataconf.nomad1_dir    -sticky nsw -pady 3
      grid $cataconf.twomass_check   $cataconf.twomass_dir   -sticky nsw -pady 3
      grid $cataconf.wfibc_check     $cataconf.wfibc_dir     -sticky nsw -pady 3
      grid $cataconf.sdss_check      $cataconf.sdss_dir      -sticky nsw -pady 3
      grid $cataconf.panstarrs_check $cataconf.panstarrs_dir -sticky nsw -pady 3
      grid columnconfigure $cataconf 0 -pad 30

      #--- Cree un frame pour la liste des cata
      set catafftitre [frame $affichage.titre -borderwidth 0 -relief groove]
      pack $catafftitre -in $affichage -anchor w -side top -expand 0 -fill x -padx 10 -pady 10
         label $catafftitre.lab -text "$caption(bdi_gui_config,dispcatamsg)" -font $bddconf(font,arial_10_b)
         pack $catafftitre.lab -in $catafftitre -side top -fill x -anchor c -pady 10

      #--- Cree un frame pour la liste des cata
      set cataff [frame $affichage.conf -borderwidth 0 -relief groove]
      pack $cataff -in $affichage -anchor c -side top -expand 0 -padx 10 -pady 5
   
         label $cataff.img_lab -text "* IMG"
            button $cataff.img_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_img \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_img $cataff.img_color"
            spinbox $cataff.img_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_img -width 3
            $cataff.img_radius set $::bdi_gui_cata::size_img_sav
         label $cataff.astroid_lab -text "* ASTROID"
            button $cataff.astroid_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_astroid \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_astroid $cataff.astroid_color"
            spinbox $cataff.astroid_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_astroid -width 3
            $cataff.astroid_radius set $::bdi_gui_cata::size_astroid_sav
         label $cataff.skybot_lab -text "* SKYBOT"
            button $cataff.skybot_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_skybot \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_skybot $cataff.skybot_color"
            spinbox $cataff.skybot_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_skybot -width 3
            $cataff.skybot_radius set $::bdi_gui_cata::size_skybot_sav
         label $cataff.usnoa2_lab -text "* USNOA2"
            button $cataff.usnoa2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_usnoa2 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_usnoa2 $cataff.usnoa2_color"
            spinbox $cataff.usnoa2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_usnoa2 -width 3
            $cataff.usnoa2_radius set $::bdi_gui_cata::size_usnoa2_sav
         label $cataff.tycho2_lab -text "* TYCHO-2"
            button $cataff.tycho2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_tycho2 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_tycho2 $cataff.tycho2_color"
            spinbox $cataff.tycho2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_tycho2 -width 3
            $cataff.tycho2_radius set $::bdi_gui_cata::size_tycho2_sav
         label $cataff.ucac2_lab -text "* UCAC2"
            button $cataff.ucac2_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac2 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_ucac2 $cataff.ucac2_color"
            spinbox $cataff.ucac2_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac2 -width 3
            $cataff.ucac2_radius set $::bdi_gui_cata::size_ucac2_sav
         label $cataff.ucac3_lab -text "* UCAC3"
            button $cataff.ucac3_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac3 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_ucac3 $cataff.ucac3_color"
            spinbox $cataff.ucac3_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac3 -width 3
            $cataff.ucac3_radius set $::bdi_gui_cata::size_ucac3_sav
         label $cataff.ucac4_lab -text "* UCAC4"
            button $cataff.ucac4_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ucac4 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_ucac4 $cataff.ucac4_color"
            spinbox $cataff.ucac4_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac4 -width 3
            $cataff.ucac4_radius set $::bdi_gui_cata::size_ucac4_sav
         label $cataff.ppmx_lab -text "* PPMX"
            button $cataff.ppmx_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ppmx \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_ppmx $cataff.ppmx_color"
            spinbox $cataff.ppmx_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ppmx -width 3
            $cataff.ppmx_radius set $::bdi_gui_cata::size_ppmx_sav
         label $cataff.ppmxl_lab -text "* PPMXL"
            button $cataff.ppmxl_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_ppmxl \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_ppmxl $cataff.ppmxl_color"
            spinbox $cataff.ppmxl_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ppmxl -width 3
            $cataff.ppmxl_radius set $::bdi_gui_cata::size_ppmxl_sav
         label $cataff.nomad1_lab -text "* NOMAD1"
            button $cataff.nomad1_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_nomad1 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_nomad1 $cataff.nomad1_color"
            spinbox $cataff.nomad1_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_nomad1 -width 3
            $cataff.nomad1_radius set $::bdi_gui_cata::size_nomad1_sav
         label $cataff.2mass_lab -text "* 2MASS"
            button $cataff.2mass_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_2mass \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_2mass $cataff.2mass_color"
            spinbox $cataff.2mass_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_2mass -width 3
            $cataff.2mass_radius set $::bdi_gui_cata::size_2mass_sav
         label $cataff.wfibc_lab -text "* WFIBC"
            button $cataff.wfibc_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_wfibc \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_wfibc $cataff.wfibc_color"
            spinbox $cataff.wfibc_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_wfibc -width 3
            $cataff.wfibc_radius set $::bdi_gui_cata::size_wfibc_sav
         label $cataff.gaia1_lab -text "* GAIA1"
            button $cataff.gaia1_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_gaia1 \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_gaia1 $cataff.gaia1_color"
            spinbox $cataff.gaia1_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_gaia1 -width 3
            $cataff.gaia1_radius set $::bdi_gui_cata::size_gaia1_sav
         label $cataff.sdss_lab -text "* SDSS"
            button $cataff.sdss_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_sdss \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_sdss $cataff.sdss_color"
            spinbox $cataff.sdss_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_sdss -width 3
            $cataff.sdss_radius set $::bdi_gui_cata::size_sdss_sav
         label $cataff.panstarrs_lab -text "* PANSTARRS"
            button $cataff.panstarrs_color -borderwidth 1 -relief groove -width 5 -bg $::bdi_gui_cata::color_panstarrs \
               -command "::bdi_gui_config::choose_color ::bdi_gui_cata::color_panstarrs $cataff.panstarrs_color"
            spinbox $cataff.panstarrs_radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_panstarrs -width 3
            $cataff.panstarrs_radius set $::bdi_gui_cata::size_panstarrs_sav

         frame $cataff.blank -width 15 -height 15

      grid $cataff.skybot_lab  $cataff.skybot_color  $cataff.skybot_radius $cataff.astroid_lab $cataff.astroid_color $cataff.astroid_radius       -sticky nsw -pady 1
      grid $cataff.blank
      grid $cataff.img_lab     $cataff.img_color     $cataff.img_radius    $cataff.usnoa2_lab    $cataff.usnoa2_color    $cataff.usnoa2_radius    -sticky nsw -pady 1
      grid $cataff.tycho2_lab  $cataff.tycho2_color  $cataff.tycho2_radius $cataff.ucac3_lab     $cataff.ucac3_color     $cataff.ucac3_radius     -sticky nsw -pady 1
      grid $cataff.ucac2_lab   $cataff.ucac2_color   $cataff.ucac2_radius  $cataff.ucac4_lab     $cataff.ucac4_color     $cataff.ucac4_radius     -sticky nsw -pady 1
      grid $cataff.ppmx_lab    $cataff.ppmx_color    $cataff.ppmx_radius   $cataff.ppmxl_lab     $cataff.ppmxl_color     $cataff.ppmxl_radius     -sticky nsw -pady 1
      grid $cataff.nomad1_lab  $cataff.nomad1_color  $cataff.nomad1_radius $cataff.2mass_lab     $cataff.2mass_color     $cataff.2mass_radius     -sticky nsw -pady 1
      grid $cataff.wfibc_lab   $cataff.wfibc_color   $cataff.wfibc_radius  $cataff.gaia1_lab     $cataff.gaia1_color     $cataff.gaia1_radius     -sticky nsw -pady 1
      grid $cataff.sdss_lab    $cataff.sdss_color    $cataff.sdss_radius   $cataff.panstarrs_lab $cataff.panstarrs_color $cataff.panstarrs_radius -sticky nsw -pady 1

      grid columnconfigure $cataff 0 -pad 20
      grid columnconfigure $cataff 1 -pad 10
      grid columnconfigure $cataff 2 -pad 10
      grid columnconfigure $cataff 3 -pad 20
      grid columnconfigure $cataff 4 -pad 10
      grid columnconfigure $cataff 5 -pad 10
      grid columnconfigure $cataff 6 -pad 10
      grid columnconfigure $cataff 7 -pad 10


   #----------------------------------------------------------------------------
   #--- CONFIG ASTROMETRIE
   #----------------------------------------------------------------------------

   #--- Cree un frame pour la liste des bddimages de l'utilisateur
   frame $astrom.conf -borderwidth 0 -relief groove
   pack $astrom.conf -in $astrom -anchor w -side top -expand 0 -fill x -padx 10 -pady 10

      #--- Cree un label pour le titre
      label $astrom.conf.titre -text "$caption(bdi_gui_config,titleastrom)" -font $bddconf(font,arial_10_b)
      pack $astrom.conf.titre -in $astrom.conf -side top -anchor c -padx 10 -pady 5

      #--- Cree un frame pour le titre et le menu deroulant
      set gril [frame $astrom.conf.param -borderwidth 0 -relief solid]
      pack $gril -in $astrom.conf -anchor c -side top -expand 0 -padx 10 -pady 5

         label $gril.lab1 -text "$caption(bdi_gui_config,ephemcc)"
         entry $gril.val1 -relief sunken -textvariable ::bdi_tools_astrometry::imcce_ephemcc

         label $gril.lab2 -text "$caption(bdi_gui_config,ephemccopts)"
         entry $gril.val2 -relief sunken -textvariable ::bdi_tools_astrometry::ephemcc_options

         label $gril.lab3 -text "$caption(bdi_gui_config,ifortlib)"
         entry $gril.val3 -relief sunken -textvariable ::bdi_tools_astrometry::ifortlib

         label $gril.lab4 -text "$caption(bdi_gui_config,locallib)" 
         entry $gril.val4 -relief sunken -textvariable ::bdi_tools_astrometry::locallib

         label $gril.lab5 -text "$caption(bdi_gui_config,thunderbird)"
         entry $gril.val5 -relief sunken -textvariable ::sendmail::thunderbird

      grid $gril.lab1  $gril.val1 -sticky nse -pady 5
      grid $gril.lab2  $gril.val2 -sticky nse -pady 5
      grid $gril.lab5  $gril.val5 -sticky nse -pady 5
      grid $gril.lab3  $gril.val3 -sticky nse -pady 5
      grid $gril.lab4  $gril.val4 -sticky nse -pady 5
      grid columnconfigure $gril 1 -pad 20

   #----------------------------------------------------------------------------
   #--- CONFIG Soumission des rapports
   #----------------------------------------------------------------------------

   #--- Cree un frame pour la liste des bddimages de l'utilisateur
   frame $reports.conf -borderwidth 0 -relief groove
   pack $reports.conf -in $reports -anchor w -side top -expand 0 -fill x -padx 10 -pady 10

      #--- Cree un label pour le titre
      label $reports.conf.reportsastrom -text "$caption(bdi_gui_config,titlereportsastrom)" -font $bddconf(font,arial_10_b)
      pack $reports.conf.reportsastrom -in $reports.conf -side top -anchor c -padx 10 -pady 5

      #--- Cree un frame pour le titre et le menu deroulant
      set gril [frame $reports.conf.astrom -borderwidth 0 -relief solid]
      pack $gril -in $reports.conf -anchor c -side top -expand 0 -padx 10 -pady 5

         entry $gril.val1 -relief sunken -textvariable ::bdi_tools_astrometry::reports_astrom_mail -width 60

      grid $gril.val1   -sticky nse -pady 5
      grid columnconfigure $gril 1 -pad 20

      #--- Cree un label pour le titre
      label $reports.conf.reportsphotom -text "$caption(bdi_gui_config,titlereportsphotom)" -font $bddconf(font,arial_10_b)
      pack $reports.conf.reportsphotom -in $reports.conf -side top -anchor c -padx 10 -pady 5

      #--- Cree un frame pour le titre et le menu deroulant
      set gril [frame $reports.conf.photom -borderwidth 0 -relief solid]
      pack $gril -in $reports.conf -anchor c -side top -expand 0 -padx 10 -pady 5

         entry $gril.val1 -relief sunken -textvariable ::bdi_tools_astrometry::reports_photom_mail -width 60

      grid $gril.val1   -sticky nse -pady 5
      grid columnconfigure $gril 1 -pad 20


   #----------------------------------------------------------------------------
   #--- CONFIG ?
   #----------------------------------------------------------------------------



   #----------------------------------------------------------------------------
   #--- PIED DE FEN
   #----------------------------------------------------------------------------

   #--- Cree un frame pour y mettre les boutons
   frame $This.buttons \
      -borderwidth 0 -cursor arrow
   pack $This.buttons \
      -in $This -anchor s -side bottom -expand 0 -fill x

     #--- Creation du bouton Fermer
     button $This.buttons.but_fermer -text "$caption(bdi_gui_config,fermer)" -borderwidth 2 \
        -command { ::bdi_gui_config::fermer }
     pack $This.buttons.but_fermer -in $This.buttons -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

     #--- Creation du bouton aide
     button $This.buttons.but_aide -text "$caption(bdi_gui_config,aide)" -borderwidth 2 \
        -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
     pack $This.buttons.but_aide -in $This.buttons -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs et fontes
   ::confColor::applyColor $This

}

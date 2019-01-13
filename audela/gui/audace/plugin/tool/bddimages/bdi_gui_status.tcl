## @file bdi_gui_status.tcl
#  @brief     M&eacute;thodes d'affichage du statut, de r&eacute;initialisation et de v&eacute;rification des bdd de bddimages
#  @author    Frederic Vachier and Jerome Berthier 
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_status.tcl]
#  @endcode

# $Id: bdi_gui_status.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_status
# @brief M&eacute;thodes d'affichage du statut, de r&eacute;initialisation et de v&eacute;rification des bdd de bddimages
# @pre Requiert bdi_tools_xml 1.0 et bddimagesAdmin 1.0
# @pre Requiert le fichier d'internationalisation \c bdi_gui_status.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_status {
   
   package require bdi_tools_xml 1.0
   package require bddimagesAdmin 1.0

   global audace
   global bddconf

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_status.cap ]\""

}

#------------------------------------------------------------
## Creation de la GUI de statut
# @param this string pathName de la fenetre
# @return void
proc ::bdi_gui_status::run { this } {

   variable This
   set This $this
   ::bdi_gui_status::createDialog

}

#------------------------------------------------------------
## Fermeture de la GUI de statut
# @return void
#
proc ::bdi_gui_status::fermer { } {

   variable This
   global conf

   set conf(bddimages,verif_repair_dir) $::bdi_tools_status::repair_dir 
   ::bdi_gui_status::recup_position
   destroy $This

}

#------------------------------------------------------------
## Fermeture et lancement de la GUI de statut
# @return void
#
proc ::bdi_gui_status::restart { } {

   variable This

   ::bdi_gui_status::recup_position
   destroy $This
   ::bdi_gui_status::run $This

}

#------------------------------------------------------------
## Recuperation de la position de la GUI de statut
# @return void
#
proc ::bdi_gui_status::recup_position { } {

   variable This
   global conf bddconf

   set bddconf(geometry_status) [ wm geometry $This ]
   set conf(bddimages,geometry_status) $bddconf(geometry_status)
   return
}


#------------------------------------------------------------
## Creation et affichage de la GUI
# @return void
#
proc ::bdi_gui_status::createDialog { } {

   variable This
   global audace caption color
   global conf bddconf

   #--- initConf
   if { ! [info exists conf(bddimages,geometry_status)] } { set conf(bddimages,geometry_status) "+100+100" }
   set bddconf(geometry_status) $conf(bddimages,geometry_status)

   if { ! [info exists conf(bddimages,verif_repair_dir)] } { set conf(bddimages,verif_repair_dir) $bddconf(dirinco) }
   set bddconf(verif_repair_dir) $conf(bddimages,verif_repair_dir)
   set ::bdi_tools_status::repair_dir $conf(bddimages,verif_repair_dir)

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This.frame11.but_fermer
      return
   }

   #---
   if { [ info exists bddconf(geometry_status) ] } {
      set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
      set fin [ string length $bddconf(geometry_status) ]
      set bddconf(position_status) "+[ string range $bddconf(geometry_status) $deb $fin ]"
   }

   #--- Mise en forme du resultat
   set errconn   [catch {::bddimages_sql::connect} connectstatus]
   if {$errconn != 0} {
      gren_erreur "Erreur de connexion a la bdd:  errconn = $errconn\n"
      gren_erreur "  Status: $connectstatus\n"
   }

   set nbimg       [::bddimagesAdmin::sql_nbimg]
   set nbheader    [::bddimagesAdmin::sql_header]
   set nbemptyhead [::bddimagesAdmin::sql_empty_header]
   set nbfichbdd   [numberoffile $bddconf(dirfits)]
   set nbfichinc   [numberoffile $bddconf(dirinco)]
   set nbficherr   [numberoffile $bddconf(direrr)]
   set erreur 0

   #--- Gestion des erreurs
   if { $erreur == "0"} {

      #---
      toplevel $This -class Toplevel
      wm geometry $This $bddconf(geometry_status)
      wm resizable $This 1 1
      wm title $This $caption(bdi_status,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::bdi_gui_status::fermer }

      #--- Cree un frame pour afficher le status de la base
      frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $This.frame1.titre -font $bddconf(font,arial_14_b) -text "$caption(bdi_status,titre)"
        pack $This.frame1.titre -in $This.frame1 -side top -padx 3 -pady 3

        #--- Cree un frame pour afficher les resultats
        frame $This.frame1.status -borderwidth 1 -relief raised -cursor arrow
        pack $This.frame1.status -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

        #--- Cree un label pour le status
        label $This.frame1.statusbdd -font $bddconf(font,arial_12_b) -text "$caption(bdi_status,label_bdd)"
        pack $This.frame1.statusbdd -in $This.frame1.status -side top -padx 3 -pady 1 -anchor w

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $This.frame1.status.l -borderwidth 0]
          pack $intitle -in $This.frame1.status -side left

            #--- Cree un label pour le status
            label $intitle.ok -font $bddconf(font,courier_10) -padx 3 -text "$caption(bdi_status,label_connect)"
            pack $intitle.ok -in $intitle -side top -padx 3 -pady 1 -anchor w
            #--- Cree un label pour le nb d image
            label $intitle.nbimg -font $bddconf(font,courier_10) -text "$caption(bdi_status,label_nbimg)"
            pack $intitle.nbimg -in $intitle -side top -padx 3 -pady 1 -anchor w
            #--- Cree un label pour le nb de header
            label $intitle.header -font $bddconf(font,courier_10) -text "$caption(bdi_status,label_nbheader)"
            pack $intitle.header -in $intitle -side top -padx 3 -pady 1 -anchor w
            #--- Cree un label pour le nb de header vide
            label $intitle.emptyheader -font $bddconf(font,courier_10) -text "$caption(bdi_status,label_nbemptyheader)"
            pack $intitle.emptyheader -in $intitle -side top -padx 3 -pady 1 -anchor w

          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $This.frame1.status.v -borderwidth 0]
          pack $inparam -in $This.frame1.status -side right -expand 1 -fill x

            #--- Cree un label pour le status
            label $inparam.ok -text $connectstatus -fg "#007f00"
            if {$errconn != 0} { $inparam.ok configure -fg $color(red) }
            pack $inparam.ok -in $inparam -side top -pady 1 -anchor w
            #--- Cree un label pour le nb image
            label $inparam.nbimg -text $nbimg -fg $color(blue)
            pack $inparam.nbimg -in $inparam -side top -pady 1 -anchor w
            #--- Cree un label pour le nb de header
            label $inparam.dm -text $nbheader -fg $color(blue)
            pack $inparam.dm -in $inparam -side top -pady 1 -anchor w
            #--- Cree un label pour le nb de header vide
            label $inparam.de -text $nbemptyhead -fg $color(blue)
            pack $inparam.de -in $inparam -side top -pady 1 -anchor w
            #button $inparam.db -text "Correction" -command ""

        #--- Cree un frame pour le status des repertoires
        frame $This.frame1.rep -borderwidth 1 -relief raised -cursor arrow
        pack $This.frame1.rep -in $This.frame1 -side top -expand 0 -fill x -padx 1 -pady 1

        #--- Cree un label pour le status des repertoires
        label $This.frame1.statusrep -font $bddconf(font,arial_12_b) -text "$caption(bdi_status,label_rep)"
        pack $This.frame1.statusrep -in $This.frame1.rep -side top -padx 3 -pady 1 -anchor w

          #--- Cree un frame pour afficher les intitules
          set intitle [frame $This.frame1.rep.l -borderwidth 0]
          pack $intitle -in $This.frame1.rep -side left

            #--- Cree un label pour le status
            label $intitle.nbimgrep -font $bddconf(font,courier_10) \
                  -text "$caption(bdi_status,label_nbimgrep)" -anchor center
            pack $intitle.nbimgrep -in $intitle -side top -padx 3 -pady 1 -anchor center

            label $intitle.nbimginco -font $bddconf(font,courier_10) \
                  -text "$caption(bdi_status,label_nbimginc)" -anchor center
            pack $intitle.nbimginco -in $intitle -side top -padx 3 -pady 1 -anchor center

            label $intitle.nbimgerr -font $bddconf(font,courier_10) \
                  -text "$caption(bdi_status,label_nbimgerr)" -anchor center
            pack $intitle.nbimgerr -in $intitle -side top -padx 3 -pady 1 -anchor center

          #--- Cree un frame pour afficher les valeurs
          set inparam [frame $This.frame1.rep.v -borderwidth 0]
          pack $inparam -in $This.frame1.rep -side right -expand 1 -fill x

            #--- Cree un label pour le status
            label $inparam.nbimgrep -text $nbfichbdd -fg "#007f00"
            if {$nbfichbdd != $nbimg} { $inparam.nbimgrep configure -fg $color(red) }
            pack $inparam.nbimgrep -in $inparam -side top -pady 1 -anchor w

            label $inparam.nbimginco -text $nbfichinc -fg $color(blue)
            pack $inparam.nbimginco -in $inparam -side top -pady 1 -anchor w

            label $inparam.nbimgerr -text $nbficherr -fg $color(blue)
            pack $inparam.nbimgerr -in $inparam -side top -pady 1 -anchor w

      #--- Cree un frame pour y mettre les boutons
      frame $This.frame11 -borderwidth 0 -cursor arrow
      pack $This.frame11 -in $This -anchor s -side bottom -expand 0 -fill x

        #--- Creation du bouton fermer
        button $This.frame11.but_fermer -text "$caption(bdi_status,fermer)" -borderwidth 2 -command { ::bdi_gui_status::fermer }
        pack $This.frame11.but_fermer -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton aide
        button $This.frame11.but_aide \
           -text "$caption(bdi_status,aide)" -borderwidth 2 -command { ::audace::showHelpPlugin tool bddimages bddimages.htm }
        pack $This.frame11.but_aide -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton refresh
        button $This.frame11.but_refresh \
           -text "$caption(bdi_status,refresh)" -borderwidth 2 -command { ::bdi_gui_status::restart }
        pack $This.frame11.but_refresh -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton Verifier
        button $This.frame11.but_connect -text "$caption(bdi_status,verif)" -borderwidth 2 -command { ::bdi_gui_status::verif }
        pack $This.frame11.but_connect -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton RAZ
        button $This.frame11.but_raz -text "$caption(bdi_status,raz)" -borderwidth 2 \
           -command { 
              ::bddimagesAdmin::RAZBdd 
              ::bdi_gui_status::restart
           }
        pack $This.frame11.but_raz -in $This.frame11 -side right -anchor e -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   } else {

      tk_messageBox -title $caption(bdi_status,msg_erreur) -type ok -message $caption(bdi_status,msg_prevent2)
      return

   }

   #--- La fenetre est active
   focus $This
   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   $This.frame1.titre             configure -font $bddconf(font,arial_14_b)
   $This.frame1.statusbdd         configure -font $bddconf(font,arial_12_b)
   $This.frame1.status.l.ok       configure -font $bddconf(font,courier_10)
   $This.frame1.status.l.nbimg    configure -font $bddconf(font,courier_10)
   $This.frame1.status.l.header   configure -font $bddconf(font,courier_10)
   $This.frame1.status.l.emptyheader configure -font $bddconf(font,courier_10)
   $This.frame1.status.v.ok       configure -fg "#007f00"
   if {$errconn != 0} {
      $This.frame1.status.v.ok    configure -fg $color(red)
   }
   $This.frame1.status.v.nbimg    configure -fg $color(blue)
   $This.frame1.status.v.dm       configure -fg $color(blue)
   $This.frame1.status.v.de       configure -fg $color(blue)
   $This.frame1.statusrep         configure -font $bddconf(font,arial_12_b)
   $This.frame1.rep.l.nbimgrep    configure -font $bddconf(font,courier_10)
   $This.frame1.rep.l.nbimginco   configure -font $bddconf(font,courier_10)
   $This.frame1.rep.l.nbimgerr    configure -font $bddconf(font,courier_10)
   $This.frame1.rep.v.nbimgrep    configure -fg "#007f00"
   if {$nbfichbdd != $nbimg} {
      $This.frame1.rep.v.nbimgrep configure -fg $color(red)
   }
   $This.frame1.rep.v.nbimginco   configure -fg $color(blue)
   $This.frame1.rep.v.nbimgerr    configure -fg $color(blue)

}


#------------------------------------------------------------
## Retourne la liste des doublons d'une liste
# @param l list Liste a analyser
# @return Liste fournissant les doublons et le nombre d'occurences
#
proc ::bdi_gui_status::list_doublons {l} {

   set l1 [lsort -ascii -unique $l]
   array set lar {}

   foreach elem $l1 {
      set idx [lsearch -all -exact -sorted $l $elem]
      set nb [llength $idx]
      if {$nb > 1} {
         array set lar [list $elem $nb]
      }
  }

   set lres {}
   foreach {elem nb} [array get lar] {
      lappend lres [list $elem $nb]
   }
   
   return $lres

}





#------------------------------------------------------------
## Creation et affichage de la GUI de verification
# @return void
#
proc ::bdi_gui_status::verif { } {

   variable This
   global audace caption color
   global maliste bddconf
   global reportConsole
   global repar
   global bddconf
   global dbname
   
   set dbname $bddconf(dbname)
   
   set reportConsole $This.verifreport
   if { [ winfo exists $reportConsole ] } {
      destroy $reportConsole
   }

   # Position de la fenetre
   set win_position "+100+50"
   if { [ info exists bddconf(geometry_status) ] } {
      set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
      set fin [ string length $bddconf(geometry_status) ]
      set win_position "+[ string range $bddconf(geometry_status) $deb $fin ]"
   }
   # Taille de la fenetre
   set win_position "680x500$win_position"

   toplevel $reportConsole -class Toplevel
   wm geometry $reportConsole $win_position
   wm resizable $reportConsole 1 1
   wm title $reportConsole "BddImages - Console"
   wm protocol $reportConsole WM_DELETE_WINDOW { destroy $reportConsole }

   text $reportConsole.text -height 15 -width 80 -yscrollcommand "$reportConsole.scroll set"
   scrollbar $reportConsole.scroll -command "$reportConsole.text yview"
   pack $reportConsole.scroll -side right -fill y
   pack $reportConsole.text -expand yes -fill both

   #--- Frame des boutons
   frame $reportConsole.config -borderwidth 1 -relief groove
   pack $reportConsole.config -side top -fill x

      # Bouton repare
      button $reportConsole.config.go -state active -text "Go" -relief "raised" -command "::bdi_tools_verif::verif_all GUI"
      pack $reportConsole.config.go -in $reportConsole.config -side left -anchor center -fill none -padx 3 -ipadx 2 -ipady 1
      checkbutton $reportConsole.config.repar -highlightthickness 0 -text "$caption(bdi_status,reparer)" -variable repar
      pack $reportConsole.config.repar -in $reportConsole.config -side left -anchor center -fill none -padx 3 -ipadx 2 -ipady 1

      # Bouton Fermer
      button $reportConsole.config.fermer -text "$caption(bdi_status,fermer)" -borderwidth 2 -command "destroy $reportConsole"
      pack $reportConsole.config.fermer -in $reportConsole.config -side right -anchor center -fill none -padx 5 -ipadx 2 -ipady 1


   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $reportConsole
   $reportConsole.text configure -background white -font $bddconf(font,courier_10)

   $reportConsole.text tag configure BODY    -foreground black -background white
   $reportConsole.text tag configure TITLE   -foreground "#808080" -justify center -font [ list {Arial} 12 bold ]
   $reportConsole.text tag configure H1      -justify left -font [ list {Arial} 10 normal ]
   $reportConsole.text tag configure H2      -justify left -font $bddconf(font,courier_10) -foreground $color(blue) 
   $reportConsole.text tag configure H3      -justify left -font $bddconf(font,courier_10) -foreground $color(green) 
   $reportConsole.text tag configure LISTE0  -foreground $color(black) -lmargin1 20
   $reportConsole.text tag configure LISTE1  -foreground $color(red) -lmargin1 30 
   $reportConsole.text tag configure GREEN   -foreground $color(green)
   $reportConsole.text tag configure RED     -foreground $color(red)
   $reportConsole.text tag configure OK      -foreground $color(green) -lmargin1 20
   $reportConsole.text tag configure ERROR   -foreground $color(red) -lmargin1 20
   $reportConsole.text tag configure ACT0    -foreground $color(black) -lmargin1 10
   $reportConsole.text tag configure ACT1    -foreground $color(black) -lmargin1 15
   $reportConsole.text tag configure ACTERR  -foreground $color(red) -lmargin1 15
   
}


##------------------------------------------------------------
### Creation et affichage de la GUI de verification
## @return void
##
#proc ::bdi_gui_status::verif_obsolete { } {
#
#   variable This
#   global audace caption color
#   global maliste bddconf reportConsole
#   global verifConsole
#
#   set reportConsole $This.verifreport
#   if { [ winfo exists $reportConsole ] } {
#      destroy $reportConsole
#   }
#
#   # Position de la fenetre
#   set win_position "+100+50"
#   if { [ info exists bddconf(geometry_status) ] } {
#      set deb [ expr 1 + [ string first + $bddconf(geometry_status) ] ]
#      set fin [ string length $bddconf(geometry_status) ]
#      set win_position "+[ string range $bddconf(geometry_status) $deb $fin ]"
#   }
#   # Taille de la fenetre
#   set win_position "680x500$win_position"
#
#   toplevel $reportConsole -class Toplevel
#   wm geometry $reportConsole $win_position
#   wm resizable $reportConsole 1 1
#   wm title $reportConsole "BddImages - Console"
#   wm protocol $reportConsole WM_DELETE_WINDOW { destroy $reportConsole }
#
#   text $reportConsole.text -height 15 -width 80 -yscrollcommand "$reportConsole.scroll set"
#   scrollbar $reportConsole.scroll -command "$reportConsole.text yview"
#   pack $reportConsole.scroll -side right -fill y
#   pack $reportConsole.text -expand yes -fill both
#
#   #--- Frame des boutons
#   frame $reportConsole.pied -borderwidth 1 -relief groove
#   pack $reportConsole.pied -side bottom -fill x
#
#   set verifConsole $reportConsole.text
#   $verifConsole tag configure BODY    -foreground black -background white
#   $verifConsole tag configure TITLE   -foreground "#808080" -justify center -font [ list {Arial} 12 bold ]
#   $verifConsole tag configure H1      -justify left -font [ list {Arial} 10 normal ]
#   $verifConsole tag configure H2      -justify left -font [ list {Arial} 10 normal ] -foreground $color(blue) 
#   $verifConsole tag configure H3      -justify left -font [ list {Arial} 10 normal ] -foreground $color(green) 
#   $verifConsole tag configure LISTE0  -foreground $color(black) -lmargin1 20
#   $verifConsole tag configure LISTE1  -foreground $color(red) -lmargin1 30 
#   $verifConsole tag configure GREEN   -foreground $color(green)
#   $verifConsole tag configure RED     -foreground $color(red)
#   $verifConsole tag configure OK      -foreground $color(green) -lmargin1 20
#   $verifConsole tag configure ERROR   -foreground $color(red) -lmargin1 20
#   $verifConsole tag configure ACT0    -foreground $color(black) -lmargin1 10
#   $verifConsole tag configure ACT1    -foreground $color(black) -lmargin1 15
#   $verifConsole tag configure ACTERR  -foreground $color(red) -lmargin1 15
#
#   $verifConsole insert end "$caption(bdi_status,consoleTitre) \n\n" TITLE
#
#   set list_img_null ""
#   set list_img_file ""
#   set list_img_sql ""
#   set list_img_size ""
#   set list_cata_null ""
#   set list_cata_file ""
#   set list_cata_sql ""
#   set list_cata_size ""
#   set limit 0
#
#   # Recupere la liste des images sur le disque
#   $verifConsole insert end "$caption(bdi_status,consoleAct1a) " H1
#   set maliste {}
#   get_files $bddconf(dirfits) $limit
#   set err [catch {set maliste [lsort -increasing $maliste]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr1) $msg" -type ok
#      return
#   }
#   set list_img_file $maliste
#   $verifConsole insert end " [llength $list_img_file]\n" H1
#
#   # Recupere la liste des catas sur le disque
#   $verifConsole insert end "$caption(bdi_status,consoleAct1b) " H1
#   set maliste {}
#   get_files $bddconf(dircata) $limit
#   set err [catch {set maliste [lsort -increasing $maliste]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr1) $msg" -type ok
#      return
#   }
#   set list_cata_file $maliste
#   $verifConsole insert end " [llength $list_cata_file]\n" H1
#
#   # Recupere la liste des images sur le serveur sql
#   $verifConsole insert end "$caption(bdi_status,consoleAct2a) " H1
#   set sqlcmd "SELECT dirfilename,filename,sizefich,idbddimg FROM images;"
#   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
#      return
#   }
#   foreach line $resultsql {
#      set dir [lindex $line 0]
#      set fic [lindex $line 1]
#      set siz [lindex $line 2]
#      set ibd [lindex $line 3]
#      lappend list_img_sql "$bddconf(dirbase)/$dir/$fic"
#      lappend list_img_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
#   }
#   $verifConsole insert end " [llength $list_img_sql]\n" H1
#
#   # Recupere la liste des catas sur le serveur sql
#   $verifConsole insert end "$caption(bdi_status,consoleAct2b) " H1
#   set sqlcmd "SELECT dirfilename,filename,sizefich,idbddcata FROM catas;"
#   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
#      return
#   }
#   foreach line $resultsql {
#      set dir [lindex $line 0]
#      set fic [lindex $line 1]
#      set siz [lindex $line 2]
#      set ibd [lindex $line 3]
#      lappend list_cata_sql "$bddconf(dirbase)/$dir/$fic"
#      lappend list_cata_size [list "$bddconf(dirbase)/$dir/$fic" $siz $ibd]
#   }
#   $verifConsole insert end " [llength $list_cata_sql]\n" H1
#
#   # Initialisations
#   set ::bdi_tools_status::err_imgnull  "no"
#   set ::bdi_tools_status::err_nbimg    "no"
#   set ::bdi_tools_status::err_imgsql   "no"
#   set ::bdi_tools_status::err_imgfile  "no"
#   set ::bdi_tools_status::err_imgsize  "no"
#
#   set ::bdi_tools_status::err_catanull "no"
#   set ::bdi_tools_status::err_nbcata   "no"
#   set ::bdi_tools_status::err_catasql  "no"
#   set ::bdi_tools_status::err_catafile "no"
#   set ::bdi_tools_status::err_catasize "no"
#
#   set ::bdi_tools_status::err_img      "no"
#   set ::bdi_tools_status::err_img_hd   "no"
#   set ::bdi_tools_status::err_doublon  "no"
#
#   # Comparaison des listes
#   $verifConsole insert end "\n$caption(bdi_status,consoleAct3) \n" H2
#   update
#
#   #-- d'images
#   set nb_list_img_file [llength $list_img_file]
#   set nb_list_img_sql [llength $list_img_sql]
#   if {$nb_list_img_file != $nb_list_img_sql} {
#      set ::bdi_tools_status::err_nbimg "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "La longueur des listes d'images differe (disque/sql: $nb_list_img_file/$nb_list_img_sql)" LISTE0
#      # recherche les fichiers dirfilename/filename en doublons dans la base SQL
#      set doublons [::bdi_gui_status::list_doublons $list_img_sql]
#      set nb_doublons [llength $doublons]
#      if {$nb_doublons > 0} {
#         $verifConsole insert end "\nX " ERROR
#         $verifConsole insert end "  Il y a $nb_doublons doublons dans les images dans la base SQL" ERROR
##gren_erreur "DOUBLONS IMG: $doublons \n"
#         set ::bdi_tools_status::err_doublon "yes"
#         foreach d $doublons {
#            lappend ::bdi_tools_status::list_doublon [lindex $d 0]
#         }
#      } else {
#         $verifConsole insert end "\nO " OK
#         $verifConsole insert end "  Pas de doublon dans les images dans la base SQL" LISTE0
#      }
#   } else {
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "La longueur des listes d'images est identique" LISTE0
#   }
#   update
#
#   #-- de catas
#   set nb_list_cata_file [llength $list_cata_file]
#   set nb_list_cata_sql [llength $list_cata_sql]
#   if {$nb_list_cata_file != $nb_list_cata_sql} {
#      set ::bdi_tools_status::err_nbcata "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "La longueur des listes de catas differe (disque/sql: $nb_list_cata_file/$nb_list_cata_sql)" LISTE0
#      # recherche les fichiers dirfilename/filename en doublons dans la base SQL
#      set doublons [::bdi_gui_status::list_doublons $list_cata_sql]
#      set nb_doublons [llength $doublons]
#      if {$nb_doublons > 0} {
#         $verifConsole insert end "\nX " ERROR
#         $verifConsole insert end "  Il y a $nb_doublons doublons dans les catas dans la base SQL" ERROR
##gren_erreur "DOUBLONS CATA: $doublons \n"
#         set ::bdi_tools_status::err_doublon "yes"
#         foreach d $doublons {
#            lappend ::bdi_tools_status::list_doublon [lindex $d 0]
#         }
#      } else {
#         $verifConsole insert end "\nO " OK
#         $verifConsole insert end "  Pas de doublon dans les catas dans la base SQL" LISTE0
#      }
#   } else {
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "La longueur des listes de catas est identique" LISTE0
#   }
#   $verifConsole insert end "\n" LISTE0
#   update
#   
#   # Verifie que la taille des images est identique sur le disque et dans la base SQL
#   set ::bdi_tools_status::new_list_imgsize {}
#   foreach elem $list_img_size {
#      set i [lindex $elem 0]
#      set size_db [lindex $elem 1]
#      set err [catch {set size_disk [file size $i]} msg]
#      if {! $err}  {
#         if {$size_db != $size_disk} {
#            lappend ::bdi_tools_status::new_list_imgsize $elem
#         }
#      }
#   }
#   if {[llength $::bdi_tools_status::new_list_imgsize] > 0} { 
#      set ::bdi_tools_status::err_imgsize "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg7b)" LISTE0
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_imgsize]" RED
#   } else {
#      set ::bdi_tools_status::err_imgsize "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg7a)" LISTE0
#   }
#   update
#
#   # Verifie que la taille des catas est identique sur le disque et dans la base SQL
#   set ::bdi_tools_status::new_list_catasize {}
#   foreach elem $list_cata_size {
#      set i [lindex $elem 0]
#      set size_db [lindex $elem 1]
#      set err [catch {set size_disk [file size $i]} msg]
#      if {! $err} {
#         if {$size_db != $size_disk} {
#            lappend ::bdi_tools_status::new_list_catasize $elem
#         }
#      }
#   }
#   if {[llength $::bdi_tools_status::new_list_catasize] > 0} { 
#      set ::bdi_tools_status::err_catasize "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg8b)" LISTE0
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_catasize]" RED
#   } else {
#      set ::bdi_tools_status::err_catasize "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg8a)" LISTE0
#   }
#   $verifConsole insert end "\n" LISTE0
#   update
#
#   # Recherche les images de la base SQL qui n'existent pas sur le disque
#   set ::bdi_tools_status::new_list_imgsql [::bdi_tools_status::list_diff_shift $list_img_file $list_img_sql]
#   set res ""
#   set nbdir 0
#   foreach elem $::bdi_tools_status::new_list_imgsql {
#      set isd [file isdirectory $elem]
#      if {$isd == 1} {
#         incr nbdir
#      } else {
#         lappend res $elem        
#      }
#   }
#   if {$nbdir > 0} {
#      $verifConsole insert end "\nX Des images dans la base SQL ne sont pas un fichier mais un repertoire" ERROR
#   }
#   set ::bdi_tools_status::new_list_imgsql $res 
#   if {[llength $::bdi_tools_status::new_list_imgsql] > 0} { 
#      set ::bdi_tools_status::err_imgsql "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg1b)" LISTE0
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_imgsql]" RED
#   } else {
#      set ::bdi_tools_status::err_imgsql "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg1a)" LISTE0
#   }
#   foreach elemsql $::bdi_tools_status::new_list_imgsql {
#      bddimages_sauve_fich $elemsql
#   }
#   update
#
#   # Recherche les catas de la base SQL qui n'existent pas sur le disque
#   set ::bdi_tools_status::new_list_catasql [::bdi_tools_status::list_diff_shift $list_cata_file $list_cata_sql]
#   set res ""
#   set nbdir 0
#   foreach elem $::bdi_tools_status::new_list_catasql {
#      set isd [file isdirectory $elem]
#      if {$isd == 1} {
#         incr nbdir
#      } else {
#         lappend res $elem        
#      }
#   }
#   if {$nbdir > 0} {
#      $verifConsole insert end "\nX Des catas dans la base SQL ne sont pas un fichier mais un repertoire" ERROR
#   }
#   set ::bdi_tools_status::new_list_catasql $res 
#   if {[llength $::bdi_tools_status::new_list_catasql] > 0} { 
#      set ::bdi_tools_status::err_catasql "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg1d)" LISTE0
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_catasql]" RED
#   } else {
#      set ::bdi_tools_status::err_catasql "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg1c)" LISTE0
#   }
#   foreach elemsql $::bdi_tools_status::new_list_catasql {
#      bddimages_sauve_fich $elemsql
#   }
#   $verifConsole insert end "\n" LISTE0
#   update
#
#   # Recherche les images sur le disque qui n'existent pas dans la base SQL
#   set ::bdi_tools_status::new_list_imgfile [::bdi_tools_status::list_diff_shift $list_img_sql $list_img_file]
#   set res ""
#   set nbdir 0
#   foreach elem $::bdi_tools_status::new_list_imgfile {
#      set isd [file isdirectory $elem]
#      if {$isd == 1} {
#         incr nbdir
#      } else {
#         lappend res $elem
#      }
#   }
#   if {$nbdir > 0} {
#      $verifConsole insert end "\nX Des images sur le disque ne sont pas un fichier mais un repertoire" ERROR
#   }
#   set ::bdi_tools_status::new_list_imgfile $res 
#   if {[llength $::bdi_tools_status::new_list_imgfile] > 0} { 
#      set ::bdi_tools_status::err_imgfile "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg2b)" LISTE0 
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_imgfile]" RED
#   } else {
#      set ::bdi_tools_status::err_imgfile "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg2a)" LISTE0 
#   }
#   foreach elemdir $::bdi_tools_status::new_list_imgfile {
#      bddimages_sauve_fich $elemdir
#   }
#   update
#   
#   # Recherche les catas sur le disque qui n'existent pas dans la base SQL
#   set ::bdi_tools_status::new_list_catafile [::bdi_tools_status::list_diff_shift $list_cata_sql $list_cata_file]
#   set res ""
#   set nbdir 0
#   foreach elem $::bdi_tools_status::new_list_catafile {
#      set isd [file isdirectory $elem]
#      if {$isd == 1} {
#         incr nbdir
#      } else {
#         lappend res $elem
#      }
#   }
#   if {$nbdir > 0} {
#      $verifConsole insert end "\nX Des catas sur le disque ne sont pas un fichier mais un repertoire" ERROR
#   }
#   set ::bdi_tools_status::new_list_catafile $res 
#   if {[llength $::bdi_tools_status::new_list_catafile] > 0} { 
#      set ::bdi_tools_status::err_catafile "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$caption(bdi_status,consoleMsg2d)" LISTE0 
#      $verifConsole insert end " [llength $::bdi_tools_status::new_list_catafile]" RED
#   } else {
#      set ::bdi_tools_status::err_catafile "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg2c)" LISTE0 
#   }
#   foreach elemdir $::bdi_tools_status::new_list_catafile {
#      bddimages_sauve_fich $elemdir
#   }
#   $verifConsole insert end "\n" LISTE0
#   update
#
#   # Recherche des images dont filename='' dans la base SQL
#   set sqlcmd "SELECT idbddimg FROM images WHERE filename ='';"
#   set err [catch {set res_null [::bddimages_sql::sql query $sqlcmd]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#      return
#   }
#   if {[llength $res_null] == 0} {
#      set ::bdi_tools_status::err_imgnull "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg6a)" LISTE0 
#   } else {
#      set ::bdi_tools_status::err_imgnull "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "[llength $res_null] $caption(bdi_status,consoleMsg6b)" LISTE0 
#   }
#   update
#
#   # Recherche des catas dont filename='' dans la base SQL
#   set sqlcmd "SELECT idbddcata FROM catas WHERE filename ='';"
#   set err [catch {set res_null [::bddimages_sql::sql query $sqlcmd]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#      return
#   }
#   if {[llength $res_null] == 0} {
#      set ::bdi_tools_status::err_catanull "no"
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$caption(bdi_status,consoleMsg6c)" LISTE0 
#   } else {
#      set ::bdi_tools_status::err_catanull "yes"
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "[llength $res_null] $caption(bdi_status,consoleMsg6d)" LISTE0 
#   }
#   $verifConsole insert end "\n" LISTE0
#   update
#
#
#   # Verification des autres tables de donnees sur le serveur SQL
#   set sqlcmd "SELECT DISTINCT idheader FROM header;"
#   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
#   if {$err} {
#      tk_messageBox -message "$caption(bdi_status,consoleErr2) $msg" -type ok
#      return
#   }
#
#   set err_list_header {}
#   set nb_headers [llength $resultsql]
#
#   foreach line $resultsql {
#      set idhd [lindex $line 0]
#      set sqlcmd "SELECT count(*) FROM images WHERE idheader='$idhd';"
#      set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
#      if {$err} {
#         tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#         return
#      }
#      set sqlcmd "SELECT count(*) FROM images_$idhd;"
#      set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
#      if {$err} {
#         tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#         return
#      }
#      if {$res_images_hd != $res_images} {
#         # recupere la liste des idbddimg de images
#         set sqlcmd "SELECT idbddimg FROM images WHERE idheader='$idhd';"
#         set err [catch {set res_images [::bddimages_sql::sql query $sqlcmd]} msg]
#         if {$err} {
#            tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#            return
#         }
#         # recupere la liste des idbddimg de images_idhd
#         set sqlcmd "SELECT idbddimg FROM images_$idhd;"
#         set err [catch {set res_images_hd [::bddimages_sql::sql query $sqlcmd]} msg]
#         if {$err} {
#            tk_messageBox -message "$caption(bdi_status,consoleErr3) $msg" -type ok
#            return
#         }
#         # effectue les compraisons
#         set ::bdi_tools_status::list_img    [::bdi_tools_status::list_diff_shift $res_images_hd $res_images]
#         set ::bdi_tools_status::list_img_hd [::bdi_tools_status::list_diff_shift $res_images $res_images_hd]
#         if {[llength $::bdi_tools_status::list_img] > 0} { 
#            set ::bdi_tools_status::err_img "yes"
#         }
#         if {[llength $::bdi_tools_status::list_img_hd] > 0} { 
#            set ::bdi_tools_status::err_img_hd "yes"
#         }
#         # affiche les resultats
#         lappend err_list_header [list "images" $idhd [llength $::bdi_tools_status::list_img]]
#         lappend err_list_header [list "images_" $idhd [llength $::bdi_tools_status::list_img_hd]]
#      }
#   }
#
#   if {[llength $err_list_header] == 0} {
#      $verifConsole insert end "\nO " OK
#      $verifConsole insert end "$nb_headers $caption(bdi_status,consoleMsg3)" LISTE0 
#   } else {
#      $verifConsole insert end "\nX " ERROR
#      $verifConsole insert end "$nb_headers $caption(bdi_status,consoleMsg3)" LISTE0 
#      $verifConsole insert end "\n   dont [llength $err_list_header] tables HEADER en erreur:" LISTE0
#      foreach err $err_list_header {
#         $verifConsole insert end "\n      * table [lindex $err 0], idheader [lindex $err 1] -> [lindex $err 2] errors" LISTE0 
#      }
#   }
#
#
#   # Initialise les checkbuttons d'action a 0
#   ::bdi_tools_status::uncheck_do_err
#
#   # Affiche les actions
#   if { [::bdi_tools_status::actionTodo] } {
#
#      $verifConsole insert end "\n\n$caption(bdi_status,consoleAct4)\n" H2
#
#      # Actions de reparation
#      frame $reportConsole.pied.actions -relief ridge
#      pack $reportConsole.pied.actions -in $reportConsole.pied -padx 2 -pady 2
#
#         label $reportConsole.pied.actions.label -text "$caption(bdi_status,repairActions)" -font $bddconf(font,arial_10_b)
#         pack $reportConsole.pied.actions.label -in $reportConsole.pied.actions -side top -fill x -anchor c -pady 2
#
#         frame $reportConsole.pied.actions.g 
#         pack $reportConsole.pied.actions.g -in $reportConsole.pied.actions -side top -expand 1 -padx 2 -pady 2
#
#            if {$::bdi_tools_status::err_imgnull == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_imgnull -highlightthickness 0 -text " Effacer les enregistrements de la table 'images' si filename=''" -variable ::bdi_tools_status::do_err_imgnull
#               grid $reportConsole.pied.actions.g.err_imgnull -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_catanull == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_catanull -highlightthickness 0 -text " Effacer les enregistrements de la table 'images' si filename=''" -variable ::bdi_tools_status::do_err_catanull
#               grid $reportConsole.pied.actions.g.err_catanull -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_imgsize == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_imgsize -highlightthickness 0 -text " Mettre a jour la taille des images dans la base SQL" -variable ::bdi_tools_status::do_err_imgsize
#               grid $reportConsole.pied.actions.g.err_imgsize -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_catasize == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_catasize -highlightthickness 0 -text " Mettre a jour la taille des catas dans la base SQL" -variable ::bdi_tools_status::do_err_catasize
#               grid $reportConsole.pied.actions.g.err_catasize -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_imgsql == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_imgsql -highlightthickness 0 -text " Effacer les images dans la base SQL qui n'existent pas sur le disque" -variable ::bdi_tools_status::do_err_imgsql 
#               grid $reportConsole.pied.actions.g.err_imgsql -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_catasql == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_catasql -highlightthickness 0 -text " Effacer les catas dans la base SQL qui n'existent pas sur le disque" -variable ::bdi_tools_status::do_err_catasql 
#               grid $reportConsole.pied.actions.g.err_catasql -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_imgfile == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_imgfile -highlightthickness 0 -text " Deplacer les images sur le disque qui n'existent pas dans la base SQL" -variable ::bdi_tools_status::do_err_imgfile
#               grid $reportConsole.pied.actions.g.err_imgfile -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_catafile == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_catafile -highlightthickness 0 -text " Deplacer les catas sur le disque qui n'existent pas dans la base SQL" -variable ::bdi_tools_status::do_err_catafile
#               grid $reportConsole.pied.actions.g.err_catafile -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_img == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_img -highlightthickness 0 -text " TODO Traiter les images qui n'ont pas d'entete" -variable ::bdi_tools_status::do_err_img 
#               grid $reportConsole.pied.actions.g.err_img -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_img_hd == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_img_hd -highlightthickness 0 -text " TODO Traiter les entetes qui ne correspondent pas a une image" -variable ::bdi_tools_status::do_err_img_hd 
#               grid $reportConsole.pied.actions.g.err_img_hd -sticky nsw -pady 3
#            }
#            if {$::bdi_tools_status::err_doublon == "yes"} {
#               checkbutton $reportConsole.pied.actions.g.err_doublon -highlightthickness 0 -text " Traiter les doublons de la base SQL" -variable ::bdi_tools_status::do_err_doublon
#               grid $reportConsole.pied.actions.g.err_doublon -sticky nsw -pady 3
#            }
#   
#            grid columnconfigure $reportConsole.pied.actions.g 0 -pad 20
#
#      # Options de reparation
#      frame $reportConsole.pied.opts -relief ridge
#      pack $reportConsole.pied.opts -in $reportConsole.pied -padx 2 -pady 2
#
#         frame $reportConsole.pied.opts.label
#         pack $reportConsole.pied.opts.label -in $reportConsole.pied.opts -side top -expand 1 -padx 2
#           
#            label $reportConsole.pied.opts.label.repair_lab -text "$caption(bdi_status,repairOpts)" -font $bddconf(font,arial_10_b)
#            pack $reportConsole.pied.opts.label.repair_lab -in $reportConsole.pied.opts.label -side left -fill x -anchor c -pady 2
#
#         frame $reportConsole.pied.opts.values
#         pack $reportConsole.pied.opts.values -in $reportConsole.pied.opts -side top -expand 1 -padx 2
#
#            label $reportConsole.pied.opts.values.repair_lab -text "$caption(bdi_status,repairDir)" -font $bddconf(font,arial_10)
#            pack $reportConsole.pied.opts.values.repair_lab -in $reportConsole.pied.opts.values -side left -fill x -anchor c -pady 2
#    
#            entry $reportConsole.pied.opts.values.repair_dir -relief flat -textvariable ::bdi_tools_status::repair_dir -width 40 
#            pack $reportConsole.pied.opts.values.repair_dir -in $reportConsole.pied.opts.values -side left -fill x -padx 2 -pady 2
#
#
#      # Bouton repare
#      button $reportConsole.pied.repare -borderwidth 2 -text "$caption(bdi_status,reparer)" \
#             -command {
#                  set answer [tk_messageBox -message "$caption(bdi_status,reparer) ?" -type yesno -parent $reportConsole]
#                  if {$answer == "yes"} {
#                     if { [::bdi_tools_status::actionChecked] } {
#                        $reportConsole.pied.repare configure -state disabled
#                        ::bdi_tools_status::repare $verifConsole
#                     } else {
#                        tk_messageBox -message "Nothing to do!" -type ok -parent $reportConsole
#                     }
#                  }
#               }
#      pack $reportConsole.pied.repare -in $reportConsole.pied -side left -anchor center -fill none -padx 5 -pady 5 -ipadx 3 -ipady 3
#
#      # Bouton Fermer
#      button $reportConsole.pied.fermer -text "$caption(bdi_status,fermer)" -borderwidth 2 \
#             -command {
#                  set conf(bddimages,verif_repair_dir) $::bdi_tools_status::repair_dir
#                  destroy $reportConsole
#               }
#      pack $reportConsole.pied.fermer -in $reportConsole.pied -side right -anchor center -fill none -padx 5 -pady 5 -ipadx 3 -ipady 3
#
#   } else {
#
#      $verifConsole insert end "\n\n$caption(bdi_status,consoleNoRepare) \n" H3
#
#      # Bouton ok
#      button $reportConsole.pied.ok -borderwidth 2 -text "OK" \
#             -command {
#                  set conf(bddimages,verif_repair_dir) $::bdi_tools_status::repair_dir
#                  destroy $reportConsole
#               }
#      pack $reportConsole.pied.ok -in $reportConsole.pied -anchor center -fill none -padx 5 -pady 5 -ipadx 3 -ipady 3
#   }
#
#   
#}

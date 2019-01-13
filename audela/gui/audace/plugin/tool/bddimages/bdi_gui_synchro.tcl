## @file bdi_gui_synchro.tcl
#  @brief     GUI de synchronisation des base de donn&eacute;es de bddimages
#  @author    Frederic Vachier and Jerome Berthier 
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_synchro.tcl]
#  @endcode

# $Id: bdi_gui_synchro.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_synchro
# @brief GUI de synchronisation des base de donn&eacute;es de bddimages
# @pre Requiert \c bdi_tools_synchro .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_synchro {

}


proc ::bdi_gui_synchro::stop {  } {
   set ::bdi_tools_synchro::stop 1
}


proc ::bdi_gui_synchro::go {  } {

   gren_info "Lancement de la synchronisation des bases\n"
   ::bdi_tools_synchro::go

}



proc ::bdi_gui_synchro::run {  } {
   

   set fen .synchro
   set ::bdi_gui_astroid::fen $fen
   if { [winfo exists $fen] } {
      wm withdraw $fen
      wm deiconify $fen
      focus $fen
      return
   }
   toplevel $fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
   wm geometry $fen +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $fen 1 1
   wm title $fen "Synchronisation"
   wm protocol $fen WM_DELETE_WINDOW "destroy .synchro"

   set frm $fen.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

          label $frm.txt -text "Synchronisation des Bases de Donnees\nChoisir de quel coté du socket voulez vous etre :" 

          button $frm.serveur -state active -text "Serveur" -relief "raised" \
             -command "::bdi_gui_synchro::serveur"
          button $frm.client -state active -text "Client" -relief "raised" \
             -command "::bdi_gui_synchro::client"

          grid $frm.txt -row 0 -column 0 -sticky news -padx 10 -pady 5 -columnspan 2

          grid $frm.serveur -row 1 -column 0 -sticky news -padx 10 -pady 5
          grid $frm.client  -row 1 -column 1 -sticky news -padx 10 -pady 5

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fen

}

proc ::bdi_gui_synchro::serveur {  } {
   
   destroy .synchro

   set fen .synchroserv
   set ::bdi_gui_astroid::fen $fen
   if { [winfo exists $fen] } {
      wm withdraw $fen
      wm deiconify $fen
      focus $fen
      return
   }
   toplevel $fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
   wm geometry $fen 800x500+165+55
   wm resizable $fen 1 1
   wm title $fen "Synchronisation Serveur Log"
   wm protocol $fen WM_DELETE_WINDOW "destroy $fen"


   set ::bdi_tools_synchro::config_port 12345

   set frm $fen.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5


   frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove
   pack $frm.buttons -in $frm -anchor w -side top 

          label $frm.buttons.lport -text "Port :" 
          entry $frm.buttons.port  -textvariable ::bdi_tools_synchro::config_port

          button $frm.buttons.reopen -state active -text "Open" -relief "raised" \
             -command "::bdi_tools_synchro::reopen_socket"

          button $frm.buttons.close -state active -text "Close" -relief "raised" \
             -command "::bdi_tools_synchro::close_socket"

          pack $frm.buttons.lport  -expand no -side left
          pack $frm.buttons.port   -expand no -side left
          pack $frm.buttons.reopen -expand no -side left
          pack $frm.buttons.close  -expand no -side left

   set ::bdi_tools_synchro::rapport $frm.text
   text $::bdi_tools_synchro::rapport -height 30 -width 80 \
        -yscrollcommand "$::bdi_tools_synchro::rapport.yscroll set" \
        -wrap none
   pack $::bdi_tools_synchro::rapport -expand yes -fill both -padx 5 -pady 5

   scrollbar $::bdi_tools_synchro::rapport.yscroll -orient vertical -cursor arrow -command "$::bdi_tools_synchro::rapport yview"
   pack $::bdi_tools_synchro::rapport.yscroll -side right -fill y

   $::bdi_tools_synchro::rapport delete 0.0 end
   
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fen

   ::bdi_tools_synchro::launch_socket

}







proc ::bdi_gui_synchro::client {  } {
   
   destroy .synchro

   set ::bdi_tools_synchro::param_check_nothing 1
   set ::bdi_tools_synchro::param_check_maj_client 1
   set ::bdi_tools_synchro::param_check_maj_server 1
   set ::bdi_tools_synchro::param_check_exist 0
   set ::bdi_tools_synchro::param_check_error 1

   set fen .synchroserv
   set ::bdi_gui_astroid::fen $fen
   if { [winfo exists $fen] } {
      wm withdraw $fen
      wm deiconify $fen
      focus $fen
      return
   }
   toplevel $fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
   wm geometry $fen 800x500+165+55
   wm resizable $fen 1 1
   wm title $fen "Synchronisation Serveur Log"
   wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

   set frm $fen.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

   set setup [frame $frm.setup -borderwidth 0 -cursor arrow -relief groove]
   pack $setup -in $frm -anchor w -side top 
          

         button $setup.conf -state active -text "Conf" -relief "raised" \
            -command "::bdi_gui_synchro::configuration_ip"
      

          label $setup.lname -text "Name :" 
          entry $setup.name -textvariable ::bdi_tools_synchro::config_name
          label $setup.lip -text "IP :" 
          entry $setup.ip -textvariable ::bdi_tools_synchro::config_ip  
          label $setup.lport -text "Port :" 
          entry $setup.port -textvariable ::bdi_tools_synchro::config_port
          
          grid $setup.conf $setup.lname $setup.name $setup.lip $setup.ip $setup.lport $setup.port 
          
          
   frame $frm.buttons -borderwidth 0 -cursor arrow -relief groove
   pack $frm.buttons -in $frm -anchor w -side top 

          button $frm.buttons.connect -state active -text "Connect" -relief "raised" \
             -command "::bdi_tools_synchro::connect_to_socket"

          button $frm.buttons.ping -state active -text "Ping" -relief "raised" \
             -command "::bdi_tools_synchro::ping_socket"

          button $frm.buttons.check -state active -text "Check" -relief "raised" \
             -command "::bdi_gui_synchro::check_synchro"

          button $frm.buttons.synchro -state active -text "Synchro" -relief "raised" \
             -command "::bdi_tools_synchro::launch_synchro"

          button $frm.buttons.stop -state active -text "STOP" -relief "raised" \
             -command "::bdi_tools_synchro::stop_synchro"

          pack $frm.buttons.connect -expand no -side left
          pack $frm.buttons.ping    -expand no -side left
          pack $frm.buttons.check   -expand no -side left
          pack $frm.buttons.synchro -expand no -side left
          pack $frm.buttons.stop    -expand no -side left

   set ::bdi_tools_synchro::buttons_synchro $frm.buttons.synchro


   set onglets [frame $frm.onglets]
   pack $onglets -in $frm  -expand yes -fill both


         pack [ttk::notebook $onglets.nb] -expand yes -fill both 
         set f_param [frame $onglets.nb.f_param]
         set f_log   [frame $onglets.nb.f_log]
         set f_liste [frame $onglets.nb.f_liste]

         $onglets.nb add $f_param -text "Parametres"
         $onglets.nb add $f_log   -text "Logs"
         $onglets.nb add $f_liste -text "Liste"

         ttk::notebook::enableTraversal $onglets.nb

      set param [frame $f_param.frm  -borderwidth 1 -relief groove]
      pack $param -in $f_param -expand yes -fill both
      set ::bdi_tools_synchro::param_frame $param

         checkbutton $param.nothing -highlightthickness 0 -text "Ne rien faire" \
                     -variable ::bdi_tools_synchro::param_check_nothing \
                     -command "::bdi_gui_synchro::param_check nothing"
                     
         checkbutton $param.maj_client -highlightthickness 0 -text "Mise a jour du client" \
                     -variable ::bdi_tools_synchro::param_check_maj_client \
                     -state disabled \
                     -command "::bdi_gui_synchro::param_check maj_client"

         checkbutton $param.maj_server -highlightthickness 0 -text "Mise a jour du serveur" \
                     -variable ::bdi_tools_synchro::param_check_maj_server \
                     -state disabled \
                     -command "::bdi_gui_synchro::param_check maj_server"

         checkbutton $param.exist -highlightthickness 0 -text "Si le fichier existe ne rien faire" \
                     -variable ::bdi_tools_synchro::param_check_exist \
                     -state disabled \
                     -command "::bdi_gui_synchro::param_check exist"

         checkbutton $param.erreur -highlightthickness 0 -text "Continu la synchro si erreur" \
                     -variable ::bdi_tools_synchro::param_check_error\
                     -state normal 


         grid $param.nothing      -sticky nsw 
         grid $param.maj_client   -sticky nsw 
         grid $param.maj_server   -sticky nsw  
         grid $param.exist        -sticky nsw 
         grid $param.erreur       -sticky nsw 

      set logs [frame $f_log.frm  -borderwidth 1 -relief groove]
      pack $logs -in $f_log -expand yes -fill both

         set ::bdi_tools_synchro::rapport $logs.text
         text $::bdi_tools_synchro::rapport -height 30 -width 80 \
              -yscrollcommand "$::bdi_tools_synchro::rapport.yscroll set" \
              -wrap none
         pack $::bdi_tools_synchro::rapport -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_tools_synchro::rapport.yscroll -orient vertical -cursor arrow -command "$::bdi_tools_synchro::rapport yview"
         pack $::bdi_tools_synchro::rapport.yscroll -side right -fill y

         $::bdi_tools_synchro::rapport delete 0.0 end

      set liste [frame $f_liste.frm  -borderwidth 1 -relief groove]
      pack $liste -in $f_liste -expand yes -fill both

# $cpt "TODO" "S->C" "FITS" $f_e $tab_server_f_m($f) $tab_server_f_s($f) $f "" ""
         set cols [list 0  "Id"        right \
                        11 "Status"    center \
                        0  "Synchro"   left \
                        0  "Type"      right \
                        0  "Exist"     left \
                        0  "Date"      left \
                        0  "Size (o)"  right \
                        0  "Filename"  left \
                        8  "Duration"  right \
                        30 "ErrLog"    left \
                  ]
         
         set ::bdi_gui_synchro::liste $liste.tab
         tablelist::tablelist $::bdi_gui_synchro::liste \
            -columns $cols \
            -labelcommand tablelist::sortByColumn \
            -yscrollcommand [ list $liste.vsb set ] \
            -selectmode extended \
            -activestyle none \
            -stripebackground "#e0e8f0" \
            -showseparators 1

         #--- Scrollbars verticale et horizontale
         scrollbar $liste.vsb -orient vertical -command [list $::bdi_gui_synchro::liste yview]
         pack $liste.vsb -in $liste -side left -fill y

         menu $liste.popupTbl -title "Actions"
         $liste.popupTbl add command -label "Voir l image" \
             -command { ::bdi_gui_synchro::view_image }
         $liste.popupTbl add command -label "Voir le chemin dans la console" \
             -command { ::bdi_gui_synchro::file_in_console }
         $liste.popupTbl add command -label "Enlever de la liste" \
             -command { ::bdi_gui_synchro::delete_on_list }
         $liste.popupTbl add command -label "Supprimer sur le client" \
             -command { ::bdi_gui_synchro::delete_on_client }
         $liste.popupTbl add command -label "Supprimer sur le serveur" \
             -command { ::bdi_gui_synchro::delete_on_serveur }

         bind [$::bdi_gui_synchro::liste bodypath] <ButtonPress-3> [ list tk_popup $liste.popupTbl %X %Y ]
         bind [$::bdi_gui_synchro::liste bodypath] <Double-1> [ list ::bdi_gui_synchro::view_image ]

         pack $::bdi_gui_synchro::liste -in $liste -expand yes -fill both
         #--- Gestion des evenements
         #bind [$tbl bodypath] <Control-Key-a> [ list ::bdi_gui_cata_gestion::selectall $tbl ]
         #bind $tbl <<ListboxSelect>>          [ list ::bdi_gui_cata_gestion::cmdButton1Click %W ]
         #bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
         #bind [$tbl bodypath] <Key-u>         [ list ::bdi_gui_cata_gestion::unset_flag $tbl ]
         $::bdi_gui_synchro::liste columnconfigure 0 -sortmode dictionary
         $::bdi_gui_synchro::liste columnconfigure 6 -sortmode dictionary

   #::bdi_tools_synchro::connect_to_socket

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fen

}


proc ::bdi_gui_synchro::view_image {  } {

   global bddconf
   set nb [llength [$::bdi_gui_synchro::liste curselection] ]
   if {$nb != 1} {
      tk_messageBox -message "Veuillez selectionner une seule image" -type ok
      return
   } 
   foreach select [$::bdi_gui_synchro::liste curselection] {
      set data [$::bdi_gui_synchro::liste get $select]
      set id [lindex $data 0]
      set file [lindex $data 7]
      set file [file join $bddconf(dirbase) $file]

      set result [bddimages_formatfichier $file]
      set type  [lindex $result 2]
      if {$type != "img"} {
         gren_erreur "File doesn't exist $file\n"
         tk_messageBox -message "La selection n'est pas une image" -type ok
         return
      }
      if {[file exists $file]} {
         loadima $file
      } else {
         gren_erreur "File doesn't exist $file\n"
         tk_messageBox -message "L'image n'existe pas sur le Client" -type ok
         return
      }
      gren_info "view file $file\n"
   }
   return
}


proc ::bdi_gui_synchro::file_in_console {  } {

   global bddconf

   foreach select [$::bdi_gui_synchro::liste curselection] {
      set data [$::bdi_gui_synchro::liste get $select]
      set id [lindex $data 0]
      set file [lindex $data 7]
      set file [file join $bddconf(dirbase) $file]
      gren_info "set file $file\n"
   }
   gren_info "file exists \$file\n"
   return
}


proc ::bdi_gui_synchro::check_synchro {  } {


   $::bdi_gui_synchro::liste delete 0 end
   update

   ::bdi_tools_synchro::check_synchro

   set tt0 [clock clicks -milliseconds]
   ::bdi_gui_synchro::affich_synchro
   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Affichage de la tablelist en $tt sec\n"
}


proc ::bdi_gui_synchro::affich_synchro { } {

   $::bdi_gui_synchro::liste delete 0 end

   if {[llength $::bdi_tools_synchro::todolist]>0} {
      set cpt 0
      foreach l $::bdi_tools_synchro::todolist {
         $::bdi_gui_synchro::liste insert end $l
         incr cpt
      }
   }
}




proc ::bdi_gui_synchro::param_check { but } {

   set param $::bdi_tools_synchro::param_frame
   set state_but [$param.$but cget -state]

   gren_info "--\n"
   gren_info "but = $but\n"
   gren_info "param_check_nothing = $::bdi_tools_synchro::param_check_nothing\n"
   gren_info "state_but = $state_but\n"

   if {$but=="nothing"&&$::bdi_tools_synchro::param_check_nothing==0} {
      $param.maj_client configure -state normal
      $param.maj_server configure -state normal
      $param.exist configure -state normal
   }
   if {$but=="nothing"&&$::bdi_tools_synchro::param_check_nothing==1} {
      $param.maj_client configure -state disabled
      $param.maj_server configure -state disabled
      $param.exist configure -state disabled
   }
}

proc ::bdi_gui_synchro::read_ip { } {
   global audace
   set file_ip [file join $audace(rep_home) bdi_synchro.dat]
   
   set ::bdi_gui_synchro::list_ip ""
   if {[file exists $file_ip]} {
      set f [open $file_ip r]
      while {![eof $f]} {
         set r [gets $f]
         if {$r != ""} {
            set r [split $r " "]
            set i 0
            foreach v $r {
               incr i
               if {$i==1} { set port $v; continue }
               if {$i==2} { set ip $v; continue }
               if {$i==3} { set name $v; continue }
               if {$i>3} { append name " $v"; continue }
            }
            
            lappend ::bdi_gui_synchro::list_ip $name
            set ::bdi_gui_synchro::list_config_ip($name,port) $port
            set ::bdi_gui_synchro::list_config_ip($name,ip)   $ip
         }
      }
      close $f
   }
}

proc ::bdi_gui_synchro::affiche_ip { } {

   $::bdi_gui_synchro::liste_config delete 0 end
   set i 0
   foreach name $::bdi_gui_synchro::list_ip {
      $::bdi_gui_synchro::liste_config insert end $name
      if {$i==0} {
         set ::bdi_gui_synchro::config_name $name
         set ::bdi_gui_synchro::config_ip   $::bdi_gui_synchro::list_config_ip($name,ip)
         set ::bdi_gui_synchro::config_port $::bdi_gui_synchro::list_config_ip($name,port)
      }
      incr i
   }
   $::bdi_gui_synchro::liste_config selection set 0
}

# 12345 192.168.0.60 Thebe@Rotoir
# 12345 metis.imcce.fr Metis@IMCCE
# 12345 thebe.imcce.fr Thebe@IMCCE


proc ::bdi_gui_synchro::write_config { } {
   global audace
   set file_ip [file join $audace(rep_home) bdi_synchro.dat]
   set f [open $file_ip w]
   foreach name $::bdi_gui_synchro::list_ip {
      puts $f "$::bdi_gui_synchro::list_config_ip($name,port) $::bdi_gui_synchro::list_config_ip($name,ip) $name"
   }
   close $f

}

proc ::bdi_gui_synchro::configuration_ip { } {

   set ::bdi_gui_synchro::config_name ""
   set ::bdi_gui_synchro::config_ip   ""
   set ::bdi_gui_synchro::config_port ""

   set fen .configip
   destroy .configip
   
   if { [winfo exists $fen] } {
      wm withdraw $fen
      wm deiconify $fen
      focus $fen
      return
   }
   set geom [wm geometry $::bdi_gui_astroid::fen]
   set geom [split $geom "+"]
   set x [expr [lindex $geom 1] + 50]
   set y [expr [lindex $geom 2] + 50]
   set geom "+${x}+${y}"

   toplevel $fen -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $fen ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $fen ] "+" ] 2 ]
   wm geometry $fen $geom
   wm resizable $fen 1 1
   wm title $fen "Gestionnaire des Sites"
   wm protocol $fen WM_DELETE_WINDOW "destroy $fen"

   set frm $fen.appli

   frame $frm -borderwidth 1 -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -padx 10 -pady 5

   frame $frm.left -borderwidth 1 -cursor arrow -relief groove
   pack $frm.left -in $frm -anchor s -side left -expand 1 -fill both -padx 10 -pady 5
   
   frame $frm.right -borderwidth 1 -cursor arrow -relief groove
   pack $frm.right -in $frm  -side right -padx 10 -pady 5
   
   # liste des config

      set liste [frame $frm.left.liste  -borderwidth 1 -relief groove]
      pack $liste -in $frm.left -expand yes -fill both
   
      set cols [list 0  "Config" left ]
   
      set ::bdi_gui_synchro::liste_config $liste.tab
      
      tablelist::tablelist $::bdi_gui_synchro::liste_config \
         -columns $cols \
         -labelcommand tablelist::sortByColumn \
         -yscrollcommand [ list $liste.vsb set ] \
         -selectmode extended \
         -activestyle none \
         -stripebackground "#e0e8f0" \
         -showseparators 1
      
      #--- Scrollbars verticale et horizontale
      scrollbar $liste.vsb -orient vertical -command [list $::bdi_gui_synchro::liste_config yview]
      pack $liste.vsb -in $liste -side left -fill y

      bind $::bdi_gui_synchro::liste_config <<ListboxSelect>> [ list ::bdi_gui_synchro::select_mouse %W ]
      
      pack $::bdi_gui_synchro::liste_config -in $liste -expand yes -fill both

      $::bdi_gui_synchro::liste_config columnconfigure 0 -sortmode dictionary
   
   # Parametrage
      
      set center  [frame $frm.right.center -borderwidth 1 -cursor arrow -relief groove]
      grid $center -in $frm.right  -sticky news
      
      set champs  [frame $center.champs -borderwidth 1 -cursor arrow -relief groove]
      set boutons [frame $center.boutons -borderwidth 1 -cursor arrow -relief groove]

      grid $champs -in $center  -sticky news
      grid $boutons -in $center -sticky news
   
      # Champs
         
         label $champs.lname -text "Nom"
         label $champs.lip   -text "IP"
         label $champs.lport -text "Port"
         
# alnum, alpha, ascii, control, boolean, digit, double, false, graph, integer, 
# list, lower, print, punct, space, true, upper, wideinteger, wordchar, or xdigit
# expr {[string match {[a-zA-Z0-9]*} %P] }     
   
         entry $champs.name -textvariable ::bdi_gui_synchro::config_name
               
         entry $champs.ip   -textvariable ::bdi_gui_synchro::config_ip
               
         entry $champs.port -textvariable ::bdi_gui_synchro::config_port
               
         
         grid $champs.lname $champs.name -in $champs -sticky news
         grid $champs.lip   $champs.ip   -in $champs -sticky news
         grid $champs.lport $champs.port -in $champs -sticky news
      
      # Boutons
   
         button $boutons.clear -state active -text "Clear" -relief "raised" \
            -command "::bdi_gui_synchro::clear"
      
         button $boutons.plus -state active -text "Save" -relief "raised" \
            -command "::bdi_gui_synchro::save"
      
         button $boutons.moins -state active -text "-" -relief "raised" \
            -command "::bdi_gui_synchro::moins"

         button $boutons.annul -state active -text "Annule" -relief "raised" \
            -command "::bdi_gui_synchro::annul"

         button $boutons.select -state active -text "Select" -relief "raised" \
            -command "::bdi_gui_synchro::select"
      
         grid $boutons.clear $boutons.plus $boutons.moins $boutons.annul $boutons.select -in $boutons -sticky news

   # Lecture du fichier config
   ::bdi_gui_synchro::read_ip
   ::bdi_gui_synchro::affiche_ip
}

proc ::bdi_gui_synchro::annul { } {
   destroy .configip
}


proc ::bdi_gui_synchro::save { } {
    
    set name $::bdi_gui_synchro::config_name
    
    if {$name!=""} {
       set id [lsearch $::bdi_gui_synchro::list_ip $name]
       if {$id == -1} {
          lappend ::bdi_gui_synchro::list_ip $name
       }
       set ::bdi_gui_synchro::list_config_ip($name,ip)   $::bdi_gui_synchro::config_ip  
       set ::bdi_gui_synchro::list_config_ip($name,port) $::bdi_gui_synchro::config_port

       
    }
    
    ::bdi_gui_synchro::affiche_ip 
    
    set l [$::bdi_gui_synchro::liste_config get 0 end]
    set select -1
    foreach x $l {
       incr select
       if {$x==$name} {
          break
       }
    }
    $::bdi_gui_synchro::liste_config selection clear 0 end
    $::bdi_gui_synchro::liste_config selection set $select
    
    set ::bdi_gui_synchro::config_name $name
    set ::bdi_gui_synchro::config_ip   $::bdi_gui_synchro::list_config_ip($name,ip)
    set ::bdi_gui_synchro::config_port $::bdi_gui_synchro::list_config_ip($name,port)
    
    ::bdi_gui_synchro::write_config
    
}


proc ::bdi_gui_synchro::moins { } {

    set name $::bdi_gui_synchro::config_name
    set id [lsearch $::bdi_gui_synchro::list_ip $name]
    set ::bdi_gui_synchro::list_ip [lreplace $::bdi_gui_synchro::list_ip $id $id]
    unset ::bdi_gui_synchro::list_config_ip($name,ip)
    unset ::bdi_gui_synchro::list_config_ip($name,port)
    
    ::bdi_gui_synchro::affiche_ip 
}


proc ::bdi_gui_synchro::select { } {

   set ::bdi_tools_synchro::config_name $::bdi_gui_synchro::config_name
   set ::bdi_tools_synchro::config_ip   $::bdi_gui_synchro::config_ip  
   set ::bdi_tools_synchro::config_port $::bdi_gui_synchro::config_port
   
   set name $::bdi_gui_synchro::config_name
   set id [lsearch $::bdi_gui_synchro::list_ip $name]

   if {$id == -1} {
      set ::bdi_gui_synchro::list_ip [linsert $::bdi_gui_synchro::list_ip 0 $name]
      set ::bdi_gui_synchro::list_config_ip($name,ip)   $::bdi_gui_synchro::config_ip  
      set ::bdi_gui_synchro::list_config_ip($name,port) $::bdi_gui_synchro::config_port
   } else {
      set ::bdi_gui_synchro::list_ip [lreplace $::bdi_gui_synchro::list_ip $id $id]
      set ::bdi_gui_synchro::list_ip [linsert $::bdi_gui_synchro::list_ip 0 $name]
   }
   
   ::bdi_gui_synchro::save

   ::bdi_gui_synchro::annul
   
}


proc ::bdi_gui_synchro::clear { } {
   set ::bdi_gui_synchro::config_name ""
   set ::bdi_gui_synchro::config_ip   ""
   set ::bdi_gui_synchro::config_port ""
}


proc ::bdi_gui_synchro::select_mouse {  w args } {

   set selection [$::bdi_gui_synchro::liste_config curselection]
   foreach select $selection {
      break
   }
   $::bdi_gui_synchro::liste_config selection clear 0 end
   $::bdi_gui_synchro::liste_config selection set $select
   
   set name [$::bdi_gui_synchro::liste_config get $select]

   set ::bdi_gui_synchro::config_name $name
   set ::bdi_gui_synchro::config_ip   $::bdi_gui_synchro::list_config_ip($name,ip)
   set ::bdi_gui_synchro::config_port $::bdi_gui_synchro::list_config_ip($name,port)
   
}



proc ::bdi_gui_synchro::delete_on_client { } {

   set selection [$::bdi_gui_synchro::liste curselection]
   foreach select $selection {
      set pass 0
      set l [$::bdi_gui_synchro::liste get $select]
      gren_info "l = $l\n"
      if {[lindex $l 2] == "S->C" && [lindex $l 4] == 1} {
         gren_erreur "Delete on client : [lindex $l 7]\n"
         set pass 1
      } 
      if {[lindex $l 2] == "C->S" } {
         gren_erreur "Delete on client * : [lindex $l 7]\n"
         set pass 1
      } 
      if {$pass} {
         set df [file dirname [lindex $l 7]]
         set fn [file tail [lindex $l 7]]

         # type de fichier CATA ou IMG
         set result [bddimages_formatfichier $fn]
         set type  [lindex $result 2]
         
         # Fichier Image
         if {$type == "img"} {
            set sqlcmd "SELECT idbddimg FROM images WHERE filename='$fn' AND dirfilename='$df';"
            set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               ::bdi_tools_synchro::set_error $id "Erreur : find idbddimg - err = $err\nsql = $sqlcmd\nmsg = $msg"
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            set data [lindex $data 0]
            set idbddimg [lindex $data 0]

            set err [catch {set ident [bddimages_image_identification $idbddimg]} msg ]
            if {$err} {
               ::bdi_tools_synchro::set_error $id "Error bddimages_image_identification : idbddimg = $idbddimg"
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }
            set idbddimg     [lindex $ident 0]
            set fileimg      [lindex $ident 1]
            set idbddcata    [lindex $ident 2]
            set catafilebase [lindex $ident 3]
            set idheader     [lindex $ident 4]

            gren_info "Effacement de $idbddimg ; $fileimg ; $idbddcata ; $catafilebase ; $idheader\n"

            bddimages_image_delete $idbddimg

            ::bdi_tools_synchro::set_status $select DELETED
            continue
            #return
         }

         # Fichier Cata
         if {$type == "cata"} {

            bddimages_delete_cata_ifexist $fn "cata.xml.gz"
            
            set sqlcmd "SELECT idbddcata FROM catas WHERE filename='$fn' AND dirfilename='$df';"
            set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
            if {$err} {
               gren_erreur "Erreur : find idbddcata - err = $err\nsql = $sqlcmd\nmsg = $msg"
               ::bdi_tools_synchro::set_error $id "Erreur : find idbddcata - err = $err\nsql = $sqlcmd\nmsg = $msg"
               if {$::bdi_tools_synchro::param_check_error} { continue } else { return }
            }

            set data [lindex $data 0]
            
            if {$data==""} {
               # cas ou l image a ete effacée et donc le cata a disparu par l effacement de l image
               ::bdi_tools_synchro::set_status $select DELETED
               continue
            }
            
            set idbddcata [lindex $data 0]
            
            set err [catch {::bdi_tools_status::delete_cata $idbddcata} msg ]
            if {$err} {
               tk_messageBox -message "Erreur ($err) a l effacement\n$msg\n" -type ok
               ::bdi_tools_synchro::set_status $select ERROR
               return
            }
            
            ::bdi_tools_synchro::set_status $select DELETED
            continue
            #return
         }

         # Fichier Inconnu
         tk_messageBox -message "Type de fichier non reconnu" -type ok
         return
      }
   }

}



proc ::bdi_gui_synchro::delete_on_list { } {

   set selection [lsort -decreasing [$::bdi_gui_synchro::liste curselection] ]
   
   foreach select $selection {
      set l [$::bdi_gui_synchro::liste get $select]
      $::bdi_gui_synchro::liste delete $select
      set ::bdi_tools_synchro::todolist [lreplace $::bdi_tools_synchro::todolist $select $select]
   }

}



proc ::bdi_gui_synchro::delete_on_serveur { } {

   set selection [$::bdi_gui_synchro::liste curselection]
   foreach select $selection {
      set l [$::bdi_gui_synchro::liste get $select]
      gren_info "l = $l\n"
      set pass 0
      
      set l [$::bdi_gui_synchro::liste get $select]
      
      set id        [lindex $l 0]
      set status    [lindex $l 1]
      set synchro   [lindex $l 2]
      set filetype  [lindex $l 3]
      set exist     [lindex $l 4]
      set modifdate [lindex $l 5]
      set filesize  [lindex $l 6]
      set filename  [lindex $l 7]
      
      if {$synchro == "S->C"} {
         gren_erreur "Delete on server : $filename\n"
         set pass 1
      } 
      if {$synchro == "C->S" && $exist == 1} {
         gren_erreur "Delete on server * : $filename\n"
         set pass 1
      } 

      if {$pass} {
      
         set df [file dirname $filename]
         set fn [file tail $filename]
         
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel "DEL_BDI" 1

         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
         if {$status=="PENDING"} {
            ::bdi_tools_synchro::set_status $select DELETING
         } else {
            ::bdi_tools_synchro::set_error $select $status
            return
         }

         # Envoie le nom du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filetype $filetype

         # Envoie le nom du fichier
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filename $filename
#            gren_info "filename send\n"

         # Envoie de la taille
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel filesize $filesize
#            gren_info "filesize send\n"

         # Envoie de la date
         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel modifdate $modifdate
#            gren_info "modifdate send\n"

         ::bdi_tools_synchro::I_send_var $::bdi_tools_synchro::channel DELETE 1
         
         ::bdi_tools_synchro::I_receive_var $::bdi_tools_synchro::channel status status
         if {$status=="DELETED"} {
            ::bdi_tools_synchro::set_status $select DELETED
         } else {
            ::bdi_tools_synchro::set_error $select $status
            return
         }

      }

   }

}

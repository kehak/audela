## @file bdi_gui_reports_mpc.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de gestion des rapports d'analyse - soumission MPC
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_mpc.tcl]
#  @endcode

# $Id: bdi_gui_reports_mpc.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_reports::submit_reports_mpc { p_from } {

   upvar $p_from from

   global  bddconf 

   set curselection [$from curselection]
   set nb [llength $curselection]
   if { $nb > 1 } {
      tk_messageBox -message "Veuillez selectionner un seul rapport" -type ok
      return
   }
   set select [ lindex $curselection 0]
   

   set batch     [lindex [$from get $select] 0]
   set firstdate [lindex [$from get $select] 1]
   set obj       [lindex [$from get $select] 2]
   set type      [lindex [$from get $select] 3]

   if { $type != "astrom" } {
      tk_messageBox -message "les rapports de type $type ne sont pas reconnus" -type ok
      return
   }

   gren_info "Soumission MPC de \n"
   gren_info "     batch     = $batch    \n"
   gren_info "     obj       = $obj      \n"
   gren_info "     firstdate = $firstdate\n"
   gren_info "     type      = $type     \n"
   
   # Fichier MPC
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)] } {
      gren_erreur "La variable n existe pas : ::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)\n"
      return
   }
   if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)] } {
      gren_erreur "Le fichier n existe pas : $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)\n"
      return
   }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)] } {
      gren_erreur "La variable n existe pas : ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)\n"
      return
   }
   if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)] } {
      gren_erreur "Le fichier n existe pas : $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)\n"
      return
   }

   # Lecture du fichier Info
   ::bdi_tools_reports::file_info_to_list $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) list_info   
   gren_info "     list_info      = $list_info     \n"

   # Init GUI
   set ::bdi_gui_reports::mpc_file_window $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)
   set ::bdi_gui_reports::mpc_info_window $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)

   array set tab_info $list_info
   if { $tab_info(submit_mpc) == "No" || $tab_info(submit_mpc) == "no"} {
      set ::bdi_gui_reports::mpc_flag_window "yes"
   } elseif { $tab_info(submit_mpc) == "Yes" || $tab_info(submit_mpc) == "yes" } { 
      set ::bdi_gui_reports::mpc_flag_window "no"
   } else {
      gren_erreur "submit inconnu = $tab_info(submit_mpc)\n"
   }

   # Lancement GUI
   ::bdi_gui_reports::mpc_build_window $batch
   
   return
}








proc ::bdi_gui_reports::mpc_close_window { } {

   global conf bddconf 

   set conf(bddimages,geometry_reports) [wm geometry $::bdi_gui_reports::fen_mpc]
   set bddconf(geometry_reports) [wm geometry $::bdi_gui_reports::fen_mpc]
   destroy $::bdi_gui_reports::fen_mpc
}







proc ::bdi_gui_reports::mpc_apply_window {  } {
   
   ::bdi_tools_reports::file_info_to_list $::bdi_gui_reports::mpc_info_window list_info
   array set tab_info $list_info
   set tab_info(submit_mpc) $::bdi_gui_reports::mpc_flag_window
   set list_info [array get tab_info]
   ::bdi_tools_reports::list_to_file_info $::bdi_gui_reports::mpc_info_window list_info
   ::bdi_gui_reports::mpc_close_window
   ::bdi_tools_reports::charge
   
}







#------------------------------------------------------------
## Fenetre de clicouillage avant soumission par email
#  @return void
#
proc ::bdi_gui_reports::mpc_build_window { batch } {

   global audace caption color
   global conf bddconf 
   
   #--- Initialisation des parametres
   set ::bdi_gui_reports::mpc_to      "obs@cfa.harvard.edu;$conf(bddimages,astrometry,reports,mail)"
   set ::bdi_gui_reports::mpc_subject "\[OBSERVATION\]\[MPC\]$batch"

   gren_info "Soumission MPC\n"
   gren_info "to : $::bdi_gui_reports::mpc_to\n"
   gren_info "subject : $::bdi_gui_reports::mpc_subject\n"

   set highprec "no"
   set widthlab 30
   set widthentry 30
   set ::bdi_gui_reports::fen_mpc .mpc_reports

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_reports) ] } {
      set conf(bddimages,geometry_reports) "+300+800"
   }
   set bddconf(geometry_reports) $conf(bddimages,geometry_reports)

   #--- Declare la GUI
   if { [ winfo exists $::bdi_gui_reports::fen_mpc ] } {
      wm withdraw $::bdi_gui_reports::fen_mpc
      wm deiconify $::bdi_gui_reports::fen_mpc
      return
   }

   #--- GUI
   toplevel $::bdi_gui_reports::fen_mpc -class Toplevel
   wm geometry $::bdi_gui_reports::fen_mpc $bddconf(geometry_reports)
   wm resizable $::bdi_gui_reports::fen_mpc 1 1
   wm title $::bdi_gui_reports::fen_mpc $caption(bddimages_go,reports)
   wm protocol $::bdi_gui_reports::fen_mpc WM_DELETE_WINDOW { ::bdi_gui_reports::mpc_close_window }

   set frm $::bdi_gui_reports::fen_mpc.appli
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_reports::fen_mpc -anchor s -side top -expand yes -fill both -padx 10 -pady 5

   set mpc $frm
   set wdth 14
   
      #--- Onglet RAPPORT - MPC
      set block [frame $mpc.flag  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5


            button   $block.fermer -text "Fermer" -borderwidth 2 \
                     -command "::bdi_gui_reports::mpc_close_window"
            pack   $block.fermer -side left -padx 3 -pady 1 -anchor w

            label  $block.lab -text "Pour flaguer le rapport en " \
                      -borderwidth 1 
            pack   $block.lab -side left -padx 3 -pady 1 -anchor w

            button   $block.flag -textvariable ::bdi_gui_reports::mpc_flag_window -borderwidth 2 \
                     -command "::bdi_gui_reports::mpc_apply_window"
            pack   $block.flag -side left -padx 3 -pady 1 -anchor w


      #--- Onglet RAPPORT - MPC
      set block [frame $mpc.exped  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

            label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 1 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_to
            pack   $block.val -side left -padx 3 -pady 1 -anchor w

      set block [frame $mpc.subj  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

            label  $block.lab -text "Sujet : " -borderwidth 1 -width $wdth
            pack   $block.lab -side left -padx 3 -pady 1 -anchor w

            entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_subject
            pack   $block.val -side left -padx 3 -pady 1 -anchor w

      set ::bdi_gui_reports::rapport_mpc $mpc.text
      text $::bdi_gui_reports::rapport_mpc -height 30 -width 80 \
           -xscrollcommand "$::bdi_gui_reports::rapport_mpc.xscroll set" \
           -yscrollcommand "$::bdi_gui_reports::rapport_mpc.yscroll set" \
           -wrap none
      pack $::bdi_gui_reports::rapport_mpc -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_gui_reports::rapport_mpc.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::rapport_mpc xview"
      pack $::bdi_gui_reports::rapport_mpc.xscroll -side bottom -fill x

      scrollbar $::bdi_gui_reports::rapport_mpc.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::rapport_mpc yview"
      pack $::bdi_gui_reports::rapport_mpc.yscroll -side right -fill y

      $::bdi_gui_reports::rapport_mpc delete 0.0 end

#01234567890123456789012345678901234567890123456789012345678901234567890123456789
#          1         2         3         4         5         6         7     
#03905         C2015 04 24.63266713 15 01.859-24 45 55.36         16.48R      181
#03905         C2015 04 24.63266 13 15 01.85 -24 45 55.3          16.4 R      181
#03905         C2015 04 24.63266 13 15 01.85 -24 45 55.3          16.4 R      181

      # Lecture du fichier mpc
      set chan [open $::bdi_gui_reports::mpc_file_window r]
      set strl ""
      set dataline "no"
      while {[gets $chan line] >= 0} {
         if {$highprec == "yes"} {
            # Rapport haute precision
            $::bdi_gui_reports::rapport_mpc insert end "$line\n"
            continue
         } else {
            # Rapport basse precision
            if {$dataline == "no"} {
               $::bdi_gui_reports::rapport_mpc insert end "$line\n"
               set pos [string first "NUM" $line]
               if {$pos==0} {set dataline "yes"}
            } else {
               set line [string replace $line 31 31 " "]
               set line [string replace $line 43 43 " "]
               set line [string replace $line 55 55 " "]
               set line [string replace $line 69 69 " "]
               $::bdi_gui_reports::rapport_mpc insert end "$line\n"
               continue                  
            }
         }
         
      }
      close $chan

      set block [frame $mpc.pied  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mpc -side top -expand 0 -fill x -padx 2 -pady 5

            label  $block.lab -text "Veuillez copier et coller les champs ci-dessus apres avoir cree un nouveau mail dans votre messagerie" -borderwidth 1 -font $bddconf(font,arial_10_b)
            pack   $block.lab -side left -padx 3 -pady 1 -anchor w
}











#------------------------------------------------------------
## Soumission quelconque
#  @return void
#
proc ::bdi_gui_reports::submit_reports { } {


   global conf
   global bddconf
   
   if {![info exists ::bdi_gui_reports::selected_obj]} {
      tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
      return
   }
   if {$::bdi_gui_reports::selected_obj==""} {
      tk_messageBox -message "Veuillez selectionner un objet dans la liste haute" -type ok
      return
   }
   
   set obj $::bdi_gui_reports::selected_obj
   set firstdate $::bdi_gui_reports::selected_firstdate
   
   
   set curselection [$::bdi_tools_reports::data_report curselection]
   foreach select $curselection {

      set batch [lindex [$::bdi_tools_reports::data_report get $select] 0]
      set flag  [lindex [$::bdi_tools_reports::data_report get $select] 6]
      
      #gren_info "firstdate = $firstdate\n"
      #gren_info "batch = $batch\n"
      #gren_info "flag  = $flag\n"
      
      switch $flag {
         "no" {
            set newflag "yes"
         }
         "yes" {
            set newflag "no"
         }
         default {
            set newflag "yes"
         }
      }
      #gren_info "newflag  = $newflag\n"
      
      set file_astrom ""
      set file_photom ""
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate]
      #gren_info "dir = $dir batch = $batch\n"
      set liste [globr $dir]
      set attachment ""
      foreach file $liste {
         set pos [string first $batch $file]
         if {$pos !=-1} {
            append attachment "file://${file},"

            set ext  [file extension $file]
            if {$ext == ".txt" && [string last "astrom_txt" $file]>0} { set file_astrom $file }
            if {$ext == ".txt" && [string last "photom_txt" $file]>0} { set file_photom $file }
         }
      }
      set uaicode -1

      set body "Hi !\n"
      append body "\n"
      append body "You should find attached all files corresponding to the reduction of this set of observations.\n"
      append body "A short header are present here :\n"
      append body "\n"
      
      set type ""
      
      if {$file_astrom!=""} {
         
         append body "** ASTROMETRY REPORTS **\n"
         append body "\n"

         set chan [open $file_astrom r]
         set cpt 0
         while {[gets $chan line] >= 0} {
            if {$uaicode == -1} {set uaicode [::bdi_gui_reports::get_uaicode $line ":"]}
            if {$cpt >0} {append body "$line\n"}
            incr cpt
            if {$cpt >10} {break}
         }
         close $chan
         
         set type "ASTROM"
         set to $conf(bddimages,astrometry,reports,mail)
         
      }
         
      if {$file_photom!=""} {
     
         append body "** PHOTOMETRY REPORTS **\n"
         append body "\n"

         set chan [open $file_photom r]
         set cpt 0
         while {[gets $chan line] >= 0} {
            if {$uaicode == -1} {set uaicode [::bdi_gui_reports::get_uaicode $line "="]}
            append body "$line\n"
            incr cpt
            if {$cpt >10} {break}
         }
         close $chan
         
         set type "PHOTOM"
         set to $conf(bddimages,photometry,reports,mail)
         
      }
      
      set subject "\[OBSERVATION\]\[${type}\]\[$uaicode\]\[$firstdate\]\[$obj\] $batch"
      
      
      if {$attachment != "" } {
         set attachment [string range $attachment 0 end-1]
         set attachment ",attachment='${attachment}'"
      }
      set err [catch {exec $::bdi_tools::sendmail::thunderbird --compose "to='${to}',subject='${subject}',body='${body}'${attachment}"} msg]
      if {$err != 0} {
         gren_erreur "ERROR: unable to launch thunderbird ($msg)"
      }
      
   }

}

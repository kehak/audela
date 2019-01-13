## @file bdi_gui_reports_mail.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de gestion des rapports d'analyse - envoie des rapports
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_mail.tcl]
#  @endcode

# $Id: bdi_gui_reports_mail.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_reports::send_mail_reports { p_from } {

   upvar $p_from from

   global bddconf 


   set curselection [$from curselection]
   set ::bdi_gui_reports::mail_nb_batch [llength $curselection]
   if {$::bdi_gui_reports::mail_nb_batch==0} {return}

   set ::bdi_gui_reports::mail_list_batch ""    
   set ::bdi_gui_reports::mail_list_fmt   ""  
   array unset ::bdi_gui_reports::mail_tabfile
   set list_uniq [ list obj type iau_code firstdate batch ]
   set ::bdi_gui_reports::mail_body ""
   
   array unset tab_info

   foreach select $curselection {

      set batch      [lindex [$from get $select] 0]
      set firstdate  [lindex [$from get $select] 1]
      set obj        [lindex [$from get $select] 2]
      set type       [lindex [$from get $select] 3]
      set iau_code   [lindex [$from get $select] 4]
      
      gren_info "Construction du mail  \n"
      gren_info "     batch     = $batch    \n"
      gren_info "     obj       = $obj      \n"
      gren_info "     firstdate = $firstdate\n"

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt info_txt
            lappend ::bdi_gui_reports::mail_tabfile(info_txt) $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)

            # Construction du Sujet du Mail
            ::bdi_tools_reports::file_info_to_list $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) list_info
            array set tab_info_f $list_info
            
            append ::bdi_gui_reports::mail_body "\n"
            append ::bdi_gui_reports::mail_body "\[OBSERVATION\]\[${type}\]\[$iau_code\]\[$firstdate\]\[$obj\]\n"
            append ::bdi_gui_reports::mail_body "   Batch        : $batch\n"
            append ::bdi_gui_reports::mail_body "   Nb Dates     : $tab_info_f(nb_dates)\n"
            append ::bdi_gui_reports::mail_body "   Seeing (\")   : $tab_info_f(fwhm_mean)\n"
            append ::bdi_gui_reports::mail_body "   Duration (h) : $tab_info_f(duration)\n"
            
            # Union
            foreach key $list_uniq {
               if {![info exists tab_info($key)]} {
                  set tab_info($key) $tab_info_f($key)
               } else {
                  if {$tab_info($key) != $tab_info_f($key)} {
                     set tab_info($key) "***"
                  }
               }
            }
         }
      }

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,txt,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,txt,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt ${type}_txt
            lappend ::bdi_gui_reports::mail_tabfile(${type}_txt) $::bdi_tools_reports::tab_batch($batch,$obj,$type,txt,rootfile)
         }
      }

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt ${type}_xml
            lappend ::bdi_gui_reports::mail_tabfile(${type}_xml) $::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile)
         }
      }

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,fms,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,fms,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt ${type}_fms
            lappend ::bdi_gui_reports::mail_tabfile(${type}_fms) $::bdi_tools_reports::tab_batch($batch,$obj,$type,fms,rootfile)
         }
      }

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,radec,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,radec,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt ${type}_radec
            lappend ::bdi_gui_reports::mail_tabfile(${type}_radec) $::bdi_tools_reports::tab_batch($batch,$obj,$type,radec,rootfile)
         }
      }

      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile) ]} { 
         if {[file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)]} {
            lappend ::bdi_gui_reports::mail_list_fmt ${type}_mpc
            lappend ::bdi_gui_reports::mail_tabfile(${type}_mpc) $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)
         }
      }

   }

   set type      $tab_info(type)
   set iau_code  $tab_info(iau_code)
   set firstdate $tab_info(firstdate)
   set obj       $tab_info(obj)
   set batch     $tab_info(batch)
   set ::bdi_gui_reports::mail_subject "\[OBSERVATION\]\[${type}\]\[$iau_code\]\[$firstdate\]\[$obj\] $batch"

   set ::bdi_gui_reports::mail_list_fmt [lsort -unique $::bdi_gui_reports::mail_list_fmt]

   set l [list info_txt "Fichier Info" astrom_txt "Astrom TXT" astrom_xml "Astrom XML" \
           astrom_mpc "Astrom MPC" astrom_fms "Astrom Famous" astrom_radec "Astrom GENOIDE radec" \
           photom_txt "Photom TXT" photom_xml "Photom XML" photom_mpc "Photom MPC" \
           photom_fms "Photom Famous"]
   array set ::bdi_gui_reports::mail_tablab $l
   set l [list info_txt 1 astrom_txt 1 astrom_xml 1 \
           astrom_mpc 1 astrom_fms 1 astrom_radec 1 \
           photom_txt 1 photom_xml 1 photom_mpc 1 \
           photom_fms 1]
   array set ::bdi_gui_reports::mail_tabcheck $l
   
   # Lancement GUI
   ::bdi_gui_reports::mail_build_window
   
   return
}



proc ::bdi_gui_reports::build_mail { type batch file } {
   
   global conf
   
   gren_info "Archive : \n"
   gren_info "Archive : \n"



   switch $type {
      "astrom_mpc" {
         set desti $conf(bddimages,astrometry,reports,mail)
         
      }
      "photom_txt" {
         set desti $conf(bddimages,photometry,reports,mail)
      }
   }

   set chan [open $file r]
   set strl ""
   while {[gets $chan line] >= 0} {
      append strl "$line\n"
   }
   close $chan
   puts $strl

  ::bdi_tools::sendmail::compose_with_thunderbird $desti $batch $strl

}



proc ::bdi_gui_reports::mail_close_window { } {

   global conf bddconf 

   set conf(bddimages,geometry_reports_mail) [wm geometry $::bdi_gui_reports::fen_mail]
   set bddconf(geometry_reports_mail) [wm geometry $::bdi_gui_reports::fen_mail]
   destroy $::bdi_gui_reports::fen_mail
}



proc ::bdi_gui_reports::mail_apply_window { } {

   global bddconf conf
   variable thunderbird "/usr/bin/thunderbird"

   gren_erreur "send mail\n"
   set cpt 0
   foreach fmt $::bdi_gui_reports::mail_list_fmt {
      if {$::bdi_gui_reports::mail_tabcheck($fmt) == 1} {
         gren_info "$fmt\n"
         incr cpt
      }
   }
   if {$cpt == 0 } {
      tk_messageBox -message "Vous devez selectionner au moins 1 format de fichier" -type ok
      return
   }

   set dir_out [file join $bddconf(dirtmp) "reports_send"]
   set arch [file join $bddconf(dirtmp) "reports_send.tar.bz2"]
   set err [catch {file delete -force $arch} msg]
   if {$err} {
      tk_messageBox -message "Impossible de supprimer ce repertoire : \n\n$dir_out\n\n$msg" -type ok
      return
   }
   set err [catch {file delete -force $dir_out} msg]
   if {$err} {
      tk_messageBox -message "Impossible de supprimer ce repertoire : \n\n$dir_out\n\n$msg" -type ok
      return
   }
   createdir_ifnot_exist $dir_out

   set attachment ""
   foreach fmt $::bdi_gui_reports::mail_list_fmt {

      if {$::bdi_gui_reports::mail_tabcheck($fmt) == 0} {continue}

      foreach file $::bdi_gui_reports::mail_tabfile($fmt) {

         append attachment "file://${file},"
         set err [catch {file copy -force $file $dir_out/} msg]
         if {$err} {
            gren_erreur "Impossible de copier ce fichier : $file\n"
            continue
         }
         
      }
   }
   
   if {$::bdi_gui_reports::mail_arch_window == 1 } {
      
      gren_info "Construction de l archive $dir_out\n"
      # TODO ! mettre un chemin absolu pour l archivage et envoie par mail des rapports
      set err [catch {exec tar jcvf $arch reports_send} msg]
      if {$err} {
         gren_erreur "Impossible d archiver ce repertoire : $dir_out\n"
         gren_erreur "$err\n"
         gren_erreur "$msg\n"
         return
      }
      
      set attachment "file://${arch},"
   }
   

      set body "Hi !\n"
      append body "\n"
      append body "You should find attached all files corresponding to the reduction of this set of observations.\n"
      append body "A short header are present here :\n"
      append body "\n"
      append body $::bdi_gui_reports::mail_body

      set to $conf(bddimages,astrometry,reports,mail)

      if {$attachment != "" } {
         set attachment [string range $attachment 0 end-1]
         set attachment ",attachment='${attachment}'"
      }

gren_info "---\n"
gren_info "MAIL:\n"
gren_info "to:${to}\n"
gren_info "subject:${::bdi_gui_reports::mail_subject}\n"
gren_info "body:${body}\n"
gren_info "attachment:${attachment}\n"
gren_info "---\n"
gren_info "thunderbird --compose to='${to}',subject='${::bdi_gui_reports::mail_subject}',body='${body}'${attachment}\n"
gren_info "---\n"


      set err [catch {exec $thunderbird --compose "to='${to}',subject='${::bdi_gui_reports::mail_subject}',body='${body}'${attachment}"} msg]
      if {$err != 0} {
         gren_erreur "ERROR: unable to launch thunderbird ($msg)"
      }

#      set desti "fv@imcce.fr"
#      set batch "batch"
#      set strl  "strl"
#     ::bdi_tools::sendmail::compose_with_thunderbird $desti $batch $strl

   
   return
}







#------------------------------------------------------------
## Fenetre de clicouillage avant soumission par email
#  @return void
#
proc ::bdi_gui_reports::mail_build_window { } {

   global audace caption color
   global conf bddconf 
   
   #--- Initialisation des parametres
   if {$::bdi_gui_reports::mail_nb_batch == 1 } {
      set ::bdi_gui_reports::mail_arch_window 0
   } else {
      set ::bdi_gui_reports::mail_arch_window 1
   }
   
   gren_info "Envoi de mail\n"

   set highprec "no"
   set widthlab 30
   set widthentry 30
   set ::bdi_gui_reports::fen_mail .mail_reports

   #--- Geometry
   if { ! [ info exists conf(bddimages,geometry_reports_mail) ] } {
      set conf(bddimages,geometry_reports_mail) "+300+800"
   }
   set bddconf(geometry_reports_mail) $conf(bddimages,geometry_reports_mail)

   #--- Declare la GUI
   if { [ winfo exists $::bdi_gui_reports::fen_mail ] } {
      wm withdraw $::bdi_gui_reports::fen_mail
      wm deiconify $::bdi_gui_reports::fen_mail
      return
   }

   #--- GUI
   toplevel $::bdi_gui_reports::fen_mail -class Toplevel
   wm geometry $::bdi_gui_reports::fen_mail $bddconf(geometry_reports_mail)
   wm resizable $::bdi_gui_reports::fen_mail 1 1
   wm title $::bdi_gui_reports::fen_mail $caption(bddimages_go,reports)
   wm protocol $::bdi_gui_reports::fen_mail WM_DELETE_WINDOW { ::bdi_gui_reports::mail_close_window }

   set frm $::bdi_gui_reports::fen_mail.appli
   frame $frm  -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_reports::fen_mail -anchor s -side top -expand yes -fill both -padx 10 -pady 5

   set mail $frm
   set wdth 14
   
      #--- Formats
      set block [frame $mail.fmt  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mail -side top -expand 0 -fill x -padx 2 -pady 5
      
            label  $block.lab -text "Selection des formats : " \
                      -borderwidth 1 
            pack   $block.lab -side top -padx 3 -pady 1 -anchor w
            
            foreach fmt $::bdi_gui_reports::mail_list_fmt {
               checkbutton $block.$fmt  -highlightthickness 0 -text $::bdi_gui_reports::mail_tablab($fmt) \
                        -variable ::bdi_gui_reports::mail_tabcheck($fmt)
               pack   $block.$fmt -side top -padx 3 -pady 1 -anchor w
            }

      #--- Archive ?
      set block [frame $mail.exped  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mail -side top -expand 0 -fill x -padx 2 -pady 5

            checkbutton $block.arch  -highlightthickness 0 -text "Archiver" \
                     -variable ::bdi_gui_reports::mail_arch_window
            pack   $block.arch -side left -padx 3 -pady 1 -anchor w

      #--- Onglet RAPPORT - mail
      set block [frame $mail.flag  -borderwidth 0 -cursor arrow -relief groove]
      pack $block  -in $mail -side top -expand 0 -fill x -padx 2 -pady 5

            button   $block.flag -text "Send Mail" -borderwidth 2 \
                     -command "::bdi_gui_reports::mail_apply_window"
            pack   $block.flag -side left -padx 3 -pady 1 -anchor w

            button   $block.fermer -text "Fermer" -borderwidth 2 \
                     -command "::bdi_gui_reports::mail_close_window"
            pack   $block.fermer -side left -padx 3 -pady 1 -anchor w






}








#------------------------------------------------------------
## Soumission quelconque
#  @return void
#
proc ::bdi_gui_reports::submit_reports { } {


   global conf
   global bddconf
   variable thunderbird "/usr/bin/thunderbird"

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
      set err [catch {exec $thunderbird --compose "to='${to}',subject='${subject}',body='${body}'${attachment}"} msg]
      if {$err != 0} {
         gren_erreur "ERROR: unable to launch thunderbird ($msg)"
      }

   }

} 


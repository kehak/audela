## @file bdi_gui_reports_mail.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de gestion des rapports d'analyse
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_mail.tcl]
#  @endcode

# $Id: bdi_gui_reports_mail.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_reports::get_uaicode { line char } {

   set pos [string last "IAU code" $line]
   if {$pos == -1} {return -1}
   set pos [expr [string last $char $line] +1]
   set uaicode [string trim [string range $line $pos end]]

}


proc ::bdi_gui_reports::get_submit { file } {

   set pos [string last "submit." $file]
   if {$pos == -1} {return no}
   set pos [expr $pos + 7 ]
   set file [string range $file $pos end]
   set pos [expr [string first "." $file] -1 ]
   return [string range $file 0 $pos]
}



#------------------------------------------------------------
## Effacement des entrees
#  @return void
#
proc ::bdi_gui_reports::delete_reports { p_from } {

   global  bddconf

   upvar $p_from from

   set curselection [$from curselection]
   set nb [llength $curselection]
   
   set l ""
   foreach select $curselection {
      set batch [string range [lindex [$from get $select] 0] 0 29]
      append l "$batch\n"
   }
   
   if { $nb == 1 } {
      set r [tk_messageBox -message "Etes vous sur de vouloir supprimer ce rapport ?\n\n$l" -type yesno]
   } else {
      set r [tk_messageBox -message "Etes vous sur de vouloir supprimer ces $nb rapports ?\n\n$l" -type yesno]
   }
   if { $r == "no" } { return }

   foreach select $curselection {

      set batch     [lindex [$from get $select] 0]
      set firstdate [lindex [$from get $select] 1]
      set obj       [lindex [$from get $select] 2]
      gren_info "Suppression de \n"
      gren_info "     batch     = $batch    \n"
      gren_info "     obj       = $obj      \n"
      gren_info "     firstdate = $firstdate\n"

      set dir_obj       [file join $bddconf(dirreports) ASTROPHOTOM $obj ]
      set dir_firstdate [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate]
      set dir_batch     [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]

      set err [catch {file delete -force $dir_batch } msg]
      if {$err} {
         gren_erreur $msg
         continue
      }

      set err [ catch { set rglob [glob -dir $dir_firstdate *] } msg ]
      if {$err==0} {
         # il y a un fichier dans le repetoire FIRSTDATE
         continue
      }
      set err [catch {file delete -force $dir_firstdate } msg]
      if {$err} {
         gren_erreur $msg
         continue
      }

      set err [ catch { set rglob [glob -dir $dir_obj *] } msg ]
      if {$err==0} {
         # il reste un fichier dans le repetoire OBJ
         continue
      }
      set err [catch {file delete -force $dir_obj } msg]
      if {$err} {
         gren_erreur $msg
         continue
      }

   }

   ::bdi_tools_reports::charge
   return
}




#------------------------------------------------------------
## Lancement de l outil d analyse
#  @return void
#
proc ::bdi_gui_reports::analysis { p_from } {

   global  bddconf

   upvar $p_from from

   set curselection [$from curselection]
   set nb [llength $curselection]
   if { $nb == 0 } {
      tk_messageBox -message "Veuillez selectionner au moins un rapport" -type ok
      return
   }
   
   set gentype ""
   set infiles ""
   
   foreach select $curselection {

      set batch     [lindex [$from get $select] 0]
      set firstdate [lindex [$from get $select] 1]
      set obj       [lindex [$from get $select] 2]
      set type      [lindex [$from get $select] 3]

      set iau       [lindex [$from get $select] 4]
      set duree     [lindex [$from get $select] 5]
      set fwhm      [lindex [$from get $select] 6]
      set mag       [lindex [$from get $select] 8]
      set prec      [lindex [$from get $select] 11]
      set nbpts     [lindex [$from get $select] 21]

      set expo     "Nan"
      set bin      "Nan"

      lappend infiles [list $batch $firstdate $obj $type $iau $duree $fwhm $mag $prec $nbpts $expo $bin]
      
      if {$gentype == ""} {
         set gentype $type
      } else {
         if {$gentype != $type} {
            tk_messageBox -message "Veuillez selectionner des rapports du meme type (photom ou astrom)" -type ok
            return
         }
      }

   }

   ::bdi_gui_analysis::run $infiles
   return
}




#------------------------------------------------------------
## affiche dans la console le repertoire des donnees
#  @return void
#
proc ::bdi_gui_reports::get_workdir_reports { } {

   global  bddconf

   set obj $::bdi_gui_reports::selected_obj
   set firstdate $::bdi_gui_reports::selected_firstdate

   set curselection [$::bdi_tools_reports::data_report curselection]
   foreach select $curselection {

      set obj       [lindex [$::bdi_tools_reports::data_report get $select] 2]
      set firstdate [lindex [$::bdi_tools_reports::data_report get $select] 1]
      set batch     [lindex [$::bdi_tools_reports::data_report get $select] 0]
      #gren_info "firstdate = $firstdate\n"
      #gren_info "batch = $batch\n"

      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]
      gren_info "Repertoire de travail = $dir \n"
   }
}

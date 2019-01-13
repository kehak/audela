## @file bdi_gui_reports_export.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de gestion des rapports d'analyse - export des donn&eacute;es
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_export.tcl]
#  @endcode

# $Id: bdi_gui_reports_export.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_reports::export_close {  } {
   destroy .export
}


proc ::bdi_gui_reports::export {  } {

   global bddconf

   # Construction de la liste des batch
   set curselection [$::bdi_tools_reports::data_report curselection]
   set nb [llength $curselection]
   
   gren_info "nb batch = $nb\n"

   set astrom 0
   set photom 0
   set ::bdi_tools_reports::export_batch_list ""
   set cpt 0
   foreach select $curselection {
      $::bdi_tools_reports::data_report cellconfigure $select,0 -font $bddconf(font,arial_10_b)
      set line [$::bdi_tools_reports::data_report get $select]
      set batch     [lindex $line 0]
      set firstdate [lindex $line 1]
      set obj       [lindex $line 2]
      set type      [lindex $line 3]

      if {$cpt == 0 } {
         set same_obj  $obj
         set same_type $type
      } else {
         if {$same_obj != $obj} {
            tk_messageBox -message "L'exportation doit concerner le meme objet" -type ok
            return
         }
         if {$same_type != $type} {
            tk_messageBox -message "L'exportation doit concerner le meme type de donnees (Astrometrique ou Photometrique)" -type ok
            return
         }
      }
      incr cpt
      
      if {$type=="astrom"} { incr astrom }
      if {$type=="photom"} { incr photom }
      lappend ::bdi_tools_reports::export_batch_list $obj $firstdate $batch
      gren_info "Batch : $batch\n"
   }

   if { $cpt > 1} {
      set newbatch [::bdi_tools_reports::get_batch]
      gren_info "New Batch $newbatch\n"
   } else {
      set newbatch ""
   }

   if { $astrom > 0 && $photom > 0} {
         tk_messageBox -message "Veuillez selectionner des rapports de meme type, soit astrometrique, soit photometrique, mais pas les deux." -type ok
         return
   }
   if { $astrom == 0 && $photom == 0} {
         tk_messageBox -message "Veuillez selectionner un ou des rapports" -type ok
         return
   }
   if { $astrom > 0 && $photom == 0} {
         set type "astrom"
         set title "Export Astrometrique"
   }
   if { $astrom == 0 && $photom > 0} {
         set type "photom"
         set title "Export Photometrique"
   }
   
   #--- Geometry
   if { ! [ info exists conf(bddimages,export,geometry) ] } {
      set conf(bddimages,export,geometry) "100x100+400+200"
   }
   set bddconf(export,geometry) $conf(bddimages,export,geometry)
   set geometry $conf(bddimages,export,geometry)
   set geometry "+378+233"
   set title $title
   
   #--- Declare la GUI
   set fen .export
   if { [ winfo exists $fen ] } {
      wm withdraw $fen
      wm deiconify $fen
      return
   }

   #--- Main Window
   toplevel $fen -class Toplevel
   wm geometry $fen $geometry
#      wm resizable $fen 1 1
   wm title $fen $title
   wm protocol $fen WM_DELETE_WINDOW "::bdi_gui_reports::export_close"

   set frm $fen.appli

   frame $frm  -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      label       $frm.newbatch -text "New Batch"  -font $bddconf(font,arial_10_b)
      checkbutton $frm.concat  -highlightthickness 0 -text "Concatenation XML Votable" -variable ::bdi_tools_reports::export_concat
      checkbutton $frm.famous  -highlightthickness 0 -text "Format Famous" -variable ::bdi_tools_reports::export_famous
      checkbutton $frm.genoide -highlightthickness 0 -text "Format Genoide" -variable ::bdi_tools_reports::export_genoide
      
      if {$nb > 1} {
         set ::bdi_tools_reports::export_concat 1
         grid $frm.newbatch  -sticky news -columnspan 2 -padx 5 -pady 2
         grid $frm.concat    -sticky nws -columnspan 2 -padx 5 -pady 2
         $frm.concat configure -state disabled
      }
      grid $frm.famous  -sticky nws -columnspan 2 -padx 5 -pady 2
      grid $frm.genoide -sticky nws -columnspan 2 -padx 5 -pady 2

      button $frm.export  -state active -text "Exporter" -relief "raised" \
         -command "::bdi_tools_reports::export $type $newbatch; ::bdi_gui_reports::export_close"
      button $frm.close  -state active -text "Fermer" -relief "raised" \
         -command "::bdi_gui_reports::export_close"

      grid $frm.export $frm.close -sticky news -padx 5 -pady 2

   # Application du theme
   ::confColor::applyColor $fen

}

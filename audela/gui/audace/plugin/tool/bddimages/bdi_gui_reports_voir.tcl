## @file bdi_gui_reports_voir.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI de gestion des rapports d'analyse - affichage des rapports
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_voir.tcl]
#  @endcode

# $Id: bdi_gui_reports_voir.tcl 13117 2016-05-21 02:00:00Z jberthier $

proc ::bdi_gui_reports::view_reports_gui {  } {

   global conf bddconf

   set ::bdi_gui_reports::view_list [list "Info TXT" "Astrom TXT" "Astrom XML" "Astrom Famous" "Astrom MPC" \
                 "Photom TXT" "Photom XML" "Photom Famous" "Photom MPC"]
   set ::bdi_gui_reports::viewfile "Info TXT"

   #--- Geometry
   if { ! [ info exists conf(bddimages,view_reports,geometry) ] } {
      set conf(bddimages,view_reports,geometry) "980x600+28+31"
   }
   set geometry $conf(bddimages,view_reports,geometry)
   set title "Voir les rapports"
   
   #--- Declare la GUI
   set fen .view_reports
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
   wm protocol $fen WM_DELETE_WINDOW "::bdi_gui_reports::view_reports_close"

   set frm $fen.appli

   frame $frm  -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

      frame $frm.but -cursor arrow -relief groove
      pack $frm.but -in $frm -side top -expand no -fill x -padx 10 -pady 5


         label  $frm.but.w_labview -text "View File :" -borderwidth 1 -width 12
         
         menubutton $frm.but.w_viewfile -relief sunken -borderwidth 2 -width 12 \
                       -textvariable ::bdi_gui_reports::viewfile \
                       -menu $frm.but.w_viewfile.list

         set menuconfig [menu $frm.but.w_viewfile.list -tearoff 1 ]
         foreach myview $::bdi_gui_reports::view_list {
            $menuconfig add radiobutton -label $myview -value $myview \
               -variable ::bdi_gui_reports::viewfile \
               -command ""
         }
         
         label  $frm.but.w_labobj   -text "Obj :" -borderwidth 1 -width 6
         label  $frm.but.w_obj      -textvariable ::bdi_gui_reports::selected_obj -font $bddconf(font,arial_10_b)
         label  $frm.but.w_labbatch -text "Batch :" -borderwidth 1 -width 8
         label  $frm.but.w_batch    -textvariable ::bdi_gui_reports::selected_batch -font $bddconf(font,arial_10_b)

         grid $frm.but.w_labview $frm.but.w_viewfile $frm.but.w_labobj $frm.but.w_obj $frm.but.w_labbatch $frm.but.w_batch
         

         button $frm.but.info_txt  -state active -text "Info TXT" -relief "raised" \
            -command "" -state disabled

         button $frm.but.astrom_txt  -state active -text "Astrom TXT" -relief "raised" \
            -command "" -state disabled
         button $frm.but.astrom_xml  -state active -text "Astrom XML" -relief "raised" \
            -command "" -state disabled
         button $frm.but.astrom_fms  -state active -text "Astrom Famous" -relief "raised" \
            -command "" -state disabled
         button $frm.but.astrom_mpc -state active -text "Astrom MPC" -relief "raised" \
            -command "" -state disabled

         button $frm.but.photom_txt  -state active -text "Photom TXT" -relief "raised" \
            -command "" -state disabled
         button $frm.but.photom_xml  -state active -text "Photom XML" -relief "raised" \
            -command "" -state disabled
         button $frm.but.photom_fms  -state active -text "Photom Famous" -relief "raised" \
            -command "" -state disabled
         button $frm.but.photom_mpc  -state active -text "Photom MPC" -relief "raised" \
            -command "" -state disabled

         button $frm.but.close  -state active -text "Fermer" -relief "raised" \
            -command "::bdi_gui_reports::view_reports_close"

#            grid $frm.but.info_txt  $frm.but.astrom_txt $frm.but.astrom_xml $frm.but.astrom_fms $frm.but.astrom_mpc \
#                                    $frm.but.photom_txt $frm.but.photom_xml $frm.but.photom_fms $frm.but.photom_mpc

         #  pack $frm.but.astrom_txt -in $frm -side left
         #  pack $frm.but.astrom_xml -in $frm -side left
         #  pack $frm.but.astrom_fms -in $frm -side left
         #  pack $frm.but.astrom_mpc -in $frm -side left
         #  pack $frm.but.photom_txt -in $frm -side left
         #  pack $frm.but.photom_xml -in $frm -side left
         #  pack $frm.but.photom_fms -in $frm -side left
         #  pack $frm.but.photom_mpc -in $frm -side left

      frame $frm.txt  -cursor arrow -relief groove
      pack $frm.txt -in $frm -side top -expand yes -fill both 

         set rapport $frm.txt.text
         text $rapport -height 30 -width 80 \
              -xscrollcommand "$rapport.xscroll set" \
              -yscrollcommand "$rapport.yscroll set" \
              -wrap none
         #grid $rapport -sticky news  -columnspan 8
         pack $rapport -in $frm.txt -side top -expand yes -fill both 

         scrollbar $rapport.xscroll -orient horizontal -cursor arrow -command "$rapport xview"
         pack $rapport.xscroll -side bottom -fill x

         scrollbar $rapport.yscroll -orient vertical -cursor arrow -command "$rapport yview"
         pack $rapport.yscroll -side right -fill y

         $rapport delete 0.0 end


}






proc ::bdi_gui_reports::view_reports { p_from } {

   upvar $p_from from

   global bddconf

   # Construction de la liste des batch
   set curselection [$from curselection]
   set nb [llength $curselection]
   if { $nb != 1 } {
      tk_messageBox -message "Veuillez selectionner un seul rapport" -type ok
      return
   }
   
   # GUI Seulement
   set ::bdi_gui_reports::selected_batch ""
   ::bdi_gui_reports::view_reports_gui
   
   # tout ce qui correspond au batch

   set select [lindex $curselection 0]
   set n [$from size]
   for {set i 0} {$i < $n} {incr i} {
      if {$i == $select} {
         $from cellconfigure $select,0 -font $bddconf(font,arial_10_b)
         

         set obj   [lindex [$from get $select] 2]
         set batch [lindex [$from get $select] 0]
         gren_info "OBJ= $obj\n"
         gren_info "BATCH= $batch\n"
         
         set ::bdi_gui_reports::selected_batch $batch
         ::bdi_gui_reports::view_reports_affichage $obj $batch
         
      } else {
         $from cellconfigure $i,0 -font $bddconf(font,arial_10)
      }
   }
   
   return
}







proc ::bdi_gui_reports::view_reports_affichage { obj batch } {
   
   # si la fenetre principale n existe pas , on sort
   set fen .view_reports
   if { ! [ winfo exists $fen ] } { return }

   # 
   set firstdate $::bdi_tools_reports::tab_batch($obj,$batch,firstdate)
   set ::bdi_gui_reports::selected_obj   $obj
   set ::bdi_gui_reports::selected_batch $batch
   set ::bdi_gui_reports::view_list ""

   # 
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,file)]} {
       lappend ::bdi_gui_reports::view_list "Info TXT"
   } else {
      gren_erreur "Info TXT not exist ! $batch,$obj\n"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,astrom,txt,file)]} {
       lappend ::bdi_gui_reports::view_list "Astrom TXT"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,astrom,xml,file)]} {
       lappend ::bdi_gui_reports::view_list "Astrom XML"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,astrom,fms,file)]} {
       lappend ::bdi_gui_reports::view_list "Astrom Famous"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,astrom,mpc,file)]} {
       lappend ::bdi_gui_reports::view_list "Astrom MPC"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,photom,txt,file)]} {
       lappend ::bdi_gui_reports::view_list "Photom TXT"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,photom,xml,file)]} {
       lappend ::bdi_gui_reports::view_list "Photom XML"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,photom,fms,file)]} {
       lappend ::bdi_gui_reports::view_list "Photom Famous"
   }
   if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,photom,mpc,file)]} {
       lappend ::bdi_gui_reports::view_list "Photom MPC"
   }
   
   if {$::bdi_gui_reports::viewfile ni $::bdi_gui_reports::view_list} {
      set ::bdi_gui_reports::viewfile [lindex $::bdi_gui_reports::view_list 0]
   }
   
   # GUI definition
   set frm $fen.appli
   set menuconfig $frm.but.w_viewfile.list
   set rapport $frm.txt.text
   
   #set menuconfig .view_reports.appli.but.w_viewfile.list
   #set rapport .view_reports.appli.txt.text

   $menuconfig delete 0 end
   $rapport delete 0.0 end

   # aucun fichier present
   set nb  [llength $::bdi_gui_reports::view_list]
   if {$nb == 0 } {
      set ::bdi_gui_reports::viewfile "No Files"
      return
   }

   # il existe au moins un fichier
   if {![info exists ::bdi_gui_reports::viewfile]} {
      set ::bdi_gui_reports::viewfile [lindex $::bdi_gui_reports::view_list 0]
   }
   
   foreach myview $::bdi_gui_reports::view_list {
      $menuconfig add radiobutton -label $myview -value $myview \
         -variable ::bdi_gui_reports::viewfile \
         -command "::bdi_gui_reports::view_reports_affichage $obj $batch"
   }
   
   if { $::bdi_gui_reports::viewfile == "Info TXT" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Astrom TXT" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,astrom,txt,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Astrom XML" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,astrom,xml,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Astrom Famous" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,astrom,fms,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Astrom MPC" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,astrom,mpc,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Photom TXT" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,photom,txt,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Photom XML" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,photom,xml,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Photom Famous" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,photom,fms,rootfile)
   }
   if { $::bdi_gui_reports::viewfile == "Photom MPC" } {
      set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,photom,mpc,rootfile)
   }
   
   if {[file exists $rootfile]} {
      set chan [open $rootfile r]
      while {[gets $chan line] >= 0} {
         $rapport insert end "$line\n"
      }
      close $chan
      # Ajout de 2 sauts de ligne pour remonter ce qui est trop bas.
      $rapport insert end "\n"
      $rapport insert end "\n"
   }
}


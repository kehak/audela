## @file bdi_gui_astroid.tcl
#  @brief     Environnement de cr&eacute;ation de cata en mode multithread  
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_astroid.tcl]
#  @endcode

# $Id: bdi_gui_astroid.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_astroid
# @brief Environnement de cr&eacute;ation de cata en mode multithread  
# @pre Requiert \c bdi_tools_astroid .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_astroid {

}

proc ::bdi_gui_astroid::fermer {  } {

   destroy $::bdi_gui_astroid::fen
   ::audace::psf_close_to_conf $::audace(visuNo)

}
proc ::bdi_gui_astroid::stop {  } {
   set ::bdi_tools_astroid::stop 1
}

proc ::bdi_gui_astroid::ressource {  } {

   console::clear
   ::bddimages::ressource
   ::bdi_gui_astroid::fermer
   ::bdi_gui_astroid::astroid
   puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"

   gren_info "*** [llength [thread::names]] threads exists\n"
}

proc ::bdi_gui_astroid::go {  } {

   gren_info "Lancement avec $::bdi_tools_astroid::nb_threads threads\n"
   ::bdi_tools_astroid::go

}



proc ::bdi_gui_astroid::astroid {  } {
   
   global private

   ::audace::psf_init $::audace(visuNo)

   set ::bdi_tools_astroid::progress 0

   set fen .astroid
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
   wm title $fen "Astroid"
   wm protocol $fen WM_DELETE_WINDOW "::bdi_gui_astroid::fermer"

   set frm $fen.appli

   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $fen -anchor s -side top -expand 1 -fill both -padx 10 -pady 5

      set  psf  [frame $frm.psf -borderwidth 1 -cursor arrow -relief groove]
      pack $psf -in $frm -anchor c -side top -expand 0 -padx 10 -pady 5

         ::audace::psf_gui_methodes $::audace(visuNo) $psf

      set  threads  [frame $frm.threads -borderwidth 1 -cursor arrow -relief groove]
      pack $threads -in $frm -anchor c -side top -expand 0 -padx 10 -pady 5


          label   $threads.a -text "Nb threads : " 
          pack    $threads.a -side left -padx 2 -pady 0
          spinbox $threads.nb -from 1 -to 32 -increment 1 -width 3 \
                         -command {gren_info "nb_threads = $::bdi_tools_astroid::nb_threads \n"} \
                         -textvariable ::bdi_tools_astroid::nb_threads
          pack    $threads.nb -side left -padx 2 -pady 0

      set  info  [frame $frm.info -borderwidth 1 -cursor arrow -relief groove]
      pack $info -in $frm -anchor c -side top -expand 0 -padx 10 -pady 5

          label $info.a -text " duree = " 
          pack  $info.a -side left -padx 2 -pady 0
          label $info.b -textvariable duree
          pack  $info.b -side left -padx 2 -pady 0
          label $info.c -text " sec" 
          pack  $info.c -side left -padx 2 -pady 0

      set data  [frame $frm.progress -borderwidth 0 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

          set    pf [ ttk::progressbar $data.p -variable ::bdi_tools_astroid::progress -orient horizontal -length 200 -mode determinate]
          pack   $pf -in $data -side top

      set data  [frame $frm.boutons -borderwidth 1 -cursor arrow -relief groove]
      pack $data -in $frm -anchor s -side top -expand 0 -padx 10 -pady 5

          button $data.fermer -state active -text "Fermer" -relief "raised" \
             -command "::bdi_gui_astroid::fermer"
#             pack   $data.fermer -side right -anchor e -padx 0 -padx 10 -pady 5

          button $data.ressource -state active -text "Ressource" -relief "raised" \
             -command "::bdi_gui_astroid::ressource"

          button $data.annul -state active -text "Stop" -relief "raised" \
             -command "::bdi_gui_astroid::stop"
#             pack   $data.annul -side top -anchor c -padx 0 -padx 10 -pady 5

          button $data.go -state active -text "Go" -relief "raised" \
             -command "::bdi_gui_astroid::go"
#             pack   $data.go -side left -anchor w -padx 0 -padx 10 -pady 5

          grid $data.go         -row 0 -column 0 -sticky nws  -padx 10 -pady 5
          grid $data.ressource  -row 0 -column 1 -sticky news -padx 10 -pady 5
          grid $data.annul      -row 0 -column 2 -sticky news -padx 10 -pady 5
          grid $data.fermer     -row 0 -column 3 -sticky nes  -padx 10 -pady 5
          # -columnspan 2 -ipadx 10 -ipady 10 -padx 10 -pady 10
}

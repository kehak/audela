## @file bddimages_infocam.tcl
#  @brief     D&eacute;termination du gain et du DARK limite
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_infocam.tcl]
#  @endcode

# $Id: bddimages_infocam.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bddimages_infocam
# @brief D&eacute;termination du gain et du DARK limite
# @pre Requiert le fichier d'internationalisation \c bddimages_infocam.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_infocam {

}


proc ::bddimages_infocam::showReport { {title "Console"} {ltexte "Empty"} {format ""} } {

   variable This
   global audace
   global caption
   global color
   global imgConsole

   set imgConsole $This.report
   if { [ winfo exists $imgConsole ] } {
      destroy $imgConsole
   }

   toplevel $imgConsole -class Toplevel
   wm title $imgConsole "BddImages - Console"
   wm positionfrom $imgConsole user
   wm sizefrom $imgConsole user
   wm resizable $imgConsole 1 1
   wm geometry $imgConsole "400x200"
   wm protocol $imgConsole WM_DELETE_WINDOW { 
      destroy $imgConsole 
   }

   set zonetext $imgConsole.text
   text $zonetext -height 30 -width 80 -yscrollcommand "$zonetext.scroll set"
   pack $zonetext -expand yes -fill both -padx 5 -pady 5
   scrollbar $zonetext.scroll -command "$zonetext yview"
   pack $zonetext.scroll -side right -fill y

   $zonetext tag configure BODY -foreground black -background white
   $zonetext tag configure TITLE -foreground "#808080" -justify center -font [ list {Arial} 12 bold ] 
   $zonetext tag configure H1 -justify left -font [ list {Arial} 10 normal ] -wrap word
   $zonetext tag configure H2 -justify left -font [ list {Arial} 10 normal ] -foreground $color(blue) -wrap word 
   $zonetext tag configure LISTE0 -foreground $color(black) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure LISTE1 -foreground $color(red) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure GREEN -foreground $color(green) -wrap word
   $zonetext tag configure RED -foreground $color(red) -wrap word

   $zonetext insert end "$title \n\n" TITLE
   foreach t $ltexte { 
      $zonetext insert end "* [lindex $t 0] : [lindex $t 1] \n" $format
   }

}





proc ::bddimages_infocam::calcul { type } {


   if {$type == "gain"}  {
      set nlist ""
      set cpt 0
      foreach img $::bddimages_imgcorrection::dark_img_list {
         incr cpt
         lappend nlist $img
         if {$cpt >= 2} {break}
      }
      set ::bddimages_imgcorrection::dark_img_list $nlist
      set nlist ""
      set cpt 0
      foreach img $::bddimages_imgcorrection::flat_img_list {
         incr cpt
         lappend nlist $img
         if {$cpt >= 2} {break}
      }
      set ::bddimages_imgcorrection::flat_img_list $nlist
      
      ::bddimages_imgcorrection::copy_to_tmp "dark" $::bddimages_imgcorrection::dark_img_list
      ::bddimages_imgcorrection::copy_to_tmp "flat" $::bddimages_imgcorrection::flat_img_list 
      set r [electronic_chip gainnoise dark0 dark1 flat0 flat1]
      catch { file delete -force  dark0.fit dark1.fit flat0.fit flat1.fit } 
   }


   if {$type == "darklimit"}  {

      ::bddimages_imgcorrection::copy_to_tmp "dark" $::bddimages_imgcorrection::dark_img_list

   }

}



#--------------------------------------------------
# run_create { this }
#--------------------------------------------------
#
#    fonction  :
#        Creation de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_infocam::run_create { this type } {
   
   variable This
   global audace bddconf caption
   global entetelog

   # Type de correction (e.g. flat)
   set ::bddimages_infocam::type $type

   # Recuperation des informations des images selectionnees
   set selection_list [::bddimages_imgcorrection::get_info_img]

   # Initialisations
   # Initialisations
   set ::bddimages_imgcorrection::offset_img_list  ""
   set ::bddimages_imgcorrection::soffset_img_list ""
   set ::bddimages_imgcorrection::dark_img_list    ""
   set ::bddimages_imgcorrection::sdark_img_list   ""
   set ::bddimages_imgcorrection::flat_img_list    ""
   set ::bddimages_imgcorrection::sflat_img_list   ""
   set ::bddimages_imgcorrection::deflat_img_list  ""
   set ::bddimages_imgcorrection::erreur_selection 0
   set ::bddimages_infocam::erreur_selection 0

   set reportMessage ""
   set reportFilename ""

   # Definition des vignettes
   image create photo icon_ok
   icon_ok configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
   image create photo icon_no
   icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
   image create photo icon_warn
   icon_warn configure -file [file join $audace(rep_plugin) tool bddimages icons warn.gif]
   image create photo icon_report
   icon_report configure -file [file join $audace(rep_plugin) tool bddimages icons report.gif]

   # Affichage de la fenetre
   set entetelog "$caption(bddimages_infocam,main_title)"
   set This $this

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   toplevel $This -class Toplevel
   wm title $This $entetelog
   wm positionfrom $This user
   wm sizefrom $This user
   wm resizable $This 0 0

   set framecurrent $This.framename
   frame $framecurrent
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame de titre
   frame $framecurrent.title
   pack configure $framecurrent.title -side top -fill x
   switch $::bddimages_infocam::type {
      gain        { set title [concat $caption(bddimages_infocam,creation) $caption(bddimages_infocam,gain)     ] }
      darklimit   { set title [concat $caption(bddimages_infocam,creation) $caption(bddimages_infocam,darklimit)] }
   }

   label $framecurrent.title.e -font $bddconf(font,arial_10_b) -text $title
   pack configure $framecurrent.title.e -side top -anchor c -padx 3 -pady 3 -fill x 

   # Images d'entree
   frame $framecurrent.input -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.input -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.input.title
      pack configure $framecurrent.input.title -side top -fill x
         label $framecurrent.input.title.t -relief groove -text "$caption(bddimages_infocam,input)" 
         pack $framecurrent.input.title.t -in $framecurrent.input.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set inputFrame $framecurrent.input.tab
      frame $inputFrame
      pack configure $inputFrame -side top -expand 0
         frame $inputFrame.filetype
         pack configure $inputFrame.filetype -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filenb
         pack configure $inputFrame.filenb -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filestatus
         pack configure $inputFrame.filestatus -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filereport
         pack configure $inputFrame.filereport -side left -fill x -padx 2 -pady 1


   # ------------------------------------------------------------------
   #                     Creation d'un OFFSET MAITRE 
   # ------------------------------------------------------------------
   if {$type == "gain"}  {

      # Chargement de la liste dark
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]

      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_infocam,indark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi < 2 } {
         set ::bddimages_infocam::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "dark" $caption(bddimages_infocam,nodark)]
         lappend reportFilename [list "dark" $caption(bddimages_infocam,nofile)]
      }  else {
         set ::bddimages_imgcorrection::dark_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }

      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # -----------------------

      # Chargement de la liste FLAT
      set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.flat -text "$caption(bddimages_infocam,inflat)"
      pack $inputFrame.filetype.flat -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.flat -text $nbi
      pack $inputFrame.filenb.flat -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi < 2} {
         set ::bddimages_infocam::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master flat" $caption(bddimages_infocam,oneflat)]
         lappend reportFilename [list "master flat" $caption(bddimages_infocam,nofile)]
      }  else {
         set ::bddimages_imgcorrection::flat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "flat" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.flat -image $icon
      pack $inputFrame.filestatus.flat -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # -----------------------

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.dark -image icon_report \
          -command [list ::bddimages_infocam::showReport $caption(bddimages_infocam,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.dark -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     Creation d'un OFFSET MAITRE 
   # ------------------------------------------------------------------
   if {$type == "darklimit"}  {

      # Chargement de la liste dark
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]

      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_infocam,indark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi < 2 } {
         set ::bddimages_infocam::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "dark" $caption(bddimages_infocam,nodark)]
         lappend reportFilename [list "dark" $caption(bddimages_infocam,nofile)]
      }  else {
         set ::bddimages_imgcorrection::dark_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }

      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w


   }

   # Concatenation des listes et verifications
   if {$::bddimages_infocam::erreur_selection == 0} {
      # 
      set err [catch {::bddimages_imgcorrection::verif_all_img} msg]
      if {$err}  {
         ::console::affiche_erreur "Verif Erreur : $err\n"
         ::console::affiche_erreur "msg=$msg\n"
         
         set ::bddimages_infocam::erreur_selection 1
         lappend reportMessage [list $::bddimages_infocam::type $msg]
      }
   }
   
   # Frame boutons Cancel et Ok
   frame $framecurrent.buttons
   pack configure $framecurrent.buttons -side top -fill x -padx 3 -pady 3

   # --- ok
   if {$::bddimages_infocam::erreur_selection == 0} {
     button $framecurrent.buttons.ok -text Ok \
        -command {
           ::bddimages_infocam::calcul $::bddimages_infocam::type
           destroy $::bddimages_infocam::This
        }
     pack configure $framecurrent.buttons.ok -side right
   }
   # --- cancel
   button $framecurrent.buttons.cancel -text Cancel \
      -command {destroy $::bddimages_infocam::This}
   pack configure $framecurrent.buttons.cancel -side right

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
   #--- Surcharge la couleur de fond des resultats
   $framecurrent.title.e configure -font $bddconf(font,arial_10_b)

   grab set $This
   tkwait window $This
}

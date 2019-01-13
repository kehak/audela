#*****************************************************************************#
#                                                                             #
# Boîtes graphiques TK de saisie des paramètres pour les focntoins Spcaudace  #
#                                                                             #
#*****************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_boxes.tcl

# Mise a jour $Id: spc_gui_boxes.tcl 10302 2013-10-02 17:34:36Z bmauclaire $



########################################################################
# Boîte graphique de saisie des paramètres pour la fonction spc_export2png
# Intitulé : Exportation au format PNG
#
# Auteurs : Benjamin Mauclaire
# Date de création : 05-03-2007
# Date de modification : 05-03-2007
# Utilisée par : spc_export2png
# Args : nom_profil_de_raies_fits
########################################################################

namespace eval ::param_spc_audace_export2png {

   source [ file join [file dirname [info script]] spc_gui_boxes.cap ]

   proc run { args {positionxy 20+20} } {
      global conf audace color caption
      global spcaudace

      set audace(param_spc_audace,export2png,config,spectre) [ lindex $args 0 ]
      #set spectre [ lindex $args 0 ]
      set lambdarange [ lindex $args 1 ]
      set ldeb [ lindex $lambdarange 0 ]
      set lfin [ lindex $lambdarange 1 ]
      set listevalmotsclef [ lindex $args 2 ]
      #-- Recupere et isole le premiere elelemnt quie est NOM_OBJET :
      #set len [ llength [
      #set listevalmots [ lrange


      if { [ string length [ info commands .param_spc_audace_export2png.* ] ] != "0" } {
         destroy .param_spc_audace_export2png
      }


      # === Initialisation des variables qui seront changées :
      set i 1
      foreach valmot $listevalmotsclef {
	  if { $valmot != "" } {
	      set valmot [ string trim $valmot " " ]
	      set audace(param_spc_audace,export2png,config,mot$i) $valmot
	  }
	  incr i
      }


      set audace(param_spc_audace,export2png,config,lambda_deb) $ldeb
      set audace(param_spc_audace,export2png,config,lambda_fin) $lfin
      set audace(param_spc_audace,export2png,config,ydeb) "*"
      set audace(param_spc_audace,export2png,config,yfin) "*"


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,export2png,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,export2png,color,backpad) #ECE9D8
      set audace(param_spc_audace,export2png,color,backdisp) $color(white)
      set audace(param_spc_audace,export2png,color,textdisp) #FF0000
      set audace(param_spc_audace,export2png,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,export2png,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_export2png de niveau le plus haut
      toplevel .param_spc_audace_export2png -class Toplevel -bg $audace(param_spc_audace,export2png,color,backpad)
      wm geometry .param_spc_audace_export2png 408x397+10+10
      wm resizable .param_spc_audace_export2png 1 1
      wm title .param_spc_audace_export2png $caption(spcaudace,boxes,export2png,titre)
      wm protocol .param_spc_audace_export2png WM_DELETE_WINDOW "::param_spc_audace_export2png::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_export2png.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,boxes,export2png,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey)
      pack .param_spc_audace_export2png.title \
	      -in .param_spc_audace_export2png -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_export2png.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,export2png,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_export2png.stop_button  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,stop_button)" \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) \
	      -command {::param_spc_audace_export2png::annuler}
      pack  .param_spc_audace_export2png.stop_button -in .param_spc_audace_export2png.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_export2png.return_button  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,return_button)" \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) \
	      -command {::param_spc_audace_export2png::go}
      pack  .param_spc_audace_export2png.return_button -in .param_spc_audace_export2png.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_export2png.buttons -in .param_spc_audace_export2png -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Message sur les caractères non autorisés :
      label .param_spc_audace_export2png.message1 \
	      -font [ list {Arial} 12 bold ] -text $caption(spcaudace,boxes,export2png,caractere)  \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey)
      pack .param_spc_audace_export2png.message1 \
	      -in .param_spc_audace_export2png -fill x -side top -pady 15


       if { 1== 0 } {
      #--- Label + Entry pour spectre
      frame .param_spc_audace_export2png.spectre -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.spectre.label -text "$caption(spcaudace,boxes,export2png,config,spectre)" -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,export2png,font,c12b)
      pack  .param_spc_audace_export2png.spectre.label -in .param_spc_audace_export2png.spectre -side left -fill none
      button .param_spc_audace_export2png.spectre.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -command { set audace(param_spc_audace,export2png,config,spectre) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_export2png.spectre.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_export2png.spectre.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,spectre) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 100
      pack  .param_spc_audace_export2png.spectre.entry -in .param_spc_audace_export2png.spectre -side left -fill none
      pack .param_spc_audace_export2png.spectre -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour nom_objet
      frame .param_spc_audace_export2png.nom_objet -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.nom_objet.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,nom_objet) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.nom_objet.label -in .param_spc_audace_export2png.nom_objet -side left -fill none
      entry  .param_spc_audace_export2png.nom_objet.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,nom_objet) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.nom_objet.entry -in .param_spc_audace_export2png.nom_objet -side left -fill none
      pack .param_spc_audace_export2png.nom_objet -in .param_spc_audace_export2png -fill none -pady 1 -padx 12
      }

      #--- Label + Entry pour mot1
      frame .param_spc_audace_export2png.mot1 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot1.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,mot1) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot1.label -in .param_spc_audace_export2png.mot1 -side left -fill none
      entry  .param_spc_audace_export2png.mot1.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot1) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot1.entry -in .param_spc_audace_export2png.mot1 -side left -fill none
      pack .param_spc_audace_export2png.mot1 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

       #--- Label + Entry pour mot2
      frame .param_spc_audace_export2png.mot2 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot2.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,mot2) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot2.label -in .param_spc_audace_export2png.mot2 -side left -fill none
      entry  .param_spc_audace_export2png.mot2.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot2) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot2.entry -in .param_spc_audace_export2png.mot2 -side left -fill none
      pack .param_spc_audace_export2png.mot2 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour mot3
      frame .param_spc_audace_export2png.mot3 -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.mot3.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,mot3) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.mot3.label -in .param_spc_audace_export2png.mot3 -side left -fill none
      entry  .param_spc_audace_export2png.mot3.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,mot3) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.mot3.entry -in .param_spc_audace_export2png.mot3 -side left -fill none
      pack .param_spc_audace_export2png.mot3 -in .param_spc_audace_export2png -fill none -pady 1 -padx 12


      #--- Label + Entry pour lambda_deb
      frame .param_spc_audace_export2png.lambda_deb -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.lambda_deb.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,lambda_deb) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.lambda_deb.label -in .param_spc_audace_export2png.lambda_deb -side left -fill none
      entry  .param_spc_audace_export2png.lambda_deb.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,lambda_deb) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.lambda_deb.entry -in .param_spc_audace_export2png.lambda_deb -side left -fill none
      pack .param_spc_audace_export2png.lambda_deb -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour lambda_fin
      frame .param_spc_audace_export2png.lambda_fin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.lambda_fin.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,lambda_fin) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.lambda_fin.label -in .param_spc_audace_export2png.lambda_fin -side left -fill none
      entry  .param_spc_audace_export2png.lambda_fin.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,lambda_fin) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.lambda_fin.entry -in .param_spc_audace_export2png.lambda_fin -side left -fill none
      pack .param_spc_audace_export2png.lambda_fin -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour ydeb
      frame .param_spc_audace_export2png.ydeb -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.ydeb.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,ydeb) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.ydeb.label -in .param_spc_audace_export2png.ydeb -side left -fill none
      entry  .param_spc_audace_export2png.ydeb.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,ydeb) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.ydeb.entry -in .param_spc_audace_export2png.ydeb -side left -fill none
      pack .param_spc_audace_export2png.ydeb -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

      #--- Label + Entry pour yfin
      frame .param_spc_audace_export2png.yfin -borderwidth 0 -relief flat -bg $audace(param_spc_audace,export2png,color,backpad)
      label .param_spc_audace_export2png.yfin.label  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -text "$caption(spcaudace,boxes,export2png,config,yfin) " -bg $audace(param_spc_audace,export2png,color,backpad) \
	      -fg $audace(param_spc_audace,export2png,color,textkey) -relief flat
      pack  .param_spc_audace_export2png.yfin.label -in .param_spc_audace_export2png.yfin -side left -fill none
      entry  .param_spc_audace_export2png.yfin.entry  \
	      -font $audace(param_spc_audace,export2png,font,c12b) \
	      -textvariable audace(param_spc_audace,export2png,config,yfin) -bg $audace(param_spc_audace,export2png,color,backdisp) \
	      -fg $audace(param_spc_audace,export2png,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_export2png.yfin.entry -in .param_spc_audace_export2png.yfin -side left -fill none
      pack .param_spc_audace_export2png.yfin -in .param_spc_audace_export2png -fill none -pady 1 -padx 12

  }


  proc go {} {
      global audace spcaudace
      global caption
      global nomprofilpng

      ::param_spc_audace_export2png::recup_conf
      set spectre $audace(param_spc_audace,export2png,config,spectre)
      set nom_objet $audace(param_spc_audace,export2png,config,mot1)
      set mot2 $audace(param_spc_audace,export2png,config,mot2)
      set mot3 $audace(param_spc_audace,export2png,config,mot3)
      set lambda_deb $audace(param_spc_audace,export2png,config,lambda_deb)
      set lambda_fin $audace(param_spc_audace,export2png,config,lambda_fin)
      set ydeb $audace(param_spc_audace,export2png,config,ydeb)
      set yfin $audace(param_spc_audace,export2png,config,yfin)
      set listevalmots [ list $nom_objet $mot2 $mot3 ]

      #--- Mise à jour des mots clef et création du graphique :
      if { $nom_objet!="" && $mot2!="" && $mot3!=""  && $lambda_deb!="" && $lambda_fin!="" && $ydeb!="" && $yfin!="" } {
	  #-- Mise à jour des mots clef :
	  buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	  foreach valmot $listevalmots mot $spcaudace(motsheader) def $spcaudace(motsheaderdef) {
	      buf$audace(bufNo) setkwd [ list "$mot" "$valmot" string "$def" "" ]
	  }
	  buf$audace(bufNo) bitpix float
	  buf$audace(bufNo) save "$audace(rep_images)/$spectre"
	  buf$audace(bufNo) bitpix short
	  set listeargs [ list $spectre $listevalmots ]

	  #-- Conversion en PNG :
	  set nomprofilpng [ spc_autofit2png $spectre "$nom_objet" $lambda_deb $lambda_fin $ydeb $yfin ]
	  destroy .param_spc_audace_export2png
	  return $nomprofilpng
      } else {
	  tk_messageBox -title $caption(spcaudace,boxes,export2png,titre)  -icon error -message $caption(spcaudace,boxes,erreur,saisie)
	  return 0
      }
  }

  proc annuler {} {
      global audace
      global nomprofilpng

      ::param_spc_audace_export2png::recup_conf
      destroy .param_spc_audace_export2png
      set nomprofilpng ""
      return 0
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_export2png ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [wm geometry .param_spc_audace_export2png]
	  set deb [expr 1+[string first + $geom ]]
	  set fin [string length $geom]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#





########################################################################
# Boîte graphique de saisie des paramètres pour la fonction spc_traitenebula
# Intitulé : Coordonnées de la zone du spectre
#
# Auteurs : Benjamin Mauclaire
# Date de création : 31-07-2007
# Date de modification : 31-07-2007
# Utilisée par : spc_traitenebula
# Args : spectre_2D liste_coordonnees_initiales_zone
########################################################################

namespace eval ::param_spc_audace_selectzone {

   proc run { args {positionxy 20+20} } {
      global conf caption audace
      global spcaudace
      global color


      set audace(param_spc_audace,selectzone,config,spectre) [ lindex $args 0 ]
      loadima "$audace(rep_images)/$audace(param_spc_audace,selectzone,config,spectre)"
      ::confVisu::autovisu 1
      set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1]
      set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1]
      set spc_windowcoords [ list 1 1 $naxis1 $naxis2 ]


      if { [ string length [ info commands .param_spc_audace_selectzone.* ] ] != "0" } {
         destroy .param_spc_audace_selectzone
      }


      #--- Initialisation des champs :
      set audace(param_spc_audace,selectzone,config,xinf) 1
      set audace(param_spc_audace,selectzone,config,yinf) 1
      set audace(param_spc_audace,selectzone,config,xsup) $naxis1
      set audace(param_spc_audace,selectzone,config,ysup) $naxis2


      # === Variables d'environnement
      # backpad : #F0F0FF
      set audace(param_spc_audace,selectzone,color,textkey) $color(blue_pad)
      set audace(param_spc_audace,selectzone,color,backpad) #ECE9D8
      set audace(param_spc_audace,selectzone,color,backdisp) $color(white)
      set audace(param_spc_audace,selectzone,color,textdisp) #FF0000
      set audace(param_spc_audace,selectzone,font,c12b) [ list {Arial} 10 bold ]
      set audace(param_spc_audace,selectzone,font,c10b) [ list {Arial} 10 bold ]

      # === Met en place l'interface graphique

      #--- Cree la fenetre .param_spc_audace_selectzone de niveau le plus haut
      toplevel .param_spc_audace_selectzone -class Toplevel -bg $audace(param_spc_audace,selectzone,color,backpad)
      wm geometry .param_spc_audace_selectzone 408x372-35-15
      wm resizable .param_spc_audace_selectzone 1 1
      wm title .param_spc_audace_selectzone $caption(spcaudace,boxes,selectzone,titre)
      wm protocol .param_spc_audace_selectzone WM_DELETE_WINDOW "::param_spc_audace_selectzone::annuler"

      #--- Create the title
      #--- Cree le titre
      label .param_spc_audace_selectzone.title \
	      -font [ list {Arial} 16 bold ] -text $caption(spcaudace,boxes,selectzone,titre2) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey)
      pack .param_spc_audace_selectzone.title \
	      -in .param_spc_audace_selectzone -fill x -side top -pady 15

      # --- Boutons du bas
      frame .param_spc_audace_selectzone.buttons -borderwidth 1 -relief raised -bg $audace(param_spc_audace,selectzone,color,backpad)
      #-- Bouton Annuler
      button .param_spc_audace_selectzone.stop_button  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,stop_button)" \
	      -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) \
	      -command {::param_spc_audace_selectzone::annuler}
      pack  .param_spc_audace_selectzone.stop_button -in .param_spc_audace_selectzone.buttons -side left -fill none -padx 3 -pady 3
      #-- Bouton OK
      button .param_spc_audace_selectzone.return_button  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,return_button)" \
	      -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) \
	      -command {::param_spc_audace_selectzone::go}
      pack  .param_spc_audace_selectzone.return_button -in .param_spc_audace_selectzone.buttons -side right -fill none -padx 3 -pady 3
      pack .param_spc_audace_selectzone.buttons -in .param_spc_audace_selectzone -fill x -pady 0 -padx 0 -anchor s -side bottom


      #--- Message sur les caractères non autorisés :
      label .param_spc_audace_selectzone.message1 \
	      -font [ list {Arial} 12 bold ] -text $caption(spcaudace,boxes,selectzone,aide) \
	      -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey)
      pack .param_spc_audace_selectzone.message1 \
	      -in .param_spc_audace_selectzone -fill x -side top -pady 15


      #--- Label + Entry pour spectre
      frame .param_spc_audace_selectzone.spectre -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.spectre.label -text "$caption(spcaudace,boxes,selectzone,config,spectre)" -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat \
	      -font $audace(param_spc_audace,selectzone,font,c12b)
      pack  .param_spc_audace_selectzone.spectre.label -in .param_spc_audace_selectzone.spectre -side left -fill none
      button .param_spc_audace_selectzone.spectre.explore -text "$caption(spcaudace,gui,parcourir)" -width 1 \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief raised \
	      -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -command { set audace(param_spc_audace,selectzone,config,spectre) [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] }
      pack .param_spc_audace_selectzone.spectre.explore -side left -padx 7 -pady 3 -ipady 0
      entry  .param_spc_audace_selectzone.spectre.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,spectre) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 100
      pack  .param_spc_audace_selectzone.spectre.entry -in .param_spc_audace_selectzone.spectre -side left -fill none
      pack .param_spc_audace_selectzone.spectre -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12

       if { 1== 0 } {
      #--- Label + Entry pour nom_objet
      frame .param_spc_audace_selectzone.nom_objet -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.nom_objet.label  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,config,nom_objet) " -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat
      pack  .param_spc_audace_selectzone.nom_objet.label -in .param_spc_audace_selectzone.nom_objet -side left -fill none
      entry  .param_spc_audace_selectzone.nom_objet.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,nom_objet) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_selectzone.nom_objet.entry -in .param_spc_audace_selectzone.nom_objet -side left -fill none
      pack .param_spc_audace_selectzone.nom_objet -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12
      }

      #--- Label + Entry pour xinf
      frame .param_spc_audace_selectzone.xinf -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.xinf.label  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,config,xinf) " -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat
      pack  .param_spc_audace_selectzone.xinf.label -in .param_spc_audace_selectzone.xinf -side left -fill none
      entry  .param_spc_audace_selectzone.xinf.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,xinf) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_selectzone.xinf.entry -in .param_spc_audace_selectzone.xinf -side left -fill none
      pack .param_spc_audace_selectzone.xinf -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12

       #--- Label + Entry pour yinf
      frame .param_spc_audace_selectzone.yinf -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.yinf.label  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,config,yinf) " -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat
      pack  .param_spc_audace_selectzone.yinf.label -in .param_spc_audace_selectzone.yinf -side left -fill none
      entry  .param_spc_audace_selectzone.yinf.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,yinf) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_selectzone.yinf.entry -in .param_spc_audace_selectzone.yinf -side left -fill none
      pack .param_spc_audace_selectzone.yinf -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12


      #--- Label + Entry pour xsup
      frame .param_spc_audace_selectzone.xsup -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.xsup.label  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,config,xsup) " -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat
      pack  .param_spc_audace_selectzone.xsup.label -in .param_spc_audace_selectzone.xsup -side left -fill none
      entry  .param_spc_audace_selectzone.xsup.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,xsup) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_selectzone.xsup.entry -in .param_spc_audace_selectzone.xsup -side left -fill none
      pack .param_spc_audace_selectzone.xsup -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12


      #--- Label + Entry pour ysup
      frame .param_spc_audace_selectzone.ysup -borderwidth 0 -relief flat -bg $audace(param_spc_audace,selectzone,color,backpad)
      label .param_spc_audace_selectzone.ysup.label  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -text "$caption(spcaudace,boxes,selectzone,config,ysup) " -bg $audace(param_spc_audace,selectzone,color,backpad) \
	      -fg $audace(param_spc_audace,selectzone,color,textkey) -relief flat
      pack  .param_spc_audace_selectzone.ysup.label -in .param_spc_audace_selectzone.ysup -side left -fill none
      entry  .param_spc_audace_selectzone.ysup.entry  \
	      -font $audace(param_spc_audace,selectzone,font,c12b) \
	      -textvariable audace(param_spc_audace,selectzone,config,ysup) -bg $audace(param_spc_audace,selectzone,color,backdisp) \
	      -fg $audace(param_spc_audace,selectzone,color,textdisp) -relief flat -width 70
      pack  .param_spc_audace_selectzone.ysup.entry -in .param_spc_audace_selectzone.ysup -side left -fill none
      pack .param_spc_audace_selectzone.ysup -in .param_spc_audace_selectzone -fill none -pady 1 -padx 12

  }


  proc go {} {
      global audace spcaudace
      global caption

      global spc_windowcoords

      ::param_spc_audace_selectzone::recup_conf
      set spectre $audace(param_spc_audace,selectzone,config,spectre)
      set xinf $audace(param_spc_audace,selectzone,config,xinf)
      set yinf $audace(param_spc_audace,selectzone,config,yinf)
      set xsup $audace(param_spc_audace,selectzone,config,xsup)
      set ysup $audace(param_spc_audace,selectzone,config,ysup)
      set listevalmots [ list $spectre $xinf $yinf $xsup $ysup ]

      #--- Mise à jour des mots clef et création du graphique :
      if { $spectre!="" && $xinf!="" && $yinf!=""  && $xsup!="" && $ysup!="" } {
	  set spc_windowcoords [ list $xinf $yinf $xsup $ysup ]
	  destroy .param_spc_audace_selectzone
	  return $spc_windowcoords
      } else {
	  tk_messageBox -title caption(spcaudace,boxes,selectzone,titre) -icon error -message $caption(spcaudace,boxes,erreur,saisie)
	  return 0
      }
  }

  proc annuler {} {
      global audace
      global caption
      global nomprofilpng

      ::param_spc_audace_selectzone::recup_conf
      destroy .param_spc_audace_selectzone
      set nomprofilpng ""
      return 0
  }


  proc recup_conf {} {
      global conf
      global audace

      if { [ winfo exists .param_spc_audace_selectzone ] } {
	  #--- Enregistre la position de la fenetre
	  set geom [ wm geometry .param_spc_audace_selectzone ]
	  set deb [ expr 1+[string first + $geom ] ]
	  set fin [ string length $geom ]
	  set conf(param_spc_audace,position) "[string range  $geom $deb $fin]"
      }
  }


}
#****************************************************************************#

#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_extraction.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_extraction.tcl
# Description    : Utilitaires d'extraction des images fits a partir de la video
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_extraction.tcl 14091 2016-10-20 21:52:15Z jberthier $
#

namespace eval ::atos_extraction {

   variable jpegformat 0

}

#
# Chargement des captions
#
proc ::atos_extraction::init { } {
   global audace

   wm focusmodel . passive
   wm withdraw .
   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool atos atos_extraction.cap ]
}



#
# Initialisation des variables de configuration
#
proc ::atos_extraction::initToConf { visuNo } {
   variable parametres

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                 { set ::atos::parametres(atos,$visuNo,messages)                 "1" }
   if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }            { set ::atos::parametres(atos,$visuNo,save_file_log)            "1" }
   if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }         { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1" }
   if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] } { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1" }
   if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }    { set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1" }
}



#
# Charge la configuration dans des variables locales
#
proc ::atos_extraction::confToWidget { visuNo } {
   variable parametres
   global panneau

   #--- confToWidget
   set ::atos_extraction::panneau(atos,$visuNo,messages)                 $::atos::parametres(atos,$visuNo,messages)
   set ::atos_extraction::panneau(atos,$visuNo,save_file_log)            $::atos::parametres(atos,$visuNo,save_file_log)
   set ::atos_extraction::panneau(atos,$visuNo,alarme_fin_serie)         $::atos::parametres(atos,$visuNo,alarme_fin_serie)
   set ::atos_extraction::panneau(atos,$visuNo,verifier_ecraser_fichier) $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
   set ::atos_extraction::panneau(atos,$visuNo,verifier_index_depart)    $::atos::parametres(atos,$visuNo,verifier_index_depart)

   set ::atos_tools::traitement "avi"

}



#
# Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#
proc ::atos_extraction::widgetToConf { visuNo } {
   variable parametres
   global panneau

}



#
# Cree la fenetre de configuration de l'affichage des messages sur la Console
# et de l'enregistrement des dates dans le fichier log
#
proc ::atos_extraction::run { visuNo this } {

  global audace panneau

   set panneau(atos,$visuNo,atos_extraction) $this
   ::atos_extraction::createdialog $this $visuNo

}



#
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#
proc ::atos_extraction::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
      [ ::atos::getPluginDirectory ] atos_extraction.htm
}



#
# Fonction appellee lors de l'appui sur le bouton 'Fermer'
#
proc ::atos_extraction::closeWindow { this visuNo } {

   ::atos_extraction::widgetToConf $visuNo
   destroy $this
}



#
# Creation de l'interface graphique
#
proc ::atos_extraction::createdialog { this visuNo } {

   package require Img

   global caption panneau atosconf color audace

   #--- Determination de la fenetre parente
   if { $visuNo == "1" } {
      set base "$audace(base)"
   } else {
      set base ".visu$visuNo"
   }

   #--- Creation de la fenetre
   if { [winfo exists $this] } {
      wm withdraw $this
      wm deiconify $this
      focus $this
      return
   }
   toplevel $this -class Toplevel

   set posx_config [ lindex [ split [ wm geometry $base ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $base ] "+" ] 2 ]
   wm geometry $this +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $this 1 1
   wm title $this $caption(atos_extraction,titre)
   wm protocol $this WM_DELETE_WINDOW "::atos_extraction::closeWindow $this $visuNo"

   #--- Charge la configuration de la vitesse de communication dans une variable locale
   ::atos_extraction::confToWidget $visuNo

   #--- Retourne l'item de la camera associee a la visu
   set frm $this.frm_atos_extraction
   set ::atos_gui::frame(base) $frm

   #--- Cree un frame pour afficher la gui
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

     #--- Cree un label pour le titre
     label $frm.titre -font $atosconf(font,arial_14_b) -text "$caption(atos_extraction,titre)"
     pack $frm.titre -in $frm -side top -padx 3 -pady 3

     #--- Cree un frame pour
     frame $frm.open -borderwidth 1 -relief raised -cursor arrow
     pack $frm.open -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

         #--- Creation du bouton open
         button $frm.open.but_open \
            -text "$caption(atos_extraction,ouvrir)" -borderwidth 2 \
            -command "::atos_tools::open_flux $visuNo"
         pack $frm.open.but_open \
            -side left -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Creation du bouton select
         button $frm.open.but_select \
            -text "..." -borderwidth 2 -takefocus 1 \
            -command "::atos_tools::select $visuNo"
         pack $frm.open.but_select \
            -side left -anchor e \
            -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

         #--- Cree un label pour le chemin de l'AVI
         entry $frm.open.avipath
         pack $frm.open.avipath -side left -padx 3 -pady 1 -expand true -fill x

     set info_load [frame $frm.info_load]
     pack $info_load -in $frm -side top  -padx 1 -pady 1

        #--- Cree un label pour le nb d image
        label $info_load.status -font $atosconf(font,courier_10) -text ""
        #--- Cree un label pour le nb d image
        label $info_load.nbtotal -font $atosconf(font,courier_10) -text ""
        grid $info_load.status $info_load.nbtotal

     set ::atos_gui::frame(info_load) $info_load

     #--- Creation de la barre de defilement
     scale $frm.scrollbar -from 0 -to 1 -length 600 -variable ::atos_tools::scrollbar \
        -label "" -orient horizontal \
        -state disabled
     pack $frm.scrollbar -in $frm -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     set ::atos_gui::frame(scrollbar) $frm.scrollbar

     #--- Cree un frame pour afficher
     set btnav [frame $frm.btnav -borderwidth 0]
     pack $btnav -in $frm -side top

     #--- Creation du bouton quick prev image
     image create photo .arr -format PNG -file [ file join $audace(rep_plugin) tool atos img arr.png ]
     button $frm.qprevimage -image .arr\
        -borderwidth 2 -width 25 -height 25 -compound center \
        -command "::atos_tools::quick_prev_image $visuNo"
     pack $frm.qprevimage \
        -in $frm.btnav \
        -side left -anchor w \
        -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

     #--- Creation du bouton prev image
     image create photo .arn -format PNG -file [ file join $audace(rep_plugin) tool atos img arn.png ]
     button $frm.previmage -image .arn\
        -borderwidth 2 -width 25 -height 25 -compound center \
        -command "::atos_tools::prev_image $visuNo"
     pack $frm.previmage \
        -in $frm.btnav \
        -side left -anchor w \
        -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

     #--- Creation du bouton next image
     image create photo .avn -format PNG -file [ file join $audace(rep_plugin) tool atos img avn.png ]
     button $frm.nextimage -image .avn\
        -borderwidth 2 -width 25 -height 25 -compound center \
        -command "::atos_tools::next_image $visuNo"
     pack $frm.nextimage \
        -in $frm.btnav \
        -side left -anchor w \
        -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

     #--- Creation du bouton quick next image
     image create photo .avr -format PNG -file [ file join $audace(rep_plugin) tool atos img avr.png ]
     button $frm.qnextimage -image .avr\
        -borderwidth 2 -width 25 -height 25 -compound center \
        -command "::atos_tools::quick_next_image $visuNo"
     pack $frm.qnextimage \
        -in $frm.btnav \
        -side left -anchor w \
        -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

       #--- Affichage positions
       frame $frm.pos -borderwidth 1 -relief raised -cursor arrow
       pack $frm.pos -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

          #--- Creation du bouton setmin
          button $frm.pos.setmin \
             -text "$caption(atos_extraction,setmin)" -borderwidth 2 \
             -command "::atos_tools::setmin"
          pack $frm.pos.setmin \
             -in $frm.pos \
             -side left -anchor w \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Creation du bouton setmax
          button $frm.pos.setmax \
             -text "$caption(atos_extraction,setmax)" -borderwidth 2 \
             -command "::atos_tools::setmax"
          pack $frm.pos.setmax \
             -in $frm.pos \
             -side left -anchor w \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          #--- Cree un frame pour afficher
          frame $frm.pos.min -borderwidth 0
          pack $frm.pos.min -in $frm.pos -side left

             #--- Cree un label pour
             #entry $frm.datemin -fg $color(blue) -relief sunken
             #pack $frm.datemin -in $frm.pos.min -side top -pady 1 -anchor w
             #--- Cree un label pour
             entry $frm.posmin -fg $color(blue) -relief sunken
             pack $frm.posmin -in $frm.pos.min -side top -pady 1 -anchor w
             set ::atos_gui::frame(posmin) $frm.posmin

          #--- Cree un frame pour afficher
          frame $frm.pos.max -borderwidth 0
          pack $frm.pos.max -in $frm.pos -side left

            #--- Cree un label pour
            #entry $frm.datemax -fg $color(blue) -relief sunken
            #pack $frm.datemax -in $frm.pos.max -side top -pady 1 -anchor w
            #--- Cree un label pour
            entry $frm.posmax -fg $color(blue) -relief sunken
            pack $frm.posmax -in $frm.pos.max -side top -pady 1 -anchor w
            set ::atos_gui::frame(posmax) $frm.posmax

       #--- Cree un frame pour afficher
       frame $frm.count -borderwidth 0
       pack $frm.count -in $frm -side top -pady 10 -ipadx 5 -ipady 5

          #--- Cree un label
          label $frm.labnbimg -font $atosconf(font,courier_10) -padx 3 \
                -text "$caption(atos_extraction,nbimg)"
          pack $frm.labnbimg -in $frm.count -side left -pady 1 -anchor w

          #--- Cree un entry
          entry $frm.imagecount -fg $color(blue) -relief sunken -width 10
          pack $frm.imagecount -in $frm.count -side left -pady 1 -anchor w
          set ::atos_gui::frame(imagecount) $frm.imagecount

          #--- Cree un button
          button $frm.doimagecount \
           -text "$caption(atos_extraction,calcul)" -borderwidth 2 \
           -command "::atos_tools_avi::imagecount"
          pack $frm.doimagecount -in $frm.count -side left -padx 3 -pady 1 -anchor w

       #--- Cree un frame pour
       #frame $frm.status -borderwidth 0 -cursor arrow
       #pack $frm.status -in $frm -side top -expand 0
       #
       ##--- Cree un frame pour afficher les intitules
       #set intitle [frame $frm.status.l -borderwidth 0]
       #pack $intitle -in $frm.status -side left
       #
       #  #--- Cree un label pour le status
       #  label $intitle.status -font $atosconf(font,courier_10) -text "$caption(atos_extraction,statut)"
       #  pack $intitle.status -in $intitle -side top -anchor w
       #
       #  #--- Cree un label pour le nb d image
       #  label $intitle.nbtotal -font $atosconf(font,courier_10) -text "$caption(atos_extraction,nbtotal)"
       #  pack $intitle.nbtotal -in $intitle -side top -anchor w
       #
       ##--- Cree un frame pour afficher les valeurs
       #set inparam [frame $frm.status.v -borderwidth 0]
       #pack $inparam -in $frm.status -side left -expand 0 -fill x
       #
       #  #--- Cree un label pour le
       #  label $inparam.status -font $atosconf(font,courier_10) -fg $color(blue) -text "-"
       #  pack  $inparam.status -in $inparam -side top -anchor w
       #
       #  #--- Cree un label pour le
       #  label $inparam.nbtotal -font $atosconf(font,courier_10) -fg $color(blue) -text "-"
       #  pack  $inparam.nbtotal -in $inparam -side top -anchor w

     #--- Cree un frame pour
     frame $frm.form -borderwidth 1 -relief raised -cursor arrow
     pack $frm.form -in $frm -side top -expand 0 -fill x -padx 10 -pady 10 -ipadx 5 -ipady 5

       #--- Cree un frame pour afficher les intitules
       set intitle [frame $frm.form.l -borderwidth 0]
       pack $intitle -in $frm.form -side left

         #--- Cree un label pour le repertoire
         label $intitle.destdir -font $atosconf(font,courier_10) -padx 3 -text "$caption(atos_extraction,destdir)"
         pack $intitle.destdir -in $intitle -side top -padx 3 -pady 1 -anchor w

         #--- Cree un label pour le prefix
         label $intitle.prefix -font $atosconf(font,courier_10) -text "$caption(atos_extraction,prefix)"
         pack $intitle.prefix -in $intitle -side top -padx 3 -pady 1 -anchor w

         #--- Cree un label pour le format JPEG
         label $intitle.format -font $atosconf(font,courier_10) -text "$caption(atos_extraction,jpegformat)"
         pack $intitle.format -in $intitle -side top -padx 3 -pady 1 -anchor w

       #--- Cree un frame pour afficher les valeurs
       set inparam [frame $frm.form.v -borderwidth 0]
       pack $inparam -in $frm.form -side left -expand 0 -fill x

         #--- Cree un label pour le repetoire destination
         entry $inparam.destdir -fg $color(blue)
         pack $inparam.destdir -in $inparam -side top -padx 3 -pady 1 -anchor w

         #--- Cree un label pour le prefixe
         entry $inparam.prefix  -fg $color(blue)
         pack $inparam.prefix -in $inparam -side top -padx 3 -pady 1 -anchor w

         #--- Option de format: defaut = FITS, si coche = JPEG
         checkbutton $inparam.format -highlightthickness 0 -variable ::atos_extraction::jpegformat -state normal 
         pack $inparam.format -in $inparam -side top -padx 3 -pady 1 -anchor w

       #--- Cree un frame pour afficher les extras
       set inbutton [frame $frm.form.e -borderwidth 0]
       pack $inbutton -in $frm.form -side left -expand 0 -fill x

         #--- Cree un button
         button $inbutton.chgdir \
          -text "..." -borderwidth 2 \
          -command "::atos_tools::chgdir $inparam.destdir"
         pack $inbutton.chgdir -in $inbutton -side top -pady 0 -anchor w

         #--- Cree un label pour le nb d image
         label $inbutton.blank -font $atosconf(font,courier_10) -text ""
         pack $inbutton.blank -in $inbutton -side top -padx 3 -pady 1 -anchor w

     #--- Cree un frame pour  les boutons d action
     frame $frm.action -borderwidth 1 -relief raised -cursor arrow
     pack $frm.action -in $frm -side top -expand 0 -fill x -padx 1 -pady 1

        button $frm.action.extract \
           -text "$caption(atos_extraction,extract)" -borderwidth 2 \
           -command " ::atos_extraction::extract $visuNo"
        pack $frm.action.extract -in $frm.action \
           -side left -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton fermer
        button $frm.action.fermer \
           -text "$caption(atos_extraction,fermer)" -borderwidth 2 \
           -command "::atos_extraction::closeWindow $this $visuNo"
        pack $frm.action.fermer -in $frm.action \
           -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton aide
        button $frm.action.aide \
           -text "$caption(atos_extraction,aide)" -borderwidth 2 \
           -command "::audace::showHelpPlugin tool atos atos.htm"
        pack $frm.action.aide -in $frm.action \
           -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $this

}



proc ::atos_extraction::extract { visuNo } {
   global audace caption conf

   if {![info exists ::atos_tools::nb_open_frames]} {
      # Rien a faire car pas de video chargee
      ::console::affiche_erreur "No video loaded\n"
      return
   }

   set frm $::atos_gui::frame(base)
   set bufNo [ visu$visuNo buf ]

   set fmin [ $frm.posmin get ]
   set fmax [ $frm.posmax get ]
   if { $fmin == "" } { set fmin 1 }
   if { $fmax == "" } { set fmax $::atos_tools::nb_open_frames }
   ::atos_tools_avi::set_frame $fmin

   set destdir [ $frm.form.v.destdir get ]
   if { $destdir == "" } {
      tk_messageBox -message "$caption(atos_extraction,errordir)" -type ok
      return -1
   }

   set prefix [ $frm.form.v.prefix get ]
   if { $prefix == "" } {
      set prefix "i_"
      ::console::affiche_resultat "$caption(atos_extraction,warnprefix) $prefix\n"
   }

   set extension_img $conf(extension,defaut)
   set quality ""
   if {$::atos_extraction::jpegformat == 1} {
      set extension_img ".jpg"
      set quality "-quality 100"
   }

   ::console::affiche_resultat "$caption(atos_extraction,encours) $fmin - $fmax au format $extension_img ...\n"

   set cpt 1
   for {set i $fmin} {$i <= $fmax} {incr i} {
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe
      visu$visuNo disp
      set path "$destdir/$prefix$cpt$extension_img"

      set mycuts [ visu$visuNo cut ]
      buf$bufNo setkwd [ list "MIPS-HI" [ lindex $mycuts 0 ] float "" "" ]
      buf$bufNo setkwd [ list "MIPS-LO" [ lindex $mycuts 1 ] float "" "" ]

      buf$bufNo save $path $quality
      ::atos_tools_avi::next_image
      incr cpt
   }

   visu$visuNo disp
   tk_messageBox -message "$caption(atos_extraction,extractfin)" -type ok

}



#
# ::atos_extraction::test_avi_1
#
# Procedure de test de deplacement aleatoire dans un fichier avi.
# Les fonctions testees sont : set_frame, next_image, prev_image
#
# Utilisation:
#  1. Ouvrir une video dans l'outil Extraction Video AVI
#  2. Dans la console, taper:
#      ::atos_extraction::test_avi_1 1
#     en supposant que 1 est le numero de visu courant.
#
proc ::atos_extraction::test_avi_1_getsample {bufNo} {
          set key ""
          set y 53
          for {set x 300} {$x<=400} {incr x} {
              set v [lindex [buf$bufNo getpix "$x $y"] 1]
              set s [format %x [expr int($v)]]
              set key "$key$s"
          }
          return $key
}



proc ::atos_extraction::test_avi_1 { visuNo } {
      set bufNo [ visu$visuNo buf ]

      ::console::affiche_resultat "Indexation de la video...\n"
      set fmin 1
      set fmax $::atos_tools::nb_open_frames
      if {$fmax > 1000} {set fmax 1000}
      ::atos_tools_avi::set_frame 1
      set imagedict [dict create]
      for {set i $fmin} {$i <= $fmax} {incr i} {
         set key [::atos_extraction::test_avi_1_getsample $bufNo]
         if {[dict exists $imagedict $key]} {
            ::console::affiche_resultat "Clef non unique,\n"
            ::console::affiche_resultat "augmentez la longueur de l echantillon dans test_avi_1_getsample.\n"
            return 1
         }
         dict set imagedict $key $i
         ::atos_tools_avi::next_image
      }

      ::console::affiche_resultat "Parcours aleatoire...\n"
      for {set i 0} {$i < $fmax} {incr i} {
         set n [expr {int(rand()*($fmax))+1}]
         ::console::affiche_resultat "test frame $n\n"
         ::atos_tools_avi::set_frame $n
         set key [::atos_extraction::test_avi_1_getsample $bufNo]
         set m [dict get $imagedict $key]
         if {$m !=$n} {
            ::console::affiche_resultat "Echec.\n"
            return 1
         }

         for {set j 0} {$j < 10} {incr j} {
            # direction : 0, 1
            set dir [expr {int(rand()*2)}]
            set len [expr {int(rand()*11)}]
            #::console::affiche_resultat "sequence dir=$dir len=$len\n"
            for {set k 0} {$k < $len} {incr k} {
               if {$dir == 0} {
                  if {$n >= $fmax} {
                     set n $fmax
                  } else {
                     ::atos_tools_avi::next_image
                     incr n
                  }
               } else {
                  ::atos_tools_avi::prev_image
                  incr n -1
                  if {$n < 1} { set n 1 }
               }
               set key [::atos_extraction::test_avi_1_getsample $bufNo]
               set m [dict get $imagedict $key]
               if {$m !=$n} {
                  ::console::affiche_resultat "Echec.\n"
                  return 1
               }
            }
         }
      }

      ::console::affiche_resultat "Fini\n"
}

#--- Initialisation au demarrage
::atos_extraction::init

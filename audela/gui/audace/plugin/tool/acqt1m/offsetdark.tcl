#--------------------------------------------------
# source audace/plugin/tool/acqt1m/acqt1m_offsetdark.tcl
#--------------------------------------------------
#
# Fichier        : offsetdark.tcl
# Description    : Acquisition des offset et des dark
# Camera         : Script optimise pour une Andor ikon-L
# Auteur         : Frederic Vachier
# Mise à jour $Id: offsetdark.tcl 12467 2015-12-28 16:13:27Z robertdelmas $
#

namespace eval ::acqt1m_offsetdark {

   variable nbimg
   variable series
   variable nboffset
   variable nbtotal
   variable nbdark
   variable frm
   variable progress


   #
   # Chargement des captions
   #
   proc ::acqt1m_offsetdark::init { bufNo } {

      variable private
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqt1m offsetdark.cap ]

      # recupere la liste des images
      set dir $audace(rep_travail)
      gren_info "DIR=$dir\n"
      set listfile [::acqt1m_offsetdark::globr $dir]

      # recupere les temps d exposition
      set err 0
      set nbimg 0
      set listexpo ""
      foreach f $listfile {
         set ext [file extension $f]
         if {$ext==".fit"||$ext==".fits"} {
            buf$bufNo load $f
            set listemotsclef [ buf$bufNo getkwds ]
            #--- Le temps de pose est dans EXPOSURE
            if { [ lsearch $listemotsclef "EXPOSURE" ] !=-1 } {
               set expo [ expr round([ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ])]
            #--- Le temps de pose est dans EXPTIME
            } elseif { [ lsearch $listemotsclef "EXPTIME" ] !=-1 } {
               set expo [ expr round([ lindex [ buf$bufNo getkwd EXPTIME ] 1 ])]
            }
            set naxis1 [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
            set naxis2 [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
            if { [lsearch {2048 1024 682 512 } $naxis1] == -1 || [lsearch {2048 1024 682 512 } $naxis2] == -1 } {
               ::console::affiche_erreur "NAXIS1 = $naxis1 NAXIS2 = $naxis2 $f\n"
               incr err
            } else {
               set name "$expo-$naxis1-$naxis2"
               if {![info exists dark($name)]} {
                  set dark($name) 1
               } else {
                  incr dark($name)
               }
             }
            incr nbimg
         }
      }
      if {$err} {::console::affiche_erreur "Nb img en Erreur : $err/$nbimg\n"}

      set l ""
      foreach { name nb } [array get dark] {
         lappend l [list $name $nb]
      }
      gren_info "l brute : $l\n"
      set l [lsort -integer -index 1 -decreasing $l]
      gren_info "l sort : $l\n"


      # dark
      set cpt 0
      gren_info "Dark : \n"
      foreach x $l {
         set name  [lindex $x 0]
         set nbimg [lindex $x 1]
         set c [split $name "-"]
         set expo [lindex $c 0]
         set n1 [lindex $c 1]
         set n2 [lindex $c 2]

         set passbin "no"
         if { $n1 == $n2 && $n1 == 2048 }  {
            set bin 1
            set passbin "yes"
         }
         if { $n1 == $n2 && $n1 == 1024 }  {
            set bin 2
            set passbin "yes"
         }
         if { $n1 == $n2 && $n1 == 682 }  {
            set bin 3
            set passbin "yes"
         }
         if { $n1 == $n2 && $n1 == 512 }  {
            set bin 4
            set passbin "yes"
         }

         if { $passbin=="yes" && $expo>0 } {
            gren_info "bin = $bin - expo = $expo - nbimg = $nbimg \n"
            set ::acqt1m_offsetdark::series($cpt,expo)   $expo
            set ::acqt1m_offsetdark::series($cpt,bin)    $bin
            set ::acqt1m_offsetdark::series($cpt,select) sunken
            set ::acqt1m_offsetdark::series($cpt,nbimg)  $nbimg
            if {![info exists off($bin)]} {
               set off($bin) 1
            } else {
               incr off($bin)
            }
            incr cpt
         }

      }
      set ::acqt1m_offsetdark::nbdark $cpt

      # offset
      gren_info "Offset : \n"
      foreach { bin nb } [array get off] {
         gren_info "bin = $bin \n"
         set ::acqt1m_offsetdark::series($cpt,expo)   0
         set ::acqt1m_offsetdark::series($cpt,bin)    $bin
         set ::acqt1m_offsetdark::series($cpt,select) sunken
         incr cpt
      }


      set ::acqt1m_offsetdark::nbtotal  $cpt
      set ::acqt1m_offsetdark::nboffset [expr $::acqt1m_offsetdark::nbtotal - $::acqt1m_offsetdark::nbdark]

      gren_info "NB Offset : $::acqt1m_offsetdark::nboffset\n"
      gren_info "NB Dark   : $::acqt1m_offsetdark::nbdark\n"
      gren_info "NB Total  : $::acqt1m_offsetdark::nbtotal\n"


      set deb  [expr $::acqt1m_offsetdark::nbdark]
      set fin  $::acqt1m_offsetdark::nbtotal
      gren_info "deb  : $deb\n"
      gren_info "fin  : $fin\n"
      for {set x $deb} {$x<$fin} {incr x} {
          gren_info "x  : $x $::acqt1m_offsetdark::series($x,expo) $::acqt1m_offsetdark::series($x,bin)\n"
      }


      set private(rep_images) $::audace(rep_images)

   }










   #
   # Charge la configuration dans des variables locales
   #
   proc ::acqt1m_offsetdark::extime_dureetotale {  } {


      set b 0.471
      set a 1.1022e-6
      set vide 0.363
      set nbpix(1) [expr 2048*2048]
      set nbpix(2) [expr 1024*1024]
      set nbpix(3) [expr 682*682]
      set nbpix(4) [expr 512*512]

      set duree 0
      for {set x 0} {$x<$::acqt1m_offsetdark::nbtotal} {incr x} {

          set frmx $::acqt1m_offsetdark::frm.choix.block.launch$x
          set select [ $frmx cget -relief]
          set state  [ $frmx cget -state ]

          gren_info "$x: $select $state  \n"
          if {$select=="sunken"&&($state=="normal"||$state=="active")}   {
             set Tlect [expr $b + $a * $nbpix($::acqt1m_offsetdark::series($x,bin))]
             set Timg  [expr $::acqt1m_offsetdark::series($x,expo) + $Tlect]
             set Tserie [expr $Timg * $::acqt1m_offsetdark::nbimg]
             set duree [expr $duree + $Tserie]
             #gren_info " $Tlect $Timg $Tserie $duree \n"
          }
      }
      # la formule sous evalue de 10% environ
      set duree [expr $duree * 1.1]
      gren_info "ESTIMATION  DUREE TOTALE : $duree\n"
      set ::acqt1m_offsetdark::duree [format "%0.0f" $duree]

   }















   #
   # Charge la configuration dans des variables locales
   #
   proc ::acqt1m_offsetdark::confToWidget { visuNo } {

      variable parametres
      global panneau

      #--- confToWidget
      if { ! [info exists conf(acqt1m_offsetdark,offsetdark,nbimg)] } { set conf(acqt1m_offsetdark,offsetdark,nbimg) 30 }
      set ::acqt1m_offsetdark::nbimg $conf(acqt1m_offsetdark,offsetdark,nbimg)
   }















   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::acqt1m_offsetdark::widgetToConf { visuNo } {
      variable parametres
      global conf

      set conf(acqt1m_offsetdark,offsetdark,nbimg) $::acqt1m_offsetdark::nbimg

   }















   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   #
   proc ::acqt1m_offsetdark::run { visuNo } {

      global panneau


      ::acqt1m_offsetdark::confToWidget $visuNo
      ::acqt1m_offsetdark::init [ visu$visuNo buf ]
      #set panneau(acqt1m,$visuNo,offsetdark) $this
      createdialog $visuNo

   }

















   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::acqt1m_offsetdark::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::acqt1m_offsetdark::getPluginType ] ] \
         [ ::acqt1m_offsetdark::getPluginDirectory ] acqt1m_offsetdark.htm
   }
















   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::acqt1m_offsetdark::closeWindow { this visuNo } {

      ::acqt1m_offsetdark::widgetToConf $visuNo

      destroy $this
   }



















   #
   # Creation de l'interface graphique
   #
   proc ::acqt1m_offsetdark::createdialog { visuNo } {

      package require tile

      global caption panneau  color audace

      #--- Determination de la fenetre parente
      if { $visuNo == "1" } {
         set this "$audace(base).offsetdark"
      } else {
         set this ".visu$visuNo.offsetdark"
      }

      #--- Creation de la fenetre
      if { [winfo exists $this] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }
      toplevel $this -class Toplevel

      set posx_config [ lindex [ split [ wm geometry $this ] "+" ] 1 ]
      set posy_config [ lindex [ split [ wm geometry $this ] "+" ] 2 ]
      wm geometry $this +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
      wm resizable $this 1 1

      wm title $this $caption(offsetdark,title)
      wm protocol $this WM_DELETE_WINDOW "::acqt1m_offsetdark::closeWindow $this $visuNo"


      #--- frame principal
      set ::acqt1m_offsetdark::frm $this.offsetdark
      set ::acqt1m_offsetdark::progress 0


           #--- Cree un frame pour afficher le status de la base
           frame $::acqt1m_offsetdark::frm -borderwidth 0 -cursor arrow -relief groove
           pack $::acqt1m_offsetdark::frm -in $this -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              #--- Cree un label pour le titre
              label $::acqt1m_offsetdark::frm.titre -text $caption(offsetdark,title)
              pack  $::acqt1m_offsetdark::frm.titre -in $::acqt1m_offsetdark::frm -side top -padx 3 -pady 3



           #--- Cree un frame pour le entrees de formulaire
           frame $::acqt1m_offsetdark::frm.form -borderwidth 1 -relief raised -cursor arrow
           pack $::acqt1m_offsetdark::frm.form -in $::acqt1m_offsetdark::frm -side top -expand 0 -fill x -padx 1 -pady 1

              #--- Cree un frame pour afficher le choix nbimg
              set nbimg [frame $::acqt1m_offsetdark::frm.form.nbimg -borderwidth 0]
              pack $nbimg -in $::acqt1m_offsetdark::frm.form -side left

                 #--- Cree un label
                 label $nbimg.lab -padx 3 -text $caption(offsetdark,nbimg)
                 pack $nbimg.lab -in $nbimg -side left -padx 3 -pady 1 -anchor w

                 #--- Cree une entree
                 entry $nbimg.val -fg $color(blue) -width 6 -justify right \
                     -textvariable ::acqt1m_offsetdark::nbimg
                 pack $nbimg.val -in $nbimg -side left -pady 1 -anchor w -expand 0


           frame $::acqt1m_offsetdark::frm.pf -borderwidth 1 -relief raised -cursor arrow
           pack  $::acqt1m_offsetdark::frm.pf -in $::acqt1m_offsetdark::frm -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

              set pf [ ttk::progressbar $::acqt1m_offsetdark::frm.pf.p -variable ::acqt1m_offsetdark::progress -orient horizontal -length 300 -mode determinate]
              pack $pf -in $::acqt1m_offsetdark::frm.pf


           #--- Cree un frame pour les choix
           frame $::acqt1m_offsetdark::frm.choix -borderwidth 1 -relief raised -cursor arrow
           pack $::acqt1m_offsetdark::frm.choix -in $::acqt1m_offsetdark::frm -side top -expand 1 -fill x -padx 1 -pady 1


              #--- Cree un frame pour les offsets
              set block [frame $::acqt1m_offsetdark::frm.choix.block -borderwidth 0]
              pack $block -in $::acqt1m_offsetdark::frm.choix -side top -expand 1 -fill both


                 set deb  [expr $::acqt1m_offsetdark::nbdark]
                 set fin  $::acqt1m_offsetdark::nbtotal
                 for {set x $deb} {$x<$fin} {incr x} {

                    #--- Cree un button
                    button $block.launch$x -text "Offset (binning $::acqt1m_offsetdark::series($x,bin))" -borderwidth 2 \
                     -command "::acqt1m_offsetdark::select $x" -relief $::acqt1m_offsetdark::series($x,select)
                    pack $block.launch$x -in $block -side top -pady 0 -anchor w -expand 1 -fill both


                 }

                 set deb  0
                 set fin  $::acqt1m_offsetdark::nbdark
                 for {set x $deb} {$x<$fin} {incr x} {

                    #--- Cree un button
                    button $block.launch$x -text "Dark $::acqt1m_offsetdark::series($x,expo) sec. (binning $::acqt1m_offsetdark::series($x,bin) - nbimg $::acqt1m_offsetdark::series($x,nbimg))" -borderwidth 2 \
                       -command "::acqt1m_offsetdark::select $x"  -relief $::acqt1m_offsetdark::series($x,select)
                    pack $block.launch$x -in $block -side top -pady 0 -anchor w -expand 1 -fill both

                 }




#           #--- Cree un frame pour le dark manuel
#           frame $::acqt1m_offsetdark::frm.manuel -borderwidth 1 -relief raised -cursor arrow
#           pack $::acqt1m_offsetdark::frm.manuel -in $::acqt1m_offsetdark::frm -side top -expand 0 -fill x -padx 1 -pady 1
#
#              #--- Cree un frame pour afficher le choix
#              set mandark [frame $::acqt1m_offsetdark::frm.manuel.dark -borderwidth 0]
#              pack $mandark -in $::acqt1m_offsetdark::frm.manuel -side left
#
#                 #--- Cree un button
#                 button $mandark.launch -text "Dark" -borderwidth 2 \
#                    -command "::acqt1m_offsetdark::select manuel"
#                 pack $mandark.launch -in $mandark -side left -pady 0 -anchor w
#
#                 #--- Cree un label
#                 label $mandark.lab1 -padx 3 -text $caption(offsetdark,manuel)
#                 pack $mandark.lab1 -in $mandark -side left -padx 3 -pady 1 -anchor w
#
#                 #--- Cree une entree
#                 entry $mandark.exposure -fg $color(blue) -width 6
#                 pack $mandark.exposure -in $mandark -side left -pady 1 -anchor w
#
#                 #--- Cree un label
#                 label $mandark.lab2 -padx 3 -text "sec."
#                 pack $mandark.lab2 -in $mandark -side left -padx 3 -pady 1 -anchor w



           #--- Cree un frame pour la duree totale
           frame $::acqt1m_offsetdark::frm.info -borderwidth 1 -relief raised -cursor arrow
           pack $::acqt1m_offsetdark::frm.info -in $::acqt1m_offsetdark::frm -side top -expand 0 -fill x -padx 1 -pady 1

              #--- Cree un frame pour afficher le choix nbimg
              set duree [frame $::acqt1m_offsetdark::frm.info.duree -borderwidth 0]
              pack $duree -in $::acqt1m_offsetdark::frm.info -side left

                 #--- Cree un label
                 label $duree.lab -padx 3 -text "Estimation duree Totale : - sec." -fg $color(blue)
                 pack $duree.lab -in $duree -side left -padx 3 -pady 1 -anchor w









           #--- Cree un frame pour les actions
           frame $::acqt1m_offsetdark::frm.action -borderwidth 1 -relief raised -cursor arrow
           pack $::acqt1m_offsetdark::frm.action -in $::acqt1m_offsetdark::frm -side top -expand 0 -fill x -padx 1 -pady 1


           #--- Creation du bouton fermeture
              button $::acqt1m_offsetdark::frm.action.fermer \
                 -text "$caption(offsetdark,fermer)" -borderwidth 2 \
                 -command "::acqt1m_offsetdark::closeWindow $this $visuNo"
              pack $::acqt1m_offsetdark::frm.action.fermer -in $::acqt1m_offsetdark::frm.action \
                 -side right -anchor e \
                 -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton aide
           button $::acqt1m_offsetdark::frm.action.aide \
              -text "$caption(offsetdark,aide)" -borderwidth 2 \
              -command "::audace::showHelpPlugin tool acqt1m acqt1m_offsetdark.htm"
           pack $::acqt1m_offsetdark::frm.action.aide -in $::acqt1m_offsetdark::frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

           #--- Creation du bouton GO
           button $::acqt1m_offsetdark::frm.action.go \
              -text "$caption(offsetdark,go)" -borderwidth 2 \
              -command "::acqt1m_offsetdark::prepare_go $visuNo"
           pack $::acqt1m_offsetdark::frm.action.go -in $::acqt1m_offsetdark::frm.action \
              -side right -anchor e \
              -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0




         ::acqt1m_offsetdark::extime_dureetotale
         $::acqt1m_offsetdark::frm.info.duree.lab configure -text "Estimation duree Totale : $::acqt1m_offsetdark::duree sec."
         gren_info "duree totale : $::acqt1m_offsetdark::duree sec.\n"


   }










   proc ::acqt1m_offsetdark::select { x } {

      gren_info "nbimg = $::acqt1m_offsetdark::nbimg \n"

      set frmx $::acqt1m_offsetdark::frm.choix.block.launch$x
      set select [ $frmx cget -relief]

      gren_info "$x select = $select \n"

      if {$select=="sunken"}   {
         $frmx configure -relief raised
         set ::acqt1m_offsetdark::series($x,select) raised
      } else {
         $frmx configure -relief sunken
         set ::acqt1m_offsetdark::series($x,select) sunken
      }

      ::acqt1m_offsetdark::extime_dureetotale
      $::acqt1m_offsetdark::frm.info.duree.lab configure -text "Estimation duree Totale : $::acqt1m_offsetdark::duree sec."
      gren_info "duree totale : $::acqt1m_offsetdark::duree sec.\n"


   }














   proc ::acqt1m_offsetdark::globr {{dir .}} {

       set res {}

       set errnum [catch {set cur [glob $dir]} msg]
       if {$errnum} {

       } else {
       foreach i $cur {
           if {[file type $i]=="directory"} {
           } else {
              lappend res $i
           }
       }

       eval lappend res [globrd $dir]
       }
       return $res
    }






   proc ::acqt1m_offsetdark::set_progress { cur max } {


#      pack [ ttk::progressbar $this.p -variable v -orient horizontal -length 200 -mode determinate]
#      for {set v 0} {$v<100} {incr v} { after 100; update }
#      destroy $::acqt1m_offsetdark::frm.p

      set ::acqt1m_offsetdark::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      gren_info "Progresse = $::acqt1m_offsetdark::progress\n"
   }



#------------------------------------------------------------
# go
#     lancement des acquisitions
# Parameters
#  visuNo  : numero de la visu associee a la camera
# Return
#    rien
#------------------------------------------------------------
   proc ::acqt1m_offsetdark::prepare_go { visuNo } {

      gren_info "\n\n nbimg = $::acqt1m_offsetdark::nbimg \n"

      ::acqt1m::push_gui $visuNo
      ::console::affiche_resultat "PUSH GUI\n"


      for {set x 0} {$x<$::acqt1m_offsetdark::nbtotal} {incr x} {

         ::acqt1m_offsetdark::extime_dureetotale
         $::acqt1m_offsetdark::frm.info.duree.lab configure -text "Estimation duree Totale : $::acqt1m_offsetdark::duree sec."
         gren_info "duree totale : $::acqt1m_offsetdark::duree sec.\n"



         set frmx $::acqt1m_offsetdark::frm.choix.block.launch$x
         set select [ $frmx cget -relief]
         set state  [ $frmx cget -state ]

         if {$select=="sunken"&&$state=="normal"}   {
            gren_info "$x , select = $select state = $state\n"
            # y a plus qu a prendre l image
            set bin $::acqt1m_offsetdark::series($x,bin)
            set bin "${bin}x${bin}"
            gren_info "Serie $x : expo = $::acqt1m_offsetdark::series($x,expo) bin = $bin nbimg = $::acqt1m_offsetdark::nbimg \n"

            $frmx configure -state disabled
            $frmx configure -bg "yellow"
            ::acqt1m_offsetdark::go $visuNo $::acqt1m_offsetdark::series($x,expo) $::acqt1m_offsetdark::nbimg $bin
            $frmx configure -bg "green"

         }
      }

      ::acqt1m::pop_gui $visuNo
      ::console::affiche_resultat "POP GUI\n"

   }



















#------------------------------------------------------------
# go
#     lancement des acquisitions
# Parameters
#  visuNo  : numero de la visu associee a la camera
#  message : message envoye par la thread de la camera (voir la description dans camera.tcl)
#  args    : parametres du message (voir la description dans camera.tcl)
# Return
#    rien
#------------------------------------------------------------
   proc ::acqt1m_offsetdark::go { visuNo pose nbImages bin} {

      global audace caption panneau
      variable private


      set panneau(acqt1m,$visuNo,mode) 2


      set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]
      set private($visuNo,camNo)   [ ::confCam::getCamNo $private($visuNo,camItem) ]
      set private($visuNo,camera)  cam$private($visuNo,camNo)


      # Teste la presence d'une camera connectee
      set err [catch {$private($visuNo,camera) info} msg]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(flat_t1m_auto,pasCamera)\n\n"
         set choix [ tk_messageBox -title "Error" -type ok \
            -message "Selectionner Camera" ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            ::confCam::run
         }
         return 1
      }

      #--- Ouverture du fichier historique
      if { $panneau(acqt1m,$visuNo,save_file_log) == "1" } {
         if { $panneau(acqt1m,$visuNo,session_ouverture) == "1" } {
            ::acqt1m::Demarrageacqt1m $visuNo
            set panneau(acqt1m,$visuNo,session_ouverture) "0"
         }
      }

      #--- Modification du bouton, pour eviter un second lancement
      $panneau(acqt1m,$visuNo,This).go_stop.but configure -text $caption(acqt1m,stop) -command "::acqt1m::Stop $visuNo"
      #--- Verrouille tous les boutons et champs de texte pendant les acquisitions
      $panneau(acqt1m,$visuNo,This).pose.but configure -state disabled
      $panneau(acqt1m,$visuNo,This).pose.entr configure -state disabled
      $panneau(acqt1m,$visuNo,This).binningt.but configure -state disabled
      $panneau(acqt1m,$visuNo,This).obt.but configure -state disabled
      $panneau(acqt1m,$visuNo,This).mode.but configure -state disabled


      #--- Desactive toute demande d'arret
      set panneau(acqt1m,$visuNo,demande_arret) "0"
      #--- Pose en cours
      set panneau(acqt1m,$visuNo,pose_en_cours) "1"
      #--- Enregistrement d'une image interrompue
      set panneau(acqt1m,$visuNo,sauve_img_interrompue) "0"


      set panneau(acqt1m,$visuNo,mode) 2


   set catchResult [catch {



      #--- on fixe le binning
      set panneau(acqt1m,$visuNo,binning) $bin
      set binningMessage $bin

      #--- NbImages
      set panneau(acqt1m,$visuNo,nb_images) $nbImages

      #--- NbImages
      set panneau(acqt1m,$visuNo,pose) $pose
      #--- NbImages
      if {$pose == 0} {
         set panneau(acqt1m,$visuNo,object) "OFFSET"
      } else {
         set panneau(acqt1m,$visuNo,object) "DARK"
      }
      set savfilter $panneau(acqt1m,$visuNo,filtrecourant)
      set panneau(acqt1m,$visuNo,filtrecourant) "none"
      set panneau(acqt1m,$visuNo,index) 1


      #--- l'obturateur reste ferme
      set saveobt $panneau(acqt1m,$visuNo,obt)
      set panneau(acqt1m,$visuNo,obt) 1
      cam$private($visuNo,camNo) shutter "closed"
      $panneau(acqt1m,$visuNo,This).obt.lab configure -text $panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt))



      if { [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) hasBinning] == "1" } {
         #--- je selectionne le binning
         set binning [list [string range $bin 0 0] [string range $bin 2 2]]
         #--- je verifie que le binning est conforme
         set ctrl [ scan $bin "%dx%d" binx biny ]
         if { $ctrl == 2 } {
            set ctrlValue [ format $binx%s$biny x ]
            if { $ctrlValue != $bin } {
               set binning "1 1"
               set panneau(acqt1m,$visuNo,binning) "1x1"
            }
         } else {
            set binning "1 1"
            set panneau(acqt1m,$visuNo,binning) "1x1"
         }
         #--- j'applique le binning
         cam$private($visuNo,camNo) bin $binning
         set binningMessage $panneau(acqt1m,$visuNo,binning)
      } else {
         set binningMessage "1x1"
      }













      if { [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) hasFormat] == "1" } {
         #--- je selectionne le format des images
         ::confCam::setFormat $panneau(acqt1m,$visuNo,camItem) $panneau(acqt1m,$visuNo,format)
         set binningMessage "$panneau(acqt1m,$visuNo,format)"
      }

      #--- Verrouille les boutons du mode "serie"
      $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr configure -state disabled
      $panneau(acqt1m,$visuNo,This).mode.serie.index.entr configure -state disabled
      $panneau(acqt1m,$visuNo,This).mode.serie.index.but configure -state disabled
      set heure $audace(tu,format,hmsint)
      if { $panneau(acqt1m,$visuNo,simulation) != "0" } {
         ::acqt1m::Message $visuNo consolog $caption(acqt1m,lance_simu)
         #--- Heure de debut de la premiere pose
         set panneau(acqt1m,$visuNo,debut) [ clock second ]
      }
      ::acqt1m::Message $visuNo consolog $caption(acqt1m,lanceserie) \
         $panneau(acqt1m,$visuNo,nb_images) $heure
      ::acqt1m::Message $visuNo consolog $caption(acqt1m,nomgen) $panneau(acqt1m,$visuNo,object) \
         $panneau(acqt1m,$visuNo,pose) $binningMessage $panneau(acqt1m,$visuNo,index)


      set camNo $panneau(acqt1m,$visuNo,camNo)
      set bufNo [ ::confVisu::getBufNo $visuNo ]
      set loadMode [::confCam::getPluginProperty $panneau(acqt1m,$visuNo,camItem) "loadMode" ]

      #--- j'initialise l'indicateur d'etat de l'acquisition
      set panneau(acqt1m,$visuNo,acquisitionState) ""
      set compteurImageSerie 1

      #--- Je calcule le dernier index de la serie
      if { $panneau(acqt1m,$visuNo,mode) == "2" } {
         set panneau(acqt1m,$visuNo,indexEndSerie) [ expr $panneau(acqt1m,$visuNo,index) + $panneau(acqt1m,$visuNo,nb_images) - 1 ]
         set panneau(acqt1m,$visuNo,indexEndSerie) "$caption(acqt1m,dernierIndex) $panneau(acqt1m,$visuNo,indexEndSerie)"
      } elseif { $panneau(acqt1m,$visuNo,mode) == "4" } {
         set panneau(acqt1m,$visuNo,indexEndSerieContinu) [ expr $panneau(acqt1m,$visuNo,index) + $panneau(acqt1m,$visuNo,nb_images) - 1 ]
         set panneau(acqt1m,$visuNo,indexEndSerieContinu) "$caption(acqt1m,dernierIndex) $panneau(acqt1m,$visuNo,indexEndSerieContinu)"
      }







      #--- Boucle d'acquisition des images





      while { $panneau(acqt1m,$visuNo,demande_arret) == "0" } {
         #--- si un nombre d'image est precise, je verifie
         if { $nbImages != "" && $compteurImageSerie > $nbImages } {
            #--- alerte sonore de fin de serie
            if { $panneau(acqt1m,$visuNo,alarme_fin_serie) == "1" } {
               if { $nbImages > "0" && $panneau(acqt1m,$visuNo,mode) == "2" } {
                  bell
                  after 200
                  bell
                  after 200
                  bell
                  after 200
                  bell
                  after 200
                  bell
               }
            }
            #--- le nombre d'image est atteint, j'arrete la boucle
            break
         }
         #--- Je note l'heure de debut de l'image (utile pour les images espacees)
         set panneau(acqt1m,$visuNo,deb_im) [ clock second ]
         #--- Alarme sonore de fin de pose
         ::camera::alarmeSonore $panneau(acqt1m,$visuNo,pose)
         #--- Declenchement l'acquisition (voir la suite dans callbackAcquition)
         ::camera::acquisition $panneau(acqt1m,$visuNo,camItem) "::acqt1m::callbackAcquisition $visuNo" $panneau(acqt1m,$visuNo,pose)
         #--- je lance la boucle d'affichage du status
         after 10 ::acqt1m::dispTime $visuNo
         #--- j'attends la fin de l'acquisition (voir ::acqt1m::callbackAcquisition)
         vwait panneau(acqt1m,$visuNo,acquisitionState)

         if { $panneau(acqt1m,$visuNo,acquisitionState) == "error" } {
            #--- j'interromps la boucle des acquisitions dans la thread de la camera
            ::acqt1m::stopAcquisition $visuNo
            #--- je ferme la fenetre de décompte
            if { $panneau(acqt1m,$visuNo,dispTimeAfterId) != "" } {
               after cancel $panneau(acqt1m,$visuNo,dispTimeAfterId)
               set panneau(acqt1m,$visuNo,dispTimeAfterId) ""
            }
            #--- j'affiche le message d'erreur
            tk_messageBox -message $::caption(acqt1m,acquisitionError) -title $::caption(acqt1m,pb) -icon error
            break
         }

         #--- Rajoute des mots cles dans l'en-tete FITS
         foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqt1m,keywordConfigName) ] {
            buf$bufNo setkwd $keyword
         }
         #--- je trace la duree réelle de la pose s'il y a eu une interruption
         if { $panneau(acqt1m,$visuNo,demande_arret) == "1" } {
            set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
            #--- je verifie qu'il y eu interruption vraiment pendant l'acquisition
            set dateEnd [mc_date2ymdhms [ lindex [ buf$bufNo getkwd DATE-END ] 1 ]]
            set dateEnd [format "%02dh %02dm %02ds" [lindex $dateEnd 3] [lindex $dateEnd 4] [expr int([lindex $dateEnd 5])]]
            if { $exposure != $panneau(acqt1m,$visuNo,pose) } {
               ::acqt1m::Message $visuNo consolog $caption(acqt1m,arrprem) $dateEnd
               ::acqt1m::Message $visuNo consolog $caption(acqt1m,lg_pose_arret) $exposure
            } else {
               ::acqt1m::Message $visuNo consolog $caption(acqt1m,arrprem) $dateEnd
            }
         }


               #--- Mode serie
               #--- Je sauvegarde l'image
               set filenamelist [::acqt1m::get_filename $visuNo]

               set nom   [lindex $filenamelist 1]
               set bufNo [lindex $filenamelist 0]

               #--- Pour eviter un nom de fichier qui commence par un blanc
               set nom [ file join [lindex $nom 0] ]


               if { $panneau(acqt1m,$visuNo,simulation) == "0" } {
                  #--- Verifie que le nom du fichier n'existe pas deja...
                  set nom1 "$nom"
                  append nom1 $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)
                  set sauvegardeValidee "1"
                  if { [ file exists [ file join $private(rep_images) $nom1 ] ] == "1" &&  $panneau(acqt1m,$visuNo,verifier_ecraser_fichier) == 1 } {
                     #--- Dans ce cas, le fichier existe deja...
                     set lastFile [ ::acqt1m::dernierFichier $visuNo ]
                     set confirmation [tk_messageBox -title $caption(acqt1m,conf) -type yesno \
                        -message "$caption(acqt1m,fichdeja_1) $lastFile $caption(acqt1m,fichdeja_2)"]
                     if { $confirmation == "no" } {
                        #--- je ne sauvegarde pas l'image et j'arrete les acquisitions
                        set sauvegardeValidee "0"
                        set panneau(acqt1m,$visuNo,demande_arret) "1"
                     }
                  }
                  #--- Sauvegarde de l'image
                  if { $sauvegardeValidee == "1" && $panneau(acqt1m,$visuNo,sauve_img_interrompue) == "0" } {
                     #--- Sauvegarde de l'image
                     saveima  [ file join $private(rep_images) [append nom "." $panneau(acqt1m,$visuNo,index) $panneau(acqt1m,$visuNo,extension)] ] $visuNo
                     #--- Indique l'heure d'enregistrement dans le fichier log
                     set heure $audace(tu,format,hmsint)
                     ::acqt1m::Message $visuNo consolog $caption(acqt1m,enrim) $heure $nom
                     incr panneau(acqt1m,$visuNo,index)
                  }
               }
               #--- j'incremente le nombre d'images de la serie
               incr compteurImageSerie
               ::acqt1m_offsetdark::set_progress [expr $compteurImageSerie -1] $nbImages





      }  ; #--- fin de la boucle d'acquisition












               #--- Mode serie
               #--- Fin de la derniere pose et intervalle mini entre 2 poses ou 2 series
               if { $panneau(acqt1m,$visuNo,simulation) == "1" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqt1m,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqt1m,$visuNo,pose) } {
                     set panneau(acqt1m,$visuNo,intervalle) [ expr $panneau(acqt1m,$visuNo,fin) - $panneau(acqt1m,$visuNo,debut) ]
                  } else {
                     set panneau(acqt1m,$visuNo,intervalle) "...."
                  }
                  set simu1 "$caption(acqt1m,int_mini_serie) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
                  $panneau(acqt1m,$visuNo,base).intervalle_continu_1.lab3 configure -text "$simu1"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqt1m,$visuNo,simulation) "0"
                  set panneau(acqt1m,$visuNo,mode)       "4"
                  set panneau(acqt1m,$visuNo,index)      $panneau(acqt1m,$visuNo,index_temp)
                  set panneau(acqt1m,$visuNo,nb_images)  $panneau(acqt1m,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  ::acqt1m::Message $visuNo consolog $caption(acqt1m,fin_simu)
               } elseif { $panneau(acqt1m,$visuNo,simulation) == "2" } {
                  #--- Affichage de l'intervalle mini simule
                  set panneau(acqt1m,$visuNo,fin) [ clock second ]
                  set exposure [ lindex [ buf$bufNo getkwd EXPOSURE ] 1 ]
                  if { $exposure == $panneau(acqt1m,$visuNo,pose) } {
                     set panneau(acqt1m,$visuNo,intervalle) [ expr $panneau(acqt1m,$visuNo,fin) - $panneau(acqt1m,$visuNo,debut) ]
                  } else {
                     set panneau(acqt1m,$visuNo,intervalle) "...."
                  }
                  set simu2 "$caption(acqt1m,int_mini_image) $panneau(acqt1m,$visuNo,intervalle) $caption(acqt1m,sec)"
                  $panneau(acqt1m,$visuNo,base).intervalle_continu_2.lab3 configure -text "$simu2"
                  #--- Je retablis les reglages initiaux
                  set panneau(acqt1m,$visuNo,simulation) "0"
                  set panneau(acqt1m,$visuNo,mode)       "5"
                  set panneau(acqt1m,$visuNo,index)      $panneau(acqt1m,$visuNo,index_temp)
                  set panneau(acqt1m,$visuNo,nb_images)  $panneau(acqt1m,$visuNo,nombre_temp)
                  #--- Fin de la simulation
                  ::acqt1m::Message $visuNo consolog $caption(acqt1m,fin_simu)
               }
               #--- Deverrouille les boutons du mode "serie"
               $panneau(acqt1m,$visuNo,This).mode.serie.nb.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie.index.entr configure -state normal
               $panneau(acqt1m,$visuNo,This).mode.serie.index.but configure -state normal






   }] ; #--- fin du catch



   if { $catchResult == 1 } {
      ::tkutil::displayErrorInfo $caption(acqt1m,titre)
      #--- J'arrete la capture de l'image
      ::camera::stopAcquisition [::confVisu::getCamItem $visuNo]
   }


   #--- Pose en cours
   set panneau(acqt1m,$visuNo,pose_en_cours) "0"

   set panneau(acqt1m,$visuNo,demande_arret) 0
   #--- Effacement de la barre de progression quand la pose est terminee
   ::acqt1m::avancementPose $visuNo -1
   $panneau(acqt1m,$visuNo,This).status.lab configure -text ""
   #--- Deverrouille tous les boutons et champs de texte pendant les acquisitions
   $panneau(acqt1m,$visuNo,This).pose.but configure -state normal
   $panneau(acqt1m,$visuNo,This).pose.entr configure -state normal
   $panneau(acqt1m,$visuNo,This).binningt.but configure -state normal
   $panneau(acqt1m,$visuNo,This).obt.but configure -state normal
   $panneau(acqt1m,$visuNo,This).mode.but configure -state normal
   #--- Je restitue l'affichage du bouton "GO"
   $panneau(acqt1m,$visuNo,This).go_stop.but configure -text $caption(acqt1m,GO) -state normal -command "::acqt1m::Go $visuNo"
   #--- je positionne l'indateur de fin d'acquisition (pour startAcquisitionSerieImage)
   set ::panneau(acqt1m,$visuNo,acqImageEnd) "1"


   #revient aux parametre de l acquisition normale
   set panneau(acqt1m,$visuNo,filtrecourant) $savfilter





            switch -exact -- $panneau(acqt1m,$visuNo,obt) {
               0  {
                  cam$camNo shutter "opened"
               }
               1  {
                  cam$camNo shutter "closed"
               }
               2  {
                  cam$camNo shutter "synchro"
               }
            }















   #--- Fin GO
   }

}

#--- Initialisation au demarrage
#::acqt1m_offsetdark::init


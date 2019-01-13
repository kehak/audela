#
## @file collector_cam.tcl
#  @brief Gère la fenêtre d'ajout/suppression d'une caméra
#  @author Raymond Zachantke
#  $Id: collector_cam.tcl 13037 2016-02-01 19:47:12Z robertdelmas $
#

   #----------gestion de la fenetre Ajouter/Supprimer une camera--------------
   # ::collector::addNewCam
   # ::collector::cmdAddCam
   # ::collector::cmdSupprCam
   # ::collector::cmdCancel
   # ::collector::configCamList
   # ::collector::setConfCam
   # ::collector::changeEntryStyle

   #------------------------------------------------------------
   #  brief   commande associée a 'Nouvelle caméra'
   #  details fenêtre de saisie du nom d'une nouvelle caméra
   #
   proc ::collector::addNewCam {} {
      variable This
      variable private
      global caption

      set this $This.newCam

      if {![info exists private(newCam)]} {
         set private(newCam) ""
      }

      #---
      if { [ winfo exists $this ] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         return
      }

      toplevel $this -class Toplevel
      wm title $this $caption(collector,addSupprCam)
      lassign [split [wm geometry $This] "+"] -> posx posy
      wm geometry $this +[expr {$posx + 200}]+[expr {$posy + 10}]
      wm resizable $this 0 0
      wm transient  $this $This
      wm protocol $this WM_DELETE_WINDOW "::collector::cmdcancelCam"

      label $this.lab -text "$caption(collector,camName)"
      grid $this.lab -row 0 -column 0 -padx 5 -pady 5
      ttk::entry $this.name -textvariable ::collector::private(newCam) -width 20 -justify center
      grid $this.name -row 0 -column 1 -columnspan 2 -padx 5 -pady 5 -sticky w

      set c 0
      foreach b [list addCam supprCam cancelCam] {
         grid [ttk::button $this.$b -text $caption(collector,$b) -command "::collector::cmd$b"] \
            -row 1 -column $c -padx 2 -pady 5
         incr c
      }

      #--   signale les parametres en rouge
      collector::changeEntryStyle $private(paramsList) "default.TEntry"

      focus $this.name

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #------------------------------------------------------------
   #  brief   commande associée au bouton "Ajouter"
   #  details complète l'array des caméras et actualise la liste de la combobox
   #
   proc ::collector::cmdaddCam { } {
      variable private
      global caption cameras

      set newCam [string trimright $private(newCam)]
      set newCam [string trimleft $newCam]

      if {$newCam ne ""} {

         #--   collecte les donnees
         set data [::struct::list map $private(paramsList) ::collector::getValue]
         for {set k 2} {$k <=3} {incr k} {
            set value [expr {[lindex $data $k]*1e-6}]
            set data [lreplace $data $k $k $value]
         }

         #--   complete l'array
         if {[llength $data] == 9} {
            array set cameras [list $newCam $data]
         }

         ::collector::configCamList $private(newCam)
         ::collector::setConfCam
      }

      cmdcancelCam
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Supprimer"
   #  details supprime une caméra dans la liste de la combobox et dans l'array
   #
   proc ::collector::cmdsupprCam {} {
      variable private
      global caption cameras

     if {$private(newCam) in $private(actualListOfCam)} {

         #-- met a jour l'array
         array unset cameras $private(newCam)

         #--   cherche le rang de la camera a pointer
         set l [lsearch $private(actualListOfCam) $private(newCam)]
         #--   selectionne la cam de rang inferieur
         incr l -1
         if {$l < 0} {set l 0}
         set detnam [lindex $private(actualListOfCam) $l]

         ::collector::configCamList $detnam
         ::collector::setConfCam
     }

     ::collector::cmdcancelCam
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Annuler"
   #  details ferme la fenêtre de saisie d'une caméra
   #
   proc ::collector::cmdcancelCam { } {
      variable This
      variable private

      if {[info exists private(newCam)]} {
         unset private(newCam)
      }

      destroy $This.newCam

      #--   remet tous les parametres en noir
      ::collector::changeEntryStyle $private(paramsList) "TEntry"
   }

   #------------------------------------------------------------
   #  brief actualise la variable private(actualListOfCam) a partir de l'array caméras et la liste de la combobox
   #
   proc ::collector::configCamList { camName } {
      variable This
      variable private
      global caption cameras

      set camList [lsort -dictionary [array names cameras]]
      set k [lsearch $camList ""]
      if {$k !=  -1 } {
         set camList [lreplace $camList $k $k]
      }
      set private(actualListOfCam) $camList

      #--   ajoute 'Nouvelle camera" a la liste
      set values [linsert $private(actualListOfCam) end $caption(collector,newCam)]
      $This.n.cam.detnam configure -values $values

      set private(detnam) $camName

      #--   met a jour etc_tools
      ::collector::modifyCamera
   }

   #------------------------------------------------------------
   #  brief actualise la variable conf(collector,cam)
   #
   proc ::collector::setConfCam { } {
      variable private
      global conf cameras

      foreach camName $private(actualListOfCam) {
         if {[lsearch $private(etcCam) $camName] == -1} {
            lappend conf(collector,cam) [array get cameras $camName]
         }
      }
   }

   #------------------------------------------------------------
   #  brief change la couleur des valeurs affichées
   #  param params liste des variables a modifier
   #  param style  [default.Tentry == rouge | TEntry == $audace(color,entryTextColor)}
   #
   proc ::collector::changeEntryStyle { params style } {
      variable This

      set w $This.n.cam

      foreach child $params {
         if {[winfo exists $w.$child]} {
            $w.$child configure -style $style
         }
      }
   }


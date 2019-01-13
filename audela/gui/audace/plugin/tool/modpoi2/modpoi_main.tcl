# @file : modpoi_main.tcl
# @brief fenetre principale de l'assistant à la mise è jour d'un modele de pointage
# @author : Michel Pujol
# $Id: modpoi_main.tcl 13696 2016-04-13 20:28:43Z michelpujol $


namespace eval ::modpoi2::main {

}

# @brief affiche la fenetre de l'assistant à la mise è jour d'un modele de pointage  
# 
# @param base nom tk de la fenetre parent
# @param visuNo numero de la visu
proc ::modpoi2::main::run { base visuNo } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(modpoi2,geometry) ] } { set ::conf(modpoi2,geometry) "440x500+250+75" }

   set private($visuNo,this)   "$base.modpoi2"
   set private($visuNo,model,fileName)     ""
   set private($visuNo,model,name)         ""
   set private($visuNo,model,comment)      ""
   set private($visuNo,model,date)         ""
   set private($visuNo,starList)           ""
   set private($visuNo,model,symbols)      ""
   set private($visuNo,model,coefficients) ""
   set private($visuNo,model,covars)       ""
   set private($visuNo,model,refraction)   0
   set private($visuNo,model,amer,raNb)    0
   set private($visuNo,model,amer,deNb)    0
   set private($visuNo,modified)           0

   set private($visuNo,mount,name)         ""
   set private($visuNo,mount,modelName)    ""
   set private($visuNo,mount,modelDate)    ""

   if { [winfo exists $private($visuNo,this) ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private($visuNo,this) [namespace current] -modal 0 \
         -geometry $::conf(modpoi2,geometry) \
         -resizable 1
      wm minsize $private($visuNo,this) 440 500
      ::confTel::addMountListener "::modpoi2::main::onChangeMount $visuNo"
   } else {
      focus $private($visuNo,this)
   }
   
   return $private($visuNo,this)
}

#------------------------------------------------------------
# getLabel
#  retourne le nom de la fenetre de configuration
# @private
#------------------------------------------------------------
proc ::modpoi2::main::getLabel { } {

   return $::caption(modpoi2,title)
}

#------------------------------------------------------------
# showHelp
#  affiche l'aide de la fenêtre de configuration
# @private
#------------------------------------------------------------
proc ::modpoi2::main::showHelp { } {
   variable private

   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::modpoi2::getPluginType ] ] \
      [ ::modpoi2::getPluginDirectory ] [ ::modpoi2::getPluginHelp ]
}

#------------------------------------------------------------
# cmdClose
#  recupere la position de l'outil apres appui sur Fermer
#
# @private
#------------------------------------------------------------
proc ::modpoi2::main::cmdClose { visuNo } {
   variable private

   if { $private($visuNo,modified) == 1 } {
      set choix [ tk_dialog $private($visuNo,this).selectSave \
         $::caption(modpoi2,title)  \
         $::caption(modpoi2,closeWindow,message)  \
         question \
         1  \
         "$::caption(audace,menu,enregistrer)" \
         "$::caption(audace,menu,enregistrer_sous)..." \
         "$::caption(modpoi2,choix,noSave)" \
         "$::caption(modpoi2,choix,cancel)" \
      ]
      switch $choix {
         "0" {
            #--- choix enregistrer
            onSave $visuNo
         }
         "1" {
            #--- choix enregistrer sous
            set fileName [onSaveAs $visuNo]
            if { $fileName == "" } {
               #--- l'utilisateur a abandonne l'enregistrement
               #--- je retourne "0" pour empecher de fermer le fenetre
               return 0
            }
         }
         "2" {
            #--- choix quitter sans enregistrer
            #--- rien a faire , on continue
         }
         "3" {
            #--- choix abandonner
            #--- je retourne "0" pour empecher de fermer le fenetre
            return "0"
         }
      }
   }

   ::confTel::removeMountListener "::modpoi2::main::onChangeMount $visuNo"

   #--- je sauve la taille et la position de la fenetre
   set ::conf(modpoi2,geometry) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]

   #--- je supprime le menubar et toutes ses entrees
   Menubar_Delete "modpoiMenu${visuNo}"

}

#------------------------------------------------------------
# fillConfigPage { }
#  fenetre de configuration
# @private
#------------------------------------------------------------
proc ::modpoi2::main::fillConfigPage { frm visuNo } {
   variable private

   #--- Je memorise la reference de la frame
   set private($visuNo,frm)      $frm

   #--- je cree le menu
   set private($visuNo,menu) "$private($visuNo,this).menubar"
   set menuNo "modpoiMenu${visuNo}"
   Menu_Setup $menuNo $private($visuNo,menu)
      Menu           $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(modpoi2,menu,create)..." \
         "::modpoi2::main::onCreateModel $visuNo"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,charger)..." \
         "::modpoi2::main::onLoadModel $visuNo"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,enregistrer)" \
         [list ::modpoi2::main::onSave $visuNo]
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,enregistrer_sous)..." \
         [list ::modpoi2::main::onSaveAs $visuNo]
      Menu_Separator $menuNo "$::caption(audace,menu,file)"
      Menu_Command   $menuNo "$::caption(audace,menu,file)" "$::caption(audace,menu,quitter)" \
        "::confGenerique::cmdClose $visuNo [namespace current]"

      Menu           $menuNo "$::caption(modpoi2,menu,edition)"
      Menu_Command   $menuNo "$::caption(modpoi2,menu,edition)" "$::caption(modpoi2,menu,editModel)..." \
         "::modpoi2::main::onEditModel $visuNo"
      Menu_Command   $menuNo "$::caption(modpoi2,menu,edition)" "$::caption(modpoi2,menu,editHorizon)..." \
         "::modpoi2::main::onEditHorizon $visuNo"

   [MenuGet $menuNo $::caption(audace,menu,file)] configure -tearoff 0
   [MenuGet $menuNo $::caption(modpoi2,menu,edition)] configure -tearoff 0

   TitleFrame $frm.mount  -borderwidth 2 -relief ridge -text $::caption(modpoi2,currrentModel)
      #--- monture
      label $frm.mount.mountLabel -text $::caption(modpoi2,monture)
      pack $frm.mount.mountLabel  -in [$frm.mount getframe] -anchor w -side left -padx 0

      entry $frm.mount.mountName -state readonly \
         -textvariable ::modpoi2::main::private($visuNo,mount,name)
      pack $frm.mount.mountName  -in [$frm.mount getframe] -anchor w -side left -padx 0

      #--- modele appliqué à la monture
      label $frm.mount.modelLabel -text $::caption(modpoi2,modele)
      pack $frm.mount.modelLabel  -in [$frm.mount getframe] -anchor w -side left -padx 0

      entry $frm.mount.modelName -state readonly \
         -textvariable ::modpoi2::main::private($visuNo,mount,modelName)
      pack $frm.mount.modelName  -in [$frm.mount getframe] -anchor w -side left -padx 0

      entry $frm.mount.modelDate -state readonly \
         -textvariable ::modpoi2::main::private($visuNo,mount,modelDate)
      pack $frm.mount.modelDate  -in [$frm.mount getframe] -anchor w -side left -padx 0
   pack $frm.mount -side bottom -fill x -expand 0

   button $frm.applyModel -text $::caption(modpoi2,modele_appliquer) \
   -command "::modpoi2::main::onApplyModel $visuNo"
   pack $frm.applyModel -anchor center -side bottom -padx 0

   #--- Frame model
   TitleFrame $frm.model  -borderwidth 2 -relief ridge
      #--- nom du modele
      label $frm.model.nameLabel -text $::caption(modpoi2,model,name)
      pack $frm.model.nameLabel  -in [$frm.model getframe] -anchor w -side left -padx 0
      entry $frm.model.nameValue -state readonly \
         -textvariable ::modpoi2::main::private($visuNo,model,name)
      pack $frm.model.nameValue -in [$frm.model getframe] -anchor w -side left -padx 0 \
          -expand 0

      #--- date du modele
      label $frm.model.dateLabel -text $::caption(modpoi2,model,date)
      pack $frm.model.dateLabel  -in [$frm.model getframe] -anchor w -side left -padx 0
      entry  $frm.model.dateValue -state readonly -width 20 \
         -textvariable ::modpoi2::main::private($visuNo,model,date)
      pack $frm.model.dateValue -in [$frm.model getframe] -anchor w -side left -padx 0 \
         -expand false

      #--- commentaire du modele
      label $frm.model.commentLabel -text $::caption(modpoi2,model,comment)
      pack $frm.model.commentLabel  -in [$frm.model getframe] -anchor w -side left -padx 0
      entry $frm.model.commentValue \
         -textvariable ::modpoi2::main::private($visuNo,model,comment)
      pack $frm.model.commentValue -in [$frm.model getframe] -anchor w -side left -padx 0 \
          -expand true -fill x

   pack $frm.model -side top -fill x -expand 0

   ##PanedWindow $frm.paned -side left
   ##set paned1 [$frm.paned add -weight 1]
   ##set paned2 [$frm.paned add -weight 0]
   set paned1 $frm
   set paned2 $frm

   #--- liste des etoiles
   TitleFrame $paned1.star  -borderwidth 2 -relief ridge -text $::caption(modpoi2,starList)
      set private($visuNo,starTable) $paned1.star.table
      scrollbar $paned1.star.xsb -command "$private($visuNo,starTable) xview" -orient horizontal
      scrollbar $paned1.star.ysb -command "$private($visuNo,starTable) yview"

      #--- Table des reference
      ::tablelist::tablelist $private($visuNo,starTable) \
         -columns [list \
            0 $::caption(modpoi2,star,amerNum) right \
            0 $::caption(modpoi2,star,amerAz)  right \
            0 $::caption(modpoi2,star,amerEl)  right \
            0 $::caption(modpoi2,star,raShift) right \
            0 $::caption(modpoi2,star,deShift) right \
            0 $::caption(modpoi2,star,name)    center \
            0 $::caption(modpoi2,star,ra)      center \
            0 $::caption(modpoi2,star,de)      center \
            0 $::caption(modpoi2,star,date)    center \
            0 $::caption(modpoi2,star,haApp)   center \
          ] \
         -xscrollcommand [list $paned1.star.xsb set] \
         -yscrollcommand [list $paned1.star.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $private($visuNo,starTable) columnconfigure 0 -name amerNum
      $private($visuNo,starTable) columnconfigure 0 -name amerAz
      $private($visuNo,starTable) columnconfigure 1 -name amerEl
      $private($visuNo,starTable) columnconfigure 6 -name deltaRa
      $private($visuNo,starTable) columnconfigure 7 -name deltaDe
      $private($visuNo,starTable) columnconfigure 2 -name name
      $private($visuNo,starTable) columnconfigure 3 -name ra
      $private($visuNo,starTable) columnconfigure 4 -name dec
      $private($visuNo,starTable) columnconfigure 5 -name date
      $private($visuNo,starTable) columnconfigure 8 -name ha

      #--- je place la table et les scrollbars dans la frame
      grid $private($visuNo,starTable) -in [$paned1.star getframe] -row 0 -column 0 -sticky ewns
      grid $paned1.star.ysb  -in [$paned1.star getframe] -row 0 -column 1 -sticky nsew
      grid $paned1.star.xsb  -in [$paned1.star getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$paned1.star getframe] 0 -weight 1
      grid columnconfig [$paned1.star getframe] 0 -weight 1
   pack $paned1.star -side top -fill both -expand 1

   #--- table parametres du modele
   TitleFrame $paned2.table  -borderwidth 2 -relief ridge -text $::caption(modpoi2,parameters)
      set private($visuNo,coefficientTable) $paned2.table.table
      scrollbar $paned2.table.xsb -command "$private($visuNo,coefficientTable) xview" -orient horizontal
      scrollbar $paned2.table.ysb -command "$private($visuNo,coefficientTable) yview"

      #--- Table des coefficients
      ::tablelist::tablelist $private($visuNo,coefficientTable) \
         -columns [list \
            0 $::caption(modpoi2,codeColumn)  left \
            0 $::caption(modpoi2,nameColumn)  left \
            0 $::caption(modpoi2,valueColumn) right \
            0 $::caption(modpoi2,covarColumn) right \
          ] \
         -xscrollcommand [list $paned2.table.xsb set] \
         -yscrollcommand [list $paned2.table.ysb set] \
         -exportselection 0 \
         -activestyle none

      #--- je donne un nom a chaque colonne
      #--- j'ajoute l'option -stretchable pour que la colonne s'etire jusqu'au bord droit de la table
      #--- j'ajoute l'option -sortmode dictionary pour le tri soit independant de la casse
      $private($visuNo,coefficientTable) columnconfigure 0 -name code
      $private($visuNo,coefficientTable) columnconfigure 1 -name name
      $private($visuNo,coefficientTable) columnconfigure 2 -name value
      $private($visuNo,coefficientTable) columnconfigure 3 -name covar

      #--- chisquare
      label $paned2.table.chisquare -justify center \
          -textvariable ::modpoi2::main::private($visuNo,model,interp)

      #--- je place les widgets dans la frame
      grid $private($visuNo,coefficientTable) -in [$paned2.table getframe] -row 0 -column 0 -sticky ewns
      grid $paned2.table.ysb  -in [$paned2.table getframe] -row 0 -column 1 -sticky nsew
      grid $paned2.table.xsb  -in [$paned2.table getframe] -row 1 -column 0 -sticky ew
      grid $paned2.table.chisquare  -in [$paned2.table getframe] -row 2 -column 0 -columnspan 2
      grid rowconfig    [$paned2.table getframe] {0 1} -weight 1
      grid columnconfig [$paned2.table getframe] 0 -weight 1
   pack $paned2.table -side top -fill x -expand 0

   ###pack $frm.paned -side top -fill both -expand 1

   #--- je recupere les informations de la monture
   ::modpoi2::main::onChangeMount $visuNo
}

#------------------------------------------------------------
# onCreateModel
#    demarre le wizad pour creer un nouveau modele
#
# @param visuNo numero de la visu
# @private
#
#------------------------------------------------------------
proc ::modpoi2::main::onCreateModel { visuNo } {
   variable private

   #--- je descative le modele courant du telescope
   ::confTel::setModelEnabled 0

   #--- je demarre le wizard
   ::modpoi2::wizard::modpoi_wiz $visuNo
}

#------------------------------------------------------------
# onLoadModel
#    ouvre le fichier d'un modele et charge les parametres
#
# @param visuNo numero de la visu
# @private
#
#------------------------------------------------------------
proc ::modpoi2::main::onLoadModel { visuNo } {
   variable private

   #--- j'ouvre la fenetre de selection du modele de pointage
   set initialdir [ file join $::audace(rep_home) modpoi ]
   set fileName [ ::tkutil::box_load [winfo toplevel $private($visuNo,frm)] $initialdir $::audace(bufNo) "10" ]
   #--- je charge les donnees du modele de pointage
   if { $fileName != "" } {

      set loadModelError [catch {
         set result [::confTel::loadModel $fileName ]
         set private($visuNo,model,fileName)     $fileName
         set private($visuNo,model,name)         [lindex $result 0]
         set private($visuNo,model,date)         [lindex $result 1]
         set private($visuNo,model,comment)      [lindex $result 2]
         set private($visuNo,starList)           [lindex $result 3]
         set private($visuNo,model,symbols)      [lindex $result 4]
         set private($visuNo,model,coefficients) [lindex $result 5]
         set private($visuNo,model,chisquare)    [lindex $result 6]
         set private($visuNo,model,covars)       [lindex $result 7]
         set private($visuNo,model,refraction)   [lindex $result 8]
         #--- j'affiche les etoiles
         displayStar $visuNo $private($visuNo,starList)
         #--- j'affiche les coefficients
         setCoefficient $visuNo $private($visuNo,model,symbols) \
           $private($visuNo,model,coefficients) \
           $private($visuNo,model,covars) \
           $private($visuNo,model,chisquare)

         set private($visuNo,modified) 0
      }]
      if { $loadModelError != 0 } {
         ::tkutil::displayErrorInfo $::caption(modpoi2,title)
      }
   }
}

#------------------------------------------------------------
# saveModel
#    sauve le modele dans un fichier
#
# @param visuNo numero de la visu
# @private
#
#------------------------------------------------------------
proc ::modpoi2::main::onSave { visuNo } {
   variable private

   #--- je calcule la date de modification
   set private($visuNo,model,date) [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]

   saveModel $private($visuNo,model,fileName) \
      $private($visuNo,model,date) $private($visuNo,model,comment) \
      $private($visuNo,starList) \
      $private($visuNo,model,symbols) $private($visuNo,model,coefficients) \
      $private($visuNo,model,covars) $private($visuNo,model,chisquare) \
      $private($visuNo,model,refraction)

   set private($visuNo,modified) 0
}

#------------------------------------------------------------
# onSaveAs
#    sauve le modele dans un nouveau fichier
#
# @private
# @param visuNo numero de la visu
# @return non du fichier . Le nom du fichier est vide si l'utilisateur a abandonne l'enregistrement
#------------------------------------------------------------
proc ::modpoi2::main::onSaveAs { visuNo } {
   variable private

   #--- j'ouvre la fenetre de selection du modele de pointage
   set initialdir [ file join $::audace(rep_home) modpoi ]
   if { ! [ file exist $initialdir ] } {
      #--- Si le repertoire modpoi n'existe pas, le creer
      file mkdir $initialdir
   }
   set fileName [ tk_getSaveFile -title "Enregistrer modele" \
         -filetypes [ list [ list "XML model" ".xml" ] [ list "TXT (old model)" ".txt" ] ] \
         -initialdir $initialdir \
         -parent [winfo toplevel $private($visuNo,frm)] \
         -defaultextension ".xml" \
       ]
   if { $fileName != "" } {
      #--- je calcule la date de modification
      set private($visuNo,model,date) [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
      #--- j'enregistre le fichier
      saveModel $fileName \
         $private($visuNo,model,date) $private($visuNo,model,comment) \
         $private($visuNo,starList) \
         $private($visuNo,model,symbols) $private($visuNo,model,coefficients) \
         $private($visuNo,model,covars) $private($visuNo,model,chisquare) \
         $private($visuNo,model,refraction)
      #--- je memorise le nouveau nom du fichier
      set private($visuNo,model,fileName) $fileName
      set private($visuNo,modified) 0

   }

   return $fileName
}

#------------------------------------------------------------
# saveModel
#    sauve le modele dans un fichier
#
# @private
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::modpoi2::main::saveModel { fileName date comment starList symbols coefficients covars chisquare refraction} {
   variable private

   package require dom
   if { $fileName != "" } {
      set modelDom [::dom::DOMImplementation create]
      set modelElement [::dom::document createElement $modelDom TPOINT_MODEL ]
      ::dom::element setAttribute $modelElement "UT_DATE" $date
      ::dom::element setAttribute $modelElement "VERSION" "1.0"
      ::dom::element setAttribute $modelElement "COMMENT" $comment

      #--- j'ajoute les etoiles
      set startsNode [::dom::document createElement  $modelElement "STARS" ]

      foreach star $starList {
         #--- j'ajoute une etoile
         set starNode  [::dom::document createElement $startsNode "STAR" ]
         ::dom::element setAttribute $starNode "AMER_AZ"     [lindex $star 0]
         ::dom::element setAttribute $starNode "AMER_EL"     [lindex $star 1]
         ::dom::element setAttribute $starNode "NAME"        [lindex $star 2]
         ::dom::element setAttribute $starNode "CAT_RA"      [lindex $star 3]
         ::dom::element setAttribute $starNode "CAT_DE"      [lindex $star 4]
         ::dom::element setAttribute $starNode "CAT_EQUINOX" [lindex $star 5]
         ::dom::element setAttribute $starNode "OBS_DATE"    [lindex $star 6]
         ::dom::element setAttribute $starNode "OBS_RA"      [lindex $star 7]
         ::dom::element setAttribute $starNode "OBS_DE"      [lindex $star 8]
         ::dom::element setAttribute $starNode "PRESSURE"    [lindex $star 9]
         ::dom::element setAttribute $starNode "TEMPERATURE" [lindex $star 10]
      }

      #--- j'ajoute les coefficients
      set coeffsNode [::dom::document createElement  $modelElement "COEFFICIENTS" ]
      for { set coeffNum 0 } { $coeffNum < [llength $symbols] } { incr coeffNum } {
         set coeffNode  [::dom::document createElement $coeffsNode "COEFFICIENT" ]
         ::dom::element setAttribute $coeffNode "SYMBOL"  [lindex $symbols $coeffNum]
         ::dom::element setAttribute $coeffNode "VALUE"   [lindex $coefficients $coeffNum]
         ::dom::element setAttribute $coeffNode "COVAR"   [lindex $covars $coeffNum]
      }
      ::dom::element setAttribute $coeffsNode "CHISQUARE"  $chisquare
      ::dom::element setAttribute $coeffsNode "REFRACTION" $refraction

      #--- j'enregistre le fichier
      set hfile [open $fileName w]
      puts $hfile [::dom::tcl::serialize $modelDom -indent true ]
      close $hfile

      ::dom::tcl::destroy $modelDom
   }
}

#------------------------------------------------------------
# @brief  listener pour surveiller le changement de monture
#   
#
# @private
# @param visuNo numero de la visu
# @param args  parametres ajoutes par le listener
#------------------------------------------------------------
proc ::modpoi2::main::onChangeMount { visuNo args } {
   variable private

   if { $::audace(telNo) != 0 } {
      set private($visuNo,mount,name) [::confTel::getPluginProperty  "name"]
      set modelEnabled [ tel$::audace(telNo) radec model -enabled]
      if { $modelEnabled == 1 } {
         set private($visuNo,mount,modelName) [ tel$::audace(telNo) radec model -name]
         set private($visuNo,mount,modelDate) [ tel$::audace(telNo) radec model -date]
      } else {
         set private($visuNo,mount,modelName) ""
         set private($visuNo,mount,modelDate) ""
      }
      set private($visuNo,mount,name) [::confTel::getPluginProperty  "name"]

   } else {
      set private($visuNo,mount,modelName) ""
      set private($visuNo,mount,modelDate) ""
   }

   ###if { $private($visuNo,model,name) != "" } {
   ###   if { $private($visuNo,mount,modelName) != $private($visuNo,model,name)
   ###      || $private($visuNo,mount,modelDate) != $private($visuNo,model,date) } {
   ###     $private($visuNo,frm).mount.applyModel configure -state normal
   ###   } else {
   ###      $private($visuNo,frm).mount.applyModel configure -state disable
   ###   }
   ###}

}

#------------------------------------------------------------
# onApplyModel
#    applique le model courant sur la monture
#
# @private
# @param visuNo numero de la visu
# @param args  parametres ajoutes par le listener
#------------------------------------------------------------
proc ::modpoi2::main::onApplyModel { visuNo } {
   variable private

   if { $::audace(telNo) != 0 } {

      if { $private($visuNo,modified) == 1 } {
         set choix [ tk_dialog $private($visuNo,this).selectSave \
            $::caption(modpoi2,modele_appliquer) \
            $::caption(modpoi2,modele_appliquer2) \
            question \
            1 \
            "$::caption(audace,menu,enregistrer)" \
            "$::caption(audace,menu,enregistrer_sous)..." \
            "$::caption(modpoi2,choix,cancel)" \
         ]
         switch $choix {
            "0" {
               #--- choix enregistrer
               onSave $visuNo
            }
            "1" {
               #--- choix enregistrer sous
               set fileName [onSaveAs $visuNo]
               if { $fileName == "" } {
                  #--- l'utilisateur a abandonne l'enregistrement
                  return
               }
            }
            "2" {
               #--- choix abandonner
               return
            }
         }
      }

      #--- je charge le modele dans la monture
      ::confTel::setModelFileName $private($visuNo,model,fileName)
      #--- j'active le modèle
      ::confTel::setModelEnabled  1
      #--- je recupere les parametres du modele pour verifier
      onChangeMount $visuNo
      #--- j'affiche un message d'information
      tk_messageBox -title "$::caption(modpoi2,wiz1b,warning)" -message "$::caption(modpoi2,modele_existe)" -type ok

   } else {
      #--- j'affiche la fenetre de choix de la monture
     ::confTel::run
   }
}

#------------------------------------------------------------
# displayStar
#   affiche la liste des etoiles
#
# @private
# @param visuNo numero de la visu
# @param starList liste d'étoiles  ( amerAz amerEl name raCat deCat equinoxCat date raObs deObs pressure temperature )
#
#------------------------------------------------------------
proc ::modpoi2::main::displayStar { visuNo starList} {
   variable private

   $private($visuNo,starTable) delete 0 end
   set private($visuNo,starList) $starList
   for {set k 0} { $k <  [llength $starList] } { incr k} {
      set starLine [lindex $starList $k]
      if { [lindex $starLine 0] != "" } {
         set amerAz   [format "%.2f" [lindex $starLine 0]]
         set amerEl   [format "%.2f" [lindex $starLine 1]]
      } else {
         set amerAz "0"
         set amerEl "0"
      }

      set starName     [lindex $starLine 2]
      if { $starName != "" } {
         set raCat       [lindex $starLine 3]
         set deCat       [lindex $starLine 4]
         set eqCat       [lindex $starLine 5]
         set date        [ string map { T " " } [lindex $starLine 6]]
         set raObs       [mc_angle2deg [lindex $starLine 7]]
         set deObs       [mc_angle2deg [lindex $starLine 8]]
         set pressure    [lindex $starLine 9]
         set temperature [lindex $starLine 10]

         #--- je recupere les coordonnees apparentes à la date de l'observation
         set hipRecord [list $starName "0" [mc_angle2deg $raCat] [mc_angle2deg $deCat] $eqCat 0 0 0 0 ]
         set coords [mc_hip2tel $hipRecord [lindex $starLine 6] $::audace(posobs,observateur,gps) $pressure $temperature]
         set raApp [lindex $coords 0]
         set deApp [lindex $coords 1]
         set haApp [mc_angle2hms [lindex $coords 2] 360 zero 0 auto string]
         set azApp [lindex $coords 3]
         set elApp [lindex $coords 4]
         #--- je calcule l'ecart en arcmin
         ###set haObs [lindex [mc_radec2altaz [mc_angle2deg $raObs] [mc_angle2deg $deObs] $::audace(posobs,observateur,gps) [lindex $starLine 6] ] 2]
         ####---mc_hadec2altaz Angle_HA Angle_dec Home  => az , el, parallactic
         ###set altaz [mc_hadec2altaz [lindex $coords 2] [lindex $coords 1] $::audace(posobs,observateur,gps)]
         ####---mc_altaz2radec Angle_az Angle_alt Home Date
         ###set radec [mc_altaz2radec [lindex $altaz 0] [lindex *$altaz 1] $::audace(posobs,observateur,gps) [lindex $starLine 6] ]
         ###set raApp [lindex $radec 0]

         #---- attention
         set raDelta [format "%8.3f" [expr 60.0 * [mc_anglescomp $raObs - $raApp ]]]
         set deDelta [format "%8.3f" [expr 60.0 * [mc_anglescomp $deObs - $deApp ]]]
      } else {
         set date    ""
         set raCat   ""
         set deCat   ""
         set raDelta ""
         set deDelta ""
         set haApp   ""
      }
      #--- j'ajoute la ligne dans la table
      $private($visuNo,starTable) insert end [list [expr $k +1] $amerAz $amerEl $raDelta $deDelta  $starName $raCat $deCat $date $haApp]
   }
}

#------------------------------------------------------------
#  onEditModel
#     modifier le modele
#
# @private
# @param visuNo numero de la visu
#------------------------------------------------------------
proc ::modpoi2::main::onEditModel { visuNo } {
   variable private

   #--- je descative le modele courant du telescope
   ::confTel::setModelEnabled 0

   ::modpoi2::wizard::modpoi_wiz $visuNo $private($visuNo,starList)

}

#------------------------------------------------------------
#  onEditHorizon
#     modifier l'horizon
#
# @private
# @param visuNo numero de la visu
#------------------------------------------------------------
proc ::modpoi2::main::onEditHorizon { visuNo } {
   variable private

   ::horizon::run $visuNo

}

#------------------------------------------------------------
# setCoefficient
#   affiche les coefficients du modele
#
# @private
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::modpoi2::main::setCoefficient { visuNo symbols coefficients covars chisquare } {
   variable private

   #--- je memorise les coefficients
   set private($visuNo,model,symbols)      $symbols
   set private($visuNo,model,coefficients) $coefficients
   set private($visuNo,model,covars)       $covars
   set private($visuNo,model,chisquare)    $chisquare

   #--- j'affiche les coefficients
   displayCoefficient $visuNo $symbols $coefficients $covars

   #--   interprete le X²
   set nbValues [llength $private($visuNo,starList)]
   set nbParameters [llength $private($visuNo,model,symbols)]
   lassign [::modpoi2::process::computePconf $chisquare $nbValues $nbParameters] p kappa
   set private($visuNo,model,interp) [format $::caption(modpoi2,interp) $chisquare $p $kappa]

   if { [::confTel::isReady] == 1 } {
       ###tk_messageBox -title "$caption(modpoi,wiz1b,warning)" -message "$caption(modpoi,modele,editer)" -icon error

   }
}

#------------------------------------------------------------
# displayCoefficient
#   affiche les coefficents du modele
#
# @private
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::modpoi2::main::displayCoefficient { visuNo symbols coefficients covars } {
   variable private

   $private($visuNo,coefficientTable) delete 0 end
   for { set rowIndex 0 } { $rowIndex < [llength $symbols ]} { incr rowIndex } {
      set symbol [lindex $symbols $rowIndex]
      if { [info exists ::caption(modpoi2,symbolName,$symbol)] } {
         set symbolName   $::caption(modpoi2,symbolName,$symbol)
      } else {
         set symbolName  ""
      }
      if { [lindex $coefficients $rowIndex] != "" }  {
         set coefficient [format "%.2f" [lindex $coefficients $rowIndex]]
         set covar [format "%.2f" [expr pow([gsl_mindex $covars [expr $rowIndex +1] [expr $rowIndex +1]],2)]]
      } else {
         set coefficient 0.0
         set covar 0.0
      }
      $private($visuNo,coefficientTable) insert $rowIndex [list $symbol $symbolName $coefficient $covar ]
   }
   $private($visuNo,coefficientTable)  configure -height [llength $symbols ]

}

#------------------------------------------------------------
# modifyModel
#   affiche les coefficents du modele
#
# @private
# @param visuNo numero de la visu
#
#------------------------------------------------------------
proc ::modpoi2::main::modifyModel { visuNo starList symbols coefficients covars chisquare } {
   variable private

   #--- j'affiche la liste des etoiles
   displayStar $visuNo $starList
   #--- j'affiche les coefficients
   ::modpoi2::main::setCoefficient $visuNo $symbols $coefficients $covars $chisquare

   #--- j'affiche la date de mise a jour du modele dans la fenetre principale
   set private($visuNo,model,date) [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]

   #--- je positionne le flag de modification du modele
   set private($visuNo,modified) 1
}


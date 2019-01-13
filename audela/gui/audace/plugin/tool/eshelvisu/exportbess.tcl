#
# Fichier : exportbess.tcl
# Description : Export de fichier au format BeSS
# Auteurs : Michel Pujol
# Mise a jour $Id: exportbess.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

################################################################
# namespace ::eshelvisu::exportbess
#
# Procedures principales
#
# ::eshelvisu::exportbess::run
#     affiche une fenetre de controle et exporte les profils d'un fichiers eShel
#
# ::eshelvisu::exportbess::export
#     export
################################################################

namespace eval ::eshelvisu::exportbess {
   variable private

}


   # OBJNAME
   # DATE-OBS
   # DATE-END
   # TELESCOP
   # DETNAM
   # INSTRUME
   # OBSERVER
   # BSS_SITE
   # BSS_ORD
   # BSS_VHEL
   # BSS_NORM
   # EXPOSURE

   # NAXIS
   # NAXIS1
   # CRVAL1
   # CDELT1
   # CRPIX1
   # CUNIT1
   # CTYPE1



## run ------------------------------------------------------------
# affiche la fenetre d'eport des profils au format BeSS
#
# @param visuNo  numero de la visu
# @param fileName   nom du fichier d'entree
# @param keywordHduIndex  numero du HDU contenant les mots clefs (la numeration commence a 1)
# @return
#   - 1 si l'export est validee
#   - 0 si l'export est abandonne
#------------------------------------------------------------
proc ::eshelvisu::exportbess::run { visuNo inputFileName keywordHduIndex} {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,exportbess,position) ] } { set ::conf(eshel,exportbess,position)     "420x440+100+15" }
   ###if { ! [ info exists ::conf(eshel,exportbess,exportOrder) ] } { set ::conf(eshel,exportbess,exportOrder)  "P_1C_*" }
   if { ! [ info exists ::conf(eshel,exportbess,zippedOutput) ] } { set ::conf(eshel,exportbess,zippedOutput)  0 }
   if { ! [ info exists ::conf(eshel,exportbess,outputDirectory) ] } { set ::conf(eshel,exportbess,outputDirectory)  $::audace(rep_images) }
   if { ! [ info exists ::conf(eshel,exportbess,outputBitpix) ] }    { set ::conf(eshel,exportbess,outputBitpix)  -32 }
   if { ! [ info exists ::conf(eshel,exportbess,bessInst) ] }        { set ::conf(eshel,exportbess,bessInst)    "" }
   set private(keywordNamesList) "OBJNAME BSS_RA BSS_DEC DATE-OBS DATE-END EXPOSURE BSS_SITE BSS_INST TELESCOP INSTRUME DETNAM BSS_VHEL BSS_TELL BSS_NORM BSS_COSM OBSERVER"
   set private(mandatoryList)    "OBJNAME DATE-OBS DATE-END BSS_SITE DETNAM INSTRUME TELESCOP BSS_VHEL OBSERVER"
   set private($visuNo,closeWindow)   1
   set private($visuNo,inputFileName) $inputFileName

   #--- le zip des fichiers n'est pas implémenté pour l'instant
   set ::conf(eshel,exportbess,zippedOutput) 0

   #--- je charge les mots clefs et le profil du fichier (
   set catchResult [catch {
      loadFile $visuNo $inputFileName $keywordHduIndex
   } ]

   if { $catchResult == 1 } {
      #--- j'affiche un message d'erreur pour toutes autres erreurs non prevues
      ::tkutil::displayErrorInfo $::caption(eshelvisu,exportBess,title)
      return 0
   }


   #--- j'affiche la fenetre de controle des mots clefs
   #---  la fenetre est modale (::confGenerique::run attend sa fermeture avant de continuer)
   set tkBase [::confVisu::getBase $visuNo]
   set private($visuNo,This) "$tkBase.exportbess"
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshelvisu::exportbess" \
      -modal 1 -geometry $::conf(eshel,exportbess,position) -resizable 1 ]

   return $result
}

## ------------------------------------------------------------
# retourne le titre de la fenetre
#
# Cette procedure est appelée par ::confGenerique::getLabel
# @return  titre de la fenêtre
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::getLabel { } {
   global caption

   return "$caption(eshelvisu,title) - $::caption(eshelvisu,exportBess,title)"
}


##------------------------------------------------------------
# controle et exporte les profils (appelle ::eshelvisu::exportbess::saveFile)
# <br> Propose d'afficher la liste des profils exportés
# Cette procedure est appelée par ::confGenerique::cmdApply
# @param visuNo  numero de la visu parent
# @return rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::cmdApply { visuNo } {
   variable private
   variable widget

   ##set ::conf(eshel,exportbess,exportOrder)     $widget($visuNo,exportOrder)
   set ::conf(eshel,exportbess,zippedOutput)    $widget($visuNo,zippedOutput)
   set private($visuNo,outputFileName)          $widget($visuNo,outputFileName)
   set ::conf(eshel,exportbess,outputDirectory) [file normalize $widget($visuNo,outputDirectory)]


   #--- je cree le fichier BeSS
   set catchResult [catch {
      saveFile $visuNo
   } catchMessage ]

   if { $catchResult == 1 } {
      ::tkutil::displayErrorInfo $::caption(eshelvisu,exportBess,title)
      set private($visuNo,closeWindow) 0
   } else {
      set private($visuNo,closeWindow) 1
      set message [format $::caption(eshelvisu,exportBess,exportDone) $::conf(eshel,exportbess,outputDirectory)]
      set choix [ tk_messageBox -type yesno -message $message -icon info -title $::caption(eshelvisu,exportBess,title)]
      if { $choix == "yes" } {
         #--- j'ouvre une fenetre pour afficher des profils
         set visuDir [::confVisu::create]
         #--- je selectionne l'outil eShel Visu
         confVisu::selectTool $visuDir ::eshelvisu
         #--- je pointe le repertoire des images brutes
         set ::eshelvisu::localTable::private($visuDir,directory) $::conf(eshel,exportbess,outputDirectory)
         #--- j'affiche le contenu du répertoire
         ::eshelvisu::localTable::fillTable $visuDir
      }
   }
}


##------------------------------------------------------------
# ferme la fenetre
#
# Cette procedure est appelée par ::confGenerique::cmdClose
# @param visuNo  numero de la visu
# @return
#   - 0  s'il ne faut pas fermer la fenêtre
#   - 1  s'il faut fermer la fenêtre
# @public
#------------------------------------------------------------
proc ::eshelvisu::exportbess::cmdClose { visuNo } {
   variable private

   if { $private($visuNo,closeWindow) == 0 } {
      #--- je repositionne la valeur par defaut
      set private($visuNo,closeWindow) 1
      #--- j'arrete le traitement et retourne 0 pour empecher la fermeture de la fenetre
      return 0
   }

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,exportbess,position) [ wm geometry $private($visuNo,This) ]


   return
}

##------------------------------------------------------------
# cree les widgets de la fenetre de controle
#
# Cette procedure est appelée par ::confGenerique::fillConfigPage
# @param frm nom tk de la frame cree par ::confgene::fillConfigPage
# @param visuNo numero de la visu
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::fillConfigPage { frm visuNo } {
   variable private
   variable widget

   set private($visuNo,frm) $frm
   #--- je copie les valeurs dans les variables temporaires
   ###set widget($visuNo,exportOrder)   $::conf(eshel,exportbess,exportOrder)
   set widget($visuNo,zippedOutput)    $::conf(eshel,exportbess,zippedOutput)
   set widget($visuNo,outputDirectory) [file nativename $::conf(eshel,exportbess,outputDirectory)]

   #--- frame des mots clefs
   TitleFrame  $frm.keywords -borderwidth 2 -relief ridge -text "$::caption(eshelvisu,exportBess,keywordControl)"
      set row 0
      foreach keywordName $private(keywordNamesList) {
         #--- j'ajoute une ligne par mot clef
         Label $frm.label$keywordName -text $::caption(eshelvisu,exportBess,label,$keywordName)
         set keywordName2 $keywordName
         if { [lsearch $private(mandatoryList) $keywordName ] != -1 } {
            append keywordName2 " (*)"
         }

         Label $frm.name$keywordName  -text $keywordName2
         Entry $frm.value$keywordName -textvariable ::eshelvisu::exportbess::private($visuNo,value,$keywordName)

         grid $frm.label$keywordName -in [$frm.keywords getframe] -row $row -column 0 -sticky nw
         grid $frm.name$keywordName  -in [$frm.keywords getframe] -row $row -column 1 -sticky nw
         grid $frm.value$keywordName -in [$frm.keywords getframe] -row $row -column 2 -sticky ew
         ###grid columnconfig [$frm.keywords getframe] $row -weight 1

         #--- ajoute un bouton les mots clefs qui possedent une valeur par defaut dans la configuration instrument
         switch $keywordName {
            BSS_INST -
            INSTRUME -
            TELESCOP -
            DETNAM {
               Button $frm.keywords.button$keywordName -text $::caption(eshelvisu,exportBess,currentConfig)  \
                  -command "::eshelvisu::exportbess::getCurrentInstrumentValue $visuNo $keywordName"
               grid $frm.keywords.button$keywordName -in [$frm.keywords getframe] -row $row -column 3  -padx 2 -sticky nw
            }
            BSS_TELL -
            BSS_COSM -
            BSS_NORM {
               #--- je cree la combobox avec les valeurs du mots clefs
               set values [list "none" "removed" "method: xxx" ]
               ComboBox $frm.keywords.combo$keywordName \
                  -height [ llength $values ] \
                  -relief sunken -borderwidth 1 -editable 1 \
                  -textvariable ::eshelvisu::exportbess::private($visuNo,value,$keywordName) \
                  -values $values
               grid $frm.keywords.combo$keywordName -in [$frm.keywords getframe] -row $row -column 3  -padx 2 -sticky n
               ###$frm.keywords.combo$keywordName setvalue "@0"
            }

         }
         #--- je passe a la ligne suivante
         incr row
      }

      Label $frm.keywords.mandatoryLabel -text "(*) mot cle obligatoire"
      grid $frm.keywords.mandatoryLabel -in [$frm.keywords getframe] -row $row -column 1  -sticky nw

      ##grid rowconfig [$frm.keywords getframe] 0 -weight 0
      ###grid rowconfig [$frm.keywords getframe] 1 -weight 0
      grid columnconfig [$frm.keywords getframe] 2 -weight 1
   pack $frm.keywords -side top -anchor nw -fill x -expand 0

   #--- frame des option d'export
   TitleFrame $frm.file  -borderwidth 2 -relief ridge -text $::caption(eshelvisu,exportBess,outputFile)

      Label $frm.file.orderLabel -text $::caption(eshelvisu,exportBess,outputProfile)
      ###set list_combobox { "P_1C_*" "P_1C_FULL" }
      ###ComboBox $frm.file.exportOrder \
      ###   -width 10  -height [ llength $list_combobox ] \
      ###   -relief sunken -borderwidth 1 -editable 1 \
      ###   -textvariable ::eshelvisu::exportbess::widget($visuNo,exportOrder) \
      ###   -modifycmd "::eshelvisu::exportbess::onSelectExportedOrder $visuNo" \
      ###   -values $list_combobox
      Label $frm.file.exportOrder -text "P_1C_*"

      checkbutton $frm.file.zippedOutput -text $::caption(eshelvisu,exportBess,zippedOuput) \
         -variable ::eshelvisu::exportbess::widget($visuNo,zippedOutput) \
         -state disabled \
         -command "::eshelvisu::exportbess::onSelectExportedOrder $visuNo"
      Label $frm.file.nameLabel -text $::caption(eshelvisu,exportBess,outputFileName)
      Entry $frm.file.nameEntry -textvariable ::eshelvisu::exportbess::widget($visuNo,outputFileName) -state disabled
      Label $frm.file.directoryLabel -text $::caption(eshelvisu,exportBess,outputDirectory)
      Entry $frm.file.directoryEntry -textvariable ::eshelvisu::exportbess::widget($visuNo,outputDirectory)
      Button $frm.file.directoryButton -text "..." -command "::eshelvisu::exportbess::selectOuputDirectory $visuNo"

      grid $frm.file.orderLabel   -in [$frm.file getframe] -row 0 -column 0 -sticky nw
      grid $frm.file.exportOrder  -in [$frm.file getframe] -row 0 -column 1 -sticky nw
      grid $frm.file.zippedOutput -in [$frm.file getframe] -row 0 -column 2 -sticky nw
      grid $frm.file.nameLabel    -in [$frm.file getframe] -row 1 -column 0 -sticky nw
      grid $frm.file.nameEntry    -in [$frm.file getframe] -row 1 -column 1 -sticky ew -columnspan 2
      grid $frm.file.directoryLabel    -in [$frm.file getframe] -row 2 -column 0 -sticky nw
      grid $frm.file.directoryEntry    -in [$frm.file getframe] -row 2 -column 1 -sticky ew -columnspan 2
      grid $frm.file.directoryButton   -in [$frm.file getframe] -row 2 -column 3 -sticky nw

      grid columnconfig [$frm.file getframe] 2 -weight 1
   pack $frm.file -side top -anchor nw -fill x -expand 1

   #--- je mets a jour le nom du fichier de sortie
   onSelectExportedOrder $visuNo

}



##------------------------------------------------------------
# recupere la valeur de la configuration instrument courante pour les mots clés
#  - BSS_INST  : avec le nom de la configuration courante
#  - DETNAM    : avec le nom de la caméra de la configuration courante
#  - INSTRUME  : avec le nom du spectrographe de la configuration courante
#  - TELESCOP  : avec le nom du télescope de la configuration courante
# @param visuNo numero de la visu
# @param configName nom du mot clé
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::getCurrentInstrumentValue { visuNo keywordName } {
   variable private

   switch $keywordName {
      BSS_INST {
         set private($visuNo,value,BSS_INST)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),configName)
      }
      DETNAM {
         set private($visuNo,value,DETNAM)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraName)
      }
      INSTRUME {
         set private($visuNo,value,INSTRUME)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectroName)
      }
      TELESCOP {
         set private($visuNo,value,TELESCOP)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),telescopeName)
      }
   }
}


##------------------------------------------------------------
# constitue le nom du fichier de sortie en fonction des choix d'exportation
# <br>  format : <nom fichier origine>-<nom HDU>.fit
#
# @param visuNo numero de la visu
# @param configName nom du mot clé
# @return  rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::onSelectExportedOrder { visuNo } {
   variable private
   variable widget

   set rootName [file rootname [file tail $private($visuNo,inputFileName)]]
   set widget($visuNo,outputFileName) "${rootName}--P_1C_*.fit"
   $private($visuNo,frm).file.zippedOutput configure -state disabled
   $private($visuNo,frm).file.nameEntry    configure -state disabled
}

##------------------------------------------------------------
# selectOuputDirectory
#   selectionne le répertoire dans lequel les fichiers sont exportés
# @param numéro de la visu
# @return rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::selectOuputDirectory { visuNo } {
   variable private
   variable widget

   #--- j'ouvre la fenetre de choix du nom du fichier Bess
   set outputDirectory [ tk_chooseDirectory -title $::caption(eshelvisu,exportBess,title)  \
      -initialdir $::conf(eshel,exportbess,outputDirectory) \
      -parent [winfo toplevel $private($visuNo,frm)] ]

   #--- j'abandonne si aucun nom de fichier n'a ete saisi
   if { $outputDirectory == "" } {
         return
   } else {
      set widget($visuNo,outputDirectory) [file nativename $outputDirectory]
   }
}

##------------------------------------------------------------
# ::eshel::process::loadFile
#    charge un fichier FITS Eshel
#    controle les mots clefs du HDU numero keywordHduIndex
# @param fileName   nom du fichier d'entree
# @param keywordHduIndex   numero du HDU contenant les mots clefs (1 pour le permier HDU)
# @return rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::loadFile { visuNo inputFileName keywordHduIndex } {
   variable private

   set hFile ""

   #--- j'ouvre le fichier
   set catchResult [catch {

      #--- j'ouvre le fichier d'entree
      set hFile [fits open $inputFileName 0]
      set nbHdu [$hFile info nhdu]

      #--- je verifie que le hduIndex existe dans le fichier
      if { $keywordHduIndex < 1 || $keywordHduIndex > $nbHdu } {
         $hFile close
         error "Invalid HDU $keywordHduIndex"
      }

      #--- je verifie que le fichier contient au moins un profil 1C qui s'appelle P_1C_*
      set hduList ""
      set hduNo 1
      #--- je recupere la liste des HDU
      while { $hduNo <= $nbHdu   }  {
         #--- je pointe le premier HDU
         $hFile move $hduNo
         if { [catch {getKeyword $hFile "EXTNAME"} hduName] == 0 } {
               lappend hduList $hduNo $hduName
         }
         incr hduNo
      }
      #--- j'affiche un message d'erreur si le fichier ne contient pas
      #--- au moins un profil qui s'appelle P_1B_* ou P_FULL*
      if {  [regexp (P_FULL)|(P_1C_) $hduList ] == 0 } {
         error $::caption(eshelvisu,exportBess,noProfileError)
      }

      #--- je pointe le HDU contenant les mots clefs
      set extensionType [$hFile move $keywordHduIndex]

      #--- je verifie que le HDU contient une image
      if { $extensionType != 0 } {
         $hFile close
         error "Invalid image $hduIndex"
      }


      #--- je lis les mots clefs
      set keywordValues [$hFile get keyword ]

      if { [catch {getKeyword $hFile "OBJNAME"} value] == 0 } {
         set private($visuNo,value,OBJNAME) $value
      } else {
         set private($visuNo,value,OBJNAME) ""
      }

      if { [catch {getKeyword $hFile "RA"} value] == 0 } {
         set value [mc_angle2hms $value 360 nozero 0 auto string]
         set private($visuNo,value,BSS_RA) $value
      } else {
         set private($visuNo,value,BSS_RA) ""
      }
      if { [catch {getKeyword $hFile "DEC"} value] == 0 } {
         set value [mc_angle2dms $value 90 nozero 0 + string]
         set private($visuNo,value,BSS_DEC) $value
      } else {
         set private($visuNo,value,BSS_DEC) ""
      }

      if { [catch {getKeyword $hFile "DATE-OBS"} value] == 0 } {
         set private($visuNo,value,DATE-OBS) $value
      } else {
         set private($visuNo,value,DATE-OBS) "yyyy-mm-ddThh:mm:ss.ss"
      }

      if { [catch {getKeyword $hFile "DATE-END"} value] == 0 } {
         set private($visuNo,value,DATE-END) $value
      } else {
         set private($visuNo,value,DATE-END) "yyyy-mm-ddThh:mm:ss.ss"
      }

      if { [catch {getKeyword $hFile "EXPOSURE"} value] == 0 } {
         set private($visuNo,value,EXPOSURE) $value
      } else {
         set private($visuNo,value,EXPOSURE) ""
      }

      if { [catch {getKeyword $hFile "SITENAME"} value] == 0 } {
         set private($visuNo,value,BSS_SITE) $value
      } else {
         if { [catch {getKeyword $hFile "BSS_SITE"} value] == 0 } {
            set private($visuNo,value,BSS_SITE) $value
         } else {
            set private($visuNo,value,BSS_SITE) ""
         }
      }


      if { [catch {getKeyword $hFile "DETNAM"} value] == 0 } {
         set private($visuNo,value,DETNAM) $value
      } else {
         set private($visuNo,value,DETNAM) ""
      }
      if { [catch {getKeyword $hFile "INSTRUME"} value] == 0 } {
         set private($visuNo,value,INSTRUME) $value
      } else {
         set private($visuNo,value,INSTRUME) ""
      }
      if { [catch {getKeyword $hFile "TELESCOP"} value] == 0 } {
         set private($visuNo,value,TELESCOP) $value
      } else {
         set private($visuNo,value,TELESCOP) ""
      }

#      if { [catch {getKeyword $hFile "CONFNAME"} value] == 0 } {
#         set private($visuNo,value,BSS_INST) $value
#      } else {
#         set private($visuNo,value,BSS_INST) ""
#      }

      set private($visuNo,value,BSS_INST) $::conf(eshel,exportbess,bessInst)

      if { [catch {getKeyword $hFile "BSS_VHEL"} value] == 0 } {
         set private($visuNo,value,BSS_VHEL) $value
      } else {
         set private($visuNo,value,BSS_VHEL) "0"
      }
      if { [catch {getKeyword $hFile "BSS_TELL"} value] == 0 } {
         set private($visuNo,value,BSS_TELL) $value
      } else {
         set private($visuNo,value,BSS_TELL) "none"
      }

      if { [catch {getKeyword $hFile "BSS_NORM"} value] == 0 } {
         set private($visuNo,value,BSS_NORM) $value
      } else {
         set private($visuNo,value,BSS_NORM) "none"
      }

      if { [catch {getKeyword $hFile "BSS_COSM"} value] == 0 } {
         set private($visuNo,value,BSS_COSM) $value
      } else {
         set private($visuNo,value,BSS_COSM) "none"
      }

      if { [catch {getKeyword $hFile "OBSERVER"} value] == 0 } {
         set private($visuNo,value,OBSERVER) $value
      } else {
         set private($visuNo,value,OBSERVER) ""
      }

   } ]

   #--- je referme le fichiier
   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult == 1 } {
      #--- je transmet l'erreur
      error $::errorInfo
   }
}



##------------------------------------------------------------
# retourne la valeur d'un mot clef
#
# @param   hFile          handle du fichier fitd
# @param   keywordName    nom du mot clef
#
# @return valeur du mot clef
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::getKeyword { hFile keywordName} {
   variable private

   #--- je recupere les mots clefs dans le nom contient la valeur keywordName
   #--- cette fonction retourne une liste de triplets { name value description }
   set keywords [$hFile get keyword $keywordName]
   #--- je cherche le mot cle qui a exactement le nom requis
   foreach keyword $keywords {
      set name [lindex $keyword 0]
      set value [lindex $keyword 1]
      if { $name == $keywordName } {
         #--- je supprime les apostrophes et les espaces qui entourent la valeur
         set value [string trim [string map {"'" ""} [lindex $keyword 1] ]]
         break
      }
   }
   if { $name != $keywordName } {
      #--- je retourne une erreur si le mot clef n'est pas trouve
      error "keyword $keywordName not found"
   }
   return $value
}



##------------------------------------------------------------
#
#   cree un fichier au format BeSS
#   controle les mots clefs obligatoires
#   - OBJNAME
#   - DATE-OBS
#   - DATE-END
#   - TELESCOP
#   - DETNAM
#   - INSTRUME
#   - OBSERVER
#   - BSS_SITE
#   - BSS_ORD
#   - BSS_VHEL
#   - BSS_NORM
#
#   Mots clefs facultatifs
#   - BSS_RA
#   - BSS_DEC
#   - BSS_INST
#
#   Ajoute automatiquement les autres mots clefs obligatoires
#   - NAXIS
#   - NAXIS1
#   - CRVAL1
#   - CDELT1
#   - CRPIX1
#   - CUNIT1
#   - CTYPE1

#   si tous les mots clefs sont corrects
#      cree le fichier BeSS
#   si un mot clefs n'est pas correctement rempli
#      retourne une exception
#
# @param numéro de la visu
# @return rien
# @private
#------------------------------------------------------------
proc ::eshelvisu::exportbess::saveFile { visuNo } {
   variable private

   #--- j'intialise le message d'erreur a vide
   set badKeywords ""

   #--- je verifie que les mots clefs obligatoires sont remplis
   foreach keywordName $private(mandatoryList) {
      if { [string length $private($visuNo,value,$keywordName)] < 1 } {
         append badKeywords "$keywordName: [format $::caption(eshelvisu,exportBess,keywordEmpty) $::caption(eshelvisu,exportBess,label,$keywordName)]\n"
      }
   }

   #--- controle OBJNAME
   #---    Verifier le longueur du champ
   #---    Verifier les caracteres que des caracteres acceptes par la norme FITS ( code ASCII 20h a 7Eh)
   if { [string length $private($visuNo,value,OBJNAME)] > 70 } {
      append badKeywords ". [format $::caption(eshelvisu,exportBess,keywordTooLarge) $::caption(eshelvisu,exportBess,label,OBJNAME)]\n"
   } elseif { [string is ascii -failindex charIndex $private($visuNo,value,OBJNAME)] == 0  } {
      append badKeywords "OBJNAME: [format $::caption(eshelvisu,exportBess,keywordBadChar) $::caption(eshelvisu,exportBess,label,OBJNAME)]: [string range $private($visuNo,value,OBJNAME) $charIndex $charIndex]\n"
   }

   #--- controle BSS_RA et BSS_DEC
  if { $private($visuNo,value,BSS_RA) != "" || $private($visuNo,value,BSS_DEC) != "" } {
      #--- controle BSS_RA
      #---    Verifier le longueur du champ
      #---    Verifier la coherence de la valeur
      if { [string length $private($visuNo,value,BSS_RA)] < 1 } {
         append badKeywords ". [format $::caption(eshelvisu,exportBess,keywordEmpty) $::caption(eshelvisu,exportBess,label,BSS_RA)]\n"
      } else {
         set value [mc_angle2deg $private($visuNo,value,BSS_RA)]
         set value [expr $value + 1.0/3600.0]
         set fitsValue [ mc_angle2hms $value 360 nozero 0 auto string]
         #--- je compare la valeur avec ce qu'on doit obtenir au format HMS
         #---   la comparaison est limitée aux nombre de caracteres saisis afin de pouvoir omettre la saisie des decimales de secondes
         if { [string compare -length [string length $private($visuNo,value,BSS_RA)] $private($visuNo,value,BSS_RA) $fitsValue] } {
            append badKeywords "BSS_RA: [format $::caption(eshelvisu,exportBess,keywordBadRa) $::caption(eshelvisu,exportBess,label,BSS_RA)]\n"
         }
      }

      #--- controle BSS_DEC
      #---    Verifier le longueur du champ
      #---    Verifier la coherence de la valeur
      if { [string length $private($visuNo,value,BSS_DEC)] < 1 } {
         set value [mc_angle2deg $private($visuNo,value,BSS_DEC)]
         set fitsValue [ mc_angle2dms $value 90 nozero 0 + string]
         #--- je compare la valeur avec ce qu'on doit obtenir au format DMS
         #---   la comparaison est limitée aux nombre de caracteres saisis afin de pouvoir omettre la saisie des decimales de secondes
         if { [string compare -length [string length $private($visuNo,value,BSS_DEC)] $private($visuNo,value,BSS_DEC) $fitsValue] } {
            append badKeywords "BSS_DEC: [format $::caption(eshelvisu,exportBess,keywordBadDec) $::caption(eshelvisu,exportBess,label,BSS_DEC)]\n"
         }
      }
   }

   #--- controle  DATE-OBS
   #---    Verifier le longueur du champ
   #---    Verifier la date au format iso8601

      set dateObs $private($visuNo,value,DATE-OBS)
      set fitsDateObs [ mc_date2iso8601 $dateObs ]
      #---   la comparaison est limitée aux nombre de caracteres saisis afin de pouvoir omette la saisie des decimales de secondes
      if { [string compare -length [string length $dateObs] $dateObs $fitsDateObs ] } {
         append badKeywords "DATE-OBS: [format $::caption(eshelvisu,exportBess,keywordBadDate) $private($visuNo,value,DATE-OBS)]\n"
      }

   #--- controle  DATE-END
   #---    Verifier le longueur du champ
   #---    Verifier la date au format iso8601
      set dateEnd $private($visuNo,value,DATE-END)
      set fitsDateEnd [ mc_date2iso8601 $dateEnd]
      #---   la comparaison est limitée aux nombre de caracteres saisis afin de pouvoir omette la saisie des decimales de secondes
      if { [string compare -length [string length $dateEnd] $dateEnd $fitsDateEnd] } {
         append badKeywords "DATE-END: [format $::caption(eshelvisu,exportBess,keywordBadDate) $private($visuNo,value,DATE-END)]\n"
      }

   #--- controle EXPOSURE
   #---    Verifier le longueur du champ
   #---    Verifier que c'est un reel
   if { [string length $private($visuNo,value,EXPOSURE)] < 1 } {
      append badKeywords ". [format $::caption(eshelvisu,exportBess,keywordEmpty) $::caption(eshelvisu,exportBess,label,EXPOSURE)]\n"
   } elseif { [string is double $private($visuNo,value,EXPOSURE)] == 0  } {
      append badKeywords ". $::caption(eshelvisu,exportBess,label,EXPOSURE) is not decimal value\n"
   }

   #--- controle BSS_SITE
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,BSS_SITE)] > 40 } {
      append badKeywords "$::caption(eshelvisu,exportBess,label,OBJNAME) is too large (40 c. max)\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,BSS_SITE)] == 0  } {
      append badKeywords "BSS_SITE: $::caption(eshelvisu,exportBess,label,BSS_SITE) contains bad character: [string range $private($visuNo,value,BSS_SITE) $charIndex $charIndex]\n"
   }

   #--- controle BSS_INST
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,BSS_INST)] > 40 } {
      append badKeywords "$::caption(eshelvisu,exportBess,label,BSS_INST) is too large (40 c. max)\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,BSS_INST)] == 0  } {
      append badKeywords "$::caption(eshelvisu,exportBess,label,BSS_INST) contains bad character: [string range $private($visuNo,value,BSS_INST) $charIndex $charIndex]\n"
   }

   #--- controle BSS_VHEL
   #---    Verifier le longueur du champ
   #---    Verifier que c'est un reel
   if { [string is double $private($visuNo,value,BSS_VHEL)] == 0  } {
      append badKeywords "BSS_VHEL: $::caption(eshelvisu,exportBess,label,BSS_VHEL) is not decimal value\n"
   }

   #--- controle BSS_TELL
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,BSS_TELL)] > 70 } {
      append badKeywords "$::caption(eshelvisu,exportBess,label,BSS_TELL) is too large\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,BSS_TELL)] == 0  } {
      append badKeywords "BSS_TELL: $::caption(eshelvisu,exportBess,label,BSS_TELL) contains bad character: [string range $private($visuNo,value,BSS_TELL) $charIndex $charIndex]\n"
   }

   #--- controle BSS_NORM
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,BSS_NORM)] > 70 } {
      append badKeywords ". $::caption(eshelvisu,exportBess,label,BSS_NORM) is too large\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,BSS_NORM)] == 0  } {
      append badKeywords "BSS_NORM: $::caption(eshelvisu,exportBess,label,BSS_NORM) contains bad character: [string range $private($visuNo,value,BSS_NORM) $charIndex $charIndex]\n"
   }

   #--- controle BSS_COSM
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,BSS_COSM)] > 70 } {
      append badKeywords ". $::caption(eshelvisu,exportBess,label,BSS_COSM) is too large\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,BSS_COSM)] == 0  } {
      append badKeywords "BSS_COSM: $::caption(eshelvisu,exportBess,label,BSS_COSM) contains bad character: [string range $private($visuNo,value,BSS_COSM) $charIndex $charIndex]\n"
   }

   #--- controle OBSERVER
   #---    Verifier le longueur du champ
   #---    Verifier les caractères
   if { [string length $private($visuNo,value,OBSERVER)] > 70 } {
      append badKeywords "$::caption(eshelvisu,exportBess,label,OBSERVER) are too large\n"
   } elseif { [string is print -failindex charIndex $private($visuNo,value,OBSERVER)] == 0  } {
      append badKeywords "OBSERVER: $::caption(eshelvisu,exportBess,label,OBSERVER) contains bad character: [string range $private($visuNo,value,OBSERVER) $charIndex $charIndex]\n"
   }

   #--- je controle qu'il n'y a pas d'erreur
   if { $badKeywords != "" } {
      #--- s'il y a des message d'erreur, je retourne le message d'erreur
      error "$::caption(eshelvisu,exportBess,keywordError):\n$badKeywords"
   }

   #--- je memorise la configurations instrumentale BESS
   set ::conf(eshel,exportbess,bessInst) $private($visuNo,value,BSS_INST)

   #--- je cree le fichier BeSS
   set hFile ""
   set hBess ""
   set catchResult [catch {
      #--- j'ouvre le fichier d'entree
      set hFile [fits open $private($visuNo,inputFileName) 0]

      #--- je recupere les numeros des HDU a exporter
      set nhdu [$hFile info nhdu ]
      set hduList ""
      set hduNo 1
      #--- je recherche tous les HDU correspond au filtre  ::conf(eshel,exportbess,exportOrder)
      while { $hduNo <= $nhdu   }  {
         #--- je pointe le premier HDU
         $hFile move $hduNo
         if { [catch {getKeyword $hFile "EXTNAME"} hduName] == 0 } {
            if { [scan $hduName "P_1C_%d" orderNo]  == 1 } {
               lappend hduList $hduNo $hduName
            }
         }
         incr hduNo
      }

      #--- je verifie que le repertoire d'export existe
      if { [file exists $::conf(eshel,exportbess,outputDirectory)] == 0 } {
         error [format $::caption(eshelvisu,exportBess,directoryError) $::conf(eshel,exportbess,outputDirectory)]
      }

      #--- je cree les fichiers de sortie
      foreach { hduNo hduName }  $hduList {
         #--- je lis les mots clef du fichier d'entree
         #--- je pointe le HDU contenant le profil
         $hFile move $hduNo
         #--- je verifie que c'est une image 1D
         set hduNaxes [$hFile info imgdim]
         if { [llength $hduNaxes] != 1 } {
            error [format $::caption(eshelvisu,exportBess,profileError) $hduName]
         }

         #--- je verifie la resence des mots clefs de calibration
         #---   CRVAL1 CDELT1 CRPIX1 CUNIT1 CTYPE1
         if { [catch {getKeyword $hFile "CRVAL1"} value] == 0 } {
            set private($visuNo,value,CRVAL1) $value
         } else {
            error "Keyword CRVAL1 not found in HDU $hduName"
         }
         if { [catch {getKeyword $hFile "CDELT1"} value] == 0 } {
            set private($visuNo,value,CDELT1) $value
         } else {
            error "Keyword CDELT1 not found in HDU $hduName"
         }
         if { [catch {getKeyword $hFile "CRPIX1"} value] == 0 } {
            set private($visuNo,value,CRPIX1) $value
        } else {
            error "Keyword CRPIX1 not found in HDU $hduName"
         }
         if { [catch {getKeyword $hFile "CUNIT1"} value] == 0 } {
            set private($visuNo,value,CUNIT1) $value
         } else {
            error "Keyword CUNIT1 not found in HDU $hduName"
         }
         if { [catch {getKeyword $hFile "CTYPE1"} value] == 0 } {
            set private($visuNo,value,CTYPE1) $value
         } else {
            error "Keyword CTYPE1 not found in HDU $hduName"
         }

         #--- je lis les valeurs du profil
         set intensity [$hFile get image]
         #--- je lis le type de valeurs
         ##set bitpix    [$hFile info imgType]
         set bitpix    $::conf(eshel,exportbess,outputBitpix)

         #--- je prepare le nom du fichier de sortie
         set rootName [file rootname [file tail $private($visuNo,inputFileName)]]
         set outputFileName "${rootName}-$hduName.fit"

         #--- je cree le fichier BeSS
         set hBess [fits open [file join $::conf(eshel,exportbess,outputDirectory) $outputFileName] 2]
         #--- je cree l'image 1D . Cela cree automatiquement les mots clefs SIMPLE BITPIX NAXIS NAXIS1
         $hBess insert image $bitpix "1" [llength $intensity]
         #--- j'insere l'image
         $hBess  put image 1 $intensity
         #--- j'ajoute les mots clefs requis par BeSS
         #--- remarque: je protège par des quotes les mots clefs de type string qui peuvent contenir des espaces
         $hBess put keyword "OBJNAME  '$private($visuNo,value,OBJNAME)'  Object name "
         $hBess put keyword "DATE-OBS '$private($visuNo,value,DATE-OBS)' \[Iso 8601\] Start of exposure. FITS standard"
         $hBess put keyword "DATE-END '$private($visuNo,value,DATE-END)' \[Iso 8601\] Start of exposure. FITS standard"
         $hBess put keyword "EXPOSURE  $private($visuNo,value,EXPOSURE)  \[s\] Total time of exposure"
         $hBess put keyword "BSS_SITE '$private($visuNo,value,BSS_SITE)' Site name"
         $hBess put keyword "DETNAM   '$private($visuNo,value,DETNAM)'   Camera name"
         $hBess put keyword "INSTRUME '$private($visuNo,value,INSTRUME)' Spectrograph name"
         $hBess put keyword "TELESCOP '$private($visuNo,value,TELESCOP)' Telescope name"
         $hBess put keyword "BSS_VHEL '$private($visuNo,value,BSS_VHEL)' Heliocentric correction (km/s)"
         $hBess put keyword "BSS_TELL '$private($visuNo,value,BSS_TELL)' Atmospheric line correction"
         $hBess put keyword "BSS_NORM '$private($visuNo,value,BSS_NORM)' Continuum normalisation"
         $hBess put keyword "BSS_COSM '$private($visuNo,value,BSS_COSM)' Cleaning cosmic"
         $hBess put keyword "OBSERVER '$private($visuNo,value,OBSERVER)' Observer names"

         #--- j'ajoute le mot cle BSS_ORD
         set genericName "${rootName}-P_1C_"
         $hBess put keyword "BSS_ORD '$genericName' generic file name"

         if { [string length $private($visuNo,value,BSS_INST) ] > 0 } {
            $hBess put keyword "BSS_INST '$private($visuNo,value,BSS_INST)' configuration name"
         }
         if { [string length $private($visuNo,value,BSS_RA) ] > "" && $private($visuNo,value,BSS_RA) != "0h0m0s"} {
            set value [mc_angle2deg $private($visuNo,value,BSS_RA)]
            $hBess put keyword "BSS_RA '$value' \[degrees\] Object right ascension"
         }
         if { [string length $private($visuNo,value,BSS_DEC) ] > "" && $private($visuNo,value,BSS_DEC) != "+0d0m0s"} {
            set value [mc_angle2deg $private($visuNo,value,BSS_DEC)]
            $hBess put keyword "BSS_DEC '$value' \[degrees\] Object declination"
         }

         $hBess put keyword "CRVAL1   $private($visuNo,value,CRVAL1)     Minimum wavelength"
         $hBess put keyword "CDELT1   $private($visuNo,value,CDELT1)     Dispersion"
         $hBess put keyword "CUNIT1   $private($visuNo,value,CUNIT1)     Unit of wavelength"
         $hBess put keyword "CRPIX1   $private($visuNo,value,CRPIX1)     Reference pixel"
         $hBess put keyword "CTYPE1   $private($visuNo,value,CTYPE1)     Type of X data"
         $hBess close
         set hBess ""
      } ; #--- fin de la boucle d'export
   }]

   if { $hFile != "" } {
       #--- je ferme le fichier d'entree, s'il n'a pas ete ferme a cause d'une exception
       $hFile close
   }
   if { $hBess != "" } {
       #--- je ferme le fichier de sortie, s'il n'a pas ete ferme a cause d'une exception
       $hBess close
   }

   if { $catchResult == 1 } {
      error $::errorInfo
   }
}

##------------------------------------------------------------
# exportHDU
#   export d'un HDU au format BeSS
#
# description detaille :
#   verifie que les mots clefs sont dans le HDU numero 1
#   si tous les mots clefs sont corrects
#      cree le fichier BeSS
#   si un mot clefs n'est pas correctement rempli
#      retourne une exception
# Parameters
# @param fileName  nom du fichier d'entree
# @param hduName   nom du HDU a extraire
#                      ou prefixe des HDU a exporter
# @return rien
# @public
#------------------------------------------------------------
proc ::eshelvisu::exportbess::exportHDU { inputFileName hduName } {
   set visuNo 0

   #--- les mots clefs sont extraits du premiers HDU
   set keywordHduIndex 1

   #--- je charge le fichier
   loadFile $visuNo $inputFileName $keywordHduIndex
   #--- j'enregistre les HDU
   saveFile $visuNo
}


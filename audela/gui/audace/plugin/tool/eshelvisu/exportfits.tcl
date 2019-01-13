#
# Fichier : exportfits.tcl
# Description : Export de fichier au format Fits
# Auteurs : Michel Pujol
# Mise a jour $Id: exportfits.tcl 12575 2016-01-10 17:25:14Z robertdelmas $
#

################################################################
# namespace ::eshelvisu::exportfits
#
# commandes :
#  ::eshelvisu::exportfits::run
#    affiche une fenetre pour selectionner et exporter les HDU vers un autre fichier FITS
#
################################################################

namespace eval ::eshelvisu::exportfits {

}

#------------------------------------------------------------
# run
#    affiche la fenetre d'export des fichiers fits
# Parameters
#    visuNo          numero de la fenetre
#    inputFileName   nom du fichier d'entree
#    keywordHduIndex   numero du HDU contenant les mots clefs (1 pour le permier HDU)
#    keywordHduIndex   numero du HDU contenant les
# @return void
#------------------------------------------------------------
proc ::eshelvisu::exportfits::run { visuNo fileNameList} {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,exportfits,position) ] }      { set ::conf(eshel,exportfits,position)     "340x200+100+15" }
   if { ! [ info exists ::conf(eshel,exportfits,outputDirectory)]} { set ::conf(eshel,exportfits,outputDirectory)  $::audace(rep_images) }
   if { ! [ info exists ::conf(eshel,exportfits,outputBitpix) ] }  { set ::conf(eshel,exportfits,outputBitpix)  -32 }
   if { ! [ info exists ::conf(eshel,exportfits,hduNameList) ] }   { set ::conf(eshel,exportfits,hduNameList)  "" }

   set private($visuNo,fileNameList) $fileNameList
   set private($visuNo,progressBarValue) -1
   #--- j'affiche la fenetre de controle des mots clefs
   set tkBase [::confVisu::getBase $visuNo]
   set private($visuNo,This) "$tkBase.exportfits"
   ::confGenerique::run $visuNo $private($visuNo,This) "::eshelvisu::exportfits" \
      -modal 0 -geometry $::conf(eshel,exportfits,position) -resizable 1
   wm minsize $private($visuNo,This) 340 200

   return
}


#------------------------------------------------------------
# ::eshelvisu::exportfits::getLabel
#   retourne le titre de la fenetre
#------------------------------------------------------------
proc ::eshelvisu::exportfits::getLabel { } {
   return "$::caption(eshelvisu,title) - $::caption(eshelvisu,exportfits,title)"
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre de controle
#   return rien
#------------------------------------------------------------
proc ::eshelvisu::exportfits::fillConfigPage { frm visuNo } {
   variable private
   variable widget

   set private($visuNo,frm) $frm

   set widget($visuNo,outputDirectory) [file nativename $::conf(eshel,exportfits,outputDirectory)]
   set widget($visuNo,selectP1A)       0
   set widget($visuNo,selectP1B)       0

   foreach hduName $::conf(eshel,exportfits,hduNameList) {
      switch $hduName {
         "P_1A" {
            set widget($visuNo,selectP1A) 1
         }
         "P_1B" {
            set widget($visuNo,selectP1B) 1
         }
         "P_1C" {
            set widget($visuNo,selectP1C) 1
         }
         "P_FULL" {
            set widget($visuNo,selectPFULL) 1
         }
         "ORDERS" {
            set widget($visuNo,selectOrders) 1
         }
         "PRIMARY" {
            set widget($visuNo,selectPrimary) 1
         }
      }
   }

   #--- choix des HDU a extraire
   TitleFrame $frm.hdu -borderwidth 2 -relief ridge -text $::caption(eshelvisu,exportfits,selectHDU)
      checkbutton $frm.hdu.selectPrimary -text $::caption(eshelvisu,exportfits,selectPrimary) \
      -variable ::eshelvisu::exportfits::widget($visuNo,selectPrimary)
      grid $frm.hdu.selectPrimary -in [$frm.hdu getframe] -row 0 -column 0 -sticky nw

      checkbutton $frm.hdu.selectPFull -text $::caption(eshelvisu,exportfits,selectPFull) \
      -variable ::eshelvisu::exportfits::widget($visuNo,selectPFull)
      grid $frm.hdu.selectPFull -in [$frm.hdu getframe] -row 0 -column 1 -sticky nw

      checkbutton $frm.hdu.selectOrders -text $::caption(eshelvisu,exportfits,selectOrders) \
      -variable ::eshelvisu::exportfits::widget($visuNo,selectOrders)
      grid $frm.hdu.selectOrders -in [$frm.hdu getframe] -row 0 -column 2 -sticky nw

      checkbutton $frm.hdu.selectP1A -text $::caption(eshelvisu,exportfits,selectP1A) \
            -variable ::eshelvisu::exportfits::widget($visuNo,selectP1A)
      grid $frm.hdu.selectP1A -in [$frm.hdu getframe] -row 1 -column 0 -sticky nw

      checkbutton $frm.hdu.selectP1B -text $::caption(eshelvisu,exportfits,selectP1B) \
         -variable ::eshelvisu::exportfits::widget($visuNo,selectP1B)
      grid $frm.hdu.selectP1B -in [$frm.hdu getframe] -row 1 -column 1 -sticky nw

      checkbutton $frm.hdu.selectP1C -text $::caption(eshelvisu,exportfits,selectP1C) \
      -variable ::eshelvisu::exportfits::widget($visuNo,selectP1C)
      grid $frm.hdu.selectP1C -in [$frm.hdu getframe] -row 1 -column 2 -sticky nw

      grid columnconfig [$frm.hdu getframe]  0 -weight 1
      grid columnconfig [$frm.hdu getframe]  1 -weight 1
      grid columnconfig [$frm.hdu getframe]  2 -weight 1
   pack $frm.hdu -side top -fill x -expand 0

   #--- repertoire de sortie
   TitleFrame $frm.directory -borderwidth 2 -relief ridge -text $::caption(eshelvisu,exportfits,exportedFile)

      Label $frm.directory.label -text $::caption(eshelvisu,exportfits,outputDirectory)
      pack $frm.directory.label -in [$frm.directory getframe] -side left -fill none -expand 0

      Entry $frm.directory.entry -textvariable ::eshelvisu::exportfits::widget($visuNo,outputDirectory)
      pack $frm.directory.entry -in [$frm.directory getframe] -side left -fill x -expand 1

      Button $frm.directory.button -text "..." -command "::eshelvisu::exportfits::selectOuputDirectory $visuNo"
      pack $frm.directory.button -in [$frm.directory getframe] -side left -fill none -expand 0
   pack $frm.directory -side top -fill x -expand 0

   #--- barre de progression
   ###ProgressBar $frm.progressBar -width 100 -type normal -relief raised \
   ###   -bg $::audace(color,backColor) -fg $::audace(color,activeTextColor) \
   ###   -variable ::eshelvisu::exportfits::private($visuNo,progressBarValue)
   ttk::progressbar $frm.progressBar  \
      -variable ::eshelvisu::exportfits::private($visuNo,progressBarValue)

   pack $frm.progressBar -side top -anchor center -fill none -expand 0 -pady 4

}

#------------------------------------------------------------
# config::cmdApply
#   export les HDU selectionnes dans des fichiers separes
#------------------------------------------------------------
proc ::eshelvisu::exportfits::cmdApply { visuNo } {
   variable private
   variable widget

   set ::conf(eshel,exportfits,outputDirectory) [file normalize $widget($visuNo,outputDirectory)]



   set ::conf(eshel,exportfits,hduNameList) ""
   if { $widget($visuNo,selectP1A) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "P_1A"
   }
   if { $widget($visuNo,selectP1B) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "P_1B"
   }
   if { $widget($visuNo,selectP1C) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "P_1C"
   }
   if { $widget($visuNo,selectPFull) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "P_FULL"
   }
   if { $widget($visuNo,selectOrders) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "ORDERS"
   }
   if { $widget($visuNo,selectPrimary) == 1 } {
      lappend ::conf(eshel,exportfits,hduNameList) "PRIMARY"
   }

   set catchResult [catch {
      set private($visuNo,progressBarValue) 0
      #--- je mets a jour la  valeur maximale de la barre de progress
      $private($visuNo,frm).progressBar  configure  -maximum [llength $private($visuNo,fileNameList)]

      foreach inputFileName $private($visuNo,fileNameList) {
         saveFile $inputFileName $::conf(eshel,exportfits,hduNameList) $::conf(eshel,exportfits,outputDirectory)
         incr private($visuNo,progressBarValue)
      }

   } ]

   if { $catchResult == 1 } {
      #--- j'affiche un message d'erreur pour toutes autres erreurs non prévues
      ::tkutil::displayErrorInfo $::caption(eshelvisu,exportfits,title)
   } else {
      #--- je ferme la boite de dialogue
      cmdClose $visuNo

      if { $::conf(eshel,exportfits,hduNameList) != "" } {
         set message [format $::caption(eshelvisu,exportfits,exportDone) $::conf(eshel,exportfits,outputDirectory)]
         set choix [ tk_messageBox -type yesno -message $message -icon info -title $::caption(eshelvisu,exportfits,title)]
         if { $choix == "yes" } {
            #--- j'ouvre une fenetre pour afficher des profils
            set visuDir [::confVisu::create]
            #--- je selectionne l'outil eShel Visu
            confVisu::selectTool $visuDir ::eshelvisu
            #--- je pointe le repertoire des images brutes
            set ::eshelvisu::localTable::private($visuDir,directory) $::conf(eshel,exportfits,outputDirectory)
            #--- j'affiche le contenu du répertoire
            ::eshelvisu::localTable::fillTable $visuDir
         }
      }
   }
}

#------------------------------------------------------------
# config::cmdClose
#   ferme la fenetre si la commande cmdClose n'a pas detecte d'erreur
#   sinon ne fait rien
# return
#   0  s'il ne faut pas fermer la fenetre
#   rien s'il faut fermer la fenetre
#------------------------------------------------------------
proc ::eshelvisu::exportfits::cmdClose { visuNo } {
   variable private

   #--- je sauve la taille et la position de la fenetre
   set ::conf(eshel,exportfits,position) [winfo geometry [winfo toplevel $private($visuNo,frm) ]]

   return ""
}


##------------------------------------------------------------
# selectOuputDirectory
#   selectionne le nom du fichier de sortie
# @param numero de la visu
# @return rien
#------------------------------------------------------------
proc ::eshelvisu::exportfits::selectOuputDirectory { visuNo } {
   variable private
   variable widget

   #--- j'ouvre la fenetre de choix du repertoire d'export FITS
   set outputDirectory [ tk_chooseDirectory -title $::caption(eshelvisu,exportfits,title)  \
      -initialdir $::conf(eshel,exportfits,outputDirectory) \
      -parent [winfo toplevel $private($visuNo,frm)] ]

   #--- j'abandonne si aucun nom de fichier n'a ete saisi
   if { $outputDirectory == "" } {
         return
   } else {
      set widget($visuNo,outputDirectory) [file nativename $outputDirectory]
   }
}


#------------------------------------------------------------
#   exporte les HDU dans des fichiers separes
#   les fichers de sortie ont pour nom  {inputFilename}_{hduName}.{inputfileName extension}
#
# Exemple :
# @param intputFileName  nom du fichier d'entree
# @param hduNameList     liste des noms de HDU à extraire PRIMARY P_1A P_1B P_1C FULL FULL0
# @param outputDirectory répertoire de sortie des fichiers
#------------------------------------------------------------
proc ::eshelvisu::exportfits::saveFile { intputFileName hduNameList outputDirectory } {
   variable private
   variable widget

   set hFile ""
   set hOutputFile ""

   set catchResult [catch {
      #--- j'ouvre le fichier d'entree en lecture
      set hFile [fits open $intputFileName 0]
      set nbHdu [$hFile info nhdu]
      set primaryKeywords ""

      #--- je balaie la liste des HDU
      for { set hduNum 1 } { $hduNum <= $nbHdu }  { incr hduNum } {
         #--- je pointe le hdu dans le fichier d'entree (retourne 0-image, 1-ASCII table, 2-Binary Table.  )
         set extensionType [$hFile move $hduNum]
         if { $hduNum != 1 } {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         } else {
            set hduName PRIMARY
            #--- je recupere les mots cles du HDU principal
            set primaryKeywords [$hFile dump]
         }
         foreach requiredHduName $hduNameList {
            #--- je verifie que le nom du HDU fait partie de la liste des HDU demandés
            if { [string first $requiredHduName $hduName] == 0 && $hduName != "P_FULL0" } {
               set outpuFileName [file join $outputDirectory [file rootname [file tail $intputFileName]]]
               append outpuFileName "_$hduName"
               append outpuFileName [file extension $intputFileName]
               if { $extensionType == 0 } {
                  #--- je verifie que c'est une image 1D
                  set hduNaxes [$hFile info imgdim]
                  set bitpix    [$hFile info imgType]
                  if { [llength $hduNaxes] == 1 && $bitpix != $::conf(eshel,exportfits,outputBitpix) } {
                     #--- je convertis le profil en 32 bits
                     #--- je cree le fichier de sortie
                     file delete -force $outpuFileName
                     set hOutputFile [fits open $outpuFileName 2]
                     set bitpix $::conf(eshel,exportfits,outputBitpix)
                     #--- je cree le HDU (cree automatiquement les mots cles BITPIX COMMENT EXTEND=T NAXIS NAXISn SIMPLE
                     $hOutputFile insert image $bitpix "1" [lindex $hduNaxes 0]
                     #--- j'insere l'image
                     $hOutputFile put image 1 [$hFile get image]
                     #--- je copie les mots cles du PRIMARY HDU
                     foreach keyword $primaryKeywords {
                        set keywordName [lindex $keyword 0]
                        if { [lsearch [list BITPIX NAXIS NAXIS1 NAXIS2 NAXIS3 EXTEND SIMPLE BGMEAN BGSIGMA MIPS-HI MIPS-LO MEAN CONTRAST SIGMA DATAMAX DATAMIN ] $keywordName ] == -1 } {
                           $hOutputFile put keyword $keyword 0
                        }
                     }
                     #--- je copie les mots clefs du HDU courant
                     foreach keyword [$hFile dump] {
                        set keywordName [lindex $keyword 0]
                        if { [lsearch [list BITPIX NAXIS NAXIS1 GCOUNT PCOUNT XTENSION ] $keywordName ] == -1 } {
                           $hOutputFile put keyword $keyword 0
                        }
                     }
                     $hOutputFile close
                     set hOutputFile ""
                  } else {
                     #--- j'enregistre l'image telle quel
                     $hFile copy $outpuFileName
                  }
               } else {
                  #--- la table est enregistree automatiquement dans le deuxième HDU
                  $hFile copy $outpuFileName
               }
            }
            update
         }
      }
      #--- je referme le fichier d'entree
      $hFile close
   } ]

   if { $catchResult == 1 } {
      if { $hFile != "" } {
         $hFile close
      }
      if { $hOutputFile != "" } {
         $hOutputFile close
      }
      #--- j'affiche un message d'erreur pour toutes autres erreurs non prevues
       error $::errorInfo
   }
}


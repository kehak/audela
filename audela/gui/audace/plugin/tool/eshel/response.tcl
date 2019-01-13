#
## @file response.tcl
#  @brief Fenêtre pour fabriquer un fichier FITS de réponse instrumentale
#  @author Michel Pujol
#  $Id: process.tcl 13355 2016-03-10 14:52:31Z rzachantke $
#

## namespace eshel::response
#  @brief Fenêtre pour fabriquer un fichier FITS de réponse instrumentale

namespace eval ::eshel::response {
   variable private

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne
#
proc ::eshel::response::run { tkbase visuNo } {
   variable private

   set ::caption(eshel,reponse,title)           "Réponse instrumentale"
   set ::caption(eshel,reponse,datFileTitle)    "Fichiers .dat"
   set ::caption(eshel,reponse,selectDat)       "Selectionner un fichier .dat"
   set ::caption(eshel,reponse,datGenericName)  "Nom générique des fichiers .dat"
   set ::caption(eshel,reponse,datFirstIndex)   "Premier index"
   set ::caption(eshel,reponse,datLastIndex)    "Dernier index"
   set ::caption(eshel,reponse,datDirectory)    "Répertoire des fichiers .dat"
   set ::caption(eshel,reponse,outputFileName)  "Fichier généré"
   set ::caption(eshel,reponse,overwriteQuestion) "Le fichier existe déjà. Voulez-vous l'écraser ?"
   set ::caption(eshel,reponse,createResponse)  "Créer la réponse instrumentale"
   set ::caption(eshel,reponse,responseCreated) "La réponse instrumentale est créée"

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,response,position) ] } { set ::conf(eshel,response,position)     "650x240+100+15" }
   if { ! [ info exists ::conf(eshel,response,datDirectory) ] } { set ::conf(eshel,response,datDirectory)  $::conf(eshel,mainDirectory) }

   #--- liste des motcls affiches = mots cles obligatoires + mots cles facultatifs
   set private(keywordList)  { "SERIESID" "IMAGETYP" "OBJNAME"\
            "DATE-OBS" "EXPOSURE" "NAXIS1" "NAXIS2" "BIN1" "BIN2"  \
            "DETNAM" "INSTRUME" "TELESCOP" "SITENAME" \
            "OBSERVER" \
            "CONFNAME" \
         }


   foreach keywordName $private(keywordList) {
      set private($keywordName,value) ""
   }

   set private(IMAGETYP,value) "RESPONSE"
   set private(datDirectory) ""
   set private(datGenericName) ""
   set private(datFirstIndex) ""
   set private(datLastIndex) ""
   set private(outputFileName) ""

   set private(apply) ""

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.reponse"
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshel::response" \
      -modal 1 -geometry $::conf(eshel,response,position) -resizable 1 ]

   if { $private(apply) == "ok" } {
     return 1
   } else {
     return 0
   }

}

#------------------------------------------------------------
# ::eshel::response::getLabel
#   retourne le titre de la fenetre
#
proc ::eshel::response::getLabel { } {
   return "$::caption(eshel,title) - $::caption(eshel,reponse,title)"
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre de configuration
#    -  liste des mots cles a renseigner
#    - nom genereique des fichiers dat
#    - repertoire des fichier .dat
#   return rien
#
proc ::eshel::response::fillConfigPage { frm visuNo } {
   variable private

   set private(frm) $frm

   set row 1
   foreach keywordName $private(keywordList) {

      label $frm.label$keywordName   -text $keywordName -justify left
      entry $frm.entry$keywordName   -textvariable ::eshel::response::private($keywordName,value)  -justify left


      grid $frm.label$keywordName -in $frm -row $row -column 0 -sticky nw
      grid $frm.entry$keywordName -in $frm -row $row -column 1 -sticky nw

      #--- ajoute un bouton les mots clefs qui possedent une valeur par defaut dans la configuration instrument
      switch $keywordName {
         IMAGETYP {
            #--- je configure l'entry en lecture seule
            $frm.entry$keywordName configure -state readonly
         }
         INSTRUME {
            Button $frm.button$keywordName -text "current specrograph : $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectroName)" \
            -command "::eshel::response::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
         TELESCOP {
            Button $frm.button$keywordName -text "current telescope : $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),telescopeName)" \
            -command "::eshel::response::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
         DETNAM {
            Button $frm.button$keywordName -text "current camera : $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraName)" \
               -command "::eshel::response::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
         SITENAME {
            Button $frm.button$keywordName -text "current site : $::conf(posobs,nom_observatoire)" \
            -command "::eshel::response::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
      }
      grid rowconfig $frm $row -weight 0
      incr row
   }
   grid columnconfig $frm 0 -weight 0
   grid columnconfig $frm 1 -weight 0
   grid columnconfig $frm 2 -weight 1

   #--- repertoire du fichier .dat
   TitleFrame $frm.dat  -borderwidth 2 -relief ridge -text $::caption(eshel,reponse,datFileTitle)
      Button $frm.dat.select -text  $::caption(eshel,reponse,selectDat) \
         -command ::eshel::response::selectDat
      grid $frm.dat.select -in [$frm.dat getframe] -row 0 -column 0 -columnspan 2

      label $frm.dat.labelDatDirectory    -text  $::caption(eshel,reponse,datDirectory)  -justify left
      entry $frm.dat.entryDatDirectory    -textvariable ::eshel::response::private(datDirectory)  -justify left -state readonly
      label $frm.dat.labelGenericFileName -text  $::caption(eshel,reponse,datGenericName)  -justify left
      entry $frm.dat.entryGenericFileName -textvariable ::eshel::response::private(datGenericName)  -justify left -state readonly
      label $frm.dat.labelFirstIndex      -text  $::caption(eshel,reponse,datFirstIndex)  -justify left
      entry $frm.dat.entryFirstIndex      -textvariable ::eshel::response::private(datFirstIndex)  -justify left
      label $frm.dat.labelLastIndex       -text  $::caption(eshel,reponse,datLastIndex)  -justify left
      entry $frm.dat.entryLastIndex       -textvariable ::eshel::response::private(datLastIndex)  -justify left
      label $frm.dat.labelOutputFileName  -text  $::caption(eshel,reponse,outputFileName)  -justify left
      entry $frm.dat.entryOutputFileName  -textvariable ::eshel::response::private(outputFileName)  -justify left

      grid $frm.dat.labelDatDirectory     -in [$frm.dat getframe] -row 1 -column 0 -sticky w
      grid $frm.dat.entryDatDirectory     -in [$frm.dat getframe] -row 1 -column 1 -sticky ew
      grid $frm.dat.labelGenericFileName  -in [$frm.dat getframe] -row 2 -column 0 -sticky w
      grid $frm.dat.entryGenericFileName  -in [$frm.dat getframe] -row 2 -column 1 -sticky ew
      grid $frm.dat.labelFirstIndex       -in [$frm.dat getframe] -row 3 -column 0 -sticky w
      grid $frm.dat.entryFirstIndex       -in [$frm.dat getframe] -row 3 -column 1 -sticky ew
      grid $frm.dat.labelLastIndex        -in [$frm.dat getframe] -row 4 -column 0 -sticky w
      grid $frm.dat.entryLastIndex        -in [$frm.dat getframe] -row 4 -column 1 -sticky ew
      grid $frm.dat.labelOutputFileName   -in [$frm.dat getframe] -row 5 -column 0 -sticky w
      grid $frm.dat.entryOutputFileName   -in [$frm.dat getframe] -row 5 -column 1 -sticky ew

      Button $frm.dat.create -text  $::caption(eshel,reponse,createResponse) \
         -command ::eshel::response::createResponse
      grid $frm.dat.create -in [$frm.dat getframe] -row 6 -column 0 -columnspan 2

      grid columnconfig $frm.dat 1 -weight 1


   grid $frm.dat -in $frm -row $row -column 0 -sticky ew -columnspan 3


}

#------------------------------------------------------------
# config::cmdClose
#   controle les valeurs de mots clefs
#   si un mot clefs n'est pas correctement rempli
#      affiche un message d'erreur s
#      et interrompt la fermeture de la fenetre
#   si tous les mots clefs sont corrects
#      ferme la fenetre
# return
#   0  s'il ne fait pas fermer la fenetre
#   rien s'il faut fermer la feenetre
#
proc ::eshel::response::cmdClose { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,response,position) [ wm geometry $private($visuNo,This) ]

   #--- on peut fermer la fenetre
   return 1
}

#------------------------------------------------------------
# getCurrentInstrumentValue
#   recupere la valeur de la configuration instrument courante
#   et la copie dans la variable du widget associé
#
proc ::eshel::response::getCurrentInstrumentValue { visuNo keywordName } {
   variable private

   switch $keywordName {
      DETNAM {
         set private(DETNAM,value)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraName)
      }
      INSTRUME {
         set private(INSTRUME,value)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectroName)
      }
      TELESCOP {
         set private(TELESCOP,value)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),telescopeName)
      }
      SITENAME {
         set private(SITENAME,value)  $::conf(posobs,nom_observatoire)
      }
   }

}

#------------------------------------------------------------
## @brief ouvre la fenêtre pour sélectionner un fichier .dat
#  @private
#
proc ::eshel::response::selectDat { } {
   variable private

   #--- je verifie si le repertoire utilisé dans la session precedente existe toujours
   #---  sinon je l'initilise avec le repertorie par defaut de l'outil eshel
   if { [file exists $::conf(eshel,response,datDirectory) ] == 0 } {
      set ::conf(eshel,response,datDirectory) $::conf(eshel,mainDirectory)
   }

   #--- j'affiche la fenetre pour selection un fichier .dat
   set fileName [ tk_getOpenFile \
      -title $::caption(eshel,instrument,process,response,title) \
      -filetypes [list [ list "DAT File"  {.dat} ]] \
      -initialdir $::conf(eshel,response,datDirectory) \
      -parent $private(frm) \
   ]

   if { $fileName != "" } {
      set catchResult [ catch {
         #--- je memorise le repertoire
         set ::conf(eshel,response,datDirectory) [file dirname $fileName]

         #--- j'extrais le nom generique
         set decompInfo [ decomp $fileName]
         console::disp "decompInfo= [lindex $decompInfo 0] ,  [lindex $decompInfo 1] , [lindex $decompInfo 2] \n"
         #--- je compte le nombre de fichiers
         set liste_serie [ lsort -integer [ liste_index [lindex $decompInfo 1] -rep [lindex $decompInfo 0] -ext ".dat" ] ]
         if { [llength $liste_serie ] == 0 } {
            error "le nom du fichier ne termine pas un nombre"
         }


         #--- je recherche le fichier -full.dat
         set fullFileName  [file join  [lindex $decompInfo 0]  "[lindex $decompInfo 1]full.dat" ]
         if { [file exists $fullFileName] == 0 } {
            error "le fichier $fullFileName n'existe pas"
         }

         set private(datDirectory)    [file native [lindex $decompInfo 0]]
         set private(datGenericName)  [lindex $decompInfo 1]
         set private(datFirstIndex) [lindex $liste_serie 0]
         set private(datLastIndex)  [lindex $liste_serie end]

         set private(outputFileName)  [string trimright  $private(datGenericName) "-_." ]
         append private(outputFileName) ".fit"

      }]

      if { $catchResult !=0 } {
        ::tkutil::displayErrorInfo $::caption(eshel,instrument,process,response,title)
      }
   }
}


#------------------------------------------------------------
# ??
# @private
#
proc ::eshel::response::createResponse { } {
   variable private

  set catchResult [ catch {
      #--- je verifie si le fichier en sortie existe déjà
      if { [file exists [file join $::conf(eshel,referenceDirectory) $private(outputFileName)] ]==1 }  {
         #--- demande de confirmation d'ecrasement du fichier existant
         set choice [tk_messageBox -message $::caption(eshel,reponse,overwriteQuestion) -title $::caption(eshel,reponse,title) -icon question -type yesno]
         if {$choice=="no"} {
            return
         }
      }

      set keywordList ""


      foreach keywordName $private(keywordList) {
         if { $private($keywordName,value) != "" } {
            lappend keywordList [list $keywordName $private($keywordName,value) "" ]
         }
      }

      eshel response  [file join $private(datDirectory) $private(datGenericName)] [file join $::conf(eshel,referenceDirectory) $private(outputFileName)] $private(datFirstIndex)  $private(datLastIndex) $keywordList

      tk_messageBox -message "$::caption(eshel,reponse,responseCreated)\n[file join $::conf(eshel,referenceDirectory) $private(outputFileName)]" -title $::caption(eshel,reponse,title) -icon info -type ok

   }]

   if { $catchResult !=0 } {
     ::tkutil::displayErrorInfo $::caption(eshel,instrument,process,response,title)
   }
}


#
## $file process.tcl
#  @brief traitements eShel
#  @author Michel PUJOL
#  $Id: process.tcl 13444 2016-03-20 15:19:06Z rzachantke $
#

## namespace eshel::process
#  @brief traitements eShel

#
# Procedures principales :
#
# ::eshel::process::startProcess
#    traite des fichiers bruts du repertoire RAW (voir ::conf(eshel,rawDirectory))
#    (enchaine GenerateAll et startScript)
#
# ::eshel::process::startProcess
#    genere le script pour traiter les fichiers bruts du repertoire RAW
#    nom du fichier script eshel/tmp/process.tcl
#     ( voir les variable ::conf(eshel,tempDirectory) et ::conf(eshel,scriptFileName) )
#
# ::eshel::process::startScript
#    lance le script de traitement
#    (le script est lancé dans une thread separée)
#

namespace eval ::eshel::process {
   variable private
   package require dom

   #--- j'initialise les variables locales
   set private(nightlog) ""

   #--- liste des mots clefs obligatoires dans les fichiers
   set private(mandatoryKeywords) { "SERIESID" "IMAGETYP" "OBJNAME"\
      "DATE-OBS" "EXPOSURE" "NAXIS1" "NAXIS2" "BIN1" "BIN2"  \
      "DETNAM" "INSTRUME" "TELESCOP" "SITENAME" \
   }

   #--- liste des mots clefs des fichiers de reference
   set private(referenceKeywords) { "FILENAME" "IMAGETYP" \
      "DATE-OBS" "EXPOSURE" "NAXIS1" "NAXIS2" "BIN1" "BIN2"  \
      "DETNAM" "INSTRUME" "TELESCOP" \
   }

   #--- liste des attributs des series
   set private(serieAttributes) { "FILES" "SERIESID" "IMAGETYP" "OBJNAME" \
      "DATE-OBS" "EXPOSURE" "NAXIS1" "NAXIS2" "BIN1" "BIN2"  \
      "DETNAM" "INSTRUME" "TELESCOP" "SITENAME" \
   }

   set private(mandatoryKeywordsType) {
      { SERIESID string }
      { IMAGETYP string }
      { OBJNAME   string }
      { DATE-OBS string }
      { EXPOSURE  float }
      { NAXIS1   int }
      { NAXIS2   int }
      { BIN1     int }
      { BIN2     int }
      { DETNAM   string }
      { INSTRUME string }
      { TELESCOP string }
      { SITENAME string }
      { OBSERVER string }
    }

   #--- je cree un nightlog vide par defaut
   set private(nightlog) [::dom::DOMImplementation create]
   set nightNode [::dom::document createElement  $private(nightlog) NIGHTLOG ]
   set filesNode [::dom::document createElement  $nightNode "FILES" ]
   set archiveNode [::dom::document createElement  $nightNode "ARCHIVE" ]
   set private(running) 0
   set private(threadNo) ""

}


#------------------------------------------------------------
# startProcess
#   genere la liste de traitement
#   et execute les traitements
#
proc ::eshel::process::startProcess {  } {
   variable private

   #--- je verifie qu'un traitement n'est pas deja en cours
   if { $private(running) == 0 } {
      set catchResult [catch {
         #--- je genere la liste des traitements a faire
         ::eshel::process::generateAll
         #--- je recupere le nombre de traitements a faire
         set processNb 0
         foreach processNode [::dom::tcl::node children [ ::eshel::process::getRoadmapNode]] {
            set processType [::dom::tcl::node cget $processNode -nodeName]
            set status [::dom::element getAttribute $processNode "STATUS"]
            if { $status == "todo" } {
               incr processNb
            }
         }

         if { $processNb > 0 } {
            #--- je positionne le flag indiquant qu'un traitement est en cours
            #--- remarque : le flag est desactive a la fin du traitement par eshel::process::endScript
            ::eshel::process::startScript
         }
      } ]
      if { $catchResult == 1 } {
         #--- je desactive le flag si une erreur est survenue pendant le lancement
         set private(running) 0
         #--- je transmet l'erreur au programme appelant
         error $::errorInfo
      }
   }
}

#------------------------------------------------------------
# generateAll
#   genere le nightlog
#
proc ::eshel::process::generateAll { } {
   variable private

   #--- j'interdis les commandes manuelles
   if { $::conf(eshel,processAuto) == 0 } {
      set private(running) "generate"
      ::eshel::processgui::setFrameState
   }

   set catchResult [catch {
      set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
      ###logInfo "\n"
      ###logInfo "==== eShel Generate roadmap begin UT: $date =====\n"
      ::eshel::processgui::resetTables

      #--- je verifie que les repertoires existent
      ::eshel::checkDirectory
      ::eshel::process::generateNightlog
      ::eshel::process::generateProcess
      ::eshel::process::generateScript
      ::eshel::process::generateArchiveList
      ::eshel::process::saveFile

      #--- j'affiche le resultat dans la fenetre des traitements
      ::eshel::processgui::copyRawToTable
      ::eshel::processgui::copyReferenceToTable
      ::eshel::processgui::copyRoadmapToTable
      ::eshel::processgui::copyArchiveToTable
      ###set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
      ###logInfo "==== eShel Generate roadmap End UT: $date =====\n"
   } ]

   #--- j'autorise les commandes manuelles
    if { $::conf(eshel,processAuto) == 0 } {
      set private(running) "0"
      ::eshel::processgui::setFrameState
   }

   #--- je remonte l'erreur a la procedure appelante
   if { $catchResult == 1 } {
      error $::errorInfo
   }
}

## ------------------------------------------------------------
# generateNightlog
#   genere le nightlog
#
proc ::eshel::process::generateNightlog { } {
   variable private

   #--- j'initialise le nightlog a vide
   if { $private(nightlog) != "" } {
      ::dom::tcl::destroy $private(nightlog)
      set private(nightlog) ""
   }
   set private(nightlog) [::dom::DOMImplementation create]
   set nightNode [::dom::document createElement  $private(nightlog) NIGHTLOG ]

   #--- j'ajoute la date de creation
   set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
   ::dom::element setAttribute $nightNode "DATE" $date

   #--- j'ajoute le TAG des fichiers
   set filesNode [::dom::document createElement  $nightNode "FILES" ]

   #--- je recupere la liste des fichiers bruts
   set globFileList [glob -nocomplain -type f -join "$::conf(eshel,rawDirectory)" *.* ]
   foreach fileName $globFileList {
      set catchResult [catch {
         #--- je lis les mots clefs du fichier
         set fileKeywords [fitsheader $fileName]
      }]
      if { $catchResult !=0 } {
         #--- j'ignore ce fichier car ce n'est pas un fichier FITS
         logError "process::generateNightlog : $fileName is not a FITS file"
         continue
      }
      #--- je copie les mots cles dans un array
      array unset keywordArray
      foreach fileKeyword $fileKeywords {
         set keywordArray([lindex $fileKeyword 0]) [lindex $fileKeyword 1]
      }

      #--- j'ajoute le fichier dans l'arbre
      set fileNode  [::dom::document createElement $filesNode "FILE" ]
      #--- je memorise le nom du fichier
      ::dom::element setAttribute $fileNode "FILENAME" [file tail $fileName]
      ::dom::element setAttribute $fileNode "DIRNAME" [file dirname $fileName]

      #--- je recherche les mots clefs obligatoires
      foreach mandatoryKeywordName $private(mandatoryKeywords) {
         if { [info exists keywordArray($mandatoryKeywordName)] } {
            set keywordValue $keywordArray($mandatoryKeywordName)
         } else {
            set keywordValue  ""
         }

         if { $mandatoryKeywordName == "EXPOSURE" } {
            if { $keywordValue == "" } {
               #--- si EXPOSURE n'existe pas , je recupere la valeur de EXPTIME
               if { [info exists keywordArray(EXPTIME)] } {
                  set keywordValue  $keywordArray(EXPTIME)
               }
            }
            #--- si la valeur se termine par un point, je supprime le point
            #--- pour eviter que le point n'apparaisse dans le nom de fichiers
            set keywordValue  [string trimright $keywordValue "."]
         }

         if { $mandatoryKeywordName == "DATE-OBS" && $keywordValue != ""} {
            #--- si l'heure est dans UT-START au lieu de DATE-OBS
            #--- alors je concatene les deux mots clefs DATE_OBS+UT-START dans DATE-OBS
            if { [string first "/" $keywordValue] != -1 && [info exists keywordArray(UT-START)] } {
               set d1 [split $keywordValue "/"]
               if { [llength $d1] == 3 } {
                  set d2 "[lindex $d1 2]  [lindex $d1 1] [lindex $d1 0]"
                  set h1 $keywordArray(UT-START)
                  set h2 [split $h1 ":"]
                  set keywordValue [mc_date2iso8601 "$d2 $h2"]
               }
            }

         }
         if { $mandatoryKeywordName == "IMAGETYP" && $keywordValue == "FLAT"} {
            set keywordValue "LED"
         }
         #--- je memorise la valeur du mot clef (chaine vide par defaut)
         ::dom::element setAttribute $fileNode $mandatoryKeywordName $keywordValue
      }
      array unset keywordArray
   }



   #--- je cree les series
   ::eshel::process::findSeries "FILES"

   #--- je recupere la liste des fichiers de reference de la session
   set globFileList [glob -nocomplain -type f -join "$::conf(eshel,referenceDirectory)" *.* ]
   foreach fileName $globFileList {
      set catchResult [catch {
         #--- je lis les mots clefs du fichier
         set fileKeywords [fitsheader $fileName]
      }]
      if { $catchResult !=0 } {
         #--- j'ignore ce fichier car ce n'est pas un fichier FITS
         logError "process::generateNightlog : $fileName is not a FITS file"
         continue
      }
      #--- je copie les mots cles dans un array
      array unset keywordArray
      foreach fileKeyword $fileKeywords {
         set keywordArray([lindex $fileKeyword 0]) [lindex $fileKeyword 1]
      }

      #--- je recherche le type d'image
      if { [info exists keywordArray(IMAGETYP)] == 1 && $keywordArray(IMAGETYP) != "" } {
         switch $keywordArray(IMAGETYP) {
            "BIAS" -
            "DARK" -
            "FLATFIELD" -
            "LED" -
            "TUNGSTEN" -
            "FLAT" -
            "CALIB" -
            "TUNGSTEN" {
               #--- pas d'autre verification a faire
               set nodeType $keywordArray(IMAGETYP)
            }
            "RESPONSE" {
               #--- j'ignore le fichier si la selection de la RI n'est pas en mode automatique
               ###if { [::eshel::instrument::getConfigurationProperty responseOption] != "AUTO" } {
               ###   continue
               ###}
               set nodeType $keywordArray(IMAGETYP)
            }
            default {
               #--- j'gnore les fichiers qui ont d'autre valeur que IMAGETYP
               ###continue
               set nodeType "BAD_REF"
            }
         }
      } else {
         #--- j'ignore ce fichier car le type d'image n'est pas defini
         ###logError "generateNightlog : [file tail $fileName] IMAGETYP keyword is missing"
         ###continue
         set nodeType "BAD_REF"
      }

      #--- je memorise le nom du fichier
      set fileNode  [::dom::document createElement $filesNode $nodeType ]
      ::dom::element setAttribute $fileNode "RAW" 0
      ::dom::element setAttribute $fileNode "FILENAME" [file tail $fileName]
      ::dom::element setAttribute $fileNode "DIRNAME" [file dirname $fileName]

      #--- je recherche les mots clefs obligatoires
      foreach mandatoryKeywordName $private(mandatoryKeywords) {
         if { [info exists keywordArray($mandatoryKeywordName)] } {
            set keywordValue $keywordArray($mandatoryKeywordName)
         } else {
            set keywordValue  ""
         }

         if { $mandatoryKeywordName == "EXPOSURE" && $keywordValue == ""} {
            #--- si EXPOSURE n'existe pas , je recupere la valeur de EXPTIME
            if { [info exists keywordArray(EXPTIME)] } {
               set keywordValue  $keywordArray(EXPTIME)
            }
         }

         #--- je memorise la valeur du mot clef (chaine vide par defaut)
         ::dom::element setAttribute $fileNode $mandatoryKeywordName $keywordValue
      }
   }

   #--- je recupere la liste des fichiers master
   set globFileList [glob -nocomplain -type f -join "$::conf(eshel,masterDirectory)" *.* ]
   foreach fileName $globFileList {
      set catchResult [catch {
         #--- je lis les mots clefs du fichier
         set fileKeywords [fitsheader $fileName]
      }]
      if { $catchResult !=0 } {
         #--- j'ignore ce fichier car ce n'est pas un fichier FITS
         logError "process::generateNightlog : $fileName is not a FITS file"
         continue
      }
      #--- je copie les mots cles dans un array
      array unset keywordArray
      foreach fileKeyword $fileKeywords {
         set keywordArray([lindex $fileKeyword 0]) [lindex $fileKeyword 1]
      }

      #--- je recherche le type d'image
      if { [info exists keywordArray(IMAGETYP)] == 1 && $keywordArray(IMAGETYP) != "" } {
         switch $keywordArray(IMAGETYP) {
            "BIAS" -
            "DARK" -
            "FLATFIELD" -
            "LED" -
            "TUNGSTEN" -
            "FLAT" -
            "CALIB" -
            "TUNGSTEN" {
               #--- pas d'autre verification a faire
               set nodeType $keywordArray(IMAGETYP)
            }
            "RESPONSE" {
               #--- j'ignore le fichier si la selection de la RI n'est pas en mode automatique
               ###if { [::eshel::instrument::getConfigurationProperty responseOption] != "AUTO" } {
               ###   continue
               ###}
               set nodeType $keywordArray(IMAGETYP)
            }
            default {
               #--- j'gnore les fichiers qui ont d'autre valeur que IMAGETYP
               ###continue
               set nodeType "BAD_REF"
            }
         }
      } else {
         #--- j'ignore ce fichier car le type d'image n'est pas defini
         ###logError "generateNightlog : [file tail $fileName] IMAGETYP keyword is missing"
         ###continue
         set nodeType "BAD_REF"
      }

      #--- je memorise le nom du fichier
      set fileNode  [::dom::document createElement $filesNode $nodeType ]
      ::dom::element setAttribute $fileNode "RAW" 0
      ::dom::element setAttribute $fileNode "FILENAME" [file tail $fileName]
      ::dom::element setAttribute $fileNode "DIRNAME" [file dirname $fileName]

      #--- je recherche les mots clefs obligatoires
      foreach mandatoryKeywordName $private(mandatoryKeywords) {
         if { [info exists keywordArray($mandatoryKeywordName)] } {
            set keywordValue $keywordArray($mandatoryKeywordName)
         } else {
            set keywordValue  ""
         }

         if { $mandatoryKeywordName == "EXPOSURE" && $keywordValue == ""} {
            #--- si EXPOSURE n'existe pas , je recupere la valeur de EXPTIME
            if { [info exists keywordArray(EXPTIME)] } {
               set keywordValue  $keywordArray(EXPTIME)
            }
         }

         #--- je memorise la valeur du mot clef (chaine vide par defaut)
         ::dom::element setAttribute $fileNode $mandatoryKeywordName $keywordValue
      }
   }

   #--- j'ajoute la réponse instrumentale choisie manuellement
   if { [::eshel::instrument::getConfigurationProperty responseOption] == "MANUAL" } {
      set fileName [::eshel::instrument::getConfigurationProperty responseFileName]
      set catchResult [catch {
         #--- je lis les mots clefs du fichier
         set fileKeywords [fitsheader $fileName]
      }]
      if { $catchResult !=0 } {
         #--- j'ignore ce fichier car ce n'est pas un fichier FITS
         logError "generateNightlog : invalid Response file $fileName"
      } else {
         #--- je copie les mots cles dans un array
         array unset keywordArray
         foreach fileKeyword $fileKeywords {
            set keywordArray([lindex $fileKeyword 0]) [lindex $fileKeyword 1]
         }

         set fileNode  [::dom::document createElement $filesNode RESP_MANUAL ]
         ::dom::element setAttribute $fileNode "RAW" 0
         ::dom::element setAttribute $fileNode "FILENAME" $fileName
         ::dom::element setAttribute $fileNode "DIRNAME" [file dirname $fileName]
         #--- je recherche les mots clefs obligatoires
         foreach mandatoryKeywordName $private(mandatoryKeywords) {
            if { [info exists keywordArray($mandatoryKeywordName)] } {
               set keywordValue $keywordArray($mandatoryKeywordName)
            } else {
               set keywordValue  ""
            }

            if { $mandatoryKeywordName == "EXPOSURE" && $keywordValue == ""} {
               #--- si EXPOSURE n'existe pas , je recupere la valeur de EXPTIME
               if { [info exists keywordArray(EXPTIME)] } {
                  set keywordValue  $keywordArray(EXPTIME)
               }
            }

            if { $mandatoryKeywordName == "IMAGETYP" && $keywordValue == ""} {
               #--- si IMAGETYP n'existe pas , je force la valeur a RESPONSE
               set keywordValue  "RESPONSE"
            }

            #--- je memorise la valeur du mot clef (chaine vide par defaut)
            ::dom::element setAttribute $fileNode $mandatoryKeywordName $keywordValue
         }
      }
   }
}

#------------------------------------------------------------
# generateArchiveList
#   genere la liste des archives
#   le resultat est dans la variable le tag ARCHIVE
#
proc ::eshel::process::generateArchiveList { } {
   variable private

   set nightNode $private(nightlog)
   #--- je vide le node s'il existe deja
   set archiveNode [::eshel::process::getArchiveNode]
   if { $archiveNode != "" } {
      ::dom::tcl::destroy $archiveNode
   }

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set archiveNode [::dom::document createElement $nightNode "ARCHIVE"]

   #--- je recupere la liste des fichiers de l'archive
   set globFileList [glob -nocomplain -type f -join "$::conf(eshel,archiveDirectory)" *.* ]
   foreach fileName $globFileList {
      set catchResult [catch {
         #--- je lis les mots clefs du fichier
         set fileKeywords [fitsheader $fileName]
      }]
      if { $catchResult !=0 } {
         #--- j'ignore ce fichier car ce n'est pas un fichier FITS
         logError "process::generateArchiveList : $fileName is not a FITS file"
         continue
      }
      #--- je copie les mots cles dans un array
      array unset keywordArray
      foreach fileKeyword $fileKeywords {
         set keywordArray([lindex $fileKeyword 0]) [lindex $fileKeyword 1]
      }

      #--- j'ajoute le fichier dans l'arbre
      set fileNode  [::dom::document createElement $archiveNode "FILE" ]
      #--- je memorise le nom du fichier
      ::dom::element setAttribute $fileNode "FILENAME" [file tail $fileName]
      ::dom::element setAttribute $fileNode "DIRNAME" [file dirname $fileName]

      #--- je recherche les mots clefs obligatoires
      foreach mandatoryKeywordName $private(mandatoryKeywords) {
         if { [info exists keywordArray($mandatoryKeywordName)] } {
            set keywordValue $keywordArray($mandatoryKeywordName)
         } else {
            set keywordValue  ""
         }

         if { $mandatoryKeywordName == "EXPOSURE" && $keywordValue == ""} {
            #--- si EXPOSURE n'existe pas , je recupere la valeur de EXPTIME
            if { [info exists keywordArray(EXPTIME)] } {
               set keywordValue  $keywordArray(EXPTIME)
            }
         }

         if { $mandatoryKeywordName == "DATE-OBS" && $keywordValue != ""} {
            #--- si l'heure est dans UT-START au lieu de DATE-OBS
            #--- alors je concatene les deux mots clefs DATE_OBS+UT-START dans DATE-OBS
            if { [string first "/" $keywordValue] != -1 && [info exists keywordArray(UT-START)] } {
               set d1 [split $keywordValue "/"]
               if { [llength $d1] == 3 } {
                  set d2 "[lindex $d1 2]  [lindex $d1 1] [lindex $d1 0]"
                  set h1 $keywordArray(UT-START)
                  set h2 [split $h1 ":"]
                  set keywordValue [mc_date2iso8601 "$d2 $h2"]
               }
            }
         }
         #--- je memorise la valeur du mot clef (chaine vide par defaut)
         ::dom::element setAttribute $fileNode $mandatoryKeywordName $keywordValue
      }
      array unset keywordArray
   }

   #--- je cree les series
   ::eshel::process::findSeries "ARCHIVE"
}

#------------------------------------------------------------
# generateProcessBias
#  genere les traitements de BIAS
#
proc ::eshel::process::generateProcessBias { } {
   variable private

   #--- je recupere la liste des series identifiées
   set filesNode [::eshel::process::getFilesNode]

   #--- je recupere la liste des series identifiées
   set roadmapNode [::eshel::process::getRoadmapNode ]

   #--- Pretraitement IMAGETYP=BIAS
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode BIAS ]] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- ce bias est deja traite
         continue
      }
      #--- je cree un traitement à faire
      set processNode [::dom::document createElement $roadmapNode "BIAS-PROCESS" ]
      #--- je copie la serie des fichiers bruts a traiter
      ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1 ]
      set status "todo"
      set errorMessage ""

      #--- je renseigne le status du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      ::dom::element setAttribute $processNode "FILENAME" $fileName
      ::dom::element setAttribute $processNode "STATUS" $status
      ::dom::element setAttribute $processNode "COMMENT" $errorMessage
   }
}

#------------------------------------------------------------
# generateProcessDark
#  genere les traitements de DARK
#
proc ::eshel::process::generateProcessDark { } {
   variable private

   #--- je recupere la liste des series identifiées
   set filesNode [::eshel::process::getFilesNode]

   #--- je recupere la liste des series identifiées
   set roadmapNode [::eshel::process::getRoadmapNode ]

   #--- Pretraitement IMAGETYP=DARK
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode DARK ]] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet dark est deja traite car n'a pas l'attribut RAW
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je cree un traitement à faire
      set processNode [::dom::document createElement $roadmapNode "DARK-PROCESS" ]
      #--- je copie la serie de darks a traiter
      ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1]
      set status "todo"

      #--- je renseigne le status du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      ::dom::element setAttribute $processNode "FILENAME" $fileName
      ::dom::element setAttribute $processNode "STATUS" $status
      ::dom::element setAttribute $processNode "COMMENT" $errorMessage
   }

}

#------------------------------------------------------------
# generateProcessLed
#  genere les traitements de LED
#
proc ::eshel::process::generateProcessLed { } {
   variable private

   #--- je recupere la liste des series identifiées
   set filesNode [::eshel::process::getFilesNode]

   #--- je recupere la liste des series identifiées
   set roadmapNode [::eshel::process::getRoadmapNode ]

   #--- Pretraitement IMAGETYP=LED (ou IMAGETYP=FLAT pour compatibilite ascendante)
   set fileNodeList [concat [set [::dom::element getElementsByTagName $filesNode LED ]] \
       [set [::dom::element getElementsByTagName $filesNode FLAT ]]]
   foreach fileNode $fileNodeList {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet flat est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je cree le traitement LED-PROCESS
      set ledProcessNode [::dom::document createElement $roadmapNode "LED-PROCESS" ]
      if { $errorMessage == "" } {
         #--- je copie la serie de LED ou FLAT a traiter avec le detail des fichiers
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $fileNode 1]
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $biasNode 0]
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $darkNode 0]
         set status "todo"
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) LED=[::dom::element getAttribute $fileNode FILENAME] "
      } else {
         set status "error"
      }
      #--- je renseigne le status du traitement
      set ledFileName [::dom::element getAttribute $fileNode "FILENAME" ]
      #--- je remplace FLAT par LED dans le nom du fichier (pour differentie avec le FLAT final)
      ###set ledFileName [string map { "-FLAT-" "-LED-" } $ledFileName ]
      ::dom::element setAttribute $ledProcessNode "FILENAME" $ledFileName
      ::dom::element setAttribute $ledProcessNode "STATUS" $status
      ::dom::element setAttribute $ledProcessNode "COMMENT" $errorMessage
   }

}


#------------------------------------------------------------
# generateProcessThar
#  genere les traitements de THAR
#
proc ::eshel::process::generateProcessThar { } {
   variable private

   #--- je recupere la liste des series identifiées
   set filesNode [::eshel::process::getFilesNode]

   #--- je recupere la liste des series identifiées
   set roadmapNode [::eshel::process::getRoadmapNode ]

   foreach fileNode [set [::dom::element getElementsByTagName $filesNode CALIB ]] {
         if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
            #--- cette calibration est deja traite
            continue
         }
         #--- j'initialise le message d'erreur
         set errorMessage ""
         #--- je recherche le bias
         set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM] ]
         if { $biasNode == "" } {
            lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
         }
         #--- je recherche le dark
         set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM ] ]
         if { $darkNode == "" } {
            lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
         }

         #--- je cree le traitement THAR-PROCESS
         set processNode [::dom::document createElement $roadmapNode "THAR-PROCESS" ]
         if { $errorMessage == "" } {
            #--- je copie la serie des fichier bruts a traiter
            ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1]
            #--- j'ajoute le bias
            ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $biasNode 0]
            #--- j'ajoute le dark
            ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $darkNode 0]
            set status "todo"
            lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
            lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
            lappend errorMessage "$::caption(eshel,process,with) THAR=[::dom::element getAttribute $fileNode FILENAME] "
         } else {
            set status "error"
         }

         #--- je renseigne le status du traitement
         set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
         ::dom::element setAttribute $processNode "FILENAME" $fileName
         ::dom::element setAttribute $processNode "STATUS" $status
         ::dom::element setAttribute $processNode "COMMENT" $errorMessage
         #--- je trace dans la console
         ###logGenerateProcess  "CALIB-PROCESS" $fileName $status $errorMessage
      }

}

#------------------------------------------------------------
## @brief génère la roadmap de traitements à partir de la liste des fichiers de nightLog
#
proc ::eshel::process::generateProcess { } {
   variable private

   #--- j'initialise le roadmap a vide
   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]

   set roadmapNode [lindex [set [::dom::element getElementsByTagName $nightNode PROCESS ]] 0]
   if { $roadmapNode != "" } {
      ::dom::tcl::destroy $roadmapNode
   }
   set roadmapNode [::dom::document createElement $nightNode PROCESS ]

   #--- je recupere la liste des series identifiées
   set filesNode [::eshel::process::getFilesNode]

   #--- j'affiche une trace dans la console pour marque le debut de la generation des traitements
   set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
   ###logInfo "[format $::caption(eshel,process,generationBegin) $date]"

   ::eshel::process::generateProcessBias

   ::eshel::process::generateProcessDark

   #--- Pretraitement IMAGETYP=FLATFIELD
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode FLATFIELD ]] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet flat est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je cree le traitement a faire
      set processNode [::dom::document createElement $roadmapNode "FLATFIELD-PROCESS" ]
      if { $errorMessage == "" } {
         #--- je copie la serie de FLATFIELD a traiter
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1]
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $biasNode 0]
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $darkNode 0]
         set status "todo"
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) FLATFIELD=[::dom::element getAttribute $fileNode FILENAME] "
      } else {
         set status "error"
      }

      #--- je renseigne le status du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      ::dom::element setAttribute $processNode "FILENAME" $fileName
      ::dom::element setAttribute $processNode "STATUS" $status
      ::dom::element setAttribute $processNode "COMMENT" $errorMessage
      #--- je trace dans la console
      ###logGenerateProcess  "FLAT-PROCESS" $fileName $status $errorMessage
   }

   #--- Pretraitement IMAGETYP=LED (ou IMAGETYP=FLAT pour compatibilite ascendante)
   set fileNodeList [concat [set [::dom::element getElementsByTagName $filesNode LED ]] \
       [set [::dom::element getElementsByTagName $filesNode FLAT ]]]
   foreach fileNode $fileNodeList {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet flat est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je cree le traitement LED-PROCESS
      set ledProcessNode [::dom::document createElement $roadmapNode "LED-PROCESS" ]
      if { $errorMessage == "" } {
         #--- je copie la serie de LED ou FLAT a traiter avec le detail des fichiers
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $fileNode 1]
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $biasNode 0]
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $ledProcessNode [::dom::node cloneNode $darkNode 0]
         set status "todo"
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) LED=[::dom::element getAttribute $fileNode FILENAME] "
      } else {
         set status "error"
      }
      #--- je renseigne le status du traitement
      set ledFileName [::dom::element getAttribute $fileNode "FILENAME" ]
      set ledDirName [::dom::element getAttribute $fileNode "DIRNAME" ]
      #--- je remplace FLAT par LED dans le nom du fichier (pour differentie avec le FLAT final)
      ###set ledFileName [string map { "-FLAT-" "-LED-" } $ledFileName ]
      ::dom::element setAttribute $ledProcessNode "FILENAME" $ledFileName
      ::dom::element setAttribute $ledProcessNode "DIRNAME" $ledDirName
      ::dom::element setAttribute $ledProcessNode "STATUS" $status
      ::dom::element setAttribute $ledProcessNode "COMMENT" $errorMessage
      #--- je trace dans la console
      ###logGenerateProcess  "LED-PROCESS" $ledFileName $status $errorMessage

      if { $status == "todo" } {
         #--- je cree le traitement FLAT-PROCESS
         set flatProcessNode [::dom::document createElement $roadmapNode "FLAT-PROCESS" ]
         set flatFileName [::dom::element getAttribute $fileNode "FILENAME" ]
         set flatDirName [::dom::element getAttribute $fileNode "DIRNAME" ]
         #--- je remplace LED par FLAT
         set flatFileName [string map { LED FLAT } $flatFileName ]
         ::dom::element setAttribute $flatProcessNode "FILENAME" $flatFileName
         ::dom::element setAttribute $flatProcessNode "DIRNAME" $flatDirName

         #--- j'ajoute le node LED dans flatProcessNode
         set newLedNode [::dom::node cloneNode $fileNode 0]
         ::dom::tcl::node appendChild $flatProcessNode $newLedNode

         #--- j'ajoute le node TUNGSTEN dans flatProcessNode
         set tungstenNode [findCompatibleImage $fileNode "TUNGSTEN" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA INSTRUME] ]
         if { $tungstenNode != "" } {
            #--- j'ajoute le TUNGSTEN dans le traitement
            set newTungstenNode [::dom::node cloneNode $tungstenNode 0]
            ::dom::tcl::node appendChild $flatProcessNode $newTungstenNode
         } else {
            #--- je recherche un FLAT deja traite qui contient un TUNGSTEN
            set tungstenNode [findCompatibleImage $fileNode "FLAT" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA INSTRUME] [list RAW 0] ]
            if { $tungstenNode != "" } {
               set newTungstenNode  [copySerieNode $tungstenNode $flatProcessNode "TUNGSTEN"]
            } else {
               #--- j'ajoute LED a la place de TUNGSTEN dans le traitement
               set newTungstenNode [copySerieNode $newLedNode $flatProcessNode "TUNGSTEN"]
            }
         }

         #--- j'ajoute le node FLAT dans FILES pour etre utilisable par les CALIB-PROCESS
         set flatNode [copySerieNode $newLedNode $filesNode "FLAT"]
         ::dom::element setAttribute $flatNode "IMAGETYP" "FLAT"
         ::dom::element setAttribute $flatNode "RAW" 0
         ::dom::element setAttribute $flatNode "FILENAME" $flatFileName
         ::dom::element setAttribute $flatNode "DIRNAME" $flatDirName

         #--- je prepare le message d'information
         set errorMessage ""
         lappend errorMessage "$::caption(eshel,process,with) LED=[::dom::element getAttribute $fileNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) TUNGSTEN=[::dom::element getAttribute $newTungstenNode FILENAME] "

         #--- je renseigne le status et le commentaire du traitement
         ::dom::element setAttribute $flatProcessNode "STATUS" "todo"
         ::dom::element setAttribute $flatProcessNode "COMMENT" $errorMessage
      }
      #--- je trace dans la console
      ###logGenerateProcess  "FLAT-PROCESS" $flatFileName $status $errorMessage
   }

   #--- Pretraitement IMAGETYP=TUNGSTEN
   set fileNodeList [set [::dom::element getElementsByTagName $filesNode TUNGSTEN ]]
   foreach fileNode $fileNodeList {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet flat est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je cree le traitement a faire
      set tungstenProcessNode [::dom::document createElement $roadmapNode "TUNGSTEN-PROCESS" ]
      if { $errorMessage == "" } {
         #--- je copie la serie de TUNGSTEN à traiter
         ::dom::tcl::node appendChild $tungstenProcessNode [::dom::node cloneNode $fileNode 1]
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $tungstenProcessNode [::dom::node cloneNode $biasNode 0]
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $tungstenProcessNode [::dom::node cloneNode $darkNode 0]
         set status "todo"
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) TUNGSTEN=[::dom::element getAttribute $fileNode FILENAME] "
      } else {
         set status "error"
      }

      #--- je renseigne le status du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      set dirName [::dom::element getAttribute $fileNode "DIRNAME" ]
      ::dom::element setAttribute $tungstenProcessNode "FILENAME" $fileName
      ::dom::element setAttribute $tungstenProcessNode "DIRNAME" $dirName
      ::dom::element setAttribute $tungstenProcessNode "STATUS" $status
      ::dom::element setAttribute $tungstenProcessNode "COMMENT" $errorMessage
      #--- je trace dans la console
      ###logGenerateProcess  "TUNGSTEN-PROCESS" $fileName $status $errorMessage

      if { $status == "todo" } {
         #--- je recherche si ce TUNGSTEN est deja utilise dans un FLAT-PROCESS
         set processList [set [::dom::element getElementsByTagName $roadmapNode FLAT-PROCESS ]]
         set flatProcessNode ""
         foreach processNode $processList {
            set tempTungstenNode [lindex [set [::dom::element getElementsByTagName $processNode TUNGSTEN ]] 0]
            if { [::dom::element getAttribute $tempTungstenNode "FILENAME"] == $fileName } {
               set flatProcessNode $processNode
               break
            }
         }

         if { $flatProcessNode == "" } {
             #--- j'initialise le message d'erreur
             set errorMessage ""

            #--- je cree le traitement FLAT-PROCESS
            set flatProcessNode [::dom::document createElement $roadmapNode "FLAT-PROCESS" ]

            #--- je renseigne l'attibut FILENAME de flatProcessNode
            set flatFileName [::dom::element getAttribute $fileNode "FILENAME" ]
            set flatDirName [::dom::element getAttribute $fileNode "DIRNAME" ]
            #--- je remplace TUNGSTEN par FLAT
            set flatFileName [string map { TUNGSTEN FLAT } $flatFileName ]
            ::dom::element setAttribute $flatProcessNode "FILENAME" $flatFileName
            ::dom::element setAttribute $flatProcessNode "DIRNAME" $flatDirName

            #--- j'ajoute LED dans flatProcessNode
            set ledNode [findCompatibleImage $fileNode "FLAT" [list NAXIS1 NAXIS2 BIN1 BIN2 CAMERA INSTRUME] ]
            #--- j'ajouter  LED dans flatProcessNode
            if { $ledNode != "" } {
               set newLedNode [::dom::node cloneNode $ledNode 0]
               ::dom::tcl::node appendChild $flatProcessNode $newLedNode
            } else {
               #--- si le LED n'existe pas, j'utilise le TUNGSTEN a la place de LED
               set newLedNode [copySerieNode $fileNode $flatProcessNode "LED"]
            }
            #--- j'ajoute le TUNGSTEN dans flatProcessNode
            set newTungstenNode [::dom::node cloneNode $fileNode 0]
            ::dom::tcl::node appendChild $flatProcessNode $newTungstenNode

            #--- j'ajoute le FLAT dans FILES pour etre utilisable par les calibrations
            set flatNode [copySerieNode $newTungstenNode $filesNode "FLAT"]
            ::dom::element setAttribute $flatNode "IMAGETYP" "FLAT"
            ::dom::element setAttribute $flatNode "RAW" 0
            ::dom::element setAttribute $flatNode "FILENAME" $flatFileName
            ::dom::element setAttribute $flatNode "DIRNAME" $flatDirName

            #--- je renseigne le status et le commentaire du traitement
            set status "todo"
            lappend errorMessage "$::caption(eshel,process,with) LED=[::dom::element getAttribute $newLedNode FILENAME]"
            lappend errorMessage "$::caption(eshel,process,with) TUNGSTEN=[::dom::element getAttribute $newTungstenNode FILENAME]"
            ::dom::element setAttribute $flatProcessNode "STATUS"   $status
            ::dom::element setAttribute $flatProcessNode "COMMENT"  $errorMessage
            #--- je trace dans la console
            ###logGenerateProcess "FLAT-PROCESS" $flatFileName $status $errorMessage
         } else {
            #--- je deplace tungstenProcessNode avant flatProcessNode pour q'uil soit fait avant
            ::dom::tcl::node insertBefore $roadmapNode $tungstenProcessNode $flatProcessNode
         }

      } ;# is status
   }

   #--- Prétraitement IMAGETYP=CALIB
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode CALIB ]] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cette calibration est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je recherche le flat
      set flatNode [findCompatibleImage $fileNode "FLAT" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM INSTRUME ] ]
      if { $flatNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "FLAT" ]
      }

      #--- je cree le traitement CALIB-PROCESS
      set processNode [::dom::document createElement $roadmapNode "CALIB-PROCESS" ]
      if { $errorMessage == "" } {
         #--- je copie la serie des fichier bruts a traiter
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1]
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $biasNode 0]
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $darkNode 0]
         #--- j'ajoute le flat
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $flatNode 0]
         set status "todo"
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) FLAT=[::dom::element getAttribute $flatNode FILENAME] "
         lappend errorMessage "$::caption(eshel,process,with) THAR=[::dom::element getAttribute $fileNode FILENAME] "
      } else {
         set status "error"
      }

      #--- je renseigne le status du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      ::dom::element setAttribute $processNode "FILENAME" $fileName
      ::dom::element setAttribute $processNode "STATUS" $status
      ::dom::element setAttribute $processNode "COMMENT" $errorMessage
      #--- je trace dans la console
      ###logGenerateProcess  "CALIB-PROCESS" $fileName $status $errorMessage
   }

   #--- Pretraitement des OBJETS
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode OBJECT ]] {
      if { [::dom::element getAttribute $fileNode "RAW"] == 0 } {
         #--- cet objet est deja traite
         continue
      }
      #--- j'initialise le message d'erreur
      set errorMessage ""
      #--- je recherche le bias
      set biasNode [findCompatibleImage $fileNode "BIAS" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM] ]
      if { $biasNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "BIAS" ]
      }
      #--- je recherche le dark
      set darkNode [findCompatibleImage $fileNode "DARK" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM ] ]
      if { $darkNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "DARK" ]
      }

      #--- je recherche le flatflied
      if { [::eshel::instrument::getConfigurationProperty flatFieldEnabled] == 1 } {
         set flatfieldNode [findCompatibleImage $fileNode "FLATFIELD" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM INSTRUME ] ]
         if { $flatfieldNode == "" } {
            lappend errorMessage "FLATFIELD missing"
         }
      }

      #--- je recherche la calibration
      set calibNode [findCompatibleImage $fileNode "CALIB" [list NAXIS1 NAXIS2 BIN1 BIN2 DETNAM INSTRUME] ]
      if { $calibNode == "" } {
         lappend errorMessage [format $::caption(eshel,process,fileNotFound) "CALIB" ]
      }

      #--- je recherche la reponse instrumentale
      switch [::eshel::instrument::getConfigurationProperty responseOption ] {
         MANUAL {
            #--- je recherche la reponse instrumentale
            set responseNode [findCompatibleImage $fileNode "RESP_MANUAL" [list ] ]
            if { $responseNode == "" } {
               lappend errorMessage [format $::caption(eshel,process,fileNotFound) "RESPONSE" ]
            }
         }
         AUTO {
            #--- je recherche la reponse instrumentale
            set responseNode [findCompatibleImage $fileNode "RESPONSE" [list DETNAM INSTRUME TELESCOP] ]
            if { $responseNode == "" } {
               lappend errorMessage [format $::caption(eshel,process,fileNotFound) "RESPONSE" ]
            }
         }
         NONE -
         default {
            #--- pas de fichier de réponse instrumentale
            set responseNode ""
         }
      }

      #--- je verifie que la reponse contient le profil FULL ou les profils par order
      if { $responseNode != "" } {
         if { [::eshel::instrument::getConfigurationProperty responsePerOrder ] == 0 } {
            #--- je verifie qu'un profil FULL est present

         } else {
            #--- je verifie que les profils par ordre sont presents

         }
      }


      #--- je cree un traitement a faire
      set processNode [::dom::document createElement $roadmapNode "OBJECT-PROCESS" ]
      if { $errorMessage == "" } {
         #--- j'ajoute le bias
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $biasNode 0]
         lappend errorMessage "$::caption(eshel,process,with) BIAS=[::dom::element getAttribute $biasNode FILENAME] "
         #--- j'ajoute le dark
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $darkNode 0]
         lappend errorMessage "$::caption(eshel,process,with) DARK=[::dom::element getAttribute $darkNode FILENAME] "
         #--- j'ajoute le flatfield
         if { [::eshel::instrument::getConfigurationProperty flatFieldEnabled] == 1 } {
            ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $flatfieldNode 0]
            lappend errorMessage "$::caption(eshel,process,with) FLATFIELD=[::dom::element getAttribute $flatfieldNode FILENAME] "
         }
         #--- j'ajoute la calib
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $calibNode 0]
         lappend errorMessage "$::caption(eshel,process,with) CALIB=[::dom::element getAttribute $calibNode FILENAME] "
         #--- j'ajoute la reponse instrumentale optionnelle
         if { $responseNode != "" } {
            ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $responseNode 0]
            lappend errorMessage "$::caption(eshel,process,with) RESPONSE=[::dom::element getAttribute $responseNode FILENAME] "
         }
         #--- je copie la serie des images brutes de l'objet
         ::dom::tcl::node appendChild $processNode [::dom::node cloneNode $fileNode 1]
         lappend errorMessage "$::caption(eshel,process,with) OBJECT=[::dom::element getAttribute $fileNode FILENAME] "
         set status "todo"
      } else {
         set status "error"
      }

      #--- je renseigne les attributs du traitement
      set fileName [::dom::element getAttribute $fileNode "FILENAME" ]
      ::dom::element setAttribute $processNode "FILENAME" $fileName
      ::dom::element setAttribute $processNode "STATUS" $status
      ::dom::element setAttribute $processNode "COMMENT" $errorMessage
      #--- je trace dans la console
      ###logGenerateProcess  "OBJECT-PROCESS" $fileName $status $errorMessage
   }
}

#------------------------------------------------------------
# generateScript
#   genere le script de traitement
#
proc ::eshel::process::generateScript { } {
   variable private

   set roadmapNode [getRoadmapNode]

   #--- petit racourci sur le nom de la configuration
   set name $::conf(eshel,currentInstrument)

   #--- je cree le fichier script
   set fileName [file join $::conf(eshel,tempDirectory) $::conf(eshel,scriptFileName)]
   set hScriptFile [open "$fileName" w]

   #--- j'ajoute le debut du script
   putScriptBegin $hScriptFile

   #--- chargement des librairies utilisees
   #  libaudela pour ttscript2
   #  libmc     pour mc_date2jd
   #  libeshel  pour eshel_processFlat  eshel_processCalib  eshel_processObject

   #putCommand $hScriptFile "load [file join $::audela_start_dir libaudela.dll]"
   putCommand $hScriptFile "load \"[file join $::audela_start_dir libtt_tcl.dll]\""
   putCommand $hScriptFile "load \"[file join $::audela_start_dir libmc.dll]\""
   putCommand $hScriptFile "load \"[file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::eshel::getPluginType]] [::eshel::getPluginDirectory] libeshel.dll]\""

   #--- j'active les traces de debugage dans le fichier de trace de la session
   if { $::conf(eshel,instrument,config,$name,debugLog) == 1 } {
      putCommand $hScriptFile "trace add execution ttscript2 enter logDebug"
      putCommand $hScriptFile "trace add execution eshel_processFlat enter logDebug"
      putCommand $hScriptFile "trace add execution eshel_processCalib enter logDebug"
      putCommand $hScriptFile "trace add execution eshel_processObject enter logDebug"
   }

   #--- je declare les variables necessaires au traitement
   putCommand $hScriptFile "#--- Spectrograph parameters"
   putCommand $hScriptFile "set alpha     $::conf(eshel,instrument,config,$name,alpha)"
   putCommand $hScriptFile "set beta      $::conf(eshel,instrument,config,$name,beta)"
   putCommand $hScriptFile "set gamma     $::conf(eshel,instrument,config,$name,gamma)"
   putCommand $hScriptFile "set grating   $::conf(eshel,instrument,config,$name,grating)     "
   putCommand $hScriptFile "set focale    $::conf(eshel,instrument,config,$name,focale)      "
   putCommand $hScriptFile "set pixelSize $::conf(eshel,instrument,config,$name,pixelSize)   "
   putCommand $hScriptFile "set width     $::conf(eshel,instrument,config,$name,width)       "
   putCommand $hScriptFile "set height    $::conf(eshel,instrument,config,$name,height)      "
   putCommand $hScriptFile "set boxWide   $::conf(eshel,instrument,config,$name,boxWide)     "
   putCommand $hScriptFile "set wideOrder $::conf(eshel,instrument,config,$name,wideOrder)   "
   putCommand $hScriptFile "set threshold $::conf(eshel,instrument,config,$name,threshold)   "
   putCommand $hScriptFile "set minOrder  $::conf(eshel,instrument,config,$name,minOrder)    "
   putCommand $hScriptFile "set maxOrder  $::conf(eshel,instrument,config,$name,maxOrder)    "
   putCommand $hScriptFile "set refNum    $::conf(eshel,instrument,config,$name,refNum)      "
   putCommand $hScriptFile "set refX      $::conf(eshel,instrument,config,$name,refX)        "
   putCommand $hScriptFile "set refY      $::conf(eshel,instrument,config,$name,refY)        "
   putCommand $hScriptFile "set refLambda $::conf(eshel,instrument,config,$name,refLambda)   "
   putCommand $hScriptFile "set calibIter $::conf(eshel,instrument,config,$name,calibIter)   "
   putCommand $hScriptFile "set hotPixelList \"$::conf(eshel,instrument,config,$name,hotPixelList)\" "


   putCommand $hScriptFile "\n#--- Order definition (num order, x_min, x_max, slant)"
   putCommand $hScriptFile "set orderDefinition [list $::conf(eshel,instrument,config,$name,orderDefinition)  ]"
   ##putCommand $hScriptFile {::console::disp [llength $orderDefinition]\n}
   putCommand $hScriptFile "set cropLambda [list $::conf(eshel,instrument,config,$name,cropLambda)  ]"
   putCommand $hScriptFile "\n#--- Calibration lines  (lambda in angtrom)"
   putCommand $hScriptFile "set lineList { $::conf(eshel,instrument,config,$name,lineList) }"

   putCommand $hScriptFile "set distorsion [list $::conf(eshel,instrument,config,$name,distorsion) ]"
   putCommand $hScriptFile "set saveObjectImage  $::conf(eshel,instrument,config,$name,saveObjectImage)"


   foreach processNode [::dom::tcl::node children $roadmapNode] {
      set processType [::dom::tcl::node cget $processNode -nodeName]
      set status [::dom::element getAttribute $processNode "STATUS"]
      if { $status != "todo" } {
         #--- je saute le traitement s'il n'est pas a faire
         continue
      }

      switch $processType {
         "BIAS-PROCESS" {
            #--- nom du bias pretraite en sortie
            set biasNode [lindex [set [::dom::element getElementsByTagName $processNode BIAS ]] 0]
            set fileNameOut   [::dom::element getAttribute $biasNode "FILENAME"]

            #--- Nom des fichier bruts en entree
            set biasNames ""
            foreach fileNode [::dom::tcl::node children $biasNode] {
               lappend biasNames [::dom::element getAttribute $fileNode "FILENAME" ]
            }

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "BIAS-PROCESS" $fileNameOut [::dom::element getAttribute $processNode "COMMENT"]
            ##putLog $hScriptFile "PROCESS BIAS $fileNameOut"
            putImaStack $hScriptFile  $::conf(eshel,rawDirectory) $biasNames $::conf(eshel,referenceDirectory) $fileNameOut "MED"
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $biasNames
            putCatchEnd $hScriptFile "BIAS-PROCESS" $fileNameOut
         }

         "DARK-PROCESS" {
            #--- nom du dark pretraite en sortie
            set darkNode [lindex [set [::dom::element getElementsByTagName $processNode DARK ]] 0]
            set fileNameOut   [::dom::element getAttribute $darkNode "FILENAME"]

            #--- Nom des darks bruts en entree
            set darkNames ""
            foreach fileNode [::dom::tcl::node children $darkNode] {
               lappend darkNames [::dom::element getAttribute $fileNode "FILENAME" ]
            }

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "DARK-PROCESS" $fileNameOut [::dom::element getAttribute $processNode "COMMENT"]
            ##putLog $hScriptFile "PROCESS DARK $fileNameOut"
            putImaStack  $hScriptFile $::conf(eshel,rawDirectory) $darkNames $::conf(eshel,referenceDirectory) $fileNameOut  "MED"
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $darkNames
            putCatchEnd $hScriptFile "DARK-PROCESS" $fileNameOut
         }

         "FLATFIELD-PROCESS" {
            #--- nom du flatfield pretraite en sortie
            set flatfieldNode [lindex [set [::dom::element getElementsByTagName $processNode FLATFIELD ]] 0]
            set fileNameOut   [::dom::element getAttribute $flatfieldNode "FILENAME"]

            #--- Nom des flats bruts en entree
            set flatfieldNames ""
            foreach fileNode [::dom::tcl::node children $flatfieldNode] {
               lappend flatfieldNames [::dom::element getAttribute $fileNode "FILENAME" ]
            }

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "FLATFIELD-PROCESS" $fileNameOut  [::dom::element getAttribute $processNode "COMMENT"]
            putImaStack  $hScriptFile $::conf(eshel,rawDirectory) $flatfieldNames $::conf(eshel,referenceDirectory) $fileNameOut  "MED"
            putImaSeries $hScriptFile $::conf(eshel,referenceDirectory) $fileNameOut $::conf(eshel,referenceDirectory) $fileNameOut  "STAT"
            putCommand   $hScriptFile "      file rename -force \"[file join $::conf(eshel,referenceDirectory) ${fileNameOut}1.fit]\"  \"[file join $::conf(eshel,referenceDirectory) $fileNameOut]\" "
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $flatfieldNames
            putCatchEnd $hScriptFile "FLATFIELD-PROCESS" $fileNameOut
         }

         "LED-PROCESS" -
         "TUNGSTEN-PROCESS" {
            #--- Nom du bias
            set biasNode [lindex [set [::dom::element getElementsByTagName $processNode BIAS ]] 0]
            set biasFileName [::dom::element getAttribute $biasNode "FILENAME"]
            set biasDirName  [::dom::element getAttribute $biasNode "DIRNAME"]

            #--- Nom du dark
            set darkNode [lindex [set [::dom::element getElementsByTagName $processNode DARK ]] 0]
            set darkFileName [::dom::element getAttribute $darkNode "FILENAME"]
            set darkDirName  [::dom::element getAttribute $darkNode "DIRNAME"]

            #--- Nom des LED ou TUNGSTEN bruts en entree (ou FLAT pour compatibilite ascendante
            set flatNode [lindex [set [::dom::element getElementsByTagName $processNode LED ]] 0]
            if { $flatNode == "" } {
               set flatNode [lindex [set [::dom::element getElementsByTagName $processNode TUNGSTEN ]] 0]
            }
            if { $flatNode == "" } {
               set flatNode [lindex [set [::dom::element getElementsByTagName $processNode FLAT ]] 0]
            }

            set flatsNames ""
            set tempNames ""
            set tempNum   "0"
            foreach fileNode [::dom::tcl::node children $flatNode] {
               lappend flatsNames [::dom::element getAttribute $fileNode "FILENAME" ]
               incr tempNum
               lappend tempNames "temp-$tempNum.fit"
            }

            #--- nom du LED ou TUNGSTEN en sortie
            set processedFlat [::dom::element getAttribute $processNode "FILENAME"]

            #--- j'ajoute le script
            putCatchBegin $hScriptFile $processType $processedFlat  [::dom::element getAttribute $processNode "COMMENT"]
            #--- tempFlat(i) = rawFlat(i) - (dark - bias)* (flatExptime/darkExptime) - bias
            putImaSeries $hScriptFile $::conf(eshel,rawDirectory) $flatsNames $::conf(eshel,tempDirectory) "temp-" "SUBDARK \\\"DARK=[file join $darkDirName $darkFileName]\\\"  \\\"BIAS=[file join $biasDirName $biasFileName]\\\"  EXPTIME=EXPOSURE DEXPTIME=EXPOSURE"
            #--- preprocFlat(i) = mediane( tempFlat(i) )
            set imaStackOption " ADD bitpix=32"
            if { $::conf(eshel,instrument,config,$name,hotPixelEnabled) == 1 } {
               #--- j'ajoute l'option pour le retrait des pixels chauds
               append imaStackOption " \\\"HOT_PIXEL_LIST=\$\hotPixelList\\\""
            }
            putImaStack  $hScriptFile $::conf(eshel,tempDirectory) $tempNames $::conf(eshel,tempDirectory) $processedFlat $imaStackOption


            #--- delete temporary files
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $tempNames
            #--- save rawFiles into archive directory
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $flatsNames
            putCatchEnd $hScriptFile $processType $processedFlat
         }

         "FLAT-PROCESS" {
            #--- Nom du LED
            set ledNode [lindex [set [::dom::element getElementsByTagName $processNode LED ]] 0]
            if { $ledNode == "" } {
               #--- pour compatibilite avec les versions precendentes
               set ledNode [lindex [set [::dom::element getElementsByTagName $processNode FLAT ]] 0]
            }
            set ledFileName [::dom::element getAttribute $ledNode "FILENAME"]
            set ledRaw      [::dom::element getAttribute $ledNode "RAW"]
            if { $ledRaw == 1 } {
               #--- l'image LED pretraitee est dans le repertoire temp
               set ledDirectory $::conf(eshel,tempDirectory)
            } else {
               #--- l'image LED traitee est dans le repertoire reference
               set ledDirectory $::conf(eshel,referenceDirectory)
            }

            #--- Nom du TUNGSTEN
            set tungstenNode [lindex [set [::dom::element getElementsByTagName $processNode TUNGSTEN ]] 0]
            set tungstenFileName  [::dom::element getAttribute $tungstenNode "FILENAME"]
            set tungstenRaw       [::dom::element getAttribute $tungstenNode "RAW"]
            if { $tungstenRaw == 1 } {
               #--- l'image TUNGSTEN pretraitee est dans le repertoire temp
               set tungstenDirectory $::conf(eshel,tempDirectory)
            } else {
               #--- l'image TUNGSTEN traitee est dans le repertoire reference
               set tungstenDirectory $::conf(eshel,referenceDirectory)
            }

            #--- nom du flat en sortie
            set processedFlat [::dom::element getAttribute $processNode "FILENAME"]

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "FLAT-PROCESS" $processedFlat [::dom::element getAttribute $processNode "COMMENT"]
            #--- processedFlat = processFlat( preprocLed , preprocTungsten)
            putProcessFlat $hScriptFile [file join $ledDirectory $ledFileName] \
               [file join $tungstenDirectory $tungstenFileName] \
               [file join $::conf(eshel,referenceDirectory) $processedFlat]
            #--- delete preprocessed files
            if { $ledRaw == 1 } {
               putDeleteFiles $hScriptFile $ledDirectory $ledFileName
            }
            if { $tungstenRaw == 1 } {
               putDeleteFiles $hScriptFile $tungstenDirectory $tungstenFileName
            }
            putCatchEnd $hScriptFile "FLAT-PROCESS" $processedFlat
         }

         "THAR-PROCESS" {
            #--- Nom du bias
            set biasNode [lindex [set [::dom::element getElementsByTagName $processNode BIAS ]] 0]
            set biasFileName [::dom::element getAttribute $biasNode "FILENAME"]
            set biasDirName  [::dom::element getAttribute $biasNode "DIRNAME"]

            #--- Nom du dark
            set darkNode [lindex [set [::dom::element getElementsByTagName $processNode DARK ]] 0]
            set darkFileName [::dom::element getAttribute $darkNode "FILENAME"]
            set darkDirName  [::dom::element getAttribute $darkNode "DIRNAME"]


            #--- Nom des fichiers bruts en entree
            set calibNode [lindex [set [::dom::element getElementsByTagName $processNode CALIB ]] 0]
            set rawNames ""
            set tempNames ""
            set tempNum   "0"
            foreach fileNode [::dom::tcl::node children $calibNode] {
               lappend rawNames [::dom::element getAttribute $fileNode "FILENAME" ]
               incr tempNum
               lappend tempNames "temp-$tempNum.fit"
            }

            #--- nom du flat en sortie
            set preprocCalib   [::dom::element getAttribute $calibNode "FILENAME"]
            set processedCalib [::dom::element getAttribute $calibNode "FILENAME"]

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "THAR-PROCESS" $processedCalib [::dom::element getAttribute $processNode "COMMENT"]
            #--- tempName(i) = rawName(i) - (dark thermique) * (calibExptime/darkExptime) - bias
            putImaSeries $hScriptFile $::conf(eshel,rawDirectory) $rawNames $::conf(eshel,tempDirectory) "temp-" "SUBDARK \\\"dark=[file join $darkDirName $darkFileName]\\\"  \\\"bias=[file join $biasDirName $biasFileName]\\\" EXPTIME=EXPOSURE DEXPTIME=EXPOSURE"
            #--- preprocCalib = mediane( tempName(i) )
            putImaStack  $hScriptFile $::conf(eshel,tempDirectory) $tempNames $::conf(eshel,tempDirectory) $preprocCalib  "MED \\\"HOT_PIXEL_LIST=\$\hotPixelList\\\""
            #--- delete temporary files
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $tempNames
            #--- save rawFiles into archive directory
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $rawNames
            putCatchEnd $hScriptFile "THAR-PROCESS" $processedCalib

         }

         "CALIB-PROCESS" {
            #--- Nom du bias
            set biasNode [lindex [set [::dom::element getElementsByTagName $processNode BIAS ]] 0]
            set biasFileName [::dom::element getAttribute $biasNode "FILENAME"]
            set biasDirName  [::dom::element getAttribute $biasNode "DIRNAME"]

            #--- Nom du dark
            set darkNode [lindex [set [::dom::element getElementsByTagName $processNode DARK ]] 0]
            set darkFileName [::dom::element getAttribute $darkNode "FILENAME"]
            set darkDirName  [::dom::element getAttribute $darkNode "DIRNAME"]

            #--- Nom du flat
            set flatNode [lindex [set [::dom::element getElementsByTagName $processNode FLAT ]] 0]
            set flatFileName [::dom::element getAttribute $flatNode "FILENAME"]

            #--- Nom des fichiers bruts en entree
            set calibNode [lindex [set [::dom::element getElementsByTagName $processNode CALIB ]] 0]
            set rawNames ""
            set tempNames ""
            set tempNum   "0"
            foreach fileNode [::dom::tcl::node children $calibNode] {
               lappend rawNames [::dom::element getAttribute $fileNode "FILENAME" ]
               incr tempNum
               lappend tempNames "temp-$tempNum.fit"
            }

            #--- nom du flat en sortie
            set preprocCalib   [::dom::element getAttribute $calibNode "FILENAME"]
            set processedCalib [::dom::element getAttribute $calibNode "FILENAME"]

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "CALIB-PROCESS" $processedCalib [::dom::element getAttribute $processNode "COMMENT"]
            ##putLog $hScriptFile "PROCESS CALIB $processedCalib"
            #--- tempName(i) = rawName(i) - (dark thermique) * (calibExptime/darkExptime) - bias
            putImaSeries $hScriptFile $::conf(eshel,rawDirectory) $rawNames $::conf(eshel,tempDirectory) "temp-" "SUBDARK \\\"dark=[file join $darkDirName $darkFileName]\\\"  \\\"bias=[file join $biasDirName $biasFileName]\\\" EXPTIME=EXPOSURE DEXPTIME=EXPOSURE"
            #--- preprocCalib = mediane( tempName(i) )
            set imaStackOption " MED"
            if { $::conf(eshel,instrument,config,$name,hotPixelEnabled) == 1 } {
               #--- j'ajoute l'option pour le retrait des pixels chauds
               append imaStackOption " \\\"HOT_PIXEL_LIST=\$\hotPixelList\\\""
            }
            putImaStack  $hScriptFile $::conf(eshel,tempDirectory) $tempNames $::conf(eshel,tempDirectory) $preprocCalib $imaStackOption
            #--- processedCalib = processCalib( preprocCalib, Flat )
            putProcessCalib $hScriptFile $::conf(eshel,tempDirectory) $preprocCalib $::conf(eshel,referenceDirectory) $processedCalib $::conf(eshel,referenceDirectory) $flatFileName
            #--- delete temporary files
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $tempNames
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $preprocCalib
            #--- save rawFiles into archive directory
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $rawNames
            putCatchEnd $hScriptFile "CALIB-PROCESS" $processedCalib

         }

         "OBJECT-PROCESS" {
            #--- Nom du bias pretraite
            set biasNode [lindex [set [::dom::element getElementsByTagName $processNode BIAS ]] 0]
            set biasFileName [::dom::element getAttribute $biasNode "FILENAME"]
            set biasDirName  [::dom::element getAttribute $biasNode "DIRNAME"]

            #--- Nom du dark pretraite
            set darkNode [lindex [set [::dom::element getElementsByTagName $processNode DARK ]] 0]
            set darkFileName [::dom::element getAttribute $darkNode "FILENAME"]
            set darkDirName  [::dom::element getAttribute $darkNode "DIRNAME"]

            #--- Nom de la calibration traitee
            set calibNode [lindex [set [::dom::element getElementsByTagName $processNode CALIB ]] 0]
            set calibFileName [::dom::element getAttribute $calibNode "FILENAME"]
            set calibFileName [file join $::conf(eshel,referenceDirectory) $calibFileName]

            #--- Nom du flatfield (optionnel)
            set flatfieldNode [lindex [set [::dom::element getElementsByTagName $processNode FLATFIELD ]] 0]
            if { $flatfieldNode != "" } {
               set flatfieldFileName [::dom::element getAttribute $flatfieldNode "FILENAME"]
            } else {
               set flatfieldFileName ""
            }

            #--- Nom de la reponse instrumentale (optionnel)
            set responseNode [lindex [set [::dom::element getElementsByTagName $processNode RESP_MANUAL ]] 0]
            if { $responseNode != "" } {
               set responseFileName [::dom::element getAttribute $responseNode "FILENAME"]
            } else {
               #--- je cherche une selectionne automatiquement
               set responseNode [lindex [set [::dom::element getElementsByTagName $processNode RESPONSE ]] 0]
               if { $responseNode != "" } {
                  set responseFileName [::dom::element getAttribute $responseNode "FILENAME"]
                  if {[file pathtype $responseFileName ] == "relative" } {
                     set responseFileName [file join $::conf(eshel,referenceDirectory) $responseFileName]
                  }
               } else {
                  set responseFileName ""
               }
            }

            #--- nom de l'objet pretraite en sortie
            set objectNode [lindex [set [::dom::element getElementsByTagName $processNode OBJECT ]] 0]
            set fileNameOut   [::dom::element getAttribute $objectNode "FILENAME"]

            #--- Nom des objets bruts en entree
            set objectsNames ""
            set tempNames ""
            set tempNum   "0"
            foreach fileNode [::dom::tcl::node children $objectNode] {
               lappend objectsNames [::dom::element getAttribute $fileNode "FILENAME" ]
               incr tempNum
               lappend tempNames "temp-$tempNum.fit"
               lappend tempFullNames [file join $::conf(eshel,tempDirectory) "temp-$tempNum.fit" ]
            }

            #--- j'ajoute le script
            putCatchBegin $hScriptFile "OBJECT-PROCESS" $fileNameOut [::dom::element getAttribute $processNode "COMMENT"]
            ##putLog $hScriptFile "PROCESS OBJECT $fileNameOut"
            set subDarkOption " \\\"dark=[file join $darkDirName $darkFileName]\\\""
            append subDarkOption " \\\"bias=[file join $biasDirName $biasFileName]\\\""
            append subDarkOption " EXPTIME=EXPOSURE DEXPTIME=EXPOSURE"
            ###if { $::conf(eshel,instrument,config,$name,hotPixelEnabled) == 1 } {
               #--- j'ajoute l'option pour le retrait des pixels chauds
               ###append subDarkOption " \\\"HOT_PIXEL_LIST=\$\hotPixelList\\\""
            ###}
            if { $::conf(eshel,instrument,config,$name,cosmicEnabled) == 1 } {
               #--- j'ajoute l'option pour le retrait des cosmiques
               append subDarkOption " \\\"COSMIC_THRESHOLD=$::conf(eshel,instrument,config,$name,cosmicThreshold)\\\""
               set cosmicCleaning "removed"
            } else {
               set cosmicCleaning "none"
            }

            #--- tempName(i) = objectRaw(i) - (dark thermique) * (objectExptime/darkExptime) - bias
            if { $::conf(eshel,instrument,config,$name,quickProcess) == 1 } {
               #--- je soustrais le dark+bias
               putImaSeries $hScriptFile $::conf(eshel,rawDirectory) $objectsNames $::conf(eshel,tempDirectory) "temp-" "SUBDARK $subDarkOption"

               #--- je divise par le flatfield
               if { $flatfieldFileName != "" } {
                  set fullFlatfieldName [file join $::conf(eshel,referenceDirectory) $flatfieldFileName]
                  #--- je recupere la moyenne du flatfield
                  putCommand $hScriptFile "set keywords \[fitsheader \"$fullFlatfieldName\"\]"
                  putCommand $hScriptFile "set flatFieldMean  \[lindex \[lsearch -index 0 -inline \$keywords MEAN\] 1\]"
                  #--- je divise par le flatfield et je multiple par sa moyenne
                  putImaSeries $hScriptFile $::conf(eshel,tempDirectory) $tempNames $::conf(eshel,tempDirectory) "temp-" "DIV \\\"file=$fullFlatfieldName\\\" constant=\$flatFieldMean"
               }

               #--- je somme les images pretraitees
               set imaStackOption "ADD bitpix=32"
               if { $::conf(eshel,instrument,config,$name,hotPixelEnabled) == 1 } {
                  #--- j'ajoute l'option pour le retrait des pixels chauds
                  append imaStackOption " \\\"HOT_PIXEL_LIST=\$\hotPixelList\\\""
               }
               putImaStack  $hScriptFile $::conf(eshel,tempDirectory) $tempNames $::conf(eshel,tempDirectory) $fileNameOut  $imaStackOption

               #--- j'extrait les profils
               putProcessObject $hScriptFile [file join $::conf(eshel,tempDirectory) $fileNameOut] \
                  [file join $::conf(eshel,processedDirectory) $fileNameOut] \
                  $calibFileName $responseFileName $::conf(eshel,instrument,config,$name,responsePerOrder) $cosmicCleaning
            } else {
               set tempFileList ""
               foreach objectFile $objectsNames {
                  putImaSeries $hScriptFile $::conf(eshel,rawDirectory) $objectFile $::conf(eshel,tempDirectory) "temp-" "SUBDARK $subDarkOption"
                  lappend tempFileList [file join $::conf(eshel,tempDirectory) $fileNameOut ]
               }
               putProcessObject $hScriptFile $tempFullNames [file join $::conf(eshel,processedDirectory) $fileNameOut] $calibFileName $responseFileName
            }
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $tempNames
            putDeleteFiles $hScriptFile $::conf(eshel,tempDirectory) $fileNameOut
            #--- save rawFiles into archive directory
            putMoveFiles $hScriptFile $::conf(eshel,rawDirectory) $::conf(eshel,archiveDirectory) $objectsNames
            putCatchEnd $hScriptFile "OBJECT-PROCESS" $fileNameOut
         }
      }
   }

   putScriptEnd $hScriptFile
   close $hScriptFile
}



#------------------------------------------------------------
# setFileAttributes
#    modifie les attributs d'un fichier
#
# parametres :
#   fileName :      nom du fichier
#   attributeList : liste de couples { nomAttribut valeurAttribut }
#
# return :
#   rien
# example :
#   setFileAttributes foo.fit { SERIESID "xxx xxx xx" CAMERA audine }
#
proc ::eshel::process::setFileAttributes { fileName attributeList } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]

   foreach fileNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $fileNode "FILENAME"] == $fileName } {
         #--- je copie les nouvelles valeurs des attributs
         foreach {attributeName attributeValue} $attributeList {
            ::dom::element setAttribute $fileNode $attributeName $attributeValue
         }
         break
      }
   }
   return
}

#------------------------------------------------------------
# ::eshel::process::getRoadmapState
#   retourne 1 si un traitement est en cours , sinon retourne 0
#
proc ::eshel::process::getRoadmapState { } {
   variable private
   return $private(running)
}

#------------------------------------------------------------
# ::eshel::process::getRoadmapDate
#   retourne la date de generation de la roadmap
#
proc ::eshel::process::getRoadmapDate { } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   if { $nightNode == "" } {
      return ""
   }
   set date [::dom::element getAttribute $nightNode "DATE"]

   return $date
}

#------------------------------------------------------------
# ::eshel::process::getRoadmapNbFiles
#   retourne le nombre de fichiers valides, ignores , reference, et le nombre de traitements a faire
#
proc ::eshel::process::getRoadmapNbFiles { } {
   variable private

   set validNb       0
   set ignoredNb     0
   set referenceNb   0
   set processNb     0

   #--- je compte le nombre de fichiers valides et ignores
   foreach fileNode [::dom::tcl::node children [ ::eshel::process::getFilesNode]] {
      set imageType [::dom::tcl::node cget $fileNode -nodeName]
      if { $imageType != "FILE" } {
         if { [::dom::element getAttribute $fileNode "RAW"] == 1 } {
            incr validNb [llength [::dom::tcl::node children $fileNode]]
         } else {
            incr referenceNb
         }
      } else {
         incr ignoredNb
      }
   }

   #--- je compte les traitements a faire
   set roadmapNode [::eshel::process::getRoadmapNode]
   if { $processNode != "" } {
      set processNb [llength [::dom::tcl::node children $roadmapNode ]]
   }

   return [list $validNb $ignoredNb $referenceNb $processNb]
}


#------------------------------------------------------------
# ::eshel::process::getArchiveNode
#   retourne le node contenant les fichiers archives
#
proc ::eshel::process::getArchiveNode { } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set archiveNode [lindex [set [::dom::element getElementsByTagName $nightNode "ARCHIVE" ]] 0]

   return $archiveNode
}

#------------------------------------------------------------
# ::eshel::process::getFilesNode
#   retourne les fichiers non identifies
#
proc ::eshel::process::getFilesNode { } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]

   return $filesNode
}

#------------------------------------------------------------
# ::eshel::process::getRoadmapNode
#   retourne le noeud des traitements a faire
#   (return "" si le noeud n'existe pas)
#
proc ::eshel::process::getRoadmapNode { } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set processNode [lindex [set [::dom::element getElementsByTagName $nightNode "PROCESS" ]] 0]
   if { $processNode == "" } {
      set processNode [::dom::document createElement $nightNode PROCESS ]
   }
   return $processNode
}

#------------------------------------------------------------
# ::eshel::process::deleteRoadmapNode
#
#
proc ::eshel::process::deleteRoadmap { } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set processNode [lindex [set [::dom::element getElementsByTagName $nightNode "PROCESS" ]] 0]
   if { $processNode != "" } {
      #--- je supprime la liste des process
      ::dom::tcl::node removeChild $nightNode $processNode
      #--- je cree la liste des process vide
      ::dom::document createElement $nightNode PROCESS
   }
   #--- j'efface le script
   file delete -force [file join $::conf(eshel,tempDirectory) $::conf(eshel,scriptFileName)]
}

#------------------------------------------------------------
# ::eshel::process::copySerieNode
#   copie un noeud en changeant le type
#
proc ::eshel::process::copySerieNode { sourceNode destinationParentNode newType } {
   variable private

   #--- je cree le node
   set newNode [::dom::document createElement $destinationParentNode $newType ]
   set attributes [::dom::node cget $sourceNode -attributes ]
   set attributes [array get $attributes]

   ####--- je copie les autres attributs
   ###foreach keywordName $private(serieAttributes) {
   ###   ::dom::element setAttribute $newNode $keywordName [::dom::element getAttribute $sourceNode $keywordName]
   ###}
   foreach { name value } $attributes {
      ::dom::element setAttribute $newNode $name $value
   }
   return $newNode
}

#------------------------------------------------------------
# ::eshel::process::getFileAttributeNames
#   retourne la liste des noms des attributs des fichiers bruts
#
proc ::eshel::process::getFileAttributeNames { } {
   variable private
   return $private(mandatoryKeywords)
}

#------------------------------------------------------------
# ::eshel::process::getReferenceAttributeNames
#   retourne la liste des noms des attributs des fichiers de reference
#
proc ::eshel::process::getReferenceAttributeNames { } {
   variable private
   return $private(referenceKeywords)
}

#------------------------------------------------------------
# ::eshel::process::getSerieAttributeNames
#   retourne la liste des noms des attributs des series
#
proc ::eshel::process::getSerieAttributeNames { } {
   variable private
   return $private(serieAttributes)
}

#------------------------------------------------------------
## @brief retourne les informations des process d'un type donné
#  @param processType ??
#  @return { { filename status comment} { filename status comment} ...}
#  @todo commenter le param processType
#
proc ::eshel::process::getProcessInfo { processType } {
   variable private

   set ouputList {}

   set roadmapNode [::eshel::process::getRoadmapNode]
   foreach processNode [set [::dom::element getElementsByTagName $roadmapNode $processType]] {
      lappend ouputList [list [::dom::element getAttribute $processNode "FILENAME"] \
         [::dom::element getAttribute $processNode "STATUS"] \
         [::dom::element getAttribute $processNode "COMMENT"] ]
   }

   return $ouputList
}

proc ::eshel::process::putCommand { hfile command } {
   variable private
   puts $hfile $command

}

proc ::eshel::process::putScriptBegin { hfile  } {
   variable private
   set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
   set name $::conf(eshel,currentInstrument)
   set command "\n"
   append  command "####################################################\n"
   append  command "# eShel script generated on $date TU  \n"
   append  command "#    Spectrograph $::conf(eshel,instrument,config,$name,spectroName) \n"
   append  command "#    Camera       $::conf(eshel,instrument,config,$name,cameraName)  \n"
   append  command "#    Telescope    $::conf(eshel,instrument,config,$name,telescopeName)  \n"
   append  command "####################################################\n"
   append  command "\n"
   append  command "#-------------------- \n"
   append  command "# Procedure\n"
   append  command "#-------------------- \n"
   append  command "proc logInfo { message } {\n"
   append  command "  ::thread::send -async [thread::id] "
   append  command { [list ::eshel::process::logInfo  "$message"] }
   append  command "\n"
   append  command "}\n"
   append  command "\n"
   append  command "proc logError { message } {\n"
   append  command "  ::thread::send -async [thread::id] "
   append  command { [list ::eshel::process::logError  "$message"] }
   append  command "\n"
   append  command "}\n"
   append  command "\n"
   append  command "proc logDebug { args } {\n"
   append  command "  ::thread::send -async [thread::id] "
   append  command { [list ::eshel::process::logDebug  "$args"] }
   append  command "\n"
   append  command "}\n"
   append  command "\n"
   append  command "proc logStep { processType fileName status { message \"\" } } {\n"
   append  command "  ::thread::send -async [thread::id] "
   append  command { [list ::eshel::process::logStep $processType $fileName $status $message] }
   append  command "\n"
   append  command "}\n"
   append  command "\n"
   append  command "#-------------------- \n"
   append  command "# Main procedure \n"
   append  command "#-------------------- \n"
   append  command "set stopScript 0\n"
   puts $hfile $command
}

proc ::eshel::process::putScriptEnd { hfile  } {
   variable private

   set command     "\n#--- Logs end date\n"
   append  command "set endLabel \"$::caption(eshel,process,processEnd)\"\n"
   append  command {set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]}
   append  command "\n"
   append  command {logInfo "$endLabel $date TU"}
   append  command "\n"
   append  command {if { $stopScript == 1 } }
   append  command " {\n"
   append  command "\n"
   append  command {   logError "stop by user."}
   append  command "\n"
   append  command "}\n"
   append  command "\n"
   append  command "#--- Notify end to main thread\n"
   append  command "::thread::send -async [thread::id] ::eshel::process::endScript\n"
   append  command "\n"
   append  command "#--- exit thread \n"
   append  command "::thread::release"
   puts $hfile $command

}

proc ::eshel::process::putCatchBegin { hfile processType fileName message} {
   variable private
   set command ""
   append command "#---je prends le temps de recevoir une eventuelle demande d'arret\n"
   append command "update  \n"
   append command "if \{ \$stopScript == 0 \} \{\n"
   append command "   set catchResult \x5B catch \x7B \n"
   append command "      logStep \"$processType\" \"$fileName\" \"running\" \"$message\" "
   puts $hfile $command
}

proc ::eshel::process::putCatchEnd { hfile processType fileName } {
   variable private

   set command ""
   append command "      logStep \"$processType\" \"$fileName\" \"done\" \n"
   append command "   \}\] ; #--- End catch section \n"
   append command "   if \{ \$catchResult == 1 \} \{ \n"
   append command "      logStep \"$processType\" \"$fileName\" \"error\" \"\$::errorInfo\" \n"
   ###append command {   logError $::errorInfo      }
   append command "   \}\n"
   append command "\}\n"
   puts $hfile $command

}


proc ::eshel::process::putLog { hfile message } {
   variable private
   ###puts $hfile "::thread::send -async [thread::id] [list ::eshel::process::logInfo \"$message\n\"]"
   puts $hfile "logInfo \"$message\""

}

proc ::eshel::process::putImaSeries { hfile dirIn fileIn dirOut fileOut operation } {
   set inFileExtension ""
   set outFileExtension ".fit"
   set command "      ttscript2 \"IMA/SERIES "
   append command " \\\"$dirIn\\\" \\\"$fileIn\\\" * * \\\"$inFileExtension\\\""
   append command " \\\"$dirOut\\\" \\\"$fileOut\\\" 1 \\\"$outFileExtension\\\""
   append command " $operation"
   append command " \""
   puts $hfile $command
}

proc ::eshel::process::putImaStack { hfile dirIn fileIn dirOut fileOut operation } {
   set fileExtension ""
   set command "      ttscript2 \"IMA/STACK "
   append command " \\\"$dirIn\\\" \\\"$fileIn\\\" * * \\\"$fileExtension\\\""
   append command " \\\"$dirOut\\\" \\\"$fileOut\\\" . \\\"$fileExtension\\\""
   append command " $operation "
   append command " \""
   puts $hfile $command
}

proc ::eshel::process::putProcessFlat { hfile ledIn tungstenIn flatOut } {
   set fileExtension ""
   set command    "      eshel_processFlat "
   append command "\"$ledIn\" "
   append command "\"$tungstenIn\" "
   append command "\"$flatOut\" "
   append command {$alpha $beta $gamma $focale $grating $pixelSize }
   append command {$width $height }
   append command {$boxWide $wideOrder $threshold }
   append command {$minOrder $maxOrder }
   append command {$refX $refY $refNum $refLambda }
   append command {$orderDefinition $lineList $distorsion }
   puts $hfile $command
}

proc ::eshel::process::putProcessCalib { hfile dirIn fileIn dirOut fileOut dirFlat fileFlat } {
   set fileExtension ""
   set command    "      eshel_processCalib "
   append command "\"[file join $dirIn $fileIn]\" "
   append command "\"[file join $dirOut $fileOut]\" "
   append command "\"[file join $dirFlat $fileFlat]\" "
   append command {$refX $refNum $refLambda $calibIter }
   append command {$lineList }

   puts $hfile $command
}

proc ::eshel::process::putProcessObject { hfile objectFileNameIn objectFileNameOut calibFileName responseFileName responsePerOrder cosmicCleaning } {
   set fileExtension ""
   set command    "      eshel_processObject "
   append command "\"$objectFileNameIn\" "
   append command "\"$objectFileNameOut\" "
   append command "\"$calibFileName\" "
   append command {$minOrder $maxOrder -merge 1 -objectimage $saveObjectImage }
   append command {-croplambda  $cropLambda }
   append command " -cosmicCleaning  \"$cosmicCleaning\" "

   #--- option pour diviser par la reponse instrumentale
   if { $responseFileName != "" } {
      append command "-responseFileName \"$responseFileName\" "
      append command "-responsePerOrder \"$responsePerOrder\""
   }

   #--- option pour exporter le profil FULL seul dans un autre fichier
   ###set fullOut [file join $dirOut "[file rootname $fileOut]-full[file extension $fileOut]"]
   ###append command "-exportfull $fullOut"

   puts $hfile $command
}

proc ::eshel::process::putDeleteFiles { hfile directory fileNames } {
   set command "      file delete"
   foreach fileName $fileNames {
      append command " \"[file join $directory $fileName]\""
   }
   puts $hfile $command
}

proc ::eshel::process::putMoveFiles { hfile dirIn dirOut fileNames } {
   set command "      file rename -force "
   foreach fileName $fileNames {
      append command " \"[file join $dirIn $fileName]\""
   }
   append command " \"$dirOut\""
   puts $hfile $command
}

#------------------------------------------------------------
# startScript
#  excute les traitements dans une thread dediee
#
# return
#   rien
#
proc ::eshel::process::startScript {  } {
   variable private

   set private(threadNo) ""
   set catchResult [catch {
      if { $private(running) == 0 } {
         set private(running) 1
         #--- je cree une thread
         set private(threadNo) [thread::create ]
         #--- je recupere le nom du fichier TCL contenant le script
         set fileName [file join $::conf(eshel,tempDirectory) $::conf(eshel,scriptFileName)]
         if { [file exists $fileName ] == 0 } {
            error $::caption(eshel,process,scriptNotFound)
         }
         #--- je lance le traitement
         ::thread::send -async $private(threadNo) [list uplevel #0 source \"$fileName\" ]
      } elseif { $private(running) == "stopping" } {
         #--- un arret a ete demande
         set private(running) 0
      } else {
         #--- un traitement est deja en cours
      }
      if { $::conf(eshel,processAuto) == 0 } {
         #--- je met a jour les boutons de la fenetre des traitements
         ::eshel::processgui::setFrameState
      }

   }]

   if { $catchResult == 1 } {
      #--- je supprime la thread
      if { $private(threadNo) != "" } {
         thread::release $private(threadNo)
      }
      set private(running) 0
      #--- j'active les widgets de la fenetre de traitement
      ::eshel::processgui::setFrameState
      #--- je remonte l'erreur a la procedure appelante
      error $::errorInfo
   }
}

#------------------------------------------------------------
# stopScript
#  interromp les traitements en cours
#
proc ::eshel::process::stopScript {  } {
   variable private

   if { $private(threadNo) != "" } {
      set private(running) "stopping"
      #--- j'envoie une demande d'arret a la thread
      ::thread::send -async $private(threadNo) "set stopScript 1"
      #--- je met a jour la fenetre des traitements
      ::eshel::processgui::setFrameState
   } else {
      #--- si la thread n'est pas encore d�marre
      set private(running) "stopping"
   }
}


#------------------------------------------------------------
# endScript
#  cette procedure est appellee par la thread des traitements
#  quand les traitements sont termin�s
#  si traitement manuel : regenere la roadmap
#  si traitement auto   : lance un nouveau traitement
#  Cette procedure est appelee a la fin d'un script
#
proc ::eshel::process::endScript {  } {
   variable private

   #--- je desactive le flag indiquant qu'un traitement est terminee
   set private(running) 0
   set private(threadNo) ""

   if { $::conf(eshel,processAuto) == 0 } {
      #--- mode manuel
      #--- j'autorise les commandes manuelles
      ::eshel::processgui::setFrameState
      #--- je regenere la roadmap , mais je ne fais pas les traitements
      ::eshel::process::generateAll
   } else {
      #--- mode automatique
      #--- je lance un nouveau cycle de traitements
      #--- Remarque: l'instruction after idle lance le traitement en mode asynchone,
      #--- permettant de ainsi l'arret de la thread precedente qui a lance endScript.
      after idle ::eshel::process::generateAll
   }
}

#------------------------------------------------------------
# getFileName
#  fabrique et retourne le nom d'un fichier en fonction de ses mots cles de la serie
#
#  exemples :
#   BIAS :        AAAAMMJJ-HHMMSS-BIAS.fit
#   DARK :        AAAAMMJJ-HHMMSS-DARK-ddd.fit
#   FLATFIELD :   AAAAMMJJ-HHMMSS-FLATFIELD-ddd.fit
#   FLAT :        AAAAMMJJ-HHMMSS-FLAT-ddd.fit
#   FLATFIELD :   AAAAMMJJ-HHMMSS-FLATFIELD-ddd.fit
#   CALIB :       AAAAMMJJ-HHMMSS-CALIB-ddd.fit
#   OBJECT :      AAAAMMJJ-HHMMSS-name-ddd.fit
#
#   avec AAAAMMJJ : annee, mois, jour
#        HHMMSS   : heure, minute, seconde
#        ddd  : temps de pose en seconde (avec les decimales si elle ne sont pas nulles)
#        name : nom de l'objet
#
# parameters:
#   serieNode : node de la serie
# return
#   fileName  : nom du fichier de la serie
#
proc ::eshel::process::getFileName { serieNode } {
   #--- je cree le déut du nom de fichier à partir du numero de serie
   set serieId [::dom::element getAttribute $serieNode "SERIESID"]
   set catchError [catch {
      #--- j'essaie de formater numero de serie sous la forme AAAAMMJJ-HHMMSS
      ### set dateList [mc_date2ymdhms $serieId]  ; # arrondi incorrect pour 2008-07-06T02:40:00.000
      scan $serieId "%d-%d-%dT%d:%d:%d" year month day hour minute second
      set fileName [format "%04d%02d%02d-%02d%02d%02d" $year $month $day $hour $minute $second ]
   }]
   if { $catchError != 0 } {
      #--- le formatage du numero de serie sous la forme AAAAMMJJ-HHMMSS a echoue
      #--- j'utilise le numero de serie sans formatage
      set fileName $serieId
   }

   set imageType [::dom::element getAttribute $serieNode "IMAGETYP"]
   set exptime [::dom::element getAttribute $serieNode "EXPOSURE"]
   #--- je supprime le point decimal si le temps de pose n'a pas de decimale
   if { [expr int($exptime) == $exptime] } {
      set exptime [expr int($exptime)]
   }
   set nbImage [llength [::dom::tcl::node children $serieNode]]

   switch $imageType {
      BIAS {
         #--- j'ajoute le type d'image
         append fileName "-BIAS"
         #--- j'ajoute le nombre d'images et le temps de pose
         append fileName "-${nbImage}x${exptime}s"
      }
      FLAT -
      FLATFIELD -
      LED -
      TUNGSTEN -
      CALIB -
      DARK {
         #--- j'ajoute le type d'image
         append fileName "-$imageType"
         #--- j'ajoute le nombre d'images et le temps de pose
         append fileName "-${nbImage}x${exptime}s"
      }
      OBJECT {
         set objectName [::dom::element getAttribute $serieNode "OBJNAME"]
         if { $objectName != "" } {
            #--- j'ajoute le nom de l'objet sans les espaces
            append fileName "-[string map { " " "" } $objectName]"
         } else {
            #--- j'ajoute le type d'image
            append fileName "-$imageType"
         }
         #--- j'ajoute le temps de pose
         append fileName "-${nbImage}x${exptime}s"
      }

   }
   #--- j'ajoute l'extension par defaut
   append fileName $::conf(extension,defaut)

   return $fileName
}

#------------------------------------------------------------
# findCompatibleImage
#   Recherche une image d'un type donne et avec les meme mot clefs
#
#   Si plusieurs images respectent ces critères, alors l'image retournée est:
#   - si le type d'image est "DARK"
#       celle qui a le temps d'exposition EXPOSURE le plus proche de celui de reference
#   - sinon pour les autres types d'images :
#       celle qui a la date DATE-OBS la plus proche de celle de reference,
#
# Parameters
#   referenceNode :     node de l'image de reference
#   searchedImageType : type d'image recherché
#   sameKeywordNames   :      liste des mots clefs servant de critère de recherche
#   staticKeywordNames :      liste des motcles avec des valeurs statiques requises (parametre optionnel)
# return
#   node de l'image la plus compatible ou "" si aucune image compatible n'a ete trouvee
#
proc ::eshel::process::findCompatibleImage { referenceNode searchedImageType sameKeywordNames { staticKeywordNames "" }} {
   variable private

   set refDateObs [::dom::element getAttribute $referenceNode "DATE-OBS"]
   set refExptime [::dom::element getAttribute $referenceNode "EXPOSURE"]
   set foundNode  ""
   set foundDiffExpTime ""
   set foundDiffDateObs ""
   set fileExptime ""

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]
   #--- je definis le pretraitement à faire sur les BIAS
   foreach fileNode [set [::dom::element getElementsByTagName $filesNode $searchedImageType ]] {
      #--- je compare les mots clefs
      set badKeyword ""
      foreach keywordName $sameKeywordNames {
         set referenceValue [::dom::element getAttribute $referenceNode $keywordName]
         set keywordValue [::dom::element getAttribute $fileNode $keywordName]
         if { $keywordName == "EXPOSURE" && $searchedImageType == "DARK" } {
            if { [expr $keywordValue > $referenceValue] } {
               append badKeyword "$keywordName "
            }
         } else {
            #--- les autres mots clefs doivent etre egaux
            if { $keywordValue != $referenceValue } {
               append badKeyword "$keywordName "
            }
         }
      }

      if {  $badKeyword != "" } {
         #--- ce fichier ne respecte pas les criteres de compatibilite,
         #--- je passe au fichier suivant
         continue
      }

      #--- je verifie les valeurs imposees
      set badKeyword ""
      foreach { keywordName staticValue } $staticKeywordNames {
         set keywordValue [::dom::element getAttribute $fileNode $keywordName]
         #--- les autres mots clefs doivent etre egaux
         if { $keywordValue != $staticValue } {
            append badKeyword "$keywordName "
         }
      }

      if {  $badKeyword != "" } {
         #--- ce fichier ne respecte pas les criteres de compatibilite,
         #--- je passe au fichier suivant
         continue
      }

      #--- je recupere la date d'observation ou le temps de pose
      if { $searchedImageType == "DARK" } {
         set fileExptime [::dom::element getAttribute $fileNode "EXPOSURE"]
      } else {
         set fileDateObs [::dom::element getAttribute $fileNode "DATE-OBS"]
      }

      if { $foundNode == "" } {
         if { $searchedImageType == "DARK" } {
            #--- c'est la premiere image compatible, je verifie si je peux prendre ...
            set diffExpTime [ expr $fileExptime - $refExptime]
            if { $diffExpTime >= 0  } {
               #--- le temps de pose est inférieur ou egal a celui du DARK, je prends ...
               set foundNode    $fileNode
               set foundDiffExpTime $diffExpTime
            } else {
               #--- le temps de pose est superieur , je ne prends pas.
            }
         } else {
            #--- c'est la premiere image compatible, je prends ...
            #--- remarque: la fonction abs() permet de prendre en compte les dates antérieures et/ou posterieures
            set foundNode    $fileNode
            set foundDiffDateObs  [ expr abs([mc_date2jd $refDateObs] - [mc_date2jd $fileDateObs]) ]
         }
      } else {
         #--- je verifie si l'image est plus compatible
         if { $searchedImageType == "DARK" } {
            #--- je recherche en priorite l'image qui a un temps de pose le plus proche de la reference
            set diffExpTime  [ expr $fileExptime - $refExptime ]
            if { $diffExpTime >= 0  } {
               if { $diffExpTime < $foundDiffExpTime } {
                  #--- le temps de pose est plus proche, je prends ...
                  set foundNode    $fileNode
                  set foundDiffExpTime $diffExpTime
               } else {
                  #--- le temps de pose n'est pas plus proche, je ne prends pas.
               }
            } else {
               #--- le temps de pose est superieur a la reference , je ne prends pas.
            }
         } else {
            #--- je compare la date
            set diffDateObs  [ expr abs([mc_date2jd $fileDateObs] - [mc_date2jd $refDateObs]) ]
            if { $diffDateObs < $foundDiffDateObs } {
               #--- la difference de date est plus petite, je prends ...
               set foundNode    $fileNode
               set foundDiffDateObs $diffDateObs
            }
         }
      }
   }

   return $foundNode
}


#------------------------------------------------------------
## @brief détecte les séries dans la rubrique FILES
#  @param nodeName ??
#  @todo commenter le param nodeName
#
proc ::eshel::process::findSeries { nodeName } {
   variable private

   set mainNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode [lindex [set [::dom::element getElementsByTagName $mainNode $nodeName ]] 0]

   foreach fileNode [::dom::tcl::node children $filesNode] {
      #--- je verifie la presence des mots clefs obligatoires
      set badKeywords ""
      set imageTyp  ""
      foreach keywordName $private(mandatoryKeywords) {
         set keywordValue [::dom::element getAttribute $fileNode $keywordName ]
         switch $keywordName {
            IMAGETYP {
               if { $keywordValue == "" } {
                  lappend badKeywords $keywordName
               } else {
                  set imageTyp $keywordValue
                  if { $imageTyp == "FLAT" } {
                     #--- je change le type FLAT en LED pour compatibilite ascendante
                     ###set imageTyp "LED"
                  }
               }
            }
            OBJNAME {
               #--- ce mot clef est obligatoire si IMAGETYP=OBJECT
               if { [::dom::element getAttribute $fileNode "IMAGETYP" ] == "OBJECT" && $keywordValue == "" } {
                  lappend badKeywords $keywordName
               }
            }
            default {
               if { $keywordValue == "" } {
                  lappend badKeywords $keywordName
               }
            }
         }
      }
      if { $badKeywords != "" } {
         #set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         #::console::affiche_resultat " nightlog::findSeries file=$fileName required keywords=$badKeywords\n"
         #--- je passe au fichier suivant
         continue
      }

      #--- je recupere le numero de serie du fichier
      set serieId [::dom::element getAttribute $fileNode "SERIESID" ]

      #--- je verifie que la serie n'est pas en cours d'acquisition
      if { $serieId == [::eshel::acquisition::getCurrentSeriesID ] } {
         continue
      }

      #--- je verifie si la serie existe deja parmi les fichiers
      set found 0
      foreach serieNode [::dom::tcl::node children $filesNode] {
         if { [::dom::tcl::node cget $serieNode -nodeName] == "FILE" } {
            continue
         }
         if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId } {
            set found 1
            break
         }
      }

      #--- je cree la serie si elle n'existe pas deja
      if { $found == 0 } {
         set serieNode  [::dom::document createElement $filesNode $imageTyp ]
         #--- j'ajoute le fichier dans la serie
         ###::dom::tcl::node appendChild $filesNode $serieNode

         ::dom::element setAttribute $serieNode "SERIESID" $serieId
         #--- je renseigne les attributs de la serie a partir des attibuts du fichier
         foreach keywordName $private(serieAttributes) {
            set keywordValue [::dom::element getAttribute $fileNode $keywordName]
            ::dom::element setAttribute $serieNode $keywordName $keywordValue
         }
         ::dom::element setAttribute $serieNode "RAW" 1
         #--- je deplace le fichier brut dans la serie
         ::dom::tcl::node appendChild $serieNode $fileNode
         #--- je renseigne le nom du fichier de la serie qui sera cree par le traitement
         #--- remarque : le nom doit etre calcule apres avoir insere le fichier dans la serie
         #---    afin de mettre a jour le nombre de fichier de la serie dans le nom
         ::dom::element setAttribute $serieNode "FILENAME" [getFileName $serieNode]

         #--- je renseigne le repertoire du fichier cree par le traitement
         switch $imageTyp {
            "BIAS" -
            "DARK" -
            "FLATFIELD" -
            "LED" -
            "TUNGSTEN" -
            "FLAT" -
            "CALIB" -
            "TUNGSTEN" {
               ::dom::element setAttribute $serieNode "DIRNAME" $::conf(eshel,referenceDirectory)
            }
            "OBJECT" {
               ::dom::element setAttribute $serieNode "DIRNAME" $::conf(eshel,processedDirectory)
            }
            "RESPONSE" -
            default {
               ::dom::element setAttribute $serieNode "DIRNAME" ""
            }
         }

      } else {
         #--- je verifie que les mots clefs du fichier sont identiques a ceux de la serie
         set badKeywords ""
         foreach keywordName $private(mandatoryKeywords) {
            switch $keywordName {
               DATE-OBS {
                  continue
               }
               default {
                  set fileKeywordValue [::dom::element getAttribute $fileNode $keywordName ]
                  set serieKeywordValue [::dom::element getAttribute $serieNode $keywordName ]
                  if { $fileKeywordValue != $serieKeywordValue } {
                     lappend badKeywords [list $keywordName $fileKeywordValue $serieKeywordValue "\n" ]
                 }
               }
            }
         }
         if { $badKeywords == "" } {
            #--- je deplace le fichier dans la serie
            ::dom::tcl::node appendChild $serieNode $fileNode
            #--- je renseigne DATE-OBS de la série avec celle du fichier si celle est inferieure
            set fileDateObs [::dom::element getAttribute $fileNode DATE-OBS ]
            set serieDateObs [::dom::element getAttribute $serieNode DATE-OBS ]
            if { [string compare $fileDateObs $serieDateObs] < 0 } {
               ::dom::element setAttribute $serieNode DATE-OBS $fileDateObs
            }
            #--- je met ajour le nom du fichier de la serie qui sera cree par le traitement
            #--- remarque : le nom doit etre calcule apres avoir insere le fichier dans la serie
            #---    afin de mettre a jour le nombre de fichier de la serie dans le nom
            ::dom::element setAttribute $serieNode "FILENAME" [getFileName $serieNode]
         }
      }
   }

   #--- je supprime les series qui n'ont qu'un seul fichier
   #foreach serieNode [::dom::tcl::node children $seriesNode] {
   #   set fileNodes [::dom::tcl::node children $serieNode]
   #   if { [llength $fileNodes] <= 1 } {
   #      foreach fileNode $fileNodes {
   #         #--- je supprime le fichier de la serie
   #         ::dom::tcl::node removeChild $serieNode $fileNode
   #         #--- j'ajoute le fichier dans la liste des fichiers non identifies
   #         ::dom::tcl::node appendChild $filesNode $fileNode
   #      }
   #      #--- je detruits la serie
   #      ::dom::tcl::node removeChild $seriesNode $serieNode
   #      ::dom::tcl::destroy $serieNode
   #   }
   #}
}

#------------------------------------------------------------
# makeSerie
#   fabrique une serie (ou complete une serie existant) avec les fichiers selectionnes pas l'utilisateur
#
#   les fichiers RAW sont dans le repertoire
#
proc ::eshel::process::makeSerie { fileNames  } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode  [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]

   #--- j'intialise des variables temporaires pour les attributs de la serie
   foreach keywordName $private(serieAttributes) {
      set temp($keywordName) ""
   }

   set fileNodes ""
   set errorMessage ""
   set dataObsMini ""
   foreach fileName $fileNames  {
      #--- je traite chaque fichier de la liste
      foreach fileNode [::dom::tcl::node children $filesNode] {
         if { [::dom::element getAttribute $fileNode "FILENAME"] == $fileName } {
            #--- je controle les mots clefs obligatoires
            foreach keywordName $private(mandatoryKeywords) {
               set keywordValue [::dom::element getAttribute $fileNode $keywordName ]
               switch $keywordName {
                  DATE-OBS {
                     if { $keywordValue == "" } {
                        #--- DATE-OBS est obligatoire pour chaque fichier
                        append errorMessage "$fileName : DATE-OBS is empty\n"
                     } else {
                        #---
                        if { $dataObsMini == "" } {
                           #--- j'utilise DATE-OBS comme identifiant de la série
                           set dataObsMini $keywordValue
                        } else {
                           if { [string compare $keywordValue $temp(SERIESID)] < 0 } {
                              #--- j'utilise DATE-OBS comme identifiant de la série
                              #--- si elle est plus petite que celle rencontre dans un autre fichier
                              set dataObsMini $keywordValue
                           }
                        }
                     }
                  }
                  default {
                     if { $keywordValue != "" } {
                        if { $temp($keywordName) == "" } {
                           #--- ce mot cle n'etait pas renseigne dans les attributs de la serie
                           set temp($keywordName) $keywordValue
                        } else {
                           if { $keywordValue != $temp($keywordName) } {
                              #--- le mot cle est different de celui de la serie deja retenu pour la serie
                              append errorMessage "$fileName: $keywordName=$keywordValue is different from $temp($keywordName)\n"
                            }
                        }
                     }
                  }
               }
            }
            #--- je memorise le node du fichier s'il n'y a pas eu d'erreur
            if { $errorMessage == "" } {
               lappend fileNodes $fileNode
            }
         }
      }
   }

   if { $errorMessage != "" } {
      error "Make series error(s): \n$errorMessage"
   }

   #--- je renseigne la date d'observation de la serie
   if { $temp(DATE-OBS) == "" } {
      set temp(DATE-OBS) $dataObsMini
   }

   #--- je renseigne le numero de serie avec la date mini s'il n'etait dans aucun des fichiers
   if { $temp(SERIESID) == "" } {
      set temp(SERIESID) $dataObsMini
   }

   #--- je verifie que les attributs de la serie sont tous renseignes
   foreach keywordName $private(serieAttributes) {
      switch $keywordName {
         FILES {
            #--- pas de controle à faire
         }
         OBJNAME {
            #--- je ne controle l'objet que si IMAGETYP = OBJECT
            if { $temp(IMAGETYP) == "OBJECT" } {
               if { $temp($keywordName) == "" } {
                  append errorMessage "No value found for $keywordName\n"
               }
            }
         }
         default {
            if { $temp($keywordName) == "" } {
               append errorMessage "No value found for $keywordName\n"
            }
         }
      }
   }

   if { $errorMessage != "" } {
      error "Make series error(s): \n$errorMessage"
   }

   #--- je verifie si la serie existe deja
   set serieId $temp(SERIESID)
   set found 0
   foreach serieNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId
           && [::dom::tcl::node cget $serieNode -nodeName] != "FILE"} {
         set found 1
         break
      }
   }

   if { $found == 0 } {
      #--- je cree la serie si elle n'existe pas
      set serieNode  [::dom::document createElement $filesNode $temp(IMAGETYP)]
      ::dom::element setAttribute $serieNode "RAW" 1

      #--- je renseigne les attributs de la serie
      foreach keywordName $private(serieAttributes) {
         ::dom::element setAttribute $serieNode $keywordName $temp($keywordName)
      }
      ###::dom::element setAttribute $serieNode "FILENAME" [getFileName $temp(SERIESID) $temp(IMAGETYP) $temp(OBJNAME)]
      #--- je renseigne le nom du fichier cree par le traitement
      ::dom::element setAttribute $serieNode "FILENAME" [getFileName $serieNode]
      #--- je reseigne le repertoire du fichier cree par le traitement
      switch $temp(IMAGETYP) {
         "BIAS" -
         "DARK" -
         "FLATFIELD" -
         "LED" -
         "TUNGSTEN" -
         "FLAT" -
         "CALIB" -
         "TUNGSTEN" {
            ::dom::element setAttribute $serieNode "DIRNAME" $::conf(eshel,referenceDirectory)
         }
         "OBJECT" {
            ::dom::element setAttribute $serieNode "DIRNAME" $::conf(eshel,processedDirectory)
         }
         "RESPONSE" -
         default {
            ::dom::element setAttribute $serieNode "DIRNAME" ""
         }
      }

   } else {
      #--- je verifie que les mots clefs des fichiers sont identiques a ceux de la serie
      foreach keywordName $private(serieAttributes) {
         switch $keywordName {
            "FILES" -
            "DATE-OBS" -
            "DATE-END"  {
               continue
            }
            default {
               set keywordValue [::dom::element getAttribute $serieNode $keywordName]
               if { $keywordValue != $temp($keywordName)
                  && [ ::dom::element getAttribute $serieNode "RAW" ] == 1 } {
                  ###append errorMessage "Serie already exist with $keywordName different from $temp($keywordName) \n"
                  append errorMessage [format $::caption(eshel,process,serieAlreadyExist) $serieId $keywordName $keywordValue $temp($keywordName) ]
                  append errorMessage " \n"
               }
            }
         }
      }
   }

   if { $errorMessage != "" } {
      error "Make series error(s): \n$errorMessage"
   }

   #--- je deplace les fichiers dans la serie
   foreach fileNode $fileNodes {
      #--- je deplace le fichier brut dans la serie
      ::dom::tcl::node appendChild $serieNode $fileNode
      #--- je copie les mots clefs dans le fichier pour uniformiser
      foreach keywordName $private(serieAttributes) {
         switch $keywordName {
            FILES {
               #--- on ne copie pas l'attribut FILES car ce n'est pas un attribut des fichiers
            }
            DATE-OBS {
               #--- on ne copie pas l'attribut DATE-OBS car chaque fichier conserve sa propre date
            }
            default {
               ::dom::element setAttribute $fileNode $keywordName $temp($keywordName)
            }
         }
      }
   }
}

#------------------------------------------------------------
## @brief déplace une série du répertoire archive vers le répertoire raw
#  @param serieId  identifiant de la série
#
proc ::eshel::process::moveArchiveToRaw { serieId } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set archiveNode  [lindex [set [::dom::element getElementsByTagName $nightNode "ARCHIVE" ]] 0]
   set filesNode  [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]
   foreach serieNode [::dom::tcl::node children $archiveNode] {
      if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId
         && [::dom::tcl::node cget $serieNode -nodeName] != "FILE" } {
         set fileNodes [::dom::tcl::node children $serieNode]
         #--- je deplace les fichiers de la serie dans le repertoire raw
         foreach fileNode $fileNodes {
            set fileName [::dom::element getAttribute $fileNode "FILENAME"]
            file rename -force [file join $::conf(eshel,archiveDirectory) $fileName] $::conf(eshel,rawDirectory)
         }
         #--- j'ajoute la serie dans le tag FILES (appendChild fait un deplacement)
         ::dom::tcl::node appendChild $filesNode $serieNode
      }
   }
}

#------------------------------------------------------------
## @brief déplace une série du répertoire raw vers le répertoire archive
#  @param serieId identifiant de la série
#
proc ::eshel::process::moveRawToArchive { serieId } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set archiveNode  [lindex [set [::dom::element getElementsByTagName $nightNode "ARCHIVE" ]] 0]
   set filesNode  [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]
   foreach serieNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId
         && [::dom::tcl::node cget $serieNode -nodeName] != "FILE" } {
         set fileNodes [::dom::tcl::node children $serieNode]
         #--- la serie doit avoir des children FILE
         if { [llength $fileNodes] > 0 } {
            #--- je deplace les fichiers de la serie dans le repertoire archive
            foreach fileNode $fileNodes {
               set fileName [::dom::element getAttribute $fileNode "FILENAME"]
               file rename -force [file join $::conf(eshel,rawDirectory) $fileName] $::conf(eshel,archiveDirectory)
            }
            #--- je deplace la serie dans le tag ARCHIVE (appendChild fait un deplacement)
            ::dom::tcl::node appendChild $archiveNode $serieNode
            #--- inutile de poursuivre
            break
         }
      }
   }
}

#------------------------------------------------------------
# unmakeSerie
#   défait une serie
#   Le fichiers de la serie sont deplaces dans la liste des
#   fichiers non identifies
#
proc ::eshel::process::unmakeSerie { serieId } {
   variable private

   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode  [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]
   foreach serieNode [::dom::tcl::node children $filesNode] {
      if { [::dom::element getAttribute $serieNode "SERIESID"] == $serieId
         && [::dom::tcl::node cget $serieNode -nodeName] != "FILE" } {
         set fileNodes [::dom::tcl::node children $serieNode]
         foreach fileNode $fileNodes {
            #--- je supprime le fichier de la serie
            ::dom::tcl::node removeChild $serieNode $fileNode
            #--- j'ajoute le fichier dans la liste des fichiers non identifies
            ::dom::tcl::node appendChild $filesNode $fileNode
            #--- j'indique que c'est un fichier brut
            ::dom::element setAttribute $fileNode "RAW" 1
         }
         #--- je detruits la serie
         ::dom::tcl::node removeChild $filesNode $serieNode
         ::dom::tcl::destroy $serieNode
      }
   }
}

#------------------------------------------------------------
# getFileAttribute
#   retourne la valeur d'attribut d'un fichier
#
proc ::eshel::process::getFileAttribute { fileNode attributeName } {
   variable private

   set result [::dom::element getElementsByTagName $fileNode $attributeName ]
   set attributeNode [lindex [set $result] 0]
   set textNode    [ ::dom::tcl::node cget $attributeNode -firstChild ]
   set attributeValue [ ::dom::tcl::node cget $textNode -nodeValue]

   return $attributeValue
}

#------------------------------------------------------------
# saveFile
#   sauve nightlog dans le fichier nightlog.xml dans tempDirectory
#
proc ::eshel::process::saveFile { { fileName "" } } {
   variable private

   if { $fileName == "" } {
      set fileName [file join $::conf(eshel,tempDirectory) nightlog.xml]
   }

   #--- j'enregistre
   set hfile [open "$fileName" w]
   puts $hfile [::dom::tcl::serialize $private(nightlog) -indent true ]
   close $hfile
}

#------------------------------------------------------------
# loadFile
#   charge un fichier nightlog
#
proc ::eshel::process::loadFile { fileName } {
   variable private

   #--- j'initialise le nightlog a vide
   if { $private(nightlog) != "" } {
      ::dom::tcl::destroy $private(nightlog)
   }
   #--- je charge le fichier existant
   set hfile [open $private(fileName) r]
   set data [read $hfile]
   close $hfile
   set private(nightlog) [::dom::tcl::parse $data]
}

#------------------------------------------------------------
# updateFileKeywords
#   met a jour les mots clefs dans les fichiers FITS
#
proc ::eshel::process::updateFileKeywords {  } {
   variable private

   #--- je mets à jour les mots clefs des fichiers des series
   set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]
   set filesNode [lindex [set [::dom::element getElementsByTagName $nightNode "FILES" ]] 0]
   foreach serieNode [::dom::tcl::node children $filesNode] {
      foreach fileNode [::dom::tcl::node children $serieNode] {
         set fileName [::dom::element getAttribute $fileNode "FILENAME"]
         set catchResult [catch {
            #--- je lis les mots clefs du fichier
            set fileKeywords [fitsheader [file join $::conf(eshel,rawDirectory) $fileName] ]
         }]
         if { $catchResult !=0 } {
            #--- j'ignore ce fichier car ce n'est pas un fichier FITS
            break
         }

         set modifiedKeywords ""
         foreach keywordName $private(mandatoryKeywords) {
            #--- je recupere la valeur initiale du mot clef
            set keywordInitialValue  ""
            foreach fileKeyword $fileKeywords {
               if { [lindex $fileKeyword 0] == $keywordName } {
                  set keywordInitialValue  [lindex $fileKeyword 1]
                  break
               }
            }

            #--- je recupere la nouvelle valeur du mot clef dans DOM
            set keywordNewValue [::dom::element getAttribute $fileNode $keywordName]

            #--- je compare les mots clefs initiaux avec les mots clefs
            if { $keywordNewValue != $keywordInitialValue } {
               #--- je stocke les mots clefs modifis dans une liste temporaire
               lappend modifiedKeywords [list $keywordName $keywordNewValue ]
            }
         }

         if { $modifiedKeywords != "" } {
            set bufNo [::buf::create ]
            buf$bufNo load [file join $::conf(eshel,rawDirectory) $fileName]
            foreach item $modifiedKeywords {
               set keywordName [lindex $item 0]
               set keywordNewValue [lindex $item 1]
               set keyword [buf$bufNo getkwd $keywordName]
               if { [lindex $keyword 0] == "" } {
                  #--- je cree le mot clef s'il n'existait pas dans le fichier
                  set keywordType [lindex [lindex $private(mandatoryKeywordsType) [lsearch $private(mandatoryKeywords) $keywordName ]] 1]
                  set keyword [list $keywordName $keywordNewValue $keywordType "" ""]
               } else {
                  #--- je met a jour la nouvelle valeur du mot clef
                  set keyword [list $keywordName "$keywordNewValue" [lindex $keyword 2] [lindex $keyword 3] [lindex $keyword 4]]
                  ##lreplace keyword  1 1 "\"$keywordNewValue\""
               }
               buf$bufNo setkwd $keyword
            }
            buf$bufNo save [file join $::conf(eshel,rawDirectory) $fileName]
            ::buf::delete $bufNo
         }
      }
   }
}

#------------------------------------------------------------
## @brief trace le résultat de la géneration de script dans la console et le fichier de log
#  @param processType  CALIB-PROCESS, OBJECT-PROCESS, ...
#  @param fileName     nom du fichier traite
#  @param status  etat du traitement
#    - todo    : le traitement est a faire
#    - running : le traitement est en cours
#    - done    : le traitement est termine correctement.
#    - error   : le traitemnt avec des erreurs
#  @param infoMessage message d'information
#  @private
#
proc ::eshel::process::logGenerateProcess { processType fileName status infoMessage  } {
   variable private

   if { $status != "error" } {
      logInfo "$::caption(eshel,process,preparation) $processType : $fileName "
      foreach errorItem $infoMessage {
         logInfo "        $errorItem"
      }
   } else {
      logError "Error $processType process $fileName"
      foreach errorItem $infoMessage {
         logError "        $errorItem"
      }
   }
}


#------------------------------------------------------------
## @brief race les étapes de traitement dans la console et dans le fichier de log
#  @details Cette procédure est appellée par la thread des traitements.
#  Elle utilise les procedures logInfo et logError
#  @param processType  CALIB-PROCESS, OBJECT-PROCESS
#  @param fileName     nom du fichier traité
#  @param status       état du traitement
#    - running : le traitement est en cours
#    - done    : le traitement est terminé correctement.
#    - error   : le traitemnt avec des erreurs
#  @param message message optionnel en complément du status
#  @private
#
proc ::eshel::process::logStep { processType fileName status { message  "" }} {
   variable private


   #--- je met a jour le status dans la roadmap
   set roadmapNode [::eshel::process::getRoadmapNode]
   foreach processNode [::dom::tcl::node children $roadmapNode] {
      if { $fileName == [::dom::element getAttribute $processNode FILENAME ] } {
         ::dom::element setAttribute $processNode "STATUS" $status
         #--- je met a jour le status dans la fenetre
         ::eshel::processgui::setProcessStatus $fileName $status
         break
      }
   }

   switch $status {
      "running" {
         #--- j'affiche une trace dans la console et le fichier de log
         if { $status != "error" } {
            logInfo "$::caption(eshel,process,processing) $processType : $fileName"
            foreach errorItem $message {
               logInfo "        $errorItem"
            }
         } else {
            logError "Error $processType : $fileName"
            foreach errorItem $message {
               logError "        $errorItem"
            }
         }
      }
      "done" {
         if { $processType == "CALIB-PROCESS" } {
            #--- j'affiche le resultat de la calibration dans les traces
            ::eshel::process::logCalibrationResult $fileName
         }
         if { $processType == "OBJECT-PROCESS" && $::conf(eshel,showProfile) == 1 } {
            #--- j'affiche le profil dans une nouvelle fenetre
            ::eshel::showObjectProfile $fileName
         }
      }
      "error" {
         #--- j'affiche un message d'erreur dans la console et le fichier de log
         logError $message
      }
   }
}

#-------------------------------------------------
## @brief trace le résultat de la calibration dans la console et le fichier de log
#  @param fileName nom du fichier calibré
#  @private
#
proc ::eshel::process::logCalibrationResult { fileName  } {
   variable private

   set hFile ""
   set catchResult [catch {
      #--- j'ouvre le fichier en mode lecture
      set hFile [fits open [file join $::conf(eshel,referenceDirectory) $fileName] 0]
      set found 0
      set nbHdu [$hFile info nhdu]
      for { set i 1 } { $i <= $nbHdu && $found == 0 } { incr i } {
         $hFile move $i
         if { $i == 1 } {
            set hduName  "PRIMARY"
         } else {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         }
         if { $hduName == "ORDERS" } {
            set found  1
         }
      }

      if { $found == 0 } {
         error "ORDERS hdu not found"
      }
      #--- je recupere
      set numOrder         [$hFile get table "order"]
      set rmsOrder         [$hFile get table "rms_order"]
      set centralOrder     [$hFile get table "central"]
      set rmscalOrder      [$hFile get table "rms_cal"]
      set resolutionOrder  [$hFile get table "resolution"]
      set nbLineOrder      [$hFile get table "nb_lines"]
      $hFile close
      set hFile ""

      set nbOrder [llength $numOrder]
      set message "$::caption(eshel,process,calibrationResult) $fileName \n"
      append message " ORDER  RMS       CENTRAL   RMS-CAL RESOLUTION NB LINE\n"
      set htmlMessage $message

      set messageFormat " %s    %s     %s     %s       %s       %s\n"
      set htmlFormat "&nbsp %s &nbsp&nbsp&nbsp&nbsp&nbsp %s &nbsp&nbsp %s &nbsp&nbsp %s &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp %s &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp %s<BR>"

      for {set i 0 } { $i < $nbOrder } { incr i } {
         append message  [format  $messageFormat [lindex [lindex $numOrder $i] 0] [lindex [lindex $rmsOrder $i] 0] [lindex $centralOrder $i] [lindex [lindex $rmscalOrder $i] 0] [lindex [lindex $resolutionOrder $i] 0] [lindex [lindex $nbLineOrder $i] 0] ]
         append htmlMessage [format  $htmlFormat [lindex [lindex $numOrder $i] 0] [lindex [lindex $rmsOrder $i] 0] [lindex $centralOrder $i] [lindex [lindex $rmscalOrder $i] 0] [lindex [lindex $resolutionOrder $i] 0] [lindex [lindex $nbLineOrder $i] 0] ]
      }

      ::console::disp  "eShel-process: $message"
      ::eshel::logFile "eShel-process: $htmlMessage" "#0000FF"
      #--- je purge la console
      if { [$::audace(Console).txt1 index end] > 1000 } {
         $::audace(Console).txt1 delete 1.0  100.0
      }
   } ]

   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult !=0 } {
      error $::errorInfo
   }

}

#-------------------------------------------------
## @brief retourne 3 listes de d'informations
#  - la liste des numéros des ordres trouvés
#  - la liste des rms de calibration géométrique
#  - la liste des longueurs d'onde centrales
#  @param fileName nom du fichier FLAT
#  @return numOrderList rmsOrderList centralOrderList
#  @private
#
proc ::eshel::process::getFlatInfo { fileName } {
   variable private
   set hFile ""
   set catchResult [catch {
      #--- j'ouvre le fichier en mode lecture
      set hFile [fits open $fileName 0]
      set found 0
      set nbHdu [$hFile info nhdu]
      for { set i 1 } { $i <= $nbHdu && $found == 0 } { incr i } {
         $hFile move $i
         if { $i == 1 } {
            set hduName  "PRIMARY"
         } else {
            set hduName [string trim [string map {"'" ""} [lindex [lindex [$hFile get keyword "EXTNAME"] 0] 1]]]
         }
         if { $hduName == "ORDERS" } {
            set found  1
         }
      }

      if { $found == 0 } {
         error "ORDERS hdu not found"
      }
      #--- je recupere
      set numOrderList         [$hFile get table "order"]
      set rmsOrderList         [$hFile get table "rms_order"]
      set centralOrderList     [$hFile get table "central"]
      $hFile close
      set hFile ""
   } ]

   if { $hFile != "" } {
      $hFile close
   }

   if { $catchResult !=0 } {
      error $::errorInfo
   }

   return [list $numOrderList $rmsOrderList $centralOrderList]
}
#------------------------------------------------------------
## @brief trace une information dans la console et dans le fichier de trace
#  @param message message d'information
#  @private
#
proc ::eshel::process::logInfo { message  } {
   variable private

   #--- j'ajoute la trace dans la console
   ::console::disp "eShel-process: $message\n"
   #--- je purge la console s'il y a plus de 1000 lignes
   if { [$::audace(Console).txt1 index end] > 1000 } {
      $::audace(Console).txt1 delete 1.0  100.0
   }
   #--- j'ajoute la trace dans le fichier de trace
   ::eshel::logFile "eShel-process: $message\n" "#0000FF"
}

#------------------------------------------------------------
## @brief  trace une erreur dans la console et dans le fichier de trace
#  @param message message d'erreur
#  @private
#
proc ::eshel::process::logError { message  } {
   variable private

   #--- j'ajoute l'erreur dans la console
   ::console::affiche_erreur "eShel-process: $message\n"
   #--- je purge la console s'il y a plus de 1000 lignes
   if { [$::audace(Console).txt1 index end] > 1000 } {
      $::audace(Console).txt1 delete 1.0  100.0
   }
    #--- j'ajoute l'erreur dans le fichier de trace
   ::eshel::logFile "eShel-process: $message\n" "#FF0000"
}

#------------------------------------------------------------
## @brief trace de debug dans la console et dans le fichier de trace
#  @param message message d'erreur
#  @private
#
proc ::eshel::process::logDebug { message  } {
   variable private

    #--- j'ajoute l'erreur dans le fichier de trace
   ::eshel::logFile "eShel-process: $message\n" "#000000"
}











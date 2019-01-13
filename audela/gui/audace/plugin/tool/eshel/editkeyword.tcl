#
## @file editkeyword.tcl
#  @brief fenêtre de saisie des mots clefs
#  @author Michel Pujol
#  $Id: editkeyword.tcl 13602 2016-04-04 12:38:40Z rzachantke $
#

## namespace eshel::editkeyword
#  @brief fenêtre de saisie des mots clefs

namespace eval ::eshel::editkeyword {
   variable private

}

#------------------------------------------------------------
#  affiche la fenetre d'edition des mots cles
# return
#   1 si la saisie est validee
#   0 si la saisie est abandonne

proc ::eshel::editkeyword::run { tkbase visuNo fileName } {
   variable private

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,editkeywordPosition) ] } { set ::conf(eshel,editkeywordPosition)     "650x240+100+15" }


   set modifiedKeywords ""
   set private($visuNo,fileName) $fileName
   set private($visuNo,types,$keywordName)  ""
   set private($visuNo,fileKeywords) ""

   #--- je recupere les mots clefs du fichier
   set catchResult [ catch {
      set private($visuNo,fileKeywords) [fitsheader [file join $::conf(eshel,rawDirectory) $fileName] ]
      foreach fileKeyword $private($visuNo,fileKeywords) {
         set keywordName [lindex $fileKeyword 0]
         set keywordValue [lindex $fileKeyword 1]
         set private($visuNo,values,$keywordName) $keywordValue
      }
   }]
   if { $catchResult !=0 } {
      #--- j'affiche le message d'erreur
      ::tkutil::displayErrorInfo [::eshel::editkeyword::getLabel]
      return
   }

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.editkeyword"
   set result [::confGenerique::run $visuNo $private($visuNo,This) "::eshel::editkeyword" \
      -modal 0 -geometry $::conf(eshel,editkeywordPosition) -resizable 1 ]
}

#------------------------------------------------------------
# ::eshel::editkeyword::getLabel
#   retourne le titre de la fenetre
#
proc ::eshel::editkeyword::getLabel { } {
   global caption

   return "$caption(eshel,title) - $::caption(eshel,process,editKeyword)"
}


#------------------------------------------------------------
## @brief enregistre la valeur des widgets
#  @return 0 en cas d'erreur pour ne pas fermer la fenêtre
#
proc ::eshel::editkeyword::cmdApply { visuNo } {
   variable private

   #--- je controle les valeurs de mots clefs obligatoires (mandatoryKeywords)
   set badKeywords ""

   if { $badKeywords != "" } {
      tk_messageBox -message  "$::caption(eshel,process,nullKeyword) : $badKeywords" -icon error -title $::caption(eshel,title)
      #--- j'arrete le traitement et retourne 0 pour empecher la fermeture de la fenetre
      return 0
   }

   set modifiedKeywords ""
   foreach keywordPath [array names private $visuNo,values,*] {
      set keywordName [lindex [split $keywordPath "," ] 2]
      set keywordValue $private($visuNo,values,$keywordName)
      #--- je recupere la valeur initiale du mot clef
      set keywordInitialValue  ""
      foreach fileKeyword $private($visuNo,fileKeywords) {
         if { [lindex $fileKeyword 0] == $keywordName } {
            set keywordInitialValue  [lindex $fileKeyword 1]
            break
         }
      }
      #--- je compare les mots clefs initiaux avec les mots clefs
      if { $keywordValue != $keywordInitialValue } {
         #--- je stocke les mots clefs modifies dans une liste temporaire
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
         }
         buf$bufNo setkwd $keyword
      }
      buf$bufNo save [file join $::conf(eshel,rawDirectory) $fileName]
      ::buf::delete $bufNo
   }


   set private($visuNo,clo) "ok"
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
proc ::eshel::editkeyword::cmdClose { visuNo } {
   variable private

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,editkeywordPosition) [ wm geometry $private($visuNo,This) ]

   array unset private
   #--- on peut fermer la fenetre
   return 1
}

#------------------------------------------------------------
# config::fillConfigPage
#   cree les widgets de la fenetre de configuration
#
proc ::eshel::editkeyword::fillConfigPage { frm visuNo } {
   variable private

   #--- premiere passe pour recenser les valeurs existantes
   foreach fileIndex $private(fileIndexes)  {
      foreach keywordName $private(mandatoryKeywords) {
         set keywordValue [$private(tkTable) cellcget $fileIndex,$keywordName -text]
         switch $keywordName {
            DATE-OBS {
               #--- j'utilise DATE-OBS comme identifiant de la s�rie
               if { $private(selected,SERIESID) == "" } {
                  #--- je prends la premiere valeur de DATE-OBS renceontree
                  set private(selected,SERIESID) $keywordValue
               } else {
                  if { [string compare $keywordValue $private(selected,SERIESID)] < 0 } {
                     #--- si elle est plus petite que celle rencontre dans un autre fichier
                     set private(selected,SERIESID) $keywordValue
                  }
               }
            }
            default {
               if { $keywordValue != "" } {
                  if { [lsearch $private($visuNo,values,$keywordName) $keywordValue] == -1  }  {
                     lappend private($visuNo,values,$keywordName) $keywordValue
                  }
               }
            }
         }
      }
   }


   #--- j'affiche les valeurs dans les combobox
   Label $frm.title -text $::caption(eshel,process,keywordValues)  -justify left
   grid $frm.title -in $frm -row 0 -column 0 -columnspan 3 -sticky w
   set row 1
   foreach keywordName $private(mandatoryKeywords) {
      if { $keywordName == "DATE-OBS" } {
         #--- je n'affiche pas DATE-OBS
         continue
      }
      #--- je cree la combobox avec les valeurs du mots clefs
      ComboBox $frm.combo$keywordName \
         -height [ llength $private($visuNo,values,$keywordName) ] \
      -relief sunken -borderwidth 1 -editable 1 \
         -textvariable ::eshel::editkeyword::private(selected,$keywordName) \
      -values $private($visuNo,values,$keywordName)
      $frm.combo$keywordName setvalue "@0"
      Label $frm.color_invariant_$keywordName -text $keywordName  -justify left
     grid $frm.color_invariant_$keywordName -in $frm -row $row -column 0 -sticky nw
      grid $frm.combo$keywordName -in $frm -row $row -column 1 -sticky nw

      #--- ajoute un bouton les mots clefs qui possedent une valeur par defaut dans la configuration instrument
      switch $keywordName {
         INSTRUME -
         TELESCOP -
         DETNAM {
            Button $frm.button$keywordName -text "current instrument" \
               -command "::eshel::editkeyword::getCurrentInstrumentValue $visuNo $keywordName"
            grid $frm.button$keywordName -in $frm -row $row -column 2  -sticky nw
         }
      }
      grid columnconfig $frm $row -weight 1
      incr row
   }
   grid rowconfig $frm 0 -weight 0
   grid rowconfig $frm 1 -weight 0
   grid rowconfig $frm 2 -weight 0
}

#------------------------------------------------------------
# getCurrentInstrumentValue
#   recupere la valeur de la configuration instrument courante
#
proc ::eshel::editkeyword::getCurrentInstrumentValue { visuNo keywordName } {
   variable private

   switch $keywordName {
      DETNAM {
         set private(selected,DETNAM)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),cameraName)
      }
      INSTRUME {
         set private(selected,INSTRUME)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),spectroName)
      }
      TELESCOP {
         set private(selected,TELESCOP)  $::conf(eshel,instrument,config,$::conf(eshel,currentInstrument),telescopeName)
      }
   }

}


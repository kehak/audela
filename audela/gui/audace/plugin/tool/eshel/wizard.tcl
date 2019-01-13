#
## @file wizard.tcl
#  @brief Assistant pour le réglage des paramètres de traitement
#  @author Michel PUJOL
#  $Id: wizard.tcl 13445 2016-03-20 15:37:54Z rzachantke $

## namespace eshel::wizard
#  @brief Assistant pour le réglage des paramètres de traitement

#
# Etapes :
#   selectLed
#   selectMargin
#   selectThar
#   selectRefLine
#   selectJoinMargin
#   done
#

namespace eval ::eshel::wizard {

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
#
proc ::eshel::wizard::run { tkbase visuNo } {
   variable private

   global caption
   set caption(eshel,wizard,title)                             "Assistant de configuration eShel"
   set caption(eshel,wizard,step)                              "Etape"
   set caption(eshel,wizard,next)                              "Next >"

   set caption(eshel,wizard,description)                       "Assistant de configuration"
   set caption(eshel,wizard,masterImage)                       "Ouvir un fichier ou acquérir une image"
   set caption(eshel,wizard,ledFileName)                       "Image LED"
   set caption(eshel,wizard,tharFileName)                      "Image THAR"
   set caption(eshel,wizard,infoFile)                          "L'image sélectionnée: %s \nVous pouvez passer à l'étape suivante."

   set caption(eshel,wizard,errorFileType)                     "Erreur: %s n'est pas une image %s"
   set caption(eshel,wizard,errorFileLoad)                     "Erreur de chargement de l'image %s.\nVoir le détail dans la console."
   set caption(eshel,wizard,errorFileNotFound)                 "Image non trouvées"
   set caption(eshel,wizard,errorFileNotSelected)              "Aucune image sélectionnée"
   set caption(eshel,wizard,errorFileSize)                     "Erreur: la taille de l'image %s (%s) est différente de la taille de la configuration courant (%s)"
   set caption(eshel,wizard,errorLedFile)                      "L'image %s n'est pas une image LED.\nLe mot clé IMAGETYP vaut %s"
   set caption(eshel,wizard,errorTharFile)                     "L'image %s n'est pas une image THAR.\nLe mot clé IMAGETYP vaut %s"
   set caption(eshel,wizard,imageTypeNotFound)                 "Le mot clé IMAGETYP est absent dans l'image %s.\n Voulez-vous quand même continuer à vos risques et péril ?"

   set caption(eshel,wizard,selectMargin,title)                "Marges et rotation de la caméra"
   set caption(eshel,wizard,selectMargin,action)               "- Vérifier que les marges de tous les ordres sont bien détectées. Diminuer le seuil de détection si certaines lignes n'ont pas de marge. Il vaut mieux qu'il ait trop d'ordres que pas assez, les ordres défectueux seront éliminés dans les prochaines étapes.\n- Ajuster l'orientation de la caméra de manière à approcher la ligne verticale en trait plein de ligne verticale en pointillé centre de l'image (à quelques pixels près).\n- Régler la mise au point de la caméra pour minimiser la FWHM des ordres au centre de l'image."
   set caption(eshel,wizard,orderDetection)                    "Détection des ordres"
   set caption(eshel,wizard,marginDetection)                   "Détection des marges"
   set caption(eshel,wizard,snnoise)                           "Coefficient signal / bruit"
   set caption(eshel,wizard,minOrder)                          "Premier ordre"
   set caption(eshel,wizard,maxOrder)                          "Dernier ordre"
   set caption(eshel,wizard,refresh)                           "Rafraichir"

   set caption(eshel,wizard,selectRefLine,title)               "Identification de la raie de référence"
   set caption(eshel,wizard,selectRefLine,action)               "Vérifier que la position de la raie de référence a été trouvée.\nSi elle n'est pas trouvée, ajuster la FWHM moyenne en s'aidant des mesures des raies avec le menu Analyse>Fwhm, ou bien refaire une image avec un temps de pose plus long."

   set caption(eshel,wizard,selectJoinMargin,title)            "Réglage des marges de recouvrement"
   set caption(eshel,wizard,selectJoinMargin,action)           "Le recouvrement des ordres est représenté par les lignes parallèles aux ordres (le recouvrement par l'ordre supérieur apparaît à droite, le recouvrement par l'ordre inférieur apparaît à gauche).\n\nRégler la largeur des marges d'aboutement délimitées par les lignes jaunes en pointillé de façon à ne pas trop utiliser l'extrémité des ordres de faible intensité."
   set caption(eshel,wizard,selectJoinMargin,width)            "Largeur des marges d'aboutement (Angtrom)"

   set caption(eshel,wizard,showLine)                          "Options d'affichage"
   set caption(eshel,wizard,showLineLabel)                     "Afficher les numéros des lignes"
   set caption(eshel,wizard,showLineDraw)                      "Afficher le tracé des lignes"
   set caption(eshel,wizard,showCameraAxis)                    "Afficher l'axe de la caméra"
   set caption(eshel,wizard,showAllOrderLine)                  "Tracé complet"
   set caption(eshel,wizard,openFile)                          "Ouvrir un fichier"
   set caption(eshel,wizard,goAcq)                             "GO ACQ"

   set caption(eshel,wizard,parameters)                        "Paramètres"
   set caption(eshel,wizard,threshin)                          "Seuil de détection des raies (ADU)"
   set caption(eshel,wizard,fwhm)                              "FWHM moyenne des raies (pixels)"


   #--- icone pour ouvrir
   set private(redIcon) [image create photo redIcon -data {
      R0lGODlhFAA2AOeMAAAAAAIAAAMAAAEBAQUAAAcAAAgAAAICAgMDAxEAABMA
      ABQAAAUFBRsAAAYGBh0AAB8AACAAAAcHByIAACQAAAgICCoAAAkJCSwAAAoK
      CjIAADgAAAwMDDsAAA0NDQ4ODhAQEBERERISElkAABMTE1sAAF0AABQUFBUV
      FWQAAGUAABYWFmwAABcXFxkZGXcAAHkAAHoAABoaGn4AABsbG4AAAIIAAIkA
      AIsAAIwAAJQAAJUAAJoAAJsAACEhIZ4AACIiIqQAACMjIyQkJCUlJSYmJrUA
      ACcnJ7oAACgoKCsrKy0tLdsAANwAAN0AAOEAADAwMOQAADExMegAAOwAAO4A
      ADMzM/sAAPwAAP0AADY2Nv4AAP8AADc3Nzk5OTo6Ojs7Oz09PT4+Pj8/P0FB
      QUJCQkNDQ0VFRUZGRklJSUpKSktLS01NTVBQUFJSUlNTU1xcXF5eXl9fX2Bg
      YGJiYmRkZGVlZWlpaWpqamxsbG1tbW9vb3FxcXJycnNzc3R0dHV1dXZ2dnh4
      eHl5eXp6ent7e3x8fH19fX5+fn9/f4CAgIGBgf//////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      /////////////////////yH5BAEKAP8ALAAAAAAUADYAAAj+AP/9A0CwoMGD
      AAQORMjQ4MKGEBkGmDACRowSFAREBJAABpMrXLhccTJDAcQEP0CGXIklyIKG
      MbCsnMkli40ACCk0oUnziQWEJmTyXLlFBcIaQ2neQGgj6UwcCFNkcRqSBUIM
      UahO0YBQQA6qOggwbGAkKRIIEB/soDKzCo8IGwtseMGjB4wOBjbq3cu34AAO
      J05wOKB3gIs0dwABurNGxgCIA5bsWaSosqJFfKA8Zjjkj6JEoEMrCnSE4QU5
      i0KrTrSITgaEQgitXm2o9EEwn2eLHoOwTGrdoBehQfglN3BFYhACGQQcdCEi
      CCvA+T170ZwLDH30oR560Z8hEJOr5LFceZEeJZsbojBThw8fO2dW7B1wAQSI
      C+n76t9PkIGPMm+8YQYQDGwUQhuCLKLgIoO4QQJEIMRR2WqKzCECQwekYRyF
      bCCAUAt+bKiaIoDQgJAVzYXWBUJkcFfdGQiN4eJqi5iB0BKHpIiIFAiFMN5x
      ezxIHCLAIRJGQxKocQh3iiDCRgUQOdDFHYVUZggeXkiglwdFaKHFER/kx59D
      /Cmkn0JopqkmmgEBADs=
   }]

   set private(orangeIcon) [image create photo orangeIcon -data {
      R0lGODlhFAA2AOeWAAAAAAEBAAEBAQICAgMDAAMDAwQEBAUFAAUFBQYGAAYG
      BgcHBwgIAAkJAAkJCQoKAAoKCgsLAAwMDA0NAA4OAA8PAA4ODhERABAQEBIS
      EhQUABMTExYWABUVFRYWFhgYABcXFxoaABoaGh4eAB8fAB4eHh8fHyIiACAg
      ICEhISMjIyYmACQkJCoqACcnJysrACgoKCkpKSsrKzAwAC0tLS4uLjAwMDY2
      ADMzMzc3ADQ0NDY2Njs7ADg4ODk5OT8/ADs7O0FBAD4+PkBAQEhIAEREREVF
      RUpKSktLS1NTAE9PT1BQUFFRUVJSUlNTU1RUVFVVVVdXV1hYWFpaWlxcXF1d
      XV5eXmJiYmpqAGNjY2RkZGVlZWdnZ2hoaG1tbXZ2AHBwcHFxcXJycnNzc3x8
      AHV1dX9/AHd3d3h4eIKCAHl5eXp6ent7e3x8fIaGAH19fYeHAH5+fn9/f4CA
      gIuLAIGBgY+PAJCQAKOjAK+vALe3ALq6ALy8AL29AL+/AMDAAMPDAMTEAM3N
      AM7OANHRANbWAN3dAN7eAOXlAObmAOnpAOzsAO/vAPDwAPT0APj4APr6APv7
      APz8AP39AP7+AP//AP//////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      /////////////////////yH5BAEKAP8ALAAAAAAUADYAAAj+AP8JBECwoMGD
      Av8dXMhwIMOHBRUehMDChxAdIgwslEhwQIwra+bUkVOGiQeEBQXoODNSjkuR
      XEQY5JiizByXOF3WsQIhIsECT1rmxBnHhk8AG8LcHIqzjpMBBCWaWMM0Zx0t
      CqISNMGmatMtC7QC6DBmadU6UQqIRTBFaNUdRwHAUGPW6hYLcQsMaVNXTh0w
      KmYaRLDDi986ddpYQYHSoIAMOI4oKQLDwUaImDlivnwwQIUVL0gwaHgwxJdA
      iBYZypOkQWOCM/5MqkSbtqM7FwQTHAGotu9KkuAciJvm9+9FP45+IGT8t52j
      ORo19+3ngdggj6bXFkRB7A1G2mnZ97EOQCKHQeEr0YlLhpJ2RTzihuAzHZIZ
      AnEBtNAT6XcjNxPoVpAGWOxxSCKF4EFEAq8ZFMEIJ3wwHGebUVihgAQJ4IEP
      S0BxBA0SWKgAEGCIhNgbWbAggIAGGPFGX3WI4YKAMoR0VhcYHKUAFW4x1cNR
      HpTllV9SqFUeQSh0NWQdYIlVAlVLZpHVkQBkUOKSTUBFZQFN9JjTGzXEVYKQ
      TNUxhWViASCADWW4JVIWIGAoAAtVoCHHHHGIgUQGDRK0gAk49FCDB0ZieGGa
      h5aXUKIJNeroo40GBAA7
   }]


   set private(greenIcon) [image create photo greenIcon -data {
      R0lGODlhFAA2AOeNAAAAAAABAAEBAQACAAICAgADAAMDAwAFAAQEBAAGAAUF
      BQAHAAYGBgcHBwkJCQoKCgsLCwAQAAwMDAARAA0NDQ4ODg8PDwAVAAAWABER
      EQAZABISEgAaABMTEwAdABUVFRYWFhcXFxgYGAAkAB0dHR8fHyEhISIiIgA2
      ACcnJwA3ACgoKCoqKgA8AAA/AC4uLi8vLzAwMDExMQBGAABHADMzMzU1NTY2
      Njc3NwBPAABSADs7Ozw8PD09PQBWAEBAQEFBQQBbAABcAEJCQkNDQwBfAEdH
      R0hISEtLSwBqAExMTE1NTU5OTk9PTwBvAFBQUFFRUQB1AFVVVVZWVldXVwB7
      AFlZWV1dXQCDAACFAGBgYGJiYmRkZACMAACNAGVlZQCQAGdnZ2hoaGlpaWtr
      a2xsbG1tbQCZAHBwcHJycnNzc3R0dHV1dQCkAHZ2dgCpAHl5eXp6ent7ewCt
      AHx8fH19fX5+fn9/f4CAgACzAIGBgQC3AADAAADIAADSAADWAADeAADrAADu
      AADwAADyAADzAAD1AAD2AAD3AAD6AAD8AAD+AAD/AP//////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
      /////////////////////yH5BAEKAP8ALAAAAAAUADYAAAj+AP8JBECwoMGD
      Av8dXMhwIMOHEAFQWLGjhwwQBCICUFBDDB08euykOWIBIgIgdPTcWXkHD54r
      GR6+kIOHpU09TxAsdLBFpU2WeOCYWFgCzs+feogsfHEUqRQBB2E0vTkFqsET
      caau1GNkoYQwPpvKScEQR52peqw0YNhgiZ2aN8OIgOjgR5o7evQEnRJCI4EQ
      OJQw+XGCgcbDiBMXFPCgw4cKBhBvGPJlDZsyUExkhHhCDEiXIN3w0MlQRJmw
      QOXYYGjgCWqbeMx0WAhCDdypOBayOKsV58IYt5vqoWK14G6teJss/JAm+NHV
      BwkweQ2UzAaGIMZQxxNHBkQSXD6wu9Sj5kZkiBZ4aEGTRgwSEsUjNrCQAUJ8
      xfgJBlB8QEWVNm94kUMEGmHQRSCMJMgIInugANEEbSyi4IR/qPBQFIpMqOEe
      BB7EgR8aaoiIDgvRcEiIGoKxUBEoajjHAAcJIWGLCb4Bo0EtDEJjglgsFAEf
      OwriAkM+EELjGQswlEAVhYS4SB4eQLRAEH0YkmAigGShwWEXzJCEEz6MUMBC
      CuUHQJn4JYTmYWq26eabAQEAOw==
   }]

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists ::conf(eshel,wizard,windowPosition) ] } { set ::conf(eshel,wizard,windowPosition)     "650x240+350+15" }

   #set private($visuNo,ledFileName)  "C:/Documents and Settings/michel/Mes documents/Astronomie/testaudela/20100718-220000-FLAT-1x60s.fit"
   #set private($visuNo,tharFileName) "C:/Documents and Settings/michel/Mes documents/Astronomie/testaudela/20100718-221500-CALIB-1x30s.fit"
   #set private($visuNo,ledFileName)  "C:/Documents and Settings/michel/Mes documents/Astronomie/testaudela/20090819-213927-FLAT-3x5s.fit"
   #set private($visuNo,tharFileName) "C:/Documents and Settings/michel/Mes documents/Astronomie/testaudela/20090819-211516-CALIB-3x30s.fit"
   set private($visuNo,ledFileName)  ""
   set private($visuNo,tharFileName) ""

   set private($visuNo,ledWizardName) "$::conf(eshel,tempDirectory)/led-wizard.fit"
   set private($visuNo,tharWizardName) "$::conf(eshel,tempDirectory)/thar-wizard.fit"
   set private($visuNo,selectRefLineFileName) "$::conf(eshel,tempDirectory)/wizard-selectRefLine.fit"

   #--- je recupere les parametres de la configuration courante
   set configId [::eshel::instrument::getCurrentConfigId]
   ###::eshel::instrument::setCurrentConfig $configId

   #--- traitement de LED
   set private($visuNo,threshold)  $::conf(eshel,instrument,config,$configId,threshold)
   set private($visuNo,width)      $::conf(eshel,instrument,config,$configId,width)
   set private($visuNo,height)     $::conf(eshel,instrument,config,$configId,height)
   #--- traitement de THAR
   set private($visuNo,alpha)       $::conf(eshel,instrument,config,$configId,alpha)
   set private($visuNo,beta)        $::conf(eshel,instrument,config,$configId,beta)
   set private($visuNo,gamma)       $::conf(eshel,instrument,config,$configId,gamma)
   set private($visuNo,focale)      $::conf(eshel,instrument,config,$configId,focale)
   set private($visuNo,grating)     $::conf(eshel,instrument,config,$configId,grating)
   set private($visuNo,pixelSize)   $::conf(eshel,instrument,config,$configId,pixelSize)
   set private($visuNo,refNum)      $::conf(eshel,instrument,config,$configId,refNum)
   set private($visuNo,refLambda)   $::conf(eshel,instrument,config,$configId,refLambda)
   set private($visuNo,lineList)    $::conf(eshel,instrument,config,$configId,lineList)
   set private($visuNo,cropLambda)  $::conf(eshel,instrument,config,$configId,cropLambda)


   #--- parametres acquisition de LED
   set private(ledExposureTime) 10
   set private(ledExposureNb) 1

   #--- parametre de recherche des marges dans LED
   set private($visuNo,snNoise)     3
   set private($visuNo,minLineNo)   0
   set private($visuNo,maxLineNo)   99

   set private($visuNo,minOrder)   0
   set private($visuNo,maxOrder)   99

   #--- parametres acquisition de THAR
   set private(tharExposureTime) 10
   set private(tharExposureNb) 1

   #--- parametre de recherche des raies dans THAR
   set private($visuNo,threshin)   3
   set private($visuNo,fwhm)       3

   #--- parametre des marges d'aboutement (en angstrom)
   set private($visuNo,joinMarginWidth) 20


   #--- options d'affichage
   set private($visuNo,showLineLabel) 0
   set private($visuNo,showLineDraw)  0
   set private($visuNo,showMagin)     0
   set private($visuNo,showCameraAxis) 1

   #--- j'affiche la fenetre
   set private($visuNo,This) "$tkbase.eshelwizard"
   set this $private($visuNo,This)
   destroy $this
   SimpleWizard $this  \
     -parent $tkbase  \
     -title $::caption(eshel,wizard,title) \
     -finishbutton 1 -helpbutton 0 -resizable { 1 1 } \
     -autobuttons 0

   #     -separatortext $::caption(eshel,wizard,description)

   wm geometry $private($visuNo,This) $::conf(eshel,wizard,windowPosition)
   wm minsize  $private($visuNo,This) 400 350
   set old [wm protocol $private($visuNo,This) WM_DELETE_WINDOW]
   wm protocol $private($visuNo,This) WM_DELETE_WINDOW ""
   wm protocol $private($visuNo,This) WM_DELETE_WINDOW "::eshel::wizard::closeWindow $visuNo"
   wm protocol $private($visuNo,This) WM_DELETE_WINDOW $old

   #--- j'affiche les etapes
   set step 0
   set maxStep 6

   $this insert step end root selectLed \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : Selection spectre LED" \
      -text2 "Ouvir une image LED ou faire une acquisition" \
      -text3 $::caption(eshel,wizard,masterImage) \
      -createcommand "::eshel::wizard::selectLedCreate $visuNo"  \
      -raisecommand "::eshel::wizard::selectLedRaise $visuNo" \
      -nextcommand   "::eshel::wizard::selectLedNext $visuNo"

  $this insert step end root selectMargin \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : $::caption(eshel,wizard,selectMargin,title)" \
      -text3 $::caption(eshel,wizard,selectMargin,action) \
      -createcommand "::eshel::wizard::selectMarginCreate $visuNo" \
      -raisecommand  "::eshel::wizard::selectMarginRaise  $visuNo" \
      -backcommand   "::eshel::wizard::selectMarginBack   $visuNo" \
      -nextcommand   "::eshel::wizard::selectMarginNext   $visuNo"

   $this insert step end root selectThar \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : Selection image THAR" \
      -createcommand "::eshel::wizard::selectTharCreate $visuNo" \
      -raisecommand "::eshel::wizard::selectTharRaise   $visuNo" \
      -backcommand   "::eshel::wizard::selectTharBack   $visuNo" \
      -nextcommand   "::eshel::wizard::selectTharNext   $visuNo"

   $this insert step end root selectRefLine \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : $::caption(eshel,wizard,selectRefLine,title)" \
      -text3 $::caption(eshel,wizard,selectRefLine,action) \
      -createcommand "::eshel::wizard::selectRefLineCreate $visuNo" \
      -raisecommand  "::eshel::wizard::selectRefLineRaise  $visuNo" \
      -backcommand   "::eshel::wizard::selectRefLineBack   $visuNo" \
      -nextcommand   "::eshel::wizard::selectRefLineNext   $visuNo"

   $this insert step end root selectJoinMargin \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : $::caption(eshel,wizard,selectJoinMargin,title)" \
      -text3 $::caption(eshel,wizard,selectJoinMargin,action) \
      -createcommand "::eshel::wizard::selectJoinMarginCreate $visuNo" \
      -raisecommand  "::eshel::wizard::selectJoinMarginRaise  $visuNo" \
      -backcommand   "::eshel::wizard::selectJoinMarginBack   $visuNo" \
      -nextcommand   "::eshel::wizard::selectJoinMarginNext   $visuNo"

   $this insert step end root done \
      -text1 "$::caption(eshel,wizard,step) [incr step]/$maxStep : Final Step " \
      -text2 "Enregistrement des nouveaux paramètres de la configuration " \
      -text3 "Récapitulatif des paramètres" \
      -createcommand "::eshel::wizard::doneCreate $visuNo" \
      -raisecommand  "::eshel::wizard::doneRaise  $visuNo" \
      -backcommand   "::eshel::wizard::doneBack   $visuNo" \
      -finishcommand  "::eshel::wizard::doneFinish   $visuNo"

   ###bind $this <<WizardLastStep>> {
   ##   %W itemconfigure back   -state normal
   ##   %W itemconfigure cancel -state normal
   ###}

   #--- je lance la surveillance de la selection de HDU
   ###::confVisu::addZoomListener $visuNo "::wizard::onChangeZoom $visuNo

   bind $this <Destroy> "::eshel::wizard::closeWindow $visuNo %W"

   $this show
   $this next

}

#------------------------------------------------------------
# closeWindow
#   supprime les ressources specifiques
#   et sauvegarde les parametres avant de fermer la fenetre
#
proc ::eshel::wizard::closeWindow { visuNo win} {
   variable private

   if { $win != $private($visuNo,This) } {
      #--- je fait rien s'il s'agit d'un widget dans la fenetre dialogue
      return
   }
   if { [winfo exists [confVisu::getCanvas $visuNo]] } {
      #--- remarque: le canvas de la visu peut avoir ete supprime avant cette fenetre
      #--- a la fermeture de Audela
      ::eshel::visu::hideMargin $visuNo
      ::eshel::visu::hideLineLabel $visuNo
      ::eshel::visu::hideLineDraw $visuNo
      ::eshel::visu::hideReferenceLine $visuNo
      ::eshel::visu::hideTangenteDraw $visuNo
      ::eshel::visu::hideOrderLabel $visuNo
      ::eshel::visu::hideCalibrationLine $visuNo
      ::eshel::visu::hideJoinMargin $visuNo
   }

   ::confVisu::removeZoomListener $visuNo "::wizard::onChangeZoom $visuNo"

   file delete -force $private($visuNo,ledWizardName)
   file delete -force $private($visuNo,selectRefLineFileName)

   #--- je memorise la position courante de la fenetre
   set ::conf(eshel,wizard,windowPosition) [ wm geometry $private($visuNo,This) ]

}

#------------------------------------------------------------
# setResult
#   affiche le resultat d'une etape
#
###proc ::eshel::wizard::onChangeZoom { visuNo } {
###   variable private
###
###
###   if { $private($visuNo,showLineLabel) == 1 } {
###      ::eshel::visu::showLineLabel $visuNo [::confVisu::getFileName $visuNo ] $private($visuNo,lineHduNum)
###   }
###   if { $private($visuNo,showLineDraw) == 1 } {
###         ::eshel::visu::showLineDraw $visuNo [::confVisu::getFileName $visuNo ] $private($visuNo,lineHduNum)
###   }
###}
###

#------------------------------------------------------------
## @brief affiche le résultat d'une etape
#  @param visuNo   numéro de la visu
#  @param stepName nom de l'étape du wizard
#  @param state    état de l'étape (ok warning error running )
#  @param message  message d'information à afficher
#
proc ::eshel::wizard::setResult { visuNo stepName state message } {
   variable private

   set back [$private($visuNo,This) step back]
   if { $back == "" || $state == "running" } {
      $private($visuNo,This) itemconfigure back  -state disabled
   } else {
      $private($visuNo,This) itemconfigure back  -state normal
   }

   set cancel [$private($visuNo,This) step cancel]
   if { $cancel == "" || $state == "running" } {
      $private($visuNo,This) itemconfigure cancel  -state disabled
   } else {
      $private($visuNo,This) itemconfigure cancel  -state normal
   }

   if { [ $private($visuNo,This) itemcget $stepName -finishcommand] == "" || $state == "running" } {
      $private($visuNo,This) itemconfigure finish -state disabled
   } else {
      $private($visuNo,This) itemconfigure finish -state normal
   }

   set frm [$private($visuNo,This) widgets get $stepName]
   if { [ $private($visuNo,This) itemcget $stepName -nextcommand] == ""} {
       $private($visuNo,This) itemconfigure next -state disabled
   } else {
      switch $state  {
         "ok" {
            $private($visuNo,This) itemconfigure next -state normal
             destroy $frm.progressBar

         }
         "warning" {
            $private($visuNo,This) itemconfigure next -state normal
            set message "WARNING : $message"
         destroy $frm.progressBar
                  }

         "error" {
            $private($visuNo,This) itemconfigure next -state disabled
            set message "ERROR : $message"
            destroy $frm.progressBar

         }
         "running" {
            $private($visuNo,This) itemconfigure next -state disabled
            ##ProgressBar  $frm.progressBar -type infinite -maximum 100
            ttk::progressbar  $frm.progressBar -mode indeterminate -length 100 -maximum 10
            pack $frm.progressBar -side top -fill none
            $frm.progressBar start

         }
      }
   }
set next [$private($visuNo,This) step next]
console::disp "setResult $stepName state=$state next=$next \n"
   $private($visuNo,This) itemconfigure $stepName -text4 $message
   ##[$private($visuNo,This) widgets get selectLed].layout.posttext configure -image $private(greenIcon)


}


###############################################################################
#  STEP selectLed
###############################################################################

#------------------------------------------------------------
# selectLedCreate
#   Etape : selection du fichier FLAT
#
proc ::eshel::wizard::selectLedCreate { visuNo } {
   variable private
   variable widget
console::disp "selectLedCreate \n"

   set frm [$private($visuNo,This) widgets get selectLed].layout.clientArea

   $private($visuNo,This) itemconfigure selectLed -text3 "$::caption(eshel,wizard,masterImage) LED"
   TitleFrame $frm.file -borderwidth 1
   #--- Bouton Fichier
   button $frm.file.loadLed  -text $::caption(eshel,wizard,openFile) \
       -command "::eshel::wizard::loadLed $visuNo"
   grid $frm.file.loadLed -in [$frm.file getframe] -row 0 -column 0 -sticky ""

   #---- Bouton go acq
   button $frm.file.goacq -text $::caption(eshel,wizard,goAcq) \
      -command "::eshel::wizard::goAcquisitionLed $visuNo"
   grid $frm.file.goacq -in [$frm.file getframe] -row 0 -column 1 -columnspan 2 -sticky ""

   #--- temps de pose
   label $frm.file.exposurelabel -text $::caption(eshel,exptime) -justify left -anchor w
   grid $frm.file.exposurelabel -in [$frm.file getframe] -row 1 -column 1 -sticky ns
   set list_combobox {0 0.5 1 3 5 10 15 30 60 120 }
   ComboBox $frm.file.exposureValue \
      -width 6  -height [ llength $list_combobox ] \
      -relief sunken -borderwidth 1 -editable 1 \
      -textvariable ::eshel::wizard::private(ledExposureTime) \
      -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s double 0 10000 } \
      -values $list_combobox
   grid $frm.file.exposureValue -in [$frm.file getframe] -row 1 -column 2 -sticky ns

   #--- nombre de poses
   label $frm.file.nbLabel -text $::caption(eshel,expnb) -justify left -anchor w
   grid $frm.file.nbLabel -in [$frm.file getframe] -row 2 -column 1 -sticky ns
   set list_combobox [list 1 2 3 5 ]
   ComboBox $frm.file.nbValue \
      -width 6 -height [ llength $list_combobox ] \
      -relief sunken -borderwidth 1 -editable 1 \
      -textvariable ::eshel::wizard::private(ledExposureNb) \
      -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 5 ) } \
      -values $list_combobox
   grid $frm.file.nbValue -in [$frm.file getframe] -row 2 -column 2 -sticky ns

   grid columnconfig [$frm.file getframe] 0 -weight 2
   grid columnconfig [$frm.file getframe] 1 -weight 1
   grid columnconfig [$frm.file getframe] 0 -weight 1

   pack $frm.file -side top -anchor n -fill x -expand 1 -pady 2

   #--- je precharge une image (pour les tests uniquement
   if { [file exists $private($visuNo,ledFileName)] == 1 } {
      set result [selectLedCheck $visuNo $private($visuNo,ledFileName)]
   }
}

#------------------------------------------------------------
# selectLedRaise
#   Etape : selection du fichier FLAT
#
proc ::eshel::wizard::selectLedRaise { visuNo } {
   variable private
   console::disp "selectLedRaise \n"

   $private($visuNo,This) configure -cursor watch
   update

   set catchResult [catch {
      if { [file exists $private($visuNo,ledFileName)] == 1 } {
         #--- j'affiche l'image LED
         ::confVisu::autovisu $visuNo "-dovisu" $private($visuNo,ledFileName)
      } else {
         ::confVisu::clear $visuNo
         setResult $visuNo selectLed "error" $::caption(eshel,wizard,errorFileNotSelected)
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      set title [$private($visuNo,This) itemcget selectLed -text1]
      tk_messageBox -icon error -title $title -message $errorMessage
      setResult $visuNo selectLed "error" $::errorInfo
   }
   $private($visuNo,This) configure -cursor arrow
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectLedNext { visuNo } {
   variable private
   console::disp "selectLedNext \n"

   return 1
}

#------------------------------------------------------------
## @brief contrôle des fichiers sélectionnés
#  @param visuNo numéro de la visu
#  @param fileName
#  @return  résultat de la vérification
#  - 1=OK
#  - 0=erreur
#  @todo commenter le param filename
#
proc ::eshel::wizard::selectLedCheck { visuNo fileName} {
   variable private
   set result "error"
   set title [$private($visuNo,This) itemcget selectLed -text1]

   #--- je verifie que le fichier LED existe
   if { $fileName != ""} {
      if { [file exists $fileName] == 1 } {
         #--- je verifie que c'est fichier LED
         set hFile ""
         set catchResult [catch {
            set hFile [fits open $fileName 0]

            set catchImageType [catch {
               set imageType [::eshel::file::getKeyword $hFile "IMAGETYP"]
            }]

            if { $catchImageType != 0 } {
               set message [format $::caption(eshel,wizard,imageTypeNotFound) [file tail $fileName] ]
               set choice [tk_messageBox -type yesno -icon error -title $title -message $message]
               if { $choice == "yes" } {
                  #--- l'utilisateur veut continuer avec cette image bien qu'elle n'ait pas le mot cle IMAGETYP
                  set imageType "LED"
               } else {
                 set imageType ""
               }
            }


            if { $imageType != "" } {
               set naxis1 [::eshel::file::getKeyword $hFile "NAXIS1"]
               set naxis2 [::eshel::file::getKeyword $hFile "NAXIS2"]
               if { $imageType == "LED" || $imageType == "FLAT" || $imageType == "TUNGSTEN" } {
                  if { $naxis1 == $private($visuNo,width) && $naxis2 == $private($visuNo,height) } {
                      set result "ok"
                      set text4 [format $::caption(eshel,wizard,infoFile) [file tail $fileName] "$naxis1 x $naxis2"]
                  } else {
                      set result "error"
                      set text4 [format $::caption(eshel,wizard,errorFileSize) \
                         [file tail $fileName] \
                         "$naxis1 x $naxis2" \
                         "$private($visuNo,width) x $private($visuNo,height)" \
                     ]
                     tk_messageBox -icon error -title $title -message $text4
                  }
               } else {
                  set result "error"
                  set text4 [format $::caption(eshel,wizard,errorLedFile) [file tail $fileName] \"$imageType\" ]
                  ####tk_messageBox -icon error -title $title -message $text4
                  set choice [tk_messageBox -type yesno -icon error -title $title -message "$text4. Voulez vous continuer quand même ?"]
                  if { $choice == "yes" } {
                     #--- l'utilisateur veut continuer quand meme
                     set result "ok"
                  } else {
                    set result "error"
                  }
               }
            } else {
               set result "error"
               set text4 $::caption(eshel,wizard,errorFileNotSelected)
               #--- pas besoin d'afficher une tkbox car cela a ete fait juste avant
            }
         }]
         if { $hFile != "" } {
            $hFile close
         }
         if { $catchResult == 1 } {
            set result "error"
            ::console::affiche_erreur "$::errorInfo\n"
            set text4 [format $::caption(eshel,wizard,errorFileLoad) [file tail $fileName]]
            tk_messageBox -icon error -title $title -message $text4
         }
      } else {
         set result "error"
         set text4 "$::caption(eshel,wizard,errorFileNotFound) $fileName"
         tk_messageBox -icon error -title $title -message $text4
      }
   } else {
      set result "error"
      set text4 $::caption(eshel,wizard,errorFileNotSelected)
      tk_messageBox -icon error -title $title -message $text4
   }
   #--- j'affiche le message d'erreur dans text4
   setResult $visuNo selectLed $result $text4
   console::disp "   selectLedCheck result=$result\n"
   if {$result != "error" } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
## @brief Ouvre la fenêtre de sélection d'un fichier LED
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::loadLed { visuNo } {
   variable private

   #--- je recupere le repertoire initial
   if { $private($visuNo,ledFileName) == "" } {
      set  initialDirectory $::conf(eshel,mainDirectory)
   } else {
      set  initialDirectory [file dir $private($visuNo,ledFileName) ]
      if { [file exists $initialDirectory ] == 0 } {
         set initialDirectory $::conf(eshel,mainDirectory)
      }
   }
   #--- j'ouvre la fenetre de choix des images
   set fileName [file native [::tkutil::box_load $private($visuNo,This) $initialDirectory $::audace(bufNo) "1"]]
   if { $fileName != "" } {
      #--- je verifie l'image
      set checkResult [selectLedCheck $visuNo $fileName]
      if { $checkResult == 1 } {
         #--- je charge l'image
         $private($visuNo,This) configure -cursor watch
         update
         set catchResult [catch {
            confVisu::loadIma $visuNo $fileName
            set private($visuNo,ledFileName) $fileName
         }]
         if { $catchResult != 0 } {
            ::console::affiche_erreur "$::errorInfo\n"
            tk_messageBox -icon error -title $title -message $errorMessage
            setResult $visuNo selectLed "error" $::errorInfo
            ::confVisu::clear $visuNo
            set private($visuNo,ledFileName) ""
         }
         $private($visuNo,This) configure -cursor arrow
      } else {
         ::confVisu::clear $visuNo
         set private($visuNo,ledFileName) ""
      }
   }
}

#------------------------------------------------------------
# goAcquisitionLed
#   supprime les ressources specifiques
#   et sauvegarde les parametres avant de fermer la fenetre
#
proc ::eshel::wizard::goAcquisitionLed { visuNo } {
   variable private

   $private($visuNo,This) configure -cursor watch
   set catchResult [catch {
     #--- acquisition
     ::eshel::acquisition::startSequence $visuNo [list [list ledSerie [list expNb $private(ledExposureNb) expTime $private(ledExposureTime)]]]

     #--- traitement
     ::eshel::checkDirectory
     ::eshel::process::generateNightlog
     ::eshel::process::generateProcessBias
     ::eshel::process::generateProcessDark
     ::eshel::process::generateProcessLed
     ::eshel::process::generateScript
     ###::eshel::process::saveFile
     #--- je recupere les informations de la dernière image LED a traiter
     set processInfo [::eshel::process::getProcessInfo "LED-PROCESS"]
      if { [llength $processInfo] > 0 } {
         set fileName [lindex [lindex $processInfo end ] 0]
         set status   [lindex [lindex $processInfo end ] 1]
         set comment  [lindex [lindex $processInfo end ] 2]
         if { $status == "todo" } {
            #--- je lance le traitement
            ::eshel::process::startScript
            while { $::eshel::process::private(running) == 1 } {
               update
               after 1000
            }
            set fileName [file join $::conf(eshel,tempDirectory) $fileName ]
            #--- je verifie l'image
            set checkResult [selectLedCheck $visuNo $fileName]
            if { $checkResult == 1 } {
               set private($visuNo,ledFileName) $fileName
            } else {
               ::confVisu::clear $visuNo
               set private($visuNo,ledFileName) ""
            }
         } else {
            set message "$fileName processing : $comment"
            setResult $visuNo selectLed "error" $message
         }
      } else {
         set message "LED image not found"
         setResult $visuNo selectLed "error" $message
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      set title "LED acquisition"
      tk_messageBox -icon error -title $title -message $::errorInfo
      setResult $visuNo selectLed "error" $::errorInfo
   }
   $private($visuNo,This) configure -cursor arrow

}

###############################################################################
#  STEP selectMargin
###############################################################################

#------------------------------------------------------------
# selectMarginCreate
#   Etape : selection des marges
#
proc ::eshel::wizard::selectMarginCreate { visuNo } {
   variable private
   variable widget
   console::disp "selectMarginCreate\n"
   ###console::disp "selectMarginCreate current step=[$private($visuNo,This) step current]"
   ##set frm [$private($visuNo,This) widgets get selectMargin]

   ##set frm [frame [$private($visuNo,This) widgets get selectMargin].selectMargin ]
   ##pack $frm -fill both -expand 1

   set frm [$private($visuNo,This) widgets get selectMargin].layout.clientArea

   set private($visuNo,showLineLabel) 1
   set private($visuNo,showLineDraw) 0
   set widget($visuNo,showAllOrderLine) 0
   set private($visuNo,findMarginResult) ""

   TitleFrame $frm.order -borderwidth 1  -relief groove -text $::caption(eshel,wizard,orderDetection)

      #---- entry threshold
      Label $frm.order.thresholdLab -text $::caption(eshel,instrument,process,threshold) -justify left
      grid $frm.order.thresholdLab -in [$frm.order getframe] -row 0 -column 0 -sticky ns
      Entry $frm.order.threshold  -width 6 -justify right \
         -textvariable ::eshel::wizard::private($visuNo,threshold) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 10000 }
      grid $frm.order.threshold -in [$frm.order getframe] -row 0 -column 1 -sticky nsew

   grid $frm.order -row 0 -column 0 -sticky sew

   TitleFrame $frm.margin -borderwidth 1  -relief groove -text $::caption(eshel,wizard,marginDetection)

      #---- entry snnoise
      Label $frm.margin.snnoiseLab -text $::caption(eshel,wizard,snnoise)
      grid $frm.margin.snnoiseLab -in [$frm.margin getframe] -row 0 -column 0 -sticky ns
      Entry $frm.margin.snnoise -width 6 -justify right \
         -textvariable ::eshel::wizard::private($visuNo,snNoise) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0.0 100.0 }
      grid $frm.margin.snnoise -in [$frm.margin getframe] -row 0 -column 1 -sticky ns

      ####---- entry minLineNo
      ###Label $frm.margin.minOrderLab -text $::caption(eshel,wizard,minOrder)
      ###grid $frm.margin.minOrderLab -in [$frm.margin getframe] -row 1 -column 0 -sticky ns
      ###Entry $frm.margin.minOrder -width 6 -justify right \
      ###   -textvariable ::eshel::wizard::private($visuNo,minLineNo) \
      ###   -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 99 }
      ###grid $frm.margin.minOrder -in [$frm.margin getframe] -row 1 -column 1 -sticky ns
      ###
      ####---- entry maxLineNos
      ###Label $frm.margin.maxOrderLab -text $::caption(eshel,wizard,maxOrder)
      ###grid $frm.margin.maxOrderLab -in [$frm.margin getframe] -row 2 -column 0 -sticky ns
      ###Entry $frm.margin.maxOrder -width 6 -justify right \
      ###   -textvariable ::eshel::wizard::private($visuNo,maxLineNo) \
      ###   -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 99 }
      ###grid $frm.margin.maxOrder -in [$frm.margin getframe] -row 2 -column 1 -sticky ns
   grid $frm.margin -row 1 -column 0 -sticky sew
   grid rowconfig    [$frm.margin getframe] 0 -weight 1

   TitleFrame $frm.show -borderwidth 1  -relief groove -text $::caption(eshel,wizard,showLine)
      #---- checkbutton showLineLabel
      checkbutton $frm.show.lineLabel -text $::caption(eshel,wizard,showLineLabel) \
         -highlightthickness 0 -variable ::eshel::wizard::private($visuNo,showLineLabel) \
         -command [list ::eshel::wizard::showLineLabel $visuNo]
      grid $frm.show.lineLabel -in [$frm.show getframe] -row 1 -column 0 -columnspan 2 -sticky w

      #---- checkbutton showCameraAxis
      checkbutton $frm.show.cameraAxis -text $::caption(eshel,wizard,showCameraAxis) \
         -highlightthickness 0 -variable ::eshel::wizard::private($visuNo,showCameraAxis) \
         -command [list ::eshel::wizard::showLineDraw $visuNo]
      grid $frm.show.cameraAxis -in [$frm.show getframe] -row 2 -column 0 -columnspan 2 -sticky w

      #---- checkbutton showLine
      checkbutton $frm.show.lineDraw -text $::caption(eshel,wizard,showLineDraw) \
         -highlightthickness 0 -variable ::eshel::wizard::private($visuNo,showLineDraw) \
         -command [list ::eshel::wizard::showLineDraw $visuNo]
      grid $frm.show.lineDraw -in [$frm.show getframe] -row 3 -column 0 -columnspan 2 -sticky w

      #---- checkbutton showAllLine
      checkbutton $frm.show.allLineDraw -text $::caption(eshel,wizard,showAllOrderLine) \
         -highlightthickness 0 -variable ::eshel::wizard::widget($visuNo,showAllOrderLine) \
         -command [list ::eshel::wizard::showLineDraw $visuNo]
      grid $frm.show.allLineDraw -in [$frm.show getframe] -row 4 -column 0 -columnspan 2 -sticky w -padx 10

   grid $frm.show -row 0 -column 1 -rowspan 2 -sticky sew
   grid rowconfig    [$frm.show getframe] 0 -weight 1
   grid rowconfig    [$frm.show getframe] 1 -weight 1
   grid rowconfig    [$frm.show getframe] 2 -weight 1
   grid rowconfig    [$frm.show getframe] 3 -weight 1
   grid rowconfig    [$frm.show getframe] 4 -weight 1

   TitleFrame $frm.button -borderwidth 0 -relief groove
      #--- Bouton Refresh
      button $frm.button.refresh -text $::caption(eshel,wizard,refresh) \
        -borderwidth 2 -command "::eshel::wizard::selectMarginBack $visuNo ; ::eshel::wizard::selectMarginRaise $visuNo"
      grid $frm.button.refresh -in [$frm.button getframe] -row 0 -column 0 -columnspan 2 -sticky ew
   grid $frm.button -row 2 -column 0 -columnspan 2 -sticky s

   grid columnconfig $frm 0 -weight 1
   grid columnconfig $frm 1 -weight 1
   grid rowconfig    $frm 0 -weight 1
   grid rowconfig    $frm 1 -weight 1
   grid rowconfig    $frm 2 -weight 1

   return 1
}

#------------------------------------------------------------
# selectMarginNext
#   Etape : selection des marges
#
proc ::eshel::wizard::selectMarginRaise { visuNo } {
   variable private
   console::disp "selectMarginRaise\n"


   ::eshel::visu::hideMargin $visuNo
   $private($visuNo,This) configure -cursor watch
   setResult $visuNo "selectMargin" "running" "recherche en cours ..."
   update

   #--- je recherche les marges
   set catchResult [catch {
     if { [file exists $private($visuNo,ledWizardName)]==0 || $private($visuNo,findMarginResult)=="" } {
        set tid [thread::create]
        set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::eshel::getPluginType]] [::eshel::getPluginDirectory]]
        thread::send $tid "load [file join $dir libeshel.dll]"
        thread::send -async $tid [list eshel_findMargin  \
                    $private($visuNo,ledFileName) \
                    $private($visuNo,ledWizardName) \
                    $private($visuNo,width)     \
                    $private($visuNo,height)    \
                    $private($visuNo,threshold) \
                    $private($visuNo,snNoise)   \
                    $private($visuNo,minLineNo)  \
                    $private($visuNo,maxLineNo)
                 ] ::eshel::wizard::private($visuNo,findMarginResult)
        vwait ::eshel::wizard::private($visuNo,findMarginResult)
        thread::release $tid
      }

      set nbOrdreOk [lindex $::eshel::wizard::private($visuNo,findMarginResult) 0]
      set tangenteList [lindex $::eshel::wizard::private($visuNo,findMarginResult) 1]
      set private($visuNo,cameraAxisCoord) [lindex $::eshel::wizard::private($visuNo,findMarginResult) 2]
      set private($visuNo,referenceAxisCoord) [lindex $::eshel::wizard::private($visuNo,findMarginResult) 3]
      if { [::confVisu::getFileName $visuNo] != $private($visuNo,ledWizardName) } {
         loadima $private($visuNo,ledWizardName)
      }

      $private($visuNo,This) configure -cursor arrow
      update

      #--- j'affiche les marges
      ::eshel::visu::showMargin $visuNo
      #--- j'affiche les marges
      showCameraAxis $visuNo
      #--- j'affiche le numero des ordres
      showLineLabel $visuNo
      #---- j'affiche le trace des ordres
      showLineDraw $visuNo

      if { $nbOrdreOk  > 0 } {
         setResult $visuNo "selectMargin" "ok" "$nbOrdreOk ordres ont été détectés.\nVous pouvez passer à l'étape suivante"
      } else {
         bell
         setResult $visuNo "selectMargin" "error" "Aucun ordre détecté."
      }

   }]
   if { $catchResult == 1 } {
      $private($visuNo,This) configure -cursor arrow
      bell
      console::affiche_erreur "$::errorInfo\n"
      set message "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]"
      setResult $visuNo selectMargin "error" $message
      return
   }

   return
}

#------------------------------------------------------------
# selectMarginBack
#   Etape : selection des marges
#
proc ::eshel::wizard::selectMarginBack { visuNo } {
   variable private

   console::disp "selectMarginBack\n"

   ::eshel::visu::hideMargin $visuNo
   ::eshel::visu::hideLineLabel $visuNo
   ::eshel::visu::hideLineDraw $visuNo
   ::eshel::visu::hideTangenteDraw $visuNo
   file delete -force $private($visuNo,ledWizardName)
   set private($visuNo,findMarginResult) ""

   return 1
}


#------------------------------------------------------------
# selectMarginNext
#   Etape : selection des marges
#
proc ::eshel::wizard::selectMarginNext { visuNo } {
   variable private
   variable widget
   console::disp "selectMarginNext\n"

   ::eshel::visu::hideMargin $visuNo
   ::eshel::visu::hideLineLabel $visuNo
   ::eshel::visu::hideLineDraw $visuNo
   ::eshel::visu::hideTangenteDraw $visuNo
   ::confVisu::clear $visuNo

   return 1
}

#------------------------------------------------------------
## @brief affiche les numéro des ordres
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::showLineLabel { visuNo } {
   variable private
   variable widget

   if { $private($visuNo,showLineLabel) == 1 } {
      ::eshel::visu::showLineLabel $visuNo
   } else {
      ::eshel::visu::hideLineLabel $visuNo
   }
}

#------------------------------------------------------------
## @brief affiche le trace des ordres
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::showLineDraw { visuNo } {
   variable private
   variable widget

   if { $private($visuNo,showLineDraw) == 1 } {
      $private($visuNo,This) configure -cursor watch
      update
      ::eshel::visu::showLineDraw $visuNo $widget($visuNo,showAllOrderLine)
      $private($visuNo,This) configure -cursor arrow
   } else {
      ::eshel::visu::hideLineDraw $visuNo
   }
}

#------------------------------------------------------------
## @brief affiche l'axe de la caméra
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::showCameraAxis { visuNo } {
   variable private
   variable widget

   if { $private($visuNo,showCameraAxis) == 1 } {
      $private($visuNo,This) configure -cursor watch
      update
      ::eshel::visu::showTangenteDraw  $visuNo [list ] $private($visuNo,cameraAxisCoord) $private($visuNo,referenceAxisCoord)
      $private($visuNo,This) configure -cursor arrow
   } else {
      ::eshel::visu::hideTangenteDraw $visuNo
   }
}

###############################################################################
#  STEP selectThar
###############################################################################

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::selectTharCreate { visuNo } {
   variable private
   variable widget

   ###set frm [$private($visuNo,This) widgets get selectThar]
   set frm [$private($visuNo,This) widgets get selectThar].layout.clientArea

   $private($visuNo,This) itemconfigure selectThar -text3 "$::caption(eshel,wizard,masterImage) THAR"

   TitleFrame $frm.file -borderwidth 1 -text $::caption(eshel,wizard,masterImage)
   #--- Bouton Fichier
   button $frm.file.loadThar  -text $::caption(eshel,wizard,openFile) \
       -command "::eshel::wizard::loadThar $visuNo"
   grid $frm.file.loadThar -in [$frm.file getframe] -row 0 -column 0 -sticky ""

   #---- Bouton go acq
   button $frm.file.goacq -text $::caption(eshel,wizard,goAcq) \
      -command "::eshel::wizard::goAcquisitionThar $visuNo"
   grid $frm.file.goacq -in [$frm.file getframe] -row 0 -column 1 -sticky ""

   #--- temps de pose
   label $frm.file.exposurelabel -text $::caption(eshel,exptime) -justify left -anchor w
   grid $frm.file.exposurelabel -in [$frm.file getframe] -row 1 -column 1 -sticky ns
   set list_combobox {0 0.5 1 3 5 10 15 30 60 120 }
   ComboBox $frm.file.exposureValue \
      -width 6  -height [ llength $list_combobox ] \
      -relief sunken -borderwidth 1 -editable 1 \
      -textvariable ::eshel::wizard::private(tharExposureTime) \
      -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s double 0 10000 } \
      -values $list_combobox
   grid $frm.file.exposureValue -in [$frm.file getframe] -row 1 -column 2 -sticky ns

   #--- nombre de poses
   label $frm.file.nbLabel -text $::caption(eshel,expnb) -justify left -anchor w
   grid $frm.file.nbLabel -in [$frm.file getframe] -row 2 -column 1 -sticky ns
   set list_combobox [list 1 2 3 5 ]
   ComboBox $frm.file.nbValue \
      -width 6 -height [ llength $list_combobox ] \
      -relief sunken -borderwidth 1 -editable 1 \
      -textvariable ::eshel::wizard::private(tharExposureNb) \
      -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 5 } \
      -values $list_combobox
   grid $frm.file.nbValue -in [$frm.file getframe] -row 2 -column 2 -sticky ns

   grid columnconfig [$frm.file getframe] 0 -weight 2
   grid columnconfig [$frm.file getframe] 1 -weight 1
   grid columnconfig [$frm.file getframe] 0 -weight 1

   pack $frm.file -side top -anchor n -fill x -expand 1 -pady 2

}

#------------------------------------------------------------
## @brief Etape : sélection du fichier THAR
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::selectTharRaise { visuNo } {
   variable private

   set catchResult [catch {
      if { [file exists $private($visuNo,tharFileName)] == 1 } {
         #--- j'affiche l'image THAR
         loadima $private($visuNo,tharFileName)
      } else {
         setResult $visuNo selectThar "error" $::caption(eshel,wizard,errorFileNotSelected)
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      tk_messageBox -icon error -title $title -message $errorMessage
      setResult $visuNo selectThar "error" $::errorInfo
   }
   $private($visuNo,This) configure -cursor arrow

}

#------------------------------------------------------------
## @brief ?
#  @return 1
#  @todo commenter le brief
#
proc ::eshel::wizard::selectTharBack { visuNo } {
   variable private
   console::disp "selectTharBack \n"

   set result 1
   return $result
}


#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectTharNext { visuNo } {
   variable private
   console::disp "selectTharNext \n"

   set result 1
   return $result
}

#------------------------------------------------------------
## @brief contrôle des fichiers sélectionnés
#  @param visuNo numéro de la visu
#  @param fileName ??
#  @return
#  - 1=OK
#  - 0=erreur
#  @todo commenter le param filename
#
proc ::eshel::wizard::selectTharCheck { visuNo fileName} {
   variable private

   set result "error"
   set title [$private($visuNo,This) itemcget selectThar -text1]

   #--- je verifie que le fichier THAR existe
   if { $fileName != ""} {
      if { [file exists $fileName] == 1 } {
         #--- je verifie que c'est fichier THAR
         set hFile ""
         set catchResult [catch {
            set hFile [fits open $fileName 0]
            set catchImageType [catch {
               set imageType [::eshel::file::getKeyword $hFile "IMAGETYP"]
            }]

            if { $catchImageType != 0 } {
               set message [format $::caption(eshel,wizard,imageTypeNotFound) [file tail $fileName] ]
               set choice [tk_messageBox -type yesno -icon error -title $title -message $message]
               if { $choice == "yes" } {
                  #--- l'utilisateur veut continuer avec cette image bien qu'elle n'ait pas le mot cle IMAGETYP
                  set imageType "CALIB"
               } else {
                 set imageType ""
               }
            }


            if { $imageType != "" } {

               set naxis1 [::eshel::file::getKeyword $hFile "NAXIS1"]
               set naxis2 [::eshel::file::getKeyword $hFile "NAXIS2"]
               if { $imageType == "CALIB" || $imageType == "THAR"} {
                  if { $naxis1 == $private($visuNo,width) && $naxis2 == $private($visuNo,height) } {
                      set result "ok"
                      set text4 [format $::caption(eshel,wizard,infoFile) [file tail $fileName] "$naxis1 x $naxis2"]
                  } else {
                      set result "error"
                      set text4 [format $::caption(eshel,wizard,errorFileSize) \
                         [file tail $fileName] \
                         "$naxis1 x $naxis2" \
                         "$private($visuNo,width) x $private($visuNo,height)" \
                     ]
                     tk_messageBox -icon error -title $title -message $text4
                  }
               } else {
                  set result "error"
                  set text4 [format $::caption(eshel,wizard,errorTharFile) [file tail $fileName] CALIB]
                  tk_messageBox -icon error -title $title -message $text4
               }
            } else {
               set result "error"
               set text4 $::caption(eshel,wizard,errorFileNotSelected)
               #--- pas besoin d'afficher une tkbox car cela a ete fait juste avant
            }
         }]
         if { $hFile != "" } {
            $hFile close
         }
         if { $catchResult == 1 } {
            ::console::affiche_erreur "$::errorInfo\n"
            set text4 [format $::caption(eshel,wizard,errorFileLoad) [file tail $fileName]]
            tk_messageBox -icon error -title $title -message $text4
         }
      } else {
         set result "error"
         set text4 "$::caption(eshel,wizard,errorFileNotFound) $fileName"
         tk_messageBox -icon error -title $title -message $text4
      }
   } else {
      set result "error"
      set text4 $::caption(eshel,wizard,errorFileNotSelected)
      tk_messageBox -icon error -title $title -message $text4
   }
   #--- j'affiche le message d'erreur dans text4
   setResult $visuNo selectThar $result $text4
   console::disp "   selectTharCheck result=$result\n"
   if {$result != "error" } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
## @brief Ouvre la fenêtre de sélection d'un fichier THAR
#  @param visuNo numéro de la visu
#
proc ::eshel::wizard::loadThar { visuNo } {
   variable private

   #--- je recupere le repertoire initial
   if { $private($visuNo,tharFileName) == "" } {
      if { $private($visuNo,ledFileName) == "" } {
         set  initialDirectory $::conf(eshel,mainDirectory)
      } else {
         set  initialDirectory [file dir $private($visuNo,ledFileName) ]
         if { [file exists $initialDirectory ] == 0 } {
            set initialDirectory $::conf(eshel,mainDirectory)
         }
      }
   } else {
      set  initialDirectory [file dir $private($visuNo,tharFileName) ]
      if { [file exists $initialDirectory ] == 0 } {
         set initialDirectory $::conf(eshel,mainDirectory)
      }
   }
   #--- Ouvre la fenetre de choix des images
   set fileName [file native [::tkutil::box_load $private($visuNo,This) $initialDirectory $::audace(bufNo) "1"]]
   if { $fileName != "" } {
      #--- je verifie l'image
      set checkResult [selectTharCheck $visuNo $fileName]
      if { $checkResult == 1 } {
         #--- je charge l'image
         $private($visuNo,This) configure -cursor watch
         update
         set catchResult [catch {
            confVisu::loadIma $visuNo $fileName
            set private($visuNo,tharFileName) $fileName
         }]
         if { $catchResult != 0 } {
            ::console::affiche_erreur "$::errorInfo\n"
            tk_messageBox -icon error -title $title -message $errorMessage
            setResult $visuNo selectLed "error" $::errorInfo
            ::confVisu::clear $visuNo
            set private($visuNo,tharFileName) ""
         }
         $private($visuNo,This) configure -cursor arrow
      } else {
         ::confVisu::clear $visuNo
         set private($visuNo,tharFileName) ""
      }
   }
}

#------------------------------------------------------------
# goAcquisitionThar
#   acquisition d'une image THAR
#
proc ::eshel::wizard::goAcquisitionThar { visuNo } {
   variable private

   $private($visuNo,This) configure -cursor watch
   set catchResult [catch {
     #--- acquisition
     ::eshel::acquisition::startSequence $visuNo [list [list tharSerie [list expNb $private(tharExposureNb) expTime $private(tharExposureTime)]]]

     #--- traitement
     ::eshel::checkDirectory
     ::eshel::process::generateNightlog
     ::eshel::process::generateProcessBias
     ::eshel::process::generateProcessDark
     ::eshel::process::generateProcessThar
     ::eshel::process::generateScript
     #--- je recupere les informations du process THAR a traiter
     set processInfo [::eshel::process::getProcessInfo "THAR-PROCESS"]
      if { [llength $processInfo] > 0 } {
         set fileName [lindex [lindex $processInfo end ] 0]
         set status   [lindex [lindex $processInfo end ] 1]
         set comment  [lindex [lindex $processInfo end ] 2]
         if { $status == "todo" } {
            #--- je lance le traitement
            ::eshel::process::startScript
            while { $::eshel::process::private(running) == 1 } {
               update
               after 1000
            }
            set fileName [file join $::conf(eshel,tempDirectory) $fileName ]
            #--- je verifie l'image
            set checkResult [selectTharCheck $visuNo $fileName]
            if { $checkResult == 1 } {
               set private($visuNo,tharFileName) $fileName
            } else {
               ::confVisu::clear $visuNo
               set private($visuNo,tharFileName) ""
            }
         } else {
            set message "$fileName processing : $comment"
            setResult $visuNo selectLed "error" $message
         }
      } else {
         set message "THAR image not found"
         setResult $visuNo selectLed "error" $message
      }
   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      tk_messageBox -icon error -title $title -message $errorMessage
      setResult $visuNo selectThar "error" $::errorInfo
   }
   $private($visuNo,This) configure -cursor arrow

}


###############################################################################
#  STEP selectRefLine
###############################################################################

#------------------------------------------------------------
# selectRefLineCreate
#   Etape : selection de la raie de reference
#
proc ::eshel::wizard::selectRefLineCreate { visuNo } {
   variable private
   variable widget
   console::disp "selectRefLineCreate \n"

   #--- je cree une frame pour pouvoir utiliser "grid layer"
   ##set frm [frame [$private($visuNo,This) widgets get selectRefLine].selectRefLine ]
   ##pack $frm -fill both -expand 1

   if { [file exists $private($visuNo,selectRefLineFileName)]==1 } {
      file delete -force $private($visuNo,selectRefLineFileName)
   }

   set frm [$private($visuNo,This) widgets get selectRefLine].layout.clientArea

   TitleFrame $frm.param -borderwidth 1 -text $::caption(eshel,wizard,parameters)
   ####---- entry alpha
   ###Label $frm.param.alphaLabel -text $::caption(eshel,instrument,spectrograph,alpha)
   ###grid $frm.param.alphaLabel -in [$frm.param getframe] -row 0 -column 0 -sticky ns
   ###Entry $frm.param.alpha  -width 6 -justify right \
   ###   -textvariable ::eshel::wizard::private($visuNo,alpha) \
   ###   -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0.0 360.0 }
   ###grid $frm.param.alpha -in [$frm.param getframe] -row 0 -column 1 -sticky nsew

   #---- entry refNum
   Label $frm.param.refNumLabel -text $::caption(eshel,instrument,process,refNum)
   grid $frm.param.refNumLabel -in [$frm.param getframe] -row 1 -column 0 -sticky ns
   Entry $frm.param.refNum  -width 6 -justify right \
      -textvariable ::eshel::wizard::private($visuNo,refNum) \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100 }
   grid $frm.param.refNum -in [$frm.param getframe] -row 1 -column 1 -sticky nsew

   #---- entry refLambda
   Label $frm.param.refLambdaLabel -text $::caption(eshel,instrument,process,refLambda)
   grid $frm.param.refLambdaLabel -in [$frm.param getframe] -row 2 -column 0 -sticky ns
   Entry $frm.param.refLambda  -width 6 -justify right \
      -textvariable ::eshel::wizard::private($visuNo,refLambda) \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 1000.0 10000.0 }
   grid $frm.param.refLambda -in [$frm.param getframe] -row 2 -column 1 -sticky nsew

   #---- entry fwhm
   Label $frm.param.fwhmLabel -text $::caption(eshel,wizard,fwhm)
   grid $frm.param.fwhmLabel -in [$frm.param getframe] -row 3 -column 0 -sticky ns
   Entry $frm.param.fwhm  -width 6 -justify right \
      -textvariable ::eshel::wizard::private($visuNo,fwhm) \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100 }
   grid $frm.param.fwhm -in [$frm.param getframe] -row 3 -column 1 -sticky nsew

   #---- entry threshin
   Label $frm.param.threshinLabel -text $::caption(eshel,wizard,threshin)
   grid $frm.param.threshinLabel -in [$frm.param getframe] -row 4 -column 0 -sticky ns
   Entry $frm.param.threshin  -width 6 -justify right \
      -textvariable ::eshel::wizard::private($visuNo,threshin) \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100000 }
   grid $frm.param.threshin -in [$frm.param getframe] -row 4 -column 1 -sticky nsew

   #--- Bouton Refresh
   button $frm.param.refresh -text $::caption(eshel,wizard,refresh) \
     -borderwidth 2 -command "::eshel::wizard::selectRefLineBack $visuNo ; ::eshel::wizard::selectRefLineRaise $visuNo"
   grid $frm.param.refresh -in [$frm.param getframe] -row 5 -column 0 -columnspan 2 -sticky ""  -ipadx 10

   grid columnconfig [$frm.param getframe] 0 -weight 1
   grid columnconfig [$frm.param getframe] 1 -weight 1

   pack $frm.param -side top -anchor s -fill x -expand 1 -pady 2
}

#------------------------------------------------------------
# selectRefLineRaise
#   Recherche la raie de reference dans THAR
#
proc ::eshel::wizard::selectRefLineRaise { visuNo } {
   variable private
   console::disp "selectRefLineRaise \n"

  $private($visuNo,This) configure -cursor watch
  setResult $visuNo "selectRefLine" "running" "recherche en cours ..."
  update

  set catchResult [catch {
      if { [file exists $private($visuNo,selectRefLineFileName)]==0 } {
         set tid [thread::create]
console::disp "eshel_findReferenceLine  \
                     $private($visuNo,ledWizardName)  \
                     $private($visuNo,tharFileName)  \
                     $private($visuNo,selectRefLineFileName) \
                     $private($visuNo,alpha) $private($visuNo,beta) $private($visuNo,gamma) \
                     $private($visuNo,focale) $private($visuNo,grating) \
                     $private($visuNo,pixelSize) $private($visuNo,width) $private($visuNo,height) \
                     $private($visuNo,refNum) $private($visuNo,refLambda) \
                     $private($visuNo,lineList) \
                     $private($visuNo,threshin) \
                     $private($visuNo,fwhm)\n "
         set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::eshel::getPluginType]] [::eshel::getPluginDirectory]]
         thread::send $tid "load [file join $dir libeshel.dll]"
         thread::send -async $tid [list eshel_findReferenceLine  \
                     $private($visuNo,ledWizardName)  \
                     $private($visuNo,tharFileName)  \
                     $private($visuNo,selectRefLineFileName) \
                     $private($visuNo,alpha) $private($visuNo,beta) $private($visuNo,gamma) \
                     $private($visuNo,focale) $private($visuNo,grating) \
                     $private($visuNo,pixelSize) $private($visuNo,width) $private($visuNo,height) \
                     $private($visuNo,refNum) $private($visuNo,refLambda) \
                     $private($visuNo,lineList) \
                     $private($visuNo,threshin) \
                     $private($visuNo,fwhm) \
                  ] ::eshel::wizard::private($visuNo,selectRefLineResult)
         vwait ::eshel::wizard::private($visuNo,selectRefLineResult)
         thread::release $tid
         if { [llength $private($visuNo,selectRefLineResult)] != 8 } {
            set errorMessage $private($visuNo,selectRefLineResult)
            set private($visuNo,selectRefLineResult) ""
         }
      }

      if { [llength $private($visuNo,selectRefLineResult)] == 8 } {
         set private($visuNo,alpha)      [lindex $private($visuNo,selectRefLineResult) 0]
         set bestLineNo      [lindex $private($visuNo,selectRefLineResult) 1]
         set bestRefCoord    [lindex $private($visuNo,selectRefLineResult) 2]
         set bestRefDx       [lindex $private($visuNo,selectRefLineResult) 3]
         set imageLineList   [lindex $private($visuNo,selectRefLineResult) 4]
         set catalogLineList [lindex $private($visuNo,selectRefLineResult) 5]
         set matchedLineList [lindex $private($visuNo,selectRefLineResult) 6]
         set orderInfoList   [lindex $private($visuNo,selectRefLineResult) 7]

         set imageLineNb   [llength $imageLineList]
         set catalogLineNb [llength $catalogLineList]
         set matchedStarNb [llength $matchedLineList]

         console::disp "selectRefLineRaise alpha=$private($visuNo,alpha) lineNo=$bestLineNo imageLineNb=$imageLineNb catalogLineNb=$catalogLineNb matchedStarNb=$matchedStarNb \n"
         console::disp "refLambda=$private($visuNo,refLambda) coord=$bestRefCoord bestRefDx=$bestRefDx\n"
         ##console::disp "orderInfoList=$orderInfoList\n"

         #--- j'affiche le resultat
         loadima $private($visuNo,selectRefLineFileName)
         ::eshel::visu::showOrderLabel $visuNo
         ::eshel::visu::showReferenceLine $visuNo $imageLineList $catalogLineList $matchedLineList $bestRefCoord
         ###::eshel::visu::showCalibrationLine $visuNo


         if { [llength $bestRefCoord ] == 2 } {
            #--- je recupere les coordonnees de la raie des reference
            set private($visuNo,refX) [expr int([lindex $bestRefCoord 0])]
            set private($visuNo,refY) [expr int([lindex $bestRefCoord 1])]

            #--- je recupere minorder et maxOrder
            set orderRange [::eshel::visu::getValidOrder $visuNo]
            set private($visuNo,minOrder) [lindex $orderRange 0]
            set private($visuNo,maxOrder) [lindex $orderRange 1]
            set message    "L'ordre $private($visuNo,refNum) a été reconnu sur la ligne $bestLineNo grâce à $matchedStarNb raies sur $catalogLineNb.\n"
            append message "L'angle de dispersion Alpha vaut $private($visuNo,alpha)°.\n"
            append message "La raie $private($visuNo,refLambda) a été trouvée sur l'ordre $private($visuNo,refNum) à la position x=$private($visuNo,refX) y=$private($visuNo,refY)).\n"
            append message "Vous pouvez passer à l'étape suivante."
            setResult $visuNo "selectRefLine" "ok" $message
         } else {
            set message    "L'ordre $private($visuNo,refNum) a été reconnu grace à $matchedStarNb raies sur $catalogLineNb.\n"
            append message "Mais la raie $private($visuNo,refLambda) n'a pas été trouvée.\n"
            append message "Veillez essayer une autre valeur de FWHM des raies ou faire un THAR avec un temps de pause plus long.\n"
            setResult $visuNo "selectRefLine" "error" $message
         }
      }
   }]

   if { $catchResult == 1 } {
      bell
      setResult $visuNo selectRefLine "error" $::errorInfo
   }

   $private($visuNo,This) configure -cursor arrow


}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectRefLineCheck { visuNo } {
   variable private
   console::disp "selectRefLineCheck \n"
   return 1
}


#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectRefLineBack { visuNo } {
   variable private
   console::disp "selectRefLineBack \n"

   ::eshel::visu::hideOrderLabel $visuNo
   ::eshel::visu::hideReferenceLine $visuNo
   ::eshel::visu::hideCalibrationLine $visuNo
   file delete -force $private($visuNo,selectRefLineFileName)
   set private($visuNo,selectRefLineResult) ""

   return 1
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return
#  - 1=OK
#  - 0=erreur
#
proc ::eshel::wizard::selectRefLineNext { visuNo } {
   variable private
   console::disp "selectRefLineNext \n"

   ::eshel::visu::hideOrderLabel $visuNo
   ::eshel::visu::hideReferenceLine $visuNo
   ::eshel::visu::hideCalibrationLine $visuNo

   set result [::eshel::wizard::selectRefLineCheck $visuNo ]
   if { $result == 0 } {
      #--- j'affiche le message d'erreur
      set title [$private($visuNo,This) itemcget selectRefLine -text1]
      set message "[$private($visuNo,This) itemcget  selectRefLine -text4]\n[$private($visuNo,This) itemcget  selectRefLine -text2]"
      tk_messageBox -icon error -title $title -message $message
   }

   return $result
}

###############################################################################
#  STEP selectJoinMargin
###############################################################################

#------------------------------------------------------------
# selectJoinMarginCreate
#   Etape : selection de la raie de reference
#
proc ::eshel::wizard::selectJoinMarginCreate { visuNo } {
   variable private
   variable widget
console::disp "selectJoinMarginCreate \n"
   set frm [$private($visuNo,This) widgets get selectJoinMargin].layout.clientArea
   TitleFrame $frm.param -borderwidth 1 -text "Paramètres"

   #---- entry refNum
   Label $frm.param.widthLabel -text $::caption(eshel,wizard,selectJoinMargin,width)
   grid $frm.param.widthLabel -in [$frm.param getframe] -row 1 -column 0 -sticky ns
   Entry $frm.param.widthValue  -width 6 -justify right \
      -textvariable ::eshel::wizard::private($visuNo,joinMarginWidth) \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 100 }
   grid $frm.param.widthValue -in [$frm.param getframe] -row 1 -column 1 -sticky ew

   #--- Bouton Refresh
   button $frm.param.refresh -text $::caption(eshel,wizard,refresh) \
     -borderwidth 2 -command "::eshel::wizard::selectJoinMarginRaise $visuNo"
   grid $frm.param.refresh -in [$frm.param getframe] -row 2 -column 0 -columnspan 2 -sticky {} -pady 4 -ipadx 10

   grid columnconfig [$frm.param getframe] 0 -weight 1
   grid columnconfig [$frm.param getframe] 1 -weight 1

   pack $frm.param -side top -anchor s -fill x -expand 1 -pady 2
}

#------------------------------------------------------------
# selectJoinMarginRaise
#   Recherche la raie de reference dans THAR
#
proc ::eshel::wizard::selectJoinMarginRaise { visuNo } {
   variable private
console::disp "selectJoinMarginRaise \n"

   set private($visuNo,cropLambda) [::eshel::visu::showJoinMargin $visuNo $private($visuNo,joinMarginWidth)]
   console::disp "joinMarginList=$private($visuNo,cropLambda)\n"
   set message "Vous pouvez passer à l'étape suivante."
   setResult $visuNo "selectJoinMargin" "ok" $message
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectJoinMarginBack { visuNo } {
   variable private
   console::disp "selectJoinMarginBack \n"
   ::eshel::visu::hideJoinMargin $visuNo
   set result 1
   return $result
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::selectJoinMarginNext { visuNo } {
   variable private
   console::disp "selectJoinMarginNext \n"

   set result 1
   return $result
}


###############################################################################
#  STEP done
###############################################################################

#------------------------------------------------------------
# doneCreate
#   Etape : selection de la raie de reference
#
proc ::eshel::wizard::doneCreate { visuNo } {
   variable private
   variable widget
console::disp "doneCreate \n"
   set frm [$private($visuNo,This) widgets get done].layout.clientArea

   set configId [::eshel::instrument::getCurrentConfigId]

   TitleFrame $frm.param -borderwidth 1 -text ""

   set rowNum 0
   #---- titre des colonnes
   label $frm.param.titleOld -text "Ancien\nparamètre" -justify center
   grid $frm.param.titleOld -in [$frm.param getframe] -row $rowNum -column 1 -sticky ew
   label $frm.param.titleNew -text "Nouveau\nparamètre" -justify center
   grid $frm.param.titleNew -in [$frm.param getframe] -row $rowNum -column 2 -sticky ew

   incr rowNum
   label $frm.param.spectro -text $::caption(eshel,instrument,spectrograph) -relief sunken -borderwidth 1 -justify center
   grid $frm.param.spectro -in [$frm.param getframe] -row $rowNum -column 0 -columnspan 3 -sticky ew

   foreach name { alpha } {
      incr rowNum
      label $frm.param.label$name -text $::caption(eshel,instrument,spectrograph,$name) -justify left -relief sunken -borderwidth 1
      grid $frm.param.label$name -in [$frm.param getframe] -row $rowNum -column 0 -sticky ew
      entry $frm.param.old$name  -width 6 -justify right -state readonly \
         -textvariable ::conf(eshel,instrument,config,$configId,$name)
      grid $frm.param.old$name -in [$frm.param getframe] -row $rowNum -column 1 -sticky ew
      entry $frm.param.new$name  -width 6 -justify right -state readonly \
         -textvariable ::eshel::wizard::private($visuNo,$name)
      grid $frm.param.new$name -in [$frm.param getframe] -row $rowNum -column 2 -sticky ew
   }

   incr rowNum
   label $frm.param.process -text $::caption(eshel,instrument,process) -relief sunken -borderwidth 1  -justify center
   grid $frm.param.process -in [$frm.param getframe] -row $rowNum -column 0 -columnspan 3 -sticky ew

   foreach name { minOrder maxOrder refNum refLambda refX refY } {
      incr rowNum
      label $frm.param.label$name -text $::caption(eshel,instrument,process,$name) -justify left -relief sunken -borderwidth 1
      grid $frm.param.label$name -in [$frm.param getframe] -row $rowNum -column 0 -sticky ew
      entry $frm.param.old$name  -width 6 -justify right -state readonly \
         -textvariable ::conf(eshel,instrument,config,$configId,$name)
      grid $frm.param.old$name -in [$frm.param getframe] -row $rowNum -column 1 -sticky ew
      entry $frm.param.new$name  -width 6 -justify right -state readonly \
         -textvariable ::eshel::wizard::private($visuNo,$name)
      grid $frm.param.new$name -in [$frm.param getframe] -row $rowNum -column 2 -sticky ew
   }

   grid columnconfig [$frm.param getframe] 0 -weight 1

   ####---- entry refNum
   ###Label $frm.param.refNumLabel -text $::caption(eshel,instrument,process,refNum)
   ###grid $frm.param.refNumLabel -in [$frm.param getframe] -row 2 -column 0 -sticky ns
   ###entry $frm.param.refNumOld  -width 6 -justify right -state readonly \
   ###   -textvariable ::conf(eshel,instrument,config,$configId,refNum)
   ###grid $frm.param.refNumOld -in [$frm.param getframe] -row 1 -column 1 -sticky nsew
   ###entry $frm.param.alphaNew  -width 6 -justify right -state readonly \
   ###   -textvariable ::eshel::wizard::private($visuNo,refNum)
   ###grid $frm.param.alphaNew -in [$frm.param getframe] -row 1 -column 2 -sticky nsew
   ###
   ####---- entry refLambda
   ###Label $frm.param.refLambdaLabel -text $::caption(eshel,instrument,process,refLambda)
   ###grid $frm.param.refLambdaLabel -in [$frm.param getframe] -row 2 -column 0 -sticky ns
   ###Entry $frm.param.refLambda  -width 6 -justify right \
   ###   -textvariable ::eshel::wizard::private($visuNo,refLambda) \
   ###   -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 1000.0 10000.0 }
   ###grid $frm.param.refLambda -in [$frm.param getframe] -row 2 -column 1 -sticky nsew
   ###


   pack $frm.param -side top -anchor s -fill x -expand 1 -pady 2
}

#------------------------------------------------------------
# doneRaise
#   Recherche la raie de reference dans THAR
#
proc ::eshel::wizard::doneRaise { visuNo } {
   variable private
console::disp "doneRaise \n"
   set message  "Cliquer sur Finish pour enregistrer le nouveaux paramètres de configuration."

   ::eshel::visu::showOrderLabel $visuNo
   ::eshel::visu::showMargin $visuNo

   set bestRefCoord    [lindex $private($visuNo,selectRefLineResult) 2]
   set imageLineList   [lindex $private($visuNo,selectRefLineResult) 4]
   set catalogLineList [lindex $private($visuNo,selectRefLineResult) 5]
   set matchedLineList [lindex $private($visuNo,selectRefLineResult) 6]
   ::eshel::visu::showReferenceLine $visuNo $imageLineList $catalogLineList $matchedLineList $bestRefCoord
   showCameraAxis $visuNo

   setResult $visuNo "done" "ok" $message
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::doneBack { visuNo } {
   variable private
   console::disp "doneBack \n"

   ::eshel::visu::hideOrderLabel $visuNo
   ::eshel::visu::hideMargin $visuNo
   ::eshel::visu::hideReferenceLine $visuNo
   ::eshel::visu::hideTangenteDraw $visuNo
   set result 1
   return $result
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::doneFinish { visuNo } {
   variable private
   console::disp "doneFinish \n"

   ::eshel::visu::hideOrderLabel $visuNo
   ::eshel::visu::hideMargin $visuNo

   set configId [::eshel::instrument::getCurrentConfigId]

   set ::conf(eshel,instrument,config,$configId,cropLambda) $private($visuNo,cropLambda)
   set ::conf(eshel,instrument,config,$configId,orderDefinition) [::eshel::visu::getOrderDefinition $visuNo]

   set ::conf(eshel,instrument,config,$configId,alpha)  $private($visuNo,alpha)
   set ::conf(eshel,instrument,config,$configId,refX)   $private($visuNo,refX)
   set ::conf(eshel,instrument,config,$configId,refY)   $private($visuNo,refY)

   ::eshel::instrumentgui::onSelectConfig $visuNo

   set title [$private($visuNo,This) itemcget done -text1]
   ###set message "Cet assistant est expérimental.\nLes données ne sont pas sauvegardées."
   set message "Les données ont été copiées dans les paramères de la configuration $::conf(eshel,instrument,config,$configId,configName)"
   tk_messageBox -icon info -title $title -message $message

   set result 1
   return $result
}


###############################################################################
#  STEP xxxx
###############################################################################

#------------------------------------------------------------
# xxxxCreate
#   Etape : selection de la raie de reference
#
proc ::eshel::wizard::xxxxCreate { visuNo } {
   variable private
   variable widget

   set frm [$private($visuNo,This) widgets get xxxx].layout.clientArea

   TitleFrame $frm.param -borderwidth 1 -text ""
   pack $frm.param -side top -anchor s -fill x -expand 1 -pady 2
}

#------------------------------------------------------------
# xxxxRaise
#   Recherche la raie de reference dans THAR
#
proc ::eshel::wizard::xxxxRaise { visuNo } {
   variable private

   setResult $visuNo "xxxx" "ok" $message
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::xxxxBack { visuNo } {
   variable private
   console::disp "xxxxBack \n"

   set result 1
   return $result
}

#------------------------------------------------------------
## @brief Etape : sélection du fichier FLAT
#  @param visuNo numéro de la visu
#  @return 1
#
proc ::eshel::wizard::xxxxNext { visuNo } {
   variable private
   console::disp "xxxxNext \n"

   set result 1
   return $result
}












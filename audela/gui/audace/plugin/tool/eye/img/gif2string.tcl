#------------------------------------------------------------
# @file     gif2string.tcl
# @brief    conversion de fichier gif en string
# @author   Michel PUJOL
# @version   $Id: gif2string.tcl 13563 2016-04-02 10:09:05Z rzachantke $

namespace eval ::gif2string {
   #--- declaration des variables du namespace

}

proc ::gif2string::init { } {
   variable private

   package require base64

   #--- Cree la fenetre .ohp de niveau le plus haut
   set private(this) .gif2string
   set private(initialDirectory) ""

   if { [winfo exists  $private(this) ] == 0 } {
      toplevel $private(this)
      ###wm geometry $private(this)
      wm resizable $private(this) 1 1
      wm title $private(this) "Gif => string"
      wm protocol $private(this) WM_DELETE_WINDOW "::gif2string::closeWindow "
      set private(image) [image create photo -data {
          R0lGODlhEgASAIAAAAAAAP///yH5BAEAAAEALAAAAAASABIAAAIdjI+py+0G
          wEtxUmlPzRDnzYGfN3KBaKGT6rDmGxQAOw==}]
      button $private(this).b1 -image $private(image)
      pack $private(this).b1
      text $private(this).texte -wrap none -font "Courier 10"
      pack $private(this).texte -expand 1 -fill both
      label $private(this).exempleLabel -text "Exemple de code" -justify left
      pack $private(this).exempleLabel -expand 1 -fill x -anchor w
      text $private(this).exemple -wrap none -font "Courier 10"

      pack $private(this).exemple -expand 1 -fill both
      menu $private(this).mbar
      $private(this) configure -menu $private(this).mbar
      $private(this).mbar add command -label "Encode File" -command ::gif2string::encode
      $private(this).mbar add command -label "Copy2Clipboard" -command ::gif2string::clipcopy
      $private(this).mbar add command -label "Exit" -command {::gif2string::closeWindow}

   } else {
      focus $private(this)
   }

}




proc ::gif2string::closeWindow { } {
   variable private

   destroy $private(this)
}

proc ::gif2string::encode {} {
   variable private
   $private(this).texte delete 1.0 end
   $private(this).exemple delete 1.0 end
   set fileName [ ::tk_getOpenFile -initialdir $private(initialDirectory) ]
   set fileID [open $fileName RDONLY]
   fconfigure $fileID -translation binary
   set rawData [read $fileID]
   close $fileID
   #--- je convertis l'image en chaine de caracteres
   set encodedData [base64::encode $rawData]
   #--- j'affiche la chaine dans le widget texte
   $private(this).texte insert 1.0 $encodedData
   #--- j'affiche l'image dans le bouton
   $private(image) configure -data  $encodedData
   #--- j'affiche l'exemple
   set exemple "set private(image1) \[image create photo\] \nbutton .b1 -image \$private(image1) \n...\n\$private(image1) configure -data \{$encodedData\}\ \n... \nimage delete \$private(image1)"
   $private(this).exemple insert 1.0 $exemple
   set private(initialDirectory) [file dirname $fileName]
}

proc ::gif2string::clipcopy {} {
   variable private
   clipboard clear
   clipboard append [$private(this).texte get 1.0 end]
}

::gif2string::init


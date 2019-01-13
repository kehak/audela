#
## @file eshelfile.tcl
#  @brief Assistant pour le réglage des paramètres de traitement
#  @author Michel PUJOL
#  $Id: eshelfile.tcl 13602 2016-04-04 12:38:40Z rzachantke $
#

## namespace eshel::file
#  @brief Assistant pour le réglage des paramètres de traitement

namespace eval ::eshel::file {

}

#------------------------------------------------------------
# ::eshel::process::run
#    affiche la fenetre du traitement
#
proc ::eshel::file::isLED { fileName } {
   variable private


}

#------------------------------------------------------------
## @brief retourne la valeur d'un mot clef
#  @param   hFile          handle du fichier fitd
#  @param   keywordName    nom du mot clef
#  @private
#
proc ::eshel::file::getKeyword { hFile keywordName} {
   variable private

  #--- je recupere les mots clefs dans le nom contient la valeur keywordName
   #--- cette fonction retourne une liste de triplets { name value description }

   set catchResult [ catch {
      set keywords [$hFile get keyword $keywordName]
   }]
   if { $catchResult !=0 } {
     #--- je transmets l'erreur en ajoutant le nom du mot clé
      error "keyword $keywordName not found\n$::errorInfo"
   }

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


proc ::eshel::file::findMargin { ledFileName } {

   set result [eshel_findMargin  $ledFileName \
         $::conf(eshel,tempDirectory)/led_wizard.fit \
         $width $height \
         $threshold $snNoise \
         $minOrder $maxOrder ]
      console::disp "eshel_findMargin: $result\n"

}


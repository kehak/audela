#
## @file wizardacq.tcl
#  @brief Assistant pour le réglage des paramètres de traitement
#  @author Michel PUJOL
#  $Id: wizardacq.tcl 13378 2016-03-15 21:19:06Z rzachantke $
#

## namespace eshel::wizardacq
#  @brief Assistant pour le réglage des paramètres de traitement

namespace eval ::eshel::wizardacq {

}



#------------------------------------------------------------
# goAcquisitionLed
#   supprime les ressources specifiques
#   et sauvegarde les parametres avant de fermer la fenetre
#
proc ::eshel::wizardacq::goAcquisitionLed { visuNo } {
   variable private

   set catchResult [catch {
     #--- acquisition
     ::eshel::acquisition::startSequence $visuNo [list ledSerie [list expNb 1 expTime 10]]

     #--- traitement
     ::eshel::checkDirectory
     ::eshel::process::generateNightlog
     ::eshel::process::generateProcessBias
     ::eshel::process::generateScript

     #--- j'initialise le roadmap a vide
     set nightNode [::dom::tcl::document cget $private(nightlog) -documentElement]

     set roadmapNode [lindex [set [::dom::element getElementsByTagName $nightNode PROCESS ]] 0]
     if { $roadmapNode != "" } {
        ::dom::tcl::destroy $roadmapNode
     }
     set roadmapNode [::dom::document createElement $nightNode PROCESS ]

     #--- je recupere la liste des series identifiées
     set filesNode [::eshel::process::getFilesNode]




   }]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
      tk_messageBox -icon error -title $title -message $errorMessage
      setResult $visuNo selectLed "error" $::errorInfo
   }

}

## @file sampTools.tcl
# @brief Methodes du protocole SAMP de communication entre applications (http://ivoa.net/documents/SAMP/index.html)
# @author J. Berthier (berthier@imcce.fr)
# @par Ressource
# @code source [file join $audace(rep_install) gui audace plugin tool vo_tools sampTools.tcl]
# @endcode

# $Id: sampTools.tcl 13890 2016-05-23 16:35:52Z jberthier $

##
# @namespace SampTools
# @brief Implementation du protocole SAMP de communication entre applications (http://ivoa.net/documents/SAMP/index.html)
# @pre Requiert le fichier d'internationalisation \c sampTools.cap .
#
namespace eval ::SampTools {
   package provide SampTools 1.0

   #--- Chargement des captions
   source [ file join [file dirname [info script]] sampTools.cap ]
}

## @brief Connection au hub Samp
# @return true si le hub est connecte, sinon false
#
proc ::SampTools::connect {} {
   global caption
   if { [::Samp::check] == 1 } {
      ::console::affiche_resultat "$caption(SampTools,samp_connected) \n"
      return true
   } else {
      ::console::affiche_erreur "$caption(SampTools,samp_hubnotfound) \n"
      return false
   }
}

## @brief Deconnection du hub Samp
#
proc ::SampTools::disconnect {} {
   ::Samp::destroy
}

## @brief Broadcast l'image courante
# @return true si l'image a ete envoyee, sinon false 
#
proc ::SampTools::broadcastImage {} {
   global audace caption

   if { [::Samp::check] == 0 } {
      ::console::affiche_erreur "$caption(SampTools,samp_hubnotfound) \n"
      return false
   }

   set image [::confVisu::getFileName $::audace(visuNo)]
   if { [file exists $image] } {
      set imgFile [::Samp::convertEntities $image]
      set url "file://localhost/$imgFile"
      ::console::affiche_resultat "$caption(SampTools,samp_imgtobroadcast) $image \n"
      set msg [::samp::m_imageLoadFits $::samp::key [list samp.mtype image.load.fits samp.params [list "name" "$url" "image-id" "$url" "url" "$url"] ]]
      return true
   } else {
      ::console::affiche_erreur "$caption(SampTools,samp_noimgtobroadcast) \n"
      return false
   }
}

## @brief Broadcast la VOTable courante
# @return true si la table a ete envoyee, sinon false
#
proc ::SampTools::broadcastTable {} {
   global caption

   if { [::Samp::check] == 0 } {
      ::console::affiche_erreur "$caption(SampTools,samp_hubnotfound) \n"
      return false
   }

   if { [info exists ::votableUtil::votBuf(file)] && [file exists $::votableUtil::votBuf(file)] } {
      set imgTab [::Samp::convertEntities $::votableUtil::votBuf(file)]
      set url "file://localhost/$imgTab"
      ::console::affiche_resultat "$caption(SampTools,samp_tabtobroadcast) $::votableUtil::votBuf(file)\n"
      set msg [::samp::m_tableLoadVotable $::samp::key [list samp.mtype table.load.votable samp.params [list "name" "$url" "table-id" "$url" "url" "$url"] ]]
      return true
   } else {
      ::console::affiche_erreur "$caption(SampTools,samp_notabtobroadcast) \n"
      return false
   }
}

## @brief Broadcast le spectre courant
# @return true si le spectre a ete envoye, sinon false
#
proc ::SampTools::broadcastSpectrum {} {
   global audace caption

   if { [::Samp::check] == 0 } {
      ::console::affiche_erreur "$caption(SampTools,samp_hubnotfound) \n"
      return false
   }

   set spectrum [::confVisu::getFileName $::audace(visuNo)]
   if { [file exists $spectrum] } {
      set speFile [::Samp::convertEntities $spectrum]
      set url "file://localhost/$speFile"
      ::console::affiche_resultat "$caption(SampTools,samp_spetobroadcast) $spectrum \n"
      set msg [::samp::m_spectrumLoadSsaGeneric $::samp::key [list samp.mtype spectrum.load.ssa-generic samp.params [list "name" "$url" "spectrum-id" "$url" "url" "$url"] ]]
      return true
   } else {
      ::console::affiche_erreur "$caption(SampTools,samp_nospetobroadcast) \n"
      return false
   }
}

## @brief Broadcast les coordonnees du point clique dans la visu
# @param w chemin de la fenetre d'ou provient le clic
# @param x coordonnees x du point envoye
# @param y coordonnees y du point envoye
#
proc ::SampTools::broadcastPointAtSky { w x y } {
   global audace

   # Recupere la valeur courante du zoom
   set zoom [::confVisu::getZoom $::audace(visuNo)]
   # Recupere les dimensions de l'image en px
   set naxis1 [expr [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1] * $zoom]
   set naxis2 [expr [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1] * $zoom]
   # Converti les coord. pointees en coord. canvas
   set coord [::audace::screen2Canvas [list $x $y]]
   # Converti les coordonnees canvas en coordonnees x,y dans l'image
   set imgXY [::audace::canvas2Picture $coord]
   # Converti les coordonnees x,y dans l'image en coordonnees sur le ciel
   set err [catch {buf$audace(bufNo) xy2radec $imgXY} RADEC ]
   ::console::affiche_resultat "$w \n Audela->Samp RA DEC = [lindex $RADEC 0] [lindex $RADEC 1]  (Screen: $x $y ; Canva: $coord  ; Img: $imgXY)\n"
   if {$err == 0} {
      # Broadcast les coordonnees
      set msg [::samp::m_coordPointAtSky $::samp::key [list samp.mtype coord.pointAt.sky samp.params [list "ra" [lindex $RADEC 0] "dec" [lindex $RADEC 1]] ]]
   }

}

## @brief Envoie d'un script Aladin
# @param script Script Aladin (e.g. 'get Aladin(DSS2) 198.69107026467 +9.085315305339 15arcmin; sync; get VizieR(USNO2); sync; set USNO2 shape=triangle')
# @return true si aucune erreur, sinon false
#
proc ::SampTools::broadcastAladinScript { script } {
   global caption

   if { [::Samp::check] == 0 } {
      ::console::affiche_erreur "$caption(SampTools,samp_hubnotfound) \n"
      return false
   }

   ::console::affiche_resultat "$caption(SampTools,samp_sendaladinscript) $script \n"
   set msg [::samp::m_sendAladinScript $::samp::key [list samp.mtype script.aladin.send samp.params [list "script" "$script"] ]]
   return true

}

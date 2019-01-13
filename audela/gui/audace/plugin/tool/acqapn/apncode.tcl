#
# Fichier : apncode.tcl
# Description : Transcodage des variables de commande des APN
# Auteur : Raymond ZACHANTKE
# Mise à jour $Id: apncode.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

#============================================================
# Declaration du namespace acqapn
#    initialise le namespace
#============================================================
namespace eval ::acqapn {
}

# VerifData
#--- Verification des valeurs
#
proc ::acqapn::VerifData { reglage } {
   variable private

   switch -exact $reglage {
      lens        { set private(coolpix,dzoom)         [::acqapn::Dzoom $private(coolpix,lens)] }
      metering    { set private(coolpix,code_metering) [::acqapn::Metering $private(coolpix,metering)] }
      format      { ::acqapn::Resolution }
      compression { ::acqapn::Resolution }
   }
}

# Dzoom
#--- Codage du digital zoom a partir de lens
#
proc ::acqapn::Dzoom { lens } {
   switch -exact $lens {
      FishEye   { set dzoom "2" }
      Wide      { set dzoom "4" }
      Telephoto { set dzoom "8" }
   }
   return $dzoom
}

# Metering
#--- Codage du digital metering a partir de metering
#
proc ::acqapn::Metering { metering } {
   switch -exact $metering {
      Center       { set code "2" }
      Spot         { set code "3" }
      Matrix       { set code "5" }
      Spot-AF-Area { set code "6" }
   }
   return $code
}

#
# Resolution
#--- Cette commande est appelee pour definir la commande de resolution
#--- en fonction du format et de la compression
#
proc ::acqapn::Resolution { } {
   variable private

   #--- La combinaison format+compression est verifiee
   set cmdresol "$private(coolpix,format)-$private(coolpix,compression)"

   switch -exact -- $cmdresol {
      VGA-Basic   { set private(coolpix,resolution) "1" }
      VGA-Normal  { set private(coolpix,resolution) "2" }
      VGA-Fine    { set private(coolpix,resolution) "3" }
      SXGA-Basic  { set private(coolpix,resolution) "4" }
      SXGA-Normal { set private(coolpix,resolution) "5" }
      SXGA-Fine   { set private(coolpix,resolution) "6" }
      XGA-Basic   { set private(coolpix,resolution) "7" }
      XGA-Normal  { set private(coolpix,resolution) "8" }
      XGA-Fine    { set private(coolpix,resolution) "9" }
      UXGA-Basic  { set private(coolpix,resolution) "10" }
      UXGA-Normal { set private(coolpix,resolution) "11" }
      UXGA-Fine   { set private(coolpix,resolution) "12" }
      -Basic      { set private(coolpix,resolution) "17" }
      -Normal     { set private(coolpix,resolution) "18" }
      -Fine       { set private(coolpix,resolution) "19" }
      3:2-Basic   { set private(coolpix,resolution) "26" }
      3:2-Normal  { set private(coolpix,resolution) "27" }
      3:2-Fine    { set private(coolpix,resolution) "28" }
      3:2-Hi      { set private(coolpix,resolution) "38" }
      MAX-Basic   { set private(coolpix,resolution) "29" }
      MAX-Normal  { set private(coolpix,resolution) "30" }
      MAX-Fine    { set private(coolpix,resolution) "31" }
      MAX-Hi      { set private(coolpix,resolution) "33" }
      MAX-Raw     { set private(coolpix,resolution) "55" }
      default     { set private(coolpix,resolution) "-1" ; ::acqapn::ErrComm 3 }
   }
}

#
# ReverseDzoom
#--- Decodage du digital zoom en lens
#
proc ::acqapn::ReverseDzoom { } {
   variable private

   switch -exact $private(dzoom) {
      0       { set private(coolpix,lens) "Telephoto" ; set private(coolpix,dzoom) "8" }
      2       { set private(coolpix,lens) "Wide" }
      4       { set private(coolpix,lens) "FishEye" }
      default { ::acqapn::ErrComm 4 }
   }
}

#
# ReverseResolution
#---Definition du format et de la compression en fonction de la resolution
#
proc ::acqapn::ReverseResolution { } {
   variable private

   switch -exact -- $private(coolpix_init,resolution) {
      1       { set private(coolpix_init,format) "VGA"  ; set private(coolpix_init,compression) "Basic" }
      2       { set private(coolpix_init,format) "VGA"  ; set private(coolpix_init,compression) "Normal" }
      3       { set private(coolpix_init,format) "VGA"  ; set private(coolpix_init,compression) "Fine" }
      4       { set private(coolpix_init,format) "SXGA" ; set private(coolpix_init,compression) "Basic" }
      5       { set private(coolpix_init,format) "SXGA" ; set private(coolpix_init,compression) "Normal" }
      6       { set private(coolpix_init,format) "SXGA" ; set private(coolpix_init,compression) "Fine" }
      7       { set private(coolpix_init,format) "XGA"  ; set private(coolpix_init,compression) "Basic" }
      8       { set private(coolpix_init,format) "XGA"  ; set private(coolpix_init,compression) "Normal" }
      9       { set private(coolpix_init,format) "XGA"  ; set private(coolpix_init,compression) "Fine" }
      10      { set private(coolpix_init,format) "UXGA" ; set private(coolpix_init,compression) "Basic" }
      11      { set private(coolpix_init,format) "UXGA" ; set private(coolpix_init,compression) "Normal" }
      12      { set private(coolpix_init,format) "UXGA" ; set private(coolpix_init,compression) "Fine" }
      17      { set private(coolpix_init,format) ""     ; set private(coolpix_init,compression) "Basic" }
      18      { set private(coolpix_init,format) ""     ; set private(coolpix_init,compression) "Normal" }
      19      { set private(coolpix_init,format) ""     ; set private(coolpix_init,compression) "Fine" }
      26      { set private(coolpix_init,format) "3:2"  ; set private(coolpix_init,compression) "Basic" }
      27      { set private(coolpix_init,format) "3:2"  ; set private(coolpix_init,compression) "Normal" }
      28      { set private(coolpix_init,format) "3:2"  ; set private(coolpix_init,compression) "Fine" }
      29      { set private(coolpix_init,format) "MAX"  ; set private(coolpix_init,compression) "Basic" }
      30      { set private(coolpix_init,format) "MAX"  ; set private(coolpix_init,compression) "Normal" }
      31      { set private(coolpix_init,format) "MAX"  ; set private(coolpix_init,compression) "Fine" }
      33      { set private(coolpix_init,format) "MAX"  ; set private(coolpix_init,compression) "Hi" }
      38      { set private(coolpix_init,format) "3:2"  ; set private(coolpix_init,compression) "Hi" }
      55      { set private(coolpix_init,format) "MAX"  ; set private(coolpix_init,compression) "Raw" }
      default { ::acqapn::ErrComm 5 }
   }
}

#
# Exposure
#--- Cette commande est appelee pour definir la commande et la valeur d'exposition
#
proc ::acqapn::Exposure { var exposure } {
   variable private
   global panneau

   set valeur [expr int($exposure*10)]
   set code_exposure [expr abs($valeur)]
   set exposurecmd  "exposure+"
   if { $valeur < "0" } { set exposurecmd "exposure-" }
   set panneau(coolpix$var,exposurecmd) $exposurecmd
   set private(coolpix$var,code_exposure) $code_exposure
}


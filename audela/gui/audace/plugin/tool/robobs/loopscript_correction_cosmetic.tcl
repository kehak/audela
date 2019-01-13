## @file      loopscript_correction_cosmetic.tcl
#  @brief     Explication du fichier ?
#  @pre       This script will be sourced in the loop
#  @note      A completer
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_correction_cosmetic.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_correction_cosmetic.tcl 14446 2018-06-20 18:43:07Z fredvachier $

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
   if {$robobs(image,ffilenames)!=""} {
      ::robobs::log "Corrections cosmetic : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   }
   foreach fname $robobs(image,ffilenames) {
      buf$bufNo load $fname
      # --- cosmetic
      set naxis1 [buf$bufNo getpixelswidth]
      set naxis2 [buf$bufNo getpixelsheight]
      set bin2 [lindex [buf$bufNo getkwd BIN2] 1]
      set camera [lindex [buf$bufNo getkwd CAMERA] 1]
      set camera [lrange $camera 0 1]
      if {$camera=="SBIG STL-11000"} {
         set x1 1
         set x2 $naxis1
         set y1 2
         set y2 [expr $naxis2-16/$bin2]
         set box [list $x1 $y1 $x2 $y2]
         ::robobs::log "Corrections cosmetic : fname=$fname window=$box"
         buf$bufNo window $box
      }
      buf$bufNo save $fname
   }
}
if {$robobs(planif,mode)=="trerrlyr"} {
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   set camera [lindex [buf$bufNo getkwd CAMERA] 1]
   set camera [lrange $camera 0 1]   
   if {$camera=="AltaF-9000 KAF09000"} {
      foreach fname $robobs(image,ffilenames) {
         buf$bufNo load $fname
         buf$bufNo mirrorx
         buf$bufNo save $fname
      }
   }
}


# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""

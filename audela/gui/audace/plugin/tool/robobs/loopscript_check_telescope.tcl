## @file      loopscript_check_telescope.tcl
#  @brief     According to the value of robobs(conf,telescope,telno,value),
#  @brief     determines if the connection is well established with the
#  @brief     telescope.
#  @pre       This script will be sourced in the loop
#  @note      If robobs(conf,telescope,telno,value) = 0, it means that no
#             telescope is connected. Then we consider a simulation telescope
#             for the next scripts to source.
#             Input variables, other than robobs(conf,*) :
#             None
#             Output variables :
#             robobs(tel,name) = Name of the telescope
#             robobs(tel,connected) = 1 if the connection is OK, else =0
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_check_telescope.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_check_telescope.tcl 14446 2018-06-20 18:43:07Z fredvachier $


# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script

# --- Telescope name: simulation or real
set telNo $robobs(conf,telescope,telno,value)
if {$telNo==0} {
   set robobs(tel,name) simulation
   set robobs(tel,connected) 1
} else {
   set robobs(tel,name) [tel$telNo name]
   set robobs(tel,connected) [tel$telNo drivername]
   # --- verify the status of motors
   if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
      if {$robobs(tel,name)=="ETEL"} {
         set msg [tel$telNo geterror]
         lassign $msg err0 err1
         if {[lindex $err0 0]!=0} {
            ::robobs::log "$robobs(tel,name) Hour angle axis error $err0"
            ::robobs::log "Try tel$telNo reset 1 0"
            tel$telNo reset 1 0
            after 1000
         }
         if {[lindex $err1 0]!=0} {
            ::robobs::log "$robobs(tel,name) Declination axis error $err1"
            ::robobs::log "Try tel$telNo reset 0 1"
            tel$telNo reset 0 1
            after 1000
         }
      }
   }
}

# --- Reconnect the tel if necessary (TBD in a personal script)

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""

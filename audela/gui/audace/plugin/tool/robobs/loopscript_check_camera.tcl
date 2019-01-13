## @file      loopscript_check_camera.tcl
#  @brief     According to the value of robobs(conf,camera,camno,value),
#             determines if the connection is well established with the
#             camera.
#  @pre       This script will be sourced in the loop
#  @warning   If robobs(conf,camera,camno,value) = 0, it means that no
#             camera is connected. Then we consider a simulation camera
#             for the next scripts to source.
#             Input variables, other than robobs(conf,*) :
#             None
#             Output variables :
#             robobs(cam,name) = Name of the camera
#             robobs(cam,connected) = 1 if the connection is OK, else =0
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_check_camera.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_check_camera.tcl 14445 2018-06-20 15:09:29Z fredvachier $


# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script

# --- Camera name: simulation or real
set camNo $robobs(conf,camera,camno,value)
if {$camNo==0} {
   set robobs(cam,name) simulation
   set robobs(cam,connected) 1
} else {
   set robobs(cam,name) [cam$camNo name]
   set robobs(cam,connected) [cam$camNo drivername]
}

# --- Reconnect the cam if necessary (TBD in a personal script)

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""

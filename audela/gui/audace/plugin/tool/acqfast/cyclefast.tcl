#
# Fichier : cyclefast.tcl
# Description : Observation en automatique
# Auteur : Matteo SCHIAVON
# Mise à jour $Id: cyclefast.tcl 12731 2016-01-19 18:09:22Z robertdelmas $
#
# source audace/plugin/tool/acqfast/cyclefast.tcl
#

#============================================================
# Declaration du namespace cyclefast
#    initialise le namespace
#============================================================
namespace eval ::cyclefast {

   variable cycle
   global panneau

   proc testCamera { visuNo } {
      global caption

      set integre oui

      #--- Tester si une camera est bien selectionnee
      if { [ ::confVisu::getCamItem $visuNo ] == "" } {
         ::audace::menustate disabled
         set choix [ tk_messageBox -title $caption(cyclefast,pb) -type ok \
            -message $caption(cyclefast,selcam) ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            ::confCam::run
         }
         ::audace::menustate normal
      }

      return $integre
   }



   proc init { visuNo } {
      variable cycle
      global panneau caption

      set namefile $panneau(acqfast,$visuNo,cycfile)

      ::cyclefast::disable_button $visuNo

      if { [::cyclefast::testCamera $visuNo] != "oui" } {
         ::cyclefast::enable_button $visuNo
         return
      }

      # test for the presence of the GPS and its synchronization
      if { ! [ info exists ::acqfast::gps::flag ] } {
         ::acqfast::Message $visuNo console $caption(cyclefast,errgps_console)
         tk_messageBox -title $caption(cyclefast,errgps_title) -type ok \
            -message $caption(cyclefast,errgps_message)
         ::cyclefast::enable_button $visuNo
         return
      } elseif { $::acqfast::gps::flag == "0" } {
         ::acqfast::Message $visuNo console $caption(cyclefast,warngps_console)
      }

      set panneau(acqfast,$visuNo,maxframe) [cam$panneau(acqfast,$visuNo,camNo) maxbuffer]
      if { $panneau(acqfast,$visuNo,cycle,state) == "WAIT" } {
         cam$panneau(acqfast,$visuNo,camNo) videomode "ffr"
         set panneau(acqfast,$visuNo,mode) "0"
      }

      set cycle(startdate) ""

      if { [::cyclefast::parse $namefile] != "yes" } {
         ::cyclefast::enable_button $visuNo
         return
      }

      set cycle(stop) 0
      set cycle(index) 0
      if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $cycle(startdate) dateiso aa mm jj sep h m s sd] } {
         set cycle(timestart) [ mc_date2jd $cycle(startdate) ]
      } else {
         set cycle(timestart) [::acqfast::gps::timejd]
      }
      set cycle(timenext) $cycle(timestart)

      #puts "Cycle starting at $cycle(timestart)"
      #set date [::acqfast::gps::timejd]
      #puts "Now we are at $date"

      ::cyclefast::run $visuNo
   }

   proc disable_button { visuNo } {

      global panneau

      $panneau(acqfast,$visuNo,This).stop.but               configure -state disabled
      $panneau(acqfast,$visuNo,This).go_stop.but            configure -state disabled
      $panneau(acqfast,$visuNo,This).display.live.but       configure -state disabled
      $panneau(acqfast,$visuNo,This).pose.entr              configure -state disabled
      $panneau(acqfast,$visuNo,This).video.mode.but         configure -state disabled
      $panneau(acqfast,$visuNo,This).video.framerate.entr   configure -state disabled
      $panneau(acqfast,$visuNo,This).save.but               configure -state disabled
      $panneau(acqfast,$visuNo,This).display.frame.entr     configure -state disabled
      $panneau(acqfast,$visuNo,This).display.prev_next.prev configure -state disabled
      $panneau(acqfast,$visuNo,This).display.prev_next.next configure -state disabled
      $panneau(acqfast,$visuNo,This).display.but            configure -state disabled
      $panneau(acqfast,$visuNo,This).cycle.but              configure -state disabled

      bind all <Key-Escape> "::cyclefast::stop $visuNo"

   }


   proc enable_button { visuNo } {

      global panneau

      $panneau(acqfast,$visuNo,This).stop.but               configure -state normal
      $panneau(acqfast,$visuNo,This).go_stop.but            configure -state normal
      $panneau(acqfast,$visuNo,This).display.live.but       configure -state normal
      $panneau(acqfast,$visuNo,This).pose.entr              configure -state normal
      $panneau(acqfast,$visuNo,This).video.mode.but         configure -state normal
      $panneau(acqfast,$visuNo,This).video.framerate.entr   configure -state normal
      $panneau(acqfast,$visuNo,This).save.but               configure -state normal
      $panneau(acqfast,$visuNo,This).display.frame.entr     configure -state normal
      $panneau(acqfast,$visuNo,This).display.prev_next.prev configure -state normal
      $panneau(acqfast,$visuNo,This).display.prev_next.next configure -state normal
      $panneau(acqfast,$visuNo,This).display.but            configure -state normal
      $panneau(acqfast,$visuNo,This).cycle.but              configure -state normal

      bind all <Key-Escape> "::acqfast::Stop $visuNo"


   }

   proc parse { file } {
      variable cycle

      set cycle(action) ""
      set cycle(exp) ""
      set cycle(framerate) ""
      set cycle(timejd) ""

      set fp [open "$file" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      if { [lindex [join [split [lindex $data 0]]] 0] == "startdate" } {
         set cycle(startdate) [lindex [join [split [lindex $data 0]]] 1]
         set data [lreplace $data 0 0]
      }
      foreach line $data {
         if { [ string index $line 0 ] == "#" } {
            continue
         }
         set line [split $line]
         set line [join $line]
         if { [lindex $line 0] != "" } { lappend cycle(action) [lindex $line 0] }
         if { [lindex $line 1] != "" } { lappend cycle(exp) [lindex $line 1] }
         if { [lindex $line 2] != ""} { lappend cycle(framerate) [lindex $line 2] }
         set t [lindex $line 3]
         if { [regexp {(\d+):(\d+):(\d+)\.*(\d*)} $t all h m s sd] } {
            lappend cycle(timejd) [expr $h./24.+$m./1440.+$s.$sd/86400.]
         }
      }

      # syntax control
      set res "yes"
      if { [lindex $cycle(action) 0] != "start" } {
         ::console::disp "The cycle must start with start\n"
         set res "no"
      }
      foreach l [lrange $cycle(action) 1 [ expr [llength $cycle(action)] - 2 ] ] {
         if { $l != "continue" } {
            ::console::disp "Invalid operation: $l\n"
            set res "no"
         }
      }
      if { [lindex $cycle(action) [ expr [llength $cycle(action)] - 1 ] ] != "stop" } {
         ::console::disp "The cycle must end with stop\n"
         set res "no"
      }
      set len [expr [llength $cycle(action)] - 1]
      if { ([llength $cycle(exp)] != $len) || ([llength $cycle(framerate)] != $len) || ([llength $cycle(timejd)] != $len) } {
         ::console::disp "Invalid sintax\n"
         set res "no"
      }

      #puts $cycle(action)
      #puts $cycle(exp)
      #puts $cycle(framerate)
      #puts $cycle(timejd)

      return $res
   }

   proc start { visuNo } {
      global panneau
      variable cycle

      #cam$panneau(acqfast,$visuNo,camNo) videomode "ffr"
      #set panneau(acqfast,$visuNo,mode) "0"
      cam$panneau(acqfast,$visuNo,camNo) exposure [lindex $cycle(exp) $cycle(index)]
      set panneau(acqfast,$visuNo,pose) [cam$panneau(acqfast,$visuNo,camNo) exposure]
      cam$panneau(acqfast,$visuNo,camNo) framerate [lindex $cycle(framerate) $cycle(index)]
      set panneau(acqfast,$visuNo,framerate) [cam$panneau(acqfast,$visuNo,camNo) framerate]

      set panneau(acqfast,$visuNo,cycle,action) "1"

   }


   proc cont { visuNo } {
      global panneau
      variable cycle

      cam$panneau(acqfast,$visuNo,camNo) exposure [lindex $cycle(exp) $cycle(index)]
      set panneau(acqfast,$visuNo,pose) [cam$panneau(acqfast,$visuNo,camNo) exposure]
      cam$panneau(acqfast,$visuNo,camNo) framerate [lindex $cycle(framerate) $cycle(index)]
      set panneau(acqfast,$visuNo,framerate) [cam$panneau(acqfast,$visuNo,camNo) framerate]

   }

   proc stop { visuNo } {
      variable cycle
      global panneau

      set panneau(acqfast,$visuNo,cycle,action) "2"
      #while { $panneau(acqfast,$visuNo,cycle,state) != "WAIT" } {
      #   set panneau(acqfast,$visuNo,cycle,action) "2"
      #}
      ::cyclefast::enable_button $visuNo
      set cycle(stop) 1
   }

   proc run { visuNo } {
      variable cycle

      if { $cycle(stop) == 1 } {
         return
      }

      set data [::acqfast::gps::timejd]
      #puts "Now: $data ---> Next event: $cycle(timenext)"

      if { [::acqfast::gps::timejd] >= $cycle(timenext) } {

         set action [lindex $cycle(action) $cycle(index)]
         if { $action == "start" } {
            ::cyclefast::start $visuNo
         } elseif { $action == "continue" } {
            ::cyclefast::cont $visuNo
         } elseif { $action == "stop" } {
            ::cyclefast::stop $visuNo
            #return
         } else {
            ::console::disp "ERROR: not recognized action \n"
            return
         }

         if { $action != "stop" } {
            set cycle(timenext) [expr $cycle(timenext) + [lindex $cycle(timejd) $cycle(index)]]
         }
         #puts "Performed event $action -> Next event $cycle(timenext)"
         #puts "   index = $cycle(index)"
         incr cycle(index)
         #puts "   nextindex = $cycle(index)"

      }

      after 100 ::cyclefast::run $visuNo

   }

}


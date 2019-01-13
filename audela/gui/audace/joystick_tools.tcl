#
## @file joystick_tools.tcl
#  @brief Outil pour les joysticks
#  @author Alain KLOTZ
#  @remark pour les commandes accessibles sous Windows 7+ consulter l'aide "../audela/lib/mkLibsdl1.0/mkLibsdl10.htm"
#  $Id: joystick_tools.tcl 13749 2016-04-25 21:01:00Z rzachantke $
#

#  source "$audace(rep_install)/gui/audace/joystick_tools.tcl"
#

## @brief fermeture du canal
proc joystick_close { } {
   global audace
   if {$audace(joystick,have)==0} {
      return ""
   }
   if { $::tcl_platform(os) == "Linux" } {
      set err [catch {close $audace(joystick,channel)} msg ]
      set audace(joystick,elements,def) ""
   }
   set audace(joystick,have) 0
   return ""
}

## @brief fait l'inventaire des accessoires
#  @return id du channel
#
proc joystick_open { {dev /dev/input/js0} } {
   global audace

   # --- open device
   if {[info exists audace(joystick,have)]==0} {
      set audace(joystick,have) 0
   }

   if {$audace(joystick,have)==0} {
      set audace(joystick,have) 0
      if { $::tcl_platform(os) == "Linux" } {
         set err [catch {open $dev r+} msg ]
      } else {
         set err [catch {package require mkLibsdl} msg ]
      }
      if {$err==0} {
         set audace(joystick,have) 1
         if { $::tcl_platform(os) == "Linux" } {
            set f $msg
            fconfigure $f -blocking 0 -encoding binary
            set audace(joystick,channel) $f
            # --- read the first frame for inits
            set events [joystick_resource_read]
            set ne [llength $events]
            set audace(joystick,elements,def) ""
            for {set ke 0} {$ke<$ne} {incr ke} {
               set event [lindex $events $ke]
               lassign $event t type num v
               if {$type>128} {
                  set typedef [expr $type-128]
                  set typedef [joystick_resource_type_num2char $typedef]
                  lappend audace(joystick,elements,def) [list $t $typedef $num]
                  set t0 $t
                  set dt [expr $t-$t0]
                  set audace(joystick,elements,prev_state,$typedef,$num) ""
                  set audace(joystick,elements,cure_state,$typedef,$num) ""
                  lappend audace(joystick,elements,prev_state,$typedef,$num) [list $t $v]
                  lappend audace(joystick,elements,cure_state,$typedef,$num) [list $dt $v]
                  #console::affiche_resultat "audace(joystick,elements,prev_state,$typedef,$num)=$audace(joystick,elements,prev_state,$typedef,$num)\n"
               }
            }
         } else {
            set audace(joystick,channel) 0
            set nbu [joystick info $audace(joystick,channel) buttons]
            set nax [joystick info $audace(joystick,channel) axes]
            set nba [joystick info $audace(joystick,channel) balls]
            set nha [joystick info $audace(joystick,channel) hats]
            set t 0
            set v 0
            set audace(joystick,elements,def) ""
            set typedef button ; # buttons
            for {set num 0} {$num<$nbu} {incr num} {
               set audace(joystick,elements,prev_state,$typedef,$num) ""
               set audace(joystick,elements,cure_state,$typedef,$num) ""
               lappend audace(joystick,elements,prev_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,cure_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,def) [list $typedef $num]
            }
            set typedef axis ; # axes
            for {set num 0} {$num<$nax} {incr num} {
               set audace(joystick,elements,prev_state,$typedef,$num) ""
               set audace(joystick,elements,cure_state,$typedef,$num) ""
               lappend audace(joystick,elements,prev_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,cure_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,def) [list $typedef $num]
            }
            set typedef ball ; # balls
            for {set num 0} {$num<$nba} {incr num} {
               set audace(joystick,elements,prev_state,$typedef,$num) ""
               set audace(joystick,elements,cure_state,$typedef,$num) ""
               lappend audace(joystick,elements,prev_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,cure_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,def) [list $typedef $num]
            }
            set typedef hat ; # hats
            for {set num 0} {$num<$nha} {incr num} {
               set audace(joystick,elements,prev_state,$typedef,$num) ""
               set audace(joystick,elements,cure_state,$typedef,$num) ""
               lappend audace(joystick,elements,prev_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,cure_state,$typedef,$num) [list $t $v]
               lappend audace(joystick,elements,def) [list $typedef $num]
            }
         }
      } else {
         set audace(joystick,have) 0
         error "Joystick driver not found : $err : $msg"
      }
   }
   return $audace(joystick,channel)
}

## @brief retourne la valeur d'un accessoire défini par son type et son id
proc joystick_get { type num {update 1} } {
   global audace

   if {$audace(joystick,have)==0} {
      return ""
   }

   if { $::tcl_platform(os) == "Linux" } {
      if {$update==1} {
         joystick_resource_update
      }
      set dtv $audace(joystick,elements,cure_state,$type,$num)
      #console::affiche_resultat "Etape 100 type=$type num=$num dtv=$dtv\n"
      set v [lindex [lindex $dtv 0] 1]
   } else {
      set v [joystick get $audace(joystick,channel) $type $num]
   }
   return $v
}

## @brief retourne une liste de listes { type id valeur }
#  @code
#  joystick_getall
#  # {button 0 0} {button 1 0} {button 2 0} {button 3 0} {button 4 0} {button 5 0} {button 6 0} {button 7 0} {button 8 0} {button 9 0} {axis 0 0} {axis 1 0} {axis 2 0} {axis 3 0
#  @endcode
#
proc joystick_getall { } {
   global audace

   if {$audace(joystick,have)==0} {
      return ""
   }
   set tns $audace(joystick,elements,def)

   if { $::tcl_platform(os) == "Linux" } {
      joystick_resource_update
   }
   set res ""
   foreach tn $tns {
      if {$::tcl_platform(os) eq "Linux" } {
         lassign $tn t type num
      } elseif {$::tcl_platform(os) eq "Windows NT" } {
         lassign $tn type num
      }
      set v [joystick_get $type $num 0]
      lappend res [list $type $num $v]
   }
   return $res
}

# ##################################################################################
# ### Resources ####################################################################
# ##################################################################################

proc joystick_resource_type_char2num {type} {
   set typedef 0
   if {$type=="button"} {
      set typedef 1
   }
   if {$type=="axis"} {
      set typedef 2
   }
   if {$type=="ball"} {
      set typedef 3
   }
   if {$type=="hat"} {
      set typedef 4
   }
   return $typedef
}

proc joystick_resource_type_num2char {type} {
   set typedef unknown
   if {$type==1} {
      set typedef "button"
   }
   if {$type==2} {
      set typedef "axis"
   }
   if {$type==3} {
      set typedef "ball"
   }
   if {$type==4} {
      set typedef "hat"
   }
   return $typedef
}

## @brief spécifique à Linux et à meteosensor
proc joystick_resource_read { } {
   global audace

   if {$audace(joystick,have)==0} {
      return
   }
   set channel $audace(joystick,channel)
   if { $::tcl_platform(os) == "Linux" } {
      set superligne [read $channel]
      set superdecode ""
      if {$superligne!=""} {
         set nc [expr [string length $superligne]/8]
         for {set kc 0} {$kc<$nc} {incr kc} {
            set kc1 [expr $kc*8]
            set kc2 [expr $kc1+8-1]
            set event [string range $superligne $kc1 $kc2]
            # === time
            set t 0
            set c [string index $event 0] ; set d [meteosensor_convert_base $c ascii 10]
            set t [expr $t+$d]
            set c [string index $event 1] ; set d [meteosensor_convert_base $c ascii 10]
            set t [expr $t+$d*256]
            set c [string index $event 2] ; set d [meteosensor_convert_base $c ascii 10]
            set t [expr $t+$d*256*256]
            set c [string index $event 3] ; set d [meteosensor_convert_base $c ascii 10]
            set t [expr $t+$d*256*256*256]
            # === value
            set v 0
            set c [string index $event 4] ; set d [meteosensor_convert_base $c ascii 10]
            set v [expr $v+$d]
            set c [string index $event 5] ; set d [meteosensor_convert_base $c ascii 10]
            set v [expr $v+$d*256]
            if {$v>32767} {
               set v [expr $v-65535-1]
            }
            # === type
            set c [string index $event 6] ; set d [meteosensor_convert_base $c ascii 10]
            set type $d
            # === num
            set c [string index $event 7] ; set d [meteosensor_convert_base $c ascii 10]
            set num $d
            set decode "$t $type $num $v" ; # type must be numeric at this step
            #console::affiche_resultat "decode=$decode\n"
            lappend superdecode $decode
         }
      }
   }
   return $superdecode
}

## @brief appelée par @ref joystick_get
#  @warning spécifique à Linux
#
proc joystick_resource_update { } {
   global audace

   set events [joystick_resource_read]
   #console::affiche_resultat "Etape 5000 events = $events\n"
   if {[llength $events]==0} {
      return ""
   }
   set defs $audace(joystick,elements,def)
   #joystick_resource_state
   set ne [llength $events]
   for {set ke 0} {$ke<$ne} {incr ke} {
      set event [lindex $events $ke]
      lassign $event t type num v
      #console::affiche_resultat "Etape 5010-$ke == $t $type $num $v\n"
      if {$type<128} {
         set type [joystick_resource_type_num2char $type]
         #console::affiche_resultat "Etape 5020-$ke == type=$type\n"
         foreach def $defs {
            #console::affiche_resultat "Etape 5030-$ke == def=$def\n"
            if {$type == [lindex $def 1]} {
               if {$num == [lindex $def 2]} {
                  #console::affiche_resultat "Etape 5040-$ke ==>> type=$type num=$num v=$v\n"
                  lappend audace(joystick,elements,prev_state,$type,$num) [list $t $v]
                  #console::affiche_resultat "Etape 5050-$ke audace(joystick,elements,prev_state,$type,$num)=$audace(joystick,elements,prev_state,$type,$num)\n"
                  break
               }
            }
         }
         #joystick_resource_state
         if {![info exists audace(joystick,elements,prev_state,$type,$num)]} {
            continue
         }
         set tvs $audace(joystick,elements,prev_state,$type,$num)
         set n [llength $tvs]
         if {$n>1} {
            set tv2 [lindex $tvs end]
            lassign $tv2 t2 v2
            set tv1 [lindex $tvs end-1]
            lassign $tv1 t1 v1
            if {$v2==0} {
               set dt [expr $t2-$t1]
            } else {
               set dt 0
            }
            set audace(joystick,elements,prev_state,$type,$num) ""
            lappend audace(joystick,elements,prev_state,$type,$num) $tv2
            set audace(joystick,elements,cure_state,$type,$num) ""
            lappend audace(joystick,elements,cure_state,$type,$num) [list $dt $v2]
         }
      }
   }
   return ""
}

## @brief appelée par @ref joystick_resource_update
#  @warning spécifique à Linux
#
proc joystick_resource_state { } {
   global audace

   set defs $audace(joystick,elements,def)

   console::affiche_resultat "Etape 4900 ----------------------\n"
   foreach def $defs {
      #lassign $def t type num
      lassign $def type num
      console::affiche_resultat "Etape 4900 audace(joystick,elements,prev_state,$type,$num)=$audace(joystick,elements,prev_state,$type,$num)\n"
   }
   console::affiche_resultat "Etape 4900 ----------------------\n"
}

# ##################################################################################
# ### Windows 7+  ##################################################################
# ##################################################################################

## @brief affiche les valeurs dynamiques d'une xBoxOne dans une IHM
#  @warning pour Windows 7 et plus (le driver xBoxOne refuse de s'installer sur XP).
#  @pre nécessite une liaison USB avec une microprise côté xBoxOne, mais pas de pile.
#  @note tiré des exemples figurant dans le dossier "../audela/lib/mkLibsdl/"
proc testxBoxOne { } {

   if { $::tcl_platform(os) eq "Windows NT" } {

      package require mkLibsdl

      if {[joystick count] < "1"} {
         ::console::affiche_erreur "no joystick found\n"
         return
      }

      # build a little GUI
      joystickGui 0

      # now we create an event handler
      joystick event eval showEvent

   } else {
      ::console::affiche_erreur "mkLibsdl works only with Windows\n"
   }
}

proc showEvent { } {
   set lEvent [joystick event peek]

   foreach {x iJoystick sType iControl x iValue} $lEvent break

   switch $sType {
      button {
         set ::aButtons($iJoystick.$iControl) $iValue
      }

      hat {
         set ::aHats($iJoystick.$iControl) $iValue
         set ::aHats($iJoystick.$iControl.n) [expr { $iValue >> 0 & 1 }]
         set ::aHats($iJoystick.$iControl.e) [expr { $iValue >> 1 & 1 }]
         set ::aHats($iJoystick.$iControl.s) [expr { $iValue >> 2 & 1 }]
         set ::aHats($iJoystick.$iControl.w) [expr { $iValue >> 3 & 1 }]
      }

      axis {
         set ::aAxes($iJoystick.$iControl) $iValue
      }
   }
}

proc joystickGui { i } {

   set This $::audace(base).js
   if {[winfo exists $This] ==1} {
      destroy $This
   }

   toplevel $This -class Toplevel
   wm title $This "[joystick name $i]"
   wm geometry $This "+350+50"
   wm resizable $This 1 1
   wm protocol $This WM_DELETE_WINDOW ""

   # buttons
   pack [frame $This.u] -fill x
   pack [labelframe $This.u.f -text " Buttons " -padx 5 -pady 5] -fill x
   for { set j 0 } { $j < [joystick info $i buttons] } { incr j } {
      pack [checkbutton $This.u.f.c$j -text $j -variable ::aButtons($i.$j) -width 2 -border 1 -indicatoron 0] -side left
   }

   # hats
   pack [frame $This.h] -fill x
   for { set j 0 } { $j < [joystick info $i hats] } { incr j } {
      pack [labelframe $This.h.f$j -text " Hat $j " -padx 5 -pady 5] -side left
      pack [checkbutton $This.h.f$j.n -text N -variable ::aHats($i.$j.n) -width 2 -border 1 -indicatoron 0] -side top
      pack [checkbutton $This.h.f$j.s -text S -variable ::aHats($i.$j.s) -width 2 -border 1 -indicatoron 0] -side bottom
      pack [checkbutton $This.h.f$j.e -text E -variable ::aHats($i.$j.e) -width 2 -border 1 -indicatoron 0] -side right
      pack [checkbutton $This.h.f$j.w -text W -variable ::aHats($i.$j.w) -width 2 -border 1 -indicatoron 0] -side left
      pack [label $This.h.f$j.c -textvariable ::aHats($i.$j) -width 2] -side left
   }

   # axes
   pack [frame $This.a] -fill x
   for { set j 0 } { $j < [joystick info $i axes] } { incr j } {
      pack [labelframe $This.a.f$j -text " Axis $j " -padx 5 -pady 5] -fill x
      pack [scale $This.a.f$j.s -from -32768 -to 32768 -variable ::aAxes($i.$j) -orient horizontal -width 8 -border 1 -highlightthickness 0] -fill x
   }
}


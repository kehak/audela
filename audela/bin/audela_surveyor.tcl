# ========================================================================
# This script allows to survey if AudeLA crashes under Windows or Linux.
# -------------------------------------------------------------------------
# 1) To launch the surveyor from a Aud'ACe console
#    source $::audela_start_dir/../gui/audace/audela_surveyor_launcher.tcl
#    launch_audela "--console --file $::audela_start_dir/audela_surveyor.tcl"
# 2) To test a crash:
#    gsl_mtranspose { {t t } t}
# -------------------------------------------------------------------------
# You should adapt the part "Things to do after the crash of AudeLA"
# =========================================================================
# open "|./audela -console --file /srv/develop/audela/bin/audela_surveyor.tcl" w+
# file20

global audace

proc launch_audela { {cmdline ""} } {
   global audace
   if {[info exists audace(audela_surveyor,path)]==0} {
      set path $::audela_start_dir
   } else {
      set path $audace(audela_surveyor,path)
   }
   set process_name audela
   if { $::tcl_platform(os) == "Linux" } {
      set process_name "./$process_name"
   } else {
      package require twapi
      set process_name "${process_name}.exe"
   }
   # --- Launch a new AudeLA process
   if { $::tcl_platform(os) == "Linux" } {
      if {$cmdline==""} {
         set texte "eval \{set pwd \[pwd\] ; cd \"${path}\" ; exec $process_name & ; cd \$pwd\}"
      } else {
         set texte "eval \{set pwd \[pwd\] ; cd \"${path}\" ; open \"|./$process_name $cmdline\" w; cd \$pwd\}"
      }
   } else {
      set priority normal
      if {$cmdline==""} {
         set texte "eval \{package require twapi ; set path ${path} ; set res \[twapi::create_process \"\${path}/$process_name\" -startdir \"\${path}\" -detached 1 -showwindow normal -priority $priority \]\}"
      } else {
         set texte "eval \{package require twapi ; set path ${path} ; set res \[twapi::create_process \"\" -startdir \"\${path}\" -cmdline \"\${path}/$process_name $cmdline\" -detached 1 -title Audela_surveyor -showwindow normal -priority $priority \]\}"
      }
   }
   eval $texte
}

if { $::tcl_platform(os) == "Linux" } {
   # === Get the PID of AudeLA to survey
   set process_name audela
   set lignes [split [exec ps -edf | grep "/$process_name"] \n]
   set pid0 ""
   foreach ligne $lignes {
      if {[string first audela_surveyor.tcl $ligne]>0} {
         set pid0 [lindex $ligne 1]
      }
   }
   set f [open log.txt a] ; puts $f "Current pid=$pid0" ; close $f
   foreach ligne $lignes {
      if {[string first "grep /${process_name}" $ligne]>0} {
         continue
      }
   set pid [lindex $ligne 1]
   if {$pid==$pid0} {
      continue
   }
      set pidtosurvey $pid
   }
   set f [open log.txt a] ; puts $f "AudeLA to survey pid=$pidtosurvey"; close $f
   # === Loop to detect a crash of AudeLA
   while {1==1} {
      set quit 1
      set err [catch {
         set lignes [split [exec ps -edf | grep "/$process_name"] \n]
         foreach ligne $lignes {
            set pid [lindex $ligne 1]
            set f [open log.txt a] ; puts $f "pid=$pid pidtosurvey=$pidtosurvey"; close $f
            if {$pid==$pidtosurvey} {
               set quit 0
            }
         }
         set f [open log.txt a] ; puts $f "A quit=$quit"; close $f
      } msg]
      if {$quit==1} {
         break
      }
      set f [open log.txt a] ; puts $f "B quit=$quit"; close $f
      if {$err==1} {
         set f [open log.txt a] ; puts $f "Error $msg"; close $f
      }
      after 1000
   }
   set f [open log.txt a] ; puts $f "finalisation"; close $f
} else {
   # === Get the PID of AudeLA to survey
   package require twapi
   set pid0 [twapi::get_current_process_id]
   puts "Current pid=$pid0"
   set pids [twapi::get_process_ids -name audela.exe]
   puts "AudeLA pids=$pids"
   foreach pid $pids {
      if {$pid==$pid0} {
         continue
      }
      break
   }
   set pidtosurvey $pid
   puts "AudeLA to survey pid=$pidtosurvey"

   # === Loop to detect a crash of AudeLA
   set quit 0
   while {1==1} {
      set err [catch {
         set hwins [twapi::get_toplevel_windows -pid $pidtosurvey]
         if {$hwins==""} {
            set quit 1
         }
         foreach hwin $hwins {
            set res2 [twapi::get_window_class $hwin]
            set hwin2s [twapi::get_descendent_windows $hwin]
            set valid 0
            foreach hwin2 $hwin2s {
               set res6 [twapi::get_window_text $hwin2]
               if {([string first "Debug Error!" $res6]>=0)||([string first "Runtime Error!" $res6]>=0)} {
                  puts "Crash detected type 1"
                  after 2000
                  puts "Kill the crashed process."
                  twapi::end_process $pidtosurvey -force
                  after 2000
                  set quit 1
                  break
               }
            }
            if {$quit==1} {
               break
            }
         }
         set pidw [twapi::get_process_ids -name WerFault.exe]
         if {$pidw!=""} {
            set hwins [twapi::get_toplevel_windows -pid $pidw]
            if {$hwins!=""} {
               foreach hwin $hwins {
                  set res5 [twapi::get_window_text $hwin]
                  puts "WerFault.exe res5=$res5"
                  if {([string first "audela.exe" $res5]>=0)} {
                     puts "Crash detected type 2"
                     after 2000
                     puts "Kill the WerFault process."
                     twapi::end_process $pidw -force
                     puts "Kill the crashed process."
                     twapi::end_process $pidtosurvey -force
                     after 2000
                     set quit 1
                     break
                  }
               }
            }
            if {$quit==1} {
               break
            }
         }
      } msg]
      if {$quit==1} {
         break
      }
      if {$err==1} {
         puts "Error $msg"
      }
      after 1000
   }
}

# === Things to do after the crash of AudeLA
set err [catch {
   # --- relance AudeLA en mode graphique
   set audace(audela_surveyor,path) [file dirname [file normalize [info script]]]
   set f [open log.txt a] ; puts $f "Launch AudeLA with Aud'ACE audace(audela_surveyor,path) = $audace(audela_surveyor,path)"; close $f
   launch_audela
   after 10000
   set file_perso $audace(audela_surveyor,path)/audela_surveyor_perso.tcl
   if {[file exists $file_perso]==1} {
      source $file_perso
   }
} msg]
if {$err==1} {
   set f [open log.txt a] ; puts $f "Error $msg"; close $f
   after 10000
}

# === End this survey
set f [open log.txt a] ; puts $f "Bye bye"; close $f
after 2000
exit


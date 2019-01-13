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


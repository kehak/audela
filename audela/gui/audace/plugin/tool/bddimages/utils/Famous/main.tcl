### source [ file join $audace(rep_plugin) tool bddimages utils Famous main.tcl]
set pi 3.141592653589793
gren_info "lecture du fichier\n"
package require math::statistics
set racine [ file join $audace(rep_plugin) tool bddimages utils Famous]

source  [ file join $racine funcs.formule.tcl]
source  [ file join $racine funcs.affiche.tcl]


set file_dirs [ file join $racine solu.res]
set file_data [ file join $racine cdl.dat]
set file_res  [ file join $racine resid_final.txt]

array unset soluce
::plotxy::clf 1
::plotxy::figure 1 
::plotxy::hold on 
::plotxy::position {0 0 600 400}


#genere_solu $racine

read_solu_direct $file_dirs soluce



#voir_solu soluce

# lecture du fichier d observation

  set xo ""
  set yo ""
  set f [open $file_data "r"]
  while {![eof $f]} {
     set line [gets $f]
     if {[string trim $line] == ""} {break}
     set line [regsub -all \[\s\] $line ,]
     set r [split [string trim $line] ","]
     lappend xo [lindex [lindex $r 0] 0 ]  
     lappend yo [lindex [lindex $r 0] 1 ]  
  }
  set mean [::math::statistics::mean $yo]
  set xmax [expr  [::math::statistics::max $xo]]
  set xmin [expr  [::math::statistics::min $xo]]
  set ymax [expr  [::math::statistics::max $yo] - $mean]
  set ymin [expr  [::math::statistics::min $yo] - $mean]


# tracer de l observation

  set xo ""
  set yo ""
  set f [open $file_data "r"]
  while {![eof $f]} {
     set line [gets $f]
     if {[string trim $line] == ""} {break}
     set line [regsub -all \[\s\] $line ,]
     set r [split [string trim $line] ","]
#     gren_info "r = [lindex $r 0]  [lindex $r 1]  \n"
     lappend xo [lindex [lindex $r 0] 0 ]  
     lappend yo [lindex [lindex $r 0] 1 ]  
  }
  close $f
     
  set hobs [::plotxy::plot $xo $yo x]
  plotxy::sethandler $hobs [list -color red -linewidth 2]

set mean [::math::statistics::mean $yo]

# tracer du residu
  set xo ""
  set yo ""
  set f [open $file_res "r"]
  while {![eof $f]} {
     set line [gets $f]
     if {[string trim $line] == ""} {break}
     set line [regsub -all \[\s\] $line ,]
     set r [split [string trim $line] ","]
#     gren_info "r = [lindex $r 0]  [lindex $r 1]  \n"
     lappend xo [lindex [lindex $r 0] 0 ]  
     lappend yo [expr [lindex [lindex $r 0] 1 ] + $mean]
  }
  close $f
     
  set hobs [::plotxy::plot $xo $yo 0]
  plotxy::sethandler $hobs [list -color blue -linewidth 2]

# tracer de la courbe calculee
set tmin $xmin 
set tmax $xmax
#set toffset 0.245565600E+07
set toffset 0.553765520E+00
set toffset 0.157000000E+01
set toffset 0.553765520E+00

set pas 0.01

set x ""
set y ""

set t $tmin
while {$t <= $tmax} {
#   gren_info "$t\n"
   set c [calcul soluce [expr ($t-$toffset)]]
   lappend x [expr ($t)]
   lappend y $c
   set t [expr $t + $pas]
}

  set h [::plotxy::plot $x $y .]
  plotxy::sethandler $h [list -color black -linewidth 4]

# set axis [list $xmin $xmax $min $max]
#::plotxy::axis $axis

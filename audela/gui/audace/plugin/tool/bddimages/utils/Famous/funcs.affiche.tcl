

proc read_solu_direct { file_solu p_solu } {

   upvar $p_solu solu

     array unset solu
     gren_info "read direct $file_solu\n"
     set i 0

     set typeofsolu "FINAL SOLUTION AFTER REJECTION"
     set start "               Frequency       Period        cos term        sine term    sigma(f)/f sigma(cos) sigma(sin)  amplitude    phase(deg)      S/N "
     set stop  "No line has been rejected from the significance test"
     set offset  "***  Origin of time in the following solution"

     set go1 "no"
     set go2 "no"
     
     set cptpos 0
     set f [open $file_solu "r"]
     while {![eof $f]} {
        set line [gets $f]
        if {[string trim $line]==$typeofsolu} {
           incr cptpos
        }
     }
     close $f


     set f [open $file_solu "r"]
     set cpt 0
     set k_sav 0
     while {![eof $f]} {
        set line [gets $f]
        if {$go1=="no"} {
          if {[string trim $line]==$typeofsolu} {
             incr cpt
             if {$cpt == $cptpos} {
                set go1 "yes"
             }
          }
          continue
        }
        if {$go2=="no"} {
          if {[string trim $line]==[string trim $start]} {
             set go2 "yes"
          }
          continue
        }
        if {[string trim $line]==[string trim $stop]} {
           break
        }
        if {[string trim $line]==""} {
           continue
        }
#        gren_info "OK=$line\n"
        # lecture de la solution

        set k [string trim [string range $line 0 4]]
        if {$k == ""} {set k $k_sav}
        set k_sav $k
        set exp [string trim [string range $line 8 9] ]
#         gren_info "k  $k $exp\n"

        set solu($k,$exp,frequency)  [string range $line 11 25]
        set solu($k,$exp,period)     [string range $line 26 41]
        set solu($k,$exp,costerm)    [string range $line 42 57]
        set solu($k,$exp,sineterm)   [string range $line 58 73]
        set solu($k,$exp,sigmaf)     [string range $line 74 84]
        set solu($k,$exp,sigmacos)   [string range $line 85 95]
        set solu($k,$exp,sigmasin)   [string range $line 96 106]
        set solu($k,$exp,amplitude)  [string range $line 107 119]
        set solu($k,$exp,phase)      [string range $line 120 132]
        set solu($k,$exp,sn)         [string range $line 133 142]
        set solu($k,nbexp) $exp

     }
     set solu(nbk) [expr $k + 1]
     close $f
     return 0
}






proc read_solu { file_solu p_solu } {

   upvar $p_solu solu

     array unset solu
     gren_info "read\n"
     set f [open $file_solu "r"]
     set i 0
     set k_sav 0
     while {![eof $f]} {
        set line [gets $f]
        if {[string trim $line] == ""} {break}
        set k [string trim [string range $line 0 4]]
        if {$k == ""} {set k $k_sav}
        set k_sav $k
        set exp [string trim [string range $line 8 9] ]
#         gren_info "k  $k $exp\n"

        set solu($k,$exp,frequency)  [string range $line 11 25]
        set solu($k,$exp,period)     [string range $line 26 41]
        set solu($k,$exp,costerm)    [string range $line 42 57]
        set solu($k,$exp,sineterm)   [string range $line 58 73]
        set solu($k,$exp,sigmaf)     [string range $line 74 84]
        set solu($k,$exp,sigmacos)   [string range $line 85 95]
        set solu($k,$exp,sigmasin)   [string range $line 96 106]
        set solu($k,$exp,amplitude)  [string range $line 107 119]
        set solu($k,$exp,phase)      [string range $line 120 132]
        set solu($k,$exp,sn)         [string range $line 133 142]
        set solu($k,nbexp) $exp
#        gren_info "solu($k,nbexp)=$solu($k,nbexp)\n"

        incr i
     }
     set solu(nbk) [expr $k + 1]
#     gren_info "nbk=$solu(nbk)\n"
     close $f
     return 0
}


proc voir_solu { p_solu } {

   upvar $p_solu solu

   for {set k 0} {$k<$solu(nbk)} {incr k} {
         gren_info "k  $k \n"

      for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
         gren_info "k  $k "
         gren_info "ex $exp)      "
         gren_info "fr $solu($k,$exp,frequency)"
         gren_info "pe $solu($k,$exp,period)   "
         gren_info "co $solu($k,$exp,costerm)  "
         gren_info "si $solu($k,$exp,sineterm) "
         gren_info "si $solu($k,$exp,sigmaf)   "
         gren_info "si $solu($k,$exp,sigmacos) "
         gren_info "si $solu($k,$exp,sigmasin) "
         gren_info "am $solu($k,$exp,amplitude)"
         gren_info "ph $solu($k,$exp,phase)    "
         gren_info "sn $solu($k,$exp,sn)       \n"
      }
   }
}
proc genere_solu { racine } {

   set pi 3.141592653589793
   
   set file_data [ file join $racine cdl_simu.dat]

   set f [open $file_data "w"]
   set tmin 0
   set tmax $pi
   set pas 0.01

   set t $tmin
   while {$t <= $tmax} {
   #   gren_info "$t\n"
      set c [expr sin($t)+cos($t)]
      puts $f "$t $c"
      set t [expr $t + $pas]
   }
   close $f
}

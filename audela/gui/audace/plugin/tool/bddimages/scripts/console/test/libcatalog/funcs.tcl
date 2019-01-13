proc main { } {
   
   gren_info "TEST DES CATALOGUES"

   set err [catch {test_usnoa2} msg]
   if {$err} { gren_info "TEST USNOA2 FAILED: $msg\n" } else { gren_info "TEST USNOA2 SUCCESS\n" }

   set err [catch {test_tycho2} msg]
   if {$err} { gren_info "TEST TYCHO-2 FAILED: $msg\n" } else { gren_info "TEST TYCHO-2 SUCCESS\n" }

   set err [catch {test_ucac2} msg]
   if {$err} { gren_info "TEST UCAC2 FAILED: $msg\n" } else { gren_info "TEST UCAC2 SUCCESS\n" }

   set err [catch {test_ucac3} msg]
   if {$err} { gren_info "TEST UCAC3 FAILED: $msg\n" } else { gren_info "TEST UCAC3 SUCCESS\n" }

   set err [catch {test_ucac4} msg]
   if {$err} { gren_info "TEST UCAC4 FAILED: $msg\n" } else { gren_info "TEST UCAC4 SUCCESS\n" }

   set err [catch {test_ppmx} msg]
   if {$err} { gren_info "TEST PPMX FAILED: $msg\n" } else { gren_info "TEST PPMX SUCCESS\n" }

   set err [catch {test_ppmxl} msg]
   if {$err} { gren_info "TEST PPMXL FAILED: $msg\n" } else { gren_info "TEST PPMXL SUCCESS\n" }

   set err [catch {test_2mass} msg]
   if {$err} { gren_info "TEST 2MASS FAILED: $msg\n" } else { gren_info "TEST 2MASS SUCCESS\n" }

   set err [catch {test_nomad1} msg]
   if {$err} { gren_info "TEST NOMAD1 FAILED: $msg\n" } else { gren_info "TEST NOMAD1 SUCCESS\n" }

   exit
}




proc test_memoire { } {

   global ucac4 dir
   
   set info [exec cat /proc/[pid]/status ]
   set mem0 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]

   for {set i 5} {$i<22} {incr i} {

      set info [exec cat /proc/[pid]/status ]
      set mem [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
      gren_info "Test LibCatalog :: current memory = $mem Mo :: CMD = csucac4 $ucac4 117.461051 26.417708 5.3201769552120002 $i -5"

      csucac4 $ucac4 117.461051 26.417708 5.3201769552120002 $i -5
   
   }
   set info [exec cat /proc/[pid]/status ]
   set memf [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"]  / 1024.0 - $mem0 ] ]
   
   gren_info "Test LibCatalog : Perte differentielle = $memf Mo"

   exit

}

proc test_tycho2 { } {

   global tycho2 dir
   
   gren_info "TEST Tycho2"
   set f [open [file join $dir list.tycho2] "a"]
   puts $f [cstycho2 $tycho2 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.tycho2] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.tycho2] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST Tycho2 END"
   
}

proc test_ucac2 { } {

   global ucac2 dir
   
   gren_info "TEST UCAC2 "
   set f [open [file join $dir list.ucac2] "a"]
   puts $f [csucac2 $ucac2 117.460999 26.41771 10.645796347765513]
   close $f
   
   array unset cnt
   set f [open [file join $dir list.ucac2] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.ucac2] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST UCAC2 END"
}

proc test_ucac3 { } {

   global ucac3 dir
   
   gren_info "TEST UCAC3 "
   set f [open [file join $dir list.ucac3] "a"]
   puts $f [csucac3 $ucac3 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.ucac3] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.ucac3] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST UCAC3 END"
   
}

proc test_ucac4 { } {

   global ucac4 dir
   
   gren_info "TEST UCAC4 "
   set f [open [file join $dir list.ucac4] "a"]
   puts $f [csucac4 $ucac4 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.ucac4] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.ucac4] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST UCAC4 END"
   
}

proc test_nomad1 { } {

   global nomad1 dir
   
   gren_info "TEST NOMAD1 "
   set f [open [file join $dir list.nomad1] "a"]
   puts $f [csnomad1 $nomad1 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.nomad1] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.nomad1] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST NOMAD1 END"
   
}

proc test_ppmx { } {

   global ppmx dir

   gren_info "TEST PPMX "
   set f [open [file join $dir list.ppmx] "a"]
   puts $f [csppmx $ppmx 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.ppmx] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.ppmx] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST PPMX END"

}

proc test_ppmxl { } {

   global ppmxl dir

   gren_info "TEST PPMXL "
   set f [open [file join $dir list.ppmxl] "a"]
   puts $f [csppmxl $ppmxl 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.ppmxl] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.ppmxl] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST PPMXL END"

}

proc test_usnoa2 { } {

   global usnoa2 dir

   gren_info "TEST USNOA2 "
   set f [open [file join $dir list.usnoa2] "a"]
   puts $f [csusnoa2 $usnoa2 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.usnoa2] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.usnoa2] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST USNOA2 END"

}

proc test_2mass { } {

   global twomass dir

   gren_info "TEST 2MASS "
   set f [open [file join $dir list.2mass] "a"]
   puts $f [cs2mass $twomass 117.460999 26.41771 10.645796347765513]
   close $f

   array unset cnt
   set f [open [file join $dir list.2mass] "r"]
   while {![eof $f]} {
      set char [read $f 1]
      scan $char %c ascii
      if {$ascii == 32 } { continue }
      if {$ascii >=43 && $ascii <= 125} { continue }
      set chr($ascii) $char
      if {[info exists cnt($ascii)]} {
         incr cnt($ascii)
      } else {
         set cnt($ascii) 1
      }
      #puts $ascii
   }
   close $f

   set f [open [file join $dir ascii.2mass] "a"]
   puts $f "acsii, nbchar, char" 
   foreach {ascii nb} [array get cnt] {
      puts $f "$ascii, $nb, $chr($ascii)" 
   }
   close $f

   gren_info "TEST 2MASS END"

}

proc test_data_on_slave { } {

   global ucac4 
   
   set good "{ { UCAC4 { } { ID ra_deg dec_deg im1_mag im2_mag sigmag_mag objt dsf sigra_deg sigdc_deg na1 nu1 us1 cepra_deg cepdc_deg pmrac_masperyear pmdc_masperyear sigpmr_masperyear sigpmd_masperyear id2m jmag_mag hmag_mag kmag_mag jicqflg hicqflg kicqflg je2mpho he2mpho ke2mpho apassB_mag apassV_mag apassG_mag apassR_mag apassI_mag apassB_errmag apassV_errmag apassG_errmag apassR_errmag apassI_errmag catflg1 catflg2 catflg3 catflg4 starId zoneUcac2 idUcac2 } } } {{ { UCAC4 { } {582-039932 117.36934472 +26.36087694 14.925 14.902 0.040 0 0 0.00000833 0.00000861 2 2 2 0.00002760 +0.00002763 -4.60000000 +4.70000000 3.30000000 3.50000000 356626292 13.685 13.399 13.293 25 25 2 0.030 0.040 0.990 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136365146 233 55925} } } { { UCAC4 { } {582-039933 117.37095528 +26.34822556 15.747 15.716 0.170 0 0 0.00002083 0.00001528 2 2 2 0.00002466 +0.00002652 -2.30000000 -3.90000000 3.60000000 3.50000000 356626267 14.522 14.338 14.158 5 5 5 0.030 0.050 0.070 16.165 15.634 15.878 15.485 20.000 2.480 2.550 0.020 0.060 0.990 0 30 0 0 136349663 233 55927} } } { { UCAC4 { } {582-039934 117.37145083 +26.37048333 15.629 15.617 0.270 0 0 0.00001472 0.00001639 2 2 2 0.00002621 +0.00002621 -0.60000000 -7.80000000 3.20000000 3.50000000 356626312 14.371 14.016 13.794 5 5 5 0.030 0.040 0.050 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136376885 233 55930} } } { { UCAC4 { } {582-039935 117.37370028 +26.35785306 15.998 15.794 0.140 0 0 0.00001444 0.00001417 3 3 2 0.00002643 +0.00002670 +0.70000000 -0.60000000 3.20000000 3.50000000 356626287 14.752 14.639 14.395 5 5 5 0.030 0.060 0.080 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136361382 233 55931} } } { { UCAC4 { } {582-039940 117.38805000 +26.35212361 16.207 15.952 0.990 0 0 0.00002861 0.00002833 1 1 2 0.00002394 +0.00002372 -0.70000000 -6.70000000 4.60000000 4.50000000 356626275 15.343 15.124 14.706 5 5 5 0.050 0.080 0.100 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136354415 0 0} } } { { UCAC4 { } {582-039944 117.40620361 +26.36948472 13.696 15.954 0.900 0 0 0.00001167 0.00002972 2 2 2 0.00002688 +0.00002131 -9.20000000 +7.70000000 3.00000000 4.40000000 356639964 15.108 14.672 14.599 5 5 5 0.040 0.060 0.100 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136375692 0 0} } } { { UCAC4 { } {582-039957 117.45642083 +26.33409444 14.446 14.407 0.070 0 0 0.00000750 0.00000528 8 8 2 0.00002782 +0.00002820 -2.90000000 +2.80000000 2.50000000 2.70000000 356640022 13.461 13.239 13.175 45 45 45 0.020 0.030 0.030 14.904 14.479 14.629 14.321 14.139 0.030 0.010 0.010 0.000 2.550 0 10 0 0 136332698 233 55972} } } { { UCAC4 { } {582-039964 117.48142472 +26.34408667 15.699 16.220 0.300 0 0 0.00001806 0.00001778 2 2 2 0.00002694 +0.00002681 -18.00000000 -5.40000000 4.30000000 4.10000000 356640001 14.620 14.002 13.781 5 5 5 0.030 0.040 0.050 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136344715 0 0} } } { { UCAC4 { } {582-039965 117.49777472 +26.36174972 14.344 14.310 0.080 0 0 0.00000694 0.00000500 7 7 2 0.00002810 +0.00002830 -7.50000000 -3.20000000 3.30000000 3.50000000 356639977 13.290 12.946 12.885 5 5 5 0.020 0.030 0.030 14.929 14.398 14.650 14.241 14.063 0.030 0.020 0.010 0.060 0.070 0 10 0 0 136366179 233 55988} } } { { UCAC4 { } {582-039967 117.51314194 +26.33439778 15.473 15.401 0.160 0 0 0.00001667 0.00001472 5 5 2 0.00002601 +0.00002685 -5.20000000 -1.20000000 3.20000000 3.40000000 356640020 14.033 13.535 13.443 45 45 45 0.030 0.040 0.040 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136333080 233 55994} } } { { UCAC4 { } {582-039972 117.53325639 +26.38324417 16.055 15.730 0.120 0 0 0.00001361 0.00001917 4 4 2 0.00002692 +0.00002560 +1.30000000 -19.80000000 3.10000000 3.30000000 356649647 13.664 12.958 12.815 25 25 5 0.030 0.030 0.030 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 30 0 0 136392548 0 0} } } { { UCAC4 { } {582-039976 117.54834083 +26.34198750 15.779 15.776 0.140 0 0 0.00000972 0.00001528 4 4 2 0.00002775 +0.00002690 -1.20000000 -1.80000000 3.00000000 3.30000000 356649574 14.659 14.320 14.212 5 5 5 0.040 0.050 0.060 16.319 15.842 16.037 15.721 20.000 0.120 0.010 2.550 2.550 0.990 0 10 0 0 136342229 233 56008} } } { { UCAC4 { } {582-039978 117.55297194 +26.39115306 14.511 14.442 0.100 0 0 0.00000861 0.00000667 7 7 2 0.00002798 +0.00002825 -7.70000000 -14.10000000 3.10000000 3.30000000 356649659 12.902 12.321 12.231 5 5 5 0.030 0.020 0.020 15.816 14.764 15.294 14.396 14.012 0.050 0.050 0.030 0.050 0.050 0 10 0 0 136402304 233 56012} } } { { UCAC4 { } {582-039979 117.55400528 +26.35998639 16.073 16.569 0.990 0 0 0.00002889 0.00002917 1 1 2 0.00002130 +0.00002139 -2.30000000 +3.20000000 4.30000000 4.30000000 356649605 15.640 15.103 15.167 5 5 6 0.060 0.080 0.150 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136364028 0 0} } } { { UCAC4 { } {583-040645 117.37273583 +26.47298222 15.392 16.150 0.900 0 0 0.00003667 0.00001861 2 2 2 0.00001575 +0.00002542 -10.20000000 +1.50000000 9.80000000 3.50000000 356626512 15.010 14.741 14.564 5 5 5 0.040 0.050 0.090 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136504650 0 0} } } { { UCAC4 { } {583-040646 117.37555306 +26.43012972 15.601 15.544 0.170 0 0 0.00001556 0.00001194 3 3 2 0.00002603 +0.00002712 +0.20000000 -2.80000000 3.20000000 3.40000000 356626426 14.546 14.266 14.047 5 5 5 0.030 0.050 0.070 16.082 15.620 15.790 15.433 20.000 2.550 2.550 0.080 0.100 0.990 0 10 0 0 136450598 233 55932} } } { { UCAC4 { } {583-040648 117.37905472 +26.44992528 13.964 14.003 0.080 0 0 0.00000611 0.00000750 6 6 2 0.00002751 +0.00002741 -12.30000000 +1.30000000 2.20000000 2.50000000 356626468 12.945 12.676 12.567 5 5 5 0.020 0.030 0.030 14.605 14.022 14.270 13.880 13.750 0.010 0.020 0.010 0.010 0.040 0 10 0 0 136475324 233 55934} } } { { UCAC4 { } {583-040649 117.39236083 +26.46917028 15.863 15.661 0.090 0 0 0.00001917 0.00001472 3 3 2 0.00002519 +0.00002661 -2.20000000 +0.00000000 3.50000000 3.50000000 356626503 14.597 14.380 14.249 5 5 5 0.040 0.050 0.080 16.075 15.654 15.915 15.455 20.000 0.090 0.200 0.010 0.020 0.990 0 10 0 0 136499743 233 55940} } } { { UCAC4 { } {583-040650 117.39434556 +26.44604000 14.993 14.978 0.110 0 0 0.00000944 0.00001167 3 3 2 0.00002743 +0.00002720 -4.30000000 -0.40000000 3.20000000 3.50000000 356639828 13.489 13.064 12.961 5 5 5 0.020 0.020 0.030 16.027 15.039 15.508 14.801 14.556 0.010 0.030 0.080 0.050 2.550 0 10 0 0 136470430 233 55943} } } { { UCAC4 { } {583-040653 117.40418528 +26.43113472 15.606 15.994 0.360 5 0 0.00001556 0.00001556 3 3 1 0.00002809 +0.00002809 +0.00000000 +0.00000000 25.50000000 25.50000000 356639859 14.830 14.337 14.277 25 25 25 0.040 0.050 0.080 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 0 0 0 136451849 0 0} } } { { UCAC4 { } {583-040654 117.40495000 +26.42975444 14.707 14.749 0.140 0 0 0.00000667 0.00001000 4 4 2 0.00002777 +0.00002745 +12.40000000 -35.70000000 3.30000000 3.50000000 356639860 13.632 13.314 13.248 5 25 25 0.030 0.030 0.040 15.405 14.668 14.964 14.407 14.277 0.050 0.050 0.000 0.010 2.550 0 70 0 0 136450091 0 0} } } { { UCAC4 { } {583-040657 117.40739222 +26.40110889 15.581 15.538 0.200 0 0 0.00001333 0.00001278 4 4 2 0.00002670 +0.00002698 +0.70000000 +1.50000000 3.20000000 3.50000000 356639915 14.539 14.193 14.146 5 5 5 0.030 0.040 0.060 16.128 15.508 15.722 15.505 20.000 0.180 0.080 2.550 2.550 0.990 0 10 0 0 136414403 233 55950} } } { { UCAC4 { } {583-040660 117.41502556 +26.42089167 14.384 14.521 0.990 8 0 0.00006944 0.00006556 1 0 2 0.00001566 +0.00001554 -27.30000000 +101.90000000 19.30000000 19.20000000 0 20.000 20.000 20.000 0 0 0 0.000 0.000 0.000 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136439051 0 0} } } { { UCAC4 { } {583-040661 117.41835833 +26.47804917 16.043 16.145 0.990 0 0 0.00006167 0.00005833 1 0 2 0.00001548 +0.00001539 +7.30000000 -24.00000000 19.20000000 19.10000000 356639774 14.442 13.766 13.553 5 5 5 0.030 0.030 0.040 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136511135 0 0} } } { { UCAC4 { } {583-040662 117.42325611 +26.47625889 15.770 15.729 0.310 0 0 0.00001778 0.00001694 2 2 2 0.00002539 +0.00002584 +2.60000000 -0.70000000 3.30000000 3.40000000 356639779 14.615 14.093 13.978 5 5 5 0.030 0.040 0.060 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136508756 233 55955} } } { { UCAC4 { } {583-040665 117.43510361 +26.49963583 16.107 16.538 0.670 0 0 0.00003222 0.00003139 2 2 2 0.00002396 +0.00002359 +0.40000000 -0.70000000 5.20000000 5.00000000 356639739 15.733 15.202 15.131 5 5 6 0.060 0.090 0.150 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136543688 233 55961} } } { { UCAC4 { } {583-040666 117.43575194 +26.41406194 13.187 13.187 0.080 0 0 0.00000472 0.00000944 4 4 2 0.00002751 +0.00002656 +10.30000000 -14.70000000 1.80000000 2.20000000 356639892 11.954 11.560 11.469 5 5 5 0.020 0.020 0.020 14.140 13.352 13.712 13.104 12.901 0.030 0.030 0.020 0.010 0.040 0 10 0 0 136430466 233 55964} } } { { UCAC4 { } {583-040668 117.45654194 +26.46557194 15.805 16.111 0.080 0 0 0.00002139 0.00002167 2 2 2 0.00002444 +0.00002486 -3.40000000 +1.30000000 3.40000000 3.50000000 356639797 15.441 15.105 15.060 5 5 7 0.050 0.070 0.160 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136495139 0 0} } } { { UCAC4 { } {583-040669 117.46801611 +26.50592222 15.120 14.930 0.100 0 0 0.00000694 0.00000694 7 7 2 0.00002808 +0.00002813 +4.10000000 -6.20000000 3.10000000 3.40000000 356639729 13.764 13.454 13.345 5 5 5 0.020 0.030 0.040 15.805 15.099 15.402 14.895 14.628 0.080 0.020 0.040 0.040 2.550 0 10 0 0 136554056 234 55817} } } { { UCAC4 { } {583-040671 117.47773889 +26.40916861 15.537 15.411 0.170 0 34 0.00002056 0.00001139 5 3 2 0.00002540 +0.00002769 -1.50000000 -2.40000000 3.50000000 3.40000000 356639900 14.572 14.428 14.404 5 5 5 0.030 0.050 0.080 15.763 15.393 15.532 15.307 20.000 0.020 0.020 0.000 0.120 0.990 0 20 0 0 136424449 233 55983} } } { { UCAC4 { } {583-040676 117.50508250 +26.44781306 13.693 13.643 0.070 0 0 0.00000417 0.00000528 8 8 2 0.00002814 +0.00002802 +0.40000000 -6.70000000 2.10000000 2.30000000 356639825 12.568 12.268 12.124 5 5 5 0.020 0.020 0.020 14.426 13.783 14.042 13.592 13.436 0.010 0.010 0.020 0.020 0.040 0 10 0 0 136472672 233 55991} } } { { UCAC4 { } {583-040678 117.50803250 +26.47209417 13.420 13.440 0.060 0 0 0.00000389 0.00000444 8 8 2 0.00002821 +0.00002819 +3.00000000 -2.00000000 2.30000000 2.50000000 356639788 11.944 11.428 11.320 5 5 5 0.020 0.020 0.020 14.697 13.686 14.139 13.367 13.087 0.020 0.030 0.000 0.010 0.050 0 10 0 0 136503472 233 55992} } } { { UCAC4 { } {583-040679 117.51877806 +26.43164806 15.253 15.195 0.060 0 1 0.00001389 0.00000889 4 4 2 0.00002697 +0.00002800 -2.40000000 -12.10000000 3.20000000 3.30000000 356639856 13.969 13.574 13.510 5 5 5 0.030 0.030 0.040 15.944 15.360 15.674 15.049 14.787 0.060 0.060 2.550 2.550 2.550 0 20 0 0 136452549 233 55995} } } { { UCAC4 { } {583-040681 117.52790056 +26.43134611 15.425 15.181 0.060 0 0 0.00001194 0.00000778 4 4 2 0.00002740 +0.00002807 +3.00000000 -6.30000000 3.20000000 3.30000000 356649754 14.202 13.958 13.889 5 5 5 0.030 0.030 0.050 15.828 15.278 15.455 15.063 20.000 0.010 0.080 2.550 2.550 0.990 0 10 0 0 136452151 233 55999} } } { { UCAC4 { } {583-040683 117.54198361 +26.49939611 16.363 16.371 0.470 0 0 0.00002833 0.00002972 2 1 2 0.00002103 +0.00002153 +1.10000000 +3.00000000 4.20000000 4.40000000 356649868 15.400 15.182 15.131 5 5 6 0.050 0.080 0.140 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136543312 233 56005} } } { { UCAC4 { } {583-040686 117.54956667 +26.49937028 12.480 12.472 0.040 0 0 0.00000417 0.00000389 10 9 2 0.00002780 +0.00002802 +4.10000000 +1.70000000 1.60000000 1.90000000 356649869 10.973 10.448 10.353 5 5 5 0.020 0.020 0.020 13.674 12.713 13.146 12.433 12.138 0.030 0.010 0.010 0.010 0.020 0 10 0 0 136543274 233 56009} } } { { UCAC4 { } {583-040687 117.55180694 +26.43268250 15.686 15.679 0.140 0 0 0.00001472 0.00001028 4 4 2 0.00002654 +0.00002759 -1.70000000 -3.80000000 3.20000000 3.30000000 356649760 14.492 14.165 14.133 5 5 5 0.030 0.040 0.060 16.149 15.586 15.817 15.528 20.000 0.010 0.050 2.550 2.550 0.990 0 30 0 0 136453856 233 56010} } } { { UCAC4 { } {583-040688 117.55225167 +26.47452861 16.345 16.323 0.210 0 0 0.00002417 0.00002583 2 1 2 0.00002328 +0.00002284 -2.50000000 -4.10000000 3.70000000 3.90000000 356649833 14.654 14.051 14.025 5 5 5 0.030 0.030 0.050 20.000 20.000 20.000 20.000 20.000 0.990 0.990 0.990 0.990 0.990 0 10 0 0 136506579 0 0} } } }"

   for {set i 1} {$i<50} {incr i} {

      set data [csucac4 $ucac4 117.461051 26.417708 5.3201769552120002]
         gren_info "CMD : csucac4 $ucac4 117.461051 26.417708 5.3201769552120002"
      if {$data!=$good} {
         gren_info "Test LibCatalog :: $i : Erreur"
         break
      } else {
         gren_info "Test LibCatalog :: $i : Ok"
      }
   
   }
   gren_info "GOOD : $good"
   gren_info "DATA : $data"
   
   
   gren_info "Test LibCatalog : Fin "

   exit

}

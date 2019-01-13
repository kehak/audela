## @file bdi_tools_famous.tcl
#  @brief     TOOLS pour l'analyse en fr&eacute;quence des donn&eacute;es observationnelles
#  @author    Frederic Vachier (fv@imcce.fr)
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_famous.tcl]
#  @endcode

# $Id: bdi_tools_famous.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_famous
# @brief TOOLS pour l'analyse en fr&eacute;quence des donn&eacute;es observationnelles
# @pre Requiert le programme Famous d&eacute;velopp&eacute; par F. Mignard (OCA)
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_famous {

}


proc ::bdi_tools_famous::read_solu_direct {  } {


   global bddconf

   set file_solu [file join $bddconf(dirtmp) "famous.res"]

   array unset solu
   gren_info "read direct $file_solu\n"
   set i 0

   set typeofsolu "FINAL SOLUTION AFTER REJECTION"

   set cptpos 0
   set f [open $file_solu "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line]==$typeofsolu} {
         incr cptpos
      }
   }
   close $f

   if {$cptpos == 0} {
      set typeofsolu "FINAL SOLUTION  AFTER NON LINEAR FIT"
      set cptpos 0
      set f [open $file_solu "r"]
      while {![eof $f]} {
         set line [gets $f]
         if {[string trim $line]==$typeofsolu} {
            incr cptpos
         }
      }
      close $f
   }
   
   if {$cptpos == 0} {
      set typeofsolu "SOLUTION  AFTER LEVENBERG-MARQUARDT FIT"
      set cptpos 0
      set f [open $file_solu "r"]
      while {![eof $f]} {
         set line [gets $f]
         if {[string trim $line]==$typeofsolu} {
            incr cptpos
         }
      }
      close $f
   }
   
   if {$cptpos == 0} {
      set typeofsolu "UNKNOWN"
      gren_erreur "typeofsolu = $typeofsolu\n"
      return
   }

   gren_info "typeofsolu = $typeofsolu\n"
   set ::bdi_tools_famous::typeofsolu $typeofsolu

   set xoffset 0
   set offset  "***  Origin of time in the following solution"
   set f [open $file_solu "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string first $offset $line]>-1} {
         set xoffset [string range $line 51 end]
      }
   }
   close $f
   gren_info "time_offset = $xoffset \n"
   set ::bdi_tools_famous::xoffset $xoffset

   set start "               Frequency       Period        cos term        sine term    sigma(f)/f sigma(cos) sigma(sin)  amplitude    phase(deg)      S/N "
   set stop  "No line has been rejected from the significance test"

   set go1 "no"
   set go2 "no"
   
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
         set exp [string trim [string range $line 8 10] ]
         if { [string is int $k] } { 
            gren_info " $k is int : exp = $exp\n"
         } else {
            gren_info " $k is not int\n"
            set k $k_sav
            break
         }
         set k_sav $k

         set solu($k,$exp,frequency)  [string range $line 12 26]
         set solu($k,$exp,period)     [string range $line 27 42]
         set solu($k,$exp,costerm)    [string range $line 43 58]
         set solu($k,$exp,sineterm)   [string range $line 59 74]
         set solu($k,$exp,sigmaf)     [string range $line 75 85]
         set solu($k,$exp,sigmacos)   [string range $line 86 96]
         set solu($k,$exp,sigmasin)   [string range $line 97 107]
         set solu($k,$exp,amplitude)  [string range $line 108 120]
         set solu($k,$exp,phase)      [string range $line 121 133]
         set solu($k,$exp,sn)         [string range $line 134 143]
         set solu($k,nbexp) $exp

   }
   set solu(nbk) [expr $k + 1]
   close $f
   
   array set ::bdi_tools_famous::solu [array get solu]   
   set ::bdi_tools_famous::lsolu [array get solu]
   
   # Calcul de la periode
   # la barre d erreur est sigma(f)/f = p/sigma(p) = 6.413E-04
   # sigma(p) = p * 2 * 24 / 6.413E-04 = 8553.19 h ?! surement erronné
   # si sigma(f)/f = sigma(p)/p => sigma(p) = p * 2 * 24 * 6.413E-04 = 0.003517636904496 h = 12.66 sec (c est plus ce qu on attend)


   set ::bdi_tools_famous::result(period)     ""
   set ::bdi_tools_famous::result(err_period) ""
   set ::bdi_tools_famous::result(amplitude)  ""
   set period ""
   set err_period ""
   set amplitude ""
   for {set k 1} {$k<$solu(nbk)} {incr k} {
      for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
         set p $solu($k,$exp,period)
         set a $solu($k,$exp,amplitude)
         set f $solu($k,$exp,frequency)
         set sigmaf $solu($k,$exp,sigmaf)
         if {[string is double $p] && [string is double $a] && [string is double $f] && [string is double $sigmaf]} {
            if {$a > $amplitude} {
               set period $p
               set amplitude $a
               set err_period [expr $sigmaf / $f * $p]
            }
         }
      }
   }
   if { $period != ""} {
      # on met la periode en heure
      
      for {set n 0} {$n<15} {incr n} {
         set t [expr $err_period * pow(10.0,$n)]
         if {$t > 1.0} {
            incr n -1
            break
         }
      }
      
      set period [format "%.${n}f" [expr $period * 48.0 ]]
      set err_period [format "%.${n}f" [expr $err_period * 48.0 ]]
      set amplitude [format "%.3f" [expr $amplitude* 2.0 ]]
      gren_info "Period : $period\n"
      gren_info "Err Period : $err_period\n"
      gren_info "Amplitude : $amplitude\n"
      set ::bdi_tools_famous::result(period)     $period
      set ::bdi_tools_famous::result(err_period) $err_period
      set ::bdi_tools_famous::result(amplitude)  $amplitude   
   }
   return [array get solu]
}




proc ::bdi_tools_famous::extrapole { t p_solu } {
   
   upvar $p_solu solu
   
   #array set solu $::bdi_tools_famous::lsolu

   set t [expr $t - $::bdi_tools_famous::xoffset]

   set pi 3.141592653589793

   for {set k 0} {$k<$solu(nbk)} {incr k} {
      set sumcos($k)) 0
      set sumsin($k)) 0
   }

   set C_0 0
   set k 0
   for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
      set a($exp) [expr pow($t,$exp)*$solu($k,$exp,costerm)]
      set C_0 [expr $C_0 + $a($exp)]
   }

   for {set k 1} {$k<$solu(nbk)} {incr k} {
      set C_k($k) 0
      set S_k($k) 0
      for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
         set a($exp) [expr pow($t,$exp)*$solu($k,$exp,costerm)]
         set b($exp) [expr pow($t,$exp)*$solu($k,$exp,sineterm)]
         set C_k($k) [expr $C_k($k) + $a($exp)]
         set S_k($k) [expr $S_k($k) + $b($exp)]
      }
      set teta [expr 2.0*$pi*$solu($k,0,frequency)*$t]
      set cosnu($k) [expr cos($teta)]
      set sinnu($k) [expr sin($teta)]
   }
   set y $C_0
   for {set k 1} {$k<$solu(nbk)} {incr k} {
      set y [expr $y + $C_k($k)*$cosnu($k)+$S_k($k)*$sinnu($k)]
   }

   return $y
}


#------------------------------------------------------------
## FAMOUS: Lance Famous
#  @return void
#
proc ::bdi_tools_famous::famous { } {

   global bddconf

   cd $bddconf(dirtmp)
   set err [catch {exec Famous_driver } msg]
   if {$err} {
      gren_erreur    "famous_launch: error #$err: $msg\n" 
      return -code 1 "famous_launch: error #$err: $msg\n" 
   } 
   gren_info "$msg\n"

   # Lit la solution
   set ::bdi_tools_famous::lsolu [::bdi_tools_famous::read_solu_direct]
   array set ::bdi_tools_famous::solu $::bdi_tools_famous::lsolu

}


#
#
#
# Lecture des residus
proc ::bdi_tools_famous::read_residus { p_xo p_yo p_ysol p_nbd p_time_span p_mean p_std p_ampl} {

   global bddconf

   upvar $p_xo        xo
   upvar $p_yo        yo
   upvar $p_ysol      ysol
   upvar $p_nbd       nbd
   upvar $p_time_span time_span
   upvar $p_mean      mean
   upvar $p_std       std
   upvar $p_ampl      ampl
   
   gren_info "Lecture des residus\n"
   set file_res [file join $bddconf(dirtmp) "resid_final.txt"]
   set xo   ""
   set yo   ""
   set ysol ""
   set f [open $file_res "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      set line [regsub -all \[\s\] $line ,]
      set r [split [string trim $line] ","]
      set x [lindex [lindex $r 0] 0 ] 
      set y [expr [lindex [lindex $r 0] 1 ]]
      lappend xo $x 
      lappend yo $y
      lappend ysol [::bdi_tools_famous::extrapole $x ::bdi_tools_famous::solu]
       
   }
   close $f

   # Calcul du time span
   set time_span [expr [::math::statistics::max $xo] - [::math::statistics::min $xo]]

   # Calcul des stats
   
   set nbd  [::math::statistics::number $yo]
   set mean [::math::statistics::mean   $yo]
   set std  [::math::statistics::stdev  $yo]
   set ampl [expr [::math::statistics::max $ysol] - [::math::statistics::min $ysol] ]
   
}

## @file bdi_tools_mpc.tcl
#  @brief     Outils pour le formattage des donn&eacute;es pour le MPC
#  @author    J. Berthier <berthier@imcce.fr> et F. Vachier <fv@imcce.fr>
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_mpc.tcl]
#  @endcode

# $Id: bdi_tools_mpc.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_mpc
# @brief Outils pour le formattage des donn&eacute;es pour le MPC
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_mpc {

   package provide bdi_tools_mpc 1.0

}


#----------------------------------------------------------------------------
## Conversion d'un angle decimal exprime en heure au format sexagesimal pour le MPC
#  @param val real Angle decimal en heure a convertir
#  @return string Angle au format sexagesimal (h m s)
proc ::bdi_tools_mpc::convert_hms { val } {

   set h [expr $val/15.]
   set hint [expr int($h)]
   set r [expr $h - $hint]
   set m [expr $r * 60.]
   set mint [expr int($m)]
   set r [expr $m - $mint]
   set sec [format "%.2f" [expr $r * 60.]]
   if {$hint < 10.0} {set hint "0$hint"}
   if {$mint < 10.0} {set mint "0$mint"}
   if {$sec  < 10.0} {set sec "0$sec"}
   return "$hint $mint $sec"

}


#----------------------------------------------------------------------------
## Conversion d'un angle decimal exprime en degres au format sexagesimal pour le MPC
#  @param val real Angle decimal en degres a convertir
#  @return string Angle au format sexagesimal (d m s)
proc ::bdi_tools_mpc::convert_dms { val } {

   set s "+"
   if {$val < 0} {
      set s "-"
   }
   set aval [expr abs($val)]
   set d [expr int($aval)]
   set r [expr $aval - $d]
   set m [expr $r * 60.]
   set mint [expr int($m)]
   set r [expr $m - $mint]
   set sec [format "%.1f" [expr $r * 60.]]
   if {$d    < 10.0} {set d "0$d"}
   if {$mint < 10.0} {set mint "0$mint"}
   if {$sec  < 10.0} {set sec "0$sec"}
   return "$s$d $mint $sec"

}

#----------------------------------------------------------------------------
## Conversion d'une date ISO au format MPC
#  @todo A VERIFIER: Perte de precision sur la date de 0.864 secondes
#  @param date string Date au format ISO
#  @return string Date au format MPC (y m h.hh)
proc ::bdi_tools_mpc::convert_date { date } {

   set a  [string range $date 0 3]
   set m  [string range $date 5 6]
   set d  [string trimleft [string range $date  8  9] 0]
   set h  [string trimleft [string range $date 11 12] 0]
   set mn [string trimleft [string range $date 14 15] 0]
   set s  [string trimleft [string range $date 17 22] 0]
   if {$d ==""} {set d  0}
   if {$h ==""} {set h  0}
   if {$mn==""} {set mn 0}
   if {$s ==""} {set s  0}
   set day [format "%.5f" [expr $d + $h / 24. + $mn / 24. / 60. + $s / 24. /3600.]]
   if {$day <10.0} {set day "0$day"}
   return "$a $m $day"

}


#----------------------------------------------------------------------------
## Conversion d'une date JD au format MPC
#  @param jd string Date au format JD
#  @return string Date au format MPC (y m h.hh)
proc ::bdi_tools_mpc::convert_jd { jd } {

   set date [mc_date2ymdhms $jd]
   set a  [lindex $date 0]
   set m  [lindex $date 1]
   if {$m < 10.0} {set m "0$m"}
   set d  [lindex $date 2]
   set h  [lindex $date 3]
   set mn [lindex $date 4]
   set s  [lindex $date 5]
   if {$d  == ""} {set d  0}
   if {$h  == ""} {set h  0}
   if {$mn == ""} {set mn 0}
   if {$s  == ""} {set s  0}
   set day [format "%.5f" [expr $d + $h / 24. + $mn / 24. / 60. + $s / 24. /3600.]]
   if {$day < 10.0} {set day "0$day"}

   return "$a $m $day"

}


#----------------------------------------------------------------------------
## Conversion d'une magnitude au format MPC
#  @param mag real Magnitude a convertir
#  @return string Magnitude formattee pour le MPC
proc ::bdi_tools_mpc::convert_mag { mag { bandmag "L"} } {

   # Band in which the measurement was made:
   #  B (default if band is not indicated), V, R, I, J, W, U, g, r, i, w, y and z
   # Observed magnitude and band: F5.2,A1
   if {$mag==""} {set mag 0}
   set mpc_mag [format "%5.1f %1s" $mag $bandmag]

   return "$mpc_mag"
}


#----------------------------------------------------------------------------
## Conversion d un partie du nom d'un Sso au format MPC
# @details : exemple 0178 > 178
# @param onum string
# @return integer
proc ::bdi_tools_mpc::delete_zero_first { onum } {

   while {[string first 0 $onum]==0} {
      set onum [string range $onum 1 end]
   }
   return $onum
}

#----------------------------------------------------------------------------
## Conversion du nom d'un Sso au format MPC
# @details La convention de nommage du MPC pour les asteroides est :
#   Columns     Format   Use
#    1 -  5       A5     Minor planet number
#    6 - 12       A7     Provisional or temporary designation
#   13            A1     Discovery asterisk
# @param name string Nom du Sso
# @return string Nom du Sso formatte pour le MPC
proc ::bdi_tools_mpc::convert_name { name } {

   set mpc_name [format "%13s" " "]

   set sname [split $name "_"]
   switch [lindex $sname 0] {
      SKYBOT {
         if {[string length [lindex $sname 1]] > 1} {
            # Sso official number
            set onum [lindex $sname 1]
            #gren_erreur "onum = $onum $name\n"
            if {$onum < 100000} {
               # Official number
               set mpc_name [format "%05u%7s%1s" $onum " " " "]
            } else {
               # Official number in packed form
               set x [expr {int($onum/10000.0)}]
               set p [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z} $x]

               set onum [::bdi_tools_mpc::delete_zero_first [string range $onum 2 end]]

               set mpc_name [format "%1s%04u%7s%1s" $p $onum " " " "]
            }
         } else {
            # No number, then get packed form of the provisional designation
            set packedname [::bdi_tools_mpc::get_packed_designation [lrange $sname 2 end]]
            set mpc_name [format "%5s%7s%1s" " " $packedname " "]
         }
      }
      IMG {
         # Unknown or not identified Sso -> user name (must start by one or more letters).
         set form "%5s%7s%1s"
         set uname [string range [lindex $sname 1] 0 5]
         set mpc_name [format $form " " "U$uname" "*"]
      }
      default {
         set mpc_name [format "%12s" $name]
      }
   }

   return $mpc_name

}


#----------------------------------------------------------------------------
## Conversion de la designation provisoire d'un Sso dans le format compact du MPC
# @details Source: http://www.minorplanetcenter.net/iau/info/PackedDes.html
# @param prov string Designation provisaoire du Sso (e.g. 2005 JE140)
# @return string Designation compacte du Sso
proc ::bdi_tools_mpc::get_packed_designation { prov } {

   # Source: http://www.minorplanetcenter.net/iau/info/PackedDes.html
   # The first two digits of the year are packed into a single character in column 1 (I = 18, J = 19, K = 20).
   # Columns 2-3 contain the last two digits of the year.
   # Column 4 contains the half-month letter and column 7 contains the second letter.
   # The cycle count (the number of times that the second letter has cycled through the alphabet) is coded in columns 5-6,
   # using a letter in column 5 when the cycle count is larger than 99. The uppercase letters are used, followed by the lowercase
   # letters.
   #
   # Where possible, the cycle count should be displayed as a subscript when the designation is written out in unpacked format.
   #   Examples:
   #   J95X00A = 1995 XA
   #   J95X01L = 1995 XL1
   #   J95F13B = 1995 FB13
   #   J98SA8Q = 1998 SQ108
   #   J98SC7V = 1998 SV127
   #   J98SG2S = 1998 SS162
   #   K99AJ3Z = 2099 AZ193
   #   K08Aa0A = 2008 AA360
   #   K07Tf8A = 2007 TA418
   #
   # Survey designations of the form 2040 P-L, 3138 T-1, 1010 T-2 and 4101 T-3 are packed differently. Columns 1-3 contain the code
   # indicating the survey and columns 4-7 contain the number within the survey.
   #
   #   Examples:
   #   2040 P-L  = PLS2040
   #   3138 T-1  = T1S3138
   #   1010 T-2  = T2S1010
   #   4101 T-3  = T3S4101
   #

   # Split la designation provisoire en ses 2 parties
   set lprov [split $prov]

   # Cas des surveys
   if {[string match {[\P\T\]-*} [lindex $lprov 1]]} {
      set c1 [string range [lindex $lprov 1] 0 0]
      set c2 [string range [lindex $lprov 1] 2 2]
      set c3 [lindex $lprov 0]
      set packed [format "%1s%1s%1s%4s" $c1 $c2 "S" $c3]
      return $packed
   }

   # Autres cas:
   set first2digits [string range [lindex $lprov 0] 0 1]
   set c1 [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z} $first2digits]
   set c2 [string range [lindex $lprov 0] 2 end]
   set c4 [string range [lindex $lprov 1] 0 0]
   set c7 [string range [lindex $lprov 1] 1 1]
   set cyclecount [string range [lindex $lprov 1] 2 end]
   if {$cyclecount < 10} {
      set c5 [format "0%1s" $cyclecount]
   } elseif {$cyclecount < 100} {
      set c5 [format "%2s" $cyclecount]
   } else {
      set first2digits [string range $cyclecount 0 1]
      set lastdigit [string range $cyclecount 2 end]
      set p [string map {10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K 21 L 22 M 23 N 24 O 25 P 26 Q 27 R 28 S 29 T 30 U 31 V 32 W 33 X 34 Y 35 Z\
                         36 a 37 b 38 c 39 d 40 e 41 f 42 g 43 h 44 i 45 j 46 k 47 l 48 m 49 n 50 o 51 p 52 q 53 r 54 s 55 t 56 u 57 v 58 w 59 x 60 y 61 z} $first2digits]
      set c5 [format "%1s%1s" $p $lastdigit]
   }
   set packed [format "%1s%2s%1s%2s%1s" $c1 $c2 $c4 $c5 $c7]
   return $packed

}

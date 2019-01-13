

proc calcul { p_solu t } {

   upvar $p_solu solu

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
#              Frequency       Period        cos term        sine term    sigma(f)/f sigma(cos) sigma(sin)  amplitude    phase(deg)      S/N 
#
#   0  t^0  0.00000000E+00                 -4.89593494E+01                             1.033E-03           -4.895935E+01
#   0  t^1  0.00000000E+00                  8.60040890E+02                             6.359E+04            8.600409E+02
#   0  t^2  0.00000000E+00                  4.48142425E+03                             3.932E+04            4.481424E+03
#   0  t^3  0.00000000E+00                 -2.14808907E+04                             1.490E+06           -2.148089E+04
#   1  t^0  1.07593985E+02  9.29419985E-03  1.50634143E-03  1.12371418E-03  3.344E-01  1.540E-02  1.815E-02 1.879308E-03  323.2774652  3.63E+00
#      t^1                                 -2.05898295E-02  8.69486653E-03             4.446E-01  4.573E-01 2.235043E-02  202.8938177
#      t^2                                 -2.40037532E-01  2.28708705E-02             8.788E+00  5.652E+00 2.411246E-01  185.4427337
#      t^3                                 -1.61235364E-01  2.95365819E+00             2.742E+01  7.050E+01 2.958056E+00  266.8754184
#   2  t^0  3.88954273E+00  2.57099631E-01  6.38217962E+01 -5.76666264E+01  4.695E+00  3.373E-02  4.366E+03 8.601547E+01   42.0996087  3.82E+00
#      t^1                                  5.46390975E+02  7.29482936E+02             4.273E+04  3.651E+03 9.114211E+02  306.8336261
#      t^2                                 -3.24360116E+03  1.92501562E+03             3.318E+04  1.617E+05 3.771821E+03  210.6883254
#      t^3                                 -2.45547373E+03 -5.90512629E+03             2.480E+05  9.529E+04 6.395300E+03  112.5785523

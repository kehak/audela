package require math::constants




proc get_identified { sra sdec serrpos srmag srmagerr ira idec ierrpos irmag irmagerr scoreposlimit scoremvlimit scorelimit } {

    set dtr $::math::constants::degtorad
    set score NULL
    set deltapos [expr sqrt(pow(($sra-$ira)*cos($sdec*$dtr),2) + pow($sdec-$idec,2))]
    set deltaposdiv [expr ($serrpos + $ierrpos) / 3600.0]
    set scorepos [expr (1.0 - $deltapos / $deltaposdiv) * 100.0]
    if {$deltapos > $deltaposdiv } { set scorepos 0.0 }
    set deltamag [expr abs($irmag - $srmag)]
    set deltamagdiv [expr $srmagerr+$irmagerr]
    set scoremv [expr (1.0 - $deltamag / $deltamagdiv) * 100.0]
    if { $deltamag > $deltamagdiv } { set scoremv 0.0 }
    set score $scorepos
    if { $scoremv < $score } { set score $scoremv }
    if { $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit } {
       return true
       }
    return false
    }




# -- Procedure 
proc identification { catalist1 catalog1 catalist2 catalog2 scoreposlimit scoremvlimit scorelimit } {

 global voconf
 global ssp_image
 global ident_ovni_skybot
 global allidentifications


   set resultlist {}

   set fields1  [lindex $catalist1 0]
   set sources1 [lindex $catalist1 1]
   set fields2  [lindex $catalist2 0]
   set sources2 [lindex $catalist2 1]

   foreach s1 $sources1 { 
      foreach cata $s1 {
         if { [lindex $cata 0]==$catalog1 } {
            set cm1 [lindex $cata 1]
            }
         }
      
      foreach s2 $sources2 {
         foreach cata $s2 {
            if { [lindex $cata 0]==$catalog2 } {
               set cm2 [lindex $cata 1]
               }
            }
         
         set accepted [get_identified [lindex $cm1 0] [lindex $cm1 1] [lindex $cm1 2] \
                                      [lindex $cm1 3] [lindex $cm1 4] [lindex $cm2 0] \
                                      [lindex $cm2 1] [lindex $cm2 2] [lindex $cm2 3] \  
                                      [lindex $cm2 4] $scoreposlimit $scoremvlimit $scorelimit ]
         if { $accepted } {
            gren_info "[lindex $cm1 0] [lindex $cm1 1] [lindex $cm2 0] [lindex $cm2 1] accepted \n"
            break
            }
         }
      }

return $allidentifications
}


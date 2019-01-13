#
## @file pneb_tools.tcl
#  @brief Planetary Nebulae Calculations
#  @author Alain KLOTZ
#  $Id: pneb_tools.tcl 13475 2016-03-23 15:37:44Z rzachantke $
#

#--------------------------------------------------
## @brief Planetary Nebulae Calculations
#  @code usage :
#  source "$audace(rep_install)/gui/audace/pneb_tools.tcl"
#  - Exemple 1 pneb_int2tene 167.6 54.1 23.7 7 179 552.9 0.8 15.2 46.1 3.9 6.1 16.6
#  - Exemple 2 pneb_int2tene "" "" "" 7 179 552.9 "" "" "" "" "" ""
#  @endcode
#  @note Bibliographie http://www.astronomie-amateur.fr/feuilles/Spectroscopie/NGC2392.html
#  @remark les 12 arguments sont les intensités pour lambda = 6562.82 4861.33 4340.47 4363 4959 5007 5755 6548 6583 6716 6731 4686
#  @return textes
#
proc pneb_int2tene { int_h_6563 int_h_4862 int_h_4340 int_oiii_4363 int_oiii_4959 int_oiii_5007 int_nii_5755 int_nii_6548 int_nii_6583 int_sii_6716 int_sii_6731 int_heii_4686} {

   set textes ""
   catch {unset pneb}

   # --- measured integrated intensities

   # - 6562.82
   set pneb(int,h,6563) $int_h_6563

   # - 4861.33
   set pneb(int,h,4862) $int_h_4862

   # - 4340.47
   set pneb(int,h,4340) $int_h_4340

   # - [OIII] 4363
   set pneb(int,oiii,4363) $int_oiii_4363

   # - [OIII] 4959
   set pneb(int,oiii,4959) $int_oiii_4959

   # - [OIII] 5007
   set pneb(int,oiii,5007) $int_oiii_5007

   # - [NII] 5755
   set pneb(int,nii,5755) $int_nii_5755

   # - [NII] 6548
   set pneb(int,nii,6548) $int_nii_6548

   # - [NII] 6583
   set pneb(int,nii,6583) $int_nii_6583

   # - [SII] 6716
   set pneb(int,sii,6716) $int_sii_6716

   # - [SII] 6731
   set pneb(int,sii,6731) $int_sii_6731

   # - HeII 4686
   set pneb(int,heii,4686) $int_heii_4686

   append textes "=== Measured integrated intensities (arbitrary units) ===\n"
   set names [lsort [array names pneb]]
   foreach name $names {
      set key [lindex [split $name ,] 0]
      if {$key!="int"} {
         continue
      }
      set elem [string toupper [lindex [split $name ,] 1]]
      set lambda_a [lindex [split $name ,] 2]
      if {($pneb($name)!="")&&($pneb(int,h,4862)!="")} {
         set ratio100 [expr 100.*$pneb($name)/$pneb(int,h,4862)]
      } else {
         set ratio100 -
      }
      append textes "$elem ($lambda_a) = $pneb($name) ($ratio100)\n"
   }
   #::console::affiche_resultat "A $textes"

   # --- extinction coefficient

   set d34 2.85 ; # theoretical ratio alpha/beta
   set d44 1.00 ; # theoretical ratio beta/beta
   set d54 0.47 ; # theoretical ratio gamma/beta

   if {($pneb(int,h,4340)!="")&&($pneb(int,h,4862)!="")} {
      set lambda_mu 0.4340
      set fa [expr 2.5634*$lambda_mu*$lambda_mu-4.8735*$lambda_mu+1.7636]
      set lambda_mu 0.4862
      set fb [expr 2.5634*$lambda_mu*$lambda_mu-4.8735*$lambda_mu+1.7636]
      set cf [expr 1./($fb-$fa)]
      set int_h_ab [expr $pneb(int,h,4340)/$pneb(int,h,4862)]
      set c [expr $cf*log10($int_h_ab/$d54)]
      set ebv [expr $c/1.46]

      append textes "=== Interstellar extinction H(gamma)/H(beta) ===\n"
      append textes "c = $c\n"
      append textes "E(B-V) = $ebv\n"
   }

   if {($pneb(int,h,6563)!="")&&($pneb(int,h,4862)!="")} {
      set lambda_mu 0.6563
      set fa [expr 2.5634*$lambda_mu*$lambda_mu-4.8735*$lambda_mu+1.7636]
      set lambda_mu 0.4862
      set fb [expr 2.5634*$lambda_mu*$lambda_mu-4.8735*$lambda_mu+1.7636]
      set cf [expr 1./($fb-$fa)]
      set int_h_ab [expr $pneb(int,h,6563)/$pneb(int,h,4862)]
      set c [expr $cf*log10($int_h_ab/$d34)]
      set ebv [expr $c/1.46]

      append textes "=== Interstellar extinction H(alpha)/H(beta) ===\n"
      append textes "c = $c\n"
      append textes "E(B-V) = $ebv\n"

      # --- extinction corrections
      set names [lsort [array names pneb]]
      foreach name $names {
         set key [lindex [split $name ,] 0]
         if {$key!="int"} {
            continue
         }
         set lambda_a [lindex [split $name ,] 2]
         set lambda_mu [expr $lambda_a*1e-4]
         set f [expr 2.5634*$lambda_mu*$lambda_mu-4.8735*$lambda_mu+1.7636]
         set i0 $pneb($name)
         if {$i0!=""} {
            set ic [expr $i0*pow(10,$c*$f)]
            set pneb($name) $ic
         }
      }

      append textes "=== Deredened integrated intensities (arbitrary units) ===\n"
      set names [lsort [array names pneb]]
      foreach name $names {
         set key [lindex [split $name ,] 0]
         if {$key!="int"} {
            continue
         }
         set elem [string toupper [lindex [split $name ,] 1]]
         set lambda_a [lindex [split $name ,] 2]
         if {($pneb($name)!="")&&($pneb(int,h,4862)!="")} {
            set ratio100 [expr 100.*$pneb($name)/$pneb(int,h,4862)]
         } else {
            set ratio100 -
         }
         append textes "$elem ($lambda_a) = $pneb($name) ($ratio100)\n"
      }

   }

   # --- Te estimation from OIII
   if {($pneb(int,oiii,5007)!="")&&($pneb(int,oiii,4959)!="")&&($pneb(int,oiii,4363)!="")} {
      set roiii [expr ($pneb(int,oiii,5007)+$pneb(int,oiii,4959))/$pneb(int,oiii,4363)]
      set teo_ost2006 [expr 3.29e4/log($roiii/7.9)]
      set teo_kwo2007 [expr 32990/log(0.132*$roiii)]
      set teo_kal1986 [expr 14320/(log10($roiii)-0.890)]
      set teo_ack2001 [expr 3.29e4/log($roiii/8.3)]

      append textes "=== Excitation temperatures (Te) from R O\[III\] ===\n"
      append textes "R (OIII) = $roiii\n"
      append textes "$teo_ost2006 K (Osterbrock & Ferland, 2006)\n"
      append textes "$teo_kwo2007 K (Kwok, 2007)\n"
      append textes "$teo_kal1986 K (Kaler, 1986)\n"
      append textes "$teo_ack2001 K (Acker, 2001)\n"
   } else {
      set teo_ost2006 12000.
   }

   # --- Te estimation from NII
   if {($pneb(int,nii,6548)!="")&&($pneb(int,nii,6583)!="")&&($pneb(int,nii,5755)!="")} {
      set rnii [expr ($pneb(int,nii,6548)+$pneb(int,nii,6583))/$pneb(int,nii,5755)]
      set ten_ost2006 [expr 2.5e4/log($rnii/8.23)]

      append textes "=== Excitation temperatures (Te) from R N\[II\] ===\n"
      append textes "R (NII) = $rnii\n"
      append textes "$ten_ost2006 K (Osterbrock & Ferland, 2006)\n"

      # --- Ne estimation from SII
      set rsii [expr $pneb(int,sii,6716)/$pneb(int,sii,6731)]
      set nes_ack1995 [expr 100*sqrt($teo_ost2006)*($rsii-1.49)/(5.62-12.8*$rsii)]

      append textes "=== Electron density (Ne) from R S\[II\] ===\n"
      append textes "R (SII) = $rsii\n"
      append textes "Using Te = $teo_ost2006 K\n"
      append textes "$nes_ack1995 electrons/cm3 (Acker & Jaschek, 1995)\n"
   }

   # --- Excitation class
   if {($pneb(int,oiii,5007)!="")&&($pneb(int,oiii,4959)!="")&&($pneb(int,h,4862)!="")&&($pneb(int,heii,4686)!="")} {

      # Gurzadyan & Egikyan,1991
      set r1 [expr ($pneb(int,oiii,5007)+$pneb(int,oiii,4959))/$pneb(int,h,4862)]
      set r2 [expr log10(($pneb(int,oiii,5007)+$pneb(int,oiii,4959))/$pneb(int,heii,4686))]
      set ec1 0
      if {($r1>=1)&&($r1<5)} { set ec1 1 }
      if {($r1>=5)&&($r1<10)} { set ec1 2 }
      if {($r1>=10)&&($r1<20)} { set ec1 3 }
      set ec2 [expr -0.6515*$r2*$r2-2.1902*$r2+14.5670]

      # Dopita & Meatheringham, 1990
      set ec1_dop1990 [expr 0.45*$pneb(int,oiii,5007)/$pneb(int,h,4862)]
      set ec2_dop1990 [expr 5.54*($pneb(int,heii,4686)/$pneb(int,h,4862)+0.78)]

      append textes "=== Excitation class ===\n"
      append textes "Low: R1 = $r1  EC = $ec1 (Gurzadyan & Egikyan,1991)\n"
      append textes "High: R2 = $r2  EC = $ec2 (Gurzadyan & Egikyan,1991)\n"
      append textes "Low: EC = $ec1_dop1990 (Dopita & Meatheringham, 1990)\n"
      append textes "High: EC = $ec2_dop1990 (Dopita & Meatheringham, 1990)\n"
   }

   return $textes
}


## @file      loopscript_calibration_photometry.tcl
#  @brief     Explication du fichier ?
#  @pre       This script will be sourced in the loop
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool robobs loopscript_calibration_photometry.tcl]
#  @todo      A completer
#  @endcode

# $Id: loopscript_calibration_photometry.tcl 14446 2018-06-20 18:43:07Z fredvachier $

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

# === Body of script
set bufNo $audace(bufNo)

if {($robobs(planif,mode)=="vttrrlyr")||($robobs(planif,mode)=="trerrlyr")} {
   
   set fwhm_min 1.5
   if {$robobs(planif,mode)=="trerrlyr"} {
      set fwhm_min 0.8
   }



#------------------------------------------------------------
## Explication ?
#  @param bufno buffer number
#  @param xc ?
#  @param yc ?
#  @param fwhm_min ? default 1.5
#  @return void
#  @todo A completer
#
   proc rrlyr_photom { bufno xc yc {fwhm_min 1.5} } {
      global robobs
      set gain 2.0 ; # e/adu
      set d 9
      set dd 10
      set cste [expr log(2.)/2.*4*atan(1)]
      #
      set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]   
      set x1 [expr round(floor($xc-$d))] ; if {$x1<1} { set x1 1 }
      set x2 [expr round(ceil($xc+$d))] ; if {$x1>$naxis1} { set x2 $naxis1 }
      set y1 [expr round(floor($yc-$d))] ; if {$y1<1} { set y1 1 }
      set y2 [expr round(ceil($yc+$d))] ; if {$y1>$naxis2} { set y2 $naxis2 }
      if {([expr $x2-$x1]<=$d)||([expr $y2-$y1]<=$d)} {
         return [list 0 0 0]
      }
      set box [list $x1 $y1 $x2 $y2]
      #
      set valeurs [ buf$bufno fitgauss $box ]
      set dif 0.
      set intx [lindex $valeurs 0]
      set xc0 [lindex $valeurs 1]
      set fwhmx [lindex $valeurs 2]
      set bgx [lindex $valeurs 3]
      set inty [lindex $valeurs 4]
      set yc0 [lindex $valeurs 5]
      set fwhmy [lindex $valeurs 6]
      set bgy [lindex $valeurs 7]
      ::robobs::log " intx=$intx inty=$inty fwhmx=$fwhmx fwhmy=$fwhmy"
      if {($intx<=0)||($inty<=0)||($fwhmx<$fwhm_min)||($fwhmy<$fwhm_min)} {
         ::robobs::log " PBPB"
         return [list 0 0 0]
      }
      if {($fwhmx<1.5)||($fwhmy<1.5)} {
         set d 3
         set x1 [expr round(floor($xc-$d))] ; if {$x1<1} { set x1 1 }
         set x2 [expr round(ceil($xc+$d))] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr round(floor($yc-$d))] ; if {$y1<1} { set y1 1 }
         set y2 [expr round(ceil($yc+$d))] ; if {$y1>$naxis2} { set y2 $naxis2 }
         if {([expr $x2-$x1]<=$d)||([expr $y2-$y1]<=$d)} {
            return [list 0 0 0]
         }
         set box [list $x1 $y1 $x2 $y2]
         #
         set valeurs [ buf$bufno photom $box square 4 5 7]
         lassign $valeurs val a b back 
      } else {
         set val [expr sqrt($intx*$inty)*$fwhmx*$fwhmy*$cste]
      }
      set val_e [expr $val*$gain]
      set noise_e [expr sqrt(abs($val_e))]
      set npix [expr 4.*$fwhmx*$fwhmy] ; # estimation grossiere du nombre de pixels occupés par l'etoile
      #
      set xc [expr $xc0+0]
      set yc [expr $yc0+30]
      set x1 [expr int($xc-$dd)]
      set x2 [expr int($xc+$dd)]
      set y1 [expr int($yc-$dd)]
      set y2 [expr int($yc+$dd)]
      set boxstat [list $x1 $y1 $x2 $y2]
      #
      set valeurs [ buf$bufno stat $boxstat ]   
      set noise_back_adu [lindex $valeurs 7] ; # ou 5
      set noise_back_e [expr $noise_back_adu*$gain*sqrt($npix)]
      #
      set noise_total_e [expr sqrt( $noise_e*$noise_e + $noise_back_e*$noise_back_e ) ]
      #
      set snr [expr $val_e/$noise_total_e]
      #set dmag [expr 2.5*log10(1+2./$snr)] ; # 2. pour tenir compte de l'etoile de ref
      set dmag [expr -2.5*log10($val_e)+2.5*log10($val_e+2.*$noise_total_e)] ; # 2. pour tenir compte de l'etoile de ref
      ::robobs::log " val=$val snr=$snr dmag=$dmag"
      set res [list $val $snr $dmag]
   }
# Fin de procedure rrlyr_photom ------------------------------------------------------------
   
   foreach fname $robobs(image,afilenames) {
      loadima $fname      
      set object_name [string trim [lindex [buf$bufNo getkwd OBJENAME ] 1]]
      if {$object_name=="ttlyn"} {
         set star_obj [list [list [mc_angle2deg 09h03m07.9s] [mc_angle2deg +44d35m08.5s 90]] "ttlyn"        "TT Lyn"]
         set star_ref [list [list [mc_angle2deg 09h01m56.2s] [mc_angle2deg +45d08m14.3s 90]] "HD 77103"      9.18]
         set star_chk [list [list [mc_angle2deg 09h04m01.1s] [mc_angle2deg +44d49m12.2s 90]] "BD+45 1669"    9.74]
      } elseif {$object_name=="arper"} {
         set star_obj [list [list [mc_angle2deg 04h17m17.2s] [mc_angle2deg +47d24m00.7s 90]] "arper"         "AR Per"]
         set star_ref [list [list [mc_angle2deg 04h17m36.6s] [mc_angle2deg +47d15.1356m 90]] "GSC 3332 1784" 8.68]
         set star_chk [list [list [mc_angle2deg 04h17m11.4s] [mc_angle2deg +47d11.3902m 90]] "GSC 3332 1332" 9.79]
      } elseif {$object_name=="rrlyr"} {
         set star_obj [list [list 291.365878 42.783933] "rrlyr" "RR Lyr"]
         set star_ref [list [list 291.851540 42.229114] "HIP 95653" 7.57]
         set star_chk [list [list 291.522732 42.326172] "HIP 95548" 7.98]
      } elseif {$object_name=="V417Dra"} {
         set star_obj [list [list 285.24489056 48.74515000] "V417Dra" "V417 Dra"]
         set star_ref [list [list 285.25231417 48.83482611] "TYC-3549-642" 11.072]
         set star_chk [list [list 285.09754750 48.67837972] "TYC-3545-131" 11.807]
      }
      set catastar [lindex [buf$bufNo getkwd CATASTAR ] 1]
      if {$catastar>10} {
         # --- date
         set dateobs [lindex [buf$bufNo getkwd DATE-OBS] 1]
         set exptime [lindex [buf$bufNo getkwd EXPOSURE] 1]
         set jd [mc_datescomp $dateobs + [expr $exptime/86400./2.-0./24]]
         # --- definition of stars
         set ref_coords [lindex $star_ref 0]
         set ref_xy [buf$bufNo radec2xy $ref_coords]
         ::robobs::log " ref_xy=$ref_xy"
         set magref [lindex $star_ref 2]
         set obj_coords [lindex $star_obj 0]
         set obj_xy [buf$bufNo radec2xy $obj_coords]
         ::robobs::log " obj_xy=$obj_xy"
         set chk_coords [lindex $star_chk 0]
         set chk_xy [buf$bufNo radec2xy $chk_coords]
         # --- ref
         set xc [lindex $ref_xy 0]
         set yc [lindex $ref_xy 1]
         set res [rrlyr_photom $bufNo $xc $yc $fwhm_min]
         set valref [lindex $res 0]
         if {$valref<=0} {
            ::robobs::log " valref=$valref <=0 => mesure non valable."
            continue
         }
         set cmag [expr $magref+2.5*log10($valref)]
         if {$cmag<16} {
            ::robobs::log " cmag=$cmag <16 => mesure non valable."
            continue
         }
         # --- obj
         set xc [lindex $obj_xy 0]
         set yc [lindex $obj_xy 1]
         set res [rrlyr_photom $bufNo $xc $yc $fwhm_min]
         set val [lindex $res 0]
         if {$val<=0} {
            ::robobs::log " val=$val <=0 => mesure non valable."
            continue
         }
         ::robobs::log " val=$val valref=$valref."
         set mag [expr $magref-2.5*log10($val/$valref)]
         set snr [lindex $res 1]
         set dmag [lindex $res 2]
         # --- check
         set xc [lindex $chk_xy 0]
         set yc [lindex $chk_xy 1]
         set res [rrlyr_photom $bufNo $xc $yc $fwhm_min]
         set valcheck1 [lindex $res 0]
         if {$valcheck1<=0} {
            set magcheck1 99
         } else {
            set magcheck1 [expr $magref-2.5*log10($valcheck1/$valref)]
         }
         # --- display results
         ::robobs::log " [mc_date2iso8601 $jd] [format %6.3f $mag] [format %6.3f $dmag] [format %6.3f $cmag] [format %6.3f $magcheck1]"
         set textes "[format %15.6f $jd] [format %6.3f $mag] [format %6.3f $dmag] [format %6.3f $cmag] [format %6.3f $magcheck1]\n"
         # ---
         set fichier_res "$robobs(conf,folders,rep_images,value)/[lindex $star_obj 1]$robobs(private,nightdate).txt"
         set fichier_gif "$robobs(conf,folders,rep_images,value)/[lindex $star_obj 1]$robobs(private,nightdate).gif"
         if {[file exists $fichier_res]==0} {
            set f [open "$fichier_res" w]
            set textes ""
            append textes "# Dossier $robobs(conf,folders,rep_images,value)\n"
            append textes "# Observer $robobs(conf,home,observer,value)\n"
            append textes "# Site $robobs(conf,home,gps,value)\n"
            append textes "# Telescope $robobs(conf,optic,name,value) D=$robobs(conf,optic,diam,value) m F=$robobs(conf,optic,foclen,value) m\n"
            append textes "# Star [lindex $star_obj 2] ([lindex $star_obj 0] J2000)\n"
            append textes "# Reference [lindex $star_ref 1] V=[lindex $star_ref 2] ([lindex $star_ref 0] J2000)\n"
            append textes "# Check [lindex $star_chk 1] V=[lindex $star_chk 2] ([lindex $star_chk 0] J2000)\n"
            append textes "# Columns JD-UT Mag_Star dMag_Star Cmag Check\n"
            append textes "# END\n"   
            puts -nonewline $f $textes
            close $f
         } else {
            set f [open "$fichier_res" a]
            puts -nonewline $f $textes
            close $f
         }
         # --- display results
         set f [open "$fichier_res" r]
         set lignes [split [read $f] \n]
         close $f
         set mags ""
         set magcheck1s ""
         set jds ""
         set cmags ""
         foreach ligne $lignes {
            set car [string index $ligne 0]
            set err [catch {expr $car+1} msg]
            if {($err==1)||([llength $ligne]<4)} {
               continue
            }
            lappend jds [lindex $ligne 0]
            lappend mags [lindex $ligne 1]
            lappend magcheck1s [lindex $ligne 3]
            lappend cmags  [lindex $ligne 4]
         }
         # --- Graphics
         if {[llength $jds]>1} {
            ::plotxy::figure 1
            ::plotxy::clf
            ::plotxy::caption "[lindex $star_obj 2]"
            ::plotxy::plot $jds $mags or
            ::plotxy::plotbackground #FFFFFF
            ::plotxy::ydir reverse
            ::plotxy::bgcolor #FFFFFF
            ::plotxy::ylabel "equivalent V mag"
            ::plotxy::xlabel "JD UT"
            ::plotxy::title "[lindex $star_obj 2] Light-curve"
            ::plotxy::writegif "$fichier_gif"
         }
         
      }
   }
   
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""

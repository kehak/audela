#
## @file surchaud.tcl
#  @brief Surcharge des fonctions de AudeLA pour les rendre compatibles avec l'usage des répertoires de travail
#  @author Alain KLOTZ
#  $Id: surchaud.tcl 14487 2018-09-21 14:33:48Z robertdelmas $
#  @todo documentation à compléter
#

# add  operand value
# add1  in operand out const ?tt_options?
# add2  in operand out const number ?first_index? ?tt_options?
# convgauss  sigma
# convgauss2  in out number sigma ?first_index? ?tt_options?
# delete2  in number
# div  operand value
# div1  in operand out const ?tt_options?
# div2  in operand out const number ?first_index? ?tt_options?
# hotpixels  hot_pixel_list
# mult  const
# mult1  in out const ?tt_options?
# mult2  in out const number ?first_index? ?tt_options?
# ngain1  in out const ?tt_options?
# ngain2  in out const number ?first_index? ?tt_options?
# noffset1  in out const ?tt_options?
# noffset2  in out const number ?first_index? ?tt_options?
# offset  value
# offset1  in out const ?tt_options?
# offset2  in out const number ?first_index? ?tt_options?
# opt  dark offset
# opt1  in dark offset out const ?tt_options?
# opt2  in dark offset out const number ?first_index? ?tt_options?
# prod  operand value
# register  in out number ?-box {x1 y1 x2 y2}? ?tt_options?
# register2  in out number ?first_index? ?tt_options?
# registerbox  in out number ?first_index? ?tt_options?
# registerboxfollow  in out boxsize number ?first_index? ?tt_options?
# registerfine  in out number ?delta? ?oversampling? ?first_index? ?tt_options?
# registerwcs  in out number ?first_index? ?tt_options?
# sadd  in out number ?first_index? ?tt_options?
# scale1  in out scale_x scale_y ?tt_options?
# scale2  in out number scale_x scale_y ?first_index? ?tt_options?
# sdrizzlewcs  in out number drop_sizepix oversampling ?first_index? ?tt_options?"
# smean  in out number ?first_index? ?tt_options?
# smedian  in out number ?first_index? ?tt_options?
# sprod  in out number ?first_index? ?tt_options?
# spythagore  in out number ?first_index? ?tt_options?
# ssigma  in out number ?first_index? ?tt_options?
# ssk  in out number kappa ?first_index? ?tt_options?
# ssort  in out number percent ?first_index? ?tt_options?
# sub  operand value
# sub1  in operand out const ?tt_options?
# sub2  in operand out const number ?first_index? ?tt_options?
# subdark2  in dark offset out number exptime dexptime ?first_index?
# subsky  back_kernel back_threshold  ?tt_options?
# subsky1  in out back_kernel back_threshold ?tt_options?
# subsky2  in out number back_kernel back_threshold ?first_index? ?tt_options?
# superuncosmic
# trans  dx dy
# trans2  in out dx dy number ?first_index? ?tt_options?
# uncosmic  coef
# uncosmic2  in out number coef ?first_index? ?tt_options?
# window1  in out {x1 y1 x2 y2} ?tt_options?
# window2  in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
#
# calibwcs  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder
# calibwcs2  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder number ?first_index?
# simulimage  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type? ?newstar_type? ?newstar_ra? ?newstar_dec? ?newstar_mag?
# simulimage2  out ListDatesObsUTC variable_type Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type?
# electronic_chip  args
#

proc add {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) add "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: add operand value"
   }
}

proc add1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: add1 in operand out const ?tt_options?"
   }
}

proc add2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" ADD \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: add2 in operand out const number ?first_index? ?tt_options?"
   }
}

#------------------------------------------------------
## @brief convolution gaussienne de l'image dans le buffer par un filtre gaussien
#  @code
#  convgauss $sigma
#  @endcode
#  @param args valeur de sigma
#
#
proc convgauss {args} {

   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: convgauss sigma"
   }
}

proc convgauss2 {args} {
   #--- in out number sigma ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" CONV kernel_type=gaussian sigma=$[lindex $args 3] $options"
   } else {
      error "Usage: convgauss2 in out number sigma ?first_index? ?tt_options?"
   }
}

## @brief efface des fichiers images indexés 1 2 ..., compressés gz ou non,
#  localisés dans \$audace(rep_images)
#  @code
#  delete2 in number
#  @endcode
#  @param args
#  - in      racine du nom de série
#  - number index final
#
proc delete2 {args} {

   if {[llength $args] == 2} {
      set ext $::conf(extension,defaut)
      set cmp [buf$::audace(bufNo) compress]
      if {$cmp=="none"} {
         set cmp ""
      } else {
         set cmp ".gz"
      }
      set kdeb 1
      set kfin [lindex $args 1]
      for {set k $kdeb} {$k<=$kfin} {incr k} {
         set filename [ file join $::audace(rep_images) [lindex $args 0]${k}${ext}${cmp} ]
         catch {
            file delete "$filename"
         }
      }
   } else {
      error "Usage: delete2 in number"
   }
}

proc div {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) div "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: div operand value"
   }
}

proc div1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
   } else {
      error "Usage: div1 in operand out const ?tt_options?"
   }
}

proc div2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" DIV \"file=$operand\" constant=[lindex $args 3] $options"
   } else {
      error "Usage: div2 in operand out const number ?first_index? ?tt_options?"
   }
}

## @brief multiplie la valeur de chaque pixel de l'image dans le buffer (CF @ref ttus1) par une constante
#  @code
#  mult $constante
#  @endcode
#  @param args valeur du multiplicateur
#
proc mult {args} {
   #--- const
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "MULT constant=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: mult const"
   }
}

proc mult1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MULT constant=[lindex $args 2] $options"
   } else {
      error "Usage: mult1 in out const ?tt_options?"
   }
}

proc mult2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" MULT constant=[lindex $args 2] $options"
   } else {
      error "Usage: mult2 in out const number ?first_index? ?tt_options?"
   }
}

proc ngain1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
   } else {
      error "Usage: ngain1 in out const ?tt_options?"
   }
}

proc ngain2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMGAIN normgain_value=[lindex $args 2] $options"
   } else {
      error "Usage: ngain2 in out const number ?first_index? ?tt_options?"
   }
}

proc noffset1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
   } else {
      error "Usage: noffset1 in out const ?tt_options?"
   }
}

proc noffset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" NORMOFFSET normoffset_value=[lindex $args 2] $options"
   } else {
      error "Usage: noffset2 in out const number ?first_index? ?tt_options?"
   }
}

#------------------------------------------------------
## @brief incrémente la valeur de chaque pixel de l'image dans le buffer (CF @ref ttus1)
#  @code
#  offset $value
#  @endcode
#  @param args valeur d'offset
#
proc offset {args} {
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "OFFSET offset=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: offset value"
   }
}

proc offset1 {args} {
   #--- in out const ?tt_options?
   set n [llength $args]
   if {($n>=3)} {
      set ext $::conf(extension,defaut)
      set options ""
      if {$n>=4} {
         set options "[lrange $args 3 end]"
      }
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" OFFSET offset=[lindex $args 2] $options"
   } else {
      error "Usage: offset1 in out const ?tt_options?"
   }
}

proc offset2 {args} {
   #--- in out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {($n>=4)} {
      set ext $::conf(extension,defaut)
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 3]+$first-1]
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" OFFSET offset=[lindex $args 2] $options"
   } else {
      error "Usage: offset2 in out const number ?first_index? ?tt_options?"
   }
}

proc opt {args} {
   #--- dark offset
   if {[llength $args] == 2} {
      set len [expr [string length $::audace(rep_images)]-1]
      set dark [lindex $args 0]
      set dirdark [file dirname "$dark"]
      if {($len>=0)&&($dirdark==".")} {
         set dark [ file join $::audace(rep_images) $dark ]
      }
      set ext [file extension "$dark"]
      if {$ext==""} {
         set dark "${dark}$::conf(extension,defaut)"
      }
      set offset [lindex $args 1]
      set diroffset [file dirname "$offset"]
      if {($len>=0)&&($diroffset==".")} {
         set offset [ file join $::audace(rep_images) $offset ]
      }
      set ext [file extension "$offset"]
      if {$ext==""} {
         set offset "${offset}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) opt "$dark" "$offset"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: opt dark offset"
   }
}

proc opt1 {args} {
   #--- in dark offset out ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set offset "$operand"
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 3]\" . \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
   } else {
      error "Usage: opt1 in dark offset out ?tt_options?"
   }
}

proc opt2 {args} {
   #--- in dark offset out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set dark "$operand"
      set operand [lindex $args 2]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set offset "$operand"
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 3]\" 1 \"$ext\" OPT \"dark=$dark\" \"bias=$offset\" $options"
   } else {
      error "Usage: opt2 in dark offset out number ?first_index? ?tt_options?"
   }
}

proc prod {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) imaseries "PROD \"file=$operand\" constant=[lindex $args 1]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: prod operand value"
   }
}

proc register {args} {
   #--- in out number ?-box {x1 y1 x2 y2}? ?tt_options?
   #--- options : "tt options" or -box {x1 y1 x2 y2}
   set argc [llength $args]
   if { $argc < 3} {
      error "Usage: register in out number ?-box {x1 y1 x2 y2}? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set method tt
   set box ""
   set options ""
   if {$argc > 3} {
      for {set k 3} {$k<[expr $argc-1]} {incr k} {
         set argu [lindex $args $k]
         if {$argu=="-box"} {
            set method box
            set box [lindex $args [expr $k+1]]
         }
      }
      if {$method=="tt"} {
         set options [lrange $args 3 end]
      }
   }
   set first 1
   set number [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   if {$method=="tt"} {
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$path\" \"$in\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" STAT objefile"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$out\" $first \"$ext\" REGISTER translate=only $options"
      ttscript2 "IMA/SERIES \"$path\" \"$objefile\" $first $number \"$ext\" \"$path\" \"$objefile\" $first \"$ext\" DELETE"
   } else {
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$number} {incr k} {
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set res [buf$::audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$::audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$number} {incr k} {
         set kk [expr $k-$first]
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$::audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$::audace(bufNo) save [ file join ${path} ${out}${k}${ext} ]
      }
   }
}

proc register2 {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      set objefile "__dummy__$ext"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"$objefile\" 1 \"$ext\" STAT objefile $options"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER translate=never $options"
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"$objefile\" 1 [lindex $args 2] \"$ext\" \"$::audace(rep_images)\" \"$objefile\" 1 \"$ext\" DELETE $options"
   } else {
      error "Usage: register2 in out number ?first_index? ?tt_options?"
   }
}

proc registerbox {args} {
   #--- in out number ?visuNo? ?first_index? ?tt_options?
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set n [llength $args]
   if {$n>=3} {
      set visuno 1
      if {$n>=4} {
         set visuno "[lindex $args 3]"
      }
      set box [::confVisu::getBox $visuno]
      set first 1
      if {$n>=5} {
         set first "[lindex $args 4]"
      }
      set number [lindex $args 2]
      set options ""
      if {$n>=6} {
         set options "[lrange $args 5 end]"
      }
      set ni [expr $number+$first-1]
      set ext $::conf(extension,defaut)
      set path "$::audace(rep_images)"
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$ni} {incr k} {
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set res [buf$::audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$::audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
      }
      ::console::affiche_saut "\n"
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$ni} {incr k} {
         set kk [expr $k-$first]
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$::audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$::audace(bufNo) save [ file join ${path} ${out}${k}${ext} ]
      }
   } else {
      error "Usage: registerbox in out number ?visuNo? ?first_index? ?tt_options?"
      return $error;
   }
}

proc registerboxfollow {args} {
   #--- in out boxsize number ?visuNo? ?first_index? ?tt_options?
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set boxsize [lindex $args 2]
   set n [llength $args]
   if {$n>=4} {
      set visuno 1
      if {$n>=5} {
         set visuno "[lindex $args 4]"
      }
      set box [::confVisu::getBox $visuno]
      set first 1
      if {$n>=6} {
         set first "[lindex $args 5]"
      }
      set number [lindex $args 3]
      set options ""
      if {$n>=7} {
         set options "[lrange $args 6 end]"
      }
      set ni [expr $number+$first-1]
      set ext $::conf(extension,defaut)
      set path "$::audace(rep_images)"
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      catch {unset x ; unset y }
      for {set k $first} {$k<=$ni} {incr k} {
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set res [buf$::audace(bufNo) centro $box]
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set x1 [expr $xx-7] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+7] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-7] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+7] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set boxx [list $x1 $y1 $x2 $y2]
         set res [buf$::audace(bufNo) centro $boxx]
         lappend x [lindex $res 0]
         lappend y [lindex $res 1]
         ::console::affiche_resultat "$k : $res\n"
         set xx [expr round([lindex $res 0])]
         set yy [expr round([lindex $res 1])]
         set d [expr $boxsize/2]
         if {$d<2} { set d 2 }
         set x1 [expr $xx-$d] ; if {$x1<1} { set x1 1 }
         set x2 [expr $xx+$d] ; if {$x1>$naxis1} { set x2 $naxis1 }
         set y1 [expr $yy-$d] ; if {$y1<1} { set y1 1 }
         set y2 [expr $yy+$d] ; if {$y1>$naxis2} { set y2 $naxis2 }
         set box [list $x1 $y1 $x2 $y2]
      }
      ::console::affiche_saut "\n"
      set tx0 [lindex $x 0]
      set ty0 [lindex $y 0]
      for {set k $first} {$k<=$ni} {incr k} {
         set kk [expr $k-$first]
         buf$::audace(bufNo) load [ file join ${path} ${in}${k}${ext} ]
         set tx [expr round($tx0-[lindex $x $kk])]
         set ty [expr round($ty0-[lindex $y $kk])]
         buf$::audace(bufNo) imaseries "TRANS trans_x=$tx trans_y=$ty nullpixel=0 "
         buf$::audace(bufNo) save [ file join ${path} ${out}${k}${ext} ]
      }
   } else {
      error "Usage: registerboxfollow in out boxsize number ?visuNo? ?first_index? ?tt_options?"
      return $error;
   }
}

proc registerfine {args} {
   #--- in out number ?delta? ?oversampling? ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set delta 1
      if {$n==4} {
         set delta "[lindex $args 3]"
      }
      set oversampling 10
      if {$n==5} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
      }
      set first 1
      if {$n==6} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set delta "[lindex $args 3]"
         set oversampling "[lindex $args 4]"
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTERFINE oversampling=$oversampling delta=$delta \"file=$::audace(rep_images)/[lindex $args 0]${first}${ext}\" $options"
   } else {
      error "Usage: registerfine in out number ?delta? ?oversampling? ?first_index? ?tt_options?"
   }
}

proc registerwcs {args} {
   #--- in out number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" REGISTER matchwcs $options"
   } else {
      error "Usage: registerwcs in out number ?first_index? ?tt_options?"
   }
}

## @brief additionne pixel à pixel des images d'une pile (CF @ref ttus1)
#  @details cette fonctions produit une seule image en sortie à partir d'une pile d'images en entrée
#  @code
#  sadd in out number ?first_index? ?tt_options?
#  @endcode
#
proc sadd {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" ADD $options"
   } else {
      error "Usage: sadd in out number ?first_index? ?tt_options?"
   }
}

proc scale1 {args} {
   #--- in out scale_x scale_y ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" RESAMPLE \"paramresample=[lindex $args 2] 0 0 0 [lindex $args 3] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale1 in out scale_x scale_y ?tt_options?"
   }
}

proc scale2 {args} {
   #--- in out number scale_x scale_y ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" RESAMPLE \"paramresample=[lindex $args 3] 0 0 0 [lindex $args 4] 0\" normaflux=1 $options"
   } else {
      error "Usage: scale2 in out number scale_x scale_y ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule la valeur moyenne pixel à pixel des images de la pile (CF @ref ttus1)
#  @code
#  smean in out number ?first_index? ?tt_options?
#  @endcode
#
proc smean {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MEAN $options"
   } else {
      error "Usage: smean in out number ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule la valeur médiane pixel à pixel des images de la pile (CF @ref ttus1)
#  @code
#  smedian in out number ?first_index? ?tt_options?
#  @endcode
#
proc smedian {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" MED $options"
   } else {
      error "Usage: smedian in out number ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule le produit pixel à pixel des images de la pile (CF @ref ttus1)
#  @code
#  sprod in out number ?first_index? ?tt_options?
#  @endcode
#
proc sprod {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PROD $options"
   } else {
      error "Usage: sprod in out number ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule la racine carrée pixel à pixel des images de la pile (CF @ref ttus1)
#  @code
#  spythagore in out number ?first_index? ?tt_options?
#  @endcode
#
proc spythagore {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" PYTHAGORE $options"
   } else {
      error "Usage: spythagore in out number ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule l'écart type pixel à pixel des images de la pile (CF @ref ttus1)
#  @code
#  ssigma in out number ?first_index? ?tt_options?
#  @endcode
#
proc ssigma {args} {
   set n [llength $args]
   if {$n>=3} {
      set first 1
      if {$n==4} {
         set first "[lindex $args 3]"
      }
      set options ""
      if {$n>=5} {
         set first "[lindex $args 3]"
         set options "[lrange $args 4 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SIG $options"
   } else {
      error "Usage: ssigma in out number ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule la moyenne kappa-sigma, pixel à pixel des images de la pile (CF @ref ttus1)
#  @details le paramètre kappa permet de choisir le seuil de réjection
#  des valeurs hors de la plage [moyenne-kappa*écart-type ; moyenne+kappa*écart-type]. Par défaut [kappa=3].
#  @code
#  ssigma in out number kappa ?first_index? ?tt_options?
#  @endcode
#
proc ssk {args} {
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SK kappa=[lindex $args 3] $options"
   } else {
      error "Usage: ssk in out number kappa ?first_index? ?tt_options?"
   }
}

## @brief produit une seule image en sortie à partir d'une pile d'images ;
#  calcule la valeur triée, pixel à pixel, des images de la pile (CF @ref ttus1)
#  @details la liste des valeurs de chaque pixel (x,y) de toutes les images de la pile sont triées dans l'ordre croissant.
#  Le paramètre optionnel [percent] permet de choisir la valeur triée.
#  La valeur triée est prise égale au minimum si [percent=0], à la valeur médiane si [percent=50] et au maximum si [percent=100].
#  percent peut prendre n'importe quelle valeur entre 0 et 100. Par défaut [percent=50].
#  @code
#  ssort in out number percent ?first_index? ?tt_options?
#  @endcode
#
proc ssort {args} {
   #--- in out number percent ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" SORT percent=[lindex $args 3] $options"
   } else {
      error "Usage: ssort in out number percent ?first_index? ?tt_options?"
   }
}

proc sub {args} {
   #--- operand value
   if {[llength $args] == 2} {
      set operand [lindex $args 0]
      set diroperand [file dirname "$operand"]
      set len [expr [string length $::audace(rep_images)]-1]
      if {($len>=0)&&($diroperand==".")} {
         set operand [ file join $::audace(rep_images) $operand ]
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      buf$::audace(bufNo) sub "$operand" [lindex $args 1]
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: sub operand value"
   }
}

proc sub1 {args} {
   #--- in operand out const ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set options ""
      if {$n>=5} {
         set options "[lrange $args 4 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" . . \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" . \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: sub1 in operand out const ?tt_options?"
   }
}

proc sub2 {args} {
   #--- in operand out const number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set operand [lindex $args 1]
      if {[file dirname $operand]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set operand [ file join $::audace(rep_images) $operand ]
         }
      }
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ext [file extension "$operand"]
      if {$ext==""} {
         set operand "${operand}$::conf(extension,defaut)"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 2]\" 1 \"$ext\" SUB \"file=$operand\" offset=[lindex $args 3] $options"
   } else {
      error "Usage: sub2 in operand out const number ?first_index? ?tt_options?"
   }
}

proc subdark2 {args} {
   #--- in dark offset out number exptime dexptime ?first_index?
   set n [llength $args]
   if {$n>=7} {
      set in         "[lindex $args 0]"
      set dark       "[lindex $args 1]"
      set offset     "[lindex $args 2]"
      set out        "[lindex $args 3]"
      set number     "[lindex $args 4]"
      set exptime    "[lindex $args 5]"
      set dexptime   "[lindex $args 6]"

      if {$n>=8} {
         set first "[lindex $args 7]"
      } else {
         set first 1
      }

      if {$n>=9} {
         set unsmearing "[lindex $args 8]"
      } else {
         set unsmearing 1
      }

      if {[file dirname $dark]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set dark [ file join $::audace(rep_images) $dark ]
         }
      }

      if {[file dirname $offset]=="."} {
         set len [expr [string length $::audace(rep_images)]-1]
         if {$len>=0} {
            set offset [ file join $::audace(rep_images) $offset ]
         }
      }

      set ext [file extension "$dark"]
      if {$ext==""} {
         set operand "${dark}$::conf(extension,defaut)"
      }

      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      set command "IMA/SERIES \"$::audace(rep_images)\" \"$in\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"$out\" 1 \"$ext\" SUBDARK \"dark=$dark\" \"bias=$offset\" \"exptime=$exptime\" \"dexptime=$dexptime\" "
      ::console::disp "subdark2 : $command\n"
      ttscript2 $command
   } else {
      #---                    0  1     2     3    4       5      6           7            8
      error "Usage: subdark2 in dark offset out number exptime dexptime ?first_index?"
   }
}

proc subsky {args} {
   #--- back_kernel back_threshold ?tt_options?
   set argc [llength $args]
   if { $argc < 2} {
      error "Usage: subsky back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set back_kernel [lindex $args 0]
   set back_threshold [lindex $args 1]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set options ""
   if {$argc>=3} {
      set options "[lrange $args 2 end]"
   }
   buf$::audace(bufNo) imaseries "back back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
}

proc subsky1 {args} {
   #--- in out back_kernel back_threshold ?tt_options?
   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: subsky1 in out back_kernel back_threshold ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set back_kernel [lindex $args 2]
   set back_threshold [lindex $args 3]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set options ""
   if {$argc>=5} {
      set options "[lrange $args 4 end]"
   }
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   ttscript2 $script
}

proc subsky2 {args} {
   #--- in out number back_kernel back_threshold ?first_index? ?tt_options?"
   set argc [llength $args]
   if { $argc < 5} {
      error "Usage: subsky2 in out number back_kernel back_threshold ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set back_kernel [lindex $args 3]
   set back_threshold [lindex $args 4]
   if {$back_threshold<0} {
      set back_threshold 0
   }
   if {$back_threshold>1} {
      set back_threshold 1
   }
   set first 1
   set options ""
   if {$argc>=6} {
      set first "[lindex $args 5]"
      if {$argc>=7} {
         set options "[lrange $args 6 end]"
      }
   }
   set ni [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" $first $ni \"$ext\" \"$path\" \"$out\" 1 \"$ext\" BACK back_kernel=$back_kernel back_threshold=$back_threshold sub $options"
   ttscript2 $script
}


#------------------------------------------------------
## @brief translate une image dans le buffer de dx, dy (CF @ref ttus1)
#  @code
#  trans $dx $dy
#  @endcode
#  @param args décalage dx dy en abscisse et en ordonnée
#
proc trans {args} {
   #--- dx dy
   if {[llength $args] == 2} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "TRANS trans_x=[lindex $args 0] trans_y=[lindex $args 1]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: trans dx dy"
   }
}

proc trans2 {args} {
   #--- in out dx dy number ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=5} {
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 4]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" TRANS trans_x=[lindex $args 2] trans_y=[lindex $args 3] $options"
   } else {
      error "Usage: trans2 in out dx dy number ?first_index? ?tt_options?"
   }
}

proc uncosmic {args} {
   #--- coef
   # 0 = maximum efficiency
   # 0 to infinite = decrease efficiency
   # Typical value is 1
   #--- threshold
   # Method to keep a good photometry with cosmic suppresion.
   # We suppress only the brightest cosmics to let the photon signal unchanged.
   # To be efficient, the threshold must be at 3 times the noise.
   # By this way the kernel_coef can be strong with no photometric influence.
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } elseif {[llength $args] == 2} {
      set ext $::conf(extension,defaut)
      buf$::audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0] threshold=[lindex $args 1]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: uncosmic coef ?threshold?"
   }
}

proc uncosmic2 {args} {
   #--- in out number coef ?first_index? ?tt_options?
   set n [llength $args]
   if {$n>=4} {
      set first 1
      if {$n==5} {
         set first "[lindex $args 4]"
      }
      set options ""
      if {$n>=6} {
         set first "[lindex $args 4]"
         set options "[lrange $args 5 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" 1 \"$ext\" FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 3] $options"
   } else {
      error "Usage: uncosmic2 in out number coef ?first_index? ?tt_options?"
   }
}

proc superuncosmic { args } {
   #--- coef
   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)

      buf$bufNo save a
      set bf [buf::create]
      buf$bf load a
      buf$bf imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $::tools_cdl::uncosm_param1 0]"
      buf$bf save b
      buf$bf load a
      buf$bf sub b 0
      buf$bf clipmin $::tools_cdl::uncosm_param2
      buf$bf clipmax [expr $::tools_cdl::uncosm_param2+1]
      buf$bf offset [expr -$::tools_cdl::uncosm_param2]
      buf$bf save dirac
      buf$bf load b
      buf$bf imaseries "PROD \"file=dirac\" constant=1"
      buf$bf save bb

      buf$bf load a
      buf$bf imaseries "PROD \"file=dirac\" constant=1"
      buf$bf save aa

      buf$bf load a
      buf$bf sub aa 0
      buf$bf add bb 0
      buf$bf copyto $bufNo
      buf::delete $bf

      catch { file delete -force  aa.fit a.fit bb.fit b.fit dirac.fit }

      #buf$::audace(bufNo) imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=[lindex $args 0]"
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: uncosmic coef"
   }
}

proc window1 {args} {
   #--- in out {x1 y1 x2 y2} ?tt_options?
   set argc [llength $args]
   if { $argc < 3} {
      error "Usage: window1 in out {x1 y1 x2 y2} ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set box [lindex $args 2]
   set x1 [lindex $box 0]
   set y1 [lindex $box 1]
   set x2 [lindex $box 2]
   set y2 [lindex $box 3]
   if {$x2<$x1} {
      set dummy $x1
      set x1 $x2
      set x2 $dummy
   }
   if {$y2<$y1} {
      set dummy $y1
      set y1 $y2
      set y2 $dummy
   }
   set options ""
   if {$argc>=4} {
      set options "[lrange $args 3 end]"
   }
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set script "IMA/SERIES \"$path\" \"$in\" . . \"$ext\" \"$path\" \"$out\" . \"$ext\"  WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"
   ttscript2 $script
}

proc window2 {args} {
   #--- in out number {x1 y1 x2 y2} ?first_index? ?tt_options?
   set argc [llength $args]
   if { $argc < 4} {
      error "Usage: window2 in out number {x1 y1 x2 y2} ?first_index? ?tt_options?"
      return $error;
   }
   #--- decode la ligne de commande
   set in [lindex $args 0]
   set out [lindex $args 1]
   set number [lindex $args 2]
   set box [lindex $args 3]
   set x1 [lindex $box 0]
   set y1 [lindex $box 1]
   set x2 [lindex $box 2]
   set y2 [lindex $box 3]
   if {$x2<$x1} {
      set dummy $x1
      set x1 $x2
      set x2 $dummy
   }
   if {$y2<$y1} {
      set dummy $y1
      set y1 $y2
      set y2 $dummy
   }
   set first 1
   set options ""
   if {$argc>=5} {
      set first "[lindex $args 4]"
      if {$argc>=6} {
         set options "[lrange $args 5 end]"
      }
   }
   set ni [expr $number+$first-1]
   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set err ""
   for {set k $first} {$k<=$ni} {incr k} {
      buf1 load $path/${in}${k}${ext}
      set naxis1 [buf1 getpixelswidth]
      set naxis2 [buf1 getpixelsheight]
      if {$naxis1<$x2} {
         append err "Problem in ${in}${k} (naxis1=$naxis1 < $x2)\n"
      }
      if {$naxis2<$y2} {
         append err "Problem in ${in}${k} (naxis2=$naxis2 < $y2)\n"
      }
   }
   if {$err==""} {
      for {set k $first} {$k<=$ni} {incr k} {
         buf1 load $path/${in}${k}${ext}
         buf1 window [list $x1 $y1 $x2 $y2]
         buf1 save $path/${out}${k}${ext}
      }
   } else {
      error $err
   }
   return ""
}

#------------------------------------------------------
#  brief fonction qui ajoute les champs SIA à une image
#  details détermine les coordonnées du polynome
#  note proc appelee par set_poly_sia
#  param cpt rang de SIAP
#  param x coordonnées x du pixel
#  param y coordonnées y du pixel
#  param bufno numéro du buffer de l'image
#
proc put_poly { cpt x y bufno } {

   set radec [buf$bufno xy2radec [list $x $y]]
   incr cpt
   buf$bufno setkwd [list "SIAP$cpt"  "$x;$y;[lindex $radec 0];[lindex $radec 1]" "string" "Polygon point $cpt" ""]
   return $cpt
}

#------------------------------------------------------
#  brief fonction qui ajoute les champs SIA à une image
#  details proc appelée par calibwcs
#  param bufno numéro du buffer
#
proc set_poly_sia { {bufno 1} } {

   buf$bufno setkwd [list "SIAKWDS"  "Y"   "string" "Header Fits SIA Compliant" "Y or N"]
   buf$bufno setkwd [list "COORDSYS" "FK5" "string" "coordinate system used"    "FK5 or ICRS"]

   set nbpts 40
   buf$bufno setkwd [list "SIAPOLNB"  $nbpts "int" "x;y;ra;dec : Polygon point number" ""]

   set naxis1 [lindex [buf$bufno getkwd "NAXIS1"] 1]
   set naxis2 [lindex [buf$bufno getkwd "NAXIS2"] 1]

   set xpas [expr int($naxis1 / ( ($nbpts / 4) - 0.5 ) ) ]
   set ypas [expr int($naxis2 / ( ($nbpts / 4) - 0.5 ) ) ]
   set cpt 0

   # 1er coin
   set x 0
   set y 0
   set cpt [put_poly $cpt $x $y $bufno]

   # 1ere ligne X
   for {set x $xpas} {$x < $naxis1} {incr x $xpas} {
      set cpt [put_poly $cpt $x $y $bufno]
   }

   # 2eme coin
   set x [expr $naxis1 -1 ]
   set cpt [put_poly $cpt $x $y $bufno]

   # 2eme ligne Y
   for {set y $ypas} {$y < $naxis2} {incr y $ypas} {
      set cpt [put_poly $cpt $x $y $bufno]
   }

   # 3eme coin
   set y [expr $naxis2 -1 ]
   set cpt [put_poly $cpt $x $y $bufno]

   # 3eme ligne X -
   set y [expr $naxis2 -1 ]
   for {set x [expr $naxis1 -1 ]} {$x > 0} {set x [expr $x - $xpas]} {
      set cpt [put_poly $cpt $x $y $bufno]
   }

   # 4eme coin
   set x 0
   set y [expr $naxis2 -1]
   set cpt [put_poly $cpt $x $y $bufno]

   # 4eme ligne Y -
   set x 0
   for {set y [expr $naxis2 -1]} {$y > 0} {set y [expr $y - $ypas]} {
      set cpt [put_poly $cpt $x $y $bufno]
   }

}

#------------------------------------------------------
## @brief fonction de calibration automatique de l'image dans le buffer
#  @code
#  calibwcs ra dec pixsize1 pixsize2 foclen USNO Path_of_Catalog
#  ou en utilisant les mots clés du header de l'image :
#  calibwcs * * * * * USNO Path_of_Catalog
#  ou en combinant :
#  calibwcs ra * * * foclen USNO Path_of_Catalog
#  @endcode
#  @param args Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder + paramètres optionels
#  - Angle_ra angle RA (HMS ou degrés) ou *
#  - Angle_dec  angle DEC (DMS ou degrés) ou *
#  - pixsize1_mu (en microns) ou *
#  - pixsize2_mu (en microns) ou *
#  - foclen longueur focale en m ou *
#  - catalog { USNO | MICROCAT }
#  - path_of_catalog chemin du catalog
#  - + paramètres optionels :
#  - del_tmp_files
#    - 1 : efface tous les fichiers temporaires (par défaut)
#    - 0 : garde tous les fichiers temporaires
#  - yes_visu
#    - 0 : ne visualise pas l'image à la fin du traitement
#    - 1 : visualise l'image à la fin du traitement (par défaut)
#  - maglimit 10     : magnitude limite des étoiles du catalogue (par défault aucune limite)
#  - add_sia         : ajoute les champs SIA à une image
#  - tmp_dir         : spécifie un répertoire de travail (sinon c'est cd)
#  - foclendif       : spécifie un seuil de difference de focale entre l'entre et la sortie (en pourcent) pour eviter de calculer la carte de sortie
#  - nbstarmin : Minimum number of stars detected by Sextractor to perform the matching.
#
proc calibwcs { args } {

   set argc [llength $args]
   if {$argc >= 5} {
      #--- Chargement des arguments
      set Angle_ra    [lindex $args 0]
      set Angle_dec   [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen   [lindex $args 4]
      set cat_format ""
      set cat_folder ""
      if {$argc >= 7} {
         set cat_format [lindex $args 5]
         set cat_folder [lindex $args 6]
      }
      set del_tmp_files 1
      set yes_visu 1
      set add_sia 0
      set maglim ""
      set tmp_dir .
      set foclendif ""
      set nbstarmin 0
      if {$argc >= 9} {
         for {set k 7} {$k<[expr $argc-1]} {incr k} {
            set key [lindex $args $k]
            if {$key=="-del_tmp_files"} {
               set del_tmp_files [lindex $args [expr $k+1]]
            }
            if {$key=="-yes_visu"} {
               set yes_visu [lindex $args [expr $k+1]]
            }
            if {$key=="-maglimit"} {
               set maglim [lindex $args [expr $k+1]]
               set maglim "\"magrlim=$maglim\" \"magblim=$maglim\""
            }
            if {$key=="-add_sia"} {
               set add_sia 1
            }
            if {$key=="-tmp_dir"} {
               set tmp_dir [lindex $args [expr $k+1]]
            }
            if {$key=="-foclendif"} {
               set foclendif [lindex $args [expr $k+1]]
            }
            if {$key=="-nbstarmin"} {
               set nbstarmin [lindex $args [expr $k+1]]
            }
         }
      }

      set pi [expr 4*atan(1.)]
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]

      if {$Angle_ra=="*"} {
         set Angle_ra [lindex [buf$::audace(bufNo) getkwd RA] 1]
      }
      if {$Angle_dec=="*"} {
         set Angle_dec [lindex [buf$::audace(bufNo) getkwd DEC] 1]
      }
      if {$valpixsize1=="*"} {
         set valpixsize1 [lindex [buf$::audace(bufNo) getkwd PIXSIZE1] 1]
      }
      if {$valpixsize2=="*"} {
         set valpixsize2 [lindex [buf$::audace(bufNo) getkwd PIXSIZE2] 1]
      }
      if {$valfoclen=="*"} {
         set valfoclen [lindex [buf$::audace(bufNo) getkwd FOCLEN] 1]
      }
      #--- Construction des parametres WCS
      set val(CRPIX1) [expr $naxis1/2]
      set val(CRPIX2) [expr $naxis2/2]
      set val(RA) [mc_angle2deg $Angle_ra 360]
      set val(DEC) [mc_angle2deg $Angle_dec 90]
      set val(CRVAL1) $val(RA)
      set val(CRVAL2) $val(DEC)
      set mult 1e-6
      set val(CDELT1) [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
      set val(CDELT2) [expr  2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
      set val(CROTA2) 0
      set val(FOCLEN) $valfoclen
      set val(PIXSIZE1) $valpixsize1
      set val(PIXSIZE2) $valpixsize2
      set cosr [expr cos($val(CROTA2)*$pi/180.)]
      set sinr [expr sin($val(CROTA2)*$pi/180.)]
      set val(CD1_1) [expr $val(CDELT1)*$cosr ]
      set val(CD1_2) [expr  abs($val(CDELT2))*$val(CDELT1)/abs($val(CDELT1))*$sinr ]
      set val(CD2_1) [expr -abs($val(CDELT1))*$val(CDELT2)/abs($val(CDELT2))*$sinr ]
      set val(CD2_2) [expr $val(CDELT2)*$cosr ]

      #--- Mise a jour du Header Fits
      set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
      set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              mum                             mum}
      set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        float          float                           float}
      set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}

      set n [llength $astrom(kwds)]
      for {set k 0 } { $k<$n } {incr k} {
         set kwd [lindex $astrom(kwds) $k]
         set value [eval set val($kwd)]
         set type [lindex $astrom(types) $k]
         set unit [lindex $astrom(units) $k]
         set comment [lindex $astrom(comments) $k]
         buf$::audace(bufNo) setkwd [list $kwd $value $type $unit $comment]
      }
      buf$::audace(bufNo) setkwd [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]
      catch {buf$::audace(bufNo) delkwd RADESYS}
      buf$::audace(bufNo) setkwd [list RADECSYS FK5 string "Mean Place IAU 1984 system" ""]
      buf$::audace(bufNo) setkwd [list LONPOLE 180 float "Long. of the celest.NP in native coor.sys" "degres"]
      buf$::audace(bufNo) setkwd [list CTYPE1 RA---TAN string "Gnomonic projection" ""]
      buf$::audace(bufNo) setkwd [list CTYPE2 DEC--TAN string "Gnomonic projection" ""]
      buf$::audace(bufNo) setkwd [list CUNIT1 deg string "Angles are degrees always" ""]
      buf$::audace(bufNo) setkwd [list CUNIT2 deg string "Angles are degrees always" ""]
      buf$::audace(bufNo) setkwd [list CATASTAR 0 int "Nb stars matched" ""]

      #--- check les catalogues
      if {[string toupper $cat_format] ni [list USNO MICROCAT]} {
         set comment "This catalog ($cat_format) is not valid. It must be only USNO or MICROCAT!"
         error $comment
      }
      if {[file exists $cat_folder]==1} {
         if {[string toupper $cat_format] eq "USNO"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain [file join $cat_folder "*.ACC"]]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain [file join $cat_folder "*.CAT"]]
            if {[llength $fics]<24} {
               error $comment
            }
         } elseif {[string toupper $cat_format] eq "MICROCAT"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain -dir [file join $cat_folder usno] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain -dir [file join $cat_folder tyc] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
         }
      } else {
         set comment "Path to the catalog does not exists:\n$cat_folder\n"
         error $comment
      }

      #--- Identification des sources
      if {($cat_format!="")} {
         set ext $::conf(extension,defaut)
         #--- Remplacement de "$::audace(rep_images)" par "." dans "mypath" - Cela permet a
         #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
         #--- espaces et ayant une longueur superieure a 70 caracteres
         set mypath $tmp_dir
         set sky0 dummy0
         set cattype $cat_format
         set cdpath "$cat_folder"
         if { ( [ string length $cdpath ] > 0 ) && ( [ string index "$cdpath" end ] != "/" ) } {
            append cdpath "/"
         }
         set sky dummy
         catch {buf$::audace(bufNo) delkwd CATASTAR}
         buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         createFileConfigSextractor $mypath
         buf$::audace(bufNo) save [ file join ${mypath} ${sky}$ext ]
         sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"
         set erreur 0
         if {$nbstarmin>0} {
            set f [open $mypath/catalog.cat r]
            set nbstar [llength [split [read $f] \n]]
            if {$nbstar<$nbstarmin} {
               set erreur 1
               set catastar 0
            }
         }
         if {$erreur==0} {
            set erreur [ catch { ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype $maglim \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}a.jpg\" \"tmp_dir=$mypath\""} msg ]
         }
         if {$erreur==0} {
            ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY \"objefile=$mypath/catalog.cat\" nullpixel=-10000 delta=5 epsilon=0.0002 file_ascii=${mypath}/ascii.txt \"tmp_dir=$mypath\""
            set valid 1
            if {$foclendif!=""} {
               buf$::audace(bufNo) load [ file join ${mypath} ${sky}$ext ]
               set catastar [lindex [buf$::audace(bufNo) getkwd CATASTAR] 1]
               set valfoclen1 [lindex [buf$::audace(bufNo) getkwd FOCLEN] 1]
               set focalendif_percent [expr 100.*abs(1.*$valfoclen1-$valfoclen)/$valfoclen]
               # --- test if the focal length is close to the expected one (e.g. 5%)
               if {$focalendif_percent>$foclendif} {
                  set valid 0
               }
            }
            if {$valid==1} {
               ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}b.jpg\" $maglim \"tmp_dir=$mypath\""
            }
            ttscript2 "IMA/SERIES \"$mypath\" \"x$sky\" . . \"$ext\" . . . \"$ext\" DELETE \"tmp_dir=$mypath\""
            ttscript2 "IMA/SERIES \"$mypath\" \"c$sky\" . . \"$ext\" . . . \"$ext\" DELETE \"tmp_dir=$mypath\""
            buf$::audace(bufNo) load [ file join ${mypath} ${sky}$ext ]
         }
         if {$del_tmp_files==1} {
            ::astrometry::delete_lst $tmp_dir
            ::astrometry::delete_dummy $tmp_dir
            deleteFileConfigSextractor $tmp_dir
         }
         #---
      }
      #---
      if {$yes_visu==1} {
         ::audace::autovisu $::audace(visuNo)
      }
      if {$add_sia==1} {
         set_poly_sia $::audace(bufNo)
      }
      set catastar [lindex [buf$::audace(bufNo) getkwd CATASTAR] 1]
      return $catastar
   } else {
      set line "Usage: \n"
      append line "calibwcs Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder\n"
      append line "# ou en utilisant les mots cles du header de l'image :\n"
      append line "calibwcs * * * * * USNO|MICROCAT cat_folder \n"
      append line "# Parametres optionels :\n"
      append line "# -del_tmp_files 1 : efface tous les fichiers temporaires (par defaut)\n"
      append line "# -del_tmp_files 0 : garde tous les fichiers temporaires\n"
      append line "# -yes_visu 0        : ne visualise pas l'image a la fin du traitement\n"
      append line "# -yes_visu 1        : visualise l'image a la fin du traitement (par defaut)\n"
      append line "# -maglimit 10       : magnitude limite des etoiles du catalogue (par default aucune limite)\n"
      append line "# -add_sia           : Ajoute les champs SIA a une image\n"
      append line "# -tmp_dir           : utilise un repertoire autre que pwd pour les fichiers temporaires\n"
      error $line
   }
}

#------------------------------------------------------
## @brief nouvelle fonction de calibration automatique de l'image dans le buffer
#  @code
#  calibwcs_new Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m cat_name cat_folder
#  ou en utilisant les mots clés du header de l'image :
#  calibwcs * * * * * USNO Path_of_Catalog
#  ou en combinant :
#  calibwcs ra * * * foclen USNO Path_of_Catalog
#  @endcode
#  @param args Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m cat_name cat_folder + paramètres optionels
#  - Angle_ra angle RA (HMS ou degrés) ou *
#  - Angle_dec  angle DEC (DMS ou degrés) ou *
#  - pixsize1_mu (en microns) ou *
#  - pixsize2_mu (en microns) ou *
#  - foclen longueur focale en m ou *
#  - cat_name { USNO | MICROCAT }
#  - path_of_catalog chemin du catalog
#  - paramètres optionels suivants :
#     - del_tmp_files
#        - 1            : efface tous les fichiers temporaires (par défaut)
#        - 0            : garde tous les fichiers temporaires
#     - yes_visu
#        - 0            : ne visualise pas l'image à la fin du traitement
#        - 1            : visualise l'image à la fin du traitement (par défaut)
#     - add_sia         : ajoute les champs SIA à une image
#     - tmp_dir         : spécifie un répertoire de travail (sinon c'est cd)
#     - delta           : distance d'incertitude (pixels)
#     - nmax            : nombre maximal d'étoiles pour l'appariement
#     - flux_criterion  : flag pour ajouter un critère sur le flux dans les triplets
#
proc calibwcs_new { args } {

   set argc [llength $args]
   if {$argc >= 5} {
      #--- Chargement des arguments
      set Angle_ra    [lindex $args 0]
      set Angle_dec   [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen   [lindex $args 4]
      set delta 3.5
      set nmax 35
      set flux_criterion 0
      set del_tmp_files 1
      set yes_visu 1
      set add_sia 0
      set maglim ""
      set tmp_dir .
      set cat_format ""
      set cat_folder ""
      if {$argc >= 7} {
         set cat_format [lindex $args 5]
         set cat_folder [lindex $args 6]
      }
      if {$argc >= 9} {
         for {set k 7} {$k<[expr $argc-1]} {incr k} {
            set key [lindex $args $k]
            if {$key=="-del_tmp_files"} {
               set del_tmp_files [lindex $args [expr $k+1]]
            }
            if {$key=="-yes_visu"} {
               set yes_visu [lindex $args [expr $k+1]]
            }
            if {$key=="-maglimit"} {
               set maglim [lindex $args [expr $k+1]]
               set maglim "\"magrlim=$maglim\" \"magblim=$maglim\""
            }
            if {$key=="-add_sia"} {
               set add_sia 1
            }
            if {$key=="-tmp_dir"} {
               set tmp_dir [lindex $args [expr $k+1]]
            }
            if {$key=="-delta"} {
               set delta $delta
            }
            if {$key=="-nmax"} {
               set delta $nmax
            }
            if {$key=="-flux_criterion"} {
               set delta $flux_criterion
            }
         }
      }

      set pi [expr 4*atan(1.)]
      set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]

      set valid 0
      if {$Angle_ra=="*"} {
         set Angle_ra [lindex [buf$::audace(bufNo) getkwd RA] 1]
         incr valid
      }
      if {$Angle_dec=="*"} {
         set Angle_dec [lindex [buf$::audace(bufNo) getkwd DEC] 1]
         incr valid
      }
      if {$valpixsize1=="*"} {
         set valpixsize1 [lindex [buf$::audace(bufNo) getkwd PIXSIZE1] 1]
         incr valid
      }
      if {$valpixsize2=="*"} {
         set valpixsize2 [lindex [buf$::audace(bufNo) getkwd PIXSIZE2] 1]
         incr valid
      }
      if {$valfoclen=="*"} {
         set valfoclen [lindex [buf$::audace(bufNo) getkwd FOCLEN] 1]
         incr valid
      }
      if {$valid!=5} {
         set wcs [wcs_optic2wcs [expr $naxis1/2] [expr $naxis2/2] $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen 0]
         wcs_wcs2buf $wcs $::audace(bufNo)
      }

      #--- check les catalogues
      #if {[string toupper $cat_format] ni [list USNO MICROCAT]} {
      #   set comment "This catalog ($cat_format) is not valid. It must be only USNO or MICROCAT!"
      #   error $comment
      #}
      if {[file exists $cat_folder]==1} {
         if {[string toupper $cat_format] eq "USNO"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain [file join $cat_folder "*.ACC"]]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain [file join $cat_folder "*.CAT"]]
            if {[llength $fics]<24} {
               error $comment
            }
         } elseif {[string toupper $cat_format] eq "MICROCAT"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain -dir [file join $cat_folder usno] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain -dir [file join $cat_folder tyc] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
         }
      } else {
         set comment "Path to the catalog does not exists:\n$cat_folder\n"
         error $comment
      }

      #--- Construction des parametres WCS
      if {($cat_format!="")} {
         if {[string toupper $cat_format]=="USNO"} {
            set Cat_format USNOA2
         } else {
            set Cat_format [string toupper $cat_format]
         }
         set wcs [wcs_optic2wcs [expr $naxis1/2] [expr $naxis2/2] $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen 0]
         wcs_wcs2buf $wcs $::audace(bufNo)
         #wcs_dispkwd $wcs "" public
         set star0s [focas_buf2stars $::audace(bufNo) $Cat_format $tmp_dir]
         set cata0s [focas_db2catas $Cat_format $cat_folder]
         set ns [llength $star0s]
         set nc [llength $cata0s]
         if {($ns<3)||($nc<3)} {
            error "Not enough stars ($ns stars in the image, $nc stars in the catalog)\n"
         }
         set couples [focas_catastars2pairs $star0s $cata0s $Cat_format $delta $nmax $flux_criterion]
         set np [llength [lindex $couples 1]]
         if {($np<3)} {
            error "$np stars matched is < 3 ($ns stars in the image, $nc stars in the catalog). impossible to compute WCS parameters.\n"
         }
         set wcs [wcs_focaspairs2wcs $couples 1 [expr $naxis1/2] [expr $naxis2/2]]
         wcs_wcs2buf $wcs $::audace(bufNo)
         set wcs [wcs_buf2wcs $::audace(bufNo)]
         set wcs [wcs_update_optic $wcs]
         #wcs_dispkwd $wcs "" public
         wcs_wcs2buf $wcs $::audace(bufNo)
         if {$del_tmp_files==1} {
            ::astrometry::delete_lst $tmp_dir
            ::astrometry::delete_dummy $tmp_dir
            deleteFileConfigSextractor $tmp_dir
         }
         #---
      }
      #---
      if {$yes_visu==1} {
         ::audace::autovisu $::audace(visuNo)
      }
      if {$add_sia==1} {
         set_poly_sia $::audace(bufNo)
      }
      set res [buf$::audace(bufNo) getkwd WCSMATCH]
      set catastar [lindex $res 1]
      buf$::audace(bufNo) setkwd [list CATASTAR [string trim [lindex $res 1]] [string trim [lindex $res 2]] [string trim [lindex $res 3]] [string trim [lindex $res 4]]]
      return $catastar
   } else {
      set line "Usage: \n"
      append line "calibwcs_new Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m cat_name cat_folder\n"
      append line "\n"
      append line "# ou en utilisant les mots cles du header de l'image :\n"
      append line "calibwcs_new * * * * * cat_name cat_folder ?delta nmax? ?flux_criterion?\n"
      append line "\n"
      append line "# Parametres catalogues :\n"
      append line "# cat_name = USNOA2 MICROCAT TYCHO2 UCAC4 \n"
      append line "\n"
      append line "# Parametres optionels :\n"
      append line "# -del_tmp_files 1 : efface tous les fichiers temporaires (par defaut)\n"
      append line "# -del_tmp_files 0 : garde tous les fichiers temporaires\n"
      append line "# -yes_visu 0        : ne visualise pas l'image a la fin du traitement\n"
      append line "# -yes_visu 1        : visualise l'image a la fin du traitement (par defaut)\n"
      append line "# -add_sia           : Ajoute les champs SIA a une image\n"
      append line "# -tmp_dir           : utilise un repertoire autre que pwd pour les fichiers temporaires\n"
      append line "# -delta             : distance d'incertitude (pixels)\n"
      append line "# -nmax              : Nombre maximal d etoiles pour l'appariement\n"
      append line "# -flux_criterion    : Flag pour ajouter un critere sur le flux dans les triplets\n"
      error $line
   }
}

#------------------------------------------------------
## @brief fonction de calibration automatique pour plusieurs images
#  @details met en oeuvre calibwcs pour une série d'images
#  @code exemple :
#  calibwcs2 in out number Angle_ra Angle_dec valpixsize1 valpixsize2 valfoclen cat_format cat_folder
#  @endcode
#  @param args liste d'arguments (voir exemple)
#
proc calibwcs2 { args } {

   if {[llength $args] >= 5} {
      set in [lindex $args 0]
      set out [lindex $args 1]
      set number [lindex $args 2]
      set Angle_ra [lindex $args 3]
      set Angle_dec [lindex $args 4]
      set valpixsize1 [lindex $args 5]
      set valpixsize2 [lindex $args 6]
      set valfoclen [lindex $args 7]
      set cat_format [lindex $args 8]
      set cat_folder [lindex $args 9]
      set first_index 1
      ::console::affiche_resultat "args = [llength $args] = $args\n"
      if {[llength $args] >= 11} {
         set first_index [lindex $args 10]
      }
      #---
      set kdeb $first_index
      set kfin [expr $kdeb+$number-1]
      for {set k $kdeb } { $k<=$kfin } {incr k} {
         ::console::affiche_resultat "Calibration WCS for ${out}${k}...\n"
         loadima ${in}${k}
         set catastar [calibwcs $Angle_ra $Angle_dec $valpixsize1 $valpixsize2 $valfoclen $cat_format $cat_folder]
         saveima ${out}${k}
         ::console::affiche_resultat "Image ${out}${k} WCS calibrated with $catastar matched stars.\n"
      }
   } else {
      error "Usage: calibwcs2 in out number Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?first_index?"
   }
}

#------------------------------------------------------
## @brief créé une image simulée avec des valeurs numériques fournies
# ou extraites (*) de l'en-tête de l'image dans le buffer (CF @ref tuto_simulimage)
#  @code examples :
#  simulimage  Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type? ?newstar_type? ?newstar_ra? ?newstar_dec? ?newstar_mag? ?crota2? ?naxis1? ?naxis2? ?bufno?
#  simulimage * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
#  simulimage * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0 REPLACE 164.630566 67.529504 8
#  simulimage * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0 NONE 0 0 0 45.67 2
#  @endcode
#  @param args liste d'arguments :
#  - Angle_ra angle RA (HMS ou degrés) ou *
#  - Angle_dec  angle DEC (DMS ou degrés) ou *
#  - pixsize1_mu (en microns) ou *
#  - pixsize2_mu (en microns) ou *
#  - foclen longueur focale en m ou *
#  - catalog { USNO | MICROCAT }
#  - path_of_catalog chemin du catalog
#  - les arguments exposure_s ,fwhm_pix, teldiam_m
#  - les arguments  colfilter, sky_brightness_mag/arcsec2, quantum_efficiency, gain_e/ADU, readout_noise_e,
#    shutter_mode, bias_level_ADU, thermic_response_e/pix/sec, Tatm, Topt, EMCCD_multsont ceux de @ref etc_tools.tcl
#  - crota2 optionnel est l'angle de rotation par rapport au nord
#  - naxis1 et naxis2 optionnels definissent la taille de l'image
#  - bufno  optionnel est le numero de buffer vers lequel sera cree l'image
#  - les arguments :
#    - flat_type    0 par défaut
#    - newstar_type { void | NONE | REPLACE }
#    - newstar_ra   AD de la nouvelle étoile
#    - newstar_dec  DEC de la nouvelle étoile
#    - newstar_mag  mag de la nouvelle étoile
#  @remark proc utilisée par ::collector ::foc et ::eye
#
proc simulimage { args } {

   if {[llength $args] >= 5} {
      set Angle_ra [lindex $args 0]
      set Angle_dec [lindex $args 1]
      set valpixsize1 [lindex $args 2]
      set valpixsize2 [lindex $args 3]
      set valfoclen [lindex $args 4]
      set cat_format ""
      set cat_folder ""
      if {[llength $args] >= 7} {
         set cat_format [lindex $args 5]
         set cat_folder [lindex $args 6]
      }
      set k 6
      incr k ; set exposure 1             ; if {[llength $args] >= [expr 1+$k]} { set exposure [lindex $args $k] }
      incr k ; set fwhm 2.5               ; if {[llength $args] >= [expr 1+$k]} { set fwhm [lindex $args $k] }
      incr k ; set teldiam 1              ; if {[llength $args] >= [expr 1+$k]} { set teldiam [lindex $args $k] }
      incr k ; set colfilter R            ; if {[llength $args] >= [expr 1+$k]} { set colfilter [lindex $args $k] }
      incr k ; set sky_brightness 20.9    ; if {[llength $args] >= [expr 1+$k]} { set sky_brightness [lindex $args $k] }
      incr k ; set quantum_efficiency 0.8 ; if {[llength $args] >= [expr 1+$k]} { set quantum_efficiency [lindex $args $k] }
      incr k ; set gain 2.5               ; if {[llength $args] >= [expr 1+$k]} { set gain [lindex $args $k] }
      incr k ; set readout_noise 10       ; if {[llength $args] >= [expr 1+$k]} { set readout_noise [lindex $args $k] }
      incr k ; set shutter_mode 1         ; if {[llength $args] >= [expr 1+$k]} { set shutter_mode [lindex $args $k] }
      incr k ; set bias_level 0           ; if {[llength $args] >= [expr 1+$k]} { set bias_level [lindex $args $k] }
      incr k ; set thermic_response 0     ; if {[llength $args] >= [expr 1+$k]} { set thermic_response [lindex $args $k] }
      incr k ; set tatm 0.6               ; if {[llength $args] >= [expr 1+$k]} { set tatm [lindex $args $k] }
      incr k ; set topt 0.85              ; if {[llength $args] >= [expr 1+$k]} { set topt [lindex $args $k] }
      incr k ; set elecmult 1             ; if {[llength $args] >= [expr 1+$k]} { set elecmult [lindex $args $k] }
      incr k ; set flat_type 0            ; if {[llength $args] >= [expr 1+$k]} { set flat_type [lindex $args $k] }
      incr k ; set newstar_type NONE      ; if {[llength $args] >= [expr 1+$k]} { set newstar_type [lindex $args $k] }
      incr k ; set newstar_ra 0           ; if {[llength $args] >= [expr 1+$k]} { set newstar_ra [mc_angle2deg [lindex $args $k]]] }
      incr k ; set newstar_dec 0          ; if {[llength $args] >= [expr 1+$k]} { set newstar_dec [mc_angle2deg [lindex $args $k] 90] }
      incr k ; set newstar_mag 0          ; if {[llength $args] >= [expr 1+$k]} { set newstar_mag [lindex $args $k] }
      incr k ; set crota2 0               ; if {[llength $args] >= [expr 1+$k]} { set crota2 [lindex $args $k] }
      incr k ; set naxis1 *               ; if {[llength $args] >= [expr 1+$k]} { set naxis1 [lindex $args $k] }
      incr k ; set naxis2 *               ; if {[llength $args] >= [expr 1+$k]} { set naxis2 [lindex $args $k] }
      incr k ; set bufno *                ; if {[llength $args] >= [expr 1+$k]} { set bufno [lindex $args $k] }

      #--- check les catalogues
      if {[string toupper $cat_format] ni [list USNO MICROCAT]} {
         set comment "This catalog ($cat_format) is not valid. It must be only USNO or MICROCAT!"
         error $comment
      }
      if {[file exists $cat_folder]==1} {
         if {[string toupper $cat_format] eq "USNO"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain [file join $cat_folder "*.ACC"]]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain [file join $cat_folder "*.CAT"]]
            if {[llength $fics]<24} {
               error $comment
            }
         } elseif {[string toupper $cat_format] eq "MICROCAT"} {
            set comment "Path to the catalog does not contain the $cat_format catalog!\n$cat_folder"
            set fics [glob -nocomplain -dir [file join $cat_folder usno] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
            set fics [glob -nocomplain -dir [file join $cat_folder tyc] -type f *.ACC]
            if {[llength $fics]<24} {
               error $comment
            }
         }
      } else {
         set comment "Path to the catalog does not exists:\n$cat_folder\n"
         error $comment
      }
      if {$bufno=="*"} {
         set bufno $::audace(bufNo)
      }
      if {$naxis1 eq "*" && $naxis2  eq "*"} {
            set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
            set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      }

      #---
      set pi [expr 4*atan(1.)]
      #set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
      #set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
      if {$Angle_ra!="*"} {
         set val(CRPIX1) [expr $naxis1/2]
         set val(CRPIX2) [expr $naxis2/2]
         set val(RA) [mc_angle2deg $Angle_ra 360]
         set val(DEC) [mc_angle2deg $Angle_dec 90]
         set val(CRVAL1) $val(RA)
         set val(CRVAL2) $val(DEC)
         set mult 1e-6
         set val(CDELT1) [expr -2*atan($valpixsize1/$valfoclen*$mult/2.)*180/$pi]
         set val(CDELT2) [expr  2*atan($valpixsize2/$valfoclen*$mult/2.)*180/$pi]
         set val(CROTA2) $crota2
         set val(FOCLEN) $valfoclen
         set val(PIXSIZE1) $valpixsize1
         set val(PIXSIZE2) $valpixsize2
         set cosr [expr cos($val(CROTA2)*$pi/180.)]
         set sinr [expr sin($val(CROTA2)*$pi/180.)]
         set val(CD1_1) [expr $val(CDELT1)*$cosr ]
         set val(CD1_2) [expr  abs($val(CDELT2))*$val(CDELT1)/abs($val(CDELT1))*$sinr ]
         set val(CD2_1) [expr -abs($val(CDELT1))*$val(CDELT2)/abs($val(CDELT2))*$sinr ]
         set val(CD2_2) [expr $val(CDELT2)*$cosr ]
         #---
         set astrom(kwds)     {RA                       DEC                       CRPIX1        CRPIX2        CRVAL1          CRVAL2           CDELT1    CDELT2    CROTA2                    CD1_1         CD1_2         CD2_1         CD2_2         FOCLEN         PIXSIZE1                        PIXSIZE2}
         set astrom(units)    {deg                      deg                       pixel         pixel         deg             deg              deg/pixel deg/pixel deg                       deg/pixel     deg/pixel     deg/pixel     deg/pixel     m              mum                             mum}
         set astrom(types)    {double                   double                    double        double        double          double           double    double    double                    double        double        double        double        float          float                           float}
         set astrom(comments) {"RA expected for CRPIX1" "DEC expected for CRPIX2" "X ref pixel" "Y ref pixel" "RA for CRPIX1" "DEC for CRPIX2" "X scale" "Y scale" "Position angle of North" "Matrix CD11" "Matrix CD12" "Matrix CD21" "Matrix CD22" "Focal length" "X pixel size binning included" "Y pixel size binning included"}
         #---
         set n [llength $astrom(kwds)]
         for {set k 0 } { $k<$n } {incr k} {
            set kwd [lindex $astrom(kwds) $k]
            set value [eval set val($kwd)]
            set type [lindex $astrom(types) $k]
            set unit [lindex $astrom(units) $k]
            set comment [lindex $astrom(comments) $k]
            buf$bufno setkwd [list $kwd $value $type $unit $comment]
         }
      }
      buf$bufno setkwd [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]
      buf$bufno setkwd [list RADECSYS FK5 string "Mean Place IAU 1984 system" ""]
      buf$bufno setkwd [list LONPOLE 180 float "Long. of the celest.NP in native coor.sys" "degres"]
      buf$bufno setkwd [list CTYPE1 RA---TAN string "Gnomonic projection" ""]
      buf$bufno setkwd [list CTYPE2 DEC--TAN string "Gnomonic projection" ""]
      buf$bufno setkwd [list CUNIT1 deg string "Angles are degrees always" ""]
      buf$bufno setkwd [list CUNIT2 deg string "Angles are degrees always" ""]
      buf$bufno setkwd [list CATASTAR 0 int "Nb stars matched" ""]
      #---
      if {($cat_format!="")} {
         set mypath "."
         set cattype $cat_format
         set cdpath "$cat_folder"
         if { ( [ string length $cdpath ] > 0 ) && ( [ string index "$cdpath" end ] != "/" ) } {
            append cdpath "/"
         }
         #::console::affiche_resultat "CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/cata.fit\" simulimage exposure=$exposure fwhmx=$fwhm  fwhmy=$fwhm teldiam=$teldiam colfilter=$colfilter sky_brightness=$sky_brightness qe=$quantum_efficiency gain=$gain readout_noise=$readout_noise shutter_mode=$shutter_mode bias_level=$bias_level thermic_response=$thermic_response tatm=$tatm topt=$topt elecmult=$elecmult flat_type=$flat_type newstar=$newstar_type ra=$newstar_ra dec=$newstar_dec mag=$newstar_mag"
         buf$bufno imaseries "CATCHART \"path_astromcatalog=$cdpath\" astromcatalog=$cattype \"catafile=${mypath}/cata.fit\" simulimage exposure=$exposure fwhmx=$fwhm  fwhmy=$fwhm teldiam=$teldiam colfilter=$colfilter sky_brightness=$sky_brightness qe=$quantum_efficiency gain=$gain readout_noise=$readout_noise shutter_mode=$shutter_mode bias_level=$bias_level thermic_response=$thermic_response tatm=$tatm topt=$topt elecmult=$elecmult flat_type=$flat_type newstar=$newstar_type ra=$newstar_ra dec=$newstar_dec mag=$newstar_mag"
         file delete [ file join ${mypath} cata.fit ]
      }
      #---
      buf$bufno setkwd [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]
      buf$bufno setkwd [list RADECSYS FK5 string "Mean Place IAU 1984 system" ""]
      #---
      set visunos [visu::list]
      foreach visuno $visunos {
         set bufno0 [visu$visuno buf]
         if {$bufno0==$bufno} {
            ::audace::autovisu $visuno
         }
      }
      #set catastar [lindex [buf$::audace(bufNo) getkwd CATASTAR] 1]
      return ""
   } else {
      error "Usage: simulimage Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type? ?newstar_type? ?newstar_ra? ?newstar_dec? ?newstar_mag? ?crota2? ?naxis1? ?naxis2? ?bufno?"
   }
}

#------------------------------------------------------
## @brief créé une séquence d'images à des intervalles prédéfinis
#  avec des valeurs numériques fournies ou extraites (*) de l'en-tête de l'image dans le buffer
#  et créé un graphique (CF @ref tuto_simulimage)
#  @code exemples :
#  - from an images ever loaded :
#  source "$::audace(rep_install)/gui/audace/surchaud.tcl"
#  simulimage2 test [mc_date2listdates 2011-11-11T00:00:00 0.021 100] {FOURIER 164.630566 67.529504 2011-11-08T00:00:00 0.28 12.5 -0.86 -0.53 -0.45 0.32 0.039 0.021} * * * * * * * USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
#  - from scratch
#  source "$::audace(rep_install)/gui/audace/surchaud.tcl"
#  simulimage2 test [mc_date2listdates 2011-11-11T00:00:00 0.021 100] {FOURIER 164.630566 67.529504 2011-11-08T00:00:00 0.28 12.5 -0.86 -0.53 -0.45 0.32 0.039 0.021} 200 200 164.589733 67.515479 13.5 13.5 0.84587 USNO c:/d/usno/ 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
#  photrel_wcs2cat test 100 new
#  photrel_cat2var test
#  photrel_cat2per test test 164.630637 67.529499 C 0
#  @endcode
#  @param args liste d'arguments :
#  - out racine du nom des images
#  - ListDates liste de dates
#  - variable_type { FOURRIER | SN )
#  - suivant identiques à ceux de simulimage
#
proc simulimage2 { args } {

   set pi [expr 4.*atan(1)]
   if {[llength $args] >= 5} {
      set arg0s [lrange $args 5 end]
      set naxis1 [lindex $args 3]
      set naxis2 [lindex $args 4]
      if {($naxis1!="*")&&($naxis2!="*")} {
         buf$::audace(bufNo) new CLASS_GRAY $naxis1 $naxis2 FORMAT_SHORT COMPRESS_NONE
         buf$::audace(bufNo) setkwd { NAXIS 2 int "" "" }
      }
      saveima tmp
      set out [lindex $args 0]
      set ListDates [lindex $args 1] ; # dates-obs UTC
      set variable_type [lindex $args 2]
      set exposure [lindex $arg0s 7]
      if {$exposure==""} {
         set exposure [lindex [buf$::audace(bufNo) getkwd EXPOSURE] 1]
      }
      if {$exposure==""} {
         set exposure [lindex [buf$::audace(bufNo) getkwd EXPTIME] 1]
      }
      if {$exposure==""} {
         set exposure 1
      }
      set filter [lindex $arg0s 10]
      if {$filter==""} {
         set filter [lindex [buf$::audace(bufNo) getkwd FILTER] 1]
      }
      if {$filter==""} {
         set filter R
      }
      set key [string toupper [lindex $variable_type 0]]
      set ra 0
      set dec 0
      if {$key=="FOURIER"} {
         # FOURIER ra dec jdphase c ?a1? ?b1? ?a2? ?b2? ?a3? ?b3? ?a4? ?b4? ?a5? ?b5?
         set ra [mc_angle2deg [lindex $variable_type 1]]
         set dec [mc_angle2deg [lindex $variable_type 2] 90]
         set jdphase [mc_date2jd [lindex $variable_type 3]] ; # HJD
         set period [lindex $variable_type 4] ; # day
         set four_c [lindex $variable_type 5] ; # mag
         set kk 1
         for {set k 6} {$k<[expr 6+5*2]} {incr k 2} {
            set four_a($kk) [lindex $variable_type [expr $k+0]] ; # mag
            set four_b($kk) [lindex $variable_type [expr $k+1]] ; # mag
            if {$four_a($kk)==""} { set four_a($kk) 0 }
            if {$four_b($kk)==""} { set four_b($kk) 0 }
            incr kk
         }
      }
      if {$key=="SN"} {
         # SN Ia ra dec jdmax magVmax
         set sntype [string toupper [lindex $variable_type 1]]
         set ra [mc_angle2deg [lindex $variable_type 2]]
         set dec [mc_angle2deg [lindex $variable_type 3] 90]
         set jdmax [mc_date2jd [lindex $variable_type 4]]
         set magmax [lindex $variable_type 5]
      }
      # --- Compute HJD
      set nd [llength $ListDates]
      set dates ""
      for {set k 0} {$k<$nd} {incr k} {
         set date [lindex $ListDates $k] ; # date-obs UTC
         set date [mc_datescomp $date + [expr $exposure/2./86400.]]
         lappend dates $date
      }
      # --- correction of time : JD UT-terrestrial -> barycentrical of the solar system
      set hjds [mc_dates_ut2bary $dates $ra $dec J2000.0]
      # --- Compute mags
      set mags ""
      if {$key=="FOURIER"} {
         for {set kk 1} {$kk<=5} {incr kk} {
            #::console::affiche_resultat "$kk => $four_a($kk) $four_b($kk)\n"
         }
         for {set k 0} {$k<$nd} {incr k} {
            set hjd [lindex $hjds $k]
            set phase [expr 1.*($hjd-$jdphase)/$period]
            set phase [expr $phase-floor($phase)]
            set mag $four_c
            for {set kk 1} {$kk<=5} {incr kk} {
               set mag [expr $mag + $four_a($kk)*cos(2*$pi*$kk*$phase) + $four_a($kk)*sin(2*$pi*$kk*$phase)]
            }
            lappend mags $mag
         }
      } elseif {$key=="SN"} {
         # From http://supernova.lbl.gov/~nugent/nugent_templates.html
         # template $::audace(rep_catalogues)/cataphotom/sn1a_lc.v1.2.dat
         set fic sn1a_lc.v1.2.dat ; set ffs [list U B V R I J H K]
         if {$sntype=="IA"} { set fic sn1a_lc.v1.2.dat ; set ffs [list U B V R I J H K] }
         if {$sntype=="IBC"} { set fic sn1bc_lc.v1.1.dat ; set ffs [list U B V R I] }
         if {$sntype=="IC"} { set fic hyper_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIP"} { set fic sn2p_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIL"} { set fic sn2l_lc.v1.2.dat  ; set ffs [list V]}
         if {$sntype=="IIN"} { set fic sn2n_lc.v2.1.dat  ; set ffs [list V]}
         if {$sntype=="91BG"} { set fic sn91bg_lc.v1.1.dat ; set ffs [list U B V R I] }
         if {$sntype=="91T"} { set fic sn91t_lc.v1.1.dat ; set ffs [list U B V R I] }
         set kf [lsearch -exact $ffs $filter]
         if {$kf==-1} { set kf 0 }
         incr kf
         set f [open $::audace(rep_catalogues)/cataphotom/$fic r]
         set lignes [split [read $f] \n]
         close $f
         set template_dts ""
         set template_mags ""
         set nt 0
         foreach ligne $lignes {
            if {[llength $ligne]<=1} { continue }
            lappend template_dts [lindex $ligne 0]
            lappend template_mags [lindex $ligne $kf]
            incr nt
         }
         set template_dt1 [lindex $template_dts 0]
         set template_dt2 [lindex $template_dts end]
         set template_dt20 [lindex $template_dts end-1]
         set template_mag2 [lindex $template_mags end]
         set template_mag20 [lindex $template_mags end-1]
         for {set k 0} {$k<$nd} {incr k} {
            set hjd [lindex $hjds $k]
            set dt [expr $hjd-$jdmax]
            if {$dt<=$template_dt1} {
               set mag [expr $magmax+[lindex $template_mags 0]]
            } elseif {$dt>=$template_dt20} {
               set frac [expr 1.*($dt-$template_dt20)/($template_dt2-$template_dt20)]
               set mag [expr $magmax+$template_mag20 + $frac * ($template_mag2-$template_mag20)]
            } else {
               for {set kt 0} {$kt<[expr $nt-1]} {incr kt} {
                  set template_dt0 [lindex $template_dts $kt]
                  set template_dt [lindex $template_dts [expr $kt+1]]
                  if {($dt>=$template_dt0)&&($dt<$template_dt)} {
                     set template_mag0 [lindex $template_mags $kt]
                     set template_mag [lindex $template_mags [expr $kt+1]]
                     set frac [expr 1.*($dt-$template_dt0)/($template_dt-$template_dt0)]
                     set mag [expr $magmax+$template_mag0 + $frac * ($template_mag-$template_mag0)]
                     break
                  }
               }
            }
            lappend mags $mag
         }
      } else {
         for {set k 0} {$k<$nd} {incr k} {
            lappend mags 12.5
         }
      }
      catch {::plotxy::clf}
      ::plotxy::plot $hjds $mags o
      ::plotxy::ydir reverse
      # --- Loop over images
      for {set k 0} {$k<$nd} {incr k} {
         set k1 [expr $k+1]
         buf$::audace(bufNo) load $::audace(rep_images)/tmp
         set mag [lindex $mags $k]
         set dateobs [mc_date2iso8601 [lindex $ListDates $k]]
         ::console::affiche_resultat "Build image ${out}$k1 : $dateobs $mag\n"
         buf$::audace(bufNo) setkwd [list DATE-OBS $dateobs string ISO8601 "Star of exposure"]
         buf$::audace(bufNo) setkwd [list EXPOSURE $exposure float s "Time of exposure"]
         set toeval "simulimage"
         foreach arg0 $arg0s {
            append toeval " \{$arg0\}"
         }
         append toeval " REPLACE $ra $dec $mag"
         #::console::affiche_resultat "$toeval\n"
         eval $toeval
         saveima ${out}$k1
         update
      }
   } else {
      error "Usage: simulimage2 out ListDatesObsUTC variable_type naxis1 naxis2 Angle_ra Angle_dec pixsize1_mu pixsize2_mu foclen_m USNO|MICROCAT cat_folder ?exposure_s? ?fwhm_pix? ?teldiam_m? ?colfilter? ?sky_brightness_mag/arcsec2? ?quantum_efficiency? ?gain_e/ADU? ?readout_noise_e? ?shutter_mode? ?bias_level_ADU? ?thermic_response_e/pix/sec? ?Tatm? ?Topt? ?EMCCD_mult? ?flat_type?"
   }
}

#------------------------------------------------------
## @brief determine gain, read_noise, thermic_signal of a given chip
#  @details permet d'obtenir certains paramètres électroniques de caméras (CF etc_tools.tcl)
#  @code
#  source "$::audace(rep_install)/gui/audace/surchaud.tcl"
#  electronic_chip $args
#  @endcode
#  @param args arguments = method {gainnoise|lintherm|shutter} + params
#  - method=gainoise params : filename_bias1 filename_bias2 filename_flat1 filename_flat2
#  - method=lintherm params : generic_filename_dark nb_files ?gain_e/ADU? ?readout_noise_e? ?saturation_ADU?
#  - method=shutter  params : generic_filename_flat nb_files
#  @return mean_gain mean_read_noise std_gain std_read_noise
#  @remark voir l'interface graphique "Paramètres électroniques" de \::echip avec l'option "lintherm"
#
proc electronic_chip { args } {

   set ext $::conf(extension,defaut)
   set path "$::audace(rep_images)"
   set argc [llength $args]
   if { $argc == 0} {
      error "Usage: electronic_chip gainnoise|lintherm|shutter ?params?"
      return $error;
   }
   set method [lindex $args 0]
   if { ($method == "gainnoise") } {
      if { ($argc < 5) } {
         error "Usage: electronic_chip $method filename_bias1 filename_bias2 filename_flat1 filename_flat2"
         return $error;
      }
      set bias1 [lindex $args 1]
      set bias2 [lindex $args 2]
      set flat1 [lindex $args 3]
      set flat2 [lindex $args 4]

      # --- define the five boxes where to measure
      buf$::audace(bufNo) load "${path}/${bias1}${ext}"
      set naxis1 [buf$::audace(bufNo) getpixelswidth]
      set naxis2 [buf$::audace(bufNo) getpixelsheight]
      set side1 [expr $naxis1/4]
      set side2 [expr $naxis2/4]
      # --- center box
      set x1 [expr int($naxis1*.5-$side1/2)]
      set y1 [expr int($naxis2*.5-$side2/2)]
      set x2 [expr int($naxis1*.5+$side1/2)]
      set y2 [expr int($naxis2*.5+$side2/2)]
      set box(1) [list $x1 $y1 $x2 $y2]
      # --- upper-left box
      set x1 [expr int($naxis1*.25-$side1/2)]
      set y1 [expr int($naxis2*.75-$side2/2)]
      set x2 [expr int($naxis1*.25+$side1/2)]
      set y2 [expr int($naxis2*.75+$side2/2)]
      set box(2) [list $x1 $y1 $x2 $y2]
      # --- lower-left box
      set x1 [expr int($naxis1*.25-$side1/2)]
      set y1 [expr int($naxis2*.25-$side2/2)]
      set x2 [expr int($naxis1*.25+$side1/2)]
      set y2 [expr int($naxis2*.25+$side2/2)]
      set box(3) [list $x1 $y1 $x2 $y2]
      # --- upper-right box
      set x1 [expr int($naxis1*.75-$side1/2)]
      set y1 [expr int($naxis2*.75-$side2/2)]
      set x2 [expr int($naxis1*.75+$side1/2)]
      set y2 [expr int($naxis2*.75+$side2/2)]
      set box(4) [list $x1 $y1 $x2 $y2]
      # --- lower-right box
      set x1 [expr int($naxis1*.75-$side1/2)]
      set y1 [expr int($naxis2*.25-$side2/2)]
      set x2 [expr int($naxis1*.75+$side1/2)]
      set y2 [expr int($naxis2*.25+$side2/2)]
      set box(5) [list $x1 $y1 $x2 $y2]

      set gains ""
      set read_noises ""
      for {set kbox 1} {$kbox<=5} {incr kbox} {
         # mesure des signaux (adu)
         buf$::audace(bufNo) load "${path}/${flat1}${ext}"
         buf$::audace(bufNo) window $box($kbox)
         set f1 [lindex [buf$::audace(bufNo) stat] 4]
         # mesure des signaux (adu)
         buf$::audace(bufNo) load "${path}/${flat2}${ext}"
         buf$::audace(bufNo) window $box($kbox)
         set f2 [lindex [buf$::audace(bufNo) stat] 4]
         # mesure des signaux (adu)
         buf$::audace(bufNo) load "${path}/${bias1}${ext}"
         buf$::audace(bufNo) window $box($kbox)
         set b1 [lindex [buf$::audace(bufNo) stat] 4]
         # mesure des signaux (adu)
         buf$::audace(bufNo) load "${path}/${bias2}${ext}"
         buf$::audace(bufNo) window $box($kbox)
         set b2 [lindex [buf$::audace(bufNo) stat] 4]
         # mesure des bruits (adu)
         buf$::audace(bufNo) load "${path}/${flat1}${ext}"
         buf$::audace(bufNo) sub "${path}/${flat2}${ext}" 0
         buf$::audace(bufNo) window $box($kbox)
         set sf [expr [lindex [buf$::audace(bufNo) stat] 5]/sqrt(2)]
         # mesure des bruits (adu)
         buf$::audace(bufNo) load "${path}/${bias1}${ext}"
         buf$::audace(bufNo) sub "${path}/${bias2}${ext}" 0
         buf$::audace(bufNo) window $box($kbox)
         set sb [expr [lindex [buf$::audace(bufNo) stat] 5]/sqrt(2)]
         # --- calcul du gain (e/adu)
         set gain [expr ($f1+$f2-$b1-$b2)/2./($sf*$sf-$sb*$sb)]
         # --- calcul du bruit (e)
         set read_noise [expr $gain*$sb]
         ::console::affiche_resultat "----- window $box($kbox)\n"
         ::console::affiche_resultat "gain = [format %.2f $gain] e/ADU  readout noise = [format %.2f $read_noise] e\n"
         ::console::affiche_resultat "flat variation = [format %.2f [expr 100.*2*($f1-$f2)/($f1+$f2)]] %\n"
         lappend gains $gain
         lappend read_noises $read_noise
      }
      package require math::statistics
      set mean_gain [::math::statistics::mean $gains]
      set std_gain [::math::statistics::stdev $gains]
      set mean_read_noise [::math::statistics::mean $read_noises]
      set std_read_noise [::math::statistics::stdev $read_noises]
      ::console::affiche_resultat "----- Final result\n"
      ::console::affiche_resultat "gain = [format %.2f $mean_gain] e/ADU (+/- [format %.2f $std_gain])\n"
      ::console::affiche_resultat "readout noise = [format %.2f $mean_read_noise] e (+/- [format %.2f $std_read_noise])\n"
      return [list $mean_gain $mean_read_noise $std_gain $std_read_noise]
   } elseif { ($method == "lintherm") } {
      if { ($argc < 3) } {
         error "Usage: electronic_chip $method generic_filename_dark nb_files ?gain_e/ADU? ?readout_noise_e? ?saturation_ADU?"
         return $error;
      }
      set darkname [lindex $args 1]
      set nbdark [lindex $args 2]
      set gain ""
      if {$argc>=4} {
         set gain [lindex $args 3]
      }
      set readout_noise_e ""
      if {$argc>=5} {
         set readout_noise_e [lindex $args 4]
      }
      set saturation_adu ""
      if {$argc>=6} {
         set saturation_adu [lindex $args 5]
      }
      # --- define the five boxes where to measure
      buf$::audace(bufNo) load "${path}/${darkname}1${ext}"
      set naxis1 [buf$::audace(bufNo) getpixelswidth]
      set naxis2 [buf$::audace(bufNo) getpixelsheight]
      set side1 [expr $naxis1/4]
      set side2 [expr $naxis2/4]
      # --- center box
      set x1 [expr int($naxis1*.5-$side1/2)]
      set y1 [expr int($naxis2*.5-$side2/2)]
      set x2 [expr int($naxis1*.5+$side1/2)]
      set y2 [expr int($naxis2*.5+$side2/2)]
      set box(1) [list $x1 $y1 $x2 $y2]
      # --- upper-left box
      set x1 [expr int($naxis1*.25-$side1/2)]
      set y1 [expr int($naxis2*.75-$side2/2)]
      set x2 [expr int($naxis1*.25+$side1/2)]
      set y2 [expr int($naxis2*.75+$side2/2)]
      set box(2) [list $x1 $y1 $x2 $y2]
      # --- lower-left box
      set x1 [expr int($naxis1*.25-$side1/2)]
      set y1 [expr int($naxis2*.25-$side2/2)]
      set x2 [expr int($naxis1*.25+$side1/2)]
      set y2 [expr int($naxis2*.25+$side2/2)]
      set box(3) [list $x1 $y1 $x2 $y2]
      # --- upper-right box
      set x1 [expr int($naxis1*.75-$side1/2)]
      set y1 [expr int($naxis2*.75-$side2/2)]
      set x2 [expr int($naxis1*.75+$side1/2)]
      set y2 [expr int($naxis2*.75+$side2/2)]
      set box(4) [list $x1 $y1 $x2 $y2]
      # --- lower-right box
      set x1 [expr int($naxis1*.75-$side1/2)]
      set y1 [expr int($naxis2*.25-$side2/2)]
      set x2 [expr int($naxis1*.75+$side1/2)]
      set y2 [expr int($naxis2*.25+$side2/2)]
      set box(5) [list $x1 $y1 $x2 $y2]

      set biass ""
      set therms ""
      for {set kbox 1} {$kbox<=5} {incr kbox} {
         set fs ""
         set exposures ""
         for {set kd 1} {$kd<=$nbdark} {incr kd} {
            # mesure des signaux (adu)
            buf$::audace(bufNo) load "${path}/${darkname}${kd}${ext}"
            buf$::audace(bufNo) window $box($kbox)
            set f [lindex [buf$::audace(bufNo) stat] 4]
            set exposure ""
            if {$exposure==""} {
               set exposure [string trim [lindex [buf$::audace(bufNo) getkwd EXPOSURE] 1] ]
            }
            if {$exposure==""} {
               set exposure [string trim [lindex [buf$::audace(bufNo) getkwd EXPTIME] 1] ]
            }
            if {$exposure==""} {
               set exposure 1
            }
            lappend exposures $exposure
            lappend fs $f
         }
         package require math::statistics
         if {[llength $exposures]==2} {
            set therm [expr ([lindex $fs 1]-[lindex $fs 0])/([lindex $exposures 1]-[lindex $exposures 0])] ; # ADU/sec
            set bias [expr [lindex $fs 0]+(0-[lindex $exposures 0])*$therm] ; # ADU
         } else {
            set res [::math::statistics::linear-model $exposures $fs]
            set bias [lindex $res 0] ; # ADU
            set therm [lindex $res 1] ; # ADU/sec
         }
         ::console::affiche_resultat "----- window $box($kbox)\n"
         ::console::affiche_resultat "bias = [format "%.2f" $bias] ADU  thermic = [format "%.2f" $therm] ADU/sec\n"
         lappend biass $bias
         lappend therms $therm
      }
      set mean_therm [::math::statistics::mean $therms]
      set std_therm [::math::statistics::stdev $therms]
      set mean_bias [::math::statistics::mean $biass]
      set std_bias [::math::statistics::stdev $biass]
      set exposure     ""
      set exposure_max ""
      ::console::affiche_resultat "----- Final result\n"
      ::console::affiche_resultat "thermic signal = [format "%.4f" $mean_therm] ADU/sec (+/- [format "%.4f" $std_therm])\n"
      if {$gain!=""} {
         ::console::affiche_resultat "thermic signal = [format "%.4f" [expr $gain*$mean_therm]] e/sec (+/- [format "%.4f" [expr $gain*$std_therm]])\n"
      }
      ::console::affiche_resultat "bias signal = [format "%.2f" $mean_bias] ADU (+/- [format "%.2f" $std_bias])\n"
      if {$readout_noise_e!=""} {
         set mean_therm_e_sec [expr $gain*$mean_therm]
         # signal_therm_e = mean_therm_e/sec * exposure
         # noise_therm_e = sqrt(signal_therm_e)
         # Compare readout_noise_e and noise_therm_e
         # --- We compute the exposure corresponding to readout_noise_e = noise_therm_e
         set noise_therm_e $readout_noise_e
         set signal_therm_e [expr $noise_therm_e*$noise_therm_e]
         set exposure [expr $signal_therm_e/$mean_therm_e_sec]
         ::console::affiche_resultat "exposures < [format %.1f $exposure] sec are dominated by readout noise (therm is negligeable against readout noise)\n"
         ::console::affiche_resultat "exposures > [format %.1f $exposure] sec are dominated by thermic noise (you must cool stronger the chip)\n"
      }
      if {$saturation_adu!=""} {
         set exposure_max [expr ($saturation_adu-$mean_bias)/$mean_therm]
         ::console::affiche_resultat "($saturation_adu-$mean_bias)/$mean_therm\n"
         ::console::affiche_resultat "exposure max = [format %.1f $exposure_max] seconds to saturate with dark\n"
      }
      return [list $mean_therm $mean_bias $std_therm $std_bias $exposure $exposure_max]
   } elseif { ($method == "shutter") } {
      if { ($argc < 3) } {
         error "Usage: electronic_chip $method generic_filename_flat nb_files ?zerocenter?"
         return $error;
      }
      set flatname [lindex $args 1]
      set nbflat [lindex $args 2]
      ttscript2 "IMA/STACK \"$path\" \"$flatname\" 1 $nbflat $ext \"$path\" shutter . $ext SHUTTER bitpix=-32"
      loadima shutter
      if { ($argc >= 4) } {
         set zerocenter [lindex $args 3]
         if {$zerocenter==1} {
            set naxis1 [buf1 getpixelswidth]
            set naxis2 [buf1 getpixelsheight]
            set xc [expr $naxis1/2]
            set yc [expr $naxis2/2]
            if {$naxis1<$naxis2} {
               set d [expr $naxis1/100]
            } else {
               set d [expr $naxis2/100]
            }
            if {$d<1} {
               set d 3
            }
            set x1 [expr $xc-$d]
            set y1 [expr $yc-$d]
            set x2 [expr $x1+2*$d]
            set y2 [expr $y1+2*$d]
            set box [list $x1 $y1 $x2 $y2]
            set res [buf1 stat $box]
            set mini [lindex $res 3]
            offset [expr -1*$mini]
         }
      }
      ::console::affiche_resultat "The displayed image gives directly the delays in seconds.\n"
   } else {
      error "$method found amongst: gainnoise, lintherm, shutter"
      return $error;
   }
}

#------------------------------------------------------
## @brief produit une seule image en sortie à partir d'une pile d'images par empilage les images. (CF @ref ttus1)
#  @warning les images doivent avoir été préalablement calibrées WCS
#  @details le paramètre [drop_size] (=0.5 par défaut) est la taille de la goutte exprimée en pixels
#  (à choisir entre 0.5 et 1).
#  Le paramètre [oversampling] (=2 par défaut) est un multiplicateur qui s'applique aux dimensions de l'image de sortie (à choisir entre 1 et 5).
#  @code
#  sdrizzlewcs in out number drop_sizepix oversampling ?first_index? ?tt_options?"
#  @endcode
#
proc sdrizzlewcs { args } {

   set n [llength $args]
   if {$n>=5} {
      set first 1
      if {$n==6} {
         set first "[lindex $args 5]"
      }
      set options ""
      if {$n>=7} {
         set first "[lindex $args 5]"
         set options "[lrange $args 6 end]"
      }
      set ni [expr [lindex $args 2]+$first-1]
      set ext $::conf(extension,defaut)
      ttscript2 "IMA/STACK \"$::audace(rep_images)\" \"[lindex $args 0]\" $first $ni \"$ext\" \"$::audace(rep_images)\" \"[lindex $args 1]\" . \"$ext\" DRIZZLEWCS drop_sizepix=[lindex $args 3] oversampling=[lindex $args 4] $options"
   } else {
      error "Usage: sdrizzlewcs in out number drop_sizepix oversampling ?first_index? ?tt_options?"
   }
}

#------------------------------------------------------
## @brief corrige les pixels chauds d'une image dans le buffer (CF @ref ttus1)
#  @code
#  loadima image_hotpixels
#  hotpixels "P 25 25 L 5 C 5"
#  @endcode
#  @param args code des pixels chauds
#
proc hotpixels {args} {

   if {[llength $args] == 1} {
      set ext $::conf(extension,defaut)
      set hot_pixel_list [lindex $args 0]
      buf$::audace(bufNo) imaseries "HOTPIXEL \"hot_pixel_list=${hot_pixel_list} \""
      ::audace::autovisu $::audace(visuNo)
   } else {
      error "Usage: hotpixels hot_pixel_list"
   }
}


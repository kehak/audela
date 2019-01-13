#
## @file photompsf.tcl
#  @brief Photométrie avec une PSF
#  @author Alain KLOTZ
#  $Id: photompsf.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#  @todo traiter pour Doxygen
#

# --- Haut niveaux
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_onebox ; # pour une seule etoile
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_addbox ; # pour ajouter d'autres etoiles
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_fitboxbypsf ; # mesure
# --- Bas niveaux
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_getboxes m67v2 a
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_synthepsf
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_save
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_save
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_calib
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_fitbypsf 0 ; loadima residu
# source $audace(rep_install)/gui/audace/photompsf.tcl ; photompsf_fitbypsf 08h32m58s57 +33d06m52s05 ; loadima residu
# photompsf(psffluxes)
# photompsf(inputstars)
# photompsf(multopt)

set photompsf(caption,warning_nowcs)       "L'image doit d'abord être calibrée WCS.\nUtiliser le menu Analyse, item Calibration astrométrique."
set photompsf(caption,warning_getbox)      "Entourer une étoile isolée à inclure dans la PSF,\npuis appuyer sur OK"
set photompsf(caption,question_acceptstar) "Accepter cette étoile pour la PSF ?"
set photompsf(caption,question_addstar)    "Ajouter une autre étoile pour la PSF ?"

proc photompsf_info { msg } {
   global audace photompsf
   if {$photompsf(verbose)==1} {
      ::console::affiche_resultat "$msg\n"
   }
}

proc photompsf_save { {fname photompsf.dat} } {
   global audace photompsf
   set anames [lsort [array names photompsf]]
   set texte ""
   foreach aname $anames {
      set k [string first , $aname]
      set key ""
      if {$k>0} {
         set key [string range $aname 0 [expr $k-1]]
      }
      if {$key!="caption"} {
         append texte "set photompsf($aname) \"$photompsf($aname)\"\n"
      }
   }
   set f [open $fname w]
   puts -nonewline $f $texte
   close $f
}

proc photompsf_load { {fname photompsf.dat} } {
   global audace photompsf
   source $fname
}

proc photompsf_calib { } {
   global audace photompsf
   set photompsf(verbose) 0
   if {[info exists photompsf(nstar)]==0} {
      error "Use photompsf_getboxes before"
   }
   if {$photompsf(nstar)==0} {
      error "Use photompsf_getboxes before"
   }
   set nstar [llength $photompsf(inputstars)]
   set xs ""
   set ys ""
   for {set k 0} {$k<$nstar} {incr k} {
      set flux [lindex $photompsf(psffluxes) $k]
      set magInstr [expr -2.5*log10($flux)]
      set catalog [lindex [lindex $photompsf(inputstars) $k] 4]
      set magB [lindex $catalog 3]
      set magV [lindex $catalog 4]
      set magR [lindex $catalog 5]
      set magJ [lindex $catalog 6]
      set magH [lindex $catalog 7]
      set magK [lindex $catalog 8]
      set x [expr $magV-$magR]
      set y [expr $magV-$magInstr]
      photompsf_info "k=$k magInstr=$magInstr magV=$magV magR=$magR x=$x y=$y"
      lappend xs $x
      lappend ys $y
   }
   catch {::plotxy::clf}
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::bgcolor #FFFFFF
   ::plotxy::plot $xs $ys "r."
   ::plotxy::ylabel R-r
   ::plotxy::xlabel V-R
   update
}

proc photompsf_fitboxbypsf { args } {
   global audace photompsf
   set photompsf(verbose) 0
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   set box [::confVisu::getBox $visuno]
   set res [buf$bufno fitgauss $box]
   set x [lindex $res 1]
   set y [lindex $res 5]
   set res [buf$bufno xy2radec [list $x $y]]
   set ra [lindex $res 0]
   set dec [lindex $res 1]
   set res [vo_neareststar $ra $dec]
   set res [lindex $res 0]
   set catalog $res
   set namecat [lindex $res 0]
   set racat [lindex $res 1]
   set deccat [lindex $res 2]
   set sepangle [mc_sepangle $ra $dec $racat $deccat]
   set sep [expr [lindex $sepangle 0]*3600.]
   set angle [lindex $sepangle 1]
   if {$sep>3} {
      set racat $ra
      set daccat $dec
   }
   photompsf_fitbypsf $racat $deccat
}

proc photompsf_fitbypsf { args } {
   global audace photompsf
   set photompsf(verbose) 0
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   if {[info exists photompsf(nstar)]==0} {
      error "Use photompsf_getboxes before"
   }
   if {$photompsf(nstar)==0} {
      error "Use photompsf_getboxes before"
   }
   set argc [llength $args]
   if {$argc==1} {
      set k [lindex $args 0]
      set res [lindex $photompsf(inputstars) $k]
      set ra [lindex $res 2]
      set dec [lindex $res 3]
   } elseif {$argc==2} {
      set ra [mc_angle2deg [lindex $args 0]]
      set dec [mc_angle2deg [lindex $args 1] 90]
   } else {
      error "Not enough arguments"
   }
   loadima $photompsf(img_filename)
   set res [buf$bufno radec2xy [list $ra $dec]]
   set x [lindex $res 0]
   set y [lindex $res 1]
   # --- on translate l'etoile sur la PSF
   set dx [expr $photompsf(x0)-$x]
   set dy [expr $photompsf(y0)-$y]
   set dxop [expr -$dx]
   set dyop [expr -$dy]
   photompsf_info "dx=$dx dy=$dy"
   buf$bufno imaseries "TRANS trans_x=$dx trans_y=$dy"
   buf$bufno window $photompsf(box)
   saveima star
   # --- estimation grossiere du rapport de flux
   set box $photompsf(box)
   loadima psf
   set res [buf$bufno fitgauss $box]
   set if0 [ expr 0.5*([ lindex $res 0 ]+[ lindex $res 4 ]) ]
   set if1 [ expr $if0*[ lindex $res 2 ]*[ lindex $res 6 ]*.601*.601*3.14159265 ]
   set fpsf $if0
   #
   loadima star
   set res [buf$bufno fitgauss $box]
   set if0 [ expr 0.5*([ lindex $res 0 ]+[ lindex $res 4 ]) ]
   set if1 [ expr $if0*[ lindex $res 2 ]*[ lindex $res 6 ]*.601*.601*3.14159265 ]
   set fstar $if0
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]
   set pixs ""
   for {set k 1} {$k<=$naxis1} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $k 1]] 1]
   }
   for {set k 1} {$k<=$naxis1} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $k $naxis2]] 1]
   }
   for {set k 1} {$k<=$naxis2} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list 1 $k]] 1]
   }
   for {set k 1} {$k<=$naxis2} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $naxis1 $k]] 1]
   }
   set np [llength $pixs]
   set pixs [lsort -real $pixs]
   set back [lindex $pixs [expr $np/2]]
   set k1 [expr int(floor(0.1*$np))]
   set k2 [expr int(floor(0.8*$np))]
   set pixs [lrange $pixs $k1 $k2]
   set np [llength $pixs]
   set total 0
   for {set k 0} {$k<$np} {incr k} {
      set total [expr $total+[lindex $pixs $k]]
   }
   set mean [expr 1.*$total/$np]
   set total 0
   for {set k 0} {$k<$np} {incr k} {
      set val [lindex $pixs $k]
      set total [expr $total+($val-$mean)*($val-$mean)]
   }
   set sigma [expr sqrt(1.*$total/($np-1))]
   set sn [expr $if0/$sigma]
   if {$sn<15} {
      set ifmini 0
      set ifmaxi [expr 15*$sigma]
   } else {
      set ifmini 0
      set ifmaxi [expr 2*$if0]
   }
   set multmini [expr $ifmini/$fpsf]
   set multmaxi [expr $ifmaxi/$fpsf]
   loadima star
   buf$bufno offset [expr -$back]
   buf$bufno bitpix -32
   saveima star0 ; # etoile centree sur la PSF et fond a zero
   # --- cree les buffers intermediaires
   set bufpsf [::buf::create]
   loadima psf
   buf$bufno copyto $bufpsf
   # --- boucle de dichotomie grossiere
   set dmult [expr $multmaxi-$multmini]
   set n 10
   set stdmini 1e23
   for {set kb 0} {$kb<20} {incr kb} {
      photompsf_info "==== iteration $kb"
      set moys ""
      set stds ""
      set mults ""
      for {set k 0} {$k<=$n} {incr k} {
         set mult [expr $multmini+1.*$dmult*$k/$n]
         buf$bufpsf copyto $bufno
         buf$bufno mult $mult
         sub star0 0
         buf$bufno mult -1
         set stat [buf$bufno stat]
         set moy [lindex $stat 4]
         set std [lindex $stat 5]
         lappend moys $moy
         lappend stds $std
         lappend mults $mult
         photompsf_info "k=$k mult=$mult moy=$moy std=$std"
         if {$std<=$stdmini} {
            set stdmini $std
            set multopt $mult
         }
      }
      set kmini $n
      set stdmini [lindex [lsort -real $stds] end]
      for {set k 0} {$k<=$n} {incr k} {
         set std [lindex $stds $k]
         if {$std<=$stdmini} {
            set kmini $k
            set stdmini $std
         }
      }
      set kmaxi [expr $kmini+1]
      set kmini [expr $kmini-1]
      photompsf_info "*** kmini=$kmini kmaxi=$kmaxi"
      set dk [expr $kmaxi-$kmini]
      if {$dk<=0} {
         set kmaxi [expr $kmini+1]
      }
      if {$kmini<0}  { set kmini 0 }
      if {$kmaxi>$n} { set kmaxi $n }
      set multmini2 [expr $multmini+1.*$dmult*$kmini/$n]
      set multmaxi2 [expr $multmini+1.*$dmult*$kmaxi/$n]
      set multmini $multmini2
      set multmaxi $multmaxi2
      photompsf_info "kmini=$kmini kmaxi=$kmaxi"
      photompsf_info "multmini=$multmini multmaxi=$multmaxi"
      # --- boucle de dichotomie fine
      set dmult [expr $multmaxi-$multmini]
      set df [expr $dmult*$fpsf]
      photompsf_info "df=$df"
      if {$df<[expr $n/2.]} {
         break
      }
      #set n [expr ceil($df)]
   }
   photompsf_info "multopt=$multopt"
   set mult $multopt
   buf$bufpsf copyto $bufno
   buf$bufno mult $mult
   sub star0 0
   buf$bufno mult -1
   saveima residu
   #::plotxy::plot $mults $stds
   #update
   # --- on enleve la PSF ajustee a l'image initiale
   loadima psf
   buf$bufno mult $mult
   buf$bufno copyto $bufpsf
   loadima $photompsf(img_filename)
   mult 0
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]
   set naxis11 [buf$bufpsf getpixelswidth]
   set naxis22 [buf$bufpsf getpixelsheight]
   for {set x 1} {$x<=$naxis11} {incr x} {
      for {set y 1} {$y<=$naxis22} {incr y} {
         set val [lindex [buf$bufpsf getpix [list $x $y]] 1]
         buf$bufno setpix [list $x $y] $val
      }
   }
   buf$bufno imaseries "TRANS trans_x=$dxop trans_y=$dyop"
   saveima psft
   loadima $photompsf(img_filename)
   sub psft 0
   ::buf::delete $bufpsf
   set photompsf(multopt) $multopt
   return $multopt
}

proc photompsf_synthepsf { {boxwidth ""} {boxheight ""} } {
   global audace photompsf
   set photompsf(verbose) 0
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   if {[info exists photompsf(nstar)]==0} {
      error "Use photompsf_getboxes before"
   }
   if {$photompsf(nstar)==0} {
      error "Use photompsf_getboxes before"
   }
   set n $photompsf(nstar)
   # --- saerch for the median value of the boxes
   if {($boxwidth=="")||($boxheight=="")} {
      set dxs ""
      set dys ""
      for {set k 0} {$k<$n} {incr k} {
         set res [lindex $photompsf(inputstars) $k]
         set box [lindex $res 0]
         set x1 [lindex $box 0]
         set y1 [lindex $box 1]
         set x2 [lindex $box 2]
         set y2 [lindex $box 3]
         set dx [expr abs($x1-$x2)]
         set dy [expr abs($y1-$y2)]
         lappend dxs $dx
         lappend dys $dy
      }
      set dxs [lsort -real $dxs]
      set dys [lsort -real $dys]
      set nn [expr $n/2]
      set width [lindex $dxs $nn]
      set height [lindex $dys $nn]
   } else {
      set width $boxwidth
      set height $boxheight
   }
   set width [expr $width/2*2+1] ; # the next odd integer
   set height [expr $height/2*2+1] ; # the next odd integer
   set x0 [expr $width/2]
   set y0 [expr $height/2]
   set box [list 1 1 $width $height]
   set photompsf(x0) $x0
   set photompsf(y0) $y0
   set photompsf(box) $box
   # --- mesure les flux dans les boites
   # TODO
   # --- translate
   for {set k 0} {$k<$n} {incr k} {
      set res [lindex $photompsf(inputstars) $k]
      set ra [lindex $res 2]
      set dec [lindex $res 3]
      loadima $photompsf(img_filename)
      set res [buf$bufno radec2xy [list $ra $dec]]
      set x [lindex $res 0]
      set y [lindex $res 1]
      photompsf_info "k=$k x=$x y=$y ra=$ra dec=$dec"
      set dx [expr $photompsf(x0)-$x]
      set dy [expr $photompsf(y0)-$y]
      photompsf_info "dx=$dx dy=$dy box=$photompsf(box)"
      buf$bufno imaseries "TRANS trans_x=$dx trans_y=$dy"
      buf$bufno window $photompsf(box)
      saveima psf$k
   }
   sadd psf psf $n 0 bitpix=-32
   # --- valeur des pixels des bords
   loadima psf
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]
   set pixs ""
   for {set k 1} {$k<=$naxis1} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $k 1]] 1]
   }
   for {set k 1} {$k<=$naxis1} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $k $naxis2]] 1]
   }
   for {set k 1} {$k<=$naxis2} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list 1 $k]] 1]
   }
   for {set k 1} {$k<=$naxis2} {incr k} {
      lappend pixs [lindex [buf$bufno getpix [list $naxis1 $k]] 1]
   }
   set np [llength $pixs]
   set pixs [lsort -real $pixs]
   set back [lindex $pixs [expr $np/2]]
   offset -$back
   saveima psf
   # --- calcul le flux relatif a la PSF pour chaque etoile qui constitue le PSF
   set photompsf(psffluxes) ""
   for {set k 0} {$k<$n} {incr k} {
      set ratio [photompsf_fitbypsf $k]
      lappend photompsf(psffluxes) $ratio
   }
}

proc photompsf_onebox { } {
   global audace photompsf
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]
   if {($naxis1==0)||($naxis2==0)} {
      return ""
   }
   set img_filename temppsf
   saveima $img_filename
   set mode w
   photompsf_getboxes $img_filename $mode 0
   if {$photompsf(nstar)==0} {
      return ""
   }
   photompsf_synthepsf
   photompsf_save
}

proc photompsf_addbox { } {
   global audace photompsf
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]
   if {($naxis1==0)||($naxis2==0)} {
      return ""
   }
   if {[info exists photompsf(nstar)]==0} {
      photompsf_onebox
      return ""
   }
   if {$photompsf(nstar)==0} {
      photompsf_onebox
      return ""
   }
   set img_filename temppsf
   saveima $img_filename
   set mode a
   photompsf_getboxes $img_filename $mode 0
   photompsf_synthepsf
   photompsf_save
}

proc photompsf_getboxes { img_filename {mode w} {interactive 1} } {
   global audace photompsf
   set photompsf(verbose) 1
   if {$mode=="w"} {
      set photompsf(nstar) 0
      set photompsf(img_filename) $img_filename
      set photompsf(inputstars) ""
   }
   set visuno $audace(visuNo)
   set bufno $audace(bufNo)
   if {($mode=="w")||($mode=="a")} {
      set sortie 0
      while {$sortie==0} {
         loadima $img_filename
         set err [catch {buf$bufno xy2radec {1 1}} msg]
         if {$err==1} {
            tk_messageBox -icon warning -message "$photompsf(caption,warning_nowcs)\n$msg"
            set photompsf(nstar) 0
            set photompsf(img_filename) ""
            return
         }
         incr photompsf(nstar)
         if {$interactive==0} {
            set box [::confVisu::getBox $visuno]
         } else {
            set box ""
         }
         while {$box==""} {
            tk_messageBox -icon warning -message "$photompsf(caption,warning_getbox)"
            set box [::confVisu::getBox $visuno]
         }
         photompsf_info "--------------------"
         set res [buf$bufno fitgauss $box]
         set x [lindex $res 1]
         set y [lindex $res 5]
         #set if0 [ expr 0.5*([ lindex $res 0 ]+[ lindex $res 4 ]) ]
         #set if1 [ expr $if0*[ lindex $res 2 ]*[ lindex $res 6 ]*.601*.601*3.14159265 ]
         set res [buf$bufno xy2radec [list $x $y]]
         set ra [lindex $res 0]
         set dec [lindex $res 1]
         set res [vo_neareststar $ra $dec]
         set res [lindex $res 0]
         set catalog $res
         photompsf_info "res=$res"
         set namecat [lindex $res 0]
         set racat [lindex $res 1]
         set deccat [lindex $res 2]
         # --- verifie que l'etoile n'a pas deja été sélectionnée
         set ns [llength $photompsf(inputstars)]
         set ret 0
         for {set ks 0} {$ks<$ns} {incr ks} {
            set inputstar [lindex $photompsf(inputstars) $ks]
            set rac [lindex $inputstar 2]
            set decc [lindex $inputstar 3]
            if {($racat==$rac)&&($deccat==$decc)} {
               incr photompsf(nstar) -1
               photompsf_info "This star is the same as n°[expr 1+$ks]"
               set ret 1
               break
            }
         }
         if {$ret==1} {
            if {$interactive==0} {
               return ""
            } else {
               continue
            }
         }
         # --- continue
         set magVcat [lindex $res 4]
         if {$magVcat==""} {
            set magVcat -99
         }
         set magRcat [lindex $res 5]
         if {$magRcat==""} {
            set magRcat -199
         }
         set sepangle [mc_sepangle $ra $dec $racat $deccat]
         set sep [expr [lindex $sepangle 0]*3600.]
         set angle [lindex $sepangle 1]
         photompsf_info "Star n°$photompsf(nstar):"
         photompsf_info "Box : $box"
         photompsf_info "Measured on this image : x=$x y=$y ra=$ra dec=$dec"
         photompsf_info "Nearest object : ra=$racat dec=$deccat magV=$magVcat magR=$magRcat"
         photompsf_info "Nearest object : $namecat"
         photompsf_info "Nearest object : separation=[format %.2f $sep] arcsec, PA=[format %.1f $angle] degrees"
         set vr [expr $magVcat-$magRcat]
         if {($vr>10)||($vr<-10)} {
            set vr " V-R=not defined"
         } else {
            set vr " V-R=$vr"
         }
         set res [tk_messageBox -type yesno -message "magV=${magVcat}${vr} separation=[format %.2f $sep] arcsec\n$photompsf(caption,question_acceptstar)" -icon question]
         if {$res=="yes"} {
            lappend photompsf(inputstars) [list $box $namecat $racat $deccat $catalog]
         } elseif {$res=="no"} {
            incr photompsf(nstar) -1
            photompsf_info "Star refused to be included in the PSF."
         }
         if {$interactive==1} {
            set res [tk_messageBox -type yesno -message "$photompsf(caption,question_addstar)" -icon question]
            if {$res=="no"} {
               set sortie 1
            }
         } else {
            set sortie 1
         }
      }
   } else {
      set ns [llength $photompsf(inputstars)]
      set ret 0
      for {set ks 0} {$ks<$ns} {incr ks} {
         set inputstar [lindex $photompsf(inputstars) $ks]
         set racat [lindex $inputstar 2]
         set deccat [lindex $inputstar 3]
         set res [lindex $inputstar 4]
         set namecat [lindex $res 0]
         set magVcat [lindex $res 4]
         set magRcat [lindex $res 5]
         photompsf_info "--------------------"
         photompsf_info "Star n°$photompsf(nstar):"
         photompsf_info "Box: $box"
         photompsf_info "Nearest object: ra=$racat dec=$deccat magV=$magVcat magR=$magRcat"
         photompsf_info "Nearest object: $namecat"
      }
   }
}


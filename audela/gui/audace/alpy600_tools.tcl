#
## @file alpy600_tools.tcl
#  @brief Procs pour traiter rapidement en aveugle les spectres Alpy600
#  @author Alain KLOTZ
#  $Id: alpy600_tools.tcl 14461 2018-08-20 14:05:12Z alainklotz $
#  @warning En cours de développement...
#  @todo traiter pour Doxygen
#

#  source $audace(rep_install)/gui/audace/alpy600_tools.tcl
#

proc alpy600_help { } {
   set texte "List of Alpy600 spectrograph commands to use both Atik caméras.\nNote that camera=spectro or camera=field in the following commands\n\n"
   set res [lsort [info commands alpy600_*]]
   foreach re $res {
      if {($re!="alpy600_help")&&($re!="alpy600_init")} {
         set err [catch {$re} msg]
         set k1 [string first \" $msg]
         set k2 [string last \" $msg]
         append texte "[string range $msg [expr $k1+1] [expr $k2-1]]\n"
      } else {
         append texte "$re\n"
      }
   }
   return $texte
}

# ###########################################################################
# ### Acquisition functions
# ###########################################################################
# alpy600_cam_create
# alpy600_acqdark
# alpy600_acq
# ###########################################################################

proc alpy600_cam_create { } {
   global audace
   set temp_spectro -10
   set temp_field -10
   # N.B. La ATIK 314L est toujours la premiere caméra.
   # --- Lance la Atik 314L
   ::confCam::run ; # ouvre le fenetre de choix des cameras
   ::confCam::selectNotebook A atik ; # selectionne l'onglet Atik
   after 100
   catch {::confCam::stopItem A} ; # deconnecte la caméra existante si necessaire
   set ::confCam::private(currentCamItem) A ; # on va choisir la camera A
   set conf(atik,A,device) 0 ; # device ATIK n° 0
   set ::atik::private(A,device) $conf(atik,A,device)
   set ::atik::private(A,cool) 1 ; # on demande de refroidir
   set ::atik::private(A,temp) $temp_field ; # on donne la consigne de temperature
   set ::atik::private(A,foncobtu) Synchro ; # obturateur en mode synchro
   set ::atik::private(A,mirh) 0 ; # miroir X
   set ::atik::private(A,mirv) 1 ; # miroir Y
   ::confCam::ok ; # on valide la configuration et on etablit la connexion
   ::confVisu::selectTool 1 ::acqfc ; # affiche l'outil d'acquisition
   ::console::affiche_resultat "Camera field (cam1) = [cam1 name] (cooler check at $temp_field °C)\n"
   # --- Lance la Atik 460ex
   after 1000
   ::confCam::run
   ::confCam::selectNotebook B atik
   after 100
   set ::confCam::private(currentCamItem) B
   catch {::confCam::stopItem B}
   set conf(atik,B,device) 1
   set ::atik::private(B,device) $conf(atik,B,device)
   set ::atik::private(B,cool) 1
   set ::atik::private(B,temp) $temp_spectro
   set ::atik::private(B,foncobtu) Synchro
   set ::atik::private(B,mirh) 0
   set ::atik::private(B,mirv) 0
   ::confCam::ok
   ::confVisu::selectTool 2 ::acqfc
   ::console::affiche_resultat "Camera spectro (cam2) = [cam2 name] (cooler check at $temp_spectro °C)\n"
}

# --- Effectue des darks et synthétize le kappa-sigma à la fin
proc alpy600_cam_acqdark { camera exp bin nbimages {generic_name ""} } {
   global audace
   if {$camera=="spectro"} {
      set bufNo 2
      set camNo 2
      set visuNo 2
   } elseif {$camera=="field"} {
      set bufNo 1
      set camNo 1
      set visuNo 1
   } else {
      error "camera must be spectro or field"
   }
   if {([catch {expr $exp}]==1)} {
      error "exp must been a real number"
   }
   if {([catch {expr $bin}]==1)} {
      error "bin must been an integer number >0"
   }
   if {$generic_name==""} {
      set generic_name dark_${camera}_${exp}s_${bin}x${bin}-
      set final_name   dark_${camera}_${exp}s_${bin}x${bin}
      set fichiers [glob -nocomplain $audace(rep_images)/${generic_name}*[buf$bufNo extension]]
      set nummax 0
      foreach fichier $fichiers {
         set fic [file tail $fichier]
         set k1 [string last - $fic]
         set k2 [string last . $fic]
         set num [string range $fic [expr $k1+1] [expr $k2-1]]
         if {$num>$nummax} {
            set nummax $num
         }
      }
      set numdeb [expr $nummax+1]
   } else {
      set numdeb 1
      set final_name $generic_name
   }
   ::acqfc::stopAcquisition $visuNo
   set sortie 0
   while {$sortie==0} {
      set camtimer [cam$camNo timer]
      if {$camtimer=="-1"} {
         set sortie 1
         break
      }
      after 500
   }
   for {set k 1} {$k<=$nbimages} {incr k} {
      ::console::affiche_resultat "A $camera dark image is started for $exp seconds and binning $bin\n"
      cam$camNo bin [list $bin $bin]
      cam$camNo exptime $exp
      cam$camNo shutter closed
      cam$camNo acq
      set sortie 0
      while {$sortie==0} {
         after 500
         set timer2 [cam$camNo timer]
         if {$timer2=="-1"} {
            set sortie 1
            break
         }
      }
      set ki [expr $numdeb+$k-1]
      set out_name ${generic_name}${ki}[buf$bufNo extension]
      ::console::affiche_resultat " $camera dark image is finished ($k/$nbimages) as file $out_name\n"
      confVisu::autovisu $visuNo -dovisu
      buf$bufNo save $audace(rep_images)/${out_name}
   }
   cam$camNo shutter synchro
   ::console::affiche_resultat "A kappa-sigma dark is synthetized as file ${final_name} \n"
   ssk ${generic_name} ${final_name} $nbimages 3 $numdeb
   confVisu::autovisu $visuNo -dovisu "$audace(rep_images)/${final_name}[buf$bufNo extension]"
}

# --- Lance une pose avec une ou deux caméras
proc alpy600_cam_acq { camera exp bin {exp_field 0} {bin_field 4} } {
   global audace
   if {$camera=="spectro"} {
      set camNo 2
      set visuNo 2
      set exp_spectro $exp
      set bin_spectro $bin
      set fbufNo 1
      set fcamNo 1
      set fvisuNo 1
   } elseif {$camera=="field"} {
      set camNo 1
      set visuNo 1
   } else {
      error "camera must be spectro or field"
   }
   if {([catch {expr $exp}]==1)} {
      error "exp must been a real number"
   }
   if {([catch {expr $bin}]==1)} {
      error "bin must been an integer number >0"
   }
   if {$camera=="spectro"} {
      if {([catch {expr $exp_field}]==1)} {
         error "exp_field must been a real number (=0 if no field acquisition)"
      }
      if {([catch {expr $bin_field}]==1)} {
         error "bin_field must been an integer number >0"
      }
   }
   ::acqfc::stopAcquisition $visuNo
   set sortie 0
   while {$sortie==0} {
      set camtimer [cam$camNo timer]
      if {$camtimer=="-1"} {
         set sortie 1
         break
      }
      after 500
   }
   if {($camera=="spectro")&&($exp_field>0)} {
      ::acqfc::stopAcquisition 1
      set sortie 0
      while {$sortie==0} {
         set camtimer [cam1 timer]
         if {$camtimer=="-1"} {
            set sortie 1
            break
         }
         after 500
      }
   }
   cam$camNo shutter synchro
   cam$camNo bin [list $bin $bin]
   cam$camNo exptime $exp
   cam$camNo acq
   ::console::affiche_resultat "A $camera image is started for $exp seconds and binning $bin\n"
   set sortie 0
   while {$sortie==0} {
      after 500
      set camtimer [cam$camNo timer]
      if {$camtimer=="-1"} {
         set sortie 1
         break
      }
      ::console::affiche_resultat " $camera image timer = $camtimer\n"
      if {($camera=="spectro")&&($exp_field>0)} {
         ::console::affiche_resultat " A field image is started for $exp_field seconds and binning $bin_field\n"
         cam$fcamNo shutter synchro
         cam$fcamNo bin [list $bin_field $bin_field]
         cam$fcamNo exptime $exp_field
         cam$fcamNo acq
         set fsortie 0
         while {$fsortie==0} {
            set fcamtimer [cam$fcamNo timer]
            if {$fcamtimer=="-1"} {
               set fsortie 1
               break
            }
            after 500
         }
         cam$fcamNo shutter synchro
         ::console::affiche_resultat " Field image is finished\n"
         # --- on soustrait le dark de l'image de champ si le fichier existe
         set dark_name   dark_field_${exp_field}s_${bin_field}x${bin_field}
         set dark_fullname $audace(rep_images)/${dark_name}[buf$fbufNo extension]
         if {[file exists $dark_fullname ]==1} {
            buf$fbufNo sub $dark_fullname 0
            ::console::affiche_resultat " Substract $dark_name to the field image\n"
         }
         confVisu::autovisu $fvisuNo -dovisu
         # --- ajouter ici le controle du telescope
      }
   }
   ::console::affiche_resultat " $camera image is finished\n"
   confVisu::autovisu $visuNo -dovisu
}

# ###########################################################################
# ### Image->Spectrum functions
# ###########################################################################
# alpy600_spec_calib1
# ###########################################################################


# ###########################################################################
# ### Spectrum functions
# ###########################################################################
# alpy600_spec_create
# alpy600_spec_delete
# alpy600_spec_list
# alpy600_spec_buf2spec
# alpy600_spec_info
# alpy600_spec_plot
# alpy600_spec_save
# alpy600_spec_save_ascii { specNo filename }
# alpy600_spec_load
# alpy600_spec_sub
# alpy600_spec_add
# alpy600_spec_prod
# alpy600_spec_div
#
# alpy600_spec_flux2lines
# alpy600_spec_atmosphere_trans
# ###########################################################################

proc alpy600_spec_create { specNo } {
   global spec
   #set res [array names spec]
   set spec($specNo) ""
}

proc alpy600_spec_delete { specNo } {
   global spec
   set res [lsort [array names spec]]
   foreach re $res {
      set reb [split $re ,]
      if {[lindex $reb 0]==$specNo} {
         unset spec($re)
      }
   }
}

proc alpy600_spec_list { } {
   global spec
   set res [lsort [array names spec]]
   set specNos ""
   foreach re $res {
      set reb [split $re ,]
      set specNo [lindex $reb 0]
      if {[lsearch -integer $specNos $specNo]==-1} {
         lappend specNos $specNo
      }
   }
   return $specNos
}

proc alpy600_buf_extract_fringes { bufNo } {
   set res [alpy600_buf_where_is_yspec $bufNo 1000]
   lassign $res ymax y1 y2
   saveima tmp
   convgauss 10
   saveima tmp0
   loadima tmp
   div tmp0 1
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   set d 40
   set yy1 [expr $y1-$d]
   set yy2 [expr $y1+$d]
   for {set y $yy1} {$y<=$yy2} {incr y} {
      for {set x 1} {$x<=$naxis1} {incr x} {
         buf$bufNo setpix [list $x $y] 1.0
      }
   }
   set yy1 [expr $y2-$d]
   set yy2 [expr $y2+$d]
   for {set y $yy1} {$y<=$yy2} {incr y} {
      for {set x 1} {$x<=$naxis1} {incr x} {
         buf$bufNo setpix [list $x $y] 1.0
      }
   }
   return $res
}

proc alpy600_buf_where_is_yspec { bufNo {dylim 60} } {
   global spec
   global audace
   buf$bufNo save $audace(rep_images)/tmp0
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   buf$bufNo imaseries "BINX x1=1 x2=$naxis1 height=20"
   buf$bufNo bitpix -32
   set ymax -1
   set valtmax 0
   set ys ""
   set vs ""
   for {set y 1} {$y<=$naxis2} {incr y} {
      lappend ys $y
      set valt 0.
      set x 1
      set val [lindex [buf$bufNo getpix [list $x $y]] 1]
      set valt [expr $valt+$val]
      if {$valt>$valtmax} {
         set ymax $y
         set valtmax $valt
      }
      lappend vs $val
   }
   # --- met le fond à zero
   set f1 [::math::statistics::median [lrange $vs 0 20]]
   set f2 [::math::statistics::median [lrange $vs end-20 end]]
   set f [expr ($f1+$f2)/2.]
   set std1 [::math::statistics::stdev [lrange $vs 0 20]]
   set std2 [::math::statistics::stdev [lrange $vs end-20 end]]
   set std [expr ($std1+$std2)/2.]
   set vss ""
   for {set ky 0} {$ky<$naxis2} {incr ky} {
      set val [expr [lindex $vs $ky]-$f]
      lappend vss $val
   }
   set valtmax [expr $valtmax-$f]
   set vs $vss
   if {1==0} {
      ::plotxy::hold off
      ::plotxy::plot $ys $vs r.-
   }
   # ---
   #set snr [expr 1.*$valtmax/$std]
   #console::affiche_resultat "snr = $snr\n"
   #console::affiche_resultat "valtmax=$valtmax f=$f\n"
   # --- recherche le fond
   set val0 [expr $valtmax/2.]
   for {set y $ymax} {$y<$naxis2} {incr y} {
      set val1 [lindex $vs $y]
      set val2 [lindex $vs [expr $y+1]]
      set dval [expr $val1-$val2]
      #console::affiche_resultat "y=$y val1=$val1 val2=$val2 dval=$dval\n"
      #if {($dval<0)&&($val2<$val0)} {}
      if {([expr abs($dval)]<$std)&&($val2<$val0)} {
         set y2 $y
         break
      }
   }
   for {set y $ymax} {$y>1} {incr y -1} {
      set val1 [lindex $vs $y]
      set val2 [lindex $vs [expr $y-1]]
      set dval [expr $val1-$val2]
      #if {($dval<0)&&($val2<$val0)} {}
      if {([expr abs($dval)]<$std)&&($val2<$val0)} {
         set y1 $y
         break
      }
   }
   buf$bufNo load $audace(rep_images)/tmp0
   set dy [expr $y2-$y1]
   if {$dy>$dylim} {
      set ymax [expr int(($y1+$y2)/2)]
      set y1 [expr int($ymax-$dylim/2)]
      set y2 [expr int($ymax+$dylim/2)]
   }
   return [list $ymax $y1 $y2]
}

proc alpy600_spec_buf2spec { bufNo specNo y1 y2} {
   global spec
   global audace
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   alpy600_spec_delete $specNo
   alpy600_spec_create $specNo
   set spec($specNo,bin,UID) {bin topo air bin}
   set spec($specNo,flu,UID) {flu app  iat adub}
   for {set x 1} {$x<=$naxis1} {incr x} {
      set valt 0.
      for {set y $y1} {$y<=$y2} {incr y} {
         set val [lindex [buf$bufNo getpix [list $x $y]] 1]
         set valt [expr $valt+$val]
      }
      lappend spec($specNo,bin) $x
      lappend spec($specNo,flu) $valt
   }
   set spec($specNo,header,date_obs) [buf$bufNo getkwd DATE-OBS]
   set spec($specNo,header,exposure) [buf$bufNo getkwd EXPOSURE]
}

proc alpy600_spec_info { {specNo ""} } {
   global spec
   set res [lsort [array names spec]]
   set symb ""
   set re2s ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$specNo!=""} {
         if {$no!=$specNo} {
            continue
         }
      }
      lappend re2s $re
   }
   if {$re2s==""} {
      return ""
   }
   set re2s [lsort $re2s]
   set texte "Informations about spec($specNo):\n"
   foreach re $re2s {
      append texte "spec($re) {[llength $spec($re)] elements} [lrange $spec($re) 0 6]\n"
   }
   console::affiche_resultat "$texte"
   return ""
}

proc alpy600_spec_plot { specNo {symbol bo-} {grandeurx ""} {grandeury ""} } {
   global spec
   if {$grandeurx==""} {
      set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo x] 0]
   }
   if {$grandeury==""} {
      set grandeury [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo y] 0]
   }
   set res [alpy600_spec_tools_spec2symbolxy $specNo $grandeurx $grandeury]
   lassign $res symbx symby
   # console::affiche_resultat "res=$res\n"
   set xs $spec($specNo,$symbx)
   set ys $spec($specNo,$symby)
   lassign $spec($specNo,$symbx,UID) grandeur site medium unite
   set res [lsort -real $xs]
   set xmin [lindex $res 0]
   set xmax [lindex $res end]
   if {$unite=="ang"} {
      set xmin 3800
      set xmax 8250
   }
   set xxs ""
   set yys ""
   set nx [llength $xs]
   for {set kx 0} {$kx<$nx} {incr kx} {
      set x [lindex $xs $kx]
      set y [lindex $ys $kx]
      if {$x<$xmin} {
         continue
      }
      if {$x>$xmax} {
         break
      }
      lappend xxs $x
      lappend yys $y
   }
   set xs $xxs
   set ys $yys
   set xlabel [alpy600_spec_tools_getlabel $spec($specNo,$symbx,UID)]
   set ylabel [alpy600_spec_tools_getlabel $spec($specNo,$symby,UID)]
   set maxixy [wm maxsize .]
   set maxix [expr [lindex $maxixy 0]-20]
   ::plotxy::plotbackground #FFFFFF
   set h [::plotxy::plot $xs $ys $symbol 1]
   #console::affiche_resultat "h=$h\n"
   ::plotxy::xlabel $xlabel
   ::plotxy::ylabel $ylabel
   ::plotxy::title " "
   ::plotxy::position [list 10 10 $maxix 400]
   ::plotxy::bgcolor #FFFFFF
   update
}

proc alpy600_spec_save { specNo filename } {
   global spec
   global audace
   set res [lsort [array names spec]]
   set symb ""
   set textes ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no==$specNo} {
         set k1 [expr 1+[string first , $re]]
         if {$k1==0} {
            continue
         }
         set ree [string range $re $k1 end]
         set n [llength $spec($re)]
         if {$n==1} {
            append textes "$ree $spec($re)\n"
         } else {
            append textes "$ree \{ $spec($re) \}\n"
         }
      }
   }
   set fic "$audace(rep_images)/${filename}.spec"
   set f [open $fic w]
   puts -nonewline $f $textes
   close $f
}

proc alpy600_spec_save_ascii { specNo filename {list_kwd_val_com_uni ""} } {
   global spec
   global audace
   set res [lsort [array names spec]]
   set symb ""
   set textes ""
   set names ""
   set headers ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no==$specNo} {
         set k1 [expr 1+[string first , $re]]
         if {$k1==0} {
            continue
         }
         set ree [string range $re $k1 end]
         set rees [split $ree ,]
         if {[llength $rees]==1} {
            set reuid "${re},UID"
            set err [catch {info exists spec($reuid)} msg]
            if {$err==0} {
               set n [llength $spec($re)]
               lappend names [list $rees $n $re]
            }
         } else {
            set key [lindex $rees 0]
            if {$key=="header"} {
               lappend headers $re
            }
         }
      }
   }
   set lignes ""
   set colno 1
   foreach name $names {
      lassign $name rees n re
      append re ",UID"
      set UID [string trim $spec($re)]
      set label [alpy600_spec_tools_getlabel $UID]
      append lignes "# COL$colno : $label \{${UID}\} \n"
      incr colno
   }
   foreach header $headers {
      lassign $spec($header) key val typ com uni
      append lignes "# $key = $val / $com ($uni) \n"
   }
   if {$list_kwd_val_com_uni!=""} {
      foreach l $list_kwd_val_com_uni {
         lassign $l key val com uni
         append lignes "# $key = $val / $com ($uni)\n"
      }
   }
   append lignes "# END\n"
   for { set k 0 } {$k<$n} {incr k} {
      foreach name $names {
         lassign $name rees n re
         set val [lindex $spec($re) $k]
         append lignes "$val "
      }
      append lignes "\n"
   }
   set fic "$audace(rep_images)/${filename}.txt"
   set f [open $fic w]
   puts -nonewline $f $lignes
   close $f
   #return $names
}

proc alpy600_spec_load { specNo filename } {
   global spec
   global audace
   alpy600_spec_delete $specNo
   alpy600_spec_create $specNo
   set fic "$audace(rep_images)/${filename}.spec"
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   foreach ligne $lignes {
      set key [lindex $ligne 0]
      if {$key==""} {
         continue
      }
      set name ${specNo},${key}
      set spec($name) [lindex $ligne 1]
   }
}

proc alpy600_spec_calib_info { startype } {
   global audace
   set fichier $audace(rep_install)/gui/audace/catalogues/cataspectro/calspec/calspec.lst
   set f [open $fichier r]
   set lignes [split [read $f] \n]
   close $f
   set startype [string tolower $startype]
   set nl [llength $lignes]
   set tls ""
   set types ""
   for {set kl 0} {$kl<$nl} {incr kl} {
      set ligne [lindex $lignes $kl]
      if {[string range $ligne 0 4]=="====="} {
         incr kl
         set ligne [lindex $lignes $kl]
         set type [string tolower [lindex $ligne 0]]
         lappend types $type
         incr kl 2
         for {set kkl $kl} {$kkl<$nl} {incr kkl} {
            set ligne [lindex $lignes $kkl]
            if {[lindex $ligne 0]==""} {
               break
            }
         }
         lappend tls [list $type $kl [expr $kkl-1]]
      }
   }
   set kt [lsearch -exact -index 0 $tls $startype]
   if {$kt<0} {
      error "List of allowed startype is $types"
   }
   set res [lindex $tls $kt]
   lassign $res t k1 k2
   set textes ""
   for {set kkl $k1} {$kkl<=$k2} {incr kkl} {
      set ligne [lindex $lignes $kkl]
      append textes "$ligne\n"
   }
   return $textes
}

proc alpy600_spec_find_calib_wavelengths { filename {couples ""} {slit single_slit} } {
   global spec
   global audace
   set catatype "alpy600 $slit"
   set star0s [focas_image2stars $filename $catatype]
   set f [open $audace(rep_images)/profile.txt r]
   set lignes [split [read $f] \n]
   close $f
   set coefs ""
   if {$couples!=""} {
      set xs ""
      set ys ""
      foreach couple $couples {
         lappend xs [lindex $couple 0]
         lappend ys [lindex $couple 1]
      }
      set degree 3
      set coefs [alpy600_spec_tools_polyfit $xs $ys $degree]
   }
   set pixpics ""
   set ypics ""
   foreach ligne $lignes {
      if {[string length $ligne]<5} {
         continue
      }
      set pix [lindex $ligne 0]
      lappend pixpics $pix
      lappend ypics [lindex $ligne 1]
      if {$coefs==""} {
         lappend lambdapics $pix
      } else {
         lappend lambdapics [alpy600_spec_tools_polyval $coefs $pix]
      }
   }
   if {$coefs==""} {
      catch {plotxy::clf}
      plotxy::plot $lambdapics $ypics -ob 0
      plotxy::xlabel "Bin (pixels)"
      plotxy::ylabel "Intensity (ADU)"
   } else {
   }
}

proc alpy600_spec_bin2ang_for_neon { specNo {delta 4} {polydeg 4} {kappa 2} {display 0} } {
   global spec
   global audace
   if {[info exists spec($specNo)]==0} {
      error "Use alpy600_spec_create $specNo before"
   }
   set star0s [alpy600_spec_flux2lines $specNo]
   set ns [llength $star0s]
   if {$ns<2} {
      error "Only $ns line found. Not enough for wavelength calibration."
   }
   set catatype "alpy600 single_slit"
   set cata0s [focas_db2catas $catatype ""]
   set nc [llength $cata0s]
   if {$nc<2} {
      error "Only $nc line in the catalog. Not enough for wavelength calibration."
   }
   set couples [focas_catastars2pairs $star0s $cata0s $catatype $delta 20]
   lassign $couples couplefull_header couplefulls best_transform
   set np [llength $couplefulls]
   if {$np<2} {
      error "$ns lines in the spectrum. $nc lines in the catalog. Only $np couple found. Not enough for wavelength calibration."
   }
   if {$display==1} {
      ::console::affiche_resultat "== $couplefull_header\n"
      foreach couplefull $couplefulls {
         ::console::affiche_resultat " $couplefull\n"
      }
   }
   set couplefulls [lsort -index 0 -real $couplefulls]
   set couples [list $couplefull_header $couplefulls $best_transform]
   set polys [focas_pairs2poly $couples $polydeg]
   lassign $polys polydeg polycoefs sigma ominuscs
   set ominusc_lim [expr $kappa*$sigma]
   set couplefullnews ""
   set ko 0
   set ke 0
   foreach ominusc $ominuscs {
      set couplefull [lindex $couplefulls $ko]
      set y [lindex $couplefull 2]
      if {$display==1} {
         ::console::affiche_resultat " ominusc = $ominusc ($ominusc_lim) y=$y\n"
      }
      if {[expr abs($ominusc)]<$ominusc_lim} {
         lappend couplefullnews $couplefull
      } else {
         incr ke
      }
      incr ko
   }
   set couplefulls $couplefullnews
   set couples [list $couplefull_header $couplefulls $best_transform]
   set polys [focas_pairs2poly $couples $polydeg]
   lassign $polys polydeg polycoefs sigma ominuscs
   if {$display==1} {
      ::console::affiche_resultat " polys = $polys\n"
      ::console::affiche_resultat " ($ke lines deletes)\n"
      set xs ""
      set ys ""
      set yts ""
      set kt 0
      foreach couplefull $couplefulls {
         set x [lindex $couplefull 0]
         set y [lindex $couplefull 2]
         set yt [expr $y+[lindex $ominuscs $kt]]
         lappend xs $x
         lappend ys $y
         lappend yts $yt
      }
      ::plotxy::hold off
      ::plotxy::plot $xs $ys ro.
      ::plotxy::hold on
      ::plotxy::plot $xs $yts bo-
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo wvl]
   # verifier res ...
   # lassign $res symbx
   # set bufNo 1
   # set naxis1 [buf$bufNo getpixelswidth]
   # set naxis2 [buf$bufNo getpixelsheight]
   set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo x] 0]
   set grandeurx bin
   set res [alpy600_spec_tools_spec2symbolx $specNo $grandeurx]
   lassign $res symbx
   set xs $spec($specNo,$symbx)
   set nbin [llength $xs]
   # if {$nwvl!=$naxis1} {
      # error "Spectrum $specNo has $nwvl pixels and image has $naxis1 pixels"
   # }
   set spec($specNo,wv1,UID) {wv1 topo air ang}
   set spec($specNo,wv1) ""
   set spec($specNo,wvl,UID) {wvl topo air ang}
   set spec($specNo,wvl) ""
   set spec($specNo,wv2,UID) {wv2 topo air ang}
   set spec($specNo,wv2) ""
   for {set x 1} {$x<=$nbin} {incr x} {
      set wv1 [focas_tools_polyval $polycoefs [expr $x-0.5]]
      lappend spec($specNo,wv1) $wv1
      set wvl [focas_tools_polyval $polycoefs $x]
      lappend spec($specNo,wvl) $wvl
      set wv2 [focas_tools_polyval $polycoefs [expr $x+0.5]]
      lappend spec($specNo,wv2) $wv2
   }
   return [list $ns $nc $np $sigma]
}

proc alpy600_spec_bin2ang_from_neon { specNo specNeon } {
   global spec
   global audace
   if {[info exists spec($specNo)]==0} {
      error "Use alpy600_spec_create $specNo before"
   }
   if {[info exists spec($specNeon)]==0} {
      error "Use alpy600_spec_create $specNeon before"
   }
   set grandeurx bin
   set res [alpy600_spec_tools_spec2symbolx $specNo $grandeurx]
   lassign $res symbx
   set xs $spec($specNo,$symbx)
   set nbin [llength $xs]
   #
   set grandeurx wvl
   set res [alpy600_spec_tools_spec2symbolx $specNeon $grandeurx]
   lassign $res symbx
   set wvls $spec($specNeon,$symbx)
   set nwvl [llength $wvls]
   #
   set grandeurx wv1
   set res [alpy600_spec_tools_spec2symbolx $specNeon $grandeurx]
   lassign $res symbx
   set wv1s $spec($specNeon,$symbx)
   set nwv1 [llength $wv1s]
   #
   set grandeurx wv2
   set res [alpy600_spec_tools_spec2symbolx $specNeon $grandeurx]
   lassign $res symbx
   set wv2s $spec($specNeon,$symbx)
   set nwv2 [llength $wv2s]
   if {$nwvl!=$nbin} {
      error "Spectrum $specNo has $nbin bins and spectrum $specNeon has $nwvl wavelengths"
   }
   set spec($specNo,wv1,UID) {wv1 topo air ang}
   set spec($specNo,wv1) ""
   set spec($specNo,wvl,UID) {wvl topo air ang}
   set spec($specNo,wvl) ""
   set spec($specNo,wv2,UID) {wv2 topo air ang}
   set spec($specNo,wv2) ""
   for {set x 0} {$x<$nbin} {incr x} {
      set wv1 [lindex $spec($specNeon,wv1) $x]
      lappend spec($specNo,wv1) $wv1
      set wvl [lindex $spec($specNeon,wvl) $x]
      lappend spec($specNo,wvl) $wvl
      set wv2 [lindex $spec($specNeon,wv2) $x]
      lappend spec($specNo,wv2) $wv2
   }
}

proc alpy600_spec_bin2ang1 { specNo filename {polydeg 6} {bintrans 0} {slit single_slit} {kappa 2} } {
   global spec
   global audace
   set catatype "alpy600 $slit"
   if {$filename==""} {
      set star0s [alpy600_spec_flux2lines $specNo]
   } else {
      set star0s [focas_image2stars $filename $catatype]
   }
   set cata0s [focas_db2catas $catatype ""]
   set couples [focas_catastars2pairs $star0s $cata0s $catatype 4 20]
   lassign $couples couplefull_header couplefulls best_transform
   ::console::affiche_resultat "== $couplefull_header\n"
   set couplefulls [lsort -index 0 -real $couplefulls]
   foreach couplefull $couplefulls {
      ::console::affiche_resultat " $couplefull\n"
   }
   set res ""
   foreach couplefull $couplefulls {
      set x [lindex $couplefull 0]
      set x [expr $x+$bintrans]
      set couplefull [lreplace $couplefull 0 0 $x]
      lappend res $couplefull
   }
   if {$res==""} {
      ::console::affiche_resultat " ===== Observed lines\n"
      set star0s [lrange $star0s 0 4]
      foreach star0 $star0s {
         set a [lindex $star0 0]
         set a [expr ($a-1278.972085)*4.23+8115.311]
         set i [lindex $star0 2]
         set i [expr int($i/2.596)]
         set x [lindex $star0 0]
         set x [format %.3f [expr ($x+36)*2]]
         ::console::affiche_resultat "$x [lrange $star0 1 end] --> $a  ($i)\n"
      }
      ::console::affiche_resultat " ===== Catalog lines\n"
      set cata0s [lrange $cata0s 0 4]
      foreach cata0 $cata0s {
         set x [lindex $cata0 0]
         set x [expr $x/2-36]
         #::console::affiche_resultat " $x [lrange $cata0 1 end]\n"
         ::console::affiche_resultat "$cata0\n"
      }
      error "No line matched"
   }
   set couplefulls $res
   set couples [list $couplefull_header $couplefulls $best_transform]
   set polys [focas_pairs2poly $couples $polydeg]
   lassign $polys polydeg polycoefs sigma ominuscs
   set ominusc_lim [expr $kappa*$sigma]
   set couplefullnews ""
   set ko 0
   set ke 0
   foreach ominusc $ominuscs {
      set couplefull [lindex $couplefulls $ko]
      set y [lindex $couplefull 2]
      #::console::affiche_resultat " ominusc = $ominusc ($ominusc_lim) y=$y\n"
      if {[expr abs($ominusc)]<$ominusc_lim} {
         lappend couplefullnews $couplefull
      } else {
         incr ke
      }
      incr ko
   }
   set couplefulls $couplefullnews
   set couples [list $couplefull_header $couplefulls $best_transform]
   set polys [focas_pairs2poly $couples $polydeg]
   lassign $polys polydeg polycoefs sigma ominuscs
   ::console::affiche_resultat " polys = $polys\n"
   ::console::affiche_resultat " ($ke lines deletes)\n"
   if {1==1} {
      set xs ""
      set ys ""
      set yts ""
      set kt 0
      foreach couplefull $couplefulls {
         set x [lindex $couplefull 0]
         set y [lindex $couplefull 2]
         set yt [expr $y+[lindex $ominuscs $kt]]
         lappend xs $x
         lappend ys $y
         lappend yts $yt
      }
      ::plotxy::hold off
      ::plotxy::plot $xs $ys ro.
      ::plotxy::hold on
      ::plotxy::plot $xs $yts bo-
      #tk_messageBox
   }


   if {[info exists spec($specNo)]==0} {
      error "Use alpy600_spec_create $specNo before"
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo wvl]
   # verifier res ...
   # lassign $res symbx
   set bufNo 1
   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]
   set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo x] 0]
   set res [alpy600_spec_tools_spec2symbolx $specNo $grandeurx]
   lassign $res symbx
   set xs $spec($specNo,$symbx)
   set nwvl [llength $xs]
   if {$nwvl!=$naxis1} {
      error "Spectrum $specNo has $nwvl pixels and image has $naxis1 pixels"
   }
   set spec($specNo,wv1,UID) {wv1 topo air ang}
   set spec($specNo,wv1) ""
   set spec($specNo,wvl,UID) {wvl topo air ang}
   set spec($specNo,wvl) ""
   set spec($specNo,wv2,UID) {wv2 topo air ang}
   set spec($specNo,wv2) ""
   for {set x 1} {$x<=$naxis1} {incr x} {
      set wv1 [focas_tools_polyval $polycoefs [expr $x-0.5]]
      #::console::affiche_resultat " focas_tools_polyval $polycoefs [expr $x-0.5]\n"
      lappend spec($specNo,wv1) $wv1
      set wvl [focas_tools_polyval $polycoefs $x]
      lappend spec($specNo,wvl) $wvl
      set wv2 [focas_tools_polyval $polycoefs [expr $x+0.5]]
      lappend spec($specNo,wv2) $wv2
   }
}

proc alpy600_spec_sub { specNo1 specNo2 } {
   alpy600_spec_tools_ope2 $specNo1 - $specNo2
   return ""
}

proc alpy600_spec_add { specNo1 specNo2 } {
   alpy600_spec_tools_ope2 $specNo1 + $specNo2
   return ""
}

proc alpy600_spec_prod { specNo1 specNo2 } {
   alpy600_spec_tools_ope2 $specNo1 * $specNo2
   return ""
}

proc alpy600_spec_div { specNo1 specNo2 } {
   alpy600_spec_tools_ope2 $specNo1 / $specNo2
   return ""
}

proc alpy600_spec_offset { specNo1 cste} {
   alpy600_spec_tools_ope1 $specNo1 + $cste
   return ""
}

proc alpy600_spec_mult { specNo1 cste} {
   alpy600_spec_tools_ope1 $specNo1 * $cste
   return ""
}

proc alpy600_spec_stat { specNo1 {grandeurx ""} {x1 4000} {x2 8000} {grandeury ""} } {
   global spec
   if {$grandeurx==""} {
      set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 x] 0]
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo1 $grandeurx]
   lassign $res symbx
   set xs $spec($specNo1,$symbx)
   set nx [llength $xs]
   if {$grandeury==""} {
      set grandeury [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 y] 0]
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo1 $grandeury]
   lassign $res symby
   set ys $spec($specNo1,$symby)
   set samples ""
   for {set kx 0} {$kx<$nx} {incr kx} {
      set x [lindex $xs $kx]
      if {$x<$x1} { continue }
      if {$x>$x2} { continue }
      set y [lindex $ys $kx]
      lappend samples $y
   }
   set maxi [::math::statistics::max $samples]
   set mini [::math::statistics::min $samples]
   set mean [::math::statistics::mean $samples]
   set std [::math::statistics::stdev $samples]
   set median [::math::statistics::median $samples]
   return [list $mini $maxi $mean $std $median]
}

# normalise à norm_value sur la moyenne du flux entre x1 et x2
proc alpy600_spec_ngain { specNo1 norm_value {grandeurx ""} {x1 4900} {x2 5100} {grandeury ""} } {
   global spec
   if {$grandeurx==""} {
      set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 x] 0]
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo1 $grandeurx]
   lassign $res symbx
   set xs $spec($specNo1,$symbx)
   set nx [llength $xs]
   if {$grandeury==""} {
      set grandeury [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 y] 0]
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo1 $grandeury]
   lassign $res symby
   set ys $spec($specNo1,$symby)
   set samples ""
   for {set kx 0} {$kx<$nx} {incr kx} {
      set x [lindex $xs $kx]
      if {$x<$x1} { continue }
      if {$x>$x2} { continue }
      set y [lindex $ys $kx]
      lappend samples $y
   }
   set mean [::math::statistics::mean $samples]
   set std [::math::statistics::stdev $samples]
   set median [::math::statistics::median $samples]
   set mult [expr 1.*$norm_value/$median]
   set ynews ""
   for {set kx 0} {$kx<$nx} {incr kx} {
      set y [lindex $ys $kx]
      lappend ynews [expr $y*$mult]
   }
   set spec($specNo1,$symby) $ynews
   return $mult
}

proc alpy600_spec_integral { specNo } {
   global spec
   # 1 erg = 1e-7 J
   # E = h*c/lambda
   set h 6.62606957e-34 ; # J.s
   set c 299792458 ; # m/s
   set hc [expr $h*$c]
   set res [alpy600_spec_tools_spec2symbolxy $specNo wvl flu]
   lassign $res symbx1 symby1
   lassign $spec($specNo,$symby1,UID) grandeur site medium unite
   if {($unite!="esca")&&($unite!="psca")} {
      error "Flux not in UID unit = esca or psca"
   }
   set x1s $spec($specNo,$symbx1)
   set y1s $spec($specNo,$symby1)
   set n [llength $x1s]
   set res [alpy600_spec_tools_spec2symbolx $specNo wv1]
   set x1_wv1s $spec($specNo,$res)
   set res [alpy600_spec_tools_spec2symbolx $specNo wv2]
   set x1_wv2s $spec($specNo,$res)
   # verifier res ...
   set finteg 0.
   for {set k 0} {$k<$n} {incr k} {
      set lambda [lindex $x1s $k]
      if {($lambda<3500)||($lambda>9000)} {
         continue
      }
      set l1 [lindex $x1_wv1s $k]
      set l2 [lindex $x1_wv2s $k]
      set dl [expr abs($l2-$l1)]
      set f [lindex $y1s $k]
      set finteg [expr $finteg+$f*$dl]
   }
   return $finteg
}

proc alpy600_spec_atmosphere_trans { specNo airmass altitude_m Aerosol_Optical_Depth} {
   # 0.07=hiver 0.21=ete : Aerosol Optical Depth (AOD)
   global spec
   global audace
   if {[info exists spec($specNo)]==0} {
      error "Use alpy600_spec_create $specNo before"
   }
   set res [alpy600_spec_tools_spec2symbolx $specNo wvl]
   lassign $res symbx
   set wvls $spec($specNo,$symbx)
   lassign $spec($specNo,$symbx,UID) grandeur site medium unite
   # - convert_unit to transform unite into micrometers
   if {$unite=="ang"} {
      set convert_unit 1e-4
   }
   if {$unite=="met"} {
      set convert_unit 1e6
   }
   if {$unite=="nme"} {
      set convert_unit 1e-3
   }
   set spec($specNo,tra,UID) {tra app iat no }
   set z $airmass
   set h [expr $altitude_m*1e-3]
   set AOD $Aerosol_Optical_Depth
   set spec($specNo,tra) ""
   for {set k 0} {$k<[llength $wvls]} {incr k} {
      set valt 0.
      set wvl [lindex $wvls $k]
      set lmu [expr 1.*$wvl*$convert_unit]
      set n1n1 [expr 0.23465+(1.076e2/(146-1/$lmu/$lmu))+(0.93161/(41-1/$lmu/$lmu))]
      set Ar [expr 9.4977e-3*pow($lmu,-4)*$n1n1*$n1n1*exp(-$h/7.996)]
      set Tz [expr exp(-2*0.0168*exp(-15*abs($lmu-0.59)))]
      set Ao [expr -2.5*log10($Tz)]
      set Ao0 [expr 1.5*exp(-pow(($lmu-0.300)/0.012,2))]
      set Ao1 [expr 0.03/(1+pow(($lmu-0.59)/0.07,2))]
      set Ao2 [expr 0.011/(1+pow(($lmu-0.576)/0.006,2))]
      set Ao3 [expr 0.009/(1+pow(($lmu-0.604)/0.01,2))]
      set Ao4 [expr 0.01/(1+pow(($lmu-0.630)/0.013,2))]
      set Ao5 [expr 0.0048/(1+pow(($lmu-0.531)/0.006,2))]
      set Ao6 [expr 0.003/(1+pow(($lmu-0.545)/0.009,2))]
      set Ao7 [expr 0.003/(1+pow(($lmu-0.564)/0.01,2))]
      set Ao8 [expr 0.004/(1+pow(($lmu-0.572)/0.01,2))]
      set Ao9 [expr 0.003/(1+pow(($lmu-0.506)/0.003,2))]
      set Ao10 [expr 0.004/(1+pow(($lmu-0.477)/0.0025,2))]
      set Ao [expr $Ao0+$Ao1+$Ao2+$Ao3+$Ao4+$Ao5+$Ao6+$Ao7+$Ao8+$Ao9+$Ao10]
      set Aa [expr 2.5*log10( exp($AOD*pow($lmu/0.55,-1.3)))]
      set AA [expr $Ar+$Ao+$Aa]
      set TT [expr pow(10,-0.4*$AA*$z)]
      lappend spec($specNo,tra) $TT
   }
}

# ############# DEBUT Conversions d'unités de flux pour un spectre observé

# ---- passage hors atmosphere
proc alpy600_spec_inatm2outatm { specNo1 airmass altitude_m Aerosol_Optical_Depth } {
   global spec
   alpy600_spec_atmosphere_trans $specNo1 $airmass $altitude_m $Aerosol_Optical_Depth
   alpy600_spec_tools_ope2 $specNo1 / $specNo1 flu tra
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   set medium oat
   set spec($specNo1,flu,UID) [list $grandeur $site $medium $unite]
   return ""
}

# ---- passage ADU/bin => ADU/A
proc alpy600_spec_bin2ang { specNo1 } {
   global spec
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   if {$unite=="adub"} {
      set spec($specNo1,flu,UID) [list $grandeur $site $medium adua]
   } else {
      error "Spectrum must be in units adub"
   }
   alpy600_spec_tools_ope1spectral $specNo1 * 1.
   return ""
}

# ---- passage ADU/A => ADU/s/cm2/A
proc alpy600_spec_energy2fluxdensity { specNo1 diameter_m exposure_s } {
   global spec
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   if {$unite=="adua"} {
      set spec($specNo1,flu,UID) [list $grandeur $site $medium asca]
   } else {
      error "Spectrum must be in units adua"
   }
   set pi [expr 4*atan(1)]
   set calib [expr 1./$exposure_s/($pi*pow($diameter_m*1e2,2)/4)]
   alpy600_spec_tools_ope1 $specNo1 * $calib
   return ""
}

# ---- passage ADU/A/cm2/A => photo-electrons/s/cm2/A
proc alpy600_spec_adu2el { specNo1 gain_e_ADU} {
   global spec
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   if {$unite=="asca"} {
      set spec($specNo1,flu,UID) [list $grandeur $site $medium pesca]
   } else {
      error "Spectrum must be in units asca"
   }
   alpy600_spec_tools_ope1 $specNo1 * $gain_e_ADU
   return ""
}

# ############# FIN Conversions d'unités de flux pour un spectre observé

# ############# DEBUT Conversions d'unités de flux pour un spectre catalogue

# specNo est un spectre deja calibre en longueurs d'onde
proc alpy600_spec_calib2spec { specNo starname } {
   global spec
   global audace
   if {[info exists spec($specNo)]==0} {
      error "Use alpy600_spec_create $specNo before"
   }
   set fichier $audace(rep_install)/gui/audace/catalogues/cataspectro/calspec/calspec.lst
   set f [open $fichier r]
   set lignes [split [read $f] \n]
   close $f
   set starname [string tolower $starname]
   set nl [llength $lignes]
   set fichier ""
   for {set kl 0} {$kl<$nl} {incr kl} {
      set ligne [lindex $lignes $kl]
      set name [string tolower [lindex $ligne 0]]
      if {$name==$starname} {
         set fichier [lindex $ligne 9]
      }
   }
   if {$fichier==""} {
      error " Star name $starname not found"
   }
   set fichier $audace(rep_install)/gui/audace/catalogues/cataspectro/calspec/${fichier}.txt
   set f [open $fichier r]
   set lignes [split [read $f] \n]
   close $f
   # -- il faut eliminer les doublons
   set nl [llength $lignes]
   set wl1s ""
   set wl2s ""
   set wl2 ""
   set fls ""
   set ftotal 0.
   set ntotal 0
   for {set kl 0} {$kl<[expr $nl-1]} {incr kl} {
      # --- pixel du spectre calibration
      set ligne [lindex $lignes $kl]
      #::console::affiche_resultat " kl=$kl ligne=$ligne \n"
      set wl0  [lindex $ligne 0]
      set f    [lindex $ligne 1]
      set ftotal [expr $ftotal+$f]
      #::console::affiche_resultat " ftotal=$ftotal \n"
      incr ntotal
      set wl1 [lindex [lindex $lignes [expr $kl+1]] 0]
      #::console::affiche_resultat " kl=$kl wl0=$wl0 wl1=$wl1\n"
      if {$wl1!=$wl0} {
         set dwl [expr $wl1-$wl0]
         if {$wl2==""} {
            set wl1 [expr $wl0-$dwl/2.]
         } else {
            set wl1 $wl2
         }
         set wl2 [expr $wl0+$dwl/2.]
         set f [expr $ftotal/$ntotal]
         lappend wl1s $wl1
         lappend wl2s $wl2
         lappend fls $f
         set ftotal 0.
         set ntotal 0
      }
   }
   set nl [llength $wl1s]
   #::plotxy::plot $wl1s $fls b-
   #::plotxy::xlabel w
   #::plotxy::ylabel f
   #::plotxy::title " TOTO "
   # ---
   set res [alpy600_spec_tools_spec2symbolx $specNo wv1]
   # verifier res ...
   lassign $res symbx1
   set wv1s $spec($specNo,$symbx1)
   set nw [llength $spec($specNo,$symbx1)]
   lassign $spec($specNo,$symbx1,UID) grandeur site medium unite
   set res [alpy600_spec_tools_spec2symbolx $specNo wv2]
   # verifier res ...
   lassign $res symbx2
   set wv2s $spec($specNo,$symbx2)
   set spec($specNo,flu,UID) {flu abs oat esca}
   set spec($specNo,flu) ""
   set spec($specNo,bin,UID) {bin topo air bin}
   set spec($specNo,bin) ""
   set kl1 0
   for {set kw 0} {$kw<$nw} {incr kw} {
      # --- pixel du spectre observé
      set w1 [lindex $wv1s $kw]
      set w2 [lindex $wv2s $kw]
      set f 0
      set ftotal 0
      #::console::affiche_resultat " OBS kw=$kw/$nw w1=$w1 w2=$w2\n"
      for {set kl $kl1} {$kl<$nl} {incr kl} {
         # --- pixel du spectre calibration
         set wl1 [lindex $wl1s $kl]
         set wl2 [lindex $wl2s $kl]
         #::console::affiche_resultat " CAL wl1=$wl1 wl2=$wl2\n"
         if {$wl2<$w1} {
            incr kl1
            set f [lindex $fls $kl]
            set ftotal 1
            continue
         } else {
            set f [expr $f+[lindex $fls $kl]]
            incr ftotal 1
            #::console::affiche_resultat " OBS kw=$kw/$nw w1=$w1 w2=$w2 f=$f\n"
            if {$wl1<$w2} {
               break
            }
         }
      }
      if {$ftotal==0} {
         set ftotal 1.
      }
      lappend spec($specNo,flu) [expr $f/$ftotal]
      lappend spec($specNo,bin) [expr $kw+1]
   }
}

proc alpy600_spec_erg2ph { specNo1 } {
   alpy600_spec_tools_erg2ph $specNo1
}

# specNo1 (photo-electron/s/cm2/A) specNo2 (photon/s/cm2/A)
# response en photo-electron/photon
proc alpy600_spec_compute_response { specNo1 specNo2 } {
   global spec
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   if {$unite=="pesca"} {
      set spec($specNo1,flu,UID) [list $grandeur $site $medium pep]
   } else {
      error "Spectrum must be in units pesca"
   }
   alpy600_spec_div $specNo1 $specNo2
   return ""
}

# specNo1 (photo-electron/s/cm2/A) specNo2 (photo-electron/photon)
# return (photon/s/cm2/A)
proc alpy600_spec_apply_response { specNo1 specNo2 } {
   global spec
   lassign $spec($specNo1,flu,UID) grandeur site medium unite
   if {$unite=="pesca"} {
      set spec($specNo1,flu,UID) [list $grandeur $site $medium psca]
   } else {
      error "Spectrum must be in units pesca"
   }
   alpy600_spec_tools_ope2 $specNo1 / $specNo2
   return ""
}

proc alpy600_spec_ph2erg { specNo1 } {
   alpy600_spec_tools_ph2erg $specNo1
}


# ############# FIN Conversions d'unités de flux pour un spectre catalogue

proc alpy600_spec_flux2lines { specNo } {
   global xobs yobs
   global spec
   set grandeurx ""
   set grandeury ""
   if {$grandeurx==""} {
      set grandeurx [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo x] 0]
   }
   if {$grandeury==""} {
      set grandeury [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo y] 0]
   }
   set res [alpy600_spec_tools_spec2symbolxy $specNo $grandeurx $grandeury]
   lassign $res symbx symby
   set xs $spec($specNo,$symbx)
   set ys $spec($specNo,$symby)
   set res [lsort -real $ys]
   set mini [lindex $res 0]
   set maxi [lindex $res end]
   set exposure 1
   set binx 1
   set biny 1
   set naxis1 [llength $ys]
   # === Detection en aveugle des raies et calcul de l'abscisse precise en pixels
   # --- calcul du seuil par rapport au bruit
   set std [::math::statistics::stdev [lrange $ys 0 20]]
   set seuil1 [expr 10*$std]
   # --- calcul du seuil par rapport au mini et maxi
   set seuil2 [expr 0.001*($maxi-$mini)]
   # --- on choisit le plus grand seuil
   if {$seuil1>$seuil2} {
      set seuil $seuil1
   } else {
      set seuil $seuil2
   }
   #console::affiche_resultat "seuil1 = $seuil1\n"
   #console::affiche_resultat "seuil2 = $seuil2\n"
   #console::affiche_resultat "seuil = $seuil\n"
   # --- algo de detection des pics
   set liste ""
   set liste2 ""
   set stars ""
   set id 0
   set value1 [lindex $ys 0]
   set value2 [lindex $ys 1]
   set value3 [lindex $ys 2]
   set value4 [lindex $ys 3]
   for {set kx 4} {$kx<=[expr $naxis1-4]} {incr kx} {
      set value5 [lindex $ys $kx]
      if {$value3>$seuil} {
         set slope12 [expr $value2-$value1]
         set slope23 [expr $value3-$value2]
         set slope34 [expr $value4-$value3]
         set slope45 [expr $value5-$value4]
         if {($slope12>0)&&($slope23>0)&&($slope34<0)&&($slope45<0)} {
            set total 0.
            set total [expr $total+($value1-$mini)*($kx-3)]
            set total [expr $total+($value2-$mini)*($kx-2)]
            set total [expr $total+($value3-$mini)*($kx-1)]
            set total [expr $total+($value4-$mini)*($kx-0)]
            set total [expr $total+($value5-$mini)*($kx+1)]
            set deno [expr $value1+$value2+$value3+$value4+$value5-5*$mini]
            set pix [expr 1.*$total/$deno]
            set larg 4
            set x1 [expr int($pix-$larg)]
            set x2 [expr $x1+2*$larg]
            set vobs [lrange $ys $x1 $x2]
            set xobs ""
            set yobs ""
            for {set kobs $x1} {$kobs<=$x2} {incr kobs} {
               lappend xobs $kobs
               lappend yobs [lindex $ys $kobs]
            }
            #console::affiche_resultat " x1=$x1 x2=$x2 yobs=$yobs\n"
            set x0 $pix
            set sig 1.5
            set fback [expr ([lindex $yobs 0]+[lindex $yobs end])/2.]
            set f [expr $value3 - $fback]
            set init_vector [list $f $x0 $sig $fback]
            #console::affiche_resultat " AVANT = $init_vector\n"
            set epsabs 1
            set sortie 0
            set ntrymax 5
            set nitermax 100
            set ktry 0
            while {$sortie==0} {
               set res [gsl_multimin_fminimizer_nmsimplex alpy600_spec_tools_gaussian $init_vector $epsabs $nitermax]
               set last_vector [lindex $res 0]
               set iters [split [lindex $res 1] \n]
               set status [lindex [split [lindex $iters end-1] =] end]
               set lastiter [lindex $iters end-2]
               set nbiter [lindex $lastiter 2]
               #console::affiche_resultat "==== ktry=$ktry epsabs=$epsabs\n"
               #console::affiche_resultat "lastiter = $lastiter\n"
               #console::affiche_resultat "status = $status\n"
               #console::affiche_resultat "nbiter = $nbiter\n"
               incr ktry
               if {$status==0} {
                  #console::affiche_resultat "nbiter = $nbiter && nitermax=$nitermax\n"
                  if {$nbiter==1} {
                     set epsabs [expr $epsabs*0.6]
                  } else {
                     set sortie 1
                  }
               } else {
                  if {$nbiter==$nitermax} {
                     set epsabs [expr $epsabs*(2.+rand()/10.)]
                  }
               }
               #console::affiche_resultat "ktry=$ktry ntrymax=$ntrymax\n"
               if {$ktry>$ntrymax} {
                  set sortie 2
               }
               #console::affiche_resultat "sortie = $sortie\n"
            }
            #console::affiche_resultat "===> lastiter = $lastiter\n"
            set final_vector [lindex $res 0]
            #console::affiche_resultat "APRES final_vector=$final_vector\n"
            set x [lindex $final_vector 1]
            set y 1
            set intx [lindex $final_vector 0]
            set flux [format %6.0f [expr $intx/$exposure/$biny]]
            set fluxerr 0
            set background [lindex $final_vector 3]
            set fwhm [lindex $final_vector 2]
            set flags 0
            if {($fwhm>1)&&($intx>$seuil)&&([expr abs($x-$x0)]<2.5)} {
               incr id
               set lambda 0
               lappend stars [list $x $y $flux $fwhm $lambda $id $flags]
            }
            #tk_messageBox
         }
      }
      set value1 $value2
      set value2 $value3
      set value3 $value4
      set value4 $value5
   }
   set star0s [lsort -decreasing -real -index 2 $stars]
   set nstar0s [llength $star0s]
   #::console::affiche_resultat "$nstar0s calibration lines found\n"
   return $star0s
}

# ###########################################################################
# ### Tool spectrum functions (used by spectrum functions)
# ###########################################################################
# alpy600_spec_tools_build.matrix {xvec degree}
# alpy600_spec_tools_build.vector {xvec yvec degree}
# alpy600_spec_tools_polyval { coefs x }
# alpy600_spec_tools_polyfit {x y degree}
# alpy600_spec_tools_spec2symbolx
# alpy600_spec_tools_spec2symbolxy
# alpy600_spec_tools_compatibility_xy
# alpy600_spec_tools_ope1
# alpy600_spec_tools_gaussian
# ###########################################################################

proc alpy600_spec_tools_build.matrix {xvec degree} {
    set sums [llength $xvec]
    for {set i 1} {$i <= 2*$degree} {incr i} {
        set sum 0
        foreach x $xvec {
            set sum [expr {$sum + pow($x,$i)}]
        }
        lappend sums $sum
    }

    set order [expr {$degree + 1}]
    set A [math::linearalgebra::mkMatrix $order $order 0]
    for {set i 0} {$i <= $degree} {incr i} {
        set A [math::linearalgebra::setrow A $i [lrange $sums $i $i+$degree]]
    }
    return $A
}

proc alpy600_spec_tools_build.vector {xvec yvec degree} {
    set sums [list]
    for {set i 0} {$i <= $degree} {incr i} {
        set sum 0
        foreach x $xvec y $yvec {
            set sum [expr {$sum + $y * pow($x,$i)}]
        }
        lappend sums $sum
    }

    set x [math::linearalgebra::mkVector [expr {$degree + 1}] 0]
    for {set i 0} {$i <= $degree} {incr i} {
        set x [math::linearalgebra::setelem x $i [lindex $sums $i]]
    }
    return $x
}

proc alpy600_spec_tools_polyfit {x y degree} {
   set A [alpy600_spec_tools_build.matrix $x $degree]
   set b [alpy600_spec_tools_build.vector $x $y $degree]
   # solve it
   set coeffs [math::linearalgebra::solveGauss $A $b]
   return $coeffs
}

proc alpy600_spec_tools_polyval { coefs x } {
   set np [llength $coefs]
   set lambda 0.
   for {set kp 0} {$kp<$np} {incr kp} {
      set l [expr [lindex $coefs $kp]*pow($x,$kp)]
      set lambda [expr $lambda+$l]
   }
   return $lambda
}

proc alpy600_spec_tools_spec2symbolx { specNo grandeurx } {
   global spec
   set res [lsort [array names spec]]
   set symb ""
   set re2s ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no!=$specNo} {
         continue
      }
      if {$attrib=="UID"} {
         set symb $symbol
      }
      lappend re2s $re
   }
   if {$symb==""} {
      return ""
   }
   set symbx ""
   foreach re $re2s {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$attrib=="UID"} {
         lassign [lindex $spec($re) 0] grandeur site medium unite
         if {$grandeur==$grandeurx} {
            set symbx $symbol
         }
      }
   }
   return $symbx
}

proc alpy600_spec_tools_spec2symbolxy { specNo grandeurx grandeury } {
   global spec
   set res [lsort [array names spec]]
   set symb ""
   set re2s ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no!=$specNo} {
         continue
      }
      if {$attrib=="UID"} {
         set symb $symbol
      }
      lappend re2s $re
   }
   if {$symb==""} {
      return ""
   }
   set symbx ""
   set symby ""
   foreach re $re2s {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$attrib=="UID"} {
         lassign [lindex $spec($re) 0] grandeur site medium unite
         if {$grandeur==$grandeurx} {
            set symbx $symbol
         }
         if {$grandeur==$grandeury} {
            set symby $symbol
         }
      }
   }
   return [list $symbx $symby]
}

proc alpy600_spec_tools_compatibility_xy { specNo1 specNo2 grandeurx grandeury } {
   global spec
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 $grandeurx $grandeury]
   lassign $res symbx1 symby1
   set UIDx1 $spec($specNo1,$symbx1,UID)
   set UIDy1 $spec($specNo1,$symby1,UID)
   set res [alpy600_spec_tools_spec2symbolxy $specNo2 $grandeurx $grandeury]
   lassign $res symbx2 symby2
   set UIDx2 $spec($specNo2,$symbx2,UID)
   set UIDy2 $spec($specNo2,$symby2,UID)
   if {$UIDx1!=$UIDx2} {
      error "Spectrum $specNo2 wavelengths are of type $UIDx1 and spectrum $specNo2 wavelengths are of type $UIDx2"
   }
   if {$UIDy1!=$UIDy2} {
      error "Spectrum $specNo2 fluxes are of type $UIDy1 and spectrum $specNo2 fluxes are of type $UIDy2"
   }
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set x2s $spec($specNo2,$symbx2)
   set y2s $spec($specNo2,$symby2)
   set n1 [llength $x1s]
   set n2 [llength $x2s]
   if {$n1!=$n2} {
      error "Spectrum $specNo2 wavelengths have $n1 bins and spectrum $specNo2 wavelengths have $n2 bins"
   }
   return [list $symbx1 $x1s $symby1 $y1s $symbx2 $x2s $symby2 $y2s]
}

proc alpy600_spec_tools_ope2 { specNo1 operation specNo2 {grandeury1 flu} {grandeury2 flu} } {
   global spec
   # --- search for grandeurs on x
   set grandeurx1s [alpy600_spec_tools_get_pertinent_grandeur $specNo1 x]
   set grandeurx2s [alpy600_spec_tools_get_pertinent_grandeur $specNo2 x]
   set grandeurx2 ""
   foreach grandeurx1 $grandeurx1s {
      set k [lsearch -exact $grandeurx2s $grandeurx1]
      if {$k>=0} {
         set grandeurx2 [lindex $grandeurx2s $k]
         break
      }
   }
   # --- search for grandeurs on y
   if {$grandeury1==""} {
      set grandeury1s [alpy600_spec_tools_get_pertinent_grandeur $specNo1 y]
      if {$grandeury2==""} {
         set grandeury2s [alpy600_spec_tools_get_pertinent_grandeur $specNo2 y]
      } else {
         set grandeury2s $grandeury2
      }
      foreach grandeury1 $grandeury1s {
         set k [lsearch -exact $grandeury2s $grandeury1]
         if {$k>=0} {
            set grandeury2 [lindex $grandeury2s $k]
            break
         }
      }
   }
   #console::affiche_resultat "grandeurx1=$grandeurx1 grandeurx2=$grandeurx2 grandeury1=$grandeury1 grandeury2=$grandeury2\n"
   # --- symbols
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 $grandeurx1 $grandeury1]
   lassign $res symbx1 symby1
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set res [alpy600_spec_tools_spec2symbolxy $specNo2 $grandeurx2 $grandeury2]
   lassign $res symbx2 symby2
   set x2s $spec($specNo2,$symbx2)
   set y2s $spec($specNo2,$symby2)
   set n [llength $x1s]
   set ys ""
   # --- case of same sampling
   set sampling equal
   for {set k 0} {$k<$n} {incr k} {
      set x1 [lindex $x1s $k]
      set x2 [lindex $x2s $k]
      if {$x1!=$x2} {
         set sampling not_equal
         break
         #error "Spectra $grandeurx1 are not the same"
      }
      set y1 [lindex $y1s $k]
      set y2 [lindex $y2s $k]
      set err [catch {
         set val [expr 1. * $y1 $operation $y2]
      } msg ]
      if {($err==1)||($val=="Inf")||($val=="-Inf")||([expr abs($val)]>1e7)} {
         set val 0.
      }
      lappend ys $val
   }
   # --- case of different sampling. resampling a la volée
   if {$sampling=="not_equal"} {
      set symbx1_wv1 [alpy600_spec_tools_spec2symbolx $specNo1 wv1]
      set symbx1_wv2 [alpy600_spec_tools_spec2symbolx $specNo1 wv2]
      set x1_wv1s $spec($specNo1,$symbx1_wv1)
      set x1_wv2s $spec($specNo1,$symbx1_wv2)
      set n1 [llength $x1_wv1s]
      set symbx2_wv1 [alpy600_spec_tools_spec2symbolx $specNo2 wv1]
      set symbx2_wv2 [alpy600_spec_tools_spec2symbolx $specNo2 wv2]
      set x2_wv1s $spec($specNo2,$symbx2_wv1)
      set x2_wv2s $spec($specNo2,$symbx2_wv2)
      set n2 [llength $x2_wv1s]
      for {set k1 0} {$k1<$n1} {incr k1} {
         set x1_wv1 [lindex $x1_wv1s $k1]
         set x1_wv2 [lindex $x1_wv2s $k1]
         set y1 [lindex $y1s $k1]
         set f ""
         for {set k2 0} {$k2<$n2} {incr k2} {
            set x2_wv1 [lindex $x2_wv1s $k2]
            set x2_wv2 [lindex $x2_wv2s $k2]
            set y2 [lindex $y2s $k2]
            #
            # x2      wv1---------------wv2
            # x1                                wv1---------------wv2
            #
            # x2                        wv1---------------------------------wv2
            # x1                                wv1---------------wv2
            #
            # x2                        wv1-----------wv2
            #                                         wv1-----wv2
            #                                                 wv1-----wv2
            # x1                                wv1---------------wv2
            #
            # x2                                                          wv1---------------wv2
            # x1                                wv1---------------wv2
            if {$x2_wv2<$x1_wv1} {
               continue
            }
            if {$x2_wv1>$x1_wv2} {
               break
            }
            if {($x2_wv1<$x1_wv1)&&($x2_wv2>=$x1_wv2)} {
               set f $y2
               break
            }
            if {($x2_wv1<$x1_wv1)&&($x2_wv2<$x1_wv2)} {
               set fwtot 0.
               set wtot 0.
               set sortie 0
               set kk2 $k2
               while {$sortie==0} {
                  set x2_wv1 [lindex $x2_wv1s $kk2]
                  set x2_wv2 [lindex $x2_wv2s $kk2]
                  set y2 [lindex $y2s $kk2]
                  if {($x2_wv1<$x1_wv1)} {
                     set w [expr ($x2_wv2-$x1_wv1)/($x2_wv2-$x2_wv1)]
                     set f $y2
                  } elseif {($x2_wv2>=$x1_wv2)} {
                     set w [expr ($x1_wv2-$x2_wv1)/($x2_wv2-$x2_wv1)]
                     set f $y2
                     set sortie 1
                  } else {
                     set w 1
                     set f $y2
                  }
                  set fwtot [expr $fwtot+$f*$w]
                  set wtot [expr $wtot+$w]
                  incr kk2
                  if {$kk2>=$n2} {
                     set sortie 2
                  }
               }
               set f [expr $fwtot/$wtot]
               break
            }
         }
         if {$f==""} {
            set val 0.
         } else {
            set err [catch {
               set val [expr 1. * $y1 $operation $y2]
            } msg ]
            if {($err==1)||($val=="Inf")||($val=="-Inf")||([expr abs($val)]>1e7)} {
               set val 0.
            }
         }
         lappend ys $val
      }
   }
   #
   set spec($specNo1,$symby1) $ys
   return ""
}

proc alpy600_spec_tools_ope1 { specNo1 operation scalar {grandeury1 flu}} {
   global spec
   # --- search for grandeurs on x
   set grandeurx1 [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 x] 0]
   # --- search for grandeurs on y
   if {$grandeury1==""} {
      set grandeury1 [lindex [alpy600_spec_tools_get_pertinent_grandeur $specNo1 y] 0]
   }
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 $grandeurx1 $grandeury1]
   lassign $res symbx1 symby1
   # verifier res ...
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set n [llength $x1s]
   set ys ""
   for {set k 0} {$k<$n} {incr k} {
      set y1 [lindex $y1s $k]
      lappend ys [expr 1. * $y1 $operation $scalar]
   }
   set spec($specNo1,$symby1) $ys
   return ""
}

proc alpy600_spec_tools_ope1spectral { specNo1 operation scalar} {
   global spec
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 wvl flu]
   lassign $res symbx1 symby1
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set n [llength $x1s]
   set res [alpy600_spec_tools_spec2symbolx $specNo1 wv1]
   lassign $res symbx
   set x11s $spec($specNo1,$symbx)
   set res [alpy600_spec_tools_spec2symbolx $specNo1 wv2]
   lassign $res symbx
   set x12s $spec($specNo1,$symbx)
   # verifier res ...
   set ys ""
   for {set k 0} {$k<$n} {incr k} {
      set x11 [lindex $x11s $k]
      set x12 [lindex $x12s $k]
      set dl [expr abs($x11-$x12)]
      set y1 [lindex $y1s $k]
      lappend ys [expr 1. * $y1 $operation $scalar / $dl]
   }
   set spec($specNo1,$symby1) $ys
   return ""
}

proc alpy600_spec_tools_erg2ph { specNo1 } {
   global spec
   # 1 erg = 1e-7 J
   # E = h*c/lambda
   set h 6.62606957e-34 ; # J.s
   set c 299792458 ; # m/s
   set hc [expr $h*$c]
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 wvl flu]
   lassign $res symbx1 symby1
   lassign $spec($specNo1,$symby1,UID) grandeur site medium unite
   if {$unite!="esca"} {
      error "Flux not in UID unit = esca"
   }
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set n [llength $x1s]
   # verifier res ...
   set ys ""
   for {set k 0} {$k<$n} {incr k} {
      set lambda [lindex $x1s $k]
      set joules_per_photon [expr $hc/($lambda*1e-10)]
      set erg [lindex $y1s $k] ; # erg
      set ph [expr $erg*1e-7/$joules_per_photon]
      lappend ys $ph
   }
   set spec($specNo1,$symby1) $ys
   set spec($specNo1,$symby1,UID) [list $grandeur $site $medium psca]
   return ""
}

proc alpy600_spec_tools_ph2erg { specNo1 } {
   global spec
   # 1 erg = 1e-7 J
   # E = h*c/lambda
   set h 6.62606957e-34 ; # J.s
   set c 299792458 ; # m/s
   set hc [expr $h*$c]
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 wvl flu]
   lassign $res symbx1 symby1
   lassign $spec($specNo1,$symby1,UID) grandeur site medium unite
   if {$unite!="psca"} {
      error "Flux not in UID unit = psca"
   }
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set n [llength $x1s]
   # verifier res ...
   set ys ""
   for {set k 0} {$k<$n} {incr k} {
      set lambda [lindex $x1s $k]
      set joules_per_photon [expr $hc/($lambda*1e-10)]
      set ph [lindex $y1s $k] ; # ph
      set erg [expr $ph*$joules_per_photon/1e-7]
      lappend ys $erg
   }
   set spec($specNo1,$symby1) $ys
   set spec($specNo1,$symby1,UID) [list $grandeur $site $medium esca]
   return ""
}

proc alpy600_spec_continuum_fit { specNo1 {apodisation 0.00005} {threshold 0} {dpix 15} } {
   global spec
   set res [alpy600_spec_tools_spec2symbolxy $specNo1 wvl flu]
   lassign $res symbx1 symby1
   lassign $spec($specNo1,$symby1,UID) grandeur site medium unite
   set x1s $spec($specNo1,$symbx1)
   set y1s $spec($specNo1,$symby1)
   set n [llength $x1s]
   # verifier res ...
   # points d'amers = zone reputées pour avoir un continuum a la resolution de l'alpy600
   #
   set amerangs {{3500 2} {3700 2} {3800 2} {3820 2} {3867 2} {3928 2} {4024 2} {4043 2} {4191 20} {4244 20} {4429 20} {4710 20} {5032 20} {5500 20} {5700 100} {6000 20} {6200 20} {6400 20} {6725 20} {6840 20} {7100 20} {7350 20} {7555 20} {8100 20} {8240 20} }
   set amerxs ""
   set amerys ""
   lappend amerxs 0
   lappend amerys 0
   lappend amerdys 1
   set k0 0
   set n1 [expr $n-1]
   foreach amerang $amerangs {
      lassign $amerang wvl dwv
      set wv11 [expr $wvl-$dwv/2.]
      set wv22 [expr $wvl+$dwv/2.]
      for {set k $k0} {$k<$n1} {incr k} {
         set wv1 [lindex $x1s $k]
         set wv2 [lindex $x1s [expr $k+1]]
         if {($wv1<=$wv11)&&($wv2>$wv11)} {
            set k0 $k
            break
         }
      }
      set k1 $k
      for {set k $k0} {$k<$n1} {incr k} {
         set wv1 [lindex $x1s $k]
         set wv2 [lindex $x1s [expr $k+1]]
         if {($wv1<=$wv22)&&($wv2>$wv22)} {
            break
         }
      }
      set k2 $k
      set sample [lrange $y1s $k1 $k2]
      set lambda [lindex $x1s [expr ($k1+$k2)/2]]
      set median [lindex [lsort -real -increasing $sample] [expr int(floor(0.8*[llength $sample]))]]
      lappend amerxs $lambda
      lappend amerys $median
      lappend amerdys 1
   }

   lappend amerxs [expr 1.5*$lambda]
   lappend amerys 0
   lappend amerdys 1
   set yfit1s [ak_fitspline $amerxs $amerys $apodisation $amerdys $x1s]
   set spec($specNo1,$symby1) [lindex $yfit1s 1]
   #plotxy::plot $amerxs $amerys ro: 2
   #plotxy::hold on
   #tk_messageBox -message "Amer response"
   return ""
}


proc alpy600_spec_tools_gaussian { v } {
   global xobs yobs
   lassign $v f xc sig fback
   set sig2 [expr $sig*$sig]
   set n [llength $xobs]
   set residu 0.
   set ycs ""
   for {set k 0} {$k<$n} {incr k} {
      set x [lindex $xobs $k]
      set yo [lindex $yobs $k]
      set yc [expr $f * exp ( -($x-$xc)*($x-$xc)/2./$sig2) + $fback]
      lappend ycs $yc
      set residu [expr $residu + ($yo - $yc)*($yo - $yc) ]
   }
   if {1==0} {
      ::plotxy::hold off
      ::plotxy::plot $xobs $yobs ro-
      ::plotxy::hold on
      ::plotxy::plot $xobs $ycs b-
      ::plotxy::title $v
      #tk_messageBox
   }
   return $residu
}

# ###########################################################################
# ### Tool spectrum unit functions (used by spectrum functions)
# ###########################################################################
#
# ###########################################################################

proc alpy600_spec_tools_get_grandeurs { specNo } {
   global spec
   set res [lsort [array names spec]]
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no!=$specNo} {
         continue
      }
      if {$attrib=="UID"} {
         lassign $spec($re) grandeur site medium unite
         lappend grandeurs $grandeur
      }
   }
   return $grandeurs
}

proc alpy600_spec_tools_get_pertinent_grandeur { specNo xy } {
   global spec
   set res [lsort [array names spec]]
   set uids ""
   foreach re $res {
      set reb [split $re ,]
      lassign $reb no symbol attrib
      if {$no!=$specNo} {
         continue
      }
      if {$attrib=="UID"} {
         lassign $spec($re) grandeur site medium unite
         set re2s [alpy600_spec_tools_get_uid_grandeurs]
         set k [lsearch -exact -index 0 $re2s $grandeur]
         if {$k>=0} {
            set uid [lindex $re2s $k]
            lassign $uid g short full xxyy priority
            # console::affiche_resultat "uid = $uid xy=$xy\n"
            if {($xy==$xxyy)&&($priority!="")} {
               lappend uids [list $g $priority]
            }
         }
      }
   }
   set uids [lsort -index 1 -real $uids]
   set grandeurs ""
   foreach uid $uids {
      lappend grandeurs [lindex $uid 0]
   }
   return $grandeurs
}

proc alpy600_spec_tools_getuids { } {
   set res [alpy600_spec_tools_get_uid_grandeurs]
   console::affiche_resultat "====== grandeurs =======\n"
   foreach re $res {
      console::affiche_resultat "$re\n"
   }
   #
   set res [alpy600_spec_tools_get_uid_sites]
   console::affiche_resultat "====== sites =======\n"
   foreach re $res {
      console::affiche_resultat "$re\n"
   }
   #
   set res [alpy600_spec_tools_get_uid_mediums]
   console::affiche_resultat "====== mediums =======\n"
   foreach re $res {
      console::affiche_resultat "$re\n"
   }
   #
   set res [alpy600_spec_tools_get_uid_units]
   console::affiche_resultat "====== units =======\n"
   foreach re $res {
      console::affiche_resultat "$re\n"
   }
}

proc alpy600_spec_tools_getlabel { uid } {
   lassign $uid grandeur site medium unite
   #
   set res [alpy600_spec_tools_get_uid_grandeurs]
   set k [lsearch -exact -index 0 $res $grandeur]
   set g_descr [lindex [lindex $res $k] 1]
   #
   set res [alpy600_spec_tools_get_uid_sites]
   set k [lsearch -exact -index 0 $res $site]
   set s_descr [lindex [lindex $res $k] 1]
   #
   set res [alpy600_spec_tools_get_uid_mediums]
   set k [lsearch -exact -index 0 $res $medium]
   set m_descr [lindex [lindex $res $k] 1]
   #
   set res [alpy600_spec_tools_get_uid_units]
   set k [lsearch -exact -index 0 $res $unite]
   set u_unit [lindex [lindex $res $k] 1]
   set u_descr [lindex [lindex $res $k] 2]
   #
   if {$u_descr==""} {
      set u_descr $g_descr
   }
   set label "$s_descr $m_descr $u_descr"
   if {$u_unit!=""} {
      append label " ($u_unit)"
   }
   return $label
}

proc alpy600_spec_tools_get_uid_grandeurs { } {
   set uidgrandeurs ""
   # --- pour les calibrations en longueur d'onde
   #                     uid  short-description full-description         xy pertinent
   lappend uidgrandeurs {bi1  "bin"             "start bin pixel"         x}
   lappend uidgrandeurs {bin  "bin"             "central bin pixel"       x 3}
   lappend uidgrandeurs {bi2  "bin"             "start bin pixel"         x}
   lappend uidgrandeurs {wv1  "wavelength"      "start bin wavelength"    x}
   lappend uidgrandeurs {wvl  "wavelength"      "central bin wavelength"  x 1}
   lappend uidgrandeurs {wv2  "wavelength"      "end bin wavelength"      x}
   lappend uidgrandeurs {fr1  "frequency"       "start bin frequency"     x}
   lappend uidgrandeurs {frq  "frequency"       "central bin frequency"   x 2}
   lappend uidgrandeurs {fr2  "frequency"       "end bin frequency"       x}
   # --- pour les calibrations en flux
   #                     uid  short-description full-description         xy pertinent
   lappend uidgrandeurs {tr1  "transmission"    "lower bin transmission"  y}
   lappend uidgrandeurs {tra  "transmission"    "mean bin transmission"   y 2}
   lappend uidgrandeurs {tr2  "transmission"    "upper bin transmission"  y}
   lappend uidgrandeurs {fl1  "flux"            "lower bin flux"          y}
   lappend uidgrandeurs {flu  "flux"            "mean bin flux"           y 1}
   lappend uidgrandeurs {fl2  "flux"            "upper bin flux"          y}
   lappend uidgrandeurs {ef1  "efficiency"      "lower bin efficiency"    y}
   lappend uidgrandeurs {eff  "efficiency"      "mean bin efficiency"     y 3}
   lappend uidgrandeurs {ef2  "efficiency"      "upper bin efficiency"    y}
   return $uidgrandeurs
}

proc alpy600_spec_tools_get_uid_sites { } {
   set uidsites ""
   # --- pour les calibrations en longueur d'onde
   #                   uid  description
   lappend uidsites {topo  "topocentric"}
   lappend uidsites {geo   "geocentric"}
   lappend uidsites {bary  "barycentric"}
   lappend uidsites {helio "heliocentric"}
   # --- pour les calibrations en flux
   #                 uid   description
   lappend uidsites {app   "apparent"}
   lappend uidsites {abs   "absolute"}
   lappend uidsites {no    ""}
   return $uidsites
}

proc alpy600_spec_tools_get_uid_mediums { } {
   set uidmediums ""
   # --- pour les calibrations en longueur d'onde
   #                   uid  description
   lappend uidmediums {air  "in air"}
   lappend uidmediums {vac  "in vacuum"}
   # --- pour les calibrations en flux
   #                   uid  description
   lappend uidmediums {iat  "inside atmosphere"}
   lappend uidmediums {oat  "outside atmosphere"}
   return $uidmediums
}

proc alpy600_spec_tools_get_uid_units { } {
   set uidunits ""
   # --- pour les calibrations en longueur d'onde
   #                 uid   unit                    description
   lappend uidunits {bin   Pixel                   "bin index"}
   lappend uidunits {ang   Angtröm                 "wavelength"}
   lappend uidunits {hz    Hertz                   "frequency"}
   # --- pour les calibrations en flux
   #                 uid   unit                    description
   lappend uidunits {esch  erg/s/cm2/Hz            "spectral flux density"}
   lappend uidunits {escm  erg/s/cm2/µm            "spectral flux density"}
   lappend uidunits {psch  photon/s/cm2/Hz         "spectral flux density"}

   lappend uidunits {adub  ADU/bin                 "spectral energy"}
   lappend uidunits {adua  ADU/A                   "spectral energy"}
   lappend uidunits {asca  ADU/s/cm2/A             "spectral flux density"}
   lappend uidunits {pesca photo-eletron/s/cm2/A   "spectral flux density"}
   lappend uidunits {psca  photon/s/cm2/A          "spectral flux density"}

   lappend uidunits {esca  erg/s/cm2/A             "spectral flux density"}
   lappend uidunits {pep   photo-electron/photon   "quantum efficiency"}

   lappend uidunits {no    ""                      ""}

   return $uidunits
}


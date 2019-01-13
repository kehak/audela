#
#  file fly.tcl
#  brief Tools to generate graph files using fly.
#  author Alain KLOTZ
#  $Id: fly.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#

#  source "$audace(rep_install)/gui/audace/fly.tcl"
#  fly_test
#

proc fly_test { } {
   set xs {2454843.1 2454843.2 2454843.3 2454843.4 2454843.5 2454843.6 2454843.7 2454843.8 2454843.9}
   set ys {.2 .3 .5 .7 .8 .9 .4 .5 .5}
   fly_clf 600 300
   fly_plot $xs $ys "JD (UTC)" "magnitude" "SS_CVn-C"
   fly_write $::audace(rep_images)/test.gif fly
}

# fly -i fly.inp -o file.gif
proc fly { args } {
   set pathbin .
   catch { set pathbin [ file join $::audace(rep_gui) .. bin ] }
   set exefile [ file join ${pathbin} fly.exe ]
   set k [file exists "$exefile"]
   if {$k==0} {
      set exefile [ file join ${pathbin} fly ]
      set k [file exists "$exefile"]
   }
   if {$k==0} {
      error "fly.exe not found"
   }
   set ligne "exec \"$exefile\" $args"
   set err [ catch {
      eval $ligne
   } msg ]
   return "$msg"
}

proc fly_clf { dimx dimy } {
   global ros
   catch {unset flyfig}
   set ros(flyfig,param,dimx) $dimx
   set ros(flyfig,param,dimy) $dimy
   set textes ""
   append textes "new\n"
   append textes "size $dimx,$dimy\n"
   append textes "fill 1,1, 255,255,255\n"
   set ros(flyfig,script) $textes
   set ros(flyfig,params,padtitley) 3
   set ros(flyfig,params,titley) 15
   set ros(flyfig,params,ticklabely) 12
   set ros(flyfig,params,ticky) 14
   set ros(flyfig,params,padframe) 4
   set ros(flyfig,params,padtitlex) 3
   set ros(flyfig,params,xlabelx) 12
   set ros(flyfig,params,tickx) 14
   set ros(flyfig,params,ticklabelx) ?
   return 0
}

proc fly_text { x y texte {size medium} {orientation horizontal} } {
   global ros
   set textes ""
   if {[info exists ros(flyfig,param,dimx)]==0} {
      fly_clf 600 300
      set textes "$ros(flyfig,script)"
   }
   # size : tiny (5x8), small (6x12), medium (7x13, bold), large (8x16) or giant (9x15, bold).
   set n [string length $texte]
   set larg 0
   set haut 0
   if {$size=="tiny"} {
      set larg [expr 5*$n]
      set haut 8
   } elseif {$size=="small"} {
      set larg [expr 6*$n]
      set haut 12
   } elseif {$size=="medium"} {
      set larg [expr 7*$n]
      set haut 13
   } elseif {$size=="large"} {
      set larg [expr 8*$n]
      set haut 16
   } elseif {$size=="giant"} {
      set larg [expr 9*$n]
      set haut 15
   }
   set diam 5
   #append textes "fcircle $x,$y,$diam, 0,0,255\n"
   if {$orientation=="horizontal"} {
      set key string
      set x [expr $x-$larg/2.]
      set y [expr $y-$haut/2.]
   } else {
      set key stringup
      set x [expr $x-$haut/2.]
      set y [expr $y+$larg/2.]
   }
   append textes "$key 0,0,0, $x,$y,$size,$texte\n"
   return $textes
}

proc fly_tool_axe { vs nticklabel {datapad 0.03} } {
   set vmin  1e23
   set vmax -1e23
   foreach v $vs {
      if {$v<$vmin} {set vmin $v}
      if {$v>$vmax} {set vmax $v}
   }
   #::console::affiche_resultat "============================= nticklabel=$nticklabel\n"
   #::console::affiche_resultat "vmin=$vmin vmax=$vmax\n"
   set dv [expr $vmax-$vmin]
   #::console::affiche_resultat "dv=$dv\n"
   if {$dv<1e-8} { set dv 1 }
   set lim1 [expr ($vmax+$vmin)/2.-$dv*(1.+2.*$datapad)/2.]
   set lim2 [expr ($vmax+$vmin)/2.+$dv*(1.+2.*$datapad)/2.]
   #::console::affiche_resultat "lim1=$lim1 lim2=$lim2\n"
   set dlim [expr $lim2-$lim1]
   #::console::affiche_resultat "dlim=$dlim\n"
   set subdigit [expr 1+int(-floor(log10($dlim)))]
   #::console::affiche_resultat "A subdigit=$subdigit\n"
   if {$subdigit<0} { set subdigit 1 }
   #::console::affiche_resultat "B subdigit=$subdigit\n"
   set increment [expr ceil(1.*$dv/$nticklabel*pow(10,$subdigit))/pow(10,$subdigit)]
   #::console::affiche_resultat "increment=$increment\n"
   set ticklabel0 [format %.${subdigit}f [expr ceil(($lim1+$increment*0.1)*pow(10,$subdigit))/pow(10,$subdigit)]]
   #::console::affiche_resultat "ticklabel0=$ticklabel0\n"
   set ticklabels ""
   for {set k 0} {$k<$nticklabel} {incr k} {
      set ticklabel [format %.${subdigit}f [expr $ticklabel0+$k*$increment]]
      #::console::affiche_resultat "ticklabel=$ticklabel\n"
      lappend ticklabels $ticklabel
   }
   return [list $lim1 $lim2 $ticklabels]
}

proc fly_plot { xs ys {xlabel ""} {ylabel ""} {title ""} } {
   global ros
   if {[info exists ros(flyfig,param,dimx)]==0} {
      fly_clf 600 300
   }
   set textes "$ros(flyfig,script)"

   # --- data analysis
   set nx [llength $xs]
   set ny [llength $ys]
   if {$nx!=$ny} {
      error "Lengths of input vetors are not the same ($nx and $ny)"
   }
   set n $nx
   # --- x
   set res [fly_tool_axe $xs 3 0.03]
   set limx1 [lindex $res 0]
   set limx2 [lindex $res 1]
   set xticklabels [lindex $res 2]
   set dx [expr $limx2-$limx1]
   # --- y
   set res [fly_tool_axe $ys 5 0.03]
   set limy1 [lindex $res 0]
   set limy2 [lindex $res 1]
   set yticklabels [lindex $res 2]
   set dy [expr $limy2-$limy1]
   set ros(flyfig,params,ticklabelx) 0
   foreach yticklabel $yticklabels {
      set l [expr 6*(1+[string length $yticklabel])]
      if {$l>$ros(flyfig,params,ticklabelx)} {
         set ros(flyfig,params,ticklabelx) $l
      }
   }

   # --- cadre
   set x1 [expr $ros(flyfig,params,padtitlex)+$ros(flyfig,params,xlabelx)+$ros(flyfig,params,padtitlex)+$ros(flyfig,params,ticklabelx)+$ros(flyfig,params,tickx)+$ros(flyfig,params,padframe) ]
   set y1 [expr $ros(flyfig,params,padtitley)+$ros(flyfig,params,titley)+$ros(flyfig,params,padtitley)+$ros(flyfig,params,ticky)+$ros(flyfig,params,padframe) ]
   set x2 [expr $ros(flyfig,param,dimx) - ($ros(flyfig,params,padtitlex)+$ros(flyfig,params,tickx)+$ros(flyfig,params,padframe) )]
   set y2 [expr $ros(flyfig,param,dimy) - ($ros(flyfig,params,padtitley)+$ros(flyfig,params,ticklabely)+$ros(flyfig,params,padtitley)+$ros(flyfig,params,ticklabely)+$ros(flyfig,params,ticky)+$ros(flyfig,params,padframe) )]
   append textes "rect $x1,$y1,$x2,$y2, 0,0,0\n"

   # --- data plotting
   for {set k 0} {$k<$n} {incr k} {
      set vx [lindex $xs $k]
      set vy [lindex $ys $k]
      set x [expr 1.*$x1+($x2-$x1)*($vx-$limx1)/($limx2-$limx1)]
      set y [expr 1.*$y1+($y2-$y1)*($vy-$limy1)/($limy2-$limy1)]
      set diam 5
      append textes "fcircle $x,$y,$diam, 255,0,0\n"
   }

   # --- lignes autour du cadre
   set offsetlig $ros(flyfig,params,padframe)
   set x1a [expr int($x1-$offsetlig)]
   set y1a [expr int($y1+$offsetlig)]
   set x2a [expr int($x1-$offsetlig)]
   set y2a [expr int($y2-$offsetlig)]
   set xcadtic1 $x1a
   append textes "line $x1a,$y1a,$x2a,$y2a, 0,0,0\n"
   set x1a [expr int($x2+$offsetlig)]
   set y1a [expr int($y1+$offsetlig)]
   set x2a [expr int($x2+$offsetlig)]
   set y2a [expr int($y2-$offsetlig)]
   set xcadtic2 $x2a
   append textes "line $x1a,$y1a,$x2a,$y2a, 0,0,0\n"
   set x1a [expr int($x1+$offsetlig)]
   set y1a [expr int($y1-$offsetlig)]
   set x2a [expr int($x2-$offsetlig)]
   set y2a [expr int($y1-$offsetlig)]
   set ycadtic1 $y1a
   append textes "line $x1a,$y1a,$x2a,$y2a, 0,0,0\n"
   set x1a [expr int($x1+$offsetlig)]
   set y1a [expr int($y2+$offsetlig)]
   set x2a [expr int($x2-$offsetlig)]
   set y2a [expr int($y2+$offsetlig)]
   set ycadtic2 $y2a
   append textes "line $x1a,$y1a,$x2a,$y2a, 0,0,0\n"

   # --- Tick X
   foreach xticklabel $xticklabels {
      set vx $xticklabel
      set xt [expr 1.*$x1+($x2-$x1)*($vx-$limx1)/($limx2-$limx1)]
      set yt1 [expr $ycadtic1+0]
      set yt2 [expr $ycadtic1-7]
      append textes "line $xt,$yt1,$xt,$yt2, 0,0,0\n"
      set yt1 [expr $ycadtic2+0]
      set yt2 [expr $ycadtic2+7]
      append textes "line $xt,$yt1,$xt,$yt2, 0,0,0\n"
      set yt [expr $y2+$ros(flyfig,params,padframe)+$ros(flyfig,params,ticky)+0.5*$ros(flyfig,params,ticklabely)]
      append textes [fly_text $xt $yt $xticklabel small horizontal]
   }

   # --- Tick Y
   foreach yticklabel $yticklabels {
      set vy $yticklabel
      set yt [expr 1.*$y1+($y2-$y1)*($vy-$limy1)/($limy2-$limy1)]
      set xt1 [expr $xcadtic2+0]
      set xt2 [expr $xcadtic2+7]
      append textes "line $xt1,$yt,$xt2,$yt, 0,0,0\n"
      set xt1 [expr $xcadtic1+0]
      set xt2 [expr $xcadtic1-7]
      append textes "line $xt1,$yt,$xt2,$yt, 0,0,0\n"
      set xt [expr $x1-$ros(flyfig,params,padframe)-$ros(flyfig,params,ticky)-0.5*$ros(flyfig,params,ticklabely)]
      append textes [fly_text $xt $yt $yticklabel small horizontal]
   }

   # --- label title
   set x [expr $ros(flyfig,param,dimx)/2.]
   set y [expr $ros(flyfig,params,padtitley)+0.5*$ros(flyfig,params,titley)]
   append textes [fly_text $x $y $title giant horizontal]

   # --- label X
   set x [expr $ros(flyfig,param,dimx)/2.]
   set y [expr $y2+$ros(flyfig,params,padframe)+$ros(flyfig,params,ticky)+$ros(flyfig,params,ticklabely)+$ros(flyfig,params,padtitley)+0.5*$ros(flyfig,params,ticklabely)]
   append textes [fly_text $x $y $xlabel small horizontal]

   # --- label Y
   set x [expr $ros(flyfig,params,padtitlex)+0.5*$ros(flyfig,params,xlabelx)]
   set y [expr ($y1+$y2)/2.]
   append textes [fly_text $x $y $ylabel small vertical]

   # --- met à jour
   set ros(flyfig,script) $textes
   return $textes
}

proc fly_write { filegif {number ""} } {
   global ros
   if {[info exists ros(flyfig,script)]==0} {
      error "Pas de plot pret"
   }
   set textes "$ros(flyfig,script)"
   # --- fabrique le plot
   set f [open fly${number}.inp w]
   puts -nonewline $f $textes
   close $f
   set err [catch {fly -i fly${number}.inp -o "$filegif"} msg ]
   file delete -force -- fly${number}.inp
   if {$err==1} {
      error $msg
   }
   return ""
}

proc fly_var2gif { fichier } {
   global ros
   set f [open "$fichier" r]
   set res [split [read $f] \n]
   close $f
   set kend [lsearch $res END]
   if {$kend>=0} {
      for {set k 0} {$k<$kend} {incr k} {
         set ligne [lindex $res $k]
         set kegal [string first = "$ligne"]
         set kwd [string trim [string range "$ligne" 0 [expr $kegal-1]]]
         set value [string trim [string range "$ligne" [expr $kegal+1] end]]
         if {$kwd=="NAME"} {
            set titre "$value"
         }
         if {$kwd=="FILTER"} {
            set filtre $value
         }
      }
      set res [lrange "$res" [expr $kend+1] end]
   } else {
      set titre [file tail [file rootname $fichier]]
      set filtre C
   }
   set fichiergif [file rootname $fichier]

   set n [llength $res]
   if {$n==0} {
      return 0;
   }
   set res [lrange "$res" 0 [expr $n-2]]

   set res [gsl_mtranspose $res]
   set jds [lindex $res 0]
   set mags [lindex $res 1]
   set bars [lindex $res 2]
   set njd [llength $jds]
   if {[info commands tkwait]==""} {
   }
      # " Cree le Gif de la courbe de lumiere avec fly [file tail $fichier]"
      fly_clf 600 300
      fly_plot $jds $mags "JD (UTC)" "$filtre magnitude" "$titre"
      set err [catch {fly_write "${fichiergif}.gif"} msg ]
      if {$err==1} {
         error " Problem fly : $msg"
      }
#       # " Cree le Gif de la courbe de lumiere avec BLT [file tail $fichier]"
#       ::plotxy::clf
#       ::plotxy::figure 1
#       ::plotxy::setgcf 1 {{hide 0}}
#       set position [::plotxy::position]
#       ::plotxy::position [list [lindex $position 0] [lindex $position 1] 600 300]
#       #::plotxy::setgcf 1 {{hide 1}}
#       ::plotxy::plot $jds $mags ro. 1.5 [list -ybars $bars]
#       ::plotxy::xlabel "JD (UTC)"
#       ::plotxy::ylabel "$filtre magnitude"
#       ::plotxy::title "$titre"
#       ::plotxy::ydir reverse
#       ::plotxy::writegif "${fichiergif}.gif"
#       ::plotxy::clf
   return $njd
}


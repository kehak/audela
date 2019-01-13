# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/identification.tcl



package require math::constants




proc get_identifiedold { sra sdec serrpos srmag srmagerr ira idec ierrpos irmag irmagerr scoreposlimit scoremvlimit scorelimit log} {

    if {$log} {gren_info "identification\n"}
    if {$log} {gren_info "$sra $sdec $serrpos $srmag $srmagerr\n"}
    if {$log} {gren_info "$ira $idec $ierrpos $irmag $irmagerr\n"}
    if {$log} {
       gren_info "l1     L2\n"
       gren_info "$sra     $ira\n"
       gren_info "$sdec    $idec\n"
       gren_info "$serrpos $ierrpos  \n"
       gren_info "$srmag   $irmag \n"
       gren_info "$srmagerr $irmagerr\n"
       
       }
    set dtr $::math::constants::degtorad
    set score NULL
    set deltapos [expr sqrt(pow(($sra-$ira)*cos($sdec*$dtr),2) + pow($sdec-$idec,2))]
    if {$log} {gren_info "deltapos=$deltapos\n"}
    if {$log} {gren_info "deltapos arcsec=[expr $deltapos*3600.0]\n"}
    set deltaposdiv [expr ($serrpos + $ierrpos) / 3600.0]
    if {$log} {gren_info "deltaposdiv=$deltaposdiv\n"}
    set scorepos [expr (1.0 - $deltapos / $deltaposdiv) * 100.0]
    if {$log} {gren_info "scorepos=$scorepos\n"}
    if {$deltapos > $deltaposdiv } {
       gren_info "annulation du scorepos\n"
       set scorepos 0.0 
    }
    set deltamag [expr abs($irmag - $srmag)]
    if {$log} {gren_info "deltamag=$deltamag\n"}
    set deltamagdiv [expr $srmagerr+$irmagerr]
    if {$log} {gren_info "deltamagdiv=$deltamagdiv\n"}
    set scoremv [expr (1.0 - $deltamag / $deltamagdiv) * 100.0]
    if {$log} {gren_info "scoremv=$scoremv\n"}
    if { $deltamag > $deltamagdiv } {
       gren_info "annulation du scoremv\n"
       set scoremv 0.0
    }
    set score $scorepos
    if {$log} {gren_info "score=$score\n"}
    if { $scoremv < $score } { set score $scoremv }
    if {$log} {gren_info "score=$score\n"}
    if {$log} {gren_info "($scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit )\n"}
    if { $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit } {
       if {$log} {gren_info "($scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit )\n"}
       return true
       }
    return false
    }





proc get_identified { sra sdec serrpos srmag srmagerr ira idec ierrpos irmag irmagerr scoreposlimit scoremvlimit log} {

    if {$log} {gren_info "identification\n"}
    if {$log} {gren_info "$sra $sdec $serrpos $srmag $srmagerr\n"}
    if {$log} {gren_info "$ira $idec $ierrpos $irmag $irmagerr\n"}
    if {$log} {
       gren_info "l1         L2\n"
       gren_info "$sra       $ira\n"
       gren_info "$sdec      $idec\n"
       gren_info "$serrpos   $ierrpos  \n"
       gren_info "$srmag     $irmag \n"
       gren_info "$srmagerr  $irmagerr\n"
       
       }
    set dtr $::math::constants::degtorad
    set deltapos [expr sqrt(pow(($sra-$ira)*cos($sdec*$dtr),2) + pow($sdec-$idec,2))]
    if {$log} {gren_info "deltapos=$deltapos\n"}
    if {$log} {gren_info "deltapos arcsec=[expr $deltapos*3600.0]\n"}
    set deltaposdiv [expr ($serrpos + $ierrpos) / 3600.0]
    if {$log} {gren_info "deltaposdiv=$deltaposdiv\n"}
    set scorepos [expr (1.0 - $deltapos / $deltaposdiv) * 100.0]
    if {$log} {gren_info "scorepos=$scorepos\n"}
    if {$deltapos > $deltaposdiv } {
       if {$log} {gren_info "annulation du scorepos\n"}
       set scorepos 0.0 
    }
    set deltamag [expr abs($irmag - $srmag)]
    if {$log} {gren_info "deltamag=$deltamag\n"}
    set deltamagdiv [expr $srmagerr+$irmagerr]
    if {$log} {gren_info "deltamagdiv=$deltamagdiv\n"}
    set scoremv [expr (1.0 - $deltamag / $deltamagdiv) * 100.0]
    if {$log} {gren_info "scoremv=$scoremv\n"}
    if { $deltamag > $deltamagdiv } {
       if {$log} {gren_info "annulation du scoremv\n"}
       set scoremv 0.0
    }
    if {$log} {gren_info "( $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit )\n"}
    if { $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit } {
       if {$log} {gren_info "yep\n"}
       return true
       }
    return false
    }





   # source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/identification.tcl
   # set listsources2 [ identification3 $listsources IMG $tycho2 TYCHO2 30.0 10.0 10.0] 



proc identification { catalist1 catalog1 catalist2 catalog2 scoreposlimit scoremvlimit f log} {

   set tt0 [clock clicks -milliseconds]
 
 
   set ulog 1

   set decoupe 16
   set delta [expr 10./3600.]

   
   set resultlist {}
   
   #gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $catalist1]\n"
   
   set fields1  [lindex $catalist1 0]
   set sources1 [lindex $catalist1 1]
   set fields2  [lindex $catalist2 0]
   set sources2 [lindex $catalist2 1]



   set fa0l [lindex $f 0]
   set fd0l [lindex $f 1]
   set fa1l [lindex $f 2]
   set fd1l [lindex $f 3]
   if {$fa0l > $fa1l } {
      set x $fa0l
      set fa0l $fa1l
      set fa1l $x
   }
   if {$fd0l > $fd1l } {
      set x $fa0l
      set fd0l $fd1l
      set fd1l $x
   }

  if {$ulog} { gren_info "Chargement liste 1 : "}
   
   set ralist1 ""
   set id 0
   set llog 0
   foreach s $sources1 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog1 } {
           set data [lindex $cata 1]
           set tabs1($id,accepted)     0
           set tabs1($id,ra)           [lindex $data 0]
           set tabs1($id,dec)          [lindex $data 1]
           set tabs1($id,poserr)       [lindex $data 2]
           set tabs1($id,mag)          [lindex $data 3]
           set tabs1($id,magerr)       [lindex $data 4]
           lappend ralist1 [list $id [lindex $data 0] [lindex $data 1]]
           if {$log == 1 && $fa0l < $tabs1($id,ra) && $tabs1($id,ra) < $fa1l && $fd0l < $tabs1($id,dec) && $tabs1($id,dec) < $fd1l } {
              if {$ulog} {gren_info "source liste 1 : $id  $tabs1($id,ra) $tabs1($id,dec) \n"}
           }
         }
      }
      incr id
   }
   set ralist1 [lsort -index 1 $ralist1] 
   if {$ulog} {gren_info "liste 1 : [llength $ralist1] rows\n"}

   if {$ulog} {gren_info "Chargement liste 2 : "}
   set ralist2 ""
   set id 0
   foreach s $sources2 {
      foreach cata $s {
         if { [lindex $cata 0]==$catalog2 } {
           set data [lindex $cata 1]
           set tabs2($id,accepted)     0
           set tabs2($id,ra)           [lindex $data 0]
           set tabs2($id,dec)          [lindex $data 1]
           set tabs2($id,poserr)       [lindex $data 2]
           set tabs2($id,mag)          [lindex $data 3]
           set tabs2($id,magerr)       [lindex $data 4]
           lappend ralist2 [list $id [lindex $data 0] [lindex $data 1]]
           if {$log == 1 && $fa0l < $tabs2($id,ra) && $tabs2($id,ra) < $fa1l && $fd0l < $tabs2($id,dec) && $tabs2($id,dec) < $fd1l } {
              if {$ulog} {gren_info "source liste 2 : $id  $tabs2($id,ra) $tabs2($id,dec) \n"}
           }
         }
      }
      incr id
   }
   set ralist2 [lsort -index 1 $ralist2] 
   if {$ulog} {gren_info "liste 2 : [llength $ralist2] rows\n"}

   if {$ulog} {gren_info "ralist 1 : [lrange $ralist1 0 5] \n"}
   if {$ulog} {gren_info "ralist 2 : [lrange $ralist2 0 5] \n"}

   set tt1 [clock clicks -milliseconds]
   set tt [expr ($tt1 - $tt0)/1000.]
   if {$ulog} {gren_info "Chargement duration $tt sec \n"}


# Decoupe 

   set maxa -1
   set mina 361
   set maxd -1
   set mind 361

   foreach e1 $ralist1 {
      set i1 [lindex $e1 0]
      set a1 [lindex $e1 1]
      set d1 [lindex $e1 2]
      if { $a1 < $mina } { set mina $a1 }
      if { $a1 > $maxa } { set maxa $a1 }
      if { $d1 < $mind } { set mind $d1 }
      if { $d1 > $maxd } { set maxd $d1 }
   }
   foreach e2 $ralist2 {
      set i2 [lindex $e2 0]
      set a2 [lindex $e2 1]
      set d2 [lindex $e2 2]
      if { $a2 < $mina } { set mina $a2 }
      if { $a2 > $maxa } { set maxa $a2 }
      if { $d2 < $mind } { set mind $d2 }
      if { $d2 > $maxd } { set maxd $d2 }
   }

   if {$ulog} {gren_info "fenetre $mina $maxa $mind $maxd  \n"}
   set sizea [expr - $mina + $maxa]
   set sized [expr - $mind + $maxd]
   if {$ulog} {gren_info "size : $sizea $sized  \n"}

   for {set i 0} {$i<$decoupe} {incr i} {
      for {set j 0} {$j<$decoupe} {incr j} {
         set fa0 [expr $sizea / $decoupe * $i + $mina - $delta]
         set fa1 [expr $sizea / $decoupe * ($i+1) + $mina + $delta]
         set fd0 [expr $sized / $decoupe * $j + $mind - $delta]
         set fd1 [expr $sized / $decoupe * ($j+1) + $mind + $delta]

         if {$ulog} {gren_info "fen $i,$j : $fa0 $fa1 $fd0 $fd1 \n"}

         set fen($i,$j) [list $fa0 $fa1 $fd0 $fd1]
         set arr1($i,$j) ""
         set arr2($i,$j) ""
      }
   }

   foreach e $ralist1 {
      set a [lindex $e 1]
      set d [lindex $e 2]
      for {set i 0} {$i<$decoupe} {incr i} {
         for {set j 0} {$j<$decoupe} {incr j} {
            set fa0 [lindex $fen($i,$j) 0]
            set fa1 [lindex $fen($i,$j) 1]
            set fd0 [lindex $fen($i,$j) 2]
            set fd1 [lindex $fen($i,$j) 3]
            if { $fa0 < $a && $a < $fa1 && $fd0 < $d && $d < $fd1 } {
               lappend arr1($i,$j) $e
            }
         }
      }
   }
   set sum 0
   for {set i 0} {$i<$decoupe} {incr i} {
      for {set j 0} {$j<$decoupe} {incr j} {
          if {$ulog} {gren_info "fen $i,$j : [llength $arr1($i,$j)] \n"}
          set sum [expr $sum + [llength $arr1($i,$j)]]
      }
   }
   if {$ulog} {gren_info "sum : $sum / [llength $ralist1]\n"}


   foreach e $ralist2 {
      set a [lindex $e 1]
      set d [lindex $e 2]
      for {set i 0} {$i<$decoupe} {incr i} {
         for {set j 0} {$j<$decoupe} {incr j} {
            set fa0 [lindex $fen($i,$j) 0]
            set fa1 [lindex $fen($i,$j) 1]
            set fd0 [lindex $fen($i,$j) 2]
            set fd1 [lindex $fen($i,$j) 3]
            if { $fa0 < $a && $a < $fa1 && $fd0 < $d && $d < $fd1 } {
               lappend arr2($i,$j) $e
            }
         }
      }
   }
   set sum 0
   for {set i 0} {$i<$decoupe} {incr i} {
      for {set j 0} {$j<$decoupe} {incr j} {
          if {$ulog} {gren_info "fen $i,$j : [llength $arr2($i,$j)] \n"}
          set sum [expr $sum + [llength $arr2($i,$j)]]
      }
   }
   if {$ulog} {gren_info "sum : $sum / [llength $ralist2]\n"}


   set tt2 [clock clicks -milliseconds]
   set tt [expr ($tt2 - $tt1)/1000.]
   if {$ulog} {gren_info "Decoupe duration $tt sec \n"}

# Cross-match

   set i 2
   set j 2
   set couple ""

   for {set i 0} {$i<$decoupe} {incr i} {
      for {set j 0} {$j<$decoupe} {incr j} {

         foreach e1 $arr1($i,$j) {
            set i1 [lindex $e1 0]
            set a1 [lindex $e1 1]
            set d1 [lindex $e1 2]
            set cpt2 0
            foreach e2 $arr2($i,$j) {
               set i2 [lindex $e2 0]
               set a2 [lindex $e2 1]
               set d2 [lindex $e2 2]
               #if { [expr $a1 - $delta - $a2 ] > 0 } {
               #   set arr2($i,$j) [lreplace $arr2($i,$j) $cpt2 $cpt2]
               #   continue
               #}
               if { ([expr abs($a1-$a2)] < $delta) && ([expr abs($d1-$d2)] < $delta) } {
                  lappend couple [list $i1 $i2]
               }
               incr cpt2
            }
         }
      }
   }


   if {$ulog} {gren_info "couple : [lrange $couple 0 5] \n"}
   gren_info "nb couple : [llength $couple] \n"


   set tt3 [clock clicks -milliseconds]
   set tt [expr ($tt3 - $tt2)/1000.]
   if {$ulog} {gren_info "Cross RA duration $tt sec \n"}







   set ident ""
   set llog 0
   foreach c  $couple {

      set i1 [lindex $c 0]
      set i2 [lindex $c 1]

         if {$log == 1 && $fa0l < $tabs2($i2,ra) && $tabs2($i2,ra) < $fa1l && $fd0l < $tabs2($i2,dec) && $tabs2($i2,dec) < $fd1l } {
            gren_info "** LOG : $i1   $i2\n"
            set llog 1
         } else {
            set llog 0
         }
      
         if {$tabs1($i1,accepted)==0 && $tabs2($i2,accepted)==0} {
            set accepted [get_identified \
                             $tabs1($i1,ra)           \
                             $tabs1($i1,dec)          \
                             $tabs1($i1,poserr)       \
                             $tabs1($i1,mag)          \
                             $tabs1($i1,magerr)       \
                             $tabs2($i2,ra)           \
                             $tabs2($i2,dec)          \
                             $tabs2($i2,poserr)       \
                             $tabs2($i2,mag)          \
                             $tabs2($i2,magerr)       \
                             $scoreposlimit $scoremvlimit $llog]
            #gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
            if { $accepted } {
               if {$llog} {gren_info "+"}
               lappend ident [list $i1 $i2]
               set tabs2($i2,accepted) 1
               set tabs1($i1,accepted) 1
               #gren_info "[list $tabs1($id1,id) $tabs2($id2,id)]\n"
            }

            #set a 106.253805
            #set d 4.088599
            #set eps 0.01
            #if { $tabs1($id1,ra)>[expr $a - $eps] && $tabs1($id1,ra)<[expr $a + $eps] } {
            #if { $tabs1($id1,dec)>[expr $d - $eps] && $tabs1($id1,dec)<[expr $d + $eps] } {
            #   gren_info "$accepted $id1 $id2 $tabs1($id1,ra)\n"
            #   gren_info "+++++++++++\n"
            #}
            #}
         } 
      

   }

   gren_info "nb ident : [llength $ident] \n"

   set tt2 [clock clicks -milliseconds]
   set tt [expr ($tt2 - $tt1)/1000.]
   if {$ulog} {gren_info "duration $tt sec \n"}



   # SI l objet est un OVNI, on efface son entree en tant qu OVNI puisqu il a ete identifié
   set cpt 0
   foreach i $ident {
      #gren_info "i = $i\n"
      set id1 [lindex $i 0]
      set id2 [lindex $i 1]
      set s1 [lindex $sources1 $id1]
      set news1 ""
      foreach cata $s1 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set s2 [lindex $sources2 $id2]
      foreach cata $s2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend news1 $cata
         }
      }
      set sources1 [lreplace $sources1 $id1 $id1 $news1]
      incr cpt
   }
   
   #gren_info "cpt = $cpt\n"
   if {$cpt > 0} {
      
      set nbovni [::manage_source::get_nb_sources_by_cata [list $fields1 $sources1] OVNI]
      #gren_info "nbovni = $nbovni\n"
     
      if {$nbovni == 0} {
         set newfields ""
         foreach cata $fields1 {
            if { [lindex $cata 0]!="OVNI" } {
               lappend newfields $cata
            }
         }
      } else {
         set newfields $fields1
      }
      foreach cata $fields2 {
         if { [lindex $cata 0]!="OVNI" } {
            lappend newfields $cata
         }
      }
      #gren_info "fini\n"
      set result [list $newfields $sources1]
   } else {
      set result $catalist1
   }
 
   set tt3 [clock clicks -milliseconds]
   set tt [expr ($tt3 - $tt2)/1000.]
   if {$ulog} {gren_info "duration $tt sec \n"}
   set tt [expr ($tt3 - $tt0)/1000.]
   gren_info "Total duration $tt sec \n"
 
  return $result

}


## @file bdi_gui_analysis_data.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI d'analyse des donn&eacute;es observationnelles
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_analysis_data.tcl]
#  @endcode

# $Id: bdi_gui_analysis_data.tcl 13117 2016-05-21 02:00:00Z jberthier $
   

#------------------------------------------------------------
## Charge les donnees et les affiche
# fait les 3 actions de chargement a la fois.
#  @return void
proc ::bdi_gui_analysis::data_charge_tout { } {
   ::bdi_gui_analysis::data_reset
   ::bdi_gui_analysis::data_charge_list
   ::bdi_gui_analysis::data_charge_valeur
   ::bdi_gui_analysis::ymov_allmean
   ::bdi_gui_analysis::light_time
   $::bdi_gui_analysis::fen.appli.onglets.nb select $::bdi_gui_analysis::fen.appli.onglets.nb.f_ymov
   ::bdi_gui_analysis::widget_hmm
   $::bdi_gui_analysis::fen.appli.onglets.nb select $::bdi_gui_analysis::fen.appli.onglets.nb.f_famous
}

#------------------------------------------------------------
## Charge les donnees recues de l appli reports
#  @return void
proc ::bdi_gui_analysis::data_charge_valeur { } {
   
   gren_info "DATA CHARGE VALEUR\n"
   
   set ::bdi_gui_analysis::widget(data,batch,selected) ""      
   
   set cpt 0
   set idtablelist 0
   set tabtjj ""
   set ::bdi_gui_analysis::widget(data,tabchrono) ""
   
   foreach l [$::bdi_gui_analysis::data_obs get 0 end] {

      lassign $l available firstdate iau duree fwhm mag prec nbpts expo bin batch obj type
      
      if {$available==0} {continue}

      for {set i 0} {$i < $::bdi_gui_analysis::widget(file,$batch,nbpts)} {incr i} {
         incr cpt
         set ::bdi_gui_analysis::widget(data,$cpt,tjj)   $::bdi_gui_analysis::widget(file,$batch,$i,tjj)
         set ::bdi_gui_analysis::widget(data,$cpt,raw)   $::bdi_gui_analysis::widget(file,$batch,$i,raw)
         set ::bdi_gui_analysis::widget(data,$cpt,err)   $::bdi_gui_analysis::widget(file,$batch,$i,err)
         set ::bdi_gui_analysis::widget(data,$cpt,batch) $batch
         lappend ::bdi_gui_analysis::widget(data,tabchrono) [list $cpt $::bdi_gui_analysis::widget(data,$cpt,tjj)]
      }

   }
   
   set ::bdi_gui_analysis::widget(data,nb) $cpt
   set ::bdi_gui_analysis::widget(data,tabchrono) [lsort -index 1 -real $::bdi_gui_analysis::widget(data,tabchrono)]

   gren_info "Nb de points lus : $::bdi_gui_analysis::widget(data,nb)\n"

   #::bdi_gui_analysis::compute_tab_data
   set batch ""
   set pack 0
   set opack 0
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {

      set cpt  [lindex $r 0]
      set tjj [lindex $r 1]
      set ::bdi_gui_analysis::widget(data,$cpt,tjjo) [expr $tjj - $::bdi_gui_analysis::widget(data,origin)]

      if {$::bdi_gui_analysis::widget(data,$cpt,batch) != $batch} {
         incr pack
         set batch $::bdi_gui_analysis::widget(data,$cpt,batch)
      }
      set ::bdi_gui_analysis::widget(data,$cpt,pack) $pack
   }

   # date iso
   set t1 [lindex $::bdi_gui_analysis::widget(data,tabchrono) { 0 1 }]
   set ::bdi_gui_analysis::widget(famous,ephem,isodate,first) [mc_date2iso8601 $t1]
   set t2 [lindex $::bdi_gui_analysis::widget(data,tabchrono) { end 1 }]
   set ::bdi_gui_analysis::widget(famous,ephem,isodate,end) [mc_date2iso8601 $t2]
   set t [expr ($t1 + $t2 ) / 2.0]
   set ::bdi_gui_analysis::widget(famous,ephem,isodate) [mc_date2iso8601 $t]

   # Cas ou une solution Famous existe
   if {[info exists ::bdi_gui_analysis::widget(famous,stats,typeofdata)]} {
      if {$::bdi_gui_analysis::widget(famous,stats,typeofdata)!=""} {
         foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
            set id  [lindex $r 0]
            set tjj  [lindex $r 1]
            set ::bdi_gui_analysis::widget(data,$id,sol) [::bdi_gui_famous::extrapole $tjj]
            set ::bdi_gui_analysis::widget(data,$id,res) [expr $::bdi_gui_analysis::widget(data,$id,raw) - $::bdi_gui_analysis::widget(data,$id,sol)]
         }
      }
   }
   


   # Cas ou la periode est definie, on peut faire le calcul du repli
   if {$::bdi_gui_analysis::widget(graph,repli,period)!=""} {
      ::bdi_gui_analysis::calc_repli
   } else {
      ::bdi_gui_analysis::graph
   }
   return
}









#------------------------------------------------------------
## Deplacement sur l axe des Y on se cale sur la moyenne generale
#  @return void
#
proc ::bdi_gui_analysis::ymov_allmean { } {

   # On prepare les donnees
   array unset data_pack
   set list_pack ""
   set all_raw ""
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set pck $::bdi_gui_analysis::widget(data,$id,pack)
      lappend list_pack $pck
      lappend data_pack($pck) $::bdi_gui_analysis::widget(data,$id,raw)
      lappend all_raw $::bdi_gui_analysis::widget(data,$id,raw)
   } 

   # On calcule l offset 
   set totalmean [::math::statistics::mean  $all_raw]
   gren_info "Mean total : $totalmean\n"
   set list_pack [lsort -uniq -integer $list_pack]
   gren_info "list_pack $list_pack\n"

   array unset tab_offset
   foreach pck $list_pack {
      set mean [::math::statistics::mean  $data_pack($pck)]
      set offset [expr $totalmean - $mean]
      set tab_offset($pck) $offset
      gren_info "Mean by pack ($pck) : $mean (OFFSET = $offset) -> [expr $mean + $offset]\n"
   }

   # On applique l offset au graphe courant
   set lbatch ""
   array unset tab_batch
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set pck $::bdi_gui_analysis::widget(data,$id,pack)
      set ::bdi_gui_analysis::widget(data,$id,raw) [expr $::bdi_gui_analysis::widget(data,$id,raw) + $tab_offset($pck)]
      set batch $::bdi_gui_analysis::widget(data,$id,batch)
      set tab_batch($batch) $tab_offset($pck)
      lappend lbatch $batch
   } 
   
   # On applique l offset au donnee d entree
   set lbatch [lsort -uniq $lbatch]
   foreach batch $lbatch {
      for {set i 0} {$i < $::bdi_gui_analysis::widget(file,$batch,nbpts)} {incr i} {
         set ::bdi_gui_analysis::widget(file,$batch,$i,raw) [expr   $::bdi_gui_analysis::widget(file,$batch,$i,raw) + $tab_batch($batch)]
      }
   }
   
   ::bdi_gui_analysis::graph
}



#------------------------------------------------------------
## Deplacement sur l axe des Y en se basant sur les moyennes 
#  par paquet fournit par la solution.
#  @return void
#
proc ::bdi_gui_analysis::ymov_solution { } {

   # On prepare les donnees
   array unset data_pack
   set list_pack ""
   set all_res ""
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set pck $::bdi_gui_analysis::widget(data,$id,pack)
      lappend list_pack $pck
      lappend data_pack($pck) $::bdi_gui_analysis::widget(data,$id,res)
      lappend all_res $::bdi_gui_analysis::widget(data,$id,res)
   } 

   # On calcule l offset 
   set totalmean [::math::statistics::mean  $all_res]
   gren_info "Mean total : $totalmean\n"
   set list_pack [lsort -uniq $list_pack]
   array unset tab_offset
   foreach pck $list_pack {
      set mean [::math::statistics::mean  $data_pack($pck)]
      set offset [expr - $mean]
      set tab_offset($pck) $offset
      gren_info "Mean by pack ($pck) : $mean (OFFSET = $offset)\n"
   }

   # On applique l offset  au graphe courant
   set lbatch ""
   array unset tab_batch
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set pck $::bdi_gui_analysis::widget(data,$id,pack)
      set ::bdi_gui_analysis::widget(data,$id,raw) [expr $::bdi_gui_analysis::widget(data,$id,raw) + $tab_offset($pck)]
      set batch $::bdi_gui_analysis::widget(data,$id,batch)
      set tab_batch($batch) $tab_offset($pck)
      lappend lbatch $batch
   } 

   # On applique l offset au donnee d entree
   set lbatch [lsort -uniq $lbatch]
   foreach batch $lbatch {
      for {set i 0} {$i < $::bdi_gui_analysis::widget(file,$batch,nbpts)} {incr i} {
         set ::bdi_gui_analysis::widget(file,$batch,$i,raw) [expr   $::bdi_gui_analysis::widget(file,$batch,$i,raw) + $tab_batch($batch)]
      }
   }

   ::bdi_gui_analysis::graph
   return
}



#------------------------------------------------------------
## correction du temps de lumiere
#  pour chaque observation
#  @todo sortir uiacode = 181 fixe ici
#  @return void
#
proc ::bdi_gui_analysis::light_time { } {
   
   global bddconf
   
   if {$::bdi_gui_analysis::widget(data,tempslumiere)!=0} {
      tk_messageBox -message "Temps de lumiere deja corrige" -type ok
      return
   }

   $::bdi_gui_analysis::widget(move,button,lighttime) configure -relief sunken -state disabled

   set ::bdi_gui_analysis::widget(data,tempslumiere) 1
   
   # Creation du fichier de date
   set filedat [ file join $bddconf(dirtmp) date.dat ]
   set chan0 [open $filedat w]
   foreach batch [$::bdi_gui_analysis::data_obs columncget batch -text] {
      for {set i 0} {$i < $::bdi_gui_analysis::widget(file,$batch,nbpts)} {incr i} {
         puts $chan0 $::bdi_gui_analysis::widget(file,$batch,$i,tjj)
      }
   }
   close $chan0
   
   # Lancement du calcul de temps de lumiere avec EPHEMCC
   set cmd "ephemcc aster -n $::bdi_gui_analysis::widget(data,aster,id) -j $filedat 1 -uai 181 --jd -e UTC -tc 5 --tau -s csv -r ./ -f tau.dat"
   set err [catch { eval exec $cmd } msg ]
   if {$err} {
      gren_erreur "Erreur CMD = $cmd\n"
      gren_erreur "Erreur ERR = $err\n"
      gren_erreur "Erreur MSG = $msg\n"
      return 
   }

   # Lecture du fichier tau
   array unset tab
   set file [file join $bddconf(dirtmp) "tau.dat"]
   set f [open $file "r"]
   set id 1
   while {![eof $f]} {
      set line [gets $f]
      set line [string trim $line]
      if {$line == ""} {break}
      if {[string index $line 0] == "#"} {continue}
      set line [regsub -all \[\s\] $line ,]
      set r [split [string trim $line] ","]
      set xo [lindex $r 0]
      set yo [lindex $r end]
      set tab($id) $yo
      incr id
   }

   # application des corrections
   set pass "ok"
   set id 1
   foreach batch [$::bdi_gui_analysis::data_obs columncget batch -text] {
      for {set i 0} {$i < $::bdi_gui_analysis::widget(file,$batch,nbpts)} {incr i} {
         if {![info exists tab($id)]} {
            gren_erreur "tau pour $id n existe pas\n"
            set pass "no"
            continue
         }
         set ::bdi_gui_analysis::widget(file,$batch,$i,tjj) [expr $::bdi_gui_analysis::widget(file,$batch,$i,tjj) - $tab($id)]
         incr id
      }
   }

   if {$pass == "no"} {
      tk_messageBox -message "Erreur du calcul de Temps de lumiere, voir console" -type ok
      return
   }

   gren_info "Fin du calul de temps de lumiere\n"
   ::bdi_gui_analysis::data_charge_valeur
   return








   # application des corrections
   set oldchrono $::bdi_gui_analysis::widget(data,tabchrono)

   set ::bdi_gui_analysis::widget(data,tabchrono) ""
   set tabtjj ""
   set pass "ok"
   foreach r $oldchrono {
      
      set id  [lindex $r 0]
      set tjj [lindex $r 1]
      if {![info exists tab($id)]} {
         gren_erreur "tau pour $id n existe pas\n"
         set pass "no"
         continue
      }
      set tjj [expr $tjj - $tab($id)]
      set ::bdi_gui_analysis::widget(data,$id,tjj) $tjj
      set ::bdi_gui_analysis::widget(data,$id,tjjo) [expr $tjj - $::bdi_gui_analysis::widget(data,origin)]
      set ::bdi_gui_analysis::widget(data,$id,repli) [::bdi_gui_analysis::jd_to_repli $tjj]
      lappend tabtjj $::bdi_gui_analysis::widget(data,$id,tjj)
      lappend ::bdi_gui_analysis::widget(data,tabchrono) [list $id $::bdi_gui_analysis::widget(data,$id,tjj)]

   }
   set ::bdi_gui_analysis::widget(data,origin) [::math::statistics::min $tabtjj]
   set ::bdi_gui_analysis::widget(data,tabchrono) [lsort -index 1 $::bdi_gui_analysis::widget(data,tabchrono)]

   
   if {$pass == "no"} {
      tk_messageBox -message "Erreur du calcul de Temps de lumiere, voir console" -type ok
   }

   ::bdi_gui_analysis::compute_tab_data
   ::bdi_gui_analysis::graph
   gren_info "Fin du calul de temps de lumiere\n"
   
   return

}





#------------------------------------------------------------
## Calcul toute la structure de donnees pour l axe des abscices
#  en cas de repli sur la periode
#  Date julienne 
#  @return x position sur l axe des abscices
#
proc ::bdi_gui_analysis::calc_repli { } {

   if  {$::bdi_gui_analysis::widget(graph,repli,period)==""} {return}
   gren_info "Periode = $::bdi_gui_analysis::widget(graph,repli,period)\n"
   gren_info "Abscisse : repli\n"
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set ::bdi_gui_analysis::widget(data,$id,repli) [::bdi_gui_analysis::jd_to_repli [lindex $r 1]]
   }

   ::bdi_gui_analysis::graph
   return
         
}


#------------------------------------------------------------
## Calcul de l abscice x repliee par la periode en donnant une 
#  Date julienne.
# les variables suivantes doivent etre affectees :
# set ::bdi_gui_analysis::widget(graph,repli,period)
# set ::bdi_gui_analysis::widget(data,origin)
#  @return x position sur l axe des abscices
#
proc ::bdi_gui_analysis::jd_to_repli { jd } {

   if  {$::bdi_gui_analysis::widget(graph,repli,period)==""} {return ""}
   set period [ expr $::bdi_gui_analysis::widget(graph,repli,period) / 24.0]
   set jo [expr $jd - $::bdi_gui_analysis::widget(data,origin)]
   return [expr $jo - floor($jo / $period) * $period]
   return
}



proc waveMagnitude {wave} {
 set out {}
 foreach value $wave {
    lassign $value re im
    lappend out [expr {hypot($re, $im)}]
 }
 return $out
}









# bddimages::ressource ; ::bdi_gui_analysis::hmm

proc ::bdi_gui_analysis::hmm { } {

   global bddconf 

   set minimumOfDates  1e100
   set maximumOfDates -1e100
   set kMes 0
   for {set cpt 1} {$cpt <= $::bdi_gui_analysis::widget(data,nb)} {incr cpt} {
      set dates($kMes) $::bdi_gui_analysis::widget(data,$cpt,tjj)
      set observations($kMes) $::bdi_gui_analysis::widget(data,$cpt,raw)
      if {$minimumOfDates  > $dates($kMes)} {
         set minimumOfDates $dates($kMes)
      }
      if {$maximumOfDates  < $dates($kMes)} {
         set maximumOfDates $dates($kMes)
      }
      incr kMes
   }
   set numberOfMeasurements $kMes
   set totalTimeSpan [expr $maximumOfDates - $minimumOfDates]
   gren_info "nb mes = $numberOfMeasurements == $::bdi_gui_analysis::widget(data,nb)\n"
   gren_info "minimumOfDates = $minimumOfDates [mc_date2iso8601 $minimumOfDates]\n"
   gren_info "maximumOfDates = $maximumOfDates [mc_date2iso8601 $maximumOfDates]\n"
   gren_info "totalTimeSpan  = $totalTimeSpan\n"

   set filedat [ file join $bddconf(dirtmp) photom.csv ]
   set chan0 [open $filedat w]
   puts $chan0 "id, tjj, mag, err"
   for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
      puts $chan0 "$kMes, $dates($kMes), $observations($kMes), 0.0"
   }
   close $chan0

   # On soustrait la plus petite date et on calcul la moyenne des observations
   set meanOfObservations 0.

   for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {

      set dates($kMes) [expr {$dates($kMes) - $minimumOfDates}]
      set meanOfObservations [expr {$meanOfObservations + $observations($kMes)}]
   }

   set meanOfObservations [expr {$meanOfObservations / $numberOfMeasurements}]

   # Definir les frequences balayees
   set frequencyUp    24.
   set frequencyLow   [expr {1./$totalTimeSpan}]
   set deltaFrequency [expr {0.1/$totalTimeSpan}]
   set nFrequencies   [expr {1 + int(($frequencyUp - $frequencyLow) / $deltaFrequency)}]
   gren_info "Tests $nFrequencies frequencies\n"

   set frequency  $frequencyLow;
   set pi         3.1415926535897931
   set omega      [expr {2 * $pi * $frequency}]
   set deltaOmega [expr {2 * $pi * $deltaFrequency}]

   for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
      set phase [expr {$omega * $dates($kMes)}]
      set cosPhases($kMes) [expr {cos($phase)}]
      set sinPhases($kMes) [expr {sin($phase)}]
      set phase [expr {$deltaOmega * $dates($kMes)}]
      set deltaCosPhases($kMes) [expr {cos($phase)}]
      set deltaSinPhases($kMes) [expr {sin($phase)}]
   }

   # Debut de la boucle sur les frequences
   set indexOfFrequency 1
   set bestSpectrum     -1.
   set bestFrequency    -1.

   while {$indexOfFrequency <= $nFrequencies} {
        
      # Initialise les sommes a 0.
      set coefficientC1 0.
      set coefficientS1 0.
      set coefficientCC 0.
      set coefficientSS 0.
      set coefficientCS 0.
      set coefficientCX 0.
      set coefficientSX 0.
    
      for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
        
         set cosPhase $cosPhases($kMes)
         set sinPhase $sinPhases($kMes)
         # C1
         set coefficientC1 [expr {$coefficientC1 + $cosPhase}]
         # S1
         set coefficientS1 [expr {$coefficientS1 + $sinPhase}]
         # CC
         set coefficientCC [expr {$coefficientCC + $cosPhase * $cosPhase}]
         # SS
         set coefficientSS [expr {$coefficientSS + $sinPhase * $sinPhase}]
         # CS
         set coefficientCS [expr {$coefficientCS + $cosPhase * $sinPhase}]
         # CX
         set coefficientCX [expr {$coefficientCX + $cosPhase * $observations($kMes)}]
         # SX
         set coefficientSX [expr {$coefficientSX + $sinPhase * $observations($kMes)}]
      }
    
      # C1
      set coefficientC1 [expr {$coefficientC1 / $numberOfMeasurements}]
      # S1
      set coefficientS1 [expr {$coefficientS1 / $numberOfMeasurements}]
      # CC
      set coefficientCC [expr {$coefficientCC / $numberOfMeasurements - $coefficientC1 * $coefficientC1}]
      # SS
      set coefficientSS [expr {$coefficientSS / $numberOfMeasurements - $coefficientS1 * $coefficientS1}]
      # CS
      set coefficientCS [expr {$coefficientCS / $numberOfMeasurements - $coefficientC1 * $coefficientS1}]
      # CX
      set coefficientCX [expr {$coefficientCX / $numberOfMeasurements - $coefficientC1 * $meanOfObservations}]
      # SX
      set coefficientSX [expr {$coefficientSX / $numberOfMeasurements - $coefficientS1 * $meanOfObservations}]
      # DTMS
      set DTMS          [expr {$coefficientCC * $coefficientSS - $coefficientCS * $coefficientCS}]
    
      # YC
      set coefficientYC [expr {($coefficientSS * $coefficientCX - $coefficientCS * $coefficientSX) / $DTMS}]
      # YS
      set coefficientYS [expr {($coefficientCC * $coefficientSX - $coefficientCS * $coefficientCX) / $DTMS}]
      # spectrum
      set spectrum      [expr {$coefficientYC * $coefficientCX + $coefficientYS * $coefficientSX}]
    
      for {set kMes 0} {$kMes < $numberOfMeasurements} {incr kMes} {
        
         set newCos [expr {$cosPhases($kMes) * $deltaCosPhases($kMes) - $sinPhases($kMes) * $deltaSinPhases($kMes)}]
         if {$newCos > 1.} {
            set newCos 1.
         } elseif {$newCos < -1} {
            set newCos -1
         }
        
         set newSin [expr {$sinPhases($kMes) * $deltaCosPhases($kMes) + $cosPhases($kMes) * $deltaSinPhases($kMes)}]
         if {$newSin > 1.} {
            set newSin 1.
         } elseif {$newSin < -1} {
            set newSin -1
         }

         set cosPhases($kMes) $newCos
         set sinPhases($kMes) $newSin
      }
    
      if {$bestSpectrum   < $spectrum} {
         set bestSpectrum  $spectrum
         set bestFrequency $frequency    
      }
    
      set frequency [expr $frequency + $deltaFrequency]
      incr indexOfFrequency
   }

   set ::bdi_gui_analysis::widget(graph,repli,period) [format "%0.8f" [expr 1./$bestFrequency*24.0*2.0] ]
   gren_info "Best period = $::bdi_gui_analysis::widget(graph,repli,period) heures\n"
   return
}







proc ::bdi_gui_analysis::export_1 { } {
   global bddconf 

   set filedat [ file join $bddconf(dirtmp) "photom_$::bdi_gui_analysis::widget(data,aster,id)_$::bdi_gui_analysis::widget(data,aster,name).csv" ]
   set chan0 [open $filedat w]
   puts $chan0 "id, pack, tjj, mag, err"
   set cpt 0
   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      incr cpt
      set id  [lindex $r 0]
      set tjj [lindex $r 1]
      puts $chan0 "$cpt, $::bdi_gui_analysis::widget(data,$id,pack), $tjj, $::bdi_gui_analysis::widget(data,$id,raw), $::bdi_gui_analysis::widget(data,$id,err)"
   }
   close $chan0
   
}


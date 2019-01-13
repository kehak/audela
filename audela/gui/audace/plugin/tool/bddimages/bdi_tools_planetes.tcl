namespace eval ::bdi_tools_planetes {

}


   # ::bdi_tools_planetes::get_idimg 2018-06-20T19:08:02.440
   # indexation des images / date
   # @warning il y a un probleme de modification des date-obs lorsqu on fait des transformation sur les images.
   proc ::bdi_tools_planetes::get_idimg { dateiso } {

      set jdsearch [mc_date2jd $dateiso]
      # la date doit etre inferieure a 0.01 sec
      set diff [expr 0.1 / 86400.0]

      foreach r $::bdi_gui_planetes::index_datebuf_idimg {
         lassign $r i date jd
         if {[expr abs($jd-$jdsearch)] < $diff} {
            return $i
         } else {
            # gren_info "[mc_date2iso8601 $jd] <> [mc_date2iso8601 $jdsearch] :: [expr abs($jd-$jdsearch)]\n"
         }
      }
   }





# ::thread::names

   proc ::bdi_tools_planetes::skybot_charge_webservice_thread_exist {  } {
   
      if { ! [info exists ::bdi_tools_planetes::skybot_threadName] } {return 0}
      if { $::bdi_tools_planetes::skybot_threadName == ""} {return 0}
      return [thread::exists $::bdi_tools_planetes::skybot_threadName]
   }








   proc ::bdi_tools_planetes::skybot_charge_webservice_thread_close {  } {
      if { $::bdi_tools_planetes::skybot_threadName == ""} {return}
      puts "[gren_date]  Detachement du thread :"
      set ex [thread::exists $::bdi_tools_planetes::skybot_threadName]
      puts "Thread exist ? = [thread::exists $::bdi_tools_planetes::skybot_threadName]"
      if {$ex} {
         ::thread::release $::bdi_tools_planetes::skybot_threadName
         puts "Thread release"
         set ::bdi_tools_planetes::skybot_threadName ""
      }
      
   }




   proc ::bdi_tools_planetes::skybot_charge_webservice_on_thread {  } {

      gren_info "Thread:: Demarrage"

      # Demarrage Thread
      tsv::set application dispo 0
      gren_info "Thread:: variable tsv : dispo = [tsv::get application dispo]"
      set tt0 [clock clicks -milliseconds]

      tsv::get application lobs lobs
      array set obs $lobs

      # Calcul date 1
      lassign $obs(first) dateiso ra dec jd1
      gren_info "Thread:: CMD1  = get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)"
      set stt0 [clock clicks -milliseconds]
      set err [ catch {get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)} skybot1 ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }
      set t [format "%4.1f sec" [expr ([clock clicks -milliseconds]-$stt0)/1000.0]]
      gren_info "Thread:: Duree requete SkyBot : $t"

      # Calcul date 2
      lassign $obs(last) dateiso ra dec jd2
      gren_info "Thread:: CMD2  = get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)"
      set stt0 [clock clicks -milliseconds]
      set err [ catch {get_skybot $dateiso $ra $dec $obs(radius) $obs(iau_code)} skybot2 ]
      if {$err} {
         gren_info "Erreur appel skybot \n"
         return
      }
      set t [format "%4.1f sec" [expr ([clock clicks -milliseconds]-$stt0)/1000.0]]
      gren_info "Thread:: Duree requete SkyBot : $t"

      # On recupere la liste des asteroides et leur position a la premiere date
      array unset tab
      set fields  [lindex $skybot1 0]
      set sources [lindex $skybot1 1]
      foreach s $sources { 
         set cata                [lindex $s 0]
         set aster               [::manage_source::naming $s SKYBOT]
         set cm                  [lindex $cata 1]
         set id                  [lindex $cata {2 0}]
         set name                [lindex $cata {2 1}]
         lappend tab(index,init) $aster
         set tab($aster,jd,1)    $jd1
         set tab($aster,ra,1)    [lindex $cm 0]
         set tab($aster,dec,1)   [lindex $cm 1]
         set tab($aster,poserr)  [lindex $cm 2]
         set tab($aster,mag)     [lindex $cm 3]
         set tab($aster,classe)  [lindex $cata {2 4}]
         set tab($aster,id)      [lindex $cata {2 0}]
         set tab($aster,name)    [lindex $cata {2 1}]
         set tab($aster,poserr)  [format "%0.3f" $tab($aster,poserr)]
      }
      gren_info "Thread:: Nombre d objet Skybot recuperes a la date initiale : [llength $sources]"

      # On recupere la liste des asteroides et leur position a la derniere date
      set fields  [lindex $skybot2 0]
      set sources [lindex $skybot2 1]
      foreach s $sources { 
         set cata                 [lindex $s 0]
         set aster                [::manage_source::naming $s SKYBOT]
         set cm                   [lindex $cata 1]
         set id                   [lindex $cata {2 0}]
         set name                 [lindex $cata {2 1}]
         lappend tab(index,end)   $aster
         set tab($aster,jd,end)   $jd2
         set tab($aster,ra,end)   [lindex $cm 0]
         set tab($aster,dec,end)  [lindex $cm 1]
      }
      gren_info "Thread:: Nombre d objet Skybot recuperes a la date finale : [llength $sources]"

      # Selection des objets qui sont visibles sur la premiere et derniere image
      set tab(index,visible) ""
      foreach aster $tab(index,init) {
         set pos [lsearch $tab(index,end) $aster]
         if {$pos == -1} {continue}
         lappend tab(index,visible) $aster
      }
      gren_info "Thread:: Nombre d objet visibles dans toutes les images : [llength $tab(index,visible)]"

      # Selection de tous les objets visibles sur la premiere et derniere image
      set tab(index,complete) ""
      foreach aster $tab(index,init) {
         lappend tab(index,complete) $aster
      }
      foreach aster $tab(index,end) {
         lappend tab(index,complete) $aster
      }
      set tab(index,complete) [lsort -uniq -ascii $tab(index,complete)]
      gren_info "Thread:: Nombre d objet au total : [llength $tab(index,complete)]"

      gren_info "Thread:: Interpolation des positions des asteroides  :"
      foreach dateobs $obs(index,dateobs) {
         #gren_info "Thread:: dateobs = $dateobs"
         set jdmp $obs(index,$dateobs,jdmp)
         #gren_info "Thread::    jdmp = $jdmp"
         foreach aster $tab(index,visible) {
            #gren_info "Thread::       aster = $aster"
            set ra  [expr ($jdmp - $tab($aster,jd,1)) / ( $tab($aster,jd,end) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,ra,end) - $tab($aster,ra,1) ) + $tab($aster,ra,1) ]
            set dec [expr ($jdmp - $tab($aster,jd,1)) / ( $tab($aster,jd,end) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,dec,end) - $tab($aster,dec,1) ) + $tab($aster,dec,1) ]
            set tab($aster,ra,$dateobs)  $ra
            set tab($aster,dec,$dateobs) $dec
         }
      }

      # Termine Thread
      tsv::set application ltab   [array get tab] 
      tsv::set application result 12
      tsv::set application duree  [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      tsv::set application dispo  1


      gren_info "Thread:: Fin"
      return





      # interpolation des positions des asteroides dans les images
      gren_info "interpolation des positions des asteroides visibles : \n"
      set nbi [llength $tab(index,img)]
      foreach idimg $tab(index,img) {
         # date jd du milieu de pose
         set jdmp $tab($idimg,jdmp)          
         set dateobs $tab($idimg,dateobs)
         foreach aster $tab(index,visible) {
            # on interpole les coordonnees de facon lineaire
            set ra  [expr ($jd - $tab($aster,jd,1)) / ( $tab($aster,jd,$nbi) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,ra,$nbi) - $tab($aster,ra,1) ) + $tab($aster,ra,1) ]
            set dec [expr ($jd - $tab($aster,jd,1)) / ( $tab($aster,jd,$nbi) - $tab($aster,jd,1) ) \
                         * ( $tab($aster,dec,$nbi) - $tab($aster,dec,1) ) + $tab($aster,dec,1) ]


            if {$idimg==1} {
               set tab($aster,ra,first)  $ra
               set tab($aster,dec,first) $dec
               continue
            }
            
            if {$idimg==$nbi} {
               set tab($aster,ra,last)  $ra
               set tab($aster,dec,last) $dec
               break
            }

            set tab($aster,ra,$dateobs)  $ra
            set tab($aster,dec,$dateobs) $dec
            #gren_info "interpol: $idimg => [expr $ra - $tab($aster,ra,$idimg)] [expr $dec - $tab($aster,dec,$idimg)]\n"
           
         }
         
      }



      # Termine Thread
      tsv::set application ltab    [array get tab] 
      tsv::set application result 12
      tsv::set application duree  [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
      tsv::set application dispo  1
      return "ReSuLtAt"
   }

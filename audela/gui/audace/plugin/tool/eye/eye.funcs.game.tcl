   ## recupere et affiche les coordonnees dans une carte
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @return void
   #
   proc ::eye::game_regles { } {

      return 0
   }






   ## recupere et affiche les coordonnees dans une carte
   # @pre si les donnees ne sont pas obtenues, l'affichage n'est pas modifie
   # @return void
   #
   proc ::eye::game_run { } {

      ::console::clear

      # Information
      gren_info "Bonjour ::eye::widget(game,joueur)\n"
      gren_info "La partie commence et vous etes chronometré\n"
      gren_info "Il est \n"
      gren_info "Vos options de jeu sont \n"

      # On affiche le story board
      $::eye::game_tab delete 0 end
      set ::eye::game_storyboard ""

      if {![info exists ::eye::game_t(keys)]} {
         tk_messageBox -message "Generer le scenario SVP" -type ok
         return
      } else {
         foreach key $::eye::game_t(keys) {
            set ::eye::game_t($key,pass) 0
         }
      }
      set ::eye::game_t("1",verif) 1
      ::eye::game_build_storyboard "1" "1"

      # Demarrage
      ::eye::game_go

      return 0
   }












   proc ::eye::game_step_button { type } {

      pack forget $::eye::widget(game,reponses).go
      pack forget $::eye::widget(game,reponses).ok
      pack forget $::eye::widget(game,reponses).pass
      pack forget $::eye::widget(game,reponses).echec
      pack forget $::eye::widget(game,reponses).back
      pack forget $::eye::widget(game,reponses).yes
      pack forget $::eye::widget(game,reponses).no
      switch $type {
         "go" {
            pack $::eye::widget(game,reponses).go   -side left
         }
         "yesno" {
            pack $::eye::widget(game,reponses).yes   -side left
            pack $::eye::widget(game,reponses).no   -side left
         }
         "fin" {
         }
         default {
            pack $::eye::widget(game,reponses).ok -side left
            pack $::eye::widget(game,reponses).echec  -side left
            pack $::eye::widget(game,reponses).back  -side left
         }
      }
   }



   proc ::eye::game_termine_echec { } {
      $::eye::widget(game,etape) configure -text "Appuyer sur Run"
      ::eye::game_step_button fin
      $::eye::game_tab delete [expr $::eye::game_step_cpt+1] end
      set id 2
      $::eye::game_tab insert end [list $id $::eye::game_con($id,title) "" "" $::eye::game_con($id,request) ""]


      tk_messageBox -message "Echec de la mission !\nEntrainez vous" -type ok
      return 0
   }




   proc ::eye::game_go { } {

      set ::eye::game_step_cpt 0

      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id  [lindex $l 0]
      set lab [lindex $l 1]
      set but [lindex $l 2]
      gren_info "$id : $lab ? $but\n"
      $::eye::widget(game,etape) configure -text $lab
      $::eye::game_tab selection clear 0 end
      $::eye::game_tab selection set $::eye::game_step_cpt $::eye::game_step_cpt
      ::eye::game_step_button $but
      return
   }






   proc ::eye::game_step_next { } {

      set l    [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id   [lindex $l 0]
      set lab  [lindex $l 1]
      set but  [lindex $l 2]
      set okey [lindex $l 3]

      if {$id>1} {
         gren_info "On finalise l etape $id \[$okey\]\n"
         set ::eye::game_t($okey,id)     $id
         set ::eye::game_con($id,okey)   $okey
         set ::eye::game_t($okey,fin)    [clock clicks -milliseconds]
         set ::eye::game_con($id,fin)    [get_date_sys2ut]
         set duree [format "%4.0f" [expr ($::eye::game_t($okey,fin)-$::eye::game_t($okey,debut))/1000.0]]
         set ::eye::game_t($okey,duree)  $duree
         set ::eye::game_con($id,duree)  $duree
         set ::eye::game_con($id,duree)  $duree
         
         set keypar [string range $okey 0 end-1]
         set ::eye::game_t($okey,verif) 1
         set ::eye::game_t($okey,pass)  1
         $::eye::game_tab cellconfigure $::eye::game_step_cpt,2 -text "Ok"

         gren_info "\[$okey\] - $id : verif pass\n"

         $::eye::game_tab rowconfigure $::eye::game_step_cpt -fg green
         $::eye::game_tab cellconfigure $::eye::game_step_cpt,3 -text "$::eye::game_t($okey,duree) sec"
         
      }

      gren_info "Nouvelle etape \n"
      incr ::eye::game_step_cpt
      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id  [lindex $l 0]
      set lab [lindex $l 1]
      set but [lindex $l 2]
      set key [lindex $l 3]

      gren_info "$id : $lab ? $but / \[$key\]\n"
      set ::eye::game_t($key,debut) [clock clicks -milliseconds]

      $::eye::widget(game,etape) configure -text $lab
      $::eye::game_tab selection clear 0 end
      $::eye::game_tab selection set $::eye::game_step_cpt $::eye::game_step_cpt
      $::eye::game_tab see $::eye::game_step_cpt
      ::eye::game_step_button $but


      if {[winfo exists .game_tree]} {
         ::eye::game_tree_view_all
         ::eye::game_focus_key $okey
      }

      return 0
   }









   proc ::eye::game_step_echec { } {

      gren_erreur "Echec \n"
      set res [tk_messageBox -message "Avez vous tout essayé ?" -type yesno]
      if {$res == "no"} { return }

      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id  [lindex $l 0]
      set key [lindex $l 3]

      set ::eye::game_t($key,verif) 1
      set ::eye::game_t($key,pass)  1
      set ::eye::game_t($key,fin)    [clock clicks -milliseconds]
      set ::eye::game_t($key,duree)  [format "%4.0f" [expr ($::eye::game_t($key,fin)-$::eye::game_t($key,debut))/1000.0]]

      set ekey "${key}0"

      set ::eye::game_t($ekey,pass)  1

      $::eye::game_tab rowconfigure $::eye::game_step_cpt -fg red
      $::eye::game_tab cellconfigure $::eye::game_step_cpt,2 -text "Echec"
      $::eye::game_tab selection clear 0 end

      gren_erreur "Echec $id \[$ekey\] id = $::eye::game_t($key,id) idechec = $::eye::game_con($::eye::game_t($key,id),echec)\n"

      if {[winfo exists .game_tree]} {
         ::eye::game_tree_view_all
         ::eye::game_focus_key $key
      }

      if {$::eye::game_con($::eye::game_t($key,id),echec)==2} {
         ::eye::game_termine_echec
         set ::eye::game_t($ekey,verif) 1
         if {[winfo exists .game_tree]} {
            ::eye::game_tree_view_all
            ::eye::game_focus_key $key
         }
      } else {
         set ::eye::game_t($ekey,debut) [clock clicks -milliseconds]
         $::eye::game_tab delete 0 end
         set ::eye::game_storyboard ""
         ::eye::game_build_storyboard "1" "1"
         $::eye::game_tab selection clear 0 end
         incr ::eye::game_step_cpt
         $::eye::game_tab selection set $::eye::game_step_cpt $::eye::game_step_cpt
         $::eye::game_tab see $::eye::game_step_cpt

         set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
         set id  [lindex $l 0]
         set lab [lindex $l 1]
         set but [lindex $l 2]
         $::eye::widget(game,etape) configure -text $lab
         ::eye::game_step_button $but

      }


   }







   proc ::eye::game_step_back { } {

      gren_erreur "Retour etape precedent \n"

      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set okey [lindex $l 3]
      set ::eye::game_t($okey,pass)  0



      incr ::eye::game_step_cpt -1
      set l  [lindex $::eye::game_storyboard $::eye::game_step_cpt ]
      set id  [lindex $l 0]
      set lab [lindex $l 1]
      set but [lindex $l 2]
      set key [lindex $l 3]
      gren_info "$id : $lab ? $but\n"

      # recharge le story board
      $::eye::game_tab delete 0 end
      set ::eye::game_storyboard ""
      ::eye::game_build_storyboard "1" "1"

      $::eye::widget(game,etape) configure -text $lab
      $::eye::game_tab selection clear 0 end
      $::eye::game_tab selection set $::eye::game_step_cpt $::eye::game_step_cpt
      ::eye::game_step_button $but

      $::eye::game_tab rowconfigure $::eye::game_step_cpt -fg black
      $::eye::game_tab cellconfigure $::eye::game_step_cpt,3 -text ""
      set ::eye::game_t($key,debut) [clock clicks -milliseconds]
      $::eye::game_tab see $::eye::game_step_cpt

      if {[winfo exists .game_tree]} {
         ::eye::game_tree_view_all
         ::eye::game_focus_key $key
      }

      return 0
   }




































   proc ::eye::game_build_storyboard { id key } {

      $::eye::game_tab insert end [list $id $::eye::game_con($id,title)  "" "" $::eye::game_con($id,request)]
      lappend ::eye::game_storyboard [list $id $::eye::game_con($id,title) $::eye::game_con($id,request) $key]

      set pass 0
      # OK
      if {[info exists ::eye::game_con($id,ok)]} {
         if {[string is integer -strict $::eye::game_con($id,ok)]} {
            set ide $::eye::game_con($id,ok)
            set ekey "${key}1"
            if {[info exists ::eye::game_t($ekey,pass)] && $::eye::game_t($ekey,pass)==1} {
               set pass 1
               if {$key!="1"} {
                  $::eye::game_tab cellconfigure end,2 -text "Ok"
                  $::eye::game_tab cellconfigure end,3 -text "$::eye::game_t($key,duree) sec"
                  $::eye::game_tab rowconfigure end -fg green
               }
               ::eye::game_build_storyboard $ide $ekey
            }
         }
      }

      # Echec
      if {[info exists ::eye::game_con($id,echec)]} {
         if {[string is integer -strict $::eye::game_con($id,echec)]} {
            set ide $::eye::game_con($id,echec)
            set ekey "${key}0"
            if {[info exists ::eye::game_t($ekey,pass)] && $::eye::game_t($ekey,pass)==1} {
               set pass 1
               $::eye::game_tab cellconfigure end,2 -text "Echec"
               $::eye::game_tab cellconfigure end,3 -text "$::eye::game_t($key,duree) sec"
               $::eye::game_tab rowconfigure end -fg red
               ::eye::game_build_storyboard $ide $ekey
            }
         }
      }

      if {$pass == 0} {
         if {[info exists ::eye::game_con($id,ok)]} {
            if {[string is integer -strict $::eye::game_con($id,ok)]} {
               set ide $::eye::game_con($id,ok)
               set ekey "${key}1"
               ::eye::game_build_storyboard $ide $ekey
            }
         }
      }
   }













   proc ::eye::game_build_t { id key rep level} {

      # level
      incr level
      if {$level > $::eye::game_level } {
         set ::eye::game_level $level
      }

      # tableau game_tab_level
      lappend ::eye::game_t(keys) $key

      if {![info exists ::eye::game_tab_level($level)]} {
         set ::eye::game_tab_level($level) $key
      } else {
         lappend ::eye::game_tab_level($level) $key
      }
      set ::eye::game_t($key,id) $id
      if {$rep == "ok"} {
         set ::eye::game_t($key,color) "green"
      } else {
         set ::eye::game_t($key,color) "red"
      }
      #gren_info "$level : $key : $id \n"

      # OK
      if {[info exists ::eye::game_con($id,ok)]} {
         if {[string is integer -strict $::eye::game_con($id,ok)]} {
            set ide $::eye::game_con($id,ok)
            set ekey "${key}1"
            ::eye::game_build_t $ide $ekey "ok" $level
         }
      }

      # Echec
      if {[info exists ::eye::game_con($id,echec)]} {
         if {[string is integer -strict $::eye::game_con($id,echec)]} {
            set ide $::eye::game_con($id,echec)
            set ekey "${key}0"
            ::eye::game_build_t $ide $ekey "echec" $level
         }
      }

   }






   proc ::eye::game_build_coord { } {

      #gren_info "levelmax = $::eye::game_level\n"
      set xbox 50
      set ybox 50

      set xunit 70
      set yunit 70

      set xorig 50
      set roval 20

      set nbmax 0
      set levelmax 0
      for {set i 2} {$i<=$::eye::game_level} {incr i} {
         set nb [llength $::eye::game_tab_level($i)]
         #gren_info "level $i : nb = $nb\n"
         if {$nb > $nbmax} {
            set nbmax $nb
            set levelmax $i
         }
      }
      set midpos [expr $nbmax/2]
      #gren_info "nbmax = $nbmax au niveau $levelmax (mid = $midpos)\n"

      for {set i 2} {$i<=$::eye::game_level} {incr i} {
         set nb   [llength $::eye::game_tab_level($i)]

         set segm [expr $nbmax/$nb]
         set keys [lsort -decreasing $::eye::game_tab_level($i)]
         set pos  [expr $midpos - $nb/2 ]
         set off  [expr ($nb+1)%2*$xunit/2]

         #gren_info "i $i nb $nb segm $segm\n"
         foreach key $keys {
            incr pos
            set x [expr $pos * $xunit + $off]
            #gren_info "$i,$key : $x\n"
            set ::eye::game_t($key,x) $x
            set ::eye::game_t($key,y) [expr $i * $yunit]
         }
      }


      for {set i 2} {$i<=$::eye::game_level} {incr i} {

         set keys [lsort -decreasing $::eye::game_tab_level($i)]
         foreach key $keys {

            set verif 0
            if {[info exists ::eye::game_t($key,verif)]} {
               if {$::eye::game_t($key,verif)==1} {
                  set verif 1
                  $::eye::game_can create oval [expr $::eye::game_t($key,x) - $roval] [expr $::eye::game_t($key,y) - $roval]  \
                              [expr $::eye::game_t($key,x) + $roval] [expr $::eye::game_t($key,y) + $roval] -tags $key \
                              -fill $::eye::game_t($key,color) -width 2

                  $::eye::game_can create text $::eye::game_t($key,x) $::eye::game_t($key,y) \
                             -text "$::eye::game_t($key,id)" -tags $key -justify left \
                             -fill white -width $xbox

               }

            }
            if {$verif ==0} {

               $::eye::game_can create text $::eye::game_t($key,x) $::eye::game_t($key,y) \
                          -text "$::eye::game_t($key,id)" -tags $key -justify left -fill $::eye::game_t($key,color) -width $xbox

               $::eye::game_can create oval [expr $::eye::game_t($key,x) - $roval] [expr $::eye::game_t($key,y) - $roval]  \
                           [expr $::eye::game_t($key,x) + $roval] [expr $::eye::game_t($key,y) + $roval] -tags $key

            }



            set keypar [string range $key 0 end-1]

            if {[info exists ::eye::game_t($keypar,x)]} {
               set x1 [expr $::eye::game_t($keypar,x) + 0]
               set y1 [expr $::eye::game_t($keypar,y) + $roval]
               set x2 [expr $::eye::game_t($key,x) + 0]
               set y2 [expr $::eye::game_t($key,y) - $roval]
               $::eye::game_can create line $x1 $y1 $x2 $y2
            }

         }

      }

      $::eye::game_can  delete -tag "border"
      set ::eye::game_can_height [expr ($::eye::game_level + 2 ) * $yunit]
      set ::eye::game_can_width  [expr ($nbmax + 2 ) * $xunit]
      $::eye::game_can create line 0 0 0 $::eye::game_can_height -fill grey -tag "border"
      $::eye::game_can create line 0 0 $::eye::game_can_width 0  -fill grey -tag "border"
      $::eye::game_can configure -scrollregion [$::eye::game_can bbox all]

   }






   proc ::eye::game_lecture_arbre { } {

      ::eye::game_build_coord

      if {$::eye::widget(tree,pdf)} {
         # Cloture et ecriture du pdf
         ::mypdf startPage -paper a4
         ::mypdf canvas $::eye::game_can -x 5 -y 5 -width 1500 -height 730
         ::mypdf finish
         ::mypdf write -file $::eye::game_pdf_filename
         ::mypdf destroy
         catch { exec $::conf(editnotice_pdf) $::eye::game_pdf_filename & } msg
      }

      return
   }





   proc ::eye::game_create_tree {  } {

      ::eye::game_scenario

      if {$::eye::widget(tree,pdf)} {::eye::game_pdf_creation}

      set ide 1
      set xe 150
      set ye 50
      set ::eye::game_level 1
      array unset ::eye::game_t
      array unset ::eye::game_tab_level

      ::eye::game_build_t $ide "1" "ok" 1
   }






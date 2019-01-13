#
## @file iris.tcl
#  @brief Ce script permet d'exécuter des commandes Iris depuis un script tcl
#  @note Documentation : @ref audela_iris dans le dossier "\doc_html\french\02programmation"
#  pour les fonctions iris_initlinux, iris, iris2_select, iris2_compute_trichro1
#  @author Benoit MAUGIS
#  @note Les fonctions iris_launch, iris_terminal, iris_put, iris_read fonctionnent pour Windows
#   uniquement. iris_put permet de démarrer, d'ouvrir la fenêtre des commandes et d'envoyer
#   une commande à Iris. iris_read permet d'importer la dernière erreur retournée dans Iris.
#  @author Alain KLOTZ
#  @pre Initialiser la variable conf(exec_iris) avec le chemin complet de iris.exe.
#  @code source $audace(rep_install)/gui/audace/iris.tcl
#  Exemple : iris_put "load" ; after 100 ; iris_read
#  @endcode
#  $Id: iris.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#

proc iris_initlinux { } {
   global audace

   set fileId [ open [ file join $audace(rep_install) bin scriptis_init.tcl ] w ]
   puts -nonewline $fileId ">"
   close $fileId

   catch { exec wine scriptis.exe scriptis_init.tcl }

   file delete [ file join $audace(rep_install) bin scriptis_init.tcl ]
}

## @brief fait exécuter à Iris la commande "commande_Iris".
proc iris { {commande} {arg1 ""} {arg2 ""} {arg3 ""} {arg4 ""} {arg5 ""} {arg6 ""} {arg7 ""} {arg8 ""} {arg9 ""} {arg10 ""} {arg11 ""} {arg12 ""} {arg13 ""} {arg14 ""} {arg15 ""} } {
   global audace

   #--- Cas particuliers
   switch $commande {
      "bestof" {
         if {[file exist [file join $audace(rep_images) select.lst]]=="1"} {
            file delete [file join $audace(rep_images) select.lst]
         }
      }
      "pregister" {
         if {[file exist [file join $audace(rep_images) $arg2${arg4}.fit]]=="1"} {
            file delete [file join $audace(rep_images) $arg2${arg4}.fit]
         }
      }
      "file_trans" {
         if {[file exist [file join $audace(rep_images) $arg2${arg3}.fit]]=="1"} {
            file delete [file join $audace(rep_images) $arg2${arg3}.fit]
         }
      }
   }

   set vieuxrep [pwd]
   cd [ file join $audace(rep_install) bin ]
   set fileId [ open [ file join $audace(rep_install) bin scriptis.tcl ] w ]

   switch -regexp $::tcl_platform(os) {
      "Linux" {
         iris_initlinux
         set line ""
      }
      "Windows" {
         set line ""
      }
   }

   append line $commande " " $arg1 " " $arg2 " " $arg3 " " $arg4 " " $arg5 " " $arg6 " " $arg7 " " $arg8 " " $arg9 " " $arg10 " " $arg11 " " $arg12 " " $arg13 " " $arg14 " " $arg15

   #--- Suppression des blancs à la fin
   set nb_blocs [llength $line]
   set mine [lrange $line 0 [expr $nb_blocs-1]]

   puts -nonewline $fileId $mine

   switch -regexp $::tcl_platform(os) {
      "Linux" {
      }
      "Windows" {
         puts $fileId ""
      }
   }

   close $fileId
   switch -regexp $::tcl_platform(os) {
      "Linux" {
         catch {exec wine scriptis.exe scriptis.tcl}
      }
      "Windows" {
         exec scriptis.exe scriptis.tcl
      }
   }

   #--- Cas particuliers
   switch $commande {
      "bestof" {
         while {[file exist [file join $audace(rep_images) select.lst]]=="0"} {
            after 100
         }
      }
      "pregister" {
         while {[file exist [file join $audace(rep_images) $arg2${arg4}.fit]]=="0"} {
            after 100
         }
      }
      "file_trans" {
         while {[file exist [file join $audace(rep_images) $arg2${arg3}.fit]]=="0"} {
            after 100
         }
      }
   }

   cd $vieuxrep
   file delete [ file join $audace(rep_install) bin scriptis.tcl ]
   return ""
}

## @brief permet, après un bestof, de ne copier que le nombre d'images choisi et pas toute la série.
proc iris2_select { {nom_ini} {nom_final} {nombre} } {
   global audace

   #--- Suppression préalable si la série de destination est déjà existante
   suppr_serie $nom_final -ext .fit
   set nom_rep [file join $audace(rep_images) select.lst]
   set fileId [open $nom_rep r]
   for {set k 1} {$k<=$nombre} {incr k} {
      gets $fileId ind
      file copy [file join $audace(rep_images) $nom_ini$ind.fit] [file join $audace(rep_images) $nom_final$k.fit]
   }
   close $fileId
}

## @brief fonction améliorée que celle du même nom sous iris
proc iris2_compute_trichro1 { {maitre} {r} {v} {b} {taille} {nb_select} {nb_total} } {
   global audace caption conf

   #--- Création du sous-répertoire de traitement
   console::affiche_resultat $caption(iris,subdir)
   set subdir [cree_sousrep -nom_base "iris2_compute_trichro1"]
   console::affiche_resultat ${subdir}\n
   #--- Normalisation de l'offset de la séquence maître
   console::affiche_resultat $caption(iris,normoffset_maitre)
   noffset2 $maitre "tmp_maitre_" "0" $nb_total
   #--- Réhaussement du contraste de la séquence maître par masque flou
   console::affiche_resultat $caption(iris,mf)
   iris "unsharp2" "tmp_maitre_" "tmp_unsharp_" "3" "6" "0" $nb_total
   #--- Bestof sur la séquence maître de contraste réhaussé
   console::affiche_resultat $caption(iris,bestof)
   iris "bestof" "tmp_unsharp_" $nb_total
   #--- Suppression de la séquence maître de contraste réhaussé
   suppr_serie "tmp_unsharp_"
   #--- On ne garde que les meilleures images de la séquence maître
   suppr_serie "tmp_maitre2_"
   iris2_select "tmp_maitre_" "tmp_maitre2_" $nb_select
   #--- Suppression des images non triées
   suppr_serie "tmp_maitre_"
   #--- Chargement de la première image maître dans Iris pour sélectionner le centre de la planète
   console::affiche_resultat $caption(iris,selectmsg)
   iris "load" "tmp_maitre2_1"
   #--- NB : On ajuste les seuils pour bien la voir
   set num_buf_tmp [buf::create]
   buf$num_buf_tmp extension $conf(extension,defaut)
   buf$num_buf_tmp load [file join $audace(rep_images) tmp_maitre2_1$conf(extension,defaut)]
   set stats [buf$num_buf_tmp stat]
   buf::delete $num_buf_tmp
   iris "visu" [lrange $stats 0 1]
   tk_messageBox -type ok -message $caption(iris,select)
   #--- Registration des images maîtres triées
   console::affiche_resultat $caption(iris,registr_maitre)
   iris "pregister" "tmp_maitre2_" "tmp_maitre3_" $taille $nb_select
   #--- Addition de ces images
   sadd "tmp_maitre3_" "tmp_maitre" $nb_select
   #--- Suppression des fichiers maîtres temporaires
   suppr_serie "tmp_maitre2_"
   #--- Traitement des images rouges
   console::affiche_resultat $caption(iris,ima_r)
   if {$maitre==$r} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $subdir r$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_r_"
      iris2_select $r "tmp_r_" $nb_select
      noffset2 "tmp_r_" "tmp_r_" "0" $nb_select
      iris "file_trans" "tmp_r_" "tmp_r2_" $nb_select
      suppr_serie "tmp_r_"
      sadd "tmp_r2_" "tmp_r" $nb_select
      suppr_serie "tmp_r2_"
      file rename [file join $audace(rep_images) tmp_r$conf(extension,defaut)] [file join $subdir r$conf(extension,defaut)]
   }
   #--- Traitement des images vertes
   console::affiche_resultat $caption(iris,ima_v)
   if {$maitre==$v} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $subdir v$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_v_"
      iris2_select $v "tmp_v_" $nb_select
      noffset2 "tmp_v_" "tmp_v_" "0" $nb_select
      iris "file_trans" "tmp_v_" "tmp_v2_" $nb_select
      suppr_serie "tmp_v_"
      sadd "tmp_v2_" "tmp_v" $nb_select
      suppr_serie "tmp_v2_"
      file rename [file join $audace(rep_images) tmp_v$conf(extension,defaut)] [file join $subdir v$conf(extension,defaut)]
   }
   #--- Traitement des images bleues
   console::affiche_resultat $caption(iris,ima_b)
   if {$maitre==$b} {
      file rename [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)] [file join $audace(rep_images) b$conf(extension,defaut)]
   } else {
      suppr_serie "tmp_b_"
      iris2_select $b "tmp_b_" $nb_select
      noffset2 "tmp_b_" "tmp_b_" "0" $nb_select
      iris "file_trans" "tmp_b_" "tmp_b2_" $nb_select
      suppr_serie "tmp_b_"
      sadd "tmp_b2_" "tmp_b" $nb_select
      suppr_serie "tmp_b2_"
      file rename [file join $audace(rep_images) tmp_b$conf(extension,defaut)] [file join $subdir b$conf(extension,defaut)]
   }
   #--- Suppression, si ce n'est déjà fait, du dernier fichier maître temporaire
   if {[file exist [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)]]=="1"} {
      file delete [file join $audace(rep_images) tmp_maitre$conf(extension,defaut)]
   }
   #--- Inscription dans un fichier texte des caractéristiques du traitement
   set fileId [open [file join $subdir iris2_compute_trichro1.txt] w]
   puts $fileId $caption(iris,nom_maitre)$maitre
   puts $fileId $caption(iris,nom_rouge)$r
   puts $fileId $caption(iris,nom_vert)$v
   puts $fileId $caption(iris,nom_bleu)$b
   puts $fileId $caption(iris,taille_pregistr)$taille
   puts $fileId $caption(iris,nb_tot)$nb_total
   puts $fileId $caption(iris,nb_select)$nb_select
   close $fileId
}

proc iris_launch { } {
   global conf

   set iris_exe "$conf(exec_iris)"
   package require twapi
   set pids [twapi::get_process_ids]
   set ever_launched 0
   foreach pid $pids {
      set res [twapi::get_process_info $pid -name]
      set name [lindex $res 1]
      if {$name=="iris.exe"} {
         set ever_launched 1
         break
      }
   }
   if {$ever_launched==0} {
      set err [catch {
         twapi::create_process ${iris_exe} -startdir [file dirname $iris_exe] -detached 1 -showwindow normal
      } msg]
      if {$err==1} {
         error "Cannot find IRIS executable as the file ${iris_exe}. $msg"
      }
   }
   for {set k 0} {$k<=20} {incr k} {
      after 500
      set err [catch {iris_terminal} hwin]
      if {$err==0} {
         break
      }
   }
   if {$err==1} {
      error $hwin
   }
   return $hwin
}

proc iris_terminal { } {
   set pids [twapi::get_process_ids]
   foreach pid $pids {
      set res [twapi::get_process_info $pid -name]
      set name [lindex $res 1]
      if {$name=="iris.exe"} {
         break
      }
   }
   set hwins [twapi::get_toplevel_windows -pid $pid]
   #console::affiche_resultat "PID=$pid\n"
   foreach hwin $hwins {
      set res1 [twapi::get_window_application $hwin]
      set res2 [twapi::get_window_class $hwin]
      set res3 [twapi::get_window_client_area_size $hwin]
      #console::affiche_resultat "===== $hwin $res1 $res2 $res3\n"
      if {[string range $res2 0 2]=="Afx"} {
         break
      }
   }
   #console::affiche_resultat "HWIN 1=$hwin\n"
   set hwinw $hwin
   set hwins [twapi::get_descendent_windows $hwinw]
   foreach hwin $hwins {
      set res1 $hwin
      set res2 [twapi::get_window_class $hwin]
      set res4 [twapi::get_window_coordinates $hwin]
      set res5 [twapi::get_window_style $hwin]
      set res6 [twapi::get_window_text $hwin]
      set res7 [twapi::get_window_userdata $hwin]
      lassign $res4 x1 y1 x2 y2
      #console::affiche_resultat "==> $res2 : $res4 : $res6 ($res7)\n"
      if {($res2=="ToolbarWindow32")} {
         #console::affiche_resultat "$res1 : $res2 : $res4\n"
         #console::affiche_resultat "get_window_style $res5\n"
         #console::affiche_resultat "get_window_text $res6\n"
         twapi::set_focus $hwin
         twapi::set_foreground_window $hwin
         set xpos [expr ($x1+$x2)/2]
         set ypos [expr ($y1+$y2)/2]
         set xpos [expr $x1+278] ; # position de l'icone
         twapi::move_mouse $xpos $ypos
         twapi::set_focus $hwin
         twapi::set_foreground_window $hwin
         twapi::click_mouse_button left
         after 50
         break
      }
   }
   #console::affiche_resultat "HWIN 2=$hwin\n"
   set res ""
   set hwins [twapi::get_toplevel_windows -pid $pid]
   #console::affiche_resultat "hwins=$hwins\n"
   foreach hwin $hwins {
      set res1 [twapi::get_window_application $hwin]
      set res2 [twapi::get_window_class $hwin]
      set res3 [twapi::get_window_client_area_size $hwin]
      set hwin2s [twapi::get_descendent_windows $hwin]
      #console::affiche_resultat "=3= $res1 $res2 $res3 :: $hwin2s\n"
      if {($res2=="#32770")&&([llength $hwin2s]==1)} {
         set res22 [twapi::get_window_class $hwin2s]
         if {($res22=="ListBox")||($res22=="Edit")} {
            set res $hwin2s
            break
         }
      }
   }
   #console::affiche_resultat "Handler of Iris terminal = $res\n"
   return $res
}

proc iris_put { msg {clear 1} } {
   set hwin2s [iris_launch]
   set hwin2 [lindex $hwin2s 0]
   twapi::set_focus $hwin2
   twapi::set_foreground_window $hwin2
   if {$clear==1} {
      twapi::send_input_text "\n"
      after 50
   }
   twapi::send_input_text "$msg"
   twapi::send_keys ~
   return ""
}

proc iris_read { } {
   set hwin2s [iris_launch]
   set hwinw [lindex $hwin2s 0]
   twapi::set_focus $hwinw
   twapi::set_foreground_window $hwinw
   set res4 [twapi::get_window_coordinates $hwinw]
   lassign $res4 x1 y1 x2 y2
   #console::affiche_resultat "$res4\n"
   set xpos [expr ($x1+$x2)/2]
   set ypos [expr ($y1+$y2)/2]
   set xpos [expr $x1+5]
   set ypos [expr $y2-10]
   twapi::move_mouse $xpos $ypos
   twapi::set_focus $hwinw
   twapi::set_foreground_window $hwinw
   twapi::click_mouse_button left
   twapi::send_keys +({UP}{UP})
   after 100
   twapi::send_keys ^c
   after 100
   set lignes [clipboard get]
   set lignes [split $lignes \n]
   #console::affiche_resultat "<< $lignes >>\n"
   set ligne [lindex $lignes end-1]
   set car [string index $ligne 0]
   if {$car==">"} {
      set ligne ""
   }
   return $ligne
}

proc iris_exit { } {
   package require twapi
   set pids [twapi::get_process_ids]
   set ever_launched 0
   foreach pid $pids {
      set res [twapi::get_process_info $pid -name]
      set name [lindex $res 1]
      if {$name=="iris.exe"} {
         twapi::end_process $pid -force
      }
   }
}

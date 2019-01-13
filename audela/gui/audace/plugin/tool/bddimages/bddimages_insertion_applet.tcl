## @file bddimages_insertion_applet.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; l'insertion des images dans la base de donn&eacute;es (no namespace)
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_insertion_applet.tcl]
#  @endcode

# $Id: bddimages_insertion_applet.tcl 14533 2018-11-13 17:00:23Z fredvachier $

#--------------------------------------------------
#  lecture_info { This }
#--------------------------------------------------
#
#    fonction  :
#       Obtention de la liste des champs du
#       header pour les images de la liste
#
#    procedure externe :
#
#    variables en entree :
#       this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc lecture_info { This } {

   global conf
   global bddconf
   global caption
   global entetelog

   set listeentiere [ $::bddimages_insertion::This.frame7.tbl get 0 end ]
   set nbimg [ llength $listeentiere ]

   set nbimgins 0
   set nbimgerr 0

   set bddconf(listetotale) {}
   if { $nbimg != "0" } {
      for { set i 0 } { $i <= [ expr $nbimg - 1 ] } { incr i } {

         set ligne     [lindex $listeentiere $i]
         set nomfich   [lindex $ligne 1]

         set result    [info_fichier $nomfich]
         set erreur    [lindex $result 0]
         set etat      [lindex $result 1]
         set nomfich   [lindex $result 2]
         set dateiso   [lindex $result 3]
         set site      [lindex $result 4]
         set sizefich  [lindex $result 5]
         set tabkey    [lindex $result 6]
         
         set fic       [file tail $nomfich]
         set entetelog $fic

         if {$erreur != 0} {
            incr nbimgerr
            set dirpb "$bddconf(direrr)"
            createdir_ifnot_exist $dirpb
            set dirpb "$bddconf(direrr)/err$erreur"
            createdir_ifnot_exist $dirpb
            bddimages_sauve_fich "lecture_info: Deplacement du fichier $nomfich dans $dirpb"
            set errnum [catch {file rename $nomfich $dirpb/} msg]

            set errcp [string first "file already exists" $msg]
            if {$errcp>0||$errnum==0} {
               set errnum [catch {file delete $nomfich} msg]
               if {$errnum!=0} {
                  bddimages_sauve_fich "lecture_info: ERREUR 111 : effacement de $nomfich impossible <err=$errnum> <msg=$msg>"
                  return 111
               } else {
                  bddimages_sauve_fich "lecture_info: Fichier $nomfich supprime"
               }
            }
            set erreur "Erreur <$erreur> : $caption(bddimages_insertion,err$erreur)"
         }
         set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur]
         $::bddimages_insertion::This.frame7.tbl delete $i
         $::bddimages_insertion::This.frame7.tbl insert $i $ligne
         # Modifie l affichage de nbimg nbimgins nbimgerr
         set bddconf(inserinfo) "Total($nbimg) Inser($nbimgins) Err($nbimgerr)"
         lappend bddconf(listetotale) [list "!" $nomfich $dateiso $site $sizefich $erreur $tabkey]
         update
      }
   }

   set bddconf(nbimg)    $nbimg
   set bddconf(nbimgins) $nbimgins
   set bddconf(nbimgerr) $nbimgerr
   return
}





#--------------------------------------------------
#  insertion { This }
#--------------------------------------------------
#
#    fonction  :
#       Insertion des images en 3 modes :
#         - selection d images
#         - tout inserer
#         - insertion automatique attente d images
#             dans le repertoire incoming
#
#    procedure externe :
#
#    variables en entree :
#       this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc insertion { This } {

   global conf
   global bddconf
   global caption
   global audace

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""

   ::bddimages_insertion::fermer_to_stop
   set ::bddimages_insertion::askstop 0
   set ::bddimages_insertion::stop_insertion 0

   # Mode d insertion automatique
   if {$bddconf(inserauto) == 1} {
      insertion_auto
      gren_info "INSERTION FINI\n"
      set ::bddimages_insertion::stop_insertion 1
      return
   }

   # Autre Mode d insertion
   gren_info "Insertion ... \n"

   # Verifie que des fichiers a inserer ont ete selectionnes
   if { ! [ info exists bddconf(listetotale) ] } {
      tk_messageBox -message "$caption(bddimages_insertion,nofileselected)" -type ok
      set ::bddimages_insertion::stop_insertion 1
      return
   }

   # Insertion des fichiers selectionnes
   for { set i 0 } { $i <= [ expr [llength $bddconf(listetotale)] - 1 ] } { incr i } {

      set selectfich [$::bddimages_insertion::This.frame7.tbl selection includes $i]
      if {$selectfich == 1} {

         set nomfich [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 1]
         set etat    [lindex [$::bddimages_insertion::This.frame7.tbl get $i] 0]
         switch $etat {
           "?" { }
           "X" { }
           "0" { }
           "!" {
              foreach ligne $bddconf(listetotale) {
                 set nomfichinfo [lindex $ligne 1]
                 if {$nomfichinfo==$nomfich} {
                    set etat      [lindex $ligne 0]
                    set dateobs   [lindex $ligne 2]
                    set site      [lindex $ligne 3]
                    set sizefich  [lindex $ligne 4]
                    set liste     [bddimages_insertion_unfich $ligne]
                    set err       [lindex $liste 0]
                    set nomfich   [lindex $liste 1]
                    if {$err == -1} {
                       break
                    } elseif {$err == 0} {
                       incr bddconf(nbimgins)
                       set etat "O"
                       set err "$caption(bddimages_insertion,err$err)"
                    } else {
                       incr bddconf(nbimgerr)
                       set etat "X"
                       set err "Erreur <$err> : $caption(bddimages_insertion,err$err)"
                    }
                    set ligne [list $etat $nomfich $dateobs $site $sizefich $err]
                    $::bddimages_insertion::This.frame7.tbl delete $i
                    $::bddimages_insertion::This.frame7.tbl insert $i $ligne
                    # Modifie l affichage de nbimg nbimgins nbimgerr
                    set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
                 }
                 update
              }
           }
           default { }
         }

       }
     }

      set ::bddimages_insertion::stop_insertion 1
      return
   }

#--------------------------------------------------
#  insertion_auto {  }
#--------------------------------------------------
#
#    fonction  :
#       Insertion des images en mode automatique :
#       attente d images dans le repertoire incoming
#
#    procedure externe :
#
#    variables en entree :
#       this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc insertion_auto { } {

   global conf
   global bddconf
   global caption
   global entetelog

   set nbimg             0
   set nbimgins          0
   set nbimgerr          0
   set bddconf(nbimg)    0
   set bddconf(nbimgerr) 0
   set bddconf(nbimgins) 0

   gren_info "Insertion Automatique \n"

   set fichlock "$bddconf(dirinco)/lock"

   while { 0 < 1 } {
      
      if {[file exists $fichlock] == 1} {

         update
         after 60000

      } else {

         set bddconf(liste) {}

         init_info
         set listetitre [lindex $bddconf(liste) 0]
         set listeval [lindex $bddconf(liste) 1]
         set listeval [lrange $listeval 0 999]
         set bddconf(liste) [list $listetitre $listeval]

         catch {
            ::bddimages_insertion::getFormatColumn
            $::bddimages_insertion::This.frame7.tbl delete 0 end
            $::bddimages_insertion::This.frame7.tbl deletecolumns 0 end
         }

         ::bddimages_insertion::Affiche_Results

         set nbcol        [ $::bddimages_insertion::This.frame7.tbl columncount ]
         set listeentiere [ $::bddimages_insertion::This.frame7.tbl get 0 end ]
         set nbimg        [ llength $listeentiere ]

         if {$nbimg == 0} {
            update
            after 10000
         }

        set bddconf(listetotale) {}

        if { $nbimg != "0" } {

           set bddconf(nbimg) [expr $bddconf(nbimg) + $nbimg]

           for { set i 0 } { $i <= [ expr $nbimg - 1 ] } { incr i } {

              if {[file exists $fichlock]==1} {break}

              set ligne     [lindex $listeentiere $i]
              set nomfich   [lindex $ligne 1]
              set result    [info_fichier $nomfich]
              set erreur    [lindex $result 0]
              set etat      [lindex $result 1]
              set nomfich   [lindex $result 2]
              set dateiso   [lindex $result 3]
              set site      [lindex $result 4]
              set sizefich  [lindex $result 5]
              set tabkey    [lindex $result 6]

              set fic [file tail $nomfich]
              set entetelog $fic

              bddimages_sauve_fich "insertion_auto:Debute"

              set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur $tabkey]
              $::bddimages_insertion::This.frame7.tbl delete $i
              $::bddimages_insertion::This.frame7.tbl insert $i $ligne

              if {$erreur != 0} {
                 incr bddconf(nbimgerr)
                 set dirpb "$bddconf(direrr)"
                 createdir_ifnot_exist $dirpb
                 set dirpb "$bddconf(direrr)/err$erreur"
                 createdir_ifnot_exist $dirpb
                 bddimages_sauve_fich "insertion_auto: Deplacement du fichier $nomfich dans $dirpb"
                 set errnum [catch {file rename $nomfich $dirpb/} msg]
                 set errcp [string first "file already exists" $msg]
                 if {$errcp>0||$errnum==0} {
                    set errnum [catch {file delete $nomfich} msg]
                    if {$errnum!=0} {
                       bddimages_sauve_fich "insertion_auto: ERREUR 111 : effacement de $nomfich impossible <err=$errnum> <msg=$msg>"
                       return 111
                    } else {
                       bddimages_sauve_fich "insertion_auto: Fichier $nomfich supprime"
                    }
                 }
                 set erreur "Erreur <$erreur> : $caption(bddimages_insertion,err$erreur)"
              }
              set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur $tabkey]
              $::bddimages_insertion::This.frame7.tbl delete $i
              $::bddimages_insertion::This.frame7.tbl insert $i $ligne
              # Modifie l affichage de nbimg nbimgins nbimgerr
              set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
#              lappend bddconf(listetotale) [list "!" $nomfich $dateiso $site $sizefich $erreur $tabkey]

              if {$erreur == 0} {

                 # Ici se fait l'Insertion de l image
                 set liste     [bddimages_insertion_unfich $ligne]
                 set err       [lindex $liste 0]
                 set nomfich   [lindex $liste 1]
                 if {$err == -1} {
                    break
                 }
                 if {$err == 0} {
                    incr bddconf(nbimgins)
                    set etat "O"
                    set err "$caption(bddimages_insertion,err$err)"
                 } else {
                    incr bddconf(nbimgerr)
                    set etat "X"
                    set err "Erreur <$err> : $caption(bddimages_insertion,err$err)"
                 }
                 set ligne [list $etat $nomfich $dateiso $site $sizefich $err]
                 $::bddimages_insertion::This.frame7.tbl delete $i
                 $::bddimages_insertion::This.frame7.tbl insert $i $ligne
                 # Modifie l affichage de nbimg nbimgins nbimgerr
                 set bddconf(inserinfo) "Total($bddconf(nbimg)) Inser($bddconf(nbimgins)) Err($bddconf(nbimgerr))"
              }
              # Fin: if {$erreur==0}
              update
              if {$::bddimages_insertion::askstop == 1} {
                 gren_info "INSERTION AUTO FINI\n"
                 set ::bddimages_insertion::stop_insertion 1
                 return
              }
           }
           # Fin: boucle for
        }
        # Fin: if { $nbimg != "0" }

      }
      #if file exists $fichlock
   }
   # Fin: while
}
# Fin: proc



proc insertion_solo { nomfich } {

   global conf
   global bddconf
   global caption
   global entetelog

   set fichlock "$bddconf(dirinco)/lock"
   if {[file exists $fichlock]==1} {
      gren_info "Insertion Solo : BDI locked : inserez plus tard \n"
      return -code 1
   }

   set result    [info_fichier $nomfich]
   set erreur    [lindex $result 0]
   set etat      [lindex $result 1]
   set nomfich   [lindex $result 2]
   set dateiso   [lindex $result 3]
   set site      [lindex $result 4]
   set sizefich  [lindex $result 5]
   set tabkey    [lindex $result 6]

   gren_info "\n\nInsertion Solo : \n"
   gren_info "Insertion Solo : nomfich  = $nomfich\n"
   #gren_info "Insertion Solo : erreur   = $erreur\n"
   #gren_info "Insertion Solo : etat     = $etat\n"
   #gren_info "Insertion Solo : site     = $site\n"
   #gren_info "Insertion Solo : sizefich = $sizefich\n"
   #gren_info "Insertion Solo : dateiso  = $dateiso\n"

   #gren_info "Site : $site \n"

   set fic [file tail $nomfich]
   set entetelog $fic
#gren_info "fic : $fic \n"
#gren_info "entetelog : $entetelog \n"
#gren_info "erreur : $erreur \n"

   if {$erreur!=0} {
      set dirpb "$bddconf(direrr)"
      createdir_ifnot_exist $dirpb
      set dirpb "$bddconf(direrr)/err$erreur"
      createdir_ifnot_exist $dirpb
      bddimages_sauve_fich "insertion_solo: Deplacement du fichier $nomfich dans $dirpb"
      set errnum [catch {file rename $nomfich $dirpb/} msg]
      set errcp [string first "file already exists" $msg]
      gren_info "errnum = $errnum errcp = $errcp"
      if {$errcp>0||$errnum==0} {
         set errnum [catch {file delete $nomfich} msg]
         if {$errnum!=0} {
            bddimages_sauve_fich "insertion_solo: ERREUR 111 : effacement de $nomfich impossible <err=$errnum> <msg=$msg>"
            return -code 111
         } else {
            bddimages_sauve_fich "insertion_solo: Fichier $nomfich supprime"
         }
      }
      set erreur "Erreur <$erreur> : $caption(bddimages_insertion,err$erreur)"
   }

   set ligne [list $etat $nomfich $dateiso $site $sizefich $erreur $tabkey]

   #gren_info "Insertion Solo : erreur = $erreur\n"
   #gren_info "Insertion Solo : ligne = $ligne\n"

   if {$erreur == 0} {
      # Ici se fait l'Insertion de l image
      set liste     [bddimages_insertion_unfich $ligne]
      #gren_info "Insertion Solo = $liste\n"
      set err       [lindex $liste 0]
      set nomfich   [lindex $liste 1]
      set newid     [lindex $liste 2]
      set msg       [lindex $liste 3]
      set typefich  [lindex $liste 4]

      #if {[info exists ::bdi_tools_verif::test_file]} {
      #   if {[file exists $::bdi_tools_verif::test_file]} {
      #      gren_info "bddimages_insertion_unfich :5 EXIST\n"
      #   } else {
      #      gren_info "bddimages_insertion_unfich :5 NOT EXIST \n"
      #   }
      #}

      gren_info "Insertion Solo : $nomfich ($typefich: id->$newid)\n"
      if {$err==-1} {return -code 2 ""}
   } else {
      gren_erreur "ERREUR Insertion Solo : erreur = $erreur\n"
      gren_erreur "ERREUR Insertion Solo : ligne  = $ligne\n"
   }

   return -code 0 $newid
}

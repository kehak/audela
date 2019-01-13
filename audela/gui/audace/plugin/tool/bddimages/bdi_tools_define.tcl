## @file bdi_tools_define.tcl
#  @brief     Outils de gestion des mots cl&eacute;s des ent&ecirc;tes fits
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_define.tcl]
#  @endcode

# $Id: bdi_tools_define.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @namespace bdi_tools_define
# @brief Outils de gestion des mots cl&eacute;s des ent&ecirc;tes fits
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_define {

}


#============================================================
##
# @brief    Recupere la liste des mots-cles deja inseres dans
#           la base de donnees
# @return   liste des champs de la base de donnees
#
#============================================================
proc ::bdi_tools_define::get_list_box_champs { } {

   global list_key_to_var

   set list_box_champs [list ]
   set nbl1 0
   set sqlcmd "select distinct keyname,variable from header order by keyname;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
      return -code error "Erreur de lecture de la liste des header par SQL"
   }
   foreach line $resultsql {
      set key [lindex $line 0]
      set var [lindex $line 1]
      set list_key_to_var($key) $var
      if {$nbl1<[string length $key]} {
         set nbl1 [string length $key]
      }
      lappend list_box_champs $key
   }
   set nbl1 [expr $nbl1 + 3]
   return [list $nbl1 $list_box_champs]
}



#============================================================
##
# @brief    Applique la programmation en effectuant les modification
#           des header pour chaque image
# @return   void
#
#============================================================
proc ::bdi_tools_define::apply { } {

   global bddconf

   set r [tk_messageBox -message "Voulez vous vraiment appliquer ces modifications ?" -type yesno]
   if {$r != "yes"} {return}

   set nb [$::bdi_gui_define::worklist size]
   set id_list ""
   for {set i 0} {$i<$nb} {incr i} {
      set line [$::bdi_gui_define::worklist get $i $i]
      set line [lindex $line 0]
      #gren_info "line = $line\n"
      set chg    [lindex $line 1]
      set key    [lindex $line 2]
      set val    [lindex $line 3]
      set type   [lindex $line 4]
      set unit   [lindex $line 5]
      set cmt    [lindex $line 6]
      set tmplst [lindex $line 7]
      foreach id $tmplst {
         lappend id_list $id
         if {![info exists tabchange($id)]} {set tabchange($id) ""}
         lappend tabchange($id) [list $chg [list $key $val $type $cmt $unit]]
      }
   }
   
   set id_list [lsort -uniq -increasing -integer $id_list]

   gren_info "Action :\n"
   set bufno [::buf::create]
   set cpt 0
   set nbtotal [llength $id_list]
   
   foreach idbddimg $id_list {
   
      # on recupere les infos de l image
      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]
      if {$fileimg == -1} {
         gren_erreur "Fichier image inexistant ($idbddimg) \n"
         continue
      }

      # on met l image dans le buffer
      buf$bufno load $fileimg

      # on defini la variable pour savoir si on aura fait des changements sur l image
      set change "no"
      

      # on applique les modifs
      foreach m $tabchange($idbddimg) {
         set chg [lindex $m 0]
         set lkey [lindex $m 1]
         gren_info "$idbddimg : $chg : $lkey\n"
         switch $chg {
            "D" {
               if {[string first [lindex $lkey 0] [buf$bufno getkwd [lindex $lkey 0]]] != -1} {
                  buf$bufno delkwd [lindex $lkey 0]
                  set change "yes"
               }
            }
            "A" - "M" {
               if {[string first [lindex $lkey 0] [buf$bufno getkwd [lindex $lkey 0]]] != -1} {
                  set key [buf$bufno getkwd [lindex $lkey 0]]
                  set lval [lindex $lkey 1]
                  set ltyp [lindex $lkey 2]
                  set lcom [lindex $lkey 3]
                  set lunt [lindex $lkey 4]
                  set val  [lindex $key 1]
                  set typ  [lindex $key 2]
                  set com  [lindex $key 3]
                  set unt  [lindex $key 4]
                  set lchange "no"
                  
                  # valeur
                  if {$lval == ""} {
                     set dval $val
                  } else {
                     if {$lval!=$val} {
                        set dval $lval
                        set lchange "yes"
                     } else {
                        set dval $val
                     }
                  }
                  
                  # type
                  if {$ltyp == ""} {
                     set dtyp $typ
                  } else {
                     if {$ltyp!=$typ} {
                        set dtyp $ltyp
                        set lchange "yes"
                     } else {
                        set dtyp $typ
                     }
                  }
                  
                  # Comment
                  if {$lcom == ""} {
                     set dcom $com
                  } else {
                     if {$lcom!=$com} {
                        set dcom $lcom
                        set lchange "yes"
                     } else {
                        set dcom $com
                     }
                  }
                  
                  # Unit
                  if {$lunt == ""} {
                     set dunt $unt
                  } else {
                     if {$lunt!=$unt} {
                        set dunt $lunt
                        set lchange "yes"
                     } else {
                        set dunt $unt
                     }
                  }
                  
                  if {$lchange == "yes"} {
                     buf$bufno setkwd [list [lindex $lkey 0] $dval $dtyp $dcom $dunt ]
                     set change "yes"
                  }
                  
               } else {
                  buf$bufno setkwd $lkey
                  set change "yes"
               }
            }
         }
      }

      # on verifie si le header est compatible BDI et on le rend compatible dans le cas contraire
      if {[::bddimagesAdmin::bdi_compatible $bufno] == 0 } {
         ::bddimagesAdmin::bdi_setcompat $bufno
         set change "yes"
      }
      
      # Un changement du header a ete effectue
      if {$change == "yes"} {

         # enregistre les modif dans l image
         set fichtmpunzip [unzipedfilename $fileimg]
         set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
         set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]

         # copie l image dans incoming
         createdir_ifnot_exist $bddconf(dirtmp)
         buf$bufno save $filetmp
         lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg
      
         # copie le cata dans incoming s'il existe
         if {$filecata != -1} {
            set err [catch {file rename -force -- $filecata $bddconf(dirinco)/.} msg ]
            if {$err} {
               gren_erreur "insertion_solo : Impossible de deplacer le fichier cata du disque vers incoming :"
               gren_erreur "<filecata=$filecata>"
               gren_erreur "<err=$err>"
               gren_erreur "<msg=$msg>"
               bddimages_sauve_fich "insertion_solo : Impossible de deplacer le fichier cata du disque vers incoming : <filecata=$filecata> <err=$err> <msg=$msg>"
            }
         }

         # efface l image et le cata dans la base et le disque
         bddimages_image_delete_fromsql $ident
         bddimages_image_delete_fromdisk $ident

         # insere l image et le cata dans la base
         insertion_solo $filefinal
         if {$filecata!=-1} {
            set filecata [file join $bddconf(dirinco) [file tail $filecata]]
            if {![file exists $filecata]} {
               gren_erreur "cata : $filecata file not exist\n"
            } else {
               insertion_solo $filecata
            }
         }

         set errnum [catch {file delete -force $filetmp} msg ]

      } else {
         gren_info "Nothing todo : [file tail $fileimg]\n"
      }
      
      # Compteur d avancement
      incr cpt
      gren_info "$cpt/$nbtotal\n"
      #::bddimages_define::set_progress $cpt $nbtotal
      
   }
   
   buf$bufno clear

   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]

}

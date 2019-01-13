## @file bdi_tools_reports.tcl
#  @brief     Outils d&eacute;di&eacute;s aux rapports d'analyse
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_reports.tcl]
#  @endcode

# $Id: bdi_tools_reports.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_reports
# @brief Outils d&eacute;di&eacute;s aux rapports d'analyse
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_reports {

}


proc ::bdi_tools_reports::charge { } {

   global bddconf

   #gren_erreur "\n** Chargement\n"

   set tt0 [clock clicks -milliseconds]
   #gren_info "Analyse du repertoire des Rapports : [file join $bddconf(dirreports) ASTROPHOTOM]\n"

   # Init variable
   $::bdi_tools_reports::data_obj       delete 0 end
   $::bdi_tools_reports::data_firstdate delete 0 end
   $::bdi_tools_reports::data_report    delete 0 end
   $::bdi_tools_reports::data_nuitee    delete 0 end
   $::bdi_tools_reports::data_total     delete 0 end

   set ::bdi_tools_reports::list_obj       ""
   set ::bdi_tools_reports::list_firstdate ""
   set ::bdi_tools_reports::list_batch     ""

   array unset ::bdi_tools_reports::tab_obj
   array unset ::bdi_tools_reports::tab_firstdate
   array unset ::bdi_tools_reports::tab_batch
   array unset ::bdi_tools_reports::tab_nuitee

   set msg_err_out "La structure des rapports de bddimages est non conforme. Veuillez proceder a une verification de la base."
   set badfile ""

   set wb_obj $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_obj
   set wb_fda $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_fda
   set wb_nui $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_nui
   set wb_tot $::bdi_gui_reports::widget(frame,astrophotom).buttons.wb_tot

   # Obtention du mode d affichage actuel
   if {[$wb_obj cget -relief ] == "sunken"} {
      set table "object"
   }
   if {[$wb_fda cget -relief ] == "sunken"} {
      set table "firstdate"
   }
   if {[$wb_nui cget -relief ] == "sunken"} {
      set table "nuitee"
      set idc [$::bdi_tools_reports::data_nuitee sortcolumn]
      set order "-[$::bdi_tools_reports::data_nuitee sortorder]"
   }
   if {[$wb_tot  cget -relief ] == "sunken"} {
      set table "total"
      set idc [$::bdi_tools_reports::data_total sortcolumn]
      set order "-[$::bdi_tools_reports::data_total  sortorder]"
   }

   # Recupere la liste des objets
   set err [catch {set liste [glob -directory [file join $bddconf(dirreports) ASTROPHOTOM] *]} msg ]
   if {$err} {
      tk_messageBox -message $msg -type ok
      return
   }
   foreach i $liste {
      if {[file type $i]=="directory"} {
         lappend ::bdi_tools_reports::list_obj [file tail $i]
      } else {
         if {[file tail $i] == "resume_total.csv" } { continue }
         if {[file tail $i] == "resume_nuitees.csv" } { continue }
         if {[file tail $i] == "resume.csv" } {
            set err [catch {file delete -force $i} msg]
            continue
         }
         tk_messageBox -message $msg_err_out -type ok
         return
      }
   }

   # Recupere la liste des firstdate
   foreach obj $::bdi_tools_reports::list_obj {
      set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj]
      set liste [glob -directory $dir *]
      foreach i $liste {
         if {[file type $i]=="directory"} {
            set firstdate [file tail $i]
            if { ! [regexp {(\d+)-(\d+)-(\d+)} $firstdate dateiso aa mm jj] } {
               tk_messageBox -message $msg_err_out -type ok
               return
            }
            lappend ::bdi_tools_reports::list_firstdate      $firstdate
            lappend ::bdi_tools_reports::tab_firstdate($obj) $firstdate
            lappend ::bdi_tools_reports::tab_obj($firstdate) $obj
         } else {
            tk_messageBox -message $msg_err_out -type ok
            return
         }
      }
   }

   # construit la liste des dates
   set ::bdi_tools_reports::list_firstdate [lsort -dic -unique $::bdi_tools_reports::list_firstdate]

   # Recupere la liste des batchs
   foreach obj $::bdi_tools_reports::list_obj {

      foreach firstdate $::bdi_tools_reports::tab_firstdate($obj) {

         set ::bdi_tools_reports::tab_batch($obj,$firstdate,batch) ""
         set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate]
         set liste [glob -directory $dir *]

         foreach i $liste {

            if {[file type $i]=="directory"} {

               set batch [file tail $i]
               #gren_info "$batch\n"

               switch $batch {
                  "astrom_txt" - "astrom_mpc" - "astrom_xml" - "photom_txt" - "photom_xml" {
                     tk_messageBox -message $msg_err_out -type ok
                     return
                  }
               }

               # le repertoire n est pas un batch dans rapports/$obj/$firstdate/
               if { ! [regexp {Audela_BDI_(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)} $i dateiso aa mm jj h m s] } {
                  tk_messageBox -message $msg_err_out -type ok
                  return
               }

               lappend ::bdi_tools_reports::list_batch                 $batch
               lappend ::bdi_tools_reports::tab_batch($obj,$firstdate) $batch

               set ::bdi_tools_reports::tab_batch($obj,$batch,firstdate) $firstdate

               if {![info exists ::bdi_tools_reports::tab_batch($batch,obj)] } {
                  set ::bdi_tools_reports::tab_batch($batch,obj) $obj
               } else {
                  lappend ::bdi_tools_reports::tab_batch($batch,obj) $obj
               }

            } else {
               # fichier solitaire dans rapports/$obj/$firstdate/
               tk_messageBox -message $msg_err_out -type ok
               return
            }

         }

      }

   }


   # Recupere la liste des fichiers
   foreach batch $::bdi_tools_reports::list_batch {

      foreach obj $::bdi_tools_reports::tab_batch($batch,obj) {

         set firstdate $::bdi_tools_reports::tab_batch($obj,$batch,firstdate)

         # Pour chaque batch
         set ::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc) "no"

         # Union de tous les batch d'un couple $obj et $firstdate

         set dir [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch]
         set info_lu "no"

         # Lecture du fichier info
         set err [catch {set liste [glob $dir/*info*]} msg ]
         if {$err!=0} {
            gren_erreur "Pas de fichier info ($err) ($msg)\n"
            gren_erreur "Procedez a une verification\n"
            continue
         }
         if {$err==0} {
            foreach i $liste {
               set file [file tail $i]
               #gren_info "file info \[[::bdi_tools_reports::is_file_info $file]\] = $file\n"
               #gren_info "rootfile $i\n"
               #gren_info "is_file_info [::bdi_tools_reports::is_file_info $file]\n"

               if {[::bdi_tools_reports::is_file_info $file]} {


                  ::bdi_tools_reports::file_info_to_list $i l
                  foreach {key val} $l {
                     #if {$key == "type"} {
                     #   gren_erreur "$key => $val\n"
                     #}#
                     set ::bdi_tools_reports::tab_batch($batch,$obj,$key) $val
                  }

                  set ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,file) $file
                  set ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) $i

                  set info_lu "yes"

                  #set type   $::bdi_tools_reports::tab_batch($batch,type)
                  #set submit_mpc $::bdi_tools_reports::tab_batch($batch,submit_mpc)

                  #if {$type == "astrom"} {
                  #   # submit_mpc de la nuitee
                  #   if {![info exists ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,batch,submit_mpc)]} {
                  #      if {$::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,batch,submit_mpc) == "no" && $submit_mpc=="yes"} {
                  #         set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,batch,submit_mpc) "yes"
                  #         set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,$batch,astrom,mpc,submit_mpc) $submit_mpc
                  #      }
                  #   }
                  #}

                  #if {$type == "photom"} {
#                 #
                  #}
               }
            }
         }

         if { $info_lu == "no" } {
            gren_erreur "info_lu NO\n"
         }

         # les autres fichiers
         set nuitee_photom_lu "no"
         set nuitee_astrom_lu "no"

         #gren_info "Lecture des autres fichiers de donnees\n"

         set liste [glob $dir/*]
         foreach i $liste {

            set file [file tail $i]

            if {![::bdi_tools_reports::is_file_info $file]} {

               set type [::bdi_tools_reports::get_type_filename $file]
               set ext  [::bdi_tools_reports::get_ext_filename $file]

               #gren_info "FILE : $type $ext : $file\n"
               set ::bdi_tools_reports::tab_batch($batch,$obj,$type,$ext,file) $file
               set ::bdi_tools_reports::tab_batch($batch,$obj,$type,$ext,rootfile) $i

               #if {$type == "photom" && $ext == "txt" && $submit_mpc == "yes"} {
               #   ::bdi_tools_reports::get_info_photom $obj $firstdate $submit_mpc $file
               #   set nuitee_photom_lu "yes"
               #}
               #if {$type == "astrom" && $ext == "txt" && $submit_mpc == "yes"} {
               #   ::bdi_tools_reports::get_info_astrom $obj $firstdate $submit_mpc $file
               #   set nuitee_astrom_lu "yes"
               #}
               #if { ($type == "astrom" || $type == "photom") && $ext == "txt"} {
               #   set ::bdi_tools_reports::tab_report($obj,$firstdate,$type,batch,exist) "Yes"
               #}
            }
         }

         # pour la nuitee
         # if {$nuitee_astrom_lu=="no"||$nuitee_photom_lu=="no"} {
         #    set l [lsort -dictionary -decreasing $::bdi_tools_reports::tab_batch($obj,$firstdate)]
         #    foreach b $l {
         #       if {$nuitee_astrom_lu=="yes"&&$nuitee_photom_lu=="yes"} { break }
         #       if {$nuitee_astrom_lu=="no"&&[info exists ::bdi_tools_reports::tab_report($obj,$firstdate,$b,astrom,txt,file)]} {
         #          ::bdi_tools_reports::get_info_astrom $obj $firstdate "No" $::bdi_tools_reports::tab_report($obj,$firstdate,$b,astrom,txt,file)
         #          set nuitee_astrom_lu "yes"
         #          continue
         #       }
         #       if {$nuitee_photom_lu=="no"&&[info exists ::bdi_tools_reports::tab_report($obj,$firstdate,$b,photom,txt,file)]} {
         #          ::bdi_tools_reports::get_info_photom $obj $firstdate "No" $::bdi_tools_reports::tab_report($obj,$firstdate,$b,photom,txt,file)
         #          set nuitee_photom_lu "yes"
         #          continue
         #       }
         #    }
         # }

      }
   }


   # Construction des listes de nuitees
   foreach obj $::bdi_tools_reports::list_obj {

      foreach firstdate $::bdi_tools_reports::tab_firstdate($obj) {

         # rapport astrometrique
         set nuitee_astrom_lu "no"
         set astrom_list ""

         # test si un rapport est soumis on le lit

         foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {
            if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
               set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)
               if {[file exists $rootfile]} {
                  ::bdi_tools_reports::file_info_to_list $rootfile l
                  array set tab $l
                  if { $tab(type) == "astrom" } {lappend astrom_list $batch}
                  if {![info exists tab(submit_mpc)]} {continue}
                  if { $tab(submit_mpc) == "yes" && $tab(type) == "astrom" } {
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code)          [::bdi_tools_reports::get_key_from_tab tab iau_code       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration)          [::bdi_tools_reports::get_key_from_tab tab duration       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)         [::bdi_tools_reports::get_key_from_tab tab fwhm_mean      ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)          [::bdi_tools_reports::get_key_from_tab tab fwhm_std       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean)          [::bdi_tools_reports::get_key_from_tab tab mag_mean       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std)           [::bdi_tools_reports::get_key_from_tab tab mag_std        ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp)           [::bdi_tools_reports::get_key_from_tab tab mag_amp        ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean)           [::bdi_tools_reports::get_key_from_tab tab ra_mean        ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std)            [::bdi_tools_reports::get_key_from_tab tab ra_std         ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean)          [::bdi_tools_reports::get_key_from_tab tab dec_mean       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std)           [::bdi_tools_reports::get_key_from_tab tab dec_std        ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_mean)    [::bdi_tools_reports::get_key_from_tab tab residuals_mean ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_std)     [::bdi_tools_reports::get_key_from_tab tab residuals_std  ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_mean)          [::bdi_tools_reports::get_key_from_tab tab omc_mean       ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_std)           [::bdi_tools_reports::get_key_from_tab tab omc_std        ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,submit_mpc) [::bdi_tools_reports::get_key_from_tab tab submit_mpc     ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,nb_dates)   [::bdi_tools_reports::get_key_from_tab tab nb_dates       ]
                     set nuitee_astrom_lu "yes"
                  }
               }
            }
         }

         # si aucun rapport n est soumis on le lit le plus recent
         if {$nuitee_astrom_lu == "no"} {
            set batch [lindex [lsort -decreasing $astrom_list] 0]
            if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
               set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)
               if {[file exists $rootfile]} {
                  ::bdi_tools_reports::file_info_to_list $rootfile l
                  array set tab $l
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code)          [::bdi_tools_reports::get_key_from_tab tab iau_code       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration)          [::bdi_tools_reports::get_key_from_tab tab duration       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)         [::bdi_tools_reports::get_key_from_tab tab fwhm_mean      ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)          [::bdi_tools_reports::get_key_from_tab tab fwhm_std       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean)          [::bdi_tools_reports::get_key_from_tab tab mag_mean       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std)           [::bdi_tools_reports::get_key_from_tab tab mag_std        ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp)           [::bdi_tools_reports::get_key_from_tab tab mag_amp        ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean)           [::bdi_tools_reports::get_key_from_tab tab ra_mean        ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std)            [::bdi_tools_reports::get_key_from_tab tab ra_std         ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean)          [::bdi_tools_reports::get_key_from_tab tab dec_mean       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std)           [::bdi_tools_reports::get_key_from_tab tab dec_std        ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_mean)    [::bdi_tools_reports::get_key_from_tab tab residuals_mean ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,residuals_std)     [::bdi_tools_reports::get_key_from_tab tab residuals_std  ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_mean)          [::bdi_tools_reports::get_key_from_tab tab omc_mean       ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,omc_std)           [::bdi_tools_reports::get_key_from_tab tab omc_std        ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,submit_mpc) [::bdi_tools_reports::get_key_from_tab tab submit_mpc     ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,astrom,nb_dates)   [::bdi_tools_reports::get_key_from_tab tab nb_dates       ]
                  set nuitee_astrom_lu "yes"
               }
            }
         }

         # rapport photometrique
         set nuitee_photom_lu "no"
         set photom_list ""

         # test si un rapport est soumis on le lit
         foreach batch $::bdi_tools_reports::tab_batch($obj,$firstdate) {
            if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
               set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)
               if {[file exists $rootfile]} {
                  ::bdi_tools_reports::file_info_to_list $rootfile l
                  array set tab $l
                  if { $tab(type) == "photom" } {lappend photom_list $batch}
                  if {![info exists tab(submit_mpc)]} {continue}
                  if { $tab(submit_mpc) == "yes" && $tab(type) == "photom" } {
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code)          [::bdi_tools_reports::get_key_from_tab tab iau_code   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration)          [::bdi_tools_reports::get_key_from_tab tab duration   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)         [::bdi_tools_reports::get_key_from_tab tab fwhm_mean  ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)          [::bdi_tools_reports::get_key_from_tab tab fwhm_std   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean)          [::bdi_tools_reports::get_key_from_tab tab mag_mean   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std)           [::bdi_tools_reports::get_key_from_tab tab mag_std    ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp)           [::bdi_tools_reports::get_key_from_tab tab mag_amp    ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_prec)          [::bdi_tools_reports::get_key_from_tab tab mag_prec   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,submit_mpc) [::bdi_tools_reports::get_key_from_tab tab submit_mpc ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,nb_dates)   [::bdi_tools_reports::get_key_from_tab tab nb_dates   ]
                     if {$nuitee_astrom_lu == "no"} {
                        set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean)        [::bdi_tools_reports::get_key_from_tab tab ra_mean    ]
                        set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std)         [::bdi_tools_reports::get_key_from_tab tab ra_std     ]
                        set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean)       [::bdi_tools_reports::get_key_from_tab tab dec_mean   ]
                        set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std)        [::bdi_tools_reports::get_key_from_tab tab dec_std    ]
                     }
                     set nuitee_photom_lu "yes"
                  }
               }
            }
         }

         # si aucun rapport n est soumis on le lit le plus recent
         if {$nuitee_photom_lu == "no"} {
            set batch [lindex [lsort -decreasing $photom_list] 0]
            if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
               set rootfile $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)
               if {[file exists $rootfile]} {
                  ::bdi_tools_reports::file_info_to_list $rootfile l
                  array set tab $l
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,iau_code)          [::bdi_tools_reports::get_key_from_tab tab iau_code   ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,duration)          [::bdi_tools_reports::get_key_from_tab tab duration   ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_mean)         [::bdi_tools_reports::get_key_from_tab tab fwhm_mean  ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,fwhm_std)          [::bdi_tools_reports::get_key_from_tab tab fwhm_std   ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_mean)          [::bdi_tools_reports::get_key_from_tab tab mag_mean   ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_std)           [::bdi_tools_reports::get_key_from_tab tab mag_std    ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_amp)           [::bdi_tools_reports::get_key_from_tab tab mag_amp    ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,mag_prec)          [::bdi_tools_reports::get_key_from_tab tab mag_prec   ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,submit_mpc) [::bdi_tools_reports::get_key_from_tab tab submit_mpc ]
                  set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,photom,nb_dates)   [::bdi_tools_reports::get_key_from_tab tab nb_dates   ]
                  if {$nuitee_astrom_lu == "no"} {
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_mean)        [::bdi_tools_reports::get_key_from_tab tab ra_mean    ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,ra_std)         [::bdi_tools_reports::get_key_from_tab tab ra_std     ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_mean)       [::bdi_tools_reports::get_key_from_tab tab dec_mean   ]
                     set ::bdi_tools_reports::tab_nuitee($obj,$firstdate,dec_std)        [::bdi_tools_reports::get_key_from_tab tab dec_std    ]
                  }
                  set nuitee_photom_lu "yes"
               }
            }
         }

      }

   }

   set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
   gren_info "Chargement complet en $tt sec \n"

   ::bdi_gui_reports::affiche_data

   if {$table=="nuitees"} {
      if {$idc!=-1&&$order!="-"} {
         $::bdi_tools_reports::data_nuitee sortbycolumn $idc $order
      } else {
         $::bdi_tools_reports::data_nuitee sortbycolumn 0 -decreasing
      }
   }
   if {$table=="total"} {
      if {$idc!=-1&&$order!="-"} {
         $::bdi_tools_reports::data_total  sortbycolumn $idc $order
      } else {
         $::bdi_tools_reports::data_total  sortbycolumn 0 -decreasing
      }
   }

}


proc ::bdi_tools_reports::export { type { newbatch "" } } {

   global bddconf audace
   
   gren_info "Lancement des scripts Stilts\n"

   # Verification du type
   switch $type {
      "astrom" {
         gren_info "Type = Astrometrique\n"
      }
      "photom" {
         gren_info "Type = Photometrique\n"
      }
      default {
         gren_info "Type = inconnu\n"
         return
      }
   }

   set submit_mpc  "no"
   set comment ""
   set xml     ""

   # liste des batch
   set nb 0
   foreach { obj firstdate batch}  $::bdi_tools_reports::export_batch_list {

      gren_info "Objet     $obj\n"
      gren_info "Firstdate $firstdate\n"
      gren_info "Batch     $batch\n"
      
      # Determination du firstdate minimum
      if { $nb == 0 } {
         set firstdate_min $firstdate
      } else {
         if {[string compare $firstdate_min $firstdate]==1} {
            set firstdate_min $firstdate
         }
      }
      
      # ajout du fichier XML dans la liste
      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile)]} {
         lappend xml $::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile)
         incr nb
      }
      if { $submit_mpc == "no" } {
         set submit_mpc  $::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc)
      }
      if {[info exists ::bdi_tools_reports::tab_batch($batch,$obj,comment)]} {
         append comment [string trim $::bdi_tools_reports::tab_batch($batch,$obj,comment)]
      }


   }
   
   # Creation d un nouveau batch
   if { $nb > 1} {
      set firstdate $firstdate_min
      set batch $newbatch
      set dirbatch [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch ]
      createdir_ifnot_exist $dirbatch
      gren_info "** Creation du repertoire de batch\n"
   } else {
      set dirbatch [file join $bddconf(dirreports) ASTROPHOTOM $obj $firstdate $batch ]
   }

   # inputfile & Fichier de commande
   gren_info "Fichier d input dans $bddconf(dirtmp)\n"
   set datfile [file join $bddconf(dirtmp) "${batch}.export.dat"]
   set chan [open $datfile w]
   foreach file $xml {
      puts $chan $file
      gren_info "inputfile = $file\n"
   }
   close $chan

   # Concatenation en conservant le format Bddimages xml
   if {$::bdi_tools_reports::export_concat && $nb > 1} {
      
      
      # Creation du fichier info.txt
      set list_uniq [ list obj type iau_code subscriber address mail software observers reduction instrument \
                           ref_catalogue deg_polynom use_refraction use_eop use_debias ]
      set list_sum  [ list nb_ref_stars nb_dates  ]
      set list_moy  [ list res_max_ref_stars res_min_ref_stars res_mean_ref_stars res_std_ref_stars \
                           fwhm_mean fwhm_std mag_mean mag_std mag_amp ra_std dec_std \
                           residuals_mean residuals_std omc_mean omc_std omc_x_mean omc_y_mean \
                           omc_x_std omc_y_std ]
      set list_real  [ list res_max_ref_stars 3 res_min_ref_stars 3 res_mean_ref_stars 3 res_std_ref_stars 3 \
                           fwhm_mean 2 fwhm_std 2 mag_mean 3 mag_std 3 mag_amp 3 ]
      
      array unset tab_info
      set outfile [file join $dirbatch [::bdi_tools_reports::build_filename $obj $firstdate $batch info txt] ]
      foreach { obj firstdate batch}  $::bdi_tools_reports::export_batch_list {
         if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} { continue }
         if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} { continue }
         ::bdi_tools_reports::file_info_to_list $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) list_info
         array set tab_info_f $list_info
         
         # Union
         foreach key $list_uniq {
            if {![info exists tab_info_f($key)]} {continue}
            if {![info exists tab_info($key)]} {
               set tab_info($key) $tab_info_f($key)
            } else {
               if {$tab_info($key) != $tab_info_f($key)} {
                  set tab_info($key) "*"
               }
            }
         }

         # Somme
         foreach key $list_sum {
            if {![info exists tab_info_f($key)]} {continue}
            if {![info exists tab_info($key)]} {
               set tab_info($key) $tab_info_f($key)
            } else {
               set tab_info($key) [expr $tab_info($key) + $tab_info_f($key)]
            }
         }

         # Moyenne
         foreach key $list_moy {
            if {![info exists tab_info_f($key)]} {continue}
            if {![info exists tab_info($key)]} {
               set tab_info($key) $tab_info_f($key)
            } else {
               set tab_info($key) [expr $tab_info($key) + $tab_info_f($key)]
            }
         }


      }
      
      # Moyenne
      foreach key $list_moy {
         if {![info exists tab_info_f($key)]} {continue}
         if {[info exists tab_info($key)]} {
            set tab_info($key) [expr $tab_info($key) / $nb]
         }
      }
      # Format reel
      foreach {key n} $list_real {
         if {![info exists tab_info_f($key)]} {continue}
         if {[info exists tab_info($key)]} {
            set tab_info($key) [format "%.${n}f" $tab_info($key)]
         }
      }
      
      # Ecriture du fichier info
      set list_info [array get tab_info]
      ::bdi_tools_reports::list_to_file_info $outfile list_info

      # Creation du fichier XML
      set outfile [file join $dirbatch [::bdi_tools_reports::build_filename $obj $firstdate $batch $type "xml"] ]
      set script [file join $audace(rep_plugin) tool bddimages scripts report export.sh]
      set err [catch {exec $script -f $datfile -e XML -o $outfile -t $type} msg]
      if {$err} {
         gren_erreur "Erreur : \[$err\] $msg\n"
      } else {
         gren_info "\n** Creation du fichier XML Votable\n"
         gren_info "MSG=$msg\n"
      }
      
    } 
   
   # Transformation en format Famous
   if {$::bdi_tools_reports::export_famous} {
      set outfile [file join $dirbatch [::bdi_tools_reports::build_filename $obj $firstdate $batch $type "fms"]]
      set script [file join $audace(rep_plugin) tool bddimages scripts report export.sh]
      set err [catch {exec $script -f $datfile -e FAMOUS -o $outfile -t $type} msg]
      if {$err} {
         gren_erreur "Erreur : \[$err\] $msg\n"
      } else {
         gren_info "\n** Creation du fichier FAMOUS\n"
         gren_info "MSG=$msg\n"
      }
   }

   # Transformation en format Genoide
   if {$::bdi_tools_reports::export_genoide} {
      set outfile [file join $dirbatch [::bdi_tools_reports::build_filename $obj $firstdate $batch $type "radec.xml"]]
      set script [file join $audace(rep_plugin) tool bddimages scripts report export.sh]
      set err [catch {exec $script -f $datfile -e GENOIDE -o $outfile -t $type} msg]
      if {$err} {
         gren_erreur "Erreur : \[$err\] $msg\n"
      } else {
         gren_info "\n** Creation du fichier GENOIDE radec\n"
         gren_info "MSG=$msg\n"
      }
   }

}



proc ::bdi_tools_reports::get_key_from_tab { p_tab key } {
   upvar $p_tab tab
   if {[info exists tab($key)]} {
      return $tab($key)
   } else {
      return ""
   }
}



#  set reportscols [list 0 "1ere Date"     left  \
#                 0 "Objets"        left  \
#                 0 "IAU\ncode"      center \
#                 0 "Duree\n(h)"     center \
#                 0 "FHWM\n(\")"     center \
#                 0 "STD\n(\")"      left  \
#                 0 "Mag"           center  \
#                 0 "STD"           left  \
#                 0 "Amp."          left  \
#                 0 "Prec."         left  \
#                 0 "Ra\n(hms)"      center  \
#                 0 "STD\n(mas)"     right  \
#                 0 "Dec\n(dms)"     center  \
#                 0 "STD\n(mas)"     right  \
#                 0 "Res\n(mas)" right  \
#                 0 "STD\n(mas)"     right  \
#                 0 "OmC\n(mas)"     right  \
#                 0 "STD\n(mas)"     right  \
#                 0 "Photom"        center  \
#                 0 "Soumis"        center  \
#                 0 "Nb-pts"        right  \
#                 0 "Astrom"        center  \
#                 0 "Soumis"        center  \
#                 0 "Nb-pts"        right  \
#           ]
# Donne les champs d un batch pour la liste reports
proc ::bdi_tools_reports::get_line_reports_batch { obj firstdate batch } {

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,type)          ]} { set type           "-" } else { set type           $::bdi_tools_reports::tab_batch($batch,$obj,type)          }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,iau_code)      ]} { set iau_code       "-" } else { set iau_code       $::bdi_tools_reports::tab_batch($batch,$obj,iau_code)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,duration)      ]} { set duration       "-" } else { set duration       $::bdi_tools_reports::tab_batch($batch,$obj,duration)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,fwhm_mean)     ]} { set fwhm_mean      "-" } else { set fwhm_mean      $::bdi_tools_reports::tab_batch($batch,$obj,fwhm_mean)     }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,fwhm_std)      ]} { set fwhm_std       "-" } else { set fwhm_std       $::bdi_tools_reports::tab_batch($batch,$obj,fwhm_std)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_mean)      ]} { set mag_mean       "-" } else { set mag_mean       $::bdi_tools_reports::tab_batch($batch,$obj,mag_mean)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_std)       ]} { set mag_std        "-" } else { set mag_std        $::bdi_tools_reports::tab_batch($batch,$obj,mag_std)       }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_amp)       ]} { set mag_amp        "-" } else { set mag_amp        $::bdi_tools_reports::tab_batch($batch,$obj,mag_amp)       }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,mag_prec)      ]} { set mag_prec       "-" } else { set mag_prec       $::bdi_tools_reports::tab_batch($batch,$obj,mag_prec)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,ra_mean)       ]} { set ra_mean        "-" } else { set ra_mean        $::bdi_tools_reports::tab_batch($batch,$obj,ra_mean)       }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,ra_std)        ]} { set ra_std         "-" } else { set ra_std         $::bdi_tools_reports::tab_batch($batch,$obj,ra_std)        }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,dec_mean)      ]} { set dec_mean       "-" } else { set dec_mean       $::bdi_tools_reports::tab_batch($batch,$obj,dec_mean)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,dec_std)       ]} { set dec_std        "-" } else { set dec_std        $::bdi_tools_reports::tab_batch($batch,$obj,dec_std)       }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,residuals_mean)]} { set residuals_mean "-" } else { set residuals_mean $::bdi_tools_reports::tab_batch($batch,$obj,residuals_mean)}
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,residuals_std) ]} { set residuals_std  "-" } else { set residuals_std  $::bdi_tools_reports::tab_batch($batch,$obj,residuals_std) }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,omc_mean)      ]} { set omc_mean       "-" } else { set omc_mean       $::bdi_tools_reports::tab_batch($batch,$obj,omc_mean)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,omc_std)       ]} { set omc_std        "-" } else { set omc_std        $::bdi_tools_reports::tab_batch($batch,$obj,omc_std)       }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,nb_dates)      ]} { set nb_dates       "-" } else { set nb_dates       $::bdi_tools_reports::tab_batch($batch,$obj,nb_dates)      }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc)    ]} { set submit_mpc     "-" } else { set submit_mpc     $::bdi_tools_reports::tab_batch($batch,$obj,submit_mpc)    }
   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,comment)       ]} { set comment        "-" } else { set comment        $::bdi_tools_reports::tab_batch($batch,$obj,comment)       }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile) ]} {
      set finfo "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,info,txt,rootfile)]} {
         set finfo "-"
      } else {
         set finfo "Yes"
      }
   }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,txt,rootfile) ]} {
      set ftxt "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,txt,rootfile)]} {
         set ftxt "-"
      } else {
         set ftxt "Yes"
      }
   }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile) ]} {
      set fxml "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,xml,rootfile)]} {
         set fxml "-"
      } else {
         set fxml "Yes"
      }
   }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,fms,rootfile) ]} {
      set ffms "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,fms,rootfile)]} {
         set ffms "-"
      } else {
         set ffms "Yes"
      }
   }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,radec,rootfile) ]} {
      set fradec "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,radec,rootfile)]} {
         set fradec "-"
      } else {
         set fradec "Yes"
      }
   }

   if {![info exists ::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile) ]} {
      set fmpc "-"
   } else {
      if {![file exists $::bdi_tools_reports::tab_batch($batch,$obj,$type,mpc,rootfile)]} {
         set fmpc "-"
      } else {
         set fmpc "Yes"
      }
   }

   #set submit_mpc  "No"
   #gren_erreur "viewmode type = $::bdi_tools_reports::viewmode $type\n"

   if { $::bdi_tools_reports::viewmode == "astrom" && $type != "astrom"} {return}
   if { $::bdi_tools_reports::viewmode == "photom" && $type != "photom"} {return}

   if { $::bdi_tools_reports::viewmode == "astrom"} {
      return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean $fwhm_std $mag_mean  \
                     $ra_mean $ra_std $dec_mean $dec_std $residuals_mean $residuals_std \
                     $omc_mean $omc_std $submit_mpc $nb_dates $comment]
   }

   if { $::bdi_tools_reports::viewmode == "photom"} {
      return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean $fwhm_std $mag_mean $mag_std $mag_amp \
                     $mag_prec $ra_mean  $dec_mean \
                     $submit_mpc $nb_dates $comment]
   }

   if { $::bdi_tools_reports::viewmode == "nostd"} {
      return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean  $mag_mean $mag_amp \
                     $mag_prec $ra_mean  $dec_mean  $residuals_mean  \
                     $omc_mean  $submit_mpc $nb_dates $comment]
   }
   if { $::bdi_tools_reports::viewmode == "submit"} {
      return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean $mag_mean \
                     $ra_mean $dec_mean $omc_mean $submit_mpc $nb_dates $comment]
   }

   if { $::bdi_tools_reports::viewmode == "files"} {
      return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean \
                     $nb_dates $finfo $fxml $ftxt $fmpc $ffms $fradec $comment]
   }
   # Affichage du resultat
   return [list $batch $firstdate $obj $type $iau_code $duration $fwhm_mean $fwhm_std $mag_mean $mag_std $mag_amp \
                  $mag_prec $ra_mean $ra_std $dec_mean $dec_std $residuals_mean $residuals_std \
                  $omc_mean $omc_std $submit_mpc $nb_dates $comment]

}



proc ::bdi_tools_reports::get_cols_reports_batch { } {

   if { $::bdi_tools_reports::viewmode == "astrom"} {
      return [list 0 "Batch"          left   \
                   0 "1ere Date"      left   \
                   0 "Objets"         left   \
                   0 "Type"           left   \
                   0 "IAU\ncode"      center \
                   0 "Duree\n(h)"     center \
                   0 "FHWM\n(\")"     center \
                   0 "STD\n(\")"      left   \
                   0 "Mag"            center \
                   0 "Ra\n(hms)"      center \
                   0 "STD\n(mas)"     right  \
                   0 "Dec\n(dms)"     center \
                   0 "STD\n(mas)"     right  \
                   0 "Res\n(mas)"     right  \
                   0 "STD\n(mas)"     right  \
                   0 "OmC\n(mas)"     right  \
                   0 "STD\n(mas)"     right  \
                   0 "MPC"            center \
                   0 "Nb-pts"         right  \
                   0 "Comment"        left   \
               ]
   }

   if { $::bdi_tools_reports::viewmode == "photom"} {
      return [list 0 "Batch"          left   \
                   0 "1ere Date"      left   \
                   0 "Objets"         left   \
                   0 "Type"           left   \
                   0 "IAU\ncode"      center \
                   0 "Duree\n(h)"     center \
                   0 "FHWM\n(\")"     center \
                   0 "STD\n(\")"      left   \
                   0 "Mag"            center \
                   0 "STD"            left   \
                   0 "Amp."           left   \
                   0 "Prec."          left   \
                   0 "Ra\n(hms)"      center \
                   0 "Dec\n(dms)"     center \
                   0 "MPC"            center \
                   0 "Nb-pts"         right  \
                   0 "Comment"        left   \
               ]
   }

   if { $::bdi_tools_reports::viewmode == "nostd"} {
      return [list 0 "Batch"          left   \
                   0 "1ere Date"      left   \
                   0 "Objets"         left   \
                   0 "Type"           left   \
                   0 "IAU\ncode"      center \
                   0 "Duree\n(h)"     center \
                   0 "FHWM\n(\")"     center \
                   0 "Mag"            center \
                   0 "Amp."           left   \
                   0 "Prec."          left   \
                   0 "Ra\n(hms)"      center \
                   0 "Dec\n(dms)"     center \
                   0 "Res\n(mas)"     right  \
                   0 "OmC\n(mas)"     right  \
                   0 "MPC"            center \
                   0 "Nb-pts"         right  \
                   0 "Comment"        left   \
               ]
   }
   if { $::bdi_tools_reports::viewmode == "submit"} {
      return [list 0 "Batch"          left   \
                   0 "1ere Date"      left   \
                   0 "Objets"         left   \
                   0 "Type"           left   \
                   0 "IAU\ncode"      center \
                   0 "Duree\n(h)"     center \
                   0 "FHWM\n(\")"     center \
                   0 "Mag"            center \
                   0 "Ra\n(hms)"      center \
                   0 "Dec\n(dms)"     center \
                   0 "OmC\n(mas)"     right  \
                   0 "MPC"            center \
                   0 "Nb-pts"         right  \
                   0 "Comment"        left   \
               ]
   }

   if { $::bdi_tools_reports::viewmode == "files"} {
      return [list 0 "Batch"          left   \
                   0 "1ere Date"      left   \
                   0 "Objets"         left   \
                   0 "Type"           left   \
                   0 "IAU\ncode"      center \
                   0 "Duree\n(h)"     center \
                   0 "FHWM\n(\")"     center \
                   0 "Nb-pts"         right  \
                   0 "Info"           center \
                   0 "XML"            center \
                   0 "TXT"            center \
                   0 "MPC"            center \
                   0 "Famous"         center \
                   0 "RaDec"          center \
                   0 "Comment"        left   \
               ]
   }
   # Retourne le resultat par defaut
   return [list 0 "Batch"          left   \
                0 "1ere Date"      left   \
                0 "Objets"         left   \
                0 "Type"           left   \
                0 "IAU\ncode"      center \
                0 "Duree\n(h)"     center \
                0 "FHWM\n(\")"     center \
                0 "STD\n(\")"      left   \
                0 "Mag"            center \
                0 "STD"            left   \
                0 "Amp."           left   \
                0 "Prec."          left   \
                0 "Ra\n(hms)"      center \
                0 "STD\n(mas)"     right  \
                0 "Dec\n(dms)"     center \
                0 "STD\n(mas)"     right  \
                0 "Res\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "OmC\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "MPC"            center \
                0 "Nb-pts"         right  \
                0 "Comment"        left   \
            ]

}

proc ::bdi_tools_reports::get_cols_total { } {
   # Retourne le resultat par defaut
   return [list 0 "Batch"          left   \
                0 "1ere Date"      left   \
                0 "Objets"         left   \
                0 "Type"           left   \
                0 "IAU\ncode"      center \
                0 "Duree\n(h)"     center \
                0 "FHWM\n(\")"     center \
                0 "STD\n(\")"      left   \
                0 "Mag"            center \
                0 "STD"            left   \
                0 "Amp."           left   \
                0 "Prec."          left   \
                0 "Ra\n(hms)"      center \
                0 "STD\n(mas)"     right  \
                0 "Dec\n(dms)"     center \
                0 "STD\n(mas)"     right  \
                0 "Res\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "OmC\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "MPC"            center \
                0 "Nb"             right  \
                0 "Comment"        left   \
          ]
}


proc ::bdi_tools_reports::get_cols_nuitee { } {
   # Retourne le resultat par defaut
   return [list 0 "1ere Date"      left   \
                0 "Objets"         left   \
                0 "IAU\ncode"      center \
                0 "Duree\n(h)"     center \
                0 "FHWM\n(\")"     center \
                0 "STD\n(\")"      left   \
                0 "Mag"            center \
                0 "STD"            left   \
                0 "Amp."           left   \
                0 "Prec."          left   \
                0 "Ra\n(hms)"      center \
                0 "STD\n(mas)"     right  \
                0 "Dec\n(dms)"     center \
                0 "STD\n(mas)"     right  \
                0 "Res\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "OmC\n(mas)"     right  \
                0 "STD\n(mas)"     right  \
                0 "Photom MPC"     center \
                0 "Photom Nb"      right  \
                0 "Astrom MPC"     center \
                0 "Astrom Nb"      right  \
          ]
}


#------------------------------------------------------------
## retourne le nom du fichier valid a partir des mots cles
# @param  obj       : Nom de l Objet
# @param  firstdate : Premiere Date
# @param  batch     : Nom du batch
# @param  type      : type de donnees
# @param  ext   [optionnel]: extension du fichier
# @return string : Nom du fichier
#
# @brief
# ::bdi_tools_reports::build_filename SKYBOT_107_Camilla 2015-04-20 Audela_BDI_2015-05-17T18:02:00_CEST info txt
# retourne "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
#
proc ::bdi_tools_reports::build_filename { obj firstdate batch type ext } {
   return "${obj}.${firstdate}.${batch}.${type}.${ext}"
}
# lassign [::bdi_tools_reports::explode_filename] obj firstdate batch type ext
proc ::bdi_tools_reports::explode_filename { file } {
   return [split $file "."]
}

#------------------------------------------------------------
## retourne le type du fichier valid a partir des mots cles
# @param  file
# @return string : Nom du fichier
#
# @brief
# ::bdi_tools_reports::build_filename SKYBOT_107_Camilla 2015-04-20 Audela_BDI_2015-05-17T18:02:00_CEST info txt
# retourne "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
#
proc ::bdi_tools_reports::get_type_filename { file } {

   set r [split $file "."]
   lassign $r obj date batch type ext

   return $type
}
proc ::bdi_tools_reports::get_ext_filename { file } {

   set r [split $file "."]
   lassign $r obj date batch type ext

   return $ext
}


#------------------------------------------------------------
## retourne 1 si le fichier d entree est un fichier d information
# pour recuperation des variables
# @param  file chemin complet vers fichier
# @return void
#
proc ::bdi_tools_reports::is_file_info { file } {

   set r [split $file .]
   lassign $r obj firstdate batch type ext

   set rxp {^.{4}-.{2}-.{2}}
   if {![regexp -- $rxp $firstdate]} {
      gren_erreur "$file conformity pb firstdate $firstdate\n"
      return 0
   }

   set rxp {^Audela_BDI_.{4}-.{2}-.{2}}
   if {![regexp -- $rxp $batch]} {
      gren_erreur "$file conformity pb batch $batch\n"
      return 0
   }

   if {$type != "info" && $type != "astrom" && $type != "photom" } {
      gren_erreur "$file conformity pb type $type\n"
      return 0
   }

   if {$ext != "txt" && $ext != "xml" && $ext != "mpc" && $ext != "dat" } {
      gren_erreur "$file conformity pb extension $ext\n"
      return 0
   }
   if {$ext == "txt" && $type == "info"} {
      return 1
   }

   return 0
}


proc ::bdi_tools_reports::file_info_good_sens { } {

   return [list obj type firstdate batch submit_mpc \
                iau_code subscriber address mail software \
                observers reduction instrument nb_dates duration \
                ref_catalogue nb_ref_stars deg_polynom use_refraction \
                use_eop use_debias res_max_ref_stars res_min_ref_stars \
                res_mean_ref_stars res_std_ref_stars \
                cm_var_max cm_var_moy cm_var_med cm_var_std \
                fwhm_mean fwhm_std \
                mag_mean mag_std mag_amp mag_prec ra_mean ra_std dec_mean dec_std \
                residuals_mean residuals_std omc_mean omc_std omc_x_mean \
                omc_y_mean omc_x_std omc_y_std comment ]
}



proc ::bdi_tools_reports::file_info_comment { key } {

   set comment ""
   switch $key {
      "obj"                { set comment "Object Name"}
      "type"               { set comment "Astrometric or Photometric report type"}
      "firstdate"          { set comment "Iso date of the day for the first date in the list"}
      "batch"              { set comment "batch code"}
      "submit_mpc"         { set comment "Report submitted to MPC"}
      "iau_code"           { set comment "IAU code"}
      "subscriber"         { set comment "Subscriber"}
      "address"            { set comment "Address"}
      "mail"               { set comment "Email"}
      "software"           { set comment "Software"}
      "observers"          { set comment "Observers"}
      "reduction"          { set comment "Reduction"}
      "instrument"         { set comment "Instrument"}
      "nb_dates"           { set comment "Nb of dates"}
      "duration"           { set comment "\[hour\] Duration"}
      "ref_catalogue"      { set comment "Reference catalogue"}
      "nb_ref_stars"       { set comment "Number of Reference Stars"}
      "deg_polynom"        { set comment "Degre of polynom"}
      "use_refraction"     { set comment "if =1 Refraction was corrected for astrometry"}
      "use_eop"            { set comment "if =1 Earth Orientation Pole was corrected for astrometry"}
      "use_debias"         { set comment "if =1 Zonal correction from star catalog was corrected for astrometry"}
      "res_max_ref_stars"  { set comment "\[arcsec\] Maximum residuals of reference stars for astrometry"}
      "res_min_ref_stars"  { set comment "\[arcsec\] Minimum residuals of reference stars for astrometry"}
      "res_mean_ref_stars" { set comment "\[arcsec\] Mean residuals of reference stars for astrometry"}
      "res_std_ref_stars"  { set comment "\[mag\] Standard deviation on residuals of reference stars for astrometry"}
      "cm_var_max"         { set comment "\[mag\] Maximum variation of the constant of magnitude for photometry"}
      "cm_var_moy"         { set comment "\[mag\] Mean variation of the constant of magnitude for photometry"}
      "cm_var_med"         { set comment "\[mag\] Median variation of the constant of magnitude for photometry"}
      "cm_var_std"         { set comment "\[mag\] Standard deviation on variation of the constant of magnitude for photometry"}
      "fwhm_mean"          { set comment "\[arcsec\] Mean Fwhm"}
      "fwhm_std"           { set comment "\[arcsec\] Standard deviation on Fwhm"}
      "mag_mean"           { set comment "\[mag\] Mean Magnitude"}
      "mag_std"            { set comment "\[mag\] Standard deviation of the Magnitude"}
      "mag_amp"            { set comment "\[mag\] Amplitude of the Magnitude variation"}
      "mag_prec"           { set comment "\[mag\] Precision on Magnitude"}
      "ra_mean"            { set comment "\[hms\] Right ascension Mean"}
      "ra_std"             { set comment "\[mas\] Right ascension Standard deviation"}
      "dec_mean"           { set comment "\[dms\] Declination Mean"}
      "dec_std"            { set comment "\[mas\] Declination Standard deviation"}
      "residuals_mean"     { set comment "\[mas\] Mean residuals on position of the object for astrometry"}
      "residuals_std"      { set comment "\[mas\] Standard deviation of the residuals on position of the object for astrometry"}
      "omc_mean"           { set comment "\[mas\] Mean Observed minus Calculus"}
      "omc_std"            { set comment "\[mas\] Standard deviation Observed minus Calculus"}
      "omc_x_mean"         { set comment "\[mas\] Mean Observed minus Calculus in X CCD coordinate"}
      "omc_y_mean"         { set comment "\[mas\] Mean Observed minus Calculus in Y CCD coordinate"}
      "omc_x_std"          { set comment "\[mas\] Standard deviation on Observed minus Calculus in X CCD coordinate"}
      "omc_y_std"          { set comment "\[mas\] Standard deviation on Observed minus Calculus in Y CCD coordinate"}
      "comment"            { set comment "Personal Comments"}
   }

   return $comment
}



proc ::bdi_tools_reports::file_info_to_list { rootfile p_l } {

   upvar $p_l l

   if {![file exists $rootfile]} {
      gren_erreur "Le fichier n existe pas : $rootfile\n"
      return -code 1 "Le fichier n existe pas"
   }

   set file [ file tail $rootfile]

   if {![::bdi_tools_reports::is_file_info $file]} {return}

   set r [split $file "."]
   lassign $r obj firstdate batch type ext

   array unset tab

   set tab(obj)       $obj
   set tab(firstdate) $firstdate
   set tab(batch)     $batch
   set tab(type)      $type
   set tab(ext)       $ext

   set chan [open $rootfile r]
   while {[gets $chan line] >= 0} {
      set line [string trim $line]
      if { [regexp {(.*):=(.*):=(.*)} $line u key val com] } {
         #gren_erreur "$key => $val => $com\n"
         if {$key != "" && $val != ""} {
            set tab([string trim $key]) [string trim $val]
         }
      } else {
         if { [regexp {(.*):=(.*)} $line u key val] } {
            if {$key != "" && $val != ""} {
               set tab([string trim $key]) [string trim $val]
            }
         } else {
            gren_erreur "Err file_info_to_list $rootfile\n"
            break
         }
      }
   }
   close $chan

   set l ""
   foreach key [::bdi_tools_reports::file_info_good_sens] {
      if { [info exists tab($key)] } { lappend l $key $tab($key) }
   }


   return
}



proc ::bdi_tools_reports::list_to_file_info { rootfile p_l } {

   upvar $p_l l

   set chan [open $rootfile w]

   gren_info "WRITE $rootfile\n"

   #set goodsens [list obj type firstdate batch nbpts submit_mpc \
   #                   iau_code subscriber address mail software \
   #                   observers reduction instrument nb_dates duration \
   #                   ref_catalogue nb_ref_stars deg_polynom use_refraction \
   #                   use_eop use_debias res_max_ref_stars res_min_ref_stars \
   #                   res_mean_ref_stars res_std_ref_stars fwhm_mean fwhm_std \
   #                   mag_mean mag_std mag_amp ra_mean ra_std dec_mean dec_std \
   #                   residuals_mean residuals_std omc_mean omc_std omc_x_mean \
   #                   omc_y_mean omc_x_std omc_y_std comment ]


   array set tab $l

   foreach key [::bdi_tools_reports::file_info_good_sens] {
      if {![info exists tab($key)]} {continue}
      set val $tab($key)
      set com  [::bdi_tools_reports::file_info_comment $key]
      gren_info "$key => $val => $com\n"
      if {$val != ""} {
         puts $chan [format "%-20s := %-50s := %s" $key $val $com]
      }
   }
   close $chan

}


#------------------------------------------------------------
## retourne 1 si le nom du fichier d entree est valide
# @param  file     : Chemin complet vers fichier
# @return bool
#
# @brief
# ::bdi_tools_reports::is_good_filename "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
# retourne 1
# ::bdi_tools_reports::is_good_filename "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.readme.txt"
# retourne 0
#
proc ::bdi_tools_reports::is_good_filename { file } {

   set r [split $file "."]
   lassign $r obj date batch type ext
   set valid 1

   set rxp {^.{4}-.{2}-.{2}}
   if {![regexp -- $rxp $date]} {
      gren_erreur "$file conformity pb date $date\n"
      set valid 0
   }

   set rxp {^Audela_BDI_.{4}-.{2}-.{2}}
   if {![regexp -- $rxp $batch]} {
      gren_erreur "$file conformity pb batch $batch\n"
      set valid 0
   }

   if {$type != "info" && $type != "astrom" && $type != "photom" } {
      gren_erreur "$file conformity pb type $type\n"
      set valid 0
   }

   if {$ext != "txt" && $type != "xml" && $type != "mpc" && $type != "dat" } {
      gren_erreur "$file conformity pb extension $ext\n"
      set valid 0

   }

   return $valid
}


#------------------------------------------------------------
## retourne 1 si le nom du fichier d entree est valide
# @param  file     : Chemin complet vers fichier
# @return bool
#
# @brief
# ::bdi_tools_reports::is_good_filename "SKYBOT_107_Camilla.2015-04-20.Audela_BDI_2015-05-17T18:02:00_CEST.info.txt"
# retourne 1
# ::bdi_tools_reports::is_good_filename "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.readme.txt"
# retourne 0
#
proc ::bdi_tools_reports::good_filename_to_list { file } {

   if {[::bdi_tools_reports::is_good_filename $file]==1} {
      set r [split $file "."]
      lassign $r obj date batch type ext
      return [list $obj $date $batch $type $ext]
   }
   return -code 1 "file not good"
}


#------------------------------------------------------------
## retourne 1 si le batch est un batch
#
# @param  batch
# @return bool
#
# @brief
# ::bdi_tools_reports::is_batch "Audela_BDI_2015-05-17T18:02:00_CEST"
# retourne 1
# ::bdi_tools_reports::is_batch "DateObs.2015-04-21.Obj.SKYBOT_107_Camilla.submit.no.Batch.Audela_BDI_2015-04-27T21:59:42_CEST.readme.txt"
# retourne 0
#
proc ::bdi_tools_reports::is_batch { batch } {
   if { [regexp {^Audela_BDI_(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)} $batch dateiso aa mm jj h m s] } {
      return 1
   }
   return 0
}

proc ::bdi_tools_reports::get_batch {  } {
   return [clock format [clock scan now] -format "Audela_BDI_%Y-%m-%dT%H:%M:%S_%Z"]
}




#------------------------------------------------------------
## lecture des info astrometrique
# @param  file
# @return void
#
proc ::bdi_tools_reports::get_info_astrom_txt { file } {


   #return [list obj $obj type $type firstdate $firstdate batch $batch nbpts $nbpts submit_mpc $submit_mpc iau_code $iau_code \
   #             subscriber $subscriber address $address mail $mail software $software observers $observers reduction $reduction \
   #             instrument $instrument nb_dates $nb_dates duration $duration ref_catalogue $refcata nb_ref_stars $nb_ref_stars \
   #             deg_polynom $deg_polynom use_refraction $use_refraction use_eop $use_eop use_debias $use_debias res_max_ref_stars $res_max_refstars \
   #             res_min_ref_stars $res_min_refstars res_mean_ref_stars $res_mean_refstars res_std_ref_stars $res_std_refstars \
   #             fwhm_mean $fwhm_mean fwhm_std $fwhm_std mag_mean $mag_mean mag_std $mag_std mag_amp $mag_amp ra_mean $ra_mean \
   #             ra_std $ra_std dec_mean $dec_mean dec_std $dec_std residuals_mean $residus_mean residuals_std $residus_std \
   #             omc_mean $omc_mean omc_std $omc_std omc_x_mean $omc_x_mean omc_y_mean $omc_y_mean omc_x_std $omc_x_std \
   #             omc_y_std $omc_y_std comment $comment]

   array unset tab
   set searchlist [list iau_code          "IAU code"            \
                        subscriber        "Subscriber"          \
                        address           "Address"             \
                        mail              "Mail"                \
                        software          "Software"            \
                        observers         "Observers"           \
                        reduction         "Reduction"           \
                        instrument        "Instrument"          \
                        nbdates           "Nb of dates"         \
                        duration          "Duration"        \
                        ref_catalogue     "Ref\. catalogue"      \
                        nb_ref_stars      "Nb Ref\. Stars"       \
                        deg_polynom       "Degre polynom"       \
                        use_refraction    "Refraction"          \
                        use_eop           "EOP correction"      \
                        res_max_ref_stars "Res max Ref Stars"   \
                        res_min_ref_stars "Res min Ref Stars"   \
                        res_mean_ref_stars "Res moy Ref Stars"   \
                        res_std_ref_stars "Res std Ref Stars"   \
                        mag_mean          "Magnitude   "           \
                        mag_std           "Magnitude STD"       \
                        mag_amp           "Magnitude Ampl"      \
                        fwhm_mean         "FWHM .arcsec"       \
                        fwhm_std          "FWHM STD"   \
                        ra_mean           "Right Asc"    \
                        dec_mean          "Declination"   \
                        ra_std            "RA STD"        \
                        dec_std           "DEC STD"       \
                        residus_mean      "Residus .mas"       \
                        residus_std       "Residus STD"   \
                        omc_mean          "OmC .mas"           \
                        omc_std           "OmC STD"       \
                        omc_x_mean        "OmC X  "     \
                        omc_y_mean        "OmC Y  "     \
                        omc_x_std         "OmC X STD"     \
                        omc_y_std         "OmC Y STD"     \
                     ]

   set chan [open $file r]

   set lecture 0
   while {[gets $chan line] >= 0} {

      if {!$lecture} {
         if {[regexp -- {^\#\$\+} $line]} {
            gren_info "on demarre la lecture\n"
            set lecture 1&
         }
         continue
      }

      if {[regexp -- {^\#\$\-} $line]} {
         gren_info "on arrete la lecture\n"
         break
      }

      foreach {x y} $searchlist {
         set r [regexp -all -inline -- "^\# $y.*= (.*)" $line] ; #"
         if {$r!=""} {
            set tab($x) [lindex $r 1]
            gren_erreur "OOO $x = $tab($x)\n"
            break
         }
      }

   }
   close $chan

   gren_info "get_info_astrom_txt [array get tab]\n"

   return [array get tab]

}


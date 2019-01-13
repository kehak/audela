

   #--------------------------------------------------------------------------------
   ## Recuperation des champs pour la construction des header des rapports
   #  @return void
   #
   proc ::bdi_gui_planetes::report_get_header {  } {

      global bddconf
      global conf

      set idframe $::bdi_gui_planetes::scrollbar
      set bufNo $::bdi_gui_planetes::buffer_list(frame2buf,$idframe)
      
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,rapporteur)] } {
         set ::bdi_gui_planetes::widget(info,rapporteur) $conf(bddimages,photometry,rapport,rapporteur)
      } else {
         set ::bdi_gui_planetes::widget(info,rapporteur) ""
      }
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,adresse)] } {
         set ::bdi_gui_planetes::widget(info,adresse) $conf(bddimages,photometry,rapport,adresse)
      } else {
         set ::bdi_gui_planetes::widget(info,adresse) ""
      }
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,mail)] } {
         set ::bdi_gui_planetes::widget(info,mail) $conf(bddimages,photometry,rapport,mail)
      } else {
         set ::bdi_gui_planetes::widget(info,mail) ""
      }
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,reduc)] } {
         set ::bdi_gui_planetes::widget(info,reduc) $conf(bddimages,photometry,rapport,reduc)
      } else {
         set ::bdi_gui_planetes::widget(info,reduc) ""
      }
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,filtre)] } {
         set ::bdi_gui_planetes::widget(info,filtre) $conf(bddimages,photometry,rapport,filtre)
      } else {
         set ::bdi_gui_planetes::widget(info,filtre) ""
      }
      # Champ pour rapport
      if { [info exists conf(bddimages,photometry,rapport,filtre_nfo)] } {
         set ::bdi_gui_planetes::widget(info,filtre_nfo) $conf(bddimages,photometry,rapport,filtre_nfo)
      } else {
         set ::bdi_gui_planetes::widget(info,filtre_nfo) ""
      }

      set ::bdi_gui_planetes::widget(info,uai_code)    [string trim [lindex [buf$bufNo getkwd "IAU_CODE"] 1] ]
      set ::bdi_gui_planetes::widget(info,rapporteur)  [string trim $::bdi_gui_planetes::widget(info,rapporteur) ]
      set ::bdi_gui_planetes::widget(info,adresse)     [string trim $::bdi_gui_planetes::widget(info,adresse) ]
      set ::bdi_gui_planetes::widget(info,mail)        [string trim $::bdi_gui_planetes::widget(info,mail) ]
      set ::bdi_gui_planetes::widget(info,observ)      [string trim [lindex [buf$bufNo getkwd "OBSERVER"] 1] ]
      set ::bdi_gui_planetes::widget(info,reduc)       [string trim $::bdi_gui_planetes::widget(info,reduc) ]
      set ::bdi_gui_planetes::widget(info,instru)      [string trim [lindex [buf$bufNo getkwd "INSTRUME"] 1] ]
      set ::bdi_gui_planetes::widget(info,cata)        [string trim [lindex [buf$bufNo getkwd "BDDIMAGES CATAASTROM"] 1] ]
      set ::bdi_gui_planetes::widget(info,batch)       [string trim [::bdi_tools_reports::get_batch] ]
      set ::bdi_gui_planetes::widget(info,filtre)      [string trim $::bdi_gui_planetes::widget(info,filtre) ]
      set ::bdi_gui_planetes::widget(info,filtre_nfo)  [string trim $::bdi_gui_planetes::widget(info,filtre_nfo) ]
      
      if {$::bdi_gui_planetes::widget(info,instru) == ""} {
         set ::bdi_gui_planetes::widget(info,instru) "0.6-m f/8 reflector + CCD"
      }
      return
   }







   #--------------------------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::report_object_create {  } {

      global bddconf

      set pass 0
      set ::bdi_gui_planetes::widget(info,obj_name) [string trim $::bdi_gui_planetes::widget(info,obj_name) ]
      
      if {$::bdi_gui_planetes::widget(info,obj_name) == ""} {set pass 1}
      
      if {$pass} {
         tk_messageBox -message  "Le nom de l'objet n'est pas correct" -type ok
         return
      }
      set file [file join $bddconf(dirreports) NEWASTER $::bdi_gui_planetes::widget(info,obj_name)]

      if {[file exists $file]} {
         tk_messageBox -message  "L'objet \"$::bdi_gui_planetes::widget(info,obj_name)\" existe" -type ok
         return
      }
      
      set err [tk_messageBox -message  "L'objet \"$::bdi_gui_planetes::widget(info,obj_name)\" va etre cree. En etes vous sur ?" -type okcancel]
      if {$err=="ok"} {
         set err [catch {file mkdir $file} msg]
         if {$err} {
            gren_erreur "Erreur : num = $err ; msg = $msg\n"
            tk_messageBox -message  "Erreur de creation du nouvel objet. Message dans la console..." -type ok
            return
         } else {
            tk_messageBox -message  "le nouvel objet a ete cree." -type ok
            return
         }
      }
      
      return
   }




   #--------------------------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::report_object_select {  } {

      global bddconf

      set dir [tk_chooseDirectory \
              -initialdir [file join $bddconf(dirreports) NEWASTER] \
              -title "Selectionner un objet dans la liste" \
              -mustexist true \
              ]
      
      set err 0

      if {$dir eq ""} {set err 1}
      
      set racine_ref [file join $bddconf(dirreports) NEWASTER]
      set racine [file dirname $dir]
      if {$racine != $racine_ref} {set err 2}
      
      
      
      if {$err} {
         gren_erreur "Erreur $err : object selectionne = [file tail $dir]\n"
         tk_messageBox -message  "Erreur de selection du nouvel objet. Message dans la console..." -type ok
      } else {
         set ::bdi_gui_planetes::widget(info,obj_name) [file tail $dir]
         gren_info "Selection de l objet : $::bdi_gui_planetes::widget(info,obj_name)\n"
      }
      return
   }


   #--------------------------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::report_verif_head {  } {

      set rapport_uai_code   $::bdi_gui_planetes::widget(info,uai_code)  
      set rapport_rapporteur $::bdi_gui_planetes::widget(info,rapporteur)
      set rapport_adresse    $::bdi_gui_planetes::widget(info,adresse)   
      set rapport_mail       $::bdi_gui_planetes::widget(info,mail)      
      set rapport_observ     $::bdi_gui_planetes::widget(info,observ)    
      set rapport_reduc      $::bdi_gui_planetes::widget(info,reduc)     
      set rapport_instru     $::bdi_gui_planetes::widget(info,instru)    
      set rapport_cata       $::bdi_gui_planetes::widget(info,cata)      
      set rapport_batch      $::bdi_gui_planetes::widget(info,batch)     
      set rapport_filtre     $::bdi_gui_planetes::widget(info,filtre)     
      set rapport_filtre_nfo $::bdi_gui_planetes::widget(info,filtre_nfo)     

      if {$rapport_uai_code   == ""} {return -code 1}
      if {$rapport_rapporteur == ""} {return -code 1}
      if {$rapport_adresse    == ""} {return -code 1}
      if {$rapport_mail       == ""} {return -code 1}
      if {$rapport_observ     == ""} {return -code 1}
      if {$rapport_reduc      == ""} {return -code 1}
      if {$rapport_instru     == ""} {return -code 1}
      if {$rapport_cata       == ""} {return -code 1}
      if {$rapport_batch      == ""} {return -code 1}
      if {$rapport_filtre     == ""} {return -code 1}
      if {$rapport_filtre_nfo == ""} {return -code 1}
      return
   }






   proc ::bdi_gui_planetes::report_create_only_mpc_obsolete {  } {

      global bddconf

      set err [catch { ::bdi_gui_planetes::report_verif_head } msg ]
      if {$err} {
         tk_messageBox -message  "Certains champs sont errones ou incomplets. Veuillez les completer avant d enregistrer le rapport" -type ok
         return
      }

      set dir      [file join $bddconf(dirreports) NEWASTER]
      set batch    $::bdi_gui_planetes::widget(info,batch)
      set obj_name $::bdi_gui_planetes::widget(info,obj_name)
      set filename_mpc  [file join $dir $obj_name "$obj_name.$batch.mpc"]

      # MPC
      gren_info "Creation Rapport MPC : $filename_mpc\n"
      
      set form "%12s%1s%1s%1s%-17s%-12s%-12s        %6s      %3s"
      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"

      set nbmesure [$::bdi_gui_planetes::data_source size]
      set handler [open $filename_mpc "w"]

      set rapport_uai_code   $::bdi_gui_planetes::widget(info,uai_code)  
      set rapport_rapporteur $::bdi_gui_planetes::widget(info,rapporteur)
      set rapport_adresse    $::bdi_gui_planetes::widget(info,adresse)   
      set rapport_mail       $::bdi_gui_planetes::widget(info,mail)      
      set rapport_observ     $::bdi_gui_planetes::widget(info,observ)    
      set rapport_reduc      $::bdi_gui_planetes::widget(info,reduc)     
      set rapport_instru     $::bdi_gui_planetes::widget(info,instru)    
      set rapport_cata       $::bdi_gui_planetes::widget(info,cata)      
      set rapport_batch      $::bdi_gui_planetes::widget(info,batch)     
      set rapport_filtre     $::bdi_gui_planetes::widget(info,filtre)     
      set rapport_filtre_nfo $::bdi_gui_planetes::widget(info,filtre_nfo)     

      append entete "COD $rapport_uai_code \n"
      append entete "CON $rapport_rapporteur \n"
      append entete "CON $rapport_adresse \n"
      append entete "CON $rapport_mail \n"
      append entete "OBS $rapport_observ\n"
      append entete "MEA $rapport_reduc\n"
      append entete "TEL $rapport_instru\n"
      append entete "NET $rapport_cata\n"
      append entete "BND $rapport_filtre\n"
      append entete "COM Filter : $rapport_filtre_nfo\n"
      append entete "COM Software Reduction : Audela (http://www.audela.org)\n"
      append entete "ACK Batch $rapport_batch\n"
      append entete "AC2 $rapport_mail\n"
      append entete "NUM $nbmesure"

      puts $handler $entete
      set first 1
      set flag " "

      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {
            
            if {$first} {
               set first 0
               set firstdate $::bdi_gui_planetes::tab_mesure_data($id,dateiso_mp)
               if {$::bdi_gui_planetes::widget(report,decouverte)} {
                  set flag "*"
               }
            } else {
               set flag " "
            }
            
            set jd_mp   $::bdi_gui_planetes::tab_mesure_data($id,jd_mp)
            set ra      $::bdi_gui_planetes::tab_mesure_data($id,ra) 
            set dec     $::bdi_gui_planetes::tab_mesure_data($id,dec)
            set mag     $::bdi_gui_planetes::tab_mesure_data($id,mag)
            set filtre  [string range $::bdi_gui_planetes::tab_mesure_data($id,filtre) 0 0]

            set object  [::bdi_tools_mpc::convert_name $obj_name]
            set datempc [::bdi_tools_mpc::convert_jd   $jd_mp]
            set ra_hms  [::bdi_tools_mpc::convert_hms  $ra]
            set dec_dms [::bdi_tools_mpc::convert_dms  $dec]
            set magmpc  [::bdi_tools_mpc::convert_mag  $mag $filtre]
            set obsuai  $rapport_uai_code

            set txt [format $form $object $flag $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $obsuai]
            puts $handler $txt

         }
      }
      close $handler

      if {[file exists $filename_mpc] } {
         tk_messageBox -message "Le rapport MPC a ete crees" -type ok
      } else {
         tk_messageBox -message "Il y a eu un probleme a la creation du rapport MPC" -type ok
      }

      return
   }
   #--------------------------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::report_create {  } {

      global bddconf
      
      set err [catch { ::bdi_gui_planetes::report_verif_head } msg ]
      if {$err} {
         tk_messageBox -message  "Certains champs sont errones ou incomplets. Veuillez les completer avant d enregistrer le rapport" -type ok
         return
      }
      
      # Initialisation des variables
      set dir      [file join $bddconf(dirreports) NEWASTER]
      set batch    $::bdi_gui_planetes::widget(info,batch)
      set obj_name $::bdi_gui_planetes::widget(info,obj_name)
      set nbmesure [$::bdi_gui_planetes::data_source size]

      set filename_mpc  [file join $dir $obj_name "$obj_name.$batch.mpc"]
      set filename_csv  [file join $dir $obj_name "$obj_name.$batch.csv"]
      set filename_info [file join $dir $obj_name "$obj_name.$batch.info"]
      
      set rapport_uai_code   $::bdi_gui_planetes::widget(info,uai_code)  
      set rapport_rapporteur $::bdi_gui_planetes::widget(info,rapporteur)
      set rapport_adresse    $::bdi_gui_planetes::widget(info,adresse)   
      set rapport_mail       $::bdi_gui_planetes::widget(info,mail)      
      set rapport_observ     $::bdi_gui_planetes::widget(info,observ)    
      set rapport_reduc      $::bdi_gui_planetes::widget(info,reduc)     
      set rapport_instru     $::bdi_gui_planetes::widget(info,instru)    
      set rapport_cata       $::bdi_gui_planetes::widget(info,cata)      
      set rapport_batch      $::bdi_gui_planetes::widget(info,batch)     
      set rapport_filter     $::bdi_gui_planetes::widget(info,filtre)      
      set rapport_filter_com $::bdi_gui_planetes::widget(info,filtre_nfo)     

      # Premiere date
      set firstdate ""
      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {
            set firstdate $::bdi_gui_planetes::tab_mesure_data($id,dateiso_mp)
            break
         }
      }
      if {$firstdate == ""} {
         tk_messageBox -message  "Erreur : Le rapport ne contient pas de mesures" -type ok
         return
      }

      # INFO
      gren_info "Creation Rapport INFO : $filename_info\n"

      set handler [open $filename_info "w"]

      set entete ""
      append entete [format "firstdate            := %-70s := Iso date of the day for the first date in the list\n" $firstdate   ]
      append entete [format "batch                := %-70s := batch code\n"                    $rapport_batch      ]
      append entete [format "submit_mpc           := %-70s := Report submitted to MPC\n"       "no"                ]
      append entete [format "iau_code             := %-70s := IAU code for the observatory\n"  $rapport_uai_code   ]
      append entete [format "subscriber           := %-70s := Subscriber \n"                   $rapport_rapporteur ]
      append entete [format "address              := %-70s := Address    \n"                   $rapport_adresse    ]
      append entete [format "mail                 := %-70s := Email      \n"                   $rapport_mail       ]
      append entete [format "software             := %-70s := Software   \n"                   $::bdi_gui_planetes::software ]
      append entete [format "observers            := %-70s := Observers  \n"                   $rapport_observ     ]
      append entete [format "reduction            := %-70s := Reduction  \n"                   $rapport_reduc      ]
      append entete [format "instrument           := %-70s := Instrument \n"                   $rapport_instru     ]
      append entete [format "nb_dates             := %-70s := Nb of dates\n"                   $nbmesure           ]
      append entete [format "ref_catalogue        := %-70s := Reference catalogue\n"           $rapport_cata       ]
      append entete [format "band                 := %-70s := Filter designation\n"            $rapport_filter     ]
      append entete [format "filter               := %-70s := Filter information\n"            $rapport_filter_com ]

      puts $handler $entete
      close $handler


      # CSV
      gren_info "Creation Rapport CSV : $filename_csv\n"

      set form "%15s, %23s, %18s, %10s, %10s, %6s, %6s, %5s"

      set handler [open $filename_csv "w"]

      set txt [format $form obj_id dateiso_mp jd_mp ra dec mag filtre uai ]
      puts $handler $txt
      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {
            
            set dateiso_mp $::bdi_gui_planetes::tab_mesure_data($id,dateiso_mp)
            set jd_mp      $::bdi_gui_planetes::tab_mesure_data($id,jd_mp)
            set ra         $::bdi_gui_planetes::tab_mesure_data($id,ra) 
            set dec        $::bdi_gui_planetes::tab_mesure_data($id,dec)
            set mag        $::bdi_gui_planetes::tab_mesure_data($id,mag)
            set filtre  [string range $::bdi_gui_planetes::tab_mesure_data($id,filtre) 0 0]

            set txt [format $form $obj_name $dateiso_mp $jd_mp $ra $dec $mag $filtre $rapport_uai_code ]
            puts $handler $txt

         }
      }

      close $handler

      
      if {[file exists $filename_info] && [file exists $filename_csv] } {
         tk_messageBox -message "Les rapports ont ete crees" -type ok
      } else {
         tk_messageBox -message "Il y a eu un probleme a la creation des rapports" -type ok
      }
      return
   }







   #--------------------------------------------------------------------------------
   ## 
   #  @return void
   #  @todo routine devenue obsolete
   #
   proc ::bdi_gui_planetes::report_create_obsolete {  } {

      global bddconf
      gren_info "Creation Rapport MPC\n"


      set nbd 0
      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {
            incr nbd
         }
      }

      set form "%13s%1s%1s%-17s%-12s%-12s        %6s      %3s"
      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"


      set filempc [file join $bddconf(dirtmp) "mpc.mpc"]
      set handler [open $filempc "w"]

      set rapport_uai_code   181
      set rapport_rapporteur "F. Vachier"
      set rapport_adresse    "IMCCE, Obs de Paris,77 Av Denfert Rochereau 75014 Paris France "
      set rapport_mail       "vachier@imcce.fr"
      set rapport_observ     "F. Vachier, A. Klotz, J.P. Teng, A. Peyrot, P. Thierry, J. Berthier"
      set rapport_reduc      "F. Vachier"
      set rapport_instru     "0.6-m f/8 reflector + CCD"
      set rapport_cata       "UCAC4"
      set rapport_batch      "Audela_BDI_2017-07-10-1"


      set entete ""
      append entete "COD $rapport_uai_code \n"
      append entete "CON $rapport_rapporteur \n"
      if {[llength $rapport_adresse]>0} {
         append entete "CON $rapport_adresse \n"
      }
      if {[llength $rapport_mail] > 0} {
         append entete "CON $rapport_mail \n"
      }
      append entete "OBS $rapport_observ\n"
      append entete "MEA $rapport_reduc\n"
      append entete "TEL $rapport_instru\n"
      append entete "NET $rapport_cata\n"
      #append entete "BND L\n"

      append entete "COM Software Reduction : Audela (http://www.audela.org)\n"
      append entete "ACK Batch $rapport_batch\n"
      append entete "AC2 $rapport_mail\n"
      append entete "NUM $nbd"

      puts $handler $entete


      for {set id 1} {$id <= $::bdi_gui_planetes::widget(nbimages)} { incr id} {
         if {! [info exists ::bdi_gui_planetes::tab_mesure_index($id)] } {continue}
         if {$::bdi_gui_planetes::tab_mesure_index($id)} {

            set dateiso $::bdi_gui_planetes::tab_mesure_data($id,dateiso)
            set jd      $::bdi_gui_planetes::tab_mesure_data($id,jd)
            set ra      $::bdi_gui_planetes::tab_mesure_data($id,ra) 
            set dec     $::bdi_gui_planetes::tab_mesure_data($id,dec)
            set mag     $::bdi_gui_planetes::tab_mesure_data($id,mag)
            set name "IMG_2018M1"

            set object  [::bdi_tools_mpc::convert_name $name]
            set datempc [::bdi_tools_mpc::convert_jd   $jd]
            set ra_hms  [::bdi_tools_mpc::convert_hms  $ra]
            set dec_dms [::bdi_tools_mpc::convert_dms  $dec]
            set magmpc  [::bdi_tools_mpc::convert_mag  $mag "L"]
            set obsuai  $rapport_uai_code

            set txt [format $form $object $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $obsuai]
            puts $handler $txt

            set line [format "%23s, %10s, %10s" $dateiso $ra $dec $mag]
            gren_info "$line\n"

         }
      }

      #389278         C2015 04 20.8890 015 54 50.9 1-08 34 18. 6         20. 8R      181
      close $handler
      
      return
   }

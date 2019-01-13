## @file bdi_gui_reports_newaster.voir.tcl
#  @brief     Affichage des rapport MPC
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_newaster.voir.tcl]
#  @endcode

# $Id: bdi_gui_reports_newaster.voir.tcl 13117 2016-05-21 02:00:00Z fredvachier $


   proc ::bdi_tools_reports::voir_rapport_mpc { } {


      set curselection [$::bdi_tools_reports::data_newaster_obs curselection]
      set nb [llength $curselection]
      if {$nb == 0 } {return}
      
      array unset ::bdi_tools_reports::voir_rapport_mpc_tab
      
      gren_info "--\n"
      foreach selection $curselection {
         lassign [$::bdi_tools_reports::data_newaster_obs get $selection ] object batch firstdate nb_dates submit_mpc angle_obs vitesse_obs angle_calc vitesse_calc omc id_obj id_info

         gren_info "firstdate  = $firstdate  \n"
         gren_info "nb_dates   = $nb_dates   \n"
         gren_info "submit_mpc = $submit_mpc \n"
         gren_info "id_obj     = $id_obj     \n"
         gren_info "id_info    = $id_info    \n"
         gren_info "--\n"

         # Designation mpc        
         array set gfo $::bdi_tools_reports::tab_newaster($id_obj,gfo)

         for {set i 1} {$i <= $gfo(designation,nb)} {incr i} {
            if {$gfo(designation,$i,fmpc) == 1} {
               set id_mpc $gfo(designation,$i,name)
               break
            } 
         }
         
         
         lappend ::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) [list $firstdate $id_info]
         set ::bdi_tools_reports::voir_rapport_mpc_tab($id_info,firstdate)  $firstdate
         set ::bdi_tools_reports::voir_rapport_mpc_tab($id_info,nb_dates)   $nb_dates
         set ::bdi_tools_reports::voir_rapport_mpc_tab($id_info,submit_mpc) $submit_mpc
         set ::bdi_tools_reports::voir_rapport_mpc_tab(id_obj)              $id_obj
         set ::bdi_tools_reports::voir_rapport_mpc_tab(id_mpc)              $id_mpc
      }      
      
      set ::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) [lsort -dictionary -increasing -index 0 $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate)] 

      ::bdi_gui_reports::voir_rapport_mpc_create_dialog
      return
   }     








   proc ::bdi_gui_reports::newaster_voir_rapport_mpc_fermer { } {

      global conf bddconf

      set bddconf(geometry_reports,newaster_voir_rapport_mpc) [ wm geometry $::bdi_gui_reports::widget(appli,newaster,voir_rapport_mpc) ]
      set conf(bddimages,geometry_reports,newaster_voir_rapport_mpc) $bddconf(geometry_reports,newaster_voir_rapport_mpc)
      destroy $::bdi_gui_reports::widget(appli,newaster,voir_rapport_mpc)

      return
   }     





   proc ::bdi_gui_reports::newaster_voir_rapport_mpc_relance { } {

      ::console::clear
      ::bddimages::ressource
      ::bdi_gui_reports::newaster_voir_rapport_mpc_fermer
      ::bdi_gui_reports::voir_rapport_mpc_create_dialog

   }



   proc ::bdi_gui_reports::voir_rapport_mpc_create_dialog { } {

      global audace caption color
      global conf bddconf

      set widthlab 30
      set widthentry 30
      set ::bdi_gui_reports::widget(appli,newaster,voir_rapport_mpc) .newaster_voir_rapport_mpc
      set fen $::bdi_gui_reports::widget(appli,newaster,voir_rapport_mpc)

      #--- Initialisation des parametres
      set ::bdi_gui_reports::mpc_to      "obs@cfa.harvard.edu;$conf(bddimages,astrometry,reports,mail)"
      set ::bdi_gui_reports::mpc_subject ""

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports,newaster_voir_rapport_mpc) ] } {
         set conf(bddimages,geometry_reports,newaster_voir_rapport_mpc) "900x600+400+800"
      }
      set bddconf(geometry_reports,newaster_voir_rapport_mpc) $conf(bddimages,geometry_reports,newaster_voir_rapport_mpc)

      #--- Declare la GUI
      if { [ winfo exists $fen ] } {
         ::bdi_gui_reports::newaster_voir_rapport_mpc_fermer
         ::bdi_gui_reports::voir_rapport_mpc_create_dialog
         return
      }

      #--- GUI
      toplevel $fen -class Toplevel
      wm geometry $fen $bddconf(geometry_reports,newaster_voir_rapport_mpc)
      wm resizable $fen 1 1
      wm title $fen "Voir rapport MPC"
      wm protocol $fen WM_DELETE_WINDOW { ::bdi_gui_reports::newaster_voir_rapport_mpc_fermer }

      set frm $fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $fen -side top -expand yes -fill both 
      set ::bdi_gui_reports::widget(frame,newaster,voir_rapport_mpc) $frm

         # Relance
         set buttons [frame $frm.buttons ]
         pack $buttons -in $frm -side top -anchor e

            button $buttons.relance -text "Relance" \
                                   -command "::bdi_gui_reports::newaster_voir_rapport_mpc_relance"
            button $buttons.ressource -text "Ressource" \
                                   -command "::console::clear ; ::bddimages::ressource"

            grid $buttons.ressource $buttons.relance -in $buttons -sticky w

         # button2
         set buttons [frame $frm.buttons2 ]
         pack $buttons -in $frm -side top -anchor w

            button $buttons.relance -text "Mail" \
                                   -command "::bdi_gui_reports::newaster_voir_rapport_mpc_mail"

            grid $buttons.relance -in $buttons -sticky w

         # Observations au format MPC
         set wdth 20
         set block [frame $frm.exped  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $frm -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Destinataire : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_to
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         set block [frame $frm.subj  -borderwidth 0 -cursor arrow -relief groove]
         pack $block  -in $frm -side top -expand 0 -fill x -padx 2 -pady 5

               label  $block.lab -text "Sujet : " -borderwidth 1 -width $wdth
               pack   $block.lab -side left -padx 3 -pady 1 -anchor w

               entry  $block.val -relief sunken -width 80 -textvariable ::bdi_gui_reports::mpc_subject
               pack   $block.val -side left -padx 3 -pady 1 -anchor w

         label  $frm.labobs -text "Observations au format MPC"
         pack $frm.labobs -in $frm -side top -anchor w

         set ::bdi_gui_reports::voir_rapport_mpc_obs $frm.mpc_obs
         text $::bdi_gui_reports::voir_rapport_mpc_obs -height 10 -width 80 \
              -xscrollcommand "$::bdi_gui_reports::voir_rapport_mpc_obs.xscroll set" \
              -yscrollcommand "$::bdi_gui_reports::voir_rapport_mpc_obs.yscroll set" \
              -wrap none
         pack $::bdi_gui_reports::voir_rapport_mpc_obs -in $frm -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_gui_reports::voir_rapport_mpc_obs.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::voir_rapport_mpc_obs xview"
         pack $::bdi_gui_reports::voir_rapport_mpc_obs.xscroll -side bottom -fill x

         scrollbar $::bdi_gui_reports::voir_rapport_mpc_obs.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::voir_rapport_mpc_obs yview"
         pack $::bdi_gui_reports::voir_rapport_mpc_obs.yscroll -side right -fill y


         # button3
         set buttons [frame $frm.buttons3]
         pack $buttons -in $frm -side top -anchor e

            button $buttons.annule -text "Annuler" \
                                   -command "::bdi_gui_reports::newaster_voir_rapport_mpc_fermer"
            button $buttons.finalise -text "Finalise" \
                                   -command "::bdi_gui_reports::newaster_voir_rapport_mpc_finalise"

            grid $buttons.finalise $buttons.annule -in $buttons 




         $::bdi_gui_reports::voir_rapport_mpc_obs delete 0.0 end

         ::bdi_tools_reports::voir_rapport_mpc_build_data

      return
   }     




   proc ::bdi_gui_reports::newaster_voir_rapport_mpc_finalise { } {
      
      set msg ""
      append msg "Les action suivantes vont etre realisees :\n"
      append msg "- Sauvegarde au format MPC\n"
      append msg "- Mise a jour de la table\n"
      append msg "\n"
      append msg "En etes vous sur ?"
      set res [tk_messageBox -message $msg -type yesno]      
      if {$res != "yes"} {return}
      gren_info "Finalise le rapport MPC\n"

      # Sauve fichier au format MPC
      foreach x $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {
         lassign          $x firstdate id_info
         set id_obj       $::bdi_tools_reports::voir_rapport_mpc_tab(id_obj)
         set filename_mpc $::bdi_tools_reports::tab_newaster($id_obj,$id_info,mpc)         
         gren_info "Creation fichier $filename_mpc\n"
         set handler [open $filename_mpc "w"]
         puts $handler [$::bdi_gui_reports::voir_rapport_mpc_obs get 0.0 end]
         close $handler
      }
      
      # flag mpc yes
      foreach x $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {
         lassign          $x firstdate id_info
         set id_obj       $::bdi_tools_reports::voir_rapport_mpc_tab(id_obj)
         set file_info    $::bdi_tools_reports::tab_newaster($id_obj,$id_info,info)         
         ::bdi_tools_reports::read_info $file_info info
         set info(submit_mpc) "yes"
         ::bdi_tools_reports::create_info $file_info info
         set ::bdi_tools_reports::tab_newaster($id_obj,$id_info,submit_mpc) $info(submit_mpc)
      }

      # recharge API
      ::bdi_gui_reports::newaster_update_tables_from_id_obj $id_obj
      
      ::bdi_gui_reports::newaster_voir_rapport_mpc_fermer
      
      
      return
   }     




   proc ::bdi_gui_reports::newaster_voir_rapport_mpc_mail { } {

      global bddconf conf
      variable thunderbird "/usr/bin/thunderbird"

      set to      $::bdi_gui_reports::mpc_to
      set subject $::bdi_gui_reports::mpc_subject

      set body [$::bdi_gui_reports::voir_rapport_mpc_obs get 0.0 end]
      #append body "\n"
      
      if {1} {
         gren_info "---\n"
         gren_info "MAIL:\n"
         gren_info "to:${to}\n"
         gren_info "subject:${subject}\n"
         gren_info "body:${body}\n"
         gren_info "---\n"
         gren_info "thunderbird --compose to='${to}',subject='${subject}',body='${body}'\n"
         gren_info "---\n"
      }

      if {1} {
         set err [catch {exec $thunderbird --compose "to='${to}',subject='${subject}',body='${body}'"} msg]
         if {$err != 0} {
            gren_erreur "ERROR: unable to launch thunderbird ($msg)"
         }
      }

#      set desti "fv@imcce.fr"
#      set batch "batch"
#      set strl  "strl"
#     ::bdi_tools::sendmail::compose_with_thunderbird $desti $batch $strl


      return
   }     











   proc ::bdi_tools_reports::voir_rapport_mpc_build_data { } {

      $::bdi_gui_reports::voir_rapport_mpc_obs delete 0.0 end

      # Check
      set check_nb_dates "no"
      set check_submit   "ok"
      set check_entete   "ok"

      # Construction des entetes
      set nb_total 0
      gren_info "--\n"
      foreach x   $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {

         lassign $x firstdate id_info
         set id_obj     $::bdi_tools_reports::voir_rapport_mpc_tab(id_obj)
         set id_mpc     $::bdi_tools_reports::voir_rapport_mpc_tab(id_mpc)
         set nb_dates   $::bdi_tools_reports::voir_rapport_mpc_tab($id_info,nb_dates)
         set submit_mpc $::bdi_tools_reports::voir_rapport_mpc_tab($id_info,submit_mpc)

         gren_info "firstdate  = $firstdate  \n"
         gren_info "nb_dates   = $nb_dates   \n"
         gren_info "submit_mpc = $submit_mpc \n"
         gren_info "id_obj     = $id_obj     \n"
         gren_info "id_info    = $id_info    \n"
         gren_info "id_mpc     = $id_mpc     \n"
         
         incr nb_total $nb_dates
         if {$submit_mpc == "yes"} {set check_submit "no"}
         
#         ::bdi_tools_reports::read_info $id_info info
#         gren_info "id_info    = [array get info]    \n"
         
         set file_info      $::bdi_tools_reports::tab_newaster($id_obj,$id_info,info)         
         set mpc            $::bdi_tools_reports::tab_newaster($id_obj,$id_info,mpc)         
         
         ::bdi_tools_reports::read_info $file_info info
         gren_info "info    = [array get info]   \n"
         
         gren_info "--\n"
      }



      # Verification des changement des header
      gren_info "-- Verification des changement des header\n"
      
      set cpt -1
      foreach x $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {
         
         incr cpt
         
         lassign $x firstdate id_info
         
         if {$cpt == 0} {
            set id_info_ref $id_info
            continue
         }
         
         foreach key [array names info] {
             if {$key in [list mpc batch csv info firstdate nb_dates]} {continue}
             if { $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,$key) != $::bdi_tools_reports::tab_newaster($id_obj,$id_info,$key) } {
                gren_erreur "$key change :: $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,$key) != $::bdi_tools_reports::tab_newaster($id_obj,$id_info,$key)\n"
                set check_entete   "no"
             }
         }

      }    
      set cpt -1
      
      gren_info "Fichiers info (le premier etant la reference)\n"
      foreach x $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {
         incr cpt
         lassign $x firstdate id_info
         set file [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $id_info]
         if {$cpt == 0} {
            gren_info "$file\n"
            continue
         }
         gren_info "$file\n"
      }

      # Affichage de la ref
      gren_info "-- Affichage de la ref\n"
      set ::bdi_gui_reports::mpc_subject "\[OBSERVATION\]\[MPC\]\[$::bdi_tools_reports::voir_rapport_mpc_tab(id_mpc)\] $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,batch)"

      set entete ""
      append entete "COD $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,iau_code)\n"
      append entete "CON $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,subscriber)\n"    
      append entete "CON $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,address)\n"       
      append entete "CON \[$::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,mail)\]\n"          
      append entete "OBS $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,observers)\n"     
      append entete "MEA $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,reduction)\n"     
      append entete "TEL $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,instrument)\n"    
      append entete "NET $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,ref_catalogue)\n" 
      append entete "BND $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,band)\n"
      append entete "COM Filter : $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,filter)\n"
      append entete "COM $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,software)\n"
      append entete "ACK Batch $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,batch)\n"
      append entete "AC2 $::bdi_tools_reports::tab_newaster($id_obj,$id_info_ref,mail)\n"
      append entete "NUM $nb_total\n"
      $::bdi_gui_reports::voir_rapport_mpc_obs insert end $entete
 
 



      # Affichage data MPC

      set form "%12s%1s%1s%1s%-17s%-12s%-12s        %6s      %3s\n"
      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"
      set flag " "



      gren_info "--\n"
      set cpt 0
      foreach x   $::bdi_tools_reports::voir_rapport_mpc_tab(index,firstdate) {
         lassign $x firstdate id_info
         set id_obj $::bdi_tools_reports::voir_rapport_mpc_tab(id_obj)
         set id_mpc $::bdi_tools_reports::voir_rapport_mpc_tab(id_mpc)

         # lecture entete MPC
         set csv      $::bdi_tools_reports::tab_newaster($id_obj,$id_info,csv)
         set iau_code $::bdi_tools_reports::tab_newaster($id_obj,$id_info,iau_code)
         ::bdi_tools_reports::read_mesure_csv $csv mesure
         
         # lecture data MPC
         # transformation au format mpc
         foreach jd $mesure(index_jd) {
            incr cpt
            set ra     $mesure($jd,ra)
            set dec    $mesure($jd,dec)
            set mag    $mesure($jd,mag)
            set filtre "L"
            #gren_info "$jd  $ra  $dec  $mag  $filtre \n"

            set object  [::bdi_tools_mpc::convert_name $id_mpc]
            set datempc [::bdi_tools_mpc::convert_jd   $jd]
            set ra_hms  [::bdi_tools_mpc::convert_hms  $ra]
            set dec_dms [::bdi_tools_mpc::convert_dms  $dec]
            set magmpc  [::bdi_tools_mpc::convert_mag  $mag $filtre]

            set txt [format $form $object $flag $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $iau_code]
            $::bdi_gui_reports::voir_rapport_mpc_obs insert end $txt

         }
      }
      $::bdi_gui_reports::voir_rapport_mpc_obs insert end "\n"

      # check
      if {$cpt == $nb_total} {set check_nb_dates "ok"}
      
      
      gren_info "--\n"
      gren_info " check_nb_dates = $check_nb_dates    \n"
      gren_info " check_submit   = $check_submit      \n"
      gren_info " check_entete   = $check_entete      \n"
      gren_info "--\n"


      return
   }     

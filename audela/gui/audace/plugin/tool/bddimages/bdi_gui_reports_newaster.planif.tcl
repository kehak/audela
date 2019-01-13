## @file bdi_gui_reports_newaster.tcl
#  @brief     GUI pour le traitement des rapports lies a la decouverte d un asteroide
#  @author    Frederic Vachier
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_reports_newaster.tcl]
#  @endcode

# $Id: bdi_gui_reports_newaster.tcl 13117 2016-05-21 02:00:00Z fredvachier $










   proc ::bdi_gui_reports::newaster_planif_fermer { } {

      global conf bddconf

      set bddconf(geometry_reports,newaster_planif) [ wm geometry $::bdi_gui_reports::widget(appli,newaster,planif) ]
      set conf(bddimages,geometry_reports,newaster_planif) $bddconf(geometry_reports,newaster_planif)
      destroy $::bdi_gui_reports::widget(appli,newaster,planif)
   }










   proc ::bdi_gui_reports::newaster_planif_relance_orbfit { } {

      ::console::clear
      ::bddimages::ressource
      ::bdi_gui_reports::newaster_planif_fermer
      ::bdi_gui_reports::build_gui_newaster_planif_orbfit

   }









   proc ::bdi_gui_reports::newaster_planif_relance_MPC_NOEG { } {

      ::console::clear
      ::bddimages::ressource
      ::bdi_gui_reports::newaster_planif_fermer
      ::bdi_gui_reports::build_gui_newaster_planif_MPC_NOEG

   }








   proc ::bdi_gui_reports::newaster_planif_affiche_mpc { } {

      set id_obj $::bdi_gui_reports::newaster_planif_id_obj
      gren_info "id_obj = $id_obj \n"
      #gren_info "index_info = $::bdi_tools_reports::tab_newaster($id_obj,index_info) \n"

      set form "%12s%1s%1s%1s%-17s%-12s%-12s        %6s      %3s\n"
      # Constant parameters
      # - Note 1: alphabetical publishable note or (those sites that use program codes) an alphanumeric
      #           or non-alphanumeric character program code => http://www.minorplanetcenter.net/iau/info/ObsNote.html
      set note1 " "
      # - C = CCD observations (default)
      set note2 "C"
      set flag " "
      
      foreach id_info $::bdi_tools_reports::tab_newaster($id_obj,index_info) {
         set csv      $::bdi_tools_reports::tab_newaster($id_obj,$id_info,csv)
         set iau_code $::bdi_tools_reports::tab_newaster($id_obj,$id_info,iau_code)
         gren_info "csv = $csv \n"
         ::bdi_tools_reports::read_mesure_csv $csv mesure
         
         # transformation au format mpc
         foreach jd $mesure(index_jd) {
            set ra     $mesure($jd,ra)
            set dec    $mesure($jd,dec)
            set mag    $mesure($jd,mag)
            set filtre "L"
            #gren_info "$jd  $ra  $dec  $mag  $filtre \n"

            set object  [::bdi_tools_mpc::convert_name $id_obj]
            set datempc [::bdi_tools_mpc::convert_jd   $jd]
            set ra_hms  [::bdi_tools_mpc::convert_hms  $ra]
            set dec_dms [::bdi_tools_mpc::convert_dms  $dec]
            set magmpc  [::bdi_tools_mpc::convert_mag  $mag $filtre]

            set txt [format $form $object $flag $note1 $note2 $datempc $ra_hms $dec_dms $magmpc $iau_code]
            $::bdi_gui_reports::planif_mpc_obs insert end $txt
            gren_info "$txt\n"

         }

      }
      
   }











   proc ::bdi_gui_reports::newaster_planif_calcul { } {

      $::bdi_gui_reports::planif_results delete 0.0 end
      set id_obj $::bdi_gui_reports::newaster_planif_id_obj
      gren_info "id_obj = $id_obj \n"
      
      # construction de la table de donnees
      set data [split [$::bdi_gui_reports::planif_mpc_eph get 0.0 end] "\n" ]
      array unset tab_ephem
      #gren_info "--\n"
      set lmag "" 
      set date_valid ""
      foreach line $data {
         lassign $line y m j h hra mra sra ddec mdec sdec elong mag
         if {$y==""||$m==""||$j==""||$h==""||$hra==""||$mra==""||$sra==""||$ddec==""||$mdec==""||$sdec==""||$elong==""||$mag==""} {continue}
         lappend lmag $mag
         set ra "${hra}h${mra}m${sra}s"
         set dec "${ddec}d${mdec}m${sdec}s"
         set date "${y}-${m}-${j}T${h}:00:00"
         set jd  [mc_date2jd $date]
         set ra  [mc_angle2deg $ra]
         set dec [mc_angle2deg $dec]
         lappend tab_ephem(index)   $jd
         set tab_ephem($jd,dateiso) $date
         set tab_ephem($jd,ra)      $ra
         set tab_ephem($jd,dec)     $dec
         set date_valid $date
         #gren_info [format "%23s %8.5f %8.5f\n" $tab_ephem($jd,dateiso) $tab_ephem($jd,ra) $tab_ephem($jd,dec) ]
      }
      set mag [format "%0.1f" [::math::statistics::mean $lmag] ]
      #gren_info "--\n"
      set orig [lindex $tab_ephem(index) 0]
      foreach jd $tab_ephem(index) {
         set tab_ephem($jd,x) [expr $jd-$orig]
      }
      
      # Regression lineaire de alpha
      set xdata ""
      set ydata ""
      foreach jd $tab_ephem(index) {
         lappend xdata $tab_ephem($jd,x)
         lappend ydata $tab_ephem($jd,ra)
      }
      set r [::math::statistics::linear-model $xdata $ydata 1]
      lassign  $r a b ystdev coef_corr_r2 degfreedom err_a sign_level_a err_b sign_level_b 
      gren_info "Regression lineaire de alpha\n"
      gren_info "a             = $a \n"
      gren_info "b             = $b \n"
      gren_info "ystdev        = $ystdev \n"
      gren_info "coef_corr_r2  = $coef_corr_r2 \n"
      gren_info "degfreedom    = $degfreedom \n"
      gren_info "err_a         = $err_a \n"
      gren_info "sign_level_a  = $sign_level_a \n"
      gren_info "err_b         = $err_b \n"
      gren_info "sign_level_b  = $sign_level_b \n"
      set ra_a $a
      set ra_b $b
      set ra_a [expr  $ra_a  - $ra_b  * $orig ]
      gren_info [format "%23s RA   Diff(arcsec)\n" "date iso"]
      set err_ra ""
      foreach jd $tab_ephem(index) {
         set diff [ expr ($tab_ephem($jd,ra) - ( $ra_a + $ra_b * $jd )) * 3600.0]
         set tab_ephem($jd,err_ra) $diff
         gren_info [format "%23s %8.5f    %+.0f\n" $tab_ephem($jd,dateiso) $tab_ephem($jd,ra) $diff ]
         lappend err_ra [expr abs($diff)]
      }
      set err_ra [format "%+.0f arcsec" [::math::statistics::max $err_ra]]
      gren_erreur "Erreur MAX en RA : $err_ra\n"
      
      # Regression lineaire de delta
      set xdata ""
      set ydata ""
      foreach jd $tab_ephem(index) {
         lappend xdata $tab_ephem($jd,x)
         lappend ydata $tab_ephem($jd,dec)
      }
      set r [::math::statistics::linear-model $xdata $ydata 1]
      lassign  $r a b ystdev coef_corr_r2 degfreedom err_a sign_level_a err_b sign_level_b 
      gren_info "Regression lineaire de alpha\n"
      gren_info "a             = $a \n"
      gren_info "b             = $b \n"
      gren_info "ystdev        = $ystdev \n"
      gren_info "coef_corr_r2  = $coef_corr_r2 \n"
      gren_info "degfreedom    = $degfreedom \n"
      gren_info "err_a         = $err_a \n"
      gren_info "sign_level_a  = $sign_level_a \n"
      gren_info "err_b         = $err_b \n"
      gren_info "sign_level_b  = $sign_level_b \n"
      set dec_a $a
      set dec_b $b
      set dec_a [expr  $dec_a  - $dec_b * $orig ]
      gren_info [format "%23s DEC   Diff(arcsec)\n" "date iso"]
      set err_dec ""
      foreach jd $tab_ephem(index) {
         set diff [ expr ($tab_ephem($jd,dec) - ( $dec_a + $dec_b * $jd )) * 3600.0]
         set tab_ephem($jd,err_dec) $diff
         gren_info [format "%23s %8.5f    %+.0f\n" $tab_ephem($jd,dateiso) $tab_ephem($jd,dec) $diff ]
         lappend err_dec [expr abs($diff)]
      }
      set err_dec [format "%+.0f arcsec" [::math::statistics::max $err_dec]]
      gren_erreur "Erreur MAX en DEC : $err_dec\n"
      
      set txt "# FIN DE VALIDITE : $date_valid  ERR MAX RA : $err_ra  ERR MAX DEC : $err_dec \n"
      $::bdi_gui_reports::planif_results insert end $txt
      
      set txt "linear, $id_obj, $mag, 3, 300, 1, 3, -1, { $ra_a $ra_b $dec_a $dec_b}\n"
      $::bdi_gui_reports::planif_results insert end $txt
      
      return
   }









#    ::console::clear ; ::bddimages::ressource ; ::bdi_gui_reports::build_gui_newaster_planif_MPC_NOEG

   proc ::bdi_gui_reports::build_gui_newaster_planif_MPC_NOEG { } {

      global audace caption color
      global conf bddconf

      set widthlab 30
      set widthentry 30
      set ::bdi_gui_reports::widget(appli,newaster,planif) .newaster_planif
      set fen $::bdi_gui_reports::widget(appli,newaster,planif)

      #--- Initialisation des parametres
      
      

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports,newaster_planif) ] } {
         set conf(bddimages,geometry_reports,newaster_planif) "900x600+400+800"
      }
      set bddconf(geometry_reports,newaster_planif) $conf(bddimages,geometry_reports,newaster_planif)

      #--- Declare la GUI
      if { [ winfo exists $fen ] } {
         ::bdi_gui_reports::newaster_planif_fermer
         ::bdi_gui_reports::build_gui_newaster_planif_MPC_NOEG
         return
      }

      #--- GUI
      toplevel $fen -class Toplevel
      wm geometry $fen $bddconf(geometry_reports,newaster_planif)
      wm resizable $fen 1 1
      wm title $fen "Planification MPC sur telescope robotique : $::bdi_gui_reports::newaster_planif_id_obj"
      wm protocol $fen WM_DELETE_WINDOW { ::bdi_gui_reports::newaster_planif_fermer }

      set frm $fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $fen -side top -expand yes -fill both 
      set ::bdi_gui_reports::widget(frame,newaster,planif) $frm

         # Relance
         set buttons [frame $frm.buttons ]
         pack $buttons -in $frm -side top -anchor e

            button $buttons.relance -text "Relance" \
                                   -command "::bdi_gui_reports::newaster_planif_relance_MPC_NOEG"
            button $buttons.ressource -text "Ressource" \
                                   -command "::console::clear ; ::bddimages::ressource"

            grid $buttons.ressource $buttons.relance -in $buttons -sticky w

         # Observations au format MPC
         label  $frm.labobs -text "Observations au format MPC"
         pack $frm.labobs -in $frm -side top -anchor w

         set ::bdi_gui_reports::planif_mpc_obs $frm.mpc_obs
         text $::bdi_gui_reports::planif_mpc_obs -height 10 -width 80 \
              -xscrollcommand "$::bdi_gui_reports::planif_mpc_obs.xscroll set" \
              -yscrollcommand "$::bdi_gui_reports::planif_mpc_obs.yscroll set" \
              -wrap none
         pack $::bdi_gui_reports::planif_mpc_obs -in $frm -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_gui_reports::planif_mpc_obs.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::planif_mpc_obs xview"
         pack $::bdi_gui_reports::planif_mpc_obs.xscroll -side bottom -fill x

         scrollbar $::bdi_gui_reports::planif_mpc_obs.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::planif_mpc_obs yview"
         pack $::bdi_gui_reports::planif_mpc_obs.yscroll -side right -fill y

         $::bdi_gui_reports::planif_mpc_obs delete 0.0 end

         # Ephemerides MPC
         label  $frm.labeph -text "Ephemerides MPC : "
         pack $frm.labeph -in $frm -side top -anchor w

         set ::bdi_gui_reports::planif_mpc_eph $frm.mpc_eph
         text $::bdi_gui_reports::planif_mpc_eph -height 10 -width 80 \
              -xscrollcommand "$::bdi_gui_reports::planif_mpc_eph.xscroll set" \
              -yscrollcommand "$::bdi_gui_reports::planif_mpc_eph.yscroll set" \
              -wrap none
         pack $::bdi_gui_reports::planif_mpc_eph -in $frm -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_gui_reports::planif_mpc_eph.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::planif_mpc_eph xview"
         pack $::bdi_gui_reports::planif_mpc_eph.xscroll -side bottom -fill x

         scrollbar $::bdi_gui_reports::planif_mpc_eph.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::planif_mpc_eph yview"
         pack $::bdi_gui_reports::planif_mpc_eph.yscroll -side right -fill y

         $::bdi_gui_reports::planif_mpc_eph delete 0.0 end

         # Calcul
         set buttons [frame $frm.calcul ]
         pack $buttons -in $frm -side top 

            button $buttons.go -text "Calcul" \
                                   -command "::bdi_gui_reports::newaster_planif_calcul"

            grid $buttons.go -in $buttons -sticky news

         # Planif
         label  $frm.labplan -text "Planif"
         pack $frm.labplan -in $frm -side top -anchor w

         set ::bdi_gui_reports::planif_results $frm.planif_results
         text $::bdi_gui_reports::planif_results -height 10 -width 80 \
              -xscrollcommand "$::bdi_gui_reports::planif_results.xscroll set" \
              -yscrollcommand "$::bdi_gui_reports::planif_results.yscroll set" \
              -wrap none
         pack $::bdi_gui_reports::planif_results -in $frm -expand yes -fill both -padx 5 -pady 5

         scrollbar $::bdi_gui_reports::planif_results.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::planif_results xview"
         pack $::bdi_gui_reports::planif_results.xscroll -side bottom -fill x

         scrollbar $::bdi_gui_reports::planif_results.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::planif_results yview"
         pack $::bdi_gui_reports::planif_results.yscroll -side right -fill y

         $::bdi_gui_reports::planif_results delete 0.0 end


      ::bdi_gui_reports::newaster_planif_affiche_mpc
      return
   }     








   proc ::bdi_gui_reports::newaster_planif_affiche_lst { } {
      
      set log 1


      set id_obj $::bdi_gui_reports::newaster_planif_id_obj
      gren_info "id_obj = $id_obj \n"

# keplerian,  K18N12N, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {mjd a e i longnode argperic meananomaly}
#keplerian, K18N12N, 18.9, 3, 300, 24, 10, -10, {58320.876016205 1.8347711424597821E+00 0.080118876820781  18.5490001089741 302.7717439646428  29.5531378538846 339.2997059763596}
      
      $::bdi_gui_reports::planif_lst insert end "# keplerian,  Designation, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {mjd a e i longnode argperic meananomaly}\n"


      set file_eq0 "$id_obj.eq0"
      set file_eq0 [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
      # teste l existence de resultat
      if { ! [file exists $file_eq0] } {
         set msg "Error reading orbit : $file_eq0 not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File exist : $file_eq0\n"}
      }

      set err [catch {set res [::bdi_tools_orbfit::read_eq0 $file_eq0]} msg ]
      if { $err } {
         set msg "Error reading parameters : $file_eq0 not read"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File read : $file_eq0\n"}
      }
      lassign $res mag mjd a e i longnode argperic meananomaly
      gren_info "PARAMZ: $mag $mjd $a $e $i $longnode $argperic $meananomaly\n"


      $::bdi_gui_reports::planif_lst insert end "keplerian,  $id_obj, $mag, 3, 300, 24, 20, -10, {$mjd $a $e $i $longnode $argperic $meananomaly}\n"

   
      #bind $::bdi_gui_cata_gestion::fen <Control-Key-a> { ::bdi_gui_reports::selectall }
   }








   proc ::bdi_gui_reports::get_keplerian { id_obj } {

      set log 1

      set file_eq0 "$id_obj.eq0"
      set file_eq0 [file join $::bdi_tools_reports::tab_newaster($id_obj,dir) $file_eq0]
      # teste l existence de resultat
      if { ! [file exists $file_eq0] } {
         set msg "Error reading orbit : $file_eq0 not exist"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File exist : $file_eq0\n"}
      }

      set err [catch {set res [::bdi_tools_orbfit::read_eq0 $file_eq0]} msg ]
      if { $err } {
         set msg "Error reading parameters : $file_eq0 not read"
         if {$log} {gren_erreur "$msg\n"}
         return -code 1 $msg
      } else {
         if {$log} {gren_info "File read : $file_eq0\n"}
      }
      lassign $res mag mjd a e i longnode argperic meananomaly
      gren_info "PARAMZ: $mag $mjd $a $e $i $longnode $argperic $meananomaly\n"

      return $res
   }









   proc ::bdi_gui_reports::newaster_planif_affiche_lst_col { } {
      
      set log 1

      $::bdi_gui_reports::planif_lst_col delete 0.0 end

      set id_obj $::bdi_gui_reports::newaster_planif_id_obj
      gren_info "id_obj = $id_obj \n"

# keplerian,  K18N12N, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {mjd a e i longnode argperic meananomaly}
#keplerian, K18N12N, 18.9, 3, 300, 24, 10, -10, {58320.876016205 1.8347711424597821E+00 0.080118876820781  18.5490001089741 302.7717439646428  29.5531378538846 339.2997059763596}
      
#$::bdi_gui_reports::widget(frame,colimacon).buttons.pepn
#$::bdi_gui_reports::widget(frame,colimacon).buttons.pn  
#$::bdi_gui_reports::widget(frame,colimacon).buttons.mepn
#$::bdi_gui_reports::widget(frame,colimacon).buttons.pe  
#$::bdi_gui_reports::widget(frame,colimacon).buttons.c   
#$::bdi_gui_reports::widget(frame,colimacon).buttons.me  
#$::bdi_gui_reports::widget(frame,colimacon).buttons.pemn
#$::bdi_gui_reports::widget(frame,colimacon).buttons.mn  
#$::bdi_gui_reports::widget(frame,colimacon).buttons.memn


      # Calcul du nb de direction
      set nbd 0
      set ldir [list pepn pn mepn pe me pemn mn memn c]
      foreach dir $ldir {
         if {[$::bdi_gui_reports::widget(frame,colimacon).buttons.$dir cget -relief ] == "sunken"} { incr nbd }
      }
      gren_info "Nb Direction = $nbd\n"
      set step [format "%0.3f" [expr ($nbd) / 10.0]]
      gren_info "Step (h) = $step\n"
      
      

      # Champ Central
      if {[$::bdi_gui_reports::widget(frame,colimacon).buttons.c cget -relief ] == "sunken"} {

          $::bdi_gui_reports::planif_lst_col insert end "# keplerian,  Designation, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {mjd a e i longnode argperic meananomaly}\n"

          set res [::bdi_gui_reports::get_keplerian $id_obj]
          lassign $res mag mjd a e i longnode argperic meananomaly

          $::bdi_gui_reports::planif_lst_col insert end "keplerian,  $id_obj, $mag, 3, 300, $step, 1, -10, {$mjd $a $e $i $longnode $argperic $meananomaly}\n"
      }


      # Existance des champs a cote
      set nbd 0
      set ldir [list pepn pn mepn pe me pemn mn memn]
      foreach dir $ldir {
         if {[$::bdi_gui_reports::widget(frame,colimacon).buttons.$dir cget -relief ] == "sunken"} { incr nbd ; break }
      }
      if {$nbd} {
            $::bdi_gui_reports::planif_lst_col insert end "# linear,  Designation, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {ra_a ra_b dec_a dec_b}\n"
      }
      
      # Champs autour
      set ldir [list pepn pn mepn pe me pemn mn memn]
      foreach dir $ldir {
         if {[$::bdi_gui_reports::widget(frame,colimacon).buttons.$dir cget -relief ] == "sunken"} {
            $::bdi_gui_reports::planif_lst_col insert end "linear,   ${id_obj}_$dir, -1, 3, 300, $step, 1, -10, {$::bdi_gui_reports::tabephem($id_obj,$dir)}\n"
         }
      }
      #$::bdi_gui_reports::planif_lst_col insert end "# linear,  Designation, Magnitude, Binning, Expo(s), Step(h), NbFrame, Priority, {a b c d}\n"
   
      #bind $::bdi_gui_cata_gestion::fen <Control-Key-a> { ::bdi_gui_reports::selectall }
   }














   proc ::bdi_gui_reports::build_gui_keplerian { frm } {

      set ::bdi_gui_reports::widget(frame,keplerian) $frm

      # Texte
      label  $frm.labobs -text "Ligne a copier dans le fichier .lst"
      pack $frm.labobs -in $frm -side top -anchor w

      set ::bdi_gui_reports::planif_lst $frm.mpc_obs
      text $::bdi_gui_reports::planif_lst -height 10 -width 80 \
           -xscrollcommand "$::bdi_gui_reports::planif_lst.xscroll set" \
           -yscrollcommand "$::bdi_gui_reports::planif_lst.yscroll set" \
           -wrap none
      pack $::bdi_gui_reports::planif_lst -in $frm -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_gui_reports::planif_lst.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::planif_lst xview"
      pack $::bdi_gui_reports::planif_lst.xscroll -side bottom -fill x

      scrollbar $::bdi_gui_reports::planif_lst.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::planif_lst yview"
      pack $::bdi_gui_reports::planif_lst.yscroll -side right -fill y

      $::bdi_gui_reports::planif_lst delete 0.0 end

      # Select
      set buttons [frame $frm.buttonsel ]
      pack $buttons -in $frm -side top 

         button $buttons.go -text "Select" \
                                -command "$::bdi_gui_reports::planif_lst tag add sel 0.end end"

         grid $buttons.go -in $buttons -sticky news


      ::bdi_gui_reports::newaster_planif_affiche_lst

      return
   }















#------------------------------------------------------------
## Cette fonction lit le fichier eph d ephemeride d'un Sso
# @return void
#
#
# Lecture eproc4
#   2018-09-24T16:32:20.023  12 40 59.11472  +03 24 43.1234     4.5954   -0.4506   -999.000      8.54       0.1023E+01      -0.4743E+00
proc ::bdi_gui_reports::read_eph_sso { id_obj file } {
   
   array unset ::bdi_gui_reports::tabephem
   set cpt 0
   set f [open $file "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      if {[string range $line 0 0] == "#"} {continue}

      # Chargement
      set res     [split [regexp -all -inline {\S+} $line] " "]
      set dateiso [string range [lindex $res 0] 0 21]
      set jd      [mc_date2jd $dateiso]
      set ra      "[lindex $res 1]h[lindex $res 2]m[lindex $res 3]s"
      set dec     "[lindex $res 4]d[lindex $res 5]m[lindex $res 6]s"
      set mura    [lindex $res 10]
      set mudec   [lindex $res 11]
      set vmag    [lindex $res 12]
      
      # Finalisation
      lappend ::bdi_gui_reports::tabephem($id_obj,dateiso) $dateiso
      lappend ::bdi_gui_reports::tabephem($id_obj,jd)      $jd
      lappend ::bdi_gui_reports::tabephem($id_obj,ra)      [mc_angle2deg $ra]
      lappend ::bdi_gui_reports::tabephem($id_obj,dec)     [mc_angle2deg $dec]
      lappend ::bdi_gui_reports::tabephem($id_obj,mura)    $mura
      lappend ::bdi_gui_reports::tabephem($id_obj,mudec)   $mudec
      
      incr cpt
   }
   close $f
   gren_info "       READ: Lecture du fichier [file tail $file] : $cpt pts\n"
}












   proc ::bdi_gui_reports::regression_lineaire_angle { xdata ydata { offset 0 } } {
      
      set log 0

      set orig [::math::statistics::min $xdata]
      set xdata_o ""
      foreach x $xdata {
         lappend xdata_o [expr $x - $orig]
      }
      set ydata_o ""
      foreach y $ydata {
         lappend ydata_o [expr $y + $offset]
      }
      
      set r [::math::statistics::linear-model $xdata_o $ydata_o 1]
      lassign  $r a b ystdev coef_corr_r2 degfreedom err_a sign_level_a err_b sign_level_b 

      
      if {$log} {
         gren_info "Regression lineaire de alpha\n"
         gren_info "a             = $a \n"
         gren_info "b             = $b \n"
         gren_info "ystdev        = $ystdev \n"
         gren_info "coef_corr_r2  = $coef_corr_r2 \n"
         gren_info "degfreedom    = $degfreedom \n"
         gren_info "err_a         = $err_a \n"
         gren_info "sign_level_a  = $sign_level_a \n"
         gren_info "err_b         = $err_b \n"
         gren_info "sign_level_b  = $sign_level_b \n"
      }

      set y_a $a
      set y_b $b
      set y_a [expr  $y_a - $y_b  * $orig ]
      if {$log} {gren_info [format "%23s RA   Diff(arcsec)\n" "date iso"]}
      set err_y ""
      set id -1
      foreach x $xdata {
         incr id
         set y [lindex $ydata_o $id]
         set diff [ expr ($y - ( $y_a + $y_b * $x )) * 3600.0]
         #set tab_ephem($jd,err_ra) $diff
         lappend err_y [expr abs($diff)]
         if {$log} {gren_info [format "%23s %8.5f    %+.0f\n" [mc_date2iso8601 $x] $y $diff ]}
      }
      set err_y [format "%+.0f arcsec" [::math::statistics::max $err_y]]
      if {$log} {gren_erreur "Erreur MAX : $err_y\n"}
      
      return [list $y_a $y_b $err_y]
   }











   proc ::bdi_gui_reports::calcul_colimacon {  } {
      
      global audace 
      
      set uai_code           $::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,uai_code)          
      set nbjour             $::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,nbjour)            
      set ra_field_size_deg  $::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,ra_field_size_deg) 
      set dec_field_size_deg $::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,dec_field_size_deg)
      set recouvrement       $::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,recouvrement)      


      set tmpdir   "./"
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,ra_err_max)  "-"
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,dec_err_max) "-"

      # RAZ GUI
      set ldir [list pepn pn mepn pe me pemn mn memn c]
      foreach dir $ldir {
         $::bdi_gui_reports::widget(frame,colimacon).buttons.$dir configure -command ""
      }

      set nbdates  [expr 144 * $nbjour]

      set id_obj $::bdi_gui_reports::newaster_planif_id_obj
      gren_info "id_obj = $id_obj \n"

      # recuperation des parametres keplerien
      set res [::bdi_gui_reports::get_keplerian $id_obj]
      lassign $res mag mjd a e i longnode argperic meananomaly

      # ephemeride sur 7 jours
      set file_json [file join $tmpdir "$id_obj.json"]
      file delete -force $file_json
      gren_info "          + Ecriture fichier json : $file_json\n"
      set jd [expr $mjd + 2400000.5]
      set f [open $file_json "w"]
      puts $f "{                                    "
      puts $f "  \"type\":\"asteroid\",             "
      puts $f "  \"name\": \"$id_obj\",                   "
      puts $f "  \"dynamical_parameters\": {          "
      puts $f "    \"ref_epoch\": $jd,          "
      puts $f "    \"semi_major_axis\": $a,   "
      puts $f "    \"eccentricity\": $e,      "
      puts $f "    \"inclination\": $i,        "
      puts $f "    \"node_longitude\": $longnode,     "
      puts $f "    \"perihelion_argument\": $argperic,"
      puts $f "    \"mean_anomaly\": $meananomaly,      "
      puts $f "    \"ceu\": 0.000,                    "
      puts $f "    \"ceu_rate\": 0.00000,            "
      puts $f "    \"orbit_ref\": \"AUDELA_json\",      "
      puts $f "    \"author\": \"AUDELA\"        "
      puts $f "  }                                  "
      puts $f "}                                    "
      close $f
      if {! [file exists $file_json]} {
         return -code 3 "Erreur ecriture fichier json : $err $msg"
      }
      
      set ephfile [file join $tmpdir "$id_obj.eph"]
      set dateiso [get_date_sys2ut]
      set cmd "/usr/local/bin/ephemcc4 --target \"${file_json}\""
      append cmd " -b $dateiso"
      append cmd " -p 10m"
      append cmd " -d $nbdates"
      append cmd " --uai $uai_code"
      append cmd " -r ${tmpdir}"
      append cmd " -f ${ephfile}"
      append cmd " -s file:votext"
      append cmd " --iofile $audace(rep_plugin)/tool/bddimages/scripts/console/planif/t60_les_makes_planif_ephemcc.xml"
      append cmd " >/dev/null"

      gren_info "          + CMD=$cmd\n"
      # gren_info "cmd= $cmd\n"
      set err [catch { eval exec $cmd } msg]
      if {$err != 0} {
         gren_info "CMD=$cmd\n"
         return -code 3 "Calcul ephem asteroide impossible: $err $msg"
      }

      # Definition des fichiers temporaires
      lappend ::bdi_gui_reports::files_to_delete ${ephfile} ${file_json}

      # lecture des ephemerides
      ::bdi_gui_reports::read_eph_sso $id_obj $ephfile
      
      set nb [llength $::bdi_gui_reports::tabephem($id_obj,dateiso)]
      gren_info "          + Nb dates lues =$nb\n"

      # linearisation de RA
      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,ra)]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res ra_a ra_b ra_err
      gren_info "          + ra_a ra_b   = $ra_a $ra_b $ra_err\n"

      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,ra) -$ra_field_size_deg]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res ra_a_m ra_b_m ra_err_m
      gren_info "          + ra_a_m ra_b_m - = $ra_a_m $ra_b_m $ra_err_m\n"
      
      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,ra) $ra_field_size_deg]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res ra_a_p ra_b_p ra_err_p
      gren_info "          + ra_a_p ra_b_p + = $ra_a_p $ra_b_p $ra_err_p\n"
      
      # linearisation de DEC
      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,dec)]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res dec_a dec_b dec_err
      gren_info "          + dec_a dec_b   = $dec_a $dec_b $dec_err\n"

      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,dec) -$dec_field_size_deg]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res dec_a_m dec_b_m dec_err_m
      gren_info "          + dec_a_m dec_b_m - = $dec_a_m $dec_b_m $dec_err_m\n"
      
      set err [catch {set res [::bdi_gui_reports::regression_lineaire_angle $::bdi_gui_reports::tabephem($id_obj,jd) $::bdi_gui_reports::tabephem($id_obj,dec) $dec_field_size_deg]} msg]
      if {$err} {
         return -code 1 "Erreur Linearisation de RA : $err $msg"
      }
      lassign $res dec_a_p dec_b_p dec_err_p
      gren_info "          + dec_a_p dec_b_p + = $dec_a_p $dec_b_p $dec_err_p\n"
      
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,ra_err_max)  $ra_err
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,dec_err_max) $dec_err

      set ::bdi_gui_reports::tabephem($id_obj,pepn) [list $ra_a_p $ra_b_p $dec_a_p $dec_b_p]
      set ::bdi_gui_reports::tabephem($id_obj,pn)   [list $ra_a   $ra_b   $dec_a_p $dec_b_p]
      set ::bdi_gui_reports::tabephem($id_obj,mepn) [list $ra_a_m $ra_b_m $dec_a_p $dec_b_p]

      set ::bdi_gui_reports::tabephem($id_obj,pe)   [list $ra_a_p $ra_b_p $dec_a $dec_b]
      set ::bdi_gui_reports::tabephem($id_obj,me)   [list $ra_a_m $ra_b_m $dec_a $dec_b]

      set ::bdi_gui_reports::tabephem($id_obj,pemn) [list $ra_a_p $ra_b_p $dec_a_m $dec_b_m]
      set ::bdi_gui_reports::tabephem($id_obj,mn)   [list $ra_a   $ra_b   $dec_a_m $dec_b_m]
      set ::bdi_gui_reports::tabephem($id_obj,memn) [list $ra_a_m $ra_b_m $dec_a_m $dec_b_m]


      # MAJ GUI
      foreach dir $ldir {
         $::bdi_gui_reports::widget(frame,colimacon).buttons.$dir configure -command "::bdi_gui_reports::select_direction $dir"
      }
      
      ::bdi_gui_reports::newaster_planif_affiche_lst_col
      return
   }








   proc ::bdi_gui_reports::select_direction { dir } {
   
      set ldir [list pepn pn mepn pe me pemn mn memn c]
      
      foreach sdir $ldir {
         if {$sdir != $dir} {continue}
      
         # ok ici on a selectionne la bonne direction         
         if {[$::bdi_gui_reports::widget(frame,colimacon).buttons.$dir cget -relief ] == "sunken"} {
            $::bdi_gui_reports::widget(frame,colimacon).buttons.$dir configure -relief "raised"
         } else {
            $::bdi_gui_reports::widget(frame,colimacon).buttons.$dir configure -relief "sunken"
         }
         
      }
      ::bdi_gui_reports::newaster_planif_affiche_lst_col
      return
   }






   proc ::bdi_gui_reports::build_gui_colimacon { frm } {


      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,ra_err_max)          "-"
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,dec_err_max)         "-"
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,uai_code)           181
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,nbjour)             2
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,ra_field_size_deg)  [format "%0.3f" [expr 25.5 / 60.] ]
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,dec_field_size_deg) [format "%0.3f" [expr 16.9 / 60.] ]
      set ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,recouvrement)       5


      set frm_top [frame $frm.top]
      pack $frm_top -in $frm -side top  -padx 10 -pady 10
      set frm_txt [frame $frm.txt]
      pack $frm_txt -in $frm -side top -expand yes -fill both -padx 10


      set frm_param [frame $frm_top.param]
      pack $frm_param -in $frm_top -side left -expand yes -fill both -padx 10 -pady 10
      set frm_buttons [frame $frm_top.buttons]
      pack $frm_buttons -in $frm_top -side left -expand yes -fill both -padx 10 -pady 10
      set frm_coli [frame $frm_top.coli]
      pack $frm_coli -in $frm_top -side left -expand yes -fill both -padx 10 -pady 10
      set frm_info [frame $frm_top.info]
      pack $frm_info -in $frm_top -side left -expand yes -fill both -padx 10 -pady 10

      # Parametres
      set wdth 30
      set frmp [frame $frm_param.param]
      pack $frmp -in $frm_param -side top -expand yes -fill both -padx 10 -pady 10  
         
         # uai_code
         label  $frmp.lab_uai_code -text "uai_code : " -borderwidth 1 -width $wdth
         #pack   $frmp.lab -side left -padx 3 -pady 1
         entry  $frmp.val_uai_code -relief sunken -width 20 -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,uai_code)
         #pack   $frmp.val -side left -padx 3 -pady 1
         grid     $frmp.lab_uai_code $frmp.val_uai_code  -in $frmp

         # nbjour
         label  $frmp.lab_nbjour -text "nbjour : " -borderwidth 1 -width $wdth
         entry  $frmp.val_nbjour -relief sunken -width 20 -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,nbjour)
         grid   $frmp.lab_nbjour $frmp.val_nbjour  -in $frmp
         # nbjour
         label  $frmp.lab_ra_field_size_deg -text "ra_field_size_deg : " -borderwidth 1 -width $wdth
         entry  $frmp.val_ra_field_size_deg -relief sunken -width 20 -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,ra_field_size_deg)
         grid   $frmp.lab_ra_field_size_deg $frmp.val_ra_field_size_deg  -in $frmp
         # nbjour
         label  $frmp.lab_dec_field_size_deg -text "dec_field_size_deg : " -borderwidth 1 -width $wdth
         entry  $frmp.val_dec_field_size_deg -relief sunken -width 20 -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,dec_field_size_deg)
         grid   $frmp.lab_dec_field_size_deg $frmp.val_dec_field_size_deg  -in $frmp
         # nbjour
         label  $frmp.lab_recouvrement -text "recouvrement : " -borderwidth 1 -width $wdth
         entry  $frmp.val_recouvrement -relief sunken -width 20 -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,param,recouvrement)
         grid   $frmp.lab_recouvrement $frmp.val_recouvrement  -in $frmp




      # Calcul
      set frmb [frame $frm_buttons.b]
      pack $frmb -in $frm_buttons -side top -expand yes -fill both -padx 10 -pady 10  

         button $frmb.calc -text "Calcul" -borderwidth 2 -takefocus 1 \
            -command "::bdi_gui_reports::calcul_colimacon"
         grid $frmb.calc -in $frmb -sticky news
      
      

      # colimacon
      set frmc [frame $frm_coli.c]
      pack $frmc -in $frm_coli -side top -expand yes -fill both -padx 10 -pady 10  

      set ::bdi_gui_reports::widget(frame,colimacon) $frmc

      set buttons [frame $frmc.buttons -borderwidth 1 -relief groove]
      pack $buttons -in $frmc -side top

         button $buttons.pepn -text "+E+N" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.pn   -text "+N" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.mepn -text "-E+N" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.pe   -text "+E" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.c    -text "C" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.me   -text "-E" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.pemn -text "+E-N" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.mn   -text "-N" -borderwidth 2 -takefocus 1 \
            -command ""
         button $buttons.memn -text "-E-N" -borderwidth 2 -takefocus 1 \
            -command ""
         grid $buttons.pepn $buttons.pn $buttons.mepn
         grid $buttons.pe   $buttons.c  $buttons.me
         grid $buttons.pemn $buttons.mn $buttons.memn

      # Texte
      label  $frm_txt.labobs -text "Ligne a copier dans le fichier .lst"
      pack $frm_txt.labobs -in $frm_txt -side top -anchor w

      set ::bdi_gui_reports::planif_lst_col $frm_txt.mpc_obs
      text $::bdi_gui_reports::planif_lst_col -height 10 -width 80 \
           -xscrollcommand "$::bdi_gui_reports::planif_lst_col.xscroll set" \
           -yscrollcommand "$::bdi_gui_reports::planif_lst_col.yscroll set" \
           -wrap none
      pack $::bdi_gui_reports::planif_lst_col -in $frm_txt -expand yes -fill both -padx 5 -pady 5

      scrollbar $::bdi_gui_reports::planif_lst_col.xscroll -orient horizontal -cursor arrow -command "$::bdi_gui_reports::planif_lst_col xview"
      pack $::bdi_gui_reports::planif_lst_col.xscroll -side bottom -fill x

      scrollbar $::bdi_gui_reports::planif_lst_col.yscroll -orient vertical -cursor arrow -command "$::bdi_gui_reports::planif_lst_col yview"
      pack $::bdi_gui_reports::planif_lst_col.yscroll -side right -fill y

      $::bdi_gui_reports::planif_lst_col delete 0.0 end

         # Select
         set buttons [frame $frm_txt.buttonsel ]
         pack $buttons -in $frm_txt -side top 

            button $buttons.go -text "Select" \
                                   -command "$::bdi_gui_reports::planif_lst_col tag add sel 0.end end"

            grid $buttons.go -in $buttons -sticky news

      # Parametres
      set wdth 30
      set frmi [frame $frm_info.param]
      pack $frmi -in $frm_info -side top -expand yes -fill both -padx 10 -pady 10  
         
         # uai_code
         label  $frmi.lab_ra_err_max -text "RA Err Max : " -borderwidth 1 -width $wdth
         label  $frmi.val_ra_err_max -text "RA Err Max : " -borderwidth 1 -width $wdth -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,ra_err_max)
         grid   $frmi.lab_ra_err_max $frmi.val_ra_err_max  -in $frmi

         # uai_code
         label  $frmi.lab_dec_err_max -text "DEC Err Max : " -borderwidth 1 -width $wdth
         label  $frmi.val_dec_err_max -text "DEC Err Max : " -borderwidth 1 -width $wdth -textvariable ::bdi_gui_reports::widget(frame,newaster,planif,colimacon,info,dec_err_max)
         grid   $frmi.lab_dec_err_max $frmi.val_dec_err_max  -in $frmi


      # MAJ GUI
      ::bdi_gui_reports::newaster_planif_affiche_lst_col
   }








   proc ::bdi_gui_reports::build_gui_newaster_planif_orbfit { } {

      global audace caption color
      global conf bddconf

      set widthlab 30
      set widthentry 30
      
      set fen .newaster_planif
      set ::bdi_gui_reports::widget(appli,newaster,planif) .newaster_planif
      set fen $::bdi_gui_reports::widget(appli,newaster,planif)

      if {[winfo exists $fen]} {
         
      }

      #--- Initialisation des parametres
      
      

      #--- Geometry
      if { ! [ info exists conf(bddimages,geometry_reports,newaster_planif) ] } {
         set conf(bddimages,geometry_reports,newaster_planif) "900x600+400+800"
      }
      set bddconf(geometry_reports,newaster_planif) $conf(bddimages,geometry_reports,newaster_planif)

      #--- Declare la GUI
      if { [ winfo exists $fen ] } {
         ::bdi_gui_reports::newaster_planif_fermer
         ::bdi_gui_reports::build_gui_newaster_planif_orbfit
         return
      }

      #--- GUI
      toplevel $fen -class Toplevel
      wm geometry $fen $bddconf(geometry_reports,newaster_planif)
      wm resizable $fen 1 1
      wm title $fen "Planification Orbfit sur telescope robotique : $::bdi_gui_reports::newaster_planif_id_obj"
      wm protocol $fen WM_DELETE_WINDOW { ::bdi_gui_reports::newaster_planif_fermer }

      set frm $fen.appli
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $fen -side top -expand yes -fill both 
      set ::bdi_gui_reports::widget(frame,newaster,planif) $frm

         # Relance
         set buttons [frame $frm.buttons ]
         pack $buttons -in $frm -side top -anchor e

            button $buttons.relance -text "Relance" \
                                   -command "::bdi_gui_reports::newaster_planif_relance_orbfit"
            button $buttons.ressource -text "Ressource" \
                                   -command "::console::clear ; ::bddimages::ressource"
            grid $buttons.ressource $buttons.relance -in $buttons 



      set onglets [frame $frm.onglets -borderwidth 1]
      pack $onglets -in $frm -anchor n  -side top -expand yes -fill both -padx 10 -pady 10
      #grid $onglets -in $frm -sticky news

         pack [ttk::notebook $onglets.nb ]  -side top -expand yes -fill both 
         #grid [ttk::notebook $onglets.nb ]  -row 0 -column 0

         set f_kepl   [frame $onglets.nb.f_kepl]
         set f_coli   [frame $onglets.nb.f_coli]

         $onglets.nb add $f_kepl   -text "Keplerian" -underline 0
         $onglets.nb add $f_coli   -text "Colimacon" -underline 0

         #$onglets.nb select $f_kepl
         $onglets.nb select $f_coli
         ttk::notebook::enableTraversal $onglets.nb


         set frmnb [frame $f_kepl.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_kepl -side top -expand yes -fill both -padx 10 -pady 10
         #grid $frmnb -in $f_asph -sticky news 

            ::bdi_gui_reports::build_gui_keplerian $frmnb

         set frmnb [frame $f_coli.frm -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmnb -in $f_coli -side top -expand yes -fill both -padx 10 -pady 10

            ::bdi_gui_reports::build_gui_colimacon $frmnb



   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_reports::fen



    
      return
   }     











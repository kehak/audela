#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_analysis_gui.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_analysis_gui.tcl
# Description    : Outils pour la GUI pour l'analyse de la courbe de lumiere
# Auteur         : Frederic Vachier
# Mise Ã  jour $Id: atos_analysis_gui.tcl 14453 2018-07-14 21:55:57Z jberthier $
#

namespace eval ::atos_analysis_gui {

   variable googleURI

   set googleURI "http://maps.google.fr/maps?q="


   proc ::atos_analysis_gui::reinitialise { } {

      # 
      # Contexte
      # 
      set ::atos_analysis_gui::occ_obj        ""
      set ::atos_analysis_gui::occ_date       ""
      set ::atos_analysis_gui::occ_pos        ""
      set ::atos_analysis_gui::occ_pos_type   ""
      set ::atos_analysis_gui::occ_obj_name   ""
      set ::atos_analysis_gui::occ_obj_id     ""
      set ::atos_analysis_gui::occ_tag        ""
      # 
      # Fichiers & Repertoires
      # 
      set ::atos_analysis_gui::prj_file_short ""
      set ::atos_analysis_gui::prj_file       ""
      set ::atos_analysis_gui::prj_dir        ""
      # 
      # Ephemerides
      # 
      set ::atos_analysis_gui::jd         ""
      set ::atos_analysis_gui::rajapp     ""
      set ::atos_analysis_gui::decapp     ""
      set ::atos_analysis_gui::dist       ""
      set ::atos_analysis_gui::magv       ""
      set ::atos_analysis_gui::phase      ""
      set ::atos_analysis_gui::elong      ""
      set ::atos_analysis_gui::dracosd    ""
      set ::atos_analysis_gui::ddec       ""
      set ::atos_analysis_gui::vn         ""
      set ::atos_analysis_gui::tsl        ""
      set ::atos_analysis_gui::raj2000    ""
      set ::atos_analysis_gui::decj2000   ""
      set ::atos_analysis_gui::hourangle  ""
      set ::atos_analysis_gui::decapp     ""
      set ::atos_analysis_gui::azimuth    ""
      set ::atos_analysis_gui::hauteur    ""
      set ::atos_analysis_gui::airmass    ""
      set ::atos_analysis_gui::dhelio     ""
      # 
      # Corrections courbe
      # 
      set ::atos_analysis_gui::raw_filename_short ""
      set ::atos_analysis_gui::raw_filename       ""
      set ::atos_analysis_gui::raw_integ_offset   0
      set ::atos_analysis_gui::raw_integ_nb_img   1
      set ::atos_analysis_gui::int_corr           1
      set ::atos_analysis_gui::tps_corr           0
      set ::atos_analysis_gui::theo_expo          0
      set ::atos_analysis_gui::time_offset        0.03
      set ::atos_analysis_gui::ref_corr           0
      # 
      # Evenements
      # 
      set ::atos_analysis_gui::corr_filename_short        ""
      set ::atos_analysis_gui::corr_filename              ""
      set ::atos_analysis_tools::id_p1                    ""
      set ::atos_analysis_tools::corr_duree_e1            ""
      set ::atos_analysis_tools::nb_p1                    ""
      set ::atos_analysis_gui::duree_max_immersion_search ""
      set ::atos_analysis_tools::id_p2                    ""
      set ::atos_analysis_tools::corr_duree_e2            ""
      set ::atos_analysis_tools::nb_p2                    ""
      set ::atos_analysis_tools::id_p3                    ""
      set ::atos_analysis_tools::corr_duree_e3            ""
      set ::atos_analysis_tools::nb_p3                    ""
      set ::atos_analysis_gui::duree_max_emersion_search  ""
      set ::atos_analysis_tools::id_p4                    ""
      set ::atos_analysis_tools::corr_duree_e4            ""
      set ::atos_analysis_tools::nb_p4                    ""
      set ::atos_analysis_tools::id_p5                    ""
      set ::atos_analysis_tools::corr_duree_e5            ""
      set ::atos_analysis_tools::nb_p5                    ""
      set ::atos_analysis_gui::duree_max_immersion_evnmt  ""
      set ::atos_analysis_tools::id_p6                    ""
      set ::atos_analysis_gui::date_immersion             ""
      set ::atos_analysis_gui::duree_max_emersion_evnmt   ""
      set ::atos_analysis_tools::id_p7                    ""
      set ::atos_analysis_gui::date_emersion              ""
      # 
      # Parametres
      # 
      set ::atos_analysis_gui::width               ""
      set ::atos_analysis_gui::occ_star_name       ""
      set ::atos_analysis_gui::occ_star_class      1
      set ::atos_analysis_gui::occ_star_B          ""
      set ::atos_analysis_gui::occ_star_V          ""
      set ::atos_analysis_gui::occ_star_K          ""
      set ::atos_analysis_gui::occ_star_size_mas   ""
      set ::atos_analysis_gui::occ_star_size_km    ""
      set ::atos_analysis_gui::occ_star_extinction ""
      set ::atos_analysis_gui::wvlngth             ""
      set ::atos_analysis_gui::dlambda             ""
      set ::atos_analysis_tools::irep              ""
      set ::atos_analysis_gui::nheure              ""
      set ::atos_analysis_gui::pas_heure           ""
      set ::atos_analysis_tools::corr_exposure     ""
      set ::atos_analysis_gui::date_begin_obs      ""
      set ::atos_analysis_gui::date_end_obs        ""
      # 
      # Immersion & Emersion
      # 
      set ::atos_analysis_gui::date_immersion_sol ""
      set ::atos_analysis_gui::im_chi2_min        ""
      set ::atos_analysis_gui::im_nfit_chi2_min   ""
      set ::atos_analysis_gui::im_t0_chi2_min     ""
      set ::atos_analysis_gui::im_t_inf           ""
      set ::atos_analysis_gui::im_t_sup           ""
      set ::atos_analysis_gui::im_t_diff          ""
      set ::atos_analysis_gui::im_t_inf_2s        ""
      set ::atos_analysis_gui::im_t_sup_2s        ""
      set ::atos_analysis_gui::im_t_diff_2s       ""
      set ::atos_analysis_gui::im_t_inf_3s        ""
      set ::atos_analysis_gui::im_t_sup_3s        ""
      set ::atos_analysis_gui::im_t_diff_3s       ""
      set ::atos_analysis_gui::date_emersion_sol  ""
      set ::atos_analysis_gui::em_chi2_min        ""
      set ::atos_analysis_gui::em_nfit_chi2_min   ""
      set ::atos_analysis_gui::em_t0_chi2_min     ""
      set ::atos_analysis_gui::em_t_inf           ""
      set ::atos_analysis_gui::em_t_sup           ""
      set ::atos_analysis_gui::em_t_diff          ""
      set ::atos_analysis_gui::em_t_inf_2s        ""
      set ::atos_analysis_gui::em_t_sup_2s        ""
      set ::atos_analysis_gui::em_t_diff_2s       ""
      set ::atos_analysis_gui::em_t_inf_3s        ""
      set ::atos_analysis_gui::em_t_sup_3s        ""
      set ::atos_analysis_gui::em_t_diff_3s       ""
      set ::atos_analysis_gui::bande              ""
      set ::atos_analysis_gui::duree              ""
      set ::atos_analysis_gui::result             ""
      # 
      # Contacts
      # 
      set ::atos_analysis_gui::occ_observers  ""
      set ::atos_analysis_gui::prj_reduc      ""
      set ::atos_analysis_gui::prj_mail       ""
      set ::atos_analysis_gui::prj_phone      ""
      set ::atos_analysis_gui::prj_address    ""
      # 
      # Station
      # 
      set ::atos_analysis_gui::type1_station  ""
      set ::atos_analysis_gui::latitude       ""
      set ::atos_analysis_gui::longitude      ""
      set ::atos_analysis_gui::altitude       ""
      set ::atos_analysis_gui::datum          ""
      set ::atos_analysis_gui::nearest_city   ""
      set ::atos_analysis_gui::type2_station  ""
      # 
      # Telescope
      # 
      set ::atos_analysis_gui::telescop_type  ""
      set ::atos_analysis_gui::telescop_aper  ""
      set ::atos_analysis_gui::telescop_magn  ""
      set ::atos_analysis_gui::telescop_moun  ""
      set ::atos_analysis_gui::telescop_moto  ""
      # 
      # Acquisition
      # 
      set ::atos_analysis_gui::record_evin    ""
      set ::atos_analysis_gui::record_time    ""
      set ::atos_analysis_gui::record_sens    ""
      set ::atos_analysis_gui::record_prod    ""
      set ::atos_analysis_gui::record_tiin    ""
      set ::atos_analysis_gui::record_comp    ""
      # 
      # Conditions
      # 
      set ::atos_analysis_gui::obscond_tran   ""
      set ::atos_analysis_gui::obscond_wind   ""
      set ::atos_analysis_gui::obscond_temp   ""
      set ::atos_analysis_gui::obscond_stab   ""
      set ::atos_analysis_gui::obscond_visi   ""
      # 
      # Comments
      # 
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f10.frm.comments.v delete 1.0 end 
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f10.frm.comments.v insert end ""

   }








   #
   # Chargement des captions
   #
   proc ::atos_analysis_gui::init { } {
      global audace

      wm focusmodel . passive
      wm withdraw .
      #--- Chargement des captions

      set ::atos_analysis_tools::raw_status_file  ""
      set ::atos_analysis_tools::raw_nbframe      ""
      set ::atos_analysis_tools::raw_date_begin   ""
      set ::atos_analysis_tools::raw_date_end     ""
      set ::atos_analysis_tools::raw_fps          ""
      set ::atos_analysis_tools::raw_duree        ""

      set ::atos_analysis_tools::corr_status_file ""
      set ::atos_analysis_tools::corr_nbframe     ""
      set ::atos_analysis_tools::corr_date_begin  ""
      set ::atos_analysis_tools::corr_date_end    ""
      set ::atos_analysis_tools::corr_fps         ""
      set ::atos_analysis_tools::corr_duree       ""

   }









   proc ::atos_analysis_gui::init_faible { } {

      set ::atos_analysis_gui::but_calcul "Calcul"
      set ::atos_analysis_gui::state_but_graph(1) 0
      set ::atos_analysis_gui::state_but_graph(2) 0
      set ::atos_analysis_gui::state_but_graph(3) 0
      set ::atos_analysis_gui::state_but_graph(20) 0
      set ::atos_analysis_gui::state_but_graph(21) 0
      set ::atos_analysis_gui::state_but_graph(22) 0
      set ::atos_analysis_gui::state_but_graph(23) 0
      set ::atos_analysis_gui::state_but_graph(24) 0

      if {![info exists ::atos_analysis_gui::wvlngth]}       {set ::atos_analysis_gui::wvlngth "0.75"}
      if {![info exists ::atos_analysis_gui::dlambda]}       {set ::atos_analysis_gui::dlambda "0.4"}
      if {[string trim $::atos_analysis_gui::wvlngth]==""}   {set ::atos_analysis_gui::wvlngth "0.75"}
      if {[string trim $::atos_analysis_gui::dlambda]==""}   {set ::atos_analysis_gui::dlambda "0.4"}

      if {![info exists ::atos_analysis_gui::nheure]}        {set ::atos_analysis_gui::nheure 200}
      if {![info exists ::atos_analysis_gui::pas_heure]}     {set ::atos_analysis_gui::pas_heure 0.02}
      if {[string trim $::atos_analysis_gui::nheure]==""}    {set ::atos_analysis_gui::nheure 200}
      if {[string trim $::atos_analysis_gui::pas_heure]==""} {set ::atos_analysis_gui::pas_heure 0.02}

   }















   #
   # Initialisation des variables de configuration
   #
   proc ::atos_analysis_gui::initToConf { visuNo } {
      variable parametres

      #--- Creation des variables de la boite de configuration si elles n'existent pas
      if { ! [ info exists ::atos::parametres(atos,$visuNo,messages) ] }                 { set ::atos::parametres(atos,$visuNo,messages)                 "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,save_file_log) ] }            { set ::atos::parametres(atos,$visuNo,save_file_log)            "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,alarme_fin_serie) ] }         { set ::atos::parametres(atos,$visuNo,alarme_fin_serie)         "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) ] } { set ::atos::parametres(atos,$visuNo,verifier_ecraser_fichier) "1" }
      if { ! [ info exists ::atos::parametres(atos,$visuNo,verifier_index_depart) ] }    { set ::atos::parametres(atos,$visuNo,verifier_index_depart)    "1" }

   }












   #
   # Charge la configuration dans des variables locales
   #
   proc ::atos_analysis_gui::confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set ::atos_analysis_gui::panneau(atos,$visuNo,messages)                 $::atos::parametres(atos,$visuNo,messages)
      set ::atos_analysis_gui::panneau(atos,$visuNo,save_file_log)            $::atos::parametres(atos,$visuNo,save_file_log)
      set ::atos_analysis_gui::panneau(atos,$visuNo,alarme_fin_serie)         $::atos::parametres(atos,$visuNo,alarme_fin_serie)
      set ::atos_analysis_gui::panneau(atos,$visuNo,verifier_ecraser_fichier) $::atos::parametres(atos,$visuNo,verifier_ecraser_fichier)
      set ::atos_analysis_gui::panneau(atos,$visuNo,verifier_index_depart)    $::atos::parametres(atos,$visuNo,verifier_index_depart)


   }















   #
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
   #
   proc ::atos_analysis_gui::widgetToConf { visuNo } {
      variable parametres
      global panneau

   }















   #
   # Cree la fenetre de configuration de l'affichage des messages sur la Console
   # et de l'enregistrement des dates dans le fichier log
   #
   proc ::atos_analysis_gui::run { visuNo frm } {

      global audace panneau

      set panneau(atos,$visuNo,atos_analysis_gui) $frm

      createdialog $visuNo $frm

   }















   #
   # Fonction appellee lors de l'appui sur le bouton 'Aide'
   #
   proc ::atos_analysis_gui::showHelp { } {
      ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::atos::getPluginType ] ] \
         [ ::atos::getPluginDirectory ] atos_analysis_gui.htm
   }
















   #
   # Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc ::atos_analysis_gui::closeWindow { this visuNo } {

      ::atos_analysis_gui::widgetToConf $visuNo
      ::plotxy::clf 1
      destroy $this
   }
























  proc ::atos_analysis_gui::test_sappho {  } {

     set ::atos_analysis_gui::wvlngth 0.7500
     set ::atos_analysis_gui::dlambda 0.4000

     set ::atos_analysis_gui::dist    1.56
     set ::atos_analysis_gui::occ_star_size_km      2.04
     set ::atos_analysis_gui::vn      27.800

     set ::atos_analysis_gui::width   150.0
     
     set ::atos_analysis_gui::nheure  200  
     set ::atos_analysis_gui::pas_heure  0.2
  }


















   proc ::atos_analysis_gui::open_raw_file { visuNo frm  } {

      global color

      if {$::atos_analysis_gui::raw_filename==""||![info exists ::atos_analysis_gui::raw_filename]} {return}
      
 
      ::console::affiche_resultat "Chargement de la courbe : $::atos_analysis_gui::raw_filename\n"
      set err [catch {set nb [::atos_analysis_tools::charge_csv $::atos_analysis_gui::raw_filename]} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de chargement du fichier\n"
         ::console::affiche_erreur "Fichier = $::atos_analysis_gui::raw_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      set err [catch {::atos_analysis_tools::filtre_raw_data $nb} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la courbe de lumiere\n"
         ::console::affiche_erreur "Fichier = $::atos_analysis_gui::raw_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      $::atos_analysis_tools::raw_status_file_gui configure -fg $color(blue)

      # cree la courbe
      set ::atos_analysis_gui::x ""
      set ::atos_analysis_gui::y ""

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         lappend ::atos_analysis_gui::x [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         lappend ::atos_analysis_gui::y $::atos_analysis_tools::cdl($i,obj_fint)
      }
      
      # affiche la courbe
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y b+
   }
























   proc ::atos_analysis_gui::select_raw_data { visuNo frm } {

      global audace
      
      if {[info exists ::atos_analysis_gui::prj_dir]} {
         set dir $::atos_analysis_gui::prj_dir
      } else {
         set dir $audace(rep_images)
      }

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::atos_analysis_gui::raw_filename [ ::tkutil::box_load_csv $frm $dir $bufNo "1" ]
      set ::atos_analysis_gui::raw_filename_short [file tail $::atos_analysis_gui::raw_filename]

   }
















   proc ::atos_analysis_gui::corr_integ_get_offset { visuNo corr_integ } {

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]
      
      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      if {$y1>$y2} {
         set t $y1
         set y1 $y2
         set y2 $t
      }
      
      set cpt 0
      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         set x  [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         set y  $::atos_analysis_tools::cdl($i,obj_fint)
         if { $x > $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            ::console::affiche_resultat "id = $i\n"
            incr cpt
         }
      }
      
      set ::atos_analysis_gui::raw_integ_offset $cpt
   }














   proc ::atos_analysis_gui::corr_integ_get_nb_img { visuNo corr_integ } {

      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set y1 [lindex $rect 1]
      set x2 [lindex $rect 2]
      set y2 [lindex $rect 3]
      
      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      if {$y1>$y2} {
         set t $y1
         set y1 $y2
         set y2 $t
      }
      
      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         set x  [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         set y  $::atos_analysis_tools::cdl($i,obj_fint)
         if { $x > $x1 && $x < $x2 && $y > $y1 && $y < $y2 } {
            incr cpt
         }
      }
      
      set ::atos_analysis_gui::raw_integ_nb_img $cpt
   }
















   proc ::atos_analysis_gui::corr_integ_reset { } {

      # cree la courbe
      set ::atos_analysis_gui::x ""
      set ::atos_analysis_gui::y ""

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         lappend ::atos_analysis_gui::x [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         lappend ::atos_analysis_gui::y $::atos_analysis_tools::cdl($i,obj_fint)
      }
      
      # affiche la courbe
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y b+

   }
   
   





   proc ::atos_analysis_gui::corr_integ_view { } {
     
     
      ::console::affiche_resultat " int_corr         = $::atos_analysis_gui::int_corr\n"
      ::console::affiche_resultat " raw_integ_offset = $::atos_analysis_gui::raw_integ_offset\n"
      ::console::affiche_resultat " raw_integ_nb_img = $::atos_analysis_gui::raw_integ_nb_img\n"
      ::console::affiche_resultat " tps_corr         = $::atos_analysis_gui::tps_corr\n"
      ::console::affiche_resultat " theo_expo        = $::atos_analysis_gui::theo_expo\n"
      ::console::affiche_resultat " time_offset      = $::atos_analysis_gui::time_offset\n"
      ::console::affiche_resultat " ref_corr         = $::atos_analysis_gui::ref_corr\n"
          
      if {![info exists ::atos_analysis_gui::raw_integ_offset]} {return}
      if {![info exists ::atos_analysis_gui::raw_integ_nb_img]} {return}
      
      if {$::atos_analysis_gui::int_corr == 1} {
         ::atos_analysis_tools::correction_integration $::atos_analysis_gui::raw_integ_offset $::atos_analysis_gui::raw_integ_nb_img
      }
      if {$::atos_analysis_gui::tps_corr == 1} {
         set ::atos_analysis_gui::time_correction [expr ($::atos_analysis_gui::theo_expo/2.0 + $::atos_analysis_gui::time_offset)]
         ::console::affiche_resultat " time_correction  = $::atos_analysis_gui::time_correction\n"
         ::atos_analysis_tools::correction_temporelle
      } else {
         set ::atos_analysis_gui::time_correction 0.0
      }
      if {$::atos_analysis_gui::ref_corr == 1} {
         ::console::affiche_resultat " correction_refetoile \n"
         ::atos_analysis_tools::correction_refetoile
      }
      
      # cree la courbe Rouges pour retrouver les paquets
      set ::atos_analysis_gui::x ""
      set ::atos_analysis_gui::y ""

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::medianecdl($i,jd)]} {continue}
         lappend ::atos_analysis_gui::x [expr ($::atos_analysis_tools::medianecdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0]
         lappend ::atos_analysis_gui::y $::atos_analysis_tools::medianecdl($i,obj_fint)
      }

      # affiche la courbe  couleur: rgbk   symbol: +xo* [list -linewidth 4]
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y rx 
      #  http://www-hermes.desy.de/pink/blt.html#Sect6_4

      # cree la courbe finale, mediane des paquets, correction d offset et correction du flux de reference
      set ::atos_analysis_gui::x ""
      set ::atos_analysis_gui::y ""

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,jd)]} {continue}
         lappend ::atos_analysis_gui::x [expr ($::atos_analysis_tools::finalcdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         lappend ::atos_analysis_gui::y $::atos_analysis_tools::finalcdl($i,obj_fint)
      }

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y go 4

   }















   proc ::atos_analysis_gui::corr_integ_apply { } {

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y rx

      # cree la courbe
      set ::atos_analysis_gui::x ""
      set ::atos_analysis_gui::y ""

      for {set i 1} {$i<=$::atos_analysis_tools::raw_nbframe} {incr i} {
         if {![info exists ::atos_analysis_tools::finalcdl($i,jd)]} {continue}
         lappend ::atos_analysis_gui::x [expr ($::atos_analysis_tools::finalcdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         lappend ::atos_analysis_gui::y $::atos_analysis_tools::finalcdl($i,obj_fint)
      }

      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}

      # affiche la courbe  couleur: rgbk   symbol: +xo*
      ::plotxy::plot $::atos_analysis_gui::x $::atos_analysis_gui::y bo 1


   }
















   proc ::atos_analysis_gui::save_corrected_curve { } {


      set file [string range $::atos_analysis_gui::raw_filename 0 [expr [string last .csv $::atos_analysis_gui::raw_filename] -1]]
      set ::atos_analysis_gui::corr_filename "${file}_CORR.csv"
      set ::atos_analysis_gui::corr_filename_short [file tail $::atos_analysis_gui::corr_filename]

      ::console::affiche_resultat "Sauvegarde de la courbe : $::atos_analysis_gui::corr_filename\n"
      
      set err [catch {::atos_analysis_tools::save_corrected_curve $::atos_analysis_gui::corr_filename} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur de sauvegarde du fichier\n"
         ::console::affiche_erreur "Fichier = $::atos_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      ::plotxy::clf 1
      
   }
















   proc ::atos_analysis_gui::open_corr_file { visuNo frm  } {

      global color

      if {$::atos_analysis_gui::corr_filename==""||![info exists ::atos_analysis_gui::corr_filename]} {return}
      
 
      ::console::affiche_resultat "Chargement de la courbe : $::atos_analysis_gui::corr_filename\n"
      set err [catch {set nb [::atos_analysis_tools::charge_csv $::atos_analysis_gui::corr_filename]} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de chargement du fichier\n"
         ::console::affiche_erreur "Fichier = $::atos_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      set err [catch {::atos_analysis_tools::filtre_corr_data $nb} msg ]
      if {$err} {
         ::console::affiche_erreur "Erreur de lecture de la courbe de lumiere\n"
         ::console::affiche_erreur "Fichier = $::atos_analysis_gui::corr_filename\n"
         ::console::affiche_erreur "Err = $err\n"
         ::console::affiche_erreur "Msg = $msg\n"
         return
      }
      
      $::atos_analysis_tools::corr_status_file_gui configure -fg $color(blue)

      # cree la courbe
      set ::atos_analysis_gui::cdl_x ""
      set ::atos_analysis_gui::cdl_y ""

      for {set i 1} {$i<=$::atos_analysis_tools::corr_nbframe} {incr i} {
         lappend ::atos_analysis_gui::cdl_x [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         lappend ::atos_analysis_gui::cdl_y $::atos_analysis_tools::cdl($i,flux)
      }
      set ::atos_analysis_gui::date_begin_obs [mc_date2iso8601 $::atos_analysis_tools::cdl(1,jd)]
      set ::atos_analysis_gui::date_end_obs   [mc_date2iso8601 $::atos_analysis_tools::cdl($::atos_analysis_tools::corr_nbframe,jd)]
      
      ::atos_analysis_gui::active_graphe $frm.frm.graphe l 1
      
   }















   proc ::atos_analysis_gui::select_corr_data { visuNo frm } {

      global audace

      if {[info exists ::atos_analysis_gui::prj_dir]} {
         set dir $::atos_analysis_gui::prj_dir
      } else {
         set dir $audace(rep_images)
      }

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      set ::atos_analysis_gui::corr_filename [ ::tkutil::box_load_csv $frm $dir $bufNo "1" ]
      set ::atos_analysis_gui::corr_filename_short [file tail $::atos_analysis_gui::corr_filename]

   }

















   proc ::atos_analysis_gui::select_event { e } {

   
      set err [ catch {set rect [::plotxy::get_selected_region]} msg]
      if {$err} {
         return
      }
      set x1 [lindex $rect 0]
      set x2 [lindex $rect 2]
      
      if {$x1>$x2} {
         set t $x1
         set x1 $x2
         set x2 $t
      }
      
      
      set cpt 0
      for {set i 1} {$i<=$::atos_analysis_tools::corr_nbframe} {incr i} {
         set x  [expr ($::atos_analysis_tools::cdl($i,jd) - $::atos_analysis_tools::orig) * 86400.0 ]
         set y  $::atos_analysis_tools::cdl($i,flux)
         if { $x > $x1 && $x < $x2 } {
            incr cpt
            if {$cpt==1} {set id $i}
            set p($cpt,idframe) $x 
            set p($cpt,x) $x 
            set p($cpt,y) $y 
         }
      }
      if {$cpt==0} {return}
      
      if {$e==1} {
         set ::atos_analysis_tools::id_p1           $id
         set ::atos_analysis_tools::corr_duree_e1   [format "%.3f" [expr $p($cpt,x) - $p(1,x)] ]
         set ::atos_analysis_tools::nb_p1 $cpt
      }
      if {$e==2} {
         set ::atos_analysis_gui::duree_max_immersion_search  [format "%.3f" [expr $cpt / $::atos_analysis_tools::corr_fps] ]
         set ::atos_analysis_tools::id_p2           $id
         set ::atos_analysis_tools::corr_duree_e2   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::atos_analysis_tools::nb_p2 $cpt
      }
      if {$e==3} {
         set ::atos_analysis_tools::id_p3           $id
         set ::atos_analysis_tools::corr_duree_e3   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::atos_analysis_tools::nb_p3 $cpt
      }
      if {$e==4} {
         set ::atos_analysis_gui::duree_max_emersion_search  [format "%.3f" [expr $cpt / $::atos_analysis_tools::corr_fps] ]
         set ::atos_analysis_tools::id_p4           $id
         set ::atos_analysis_tools::corr_duree_e4   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::atos_analysis_tools::nb_p4 $cpt
      }
      if {$e==5} {
         set ::atos_analysis_tools::id_p5           $id
         set ::atos_analysis_tools::corr_duree_e5   [format "%.3f"  [expr $p($cpt,x) - $p(1,x)] ]
         set ::atos_analysis_tools::nb_p5 $cpt
      }
      if {$e==6} {
         set ::atos_analysis_gui::duree_max_immersion_evnmt  [format "%.3f" [expr $cpt / $::atos_analysis_tools::corr_fps] ]
         set i [expr int($cpt/2.0)]
         if {$i==0} {incr i}
         set ::atos_analysis_tools::id_p6         [expr $id + $i]
         set ::atos_analysis_gui::date_immersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::atos_analysis_tools::orig ] ]
      }
      if {$e==7} {
         set ::atos_analysis_gui::duree_max_emersion_evnmt  [format "%.3f" [expr $cpt / $::atos_analysis_tools::corr_fps] ]
         set i [expr int($cpt/2.0)]
         if {$i==0} {incr i}
         set ::atos_analysis_tools::id_p7        [expr $id + $i]
         set ::atos_analysis_gui::date_emersion  [ mc_date2iso8601 [expr $p($i,x) / 86400.0 + $::atos_analysis_tools::orig ] ]
      }

   }

















   proc ::atos_analysis_gui::calcul_evenement { e } {

      # Test si calcul en cours      
      if {$::atos_analysis_gui::but_calcul=="Stop"} {
         set ::atos_analysis_tools::but_calcul "Stop"
         return
      }

      set tt0 [clock clicks -milliseconds]

      # On averti qu on va commencer le calcul       
      # BOUTTONS CALCUL -> mode WAIT
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .stop
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .stop
      set ::atos_analysis_gui::but_calcul "Stop"

      # init du repertoire des fichiers de sorti
      set ::atos_analysis_tools::dirwork $::atos_analysis_gui::prj_dir
      set ::atos_analysis_tools::filesout 0

      # Longueur d''onde (m)
      set ::atos_analysis_tools::wvlngth [expr $::atos_analysis_gui::wvlngth * 1.e-09]

      # Bande passante (m)
      set ::atos_analysis_tools::dlambda [expr $::atos_analysis_gui::dlambda * 1.e-09]

      #  Distance a l'anneau (km): distance geocentrique de l objet occulteur
      set ::atos_analysis_tools::dist  [expr $::atos_analysis_gui::dist * [::atos_analysis_tools::ua]]

      #  Rayon de l'etoile (km)
      set ::atos_analysis_tools::re $::atos_analysis_gui::occ_star_size_km

      # Vitesse normale de l'etoile (dans plan du ciel, km/s) ???
      # Vitesse relative de l'objet par rapport a la terre (km/s)
      set ::atos_analysis_tools::vn $::atos_analysis_gui::vn

      # Largeur de la bande (km)
      # Taille estimée de l'objet (km)
      # si occultation rasante c est la taille de la corde (km)
      set ::atos_analysis_tools::width $::atos_analysis_gui::width

      # transmission
      # opaque = 0, sinon demander bruno
      set ::atos_analysis_tools::trans 0

      # pas en temps (sec)
      set ::atos_analysis_tools::pas [expr 1.0 * $::atos_analysis_tools::corr_exposure]

      # on essai 100 points autour du T0 
      # en considerant un ecart entre les points de 0.02 sec
      # on peut dire qu on choisi pas = tmps d expo / 10
      # le pas est une estimation de la precision
      # nheure = 100 *0.02=> duree de 2 sec pour explorer l espace de
      # recherche autour de l evenement
      #
      # Nombre d'instant a explorer autour de la reference (points)
      set ::atos_analysis_tools::nheure $::atos_analysis_gui::nheure
      
      # pas (sec)
      set ::atos_analysis_tools::pas_heure $::atos_analysis_gui::pas_heure
      
      # mediane plateau haut
      set tab ""
      for {set i 1} {$i<=$::atos_analysis_tools::nb_p1} {incr i} {
         set j [expr $i + $::atos_analysis_tools::id_p1 - 1]
         lappend tab $::atos_analysis_tools::cdl($j,flux)
      }
      for {set i 1} {$i<=$::atos_analysis_tools::nb_p5} {incr i} {
         set j [expr $i + $::atos_analysis_tools::id_p5 - 1]
         lappend tab $::atos_analysis_tools::cdl($j,flux)
      }
      set ::atos_analysis_tools::med1 [::math::statistics::median $tab]
      set ::atos_analysis_tools::sigma [expr [::math::statistics::stdev $tab]/ $::atos_analysis_tools::med1]

      # mediane plateau bas
      set tab ""
      for {set i 1} {$i<=$::atos_analysis_tools::nb_p3} {incr i} {
         incr cpt
         set j [expr $i + $::atos_analysis_tools::id_p3 - 1]
         lappend tab $::atos_analysis_tools::cdl($j,flux)
      }
      set med0 [::math::statistics::median $tab]
      ::console::affiche_resultat "med0: $med0\n"      
      ::console::affiche_resultat "med1: $::atos_analysis_tools::med1\n"      

      # normalisation du flux
      set ::atos_analysis_tools::phi1 1
      set ::atos_analysis_tools::phi0 [expr $med0 / $::atos_analysis_tools::med1]
      ::console::affiche_resultat "phi0: $::atos_analysis_tools::phi0\n"      
      ::console::affiche_resultat "phi1: $::atos_analysis_tools::phi1\n"      

      if {$e == -1} {
      
         # Mode immersion
         set ::atos_analysis_tools::mode -1
         set type "Immersion"

         # 
         # on a 5 secondes dans lesquelles on va mesurer l instant
         # on a37 points de 0.3 sec d ecart
         # 
         # 
         # Duree generee (points)
         # duree synthetique choisie autour de l'evenement.
         # ex: 30 sec alrs que l evenement est au milieu.
         # attention de ne pas choisir trop large pour englober
         # l'autre evenement.
         set ::atos_analysis_tools::duree $::atos_analysis_tools::nb_p2

         # Heure de reference (sec TU)
         set t  [ mc_date2jd $::atos_analysis_gui::date_immersion]
         set ::atos_analysis_tools::t0_ref [expr ( $t - $::atos_analysis_tools::orig ) * 86400.0]
         set ::atos_analysis_tools::t_milieu [expr $::atos_analysis_tools::t0_ref  + $::atos_analysis_tools::width/(2.0*$::atos_analysis_tools::vn)]

         set ::atos_analysis_tools::t0_min [expr $::atos_analysis_tools::t0_ref - $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
         set ::atos_analysis_tools::t0_max [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
         set ::atos_analysis_tools::t0     $::atos_analysis_tools::t0_min

         # tableau des observations
         for {set i 1} {$i<=$::atos_analysis_tools::nb_p2} {incr i} {
            set j [expr $i + $::atos_analysis_tools::id_p2 - 1]
            set ::atos_analysis_tools::tobs($i) [expr ($::atos_analysis_tools::cdl($j,jd)-$::atos_analysis_tools::orig) * 86400.0]
            set ::atos_analysis_tools::fobs($i) [expr $::atos_analysis_tools::cdl($j,flux)/$::atos_analysis_tools::med1]
         }

         set ::atos_analysis_tools::chi2_search ""

         # Premier passage recherche du meilleur temps
         set err [ catch {::atos_analysis_tools::partie2 1} msg ]
         if {$err} {
            ::console::affiche_erreur "Erreur durant le calcul\n"
            ::console::affiche_erreur "Err = $err\n"
            ::console::affiche_erreur "Msg = $msg\n"

            # BOUTTONS CALCUL -> mode Ok
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::atos_analysis_gui::but_calcul "Calcul"

            return
         }
         if {$::atos_analysis_tools::but_calcul=="Stop"} {
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::atos_analysis_gui::but_calcul "Calcul"
            return
         }
         
         
         if {1==1} {
         
            set nheuresav $::atos_analysis_tools::nheure
            set ::atos_analysis_tools::nheure   1
            set ::atos_analysis_tools::t0_ref   $::atos_analysis_tools::t0_chi2_min
            set ::atos_analysis_tools::t_milieu [expr $::atos_analysis_tools::t0_ref  + $::atos_analysis_tools::width/(2.0*$::atos_analysis_tools::vn)]
            set ::atos_analysis_tools::t0_min   [expr $::atos_analysis_tools::t0_ref - $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
            set ::atos_analysis_tools::t0_max   [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
            set ::atos_analysis_tools::t0       $::atos_analysis_tools::t0_min

            # Deuxieme passage initialisation des resultats
            set err [ catch {::atos_analysis_tools::partie2 2} msg ]
            if {$err} {
               ::console::affiche_erreur "Erreur durant le calcul\n"
               ::console::affiche_erreur "Err = $err\n"
               ::console::affiche_erreur "Msg = $msg\n"

               # BOUTTONS CALCUL -> mode Ok
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::atos_analysis_gui::but_calcul "Calcul"

               return
            }
            set ::atos_analysis_tools::nheure $nheuresav
            if {$::atos_analysis_tools::but_calcul=="Stop"} {
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::atos_analysis_gui::but_calcul "Calcul"
               return
            }

         }
         
         ::console::affiche_resultat "orig: $::atos_analysis_tools::orig\n"      
         ::console::affiche_resultat "t0_chi2_min: $::atos_analysis_tools::t0_chi2_min\n"      
         ::console::affiche_resultat "t0_norm: [expr $::atos_analysis_tools::t0_chi2_min / 86400.0 + $::atos_analysis_tools::orig]\n"      
         
         set ::atos_analysis_gui::date_immersion_sol [ mc_date2iso8601 [expr $::atos_analysis_tools::t0_chi2_min / 86400.0 + $::atos_analysis_tools::orig] ]

         set t $::atos_analysis_tools::t0_chi2_min
         set ::atos_analysis_tools::im_evenement_x [list $t $t]
         set ::atos_analysis_tools::im_evenement_y [list 0 $::atos_analysis_tools::med1]

         set ::atos_analysis_gui::im_chi2_min      $::atos_analysis_tools::chi2_min     
         set ::atos_analysis_gui::im_nfit_chi2_min $::atos_analysis_tools::nfit_chi2_min
         set ::atos_analysis_gui::im_t0_chi2_min   $::atos_analysis_tools::t0_chi2_min  
         set ::atos_analysis_gui::im_t_inf         $::atos_analysis_tools::t_inf        
         set ::atos_analysis_gui::im_t_sup         $::atos_analysis_tools::t_sup        
         set ::atos_analysis_gui::im_t_diff        $::atos_analysis_tools::t_diff       
         set ::atos_analysis_gui::im_t_inf_2s      $::atos_analysis_tools::t_inf_2s     
         set ::atos_analysis_gui::im_t_sup_2s      $::atos_analysis_tools::t_sup_2s     
         set ::atos_analysis_gui::im_t_diff_2s     $::atos_analysis_tools::t_diff_2s    
         set ::atos_analysis_gui::im_t_inf_3s      $::atos_analysis_tools::t_inf_3s     
         set ::atos_analysis_gui::im_t_sup_3s      $::atos_analysis_tools::t_sup_3s     
         set ::atos_analysis_gui::im_t_diff_3s     $::atos_analysis_tools::t_diff_3s    

      }
      
      
      if {$e==1} {
      
         # Mode Emersion
         set ::atos_analysis_tools::mode 1
         set type "Emersion"

         # 
         # on a 5 secondes dans lesquelles on va mesurer l instant
         # on a37 points de 0.3 sec d ecart
         # 
         # 
         # Duree generee (points)
         # duree synthetique choisie autour de l'evenement.
         # ex: 30 sec alrs que l evenement est au milieu.
         # attention de ne pas choisir trop large pour englober
         # l'autre evenement.
         set ::atos_analysis_tools::duree $::atos_analysis_tools::nb_p4

         # Heure de reference (sec TU)
         set t  [ mc_date2jd $::atos_analysis_gui::date_emersion]
         set ::atos_analysis_tools::t0_ref [expr ( $t - $::atos_analysis_tools::orig ) * 86400.0]
         set ::atos_analysis_tools::t_milieu [expr $::atos_analysis_tools::t0_ref  + $::atos_analysis_tools::width/(2.0*$::atos_analysis_tools::vn)]
      
         set ::atos_analysis_tools::t0_min [expr $::atos_analysis_tools::t0_ref - $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
         set ::atos_analysis_tools::t0_max [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
         set ::atos_analysis_tools::t0     $::atos_analysis_tools::t0_min

         # tableau des observations
         for {set i 1} {$i<=$::atos_analysis_tools::nb_p4} {incr i} {
            set j [expr $i + $::atos_analysis_tools::id_p4 - 1]
            set ::atos_analysis_tools::tobs($i) [expr ($::atos_analysis_tools::cdl($j,jd)-$::atos_analysis_tools::orig) * 86400.0]
            set ::atos_analysis_tools::fobs($i) [expr $::atos_analysis_tools::cdl($j,flux)/$::atos_analysis_tools::med1]
         }

         set ::atos_analysis_tools::chi2_search ""

         # Premier passage recherche du meilleur temps
         set err [ catch {::atos_analysis_tools::partie2 1} msg ]
         if {$err} {
            ::console::affiche_erreur "Erreur durant le calcul\n"
            ::console::affiche_erreur "Err = $err\n"
            ::console::affiche_erreur "Msg = $msg\n"

            # BOUTTONS CALCUL -> mode Ok
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::atos_analysis_gui::but_calcul "Calcul"

            return
         }
         if {$::atos_analysis_tools::but_calcul=="Stop"} {
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
            .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
            set ::atos_analysis_gui::but_calcul "Calcul"
            return
         }
         
         if {1==1} {
         
            set nheuresav $::atos_analysis_tools::nheure
            set ::atos_analysis_tools::nheure   1
            set ::atos_analysis_tools::t0_ref   $::atos_analysis_tools::t0_chi2_min
            set ::atos_analysis_tools::t_milieu [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::width/(2.0*$::atos_analysis_tools::vn)]
            set ::atos_analysis_tools::t0_min   [expr $::atos_analysis_tools::t0_ref - $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
            set ::atos_analysis_tools::t0_max   [expr $::atos_analysis_tools::t0_ref + $::atos_analysis_tools::pas_heure * $::atos_analysis_tools::nheure / 2.0]
            set ::atos_analysis_tools::t0       $::atos_analysis_tools::t0_min



            # Deuxieme passage initialisation des resultats
            set err [ catch {::atos_analysis_tools::partie2 2} msg ]
            if {$err} {
               ::console::affiche_erreur "Erreur durant le calcul\n"
               ::console::affiche_erreur "Err = $err\n"
               ::console::affiche_erreur "Msg = $msg\n"

               # BOUTTONS CALCUL -> mode Ok
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::atos_analysis_gui::but_calcul "Calcul"

               return
            }
            set ::atos_analysis_tools::nheure $nheuresav
            if {$::atos_analysis_tools::but_calcul=="Stop"} {
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
               .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
               set ::atos_analysis_gui::but_calcul "Calcul"
               return
            }

         }
         
         ::console::affiche_resultat "orig: $::atos_analysis_tools::orig\n"      
         ::console::affiche_resultat "t0_chi2_min: $::atos_analysis_tools::t0_chi2_min\n"      
         ::console::affiche_resultat "t0_norm: [expr $::atos_analysis_tools::t0_chi2_min / 86400.0 + $::atos_analysis_tools::orig]\n"      
         
         set ::atos_analysis_gui::date_emersion_sol [ mc_date2iso8601 [expr $::atos_analysis_tools::t0_chi2_min / 86400.0 + $::atos_analysis_tools::orig] ]

         set t $::atos_analysis_tools::t0_chi2_min
         set ::atos_analysis_tools::em_evenement_x [list $t $t]
         set ::atos_analysis_tools::em_evenement_y [list 0 $::atos_analysis_tools::med1]

         set ::atos_analysis_gui::em_chi2_min      $::atos_analysis_tools::chi2_min     
         set ::atos_analysis_gui::em_nfit_chi2_min $::atos_analysis_tools::nfit_chi2_min
         set ::atos_analysis_gui::em_t0_chi2_min   $::atos_analysis_tools::t0_chi2_min  
         set ::atos_analysis_gui::em_t_inf         $::atos_analysis_tools::t_inf        
         set ::atos_analysis_gui::em_t_sup         $::atos_analysis_tools::t_sup        
         set ::atos_analysis_gui::em_t_diff        $::atos_analysis_tools::t_diff       
         set ::atos_analysis_gui::em_t_inf_2s      $::atos_analysis_tools::t_inf_2s     
         set ::atos_analysis_gui::em_t_sup_2s      $::atos_analysis_tools::t_sup_2s     
         set ::atos_analysis_gui::em_t_diff_2s     $::atos_analysis_tools::t_diff_2s    
         set ::atos_analysis_gui::em_t_inf_3s      $::atos_analysis_tools::t_inf_3s     
         set ::atos_analysis_gui::em_t_sup_3s      $::atos_analysis_tools::t_sup_3s     
         set ::atos_analysis_gui::em_t_diff_3s     $::atos_analysis_tools::t_diff_3s    

      }
      
      # Si l immersion et l emersion ont ete calculé alors on calcule la duree et la taille de la bande
      if {[info exists ::atos_analysis_gui::date_emersion_sol]} {
         if {$::atos_analysis_gui::date_emersion_sol!=""} {
            if {[info exists ::atos_analysis_gui::date_immersion_sol]} {
               if {$::atos_analysis_gui::date_immersion_sol!=""} {
                  set ::atos_analysis_gui::duree [format "%.3f" [expr ([mc_date2jd $::atos_analysis_gui::date_emersion_sol]-[mc_date2jd $::atos_analysis_gui::date_immersion_sol])*86400.0] ]
                  set ::atos_analysis_gui::bande [format "%.3f" [expr $::atos_analysis_gui::duree * $::atos_analysis_gui::vn] ]
               }
            }
         }
      }
      
      # BOUTTONS CALCUL -> mode Ok
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f6.frm.calcul.blockcentre.but_calc configure -image .calc
      .audace.atos_analysis.frm_atos_analysis_gui.onglets.nb.f7.frm.calcul.blockcentre.but_calc configure -image .calc
      set ::atos_analysis_gui::but_calcul "Calcul"

      set tt [format "%.3f" [expr ([clock clicks -milliseconds] - $tt0)/1000.]]
      ::console::affiche_resultat "Traitement total en $tt secondes\n"

       tk_messageBox -message "Calcul $type terminé en $tt secondes" -type ok

      ::atos_analysis_gui::affiche_graphe
      
   }
      













   proc ::atos_analysis_gui::affiche_graphe { } {
      
      # recupere les axes d un graphe 
      #  set ax [::plotxy::axis]
      
      # defninit les axes d un graphe 
      #  ::plotxy::axis $ax
      
      # Faire une trainée plus epaisse
      # [list -linewidth 4]
      
      # cacher un plot
      # plotxy::sethandler $::atos_analysis_gui::h1 [list -hide yes]
      
      # montrer un plot
      # plotxy::sethandler $::atos_analysis_gui::h1 [list -hide no]
      # ::plotxy::axis $ax

      # affiche la courbe
      set err [catch {set ax [::plotxy::getzoom]} msg ]
      if {!$err} {
         ::console::affiche_resultat "ZOOM: $ax\n"      
      } else {
      
    
      }
      
      ::plotxy::clf 1
      ::plotxy::figure 1 
      ::plotxy::hold on 
      ::plotxy::position {40 40 600 400}
      
      if {!$err&&$::atos_analysis_gui::state_but_graph(24)!=1} {
         ::plotxy::setzoom $ax
      }

      # Signal photométrique (noir)
      if {$::atos_analysis_gui::state_but_graph(1)==1} {
         set h1 [::plotxy::plot $::atos_analysis_gui::cdl_x $::::atos_analysis_gui::cdl_y .]
         plotxy::sethandler $h1 [list -color #000000 -linewidth 1]
      }
      # Polynome (noir)
      if {$::atos_analysis_gui::state_but_graph(2)==1} {
         set h2 [::plotxy::plot $::atos_analysis_tools::poly_x $::atos_analysis_tools::poly_y o]
         plotxy::sethandler $h2 [list -color #18ad86 -linewidth 1]
      }
      # Evenements
      if {$::atos_analysis_gui::state_but_graph(3)==1} {
         if {[info exists ::atos_analysis_tools::im_evenement_x]&&[info exists ::atos_analysis_tools::im_evenement_y]} {
            set h3 [::plotxy::plot $::atos_analysis_tools::im_evenement_x $::atos_analysis_tools::im_evenement_y o]
            plotxy::sethandler $h3 [list -color #00fffc -linewidth 1]
         }
         if {[info exists ::atos_analysis_tools::em_evenement_x]&&[info exists ::atos_analysis_tools::em_evenement_y]} {
            set h4 [::plotxy::plot $::atos_analysis_tools::em_evenement_x $::atos_analysis_tools::em_evenement_y o]
            plotxy::sethandler $h4 [list -color #00fffc -linewidth 1]
         }
      }
      # Ombre géométrique (jaune fff500)
      if {$::atos_analysis_gui::state_but_graph(20)==1} {
         set h20 [::plotxy::plot $::atos_analysis_tools::20_ombre_geometrique_x $::atos_analysis_tools::20_ombre_geometrique_y o]
         plotxy::sethandler $h20 [list -color #fff500 -linewidth 1]
      }
      # Ombre avec diffraction (Fresnel) (bleue 002aff)
      if {$::atos_analysis_gui::state_but_graph(21)==1} {
         set h21 [::plotxy::plot $::atos_analysis_tools::21_ombre_avec_diffraction_x $::atos_analysis_tools::21_ombre_avec_diffraction_y o]
         plotxy::sethandler $h21 [list -color #002aff -linewidth 1]
      }
      # Ombre lissee par la reponse instrumentale (donne par le modele) (magenta=ff00fc)
      if {$::atos_analysis_gui::state_but_graph(22)==1} {
         set h22 [::plotxy::plot $::atos_analysis_tools::22_ombre_instru_x $::atos_analysis_tools::22_ombre_instru_y o]
         plotxy::sethandler $h22 [list -color #ff00fc -linewidth 1]
      }
      # Ombre interpolée sur les points d'observation (rouge=ff0000)
      if {$::atos_analysis_gui::state_but_graph(23)==1} {
         set h23 [::plotxy::plot $::atos_analysis_tools::23_ombre_interpol_x $::atos_analysis_tools::23_ombre_interpol_y o]
         plotxy::sethandler $h23 [list -color #ff0000 -linewidth 0]
      }
      # Chi2 (vert foncé 18ad00)
      if {$::atos_analysis_gui::state_but_graph(24)==1} {
         set h24 [::plotxy::plot $::atos_analysis_tools::24_chi2_x $::atos_analysis_tools::24_chi2_y o]
         plotxy::sethandler $h24 [list -color #18ad00 -linewidth 1]
      }
      
      

   }
















   proc ::atos_analysis_gui::active_graphe { frame c b } {
   
   
      if {$::atos_analysis_gui::state_but_graph($b) == 1} {
         set ::atos_analysis_gui::state_but_graph($b) 0
         $frame.$c.$b.view configure -relief "raised"
      } else {
         set ::atos_analysis_gui::state_but_graph($b) 1 
         $frame.$c.$b.view configure -relief "sunken"
      }
      
      if {$b==24} {
         set lb [list 1 2 3 20 21 22 23]
         if {$::atos_analysis_gui::state_but_graph($b)==1 } {
            foreach bp $lb {
               set ::atos_analysis_gui::state_but_graph($bp) 0
            }
            $frame.l.1.view configure -relief "raised"
            $frame.l.3.view configure -relief "raised"
            $frame.l.2.view configure -relief "raised"
            $frame.r.21.view configure -relief "raised"
            $frame.r.22.view configure -relief "raised"
            $frame.r.23.view configure -relief "raised"
            $frame.r.20.view configure -relief "raised"
         } else {
            set ::atos_analysis_gui::state_but_graph(1) 1 
            $frame.l.1.view configure -relief "sunken"
         }
      } else {
         set ::atos_analysis_gui::state_but_graph(24) 0 
         $frame.l.24.view configure -relief "raised"
      }
      
      ::atos_analysis_gui::affiche_graphe
   
   }



















   proc ::atos_analysis_gui::calcul_dureesearch { frm e } {

      global color

      if {$e==-1} {
         if {![info exists ::atos_analysis_gui::duree_max_immersion_search]} {
            return
         }
         if {$::atos_analysis_gui::duree_max_immersion_search==""} {
            return
         }
         if {![info exists ::atos_analysis_gui::duree_max_immersion_evnmt]} {
            return
         }
         if {$::atos_analysis_gui::duree_max_immersion_evnmt==""} {
            return
         }
         set duree_max_search $::atos_analysis_gui::duree_max_immersion_search 
         set duree_max_evnmt  $::atos_analysis_gui::duree_max_immersion_evnmt
      }
      if {$e==1} {
         if {![info exists ::atos_analysis_gui::duree_max_emersion_search]} {
            return
         }
         if {$::atos_analysis_gui::duree_max_emersion_search==""} {
            return
         }
         if {![info exists ::atos_analysis_gui::duree_max_emersion_evnmt]} {
            return
         }
         if {$::atos_analysis_gui::duree_max_emersion_evnmt==""} {
            return
         }
         set duree_max_search $::atos_analysis_gui::duree_max_emersion_search 
         set duree_max_evnmt  $::atos_analysis_gui::duree_max_emersion_evnmt
      }

      
      if {$::atos_analysis_gui::pas_heure==""} {
         set ::atos_analysis_gui::dureesearch "?"
         return
      }
      
      if {$::atos_analysis_gui::nheure==""} {
         set ::atos_analysis_gui::dureesearch "?"
         return
      }
      
      if {![string is double $::atos_analysis_gui::pas_heure]} {
         set ::atos_analysis_gui::dureesearch "?"
         return
      }
      
      if {![string is double $::atos_analysis_gui::nheure]} {
         set ::atos_analysis_gui::dureesearch "?"
         return
      }
      
      set ::atos_analysis_gui::dureesearch [format "%.3f" [expr $::atos_analysis_gui::pas_heure * $::atos_analysis_gui::nheure]]
      
      $frm.v configure -fg $color(blue)
      if {$::atos_analysis_gui::dureesearch > $duree_max_search } {
         $frm.v configure -fg $color(red)
      }
      if {$::atos_analysis_gui::dureesearch < $duree_max_evnmt } {
         $frm.v configure -fg $color(red)
      }
      
      
      
   }   



















   proc ::atos_analysis_gui::generer { visuNo } {

      if {![info exists ::atos_analysis_gui::occ_obj]} {
         tk_messageBox -message "Veuillez entrer le nom d'un objet occulteur" -type ok
         return
      }
      if {![info exists ::atos_analysis_gui::occ_date]} {
         tk_messageBox -message "Veuillez entrer une date d'occultation" -type ok
         return
      }
      if {![info exists ::atos_analysis_gui::occ_pos]} {
         tk_messageBox -message "Veuillez entrer une position de l'observateur. Le code 500 du geocentre peut etre mis en attendant une position plus précise." -type ok
         return
      }
      if {![info exists ::atos_analysis_gui::occ_pos_type]} {
         tk_messageBox -message "Veuillez selectionner un type de position de l'observateur. 'Code UAI' ou 'Lon (deg, <0 vers l'Est) Lat (deg) Alt (m)'" -type ok
         return
      }
      if {$::atos_analysis_gui::occ_obj==""} {
         tk_messageBox -message "Veuillez saisir les informations du Contexte et valider avec Miriade." -type ok
         return
      }
      if {$::atos_analysis_gui::occ_date==""} {
         tk_messageBox -message "Veuillez entrer une date d'occultation" -type ok
         return
      }
      if {$::atos_analysis_gui::occ_pos==""} {
         tk_messageBox -message "Veuillez entrer une position de l'observateur. Le code 500 du geocentre peut etre mis en attendant une position plus précise." -type ok
         return
      }
      if {$::atos_analysis_gui::occ_pos_type==""} {
         tk_messageBox -message "Veuillez selectionner un type de position de l'observateur. 'Code UAI' ou 'Lon Lat Alt'" -type ok
         return
      }
      
      # 2010-06-05_80_Sappho_Lat+48.0001_Lon_+02.0001

      if {1==1} {
         set date [mc_date2jd $::atos_analysis_gui::occ_date ]
         set date [mc_date2ymdhms $date]
         set y [lindex $date 0]
         set m [format "%0.2d" [lindex $date 1]]
         set d [format "%0.2d" [lindex $date 2]]
         set h [format "%0.2d" [lindex $date 3]]
         set m [format "%0.2d" [lindex $date 4]]
         set s [format "%0.2d" [expr int([lindex $date 5])]]
         set date "${y}${m}${d}_${h}${m}${s}"
      } else {
         set date $::atos_analysis_gui::occ_date
         regsub -all {\-} $date {}   date
         regsub -all { }  $date {_}  date
         regsub -all {T}  $date {_}  date
         regsub -all {:}  $date {}   date
         set d [split $date "."]
         set date [lindex $d 0]
         #regsub -all {\.} $date {_}  date
      }

      gren_info "Date = $date\n"

      #Type
      if {$::atos_analysis_gui::occ_pos_type=="Code UAI"} {
         set pos  "UAI_$::atos_analysis_gui::occ_pos"
      } else {
         set pos $::atos_analysis_gui::occ_pos
         regsub -all -- {[[:space:]]+} $pos " " pos
         set pos [split $pos]
         foreach s_el $pos {
            ::console::affiche_resultat  "$s_el\n"
         }
         
         set longw [lindex $pos 0]
         set latn  [lindex $pos 1]
         set nb [regexp -all {\-} $longw]
         if {$nb==0} {
            set nb [regexp -all {\+} $longw]
            if {$nb==0} {
               set longw "+$longw"
            }
         }
         set nb [regexp -all {\-} $latn]
         if {$nb==0} {
            set nb [regexp -all {\+} $latn]
            if {$nb==0} {
               set latn "+$latn"
            }
         }
         
         set pos "LonW${longw}_LatN${latn}"
         
         #set pos [split $::atos_analysis_gui::occ_pos " "]
         #Tset pos [split $::atos_analysis_gui::occ_pos " "]
         #Tset longw [lindex $pos 0]
      }

      if {$::atos_analysis_gui::occ_tag==""} {
         set tag  ""
      } else {
         set tag "_$::atos_analysis_gui::occ_tag"
      }

      # Nom de l objet
      set name [::atos_analysis_gui::cleanEntities $::atos_analysis_gui::occ_obj]

      # Construction du fichier
      set filename "${date}_${name}_${pos}${tag}"

      if { $::atos::parametres(atos,$visuNo,dir_prj)!="" } {
         set ::atos_analysis_gui::prj_dir [file join $::atos::parametres(atos,$visuNo,dir_prj) $filename]
      }

      set ::atos_analysis_gui::prj_file [file join $::atos_analysis_gui::prj_dir "$filename.atos"]
      set ::atos_analysis_gui::prj_file_short "$filename.atos"

      set a1 [file exists $::atos_analysis_gui::prj_file]
      set a2 [file exists $::atos_analysis_gui::prj_dir]

      set msg "Creation du projet :\n"
      if {$a1 == 0} {set msg "${msg}  - le fichier projet va être créé.\n"}
      if {$a2 == 0} {set msg "${msg}  - le repertoire projet va être créé.\n"}
      if {$a1 == 1 && $a2 == 1} {return}
      
      set res [tk_messageBox -message $msg -type yesno]

      if {$res == "no"} {return}

      set err [catch {file mkdir $::atos_analysis_gui::prj_dir} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur creation du repertoire\n"
         ::console::affiche_erreur "DIR=$::atos_analysis_gui::prj_dir\n"
         ::console::affiche_erreur "ERR=$err\n"
         ::console::affiche_erreur "MSG=$msg\n"
      }

      set err [catch {save_project} msg]
      if {$err} {
         ::console::affiche_erreur "Erreur sauvegarde du projet\n"
         ::console::affiche_erreur "ERR=$err\n"
         ::console::affiche_erreur "MSG=$msg\n"
      }

      return
   }





   #
   # Charge du fichier projet
   #
   proc ::atos_analysis_gui::load_atos_file { {no_msg 0} } {

      if {![info exists ::atos_analysis_gui::prj_file]} {
         if {$no_msg == 0} { tk_messageBox -message "Veuillez selectionner un fichier" -type ok }
         return -code 0 "no"
      } else {
         if {$::atos_analysis_gui::prj_file == ""} {
            if {$no_msg == 0} { tk_messageBox -message "Aucun fichier selectionne" -type ok }
            return -code 0 "no"
         }
      }

      if {[file exists $::atos_analysis_gui::prj_file] == 0} {
         tk_messageBox -message "Le fichier n'existe pas !" -type ok
         return -code 0 "no"
      }
      
      source $::atos_analysis_gui::prj_file

   }




   #
   # Selection du fichier projet
   #
   proc ::atos_analysis_gui::select_atos_file { visuNo frm } {

      global audace

      set fenetre [::confVisu::getBase $visuNo]
      set bufNo [ visu$visuNo buf ]
      
      set loaded_file [ ::tkutil::box_load_atos $frm $::atos::parametres(atos,$visuNo,dir_prj) $bufNo "1" ]

      if {$loaded_file != ""} {
         set ::atos_analysis_gui::prj_file $loaded_file
         set ::atos_analysis_gui::prj_file_short [file tail $::atos_analysis_gui::prj_file]
         set ::atos_analysis_gui::prj_dir        [file dirname $::atos_analysis_gui::prj_file]
      }

   }   








#
# Clean special characters into string
# @param string chaine a convertir
# @return chunk chaine convertie
proc ::atos_analysis_gui::cleanEntities { chunk } {
   regsub -all { }  $chunk {} chunk
   regsub -all {!}  $chunk {} chunk
   regsub -all {#}  $chunk {} chunk
   regsub -all {\$} $chunk {} chunk
   regsub -all {\&} $chunk {} chunk
   regsub -all {'}  $chunk {} chunk
   regsub -all {\(} $chunk {} chunk
   regsub -all {\)} $chunk {} chunk
   regsub -all {\*} $chunk {} chunk
   regsub -all {\+} $chunk {} chunk
   regsub -all {\-} $chunk {} chunk
   regsub -all {,}  $chunk {} chunk
   regsub -all {=}  $chunk {} chunk
   regsub -all {\?} $chunk {} chunk
   regsub -all {@}  $chunk {} chunk
   regsub -all {\[} $chunk {} chunk
   regsub -all {\]} $chunk {} chunk
   regsub -all {\^} $chunk {} chunk
   regsub -all {`}  $chunk {} chunk
   regsub -all {\{} $chunk {} chunk
   regsub -all {\|} $chunk {} chunk
   regsub -all {\}} $chunk {} chunk
   regsub -all {~}  $chunk {} chunk
   regsub -all {:}  $chunk {} chunk
   regsub -all {/}  $chunk {} chunk
   regsub -all {\.} $chunk {} chunk
   return $chunk
}













   #
   # Sauvegarde du fichier projet
   #
   proc ::atos_analysis_gui::save_project { } {

      set a1 [file exists $::atos_analysis_gui::prj_file]
      if {$a1 == 1} {
         set res [tk_messageBox -message "Le fichier existe. Voulez vous l'écraser ?" -type yesno]
         if {$res == "no"} {return -code 0 "no"}
      }

      set chan [open $::atos_analysis_gui::prj_file w]

      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_date                  ]} {set ::atos_analysis_gui::occ_date                   ""}
      if {![info exists ::atos_analysis_gui::occ_pos                   ]} {set ::atos_analysis_gui::occ_pos                    ""}
      if {![info exists ::atos_analysis_gui::occ_pos_type              ]} {set ::atos_analysis_gui::occ_pos_type               ""}
      if {![info exists ::atos_analysis_gui::occ_obj_name              ]} {set ::atos_analysis_gui::occ_obj_name               ""}
      if {![info exists ::atos_analysis_gui::occ_obj_id                ]} {set ::atos_analysis_gui::occ_obj_id                 ""}
      if {![info exists ::atos_analysis_gui::occ_tag                   ]} {set ::atos_analysis_gui::occ_tag                    ""}
      if {![info exists ::atos_analysis_gui::prj_file_short            ]} {set ::atos_analysis_gui::prj_file_short             ""}
      if {![info exists ::atos_analysis_gui::prj_file                  ]} {set ::atos_analysis_gui::prj_file                   ""}
      if {![info exists ::atos_analysis_gui::prj_dir                   ]} {set ::atos_analysis_gui::prj_dir                    ""}
      if {![info exists ::atos_analysis_gui::jd                        ]} {set ::atos_analysis_gui::jd                         ""}
      if {![info exists ::atos_analysis_gui::rajapp                    ]} {set ::atos_analysis_gui::rajapp                     ""}
      if {![info exists ::atos_analysis_gui::decapp                    ]} {set ::atos_analysis_gui::decapp                     ""}
      if {![info exists ::atos_analysis_gui::dist                      ]} {set ::atos_analysis_gui::dist                       ""}
      if {![info exists ::atos_analysis_gui::magv                      ]} {set ::atos_analysis_gui::magv                       ""}
      if {![info exists ::atos_analysis_gui::phase                     ]} {set ::atos_analysis_gui::phase                      ""}
      if {![info exists ::atos_analysis_gui::elong                     ]} {set ::atos_analysis_gui::elong                      ""}
      if {![info exists ::atos_analysis_gui::dracosd                   ]} {set ::atos_analysis_gui::dracosd                    ""}
      if {![info exists ::atos_analysis_gui::ddec                      ]} {set ::atos_analysis_gui::ddec                       ""}
      if {![info exists ::atos_analysis_gui::vn                        ]} {set ::atos_analysis_gui::vn                         ""}
      if {![info exists ::atos_analysis_gui::tsl                       ]} {set ::atos_analysis_gui::tsl                        ""}
      if {![info exists ::atos_analysis_gui::raj2000                   ]} {set ::atos_analysis_gui::raj2000                    ""}
      if {![info exists ::atos_analysis_gui::decj2000                  ]} {set ::atos_analysis_gui::decj2000                   ""}
      if {![info exists ::atos_analysis_gui::hourangle                 ]} {set ::atos_analysis_gui::hourangle                  ""}
      if {![info exists ::atos_analysis_gui::decapp                    ]} {set ::atos_analysis_gui::decapp                     ""}
      if {![info exists ::atos_analysis_gui::azimuth                   ]} {set ::atos_analysis_gui::azimuth                    ""}
      if {![info exists ::atos_analysis_gui::hauteur                   ]} {set ::atos_analysis_gui::hauteur                    ""}
      if {![info exists ::atos_analysis_gui::airmass                   ]} {set ::atos_analysis_gui::airmass                    ""}
      if {![info exists ::atos_analysis_gui::dhelio                    ]} {set ::atos_analysis_gui::dhelio                     ""}
      if {![info exists ::atos_analysis_gui::raw_filename_short        ]} {set ::atos_analysis_gui::raw_filename_short         ""}
      if {![info exists ::atos_analysis_gui::raw_filename              ]} {set ::atos_analysis_gui::raw_filename               ""}
      if {![info exists ::atos_analysis_gui::raw_integ_offset          ]} {set ::atos_analysis_gui::raw_integ_offset           0}
      if {![info exists ::atos_analysis_gui::raw_integ_nb_img          ]} {set ::atos_analysis_gui::raw_integ_nb_img           1}
      if {![info exists ::atos_analysis_gui::int_corr                  ]} {set ::atos_analysis_gui::int_corr                   1}
      if {![info exists ::atos_analysis_gui::tps_corr                  ]} {set ::atos_analysis_gui::tps_corr                   0}
      if {![info exists ::atos_analysis_gui::theo_expo                 ]} {set ::atos_analysis_gui::theo_expo                  0}
      if {![info exists ::atos_analysis_gui::time_offset               ]} {set ::atos_analysis_gui::time_offset                0.03}
      if {![info exists ::atos_analysis_gui::ref_corr                  ]} {set ::atos_analysis_gui::ref_corr                   0}
      if {![info exists ::atos_analysis_gui::corr_filename_short       ]} {set ::atos_analysis_gui::corr_filename_short        ""}
      if {![info exists ::atos_analysis_gui::corr_filename             ]} {set ::atos_analysis_gui::corr_filename              ""}
      if {![info exists ::atos_analysis_tools::id_p1                   ]} {set ::atos_analysis_tools::id_p1                    ""}
      if {![info exists ::atos_analysis_tools::corr_duree_e1           ]} {set ::atos_analysis_tools::corr_duree_e1            ""}
      if {![info exists ::atos_analysis_tools::nb_p1                   ]} {set ::atos_analysis_tools::nb_p1                    ""}
      if {![info exists ::atos_analysis_gui::duree_max_immersion_search]} {set ::atos_analysis_gui::duree_max_immersion_search ""}
      if {![info exists ::atos_analysis_tools::id_p2                   ]} {set ::atos_analysis_tools::id_p2                    ""}
      if {![info exists ::atos_analysis_tools::corr_duree_e2           ]} {set ::atos_analysis_tools::corr_duree_e2            ""}
      if {![info exists ::atos_analysis_tools::nb_p2                   ]} {set ::atos_analysis_tools::nb_p2                    ""}
      if {![info exists ::atos_analysis_tools::id_p3                   ]} {set ::atos_analysis_tools::id_p3                    ""}
      if {![info exists ::atos_analysis_tools::corr_duree_e3           ]} {set ::atos_analysis_tools::corr_duree_e3            ""}
      if {![info exists ::atos_analysis_tools::nb_p3                   ]} {set ::atos_analysis_tools::nb_p3                    ""}
      if {![info exists ::atos_analysis_gui::duree_max_emersion_search ]} {set ::atos_analysis_gui::duree_max_emersion_search  ""}
      if {![info exists ::atos_analysis_tools::id_p4                   ]} {set ::atos_analysis_tools::id_p4                    ""}
      if {![info exists ::atos_analysis_tools::corr_duree_e4           ]} {set ::atos_analysis_tools::corr_duree_e4            ""}
      if {![info exists ::atos_analysis_tools::nb_p4                   ]} {set ::atos_analysis_tools::nb_p4                    ""}
      if {![info exists ::atos_analysis_tools::id_p5                   ]} {set ::atos_analysis_tools::id_p5                    ""}
      if {![info exists ::atos_analysis_tools::corr_duree_e5           ]} {set ::atos_analysis_tools::corr_duree_e5            ""}
      if {![info exists ::atos_analysis_tools::nb_p5                   ]} {set ::atos_analysis_tools::nb_p5                    ""}
      if {![info exists ::atos_analysis_gui::duree_max_immersion_evnmt ]} {set ::atos_analysis_gui::duree_max_immersion_evnmt  ""}
      if {![info exists ::atos_analysis_tools::id_p6                   ]} {set ::atos_analysis_tools::id_p6                    ""}
      if {![info exists ::atos_analysis_gui::date_immersion            ]} {set ::atos_analysis_gui::date_immersion             ""}
      if {![info exists ::atos_analysis_gui::duree_max_emersion_evnmt  ]} {set ::atos_analysis_gui::duree_max_emersion_evnmt   ""}
      if {![info exists ::atos_analysis_tools::id_p7                   ]} {set ::atos_analysis_tools::id_p7                    ""}
      if {![info exists ::atos_analysis_gui::date_emersion             ]} {set ::atos_analysis_gui::date_emersion              ""}
      if {![info exists ::atos_analysis_gui::width                     ]} {set ::atos_analysis_gui::width                      ""}
      if {![info exists ::atos_analysis_gui::occ_star_name             ]} {set ::atos_analysis_gui::occ_star_name              ""}
      if {![info exists ::atos_analysis_gui::occ_star_class            ]} {set ::atos_analysis_gui::occ_star_class             1}
      if {![info exists ::atos_analysis_gui::occ_star_B                ]} {set ::atos_analysis_gui::occ_star_B                 ""}
      if {![info exists ::atos_analysis_gui::occ_star_V                ]} {set ::atos_analysis_gui::occ_star_V                 ""}
      if {![info exists ::atos_analysis_gui::occ_star_K                ]} {set ::atos_analysis_gui::occ_star_K                 ""}
      if {![info exists ::atos_analysis_gui::occ_star_size_mas         ]} {set ::atos_analysis_gui::occ_star_size_mas          ""}
      if {![info exists ::atos_analysis_gui::occ_star_size_km          ]} {set ::atos_analysis_gui::occ_star_size_km           ""}
      if {![info exists ::atos_analysis_gui::occ_star_extinction       ]} {set ::atos_analysis_gui::occ_star_extinction        ""}
      if {![info exists ::atos_analysis_gui::wvlngth                   ]} {set ::atos_analysis_gui::wvlngth                    ""}
      if {![info exists ::atos_analysis_gui::dlambda                   ]} {set ::atos_analysis_gui::dlambda                    ""}
      if {![info exists ::atos_analysis_tools::irep                    ]} {set ::atos_analysis_tools::irep                     ""}
      if {![info exists ::atos_analysis_gui::nheure                    ]} {set ::atos_analysis_gui::nheure                     ""}
      if {![info exists ::atos_analysis_gui::pas_heure                 ]} {set ::atos_analysis_gui::pas_heure                  ""}
      if {![info exists ::atos_analysis_tools::corr_exposure           ]} {set ::atos_analysis_tools::corr_exposure            ""}
      if {![info exists ::atos_analysis_gui::date_begin_obs            ]} {set ::atos_analysis_gui::date_begin_obs             ""}
      if {![info exists ::atos_analysis_gui::date_end_obs              ]} {set ::atos_analysis_gui::date_end_obs               ""}
      if {![info exists ::atos_analysis_gui::date_immersion_sol        ]} {set ::atos_analysis_gui::date_immersion_sol         ""}
      if {![info exists ::atos_analysis_gui::im_chi2_min               ]} {set ::atos_analysis_gui::im_chi2_min                ""}
      if {![info exists ::atos_analysis_gui::im_nfit_chi2_min          ]} {set ::atos_analysis_gui::im_nfit_chi2_min           ""}
      if {![info exists ::atos_analysis_gui::im_t0_chi2_min            ]} {set ::atos_analysis_gui::im_t0_chi2_min             ""}
      if {![info exists ::atos_analysis_gui::im_t_inf                  ]} {set ::atos_analysis_gui::im_t_inf                   ""}
      if {![info exists ::atos_analysis_gui::im_t_sup                  ]} {set ::atos_analysis_gui::im_t_sup                   ""}
      if {![info exists ::atos_analysis_gui::im_t_diff                 ]} {set ::atos_analysis_gui::im_t_diff                  ""}
      if {![info exists ::atos_analysis_gui::im_t_inf_2s               ]} {set ::atos_analysis_gui::im_t_inf_2s                ""}
      if {![info exists ::atos_analysis_gui::im_t_sup_2s               ]} {set ::atos_analysis_gui::im_t_sup_2s                ""}
      if {![info exists ::atos_analysis_gui::im_t_diff_2s              ]} {set ::atos_analysis_gui::im_t_diff_2s               ""}
      if {![info exists ::atos_analysis_gui::im_t_inf_3s               ]} {set ::atos_analysis_gui::im_t_inf_3s                ""}
      if {![info exists ::atos_analysis_gui::im_t_sup_3s               ]} {set ::atos_analysis_gui::im_t_sup_3s                ""}
      if {![info exists ::atos_analysis_gui::im_t_diff_3s              ]} {set ::atos_analysis_gui::im_t_diff_3s               ""}
      if {![info exists ::atos_analysis_gui::date_emersion_sol         ]} {set ::atos_analysis_gui::date_emersion_sol          ""}
      if {![info exists ::atos_analysis_gui::em_chi2_min               ]} {set ::atos_analysis_gui::em_chi2_min                ""}
      if {![info exists ::atos_analysis_gui::em_nfit_chi2_min          ]} {set ::atos_analysis_gui::em_nfit_chi2_min           ""}
      if {![info exists ::atos_analysis_gui::em_t0_chi2_min            ]} {set ::atos_analysis_gui::em_t0_chi2_min             ""}
      if {![info exists ::atos_analysis_gui::em_t_inf                  ]} {set ::atos_analysis_gui::em_t_inf                   ""}
      if {![info exists ::atos_analysis_gui::em_t_sup                  ]} {set ::atos_analysis_gui::em_t_sup                   ""}
      if {![info exists ::atos_analysis_gui::em_t_diff                 ]} {set ::atos_analysis_gui::em_t_diff                  ""}
      if {![info exists ::atos_analysis_gui::em_t_inf_2s               ]} {set ::atos_analysis_gui::em_t_inf_2s                ""}
      if {![info exists ::atos_analysis_gui::em_t_sup_2s               ]} {set ::atos_analysis_gui::em_t_sup_2s                ""}
      if {![info exists ::atos_analysis_gui::em_t_diff_2s              ]} {set ::atos_analysis_gui::em_t_diff_2s               ""}
      if {![info exists ::atos_analysis_gui::em_t_inf_3s               ]} {set ::atos_analysis_gui::em_t_inf_3s                ""}
      if {![info exists ::atos_analysis_gui::em_t_sup_3s               ]} {set ::atos_analysis_gui::em_t_sup_3s                ""}
      if {![info exists ::atos_analysis_gui::em_t_diff_3s              ]} {set ::atos_analysis_gui::em_t_diff_3s               ""}
      if {![info exists ::atos_analysis_gui::bande                     ]} {set ::atos_analysis_gui::bande                      ""}
      if {![info exists ::atos_analysis_gui::duree                     ]} {set ::atos_analysis_gui::duree                      ""}
      if {![info exists ::atos_analysis_gui::result                    ]} {set ::atos_analysis_gui::result                     ""}
      if {![info exists ::atos_analysis_gui::occ_observers             ]} {set ::atos_analysis_gui::occ_observers              ""}
      if {![info exists ::atos_analysis_gui::prj_reduc                 ]} {set ::atos_analysis_gui::prj_reduc                  ""}
      if {![info exists ::atos_analysis_gui::prj_mail                  ]} {set ::atos_analysis_gui::prj_mail                   ""}
      if {![info exists ::atos_analysis_gui::prj_phone                 ]} {set ::atos_analysis_gui::prj_phone                  ""}
      if {![info exists ::atos_analysis_gui::prj_address               ]} {set ::atos_analysis_gui::prj_address                ""}
      if {![info exists ::atos_analysis_gui::type1_station             ]} {set ::atos_analysis_gui::type1_station              ""}
      if {![info exists ::atos_analysis_gui::latitude                  ]} {set ::atos_analysis_gui::latitude                   ""}
      if {![info exists ::atos_analysis_gui::longitude                 ]} {set ::atos_analysis_gui::longitude                  ""}
      if {![info exists ::atos_analysis_gui::altitude                  ]} {set ::atos_analysis_gui::altitude                   ""}
      if {![info exists ::atos_analysis_gui::datum                     ]} {set ::atos_analysis_gui::datum                      ""}
      if {![info exists ::atos_analysis_gui::nearest_city              ]} {set ::atos_analysis_gui::nearest_city               ""}
      if {![info exists ::atos_analysis_gui::type2_station             ]} {set ::atos_analysis_gui::type2_station              ""}
      if {![info exists ::atos_analysis_gui::telescop_type             ]} {set ::atos_analysis_gui::telescop_type              ""}
      if {![info exists ::atos_analysis_gui::telescop_aper             ]} {set ::atos_analysis_gui::telescop_aper              ""}
      if {![info exists ::atos_analysis_gui::telescop_magn             ]} {set ::atos_analysis_gui::telescop_magn              ""}
      if {![info exists ::atos_analysis_gui::telescop_moun             ]} {set ::atos_analysis_gui::telescop_moun              ""}
      if {![info exists ::atos_analysis_gui::telescop_moto             ]} {set ::atos_analysis_gui::telescop_moto              ""}
      if {![info exists ::atos_analysis_gui::record_evin               ]} {set ::atos_analysis_gui::record_evin                ""}
      if {![info exists ::atos_analysis_gui::record_time               ]} {set ::atos_analysis_gui::record_time                ""}
      if {![info exists ::atos_analysis_gui::record_sens               ]} {set ::atos_analysis_gui::record_sens                ""}
      if {![info exists ::atos_analysis_gui::record_prod               ]} {set ::atos_analysis_gui::record_prod                ""}
      if {![info exists ::atos_analysis_gui::record_tiin               ]} {set ::atos_analysis_gui::record_tiin                ""}
      if {![info exists ::atos_analysis_gui::record_comp               ]} {set ::atos_analysis_gui::record_comp                ""}
      if {![info exists ::atos_analysis_gui::obscond_tran              ]} {set ::atos_analysis_gui::obscond_tran               ""}
      if {![info exists ::atos_analysis_gui::obscond_wind              ]} {set ::atos_analysis_gui::obscond_wind               ""}
      if {![info exists ::atos_analysis_gui::obscond_temp              ]} {set ::atos_analysis_gui::obscond_temp               ""}
      if {![info exists ::atos_analysis_gui::obscond_stab              ]} {set ::atos_analysis_gui::obscond_stab               ""}
      if {![info exists ::atos_analysis_gui::obscond_visi              ]} {set ::atos_analysis_gui::obscond_visi               ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}
      if {![info exists ::atos_analysis_gui::occ_obj                   ]} {set ::atos_analysis_gui::occ_obj                    ""}

catch {
      puts $chan "###############################################################"
      puts $chan "#                                                             #"
      puts $chan "#                       A.T.O.S.                              #"
      puts $chan "#                                                             #"
      puts $chan "#    Acquisition et Traitement des Occultations stellaires    #"
      puts $chan "#                                                             #"
      puts $chan "#         Author : frederic.vachier@imcce.fr (2012-2014)      #"
      puts $chan "#                                                             #"
      puts $chan "###############################################################"

      puts $chan "# "
      puts $chan "# Contexte"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::occ_obj        \"$::atos_analysis_gui::occ_obj\""
      puts $chan "set ::atos_analysis_gui::occ_date       \"$::atos_analysis_gui::occ_date\""
      puts $chan "set ::atos_analysis_gui::occ_pos        \"$::atos_analysis_gui::occ_pos\""
      puts $chan "set ::atos_analysis_gui::occ_pos_type   \"$::atos_analysis_gui::occ_pos_type\""
      puts $chan "set ::atos_analysis_gui::occ_obj_name   \"$::atos_analysis_gui::occ_obj_name\""
      puts $chan "set ::atos_analysis_gui::occ_obj_id     \"$::atos_analysis_gui::occ_obj_id\""
      puts $chan "set ::atos_analysis_gui::occ_tag        \"$::atos_analysis_gui::occ_tag\""

      puts $chan "# "
      puts $chan "# Fichiers & Repertoires"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::prj_file_short \"$::atos_analysis_gui::prj_file_short\""
      puts $chan "set ::atos_analysis_gui::prj_file       \"$::atos_analysis_gui::prj_file\""
      puts $chan "set ::atos_analysis_gui::prj_dir        \"$::atos_analysis_gui::prj_dir\""
      
      puts $chan "# "
      puts $chan "# Ephemerides"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::jd         \"$::atos_analysis_gui::jd\""  
      puts $chan "set ::atos_analysis_gui::rajapp     \"$::atos_analysis_gui::rajapp\""  
      puts $chan "set ::atos_analysis_gui::decapp     \"$::atos_analysis_gui::decapp\""
      puts $chan "set ::atos_analysis_gui::dist       \"$::atos_analysis_gui::dist\""
      puts $chan "set ::atos_analysis_gui::magv       \"$::atos_analysis_gui::magv\""
      puts $chan "set ::atos_analysis_gui::phase      \"$::atos_analysis_gui::phase\""
      puts $chan "set ::atos_analysis_gui::elong      \"$::atos_analysis_gui::elong\""
      puts $chan "set ::atos_analysis_gui::dracosd    \"$::atos_analysis_gui::dracosd\""
      puts $chan "set ::atos_analysis_gui::ddec       \"$::atos_analysis_gui::ddec\""
      puts $chan "set ::atos_analysis_gui::vn         \"$::atos_analysis_gui::vn\""
      puts $chan "set ::atos_analysis_gui::tsl        \"$::atos_analysis_gui::tsl\""
      puts $chan "set ::atos_analysis_gui::raj2000    \"$::atos_analysis_gui::raj2000\""
      puts $chan "set ::atos_analysis_gui::decj2000   \"$::atos_analysis_gui::decj2000\""
      puts $chan "set ::atos_analysis_gui::hourangle  \"$::atos_analysis_gui::hourangle\""
      puts $chan "set ::atos_analysis_gui::decapp     \"$::atos_analysis_gui::decapp\""
      puts $chan "set ::atos_analysis_gui::azimuth    \"$::atos_analysis_gui::azimuth\""
      puts $chan "set ::atos_analysis_gui::hauteur    \"$::atos_analysis_gui::hauteur\""
      puts $chan "set ::atos_analysis_gui::airmass    \"$::atos_analysis_gui::airmass\""
      puts $chan "set ::atos_analysis_gui::dhelio     \"$::atos_analysis_gui::dhelio\""

      puts $chan "# "
      puts $chan "# Corrections courbe"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::raw_filename_short \"$::atos_analysis_gui::raw_filename_short\""
      puts $chan "set ::atos_analysis_gui::raw_filename       \"$::atos_analysis_gui::raw_filename\""
      puts $chan "set ::atos_analysis_gui::raw_integ_offset   \"$::atos_analysis_gui::raw_integ_offset\""
      puts $chan "set ::atos_analysis_gui::raw_integ_nb_img   \"$::atos_analysis_gui::raw_integ_nb_img\""
      puts $chan "set ::atos_analysis_gui::int_corr           \"$::atos_analysis_gui::int_corr\""
      puts $chan "set ::atos_analysis_gui::tps_corr           \"$::atos_analysis_gui::tps_corr\""
      puts $chan "set ::atos_analysis_gui::theo_expo          \"$::atos_analysis_gui::theo_expo\""
      puts $chan "set ::atos_analysis_gui::time_offset        \"$::atos_analysis_gui::time_offset\""
      puts $chan "set ::atos_analysis_gui::ref_corr           \"$::atos_analysis_gui::ref_corr\""

      puts $chan "# "
      puts $chan "# Evenements"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::corr_filename_short        \"$::atos_analysis_gui::corr_filename_short\""
      puts $chan "set ::atos_analysis_gui::corr_filename              \"$::atos_analysis_gui::corr_filename\""
      puts $chan "set ::atos_analysis_tools::id_p1                    \"$::atos_analysis_tools::id_p1\""
      puts $chan "set ::atos_analysis_tools::corr_duree_e1            \"$::atos_analysis_tools::corr_duree_e1\""
      puts $chan "set ::atos_analysis_tools::nb_p1                    \"$::atos_analysis_tools::nb_p1\""
      puts $chan "set ::atos_analysis_gui::duree_max_immersion_search \"$::atos_analysis_gui::duree_max_immersion_search\""
      puts $chan "set ::atos_analysis_tools::id_p2                    \"$::atos_analysis_tools::id_p2\""
      puts $chan "set ::atos_analysis_tools::corr_duree_e2            \"$::atos_analysis_tools::corr_duree_e2\""
      puts $chan "set ::atos_analysis_tools::nb_p2                    \"$::atos_analysis_tools::nb_p2\""
      puts $chan "set ::atos_analysis_tools::id_p3                    \"$::atos_analysis_tools::id_p3\""
      puts $chan "set ::atos_analysis_tools::corr_duree_e3            \"$::atos_analysis_tools::corr_duree_e3\""
      puts $chan "set ::atos_analysis_tools::nb_p3                    \"$::atos_analysis_tools::nb_p3\""
      puts $chan "set ::atos_analysis_gui::duree_max_emersion_search  \"$::atos_analysis_gui::duree_max_emersion_search\""
      puts $chan "set ::atos_analysis_tools::id_p4                    \"$::atos_analysis_tools::id_p4\""
      puts $chan "set ::atos_analysis_tools::corr_duree_e4            \"$::atos_analysis_tools::corr_duree_e4\""
      puts $chan "set ::atos_analysis_tools::nb_p4                    \"$::atos_analysis_tools::nb_p4\""
      puts $chan "set ::atos_analysis_tools::id_p5                    \"$::atos_analysis_tools::id_p5\""
      puts $chan "set ::atos_analysis_tools::corr_duree_e5            \"$::atos_analysis_tools::corr_duree_e5\""
      puts $chan "set ::atos_analysis_tools::nb_p5                    \"$::atos_analysis_tools::nb_p5\""
      puts $chan "set ::atos_analysis_gui::duree_max_immersion_evnmt  \"$::atos_analysis_gui::duree_max_immersion_evnmt\""
      puts $chan "set ::atos_analysis_tools::id_p6                    \"$::atos_analysis_tools::id_p6\""
      puts $chan "set ::atos_analysis_gui::date_immersion             \"$::atos_analysis_gui::date_immersion\""
      puts $chan "set ::atos_analysis_gui::duree_max_emersion_evnmt   \"$::atos_analysis_gui::duree_max_emersion_evnmt\""
      puts $chan "set ::atos_analysis_tools::id_p7                    \"$::atos_analysis_tools::id_p7\""       
      puts $chan "set ::atos_analysis_gui::date_emersion              \"$::atos_analysis_gui::date_emersion\"" 

      puts $chan "# "
      puts $chan "# Parametres"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::width               \"$::atos_analysis_gui::width\""
      puts $chan "set ::atos_analysis_gui::occ_star_name       \"$::atos_analysis_gui::occ_star_name\""
      puts $chan "set ::atos_analysis_gui::occ_star_class      \"$::atos_analysis_gui::occ_star_class\""
      puts $chan "set ::atos_analysis_gui::occ_star_B          \"$::atos_analysis_gui::occ_star_B\""
      puts $chan "set ::atos_analysis_gui::occ_star_V          \"$::atos_analysis_gui::occ_star_V\""
      puts $chan "set ::atos_analysis_gui::occ_star_K          \"$::atos_analysis_gui::occ_star_K\""
      puts $chan "set ::atos_analysis_gui::occ_star_size_mas   \"$::atos_analysis_gui::occ_star_size_mas\""
      puts $chan "set ::atos_analysis_gui::occ_star_size_km    \"$::atos_analysis_gui::occ_star_size_km\""
      puts $chan "set ::atos_analysis_gui::occ_star_extinction \"$::atos_analysis_gui::occ_star_extinction\""
      puts $chan "set ::atos_analysis_gui::wvlngth             \"$::atos_analysis_gui::wvlngth\""
      puts $chan "set ::atos_analysis_gui::dlambda             \"$::atos_analysis_gui::dlambda\""
      puts $chan "set ::atos_analysis_tools::irep              \"$::atos_analysis_tools::irep\""
      puts $chan "set ::atos_analysis_gui::nheure              \"$::atos_analysis_gui::nheure\""
      puts $chan "set ::atos_analysis_gui::pas_heure           \"$::atos_analysis_gui::pas_heure\""
      puts $chan "set ::atos_analysis_tools::corr_exposure     \"$::atos_analysis_tools::corr_exposure\""
      puts $chan "set ::atos_analysis_gui::date_begin_obs      \"$::atos_analysis_gui::date_begin_obs\""
      puts $chan "set ::atos_analysis_gui::date_end_obs        \"$::atos_analysis_gui::date_end_obs\""

      puts $chan "# "
      puts $chan "# Immersion & Emersion"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::date_immersion_sol \"$::atos_analysis_gui::date_immersion_sol\""
      puts $chan "set ::atos_analysis_gui::im_chi2_min        \"$::atos_analysis_gui::im_chi2_min\""
      puts $chan "set ::atos_analysis_gui::im_nfit_chi2_min   \"$::atos_analysis_gui::im_nfit_chi2_min\""
      puts $chan "set ::atos_analysis_gui::im_t0_chi2_min     \"$::atos_analysis_gui::im_t0_chi2_min\""
      puts $chan "set ::atos_analysis_gui::im_t_inf           \"$::atos_analysis_gui::im_t_inf\""
      puts $chan "set ::atos_analysis_gui::im_t_sup           \"$::atos_analysis_gui::im_t_sup\""
      puts $chan "set ::atos_analysis_gui::im_t_diff          \"$::atos_analysis_gui::im_t_diff\""
      puts $chan "set ::atos_analysis_gui::im_t_inf_2s        \"$::atos_analysis_gui::im_t_inf_2s\""
      puts $chan "set ::atos_analysis_gui::im_t_sup_2s        \"$::atos_analysis_gui::im_t_sup_2s\""
      puts $chan "set ::atos_analysis_gui::im_t_diff_2s       \"$::atos_analysis_gui::im_t_diff_2s\""
      puts $chan "set ::atos_analysis_gui::im_t_inf_3s        \"$::atos_analysis_gui::im_t_inf_3s\""
      puts $chan "set ::atos_analysis_gui::im_t_sup_3s        \"$::atos_analysis_gui::im_t_sup_3s\""
      puts $chan "set ::atos_analysis_gui::im_t_diff_3s       \"$::atos_analysis_gui::im_t_diff_3s\""
      puts $chan "set ::atos_analysis_gui::date_emersion_sol  \"$::atos_analysis_gui::date_emersion_sol\""
      puts $chan "set ::atos_analysis_gui::em_chi2_min        \"$::atos_analysis_gui::em_chi2_min\""
      puts $chan "set ::atos_analysis_gui::em_nfit_chi2_min   \"$::atos_analysis_gui::em_nfit_chi2_min\""
      puts $chan "set ::atos_analysis_gui::em_t0_chi2_min     \"$::atos_analysis_gui::em_t0_chi2_min\""
      puts $chan "set ::atos_analysis_gui::em_t_inf           \"$::atos_analysis_gui::em_t_inf\""
      puts $chan "set ::atos_analysis_gui::em_t_sup           \"$::atos_analysis_gui::em_t_sup\""
      puts $chan "set ::atos_analysis_gui::em_t_diff          \"$::atos_analysis_gui::em_t_diff\""
      puts $chan "set ::atos_analysis_gui::em_t_inf_2s        \"$::atos_analysis_gui::em_t_inf_2s\""
      puts $chan "set ::atos_analysis_gui::em_t_sup_2s        \"$::atos_analysis_gui::em_t_sup_2s\""
      puts $chan "set ::atos_analysis_gui::em_t_diff_2s       \"$::atos_analysis_gui::em_t_diff_2s\""
      puts $chan "set ::atos_analysis_gui::em_t_inf_3s        \"$::atos_analysis_gui::em_t_inf_3s\""
      puts $chan "set ::atos_analysis_gui::em_t_sup_3s        \"$::atos_analysis_gui::em_t_sup_3s\""
      puts $chan "set ::atos_analysis_gui::em_t_diff_3s       \"$::atos_analysis_gui::em_t_diff_3s\""

      puts $chan "set ::atos_analysis_gui::bande       \"$::atos_analysis_gui::bande\""
      puts $chan "set ::atos_analysis_gui::duree       \"$::atos_analysis_gui::duree\""
      puts $chan "set ::atos_analysis_gui::result      \"$::atos_analysis_gui::result\""

      puts $chan "# "
      puts $chan "# Contacts"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::occ_observers  \"$::atos_analysis_gui::occ_observers\""
      puts $chan "set ::atos_analysis_gui::prj_reduc      \"$::atos_analysis_gui::prj_reduc\""
      puts $chan "set ::atos_analysis_gui::prj_mail       \"$::atos_analysis_gui::prj_mail\""
      puts $chan "set ::atos_analysis_gui::prj_phone      \"$::atos_analysis_gui::prj_phone\""
      puts $chan "set ::atos_analysis_gui::prj_address    \"$::atos_analysis_gui::prj_address\""

      puts $chan "# "
      puts $chan "# Station"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::type1_station  \"$::atos_analysis_gui::type1_station\""
      puts $chan "set ::atos_analysis_gui::latitude       \"$::atos_analysis_gui::latitude\""
      puts $chan "set ::atos_analysis_gui::longitude      \"$::atos_analysis_gui::longitude\""
      puts $chan "set ::atos_analysis_gui::altitude       \"$::atos_analysis_gui::altitude\""
      puts $chan "set ::atos_analysis_gui::datum          \"$::atos_analysis_gui::datum\""
      puts $chan "set ::atos_analysis_gui::nearest_city   \"$::atos_analysis_gui::nearest_city\""
      puts $chan "set ::atos_analysis_gui::type2_station  \"$::atos_analysis_gui::type2_station\""

      puts $chan "# "
      puts $chan "# Telescope"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::telescop_type  \"$::atos_analysis_gui::telescop_type\""
      puts $chan "set ::atos_analysis_gui::telescop_aper  \"$::atos_analysis_gui::telescop_aper\""
      puts $chan "set ::atos_analysis_gui::telescop_magn  \"$::atos_analysis_gui::telescop_magn\""
      puts $chan "set ::atos_analysis_gui::telescop_moun  \"$::atos_analysis_gui::telescop_moun\""
      puts $chan "set ::atos_analysis_gui::telescop_moto  \"$::atos_analysis_gui::telescop_moto\""

      puts $chan "# "
      puts $chan "# Acquisition"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::record_evin    \"$::atos_analysis_gui::record_evin\""
      puts $chan "set ::atos_analysis_gui::record_time    \"$::atos_analysis_gui::record_time\""
      puts $chan "set ::atos_analysis_gui::record_sens    \"$::atos_analysis_gui::record_sens\""
      puts $chan "set ::atos_analysis_gui::record_prod    \"$::atos_analysis_gui::record_prod\""
      puts $chan "set ::atos_analysis_gui::record_tiin    \"$::atos_analysis_gui::record_tiin\""
      puts $chan "set ::atos_analysis_gui::record_comp    \"$::atos_analysis_gui::record_comp\""

      puts $chan "# "
      puts $chan "# Conditions"
      puts $chan "# "
      puts $chan "set ::atos_analysis_gui::obscond_tran   \"$::atos_analysis_gui::obscond_tran\""
      puts $chan "set ::atos_analysis_gui::obscond_wind   \"$::atos_analysis_gui::obscond_wind\""
      puts $chan "set ::atos_analysis_gui::obscond_temp   \"$::atos_analysis_gui::obscond_temp\""
      puts $chan "set ::atos_analysis_gui::obscond_stab   \"$::atos_analysis_gui::obscond_stab\""
      puts $chan "set ::atos_analysis_gui::obscond_visi   \"$::atos_analysis_gui::obscond_visi\""

      puts $chan "# "
      puts $chan "# Comments"
      puts $chan "# "
      #puts $chan "set ::atos_analysis_gui::comments   \"$::atos_analysis_gui::comments\""
      #puts $chan "$::atos_analysis_gui::gui_comment.v insert 0 end \"$::atos_analysis_gui::comments\""
      set a [split [$::atos_analysis_gui::gui_comment.v get 1.0 end] "\n" ]
      set newl "$::atos_analysis_gui::gui_comment.v insert end \""
      foreach line $a {
         gren_info "$line\n"
         if {[string bytelength [string trim $line]]==0} {continue}
         append newl "[string trim $line]\\n"
      }
      puts $chan "$::atos_analysis_gui::gui_comment.v delete 1.0 end "
      puts $chan "$newl\""

}
      
      close $chan
      
      return -code 0 "ok"
   }   

















   #
   # Sauvegarde du fichier projet
   #
   proc ::atos_analysis_gui::save_planoccult { } {

      set file [file join $::atos_analysis_gui::prj_dir "$::atos_analysis_gui::prj_file_short.PLANOCCULT"]
      if {[file exists $file]} {
         set res [tk_messageBox -message "Le Rapport PLANOCCULT existe. Voulez vous l'écraser ?" -type yesno]
         if {$res == "no"} {return -code 0 "no"}
      }

      # Parametres dans tous les cas
      set reaction_time ""

      # Constantes 
      set ::atos_analysis_gui::type2_station "Single"
      set ::atos_analysis_gui::record_evin ""

      # A Calculer  
      set obscond_alti [format "%+d deg" [lindex [split $::atos_analysis_gui::hauteur ":"] 0] ]
      set occ_date_short [lindex [split $::atos_analysis_tools::raw_date_begin "T"] 0]

      # debut obs
      set datetmp [lindex [split $::atos_analysis_tools::raw_date_begin "T"] 1]
      set datetmp [split $datetmp ":"]
      set hs  [lindex $datetmp 0]
      set ms  [lindex $datetmp 1]
      set ss  [lindex $datetmp 2]

      # immersion
      set hd ""
      set md ""
      set sd ""

      # emersion
      set hr ""
      set mr ""
      set sr ""

      # fin obs
      set datetmp [lindex [split $::atos_analysis_tools::raw_date_end "T"] 1]
      set datetmp [split $datetmp ":"]
      set he  [lindex $datetmp 0]
      set me  [lindex $datetmp 1]
      set se  [lindex $datetmp 2]


      # incertitude imm et em
      set ad ""
      set ar ""
      # duree integration
      set int ""
      # mid evenement
      set midevent ""
      # Commentaires
      set comments "8 frame integration used (Watec setting 4 Slow) Codec use for grab : No recompression YUY2"
      set comments [$::atos_analysis_gui::gui_comment.v get 1.0 end]

      # Parametres dans le cas POSITIF
      if {$::atos_analysis_gui::result == "POSITIVE"} {

         # Was your reaction time applied to the above timings ?
         if {$::atos_analysis_gui::tps_corr} {
            set reaction_time "YES"
         } else {
            set reaction_time "NO"
         }

         set occ_date_short [lindex [split $::atos_analysis_gui::date_immersion_sol "T"] 0]

         # immersion
         set datetmp [lindex [split $::atos_analysis_gui::date_immersion_sol "T"] 1]
         set datetmp [split $datetmp ":"]
         set hd  [lindex $datetmp 0]
         set md  [lindex $datetmp 1]
         set sd  [lindex $datetmp 2]
         
          #if {[string index $hd 0]==0} { set hd [string index $hd 1] } 
          #if {[string index $md 0]==0} { set md [string index $md 1] } 
   
         # emersion
         set datetmp [lindex [split $::atos_analysis_gui::date_emersion_sol "T"] 1]
         set datetmp [split $datetmp ":"]
         set hr  [lindex $datetmp 0]
         set mr  [lindex $datetmp 1]
         set sr  [lindex $datetmp 2]

          #if {[string index $hr 0]==0} { set hr [string index $hr 1] } 
          #if {[string index $mr 0]==0} { set mr [string index $mr 1] } 

         # incertitude imm et em
         set ad  $::atos_analysis_gui::im_t_diff_2s
         set ar  $::atos_analysis_gui::em_t_diff_2s
         # duree integration
         set int $::atos_analysis_tools::corr_exposure
         # mid evenement
         set midevent [mc_date2iso8601 [expr ([mc_date2jd $::atos_analysis_gui::date_emersion_sol]+[mc_date2jd $::atos_analysis_gui::date_immersion_sol])/2.0] ]


      ::console::affiche_resultat  "Event : $he $me $se \n"
      ::console::affiche_resultat  "D : $hd $md $sd \n"
      ::console::affiche_resultat  "R : $hr $mr $sr \n"

      }

# Ecriture du rapport

      set chan [open $file w]
      ::console::affiche_resultat  "Enregistrement du fichier = [file tail $file] \n"
      

      puts $chan "                   ASTEROIDAL OCCULTATION - REPORT FORM               "
      puts $chan "                                                                      "
      puts $chan "    +------------------------------+  +------------------------------+"
      puts $chan "    |            EAON              |  |            IOTA/ES           |"
      puts $chan "    |                              |  |   INTERNATIONAL OCCULTATION  |"
      puts $chan "    |     EUROPEAN  ASTEROIDAL     |  |      TIMING  ASSOCIATION     |"
      puts $chan "    |     OCCULTATION NETWORK      |  |       EUROPEAN SECTION       |"
      puts $chan "    +------------------------------+  +------------------------------+"
      puts $chan ""

      puts $chan [format "1 DATE: %s                   STAR: %s" $occ_date_short $::atos_analysis_gui::occ_star_name]
      puts $chan [format "  ASTEROID: %-25s  No: %s" $::atos_analysis_gui::occ_obj_name $::atos_analysis_gui::occ_obj_id]
      puts $chan ""
      puts $chan [format "2 OBSERVER: Name: %s"    $::atos_analysis_gui::occ_observers]
      puts $chan [format "            Phone: %s"   $::atos_analysis_gui::prj_phone]
      puts $chan [format "            E-mail: %s"  $::atos_analysis_gui::prj_mail]
      puts $chan [format "            Address: %s" $::atos_analysis_gui::prj_address]
      puts $chan ""
      puts $chan [format "3 OBSERVING STATION: Nearest city: %s" $::atos_analysis_gui::nearest_city]
      puts $chan [format "  Station:  %s"                        $::atos_analysis_gui::type1_station]
      puts $chan [format "  Latitude:  %s"                       $::atos_analysis_gui::latitude]
      puts $chan [format "  Longitude: %s"                       $::atos_analysis_gui::longitude]
      puts $chan [format "  Altitude: %s"                        $::atos_analysis_gui::altitude]
      puts $chan [format "  Datum (WGS84 preferred): %s"         $::atos_analysis_gui::datum]
      puts $chan ""
      puts $chan [format "  Single, OR Double or Multiple station (Specify observer's name): %s" $::atos_analysis_gui::type2_station]
      puts $chan ""
      puts $chan "                         +----------------------------------+"
      puts $chan "4 TIMING OF EVENTS:      |                                  |"
      puts $chan [format "                         |  OCCULTATION RECORDED: %8s  |"  $::atos_analysis_gui::result]
      puts $chan "                         |                                  |"
      puts $chan "                         +----------------------------------+"
      puts $chan "  Type of event"
      puts $chan "  Start observation   Interrupt-start   Disappearance   Blink   Flash"
      puts $chan "  End observation     Interrupt-end     Reappearance    Other (specify)"
      puts $chan ""
      puts $chan "                                                  Comments"
      puts $chan "  Event   Time (UT)    P.E.   Acc."
      puts $chan "  Code   HH MM SS.ss   S.ss   S.ss"
      puts $chan ""
      
      if {$hs==""||$ms==""||$ss==""} {
         puts $chan [format "    S  - %2s %2s %s    -      -         :" "HH" "MM" "SS.SS"]
      } else {
         puts $chan [format "    S  - %2s %2s %s   -      -         :" $hs $ms $ss]
      }

      if {$::atos_analysis_gui::result == "POSITIVE"} {
         puts $chan "       -                -      -         :"
         if {$hd == "" || $md == "" || $sd == "" || $ad == "" || $int == ""} {
            puts $chan [format "    D  - %2s %2s %s    -     %s      :  Video integration %s s" "HH" "MM" "SS.SS" "SS.SS" "SS.SS"]
         } else {
            puts $chan [format "    D  - %2s %2s %s   -     %.3f      :  Video integration %.3f s" $hd $md $sd $ad $int]
         }
         if {$hr == "" || $mr == "" || $sr == "" || $ar == "" || $int == ""} {
            puts $chan [format "    R  - %2s %2s %s    -     %s      :  Video integration %s s" "HH" "MM" "SS.SS" "SS.SS" "SS.SS"]
         } else {
            puts $chan [format "    R  - %2s %2s %s   -     %.3f      :  Video integration %.3f s" $hr $mr $sr $ar $int]
         }
         puts $chan "       -                -      -         :"
      } else {
         puts $chan "    D  - "
         puts $chan "    R  - "
      }

      if {$he==""||$me==""||$se==""} {
         puts $chan [format "    E  - %2s %2s %s    -      -         :" "HH" "MM" "SS.SS"]
      } else {
         
         puts $chan [format "    E  - %2s %2s %s   -      -         :" $he $me $se]
      }
      
      puts $chan ""
      if {$::atos_analysis_gui::result == "POSITIVE"} {
         if {$::atos_analysis_gui::duree == ""} {
            puts $chan [format "                          Duration : %s s" "SS.SS"]
         } else {
            puts $chan [format "                          Duration : %.3f s" $::atos_analysis_gui::duree]
         }
         puts $chan [format "                         Mid-event : %s UTC" $midevent]
         puts $chan [format "                             Width : %s km" $::atos_analysis_gui::bande]
      } else {
         puts $chan "                          Duration : 0s"
         puts $chan [format "                         Mid-event : %s UTC" $midevent]
         puts $chan [format "                             Width : %s km" $::atos_analysis_gui::bande]
      }

      puts $chan ""
      puts $chan "  Was your reaction time applied to the above timings? $reaction_time"
      puts $chan ""
      puts $chan "5 TELESCOPE:"
      puts $chan "    Type:          $::atos_analysis_gui::telescop_type"
      puts $chan "    Aperture:      $::atos_analysis_gui::telescop_aper"
      puts $chan "    Magnification: $::atos_analysis_gui::telescop_magn"
      puts $chan "    Mount:         $::atos_analysis_gui::telescop_moun"
      puts $chan "    Motor drive:   $::atos_analysis_gui::telescop_moto"
      puts $chan ""
      puts $chan "6 TIMING & RECORDING:"
      puts $chan "    Time source:               $::atos_analysis_gui::record_time"
      puts $chan "    Sensor:                    $::atos_analysis_gui::record_sens"
      puts $chan "    Recording:                 $::atos_analysis_gui::record_prod"
      puts $chan "    Time  insertion (specify): $::atos_analysis_gui::record_tiin"
      puts $chan "    Event insertion (specify): $::atos_analysis_gui::record_evin"
      puts $chan "    Compression:               $::atos_analysis_gui::record_comp"
      puts $chan "    Software Reduction:        Audela/ATOS"
      puts $chan ""
      puts $chan "7 OBSERVING CONDITIONS:"
      puts $chan "    Atmospheric transparency: $::atos_analysis_gui::obscond_tran"
      puts $chan "    Wind:                     $::atos_analysis_gui::obscond_wind"
      puts $chan "    Temperature:              $::atos_analysis_gui::obscond_temp"
      puts $chan "    Star image stability:     $::atos_analysis_gui::obscond_stab"
      puts $chan "    Altitude:                 $obscond_alti"
      puts $chan "    Minor planet visible:     $::atos_analysis_gui::obscond_visi"
      puts $chan ""
      puts $chan "8 ADDITIONAL COMMENTS: "
      set a [split $comments "\n" ]
      foreach line $a {
         puts $chan "     $line"
      }
      
      close $chan
      
      return -code 0 "ok"
   }   





   #
   # Calcul de la taille de l'etoile occultee
   #
   proc ::atos_analysis_gui::calcul_taille_etoile { } {

      set B $::atos_analysis_gui::occ_star_B
      set V $::atos_analysis_gui::occ_star_V
      set K $::atos_analysis_gui::occ_star_K
      set D $::atos_analysis_gui::dist

      set class $::atos_analysis_gui::occ_star_class
      if {$class == ""} { set class 0}

      catch {set res [::atos_analysis_tools::diametre_stellaire $B $V $K $D $class]}

      if {$res != 0} {
         set ::atos_analysis_gui::occ_star_size_mas [format "%.3f" [lindex $res 0]]
         set ::atos_analysis_gui::occ_star_size_km  [format "%.4f" [lindex $res 1]]
         if {$::atos_analysis_gui::vn != 0 && $::atos_analysis_gui::vn != ""} {
            set ::atos_analysis_gui::occ_star_extinction [format "%.4f" [expr [lindex $res 1]/$::atos_analysis_gui::vn]]
         } else {
            set ::atos_analysis_gui::occ_star_extinction ""
            ::console::affiche_erreur "Calcul de la duree d'extinction de l'etoile impossible: vitesse de l'ombre nulle ou inconnue.\n"
         }
         set ::atos_analysis_gui::occ_star_class [lindex $res 2]
      } else {
         set ::atos_analysis_gui::occ_star_size_mas   ""
         set ::atos_analysis_gui::occ_star_size_km    ""
         set ::atos_analysis_gui::occ_star_extinction ""
      }

   }   



   proc ::atos_analysis_gui::good_sexa { d m s prec } {

#gren_info "$d $m $s $prec\n"

      if {[string index $d 0] == "-"} {
         if { [string index $d 1] == "0"} {
            set d "-[string range $d 2 end]"
         }
      } elseif { [string index $d 0] == "+"} {
         if { [string index $d 1] == "0"} {
            set d "[string range $d 2 end]"
         } else {
            set d "[string range $d 1 end]"
         }
      } elseif { [string index $d 0] == "0"} {
            set d [string range $d 1 end]
      }

      if { [string index $m 0] == "0"} {
         set d [string range $m 1 end]
      }

      if { [string index $s 0] == "0"} {
         set d [string range $s 1 end]
      }

#gren_info "transf : $d $m $s $prec\n"

      set d  [expr int($d)]
      set m  [expr int($m)]
      set sa [expr int($s)]
      if {$prec==0} {
         return [format "%02d:%02d:%02d" $d $m $sa]
      }
      set ms [expr int(($s - $sa) * pow(10,$prec))]
      return [format "%02d:%02d:%02d.%0${prec}d" $d $m $sa $ms]
   }   



# ::atos_analysis_gui::set_object_name "# Asteroide     80 Sappho"

   proc ::atos_analysis_gui::set_object_name { line } {

      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      set name ""
      foreach s_el $line {
         gren_info "$cpt $s_el\n"
         if {$cpt==3} {set name $s_el}
         if {$cpt>3} {append name "_$s_el"}
         incr cpt
      }
      regsub -all { }  $name {_} name

      set ::atos_analysis_gui::occ_obj "[lindex $line 2]_$name"
      set ::atos_analysis_gui::occ_obj_name $name
      set ::atos_analysis_gui::occ_obj_type [lindex $line 1]     
      set ::atos_analysis_gui::occ_obj_id   [lindex $line 2]     

      ::console::affiche_resultat  "obj = $::atos_analysis_gui::occ_obj \n"
      ::console::affiche_resultat  "name = $::atos_analysis_gui::occ_obj_name \n"
      ::console::affiche_resultat  "type = $::atos_analysis_gui::occ_obj_type \n"
      ::console::affiche_resultat  "id = $::atos_analysis_gui::occ_obj_id \n"
      ::console::affiche_resultat  "$::atos_analysis_gui::occ_obj_type $::atos_analysis_gui::occ_obj_id $::atos_analysis_gui::occ_obj_name \n"

   }


   #
   # Appel a Miriade pour recuperer quelques informations
   #
   proc ::atos_analysis_gui::miriade { } {


      # Verif
      set pass "yes"
      if {![info exists ::atos_analysis_gui::occ_date]} {
         set pass "no"
      } else {
         if  {$::atos_analysis_gui::occ_date == ""} {
            set pass "no"
         }
      }
      if {![info exists ::atos_analysis_gui::occ_obj_name]} {
         set pass "no"
      } else {
         if  {$::atos_analysis_gui::occ_obj_name == ""} {
            set pass "no"
         }
      }
      if {![info exists ::atos_analysis_gui::occ_pos]} {
         set pass "no"
      } else {
         if  {$::atos_analysis_gui::occ_pos == ""} {
            set pass "no"
         }
      }

      #::console::affiche_resultat "position : $::atos_analysis_gui::occ_pos\n"

      if {$pass=="no"} {
         tk_messageBox -message "Veuillez entrer des valeurs valides pour les champs objet, date et localisation" -type ok
         return
      }

      #
      set jd [mc_date2jd $::atos_analysis_gui::occ_date]
      #set ::atos_analysis_gui::occ_date [mc_date2iso8601 $jd]
      set ::atos_analysis_gui::jd $jd
     
      set cmd1 "vo_miriade_ephemcc \"$::atos_analysis_gui::occ_obj_name\" \"\" $jd 1 \"1d\" \"UTC\" \"$::atos_analysis_gui::occ_pos\" \"INPOP\" 2 1 1 \"text\" \"--jd\" 0"
      #::console::affiche_resultat "CMD MIRIADE 1 = $cmd1\n"

      set cmd5 "vo_miriade_ephemcc \"$::atos_analysis_gui::occ_obj_name\" \"\" $jd 1 \"1d\" \"UTC\" \"$::atos_analysis_gui::occ_pos\" \"INPOP\" 2 5 1 \"text\" \"--jd,--rv\" 0"
      #::console::affiche_resultat "CMD MIRIADE 5 = $cmd5\n"

      set textraw1 [vo_miriade_ephemcc "$::atos_analysis_gui::occ_obj_name" "" $jd 1 "1d" "UTC" "$::atos_analysis_gui::occ_pos" "INPOP" 2 1 1 "text" "--jd" 0]
      set text1 [split $textraw1 ";"]

      set textraw5 [vo_miriade_ephemcc "$::atos_analysis_gui::occ_obj_name" "" $jd 1 "1d" "UTC" "$::atos_analysis_gui::occ_pos" "INPOP" 2 5 1 "text" "--jd" 0]
      set text5 [split $textraw5 ";"]
      
      set nbl [llength $text1]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel au serveur d'ephemerides Miriade a echouer.\nVerifier le nom de l'objet.\nLa commande est affichee dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         return      
      }
      set nbl [llength $text5]
      if {$nbl == 1} {
         set res [tk_messageBox -message "L'appel au serveur d'ephemerides Miriade a echouer.\nVerifier le nom de l'objet.\nLa commande est affichee dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd5\n"
         return      
      }

      # Sauvegarde des fichiers intermediaires
      set file [file join $::atos_analysis_gui::prj_dir "miriade.1"]
      set chan [open $file w]
      foreach line $text1 {
         puts $chan $line
      }
      close $chan

      set file [file join $::atos_analysis_gui::prj_dir "miriade.5"]
      set chan [open $file w]
      foreach line $text5 {
         puts $chan $line
      }
      close $chan

      # Analyse les retours de Miriade a la recherche d'une erreur


      # Recupere la position de l'observateur
      foreach t $text1 {
         if { [regexp {.*(\d+) h +(\d+) m +(\d.+) s (.+?).* (\d+) d +(\d+) ' +(\d.+) " +(.+?).* ([-+]?\d*\.?\d*) m.*} $t str loh lom los lowe lad lam las lans alt] } {

            #gren_info "Longitude = $lowe $loh $lom $los\n"
            set lont [expr 15.0*($loh + $lom/60.0 + $los/3600.0)]

            if {$lowe=="E" || $lowe=="e"} {
               set ::atos_analysis_gui::longitude_deg $lont
            } else {
               set ::atos_analysis_gui::longitude_deg [expr -$lont]
            }

            set lont [mc_angle2dms $lont]
            set lod [lindex $lont 0]
            set lom [lindex $lont 1]
            set los [lindex $lont 2]
            set ::atos_analysis_gui::longitude [format " %02dd %02dm %02.2fs (%s) " $lod $lom $los $lowe]

            #set ::atos_analysis_gui::longitude [format "%s %02dh%02dm%02d.%03ds" $lowe $loh $lom $los $loms ]
            #gren_info "Longitude = $::atos_analysis_gui::longitude\n"

            #gren_info "Latitude = $lans $lad $lam $las\n"
            set latt [expr $lad + $lam/60.0 + $las/3600.0]

            if {$lans=="N" || $lans=="n"} {
               set ::atos_analysis_gui::latitude_deg $latt
            } else {
               set ::atos_analysis_gui::latitude_deg [expr -$latt]
            }

            set latt [mc_angle2dms $latt]
            set lad [lindex $latt 0]
            set lam [lindex $latt 1]
            set las [lindex $latt 2]

            set ::atos_analysis_gui::latitude [format " %02dd %02dm %02.2fs (%s) " $lad $lam $las $lans]

            #set ::atos_analysis_gui::latitude  [format "%s %02dd%02dm%02d.%03ds" $lans $lad $lam $las $lams ]

            set ::atos_analysis_gui::altitude  [format "%.0f m" $alt]
            
            gren_info "Latitude  = $::atos_analysis_gui::latitude\n"
            gren_info "Longitude = $::atos_analysis_gui::longitude\n"
            gren_info "Altitude  = $::atos_analysis_gui::altitude\n"
         }      
      }

      # Maj du nom de l asteroide
      set ::atos_analysis_gui::text1 $text1
      set ast [lindex $text1 1]
      if {$ast != ""} {
         ::atos_analysis_gui::set_object_name $ast
      } else {
         set res [tk_messageBox -message "Le nom de l'objet n'est pas reconnu par Miriade.\nLe resultat de la commande s'affiche dans la console" -type ok]
         ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
         set cpt 0
         foreach line $text1 {
            ::console::affiche_erreur "($cpt)=$line\n"
            incr cpt
         }
         return               
      }

      # Interpretation appel format num 1
      set cpt 0
      foreach line $text1 {
         set char [string index [string trim $line] 0]
         #::console::affiche_resultat "ephemcc 1 ($cpt) ($char)=$line\n"
         if {$char!="#"} { break }
         incr cpt
      }
      #::console::affiche_resultat "cptdata = $cpt\n"
      # on split la la ligne pour retrouver les valeurs
      set line [lindex $text1 $cpt]
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      #foreach s_el $line {
      #   ::console::affiche_resultat  "($cpt) $s_el\n"
      #   incr cpt
      #}
      # on affecte les variables
      set ::atos_analysis_gui::rajapp   [::atos_analysis_gui::good_sexa [lindex $line  2] [lindex $line  3] [lindex $line  4] 2]
      set ::atos_analysis_gui::decapp   [::atos_analysis_gui::good_sexa [lindex $line  5] [lindex $line  6] [lindex $line  7] 2]
      set ::atos_analysis_gui::dist     [format "%.5f" [lindex $line 8]]
      set ::atos_analysis_gui::magv     [lindex $line 9]
      set ::atos_analysis_gui::phase    [lindex $line 10]
      set ::atos_analysis_gui::elong    [lindex $line 11]
      set ::atos_analysis_gui::dracosd  [format "%.5f" [lindex $line 12]]
      set ::atos_analysis_gui::ddec     [format "%.5f" [lindex $line 13]]
      set ang [expr tan((sqrt(pow($::atos_analysis_gui::dracosd,2) + pow($::atos_analysis_gui::ddec,2))/60.0/3600.0)*3.1415926536/180.0)]
      set ::atos_analysis_gui::vn       [format "%.5f" [expr $ang*$::atos_analysis_gui::dist*149597870.0]]

      # Interpretation appel format num 5
      set cpt 0
      foreach line $text5 {
         set char [string index [string trim $line] 0]
         #::console::affiche_resultat "ephemcc 5 ($cpt) ($char)=$line\n"
         if {$char!="#"} { break }
         incr cpt
      }
      #::console::affiche_resultat "cptdata = $cpt\n"
      
      # on split la la ligne pour retrouver les valeurs
      set line [lindex $text5 $cpt]
      regsub -all -- {[[:space:]]+} $line " " line
      set line [split $line]
      set cpt 0
      #foreach s_el $line {
      #   ::console::affiche_resultat  "($cpt) $s_el\n"
      #   incr cpt
      #}
      
      set tsl [mc_angle2hms [expr [lindex $line 2] * 15.] ]
      set ::atos_analysis_gui::tsl       [::atos_analysis_gui::good_sexa [lindex $tsl   0] [lindex $tsl   1] [lindex $tsl   2] 2]
      set ::atos_analysis_gui::raj2000   [::atos_analysis_gui::good_sexa [lindex $line  3] [lindex $line  4] [lindex $line  5] 2]
      set ::atos_analysis_gui::decj2000  [::atos_analysis_gui::good_sexa [lindex $line  6] [lindex $line  7] [lindex $line  8] 2]
      set ::atos_analysis_gui::hourangle [::atos_analysis_gui::good_sexa [lindex $line  9] [lindex $line 10] [lindex $line 11] 2]
      set ::atos_analysis_gui::decapp    [::atos_analysis_gui::good_sexa [lindex $line 12] [lindex $line 13] [lindex $line 14] 2]
      set ::atos_analysis_gui::azimuth   [::atos_analysis_gui::good_sexa [lindex $line 15] [lindex $line 16] [lindex $line 17] 2]
      set ::atos_analysis_gui::hauteur   [::atos_analysis_gui::good_sexa [lindex $line 18] [lindex $line 19] [lindex $line 20] 2]

      set ::atos_analysis_gui::airmass   [lindex $line 21]
      set ::atos_analysis_gui::dhelio    [lindex $line 23]
      
   }   






   proc ::atos_analysis_gui::googlemaps {  } {
      
      global conf
      
      if {(! [info exists ::atos_analysis_gui::latitude_deg]  || ! [info exists ::atos_analysis_gui::longitude_deg]) || 
          ($::atos_analysis_gui::latitude_deg == "" || $::atos_analysis_gui::longitude_deg == "")} {
         tk_messageBox -message "Veuillez valider le projet avec Miriade." -type ok
         return
      } else {
         #::console::affiche_resultat "latitude , Longitude = $::atos_analysis_gui::latitude_deg,$::atos_analysis_gui::longitude_deg \n"
         set url "$::atos_analysis_gui::googleURI$::atos_analysis_gui::latitude_deg,$::atos_analysis_gui::longitude_deg"
      }

      ::console::affiche_resultat "Google map URL: $url\n"
      set answer [ catch { exec $conf(editsite_htm) $url & } ]

   }



   proc ::atos_analysis_gui::sendAladinScript { } {

      # Verif
      set pass "yes"
      if {![info exists ::atos_analysis_gui::raj2000] || $::atos_analysis_gui::raj2000 == ""} {
         set pass "no"
      }
      if {![info exists ::atos_analysis_gui::decj2000] || $::atos_analysis_gui::decj2000 == ""} {
         set pass "no"
      }
      if {![info exists ::atos_analysis_gui::jd] || $::atos_analysis_gui::jd == ""} {
         set pass "no"
      }

      if {$pass == "no"} {
         tk_messageBox -message "Veuillez valider le projet avec Miriade." -type ok
         return
      }

      # Get parameters
      set ra  [expr [mc_angle2deg $::atos_analysis_gui::raj2000] * 15.]
      set dec [mc_angle2deg $::atos_analysis_gui::decj2000]
      set radius 10
      set coord "$ra $dec"
      set radius_arcmin "${radius}arcmin"
      set radius_arcsec [concat [expr $radius * 60.0] "arcsec"]
      set date [mc_date2iso8601 $::atos_analysis_gui::jd]

      if {$::atos_analysis_gui::occ_pos_type == "Code UAI"} {
         set uaicode  "$::atos_analysis_gui::occ_pos"
      } else {
         set uaicode  "500"
      }
      
      # Request Skybot cone-search
      set skybotQuery "get SkyBoT.IMCCE($date,$uaicode,'Asteroids and Planets','$radius_arcsec')"
      # Draw a circle to mark the fov center
      set drawFovCenter "draw phot($ra,$dec,20.00arcsec)"
      # Draw USNO stars as triangles
      set getUSNO   "get VizieR(USNO2);   set USNO2  shape=triangle color=blue"
      set getNOMAD1 "get VizieR(NOMAD1);  set NOMAD1 shape=plus     color=red "

      # Aladin Script
#      set script "get Aladin(DSS2) ${coord} $radius_arcmin; $getUSNO ; $getNOMAD1 ; sync; $skybotQuery;"
      set script "get hips(P/DSS2/color) ${coord} $radius_arcmin; sync; $getUSNO ; $getNOMAD1 ; sync; $skybotQuery;"
      # Broadcast script
      ::SampTools::broadcastAladinScript $script
   
   }


   proc ::atos_analysis_gui::modif_href { type } {
   
      if {$type == "i" } {
         if {$::atos_analysis_gui::date_immersion_sol==""} {return}
         set ::atos_analysis_gui::date_immersion $::atos_analysis_gui::date_immersion_sol
         return
      }
      if {$type == "e" } {
         if {$::atos_analysis_gui::date_emersion_sol==""} {return}
         set ::atos_analysis_gui::date_emersion $::atos_analysis_gui::date_emersion_sol
         return
      }
   
   }


}

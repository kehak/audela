#
# Fichier : astroid.tcl
# Description : Observation en automatique
# Auteur : Frédéric Vachier
# Mise à jour $Id: astroid.tcl 9719 2013-07-09 21:43:12Z robertdelmas $
#
# source audace/plugin/tool/acqt1m/astroid.tcl
#

#============================================================
# Declaration du namespace t1mastroid
#    initialise le namespace
#============================================================
namespace eval ::t1mastroid {

   proc ::t1mastroid::astroid { visuNo } {

      global audace panneau

      cleanmark

      set bufNo    [ ::confVisu::getBufNo $visuNo ]
      set naxis1   [ lindex [ buf$bufNo getkwd NAXIS1 ] 1 ]
      set naxis2   [ lindex [ buf$bufNo getkwd NAXIS2 ] 1 ]
      affich_un_rond_xy [expr int($naxis1/2)] [expr int($naxis2/2)] "yellow" 5 1

      set pass 0
      if {$panneau(acqt1m,$visuNo,ra)!=""} {
         set ra [mc_angle2deg "$panneau(acqt1m,$visuNo,ra) h"]
         incr pass
      }
      if {$panneau(acqt1m,$visuNo,dec)!=""} {
         set dec [mc_angle2deg $panneau(acqt1m,$visuNo,dec)]
         incr pass
      }
      if {$pass != 2} {
         gren_erreur "$::caption(astroid,erreur_entrer_coord)\n"
         return
      }

      gren_info "$::caption(astroid,AD) = $ra   $::caption(astroid,DEC) = $dec \n"

      set erreur [catch {set nbstars [calibwcs $ra $dec * * * USNO $audace(rep_userCatalogUsnoa2) -del_tmp_files 1 -yes_visu 0]} msg]

      file delete -force config.param config.sex default.nnw tt.log

      if {$erreur} {
         if {[info exists nbstars]} {
            if {[string is integer -strict $nbstars]} {
               gren_erreur "$::caption(astroid,erreur_nbstars) = $nbstars ($msg)\n"
            }
         } else {
            gren_erreur "$::caption(astroid,erreur_calibwcs)\n"

         }
         return
      }

      if {$nbstars<3} {
         gren_info "$::caption(astroid,erreur_failure)\n"
         return
      }
      gren_info "$::caption(astroid,erreur_found) $nbstars USNOA2\n"

      set ra       [ lindex [ buf$bufNo getkwd CRVAL1 ] 1 ]
      set dec      [ lindex [ buf$bufNo getkwd CRVAL2 ] 1 ]
      set dateobs  [ lindex [ buf$bufNo getkwd DATE-OBS ] 1 ]
      set iau_code [ lindex [ buf$bufNo getkwd IAU_CODE ] 1 ]

      set ::t1mastroid::naxis1   $naxis1
      set ::t1mastroid::naxis2   $naxis2

      set panneau(acqt1m,$visuNo,ra)  "[mc_angle2hms $ra 360 zero 2]"
      set panneau(acqt1m,$visuNo,dec) "[mc_angle2dms $dec 90 zero 2 ]"

      set lcd ""
      lappend lcd [ lindex [ buf$bufNo getkwd CD1_1 ] 1 ]
      lappend lcd [ lindex [ buf$bufNo getkwd CD1_2 ] 1 ]
      lappend lcd [ lindex [ buf$bufNo getkwd CD2_1 ] 1 ]
      lappend lcd [ lindex [ buf$bufNo getkwd CD2_2 ] 1 ]
      set mscale [::math::statistics::max $lcd]
      set radius [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale ]

      gren_info "$::caption(astroid,radius_max) = $radius\n"

      # NOMAD1
      gren_info "csnomad1 $audace(rep_userCatalogNomad1) $ra $dec $radius\n"
      set nomad1 [csnomad1 $audace(rep_userCatalogNomad1) $ra $dec $radius]
      set nomad1 [::manage_source::set_common_fields $nomad1 NOMAD1 { RAJ2000 DECJ2000 errDec magV 0.5 }]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $nomad1]\n"
      ::t1mastroid::affich_rond $nomad1 NOMAD1 blue 1 $bufNo 5

      # USNOA2
      gren_info "csusnoa2 $audace(rep_userCatalogUsnoa2) $ra $dec $radius\n"
      set usnoa2 [csusnoa2 $audace(rep_userCatalogUsnoa2) $ra $dec $radius]
      set usnoa2 [::manage_source::set_common_fields $usnoa2 USNOA2 { ra_deg dec_deg 5.0 magR 0.5 }]
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $usnoa2]\n"
      ::t1mastroid::affich_rond $usnoa2 USNOA2 green 1 $bufNo 5

      # SKYBOT
      gren_info "::t1mastroid::get_skybot $dateobs $ra $dec [expr $radius*60.0] $iau_code\n"
      set err [ catch {::t1mastroid::get_skybot $dateobs $ra $dec [expr $radius*60.0] $iau_code} skybot ]
      if {$err} {
         gren_erreur "$::caption(astroid,erreur_connect)\n"
         return
      }
      gren_info "rollup = [::manage_source::get_nb_sources_rollup $skybot]\n"
      ::t1mastroid::affich_rond $skybot SKYBOT "#f120f0" 1 $bufNo 15
      ::t1mastroid::affich_skybot $skybot $bufNo

      gren_info "$::caption(astroid,end_astroid)\n"

      return
   }




   proc ::t1mastroid::astroid_acqu { visuNo } {

      global audace panneau

      set erreur [catch {set nbstars [calibwcs * * * * * USNO $audace(rep_userCatalogUsnoa2) -del_tmp_files 1 -yes_visu 0]} msg]
      file delete -force config.param config.sex default.nnw tt.log

      if {$erreur} {
         if {[info exists nbstars]} {
            if {[string is integer -strict $nbstars]} {
               gren_erreur "$::caption(astroid,erreur_failure): $::caption(astroid,erreur_nbstars) = $nbstars ($msg)\n"
            }
         } else {
            gren_erreur "$::caption(astroid,erreur_failure): $::caption(astroid,erreur_calibwcs)\n"
         }
         return
      }

      if {$nbstars<3} {
         gren_erreur "$::caption(astroid,erreur_failure): $::caption(astroid,nb_etoile) < 3\n"
         return
      }

      set bufNo    [ ::confVisu::getBufNo $visuNo ]
      set ra       [ lindex [ buf$bufNo getkwd CRVAL1 ] 1 ]
      set dec      [ lindex [ buf$bufNo getkwd CRVAL2 ] 1 ]
      set panneau(acqt1m,$visuNo,ra)  "[mc_angle2hms $ra 360 zero 2]"
      set panneau(acqt1m,$visuNo,dec) "[mc_angle2dms $dec 90 zero 2 ]"

      gren_info "$::caption(astroid,erreur_found) $nbstars USNOA2\n"
      return
   }










   proc ::t1mastroid::affich_skybot { listsources  bufNo } {

      gren_info "num name ra de class magV errpos angdist\n"
      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      foreach s $sources {
         foreach cata $s {
            set ra [lindex $cata {2 2}]
            set dec [lindex $cata {2 3}]
            set img_xy [ buf$bufNo radec2xy [ list $ra $dec ] ]
            set x [lindex $img_xy 0]
            set y [lindex $img_xy 1]
            if {$x < 0 || $x> $::t1mastroid::naxis1} {break}
            if {$y < 0 || $y> $::t1mastroid::naxis2} {break}
            gren_info "[lindex $cata 2]\n"
         }
      }
   }


   proc ::t1mastroid::affich_rond { listsources catalog color width bufNo r} {

      set fields  [lindex $listsources 0]
      set sources [lindex $listsources 1]
      foreach s $sources {
         foreach cata $s {
            if { [lindex $cata 0] == $catalog } {
               set cm [lindex $cata 1]
               set ra [lindex $cm 0]
               set dec [lindex $cm 1]
               if {$ra != "" && $dec != ""} {
                  ::t1mastroid::affich_un_rond $ra $dec $color $width $bufNo $r
               }
            }
         }
      }

   }


   proc ::t1mastroid::affich_un_rond { ra dec color width bufNo r } {

      global audace
      # Affiche un rond vert
      set img_xy [ buf$bufNo radec2xy [ list $ra $dec ] ]
      set x [lindex $img_xy 0]
      set y [lindex $img_xy 1]
      if {$x < 0 || $x> $::t1mastroid::naxis1} {return}
      if {$y < 0 || $y> $::t1mastroid::naxis2} {return}
      #gren_info "affich_un_rond_xy $x $y $color 5 $width\n"
      ::t1mastroid::affich_un_rond_xy $x $y $color $r $width

   }


   proc ::t1mastroid::affich_un_rond_xy { x y color radius width } {

      global audace

      set xi [expr $x - $radius]
      set yi [expr $y - $radius]
      set can_xy [ ::audace::picture2Canvas [list $xi $yi] ]
      set cxi [lindex $can_xy 0]
      set cyi [lindex $can_xy 1]

      set xs [expr $x + $radius]
      set ys [expr $y + $radius]
      set can_xy [ ::audace::picture2Canvas [list $xs $ys] ]
      set cxs [lindex $can_xy 0]
      set cys [lindex $can_xy 1]

      $audace(hCanvas) create oval $cxi $cyi $cxs $cys -outline $color -tags cadres -width $width

   }


   # radius   = rayon du FOV en arcsec
   proc ::t1mastroid::get_skybot { dateobs ra dec radius uaicode } {

      global voconf
      global skybot_list
      global skybot_list2

      set log 0

      set voconf(date_image)          $dateobs
      set voconf(centre_ad_image)     $ra
      set voconf(centre_dec_image)    $dec
      set voconf(observer)            [string trim $uaicode]
      set voconf(taille_champ_calcul) $radius
      set voconf(filter)              120
      set voconf(objfilter)           "110"

      #"TAROT CHILI"  809
      #"TAROT CALERN" 910

      # -- check availability of skybot slice
      set uptodate 0
      # dateobs format : 2008-01-01T03:48:04.64
      # skybot epoch format : 2008-01-01 03:48:04
      set epoch [regsub {T} $voconf(date_image) " "]
      set epoch [regsub {\..*} $epoch ""]
       # gren_info "    SKYBOT-STATUS for epoch $epoch \n"
      set status [vo_skybotstatus "text" "$epoch"]
       # gren_info "    MSG-SKYBOT-STATUS : <$status> \n"
      if {[lindex $status 1] >= 1} then {
         set stats [lindex $status 5]
         set lines [split $stats ";"]
         if { [llength $lines] == 2 } {
            if {[string match -nocase "*uptodate*" "[lindex $lines 1]"]} { set uptodate 1 }
         }
      }
      if { ! $uptodate } {
         # gren_info "SKYBOT-STATUS not up to date"
         # TODO if not up to date skip image
      }

      set skybot_answered 0
      set no_answer 0
      while { ! $skybot_answered } {

         # gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Appel au conesearch"
         # gren_info "$voconf(date_image) $voconf(centre_ad_image) $voconf(centre_dec_image) $voconf(taille_champ_calcul) $voconf(observer)"

         set err [ catch { vo_skybotconesearch $voconf(date_image) $voconf(centre_ad_image)   \
                                               $voconf(centre_dec_image) $voconf(taille_champ_calcul) \
                                               "votable" "object" $voconf(observer) $voconf(filter) $voconf(objfilter) } msg ]

         if {$err} {
            gren_info "$::caption(astroid,erreur_7)"
            gren_info "$::caption(astroid,erreur_MSG) <$err>"
            gren_info "$::caption(astroid,erreur_NUM) <$msg>"
            incr no_answer
            if {$no_answer>10} {
               break
            }
         } else {

            if { $msg eq "failed" } {
               gren_info "solarsystemprocess->get_skybot: failed"
            } else {
               set skybot_answered 1
               set err [ catch { ::dom::parse $msg } votable ]
               if { $err } {
                  gren_info "  => $::caption(astroid,erreur_analyse)"
                  set skybot_answered 0
                  after 10000
               }
            }

         }

      }

      set err [ catch { ::dom::parse $msg } votable ]
      if { $err } {
         gren_info "  => $::caption(astroid,erreur_analyse)"
         after 10000
      }

      # -- Parse the votable and extract solar system objects from the parsed votable
      set skybot_fields {}
      foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::ID}] {
         lappend skybot_fields "[::dom::node stringValue $n]"
      }
      set voconf(fields) $skybot_fields

      set skybot_list2 {}
      set common_fields [list ra dec poserr mag magerr]
      set fields [list [list "SKYBOT" $common_fields $skybot_fields] ]

      set cpt 0
      foreach tr [::dom::selectNode $votable {descendant::TR}] {
         set row {}
         foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
            lappend row [::dom::node stringValue $td]
         }
         # Conversion RA,DEC sexadec -> dec en degres
         set ra_d [expr [mc_angle2deg [lindex $row 2]] * 15.0]
         set dec_d [lindex [mc_angle2deg [lindex $row 3]] 0]
         set row [lreplace $row 2 3 $ra_d $dec_d]

         # Data pour le champ common
         set sra [lindex $row 2]
         set sdec [lindex $row 3]
         set sradialerrpos [expr abs([lindex $row 6])]
         set srmag [lindex $row 5]
         set srmagerr 1
         set common [list $sra $sdec $sradialerrpos $srmag $srmagerr ]

         set row [list [list "SKYBOT" $common $row ] ]
         lappend skybot_list2 $row
         incr cpt
      }

      set skybot_list2 [list $fields $skybot_list2]

      ::dom::destroy $votable

      if {$cpt == 0} {
         return -1
      } else {
         if {$log} { gren_info " $::caption(astroid,skybot_objet) $skybot_list2\n" }
         return $skybot_list2
      }

   }

}


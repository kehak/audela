## @file bdi_gui_planetes.tcl
#  @brief     GUI de recherche d objet mouvant dans les images
#  @author    Frederic Vachier & Alain Klotz
#  @version   1.0
#  @date      2018
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_planetes.tcl]
#  @endcode

# $Id: bdi_gui_planetes.tcl 13117 2016-05-21 02:00:00Z jberthier $

   ##
   # @namespace bdi_gui_planetes
   # @brief GUI de recherche d objet mouvant dans les images
   # @pre Requiert \c bdi_tools_cdl .
   # @warning Outil en d&eacute;veloppement
   #
   namespace eval ::bdi_gui_planetes {

      # Variable definissant la racine de la fenetre de l'outil
      variable fen
      # Table des donnees des etoiles de reference
      variable data_reference
      # Variable contenant la liste des sources selectionnees
      variable selectedTableList
      # Index des figures
      variable figConst     1
      variable figStars     2
      variable figTimeline  3
      variable figScimag    4
      variable figscifamous 5
      # Figure courante
      variable currentFig 0

      variable imglist

   }





   #----------------------------------------------------------------------------
   ## Initialisation des variables de namespace
   #  @brief Si la variable n'existe pas alors on va chercher
   #         dans la variable globale \c conf
   proc ::bdi_gui_planetes::inittoconf {  } {

      global bddconf audace

      #set ::bdi_gui_planetes::visuNo $bddconf(bufno) 
      #set ::bdi_gui_planetes::bufNo  $bddconf(visuno)
      #set ::bdi_gui_planetes::ext    [buf$bddconf(bufno) extension]
      
      set ::bdi_gui_planetes::software "Audela-BDI-Planete.v1.0"

      set ::bdi_gui_planetes::widget(nbimages) [llength $::bdi_gui_planetes::imglist]

      set ::bdi_gui_planetes::widget(rootfile)   "PLANET-"
      set ::bdi_gui_planetes::widget(step1,file) "PLANET-i."
      set ::bdi_gui_planetes::widget(step2,file) "PLANET-o"
      set ::bdi_gui_planetes::widget(step3,file) "PLANET-t"
      set ::bdi_gui_planetes::widget(step4,file) "PLANET-f."
      set ::bdi_gui_planetes::widget(step5,file) "PLANET-m"
      set ::bdi_gui_planetes::widget(step6,file) "PLANET-p"

      set ::bdi_gui_planetes::widget(step1,label) ""
      set ::bdi_gui_planetes::widget(step2,label) ""
      set ::bdi_gui_planetes::widget(step3,label) ""
      set ::bdi_gui_planetes::widget(step4,label) ""
      set ::bdi_gui_planetes::widget(step5,label) ""
      set ::bdi_gui_planetes::widget(step6,label) ""

      set ::bdi_gui_planetes::widget(step1,comment)    "Creation des images brutes indexees"
      set ::bdi_gui_planetes::widget(step2,comment)    "Creation de l image avant centrage"
      set ::bdi_gui_planetes::widget(step3,comment)    "Creation des images re-centrees"
      set ::bdi_gui_planetes::widget(step3b,comment)   "Creation des images re-centrees (methode affine)"
      set ::bdi_gui_planetes::widget(step4,comment)    "Creation du masque des etoiles part 1"
      set ::bdi_gui_planetes::widget(step5,comment)    "Creation du masque des etoiles part 2"
      set ::bdi_gui_planetes::widget(step6,comment)    "Creation des images masquees"

      # Si les repertoires sont differents
      if { $audace(rep_images) != $bddconf(dirtmp) } {
         set res [tk_messageBox -message  "Attention changement des repertoires de travail et d images" -type yesno]
         if { $res == "yes" } {
            gren_info "Attention les repertoires de travail et d images ont ete modifie\n"
            set audace(rep_images)  $bddconf(dirtmp)
            #set audace(rep_travail) $bddconf(dirtmp)
         }
      }
   }





   #----------------------------------------------------------------------------
   ## Fermeture de la fenetre .
   #  Les variables utilisees sont affectees a la variable globale
   #  @return void
   #
   proc ::bdi_gui_planetes::fermer {  } {
      
      global conf
      
      # TODO : effacer fichiers PLANET-
      # il faut faire un glob
      catch {
         set list_file [glob "$::bdi_gui_planetes::widget(rootfile)*"]
         foreach file $list_file {
            set errnum [catch {file delete -force $file} msg ]
         }
      }
      #set errnum [catch {file delete -force $::bdi_gui_planetes::widget(rootfile)*} msg ]
      
      # Sauve les variables
      # Champ pour rapport
 

      catch {
         set conf(bddimages,photometry,rapport,rapporteur)  $::bdi_gui_planetes::widget(info,rapporteur)
         set conf(bddimages,photometry,rapport,adresse)     $::bdi_gui_planetes::widget(info,adresse)   
         set conf(bddimages,photometry,rapport,mail)        $::bdi_gui_planetes::widget(info,mail)      
         set conf(bddimages,photometry,rapport,reduc)       $::bdi_gui_planetes::widget(info,reduc)     
         set conf(bddimages,photometry,rapport,filtre)      $::bdi_gui_planetes::widget(info,filtre)    
         set conf(bddimages,photometry,rapport,filtre_nfo)  $::bdi_gui_planetes::widget(info,filtre_nfo)
      }
      
      # Recupere la position
      ::bdi_gui_planetes::recup_position

      # liberation des variables
      ::bdi_gui_planetes::free_memory

      # Fermeture de la fenetre
      destroy $::bdi_gui_planetes::fen
      unset ::bdi_gui_planetes::fen
      return
   }





   #------------------------------------------------------------
   ## Recuperation de la position d'affichage de la GUI
   #  @return void
   #
   proc ::bdi_gui_planetes::recup_position { } {

      global conf bddconf

      set bddconf(geometry_bdi_gui_planetes) [wm geometry $::bdi_gui_planetes::fen]
      set conf(bddimages,geometry_bdi_gui_planetes) $bddconf(geometry_bdi_gui_planetes)
      return
   }





   #----------------------------------------------------------------------------
   ## Relance l outil
   #  @return void
   #
   proc ::bdi_gui_planetes::relance {  } {

      ::console::clear 
      ::bddimages::ressource
      ::bdi_gui_planetes::fermer
      ::bdi_gui_planetes::run $::bdi_gui_planetes::imglist
      return
   }


   #------------------------------------------------------------
   ## Effacement des marques de photometrie
   #  @return void
   #
   proc ::bdi_gui_planetes::p_cleanmark {  } {

      global bddconf

      cleanmark
      catch { ::audace::psf_clean_mark $bddconf(visuno) }
      
      return
   }



   #------------------------------------------------------------
   ## Demarrage de l'outil
   #  @return void
   #
   proc ::bdi_gui_planetes::run { imglist } {

      set ::bdi_gui_planetes::imglist $imglist
      ::bdi_gui_planetes::precharge_imglist
      ::bdi_gui_planetes::inittoconf
      ::bdi_gui_planetes::create_dialog
      return
   }





   #------------------------------------------------------------
   ## Recuperation de la position d'affichage de la GUI
   #  @return void
   #
   proc ::bdi_gui_planetes::free_memory { } {

      global bddconf

      # desactivation des binding
      ::bdi_gui_planetes::activ_touches 0

      # Effacement des buffer
      visu$bddconf(visuno) buf 1
      ::bdi_gui_planetes::buffer_clear
      
      # procedure d effacement
      catch { ::bdi_gui_planetes::delete_table_mesure }
      
      # Effacement  des tables
      catch { $::bdi_gui_planetes::skybot_table delete 0 end }
      catch { $::bdi_gui_planetes::data_source  delete 0 end }

      # Effacement  des tableaux associatifs
      array unset ::bdi_gui_planetes::widget
      array unset ::bdi_gui_planetes::buffer_list
      
      # Effacement  des variables
      catch { unset ::bdi_gui_planetes::skybot_table }
      catch { unset ::bdi_gui_planetes::data_source  }
      catch { unset ::bdi_gui_planetes::scrollbar    }

      # Effacement  des marques
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot
      $::confVisu::private($bddconf(visuno),hCanvas) delete planetes_skybot_solo

   }





#::bddimages::ressource ; ::bdi_gui_planetes::precharge_imglist
   proc ::bdi_gui_planetes::precharge_imglist {  } {

      array unset ::bdi_gui_planetes::obs
      
      # info premiere image
      set img [lindex $::bdi_gui_planetes::imglist 0]
      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set date_obs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
      set exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set jdmp      [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]
      set ra        [lindex [::bddimages_liste::lget $tabkey RA] 1]
      set dec       [lindex [::bddimages_liste::lget $tabkey DEC] 1]
      set iau_code  [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]
      set naxis1    [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
      set naxis2    [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
      set scale_x   [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set scale_y   [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      set mscale    [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
      set radius    [format "%0.0f" [expr [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale] * 2.0 * 60.0] ]

      set ::bdi_gui_planetes::obs(naxis1)        $naxis1
      set ::bdi_gui_planetes::obs(naxis2)        $naxis2
      set ::bdi_gui_planetes::obs(radius)        $radius
      set ::bdi_gui_planetes::obs(iau_code)      $iau_code
      set ::bdi_gui_planetes::obs(first)         [list [mc_date2iso8601 $jdmp ] $ra $dec $jdmp ]
      
      gren_info "precharge_imglist\n"
      gren_info "ra        = [mc_angle2hms $ra 360 zero 1 auto string]\n"
      gren_info "dec       = [mc_angle2dms $dec 90 zero 1 + string]\n"

      # info derniere image
      set img [lindex $::bdi_gui_planetes::imglist end]
      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set date_obs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
      set exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set jdmp      [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]
      set ra        [lindex [::bddimages_liste::lget $tabkey RA] 1]
      set dec       [lindex [::bddimages_liste::lget $tabkey DEC] 1]
      set ::bdi_gui_planetes::obs(last)         [list [mc_date2iso8601 $jdmp ] $ra $dec $jdmp ]
      
      # info chaque images
      foreach img $::bdi_gui_planetes::imglist {
         set tabkey    [::bddimages_liste::lget $img "tabkey"]
         set date_obs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
         set exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
         set jdmp     [expr [mc_date2jd $date_obs] + $exposure / 86400.0 / 2.0]

         lappend ::bdi_gui_planetes::obs(index,dateobs)     $date_obs
         set ::bdi_gui_planetes::obs(index,$date_obs,jdmp) $jdmp
      }
      
      return
   }















   #------------------------------------------------------------
   ## Selectionne le type d image qui sera affiche
   #  @return void
   #
   proc ::bdi_gui_planetes::select_type_image { type } {

      set ::bdi_gui_planetes::widget(type_image,selected) $type
      return
   }



   #------------------------------------------------------------
   ## 
   #  @return void
   #
   proc ::bdi_gui_planetes::compare_id_skybot {item1 item2} {
       
       if {[string is integer $item1] == 1 && [string is integer $item2] == 1} {
          if {$item1 < $item2} { 
             return -1
          } else {
             return 1
          }
       }
       if {[string is integer $item1] != 1 && [string is integer $item2] == 1} {
          return -1
       }
       if {[string is integer $item1] == 1 && [string is integer $item2] != 1} {
          return 1
       }
       if {[string is integer $item1] != 1 && [string is integer $item2] != 1} {
          return 1
       }
       
   }






   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::bdi_gui_planetes::activ_touches { tp } {

      if {$tp==0} {
         bind .audace <Key-c> ""
         bind .audace <Key-x> ""
         bind .audace <Key-v> ""
         bind .audace <Key-q> ""
      }
      if {$tp==1} {
         gren_info "c: next scroll, x: prev scroll, v: mesure, q: keep\n"
         bind .audace <Key-c> "::bdi_gui_planetes::next_scroll"
         bind .audace <Key-x> "::bdi_gui_planetes::previous_scroll"
         bind .audace <Key-v> "::bdi_gui_planetes::bind_mesure"
         bind .audace <Key-q> "::bdi_gui_planetes::keep"
      }
   }






   #----------------------------------------------------------------------------
   ## Creation de la boite de dialogue.
   #  @return void
   proc ::bdi_gui_planetes::create_dialog { } {

      global audace
      global conf bddconf
      
      set scroll_size 450

      if { ! [info exists conf(bddimages,geometry_bdi_gui_planetes)] } { set conf(bddimages,geometry_bdi_gui_planetes) "+165+55" }
      set bddconf(geometry_bdi_gui_planetes) $conf(bddimages,geometry_bdi_gui_planetes)

      set ::bdi_gui_planetes::fen .planetes
      if { [winfo exists $::bdi_gui_planetes::fen] } {
         wm withdraw $::bdi_gui_planetes::fen
         wm deiconify $::bdi_gui_planetes::fen
         focus $::bdi_gui_planetes::fen
         return
      }
      toplevel $::bdi_gui_planetes::fen -class Toplevel
      wm geometry $::bdi_gui_planetes::fen $bddconf(geometry_bdi_gui_planetes)
      wm resizable $::bdi_gui_planetes::fen 1 1
      wm title $::bdi_gui_planetes::fen "Decouverte d'objets mobile"
      wm protocol $::bdi_gui_planetes::fen WM_DELETE_WINDOW "::bdi_gui_planetes::fermer"

      set frm $::bdi_gui_planetes::fen.appli
      #--- Cree un frame general
      frame $frm  -cursor arrow -relief groove
      pack $frm -in $::bdi_gui_planetes::fen -anchor s -side top -expand yes -fill both -padx 10 -pady 5

        # Bouton actions
        set frmbut [frame $frm.but]
        grid $frmbut -in $frm -sticky news

           Button $frmbut.recharge -text "Recharge"  -command "::bdi_gui_planetes::relance"
           Button $frmbut.ressource -text "Ressource"  -command "::console::clear ; ::bddimages::ressource"
           Button $frmbut.close -text "Close"  -command "::bdi_gui_planetes::fermer"
           grid $frmbut.recharge $frmbut.ressource $frmbut.close -in $frmbut  -sticky news

        # Selection des images
        TitleFrame $frm.selimg -borderwidth 2 -text "Selection des images"
        grid $frm.selimg -in $frm -sticky news

           #set frmmod [frame $frm.selimg.mod]
           #grid $frmmod -in [$frm.selimg getframe] -sticky news
           #set ::bdi_gui_planetes::widget(type_image,frame) $frmmod

           set frmsc [frame $frm.selimg.scale]
           grid $frmsc -in [$frm.selimg getframe] -sticky news

              scale $frmsc.scrollbar -from 0 -to 1 -length $scroll_size -variable ::bdi_gui_planetes::scrollbar \
                 -label "" -orient horizontal -state disabled
              pack $frmsc.scrollbar -in $frmsc -anchor center -fill none -pady 5 -ipadx 5 -ipady 3 -expand yes -fill both 

              bind $frmsc.scrollbar <ButtonRelease> "::bdi_gui_planetes::move_scroll "
              set ::bdi_gui_planetes::widget(scrollbar,frame) $frmsc.scrollbar

           set frmnav [frame $frm.selimg.nav]
           grid $frmnav -in [$frm.selimg getframe] -sticky news

              Button $frmnav.av -text "<-"  -command "::bdi_gui_planetes::previous_scroll"    
              Button $frmnav.ap -text "->"  -command "::bdi_gui_planetes::next_scroll"        
              Button $frmnav.cl -text "CleanMark"  -command "::bdi_gui_planetes::p_cleanmark" 
              Button $frmnav.rj -text "rejected"  -command "" -state disabled

              grid $frmnav.av $frmnav.ap $frmnav.cl $frmnav.rj -in $frmnav -sticky news
              set ::bdi_gui_planetes::widget(manage_img,rejected) $frmnav.rj

           set frmfilm [frame $frm.selimg.frmfilm]
           grid $frmfilm -in [$frm.selimg getframe] -sticky news

              Button $frmfilm.ar -text "AR"     -command "::bdi_gui_planetes::visu_boucle_va_et_vient" -state disabled
              Button $frmfilm.a  -text "Aller"  -command "::bdi_gui_planetes::visu_boucle_un_sens" -state disabled

              grid $frmfilm.ar $frmfilm.a -in $frmfilm -sticky news
              set ::bdi_gui_planetes::widget(film,ar) $frmfilm.ar
              set ::bdi_gui_planetes::widget(film,a)  $frmfilm.a





         # Onglets
         set onglets [frame $frm.onglets]
         grid $onglets -in $frm -sticky news
         #pack $onglets -in $frm  -expand yes -fill both

            pack [ttk::notebook $onglets.nb] -expand yes -fill both
            set f_trimg   [frame $onglets.nb.f_trimg]
            set f_skybot  [frame $onglets.nb.f_skybot]
            set f_newast  [frame $onglets.nb.f_newast]
            set f_starref [frame $onglets.nb.f_starref]
            set f_photom  [frame $onglets.nb.f_photom]
            set f_report  [frame $onglets.nb.f_report]

            $onglets.nb add $f_trimg    -text "Traitement"
            $onglets.nb add $f_skybot   -text "Skybot"
            $onglets.nb add $f_newast   -text "Newaster"
            $onglets.nb add $f_starref  -text "Star Ref"
            $onglets.nb add $f_photom   -text "Mesure"
            $onglets.nb add $f_report   -text "Rapport"

            #$onglets.nb select $f_data_reference
            ttk::notebook::enableTraversal $onglets.nb
            $onglets.nb select $f_trimg

         # Traitement
         set trimg [frame $f_trimg.trimg  -borderwidth 1 -relief groove]
         pack $trimg -in $f_trimg -expand yes -fill both


            # Traitement
             TitleFrame $trimg.work -borderwidth 2 -text "Traitement par lot"
             grid $trimg.work -in $trimg -sticky news
                set width 25
                label  $trimg.work.lnbi -text "Nombre d images :"
                label  $trimg.work.cnbi -textvariable ::bdi_gui_planetes::widget(nbimages)

                Button $trimg.work.step1 -text "Step 1"  -command "::bdi_gui_planetes::step1"
                Button $trimg.work.voir1 -text "voir"  -command "::bdi_gui_planetes::voir 1" -state disabled
                label  $trimg.work.cstp1 -textvariable ::bdi_gui_planetes::widget(step1,label) -width $width
                DynamicHelp::add $trimg.work.step1 -text $::bdi_gui_planetes::widget(step1,comment)
                set ::bdi_gui_planetes::widget(step1,exec,button) $trimg.work.step1
                set ::bdi_gui_planetes::widget(step1,voir,button) $trimg.work.voir1

                Button $trimg.work.step2 -text "Step 2"  -command "::bdi_gui_planetes::step2" -state disabled
                Button $trimg.work.voir2 -text "voir"  -command "::bdi_gui_planetes::voir 2" -state disabled
                label  $trimg.work.cstp2 -textvariable ::bdi_gui_planetes::widget(step2,label) -width $width
                DynamicHelp::add $trimg.work.step2 -text $::bdi_gui_planetes::widget(step2,comment)
                set ::bdi_gui_planetes::widget(step2,exec,button) $trimg.work.step2
                set ::bdi_gui_planetes::widget(step2,voir,button) $trimg.work.voir2

                grid $trimg.work.lnbi   $trimg.work.cnbi  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step1  $trimg.work.voir1  $trimg.work.cstp1  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step2  $trimg.work.voir2  $trimg.work.cstp2  -in [$trimg.work getframe] -sticky news





if {0} {
                Button $trimg.work.step3 -text "Step 3"  -command "::bdi_gui_planetes::step3" -state disabled
                Button $trimg.work.voir3 -text "voir"  -command "::bdi_gui_planetes::voir 3" -state disabled
                label  $trimg.work.cstp3 -textvariable ::bdi_gui_planetes::widget(step3,label) -width $width
                DynamicHelp::add $trimg.work.step3 -text $::bdi_gui_planetes::widget(step3,comment)
                set ::bdi_gui_planetes::widget(step3,exec,button) $trimg.work.step3
                set ::bdi_gui_planetes::widget(step3,voir,button) $trimg.work.voir3

                Button $trimg.work.step3b -text "Step 3 bis"  -command "::bdi_gui_planetes::step3bis" -state disabled
                Button $trimg.work.voir3b -text "voir"  -command "::bdi_gui_planetes::voir 3" -state disabled
                label  $trimg.work.cstp3b -textvariable ::bdi_gui_planetes::widget(step3b,label) -width $width
                DynamicHelp::add $trimg.work.step3b -text $::bdi_gui_planetes::widget(step3b,comment)
                set ::bdi_gui_planetes::widget(step3b,exec,button) $trimg.work.step3b
                set ::bdi_gui_planetes::widget(step3b,voir,button) $trimg.work.voir3b

                Button $trimg.work.step4 -text "Step 4"  -command "::bdi_gui_planetes::step4" -state disabled
                Button $trimg.work.voir4 -text "voir"  -command "::bdi_gui_planetes::voir 4" -state disabled
                label  $trimg.work.cstp4 -textvariable ::bdi_gui_planetes::widget(step4,label) -width $width
                DynamicHelp::add $trimg.work.step4 -text $::bdi_gui_planetes::widget(step4,comment)
                set ::bdi_gui_planetes::widget(step4,exec,button) $trimg.work.step4
                set ::bdi_gui_planetes::widget(step4,voir,button) $trimg.work.voir4

                Button $trimg.work.step5 -text "Step 5"  -command "::bdi_gui_planetes::step5" -state disabled
                Button $trimg.work.voir5 -text "voir"  -command "::bdi_gui_planetes::voir 5" -state disabled
                label  $trimg.work.cstp5 -textvariable ::bdi_gui_planetes::widget(step5,label) -width $width
                DynamicHelp::add $trimg.work.step5 -text $::bdi_gui_planetes::widget(step5,comment)
                set ::bdi_gui_planetes::widget(step5,exec,button) $trimg.work.step5
                set ::bdi_gui_planetes::widget(step5,voir,button) $trimg.work.voir5

                Button $trimg.work.step6 -text "Step 6"  -command "::bdi_gui_planetes::step6" -state disabled
                Button $trimg.work.voir6 -text "voir"  -command "::bdi_gui_planetes::voir 6" -state disabled
                label  $trimg.work.cstp6 -textvariable ::bdi_gui_planetes::widget(step6,label) -width $width
                DynamicHelp::add $trimg.work.step6 -text $::bdi_gui_planetes::widget(step6,comment)
                set ::bdi_gui_planetes::widget(step6,exec,button) $trimg.work.step6
                set ::bdi_gui_planetes::widget(step6,voir,button) $trimg.work.voir6

                grid $trimg.work.lnbi   $trimg.work.cnbi  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step1  $trimg.work.voir1  $trimg.work.cstp1  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step2  $trimg.work.voir2  $trimg.work.cstp2  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step3  $trimg.work.voir3  $trimg.work.cstp3  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step3b $trimg.work.voir3b $trimg.work.cstp3b -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step4  $trimg.work.voir4  $trimg.work.cstp4  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step5  $trimg.work.voir5  $trimg.work.cstp5  -in [$trimg.work getframe] -sticky news
                grid $trimg.work.step6  $trimg.work.voir6  $trimg.work.cstp6  -in [$trimg.work getframe] -sticky news
}




         # Objets Skybot
         set skybot [frame $f_skybot.skybot  -borderwidth 1 -relief groove]
         pack $skybot -in $f_skybot -expand yes -fill both

           set frmnav [frame $skybot.nav]
           #grid $frmnav -in $skybot -sticky news
           pack $frmnav  -in $skybot -expand yes -fill both

              Button $frmnav.calcul -text "Cacul"  -command "::bdi_gui_planetes::skybot_charge"
              Button $frmnav.charge -text "Charge" -command "::bdi_gui_planetes::skybot_charge_webservice_result"
              Button $frmnav.voir   -text "Voir"   -command "::bdi_gui_planetes::skybot_voir"
              grid $frmnav.calcul $frmnav.charge $frmnav.voir -in $frmnav -sticky news
              set ::bdi_gui_planetes::widget(skybot,charge) $frmnav.charge
              set ::bdi_gui_planetes::widget(skybot,voir)   $frmnav.voir

           set frmtab [frame $skybot.tab]
           pack $frmtab  -in $skybot -expand yes -fill both

              set cols [list 0 "aster"      right \
                             0 "Id"         right \
                             0 "Name"       left  \
                             0 "Class"      left  \
                             0 "Mag"        right \
                             0 "Err Pos"    right \
                       ]
              # Table
              set ::bdi_gui_planetes::skybot_table $frmtab.table
              tablelist::tablelist $::bdi_gui_planetes::skybot_table \
                -columns $cols \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $frmtab.hsb set ] \
                -yscrollcommand [ list $frmtab.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              # Scrollbar
              scrollbar $frmtab.hsb -orient horizontal -command [list $::bdi_gui_planetes::skybot_table xview]
              pack $frmtab.hsb -in $frmtab -side bottom -fill x
              scrollbar $frmtab.vsb -orient vertical -command [list $::bdi_gui_planetes::skybot_table yview]
              pack $frmtab.vsb -in $frmtab -side right -fill y

              # Pack la Table
              pack $::bdi_gui_planetes::skybot_table -in $frmtab -expand yes -fill both

              # Popup
              menu $frmtab.popupTbl -title "Actions"

                 $frmtab.popupTbl add command -label "Selctionner" \
                     -command "" -state disabled

              bind [$::bdi_gui_planetes::skybot_table bodypath] <ButtonPress-3> [ list tk_popup $frmtab.popupTbl %X %Y ]
              bind $::bdi_gui_planetes::skybot_table <<ListboxSelect>> [ list ::bdi_gui_planetes::cmdButton1Click_skybot_table %W ]

              # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
              #    Ascii
              foreach ncol [list "Name" "Class"] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::skybot_table columnconfigure $pcol -sortmode ascii
              }
              #    Spec
              foreach ncol [list "Id" ] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::skybot_table columnconfigure $pcol -sortmode command -sortcommand ::bdi_gui_planetes::compare_id_skybot
              }
              #    Real
              foreach ncol [list "Mag" "Err Pos"] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::skybot_table columnconfigure $pcol -sortmode real
              }
              foreach ncol [list "aster"] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::skybot_table columnconfigure $pcol -hide yes

              }




         # Objets Newaster  
         set frmn [frame $f_newast.newast  -borderwidth 1 -relief groove]
         pack $frmn -in $f_newast -expand yes -fill both

           set frmnav [frame $frmn.nav]
           pack $frmnav  -in $frmn -expand yes -fill both

              Button $frmnav.calcul -text "Cacul"  -command "::bdi_gui_planetes::newast_calcul"
              Button $frmnav.voir   -text "Voir"   -command "::bdi_gui_planetes::newast_voir"
              grid $frmnav.calcul $frmnav.voir -in $frmnav -sticky news
              set ::bdi_gui_planetes::widget(newast,voir)   $frmnav.voir


           set frmtab [frame $frmn.tab]
           pack $frmtab  -in $frmn -expand yes -fill both

              set cols [list 0 "Object"         left  \
                             0 "Mag"            right \
                             0 "Err Pos"        right \
                             0 "Designations"   right \
                       ]
              # Table
              set ::bdi_gui_planetes::newast_table $frmtab.table
              tablelist::tablelist $::bdi_gui_planetes::newast_table \
                -columns $cols \
                -labelcommand tablelist::sortByColumn \
                -xscrollcommand [ list $frmtab.hsb set ] \
                -yscrollcommand [ list $frmtab.vsb set ] \
                -selectmode extended \
                -activestyle none \
                -stripebackground "#e0e8f0" \
                -showseparators 1

              # Scrollbar
              scrollbar $frmtab.hsb -orient horizontal -command [list $::bdi_gui_planetes::newast_table xview]
              pack $frmtab.hsb -in $frmtab -side bottom -fill x
              scrollbar $frmtab.vsb -orient vertical -command [list $::bdi_gui_planetes::newast_table yview]
              pack $frmtab.vsb -in $frmtab -side right -fill y

              # Pack la Table
              pack $::bdi_gui_planetes::newast_table -in $frmtab -expand yes -fill both

              # Popup
              menu $frmtab.popupTbl -title "Actions"

                 $frmtab.popupTbl add command -label "Selctionner" \
                     -command "" -state disabled

              bind [$::bdi_gui_planetes::newast_table bodypath] <ButtonPress-3> [ list tk_popup $frmtab.popupTbl %X %Y ]
              bind $::bdi_gui_planetes::newast_table <<ListboxSelect>> [ list ::bdi_gui_planetes::cmdButton1Click_newast_table %W ]

              # tri des colonnes (ascii|asciinocase|command|dictionary|integer|real)
              #    Ascii
              foreach ncol [list "Object" "Designations"] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::newast_table columnconfigure $pcol -sortmode ascii
              }
              #    Real
              foreach ncol [list "Mag" "Err Pos"] {
                 set pcol [expr int ([lsearch $cols $ncol]/3)]
                 $::bdi_gui_planetes::newast_table columnconfigure $pcol -sortmode real
              }

           set frmentry [frame $frmn.entry]
           pack $frmentry  -in $frmn -expand yes -fill both
           #pack configure $frmentry -side top -fill x

           set ::bdi_gui_planetes::newaster_orbit_entry $frmentry.val
           text $::bdi_gui_planetes::newaster_orbit_entry -height 10 -width 80
#                -xscrollcommand "${::bdi_gui_reports::build_gui_newaster_orbit_entry}.xscroll set" \
#                -yscrollcommand "${::bdi_gui_reports::build_gui_newaster_orbit_entry}.yscroll set" \
#                -wrap none
           pack $::bdi_gui_planetes::newaster_orbit_entry -in $frmentry -expand yes -fill both -padx 5 -pady 5




         # Etoiles de Reference
         set starref [frame $f_starref.starref  -borderwidth 1 -relief groove]
         pack $starref -in $f_starref -expand yes -fill both

           #set frmnav [frame $starref.nav]
           #grid $frmnav -in $starref -sticky news

           #   Button $frmnav.ch -text "Load Cata"    -command "::bdi_gui_planetes::charge_cata"
           #   Button $frmnav.se -text "Select Star"  -command "::bdi_gui_planetes::select_star"
           #   grid $frmnav.ch $frmnav.se -in $frmnav -sticky news

           set frmsel [frame $starref.sel]
           grid $frmsel -in $starref -sticky news


              checkbutton $frmsel.usecata -variable ::bdi_gui_planetes::widget(starref,usecata) \
                                          -justify left \
                                          -text "Utiliser CATA" \
                                          -state disabled

              grid $frmsel.usecata -in $frmsel -sticky nws -columnspan 2

              set frmucl [frame $frmsel.ucl1 -width 50]
              set frmucr [frame $frmsel.ucr1]
              grid $frmucl $frmucr -in $frmsel -sticky news

                 set ::bdi_gui_planetes::widget(starref,usecata,auto) 1
                 set ::bdi_gui_planetes::widget(starref,usecata,manu) 0

                 checkbutton $frmucr.auto -variable ::bdi_gui_planetes::widget(starref,usecata,auto) \
                                          -justify left \
                                          -text "Construit une Super etoile de Reference automatiquement" \
                                          -state disabled
                 checkbutton $frmucr.manu -variable ::bdi_gui_planetes::widget(starref,usecata,manu) \
                                          -justify left \
                                          -command "::bdi_gui_planetes::starref_usecata_select_box_view" \
                                          -text "Selectionner une etoile du CATA manuellement"           
                 grid $frmucr.auto -in $frmucr -sticky nws
                 grid $frmucr.manu -in $frmucr -sticky nws 
                 #-columnspan 2

                 set frmucrf [frame $frmucr.ucrf -width 50]
                 grid $frmucrf -in $frmucr -sticky news

                    set frmucrl [frame $frmucrf.ucrl -width 50]
                    set frmucrr [frame $frmucrf.ucrr]
                    grid $frmucrl $frmucrr -in $frmucrf -sticky news

                       Button $frmucrr.box -text "Select Box" \
                                           -command "::bdi_gui_planetes::starref_usecata_select_box"
                       label  $frmucrr.lab -textvariable ::bdi_gui_planetes::widget(starref_usecata,manuel,star,name) 

                       set ::bdi_gui_planetes::widget(starref,usecata,box) $frmucrr.box
                       grid $frmucrr.box $frmucrr.lab -in $frmucrr -sticky nws 


              checkbutton $frmsel.nocata  -variable ::bdi_gui_planetes::widget(starref,nocata) \
                                          -justify left \
                                          -text "Selectionner une etoile manuellement sur l image" \
                                          -state disabled

              grid $frmsel.nocata -in $frmsel -sticky nws -columnspan 2

              set frmucl [frame $frmsel.ucl2]
              set frmucr [frame $frmsel.ucr2]
              grid $frmucl $frmucr -in $frmsel -sticky news

                 Button $frmucr.box -text "Select Box" -command "::bdi_gui_planetes::starref_nocata_select_box" -state disabled
                 label  $frmucr.lab -text "Mag : " -borderwidth 1 -width 10 -state disabled
                 entry  $frmucr.val -relief sunken -width 10 -textvariable ::bdi_gui_planetes::widget(starref,nocata,mag) -state disabled
                 grid $frmucr.box $frmucr.lab $frmucr.val -in $frmucr -sticky news


         # Mesure Photometrique
         set photom [frame $f_photom.photom  -borderwidth 1 -relief groove]
         pack $photom -in $f_photom -expand yes -fill both

           set frmgen [frame $photom.gen]
           pack $frmgen  -in $photom -expand yes -fill both

              Button $frmgen.at -text "Activer Touches" -command "::bdi_gui_planetes::activ_touches 1"
              Button $frmgen.dt -text "Desactiver Touches" -command "::bdi_gui_planetes::activ_touches 0"
              Button $frmgen.rm -text "Efface table Mesure" -command "::bdi_gui_planetes::delete_table_mesure"

              grid $frmgen.at $frmgen.dt $frmgen.rm -in $frmgen -sticky nws

           set frmnav [frame $photom.nav]
           pack $frmnav  -in $photom -expand yes -fill both
           #grid $frmnav -in $photom -sticky news

              Button $frmnav.av -text "<-"        -command "::bdi_gui_planetes::previous_scroll"
              Button $frmnav.ap -text "->"        -command "::bdi_gui_planetes::next_scroll"
              Button $frmnav.ok -text "keep"      -command "::bdi_gui_planetes::keep"
              Button $frmnav.cl -text "CleanMark" -command "::bdi_gui_planetes::p_cleanmark"

              grid $frmnav.av $frmnav.ap $frmnav.ok $frmnav.cl -in $frmnav -sticky news

           set frmtab [frame $photom.tab -width 300]
           pack $frmtab  -in $photom -expand yes -fill both
           #grid $frmtab -in $photom -sticky news

              set cols [list 0 "Id"         left  \
                             0 "Date"       left  \
                             0 "Ra"         right \
                             0 "Dec"        right \
                             0 "Mag"        right \
                             0 "Filtre"     right \
                       ]
            # Table
            set ::bdi_gui_planetes::data_source $frmtab.table
            tablelist::tablelist $::bdi_gui_planetes::data_source \
              -columns $cols \
              -labelcommand tablelist::sortByColumn \
              -xscrollcommand [ list $frmtab.hsb set ] \
              -yscrollcommand [ list $frmtab.vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -showseparators 1

            # Scrollbar
            scrollbar $frmtab.hsb -orient horizontal -command [list $::bdi_gui_planetes::data_source xview]
            pack $frmtab.hsb -in $frmtab -side bottom -fill x
            scrollbar $frmtab.vsb -orient vertical -command [list $::bdi_gui_planetes::data_source yview]
            pack $frmtab.vsb -in $frmtab -side right -fill y

            # Pack la Table
            pack $::bdi_gui_planetes::data_source -in $frmtab -expand yes -fill both


            # Popup
            menu $frmtab.popupTbl -title "Actions"

               $frmtab.popupTbl add command -label "(s)upprimer entree" \
                   -command "::bdi_gui_planetes::delete_table_mesure_sel"
               $frmtab.popupTbl add command -label "(S)upprimer tout" \
                   -command "::bdi_gui_planetes::delete_table_mesure"

            bind [$::bdi_gui_planetes::data_source bodypath] <ButtonPress-3> [ list tk_popup $frmtab.popupTbl %X %Y ]

         # Export des rapports
         set report [frame $f_report.report  -borderwidth 1 -relief groove]
         pack $report -in $f_report -expand yes -fill both

            # Object
            set obj [TitleFrame $report.obj -borderwidth 2 -text "Objet"]
            grid $obj -in $report -sticky news

               label  $obj.lab_obj_name -text "Nom de l objet : "
               entry  $obj.val_obj_name -relief sunken -width 20 -textvariable ::bdi_gui_planetes::widget(info,obj_name)
               Button $obj.cre -text "+"      -command "::bdi_gui_planetes::report_object_create"
               Button $obj.sel -text "Select" -command "::bdi_gui_planetes::report_object_select"

               grid $obj.lab_obj_name $obj.val_obj_name $obj.cre $obj.sel -in [$obj getframe] -sticky nws

            # Header
            set head [TitleFrame $report.head -borderwidth 2 -text "Header"]
            grid $head -in $report -sticky news

               set width_short 10
               set width_long  40

               label  $head.lab_uai_code -text "UAI code"
               entry  $head.val_uai_code -relief sunken -width $width_short -textvariable ::bdi_gui_planetes::widget(info,uai_code)

               label  $head.lab_rapporteur -text "Rapporteur"
               entry  $head.val_rapporteur -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,rapporteur)

               label  $head.lab_adresse -text "Adresse"
               entry  $head.val_adresse -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,adresse)

               label  $head.lab_mail -text "Mail"
               entry  $head.val_mail -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,mail)

               label  $head.lab_observ -text "Observateurs"
               entry  $head.val_observ -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,observ)

               label  $head.lab_reduc -text "Reduction"
               entry  $head.val_reduc -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,reduc)

               label  $head.lab_instru -text "Instrument"
               entry  $head.val_instru -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,instru)

               label  $head.lab_cata -text "Catalogue"
               entry  $head.val_cata -relief sunken -width $width_short -textvariable ::bdi_gui_planetes::widget(info,cata)

               label  $head.lab_batch -text "Batch"
               entry  $head.val_batch -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,batch)

               label  $head.lab_filtre -text "Filtre"
               entry  $head.val_filtre -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,filtre)

               label  $head.lab_filtre_nfo -text "Filtre info"
               entry  $head.val_filtre_nfo -relief sunken -width $width_long -textvariable ::bdi_gui_planetes::widget(info,filtre_nfo)

               grid $head.lab_uai_code   $head.val_uai_code   -in [$head getframe] -sticky nws
               grid $head.lab_rapporteur $head.val_rapporteur -in [$head getframe] -sticky nws
               grid $head.lab_adresse    $head.val_adresse    -in [$head getframe] -sticky nws
               grid $head.lab_mail       $head.val_mail       -in [$head getframe] -sticky nws
               grid $head.lab_observ     $head.val_observ     -in [$head getframe] -sticky nws
               grid $head.lab_reduc      $head.val_reduc      -in [$head getframe] -sticky nws
               grid $head.lab_instru     $head.val_instru     -in [$head getframe] -sticky nws
               grid $head.lab_cata       $head.val_cata       -in [$head getframe] -sticky nws
               grid $head.lab_batch      $head.val_batch      -in [$head getframe] -sticky nws
               grid $head.lab_filtre     $head.val_filtre     -in [$head getframe] -sticky nws
               grid $head.lab_filtre_nfo $head.val_filtre_nfo -in [$head getframe] -sticky nws

            # Export des rapports
            set export [TitleFrame $report.export -borderwidth 2 -text "Exporter"]
            grid $export -in $report -sticky news

              Button $export.cr -text "Creation des Rapports INFO+CSV" -command "::bdi_gui_planetes::report_create"
              checkbutton $export.flag -variable ::bdi_gui_planetes::widget(report,decouverte) \
                                       -justify left \
                                       -text "Flag decouverte" 

              grid $export.cr $export.flag -in [$export getframe]  -sticky news

#      set rapport_uai_code   181
#      set rapport_rapporteur "F. Vachier"
#      set rapport_adresse    "IMCCE, Obs de Paris,77 Av Denfert Rochereau 75014 Paris France "
#      set rapport_mail       "vachier@imcce.fr"
#      set rapport_observ     "F. Vachier, A. Klotz, J.P. Teng, A. Peyrot, P. Thierry, J. Berthier"

#      set rapport_reduc      "F. Vachier"
#      set rapport_instru     "0.6-m f/8 reflector + CCD"
#      set rapport_cata       "UCAC4"
#      set rapport_batch      "Audela_BDI_2017-07-10-1"



      #--- Mise a jour dynamique des couleurs

      #::confColor::applyColor $::bdi_gui_planetes::fen

      return

   }

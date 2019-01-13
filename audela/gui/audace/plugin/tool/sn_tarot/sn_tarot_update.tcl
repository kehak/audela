#
## @file sn_tarot_update.tcl
#  @brief Gère la mise à jour des fichiers
#  @author Alain KLOTZ et Raymond ZACHANTKE
#  $Id: sn_tarot_update.tcl 13439 2016-03-20 11:35:00Z rzachantke $
#  @code source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_update.tcl
#  @endcode
#

#------------------------------------------------------------
## @brief créé la fenêtre "Tarot Supernovae - Mise à jour" lancée
#  - lors du démarrage de l'outil
#  - ou par le bouton "Rafraîchir" du panneau
#
proc ::sn_tarot::updateFiles { } {
   variable This
   global caption panneau

   set w $This.update

   if { [ winfo exists $w ] } { destroy $w }

   #--- Create the toplevel window $This.snvisu
   #--- Cree la fenetre $This.snvisu de niveau le plus haut
   toplevel $w -class Toplevel
   wm title $w $caption(sn_tarot_go,init)
   wm geometry $w "+20+150"
   wm resizable $w 0 0
   wm transient $w $This
   wm protocol $w WM_DELETE_WINDOW "::sn_tarot::cmdCloseUpdate"

   #--- Cree l'etiquette et les radiobuttons
   frame $w.dat -borderwidth 2 -relief raised
   pack $w.dat

   set i 0
   label $w.dat.wait -text $caption(sn_tarot_go,wait)
   grid $w.dat.wait -row $i -column 0 -padx 10 -sticky w
   incr i

   set dir "$panneau(init_dir)"
   set subdir [ file join $dir references ]
   set dssdir [ file join $dir dss ]
   set subdir_zadko [ file join $dir references_zadko ]
   set dssdir_zadko [ file join $dir dss_zadko ]
   #
   set list_of_data [ list folder folder "$dir" calern available "Tarot_Calern" \
      chili available "Tarot_Chili" ref ref refgaltarot.zip \
      refunzip refunzip "$subdir" dss dss dss.zip dssunzip dssunzip "$dssdir" ]
   #
   set list_of_data ""
   lappend list_of_data folder
   lappend list_of_data folder
   lappend list_of_data "$dir"
   lappend list_of_data calern
   lappend list_of_data available
   lappend list_of_data "Tarot_Calern"
   lappend list_of_data chili
   lappend list_of_data available
   lappend list_of_data "Tarot_Chili"
   lappend list_of_data ref
   lappend list_of_data ref
   lappend list_of_data refgaltarot.zip
   lappend list_of_data refunzip
   lappend list_of_data refunzip
   lappend list_of_data "$subdir"
   lappend list_of_data dss
   lappend list_of_data dss
   lappend list_of_data dss.zip
   lappend list_of_data dssunzip
   lappend list_of_data dssunzip
   lappend list_of_data "$dssdir"
   if {$::audace(sn_tarot,ok_zadko)==1} {
      lappend list_of_data zadko
      lappend list_of_data available
      lappend list_of_data "Zadko_Australia"
      lappend list_of_data refzadko
      lappend list_of_data ref
      lappend list_of_data refgalzadko.zip
      lappend list_of_data refzadkounzip
      lappend list_of_data refunzip
      lappend list_of_data "$subdir_zadko"
      lappend list_of_data dsszadko
      lappend list_of_data dss
      lappend list_of_data dss_zadko.zip
      lappend list_of_data dsszadkounzip
      lappend list_of_data dssunzip
      lappend list_of_data "$dssdir_zadko"
   }

   foreach { child lab val } $list_of_data {
      checkbutton $w.dat.$child -text [ format $caption(sn_tarot_go,$lab) $val ] \
         -indicatoron 1 -onvalue 1 -offvalue 0 -state disabled \
         -variable panneau(sn_tarot,ini_$child)
      grid $w.dat.$child -row $i -column 0 -padx 10 -sticky w
      incr i
   }

   frame $w.cmd -borderwidth 2 -relief raised
   pack $w.cmd -fill x

   #--- Create the button 'GO', 'Cancel' and 'Help'
   #--- Cree le bouton 'GO', 'Annuler' and 'Aide'
   foreach { lab cmd } [ list go "::sn_tarot::cmdApplyUpdate" \
      cancel "::sn_tarot::cmdCloseUpdate" hlp "::sn_tarot::snHelp" ] {
      button $w.cmd.but_$lab -text $caption(sn_tarot_go,$lab) \
        -borderwidth 2 -width 8 -command $cmd
      pack $w.cmd.but_$lab -anchor w -padx 5 -pady 5 -side right
   }
   pack configure $w.cmd.but_go -side left

   #--- La fenetre est active
   focus $w.cmd.but_go

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}


#-----------------------------------------------------
## @brief commande du bouton 'Go' de la fenêtre "Tarot Supernovae - Mise à jour"
#  @details exécute les opérations d'initialisation/mise à jour
#
proc ::sn_tarot::cmdApplyUpdate { } {
   variable This
   global audace panneau rep

   set w $This.update

   ::sn_tarot::changeUpdateState disabled

   #--   cree les repertoires s'ils n'existent pas
   set dir $panneau(init_dir)
   set ls [ list archives night dss ]
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend ls references_zadko
      lappend ls dss_zadko
   }
   foreach sub_path $ls {
      set rep($sub_path) [ file join $dir $sub_path ]
      if { ![ file exists $rep($sub_path) ] } {
         file mkdir $rep($sub_path)
      }
   }

   set panneau(sn_tarot,ini_folder) 1
   update ; # pour la mise a jour de la fenetre

   #--
   set ls ""
   lappend ls "Tarot_Calern"    ; lappend ls "$panneau(sn_tarot,Tarot_Calern,url)" ; lappend ls calern
   lappend ls "Tarot_Chili"     ; lappend ls "$panneau(sn_tarot,Tarot_Chili,url)" ; lappend ls chili
   if {$audace(sn_tarot,ok_zadko)==1} {
      lappend ls "Zadko_Australia" ; lappend ls "$panneau(sn_tarot,Zadko_Australia,url)" ; lappend ls zadko
   }
   foreach { prefix url var } $ls {
      ::sn_tarot::inventaire $prefix $url
      set panneau(sn_tarot,ini_$var) 1
      update ; # pour la mise a jour de la fenetre
   }

   #--   si necessaire, telecharge refgaltarot.zip dans archives
   set file [ file join $rep(archives) refgaltarot.zip ]
   if { ![ file exists $file ] } {
      ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) refgaltarot.zip $file
   }
   set panneau(sn_tarot,ini_ref) 1
   update ; # pour la mise a jour de la fenetre

   #--   si necessaire, dezippe refgaltarot.zip
   set panneau(sn_tarot,references) [ file join $dir references ]

   set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,references) *$::conf(extension,defaut) ] ]
   if { $nb == 0 } {
      #--   chemin de unzip.exe
      if { $::tcl_platform(os) == "Linux" } {
         set tarot_unzip unzip
      } else {
         set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
      }
      #--   dezippe refgaltarot.zip
      catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

      #--   change le nom du repertoire en reference
      if {![file exists $panneau(sn_tarot,references)] && [ file exists [ file join $dir refgaltarot ] ] } {
         file rename -force [ file join $dir refgaltarot ] $panneau(sn_tarot,references)
      }
   }
   set panneau(sn_tarot,ini_refunzip) 1

   update ; # pour la mise a jour de la fenetre

   #--   si necessaire, telecharge dss.zip dans archives
   set file [ file join $rep(archives) dss.zip ]
   if { ![ file exists $file ] } {
      ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) dss.zip $file
   }
   set panneau(sn_tarot,ini_ref) 1

   update ; # pour la mise a jour de la fenetre

   #--   si necessaire, dezippe dss.zip
   set panneau(sn_tarot,dss) [ file join $dir .. dss ]

   set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,dss) *$::conf(extension,defaut) ] ]
   if { $nb == 0 } {
      #--   chemin de unzip.exe
      if { $::tcl_platform(os) == "Linux" } {
         set tarot_unzip unzip
      } else {
         set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
      }
      #--   dezippe dss.zip
      catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

   }

   set panneau(sn_tarot,ini_refunzip) 1
   update ; # pour la mise a jour de la fenetre

   if {$audace(sn_tarot,ok_zadko)==1} {

      #--   si necessaire, telecharge refgalzadko.zip dans archives
      set file [ file join $rep(archives) refgalzadko.zip ]
      if { ![ file exists $file ] } {
         ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) refgalzadko.zip $file
      }
      set panneau(sn_tarot,ini_ref) 1
      update ; # pour la mise a jour de la fenetre

      #--   si necessaire, dezippe refgaltarot.zip
      set panneau(sn_tarot,references_zadko) [ file join $dir references_zadko ]

      set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,references_zadko) *$::conf(extension,defaut) ] ]
      if { $nb == 0 } {
         #--   chemin de unzip.exe
         if { $::tcl_platform(os) == "Linux" } {
            set tarot_unzip unzip
         } else {
            set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
         }
         #--   dezippe refgaltarot.zip
         catch { exec $tarot_unzip -u -d $dir $file } ErrInfo

         #--   change le nom du repertoire en reference
         if {![file exists $panneau(sn_tarot,references_zadko)] && [ file exists [ file join $dir refgalzadko ] ] } {
            file rename -force [ file join $dir refgalzadko ] $panneau(sn_tarot,references_zadko)
         }
      }
      set panneau(sn_tarot,ini_refunzip) 1
      update ; # pour la mise a jour de la fenetre

      #--   si necessaire, telecharge dss_zadko.zip dans archives
      set file [ file join $rep(archives) dss_zadko.zip ]
      if { ![ file exists $file ] } {
         ::sn_tarot::downloadFile $panneau(sn_tarot,ohp,url) dss_zadko.zip $file
      }
      set panneau(sn_tarot,ini_ref) 1
      update ; # pour la mise a jour de la fenetre

      #--   si necessaire, dezippe dss_zadko.zip
      set panneau(sn_tarot,dss_zadko) [ file join $dir .. dss ]

      set nb [ llength [ glob -nocomplain -type f -tails -dir $panneau(sn_tarot,dss_zadko) *$conf(extension,defaut) ] ]
      if { $nb == 0 } {
         #--   chemin de unzip.exe
         if { $::tcl_platform(os) == "Linux" } {
            set tarot_unzip unzip
         } else {
            set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
         }
         #--   dezippe dss.zip
         catch { exec $tarot_unzip -u -d $dir $file } ErrInfo
         set panneau(sn_tarot,ini_dss) 1
         update ; # pour la mise a jour de la fenetre
      }
   }

   ::sn_tarot::changeUpdateState normal

   #--   detruit les variables liees a This.update
   unset panneau(sn_tarot,ini_folder) panneau(sn_tarot,ini_calern) \
      panneau(sn_tarot,ini_chili) panneau(sn_tarot,ini_ref) \
      panneau(sn_tarot,ini_refunzip)

   set panneau(sn_tarot,init) 1

   #--   ferme la fenetre de mise a jour
   ::sn_tarot::cmdCloseUpdate
}


#------------------------------------------------------------
## @brief commande du bouton "Annuler" de la fenêtre de "Tarot Supernovae - Mise à jour"
#  @remark si l'utilisateur refuse la mise à jour et s'il existe des archives
#  le panneau est visualisé, sinon l'outil est fermé.
#
proc ::sn_tarot::cmdCloseUpdate { } {
   variable This
   global caption panneau rep

   #--   examine le contenu du répertoire des archives
   set nb [ llength [ glob -nocomplain -type f -tails -dir $rep(archives) *.zip ] ]

   if {$panneau(sn_tarot,init) == "1" || $nb != "0"} {

      #--   Si la mise a jour a eu lieu ou si l'utilisateur refuse la mise a jour
      #     et qu'il existe des archives

      #--   on complete le panneau s'il est vide (premiere passe)
      if {[winfo exists $This.fra1] ==0} {
         ::sn_tarot::tarotBuildIF
      }

      #--- liste les fichiers du dossier archives
      #::sn_tarot::listArchives

      #---  selection des dates disponibles pour le site
      ::sn_tarot::selectSiteDates

      destroy $This.update

   } else {

      #--   si l'utlisateur refuse la mise a jour et si le repertoire des archives est vide,
      #     demande confirmation pour quitter
      set answer [tk_messageBox -title "$caption(sn_tarot_go,attention)" -icon warning \
            -type yesno -message "$caption(sn_tarot_go,quitter)"]

      if {$answer eq "yes"} {

         #--   ferme complètement l'outil
         ::confVisu::stopTool [::confVisu::getToolVisuNo ::sn_tarot] ::sn_tarot

      } else {

         #--   rend la main au panneau de "Tarot Supernovae - Mise à jour"
         return
      }

   }
   update
}

#------------------------------------------------------------
#  brief inhibe/désinhibe les widgets de la fenêtre de "Tarot Supernovae - Mise à jour"
#  param state { normal disabled }
#
proc ::sn_tarot::changeUpdateState { state } {
   variable This

   set w $This.update

   #--   inhibition des widgets
   regsub "$w.dat.wait" [ winfo children $w.dat ] "" children
   set children [ concat $children [ winfo children $w.cmd ] ]
   foreach child $children {
      $child configure -state $state
   }
   update
}

#------------------------------------------------------------
## @brief liste les 100 fichiers zip les plus récents pour le site ;
#  @details invoquée par la proc ::sn_tarot::cmdApplyUpdate
#  @remark peuple la variable panneau(sn_tarot,$prefix) sous forme de liste de dates 20160111 20160110 20160109 20160108 20160107
#  @code
#  exemple ::sn_tarot::inventaire Tarot_Chili "http://tarotchili5.oamp.fr/ros/supernovae/zip"
#  @endcode
#  @param prefix nom du site (Tarot_Chili, Tarot_Calern, etc.)
#  @param url l'url du site de téléchargement
#
proc ::sn_tarot::inventaire { prefix url } {
   global panneau
   global caption rep

   #--   cree la liste des dates specifique a chaque telescope
   lassign [ ::sn_tarot::httpcopy $prefix $url ] error list_zip

   set typetel [lindex [split $prefix _] 0]

   if { $error eq "0" } {

      #--   si connexion reussie
      switch -exact $prefix {
         Tarot_Calern {set home {GPS 6.92353 E 43.75203 1320} }
         Tarot_Chili  {set home {GPS 70.7326 W -29.259917 2398} }
         Zadko_Australia {set home {GPS 115.7140 E -31.3567 50} }
      }

      #--   recherche la date courante et le creneau horaire
      lassign [ ::sn_tarot::prevnight $home ] date day_night

      #--   si la premiere date est la date courante et day_night == Night
      set old [ lindex $list_zip 0 ]_old
      if { [ lindex $list_zip 0 ] > $date && $day_night eq "Night" } {
         #--   propose $date_old.zip au chargement
         set list_zip [ lreplace $list_zip 0 0 $old ]
      } elseif { [ lindex $list_zip 0 ] > $date && $day_night ne "Night" } {
         set file [ file join $rep(archives) $old ]
         if { [ file exists $file ] == 1 } {
            #--   efface le fichier _old dans le fichier archives
            file delete $file
         }
      }

   } else {

      #--   si echec de connexion au site, liste le contenu du dossier archives
      #--   masque refgaltarot
      set repref refgaltarot
      if {$typetel=="Zadko"} {
         set repref refgalzadko
      }
      regsub -all "$repref" [ glob -nocomplain -type f -dir $rep(archives) -tails *.zip ] "" list_archives
      foreach archive $list_archives {
         regexp "${prefix}_(\[0-9\]\{8\})\.zip" $archive match date
         if { [ info exists date ] } {
            lappend list_zip $date
            unset date
         }
      }
      #--   trie la liste par ordre decroissant et garde les 100 premiers
      set list_zip [ lrange [ lsort -decreasing $list_zip ] 0 99 ]

  }
  set panneau(sn_tarot,$prefix) $list_zip
}


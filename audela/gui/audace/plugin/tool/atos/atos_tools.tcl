#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos atos_tools.tcl
#------------------------------------------------------------------
#
# Fichier        : atos_tools.tcl
# Description    : Utilitaires de communcation avec un flux (video ou lot d'image)
# Auteur         : Frederic Vachier
# Mise à jour $Id: atos_tools.tcl 14038 2016-09-12 07:43:30Z jberthier $
#


namespace eval ::atos_tools {

   variable nb_frames
   variable nb_open_frames
   variable cur_idframe
   variable frame_begin
   variable frame_end

   variable scrollbar

   variable traitement

   variable avi_filename
   variable fits_dir
   variable fits_genericname

   variable uncosm_param1 0.8
   variable uncosm_param2 100

   
   #
   # atos_tools::open_flux
   # ouvre un flux
   #
   proc ::atos_tools::open_flux { visuNo } {

      set scrollbar $::atos_gui::frame(scrollbar)

      if { $::atos_tools::traitement == "fits" } {
         ::atos_tools_fits::open_flux $visuNo
      }

      if { $::atos_tools::traitement == "avi" }  {
         ::atos_tools_avi::open_flux $visuNo
      }

      catch {
         $::atos_gui::frame(info_load).status  configure -text "Loaded"
         $::atos_gui::frame(info_load).nbtotal configure -text "$::atos_tools::nb_frames frames"
      }

      catch {
         set bufNo [ visu$visuNo buf ]
         if { [buf$bufNo imageready] == 1 } {
            set autocuts [buf$bufNo autocuts]
            visu$visuNo disp [list [lindex $autocuts 0] [lindex $autocuts 1]]
         }
      }
   
      catch {
         set ::atos_tools::scrollbar 1
         $scrollbar configure -from 1
         $scrollbar configure -to $::atos_tools::nb_frames
         $scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]
         $scrollbar configure -command "::atos_tools::slide $visuNo"
         $scrollbar configure -state normal
         $scrollbar configure -variable ::atos_tools::scrollbar
      }

   }



   #
   # atos_tools::select
   # Selectionne le ou les fichiers a ouvrir
   #
   proc ::atos_tools::select { visuNo } {

      if { $::atos_tools::traitement == "avi" }  {
         ::atos_tools_avi::select $visuNo
         ::atos_tools::open_flux $visuNo
      }

   }



   #
   # atos_tools::quick_prev_image
   # Retour Rapide
   #
   proc ::atos_tools::quick_prev_image { visuNo } {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      if { $::atos_tools::traitement == "fits" } {
         ::atos_tools_fits::quick_prev_image $visuNo
      }

      if { $::atos_tools::traitement == "avi" }  {
         ::atos_tools_avi::quick_prev_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }




   #
   # atos_tools::quick_next_image
   # avance rapide
   #
   proc ::atos_tools::quick_next_image { visuNo } {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      if { $::atos_tools::traitement == "fits" } {
         ::atos_tools_fits::quick_next_image $visuNo
      }

      if { $::atos_tools::traitement == "avi" }  {
         ::atos_tools_avi::quick_next_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }




   #
   # atos_tools::next_image
   # Passe a l image suivante
   #
   proc ::atos_tools::next_image { visuNo {novisu ""}} {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         ::console::affiche_erreur "Error: ::atos_tools::next_image: pas de video (unknown cur_idframe)\n"
         return
      }

      if { $::atos_tools::traitement == "fits" } {
         ::atos_tools_fits::next_image $visuNo $novisu
      }

      if { $::atos_tools::traitement == "avi" }  {
         ::atos_tools_avi::next_image
      }

      if { $novisu == "" } {
         visu$visuNo disp
      }

      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }




   #
   # atos_tools::prev_image
   # Passe a l image precedente
   #
   proc ::atos_tools::prev_image { visuNo } {

      if {![info exists ::atos_tools::cur_idframe]} {
         # Rien a faire car pas de video chargee
         return
      }

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::prev_image $visuNo
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::prev_image
      }

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }



   #
   # se positionne a l'image $idframe
   #
   proc ::atos_tools::set_frame { visuNo idframe } {

      if { $::atos_tools::traitement=="fits" } {
         ::atos_tools_fits::set_frame $visuNo $idframe
      }

      if { $::atos_tools::traitement=="avi" }  {
         ::atos_tools_avi::set_frame $idframe
      }
      visu$visuNo disp
      set ::atos_tools::scrollbar [expr int($::atos_tools::cur_idframe)]
   }



   #
   # selection du frame de debut
   #
   proc ::atos_tools::setmin { } {

      set posmin $::atos_gui::frame(posmin)

      if {[info exists ::atos_tools::cur_idframe]} {
         $posmin delete 0 end
         $posmin insert 0 [expr int($::atos_tools::cur_idframe)]
      }

   }

   #
   # selection du frame de fin
   #
   proc ::atos_tools::setmax { } {

      set posmax $::atos_gui::frame(posmax)

      if {[info exists ::atos_tools::cur_idframe]} {
         $posmax delete 0 end
         $posmax insert 0 [expr int($::atos_tools::cur_idframe)]
      }

   }

   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::atos_tools::crop { visuNo } {

      if {![info exists ::atos_tools::nb_open_frames]} {
         # Rien a faire car pas de video chargee
         return
      }

      set scrollbar $::atos_gui::frame(scrollbar)
      set posmin    $::atos_gui::frame(posmin)
      set posmax    $::atos_gui::frame(posmax)

      set fmin [$posmin get]
      set fmax [$posmax get]

      if { $fmin == "" } { set fmin 1 }
      if { $fmax == "" } { set fmax $::atos_tools::nb_open_frames }

      set ::atos_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::atos_tools::frame_begin $fmin
      set ::atos_tools::frame_end   $fmax
      set ::atos_tools::cur_idframe $fmin

      #::console::affiche_resultat "CROP! \n"
      #::console::affiche_resultat "cur_idframe  $::atos_tools::cur_idframe \n"
      #::console::affiche_resultat "frame_begin  $::atos_tools::frame_begin \n"
      #::console::affiche_resultat "frame_end    $::atos_tools::frame_end   \n"
      #::console::affiche_resultat "nb_frames    $::atos_tools::nb_frames   \n"

      $scrollbar configure -from $fmin
      $scrollbar configure -to $fmax
      $scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]

      ::atos_tools::set_frame $visuNo $fmin

   }




   #
   # redimensionne le flux entre la valeur min et max
   #
   proc ::atos_tools::uncrop { visuNo } {

      if {![info exists ::atos_tools::nb_open_frames]} {
         # Rien a faire car pas de video chargee
         return
      }

      set scrollbar $::atos_gui::frame(scrollbar)
      set posmin    $::atos_gui::frame(posmin)
      set posmax    $::atos_gui::frame(posmax)

      set fmin 1
      set fmax $::atos_tools::nb_open_frames

      set ::atos_tools::nb_frames   [expr int($fmax-$fmin+1)]
      set ::atos_tools::frame_begin $fmin
      set ::atos_tools::frame_end   $fmax
      set ::atos_tools::cur_idframe $fmin

      $scrollbar configure -from $fmin
      $scrollbar configure -to $fmax
      $scrollbar configure -tickinterval [expr $::atos_tools::nb_frames / 5]
      $posmin delete 0 end
      $posmin insert 0 ""
      $posmax delete 0 end
      $posmax insert 0 ""

      visu$visuNo disp
      set ::atos_tools::scrollbar $::atos_tools::cur_idframe

   }




   #
   # atos_tools::slide
   # mouvement de la barre d avancement
   #
   proc ::atos_tools::slide { visuNo idframe } {

      ::atos_tools::set_frame $visuNo [expr int($idframe)]

   }





   #
   # atos_acq::chgdir
   # Ouvre une boite de dialogue pour choisir un nom  de repertoire
   #
   proc ::atos_tools::chgdir { This } {
      global caption
      global cwdWindow
      global audace

      #--- Initialisation des variables a 2 (0 et 1 reservees a Configuration --> Repertoires)
      set cwdWindow(rep_images)      "2"
      set cwdWindow(rep_travail)     "2"
      set cwdWindow(rep_scripts)     "2"
      set cwdWindow(rep_catalogues)  "2"
      set cwdWindow(rep_userCatalog) "2"
      set cwdWindow(rep_archives)    "2"

      set parent "$audace(base)"
      set title "Choisir un repertoire de destination"
      set rep "$audace(rep_images)"

      set numerror [ catch { set filename "[ ::cwdWindow::tkplus_chooseDir "$rep" $title $This ]" } msg ]

      if { $numerror == "1" } {
         set filename "[ ::cwdWindow::tkplus_chooseDir "[pwd]" $title $This ]"
      }

      $This delete 0 end
      $This insert 0 $filename

   }


   proc ::atos_tools::uncosmic { bufNo } {

      buf$bufNo save /dev/shm/a
      set bf [buf::create]
      buf$bf load /dev/shm/a
      buf$bf imaseries "FILTER kernel_width=3 kernel_type=med kernel_coef=$::atos_tools::uncosm_param1"
      buf$bf save /dev/shm/b
      buf$bf load /dev/shm/a
      buf$bf sub /dev/shm/b 0
      buf$bf clipmin $::atos_tools::uncosm_param2
      buf$bf clipmax [expr $::atos_tools::uncosm_param2 + 1]
      buf$bf offset [expr -$::atos_tools::uncosm_param2]
      buf$bf save /dev/shm/dirac
      buf$bf load /dev/shm/b
      buf$bf imaseries "PROD \"file=/dev/shm/dirac\" constant=1"
      buf$bf save /dev/shm/bb

      buf$bf load /dev/shm/a
      buf$bf imaseries "PROD \"file=/dev/shm/dirac\" constant=1"
      buf$bf save /dev/shm/aa

      buf$bf load /dev/shm/a
      buf$bf sub /dev/shm/aa 0
      buf$bf add /dev/shm/bb 0
      buf$bf copyto $bufNo
      buf::delete $bf 

      catch { file delete -force /dev/shm/aa.fit /dev/shm/a.fit /dev/shm/bb.fit /dev/shm/b.fit /dev/shm/dirac.fit }

   }


}

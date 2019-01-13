#
# Fichier : cycle.tcl
# Description : Observation en automatique
# Auteur : FrÃ©dÃ©ric Vachier
# Mise Ã  jour $Id: cycle.tcl 9411 2013-05-05 13:07:31Z fredvachier $
#
# source audace/plugin/tool/acqt1m/cycle.tcl
#

#============================================================
# Declaration du namespace bddimages
#    initialise le namespace
#============================================================
namespace eval ::cycle {

   variable camera
   variable stop



   proc ::cycle::init { } {

      variable private

      ::mycycle::use
   
      set private(object)  $::cycle::object
      set private(ra)      $::cycle::ra 
      set private(dec)     $::cycle::dec
      set private(roue)    $::cycle::roue

      # obturateur = 0 : Ouvert, 1 : Fermer, 2 : Synchro
      set private(obt)            2
      # obturateur = 2 : Serie d'image
      set private(mode)           2
   }






   proc disable_button { visuNo } {

      global panneau

      $panneau(acqt1m,$visuNo,This).pose.but               configure -state disabled
      $panneau(acqt1m,$visuNo,This).pose.entr              configure -state disabled
      $panneau(acqt1m,$visuNo,This).binningt.but           configure -state disabled
      $panneau(acqt1m,$visuNo,This).obt.but                configure -state disabled
      $panneau(acqt1m,$visuNo,This).mode.but               configure -state disabled
      $panneau(acqt1m,$visuNo,This).go_stop.but            configure -state disabled
      $panneau(acqt1m,$visuNo,This).filtre.but             configure -state disabled
      $panneau(acqt1m,$visuNo,This).filtre.filtrecourant   configure -state disabled
      $panneau(acqt1m,$visuNo,This).special.offsetdark     configure -state disabled
      $panneau(acqt1m,$visuNo,This).special.flatautoplus   configure -state disabled
      $panneau(acqt1m,$visuNo,This).special.cyclepose      configure -state disabled
      $panneau(acqt1m,$visuNo,This).special.offsetdark     configure -state disabled

   }






   proc enable_button { visuNo } {

      global panneau

      $panneau(acqt1m,$visuNo,This).pose.but               configure -state normal
      $panneau(acqt1m,$visuNo,This).pose.entr              configure -state normal
      $panneau(acqt1m,$visuNo,This).binningt.but           configure -state normal
      $panneau(acqt1m,$visuNo,This).obt.but                configure -state normal
      $panneau(acqt1m,$visuNo,This).mode.but               configure -state normal
      $panneau(acqt1m,$visuNo,This).go_stop.but            configure -state normal
      $panneau(acqt1m,$visuNo,This).filtre.but             configure -state normal
      $panneau(acqt1m,$visuNo,This).filtre.filtrecourant   configure -state normal
      $panneau(acqt1m,$visuNo,This).special.offsetdark     configure -state normal
      $panneau(acqt1m,$visuNo,This).special.flatautoplus   configure -state normal
      $panneau(acqt1m,$visuNo,This).special.cyclepose      configure -state normal
      $panneau(acqt1m,$visuNo,This).special.offsetdark     configure -state normal

   }






   proc run { visuNo } {

      variable private
      global panneau

      ::console::affiche_resultat "$::caption(cycle,lancement)\n"
      incr ::cycle::go
      
      ::cycle::init

      ::console::affiche_resultat "------------------------\n"
      ::console::affiche_resultat "--Definition du cycle --\n"
      ::console::affiche_resultat "------------------------\n"
      foreach l $private(roue) {

         set panneau(acqt1m,$visuNo,filtrecourant) [lindex $l 0]
         set panneau(acqt1m,$visuNo,pose)          [lindex $l 1]
         set panneau(acqt1m,$visuNo,nb_images)     [lindex $l 2]
         set panneau(acqt1m,$visuNo,bin)           [lindex $l 3]
         set panneau(acqt1m,$visuNo,index) 1

         ::console::affiche_resultat "Image Nb=$panneau(acqt1m,$visuNo,nb_images) Filtre=$panneau(acqt1m,$visuNo,filtrecourant) Expo=$panneau(acqt1m,$visuNo,pose) Bin=$panneau(acqt1m,$visuNo,bin)\n"
      }
      ::console::affiche_resultat "------------------------\n"

      if {$::cycle::go >= 2} {
         ::console::affiche_resultat "Demarrage du cycle \n"
         set ::cycle::go 0
      } else {
         ::console::affiche_resultat "Le prochain clic demarre le cycle \n"
         return
      }

      set ::cycle::stop 0
      
      # Evenement pour la GUI
      ::cycle::disable_button $visuNo
      
      # Lecture des champs de la GUI -> PUSH
      ::console::affiche_resultat "\nPUSH\n"
      ::acqt1m::push_gui $visuNo


      # Modification des champs de la GUI
      ::console::affiche_resultat "\nINITIALISATION DES PARAMETRES\n"
      set panneau(acqt1m,$visuNo,object) $private(object)
      ::console::affiche_resultat "OBJECT=$panneau(acqt1m,$visuNo,object)\n"

      #set panneau(acqt1m,$visuNo,bin) $private(bin)
      #::console::affiche_resultat "BIN=$panneau(acqt1m,$visuNo,bin)\n"

      #set panneau(acqt1m,$visuNo,binning) $private(bin)
      #::console::affiche_resultat "BIN=$panneau(acqt1m,$visuNo,binning)\n"

      set panneau(acqt1m,$visuNo,mode_en_cours) [ lindex $panneau(acqt1m,$visuNo,list_mode) [ expr $private(mode) - 1 ] ]
      ::console::affiche_resultat "MODE_EN_COURS=$panneau(acqt1m,$visuNo,mode_en_cours)\n"

      ::acqt1m::ChangeMode $visuNo $panneau(acqt1m,$visuNo,mode_en_cours)

      set panneau(acqt1m,$visuNo,mode) $private(mode)
      ::console::affiche_resultat "MODE=$panneau(acqt1m,$visuNo,mode)\n"

      set panneau(acqt1m,$visuNo,ra) $private(ra)
      ::console::affiche_resultat "RA=$panneau(acqt1m,$visuNo,ra)\n"

      set panneau(acqt1m,$visuNo,dec) $private(dec)
      ::console::affiche_resultat "DEC=$panneau(acqt1m,$visuNo,dec)\n"

      set panneau(acqt1m,$visuNo,obt) $private(obt)
      ::console::affiche_resultat "OBTURATEUR=$panneau(acqt1m,$visuNo,obt,$panneau(acqt1m,$visuNo,obt))\n"

      ::acqt1m::setShutter $visuNo $panneau(acqt1m,$visuNo,obt)

      # Initialisation de la roue a filtre
      ::console::affiche_resultat "$::caption(cycle,initFiltres)\n"
      ::t1m_roue_a_filtre::initFiltre $visuNo

     ::console::affiche_resultat "\n"

      set panneau(acqt1m,$visuNo,index) 1
      set panneau(acqt1m,$visuNo,verifier_index_depart) 0
      
      while {1==1} {

         foreach l $private(roue) {

            # permet de modifier les temps de pose sans arreter les cycles
            # modifer le code 
            # et recharger les cycles 
            ::cycle::init


            set panneau(acqt1m,$visuNo,filtrecourant) [lindex $l 0]
            set panneau(acqt1m,$visuNo,pose)          [lindex $l 1]
            set panneau(acqt1m,$visuNo,nb_images)     [lindex $l 2]
            set panneau(acqt1m,$visuNo,bin)           [lindex $l 3]
            set panneau(acqt1m,$visuNo,binning)       "[lindex $l 3]x[lindex $l 3]"
            ::acqt1m::changebinning $visuNo   

            #::console::affiche_resultat "index=$panneau(acqt1m,$visuNo,index)\n" 

            ::console::affiche_resultat "Image Nb=$panneau(acqt1m,$visuNo,nb_images) Filtre=$panneau(acqt1m,$visuNo,filtrecourant) Expo=$panneau(acqt1m,$visuNo,pose) Bin=$panneau(acqt1m,$visuNo,bin)\n"

            # Changement du Filtre
            ::t1m_roue_a_filtre::changeFiltreInfini $visuNo

            # Lancement Acquisition
            ::acqt1m::Go $visuNo             
            # Evenement pour la GUI
            ::cycle::disable_button $visuNo

            if {$::cycle::stop == 1 } { break }

         }

         if {$::cycle::stop == 1 } { break }

      }

      ::console::affiche_resultat "\n"



      ::console::affiche_resultat "POP dans 1 sec\n"
      #after 5000
      # Retour sur la GUI d'Origine -> POP
      ::acqt1m::pop_gui $visuNo
      ::console::affiche_resultat "POP effectue\n"

      # Evenement pour la GUI
      ::cycle::enable_button $visuNo

      after 500
      bell
      after 200
      bell
      after 100
      bell
      after 100
      bell
      after 200
      bell
      after 400
      bell
      after 200
      bell

      return

   }

}


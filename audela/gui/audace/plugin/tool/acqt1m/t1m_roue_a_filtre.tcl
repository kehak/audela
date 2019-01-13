#
# Fichier : t1m_roue_a_filtre.tcl
# Description : Pilotage de la roue a filtres du T1m - Observation en automatique
# Camera : Script optimise pour une Andor ikon-L
# Auteur : Frédéric Vachier
# Mise à jour $Id: t1m_roue_a_filtre.tcl 9455 2013-05-15 16:09:25Z robertdelmas $
#
# source audace/plugin/tool/acqt1m/t1m_roue_a_filtre.tcl
#

#============================================================
# Declaration du namespace t1m_roue_a_filtre
#    initialise le namespace
#============================================================
namespace eval ::t1m_roue_a_filtre {



      variable log
      variable stopcpt






   #--- Reboot de la roue : a faire
   proc ::t1m_roue_a_filtre::init_roue { } {

   }



   #--- Procedure d'initialisation de la liste des filtres
   proc ::t1m_roue_a_filtre::init { } {

      ::t1m_roue_a_filtre::init_roue
      set ::t1m_roue_a_filtre::log 0
      set ::t1m_roue_a_filtre::stopcpt 50
   }









   #--- Procedure d'initialisation de la roue a filtres
   proc ::t1m_roue_a_filtre::initFiltre { visuNo } {

      variable private
      global panneau

      ::t1m_roue_a_filtre::init

      #set panneau(acqt1m,$visuNo,filtrelist) "none"
      for { set i 1 } {$i <= 9} {incr i} {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,filtre) [lindex $private(filtre,$i) 2]\n"
         lappend panneau(acqt1m,$visuNo,filtrelist) [lindex $private(filtre,$i) 2]
      }

      set panneau(acqt1m,$visuNo,filtrecourant) [::t1m_roue_a_filtre::getFiltre]
   }













   #--- Procedure de recuperation de filtre
   proc ::t1m_roue_a_filtre::getFiltre { } {
      variable private
      global panneau

      set ::t1m_roue_a_filtre::stopcpt 50


      set passinit "no"
      set passfiltre "no"
      set passclose "no"



      # Initialise la roue a filtres
      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "$::caption(t1m_roue_a_filtre,ouvre_socket)\n"}
      set err [ catch { set tty [open "/dev/ttyS0" r+] } ]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,roueNonInitialise)\n"
         return
      }

      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "getFiltre: fconfigure\n"}
      fconfigure $tty -mode "19200,n,8,1" -buffering none -blocking 0

      # Initialise la roue a filtres
      puts -nonewline $tty "WSMODE"
      set state "reading"
      after 5000 set state "timeout"
      set cpt 0
      while {$state=="reading"} {
         after 100
         set char [read $tty 10]
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WSMODE: $char $state $cpt"}
         if {[lsearch -exact $char "!"] == 0} {
            set passinit "yes"
            break
         }
         incr cpt
         if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
            break
         }
      }
      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WSMODE: $passinit $state\n"}


      # Recupere le filtre courant
      if {$passinit=="yes"} {
         puts -nonewline $tty "WFILTR"
         set state "reading"
         after 5000 set state "timeout"
         set cpt 0
         while {$state=="reading"} {
            after 100
            set char [read $tty 10]
            if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WFILTR: $char"}
            if {[llength $char] == 1} {
               set passfiltre "yes"
               break
            }
            incr cpt
            if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
               break
            }
         }
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WFILTR: $passfiltre $char\n"}
         set idgetfiltre $char
      }

      # Ferme la connexion avec la roue a filtres
      if {$passinit=="yes"} {
         puts -nonewline $tty "WEXITS"
         set state "reading"
         after 5000 set state "timeout"
         set cpt 0
         while {$state=="reading"} {
            after 100
            set char [read $tty 10]
            if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WEXITS: $char"}
            if {[lsearch -exact $char "END"] == 0} {
               set passclose "yes"
               break
            }
            incr cpt
            if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
               break
            }
         }
         close $tty
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WEXITS: $passclose $char\n"}
      }


      set filtre "unknown"
      if {$passfiltre=="yes"} {
         for { set idfiltre 1 } {$idfiltre <= 9} {incr idfiltre} {
            #::console::affiche_resultat "$idfiltre - [lindex $private(filtre,$idfiltre) 2]\n"
            if {$idfiltre==$idgetfiltre} {
               set filtre [lindex $private(filtre,$idfiltre) 2]
               break
            }
         }
      }

      #::console::affiche_resultat "GETFILTRE: Filtre=$filtre (init=$passinit get=$passfiltre close=$passclose) \n"
      return $filtre

   }




















   #--- Procedure de changement de filtre
  proc ::t1m_roue_a_filtre::changeFiltre { visuNo } {
      variable private
      global panneau

      set ::t1m_roue_a_filtre::stopcpt 50

      set passinit "no"
      set passgoto "no"
      set passfiltre "no"
      set passclose "no"
      set pass "no"


      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "$::caption(t1m_roue_a_filtre,changeFiltre) $panneau(acqt1m,$visuNo,filtrecourant)\n"}
      for { set idfiltre 1 } {$idfiltre <= 9} {incr idfiltre} {
         if {[lindex $private(filtre,$idfiltre) 2]==$panneau(acqt1m,$visuNo,filtrecourant)} {
            break
         }
      }

      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "$::caption(t1m_roue_a_filtre,ouvre_socket1)\n"}
      # Initialise la roue a filtres
      set err [ catch { set tty [open "/dev/ttyS0" r+] } ]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,roueNonInitialise)\n\n"
         return
      }

      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "changeFiltre: fconfigure\n"}
      fconfigure $tty -mode "19200,n,8,1" -buffering none -blocking 0

      # Initialise la roue a filtres
      puts -nonewline $tty "WSMODE"
      set state "reading"
      after 5000 set state "timeout"
      set cpt 0
      while {$state=="reading"} {
         after 100
         set char [read $tty 10]
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WSMODE: $char"}
         if {[lsearch -exact $char "!"] == 0} {
            set passinit "yes"
            break
         }
         incr cpt
         if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
            break
         }
      }
      if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WSMODE: $passinit $state\n"}

      # change le filtre
      if {$passinit=="yes"} {
         puts -nonewline $tty "WGOTO$idfiltre"
         set state "reading"
         after 5000 set state "timeout"
         set cpt 0
         while {$state=="reading"} {
            after 100
            set char [read $tty 10]
            if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WGOTO: $char"}
            if {[lsearch -exact $char "*"] == 0} {
               set passgoto "yes"
               break
            }
            incr cpt
            if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
               break
            }
         }
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WGOTO: $passgoto $char\n"}
      }


      # Recupere le filtre courant
      if {$passinit=="yes" && $passgoto=="yes"} {
         puts -nonewline $tty "WFILTR"
         set state "reading"
         after 5000 set state "timeout"
         set cpt 0
         while {$state=="reading"} {
            after 100
            set char [read $tty 10]
            if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WFILTR: $char"}
            if {[llength $char] == 1} {
               set passfiltre "yes"
               break
            }
            incr cpt
            if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
               break
            }
         }
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WFILTR: $passfiltre $char\n"}
         set idgetfiltre $char
      }

      # Ferme la connexion avec la roue a filtres
      if {$passinit=="yes"} {
         puts -nonewline $tty "WEXITS"
         set state "reading"
         after 5000 set state "timeout"
         set cpt 0
         while {$state=="reading"} {
            after 100
            set char [read $tty 10]
            if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WEXITS: $char"}
            if {[lsearch -exact $char "END"] == 0} {
               set passclose "yes"
               break
            }
            incr cpt
            if {$cpt>$::t1m_roue_a_filtre::stopcpt} {
               break
            }
         }
         close $tty
         if {$::t1m_roue_a_filtre::log} {::console::affiche_resultat "WEXITS: $passclose $char\n"}
      }


      if {$passinit=="yes"} {
         if {$passgoto=="yes"} {
            if {$passfiltre=="yes"} {
               if {$passclose=="yes"} {
                  if {$idfiltre == $idgetfiltre} {
                     set pass "yes"
                  }
               }
            }
         }
      }
      if {$pass=="yes"} {
         #::console::affiche_resultat "SETFILTRE: Filtre=$panneau(acqt1m,$visuNo,filtrecourant) (init=$passinit goto=$passgoto get=$passfiltre close=$passclose) \n"
         return "ok"
      } else {
         ::console::affiche_erreur "$::caption(t1m_roue_a_filtre,probleme)\n"
         return "no"
      }




   }












   #--- Procedure de changement de filtre
   proc ::t1m_roue_a_filtre::eventFiltre { } {

      set ::t1m_roue_a_filtre::stopcpt 50

      # Initialise la roue a filtres
      set err [ catch { set tty [open "/dev/ttyS0" r+] } ]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(t1m_roue_a_filtre,roueNonInitialise)\n"
         return
      }

      fconfigure $tty -mode "19200,n,8,1" -buffering none -blocking 0

      # Initialise la roue a filtres
      puts -nonewline $tty "WSMODE"
      set state "reading"
      set pass "no"
      after 5000 set state "timeout"
      while {$state=="reading"} {
         after 100
         set char [read $tty 10]
         ::console::affiche_resultat "WSMODE: $char"
         if {[lsearch -exact $char "!"] == 0} {
            set pass "yes"
            break
         }
      }
      ::console::affiche_resultat "WSMODE: $pass $state\n"


      # Recupere le filtre courant
      puts -nonewline $tty "WFILTR"
      set state "reading"
      set pass "no"
      after 5000 set state "timeout"
      while {$state=="reading"} {
         after 100
         set char [read $tty 10]
         ::console::affiche_resultat "WFILTR: $char"
         if {[llength $char] == 1} {
            set pass "yes"
            break
         }
      }
      ::console::affiche_resultat "WFILTR: $pass $char\n"



      # Ferme la connexion avec la roue a filtres
      puts -nonewline $tty "WEXITS"
      set state "reading"
      set pass "no"
      after 5000 set state "timeout"
      while {$state=="reading"} {
         after 100
         set char [read $tty 10]
         ::console::affiche_resultat "WEXITS: $char"
         if {[lsearch -exact $char "END"] == 0} {
            set pass "yes"
            break
         }
      }
      close $tty
      ::console::affiche_resultat "WEXITS: $pass $char\n"

   }


   #--- Procedure de changement du filtre effectue a l infini
   proc ::t1m_roue_a_filtre::changeFiltreInfini { visuNo } {

      global panneau

      set filtre $panneau(acqt1m,$visuNo,filtrecourant)
      set pass "no"
      for { set i 1 } {$i <= 9} {incr i} {
         if {$filtre == [lindex $::t1m_roue_a_filtre::private(filtre,$i) 2]} {
            set pass "yes"
            break
         }
      }
      if {$pass == "no"} {
         ::t1m_roue_a_filtre::initFiltre $visuNo
         return
      }

      while {1==1} {

         set reschgt [::t1m_roue_a_filtre::changeFiltre $visuNo]

         if {$reschgt=="no"} {

            set resverif [::t1m_roue_a_filtre::verifFiltre $panneau(acqt1m,$visuNo,filtrecourant)]
            ::console::affiche_erreur "VERIF = $resverif\n"

            if {$resverif=="no"} {
               ::t1m_roue_a_filtre::initFiltre $visuNo
               set panneau(acqt1m,$visuNo,filtrecourant) $filtre

            } else {
               break
            }

         } else {
            break
         }

      }

   }


   #--- Procedure de verification du filtre
   proc ::t1m_roue_a_filtre::verifFiltre { filtre } {

      set pass "no"
      set current [::t1m_roue_a_filtre::getFiltre]
      for { set i 1 } {$i <= 9} {incr i} {
         if {$filtre==$current} {
            set pass "yes"
         }
      }
      #::console::affiche_resultat "verifFiltre: $pass ($filtre==$current)\n"

      return $pass
   }










   #--- Procedure de changement de filtre
   proc ::t1m_roue_a_filtre::infoFiltre { visuNo } {
      variable private

      set ::t1m_roue_a_filtre::stopcpt 50

      ::t1m_roue_a_filtre::initFiltre $visuNo
      for { set i 1 } {$i <= 9} {incr i} {
         set line  [format "Nomcourt=%-3s Nom=%-10s sensdebutnuit=%s largeur=%s centre=%s \n" \
            [lindex $private(filtre,$i) 1] \
            [lindex $private(filtre,$i) 2] \
            [lindex $private(filtre,$i) 4] \
            [lindex $private(filtre,$i) 5] \
            [lindex $private(filtre,$i) 6] ]
         ::console::affiche_resultat $line
      }

   }

}


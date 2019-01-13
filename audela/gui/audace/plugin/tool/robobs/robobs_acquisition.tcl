## @file robobs_acquisition.tcl 
#  @brief     Grande boucle d'acquisition/traitement de RobObs
#  @author    Alain Klotz
#  @version   1.0
#  @date      2014
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool robobs robobs_acquisition.tcl]
#  @endcode

# $Id: robobs_acquisition.tcl 14445 2018-06-20 15:09:29Z fredvachier $

#--------------------------------------------------
# source audace/plugin/tool/robobs/robobs_acquisition.tcl
#--------------------------------------------------
#
# Fichier        : robobs_acquisition.tcl
# Description    : Grande boucle d'acquisition/traitement de RobObs
# Auteur         : Alain Klotz
# Mise à jour $Id: robobs_acquisition.tcl 14445 2018-06-20 15:09:29Z fredvachier $
#


##
# @namespace robobs_acquisition
# @brief Espace de nom general pour l'acquisition et le traitement de RobObs
# @pre Requiert des librairies : mysqltcl
# @warning Outil en d&eacute;veloppement
# @todo Ecrire les entetes pour toutes les fonctions
#
namespace eval ::robobs_acquisition {

   global audace
   global robobsconf

   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool robobs robobs_acquisition.cap ]\""

   #--------------------------------------------------
   # run { this }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Creation de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #        this = chemin de la fenetre
   #
   #    variables en sortie :
   #
   #--------------------------------------------------

#------------------------------------------------------------
## Creation de la fenetre
#  @param this chemin de la fenetre
#  @return void
#
   proc ::robobs_acquisition::run { this } {
      variable This

      set This $this
      createDialog
      return
   }

   #--------------------------------------------------
   # fermer { }
   #--------------------------------------------------
   #
   #    fonction  :
   #        Fonction appellee lors de l'appui
   #        sur le bouton 'Fermer'
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::robobs_acquisition::fermer { } {
      variable This

      ::robobs_acquisition::recup_position
      destroy $This
      return
   }

   #--------------------------------------------------
   #  recup_position { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Permet de recuperer et de sauvegarder
   #       la position de la fenetre
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::robobs_acquisition::recup_position { } {
      variable This
      global audace
      global conf
      global robobsconf

      set robobsconf(geometry_status) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $robobsconf(geometry_status) ] ]
      set fin [ string length $robobsconf(geometry_status) ]
      set robobsconf(position_status) "+[ string range $robobsconf(geometry_status) $deb $fin ]"
      #---
      set conf(robobs,position_status) $robobsconf(position_status)
      return
   }

   #--------------------------------------------------
   #  createDialog { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Creation de l'interface graphique
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc ::robobs_acquisition::createDialog { } {

      variable This
      global audace
      global caption
      global color
      global conf
      global robobsconf

      #--- initConf
      if { ! [ info exists conf(robobs,position_status) ] } { set conf(robobs,position_status) "+80+40" }

      #--- confToWidget
      set robobsconf(position_status) $conf(robobs,position_status)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists robobsconf(geometry_status) ] } {
         set deb [ expr 1 + [ string first + $robobsconf(geometry_status) ] ]
         set fin [ string length $robobsconf(geometry_status) ]
         set robobsconf(position_status) "+[ string range $robobsconf(geometry_status) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This $robobsconf(position_status)
      wm resizable $This 1 1
      wm title $This $caption(robobs_acquisition,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::robobs_acquisition::fermer }


      #--- Cree un frame pour afficher le status de la base
      frame $This.frame1 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame1 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un label pour le titre
        label $This.frame1.titre \
              -text "$caption(robobs_acquisition,titre)"
        pack $This.frame1.titre \
             -in $This.frame1 -side top -padx 3 -pady 3

        #--- Cree un label pour le status
        label $This.frame1.status \
              -text "Status: Exit"
        pack $This.frame1.status \
             -in $This.frame1 -side top -padx 3 -pady 3

        label $This.frame1.titre2 \
              -text "$caption(robobs_acquisition,titre2)"
        pack $This.frame1.titre2 \
             -in $This.frame1 -side top -padx 3 -pady 3

#       #--- Gestion du bouton
#       #-$audace(base).robobs.fra5.but1 configure -relief raised -state normal

      #--- Cree un frame pour afficher le status de la base
      frame $This.frame2 -borderwidth 0 -cursor arrow -relief groove
      pack $This.frame2 -in $This -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un bouton
        button $This.frame2.but1 \
              -text "$caption(robobs_acquisition,but1)" -command {::robobs_acquisition::push_button 1}
        pack $This.frame2.but1 \
             -in $This.frame2 -side left -padx 3 -pady 3

        #--- Cree un bouton
        button $This.frame2.but2 \
              -text "$caption(robobs_acquisition,but4)" -command {::robobs_acquisition::push_button 2}
        pack $This.frame2.but2 \
             -in $This.frame2 -side left -padx 3 -pady 3

        #--- Cree un bouton
        button $This.frame2.but3 \
              -text "$caption(robobs_acquisition,but5)" -command {::robobs_acquisition::push_button 3}
        pack $This.frame2.but3 \
             -in $This.frame2 -side left -padx 3 -pady 3

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { $audace(console)::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
      $This.frame1.titre configure -font $robobsconf(font,arial_12_b)

   }

   proc ::robobs_acquisition::push_button {action} {
      variable This
      global audace
      global caption
      global color
      global conf
      global robobsconf
      if {$action==1} {
         # Start/Continu | Pause
         if {[::robobs_acquisition::signal_loop]=="Exit"} {
            ::robobs::ressource
            ::robobs_config::disp
            ::robobs::verbose 5
            $This.frame2.but1 configure -text "$caption(robobs_acquisition,but2)"
            ::robobs_acquisition::start_loop
         } else {
            if {[::robobs_acquisition::signal_loop]==0} {
               $This.frame2.but1 configure -text "$caption(robobs_acquisition,but3)"
               ::robobs_acquisition::stop_loop
            } else {
               $This.frame2.but1 configure -text "$caption(robobs_acquisition,but2)"
               ::robobs_acquisition::continue_loop
            }
         }
      }
      if {$action==2} {
         # Step
         if {[::robobs_acquisition::signal_loop]=="Exit"} {
         } else {
            ::robobs_acquisition::step_loop
         }
      }
      if {$action==3} {
         # Exit
         if {[::robobs_acquisition::signal_loop]=="Exit"} {
            ::robobs_acquisition::fermer
         } else {
            ::robobs_acquisition::exit_loop
            $This.frame2.but1 configure -text "$caption(robobs_acquisition,but1)"
         }
      }

   }

   #------------------------------------------------------------
   # start_loop
   #    Entre dans la boucle d'acquisition (c'est le coeur de robobs)
   #------------------------------------------------------------
   proc ::robobs_acquisition::start_loop {} {

      global robobs
      global caption
      global audace
      global robobsconf
      global conf

      if {$robobs(conf,home,telescope_id,value)=="makes_t60"} {
         set command "USE `t60`"      
         set err [catch {
            ::robobs::log "Verify connection Mysql"
            if {[info commands ::bddimages_sql::sql]==""} {
               ::bddimages::ressource
            }
            package require mysqltcl
            set res [::bddimages_sql::sql connect $robobs(conf_planif,vachier_berthier,sql_host) $robobs(conf_planif,vachier_berthier,sql_user) $robobs(conf_planif,vachier_berthier,sql_pass)]
            ::bddimages_sql::sql query $command
            ::bddimages_sql::sql disconnect
         } msg]
         if {$err==1} {
            ::robobs::log "ERROR MySQL : $msg"
            ::robobs::log "SQL command = $command"
            ::robobs::log "Verify connection Mysql ERROR" 0 #FF0000
         } else {
            ::robobs::log "Verify connection Mysql OK" 0 #00AA00
         }
      }
      
      ::robobs::log "Enter in the acquisition loop"
      if {[::robobs_acquisition::signal_loop]!="Exit"} {
         error "Loop ever in use (signal [::robobs_acquisition::signal_loop])"
      }
      ::robobs_acquisition::signal_loop 0
      ::robobs_acquisition::state_loop "Enter"
      set robobs(signal_loop) 0

      while {1==1} {

         after 250 ; update
         ::robobs_config::update
         ::robobs_planif::update

         set item loopscripts
         set steps $robobs(conf,$item,descr)

         foreach step $steps {

            # === Beginning of script
            #set robobs(state_loop) "$step"
            ::robobs_acquisition::state_loop "$step"
            ::robobs::log "$caption(robobs,start_script) RobObs $step" 40

            # === Check for a personal script if it exists
            set fic $robobs(conf,folders,rep_personal_robobs,value)/loopscript_${step}.tcl
            if {[file exists $fic]==0} {
               set fic $audace(rep_install)/gui/audace/plugin/tool/robobs/loopscript_${step}.tcl
            }

            # === Launch the script if it exists
            if {[file exists $fic]==1} {
               ::robobs::log "$caption(robobs,start_script) $fic found" 45
               # === Start script
               set errscript [catch { source $fic } msgscript ]
               if {$errscript==1} {
                  ::robobs::log "$caption(robobs,exit_script) $step ERROR $msgscript"
               }
               # === End of script
               ::robobs::log "$caption(robobs,exit_script) RobObs $fic" 45
            } else {
               ::robobs::log "$caption(robobs,start_script) $fic not found !!!" 30
            }

            # === Check for a stop signal
            if {[::robobs_acquisition::signal_loop]==2} {
               ::robobs::log "Loop stopped at the end of $step"
               while {[::robobs_acquisition::signal_loop]==2} {
                  update
                  after 2000
               }
               if {[::robobs_acquisition::signal_loop]==3} {
                  ::robobs_acquisition::signal_loop 2
               }
               ::robobs::log "Loop continuation"
            }

            # === Check for a premature signal to exit the steps
            if {[::robobs_acquisition::signal_loop]==1} {
               ::robobs::log "Aborting steps"
               break
            }
            update

         }

         # === Check for a premature signal to exit the steps
         if {[::robobs_acquisition::signal_loop]==1} {
            ::robobs::log "Aborting loop"
            break
         }
         update

      }

      set robobs(state_loop) "Outside the loop"
      ::robobs::log "Exit the acquisition loop"
      ::robobs_acquisition::signal_loop "Exit"
      return ""
   }

   #------------------------------------------------------------
   # signal_loop
   #    Retourne ou met a jour le signal de la boucle d'acquisition
   #
   #------------------------------------------------------------
#------------------------------------------------------------
## Retourne ou met a jour le signal de la boucle d'acquisition
#  le signal se retrouve aussi dans la variable globale robobs(signal_loop)
#
#  Valeur d entree => Action
#  Action = 0 : 
#  Action = 1 : 
#  Action = 2 : 
#
#  Valeur de retour => Etat
#  Etat = "Exit" : 
#  Etat = 1 : 
#  Etat = 2 : 
#  Etat = 3 : 
#
#  @param actions signal de boucle, parametre optionnel
#  @return etat
#
   proc ::robobs_acquisition::signal_loop { {actions ""} } {
      global audace panneau caption robobs robobsconf
      variable This
      if {[info exists robobs(signal_loop)]==0} {
         set robobs(signal_loop) "Exit"
      } else {
         if {$actions!=""} {
            set robobs(signal_loop) $actions
         }
      }
      $This.frame1.titre2 configure -text "$caption(robobs_acquisition,titre2) $robobs(signal_loop)"

      return $robobs(signal_loop)
   }

   #------------------------------------------------------------
   # continue_loop
   #    Reprend la boucle d'acquisition
   #------------------------------------------------------------
   proc ::robobs_acquisition::continue_loop {} {
      global robobs
      global caption
      global audace
      global robobsconf

      if {$robobs(signal_loop)!="Exit"} {
         ::robobs_acquisition::signal_loop 0
         ::robobs::log "Continue loop signal received."
      }

   }

   #------------------------------------------------------------
   # exit_loop
   #    Active le signal de sortie de la boucle d'acquisition
   #------------------------------------------------------------
   proc ::robobs_acquisition::exit_loop {} {
      global robobs
      global caption
      global audace
      global robobsconf

      if {$robobs(signal_loop)!="Exit"} {
         ::robobs_acquisition::signal_loop 1
         ::robobs::log "Exit loop signal received."
      }

   }

   #------------------------------------------------------------
   # stop_loop
   #    Active le signal d'arret de la boucle d'acquisition
   #------------------------------------------------------------
   proc ::robobs_acquisition::stop_loop {} {
      global robobs
      global caption
      global audace

      if {$robobs(signal_loop)!="Exit"} {
         ::robobs_acquisition::signal_loop 2
         ::robobs::log "Stop loop signal received."
      }

   }

   #------------------------------------------------------------
   # step_loop
   #    Reprend la boucle d'acquisition en mode pas a pas
   #------------------------------------------------------------
   proc ::robobs_acquisition::step_loop {} {
      global robobs
      global caption
      global audace
      global robobsconf

      if {$robobs(signal_loop)!="Exit"} {
         ::robobs_acquisition::signal_loop 3
         ::robobs::log "Step loop signal received."
      }

   }

   #------------------------------------------------------------
   # state_loop
   #    Retourne l'etat de la boucle d'acquisition
   #
   #------------------------------------------------------------
   proc ::robobs_acquisition::state_loop { {actions ""} } {
      global audace panneau caption robobs robobsconf
      variable This
      if {[info exists robobs(state_loop)]==0} {
         set robobs(state_loop) "Outside the loop"
      }
      if {$actions==""} {
         set actions
      } else {
         set robobs(state_loop) $actions
      }
      catch {$This.frame1.status configure -text "Status: $robobs(state_loop)"}
      update
      return $robobs(state_loop)
   }

}


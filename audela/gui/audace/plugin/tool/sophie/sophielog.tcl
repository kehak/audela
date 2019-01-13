#
## @file     sophielog.tcl
#  @brief    Fichier du namespace ::sophie::log
#  @author   Michel PUJOL et Robert DELMAS
#  $Id: sophielog.tcl 13349 2016-03-11 14:45:52Z rzachantke $

## namespace sophie::log
#  @brief écriture de messages de log
#
namespace eval ::sophie::log {

}

#------------------------------------------------------------
# startLogFile
#    demarrage et gestion du fichier de log
#------------------------------------------------------------
proc ::sophie::log::startLogFile { visuNo } {
   #--- Creation du nom de fichier log
   set nom_generique "guidage-sophie-"
   #--- Heure a partir de laquelle on passe sur un nouveau fichier de log
   if { $::conf(rep_images,refModeAuto) == "0" } {
      set heure_nouveau_fichier "0"
   } else {
      set heure_nouveau_fichier "12"
   }
   set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
   if { $heure_courante < $heure_nouveau_fichier } {
      #--- Si on est avant l'heure de changement, je prends la date de la veille
      set formatdate [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y-%m-%d" ]
   } else {
      #--- Sinon, je prends la date du jour
      set formatdate [ clock format [ clock seconds ] -format "%Y-%m-%d" ]
   }
   set file_log ""
   set ::sophie::log::fichier_log [ file join $::audace(rep_images) [ append $file_log $nom_generique $formatdate ".log" ] ]

   #--- Ouverture du fichier de log
   if { [ catch { open $::sophie::log::fichier_log a } ::sophie::log::log_id ] } {
      writeLogFile $visuNo console $::caption(sophie,pbouvfichcons)
      tk_messageBox -title $::caption(sophie,pb) -type ok \
         -message $::caption(sophie,pbouvfich)
      #--- Note importante : Je detecte si j'ai un pb a l'ouverture du fichier, mais je ne sais pas traiter ce cas :
      #--- Il faudrait interdire l'ouverture de l'outil, mais le processus est deja lance a ce stade...
      #--- Tout ce que je fais, c'est inviter l'utilisateur a changer d'outil !
   } else {
      #--- En-tete du fichier
      writeLogFile $visuNo log $::caption(sophie,ouvsess) [ package version sophie ]
      set date [ clock format [ clock seconds ] -format "%A %d %B %Y" ]
      set date [ ::tkutil::transalteDate $date ]
      set heure $::audace(tu,format,hmsint)
      writeLogFile $visuNo log $::caption(sophie,affheure) $date $heure
   }
}

#------------------------------------------------------------
# stopLogFile
#    arret du fichier de log
#------------------------------------------------------------
proc ::sophie::log::stopLogFile { visuNo } {
   variable private

   #--- Fermeture du fichier de log
   if { [ info exists ::sophie::log::log_id ] } {
      set heure $::audace(tu,format,hmsint)
      #--- Je m'assure que le fichier se termine correctement, en particulier pour le cas ou il y
      #--- a eu un probleme a l'ouverture (c'est un peu une rustine...)
      if { [ catch { writeLogFile $visuNo log $::caption(sophie,finsess) $heure } bug ] } {
         writeLogFile $visuNo console $::caption(sophie,pbfermfichcons)
      } else {
         writeLogFile $visuNo console "\n"
         close $::sophie::log::log_id
         unset ::sophie::log::log_id
      }
   }
   #--- Re-initialisation de la session
   set private(session_ouverture) "1"
}

#------------------------------------------------------------
# writeLogFile
#    affichage de differents messages (dans la Console, le
#    fichier log, etc.)
#------------------------------------------------------------
proc ::sophie::log::writeLogFile { visuNo niveau args } {
   switch -exact -- $niveau {
      console {
         ::console::disp [eval [concat {format} $args]]
         update idletasks
      }
      log {
         set temps [ clock format [ clock seconds ] -format %H:%M:%S ]
         append temps " "
         catch {
            puts -nonewline $::sophie::log::log_id [ eval [ concat {format} $args ] ]
            #--- Force l'ecriture immediate sur le disque
            flush $::sophie::log::log_id
         }
      }
      consolog {
         ::console::disp [ eval [ concat {format} $args ] ]
         update idletasks
         set temps [ clock format [ clock seconds ] -format %H:%M:%S ]
         append temps " "
         catch {
            puts -nonewline $::sophie::log::log_id [ eval [ concat {format} $args ] ]
            #--- Force l'ecriture immediate sur le disque
            flush $::sophie::log::log_id
         }
      }
      default {
         set b [ list "%s\n" $::caption(sophie,pbmesserr) ]
         ::console::disp [ eval [ concat {format} $b ] ]
         update idletasks
      }
   }
}


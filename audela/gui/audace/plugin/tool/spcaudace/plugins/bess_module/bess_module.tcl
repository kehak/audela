#####################################################################
#
# Fichier     : bess_module.tcl
# Description : Script pour générer un fichier FITS de spectre conforme à la base de données bess
# Auteurs     : François Cochard (francois.cochard@wanadoo.fr)
#               Sur la forme, je suis parti du script calaphot de Jacques Michelet (jacques.michelet@laposte.net)
#               Par ailleurs, je m'appuie sur les routines spc_audace de Benjamin Mauclaire
#
#####################################################################


# Mise à jour $Id: bess_module.tcl 11145 2014-11-19 18:01:00Z bmauclaire $


# Bugs à corriger :
# - Permettre l'accès à la routine aussi bien en standalone (script) que par une ligne de cde avec nom de fichier en argument
# - Virer les appels à consolog: pas besoin de générer un fichier de log !
# - Le message "fin normale du script arrive trop tôt dans la console
# - Ajouter des coches pour les traitements (tell; helio, norm...)
# - Bug : Permettre de mettre des # dans les champs prédefinis
# - Bug "affichage fin ANTICIPEE du script..."
# - Demander confirmation avant d'écraser le fichier...
# - Tenir compte du fait que la vitesse héliocentrique est optionnelle
# - Ajouter la correction tellurique, la normalisation, la vitesse helio
# - Recharger dynamiquement le fichier des prédéfinis

# Définition d'un espace réservé à ce script
catch {namespace delete ::bess}
namespace eval ::bess {
   variable police
   global audace audela

   set fich_in ""
   set numero_version v0.2

   if {$tcl_platform(os)!="Linux"} {
      set police(gras)     [font actual .audace]
      set police(italique) [font actual .audace]
      set police(normal)   [font actual .audace]
      set police(titre)    [font actual .audace]
   } else {
      set police(gras)     {helvetica 9 bold}
      set police(italique) {helvetica 9 italic}
      set police(normal)   {helvetica 9 normal}
      set police(titre)    {helvetica 11 bold}
   }

   if { [regexp {1.3.0} $audela(version) match resu ] } {
      set repspc [ file join $audace(rep_scripts) spcaudace ]
      source [file join $repspc plugins bess_module bess_module.cap]
      source [file join $repspc spc_io.tcl]
   } else {
      set repspc [ file join $audace(rep_plugin) tool spcaudace ]
      source [file join $repspc plugins bess_module bess_module.cap]
      source [file join $repspc spc_io.tcl]
   }

   #*************************************************************************#
   #*************  Principal  ***********************************************#
   #*************************************************************************#
   # Lancement de l'interface
   proc Principal { fich_in } {
      LitFichesBeSSPredefinies
      ChargeFichier $fich_in
      EditeParametres $fich_in
   }

   #*************************************************************************#
   #*************  AnnuleSaisie  ********************************************#
   #*************************************************************************#
   proc AnnuleSaisie { } {
      global audace

      destroy $audace(base).saisie
      update idletasks
   }

   #*************************************************************************#
   #*************  Message  *************************************************#
   #*************************************************************************#
   proc Message { niveau args } {
      variable test
      variable fileId
      global audace

      switch -exact -- $niveau {
         console {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
         }
         log {
            puts -nonewline $fileId [eval [concat {format} $args]]
         }
         consolog {
            ::console::disp [eval [concat {format} $args]]
            update idletasks
            catch {puts -nonewline $fileId [eval [concat {format} $args]]}
         }
         test {
            ::console::affiche_erreur [eval [concat {format} $args]]
            update idletasks
         }
      }

      if {[info exists test]} {
         if {[catch {open [file join $audace(rep_images) debug.log] a} filetest]} {
            message console $filetest
            return
         } else {
            puts -nonewline $filetest [eval [concat {format} $args]]
            close $filetest
         }
      }
   }

   #*************************************************************************#
   #*************  LitFichesBeSSPredefinies  **********************************#
   #*************************************************************************#
   # Lit les noms prédéfinis pour les sites, les instruments et les observateurs
   proc LitFichesBeSSPredefinies { } {
      variable parametres
      variable liste_instrument
      variable liste_site
      variable liste_observer
      global audace

      set motcle ""
      set valeur ""

      # Initialisation
      if {[info exists liste_instrument]} {unset liste_instrument}
      if {[info exists liste_site]}       {unset liste_site}
      if {[info exists liste_observer]}   {unset liste_observer}

      # Ouverture du fichier de paramètres
      set fichier [file join $::audace(rep_home) BeSSParam.ini]

      if { ! [file exists $fichier] } {
         # Creation du fichier s'il n'existe pas
         if [ catch { open $fichier w } file ] {
         } else {
            puts $file "# Fichier de configuration pour le panneau Spectres BeSS."
            puts $file "#"
            puts $file "# Syntaxe : Chaque ligne débute par un mot clé, encadré par des crochets."
            puts $file "# Ce mot clé est suivi par un champ de données (valeur ou texte) correspondant à ce mot clé."
            puts $file "# Tout ce qui suit le symbole # dans une ligne est ignoré.\n\n"
            puts $file "\[observer\] Benjamin MAUCLAIRE"
            puts $file "\[observer\] Votre nom"
            puts $file "\[observer\] Un autre nom"
            puts $file "\[site\] O.V.A. (Observatoire du Val de l'Arc)"
            puts $file "\[site\] Chez vous"
            puts $file "\[site\] Ailleurs..."
            puts $file "\[instrument\] LHIRES3#073-2400-SCT0.3m-AudineKAF1602E"
            puts $file "\[instrument\] Votre instrument"
            puts $file "\[instrument\] Un autre instrument"
            close $file
         }
      }
      # On ouvre le fichier BeSSParam.ini
      set fileID [open $fichier r]
      # Et on lit chaque ligne
      while {[eof $fileID] == 0} {
         gets $fileID ligne
        # Message console "%s - eof %s\n" $ligne [eof $fileID]
         if {[BalayageLigne $ligne] == 0} {
            lappend liste_$motcle $valeur
         }
      }
      close $fileID

      if { ! [info exists liste_instrument] } { set liste_instrument [ list "" ] }
      if { ! [info exists liste_site] }       { set liste_site       [ list "" ] }
      if { ! [info exists liste_observer] }   { set liste_observer   [ list "" ] }
   }

#*******************************************************************************

   proc BalayageLigne { ligne } {
      # Passage des parametres de retour (mot cle et valeur)
      upvar motcle motcle
      upvar valeur valeur

      # Nettoyage des characteres <espace> en trop
      set ligne [string trim $ligne]

      # Cas de la ligne de commentaires (ignorée)
      if {[string first \# $ligne] == 0} {
         return -2
      }

      # Isolement du mot cle
      set cg [string first \[ $ligne]
      set cd [string first \] $ligne]
      # Erreurs de syntaxe
      if {($cg<0 && $cd>=0) || ($cg>=0 && $cd<0)} {
         return -1
      }
      set motcle [string tolower [string range $ligne [expr $cg+1] [expr $cd-1]]]

      # Isolement de la valeur associée, et nettoyage des caractères <espace> résiduels
      set valeur [string trim [string range $ligne [expr $cd+1] end]]
      if {[string length $valeur] == 0} {
         return -3
      }
      return 0
   }

   #*************************************************************************#
   #*************  ChargeFichier  ********************************************#
   #*************************************************************************#
   # Va chercher les mots-clé fits dans le header du fichier sélectionné
   proc ChargeFichier { fich_in } {
      # On procède par étapes:
      # - On regarde le format du fichier, et on convertit si besoin
      # - On lit le header pour initialiser les variables
      # - On duplique les données du header pour en garder trace
      variable parametres
      variable parametresOld
      variable fich_out
      global audace

      if { $fich_in == ""} {

         foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM obs1 obs2 obs3 datedeb heuredeb BSS_ESRP BSS_SRPW } {
            set parametres($motcle) ""
         }
        # return

      } else {

         # On regarde le format du fichier et on le convertit si besoin
         set racine [file tail [file rootname $fich_in]]
         set ::bess::fich_in $racine
         set fich_out "bess_$racine"

         switch [file extension $fich_in] {
            ".dat" {
               spc_dat2fits $racine.dat
               buf$audace(bufNo) load [file join $audace(rep_images) $racine ]
            }
            ".spc" {
               spc_spc2fits $racine.spc
               buf$audace(bufNo) load [file join $audace(rep_images) $racine]
               # Corriger: virer l'extension _spc à la création du fichier (cf Benjamin)
            }
            ".fit" {
               # On se contente de charger le fichier
               buf$audace(bufNo) load [file join $audace(rep_images) $fich_in]
              # Message console "Je charge %s - Ok\n" [file join $audace(rep_images) $fich_in]
            }
            "" {
               # On se contente de charger le fichier
               buf$audace(bufNo) load [file join $audace(rep_images) $fich_in]
              # Message console "Je charge en FIT %s - Ok\n" [file join $audace(rep_images) $fich_in]
            }
            default {
              # break
            }
         }


         #-- Importe le contenu de mots clef SPC_ :
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         #- Normalisation :
         if { [ lsearch $listemotsclef "SPC_NORM" ] != -1 } {
            set method_norma [ lindex [ buf$audace(bufNo) getkwd "SPC_NORM" ] 1 ]
            if { $method_norma=="none    " } {
               buf$audace(bufNo) setkwd [ list "BSS_NORM" "none" string "Process used for transforming the continuum" "" ]
            } else {
               buf$audace(bufNo) setkwd [ list "BSS_NORM" "$method_norma" string "Process used for transforming the continuum" "" ]
            }
         } else {
            buf$audace(bufNo) setkwd [ list "BSS_NORM" "none" string "Process used for transforming the continuum" "" ]
         }

         #- Correction des cosmics :
         if { [ lsearch $listemotsclef "SPC_COSM" ] != -1 } {
            set method_cosmics [ lindex [ buf$audace(bufNo) getkwd "SPC_COSM" ] 1 ]
            if { $method_cosmics=="none    " } {
               buf$audace(bufNo) setkwd [ list "BSS_COSM" "none" string "Cosmics correction method" "" ]
            } else {
               buf$audace(bufNo) setkwd [ list "BSS_COSM" "$method_cosmics" string "Cosmics correction method" "" ]
            }
         } else {
            buf$audace(bufNo) setkwd [ list "BSS_COSM" "none" string "Cosmics correction method" "" ]
         }

         #- Pouvoir de resolution :
         if { [ lsearch $listemotsclef "SPC_RESP" ] != -1 } {
            set respow [ lindex [ buf$audace(bufNo) getkwd "SPC_RESP" ] 1 ]
            set reslon [ lindex [ buf$audace(bufNo) getkwd "SPC_RESL" ] 1 ]
            buf$audace(bufNo) setkwd [ list "BSS_ESRP" $respow float "Power of resolution at wavelength BSS_RESW" "" ]
            buf$audace(bufNo) setkwd [ list "BSS_SRPW" $reslon float "Wavelength where BSS_ESRP was measured" "Angstrom" ]
         }

         # On liste les mots-clé BeSS
         foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM BSS_ESRP BSS_SRPW } {
            set ligne [buf$audace(bufNo) getkwd $motcle]
           # Message console "mot cle - %s - %s\n" $motcle [lindex $ligne 1]
             set parametres($motcle) [lindex $ligne 1]
         }
         # Sépare le champ DATE-OBS
         set parametres(datedeb)  [lindex [split $parametres(DATE-OBS) T] 0]
         set parametres(heuredeb) [lindex [split $parametres(DATE-OBS) T] 1]

         # Sépare le champ Observer en 3 noms
         set parametres(obs1) [string trim [lindex [split $parametres(OBSERVER) ,] 0]]
         set parametres(obs2) [string trim [lindex [split $parametres(OBSERVER) ,] 1]]
         set parametres(obs3) [string trim [lindex [split $parametres(OBSERVER) ,] 2]]

      # On garde trace des éléments du header - On n'enregistrera que ceux qui sont modifiés
      }
      if {[info exists parametresOld]} {unset parametresOld}
      foreach indice [array names parametres] {
         set parametresOld($indice) $parametres($indice)
      }
   }

   #*************************************************************************#
   #*************  SelectFile  **********************************************#
   #*************************************************************************#
   # Ouvre un menu de sélection de fichier
   proc SelectFile { } {
      global audace

      set nomFichier [tk_getOpenFile -filetypes { { {FIT} {.fit} } { {DAT} {.dat} } { {SPC} {.spc} } } -initialdir $audace(rep_images)]
      set nomFichier [file tail $nomFichier]
      set ::bess::fich_in [file tail $nomFichier]
      ChargeFichier $nomFichier
  }

   #*************************************************************************#
   #*************  EditeParametres  ****************************************#
   #*************************************************************************#
   proc EditeParametres { fich_in } {
      variable parametres
      variable police
      variable liste_instrument
      variable liste_site
      variable liste_observer
      global audace caption color

      variable bess_export_fg
      set bess_export_fg #ECE9D8

      variable bess_entry_fg
      set bess_entry_fg $color(white)

      # Ferme la fenetre si elle est deja ouverte
      if [ winfo exists $audace(base).saisie ] {
         ::bess::AnnuleSaisie
      }

      # Provisioire (debug)
     # Message console "fichier - %s - Ok (editeur)\n" $fich_in

      # Construction de la fenêtre des paramètres
      toplevel $audace(base).saisie -borderwidth 2 -relief groove -bg $bess_export_fg
      # wm geometry $audace(base).saisie 670x570+120+50
      wm geometry $audace(base).saisie 746x589+285-17
      # 585x590+120+50
      #
      wm title $audace(base).saisie $caption(titre_saisie)
      wm protocol $audace(base).saisie WM_DELETE_WINDOW ::bess::AnnuleSaisie

      # Construction du canevas qui va contenir toutes les trames et des ascenseurs
      set c [canvas $audace(base).saisie.canevas]

      # Construction d'une trame qui va englober toutes les listes dans le canevas
      set t [frame $c.t]
      $c create window 0 0 -anchor nw -window $t

      # Trame du titre
      if { 1==0 } {
         frame $t.trame0 -borderwidth 5 -relief groove -bg $bess_export_fg
         label $t.trame0.titre \
            -font [ list {Arial} 16 bold ] -text $caption(titrePanneau) \
            -borderwidth 0 -relief flat -bg $bess_export_fg  \
            -fg $color(blue_pad)
        # label $t.trame0.titre -text $caption(titrePanneau) -font {helvetica 16 bold} -justify center -fg $color(blue_pad) -bg $bess_export_fg
         pack $t.trame0.titre -in $t -fill x -side top -pady 15
        # pack $t.trame0.titre -side top -fill both -expand true
      }

      #--------------------------------------------------------------------------------
      # Trame du nom des fichier à éditer et de sortie
      frame $t.trame1 -borderwidth 5 -relief groove -bg $bess_export_fg

      label $t.trame1.titre -text $caption(titrePanneau) -font {helvetica 16 bold} -justify center -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame1.titre -in $t.trame1 -columnspan 2 -sticky w

      label $t.trame1.l1 -text $caption(fich_in) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      entry $t.trame1.e1 -textvariable ::bess::fich_in -font $police(normal) -relief sunken -bg $bess_entry_fg
      button $t.trame1.b1 -text $caption(SelecFile) -command {::bess::SelectFile} -font $police(titre) -bg $bess_export_fg
      button $t.trame1.b2 -text $caption(ChargeFichier) -command {::bess::ChargeFichier $::bess::fich_in} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame1.l1 $t.trame1.e1 $t.trame1.b1 $t.trame1.b2

      label $t.trame1.l2 -text $caption(fich_out) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      entry $t.trame1.e2 -textvariable ::bess::fich_out -font $police(normal) -relief sunken -bg $bess_entry_fg
      grid $t.trame1.l2 $t.trame1.e2

      pack $t.trame1 -side top -fill both -expand true

      #--------------------------------------------------------------------------------
      # Trame des renseignements généraux
      frame $t.trame2 -borderwidth 5 -relief groove -bg $bess_export_fg
     # label $t.trame2.titre -text $caption(param_generaux) -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      label $t.trame2.opt -text $caption(optionnel) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
      grid $t.trame2.opt -in $t.trame2 -columnspan 3 -sticky e

      foreach champ {OBJNAME BSS_RA BSS_DEC datedeb heuredeb EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_COSM BSS_ESRP BSS_SRPW } {
         label $t.trame2.l$champ -text $caption($champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         entry $t.trame2.e$champ -textvariable ::bess::parametres($champ) -font $police(normal) -relief sunken -bg $bess_entry_fg
         label $t.trame2.lb$champ -text $caption(u_$champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         grid $t.trame2.l$champ $t.trame2.e$champ $t.trame2.lb$champ
      }

      set liste_BSS_INST $liste_instrument
      set liste_BSS_SITE $liste_site
      set liste_obs1 $liste_observer
      set liste_obs2 $liste_observer
      set liste_obs3 $liste_observer

      foreach champ {BSS_INST BSS_SITE obs1 obs2 obs3} {
         set liste [set liste_$champ]
         label $t.trame2.l$champ -text $caption($champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         ComboBox $t.trame2.e$champ -textvariable ::bess::parametres($champ) -font $police(normal) -relief sunken -values $liste
         label $t.trame2.lb$champ -text $caption(u_$champ) -font $police(gras) -fg $color(blue_pad) -bg $bess_export_fg
         grid $t.trame2.l$champ $t.trame2.e$champ $t.trame2.lb$champ
      }
      pack $t.trame2 -side top -fill both -expand true

      #--------------------------------------------------------------------------------
      # Trame des boutons. Ceux-ci sont fixes (pas d'ascenseur).
      frame $t.trame3 -borderwidth 5 -relief groove -bg $bess_export_fg

      button $t.trame3.b1 -text $caption(enregistrer) -command {::bess::EnregistreSaisie $::bess::fich_out} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b2 -text $caption(editer) -command {::bess::EditeConfigs} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b3 -text $caption(annuler) -command {::bess::AnnuleSaisie} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      button $t.trame3.b4 -text $caption(webess) -command {::bess::WebBeSS} -font $police(titre) -fg $color(blue_pad) -bg $bess_export_fg
      pack $t.trame3.b1 -side left -padx 10 -pady 10
      pack $t.trame3.b2 -side left -padx 10 -pady 10
      pack $t.trame3.b3 -side right -padx 10 -pady 10
      pack $t.trame3.b4 -side right -padx 35 -pady 10

      pack $t.trame3 -side top -fill both -expand true

      pack $c -side left -fill both -expand true

      tkwait window $audace(base).saisie
      if { "$::bess::fich_out"!="" } {
         return "$::bess::fich_out"
      }
   }

   #*************************************************************************#
   #*************  WebBeSS  ************************************#
   #*************************************************************************#
   proc WebBeSS { } {
      global caption conf spcaudace

      if { $conf(editsite_htm)!="" } {
         set answer [ catch { exec $conf(editsite_htm) "$spcaudace(sitebess)" &
         } ]
      } else {
         set message_erreur $caption(pb_editweb)
         tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
      }
   }

   #*************************************************************************#
   #*************  EditeConfigs  ************************************#
   #*************************************************************************#
   proc EditeConfigs { } {
      global audace conf

      set fichier [file join $::audace(rep_home) BeSSParam.ini]
      catch {
         exec $conf(editscript) $fichier
         tkwait visibility $audace(base).saisie
         LitFichesBeSSPredefinies
      }

   }

   #*************************************************************************#
   #*************  valideMotCle  ********************************************#
   #*************************************************************************#
   # Cette procédure teste la validité d'un mote-clé BeSS
   proc valideMotCle { motcle valeurmotle } {
      variable parametres
      global caption

      switch $motcle {

         "OBJNAME" {
            # Verifier le longueur du champ
            # Verifier les caractères utilisés
            set result 1
         }

         "BSS_RA" {
            # Verifier que DEC est aussi présent
            if {!([string is double $parametres(BSS_RA)])} {
               set message_erreur $caption(pb_ra)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_DEC" {
            # Verifier que RA est aussi présent
            if {!([string is double $parametres(BSS_DEC)])} {
               set message_erreur $caption(pb_dec)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "OBSERVER" {
            #- Verifier que pas plus de trois observateurs
            #- Verifier la longueur du champ
            #set result 1
            if { [string length $parametres(OBSERVER)]>70 || [string length $parametres(OBSERVER)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_INST" {
            # Verifier la longueur du champ
            #set result 1
            if {[string length $parametres(BSS_INST)]>70 || [string length $parametres(BSS_INST)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_SITE" {
            # Verifier la longueur du champ
            #set result 1
            if {[string length $parametres(BSS_SITE)]>70 || [string length $parametres(BSS_INST)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "DATE-OBS" {
            # Vérifier le format
            set result 1
         }

         "EXPTIME" {
            if {!([string is double $parametres(EXPTIME)])} {
                set message_erreur $caption(pb_exptime)
                tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
                set result -2
             } else {
                set result 1
             }
          }

         "BSS_VHEL" {
            if {!([string is double $parametres(BSS_VHEL)])} {
               set message_erreur $caption(pb_vhel)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_NORM" {
            # Verifier la longueur du champ
            #set result 1
            if {[string length $parametres(BSS_NORM)]>70 || [string length $parametres(BSS_NORM)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_TELL" {
            # Verifier la longueur du champ
            #set result 1
            if {[string length $parametres(BSS_TELL)]>70 || [string length $parametres(BSS_TELL)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_COSM" {
            # Verifier la longueur du champ
            #set result 1
            if {[string length $parametres(BSS_COSM)]>70 || [string length $parametres(BSS_COSM)]==0} {
               set message_erreur $caption(pb_longueur)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               set result 1
            }
         }

         "BSS_ESRP" {
            if {!([string is double $parametres(BSS_ESRP)])} {
               set message_erreur $caption(pb_rp)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               if { $parametres(BSS_ESRP)<0 } {
                  set message_erreur $caption(pb_rp)
                  tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
                  set result -2
               } else {
                  set result 1
               }
            }
         }

         "BSS_SRPW" {
            if {!([string is double $parametres(BSS_SRPW)])} {
               set message_erreur $caption(pb_wrp)
               tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
               set result -2
            } else {
               if { $parametres(BSS_SRPW)<0 } {
                  set message_erreur $caption(pb_wrp)
                  tk_messageBox -message $message_erreur -icon error -title $caption(probleme)
                  set result -2
               } else {
                  set result 1
               }
            }
         }

         default {
            set result -1
         }

      }
      return $result
   }

   #*************************************************************************#
   #*************  EnregistreSaisie  ****************************************#
   #*************************************************************************#
   proc EnregistreSaisie { fich_out } {
      variable parametres
      variable parametresOld
      global audace caption

      # Dans un premier temps, on commence par regarder si les mots-cle modifiés sont valides.
      # La variable motCleAModifier contiendra la liste des mots-clé modifiés
      if {[info exists motCleAModifier]} {unset motCleAModifier}
      # La variable pas_glop est à 0 tant que les champs sont corrects. Le processus est interrompu sinon
      set pas_glop 0
     # Message console "fichier %s\n" $fich_out

      # On traite le cas à part du mot-clé OBSERVER (séparé en 3 dans le panneau)
      if { $parametres(obs1) != $parametresOld(obs1) ||
           $parametres(obs2) != $parametresOld(obs2) ||
           $parametres(obs3) != $parametresOld(obs3) } {
         set parametres(OBSERVER) $parametres(obs1)
         append parametres(OBSERVER) ","
         append parametres(OBSERVER) $parametres(obs2)
         append parametres(OBSERVER) ","
         append parametres(OBSERVER) $parametres(obs3)
      } else {
         set parametres(OBSERVER) $parametresOld(OBSERVER)
      }

      # On traite le cas à part du mot-clé DATE-OBS (séparé en 2 dans le panneau)
      if {$parametres(datedeb) != $parametresOld(datedeb) ||
          $parametres(heuredeb) != $parametresOld(heuredeb) } {
         set parametres(DATE-OBS) $parametres(datedeb)
         append parametres(DATE-OBS) T
         append parametres(DATE-OBS) $parametres(heuredeb)
      } else {
         set parametres(DATE-OBS) $parametresOld(DATE-OBS)
      }

      # On traite maintenant en bloc tous le smots-clé
      foreach motcle { OBJNAME BSS_RA BSS_DEC OBSERVER BSS_INST BSS_SITE DATE-OBS EXPTIME BSS_VHEL BSS_NORM BSS_TELL BSS_NORM BSS_ESRP BSS_SRPW } {
         if { $parametres($motcle) != $parametresOld($motcle)} {
            # Le mot-cle a été modifié
            if { [valideMotCle $motcle $parametres($motcle)] != 1 } {
               set pas_glop 1
              # Message console "Erreur:  %s - %s\n" $motcle $parametres($motcle)
              # break
            } else {
              # Message console "A MODIFIER ! - %s - %s\n" $motcle $parametres($motcle)
               lappend motCleAModifier $motcle
            }
         }
      }
      if {$pas_glop == 0} {
         # On peut maintenant enregistrer les mots-clés
         # J'initialise les valeurs qui seront mises dans le header
         set formatmotcle(OBJNAME)  "string"
         set formatmotcle(BSS_RA)   "double"
         set formatmotcle(BSS_DEC)  "double"
         set formatmotcle(OBSERVER) "string"
         set formatmotcle(BSS_INST) "string"
         set formatmotcle(BSS_SITE) "string"
         set formatmotcle(DATE-OBS) "string"
         set formatmotcle(EXPTIME)  "float"
         set formatmotcle(BSS_VHEL) "float"
         set formatmotcle(BSS_NORM) "string"
         set formatmotcle(BSS_TELL) "string"
         set formatmotcle(BSS_COSM) "string"
         set formatmotcle(BSS_ESRP) "float"
         set formatmotcle(BSS_SRPW) "float"

         set commentaire(OBJNAME)  "Object name - updated by Audela BeSS module"
         set commentaire(BSS_RA)   "Updated by Audela BeSS module"
         set commentaire(BSS_DEC)  "Updated by Audela BeSS module"
         set commentaire(OBSERVER) "Updated by Audela BeSS module"
         set commentaire(BSS_INST) "Updated by Audela BeSS module"
         set commentaire(BSS_SITE) "Updated by Audela BeSS module"
         set commentaire(DATE-OBS) "Start. obs. - Updated by Audela BeSS module"
         set commentaire(EXPTIME)  "Total duration - Updated by Audela BeSS module"
         set commentaire(BSS_VHEL) "Updated by Audela BeSS module"
         set commentaire(BSS_NORM) "Updated by Audela BeSS module"
         set commentaire(BSS_TELL) "Updated by Audela BeSS module"
         set commentaire(BSS_COSM) "Updated by Audela BeSS module"
         set commentaire(BSS_ESRP) "Power of resolution at wavelength BSS_RESW"
         set commentaire(BSS_SRPW) "Wavelength where BSS_ESRP was measured"

         if {[info exists motCleAModifier]} {
            foreach motcle $motCleAModifier {
               buf$audace(bufNo) setkwd [list $motcle $parametres($motcle) $formatmotcle($motcle) $commentaire($motcle) ""]
            }

            #--- Gestion de certains mots clefs :
            set listemotsclef [ buf$audace(bufNo) getkwds ]
            #-- Gere les mots clefs vides generes par le panneau Telescope :
            if { [ lsearch $listemotsclef "RA" ] != -1 } {
               if { [ lindex [ buf$audace(bufNo) getkwd "RA" ] 1 ] == "        " } { buf$audace(bufNo) delkwd "RA" }
            }
            if { [ lsearch $listemotsclef "DEC" ] != -1 } {
               if { [ lindex [ buf$audace(bufNo) getkwd "DEC" ] 1 ] == "        " } { buf$audace(bufNo) delkwd "DEC" }
            }
            if { [ lsearch $listemotsclef "EQUINOX" ] != -1 } {
               if { [ lindex [ buf$audace(bufNo) getkwd "EQUINOX" ] 1 ] == "        " } { buf$audace(bufNo) delkwd "EQUINOX" }
            }
            if { [ lsearch $listemotsclef "OBJNAME" ] != -1 } {
               if { [ lindex [ buf$audace(bufNo) getkwd "OBJNAME" ] 1 ] == "        " } { buf$audace(bufNo) delkwd "OBJNAME" }
            }

            #-- Efface des mots clefs incompatibles avec la presence de BSS_INST :
            if { [ lsearch $listemotsclef "INSTRUME" ] != -1 } {
               buf$audace(bufNo) delkwd "INSTRUME"
            }
            if { [ lsearch $listemotsclef "TELESCOP" ] != -1 } {
               buf$audace(bufNo) delkwd "TELESCOP"
            }
            if { [ lsearch $listemotsclef "DETNAM" ] != -1 } {
               buf$audace(bufNo) delkwd "DETNAM"
            }
            if { [ lsearch $listemotsclef "RADECSYS" ] != -1 } {
               buf$audace(bufNo) delkwd "RADECSYS"
            }

            #-- Complete les mots clefs vides :
            if { [ lsearch $listemotsclef "BSS_VHEL" ] ==-1 } {
               buf$audace(bufNo) setkwd [ list BSS_VHEL 0.0 float "Heliocentric velocity at data date" "km/s" ]
            }
            if { [ lsearch $listemotsclef "BSS_NORM" ] ==-1 } {
               buf$audace(bufNo) setkwd [ list BSS_NORM "none" string "Removed or none if normalisation has been done" "" ]
            }
            if { [ lsearch $listemotsclef "BSS_TELL" ] ==-1 } {
               buf$audace(bufNo) setkwd [ list BSS_TELL "none" string "Remove or none if telluric lines has been removed" "" ]
            }
            if { [ lsearch $listemotsclef "BSS_COSM" ] ==-1 } {
               buf$audace(bufNo) setkwd [ list BSS_COSM "none" string "Removed or none if cosmics correction has been done" "" ]
            } elseif { [ lindex [ buf$audace(bufNo) getkwd "BSS_COSM" ] 1 ]=="None    " } {
               buf$audace(bufNo) setkwd [ list BSS_COSM "none" string "Removed or none if cosmics correction has been done" "" ]    
            }
            #- Efface ce mot clef qui pose un probleme d'arrondi au centieme de seconde avec la validation Bess :
            if { [ lsearch $listemotsclef "DATE-END" ] !=-1 } {
               buf$audace(bufNo) delkwd "DATE-END"
            }
            #- Efface ce mot clef qui pose un probleme d'arrondi si les coordonnees de pointage sont imprecises :
            if { [ lsearch $listemotsclef "RA" ] !=-1 } {
               buf$audace(bufNo) delkwd "RA"
               buf$audace(bufNo) delkwd "DEC"
            }
            #- Efface ce mot clef qui pose un probleme car il doit etre au format flot pour BeSS :
            if { [ lsearch $listemotsclef "EQUINOX" ] !=-1 } {
               buf$audace(bufNo) delkwd "EQUINOX"
            }


            #---   Et je sauve le fichier... si le nom de fichier n'est pas vide
            if { $fich_out != ""} {
               set fichier [file root $fich_out]
               append fichier ".fit"
               set okpoursauver 0
               if {[file exists [file join $audace(rep_images) $fichier]]} {
                  set message_erreur $caption(FichExiste)
                  if {[tk_messageBox -message $message_erreur -icon warning -type yesno -title $caption(probleme)] == "yes"} {
                     set okpoursauver 1
                  }
               } else {
                  set okpoursauver 1
               }
               if { $okpoursauver == 1 } {
                  buf$audace(bufNo) bitpix float
                  buf$audace(bufNo) save [file join $audace(rep_images) $fich_out]
                  buf$audace(bufNo) bitpix short
                  ChargeFichier $fich_out
               }
            } else {
               set message_erreur $caption(FichOutVide)
               tk_messageBox -message $message_erreur -icon warning -type ok -title $caption(probleme)
            }
         } else {
          # Message console "Pas besoin de sauver: pas de changements \n"
         }
      } else {
       # Message console "Je ne sauve pas: bugs ! \n"
      }
   }
}
# Fin du namespace bess

#-- BMauclaire - 070619 : ne lance pas la fenetre au chargement de l'ensemble des scripts bess
# ::bess::Principal ""


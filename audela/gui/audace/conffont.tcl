#
## @file conffont.tcl
#  @brief Sélection et mise à jour en direct des polices de l'interface Aud'ACE
#  @author Robert DELMAS
#  @namespace confFont
#  @brief Sélection et mise à jour en direct des polices de l'interface Aud'ACE
#  $Id: conffont.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::confFont {
   global audace

   #--- Charge le fichier caption
   source [ file join $audace(rep_caption) conffont.cap ]
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Police de caractères"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(conffonte,position) définit la position de la fenêtre
#  - polices spécifiques aux OS
#  - polices des widgets
#
proc ::confFont::init { } {
   global audace conf

   #--- Creation des variables si elles n'exitaitent pas
   if { ! [ info exists conf(conffonte,position) ] } { set conf(conffonte,position) "+150+75" }

   if { $::tcl_platform(os) == "Linux" } {

      #--- Polices par classe de widget (police Linux = police Windows + 3)
      if { ! [ info exists conf(conffont,Label) ] }       { set conf(conffont,Label)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,LabelFrame) ] }  { set conf(conffont,LabelFrame)  "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Entry) ] }       { set conf(conffont,Entry)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Button) ] }      { set conf(conffont,Button)      "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Checkbutton) ] } { set conf(conffont,Checkbutton) "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Radiobutton) ] } { set conf(conffont,Radiobutton) "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Menubutton) ] }  { set conf(conffont,Menubutton)  "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Menu) ] }        { set conf(conffont,Menu)        "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Scale) ] }       { set conf(conffont,Scale)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Listbox) ] }     { set conf(conffont,Listbox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,ListBox) ] }     { set conf(conffont,ListBox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Spinbox) ] }     { set conf(conffont,Spinbox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Tablelist) ] }   { set conf(conffont,Tablelist)   "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Text) ] }        { set conf(conffont,Text)        "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Message) ] }     { set conf(conffont,Message)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Graph) ] }       { set conf(conffont,Graph)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,ComboBox) ] }    { set conf(conffont,ComboBox)    "Arial 11 normal" }

   } elseif { $::tcl_platform(os) == "Darwin" } {

      #--- Polices par classe de widget (police Darwin = police Windows + 3)
      if { ! [ info exists conf(conffont,Label) ] }       { set conf(conffont,Label)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,LabelFrame) ] }  { set conf(conffont,LabelFrame)  "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Entry) ] }       { set conf(conffont,Entry)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Button) ] }      { set conf(conffont,Button)      "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Checkbutton) ] } { set conf(conffont,Checkbutton) "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Radiobutton) ] } { set conf(conffont,Radiobutton) "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Menubutton) ] }  { set conf(conffont,Menubutton)  "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Menu) ] }        { set conf(conffont,Menu)        "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Scale) ] }       { set conf(conffont,Scale)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Listbox) ] }     { set conf(conffont,Listbox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,ListBox) ] }     { set conf(conffont,ListBox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Spinbox) ] }     { set conf(conffont,Spinbox)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Tablelist) ] }   { set conf(conffont,Tablelist)   "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Text) ] }        { set conf(conffont,Text)        "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Message) ] }     { set conf(conffont,Message)     "Arial 11 normal" }
      if { ! [ info exists conf(conffont,Graph) ] }       { set conf(conffont,Graph)       "Arial 11 normal" }
      if { ! [ info exists conf(conffont,ComboBox) ] }    { set conf(conffont,ComboBox)    "Arial 11 normal" }

   } else {

      #--- Polices par classe de widget
      if { ! [ info exists conf(conffont,Label) ] }       { set conf(conffont,Label)       "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,LabelFrame) ] }  { set conf(conffont,LabelFrame)  "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Entry) ] }       { set conf(conffont,Entry)       "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Button) ] }      { set conf(conffont,Button)      "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Checkbutton) ] } { set conf(conffont,Checkbutton) "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Radiobutton) ] } { set conf(conffont,Radiobutton) "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Menubutton) ] }  { set conf(conffont,Menubutton)  "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Menu) ] }        { set conf(conffont,Menu)        "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Scale) ] }       { set conf(conffont,Scale)       "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Listbox) ] }     { set conf(conffont,Listbox)     "Courier 10 normal" }
      if { ! [ info exists conf(conffont,ListBox) ] }     { set conf(conffont,ListBox)     "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Spinbox) ] }     { set conf(conffont,Spinbox)     "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Tablelist) ] }   { set conf(conffont,Tablelist)   "{MS Sans Serif} 8 normal" }
      if { ! [ info exists conf(conffont,Text) ] }        { set conf(conffont,Text)        "Verdana 8 normal" }
      if { ! [ info exists conf(conffont,Message) ] }     { set conf(conffont,Message)     "Arial 8 normal" }
      if { ! [ info exists conf(conffont,Graph) ] }       { set conf(conffont,Graph)       "Arial 12 normal" }
      if { ! [ info exists conf(conffont,ComboBox) ] }    { set conf(conffont,ComboBox)    "{MS Sans Serif} 8 normal" }

   }

   #--- Je copie les polices dans audace()
   foreach {key value} [array get conf conffont,*] {
      set fonteType [lindex [split $key ,] 1]
      set audace(font,$fonteType) $value
   }
}

#------------------------------------------------------------
#  brief ouverture de la fenetre de configuration
#  param visuNo numéro de la visu
#
proc ::confFont::run { visuNo } {
   global audace

   ::confGenerique::run $visuNo $audace(base).selectFont "::confFont" -modal 0
}

#------------------------------------------------------------
#  brief retourne le titre de la fenêtre dans la langue de l'utilisateur
#
proc ::confFont::getLabel { } {
   global caption

   return "$caption(conffont,title)"
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confFont::showHelp { } {
   global help

   ::audace::showHelpItem "$help(dir,config)" "1100police.htm"
}

#------------------------------------------------------------
#  brief copie les paramètres du tableau conf() dans les variables des widgets
#  param visuNo numéro de la visu
#
proc ::confFont::confToWidget { visuNo } {
   variable widget
   global conf

   set widget(position) "$conf(conffonte,position)"

   #--- Je copie les polices de conf() dans widget() en fonction des polices choisies
   foreach {key value} [array get conf conffont,*] {
      set fonteType [lindex [split $key ,] 1]
      set widget(font,$fonteType) $value
      set widget(police,$fonteType) [ lindex $widget(font,$fonteType) 0 ]
      if { [ llength "$widget(police,$fonteType)" ] != "1" } {
         set widget(police,$fonteType) [ list $widget(police,$fonteType) ]
      }
      set widget(taille,$fonteType) [ lindex $widget(font,$fonteType) 1 ]
      set widget(style,$fonteType)  [ lindex $widget(font,$fonteType) 2 ]
   }
}

#------------------------------------------------------------
## @brief commande du bouton "Appliquer" ou "OK"
#  @param visuNo numéro de la visu
#
proc ::confFont::cmdApply { visuNo } {
   variable widget
   global audace conf

   #--- Je supprime l'apercu correspondant a la police choisie
   $widget(frm).msg configure -text ""

   #--- Je sauvegarde les polices de widget() dans conf()
   foreach {key value} [array get widget font,*] {
      set fonteType [lindex [split $key ,] 1]
      set conf(conffont,$fonteType) $value
   }

   #--- Je copie les polices dans audace()
   foreach {key value} [array get conf conffont,*] {
      set fonteType [lindex [split $key ,] 1]
      set audace(font,$fonteType) $value
   }

   #--- Je mets la position actuelle de la fenetre dans conf()
   set geom [ winfo geometry [winfo toplevel $widget(frm) ] ]
   set deb [ expr 1 + [ string first + $geom ] ]
   set fin [ string length $geom ]
   set conf(conffonte,position) "+[ string range $geom $deb $fin ]"

   #--- J'affiche les polices
   foreach visuNo [ ::visu::list ] {
      set catchError [ catch {
         set base [ ::confVisu::getBase $visuNo ]
      } m ]
      if { $catchError != "1" } {
         ::confColor::applyColor $base
      }
   }
   ::confColor::applyColor $audace(Console)
}

#------------------------------------------------------------
#  brief affiche la fenêtre à onglets
#  param frm
#  param visuNo numéro de la visu
#
proc ::confFont::fillConfigPage { frm visuNo } {
   variable widget
   global caption conf

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Je position la fenetre
   wm geometry [ winfo toplevel $widget(frm) ] $conf(conffonte,position)

   #--- J'initialise les variables des widgets
   confToWidget $visuNo

   #--- Frame
   frame $frm.select -borderwidth 1 -relief groove
   pack $frm.select -fill x -expand 1 -anchor n -side top

   #--- Button restore
   button $frm.select.restore -text "$caption(conffont,button_restore)" -borderwidth 2 \
      -command { ::confFont::restoreFactoryFonts }
   pack $frm.select.restore -expand 1 -anchor n -side top -ipadx 10

   #--- Frame
   frame $frm.frame -borderwidth 1 -relief groove
   pack $frm.frame -fill both -expand 1 -anchor n -side top

   #--- Je choisis la police, le style et la taille pour chaque widget
   label $frm.frame.label1 -text "$caption(conffont,police)"
   label $frm.frame.label2 -text "$caption(conffont,taille)"
   label $frm.frame.label3 -text "$caption(conffont,style)"
   grid $frm.frame.label1 -row 0 -column 1 -sticky w -padx 3
   grid $frm.frame.label2 -row 0 -column 2 -sticky w -padx 3
   grid $frm.frame.label3 -row 0 -column 3 -sticky w -padx 3
   foreach { key } [lsort [array names widget -glob font,*] ] {
      set i [lindex [split $key ,] 1]
      #--- Je mets un etiquette pour les widgets
      label $frm.frame.lab$i -text "$i"
      #--- Je choisis la police, le style et la taille
      spinbox $frm.frame.spinbox1$i -value [ list Arial Courier Helvetica [ list {MS Sans Serif} ] Times Verdana ] \
         -command "::confFont::showFont $i 0" -width 15
      $frm.frame.spinbox1$i set $widget(police,$i)
      $frm.frame.spinbox1$i configure -textvariable ::confFont::widget(police,$i)
      spinbox $frm.frame.spinbox2$i -from 8 -to 20 -incr 1 \
        -command "::confFont::showFont $i 1" -width 4
      $frm.frame.spinbox2$i set $widget(taille,$i)
      $frm.frame.spinbox2$i configure -textvariable ::confFont::widget(taille,$i)
      spinbox $frm.frame.spinbox3$i -value [ list normal bold ] \
         -command "::confFont::showFont $i 2" -width 10
      $frm.frame.spinbox3$i set $widget(style,$i)
      $frm.frame.spinbox3$i configure -textvariable ::confFont::widget(style,$i)
      grid $frm.frame.lab$i $frm.frame.spinbox1$i $frm.frame.spinbox2$i $frm.frame.spinbox3$i \
         -sticky w -padx 3
      set widget(font,$i) "$widget(police,$i) $widget(taille,$i) $widget(style,$i)"
   }

   #--- Affichage d'un echantillon de la police de caracteres
   message $frm.msg -text "" -width 600
   pack $frm.msg -side top -anchor center -fill both -padx 10 -pady 10
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#
proc ::confFont::cmdClose { visuNo } {
   global audace conf

   #--- Je copie les polices initiales dans audace(font,*)
   foreach {key value} [array get conf conffont,*] {
      set fonteType [lindex [split $key ,] 1]
      set audace(font,$fonteType) $value
   }

   #--- J'applique les polices precedentes
   foreach visuNo [ ::visu::list ] {
      set catchError [ catch {
         set base [ ::confVisu::getBase $visuNo ]
      } m ]
      if { $catchError != "1" } {
         ::confColor::applyColor $base
      }
   }
   ::confColor::applyColor $audace(Console)
}

#------------------------------------------------------------
#  brief visualise la police choisie
#  param i
#  param type
#
proc ::confFont::showFont { i type } {
   variable widget

   if { $widget(font,$i) != "" } {
      if { $type == "0" } {
         set widget(font,$i) [ lreplace $widget(font,$i) 0 0 "$widget(police,$i)" ]
      } elseif { $type == "1" } {
         set widget(font,$i) [ lreplace $widget(font,$i) 1 1 "$widget(taille,$i)" ]
      } elseif { $type == "2" } {
         set widget(font,$i) [ lreplace $widget(font,$i) 2 2 "$widget(style,$i)" ]
      }
      $widget(frm).msg configure -text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz" \
         -font "$widget(font,$i)" -justify center
   }
}

#------------------------------------------------------------
## @brief commande du bouton  "Rétablir les polices de caractères d'origine"
#  @details restaure les polices usine
#
proc ::confFont::restoreFactoryFonts { } {
   variable widget
   global audace caption conf

   set choice [tk_messageBox \
      -message "$caption(conffont,confirmation)" \
      -title "$caption(conffont,couleur_defaut)" \
      -icon question \
      -type yesno ]

   if {"$choice"=="no"} {
      return
   }

   #--- Je supprime les variables conf(conffont,*)
   foreach {key value} [array get conf conffont,*] {
      unset conf($key)
   }

   #--- Je recree les variables supprimees avec les valeurs par defaut
   ::confFont::init

   #--- Je copie les polices dans audace()
   foreach {key value} [array get conf conffont,*] {
      set fonteType [lindex [split $key ,] 1]
      set audace(font,$fonteType) $value
   }

   #--- Je mets a jour les polices de la fenetre audace
   foreach visuNo [ ::visu::list ] {
      set catchError [ catch {
         set base [ ::confVisu::getBase $visuNo ]
      } m ]
      if { $catchError != "1" } {
         ::confColor::applyColor $base
      }
   }
   ::confColor::applyColor $audace(Console)

   #--- Je mets a jour les polices de la fenetre de configuration
   set frm $widget(frm)
   foreach {key value} [array get widget font,*] {
      set i [lindex [split $key ,] 1]
      set widget(font,$i) $conf(conffont,$i)
      #--- Mise a jour de la spinbox police
      set widget(police,$i) [ lindex $widget(font,$i) 0 ]
      if { [ llength "$widget(police,$i)" ] != "1" } {
         set widget(police,$i) [ list $widget(police,$i) ]
      }
      $frm.frame.spinbox1$i set $widget(police,$i)
      $frm.frame.spinbox1$i configure -textvariable ::confFont::widget(police,$i)
      #--- Mise a jour de la spinbox taille
      set widget(taille,$i) [ lindex $widget(font,$i) 1 ]
      $frm.frame.spinbox2$i set $widget(taille,$i)
      $frm.frame.spinbox2$i configure -textvariable ::confFont::widget(taille,$i)
      #--- Mise a jour de la spinbox style
      set widget(style,$i) [ lindex $widget(font,$i) 2 ]
      $frm.frame.spinbox3$i set $widget(style,$i)
      $frm.frame.spinbox3$i configure -textvariable ::confFont::widget(style,$i)
   }
}

#--- Initialisation des polices
::confFont::init


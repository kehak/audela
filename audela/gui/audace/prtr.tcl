#
## @file prtr.tcl
#  @brief Scripts dédiés aux menus déroulants Images et Analyse --> Extraire
#  @author Raymond ZACHANTKE
#  @namespace prtr
#  @brief Scripts dédiés aux menus déroulants Images et Analyse --> Extraire
#  $Id: prtr.tcl 14401 2018-04-11 12:24:26Z rzachantke $
#

#--   pour un acces plus rapide, liste des proc, hors dictionanires
   #  ::prtr::run nom_de_fonction
   #  ::prtr::createDialog
   #  ::prtr::initConf
   #  ::prtr::configWindow
   #  ::prtr::changeOp visuNo
   #  ::prtr::buildParam_obligatoire
   #  ::prtr::buildParam_optionnel
   #  ::prtr::configZone w liste
   #  ::prtr::selectDeselectAll
   #  ::prtr::dispOptions w
   #  ::prtr::selectFiles row
   #  ::prtr::confBitPix
   #  ::prtr::updateTbl visuNo args
   #  ::prtr::analyseFitsHeader file
   #  ::prtr::configOutName
   #  ::prtr::configTableState w  etat
   #  ::prtr::getWidthHeight visuNo
   #  ::prtr::getCenterCoord
   #  ::prtr::updateBox visuNo args
   #  ::prtr::getFileName w nom_de_variable
   #  ::prtr::getDirName
   #  ::prtr::changeExtension visuNo args
   #  ::prtr::cmdApply
   #  ::prtr::windowActive {normal|disabled}
   #  ::prtr::compressFiles dirOut nameOut nb
   #  ::prtr::loadImg
   #  ::prtr::cmdOk tbl
   #  ::prtr::cmdClose
   #  ::prtr::widgetToConf
   #  ::prtr::confToWidget
   #  ::prtr::displayAvancement c
   #  ::prtr::avertiUser err args
   #  ::prtr::Error info
   #  ::prtr::afficheAide
   #  ::prtr::createCheckButton tbl row col w
   #  ::prtr::cmdVerif
   #  ::prtr::cmdTestVariable nom_du_parametre {1=obligatoire | 0=optionnel}
   #  ::prtr::getInfoFile file
   #  ::prtr::cmdExec data options
   #  ::prtr::traiteImg options p
   #  ::prtr::decompRGB file
   #  ::prtr::convertitRGB nameOut
   #  ::prtr::getImgType files
   #  ::prtr::convertBitPix2BitPix {8|16|+16|32|+32|-32|-64}
   #  ::prtr::clipMinMax data options
   #  ::prtr::cmdRot data options
   #  ::prtr::cmdMasqueFlou data options
   #  ::prtr::faireOffset data options
   #  ::prtr::faireDark data options
   #  ::prtr::faireFlat data options
   #  ::prtr::faireOptNoir data options
   #  ::prtr::fairePretraitement data options
   #  ::prtr::createOffset+Dark file1 file2
   #  ::prtr::subsOffset+Dark data file
   #  ::prtr::editScript script
   #  ::prtr::extractData options what
   #  ::prtr::buildNewList newName l
   #  ::prtr::informeUser v1 v2
   #  ::prtr::cmdAligner data options
   #  ::prtr::searchMax box buf
   #  ::prtr::seeWCSKeywords filename
   #  ::prtr::checkCatalog
   #  ::prtr::calibWCS data options
   #  ::prtr::setKwdList options dirOut
   #  ::prtr::getKwdValue filename
   #  ::prtr::createProgressBar

namespace eval ::prtr {

   #--------------------------------------------------------------------------
   #  ::prtr::run nom_de_fonction
   #  Liste les operations proposees dans le bouton de menu de la fenetre
   #--------------------------------------------------------------------------
   proc run {oper} {
      variable private

      set visuNo $::audace(visuNo)
      set ::prtr::operation $oper
      set private(inVisu) ""
      set private(profil) ""

      ::prtr::searchFunction $oper
      ::prtr::getTypeVar

      if {![ winfo exists $::audace(base).prtr]} {
         #--   surveille le changement de fonction
         trace add variable "::prtr::operation" write "::prtr::changeOp $visuNo"
         #--   surveille le changement de repertoire
         trace add variable "::audace(rep_images)" write "::prtr::updateTbl $visuNo"
         #--   surveille le chargement d'une image
         trace add variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
         #--   surveille le changement d'extension
         trace add variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
         #--   surveille le changement de compression
         trace add variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"

         set private(lineHeight) 40
         set private(minWidth)  550
         set private(minHeight) 404

         set private(this) "$::audace(base).prtr"
         ::prtr::createDialog $visuNo
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre du menu "Images"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(prtr,geometry) définit la position de la fenêtre
   #
   proc initConf { } {
      variable private

      if {![info exists ::conf(prtr,geometry)]} {
         set ::conf(prtr,geometry) "${private(minWidth)}x${private(minHeight)}+350+75"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createDialog
   #  Cree l'interface graphique si elle n'existe pas
   #--------------------------------------------------------------------------
   proc createDialog {visuNo} {
      variable private
      variable widget

      set private(visuNo) $visuNo

      initConf

      set This $private(this)

      #--   initialisation des variables
      set ::prtr::all         "0"   ; # booleen, sélection des images
      set ::prtr::ttoptions   "0"   ; # booleen, affichage des options
      set ::prtr::disp        "1"   ; # booleen, affichage de la derniere image
      set ::prtr::script      "0"   ; # booleen, edition ud script
      set ::prtr::out         "./"  ; # nom de sortie
      set private(fun_lignes) "0"

      toplevel $This
      wm resizable $This 1 1
      wm minsize $private(this) $private(minWidth) $private(minHeight)
      wm transient $This $::audace(base)
      #--   pm la geometrie est fixee ::prtr::confToWidget
      wm geometry $private(this) $::conf(prtr,geometry)
      wm protocol $This WM_DELETE_WINDOW "::prtr::cmdClose"

      frame $This.usr -borderwidth 0 -relief raised
      pack $This.usr -fill both -expand 1

      frame $This.usr.select -height 40
      #--   configure la fenetre
      ::prtr::configWindow
      pack $This.usr.select -side top -fill x -expand 0

      frame $This.usr.choix
      set tbl $This.usr.choix.tablelist
      set private(tbl) $tbl
      scrollbar $This.usr.choix.vscroll -command "$tbl yview" -width 18

      frame $This.usr.table
      set this [blt::table $This.usr.table]
      set private(table) $this
      foreach fr {all sortie affiche edit info cmd} {
         frame $this.$fr -borderwidth 1 -relief raised
      }

      scrollbar $this.hscroll -orient horizontal -command "$tbl xview"
      pack $this.hscroll -side left -anchor w
      frame $this.nihil -width 18
      pack $this.nihil -side right -anchor e

      #---  le check bouton pour selectionner tout
      checkbutton $this.all.select -variable ::prtr::all \
         -text "$::caption(prtr,select_all)" -command "::prtr::selectDeselectAll"
      pack $this.all.select -side left -padx 10 -pady 5

      #---  frame pour le fichier de sortie
      LabelEntry $this.sortie.out \
         -label "$::caption(prtr,image_sortie)" -labelanchor w \
         -labelwidth [string length "$::caption(prtr,image_sortie)"]\
         -textvariable ::prtr::out -padx 10 -justify center
      pack $this.sortie.out -side left -padx 5 -pady 5 -fill x -expand 1

      button $this.sortie.explore -text "$::caption(prtr,parcourir)" \
         -width 1 -command "::prtr::getDirName"
      pack $this.sortie.explore -side left -pady 5 -ipady 5 \
         -padx [$This.usr.choix.vscroll cget -width] -pady 5 -ipady 5

      #---  le check bouton pour l'affichage
      checkbutton $this.affiche.disp -variable ::prtr::disp \
         -text "$::caption(prtr,afficher_image_fin)"
      pack $this.affiche.disp -side left -padx 10 -pady 5

      #---  le check bouton pour l'edition du script
      checkbutton $this.affiche.script -variable ::prtr::script \
         -text "$::caption(prtr,afficher_script)"
      pack $this.affiche.script -side left -padx 10 -pady 5 -expand yes

      #---  frame pour l'affichage du deroulement du traitement
      label $this.info.labURL1 -textvariable ::prtr::avancement -fg $::color(blue)
      pack $this.info.labURL1 -side top -padx 10 -pady 5

      #---  les commandes habituelles
      button $this.cmd.ok -text "$::caption(prtr,ok)" \
         -command "::prtr::cmdOk $tbl"
      if {$::conf(ok+appliquer) eq 1} {
         pack $this.cmd.ok -side left -padx 3 -pady 3 -ipadx 25 -ipady 5
      }
      button $this.cmd.appliquer -text "$::caption(prtr,appliquer)" \
         -command "::prtr::cmdApply"
      pack $this.cmd.appliquer -side left -padx 3 -pady 3 -ipadx 5 -ipady 5
      button $this.cmd.fermer -text "$::caption(prtr,fermer)" \
         -command "::prtr::cmdClose"
      pack $this.cmd.fermer -side right -padx 3 -pady 3 -ipadx 5 -ipady 5
      button $this.cmd.aide -text "$::caption(prtr,hlp_function)"\
         -command "::prtr::afficheAide"
      pack $this.cmd.aide -side right -padx 3 -pady 3 -ipadx 5
      button $this.cmd.hlp -text "$::caption(prtr,hlp_gene)" \
         -command "::audace::showHelpItem \"$::audace(rep_doc_html)/french/05images\" \"1010images.htm\""
      pack $this.cmd.hlp -side right -padx 3 -pady 3 -ipadx 5

      #--- positionne les elements dans la table
      blt::table $this \
         $this.hscroll 1,0 -fill both -height {18} \
         $this.nihil 1,1 \
         $this.all 2,0 -fill both -cspan 2 -height {34} \
         $this.sortie 5,0 -fill both -cspan 2 -height {34} \
         $this.affiche 6,0 -fill both -cspan 2 -height {34} \
         $this.info 7,0 -fill both -cspan 2 -height {34} \
         $this.cmd 8,0 -fill both -cspan 2 -height {50}
      pack $this -in $This.usr -side bottom -fill both -expand 0
      blt::table configure $this c1 -width 18 -resize none

      #--- definit la structure et les caracteristiques
      ::tablelist::tablelist $tbl -borderwidth 2 \
         -columns [list \
            4 "" center \
            0 $::caption(prtr,src) left \
            0 $::caption(prtr,type) center \
            0 $::caption(prtr,dimension) center] \
         -xscrollcommand [list $this.hscroll set] \
         -yscrollcommand [list $This.usr.choix.vscroll set] \
         -exportselection 0 -setfocus 1 \
         -activestyle none -stretch {1}

      #--- place la table et le vscrollbar dans la frame
      pack $tbl -anchor w -side left -fill both -expand 1
      pack $This.usr.choix.vscroll -side right -anchor e -fill y
      pack $This.usr.choix -side top -fill both -expand 1

      #--   remplit la tablelist
      #::prtr::updateTbl $visuNo

      #--- selectionne le traitement
      set i [lsearch -exact $private(fonctions) $::prtr::operation]
      incr i
      $This.usr.select.but.menu invoke $i

      bind $This <Key-Return> [list ::prtr::cmdOk $tbl]
      bind $This <Key-Escape> [list ::prtr::cmdClose]
      bind $This <Key-F1> {::console::GiveFocus}

      #--   L'interface est terminee apres l'analyse des images
      #--   Inhibe/Desinhibe le bouton "Tout sélectionner"
      if {$private(size) > 0} {
         $this.all.select configure -state normal
         set img  [::confVisu::getFileName $visuNo]
         if {[file exists $img] == 1 && $private(function) == "CALIBWCS"} {
            ::prtr::seeWCSKeywords [file rootname [file tail $img]]
         }
      }  else {
         $this.all.select configure -state disabled
      }

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configWindow
   #  Gere le titre de la fenetre, le libelle et le bouton de menu
   #  Lancee par ::prtr::createDialog et par ::prtr::changeOp
   #--------------------------------------------------------------------------
   proc configWindow {} {
      variable private

      switch -regexp $private(ima) {
         ARIHTM      { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,arithm)"}
         CENTER      { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,center)"}
         EXTRACT     { set titre "$::caption(audace,menu,analysis) - $::caption(audace,menu,extract)"}
         FILTER      { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,filter)"}
         GEOMETRY    { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,geometry)"}
         IMPROVE     { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,improve)"}
         MAITRE      { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,maitre)"}
         PRETRAITEE  { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,pretraitee)"}
         ROTATION    { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,geometry)"}
         TRANSFORM   { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,transform)"}
         STACK       { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,pile)"}
         CALIB       { set titre "$::caption(audace,menu,analysis) - $::caption(audace,menu,calibration)"}
         default     { set titre "$::caption(audace,menu,images) - $::caption(audace,menu,[string tolower $private(ima)])"}
      }

      wm title $private(this) "$titre"

      #--   detruit le libelle et bouton de menu
      set this $private(this).usr.select
      if {[winfo exists $this]} {destroy $this.lbl $this.but}

      #--   selectionne le libelle (lot ou image) apparaissant a cote du bouton de menu
      if {$private(ima) in [list PILE MAITRE CENTER CALIB]} {
         set texte "$::caption(prtr,operation_lot)"
      } else {
         set texte "$::caption(prtr,operation_disk)"
      }
      label $this.lbl -text $texte
      pack $this.lbl -side left -padx 10 -pady 10

      #--- cherche la longueur maximale du libelle des formules
      #--- pour dimensionner la largeur du bouton de menu
      set bwidth "0"
      foreach formule $private(fonctions) {
         set bwidth [expr {max([string length $formule],$bwidth)}]
      }
      if {$bwidth < "20"} {set bwidth 20}

      menubutton $this.but -relief raised -width $bwidth -borderwidth 2 \
         -textvariable ::prtr::operation -menu $this.but.menu

      #--- menu du bouton
      set m [menu $this.but.menu -tearoff "1"]
      foreach form $private(fonctions) {
         $m add radiobutton -label "$form" -value "$form" \
            -variable ::prtr::operation
      }
      pack $this.but -side right -padx 18 -pady 10
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeOp visuNo
   #  Au lancement d'une fonction, extrait le nom de la fonction TT, la liste
   #  des parametres obligatoires et optionnels, les coordonnees de la doc,
   #  Lancee par trace variable ::prtr::operation
   #--------------------------------------------------------------------------
   proc changeOp {visuNo args} {
      variable private

      #--   cherche le nouveau dictionnaire
      ::prtr::searchFunction $::prtr::operation
      #--   configure la fenetre
      ::prtr::configWindow

      #--   detruit les zones, les widgets et les variables
      destroy $private(table).lbl
      foreach frame {funoptions ttoptions} liste {obligatoire optionnel} {
         set w $private(table).$frame
         if {![winfo exists $w]} {
            continue
         } else {
            destroy $w
            foreach v $private($liste) {unset ::prtr::$v}
            unset private($liste)
         }
      }
      set private(todo) ""
      set private(profil) ""

      #--   charge les nouvelles info
      lassign [${private(ima)}Functions "$::prtr::operation"] private(function) \
         private(l_obligatoire) private(l_optionnel) private(aide)

      #--   force la maj de la liste des fichiers (du fait des images wcs)
      ::prtr::updateTbl $visuNo

      ::prtr::configOutName

      #--   initialise les compteurs de lignes
      set private(fun_lignes) "0"
      set private(tt_lignes)  "1"

      #--   cree et initialise les variables lies aux parametres
      foreach liste {obligatoire optionnel} child {funoptions ttoptions} {
         set content [set private(l_$liste)]
         if {$content ne ""} {
            foreach {var init} $content {set ::prtr::$var $init}
            set l [llength $content]
            set private($liste) ""
            for {set i 0} {$i < $l} {incr i 2} {
               lappend private($liste) [lindex $content $i]
            }
            ::prtr::buildParam_$liste $private(table).$child $visuNo
         }
      }

      if {$private(function) in {WINDOW MATRIX}} {
         #--   surveille le dessin d'une boite de selection
         trace add variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      } else  {
         if {[trace info variable "::confVisu::private($visuNo,boxSize)"] ne ""} {
            trace remove variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
         }
      }

      #--   Verifie le catalogue
      if {$private(function) eq "CALIBWCS"} {
         ::prtr::checkCatalog
      }

      #--  Adapte la geometrie
      ::prtr::confToWidget

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildParam_obligatoire
   #  Configure la zone des parametres obligatoires
   #--------------------------------------------------------------------------
   proc buildParam_obligatoire {w visuNo} {
      variable private

      set obligatoire $private(obligatoire)

      frame $w -borderwidth 1 -relief raised
      #--   la case du titre
      label $w.label  -text "$::caption(prtr,param)"
      set private(fun_lignes) [::prtr::configZone $w obligatoire]
      grid $w.label -row 0 -column 0 -padx 10 -pady 5 -rowspan $private(fun_lignes)
      blt::table $private(table) $w 3,0 -fill x -cspan 2 \
        -height [list [expr {$private(fun_lignes)*$private(lineHeight)}]]

      #--   modifie les variables initiales
      if {$private(inVisu) ne ""} {
         if {"x0" in $obligatoire || "xcenter" in $obligatoire} {
            ::prtr::getCenterCoord
         }

         if {"x2" in $obligatoire && "y2" in $obligatoire} {
            if {[ ::confVisu::getBox $visuNo ] ne ""} {
               #--   affiche les coordonnees de la box
               ::prtr::updateBox $visuNo
            }
         }
         if {$private(function) == "RESIZE"} {
            ::prtr::getWidthHeight $visuNo
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildParam_optionnel
   #  Configure la zone des options
   #--------------------------------------------------------------------------
   proc buildParam_optionnel {w visuNo} {
      variable private

      #--   premiere construction
      if {![winfo exists $w]} {
         frame $w -borderwidth 1 -relief raised
         checkbutton $w.che -indicatoron 1 -offvalue 0 -onvalue 1 \
            -variable ::prtr::ttoptions -text "$::caption(prtr,options)" \
            -command "::prtr::dispOptions $w"
         grid $w.che -row 0 -column 0 -padx 10 -pady 5 -rowspan 1
      }

      ::prtr::confBitPix
      ::prtr::dispOptions $w

      if {$private(function) eq "CALIBWCS"} {
         #--   masque la ligne
         set private(tt_lignes) 0
         blt::table $private(table) $w 4,0 -height {0}
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configZone w liste
   #  Selectionne le widget a appliquer a une variable
   #  Parametres : nom du parent, nom de la liste (obligatoire ou optionnel)
   #--------------------------------------------------------------------------
   proc configZone { w liste } {
      variable private
      variable Var

      lassign [list 2 0 1] nb_max row col
      foreach child $private($liste) {
         set labelwidth [string length $child]
         set d "3"
         if {[expr {fmod($col,2)}] == "0"} {set d "20"}
         switch [lindex [dict get $Var $child] end] {
            "checkbutton"  {
               checkbutton $w.$child -text "$child" \
                  -variable ::prtr::$child -width $labelwidth
               grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
               namespace upvar ::prtr $child value
               if {$value eq 1} {set state disabled} else {set state normal}
               $w.$child configure -state
               if {$child eq "opt_black"} {incr col}
            }
            "labelentry"   {
               set valuewidth [expr {[string length [set ::prtr::$child]]+4}]
               if {$valuewidth < "8"} {set valuewidth 9}
               if {$child ni [list file bias dark flat image_ref hot_pixel_list]} {
                  #--   cas general
                  LabelEntry $w.$child -label "$child" -labelanchor e \
                     -labelwidth $labelwidth -textvariable ::prtr::$child \
                     -padx $d -width $valuewidth -justify center
                  grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
               } else {
                  #--   cas des noms comportant un chemin
                  LabelEntry $w.$child -label "$child" -labelanchor e \
                     -labelwidth $labelwidth -textvariable ::prtr::$child \
                     -padx $d -width 30 -justify center
                  grid $w.$child -row $row -column $col -padx $d -pady 5 -sticky e
                  #--   rajout un bouton "..."
                  if {$child ne "hot_pixel_list"} {
                     incr col
                     button $w.explore_$child -text "$::caption(prtr,parcourir)" \
                        -width 2 -command "::prtr::getFileName $w $child"
                     grid $w.explore_$child -row $row -column $col -padx $d -pady 5
                  }
               }
            }
            "radiobutton" {
               if {![winfo exists $w.$child]} {
                  frame $w.$child
                  label $w.$child.label -text "$::caption(prtr,$child)"
                  pack $w.$child.label -side left
                  switch -exact $child {
                     "methode"   {  foreach radio {somme moyenne mediane} function {ADD MEAN MED} {
                                       radiobutton $w.$child.$radio -text "$::caption(audace,menu,$radio)" \
                                          -indicatoron 1 -variable ::prtr::${child} -value $function
                                       pack $w.$child.$radio -side left -expand 1
                                    }
                                 }
                     "plan"      {  foreach radio {r g b} {
                                       radiobutton $w.$child.$radio -text "$::caption(prtr,$child,$radio)" \
                                          -indicatoron 1 -variable ::prtr::${child} -value $radio
                                       pack $w.$child.$radio -side left -expand 1
                                    }
                                 }
                  }
                  grid $w.$child -row $row -column $col -columnspan 2 -padx $d -pady 5 -sticky ew
               }
               incr col "1"
            }
            "combobox"     {
               set bitpixValues  [list 8 16 +16 32 +32 -32 -64]
               set kernel_widthValues  [list 3 5 7 9 11 13 15 17 19 21]
               set kernel_coefValues  [list 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]
               set type_thresholdValues  [list -1 0 +1]
               set translateValues [list after before never only]
               set astromcatalogValues [list USNO MICROCAT]
               set height [llength [set ${child}Values]]
               set width [ ::tkutil::lgEntryComboBox [set ${child}Values] ]
               if {$width < 6} {set width 6}
               if {$child eq "astromcatalog"} {
                  frame $w.combo$child
                  label $w.combo$child.lbl_$child -text "$child" -width $labelwidth
                  ComboBox $w.combo$child.$child -textvariable ::conf(prtr,astromcatalog) -relief sunken \
                     -width $width -height $height -values [set ${child}Values] -editable 0 \
                     -modifycmd {::prtr::checkCatalog}
                  pack $w.combo$child.lbl_$child $w.combo$child.$child -side left
                  grid $w.combo$child -row $row -column $col -columnspan 2 -pady 5
                  incr col 2
               } elseif {$child eq "bitpix"} {
                  frame $w.combo$child
                  label $w.combo$child.lbl_$child -text "$child" -width $labelwidth
                  ComboBox $w.combo$child.$child -textvariable ::prtr::$child -relief sunken \
                     -width $width -height $height -values [set ${child}Values] -editable 0
                  button $w.combo$child.aide -text "?" -width 2 \
                     -command "::prtr::afficheAideBitpix"
                  pack $w.combo$child.lbl_$child $w.combo$child.$child $w.combo$child.aide -side left
                  grid $w.combo$child -row $row -column $col -padx $d -pady 5 -sticky e
               } else {
                  frame $w.combo$child
                  label $w.combo$child.lbl_$child -text "$child" -width $labelwidth
                  ComboBox $w.combo$child.$child -textvariable ::prtr::$child -relief sunken \
                     -width $width -height $height -values [set ${child}Values] -editable 0
                  pack $w.combo$child.lbl_$child $w.combo$child.$child -side left
                  grid $w.combo$child -row $row -column $col -padx $d -pady 5 -sticky e
               }

               #--   retablit la valeur par defaut de bitpix
               if {$child eq "bitpix"} {
                  ::prtr::confBitPix
                  set k [lsearch [$w.combo$child.$child cget -values] $::prtr::bitpix]
                  $w.combo$child.$child setvalue @$k
               }
            }
         }
         #--   definit la hauteur de la ligne
         grid rowconfigure $w $row -minsize [list $private(lineHeight) ]

         #--   memorise le nb de lignes
         set lignes $row
         incr col
         if {$col > $nb_max} {
            incr row
            set col "1"
         }
      }

      grid columnconfigure $w 1 -minsize 120 -weight 1
      grid columnconfigure $w 2 -weight 1
      grid columnconfigure $w 3 -minsize [$private(this).usr.choix.vscroll cget -width]
      incr lignes
      return $lignes
   }

   #--------------------------------------------------------------------------
   ## @brief commande associée au checkbutton "Options :" ;
   #affiche les options
   #  @param w chemin du widget des options (.audace.prtr.usr.table.ttoptions)
   #
   proc dispOptions { w } {
      variable private

      if {$::prtr::ttoptions == "1"} {
         set private(tt_lignes) [::prtr::configZone $w optionnel]
      } else {
         set children [lreplace [winfo children "$w"] 0 0]
         destroy {*}$children
         #--   il y a toujours au moins une ligne
         set private(tt_lignes) "1"
      }

      #--   Adapte la geometrie a la configuration
      ::prtr::confToWidget

      blt::table $private(table) $w 4,0 -fill both -cspan 2 \
         -height [list [expr {$private(tt_lignes)*$private(lineHeight)}]]

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   ## @brief commande associée au checkbutton "Sélectionner tout" ;
   #sélectionne/désélectionne tous les checkbuttons de la tablelist
   #
   proc selectDeselectAll { } {
      variable private

      #--   arrete si fonction d'extraction sur une image unique ou aucune selection
      if {$::prtr::operation in [list $::caption(audace,menu,ligne) $::caption(audace,menu,colonne) \
            $::caption(audace,menu,matrice)] || $private(profil) eq "" && $private(function) ne "CALIBWCS"} {
         return
      }

      set tbl $private(tbl)
      if {$::prtr::all == 0} {
         #--   deselectionne et desinhibe toutes les lignes
         for {set row 0} {$row < $private(size)} {incr row} {
            [$tbl windowpath $row,0] deselect
            [$tbl windowpath $row,0] configure -state normal
         }
         set private(todo)   ""
         set private(profil) ""
         if {$private(function) eq "CALIBWCS"} {
            #--   Efface les valeurs affichees
            foreach param [list pixsize1 pixsize2 ra dec foclen crota2] {
               set ::prtr::$param ""
            }
         }
      } else {
         #--   Examine toute la table
         for {set row 0} {$row <  [$tbl size]} {incr row} {
            set fileName [$tbl cellcget $row,1 -text]
            if {$private(function) ne "CALIBWCS" } {
               #--   compare le profil de l'image au profil selectionne
               if {[lrange [$tbl get $row] 2 end] eq "$private(profil)"} {
                  #--   selectionne tous les profils identiques a celui de la premiere image
                  [$tbl windowpath $fileName,0] select
                  if {$fileName ni $private(todo)} {
                     lappend private(todo) $fileName
                  }
               }
            } else {
               #--   pas de filtrage pour CALIBWCS
               [$tbl windowpath $row,0] select
               if {$row == 0} {
                  #--   affiche les valeurs des mots clés de la premiere image
                  ::prtr::seeWCSKeywords $fileName
               }
               if {$fileName ni $private(todo)} {
                  lappend private(todo) $fileName
               }
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::selectFiles row
   #  Rafraichit la liste des fichiers selectionnes
   #  Lancee lors de la construction de la fenetre et
   #  par la selection d'une image dans la table
   #--------------------------------------------------------------------------
   proc selectFiles { row } {
      variable bd
      variable private

      set tbl $private(tbl)

      #--   Identifie le nom de l'image selectionnee
      set fileName [$tbl cellcget $row,1 -text]
      #--   Identifie son profil
      set profil [lrange [$tbl get $row] 2 end]

      #--   Arrete si le repertoire est vide
      if {$fileName eq "$::caption(prtr,no_file)" } {return}

      #--   Classe les fonctions par famille
      if {$::prtr::operation in [list $::caption(audace,menu,ligne) $::caption(audace,menu,colonne) \
            $::caption(audace,menu,matrice)]} {
         #--   on ne peut selectionner qu'une seule image
         set function_type 1
      } elseif {$private(function) eq "CALIBWCS"} {
         #--   on peut selectionner toutes les images
         set function_type 2
      } else {
         #--   on ne peut selectionner qu'une image avec le même profil
         set function_type 0
      }

      #--   Recommence la liste
      set private(todo) ""

      #--   Cree un profil referent avec la premiere image selectionnee
      if {$private(profil) eq "" || $private(profil) ne "" && $private(profil) ne "$profil"} {
         set private(profil) $profil
         $tbl seecell $row,0
         if {$private(function) eq "CALIBWCS"} {
            #--   affiche les valeurs
            ::prtr::seeWCSKeywords $fileName
         }
      }

      #--   Adapte l'etat (selectionnable ou non)
      if {$private(profil) ne ""} {
         for {set row 0} {$row < $private(size)} {incr row} {

            #--   Identifie le chemin de la ligne
            set w [$tbl windowpath $row,0]

            #--   Identifie son etat de selection
            set select_state $::prtr::private(file_$row)

            #--   Action specifique au type de fonction
            if {$function_type == 0} {
                #--   pour ces fonctions on peut selectionner plusieurs images
               set match_profil [string match $private(profil) [lrange [$tbl get $row] 2 end]]
               if {$match_profil == "0"} {
                  $w deselect
                  $w configure -state disabled
               } else {
                  if {$select_state == "1"} {
                     lappend private(todo) "[$tbl cellcget $row,1 -text]"
                  }
               }
             } elseif {$function_type == 1} {
               if {$select_state eq "0"} {
                  $w deselect
                  $w configure -state disabled
               } else {
                  lappend private(todo) "[$tbl cellcget $row,1 -text]"
               }
            } elseif {$function_type == 2} {
               #--   pour ces fonctions on peut selectionner toutes les images
               if {$private(function) eq "CALIBWCS"} {
                  if {$select_state == "1"} {
                     lappend private(todo) "[$tbl cellcget $row,1 -text]"
                  }
               }
            }
         }
      }

      if {$private(todo) eq ""} {
         #--   Autorise toutes les selections si la liste est vide
         for {set row 0} {$row < $private(size)} {incr row} {
            [$tbl windowpath $row,0] configure -state normal
         }

         set private(profil) ""

         #--   Efface les valeurs affichees
         if {$private(function) eq "CALIBWCS"} {
             foreach param [list pixsize1 pixsize2 ra dec foclen crota2] {
               set ::prtr::$param ""
            }
         }
         #--   Retablit la valeur par defaut de bitpix
         ::prtr::confBitPix

      } else {

         #--   Cherche la valeur de bitpix
         set info [lindex [array get bd [lindex $private(todo) 0]] 1]
         set ::prtr::bitpix [lindex [lindex $info 4]]
      }

      set private(todo) [lsort -dictionary $private(todo)]

      if {$::prtr::ttoptions eq 1} {
         #--   Affiche la bonne valeur de bitpix
         set k [lsearch [$private(table).ttoptions.combobitpix.bitpix cget -values] $::prtr::bitpix]
         $private(table).ttoptions.combobitpix.bitpix setvalue @$k
      }

      ::prtr::displayAvancement "3"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::confBitPix
   #  Fixe la valeur de bitpix identique a celle du reglage
   #  Utilisee par ::prtr::configZone et ::prtr::selectFiles
   #--------------------------------------------------------------------------
   proc confBitPix {} {

      set ::prtr::bitpix "+16"
      if {$::conf(format_fichier_image) eq "1"} {
         set ::prtr::bitpix "-32"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::updateTbl visuNo args
   #  Rafraichit la tablelist
   #  Lancee lors de la construction de la fenetre, apres execution d'une commande
   #  et au changement de repertoire images
   #--------------------------------------------------------------------------
   proc updateTbl { visuNo args} {
      variable private
      variable bd

      set w $private(tbl)
      set dir $::audace(rep_images)

      set ::prtr::ext "$::conf(extension,defaut)"
      #--   rajoute l'extension de compression
      if {$::conf(fichier,compres) eq "1"} {append ::prtr::ext ".gz"}
      array unset bd

      set files [glob -nocomplain -type f -tails -dir $dir *$::prtr::ext]

      #--   filtre les repertoires et les images d'extensions differentes
      set count 0
      foreach file $files {
         set index [string first "." $file]
         set extension [string range $file $index end]
          if {$extension ne "$::prtr::ext"} {
            set index [lsearch -exact $files $file]
            set files [lreplace $files $index $index]
            incr count
         }
      }

      #--   message d'avertissement si une image detectee
      if {$count != 0} {
        ::console::affiche_erreur "[format $::caption(prtr,err_extension) $count "$::prtr::ext"]\n"
      }

      #--   efface tout
      $w delete 0 end

      #--      arrete si le repertoire est vide
      if {$files eq ""} {
         set private(size) "0"
         ::prtr::configTableState $w normal
         return
      }

      set wcsFunctions [list "REGISTER matchwcs" DRIZZLEWCS CALIBWCS]

      #--   construit la bdd
      foreach file $files {
         set result [::prtr::analyseFitsHeader [file join $dir $file]]
         set wcs [lindex $result 8]
         if {$private(function) in $wcsFunctions && $wcs == "0"} {
            #--   filtre les images non wcs
            set result ""

         }
         if {$result ne ""} {
            regsub "$::prtr::ext" [file tail $file] "" nom_court
            array set bd [list $nom_court $result]
         }
      }

      #--   rafraichit la tablelist
      set private(listFiles) [lsort -dictionary [array names bd]]
      set private(size) [llength $private(listFiles)]

      #--   arrete si la bd est vide et que le répertoire n'est pas vide
      ::prtr::configTableState $w normal
      if {$private(size) == "0"} {return}

      set nb 0
      foreach cible $private(listFiles) {
         foreach {naxis naxis3 naxis1 naxis2 bitpix crpix1 crpix2 mean wcs} [lindex [array get bd $cible] 1] {break}
         if {$naxis eq 2} {set type "M"} else {set type "C"}
         if {$type eq "M" || ($type eq "C" && $private(ima) ni {MAITRE PRETRAITEE})} {
            $w insert end [list "" "$cible" "$type" "${naxis1} X ${naxis2}"]
            $w cellconfigure end,0 -window "::prtr::createCheckButton"
            $w configrows $nb -name "$cible"
            [$w windowpath $cible,0] deselect
            incr nb
         }
      }

      set private(size) $nb
     if {$private(size) == "0"} {return}

      set row -1
      set img  [::confVisu::getFileName $visuNo]
      if {[file exists $img]} {
         #--   image dans la visu
         lassign [::prtr::getInfoFile $img] dir nom
         set row [lsearch [$w getcolumns 1] $nom]
         if {$row ne "-1"} {
            set private(inVisu) $nom
            $w seecell $row,0
            [$w windowpath $nom,0] invoke
         }

      } else {
         #--   pas image dans la visu
         if {[info exists private(lastImage)]} {
            lassign [getInfoFile $private(lastImage)] dir nom
            unset private(lastImage)
            set row [lsearch [$w getcolumns 1] $nom]
            if {$row ne "-1"} {
               $w seecell $row,0
               [$w windowpath $nom,0] invoke
            }
         }
      }

      if {$row > 0} {
         ::prtr::selectFiles $row
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $private(this)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::analyseFitsHeader file (nom complet)
   #  Retourne les caracteristiques d'une image ou rien (si erreur)
   #--------------------------------------------------------------------------
   proc analyseFitsHeader { file } {
      variable private

      set result ""
      set resultMessage ""
      if {![catch {set kwds_list [fitsheader $file]}]} {
         #--- cree un array des kwds
         #--- detecte les erreurs dans les mots-cles
         set error "0"
         foreach kwd $kwds_list {
            set err1 [ catch { set nom [lindex $kwd 0] } resultMessage]
            set err2 [ catch { set valeur [lindex $kwd 1] } resultMessage]
            if { $err1 == "0" && $err2 == "0" } {
               array set kwds [ list $nom $valeur ]
            } else {
               set error "1"
            }
         }
         if { $error == "0" } {
            #--   test wcs
            set wcs_kwd [list crota2 cd1_1 cd1_2 cd2_1 cd2_2 cdelt1 cdelt2 crval1 crval2 dec foclen pixsize1 pixsize2 ra]
            #--   test la presence des mot-cles
            foreach var $wcs_kwd {
               set $var 0
               set value [lindex [array get kwds [string toupper $var]] 1]
               if {$value ne ""} {set $var 1}
            }

            set wcs 0
            set optic 0
            set classic 0
            set matrix 0
            #--   WCS optic
            if {$ra && $dec && $foclen && $crota2 && $pixsize1 && $pixsize2} {
               #--   precaution
               set ra  [mc_angle2deg $ra 360]
               set dec [mc_angle2deg $ra 90]
               set optic 1
            }
            #--   WCS classic
            if {$crval1 && $crval2 && $cdelt1 && $cdelt2 && $crota2 && $pixsize1 && $pixsize2} {
               set classic 1
            }
            #--   WCS matrix
            if {$crval1 && $crval2 && $cd1_1 && $cd1_2 && $cd2_1 && $cd2_2 && $pixsize1 && $pixsize2} {
               set maxtrix 1
            }
            if {($optic == 1 && $private(function) eq "CALIBWCS")  || ($optic == 1 || $classic == 1 || $matrix ==1 && $private(function) ne "CALIBWCS")} {
               set wcs 1
            }

            #--   affecte les valeurs aux variables
            foreach var {bitpix bzero crpix1 crpix2 mean naxis naxis1 naxis2 naxis3 pixsize1 pixsize2 ra dec foclen crota2} {
               set $var [lindex [array get kwds [string toupper $var]] 1]
            }

            if {[info exists bzero] && $bzero ne ""} {set bitpix "$bitpix"}
            array unset kwds
            if {$naxis eq "2" || $naxis eq "3"} {
               #--   si CRPIX1 et CRPIX2 indefinis, calcule le centre de l'image
               if {$crpix1 eq "" || $crpix2 eq ""} {
                  set crpix1 [expr {$naxis1/2}]
                  set crpix2 [expr {$naxis2/2}]
               }
               #-- rajout des variables wcs
               set result [list $naxis $naxis3 $naxis1 $naxis2 $bitpix $crpix1 $crpix2 $mean $wcs $pixsize1 $pixsize2 $ra $dec $foclen $crota2]
            } elseif {$naxis eq "1"} {
               set resultMessage " Traitement impossible sur les images une dimension."
            } else {
               set resultMessage " Traitement non autorisé avec NAXIS différent de 2 ou 3."
            }
         }
      }
      if {$result eq ""} {
         set bad [info exists private(bad_file)]
         if {$bad == "0" || ($bad == "1" && $file ni $private(bad_file))} {
            ::console::affiche_erreur "$file $::caption(prtr,err_file_header) $resultMessage\n\n"
            lappend private(bad_file) "$file"
         }
      }
      return $result
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configOutName
   #  Configure la saisie du nom de sortie
   #--------------------------------------------------------------------------
   proc configOutName {} {
      variable private

      set ::prtr::out ""
      if {$private(function) ni [list "PROFILE direction=x" "PROFILE direction=y" "MATRIX"]} {
         set state normal
      } else {
         #--   inhibe la saisie car nom de sortie==nom d'entree
         set state disabled
      }
      $private(table).sortie.out configure -state $state
   }

   #--------------------------------------------------------------------------
   #  ::prtr::configTableState w  etat
   #  Configure la fenetre
   #--------------------------------------------------------------------------
   proc configTableState { w  etat } {
      variable private

      $private(table).cmd.fermer configure -state $etat

      #--   modifie inconditionnellement la variable etat si la liste est vide
      if {$private(size) == "0"} {
         $w insert end [list "" "$::caption(prtr,no_file)" " " " " ]
         set etat disabled
      }

      #--   inhibe/desinhibe tous les boutons critiques
      if {$::conf(ok+appliquer) eq 1} {
         $private(table).cmd.ok configure -state $etat
      }
      $private(table).cmd.appliquer configure -state $etat
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getWidthHeight
   #  Affiche les dimensions de l'image
   #  Lancee lors de la construction de l'activation de RESIZE
   #--------------------------------------------------------------------------
   proc getWidthHeight { $visuNo } {
      variable private
      variable bd

      #--   cherche les info dans bd
      lassign [lindex [array get bd [lindex $private(todo) 0]] 1] -> -> width height

      set ::prtr::width  $width
      set ::prtr::height $height
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getCenterCoord
   #  Affiche les coordonnees du centre
   #  Lancee lors de la construction de l'activation d'une fonction avec centre
   #--------------------------------------------------------------------------
   proc getCenterCoord { } {
      variable private
      variable bd

      #--   cherche les info dans bd
      set info [lindex [array get bd [lindex $private(todo) 0]] 1]

      #--   rem en absence de CRPIX les valeurs sont au centre de l'image
      set crpix1 [lindex $info 5]
      set crpix2 [lindex $info 6]

      #--   modifie les valeurs initiales
      foreach parametre $private(obligatoire) {
         switch $parametre {
            x0       {set ::prtr::x0       $crpix1   ; #-- ROT REC2POL POL2REC}
            y0       {set ::prtr::y0       $crpix2   ; #-- ROT REC2POL POL2REC}
            xcenter  {set ::prtr::xcenter  $crpix1   ; #-- RGRADIENT RADIAL NORMOFFSET NORMGAIN}
            ycenter  {set ::prtr::ycenter  $crpix2   ; #-- RGRADIENT RADIAL NORMOFFSET NORMGAIN}
            default  {}
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::updateBox visuNo args
   #  Affiche les coordonnees de la box dans x1 y1 x2 y2
   #  Lancee lors de la construction, de l'activation de la fonction de recadrage
   #  ou lors du dessin/effacement d'une boite de selection
   #--------------------------------------------------------------------------
   proc updateBox {visuNo args} {
      variable private
      variable bd

      #--   arrete si pas fonction avec une box
      if {$private(function) ni {WINDOW MATRIX}} {return}

      set box  [::confVisu::getBox $visuNo]
      if {$box eq ""} {
         #--   les valeurs par defaut des fonctions a la box
         regsub -all {x1|y1|x2|y2} $private(l_obligatoire) "" box
      }

      foreach {::prtr::x1 ::prtr::y1 ::prtr::x2 ::prtr::y2} $box {break}
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getFileName w nom_de_variable
   #  Ouvre un explorateur pour choisir une image operande
   #  Produit ::prtr::nom_de_variable
   #--------------------------------------------------------------------------
   proc getFileName { w var } {
      variable private

      #--   ouvre la fenetre de choix des images
      set file [::tkutil::box_load $private(this) $::audace(rep_images) $::audace(bufNo) "1"]

      #--   arrete si pas de selection
      if {$file eq ""} {return}

      #--   decompose le nom en dir nom_court et extension(s)
      lassign [::prtr::getInfoFile $file] dir nom_court ext

      #--   verifie que l'extension est identique a celle des fichiers traites
      if {$ext ne "$::prtr::ext"} {
         return [::prtr::avertiUser err_file_ext $ext $::prtr::ext]
      }

      #--   affiche la valeur moyenne du flat dans la constante
      if {$var eq "flat"} {
         regexp {^(\.[a-zA-Z]{3,4})(\.gz)?} $ext ext_in ext_out compr
         ttscript2 "IMA/SERIES \"$dir\" $nom_court . . $ext_in \"$dir\" $nom_court . $ext_out STAT"
         set fileName [file join $dir $nom_court$ext_out]
         set ::prtr::constant [expr {int([lindex [analyseFitsHeader $fileName] 4])}]
         #--   supprime le fichier non zippe
         if {$compr ne ""} {file delete $fileName}
      }

      #--   remplace le nom du repertoire s'il est identique a celui d'entree
      if {$dir eq "$::audace(rep_images)"} {
         set dir "."
         set file [file join $dir $nom_court$::prtr::ext]
      }

      #--   fixe le nom du fichier
      set ::prtr::$var "$file"

      #--   montre la fin du nom du fichier
      switch $var {
         out      {$private(table).sortie.$var.e xview end}
         default  {$private(table).funoptions.$var.e xview end}
      }
   }

   #--------------------------------------------------------------------------
   ## @brief commande du bouton "..." de saisie du nom générique de sortie ;
   #capture le nom d'un répertoire
   #
   proc getDirName { } {
      variable private

      set dirname [tk_chooseDirectory -title "$::caption(prtr,outfolder)" \
         -initialdir $::audace(rep_images)]

      if {$dirname eq "" || $dirname eq "$::audace(rep_images)"} {
         set dirname "./"
      }
      if {$dirname ne "" && [string index $dirname end] ne "/"} {
         append dirname "/"
      }

      set ::prtr::out $dirname
      $private(table).sortie.out.e xview end
   }

   #--------------------------------------------------------------------------
   #  ::prtr::changeExtension visuNo args
   #  Trace les options d'extension
   #--------------------------------------------------------------------------
   proc changeExtension {visuNo args} {
      variable private

      set ::prtr::ext $::conf(extension,defaut)
      #--   rajoute l'extension de compression
      if {$::conf(fichier,compres) eq "1"} {
         append ::prtr::ext ".gz"
      }
      set private(profil) ""
      if {[info exists private(table)]} {::prtr::updateTbl $visuNo}
   }

   #--------------------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #  @return 0 si la vérification a échoué, 1 si la procédure a été a son terme
   #
   proc cmdApply { } {
      variable private
      variable bd

      set tbl $private(tbl)

      #--   arrete si une erreur ou un oubli
      set opt [::prtr::cmdVerif]
      #--   pour bloquer la fermeture de la fenêtre dans ::prtr::cmdOk
      if {$opt eq 0} {return 1}

      #--   inhibe toutes les zones sensibles
      ::prtr::windowActive disabled

      set dir "$::prtr::dir_out"
      set generique  "$::prtr::generique"
      set imgList "$private(todo)"
      set nbImg [llength $imgList]
      set data [list "$imgList" "$dir" "$generique" "$::prtr::ext"]

      #--   selectionne la fonction a activer
      switch -exact $private(function) {
         "BIAS"            {  set private(error) [::prtr::faireOffset $data $opt]}
         "CENTER"          {  set private(error) [::prtr::cmdAligner $data $opt]}
         "CLIP"            {  set private(error) [::prtr::clipMinMax $data $opt]}
         "DARK"            {  lappend data $prtr::methode
                              set private(error) [::prtr::faireDark $data $opt]}
         "FLAT"            {  set private(error) [::prtr::faireFlat $data $opt]}
         "FLOU"            {  set private(error) [::prtr::cmdMasqueFlou $data $opt]}
         "PRETRAITEMENT"   {  if {$::prtr::opt_black eq "1"} {
                                 set private(error) [::prtr::faireOptNoir $data $opt]
                              } else {
                                 set private(error) [::prtr::fairePretraitement $data $opt]
                              }
                           }
         "ROT+90"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROT-90"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROT180"          {  lappend data "$private(function)"
                              set private(error) [::prtr::cmdRot $data $opt]
                           }
         "ROTENTIERE"      {  set data [concat \"IMA/SERIES\" $data]
                              lappend data "$private(function)"
                              set info [lindex [array get bd [lindex $private(todo) 0]] 1]
                              set x0 [expr {[lindex $info 2]/2.}]
                              set y0 [expr {[lindex $info 3]/2.}]
                              set opt [linsert $opt 0 "x0=$x0" "y0=$y0"]
                              set private(error) [::prtr::cmdExec $data $opt]
                           }
         "CALIBWCS"        {  #--   Attention a l'espace
                              append options $opt " path_astromcatalog=$::prtr::path_astromcatalog"
                              set private(error) [::prtr::calibWCS $data $options]
                           }
         default           {  switch $private(ima) PILE {set appl "IMA/STACK"} default {set appl "IMA/SERIES"}
                              set data [linsert $data 0 $appl]
                              lappend data "$private(function)"
                              set private(error) [::prtr::cmdExec $data $opt]
                           }
      }

      #--   post traitement
      if {$private(error) eq "0"} {

         set ext "$::conf(extension,defaut)"
         if {$dir eq "." || $dir eq "./"} {set dir $::audace(rep_images)}

         #--   image de reference en plus dans ce cas
         if {$private(function) eq "CENTER"} {incr nbImg}

         #--   ces fonctions ne produisent qu'une image
         if {$private(ima) in [list MAITRE PILE] || $nbImg eq "1"} { set nbImg "1"}

         if {$private(function) eq "CALIBWCS"} {set nbImg ""}

         #--   designe l'image a afficher
         if {$nbImg eq "1"} {
            set lastImage [file join "$dir" $generique$ext]
         } elseif {$nbImg eq ""} {
            set lastImage [file join $dir [lindex $private(outList) end]$ext]
         } else {
            set lastImage [file join "$dir" $generique$nbImg$ext]
         }

         #--   compresse les images
         if {$::conf(fichier,compres) eq "1"} {
             ::prtr::compressFiles "$dir" "$generique" $nbImg
             append lastImage ".gz"
         }

         #--  charge la derniere image si demande
         set private(lastImage) $lastImage
         if {$::prtr::disp eq 1} {::prtr::loadImg}
      } else {
         #--   Rend la main
         set ::prtr::all "0"
         ::prtr::selectDeselectAll
      }

      ::prtr::updateTbl $private(visuNo)

      #--   desinhibe les zones sensibles
      ::prtr::windowActive normal

      #--   evite une erreur si appuie sur Fermer avant la fin
      if {![info exists private(error)]} {
         set private(error) 0
      }
      return $private(error)
   }

   #--------------------------------------------------------------------------
   #  ::prtr::windowActive tbl {normal|disabled}
   #  Active/desactive les zones sensibles de la fenetre
   #  Lancee par ::prtr::cmdApply
   #--------------------------------------------------------------------------
   proc windowActive { etat } {
      variable private

      set tbl $private(tbl)
      set this $private(table)

      #--   inhibe/desinhibe tous les checkbutton et le nom de sortie
      set children [list "all.select" "affiche.disp" "affiche.script" "sortie.out"]
      foreach child $children {
         $this.$child configure -state $etat
      }

      #--   inhibe/desinhibe tous les boutons et l'entree du nom
      ::prtr::configTableState $this $etat

      #--- le bouton 'Appliquer' et le message
      if {$etat eq "disabled"} {
         ::prtr::displayAvancement "1"
         $this.cmd.appliquer configure -relief sunken
      } else {
         if {$private(error) ne "1"} {
            ::prtr::displayAvancement "2"
         } else {
            ::prtr::displayAvancement "0"
         }
         $this.cmd.appliquer configure -relief raised
      }

      #--   liste les widgets a inhiber/desinhiber
      if {$etat eq "disabled"} {
         set private(frames) ""
         foreach fr {funoptions ttoptions} {
            if {[winfo exists $this.$fr]} {
               #--   liste les descendants
               set children [winfo children $this.$fr]
               #--   liste les descendants dans une ComboBox
               set comboList [lsearch -regexp -all -inline $children "combo*"]
               #--   extrait le nom des combo
               regsub -all "$this.$fr.combo" $comboList "" descendants
               foreach descendant $descendants {
                  set k [lsearch $children "$this.$fr.combo$descendant"]
                  set children [lreplace $children $k $k "$this.$fr.combo$descendant.$descendant"]
               }
               if {"$this.$fr.methode" in $children} {
                  set k [lsearch $children "$this.$fr.methode"]
                  set children [lreplace $children $k $k]
                  set children [concat $children "$this.$fr.methode.somme" \
                     "$this.$fr.methode.moyenne" "$this.$fr.methode.mediane"]
               } elseif {"$this.$fr.plan" in $children} {
                  set k [lsearch $children "$this.$fr.plan"]
                  set children [lreplace $children $k $k]
                  set children [concat $children "$this.$fr.plan.label" "$this.$fr.plan.r" \
                     "$this.$fr.plan.g" "$this.$fr.plan.b"]
               }
               set private(frames) [concat $private(frames) $children]
            }
         }
      }

      #--   inhibe/desinhibe tous les frames
      foreach frame $private(frames) {$frame configure -state $etat}
      #--- inhibe/desinhibe uniquement les checkbuttons selectionnables
      set private(disabled) ""
      if {$etat eq "disabled"} {
         #--- inhibe tous les checkbuttons selectionnables
         for {set row 0} {$row < $private(size)} {incr row} {
            set w [$tbl windowpath $row,0]
            if {[lindex [$w configure -state] end] eq "normal"} {
               #--   inhibe le checkbutton en etat normal
               $w configure -state $etat
            } else {
               #--   memorise le nom de l'image inhibee
               lappend private(disabled) $row
            }
         }
      } elseif {$etat eq "normal"} {
         #--   desinhibe uniquement la liste qui etait selectionnable
         for {set row 0} {$row < $private(size)} {incr row} {
            if {$row ni $private(disabled)} {
               [$tbl windowpath $row,0] configure -state $etat
            }
         }
         ::prtr::configOutName
      }
      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::compressFiles dirOut nameOut nb
   #  Compresse le ou les fichiers de sortie
   #--------------------------------------------------------------------------
   proc compressFiles { dirOut nameOut nb } {

      set ext "$::conf(extension,defaut)"
      set fileToCompres ""

      if {$nb eq "1"} {
         lappend fileToCompress [file join $dirOut $nameOut$ext]
      } else {
         for {set i 1} {$i <=$nb} {incr i} {
            lappend fileToCompress "[file join $dirOut $nameOut$i$ext]"
         }
      }
      #--   compresse tous les fichiers
      foreach file $fileToCompress {gzip $file}
   }

   #--------------------------------------------------------------------------
   ## @brief commande associée au check button "Afficher l'image à la fin du traitement."
   #charge une image dans un buffer avec bitpix en accord avec la valeur par défaut ou avec la valeur demandée par l'utilisateur
   #
   proc loadImg { } {
      variable private

      set visuNo $::audace(visuNo)
      set bufNo [visu$visuNo buf]
      set bitpix [::prtr::convertBitPix2BitPix $::prtr::bitpix]

      #--   convertit le reglage par defaut en valeur
      switch $::conf(format_fichier_image) {
         "0"   {set bitpix_defaut "ushort" }
         "1"   {set bitpix_defaut "float" }
      }

      #--   regle bitpix si different du reglage par defaut
      if {$bitpix ne "$bitpix_defaut"} {
         buf$bufNo bitpix $bitpix
      }

      trace remove variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
      #--   charge, affiche et nomme l'image
      ::confVisu::autovisu $visuNo -no $private(lastImage)
      trace add variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
   }

   #--------------------------------------------------------------------------
   ## @brief commande du bouton "OK"
   #  @param tbl chemin de la tablelist (ex .audace.prtr.usr.choix.tablelist )
   #
   proc cmdOk {tbl} {

      if {[::prtr::cmdApply $tbl] eq "1"} {return}
      ::prtr::cmdClose
   }

   #--------------------------------------------------------------------------
   ## @brief commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable private
      variable bd

      set visuNo $private(visuNo)

      trace remove variable "::prtr::operation" write "::prtr::changeOp $visuNo"
      trace remove variable "::audace(rep_images)" write "::prtr::updateTbl $visuNo"
      trace remove variable "::confVisu::private($visuNo,lastFileName)" write "::prtr::updateTbl $visuNo"
      if {[trace info variable "::confVisu::private($visuNo,boxSize)"] ne ""} {
         trace remove variable "::confVisu::private($visuNo,boxSize)" write "::prtr::updateBox $visuNo"
      }
      trace remove variable "::conf(extension,defaut)" write "::prtr::changeExtension $visuNo"
      trace remove variable "::conf(fichier,compres)" write "::prtr::changeExtension $visuNo"

      ::prtr::widgetToConf
      destroy $private(this)
      array unset bd
      array unset private
      array unset ::prtr
   }

   #--------------------------------------------------------------------------
   #  ::prtr::widgetToConf
   #  Calcul et sauvegarde de la geometrie a l'exclusion des parties variables
   #  Lancee par cmdClose
   #--------------------------------------------------------------------------
   proc widgetToConf { } {
      variable private

      set geometry [wm geometry $private(this)]

      #--   cherche la hauteur totale de la fenetre
      lassign [string map -nocase [list x " " + " "] $geometry] widgetWidth widgetHeight x y

      if {$widgetHeight ne ""} {
         set variableHeight 0
         #--   definit la hauteur variable (parametres+options) de l'interface
         foreach child [list funoptions ttoptions] {
            if {[winfo exists $private(table).$child]} {
               set height [blt::table configure $private(table) $private(table).$child -reqheight]
               set height [lindex [string map [list \{ "" \} "" ] $height] end]
               incr variableHeight $height
            }
         }

         #--   Calcule la hauteur invariable choisie pat l'utilisateur
         set fixeHeight [expr { $widgetHeight-$variableHeight }]
         set ::conf(prtr,geometry) "${widgetWidth}x${fixeHeight}+${x}+${y}"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::confToWidget
   #  Adapte la geometrie de la fenetre
   #  Lancee lors du changement d'operation et de l'ouverture des options TT
   #--------------------------------------------------------------------------
   proc confToWidget { } {
      variable private

      lassign [string map -nocase [list x " " + " "] $::conf(prtr,geometry)] width fixeHeight x y

      #--   definit la hauteur variable (parametres+options) de l'interface
      if {$private(function) ne "CALIBWCS"} {
         set tt_lignes $private(tt_lignes)
      } else {
         #--   masque la ligne des options
         set tt_lignes 0
      }
      set variableHeight [expr { ($private(fun_lignes)+$tt_lignes)*$private(lineHeight) }]
      set totalHeight [expr { $fixeHeight+$variableHeight }]

      #--   si la position existe (pas au demarrage)
      if {![info exists x] || ![info exists y]} {
         #--   configuration par defaut
         set x 350 ; set y 75
      }

      #--   actualise la geometrie de la fenetre
      set geometry "${width}x${totalHeight}+${x}+${y}"
      wm geometry $private(this) "$geometry"
      #wm minsize $private(this) $private(minWidth) 400

      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::displayAvancement c
   #  Rafraichit l'affichage de la ligne d'info
   #--------------------------------------------------------------------------
   proc displayAvancement {c} {
      variable private

      switch $c {
         0  {  set ::prtr::avancement ""}
         1  {  set ::prtr::avancement $::caption(prtr,en_cours)}
         2  {  set ::prtr::avancement $::caption(prtr,fin_traitement)}
         3  {  set ::prtr::avancement \
                  "[format $::caption(prtr,nb_select) [llength $private(todo)] $private(size)]"
            }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::avertiUser err args
   #  Affiche une fenetre d'avertissement
   #--------------------------------------------------------------------------
   proc avertiUser {err args} {

      switch [llength $args] {
         0  {set msg "$::caption(prtr,$err)"}
         1  {set msg "[format $::caption(prtr,$err) $args]"}
         2  {set msg "[format $::caption(prtr,$err) [lindex $args 0] [lindex $args 1]]"}
      }
      tk_messageBox -title "$::caption(prtr,attention)" -type ok -message $msg
      return 0
   }

   #--------------------------------------------------------------------------
   #  ::prtr::Error info
   #  Message d'erreur lie aux scripts TT
   #--------------------------------------------------------------------------
   proc Error {info} {

      tk_messageBox -title "$::caption(prtr,attention)" -icon error -message "$info"
   }

   #--------------------------------------------------------------------------
   ## @brief sélectionne l'aide associée à la fonction y compris avec l'item dans la page
   #
   proc afficheAide { } {
      variable private

      foreach {dir page item} $private(aide) {break}
      if { $dir == $::help(dir,docLibtt) } {
         ::audace::showHelpDocLibrairy $dir $page $item
      } else {
         ::audace::showHelpItem $dir $page $item
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::afficheAideBitpix
   #  Selectionne l'aide associee a la definition de bitpix
   #  Procedure lancee par le bouton ?
   #--------------------------------------------------------------------------
   proc afficheAideBitpix { } {
      variable private

      ::audace::showHelpDocLibrairy "$::help(dir,docLibtt)" "ttus1-fr.htm" "defBitpix"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createCheckButton tbl row col w
   #  Cree un checkbutton pour inserer dans une tablelist
   #  Parametres : tbl row col et w completes automatiquement
   #--------------------------------------------------------------------------
   proc createCheckButton {tbl row col w} {

      checkbutton $w -height 1 -indicatoron 1 -onvalue 1 -offvalue 0 \
         -variable ::prtr::private(file_$row) \
         -command "::prtr::selectFiles $row"
   }

   #--   chaque fonction est accompagnee de quatre variables (eventuellement vides) :
   #     -fun : nom de la fonction TT
   #     -hlp : nom du repertoire de la page, nom de la page et nom de l'ancre (si elle existe)
   #     -par : noms des parametres obligatoires alternant avec la valeur d'initialisation
   #     -opt : noms des parametres optionnels alternant avec la valeur d'initialisation

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions de calibration WCS d'une série d'images
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::CALIBFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Calibration WCS par lot}
   #  exemple 2
   #  [::prtr::CALIBFunctions "Une ligne" ] retourne la liste des paramètres de la fonction :
   #  # CALIBWCS {ra "" dec "" pixsize1 "" pixsize2 "" foclen "" crota2 0.0 astromcatalog MICROCAT} {} {07analyse 1080calibwcsbatch.htm}
   #  @endcode
   #
   proc CALIBFunctions {function} {
      variable CALIB

      if {![info exists ::conf(prtr,astromcatalog)]} {
         set ::conf(prtr,astromcatalog) "MICROCAT"
      }

      dict set CALIB "$::caption(audace,menu,calibwcs)"            fun "CALIBWCS"
      dict set CALIB "$::caption(audace,menu,calibwcs)"            hlp "$::help(dir,analyse) 1080calibwcsbatch.htm"
      dict set CALIB "$::caption(audace,menu,calibwcs)"            par "ra \"\" dec \"\" pixsize1 \"\" pixsize2 \"\" foclen \"\" crota2 0.0 astromcatalog $::conf(prtr,astromcatalog)"
      dict set CALIB "$::caption(audace,menu,calibwcs)"            opt ""

      return [consultDic CALIB $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions de pretraitement créant des maîtres (offset,dark et flat)
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::MAITREFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # Précharge Noir P.L.U.
   #  exemple 2
   #  [::prtr::MAITREFunctions "P.L.U." ] retourne la liste des paramètres de la fonction :
   #  # FLAT {bias  "" dark "" normoffset_value 0.} {bitpix +16 skylevel 0 nullpixel 0.} {05images 1020elaborer_maitre.htm FLAT}
   #  @endcode
   #
   proc MAITREFunctions {function} {
      variable MAITRE

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set MAITRE "$::caption(audace,menu,faire_offset)"        fun "BIAS"
      dict set MAITRE "$::caption(audace,menu,faire_offset)"        hlp "$::help(dir,images) 1020elaborer_maitre.htm BIAS"
      dict set MAITRE "$::caption(audace,menu,faire_offset)"        par ""
      dict set MAITRE "$::caption(audace,menu,faire_offset)"        opt "$options nullpixel 0."
      dict set MAITRE "$::caption(audace,menu,faire_dark)"          fun "DARK"
      dict set MAITRE "$::caption(audace,menu,faire_dark)"          hlp "$::help(dir,images) 1020elaborer_maitre.htm DARK"
      dict set MAITRE "$::caption(audace,menu,faire_dark)"          par "methode MED bias \"\" "
      dict set MAITRE "$::caption(audace,menu,faire_dark)"          opt "$options nullpixel 0."
      dict set MAITRE "$::caption(audace,menu,faire_flat_field)"    fun "FLAT"
      dict set MAITRE "$::caption(audace,menu,faire_flat_field)"    hlp "$::help(dir,images) 1020elaborer_maitre.htm FLAT"
      dict set MAITRE "$::caption(audace,menu,faire_flat_field)"    par "bias \"\" dark \"\" normoffset_value 0."
      dict set MAITRE "$::caption(audace,menu,faire_flat_field)"    opt "$options nullpixel 0."

      return [consultDic MAITRE $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions de prétraitement
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::PRETRAITEEFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Prétraiter image(s) brute(s)}
   #  exemple 2
   #  [::prtr::PRETRAITEEFunctions "Prétraiter image(s) brute(s)" ] retourne la liste des paramètres de la fonction :
   #  # PRETRAITEMENT {bias "" dark "" opt_black 0 flat "" constant 1.} {bitpix +16 skylevel 0 nullpixel 0.} {05images 1020elaborer_maitre.htm PRETRAITER}
   #  @endcode
   #
   proc PRETRAITEEFunctions {function} {
      variable PRETRAITEE

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set PRETRAITEE "$::caption(audace,menu,pretraitee)"      fun "PRETRAITEMENT"
      dict set PRETRAITEE "$::caption(audace,menu,pretraitee)"      hlp "$::help(dir,images) 1020elaborer_maitre.htm PRETRAITER"
      dict set PRETRAITEE "$::caption(audace,menu,pretraitee)"      par "bias \"\" dark \"\" opt_black 0 flat \"\" constant 1."
      dict set PRETRAITEE "$::caption(audace,menu,pretraitee)"      opt "$options nullpixel 0."

      return [consultDic PRETRAITEE $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions de recentrage
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::CENTERFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # Intercorrélation {Translation automatique} {Transformation affine} etc.
   #  exemple 2
   #  [::prtr::CENTERFunctions "Intercorrélation" ] retourne la liste des paramètres de la fonction :
   #  # CENTER {plan g image_ref "" } {bitpix +16 skylevel 0 nullpixel 0.} {05images 1040aligner.htm}
   #  @endcode
   #
   proc CENTERFunctions {function} {
      variable CENTER

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set CENTER "$::caption(audace,menu,reg_inter)"           fun "CENTER"
      dict set CENTER "$::caption(audace,menu,reg_inter)"           hlp "$::help(dir,images) 1040aligner.htm"
      dict set CENTER "$::caption(audace,menu,reg_inter)"           par "plan g image_ref \"\" "
      dict set CENTER "$::caption(audace,menu,reg_inter)"           opt "$options nullpixel 0."
      dict set CENTER "$::caption(audace,menu,reg_trans)"           fun "REGISTER translate=before"
      dict set CENTER "$::caption(audace,menu,reg_trans)"           hlp "$::help(dir,images) 1040aligner.htm"
      dict set CENTER "$::caption(audace,menu,reg_trans)"           par "normaflux 1."
      dict set CENTER "$::caption(audace,menu,reg_trans)"           opt "$options nullpixel 0."
      dict set CENTER "$::caption(audace,menu,reg_tri)"             fun "REGISTER translate=never"
      dict set CENTER "$::caption(audace,menu,reg_tri)"             hlp "$::help(dir,images) 1040aligner.htm"
      dict set CENTER "$::caption(audace,menu,reg_tri)"             par "normaflux 1."
      dict set CENTER "$::caption(audace,menu,reg_tri)"             opt "$options nullpixel 0."
      dict set CENTER "$::caption(audace,menu,reg_fine)"            fun "REGISTERFINE"
      dict set CENTER "$::caption(audace,menu,reg_fine)"            hlp "$::help(dir,images) 1040aligner.htm"
      dict set CENTER "$::caption(audace,menu,reg_fine)"            par "file img oversampling 10 delta 2"
      dict set CENTER "$::caption(audace,menu,reg_fine)"            opt "$options nullpixel 0."
      dict set CENTER "$::caption(audace,menu,reg_wcs)"             fun "REGISTER matchwcs"
      dict set CENTER "$::caption(audace,menu,reg_wcs)"             hlp "$::help(dir,images) 1040aligner.htm"
      dict set CENTER "$::caption(audace,menu,reg_wcs)"             par "normaflux 1."
      dict set CENTER "$::caption(audace,menu,reg_wcs)"             opt "$options nullpixel 0."

      return [consultDic CENTER $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/STACK
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::PILEFunctions 0] retourne la liste des fonctions arithmétiques dans la langue de l'utilisateur :
   #  # Somme Moyenne Médiane Produit {Racine carrée} Ecart-type etc.
   #  exemple 2
   #  [::prtr::PILEFunctions "Drizzle WCS" ] retourne la liste des paramètres de la fonction :
   #  # DRIZZLEWCS {oversampling 2 drop_sizepix 0.5} {bitpix +16 skylevel 0 nullpixel 0.} {doc/libtt ttus1-fr.htm DRIZZLEWCS}
   #  @endcode
   #
   proc PILEFunctions {function} {
      variable STACK

      if {![info exists ::conf(prtr,sk,kappa)]} {set ::conf(prtr,sk,kappa) "0.8"}

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set STACK "$::caption(audace,menu,somme)"                fun ADD
      dict set STACK "$::caption(audace,menu,somme)"                hlp "$::help(dir,docLibtt) ttus1-fr.htm stackADD"
      dict set STACK "$::caption(audace,menu,somme)"                par ""
      dict set STACK "$::caption(audace,menu,somme)"                opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,moyenne)"              fun MEAN
      dict set STACK "$::caption(audace,menu,moyenne)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm MEAN"
      dict set STACK "$::caption(audace,menu,moyenne)"              par ""
      dict set STACK "$::caption(audace,menu,moyenne)"              opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,mediane)"              fun MED
      dict set STACK "$::caption(audace,menu,mediane)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm MED"
      dict set STACK "$::caption(audace,menu,mediane)"              par ""
      dict set STACK "$::caption(audace,menu,mediane)"              opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,produit)"              fun PROD
      dict set STACK "$::caption(audace,menu,produit)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm stackPROD"
      dict set STACK "$::caption(audace,menu,produit)"              par ""
      dict set STACK "$::caption(audace,menu,produit)"              opt "powernorm 0 $options nullpixel 0."
      dict set STACK "$::caption(audace,menu,racine_carree)"        fun PYTHAGORE
      dict set STACK "$::caption(audace,menu,racine_carree)"        hlp "$::help(dir,docLibtt) ttus1-fr.htm PYTHAGORE"
      dict set STACK "$::caption(audace,menu,racine_carree)"        par ""
      dict set STACK "$::caption(audace,menu,racine_carree)"        opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,ecart_type)"           fun SIG
      dict set STACK "$::caption(audace,menu,ecart_type)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm SIG"
      dict set STACK "$::caption(audace,menu,ecart_type)"           par ""
      dict set STACK "$::caption(audace,menu,ecart_type)"           opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,moyenne_k)"            fun SK
      dict set STACK "$::caption(audace,menu,moyenne_k)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm SK"
      dict set STACK "$::caption(audace,menu,moyenne_k)"            par "kappa $::conf(prtr,sk,kappa)"
      dict set STACK "$::caption(audace,menu,moyenne_k)"            opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,moyenne_tri)"          fun SORT
      dict set STACK "$::caption(audace,menu,moyenne_tri)"          hlp "$::help(dir,docLibtt) ttus1-fr.htm SORT"
      dict set STACK "$::caption(audace,menu,moyenne_tri)"          par ""
      dict set STACK "$::caption(audace,menu,moyenne_tri)"          opt "percent 50 $options nullpixel 0."
      dict set STACK "$::caption(audace,menu,obturateur)"           fun SHUTTER
      dict set STACK "$::caption(audace,menu,obturateur)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm SHUTTER"
      dict set STACK "$::caption(audace,menu,obturateur)"           par ""
      dict set STACK "$::caption(audace,menu,obturateur)"           opt "$options nullpixel 0."
      dict set STACK "$::caption(audace,menu,drizzle)"              fun DRIZZLEWCS
      dict set STACK "$::caption(audace,menu,drizzle)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm DRIZZLEWCS"
      dict set STACK "$::caption(audace,menu,drizzle)"              par "oversampling 2 drop_sizepix 0.5"
      dict set STACK "$::caption(audace,menu,drizzle)"              opt "$options nullpixel 0."


      return [::prtr::consultDic STACK $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions de rotation à angles droit
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::ROTATIONFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Tourner 90° sens horaire} {Tourner 90° sens anti-horaire} etc.
   #  exemple 2 #
   #   [::prtr::ROTATIONFunctions "Tourner 180°" ] retourne la liste des paramètres de la fonction :
   #  # ROT180 {} {bitpix +16 skylevel 0 nullpixel 0.} {05images 1050tourner.htm ROT180}
   #  @endcode
   #
   proc ROTATIONFunctions {function} {
      variable ROTATION

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction
      #--   les fonctions combinent des fonctions INVERT qui ont l'option nullpixel

      dict set ROTATION "$::caption(audace,menu,rot+90)"            fun "ROT+90"
      dict set ROTATION "$::caption(audace,menu,rot+90)"            hlp "$::help(dir,images) 1050tourner.htm ROT+90"
      dict set ROTATION "$::caption(audace,menu,rot+90)"            par ""
      dict set ROTATION "$::caption(audace,menu,rot+90)"            opt "$options nullpixel 0."
      dict set ROTATION "$::caption(audace,menu,rot-90)"            fun "ROT-90"
      dict set ROTATION "$::caption(audace,menu,rot-90)"            hlp "$::help(dir,images) 1050tourner.htm ROT-90"
      dict set ROTATION "$::caption(audace,menu,rot-90)"            par ""
      dict set ROTATION "$::caption(audace,menu,rot-90)"            opt "$options nullpixel 0."
      dict set ROTATION "$::caption(audace,menu,rot180)"            fun "ROT180"
      dict set ROTATION "$::caption(audace,menu,rot180)"            hlp "$::help(dir,images) 1050tourner.htm ROT180"
      dict set ROTATION "$::caption(audace,menu,rot180)"            par ""
      dict set ROTATION "$::caption(audace,menu,rot180)"            opt "$options nullpixel 0."

      return [consultDic ROTATION $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES qui modifient la géometrie
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::GEOMETRYFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Inverser Gauche/Droite} {Inverser Haut/Bas} etc.
   #  exemple 2
   #  [::prtr::GEOMETRYFunctions "Translater" ] retourne la liste des paramètres de la fonction :
   #  # TRANS {trans_x 1. trans_y 1.} {bitpix +16 skylevel 0 nullpixel 0.} {doc/libtt ttus1-fr.htm TRANS}
   #  @endcode
   #
   proc GEOMETRYFunctions {function} {
      variable SERIES

      if {![info exists ::conf(multx)] && ![info exists ::conf(multy)] && ![info exists ::conf(prtr,resample,paramresample)]} {
         set ::conf(prtr,resample,paramresample) "0.5 0 0 0 0.5 0"
      } elseif {[info exists ::conf(multx)] && [info exists ::conf(multy)]} {
         set ::conf(prtr,resample,paramresample) "$::conf(multx) 0 0 0 $::conf(multy) 0"
         unset ::conf(multx) ::conf(multy)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$::caption(audace,menu,miroir_x)"            fun "INVERT mirror"
      dict set SERIES "$::caption(audace,menu,miroir_x)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm INVERT"
      dict set SERIES "$::caption(audace,menu,miroir_x)"            par ""
      dict set SERIES "$::caption(audace,menu,miroir_x)"            opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,miroir_y)"            fun "INVERT flip"
      dict set SERIES "$::caption(audace,menu,miroir_y)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm INVERT"
      dict set SERIES "$::caption(audace,menu,miroir_y)"            par ""
      dict set SERIES "$::caption(audace,menu,miroir_y)"            opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,miroir_xy)"           fun "INVERT xy"
      dict set SERIES "$::caption(audace,menu,miroir_xy)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm INVERT"
      dict set SERIES "$::caption(audace,menu,miroir_xy)"           par ""
      dict set SERIES "$::caption(audace,menu,miroir_xy)"           opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,window1)"             fun WINDOW
      dict set SERIES "$::caption(audace,menu,window1)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm WINDOW"
      dict set SERIES "$::caption(audace,menu,window1)"             par "x1 1 y1 1 x2 2 y2 2"
      dict set SERIES "$::caption(audace,menu,window1)"             opt $options
      dict set SERIES "$::caption(audace,menu,taille)"              fun RESIZE
      dict set SERIES "$::caption(audace,menu,taille)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm RESIZE"
      dict set SERIES "$::caption(audace,menu,taille)"              par "width 100 height 100"
      dict set SERIES "$::caption(audace,menu,taille)"              opt $options
      dict set SERIES "$::caption(audace,menu,scale)"               fun RESAMPLE
      dict set SERIES "$::caption(audace,menu,scale)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm RESAMPLE"
      dict set SERIES "$::caption(audace,menu,scale)"               par "paramresample \"$::conf(prtr,resample,paramresample)\" normaflux 1."
      dict set SERIES "$::caption(audace,menu,scale)"               opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,translate)"           fun TRANS
      dict set SERIES "$::caption(audace,menu,translate)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm TRANS"
      dict set SERIES "$::caption(audace,menu,translate)"           par "trans_x 1. trans_y 1."
      dict set SERIES "$::caption(audace,menu,translate)"           opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,rotation1)"           fun ROT
      dict set SERIES "$::caption(audace,menu,rotation1)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm ROT"
      dict set SERIES "$::caption(audace,menu,rotation1)"           par "x0 1. y0 1. angle 1."
      dict set SERIES "$::caption(audace,menu,rotation1)"           opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,rotation2)"           fun ROTENTIERE
      dict set SERIES "$::caption(audace,menu,rotation2)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm ROTENTIERE"
      dict set SERIES "$::caption(audace,menu,rotation2)"           par "angle 1."
      dict set SERIES "$::caption(audace,menu,rotation2)"           opt "$options nullpixel 0."

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES qui améliorent les images
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::IMPROVEFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Supprimer une traînée} {Supprimer un cosmique} etc.
   #  exemple 2
   #  [::prtr::IMPROVEFunctions "Supprimer un cosmique" ] retourne la liste des paramètres de la fonction :
   #  # COSMIC {cosmic_threshold 400} {bitpix +16 skylevel 0} {doc/libtt ttus1-fr.htm COSMIC}
   #  @endcode
   #
   proc IMPROVEFunctions {function} {
      variable SERIES

      if {![info exists ::conf(back_kernel)] && ![info exists ::conf(prtr,back,back_kernel)]} {
         set ::conf(prtr,back,back_kernel) "15"
      } elseif {[info exists ::conf(back_kernel)]} {
         set ::conf(prtr,back,back_kernel) $::conf(back_kernel)
         unset ::conf(back_kernel)
      }
      if {![info exists ::conf(back_threshold)] && ![info exists ::conf(prtr,back,back_threshold)]} {
         set ::conf(prtr,back,back_threshold) "0.2"
      } elseif {[info exists ::conf(back_threshold)]} {
         set ::conf(prtr,back,back_threshold) $::conf(back_threshold)
         unset ::conf(back_threshold)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$::caption(audace,menu,trainee)"             fun UNSMEARING
      dict set SERIES "$::caption(audace,menu,trainee)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm UNSMEARING"
      dict set SERIES "$::caption(audace,menu,trainee)"             par "unsmearing 0.0005"
      dict set SERIES "$::caption(audace,menu,trainee)"             opt $options
      dict set SERIES "$::caption(audace,menu,cosmic)"              fun COSMIC
      dict set SERIES "$::caption(audace,menu,cosmic)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm COSMIC"
      dict set SERIES "$::caption(audace,menu,cosmic)"              par "cosmic_threshold 400"
      dict set SERIES "$::caption(audace,menu,cosmic)"              opt $options
      dict set SERIES "$::caption(audace,menu,hotpixel)"            fun HOTPIXEL
      dict set SERIES "$::caption(audace,menu,hotpixel)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm HOTPIXEL"
      dict set SERIES "$::caption(audace,menu,hotpixel)"            par "hot_pixel_list \"[list P 3 4 L 3 C 3 ]\""
      dict set SERIES "$::caption(audace,menu,hotpixel)"            opt $options
      dict set SERIES "$::caption(audace,menu,opt_noir)"            fun OPT
      dict set SERIES "$::caption(audace,menu,opt_noir)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm OPT"
      dict set SERIES "$::caption(audace,menu,opt_noir)"            par "bias img dark img therm_kappa 0.25"
      dict set SERIES "$::caption(audace,menu,opt_noir)"            opt "unsmearing 0.0005 $options"
      dict set SERIES "$::caption(audace,menu,subsky)"              fun BACK
      dict set SERIES "$::caption(audace,menu,subsky)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm BACK"
      dict set SERIES "$::caption(audace,menu,subsky)"              par "back_kernel $::conf(prtr,back,back_kernel) back_threshold $::conf(prtr,back,back_threshold)"
      dict set SERIES "$::caption(audace,menu,subsky)"              opt "sub 0 div 0 $options nullpixel 0."

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES arithmétiques
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interfacce pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::ARITHMFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Ajouter une image} {Soustraire une image} etc.
   #  exemple 2
   #  [::prtr::ARITHMFunctions Logarithme ] retourne la liste des paramètres de la fonction :
   #  # LOG {coef 20. offsetlog 1.} {bitpix +16 skylevel 0 nullpixel 0.} {doc/libtt ttus1-fr.htm LOG}
   #  @endcode
   #
   proc ARITHMFunctions {function} {
      variable SERIES

      if {![info exists ::conf(clip_mini)] && ![info exists ::conf(prtr,clip,clip_mini)]} {
         set ::conf(prtr,clip,clip_mini) "0"
      } elseif {[info exists ::conf(clip_mini)]} {
         set ::conf(prtr,clip,clip_mini) $::conf(clip_mini)
         unset ::conf(clip_mini)
      }
      if {![info exists ::conf(clip_maxi)] && ![info exists ::conf(prtr,clip,clip_maxi)]} {
         set ::conf(prtr,clip,clip_maxi) "32767"
      } elseif {[info exists ::conf(clip_maxi)]} {
         set ::conf(prtr,clip,clip_maxi) $::conf(clip_maxi)
         unset ::conf(clip_maxi)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$::caption(audace,menu,addition)"            fun ADD
      dict set SERIES "$::caption(audace,menu,addition)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm seriesADD"
      dict set SERIES "$::caption(audace,menu,addition)"            par "file img"
      dict set SERIES "$::caption(audace,menu,addition)"            opt "offset 0 $options"
      dict set SERIES "$::caption(audace,menu,soust)"               fun SUB
      dict set SERIES "$::caption(audace,menu,soust)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm SUB"
      dict set SERIES "$::caption(audace,menu,soust)"               par "file img"
      dict set SERIES "$::caption(audace,menu,soust)"               opt "offset 0 $options"
      dict set SERIES "$::caption(audace,menu,division)"            fun DIV
      dict set SERIES "$::caption(audace,menu,division)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm DIV"
      dict set SERIES "$::caption(audace,menu,division)"            par "file img"
      dict set SERIES "$::caption(audace,menu,division)"            opt "constant 1. $options"
      dict set SERIES "$::caption(audace,menu,multipli)"            fun PROD
      dict set SERIES "$::caption(audace,menu,multipli)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm seriesPROD"
      dict set SERIES "$::caption(audace,menu,multipli)"            par "file img"
      dict set SERIES "$::caption(audace,menu,multipli)"            opt "constant 1. $options"
      dict set SERIES "$::caption(audace,menu,offset)"              fun OFFSET
      dict set SERIES "$::caption(audace,menu,offset)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm OFFSET"
      dict set SERIES "$::caption(audace,menu,offset)"              par "offset 0"
      dict set SERIES "$::caption(audace,menu,offset)"              opt $options
      dict set SERIES "$::caption(audace,menu,mult_cte)"            fun MULT
      dict set SERIES "$::caption(audace,menu,mult_cte)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm MULT"
      dict set SERIES "$::caption(audace,menu,mult_cte)"            par "constant 1."
      dict set SERIES "$::caption(audace,menu,mult_cte)"            opt $options
      dict set SERIES "$::caption(audace,menu,log)"                 fun LOG
      dict set SERIES "$::caption(audace,menu,log)"                 hlp "$::help(dir,docLibtt) ttus1-fr.htm LOG"
      dict set SERIES "$::caption(audace,menu,log)"                 par "coef 20. offsetlog 1."
      dict set SERIES "$::caption(audace,menu,log)"                 opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,noffset)"             fun NORMOFFSET
      dict set SERIES "$::caption(audace,menu,noffset)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm NORMOFFSET"
      dict set SERIES "$::caption(audace,menu,noffset)"             par "normoffset_value 0. xcenter 1. ycenter 1. radius 2"
      dict set SERIES "$::caption(audace,menu,noffset)"             opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,ngain)"               fun NORMGAIN
      dict set SERIES "$::caption(audace,menu,ngain)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm NORMGAIN"
      dict set SERIES "$::caption(audace,menu,ngain)"               par "normgain_value 200. xcenter 1. ycenter 1. radius 2"
      dict set SERIES "$::caption(audace,menu,ngain)"               opt "$options nullpixel 0."
      #--   CLIP fonction artificielle inexistante dans IMA/SERIES
      dict set SERIES "$::caption(audace,menu,clip)"                fun CLIP
      dict set SERIES "$::caption(audace,menu,clip)"                hlp "$::help(dir,images) 1080ecreter.htm"
      dict set SERIES "$::caption(audace,menu,clip)"                par "mini $::conf(prtr,clip,clip_mini) maxi $::conf(prtr,clip,clip_maxi)"
      dict set SERIES "$::caption(audace,menu,clip)"                opt "bitpix +16"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES avec les filtres
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::FILTERFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Masque flou} {Filtre passe-bas} {Filtre passe-haut} etc.
   #  exemple 2
   #  [::prtr::FILTERFunctions "Filtre moyen" ] retourne la liste des paramètres de la fonction :
   #  # REC2POL {x0 1. y0 1. scale_theta 1. scale_rho 1.} {bitpix +16 skylevel 0 nullpixel 0.} {doc/libtt ttus1-fr.htm REC2POL}
   #  @endcode
   #
   proc FILTERFunctions {function} {
      variable SERIES

      if {![info exists ::conf(coef_etal)] && ![info exists ::conf(prtr,flou,sigma)]} {
         set ::conf(prtr,flou,sigma) "2.0"
      } elseif {[info exists ::conf(coef_etal)]} {
         set ::conf(prtr,flou,sigma) $::conf(coef_etal)
         unset ::conf(coef_etal)
      }
      if {![info exists ::conf(coef_mult)] && ![info exists ::conf(prtr,flou,constant)]} {
         set ::conf(prtr,flou,constant) "5.0"
      } elseif {[info exists ::conf(coef_mult)]} {
        set ::conf(prtr,flou,constant) $::conf(coef_mult)
         unset ::conf(coef_mult)
      }

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      #--   FLOU fonction artificielle inexistante dans IMA/SERIES
      dict set SERIES "$::caption(audace,menu,masque_flou)"         fun FLOU
      dict set SERIES "$::caption(audace,menu,masque_flou)"         hlp "$::help(dir,images) 1090masque_flou.htm"
      dict set SERIES "$::caption(audace,menu,masque_flou)"         par "sigma $::conf(prtr,flou,sigma) constant $::conf(prtr,flou,constant)"
      dict set SERIES "$::caption(audace,menu,masque_flou)"         opt $options
      dict set SERIES "$::caption(audace,menu,filtre_passe-bas)"    fun "FILTER kernel_type=fb"
      dict set SERIES "$::caption(audace,menu,filtre_passe-bas)"    hlp "$::help(dir,images) 1100passe_bas.htm"
      dict set SERIES "$::caption(audace,menu,filtre_passe-bas)"    par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_passe-bas)"    opt $options
      dict set SERIES "$::caption(audace,menu,filtre_passe-haut)"   fun "FILTER kernel_type=fh"
      dict set SERIES "$::caption(audace,menu,filtre_passe-haut)"   hlp "$::help(dir,images) 1110passe_haut.htm"
      dict set SERIES "$::caption(audace,menu,filtre_passe-haut)"   par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_passe-haut)"   opt $options
      dict set SERIES "$::caption(audace,menu,filtre_median)"       fun "FILTER kernel_type=med"
      dict set SERIES "$::caption(audace,menu,filtre_median)"       hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_median)"       par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_median)"       opt $options
      dict set SERIES "$::caption(audace,menu,filtre_mean)"         fun "FILTER kernel_type=mean"
      dict set SERIES "$::caption(audace,menu,filtre_mean)"         hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_mean)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_mean)"         opt $options
      dict set SERIES "$::caption(audace,menu,filtre_minimum)"      fun "FILTER kernel_type=min"
      dict set SERIES "$::caption(audace,menu,filtre_minimum)"      hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_minimum)"      par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_minimum)"      opt $options
      dict set SERIES "$::caption(audace,menu,filtre_maximum)"      fun "FILTER kernel_type=max"
      dict set SERIES "$::caption(audace,menu,filtre_maximum)"      hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_maximum)"      par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_maximum)"      opt $options
      dict set SERIES "$::caption(audace,menu,filtre_up)"           fun "FILTER kernel_type=gradup"
      dict set SERIES "$::caption(audace,menu,filtre_up)"           hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_up)"           par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_up)"           opt $options
      dict set SERIES "$::caption(audace,menu,filtre_left)"         fun "FILTER kernel_type=gradleft"
      dict set SERIES "$::caption(audace,menu,filtre_left)"         hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_left)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_left)"         opt $options
      dict set SERIES "$::caption(audace,menu,filtre_down)"         fun "FILTER kernel_type=graddown"
      dict set SERIES "$::caption(audace,menu,filtre_down)"         hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_down)"         par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_down)"         opt $options
      dict set SERIES "$::caption(audace,menu,filtre_right)"        fun "FILTER kernel_type=gradright"
      dict set SERIES "$::caption(audace,menu,filtre_right)"        hlp "$::help(dir,docLibtt) ttus1-fr.htm FILTER"
      dict set SERIES "$::caption(audace,menu,filtre_right)"        par "kernel_width 3 kernel_coef 0 threshold 0 type_threshold 0"
      dict set SERIES "$::caption(audace,menu,filtre_right)"        opt $options
      dict set SERIES "$::caption(audace,menu,filtre_gaussien)"     fun "CONV kernel_type=gaussian"
      dict set SERIES "$::caption(audace,menu,filtre_gaussien)"     hlp "$::help(dir,docLibtt) ttus1-fr.htm CONV"
      dict set SERIES "$::caption(audace,menu,filtre_gaussien)"     par ""
      dict set SERIES "$::caption(audace,menu,filtre_gaussien)"     opt "sigma 0.5 $options"
      dict set SERIES "$::caption(audace,menu,ond_morlet)"          fun "CONV kernel_type=morlet"
      dict set SERIES "$::caption(audace,menu,ond_morlet)"          hlp "$::help(dir,docLibtt) ttus1-fr.htm CONV"
      dict set SERIES "$::caption(audace,menu,ond_morlet)"          par ""
      dict set SERIES "$::caption(audace,menu,ond_morlet)"          opt "sigma 2. bitpix +16 skylevel 0 nullpixel 0."
      dict set SERIES "$::caption(audace,menu,ond_mexicain)"        fun "CONV kernel_type=mexican"
      dict set SERIES "$::caption(audace,menu,ond_mexicain)"        hlp "$::help(dir,docLibtt) ttus1-fr.htm CONV"
      dict set SERIES "$::caption(audace,menu,ond_mexicain)"        par ""
      dict set SERIES "$::caption(audace,menu,ond_mexicain)"        opt "sigma 2. bitpix +16 skylevel 0 nullpixel 0."
      dict set SERIES "$::caption(audace,menu,grad_rot)"            fun RGRADIENT
      dict set SERIES "$::caption(audace,menu,grad_rot)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm RGRADIENT"
      dict set SERIES "$::caption(audace,menu,grad_rot)"            par "xcenter 1. ycenter 1. radius 1. angle 1."
      dict set SERIES "$::caption(audace,menu,grad_rot)"            opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,radial)"              fun RADIAL
      dict set SERIES "$::caption(audace,menu,radial)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm RADIAL"
      dict set SERIES "$::caption(audace,menu,radial)"              par "sigma 10 power 2 xcenter 1. ycenter 1. radius 1."
      dict set SERIES "$::caption(audace,menu,radial)"              opt $options

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES qui effectuent des transformations
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::TRANSFORMFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Rectangulaire -> Polaire} {Polaire -> Rectangulaire} {Fonction de Hough}
   #  exemple 2
   #  [::prtr::TRANSFORMFunctions "Polaire -> Rectangulaire" ] retourne la liste des paramètres de la fonction :
   #  # REC2POL {x0 1. y0 1. scale_theta 1. scale_rho 1.} {bitpix +16 skylevel 0 nullpixel 0.} {doc/libtt ttus1-fr.htm REC2POL}
   #  @endcode
   #
   proc TRANSFORMFunctions {function} {
      variable SERIES

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$::caption(audace,menu,cart2pol)"            fun REC2POL
      dict set SERIES "$::caption(audace,menu,cart2pol)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm REC2POL"
      dict set SERIES "$::caption(audace,menu,cart2pol)"            par "x0 1. y0 1. scale_theta 1. scale_rho 1."
      dict set SERIES "$::caption(audace,menu,cart2pol)"            opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,pol2cart)"            fun POL2REC
      dict set SERIES "$::caption(audace,menu,pol2cart)"            hlp "$::help(dir,docLibtt) ttus1-fr.htm POL2REC"
      dict set SERIES "$::caption(audace,menu,pol2cart)"            par "x0 1.  y0 1. scale_theta 1. scale_rho 1. width 100 height 100"
      dict set SERIES "$::caption(audace,menu,pol2cart)"            opt "$options nullpixel 0."
      dict set SERIES "$::caption(audace,menu,hough)"               fun HOUGH
      dict set SERIES "$::caption(audace,menu,hough)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm HOUGH"
      dict set SERIES "$::caption(audace,menu,hough)"               par ""
      dict set SERIES "$::caption(audace,menu,hough)"               opt "threshold 0 binary 0 $options"
      dict set SERIES "$::caption(audace,menu,corners)"             fun CORNERS
      dict set SERIES "$::caption(audace,menu,corners)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm CORNERS"
      dict set SERIES "$::caption(audace,menu,corners)"             par "width 10 height 10"
      dict set SERIES "$::caption(audace,menu,corners)"             opt "$options"

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   ## @brief créé le dictionnaire des fonctions IMA/SERIES qui extrait des infomations numériques
   #  @param function 0 ou nom de la fonction (dans la langue de l'utilisateur)
   #  @return liste des fonctions affichées dans le menu
   #  ou liste des paramètres de construction de l'interface pour la fonction spécifiée
   #  @code
   #  exemple 1
   #  [::prtr::EXTRACTFunctions 0] retourne la liste des fonctions dans la langue de l'utilisateur :
   #  # {Une ligne} {Somme de lignes} {Médiane de lignes}
   #  exemple 2
   #  [::prtr::EXTRACTFunctions "Une ligne" ] retourne la liste des paramètres de la fonction :
   #  # {PROFILE direction=x} {offset 1 filename row} {bitpix +16 skylevel 0} {doc/libtt ttus1-fr.htm PROFILE}
   #  @endcode
   #
   proc EXTRACTFunctions {function} {
      variable SERIES

      set options "bitpix +16 skylevel 0"
      #--   l'option nullpixel est specifiee dans la fonction

      dict set SERIES "$::caption(audace,menu,ligne)"               fun "PROFILE direction=x"
      dict set SERIES "$::caption(audace,menu,ligne)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm PROFILE"
      dict set SERIES "$::caption(audace,menu,ligne)"               par "offset 1 filename row"
      dict set SERIES "$::caption(audace,menu,ligne)"               opt $options
      dict set SERIES "$::caption(audace,menu,bin_y)"               fun BINY
      dict set SERIES "$::caption(audace,menu,bin_y)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm BINY"
      dict set SERIES "$::caption(audace,menu,bin_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$::caption(audace,menu,bin_y)"               opt $options
      dict set SERIES "$::caption(audace,menu,med_y)"               fun "MEDIANY"
      dict set SERIES "$::caption(audace,menu,med_y)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm MEDIANY"
      dict set SERIES "$::caption(audace,menu,med_y)"               par "y1 1 y2 2 height 20"
      dict set SERIES "$::caption(audace,menu,med_y)"               opt $options
      dict set SERIES "$::caption(audace,menu,sort_y)"              fun "SORTY"
      dict set SERIES "$::caption(audace,menu,sort_y)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm SORTY"
      dict set SERIES "$::caption(audace,menu,sort_y)"              par "y1 1 y2 2 height 20 percent 50"
      dict set SERIES "$::caption(audace,menu,sort_y)"              opt $options
      dict set SERIES "$::caption(audace,menu,colonne)"             fun "PROFILE direction=y"
      dict set SERIES "$::caption(audace,menu,colonne)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm PROFILE"
      dict set SERIES "$::caption(audace,menu,colonne)"             par "offset 1 filename col"
      dict set SERIES "$::caption(audace,menu,colonne)"             opt $options
      dict set SERIES "$::caption(audace,menu,bin_x)"               fun BINX
      dict set SERIES "$::caption(audace,menu,bin_x)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm BINX"
      dict set SERIES "$::caption(audace,menu,bin_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$::caption(audace,menu,bin_x)"               opt $options
      dict set SERIES "$::caption(audace,menu,med_x)"               fun "MEDIANX"
      dict set SERIES "$::caption(audace,menu,med_x)"               hlp "$::help(dir,docLibtt) ttus1-fr.htm MEDIANX"
      dict set SERIES "$::caption(audace,menu,med_x)"               par "x1 1 x2 2 width 20"
      dict set SERIES "$::caption(audace,menu,med_x)"               opt $options
      dict set SERIES "$::caption(audace,menu,sort_x)"              fun "SORTX"
      dict set SERIES "$::caption(audace,menu,sort_x)"              hlp "$::help(dir,docLibtt) ttus1-fr.htm SORTX"
      dict set SERIES "$::caption(audace,menu,sort_x)"              par "x1 1 x2 2 width 20 percent 50"
      dict set SERIES "$::caption(audace,menu,sort_x)"              opt $options
      dict set SERIES "$::caption(audace,menu,matrice)"             fun MATRIX
      dict set SERIES "$::caption(audace,menu,matrice)"             hlp "$::help(dir,docLibtt) ttus1-fr.htm MATRIX"
      dict set SERIES "$::caption(audace,menu,matrice)"             par "x1 1 y1 1 x2 2 y2 2 filematrix matrice"
      dict set SERIES "$::caption(audace,menu,matrice)"             opt $options

      return [::prtr::consultDic SERIES $function]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::consultDic dico {0|nom_de_fonction}
   #  Consulte un dictionnaire
   #  Retourne la liste des fonctions ou des parametres de la fonction
   #--------------------------------------------------------------------------
   proc consultDic {dico function} {
      variable $dico

      upvar $dico dictionnaire
      if {$function ne 0} {
         foreach key {fun par opt hlp} {
            lappend result "[dict get $dictionnaire $function $key]"
         }
      } else {
         set result "[dict keys $dictionnaire]"
      }
      unset $dico

      return $result
   }

   #--------------------------------------------------------------------------
   #  ::prtr::searchFunction nom_de_fonction
   #  Recherche le dictionnaire de la fonction et affiche la liste dans le bouton de menu
   #--------------------------------------------------------------------------
   proc searchFunction {oper} {
      variable private

      set purDico {ARITHM CENTER EXTRACT FILTER IMPROVE MAITRE PILE PRETRAITEE TRANSFORM CALIB}
      set agregDico {ROTATION GEOMETRY}
      set private(fonctions) ""
      set private(ima) ""

      foreach dico $purDico {
         set fonctions [${dico}Functions 0]
         if {$oper in $fonctions} {
            set private(fonctions) "$fonctions"
            set private(ima) $dico
            break
         }
      }

      #--   si la liste des fonctions n'est pas identifiee
      if {$private(fonctions) eq "" && $private(ima) eq ""} {
         foreach dico $agregDico {
            set fonctions [${dico}Functions 0]
            append private(fonctions) $fonctions " "
            if {$oper in $fonctions} {
               set private(ima) $dico
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::consultDic getTypeVar
   #  Liste les parametres  avec les tests et le widget associes
   #  Consulte par une cmd [dict get $Var $child]
   #--------------------------------------------------------------------------
   proc getTypeVar {} {
      variable Var

      dict set Var   bitpix            "integer combobox"            ;#options IMA
      dict set Var   skylevel          "boolean checkbutton"         ;#options IMA
      dict set Var   nullpixel         "double labelentry"           ;#options IMA
      dict set Var   powernorm         "boolean checkbutton"         ;#PROD
      dict set Var   percent           "double 100 labelentry"       ;#IMA/STACK SORT
      dict set Var   kappa             "double labelentry"           ;#SK
      dict set Var   offset            "integer labelentry"          ;#OFFSET ADD SUB PROFILE
      dict set Var   constant          "double labelentry"           ;#MULT FLAT
      dict set Var   coef              "double labelentry"           ;#LOG
      dict set Var   offsetlog         "double labelentry"           ;#LOG
      dict set Var   back_threshold    "double 1. labelentry"        ;#BACK
      dict set Var   back_kernel       "integer 50 labelentry"       ;#BACK
      dict set Var   sub               "boolean checkbutton"         ;#BACK
      dict set Var   div               "boolean checkbutton"         ;#BACK
      dict set Var   binary            "boolean checkbutton"         ;#HOUGH
      dict set Var   normoffset_value  "double labelentry"           ;#NORMOFFSET FLAT
      dict set Var   normgain_value    "double labelentry"           ;#NORMGAIN
      dict set Var   unsmearing        "double labelentry"           ;#UNSMEARING
      dict set Var   cosmic_threshold  "double labelentry"           ;#COSMIC
      dict set Var   sigma             "double labelentry"           ;#CONV RADIAL
      dict set Var   radius            "double labelentry"           ;#RGRADIENT RADIAL NORMGAIN NORMOFFSET
      dict set Var   xcenter           "double labelentry"           ;#RGRADIENT RADIAL NORMGAIN NORMOFFSET
      dict set Var   ycenter           "double labelentry"           ;#RGRADIENT RADIAL NORMGAIN NORMOFFSET
      dict set Var   power             "double labelentry"           ;#RADIAL
      dict set Var   x0                "double naxis1 labelentry"    ;#ROT REC2POL POL2REC
      dict set Var   y0                "double naxis2 labelentry"    ;#ROT REC2POL POL2REC
      dict set Var   angle             "double labelentry"           ;#ROT ROTENTIERE RGRADIENT
      dict set Var   scale_rho         "double labelentry"           ;#REC2POL POL2REC
      dict set Var   scale_theta       "double labelentry"           ;#REC2POL POL2REC
      dict set Var   trans_x           "double labelentry"           ;#TRANS
      dict set Var   trans_y           "double labelentry"           ;#TRANS
      dict set Var   threshold         "double labelentry"           ;#HOUGH
      dict set Var   therm_kappa       "double labelentry"           ;#OPT
      dict set Var   x1                "integer naxis1 labelentry"   ;#WINDOW BINX MATRIX MEDIANX SORTX
      dict set Var   y1                "integer naxis2 labelentry"   ;#WINDOW BINY MATRIX MEDIANY SORTY
      dict set Var   x2                "integer naxis1 labelentry"   ;#WINDOW BINX MATRIX MEDIANX SORTX
      dict set Var   y2                "integer naxis2 labelentry"   ;#WINDOW BINY MATRIX MEDIANY SORTY
      dict set Var   width             "integer naxis1 labelentry"   ;#BINX POL2REC MEDIANX SORTX RESIZE CORNERS
      dict set Var   height            "integer naxis2 labelentry"   ;#BINY POL2REC MEDIANY SORTY RESIZE CORNERS
      dict set Var   normaflux         "double labelentry"           ;#RESAMPLE REGISTER
      dict set Var   paramresample     "liste labelentry"            ;#RESAMPLE
      dict set Var   filename          "filename labelentry"         ;#PROFILE
      dict set Var   filematrix        "filename labelentry"         ;#MATRIX
      dict set Var   file              "img labelentry"              ;#ADD SUB DIV PROD REGISTERFINE
      dict set Var   bias              "img labelentry"              ;#OPT FLAT PRETRAITEMENT
      dict set Var   dark              "img labelentry"              ;#OPT FLAT PRETRAITEMENT
      dict set Var   flat              "img labelentry"              ;#PRETRAITEMENT
      dict set Var   mini              "double labelentry"           ;#CLIP
      dict set Var   maxi              "double labelentry"           ;#CLIP
      dict set Var   opt_black         "boolean checkbutton"         ;#PRETRAITEMENT
      dict set Var   methode           "boolean radiobutton"         ;#DARK
      dict set Var   plan              "boolean radiobutton"         ;#INTERCORRELATION
      dict set Var   kernel_width      "integer combobox"            ;#FILTER
      dict set Var   kernel_coef       "integer combobox"            ;#FILTER
      dict set Var   type_threshold    "integer combobox"            ;#FILTER
      dict set Var   image_ref         "img labelentry"              ;#CENTER
      dict set Var   matchwcs          "boolean checkbutton"         ;#REGISTER
      dict set Var   translate         "alpha combobox"              ;#REGISTER
      dict set Var   delta             "integer labelentry"          ;#REGISTERFINE
      dict set Var   oversampling      "integer labelentry"          ;#REGISTERFINE DRIZZLEWCS
      dict set Var   drop_sizepix      "double labelentry"           ;#DRIZZLEWCS
      dict set Var   ra                "double 360 labelentry"       ;#CALIBWCS
      dict set Var   dec               "double 90 labelentry"        ;#CALIBWCS
      dict set Var   pixsize1          "double labelentry"           ;#CALIBWCS
      dict set Var   pixsize2          "double labelentry"           ;#CALIBWCS
      dict set Var   foclen            "double labelentry"           ;#CALIBWCS
      dict set Var   crota2            "double 360 labelentry"       ;#CALIBWCS
      dict set Var   astromcatalog     "alpha combobox"              ;#CALIBWCS
      dict set Var   hot_pixel_list    "liste labelentry"            ;#HOTPIXEL
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdVerif
   #  Verifie les donnees saisies : nb de selections, nom de sortie, parametres numeriques
   #  Produit options formatees pour le scriptTT
   #  Retourne options si pas d'erreur, sinon 0
   #--------------------------------------------------------------------------
   proc cmdVerif {} {
      variable private

      set nb_images "1"
      #--   pour ces fonctions il faut au moins 2 images
      if {$private(ima) in [list MAITRE PILE]} {set nb_images "2"}

      #--   nb d'images est inferieur au seuil ?
      if {![info exists private(todo)] || [llength $private(todo)] < $nb_images} {
         return [::prtr::avertiUser err_file_nb $nb_images]
      }

      #--   nom de sortie defini ?
      if {$private(function) ni [list "PROFILE direction=x" "PROFILE direction=y" "MATRIX"]} {

         if {$prtr::out eq "" || $prtr::out eq "\"\""} {
            return [::prtr::avertiUser sortie_generique]
         }

         #--   separe les elements
         lassign [::prtr::getInfoFile $::prtr::out] dir ::prtr::generique extension

         if {![file exists $dir]} {
            return [::prtr::avertiUser err_file_dir $dir]
         } else {
            set ::prtr::dir_out $dir
         }

         #--   verifie l'extension si l'utilisateur en a donnee une
         if {$extension ne "" && $extension ne "$::prtr::ext"} {
            return [::prtr::avertiUser err_file_ext "$prtr::out" "$::prtr::ext"]
         }

         if {$::prtr::generique ne ""} {
            #--   nom_court correct ?
            regexp -all {[\w_-]+} $::prtr::generique match
            if {![ info exists match] || $match ne $::prtr::generique} {
               return [::prtr::avertiUser err_file_generique]
            }
         } elseif {$::prtr::generique eq "" && $private(function) ne "CALIBWCS"} {
            return [::prtr::avertiUser err_file_generique]
         }

      } else {
         set ::prtr::dir_out "./"
         set ::prtr::out ""
         #--      definit le nom de sortie comme le premier de la liste
         set ::prtr::generique "[lindex $private(todo) 0]"
      }

      set options " "
      foreach type {obligatoire optionnel} val {1 0} {
         #--   si la liste n'existe pas, passe a la liste suivante
         if {![ info exists private($type)]} {continue}
         if {$options == "0"} {break}
         #--   isole la liste
         set content $private($type)
         set l [llength $content]
         for {set i 0} {$i < $l} {incr i} {
            #--   extrait le parametre
            set parametre [lindex $content $i]
            set res [cmdTestVariable $parametre $val]
            switch $res {
                  "0"      {set options 0 ; #--    une erreur}
                  ""       {#--parametre optionnel non pris en compte}
                  default  {append options " $res" ;#--   bonne valeur}
            }
            if {$options == "0"} {break}
         }
      }
      return $options
   }

   #--------------------------------------------------------------------------
   # ::prtr::cmdTestVariable nom_du_parametre {1=obligatoire | 0=optionnel}
   # Teste la valeur associe a un parametre
   # Retourne : 0 si erreur, parametre=$valeur si test ok, rien si parametre optionnel inchange
   #--------------------------------------------------------------------------
   proc cmdTestVariable {parametre obl} {
      variable Var
      variable bd
      variable private

      #--   recupere la nature du test et la valeur par defaut du parametre
      foreach {test seuil} [lrange [dict get $Var $parametre] 0 end-1] {break}

      #--   capture la valeur du parametre
      namespace upvar ::prtr:: $parametre value

      #--   si parametre optionnel, compare la valeur a la valeur par defaut
      #--   arrete si les deux valeurs sont identiques car non pris en compte
      if {$obl eq "0"} {
         set index [lsearch $private(l_optionnel) $parametre]
         incr index
         if { [lindex $private(l_optionnel) $index] eq "$value"} {
            return ""
         }
      }

      #--   teste si une valeur existe
      if {$value eq ""} {
         #--   teste un parametre alphanumerique
         if {$parametre ni [list bias dark flat hot_pixel_list]} {
            return [::prtr::avertiUser err_par_def $parametre ]
         } else {
            return ""
         }
      }

      if {$test == "boolean"} {
         #--   teste un parametre booleen
         if {$value == "1"} {
            if {$parametre eq "opt_black" && ($::prtr::bias eq "" || $::prtr::dark eq "")} {
               return [::prtr::avertiUser err_opt_noir $parametre]
            } else {
               return "$parametre"
            }
         } elseif {$value in [list r g b]} {
            return "$parametre=$value"
         }
      } elseif {$test eq "alpha"} {
         #--   teste un parametre alphanumerique (astromcatalog et translate)
         if {![string is $test -strict $value]} {
            return [::prtr::avertiUser err_par_type $parametre $test]
         }
         return "$parametre=$value"
      } elseif {$test in {double integer}} {
         #--   teste la nature de la variable
         if {![string is $test -strict $value]} {
            return [::prtr::avertiUser err_par_type $parametre $test]
         }
         if {$seuil eq ""} {
            #--   si pas controle dimensionnel
            return "$parametre=$value"
         } else {
            #--   si controle dimmensionnel
            if {$parametre ne "dec"} {
               set mini "0"
            } else {
               #--   seuil mini de DEC
               set mini "-90"
            }
            if {$seuil in {naxis1 naxis2}} {
               #--   extrait le nom de la premiere image, naxis1 et naxis2
               set img [lindex $private(todo) 0]
               set info [lindex [array get bd $img] 1]
               foreach {nihil nihil naxis1 naxis2} $info {break}
               switch $seuil "naxis1" "set seuil $naxis1" "naxis2" "set seuil $naxis2" "default" ""
               set mini "1"
            }
            if {$value < $mini || $value > $seuil && $private(function) ni [list POL2REC RESIZE]} {
               return [::prtr::avertiUser err_par_bornes $parametre]
            } else {
               return "$parametre=$value"
            }
         }
      } elseif {$test in {filename filematrix}} {
         #--   teste si le nom est valide (filename filematrix)
         regexp -all {[\w_-]+} $value match
         if {[info exists match] && $value eq "$match"} {
            #--   cas du nom d'un fichier .txt
            return "\"$parametre=$value.txt\""
         } else {
            return [::prtr::avertiUser err_par_def $value]
         }
      } elseif {$test eq "img"} {
         #--   teste le nom d'une image (file bias dark et flat)
         lassign [::prtr::getInfoFile $value] dir nom_court extension

         #--   verifie l'extension
         if {$extension ne "$::conf(extension,defaut)" && $extension ne "$::conf(extension,defaut).gz"} {
            return [::prtr::avertiUser err_file_ext $parametre $::conf(extension,defaut)]
         }
         #--   verifie son orthographe
         regexp -all {[\w_-]+} $nom_court match
         if {![info exists match] || $nom_court ne "$match"} {
            return [::prtr::avertiUser err_par_name $parametre]
         }

         set row [lsearch [$private(tbl) getcolumns 1] $nom_court]
         if {$row >=0} {
            if {[lrange [$private(tbl) get $row] 2 end] eq $private(profil)} {
               #--   l'image est du meme type que celles selectionnee
               if {$nom_court in $private(todo)} {
                  #--   cas ou l'image deja ete selectionnee
                  #--   juste un message d'avertissement
                  ::prtr::avertiUser err_file_select $value
               }
               return "$parametre=$nom_court$extension"
            } else {
               #--   cas du fichier de type different
               return [::prtr::avertiUser err_file_type $parametre]
            }
         } else {
           #--   l'image vient d'un autre repertoire
            #--   verifie si elle existe
            if {![file exists $value]} {
               return [::prtr::avertiUser err_no_file $value]
            }

            #--   verifie les dimensions des images
            lassign [::prtr::analyseFitsHeader $value] naxis naxis3 naxis1 naxis2
            #--   test non valable pour POL2REC
            if {[lindex $private(profil) 1] ne "${naxis1} X ${naxis2}" && $private(function) ne "POL2REC"} {
              return [::prtr::avertiUser err_file_dim $value]
            }

            if {$naxis eq "2"} {
               set type "M"
            } elseif {$naxis eq "3" && $naxis eq "3"} {
               set type "C"
            }

            switch $private(function) {
               OPT      {  #--   verifie que l'image est de meme nature que l'image d'entree
                           if {$type ne "[lindex $private(profil) 0]"} {
                              return [::prtr::avertiUser err_file_type $parametre]
                           }
                        }
               MAITRE   {  #--   verifie que l'image n'est pas une image RGB
                           if {$naxis eq "3" && $naxis3 eq "3"} {
                              return [::prtr::avertiUser err_par_file $parametre]
                           }
                        }
               CENTER   {  #--   verifie que l'image n'est pas une image RGB
                           if {$naxis eq "3" && $naxis3 eq "3"} {
                              return [::prtr::avertiUser err_par_file $parametre]
                           }
                        }
            }

            return "\"$parametre=$value\""
         }
      } elseif {$test eq "liste"} {
         if {$parametre eq "paramresample"} {
            #--   teste paramresample
            #--   il doit y avoir exactement 6 parametres
            if {[llength $value] ne 6 } {
               return [::prtr::avertiUser err_par_def $parametre]
            }
            #--   tous les parametres doivent etre numeriques
            blt::vector create temp -watchunset 1
            if {[catch {temp append $value}]} {
               blt::vector destroy temp
               return [::prtr::avertiUser err_par_def $parametre]
            }
            #--   teste les valeurs
            if {[expr {$temp(1)*$temp(3)-$temp(0)*$temp(4)}] == "0"} {
               blt::vector destroy temp
               return [::prtr::avertiUser err_list_val $parametre]
            }
            blt::vector destroy temp
            return "\"paramresample=$value\""
         } else {
            #--   teste hot_pixel_list
            set error 0
            set result ""
            regsub -all "X" [lindex $private(profil) 1] "" naxis
            lassign $naxis naxis1 naxis2

            foreach point [lsearch -exact -all $value "P"] {
               #--   compare les deux valeurs suivantes a un entier
               set v1 [lindex $value [expr { $point+1 }]]
               set v2 [lindex $value [expr { $point+2 }]]
               if {[string is integer -strict $v1] && [string is integer -strict $v2] \
                  && $v1 <= $naxis1 && $v2 <= $naxis2} {
                  append result "P $v1 $v2 "
               } else {
                  set error 1
               }
            }
            foreach li [lsearch -exact -all $value "L"] {
               #--   compare la valeur suivante a un entier
               set v [lindex $value [expr { $li+1 }]]
               if {[string is integer -strict $v] && $v <= $naxis2} {
                  append result "L $v "
               } else {
                  set error 1
               }
            }
            foreach col [lsearch -exact -all $value "C"] {
               #--   compare la valeur suivante a un entier
               set v [lindex $value [expr { $col+1 }]]
               if {[string is integer -strict $v] && $v <= $naxis1} {
                  append result "C $v "
               } else {
                  set error 1
               }
            }
            if {$error == 0} {
               return "\"hot_pixel_list=$result\""
            } else {
               return [::prtr::avertiUser err_list_val $parametre]
            }
         }
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getInfoFile file
   #  Retourne le directory, le nom court et l'extension suivie ou non de .gz
   #--------------------------------------------------------------------------
   proc getInfoFile {file} {

      set nom_court ""
      set extensions ""
      if {[file isdirectory "$file"]} {
         set dir "$file"
      } else {
         set dir [file dirname $file]
         if {$dir eq "."} {append dir /}
         set nom_avec_extensions "[file tail $file]"
         #--   extrait l'extension
         set extensions ""
         regexp {(\.[a-zA-Z]{3,4}|\.[a-zA-Z]{3,4}.gz)} $nom_avec_extensions extensions
         #--   ote toutes les extensions du nom
         regsub "$extensions" $nom_avec_extensions "" nom_court
      }

      return [list $dir $nom_court $extensions]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdExec data options
   #  Exemple ::prtr::cmdExec [ list "IMA/SERIES" "$liste_generique_avec_index" "$nom_sortie" "ADD" "bitpix=16" ]
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdExec { data options } {

      set dir  $::audace(rep_images)
      cd $dir
      foreach {select imgList dirOut nameOut extIn function} $data {break}

      #--   fonctions necessitant une indexation de parametres en .fit ou .txt
      set filtre_file [list ADD SUB DIV PROD OPT]
      set filtre_txt [list "PROFILE direction=x" "PROFILE direction=y" MATRIX]
      set filtres [concat $filtre_file $filtre_txt]
      set nb_img [llength $imgList]

      #--   sauvegarde des parametres utilisateur
      if {$function eq "BACK"} {
         foreach var {back_kernel back_threshold} {
            set result [lsearch -regexp -inline $options "${var}"]
            regsub "${var}=" $result "" ::conf(prtr,back,$var)
         }
      } elseif {$function eq "RESAMPLE"} {
         set result [lsearch -regexp -inline $options "paramresample"]
         regsub "paramresample=" $result "" ::conf(prtr,resample,paramresample)
      } elseif {$function eq "SK"} {
         set result [lsearch -regexp -inline $options "kappa"]
         regsub "kappa=" $result "" ::conf(prtr,sk,kappa)
      }

      #--   identifie le type d'images
      set type [::prtr::getImgType $imgList]

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extIn
      } else {
         set to_compress ""
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      if {$type eq "C"} {
         foreach file $imgList {
           ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
         set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      set indiceOut "."
      #--   si plusieurs images de sortie
      if {$select eq "IMA/SERIES" && $nb_img ne "1"} {set indiceOut "1"}

      #--   RGB2R+G+B des images RGB passees en parametres
      if {$select eq "IMA/SERIES" && $function in {ADD SUB DIV PROD REGISTERFINE} && $type == "C"} {
         set data [::prtr::traiteImg $options file]
         set options [lindex $data 0]
         set img [lindex $data 1]
         ::prtr::decompRGB $img
          #--   ajoute l'image si elle a ete copiee
         if {[file dirname [lindex $data 2]] ne "$::audace(rep_images)" && [file dirname [lindex $data 2]] ne "."} {
            lappend to_destroy $img
         }
         #--   ajoute les plans couleurs issus de la conversion
         lappend to_destroy ${img}r ${img}g ${img}b
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]
      if {[string index $options 0] eq " "} {
         set options [string range $options 1 end]
      }

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "$ext" $options "${color}$ext" options
               regsub -all ".txt" $options "${color}.txt" options
            }

            if {$function ni [list "REGISTER translate=never" "REGISTER translate=before"]} {

               set script "$select . \"$file_type\" * * $ext \"$rep\" $file_out $indiceOut $ext $function $options"
               ::prtr::editScript $script
               ttscript2 $script

            } else {

               set n [llength "$file_type"]
               set index [lsearch -regexp $options "normaflux"]
               incr index
               set options1 "[lrange $options $index end]"

               set objefile "dummy"
               set script1 "IMA/SERIES . \"$file_type\" * * $ext . \"$objefile\" 1 $ext STAT objefile $options1"
               set script2 "IMA/SERIES . \"$objefile\" 1 $n $ext . $file_out 1 $ext $function $options"
               set script3 "IMA/SERIES . \"$objefile\" 1 $n $ext . . . . DELETE"
               foreach script {script1 script2 script3} {
                  ::prtr::editScript [set $script]
                  ttscript2 [set $script]
               }
               file delete com.lst dif.lst eq.lst in.lst ref.lst xy.lst
            }

            if {($type eq "C") && ($select eq "IMA/SERIES") && ($function in $filtres)} {
               regsub -all "(r|g|b)$ext" $options "$ext" options
               regsub -all "(r|g|b)\.txt" $options ".txt" options
            }

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree et les fichiers de sortie
         if {$::conf(fichier,compres) eq "1"} {
            foreach file $to_compress {gzip $file}
            set ext "$ext.gz"
         }

         #--   efface les plans couleurs des images entrantes
         if {[info exists to_destroy]} {
           ttscript2 "IMA/SERIES . \"$to_destroy\" * * $ext . . . . DELETE"
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::traiteImg options p
   #  Copie l'image operande et modifie le parametre file en consequence
   #  Retourne una liste raccourcie des options et le nom generique du fichier
   #  Lancee par cmdExec
   #--------------------------------------------------------------------------
   proc traiteImg {options p} {

      #--   cherche le rang du parametre "$p="
      set pattern "$p="
      set k [lsearch -regexp $options $pattern]
      #--   extrait tout le parametre
      set param [lindex $options $k]
      #--   extrait le nom complet du fichier
      regsub ($pattern) $param "" file
      set ext [file extension $file]
      set generique [file rootname [file tail $file]]
      #--   recopie le fichier dans rep_images
      if {[file dirname $file] ni [list "$::audace(rep_images)" "."]} {
         file copy -force $file $::audace(rep_images)
      }
      #--   remplace le parametre dans options
      set options [lreplace $options $k $k "$pattern$generique$ext"]
      return [list $options $generique $file]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::decompRGB file
   #  Decompose l'image couleur en plans couleurs
   #--------------------------------------------------------------------------
   proc decompRGB {file} {

      set ext $::prtr::ext
      set nom_sans_extension [file join $::audace(rep_images) $file]
      ::conv2::Do_rgb2r+g+b $nom_sans_extension$ext $nom_sans_extension
   }

   #--------------------------------------------------------------------------
   #  ::prtr::convertitRGB nameOut
   #  Reconstitue l'image couleur et efface les plans couleurs
   #  Parametre : nom de sortie (avec ou sans indice) de l'image
   #--------------------------------------------------------------------------
   proc convertitRGB {nameOut} {

      set file [file rootname $nameOut]
      set ext [file extension $nameOut]
      #--   convertit les plans couleurs en RGB
      ::conv2::Do_r+g+b2rgb $file $file
      #--   efface les plans couleurs
      file delete ${file}r$ext ${file}g$ext ${file}b$ext
   }

   #--------------------------------------------------------------------------
   #  ::prtr::getImgType files
   #  Definit le type d'image a traiter
   #  Retourne : {C|M|error} ;C pour couleur, M pour monochrome
   #  Lancee par ::prtr::cmdApply
   #--------------------------------------------------------------------------
   proc getImgType { files } {
      variable private
      variable bd

      #--   accelere pour le cas particulier d'une image isolee
      if {[llength $files] eq "1"} {
         set w "$private(tbl)"
         set k [lsearch [$w getcolumns 1] $files]
         return "[$w cellcget $k,2 -text]"
      }

      blt::vector create Vnaxis Vnaxis3 -watchunset 1
      foreach file $files {
         foreach {naxis naxis3} [lindex [array get bd $file] 1] {break}
         Vnaxis append $naxis
         if {$naxis3 ne ""} {
            Vnaxis3 append $naxis3
         }
      }
      switch [Vnaxis3 length] 0 {set type "M"} [Vnaxis length] {set type "C"} default {set type "error"}
      blt::vector destroy Vnaxis Vnaxis3
      return $type
   }

   #--------------------------------------------------------------------------
   #  ::prtr::convertBitPix2BitPix {8|16|+16|32|+32|-32|-64}
   #  Convertit bitpix de TT vers bitpix pour buf
   #--------------------------------------------------------------------------
   proc convertBitPix2BitPix {bitpix} {

      set convert [list byte 8 short 16 ushort +16 long 32 ulong +32 float -32 double -64]
      set k [lsearch $convert $bitpix]
      incr k "-1"
      return [lindex $convert $k]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::clipMinMax data options
   #  Ex-tournement de multi-ecreter
   #--------------------------------------------------------------------------
   proc clipMinMax { data options } {

      lassign $data imgList dirOut nameOut extOut
      set l [llength $imgList]

      if {$dirOut eq "."} {set dirOut $::audace(rep_images)}

      #---  extrait les valeurs numeriques
      foreach type {mini maxi bitpix} {
        lassign [::prtr::extractData $options "$type"] options $type
      }
      set bitpix [::prtr::convertBitPix2BitPix $bitpix]

      #--   sauvegarde les reglages utilisateurs
      set ::conf(prtr,clip,clip_mini) $mini
      set ::conf(prtr,clip,clip_maxi) $maxi

      set catchError [catch {

         set buf_clip [::buf::create]
         buf$buf_clip extension $extOut
         if {$bitpix ne ""} {buf$buf_clip bitpix $bitpix}
         set l [llength $imgList]

         buf$buf_clip load  [file join $dirOut [lindex $imgList 0]$extOut]
         #--   identifie le type d'images
         foreach kwd {NAXIS NAXIS3} {
            set [string tolower $kwd] [lindex [buf$buf_clip getkwd $kwd] 1]
         }

         set type M
         if {$naxis eq "3" && $naxis eq "3"} {set type C}

         foreach in $imgList {
            set index [lsearch $imgList $imgList]
            #--   decompose l'image RGB
            if {$type eq "C"} {
               ::prtr::decompRGB $in
               foreach color {r g b} {
                  buf$buf_clip load [file join $dirOut $imgList$color$extOut]
                  buf$buf_clip clipmin $mini
                  buf$buf_clip clipmax $maxi
                  if {$l == "1"} {
                     set nameOut [file join $dirOut $nameOut]
                  } else {
                     set nameOut [file join $dirOut $nameOut$index]
                  }
                  buf$buf_clip save $nameOut$color$extOut
               }
               #--   convertit en RGB
               ::prtr::convertitRGB $nameOut$extOut
               #--   efface les plans couleurs intermediaires
               file delete [file join $dirOut ${imgList}r$extOut] [file join $dirOut ${imgList}g$extOut] \
                  [file join $dirOut ${imgList}b$extOut]
            }  else {
               buf$buf_clip load [file join $dirOut $imgList$extOut]
               buf$buf_clip clipmin $mini
               buf$buf_clip clipmax $maxi
               if {$l == "1"} {
                  set nameOut [file join $dirOut $nameOut]
               } else {
                  set nameOut [file join $dirOut $nameOut$index]
               }
               buf$buf_clip save $nameOut$extOut
            }
         }
         ::buf::delete $buf_clip
      } ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdRot data options
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdRot { data options } {

      set dir $::audace(rep_images)
      cd $dir
      foreach {imgList dirOut nameOut extIn function} $data {break}
      set nb_img [llength $imgList]

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extIn
      } else {
         set to_compress ""
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      #--   identifie le type d'images
      set b [::buf::create]
      buf$b load [lindex $imgList 0]$extIn
      foreach kwd {NAXIS NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }
      ::buf::delete $b

      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      if {$type eq "C"} {
         foreach file $imgList {
            ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
         set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      if {$nb_img eq "1"} {
         set indiceOut "."
         set indFinal "."
      } else {
         set indiceOut "1"
         set indFinal $nb_img
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}

            switch -exact $function {
               "ROT+90" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT xy $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT flip $options"
                        }
               "ROT180" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT mirror $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT flip $options"
                        }
               "ROT-90" {  set script1 "IMA/SERIES . \"$file_type\" * * $ext . temp $indiceOut $ext INVERT flip $options"
                           set script2 "IMA/SERIES . temp $indiceOut $indFinal $ext \"$rep\" $file_out $indiceOut $ext INVERT xy $options"
                        }
            }

            if {$nb_img eq "1"} {
               lappend to_destroy temp
            } else {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  lappend to_destroy temp$i
               }
            }

            ::prtr::editScript $script1
            ttscript2 $script1
            ::prtr::editScript $script2
            ttscript2 $script2

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree
         if {$::conf(fichier,compres) eq "1"} {
            foreach file $to_compress {gzip $file}
            set ext "$ext.gz"
         }

         #--   efface les plans couleurs des images entrantes
         if {[info exists to_destroy]} {
           ttscript2 "IMA/SERIES . \"$to_destroy\" * * $ext . . . . DELETE"
         }

      }  ErrInfo]
     if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdMasqueFlou data options
   #  Procedure lancee par le bouton Appliquer
   #--------------------------------------------------------------------------
   proc cmdMasqueFlou { data options } {

      set dir  $::audace(rep_images)
      cd $dir
      foreach {imgList dirOut nameOut extOut} $data {break}
      set nb_img [llength $imgList]

      set b [::buf::create]
      buf$b load [lindex $imgList 0]
      foreach kwd {NAXIS NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }
      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      ::buf::delete $b

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extOut
      } else {
         set to_compress ""
         regsub ".gz" $extOut "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extOut
            #--   prepare la liste des compressions
            lappend to_compress [file join $dir $img$ext]
         }
      }

      #--   examine chaque fichier et
      #--   constitue la liste des nom en entree et en sortie
      if {$type eq "C"} {
         foreach file $imgList {
            ::prtr::decompRGB $file
            #--   liste les fichiers a traiter
            foreach k {r g b} {
               lappend list_$k ${file}$k
               lappend to_destroy ${file}$k
            }
         }
         set list_in [list "$list_r" "$list_g" "$list_b"]
         set list_out [list ${nameOut}r ${nameOut}g ${nameOut}b]
      } else {
        set gray "$imgList"
         set list_in [list $gray]
         set list_out [list $nameOut]
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   gere les indices de sortie
      set indiceOut "."
      #--   si plusieurs images de sortie
      if {$nb_img eq "1"} {
         set indiceOut "."
         set indFinal "."
      } else {
         set indiceOut "1"
         set indFinal $nb_img
      }

      #--   fixe le generique de sortie sans indice ni plan couleur ni extension
      set racine [file join $rep $nameOut]

      #--   extrait la valeur de sigma
      lassign [::prtr::extractData $options sigma] options sigma

      #--   extrait la valeur de la constante multiplicative
      lassign [::prtr::extractData $options constant] options constant

      #--   sauvegarde les reglages utilisateurs
      set ::conf(prtr,flou,sigma) $sigma
      set ::conf(prtr,flou,constant) $constant

      #--   il ne reste dans options que les options TT classiques (bitpix, skylevel, nullpixel)

      set catchError [catch {

         foreach file_type $list_in file_out $list_out {

            if {$type eq "C"} {set color [string index [lindex $file_type 0] end]}
            set script1 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext CONV kernel_type=gaussian sigma=$sigma $options"
            set script2 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext SUB \"file=./$file_out\" $options"
            set script3 "IMA/SERIES . \"$file_out\" $indiceOut $indFinal $ext . $file_out $indiceOut $ext MULT constant=$constant $options"
            set script4 "IMA/SERIES . \"$file_type\" * * $ext . $file_out $indiceOut $ext ADD \"file=./$file_out\" $options"

            ::prtr::editScript $script1
            ttscript2 $script1
            ::prtr::editScript $script2
            ttscript2 $script3
            ::prtr::editScript $script3
            ttscript2 $script3
            ::prtr::editScript $script4
            ttscript2 $script4

            if {$type eq "C" && $indiceOut eq "1"} {
               for {set i 1} {$i <= $nb_img} {incr i} {
                  #--   intervertit le nom du plan et l'indice
                  file rename -force "$racine$color$i$ext" "$racine$i$color$ext"
               }
            }
         }

         #--   convertir en RGB
         if {$indiceOut eq "."} {
            if {$type eq "C"} {::prtr::convertitRGB $racine$ext}
         } else {
            for {set i 1} {$i <= $nb_img} {incr i} {
               if {$type eq "C"} {::prtr::convertitRGB $racine$i$ext}
            }
         }

         #--   recompresse les fichiers d'entree
         if {$::conf(fichier,compres) eq "1"} {
            foreach file $to_compress {gzip $file}
            set ext "$ext.gz"
         }

         #--   efface les plans couleurs des images entrantes
         if {[info exists to_destroy]} {
           ttscript2 "IMA/SERIES . \"$to_destroy\" * * $ext . . . . DELETE"
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}

      return $catchError
   }

   #----------------------fonctions du pretraitement--------------------------

   #--------------------------------------------------------------------------
   #  ::prtr::faireOffset data options
   #  Fait la mediane des images d'offset
   #  Parmetres : donnees du script, options TT sous forme de listes
   #--------------------------------------------------------------------------
   proc faireOffset { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn

      set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" .  $extOut MED"
      if {$options ne ""} {append script " " $options}
      ::prtr::editScript $script
      set catchError [catch {ttscript2 $script} ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireDark data options
   #  Applique la methode choisie apres soustraction de l'offset s'il existe
   #  Parmetres : donnees du script, options T sous forme de listes
   #--------------------------------------------------------------------------
   proc faireDark { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn methode
      set l [llength $imgList]

      #--   cherche le nom de l'offset
      lassign [::prtr::extractData $options "bias"] options bias

      if {$bias eq ""} {::prtr::informeUser "faire_dark" "faire_offset"}

      set catchError [catch {
         if {$bias ne ""} {

            #--   soustrait l'offset des images
            set script "IMA/SERIES . \"$imgList\" * * $extIn . temp 1 $extOut SUB \"file=$bias\" "
            ::prtr::editScript $script
            ttscript2 "$script"

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]

            #--   change l'extension des fichiers entrants
            set extIn $::conf(extension,defaut)
         }

         set script "IMA/STACK . \"$imgList\" * * $extIn \"$dirOut\" \"$nameOut\" . $extOut $methode"
         if {$options ne ""} {append script " " $options}
         ::prtr::editScript $script
         ttscript2 $script

         #--   detruit les fichiers temporaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            ttscript2 "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
         }

      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireFlat data options
   #--------------------------------------------------------------------------
   proc faireFlat { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]

      #--   isole le nom complet de l'image d'offset et de dark
      foreach type {bias dark} {
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$bias eq ""} {::prtr::informeUser "faire_flat_field" "faire_offset"}
      if {$dark eq ""} {::prtr::informeUser "faire_flat_field" "faire_dark"}

      #--   cree l'image Offset+Dark si l'offset et/ou le dark existe
      if {$dark ne "" || $bias ne ""} {
         if {[::prtr::createOffset+Dark $dark $bias] ne "0"} {return 1}

         set file Offset+Dark$extOut

         if {[file exists $file]} {
            if {[::prtr::subsOffset+Dark $data $file] ne "0"} {return 1}

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]

            #--   extrait la valeur de normalisation de l'offset
            lassign [::prtr::extractData $options "normoffset_value"] options opt

            #--   normalise l'offset
            set script "IMA/SERIES . \"$imgList\" * * $extOut . temp 1 $extOut NORMOFFSET normoffset_value=$opt"
            ::prtr::editScript $script
            ttscript2 "$script"
            set extIn $extOut
         }
      }

      set catchError [catch {

         set script "IMA/STACK . \"$imgList\" * * $extOut \"$dirOut\" $nameOut . $extOut MED "
         if {$options ne ""} {append script "$options"}
         ::prtr::editScript $script
         ttscript2 "$script"

         #--   supprime les fichiers intermediaires
         if {[lsearch -regexp $imgList temp] >= "0"} {
            ttscript2 "IMA/SERIES . \"$imgList\" * * $extOut . . . . DELETE"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::faireOptNoir data options
   #  Pretraitement avec optimisation du noir,
   #  suivi d'un division par le flat et d'une multiplication par la constante
   #--------------------------------------------------------------------------
   proc faireOptNoir { data options } {
      variable private

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set l [llength $imgList]
      if {$l eq "1"} {
         lassign [list . . ] indexIn indexOut
      } else {
         lassign [list * 1 ] indexIn indexOut
      }

      #--   ote opt_black des options
      lassign [::prtr::extractData $options "opt_black"] options opt

      #--   extrait le nom des fichiers operandes
      foreach type {bias dark flat} {
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$flat eq ""} {::prtr::informeUser "pretraitee" "faire_flat_field"}

      set catchError [catch {
         #--   cree les images optimisees dans le repertoire de destination
         set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut OPT \"bias=$bias\" \"dark=$dark\" "
         ::prtr::editScript $script
         ttscript2 "$script"

         #--   divise les images par le flat s'il existe et multiplie par la constante
         if {$flat ne ""} {

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList $nameOut $l]

            #--   divise les images par le flat
            set script "IMA/SERIES \"$dirOut\" \"$imgList\" $indexIn $indexIn $extOut \"$dirOut\" $nameOut $extOut $extOut DIV \"file=$flat\" $options"
            ::prtr::editScript $script
            ttscript2 "$script"
         }
      }  ErrInfo]
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::fairePretraitement data options
   #  Prétraitement sans optimisation du noir
   #--------------------------------------------------------------------------
   proc fairePretraitement  { data options } {
      variable private

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn

      set l [llength $imgList]
      if {$l eq "1"} {
         lassign [list . . ] indexIn indexOut
      } else {
         lassign [list * 1 ] indexIn indexOut
      }

      #--   extrait le nom des fichiers operandes
      foreach type {bias dark flat} {
        lassign [::prtr::extractData $options "$type"] options $type
      }

      if {$bias eq ""} {::prtr::informeUser "pretraitee" "faire_offset"}
      if {$dark eq ""} {::prtr::informeUser "pretraitee" "faire_dark"}
      if {$flat eq ""} {::prtr::informeUser "pretraitee" "faire_flat_field"}

     if {$dark ne "" || $bias ne ""} {
         if {[::prtr::createOffset+Dark $dark $bias] ne "0"} {return 1}
         set file Offset+Dark$extOut
         if {[file exists $file]} {

            if {[::prtr::subsOffset+Dark $data $file] ne "0"} {return 1}

            #--   met a jour la liste des images a traiter
            set imgList [::prtr::buildNewList temp $l]
            set extIn $extOut
         }
      }

      set catchError [catch {
         if {$flat ne ""} {
            #--   divise les images par le flat et multiplie par la constante
            set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn \"$dirOut\" $nameOut $indexOut $extOut DIV \"file=$flat\" $options"
            ::prtr::editScript $script
            ttscript2 "$script"

            #--   detruit les fichiers temporaires
            if {[lsearch -regexp $imgList temp] >= "0"} {
               set script "IMA/SERIES . \"$imgList\" $indexIn $indexIn $extIn . . . . DELETE"
               ::prtr::editScript $script
               ttscript2 "$script"
            }
         } else {
            #--   renomme les fichiers temp en l'absence de flat
            foreach file $imgList {
               regsub "temp" $file "$nameOut" newName
               file rename -force [file join $dirOut $file$extOut] [file join $dirOut $newName$extOut]
            }
         }
       }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::createOffset+Dark file1 file2
   #  Cree l'image Offset+Dark (non zippee) dans le repertoire audace(rep-images)
   #  a partir d'une image d'offset et/ou de dark (zippes ou non)
   #  Le dark et l'offset peuvent etre dans un repertoire different de audace(rep_images)
   #--------------------------------------------------------------------------
   proc createOffset+Dark { file1 file2 } {

      set catchError 0
      set nameOut "Offset+Dark"
      set extOut $::conf(extension,defaut)
      if {$file1 eq ""} {
         file copy -force $file2 $nameOut$extOut
      } elseif  {$file2 eq ""} {
         file copy -force $file1 $nameOut$extOut
      } else {
         #--   cas de deux fichiers
         set catchError [catch {
            set dir [file dirname $file1]
            set nameIn [file tail $file1]
            set script "IMA/SERIES \"$dir\" $nameIn . . . . $nameOut . $extOut ADD \"file=$file2\" "
            ::prtr::editScript $script
            ttscript2 "$script"
         }  ErrInfo]
      }
      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   #  ::prtr::subsOffset+Dark data file
   #  Soustrait l'image 'file' de chaque image (zippee ou non)
   #  et stocke l'image produite dans audace(rep_images)
   #--------------------------------------------------------------------------
   proc subsOffset+Dark { data file } {

      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set index "."
      if {[llength $imgList] ne "1"} {set index 1}

      set catchError [catch {
         set script "IMA/SERIES . \"$imgList\" * * $extIn . temp $index $extOut SUB \"file=$file\" "
         ::prtr::editScript $script
         ttscript2 "$script"
         #--   efface le fichier provisoire
         file delete $file
      }  ErrInfo]

      if {$catchError eq "1"} {::prtr::Error "$ErrInfo"}
      return $catchError
   }

   #--------------------------------------------------------------------------
   ## @brief commande associée au checkbutton "Afficher le(s) ttscript2." ;
   #édite le script dans la console
   #  @param script script à éditer
   #
   proc editScript { script } {

      if {[info exists ::prtr::script] && $::prtr::script eq "1"} {
         ::console::affiche_resultat "$script\n"
      }
   }

   #--------------------------------------------------------------------------
   #  ::prtr::extractData options what
   #  Extrait une variable des options et met a jour les options
   #  Parametres : options globales, a extraire
   #--------------------------------------------------------------------------
   proc extractData { options what } {

      set extract [lsearch -regexp -inline $options "${what}="]
      set k [lsearch -regexp $options "$what"]
      set options [lreplace $options $k $k]
      regsub "${what}=" $extract "" extract
      return [list $options $extract]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::buildNewList newName l
   #  Renvoie une nouvelle liste d'images a traiter
   #  Parametres : nouveau nom, nb d'images
   #--------------------------------------------------------------------------
   proc buildNewList { newName l } {

      set newList ""
      if {$l eq "1"} {
         lappend newList $newName
      } else {
         for {set i 1} {$i <= $l} {incr i} {
            lappend newList $newName$i
         }
      }
      return $newList
   }

   #--------------------------------------------------------------------------
   #  ::prtr::informeUser v1 v2
   #  Affiche une info sur la console sur l'absence d'une image maître
   #--------------------------------------------------------------------------
   proc informeUser { v1 v2 } {

      ::console::affiche_resultat "[format $::caption(prtr,sans) \
         $::caption(audace,menu,$v1) $::caption(audace,menu,$v2)]\n"
   }

   #--------------------------------------------------------------------------
   #  ::prtr::cmdAligner data options
   #  Aligne une ou plusieurs images sur une image de reference et les fenetre
   #--------------------------------------------------------------------------
   proc cmdAligner { data options } {

      cd $::audace(rep_images)
      set extOut $::conf(extension,defaut)
      lassign $data imgList dirOut nameOut extIn
      set nbImg [llength $imgList]
      set b [::buf::create]
      set toResize ""
      set toDestroy ""

      #--   extrait le nom du plan principal
      lassign [::prtr::extractData $options "plan"] options plan_ref

      #--   extrait le nom de l'image de reference
      lassign [::prtr::extractData $options "image_ref"] options imgRef

      #--   travaille sur une copie de l'image de refrence
      file copy -force $imgRef reference$extOut
      set toDestroy [concat $toDestroy reference]

      #--   saisit le nom de sortie de l'image de correlation croisee
      set dest crosscorrelation$extOut

      #--   cree deux vecteurs
      blt::vector create Vx Vy -watchunset 1

      #--   si compression
      if {$::conf(fichier,compres) eq "0"} {
         set ext $extOut
      } else {
         regsub ".gz" $extIn "" ext
         #--   decompresse les fichiers .gz
         foreach img $imgList {
            gunzip $img$extIn
            #--   prepare la liste des compressions
            lappend toCompress [file join $dirOut $img$ext]
         }
         set extIn $ext
      }

      #--   identifie le type d'images
      buf$b load $imgRef reference$extOut
      foreach kwd {NAXIS NAXIS1 NAXIS2 NAXIS3} {
         set [string tolower $kwd] [lindex [buf$b getkwd $kwd] 1]
      }

      set type M
      if {$naxis eq "3" && $naxis eq "3"} {set type C}
      set box [list 1 1 $naxis1 $naxis2]

      if {$type ne "C"} {
         set ref "reference$extOut"
      } else {
         #--   decompose toutes les images en plans couleurs
         foreach file "$imgList reference" {
            ::prtr::decompRGB $file
            set toDestroy [concat $toDestroy ${file}r ${file}g ${file}b]
         }
         #--   indique le plan vert de l'image de reference
         set ref "reference${plan_ref}$extOut"
      }

      #--   gere le repertoire de sortie
      set rep $dirOut
      if {$dirOut eq "."} {set rep "$::audace(rep_images)"}

      #--   cherche la correlation
      foreach img $imgList {

         set plan $img
         if {$type eq "C"} {
            set plan ${img}${plan_ref}
         }

         set catchError [catch {icorr2d $ref ${plan}$extIn $dest} ErrInfo]

         if {$catchError eq "1"} {
            ::prtr::Error "$ErrInfo"
            return $catchError
         }

         #--   charge l'image d'intercorrelation
         buf$b load $dest

         #--cherche les coordonnees du maximum
         set result [::prtr::searchMax $box $b]
         if {$result ne "1"} {

            #--   cherche les coordonnees du point avec l'intensite maximale
            lassign $result x y

            #--   calcule la translation a effectuer
            set dx [expr {$x-1-$naxis1/2}]
            set dy [expr {$y-1-$naxis2/2}]

            #--   memorise les resultat pour le fenetrage
            Vx append $dx
            Vy append $dy

            if {$type ne "C"} {
               set todo $img
               lassign [list . . .] indiceDeb  indiceFin  indiceOut
            } else {
               set todo [list ${img}r ${img}g ${img}b]
               lassign [list * * 1] indiceDeb  indiceFin  indiceOut
            }

            #--   translate chaque image ou les 3 plans couleurs
            #--   ca marche aussi si dx=0 et/ou dy=0
            set catchError [catch {
               set script "IMA/SERIES . \"$todo\" $indiceDeb $indiceFin $extIn . temp$img $indiceOut $extOut TRANS trans_x=$dx trans_y=$dy $options"
               ::prtr::editScript $script
               ttscript2 "$script"

               #--   memorise la liste des fichiers
               if {$indiceOut ne "1"} {
                  lappend toResize temp$img
                  set toDestroy [concat $toDestroy temp$img]
               } else {
                  foreach i {1 2 3} p {r g b} {
                     file rename -force "temp$img$i$extOut" "temp$img$p$extOut"
                     lappend toResize temp$img$p
                     set toDestroy [concat $toDestroy temp$img$p]
                  }
               }
            } ErrInfo]

            if {$catchError eq "1"} {
               ::prtr::Error "$ErrInfo"
               return $catchError
            }

            file delete $dest
         }
      }

      #--   supprime le buffer provisoire
      ::buf::delete $b

      #--   calcule les limites du fenetrage
      foreach {vector var} [list Vx x Vy y] {

        if {$var eq "x"} {
            set naxis $naxis1
         } else {
            set naxis $naxis2
         }
         lassign [list 1 $naxis] ${var}1 ${var}2

         $vector sort
         set min [$vector range 0 0]
        set max [$vector range end end]

         if {$min > "0"} {
            set ${var}1 [expr {int($max+1)}]
         } elseif {$max < "0"} {
            set ${var}2 [expr {int($naxis+$min)}]
         } else {
            set ${var}1 [expr {int($max+1)}]
            set ${var}2 [expr {int($naxis+$min)}]
        }
      }
      blt::vector destroy Vx Vy

      #--   liste les fichiers a fenetrer
      if {$type ne "C"} {
         set toResize [concat reference $toResize]
      } else {
         set toResize [concat referencer referenceg referenceb $toResize]
      }

      #--   ote l'option nullpixel si elle existe
      regsub "[lsearch -regexp -inline $options "nullpixel=*"]" $options "" options

      #--   ca marche aussi si x1=1, y1=1, x2=naxis1 ou y2=naxis2
      set script "IMA/SERIES \"$dirOut\" \"$toResize\" * * $extOut \"$dirOut\" temp 1 $extOut WINDOW x1=$x1 x2=$x2 y1=$y1 y2=$y2 $options"

      ::prtr::editScript $script
      set catchError [catch {ttscript2 $script} ErrInfo]
      if {$catchError eq "1"} {
         ::prtr::Error "$ErrInfo"
          return $catchError
      }

      #--   convertit en RGB
      if {$type eq "C"} {
         set limite [llength $toResize]
         set k "0"
         for {set i 1} {$i <= $limite} {incr i 3} {
            incr k
            foreach p [list $i [expr {$i+1}] [expr {$i+2}]] c {r g b } {
               file rename -force temp$p$extOut ${nameOut}$k$c$extOut
               set toDestroy [concat $toDestroy temp$p ${nameOut}$k$c]
            }
           ::prtr::convertitRGB ${nameOut}$k$extOut
         }
      } else {
         set limite [llength $toResize]
         for {set i 1} {$i <= $limite} {incr i} {
            file rename -force temp$i$extOut ${nameOut}$i$extOut
            set toDestroy [concat $toDestroy temp$i]
         }
      }

      #--   recompresse les fichiers d'entree et les fichiers de sortie
      if {$::conf(fichier,compres) eq "1"} {
         foreach file $toCompress {gzip $file}
         set ext "$ext.gz"
      }

      #--   detruit les fichiers provisoires
      ttscript2 "IMA/SERIES . \"$toDestroy\" * * $extOut . . . . DELETE"
      return $catchError
   }

   #--------------------------------------------------------------------------
   ## @brief retourne les coordonnées x y du maximum d'une boîte dans l'image affichée
   #  @param box coordonnées de la boîte
   #  @param buf numéro du buffer
   #  @return coordonnées x y du maximum
   #
   proc searchMax { box buf } {

      lassign $box x1 y1 x2 y2
      set c [::buf::create]
      set d [::buf::create]
      buf$buf copyto $c
      buf$buf copyto $d

      #--   additionne les lignes et les colonnes
      set catchError [catch {
         buf$c imaseries "SORTY percent=100 y1=$y1 y2=$y2 height=1"
         buf$c imaseries "PROFILE direction=x offset=1 \"filename=sortli.txt\" "
         buf$d imaseries "SORTX percent=100 x1=$x1 x2=$x2 width=1"
         buf$d imaseries "PROFILE direction=y offset=1 \"filename=sortcol.txt\" "
      }  ErrInfo]

      ::buf::delete $c
      ::buf::delete $d

      if {$catchError eq "1"} {
         ::prtr::Error "$ErrInfo"
         return $catchError
      }

      foreach file {sortli.txt sortcol.txt} coord {x y} {
         set fd [open $file r+ ]
         set max "0"
         set $coord ""
         gets $fd value
         while {![eof $fd]} {
            gets $fd value
            lassign $value c v
            if {$v > $max} {
               set $coord $c
               set max $v
            } elseif {$v == $max} {
               lappend $coord $c
            }
         }
         close $fd
         file delete $file
      }

      #--   cherche la fraction de pixel
      set x [lindex $x end]
      set y [lindex $y end]
      set x1 [expr {int($x-5)}]
      set y1 [expr {int($y-5)}]
      set x2 [expr {int($x+5)}]
      set y2 [expr {int($y+5)}]

      set box [list $x1 $y1 $x2 $y2]
      lassign  [buf$buf centro $box] x y
      return [list $x $y]
   }

   #--------------------------------------------------------------------------
   #  ::prtr::seeWCSKeywords
   #  Affiche les valeurs des mots cles WCS
   #  Parametre : nom court de l'image sans extension preleve dans la table
   #  Lancee lors de la selection de la premiere image
   #--------------------------------------------------------------------------
   proc seeWCSKeywords { fileName } {
      variable bd

      #--   cherche les info dans bd
      set info [lindex [array get bd $fileName] 1]
      lassign [lrange $info 5 8] ::prtr::crpix1 ::prtr::crpix2 -> wcs

      if {$wcs == 1} {
         lassign [lrange $info 9 end] pixsize1 pixsize2 ::prtr::ra ::prtr::dec foclen crota2
         set ::prtr::foclen  [format "%.3f" $foclen]
         set ::prtr::crota2  [format "%.6f" $crota2]
         set ::prtr::pixsize1 [format "%.2f" $pixsize1]
         set ::prtr::pixsize2 [format "%.2f" $pixsize2]
      }

      update
   }

   #--------------------------------------------------------------------------
   #  ::prtr::checkCatalog
   #  Selectionne le bon chemin s'il est configure
   #  Commande associee a la combobox du choix du catalogue
   #--------------------------------------------------------------------------
   proc checkCatalog { } {

      #--   racourci (astromcatalog est deja en majuscules)
      set astromcatalog $::prtr::astromcatalog
      set ok 1

      #--   Definit le chemin en fonction du catalogue (CF Configuration/Répertoires)
      switch -exact $astromcatalog {
         MICROCAT {  set var "::conf(rep_userCatalogMicrocat)" }
         USNO     {  set var "::conf(rep_userCatalogUsnoa2)" }
      }

      #--   Verifie si le nom de la variable existe
      if {[info exists $var] == 1} {

         #--   la variable existe
         set path "[set $var]"

         #--   Verifie l'existence du repertoire
         if {[file exists $path] == 1} {

            set path_astromcatalog "$path"
            #--   Verifie l'integrite du catalogue
            switch -exact $astromcatalog {
               MICROCAT {  set fics [glob -nocomplain -dir [file join $path_astromcatalog usno] -type f *.ACC]
                           if {[llength $fics]<24} {
                              set ok 0
                           }
                           set fics [glob -nocomplain -dir [file join $path_astromcatalog tyc] -type f *.ACC]
                           if {[llength $fics]<24} {
                              set ok 0
                           }
                        }
               USNO     {  set fics [glob -nocomplain [file join $path_astromcatalog "*.ACC"]]
                           if {[llength $fics]<24} {
                              set ok 0
                           }
                           set fics [glob -nocomplain [file join $path_astromcatalog "*.CAT"]]
                           if {[llength $fics]<24} {
                              set ok 0
                           }
                        }
           }
           #-- Tout est ok
           set ::prtr::path_astromcatalog "$path_astromcatalog"
        } else {
           #--   Repertoire inexistant
           set ok 0
        }
      } else {
         #--   Variable conf non configuree
         set ok 0
      }

      if {$ok == 0} {
         #--   Message d'erreur
         ::prtr::avertiUser err_cat_folder "$astromcatalog"

         #--   Ouverture de Configuration/Répertoires...
         ::cwdWindow::run "$::audace(base).cwdWindow"

         #--   Attend la configuration de la variable conf adhoc
         vwait $var
      }
   }

   #--------------------------------------------------------------------------
   ## @brief
   #  @param data liste de liste des images, répertoire de sortie, nom générique, extension
   #  @param options liste de nom_variable=valeur, dans l'orde de présentation des variables dans l'interface
   #  @code
   #  exemple "ra=291.366303542 dec=42.7843595 pixsize1=6.45 pixsize2=6.45
   #           foclen=0.133 crota2=86.688467 cat_format=MICROCAT
   #           cat_folder=C:/Documents and Settings/1/Application Data/AudeLA/catalog/microcat/"
   #  @endcode
   #  @warning cat_format et cat_folder doivent être les derniers de la liste
   #  @return
   #  - 0 = sans erreur
   #  - 1 = échec
   #
   proc calibWCS { data options } {
      variable private

      #--   Affecte les valeurs a la liste des images, du repertoire de sortie
      #     du nom generique de sortie et de l'extension
      foreach {imgList dirOut nameOut ext} $data {break}

      #--   Initialise des variables de la barre de progression
      set n 0
      set len [llength $imgList]
      set todestroy [::prtr::createProgressBar]
      update

      set dirIn "$::audace(rep_images)"

      #--   Definit les noms de sortie
      if {$nameOut eq ""} {
         #--   en absence de nom generique
         #--   les noms de sortie sont identiques aux nom d'entree
         set private(outList) $imgList
      } else {
         #--   en presence de nom generique
         #--   compose une liste de sortie
         set lastCar [string index $nameOut [expr { [string length $nameOut]-1 }]]
         if {[string is integer -strict $lastCar] == 1} {
            set racine [string range $nameOut 0 end-1]
            set firstIndex "$lastCar"
            set lastIndex [expr { $firstIndex+$len-1 }]
         } else {
            set racine $nameOut
            set firstIndex 1
            set lastIndex $len
         }
         set private(outList) ""
         for {set i $firstIndex} {$i <= $lastIndex} {incr i} {
            lappend private(outList) ${racine}$i
         }
      }

      if {$dirOut eq "./"} {set dirOut "."}

      #--   Recupere astromcatalog et path_astromcatalog
      set astromcatalog [lindex $options 6]
      set path_astromcatalog [lrange $options 7 end]
      set options [lrange $options 0 5]

      #--- Remplace "$::audace(rep_images)" par "." dans "mypath" - Cela permet a
      #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
      #--- espaces et ayant une longueur superieure a 70 caracteres
      #--   le repertoire de sortie devient le repertoire courant
      cd "$dirOut"
      set mypath "."
      set sky    dummy
      set sky0   dummy0
      set erreur 0

      foreach file $imgList out $private(outList) {

         #--   ATTENTION
         #  inName  = nom dans le repertoire initial
         set inName  $file$ext
         #  nameOut = nom dans le repertoire de destination
         set outName $out$ext

         #--   Recupere les naxis de l'image pour completer les options
         lassign [::prtr::getKwdValue [file join $dirIn $file$ext]] naxis1 naxis2
         append options " naxis1=$naxis1 naxis2=$naxis2"

         #--   Ecrit les mots cles dans un fichier pour utiliser HEADERFITS
         set kwdFile [::prtr::setKwdList $options "$dirOut"]

         #--   Recopie les images avec les nouveaux mots cles
         set script1 "IMA/SERIES \"$dirIn\" \"$file\" . . \"$ext\" \"${dirOut}\" \"$sky\" . \"$ext\" HEADERFITS \"file=${kwdFile}\" "
         ::prtr::editScript $script1
         ttscript2 $script1
         createFileConfigSextractor
         ttscript2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky0\" . \"$ext\" COPY"
         sextractor [file join ${mypath} $sky0$ext] -c [file join $mypath config.sex]

         set script2 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" CATCHART \"$path_astromcatalog\" $astromcatalog \"catafile=${mypath}/c$sky$ext\"  \"jpegfile_chart2=$mypath/${sky}a.jpg\" "
         ::prtr::editScript $script2

         if {[catch { ttscript2 $script2 } msg] == 0} {

            #--   Continue le traitement
            set script3 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"$sky\" . \"$ext\" ASTROMETRY \"objefile=${mypath}/catalog.cat\" nullpixel=-10000 delta=5 epsilon=0.0002 \"file_ascii=$mypath/ascii.txt\" "
            ::prtr::editScript $script3
            ttscript2 $script3
            set script4 "IMA/SERIES \"$mypath\" \"$sky\" . . \"$ext\" \"$mypath\" \"z$sky\" . \"$ext\" CATCHART \"$path_astromcatalog\" $astromcatalog \"catafile=${mypath}/c$sky$ext\" \"jpegfile_chart2=$mypath/${sky}b.jpg\" "
            ::prtr::editScript $script4
            ttscript2 $script4

            #--   Renomme l'image finale
            file rename -force $sky$ext $outName

            lassign [::prtr::getKwdValue $outName] -> -> catastar

            #--   Met a jour de la barre de progression
            incr n
            set private(progress) [expr { $n*100./($len+0.025) }]
            set private(calibrating) [format $::caption(prtr,prgrsbr) "$inName" $catastar]
            update

            #-- Nettoie
            set toDelete [list $sky0$ext x$sky$ext c$sky$ext z$sky$ext ascii.txt kwd.txt \
               catalog.cat com.lst dif.lst eq.lst obs.lst pointzero.lst usno.lst xy.lst tt.log \
               ${sky}a.jpg ${sky}b.jpg signal.sex config.sex config.param default.nnw file.fit]

            ttscript2 "IMA/SERIES \"$mypath\" \"$toDelete\" * * . . . * . DELETE"

         } else {
            set erreur 1
            ::console::affiche_erreur "$msg\n"
         }
      }

      #--   Retablit le repertoire
      cd $dirIn

      #--   Detruit la barre de progression
      after 2000
      destroy $todestroy
      set private(progress) 0
      set private(calibrating) ""

      return $erreur
   }

   #--------------------------------------------------------------------------
   #  ::prtr::setKwdList
   #  Calcule les valeurs des mots cles et ecrit le fichier pour HEADERFITS
   #  Parametres : liste de 8 couples {nom_variable=valeur}, peu importe l'orde
   #  ex : "ra=291.366303542 dec=42.7843595 pixsize1=6.45 pixsize2=6.45
   #       foclen=0.133 crota2=86.688467 naxis1=490 naxis2=540"
   #  Retourne : le chemin du fichier
   #--------------------------------------------------------------------------
   proc setKwdList { options dirOut } {

      #--   Extrait les valeurs des variables
      regsub -all "=" $options " " optVal
      foreach {varName value} $optVal {
         set $varName $value
         #::console::disp "$varName $value\n"
      }

      #--   Calcule les intermediaires
      set crpix1 [expr { $naxis1/2. }]
      set crpix2 [expr { $naxis2/2. }]
      set pi [expr 4*atan(1.)]
      set mult 1e-6
      set cdelt1 [expr { -2*atan($pixsize1/$foclen*$mult/2.)*180/$pi }]
      set cdelt2 [expr { 2*atan($pixsize2/$foclen*$mult/2.)*180/$pi }]
      set cosr   [expr { cos($crota2*$pi/180.) }]
      set sinr   [expr { sin($crota2*$pi/180.) }]
      set cd1_1  [expr { $cdelt1*$cosr }]
      set cd1_2  [expr { abs($cdelt2)*$cdelt1/abs($cdelt1)*$sinr }]
      set cd2_1  [expr { -abs($cdelt1)*$cdelt2/abs($cdelt2)*$sinr }]
      set cd2_2  [expr { $cdelt2*$cosr }]

      #--   Definit les mot cles avec variable
      set cd1_1    [list CD1_1 $cd1_1 double "Matrix CD11" "deg/pixel"]
      set cd1_2    [list CD1_2 $cd1_2 double "Matrix CD12" "deg/pixel"]
      set cd2_1    [list CD2_1 $cd2_1 double "Matrix CD21" "deg/pixel"]
      set cd2_2    [list CD2_2 $cd2_2 double "Matrix CD22" "deg/pixel"]
      set cdelt1   [list CDELT1 $cdelt1 double "X scale" "deg/pixel"]
      set cdelt2   [list CDELT2 $cdelt2 double "Y scale" "deg/pixel"]
      set crota2   [list CROTA2 $crota2 double "Position angle of North" "deg"]
      set crpix1   [list CRPIX1 $crpix1 double "X ref pixel" "pixel"]
      set crpix2   [list CRPIX2 $crpix2 double "Y ref pixel" "pixel"]
      set crval1   [list CRVAL1 $ra double "RA for CRPIX1" "deg"]
      set crval2   [list CRVAL2 $dec double "DEC for CRPIX2" "deg"]
      set dec      [list DEC $dec double "DEC expected for CRPIX2" "deg"]
      set foclen   [list FOCLEN $foclen float "Focal length" "m"]
      set pixsize1 [list PIXSIZE1 $pixsize1 float "X pixel size binning included" "mum"]
      set pixsize2 [list PIXSIZE2 $pixsize2 float "Y pixel size binning included" "mum"]
      set ra       [list RA $ra double "RA expected for CRPIX1" "deg"]

      #--   Definit les mot cles avec constante
      #-- compense le fait que ne peut pas supprimer CATASTAR dans l'image
      set catastar [list CATASTAR 0 int "Nb stars matched" ""]
      set equinox  [list EQUINOX J2000.0 string "System of equatorial coordinates" ""]
      set lonpole  [list LONPOLE 180 float "Long. of the celest.NP in native coor.sys" "degres"]
      set ctype1   [list CTYPE1 RA---TAN string "Gnomonic projection" ""]
      set ctype2   [list CTYPE2 DEC--TAN string "Gnomonic projection" ""]
      set cunit1   [list CUNIT1 deg string "Angles are degrees always" ""]
      set cunit2   [list CUNIT2 deg string "Angles are degrees always" ""]
      set radesys  [list RADESYS FK5 string "Mean Place IAU 1984 system" ""]
      set radecsys [list RADECSYS FK5 string "Mean Place IAU 1984 system" ""]

      #--   Ecrit les mots dans un fichier .txt pour usage avec HEADERFITS
      set listKwd [list cd1_1 cd1_2 cd2_1 cd2_2 catastar cdelt1 cdelt2 crota2 \
         crpix1 crpix2 crval1 crval2 ctype1 ctype2 cunit1 cunit2 dec equinox \
         foclen lonpole pixsize1 pixsize2 ra radesys radecsys]

      set kwdFile [file join ${dirOut} kwd.txt]
      set fileID [open $kwdFile w]
      foreach sentence $listKwd {
         lassign [set $sentence] kwd value type comment unit
         puts $fileID "$kwd\n$value\n$type\n$comment\n$unit"
      }
      close $fileID

      return "$kwdFile"
   }

   #------------------------------------------------------------
   # ::prtr::getKwdValue
   #   Extrait des valeurs du header d'une image
   #   Parametre : chemin complet du fichier image
   #   Retourne : liste des valeurs NAXIS1, NAXIS2 et CATASTAR
   #------------------------------------------------------------
   proc getKwdValue { fileName } {

      set result ""
      if {$fileName ne "" || [file exists $fileName] == 1} {
         if {[catch { set kwdList [fitsheader $fileName] } msg] == 0} {
            foreach kwd [list NAXIS1 NAXIS2 CATASTAR] {
               set sentence [lsearch -all -regexp -inline $kwdList $kwd]
               set value [lindex [lindex $sentence 0] 1]
               if {[string is integer -strict $value]} {
                  lappend result $value
               }
            }
         } else {
            #--   Erreur dans le header
            ::console::affiche_erreur "$msg\n"
         }
      }

      return $result
   }

   #------------------------------------------------------------
   # ::prtr::createProgressBar
   #   Marque la porgression de la calibration WCS
   #   Retourne : le nom de la fenetre
   #   Liee a proc ::prtr::calibWCS
   #------------------------------------------------------------
   proc createProgressBar { } {
      variable private

      package require Ttk

      if {![info exists private(this)]} {
         set this "$::audace(base)"
      } else {
         set this $private(this)
      }
      set w $this.prgrsbr

      toplevel $w -class Toplevel
      wm title $w "$::caption(prtr,calibration)"
      regsub -all {[\+|x]} [ wm geometry $this ]  " " pos
      lassign $pos -> -> x y
      incr x 80
      incr y 250
      wm geometry $w "420x78+$x+$y"
      wm resizable $w 0 0
      wm transient $w $this
      wm protocol $w WM_DELETE_WINDOW ""

      pack [frame $w.fr]
      label $w.fr.label -textvariable ::prtr::private(calibrating) -width 40
      pack $w.fr.label -padx 10 -pady 5
      ttk::progressbar $w.fr.p -orient horizontal -length 400 -maximum 100.0 \
         -mode determinate -variable ::prtr::private(progress)
      pack $w.fr.p -padx 10 -pady 5

      #--   Initialise
      set private(calibrating) ""
      set private(progress)    2.5

      focus $w

      return $w
   }

}


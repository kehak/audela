#
## @file aud_menu_3.tcl
#  @brief Scripts regroupant des fonctionnalités du menu Images
#  $Id: aud_menu_3.tcl 14159 2016-12-15 14:07:09Z rzachantke $
#  @todo doxygéner ::traiteFilters

## namespace conv2
#  @brief Scripts de conversion d'images
#  @author Raymond ZACHANTKE

namespace eval ::conv2 {

   #---------------------------------------------------------------------------
   ##  @brief initialise le script
   #   @param type_conversion (option)
   #
   proc run { { type_conversion "" } } {
      variable this
      variable private
      variable widget
      variable CONVERSION

      #--- icone hourglass
      set private(conv2,hourglass) [ image create photo imagehourglass -data {
         R0lGODlhGAAYAIIAMVQYGKmkKvr8BFlbTKKkp7kDBJprPt7d3ywAAAAAGAAY
         AAIDZii63P4wyklVuEHkW4UpgfEVJJBVwDAALGt0GnEcRA28nTzPhAoHO1oP
         VwnIDCrVqQPsDWGLpgkanQ2IP9ngcIUCebRpbjeo+Zgz5LWbq/WSA1hK1bp1
         DDd6AbBfTjCAHFSDhIUMCQA7
      } ]

      #--- icone info
      set private(conv2,info) [ image create photo imageinfo -data {
         R0lGODlhGAAYAIIAMS4tNpKSpvD4Nfj5+l1eUHd30goI+66vqiwAAAAAGAAY
         AAIDkyi6GnHvsTnhGTgfS9nLILh1wgUWRhoeBGWCaVqs7RKEGKriQb3hQBzg
         ILjxCoVA4SUClIAHnWGGOwyN1Rh1BfhAtdAudgWudovBcqhbQIcCsdR4QCBI
         BITVZfPL9HoMeUFvbBQAgkEsdncTBABDIY51BTUkDo+CBV2LJBVWF3V8nSR5
         AUOjo3UERKidh6ytlgEkCQA7
      } ]

      #--- icone nop
      set private(conv2,nop) [ image create photo imagenop -data {
         R0lGODlhGAAYAIIAMfoFB6WovKvU+e31+uSts3tkd+hSV98vMCwAAAAAGAAY
         AAIDoTi6GiMwyiCCY0rgvULhF4d5nCYyQvFhpgY9jzt4JnO5URyRRBUQlAzs
         Rax8LMgWbJgxhjo6idTYEAAt0eluhaTUWMPUs9HUbk2Ua1Y7W82Sa21hPBMW
         dwcA4HD5Yc0QBnqDBwRvdYAFg4sHaHEReQYHkoIAXChCD3sYBJZVSV0WewSk
         pIIHClcWc6GVi3puJxmvenyynHmDKrcbBAUHKisJADs=
      } ]

      #--- icone ok
      set private(conv2,ok) [ image create photo imageok -data {
         R0lGODlhGAAYAIIAMSE8ZASlBAV/C6SrpoKChfr8+hPWE2i5aCwAAAAAGAAY
         AAIDZ1i63P4wykmrjedcd4wY23IEAgBug0GWxXBSqSADLUG8bc4Y3lzYNkbH
         c4rJSgNgcKGSERS9mUvZ6AEIvCPgqnxWj4IVsuv9gqVJ6iOqNXUxx8CWTCFs
         512chLy08PV1QIAhhIWGDAkAOw==
      } ]

      #--- initialisation de variables
      ::conv2::confToWidget

      set private(conv2,rep) "$::audace(rep_images)"
      set private(conv2,conversion) "$type_conversion"
      #--   definit l'extension reelle des fichiers
      if {$::conf(fichier,compres) eq "1"} {
         set private(conv2,extension) "$::conf(extension,defaut).gz"
      } else {
         set private(conv2,extension) $::conf(extension,defaut)
      }

      #--- liste les libelles du menubutton
      set private(conv2,formules) "[dict keys $CONVERSION]"

      #--- liste les operations de conversion et les noms generiques
      foreach formule $private(conv2,formules) {
         set op "[dict get $CONVERSION $formule fun]"
         lappend private(conv2,operations) $op
         set private(conv2,$op,generique) "[dict get $CONVERSION $formule gen]"
      }

      #--- cherche la longueur maximale du libelle des formules
      #--- pour dimensionner la largeur du menuboutton
      set private(conv2,bwidth) "0"
      foreach formule $private(conv2,formules) {
         set private(conv2,bwidth) [ expr { max([ string length $formule ],$private(conv2,bwidth)) } ]
      }

      #--- definit le nom generique propose pour le fichier de sortie des RAW
      set dir "[ file tail [ file rootname $private(conv2,rep) ] ]_"

      #--- remplace les caracteres
      regsub -all {[^\w_-]} $dir {} dir

      set liste_generiques [ list $dir "rgb_" "plan_" "img3d_" ]
      foreach op $private(conv2,operations) generique $liste_generiques {
         set private(conv2,$op,generique) $generique
      }

      set this "$::audace(base).dialog"
      if { [ winfo exists $this ] } {
         wm withdraw $this
         wm deiconify $this
         focus $this
         #--- selectionne la conversion
         set i [ lsearch -exact $private(conv2,formules) $private(conv2,conversion) ]
         incr i
         $this.but.menu invoke $i
      } else {
         #--- classe et liste les fichiers convertibles par type de conversion
         #--- les sept listes sont contenues dans l'array bdd
         ::conv2::ListFiles
         if { [ info exists widget(geometry) ] } {
            set deb [ expr 1 + [ string first + $widget(geometry) ] ]
            set fin [ string length $widget(geometry) ]
            set widget(conv2,position) "+[string range $widget(geometry) $deb $fin]"
         }
         ::conv2::CreateDialog $this
         #--- initialise les listes de fichiers in & out
         #--- evite une erreur si on appuie sur 'Appliquer'
         lassign { "" "" } private(conv2,in) private(conv2,out)
      }
   }

   #---------------------------------------------------------------------------
   ##  @brief liste les images par nature (raw cfa rgb plan_coul all_files)
   #et créé l'array bdd des listes des noms courts de fichiers
   #
   proc ListFiles { } {
      variable private
      variable bdd

      #--- initialise les listes
      lassign { "" "" "" "" "" "" "" "" ""} fits raw cfa rgb plan_coul assign_r assign_g assign_b ::conv2::maj_header

      #--- etape 1 : recherche les fichiers raw convertibles
      if { $::tcl_platform(platform) == "windows" } {
         #--- la recherche de l'extension est insensible aux minuscules/majuscules ... sous windows uniquement
         foreach extension { ARW CR2 CRW DNG ERF MRW NEF ORF RAF RW2 SR2 TIFF X3F } {
            set raw [ concat $raw [ glob -nocomplain -type f -join $private(conv2,rep) *.$extension ] ]
         }
      } else {
         #--- la recherche de l'extension est _sensible_ aux minuscules/majuscules dans tous les autres cas
         foreach extension { ARW CR2 CRW DNG ERF MRW NEF ORF RAF RW2 SR2 TIFF X3F \
                             arw cr2 crw dng erf mrw nef orf raf rw2 sr2 tiff x3f } {
            set raw [ concat $raw [ glob -nocomplain -type f -join $private(conv2,rep) *.$extension ] ]
         }
      }

      #--- remplace le nom par le nom court
      foreach fi $raw {
         set i [ lsearch -exact $raw $fi ]
         set raw [ lreplace $raw $i $i [ file tail $fi ] ]
      }

      #--- etape 2 : recherche les fichiers d'extensions par defaut
      if { $::tcl_platform(platform) eq "windows" } {
         set pattern "\{$private(conv2,extension)\}"
      } else {
         #--   pour Linux
         set pattern "\{[string tolower $private(conv2,extension)] [string toupper $private(conv2,extension)]\}"
      }
      #--   remplace les espaces par une virgule
      regsub -all " " $pattern "," pattern
      set files [glob -nocomplain -type f -join $private(conv2,rep) *$pattern]
      foreach fichier $files {
         #--- capture les kwds
         if ![ catch { set kwds_list [ fitsheader $fichier ] } ] {

            #--- cree un array des kwds
            #--- detecte les erreurs dans les mots-cles
            set error "0"
            foreach kwd $kwds_list {

               set err1 [ catch { set nom [ lindex $kwd 0 ] } ]
               set err2 [ catch { set valeur [ lindex $kwd 1 ] } ]

               if { $err1 == "0" && $err2 == "0" } {
                  array set kwds [ list $nom $valeur ]
               } else {
                  set error "1"
               }
            }

            if { $error == "0" } {

               #--- recherche des anciens mots-cles
               set data ""
               lappend data [ array get kwds "RAW_COLORS" ] [ array get kwds "RAW_FILTER" ] \
                  [ array get kwds "RAW_BLACK" ] [ array get kwds "RAW_MAXIMUM" ]
               if { $data != "{} {} {none} {} {}" } {
                  #--- si l'image contient un seul de ces mots cles elle est mise dans la liste
                  lappend ::conv2::maj_header "$fichier"
               }

               #--- extrait les kwd en vue des tests de classification
               set data [ list [ lindex [array get kwds "NAXIS" ] 1 ] \
                  [ lindex [ array get kwds "NAXIS3" ] 1 ] \
                  [ lindex [ array get kwds "RGBFILTR" ] 1 ] \
                  [ lindex [ array get kwds "RAWFILTE" ] 1 ] \
                  [ lindex [ array get kwds "RAW_FILTER" ] 1 ] ]
               lassign $data naxis naxis3 rgbfiltr rawfilte raw_filter
               set file [file tail $fichier ]

               #--- classe les fichiers en fonction de leur nature
               if { $naxis == "3" && $naxis3 == "3" } {
                  lappend rgb "$file"
               } elseif { $naxis == "2" && $rgbfiltr =="" && ( $rawfilte != "" || $raw_filter != "" ) } {
                  lappend cfa "$file"
               } elseif { $naxis == "2" && $rgbfiltr !="" } {
                  #--- enleve l'extension
                  set file [ file rootname $file ]
                  set term [ string range $file end end ]
                  if {$term eq "[ string tolower $rgbfiltr ]" } {
                     #--- isole la racine du nom (index compris)
                     set racine [ string range $file 0 end-1 ]
                     #--- cree une ligne de dictionary
                     dict set plans $racine couleur $rgbfiltr $file
                  } else {
                     #--   assimiles a des plans N&B si discordance entre RGBFILTR et indice terminal
                     lappend assign_r "$file"
                     lappend assign_g "$file"
                     lappend assign_b "$file"
                  }
               } else {
                  #--   vrais plans N&B
                  lappend assign_r "$file"
                  lappend assign_g "$file"
                  lappend assign_b "$file"
               }
            } else {
               ::console::affiche_erreur "$fichier $::caption(pretraitement,err_entete) $::errorInfo\n\n"
            }
            array unset kwds
         } else {
            ::console::affiche_erreur "$fichier $::caption(pretraitement,err_analyse) $::errorInfo\n\n"
         }
      }

      #--- etape 3 selectionne les triades R  G  B de plans couleurs
      #--- s'il n'y a que un ou deux plans l'image n'est pas selectionnee
      catch { dict for { id info } $plans {
            dict with info {
               if { [ expr {[ llength $couleur ]/2} ] == "3" } {
                  lappend plan_coul "$id"
               }
            }
         }
      }

      #--- etape 4 : construit la base de donnees (conversion,liste des fichiers)
      foreach op $private(conv2,operations) liste [list $raw $cfa $rgb $plan_coul $assign_r $assign_g $assign_b] {
         set private(conv2,$op,no_file) ""
         if { $liste == "" } {
            set liste [ list $::caption(pretraitement,no_file) ]
            set private(conv2,$op,no_file) $liste
         } else {
            set private(conv2,$op,no_file) ""
         }
         set private(conv2,$op,state) "normal"
         if { [ llength $liste ] != "0" } {
            array set bdd [ list $op $liste ]
         }
      }

      return [ array size bdd ]
   }

   #---------------------------------------------------------------------------
   #  brief récupère la position de la fenêtre
   #
   proc recupPosition { } {
      variable this
      variable widget

      set widget(geometry) [wm geometry $this]
      set deb [ expr 1 + [ string first + $widget(geometry) ] ]
      set fin [ string length $widget(geometry) ]
      set widget(conv2,position) "+[string range $widget(geometry) $deb $fin]"
      #---
      ::conv2::widgetToConf
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Convertir"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(conv2,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if { ! [ info exists ::conf(conv2,position) ] } { set ::conf(conv2,position) "+350+75" }
   }

   #---------------------------------------------------------------------------
   #  brief charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget

      initConf

      set widget(conv2,position) "$::conf(conv2,position)"
   }

   #---------------------------------------------------------------------------
   #  brief charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget

      set ::conf(conv2,position) "$widget(conv2,position)"
   }

   #---------------------------------------------------------------------------
   #  brief créé la fenêtre de dialogue
   #
   proc CreateDialog { this } {
      variable private
      variable widget

      set private(conv2,This) $this
      if [ winfo exists $this ] { destroy $this }
      toplevel $this
      wm resizable $this 0 0
      wm minsize $this 250 150
      wm deiconify $this
      wm title $this "$::caption(audace,menu,images) - $::caption(audace,menu,convertir)"
      wm geometry $this $widget(conv2,position)
      wm protocol $this WM_DELETE_WINDOW "::conv2::cmdClose"

      ::blt::table $this
      #--- rappel du repertoire
      Label $this.info -justify left\
          -text "$::caption(pretraitement,repertoire) /[ file tail $private(conv2,rep) ]"

      #--- bouton de menu
      menubutton $this.but -relief raised -textvariable conversion \
         -menu $this.but.menu -width $private(conv2,bwidth)

      #--- menu du bouton
      set m [ menu $this.but.menu -tearoff "1" ]
      foreach form $private(conv2,formules) {
         $m add radiobutton -label "$form" -indicatoron "1" -value "$form" \
            -variable conversion
      }

      ::conv2::MenuUpdate

      set tbl $this.tl
      set private(conv2,tbl) $tbl

      #--- definit la structure et les caracteristiques
      ::tablelist::tablelist $tbl \
         -height 9 -width 50 -stretch all -borderwidth 2 \
         -columns [ list 0 "" center \
            0 $::caption(pretraitement,src) left \
            0 "" center \
            0 $::caption(pretraitement,output) left \
            0 $::caption(pretraitement,done) center ] \
         -xscrollcommand [ list $this.hscroll set ] \
         -yscrollcommand [ list $this.vscroll set ] \
         -editendcommand { ::conv2::applyValue } \
         -exportselection 0 -setfocus 1 -activestyle none

      #--- nomme les colonnes
      foreach col { 1 3 4 } name { src dest done } {
         $tbl columnconfigure $col -name $name
      }

      scrollbar $this.hscroll -orient horizontal -command [ list $tbl xview ]
      scrollbar $this.vscroll -command [ list $tbl yview ]

      #--- frame du message
      Label $this.labURLmsg -justify center -borderwidth 1 -relief raised -fg $::color(blue)

      #--- frame avec les options
      Label $this.label -text "$::caption(pretraitement,options)"

      #--- cree 4 checkbuttons
      foreach child { all renum chg destroy_src } { ::conv2::CheckButton $this $child }
      $this.all configure -command "::conv2::SelectAll"
      #--- pour annuler la cmd
      $this.destroy_src configure -command { }

      #--- cree l'entree pour le nom generique
      Entry $this.generique -width 15 -relief sunken \
         -justify right -state normal -textvariable ::conv2::private(conv2,new_name) \
         -command "::conv2::EntryCtrl"

      #--- les boutons de commandes
      frame $this.cmd -borderwidth 1 -relief raised
         button $this.cmd.ok -text "$::caption(pretraitement,ok)" -width 7 \
            -command "::conv2::cmdOk"
         if { $::conf(ok+appliquer)=="1" } {
            pack $this.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $this.cmd.appliquer -text "$::caption(pretraitement,appliquer)" -width 8 \
            -command "::conv2::cmdApply"
         pack $this.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $this.cmd.fermer -text "$::caption(pretraitement,fermer)" -width 7 \
            -command "::conv2::cmdClose"
         pack $this.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $this.cmd.aide -text "$::caption(pretraitement,aide)" -width 7 \
            -command "::conv2::afficheAide"
         pack $this.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $this.cmd -side top -fill x

      #--- positionne les elements dans la table
      ::blt::table $this \
         $this.info 0,1 -cspan 2 -anchor w -padx { 10 5 } -pady { 5 5 } -height 1c \
         $this.but 0,3 -cspan 2 -anchor e -height 1c \
         $this.tl 1,0 -cspan 5 -fill both \
         $this.vscroll 1,5 -fill y -width $this.vscroll \
         $this.hscroll 2,0 -cspan 5 -fill x -height $this.hscroll \
         $this.labURLmsg 3,0 -fill x -cspan 6 -height 1c \
         $this.label 4,1 -rspan 4 -fill x -height 3c\
         $this.all 4,2 -anchor w \
         $this.renum 5,2 -anchor w \
         $this.chg 6,2 -cspan 3 -anchor w \
         $this.generique 6,4 -anchor w \
         $this.destroy_src 7,2 -anchor w \
         $this.cmd 8,0 -cspan 6 -fill both -height 1c

      #--- selectionne la conversion
      set i [ lsearch -exact $private(conv2,formules) $private(conv2,conversion) ]
      incr i
      $this.but.menu invoke $i

      #--- focus
      focus $this

      #--- raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $this <Key-F1> { ::console::GiveFocus }

      #--- mise a jour dynamique des couleurs
      ::confColor::applyColor $this
   }

   #---------------------------------------------------------------------------
   #  brief affiche la liste des fichiers convertibles
   #
   proc Select { op } {
      variable private
      variable bdd

      #--- memorise l'operation
      set private(conv2,conversion) "$op"

      #--- efface l'ancienne liste
      catch { $private(conv2,tbl) delete 0 [ $private(conv2,tbl) size ] }

      #--- extrait la liste des fichiers RAW, CFA, RGB ou R G B, ou indifferencies de bdd
      set private(conv2,liste_cibles) [ lsort -dictionary -index 0 [ lindex [ array get bdd $op ] 1 ] ]

      set private(conv2,nb) [ llength $private(conv2,liste_cibles) ]

      #--- cree une ligne par fichier convertible
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set cible [ lindex $private(conv2,liste_cibles) $i ]

         #--- adapte le texte a afficher (premier chargement)
         switch -exact $op {
            "raw2fits"     {  set out "[ file rootname $cible ]$private(conv2,extension)" }
            "cfa2rgb"      {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname $cible ]" }
            "rgb2r+g+b"    {  set cible "[ file rootname $cible ]"
                              set out "${cible}r + ${cible}g + ${cible}b"
                           }
            "r+g+b2rgb"    {  set out $cible
                              set cible "${cible}r + ${cible}g + ${cible}b"
                           }
            "assigner_r"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]r"
                           }
            "assigner_g"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]g"
                           }
            "assigner_b"   {  set cible "[ file rootname $cible ]"
                              set out "[ file rootname [string range $cible 0 end-1] ]b"
                           }
         }

         #--- insere la nouvelle ligne
         if { $cible == "$::caption(pretraitement,no_file)" } {
            $private(conv2,tbl) insert end [ list "" "$cible" ]
            set private(conv2,nb) "0"
         } elseif { $cible == "$::caption(pretraitement,no_file)r + $::caption(pretraitement,no_file)g + $::caption(pretraitement,no_file)b" } {
            $private(conv2,tbl) insert end [ list "" "$::caption(pretraitement,no_file)" ]
            set private(conv2,nb) "0"
         } else {
            $private(conv2,tbl) insert end [ list "" "$cible" "-->" "$out" "" ]
            #--- insere le checkbutton
            $private(conv2,tbl) cellconfigure end,0 -window [ list ::conv2::CreateCheckButton $i ]
         }
      }

      ::conv2::WindowConfigure $op

      focus $private(conv2,This)
   }

   #---------------------------------------------------------------------------
   #  brief créé les listes de fichiers selectionnés (entree et sortie)
   #  details en conformité avec les processus de traitement
   #  les fichiers peuvent etre renommés et/ou renumerotés
   #  de manière à pouvoir être pretraités (offset, dark et flat)
   #
   proc UpdateDialog { } {
      variable private

      #--- initialise les listes de fichiers in & out
      lassign { "" "" } private(conv2,in) private(conv2,out)

      #--- recupere la valeur de la commande de renumerotation
      set renumerote $::conv2::private(conv2,renum)

      #--- recupere la valeur de la commande de modification du nom generique
      set chg_generique $::conv2::private(conv2,chg)
      set this $private(conv2,This).generique
     if { $chg_generique == 0 } {
         set private(conv2,new_name) ""
         $this configure -state disabled
      } else {
         if { $private(conv2,new_name) == "" } {
            set op $private(conv2,conversion)
            set private(conv2,new_name) $private(conv2,$op,generique)
         }
         $this configure -state normal
      }

      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {

         set in [ lindex $private(conv2,liste_cibles) $i ]
         set out [ file rootname $in ]

         #--- efface le contenu de la cellule REMARQUE
         $private(conv2,tbl) cellconfigure $i,done -image ""

         #--- configure l'affichage des fichiers selectionnes en fonction des options
         if { $::conv2::private(conv2,file_$i) == "1" } {

            #--- decompose le nom en generique et index
            lassign [ decomp $in ] rep generique_in index_out

            #--- change le generique
            set out $generique_in
            if { $chg_generique == "1" } { set out $private(conv2,new_name) }

            #--- modifie l'indexation des fichiers de sortie
            if { $renumerote == "1" } { set index_out [ expr { [ llength $private(conv2,out) ]+1} ] }

            #--- reconstitue le nom de sortie
            set out "$out$index_out"

            #--- verifie s'il y a collision avec un fichier exsitant ou a creer
            if [ ::conv2::Collision "$in" "$out" ] {
               #--- deselectionne le checkbutton
               set w [ $private(conv2,tbl) windowpath $i,0 ]
               $w deselect
               #--- affiche le symbole interdit
               ::conv2::Avancement nop $i
            }
         }

         #--- rafraichissement du nom 'out' sans extension sauf pour raw2fits
         switch -exact $private(conv2,conversion) {
            "raw2fits"     { set texte "$out$private(conv2,extension)" }
            "r+g+b2rgb"    { set texte "$out" }
            "rgb2r+g+b"    { set texte "${out}r + ${out}g + ${out}b" }
            "cfa2rgb"      { set texte "$out" }
            "assigner_r"   { set texte "${out}r" }
            "assigner_g"   { set texte "${out}g" }
            "assigner_b"   { set texte "${out}b" }
         }

         #--- actualise l'affichage dans la tablelist
         $private(conv2,tbl) cellconfigure $i,dest -text $texte
      }
      ::conv2::WindowUpdate
   }

   #---------------------------------------------------------------------------
   #  brief détecte les collisions avec des fichiers existants ou à créer et
   #constitue les listes de fichiers à convertir in & out
   #  param in nom entrant
   #  param out nom sortant
   #  return 1 si collision sinon 0
   #
   proc Collision { in out } {
      variable private

      set ext $private(conv2,extension)
      switch -exact $private(conv2,conversion) {
         "raw2fits"     { set file_out $out$ext
                          set explore [ list "$file_out" ]
                        }
         "r+g+b2rgb"    { set file_out "$out"
                          set explore [ list "$out$ext" ]
                        }
         "rgb2r+g+b"    { set file_out "$out"
                          foreach i { r g b } {
                           set name$i $out
                           append name$i  "$i$ext"
                          }
                          set explore [ list $namer $nameg $nameb ]
                        }
         "cfa2rgb"      { set file_out "$out$ext"
                          set explore [ list "$file_out" ]
                        }
         "assigner_r"   { set file_out "${out}r$ext"
                          set explore [ list "$file_out"]
                        }
         "assigner_g"   { set file_out "${out}g$ext"
                          set explore [ list "$file_out"]
                        }
         "assigner_b"   { set file_out "${out}b$ext"
                          set explore [ list "$file_out"]
                        }
      }

      #--- detecte un fichier out pre-existant ou a venir
      set err "0"
      foreach f $explore {
         #--- file exists retourne 1 si le fichier teste existe dans le repertoire
         set err [ expr { $err + [ file exists [ file join $private(conv2,rep) $f ] ] } ]

         #--- incremente le nombre d'erreur si le nom du fichier existe dans la liste des fichiers a creer
         if { $private(conv2,out) != "" && ($f in $private(conv2,out)) } { incr err }
      }

      if { $err == "0" } {
         #--- complete les listes de fichiers entrant et sortant
         lappend private(conv2,in) "$in"
         lappend private(conv2,out) $file_out
      }

     return $err
   }

   #------------------------ pilote de conversion --------------------------

   #---------------------------------------------------------------------------
   #  brief commande de la commande "OK"
   #
   proc cmdOk { } {
      ::conv2::cmdApply
      ::conv2::cmdClose
   }

   #---------------------------------------------------------------------------
   #  brief commande de la commande "Aide"
   #
   proc afficheAide { } {
      ::audace::showHelpItem "$::help(dir,images)" "1030conversion_couleurs.htm"
   }

   #---------------------------------------------------------------------------
   #  brief pilote les conversions à partir des listes in & out
   #
   proc cmdApply { } {
      variable private

      #--- elimine les caracteres non autorises dans le nom
      ::conv2::EntryCtrl

      set l [ llength $private(conv2,in) ]
      #--- arrete si aucune selection
      if { $l == "0" } {
         ::conv2::Error "$::caption(pretraitement,no_selection)"
         return
      }

      #--- change l'etat des boutons et appelle la console
      #--- pour les eventuels messages d'erreur
      ::conv2::WindowActive disabled
      ::console::GiveFocus
      update

      for { set i 0 } { $i < $l } { incr i } {

         #--- cherche le rang du fichier traite dans la liste initiale
         set j [ lsearch -exact $private(conv2,liste_cibles) [ lindex $private(conv2,in) $i ] ]

         #--- definit les noms complets in et out
         set in [ file join $private(conv2,rep) [ lindex $private(conv2,in) $i ] ]
         set out [ file join $private(conv2,rep) [ lindex $private(conv2,out) $i ] ]

         #--- amene la cellule dans la zone visible
         $private(conv2,tbl) seecell $j,done
         ::conv2::Avancement "hourglass" $j
         update

         #--- convertit chaque fichier
         switch [ Do_$private(conv2,conversion) $in $out ] {
            0  { ::conv2::Avancement ok $j }
            1  { ::console::affiche_erreur "$private(conv2,msg)\n\n"
                 ::conv2::Avancement info $j
               }
         }
         update

         #--- si demande, detruit l'image-source
         if { $private(conv2,destroy_src) == "1" } {
            foreach f $private(conv2,to_destroy) {
               file delete $f
            }
         }

         #--- detruit le message d'erreur existant
         catch { unset private(conv2,msg) }
      }

      #--- met a jour la base de donnees des fichiers
      ::conv2::ListFiles

      #--- met a jour les commandes du menu
      ::conv2::MenuUpdate

      #--- change l'etat des boutons
      ::conv2::WindowActive normal

      #--- recupere la position de la fenetre
      ::conv2::recupPosition
   }

   #------------------ sept routines de conversion -----------------------

   #---------------------------------------------------------------------------
   ##  @brief assigne des images à la couleur R
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_assigner_r { in out } {
      set buf "buf$::audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR R string "Color extracted (red)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief assigne des images à la couleur G
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_assigner_g { in out } {
      set buf "buf$::audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR G string "Color extracted (green)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief assigne des images à la couleur B
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_assigner_b { in out } {
      set buf "buf$::audace(bufNo)"
      set err [ catch {
         $buf load $in
         $buf setkwd [ list RGBFILTR B string "Color extracted (blue)" "" ]
         $buf save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief créé une image RGB à partir de plans R G B
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_r+g+b2rgb { in out } {
      variable private

      set buf "buf$::audace(bufNo)"

      if {[info exists ::prtr::bitpix]} {
         set bitpix [::prtr::convertBitPix2BitPix $::prtr::bitpix]
         #--   convertit le reglage par defaut en valeur
         switch $::conf(format_fichier_image) {
            "0"   {set bitpix_defaut "ushort" }
            "1"   {set bitpix_defaut "float" }
         }
         if {$bitpix ne "$bitpix_defaut"} {$buf bitpix $bitpix}
      }

      if [ info exists private(conv2,extension) ] {
         set ext "$private(conv2,extension)"
      } else {
         set ext $::conf(extension,defaut)
      }

      set err [ catch {

         set filter ""
         set filternu ""

         #--- charge, modifie les en-tetes et sauve les trois images
         set private(conv2,to_destroy) ""
         foreach i { r g b } k { 1 2 3 } {

            #--- charge chaque image R, G et B
            $buf load ${in}$i$ext

            #--- si necessaire change les mots cles
            ::conv2::MajHeader ${in}$i$ext

            #--- au cas ou les seuils n'existeraient pas
            $buf stat

            #--- construit les en-tetes des seuils couleurs
            set color [ string toupper $i ]
            foreach kwd { MIPS-HI MIPS-LO } level [ list "Hight" "Low"] {
               set val [ lindex [ $buf getkwd $kwd ] 1 ]
               switch $color {
                  R  {  set $kwd$color [ list $kwd$color $val float "Red $level Cut" "adu" ] }
                  G  {  set $kwd$color [ list $kwd$color $val float "Green $level Cut" "adu" ] }
                  B  {  set $kwd$color [ list $kwd$color $val float "Blue $level Cut" "adu" ] }
               }
            }

            #--   recupere le contenu des mots-cles FILTER et FILTERNU
            set filter [ concat $filter [ lindex [$buf getkwd FILTER ] 1 ] ]
            set filternu [ concat $filternu [ lindex [$buf getkwd FILTERNU ] 1 ] ]

            #--- memorise les fichiers a detruire
            lappend private(conv2,to_destroy) ${in}$i$ext

            #--- sauve les images avec un index numerique
            $buf save ${in}$k$ext
         }

         #--- conversion en une image
         fitsconvert3d $in 3 $ext $out
         $buf load $out$ext
         $buf delkwd "RGBFILTR"

         #--- inscrit les seuils couleurs dans l'en-tete
         foreach kwd [ list MIPS-LOR MIPS-HIR MIPS-LOG MIPS-HIG MIPS-LOB MIPS-HIB ] {
            $buf setkwd [ set $kwd ]
         }
         $buf stat

         #---  met a jour FILTER et FILTERNU
         foreach f {FILTER FILTERNU} content [ list $filter $filternu ] {
            if { $content ne "" } {
               set kwd [ $buf getkwd $f ]
               set kwd [ lreplace $kwd 1 2 "sum of \{$content\}" "string" ]
               $buf setkwd $kwd
            }
         }

         #--- sauve l'image couleur
         $buf save $out$ext

         #--- supprime les images avec un index numerique
         foreach i { 1 2 3 } { file delete ${in}$i$ext }
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief créé les plans R G B à partir d'une image RGB
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_rgb2r+g+b { in out } {
      variable private

      set buf "buf$::audace(bufNo)"
      set private(conv2,to_destroy) [ list $in ]

      set err [ catch {

         #--- charge l'image
         $buf load $in

         #--- si necessaire change les mots cles et sauve l'image
         ::conv2::MajHeader $in

         #--- je fixe NAXIS a 2
         set kwdNaxis [ $buf getkwd NAXIS ]
         set kwdNaxis [ lreplace $kwdNaxis 1 1 "2" ]
         $buf setkwd $kwdNaxis

         #--- extrait les seuils bas et haut une seule fois
         foreach kwd [ list MIPS-LO MIPS-HI FILTER FILTERNU ] {
            set $kwd [ $buf getkwd $kwd ]
         }

         #--   textrait les valeurs des mots-cles FILTER et FILTERNU
         if {$FILTER ne "" && $FILTERNU ne ""} {
            regsub {(sum of \{)} [lindex $FILTER 1] "" liste_filter
            regsub \} $liste_filter "" liste_filter
            regsub {(sum of \{)} [lindex $FILTERNU 1] "" liste_filternu
            regsub \} $liste_filternu "" liste_filternu
         }

         foreach indice { 1 2 3 } c { r g b } {

            #--- definit le symbole du plan couleur
            set s [ string toupper $c ]
            switch $s {
               R  { set color Red }
               G  { set color Green }
               B  { set color Blue }
            }
            set filter [ list RGBFILTR $s string "Color extracted ($color)" "" ]
            $buf setkwd $filter

            foreach kwd { MIPS-LO MIPS-HI} {
               #--- cherche le seuil du plan couleur
               set seuil [ $buf getkwd $kwd$s ]
               #--- extrait la valeur
               set valeur [ lindex $seuil 1 ]
               #--- la replace dans le MIPS correspondant
               set $kwd [ lreplace [ set $kwd ] 1 1 $valeur ]
               #--- sauvegarde le seuil
               $buf setkwd [ set $kwd ]
            }

            if {$liste_filter ne "" && $liste_filternu ne "" } {
               set k [expr {$indice-1}]
               set FILTER [lreplace $FILTER 1 1 [lindex $liste_filter $k]]
               $buf setkwd $FILTER
               set FILTERNU [lreplace $FILTERNU 1 2 [lindex $liste_filternu $k] int]
               $buf setkwd $FILTERNU
            }

            #--- sauve le plan couleur
            $buf save3d ${out}$c 3 $indice $indice

         }
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief créé une image RGB à partir d'une image CFA
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_cfa2rgb { in out } {
      variable private

      set buf "buf$::audace(bufNo)"
      set ext [ file extension $out ]
      set dir [ file dirname $out]
      set generique [ file rootname $out ]
      set nom [ file tail $generique ]
      set private(conv2,to_destroy) [ list $in ]

      set err [ catch {

         #--- charge l'image
         $buf load $in

         #--- si necessaire change les mots cles et sauve l'image
         ::conv2::MajHeader $in

         #--- convertit en couleurs
         $buf cfa2rgb 1

         #--- permet le calcul les seuils
         $buf stat

         #--- sauve l'image
         $buf save $out

         #--- decompose l'image couleurs en 3 plans pour calculer les seuils
         #--- memorise NAXIS
         set kwdNaxis [ $buf getkwd NAXIS ]
         #--- fixe NAXIS a 2
         $buf setkwd [ lreplace $kwdNaxis 1 1 "2" ]

         foreach indice { 1 2 3 } {
            #--- definit le filtre RGBFILTR de chaque plan
            switch $indice {
                  1  {  set filter [ list RGBFILTR R string "Color extracted (Red)" "" ] }
                  2  {  set filter [ list RGBFILTR G string "Color extracted (Green)" "" ] }
                  3  {  set filter [ list RGBFILTR B string "Color extracted (Blue)" "" ] }
            }
            #--- change l'en-tete
            $buf setkwd $filter
            #--- sauve le plan couleur
            $buf save3d ${generique}$indice$ext 3 $indice $indice
         }

         #--- fait les stat sur les 3 plans couleurs
         ttscript2 "IMA/SERIES \"$dir\" $nom 1 3 $ext \"$dir\" $nom 1 $ext STAT"

         #--- reprend chaque plan couleur
         foreach file [ list ${generique}1 ${generique}2 ${generique}3 ] color { R G B } {
            #--- extrait les kwd
            set kwds_list [ fitsheader $file$ext ]

            foreach kwd [ list "MIPS-LO" "MIPS-HI" ] level [ list "Low" "Hight" ] {
               #--- cherche l'index du mot cle
               set index [ lsearch -index 0 $kwds_list $kwd ]
               #--- isole la valeur
               set val [ lindex [ lindex $kwds_list $index ] 1 ]
               #--- memorise le seuil couleur
               switch $color {
                  R  {  set $kwd$color [ list $kwd$color $val float "Red $level Cut" "adu" ] }
                  G  {  set $kwd$color [ list $kwd$color $val float "Green $level Cut" "adu" ] }
                  B  {  set $kwd$color [ list $kwd$color $val float "Blue $level Cut" "adu" ] }
               }
            }
         }

         #--- efface la mention du plan couleur
         $buf delkwd RGBFILTR

         #--- retablit naxis=3
         $buf setkwd $kwdNaxis

         #--- inscrit les seuils couleurs dans l'en-tete
         foreach kwd [ list MIPS-LOR MIPS-HIR MIPS-LOG MIPS-HIG MIPS-LOB MIPS-HIB ] {
            $buf setkwd [ set $kwd ]
         }

         #--- sauve l'image
         $buf save $out

         #--- efface les plans couleurs
         ttscript2 "IMA/SERIES \"$dir\" $nom 1 3 $ext . . . . DELETE"

      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #---------------------------------------------------------------------------
   ##  @brief créé une image FITS à partir d'une image RAW
   #   @param in fichier entrant
   #   @param out fichier sortant
   #   @return 0=pas d'erreur 1=erreur
   #
   proc Do_raw2fits { in out } {
      variable private

      set err [ catch {
         buf$::audace(bufNo) load $in
         #buf$::audace(bufNo) stat
         buf$::audace(bufNo) save $out
      } ]

      if { $err == "1" } {
         set private(conv2,msg) [ format $::caption(pretraitement,echec) $in $::errorInfo ]
      }
      return $err
   }

   #------------------------- fonctions diverses ---------------------------

   #---------------------------------------------------------------------------
   ##  @brief met à jour des mots clés des images issus CFA et RGB
   #   @details la conversion se fait apres modification  des mots clés et sauvegarde de l'image ;
   #   pour R+G+B il faut charger, modifier et sauver les trois images
   #   @param file chemin du fichier
   #
   proc MajHeader { file } {
      set bufNo $::audace(bufNo)

      if ![ info exists ::conv2::maj_header ] {
         set ::conv2::maj_header ""
      }

      #--- teste si l'image est dans la liste des fichiers contenant un ancien mot cle
      if { [ lsearch -regexp $::conv2::maj_header $file ] != "-1" } {

         set old_kwds [ list RAW_COLORS RAW_FILTER RAW_BLACK RAW_MAXIMUM ]
         set new_kwds [ list RAWCOLOR RAWFILTE RAWBLACK RAWMAXI ]
         set mot_vide "{} {} {none} {} {}"

         foreach old $old_kwds new $new_kwds {

            #--- copie l'ancien mot cle
            set data [ buf$bufNo getkwd $old ]

            if { $data != $mot_vide } {

               #--- remplace l'ancien mot par le nouveau
               set data [ lreplace $data 0 0 "$new" ]

               #--- ecrit le nouveau mot-cle
               buf$bufNo setkwd $data

               #--- detruit l'ancien mot-cle
               buf$bufNo delkwd $old

               #--- sauve l'image modifiee
               buf$bufNo save $file
            }
         }
      }
   }

   #---------------------------------------------------------------------------
   #  brief gère l'image affichée dans la colonne REM
   #  param img icône
   #  param j   référence de la cell
   #
   proc Avancement { img j } {
      variable private

      $private(conv2,tbl) cellconfigure $j,done -image $private(conv2,$img)
   }

   #---------------------------------------------------------------------------
   #  brief active/désactive les commandes
   #  param etat normal ou disabled
   #
   proc WindowActive { etat } {
      variable private

      set this $private(conv2,This)

      #--   le bouton 'Appliquer' et le message
      if { $etat == "disabled" } {
         $this.labURLmsg configure -text $::caption(pretraitement,en_cours)
         $this.cmd.appliquer configure -relief sunken
      } else {
         #--- actualise le message concernant le nombre de selection
         $this.labURLmsg configure -text $::caption(pretraitement,fin_traitement)
         $this.cmd.appliquer configure -relief raised
      }

      #--   les autres commandes
      set frames { but chg generique renum all cmd.ok cmd.appliquer cmd.aide cmd.fermer }
      #--   ne propose pas la destruction pour ces fonctions
      set filtres [list "raw2fits" "assigner_r" "assigner_g" "assigner_b"]
      if { $private(conv2,conversion) ni $filtres } {

         lappend frames "destroy_src"
      }
      foreach frame $frames { $this.$frame configure -state $etat }

      #---  tous les checkbuttons des series
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set w [ $private(conv2,tbl) windowpath $i,0 ]
         $w configure -state $etat
      }
      update
   }

   #---------------------------------------------------------------------------
   #  brief gère la fenêtre lors de la sélection d'une conversion
   #  param op opération sélectionnée
   #
   proc WindowConfigure { op } {
      variable private

      #--- dimensionne la largeur des colonnes
      foreach col {0 1 2 3 4 } wi [ list 3 0 3 0 4 ] {
         $private(conv2,tbl) columnconfigure $col -width $wi
      }

      set this $private(conv2,This)
      #--- actualise le message
      if { $private(conv2,nb) != "0" } {
         $this.labURLmsg configure -text "$::caption(pretraitement,nb_select) 0/[ $private(conv2,tbl) size ]"
      } else {
         $this.labURLmsg configure -text "$::caption(pretraitement,nb_select) 0/$private(conv2,nb)"
      }

      #--- decoche toutes les options
      foreach child { all renum chg destroy_src } {$this.$child deselect}

      #--- affiche le texte generique
      set filtres [list "raw2fits" "assigner_r" "assigner_g" "assigner_b"]
      if { $op in $filtres } {
         $this.chg toggle
         set private(conv2,new_name) $private(conv2,$op,generique)
         $this.generique configure -state normal
      } else {
         set private(conv2,new_name) ""
         $this.generique configure -state disabled
      }

      #--- interdit ces widgets s'il n'y a pas de fichiers a convertir
      if { $private(conv2,$op,no_file) == [ list $::caption(pretraitement,no_file) ] } {
         set state disabled
      } else {
         set state normal
      }
      $this.all configure -state $state
      $this.renum configure -state $state
      $this.chg configure -state $state
      $this.generique configure -state $state
      if { $op ni $filtres} {$this.destroy_src configure -state $state}

      #--- interdit la destruction des sources raw ou en cas d'assignation des plans
      if { $op in $filtres } {  set state disabled }
      $this.destroy_src configure -state $state
   }

   #---------------------------------------------------------------------------
   #  brief met à jour la fenêtre lors de la sélection d'un fichier
   #
   proc WindowUpdate { } {
      variable private

      set l [ llength $private(conv2,in) ]
      #--- actualise la case a cocher de l'option 'Tout convertir'
      if { $private(conv2,nb) == $l } {
         $private(conv2,This).all select
      } else {
         $private(conv2,This).all deselect
      }

      #--- actualise le message concernant le nombre de selections
      set affiche "$::caption(pretraitement,nb_select) $l/$private(conv2,nb)"
      $private(conv2,This).labURLmsg configure -text $affiche
   }

   #---------------------------------------------------------------------------
   #  brief configure le menu en fonction des listes
   #
   proc MenuUpdate { } {
      variable private

      #--- modifie les commandes liees au menu
      foreach op $private(conv2,operations) {
         set k [ lsearch -exact $private(conv2,operations) $op ]
         incr k
         $private(conv2,This).but.menu entryconfigure $k \
            -state $private(conv2,$op,state) \
            -command [ list ::conv2::Select $op ]
      }
   }

   #---------------------------------------------------------------------------
   #  brief sélectionne/désélectionne tous les checkbuttons de la tablelist
   #
   proc SelectAll { } {
      variable private

      set cmd "deselect"
      if { $::conv2::private(conv2,all) == 1 } { set cmd "select" }
      for { set i 0 } { $i < $private(conv2,nb) } { incr i } {
         set w [ $private(conv2,tbl) windowpath $i,0 ]
         $w $cmd
      }
      ::conv2::UpdateDialog
   }

   #---------------------------------------------------------------------------
   #  brief élimine les caractères non autorisés dans le nom
   #
   proc EntryCtrl { } {
      variable private

      regsub -all {[^\w\-_]} $private(conv2,new_name) {} private(conv2,new_name)
      ::conv2::UpdateDialog
   }

   #---------------------------------------------------------------------------
   #  brief affiche une fenêtre d'erreur
   #  param msg message d'erreur
   #
   proc Error { msg } {
      tk_messageBox -title $::caption(pretraitement,attention)\
         -icon error -type ok -message $msg
   }

   #---------------------------------------------------------------------------
   #  brief créé un checkbutton pour inserer dans une tablelist
   #  param index index de la ligne de la tablelist
   #  param tbl complété automatiquement
   #  param row complété automatiquement
   #  param col complété automatiquement
   #  param w   complété automatiquement
   #
   proc CreateCheckButton { index tbl row col w } {
      variable private

      checkbutton $w -height 1 -indicatoron 1 -onvalue "1" -offvalue "0" \
         -variable ::conv2::private(conv2,file_$index) \
         -command "::conv2::UpdateDialog"
      $w deselect
   }

   #---------------------------------------------------------------------------
   #  brief créé un checkbutton normal
   #  param f fenêtre parent
   #  param var nom de la variable associée
   #
   proc CheckButton { f var } {
      variable private

      checkbutton $f.$var -indicatoron 1 -onvalue "1" -offvalue "0" \
         -text "$::caption(pretraitement,$var)" \
         -variable ::conv2::private(conv2,$var) \
         -command "::conv2::UpdateDialog"
      $f.$var deselect
   }

   #---------------------------------------------------------------------------
   ##  @brief ferme la fenêtre
   #
   proc cmdClose { } {
      variable private
      variable bdd

      ::conv2::recupPosition
      catch {
         unset bdd
         destroy $private(conv2,This)
      }
      unset private
   }

   #---------------------------------------------------------------------------
   ##  @brief créé le dictionnaire des fonctions de conversion
   #   @param function 0 ou nom de la fonction
   #   @return liste des fonctions ou les paramètres d'une fonction spécifiée
   #
   proc CONVERSIONFunctions {function} {
      variable CONVERSION

      #--- definit le nom generique propose pour le fichier de sortie des RAW
      set dir "[ file tail [ file rootname "$::audace(rep_images)" ] ]_"

      #--- remplace les caracteres
      regsub -all {[^\w_-]} $dir {} dir

      dict set CONVERSION "$::caption(audace,menu,raw2fits)"     fun "raw2fits"
      dict set CONVERSION "$::caption(audace,menu,raw2fits)"     gen "$dir"
      dict set CONVERSION "$::caption(audace,menu,cfa2rvb)"      fun "cfa2rgb"
      dict set CONVERSION "$::caption(audace,menu,cfa2rvb)"      gen "rgb_"
      dict set CONVERSION "$::caption(audace,menu,rvb2r+v+b)"    fun "rgb2r+g+b"
      dict set CONVERSION "$::caption(audace,menu,rvb2r+v+b)"    gen "plan_"
      dict set CONVERSION "$::caption(audace,menu,r+v+b2rvb)"    fun "r+g+b2rgb"
      dict set CONVERSION "$::caption(audace,menu,r+v+b2rvb)"    gen "img3d_"
      dict set CONVERSION "$::caption(audace,menu,assigner_r)"   fun "assigner_r"
      dict set CONVERSION "$::caption(audace,menu,assigner_r)"   gen "plan_"
      dict set CONVERSION "$::caption(audace,menu,assigner_g)"   fun "assigner_g"
      dict set CONVERSION "$::caption(audace,menu,assigner_g)"   gen "plan_"
      dict set CONVERSION "$::caption(audace,menu,assigner_b)"   fun "assigner_b"
      dict set CONVERSION "$::caption(audace,menu,assigner_b)"   gen "plan_"

      if {$function ne "0"} {
         foreach key {fun hlp gen} {
            lappend result "[dict get $CONVERSION $function $key]"
         }
      } else {
         set result "[dict keys $CONVERSION]"
      }
      return $result
   }

}

############################# Fin du namespace conv2 #############################[

## namespace traiteWindow
#  @brief Prétraitements sur une image

namespace eval ::traiteWindow {

   #---------------------------------------------------------------------------
   ## @brief Lance la fenêtre de dialogue pour les pretraitements sur une image
   #  @param type_pretraitement (aligner)
   #
   proc run { type_pretraitement } {
      variable This $::audace(base).traiteWindow
      variable widget

      ::traiteWindow::initConf
      ::traiteWindow::confToWidget
      set ::traiteWindow(captionOperation) "$::caption(audace,menu,recentrer_manu)"
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {
         if { [ info exists ::traiteWindow(geometry) ] } {
            set deb [ expr 1 + [ string first + $::traiteWindow(geometry) ] ]
            set fin [ string length $::traiteWindow(geometry) ]
            set widget(traiteWindow,position) "+[string range $::traiteWindow(geometry) $deb $fin]"
         }
         ::traiteWindow::createDialog "$type_pretraitement"
      }
      #---
      set ::traiteWindow(operation) "$type_pretraitement"
   }

   #---------------------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Aligner Sélection..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(traiteWindow,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if { ! [ info exists ::conf(traiteWindow,position) ] } { set ::conf(traiteWindow,position) "+350+75" }
   }

   #---------------------------------------------------------------------------
   #  brief charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget

      set widget(traiteWindow,position) "$::conf(traiteWindow,position)"
   }

   #---------------------------------------------------------------------------
   #  brief charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget

      set ::conf(traiteWindow,position) "$widget(traiteWindow,position)"
   }

   #---------------------------------------------------------------------------
   #  brief récupère la position de la fenêtre
   #
   proc recupPosition { } {
      variable This
      variable widget

      set ::traiteWindow(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $::traiteWindow(geometry) ] ]
      set fin [ string length $::traiteWindow(geometry) ]
      set widget(traiteWindow,position) "+[string range $::traiteWindow(geometry) $deb $fin]"
      #---
      ::traiteWindow::widgetToConf
   }

   #---------------------------------------------------------------------------
   #  brief créé la fenêtre de dialogue
   #
   proc createDialog { type_pretraitement } {
      variable This
      variable widget

      #--- Initialisation des variables principales
      set ::traiteWindow(in)            ""
      set ::traiteWindow(nb)            ""
      set ::traiteWindow(valeur_indice) "1"
      set ::traiteWindow(out)           ""
      set ::traiteWindow(sup_boite)     "0"
      set ::traiteWindow(disp)          "1"
      set ::traiteWindow(avancement)    ""

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$::caption(audace,menu,images) - $::caption(audace,menu,center)"
      wm geometry $This $widget(traiteWindow,position)
      wm transient $This $::audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteWindow::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised

         frame $This.usr.4 -borderwidth 1 -relief raised
            frame $This.usr.4.1 -borderwidth 0 -relief flat
               label $This.usr.4.1.labURL1 -textvariable "traiteWindow(avancement)" -fg $::color(blue)
               pack $This.usr.4.1.labURL1 -side top -padx 10 -pady 5
            pack $This.usr.4.1 -side top -fill both
        # pack $This.usr.4 -in $This.usr -side top -fill both

         frame $This.usr.3a -borderwidth 1 -relief raised
            frame $This.usr.3a.1 -borderwidth 0 -relief flat
               checkbutton $This.usr.3a.1.che1 -text "$::caption(pretraitement,afficher_der_image_fin)" \
                  -variable ::traiteWindow(disp)
               pack $This.usr.3a.1.che1 -side left -padx 10 -pady 5
            pack $This.usr.3a.1 -side top -fill both
        # pack $This.usr.3a -in $This.usr -side top -fill both

         frame $This.usr.2 -borderwidth 1 -relief raised
            frame $This.usr.2.1 -borderwidth 0 -relief flat
               label $This.usr.2.1.lab1 -textvariable "traiteWindow(image_A)"
               pack $This.usr.2.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.2.1.ent1 -textvariable ::traiteWindow(in)
               pack $This.usr.2.1.ent1 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.1.explore -text "$::caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 1 }
               pack $This.usr.2.1.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.1 -side top -fill both
            frame $This.usr.2.2 -borderwidth 0 -relief flat
               label $This.usr.2.2.lab2 -textvariable "traiteWindow(nombre)" -width 20
               pack $This.usr.2.2.lab2 -side left -padx 5 -pady 5
               entry $This.usr.2.2.ent2 -textvariable ::traiteWindow(nb) -width 7 -justify center
               pack $This.usr.2.2.ent2 -side left -padx 10 -pady 5
            pack $This.usr.2.2 -side top -fill both
            frame $This.usr.2.3 -borderwidth 0 -relief flat
               label $This.usr.2.3.lab3 -textvariable "traiteWindow(premier_indice)" -width 20
               pack $This.usr.2.3.lab3 -side left -padx 5 -pady 5
               entry $This.usr.2.3.ent3 -textvariable ::traiteWindow(valeur_indice) -width 7 -justify center
               pack $This.usr.2.3.ent3 -side left -padx 10 -pady 5
            pack $This.usr.2.3 -side top -fill both
            frame $This.usr.2.4 -borderwidth 0 -relief flat
               label $This.usr.2.4.lab4 -textvariable "traiteWindow(image_B)"
               pack $This.usr.2.4.lab4 -side left -padx 5 -pady 5
               entry $This.usr.2.4.ent4 -textvariable ::traiteWindow(out)
               pack $This.usr.2.4.ent4 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.2.4.explore -text "$::caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteWindow::parcourir 2 }
               pack $This.usr.2.4.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.2.4 -side top -fill both
        # pack $This.usr.2 -in $This.usr -side top -fill both

         frame $This.usr.2a -borderwidth 1 -relief raised
            checkbutton $This.usr.2a.che1 -text "$::caption(pretraitement,sup_boite)" \
               -variable ::traiteWindow(sup_boite)
            pack $This.usr.2a.che1 -side left -padx 10 -pady 5
        # pack $This.usr.2a -side top -fill both

         frame $This.usr.1 -borderwidth 1 -relief raised
            label $This.usr.1.lab1 -text "$::caption(pretraitement,operation_serie)"
            pack $This.usr.1.lab1 -side left -padx 10 -pady 5
            #--- Liste des pretraitements disponibles
            set list_traiteWindow [ list $::caption(audace,menu,recentrer_manu) ]
            #---
            menubutton $This.usr.1.but1 -textvariable ::traiteWindow(captionOperation) -menu $This.usr.1.but1.menu \
               -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach pretrait $list_traiteWindow {
               $m add radiobutton -label "$pretrait" \
                  -indicatoron "1" \
                  -value "$pretrait" \
                  -variable ::traiteWindow(captionOperation) \
                  -command { set ::traiteWindow(operation) "aligner" }
            }
        # pack $This.usr.1 -in $This.usr -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      #---
      frame $This.cmd -borderwidth 1 -relief raised

         button $This.cmd.ok -text "$::caption(pretraitement,ok)" -width 7 \
            -command { ::traiteWindow::cmdOk }
         if { $::conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }

         button $This.cmd.appliquer -text "$::caption(pretraitement,appliquer)" -width 8 \
            -command { ::traiteWindow::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.fermer -text "$::caption(pretraitement,fermer)" -width 7 \
            -command { ::traiteWindow::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

         button $This.cmd.aide -text "$::caption(pretraitement,aide)" -width 7 \
            -command { ::traiteWindow::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

      pack $This.cmd -side top -fill x

      #---
      uplevel #0 trace variable ::traiteWindow(operation) w ::traiteWindow::change

      #---
      bind $This <Key-Return> {::traiteWindow::cmdOk}
      bind $This <Key-Escape> {::traiteWindow::cmdClose}

      #--- Focus
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      if { [ ::traiteWindow::cmdApply ] == "0" } { return }
      ::traiteWindow::cmdClose
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable This

      #---
      set ::traiteWindow(avancement) "$::caption(pretraitement,en_cours)"
      update
      #---

      set in    $::traiteWindow(in)
      set nb    $::traiteWindow(nb)
      set first $::traiteWindow(valeur_indice)
      set out   $::traiteWindow(out)

      #--- Tests sur les images d'entree, le nombre d'images et les images de sortie
      if { $::traiteWindow(in) == "" } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
            -message "$::caption(pretraitement,definir_entree_generique)"
         set ::traiteWindow(avancement) ""
         return 0
      }
      if { $::traiteWindow(nb) == "" } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
            -message "$::caption(pretraitement,choix_nbre_images)"
         set ::traiteWindow(avancement) ""
         return 0
      }
      if { [ TestEntier $::traiteWindow(nb) ] == "0" } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -icon error \
           -message "$::caption(pretraitement,nbre_entier)"
         set ::traiteWindow(avancement) ""
         return 0
      }
      if { $::traiteWindow(valeur_indice) == "" } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
            -message "$::caption(pretraitement,choix_premier_indice)"
         set ::traiteWindow(avancement) ""
         return 0
      }
      if { [ TestEntier $::traiteWindow(valeur_indice) ] == "0" } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -icon error \
            -message "$::caption(pretraitement,nbre_entier1)"
         set ::traiteWindow(avancement) ""
         return 0
      }
      if { $::traiteWindow(out) == "" } {
         if { $::traiteWindow(operation) != "aligner" } {
            tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
               -message "$::caption(pretraitement,definir_image_sortie)"
         } else {
            tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
               -message "$::caption(pretraitement,definir_sortie_generique)"
         }
         set ::traiteWindow(avancement) ""
         return 0
     }
      #--- Calcul du dernier indice de la serie
      set end [ expr $nb + ( $first - 1 ) ]

      #--- Switch
      switch $::traiteWindow(operation) {
         "aligner" {
            set catchError [ catch {
              ::console::affiche_resultat "Usage: registerbox in out number ?visuNo? ?first_index? ?tt_options?\n\n"
               #--- Un cadre trace avec la souris n'existe pas
               if { [ lindex [ list [ ::confVisu::getBox $::audace(visuNo) ] ] 0 ] == "" } {
                  set coordWindow ""
                  loadima $in$first
                  set choix [ tk_messageBox -title $::caption(pretraitement,attention) -type yesno \
                     -message "$::caption(pretraitement,tracer_boite)\n$::caption(pretraitement,appuyer)" ]
                  if { $choix == "yes" } {
                     ::traiteWindow::cmdApply
                     return
                  } elseif { $choix == "no" } {
                     return
                  }
               }
               set coordWindow [ list [ ::confVisu::getBox $::audace(visuNo) ] ]
               registerbox $in $out $nb $::audace(visuNo) $first
               if { $::traiteWindow(disp) == 1 } {
                  loadima $out$end
               }
               if { $::traiteWindow(sup_boite) == 1 } {
                  ::confVisu::deleteBox $::audace(visuNo)
               }
               set ::traiteWindow(avancement) "$::caption(pretraitement,fin_traitement)"
            } m ]
            if { $catchError == "1" } {
               tk_messageBox -title "$::caption(pretraitement,attention)" -icon error -message "$m"
               set ::traiteWindow(avancement) ""
            }
         }
      }
      ::traiteWindow::recupPosition
   }

   #---------------------------------------------------------------------------
   ##  @brief ferme la fenêtre
   #
   proc cmdClose { } {
      variable This

      ::traiteWindow::recupPosition
      destroy $This
      unset This
   }

   #---------------------------------------------------------------------------
   #  brief commande de la commande "Aide"
   #
   proc afficheAide { } {
      if { $::traiteWindow(operation) == "aligner" } {
         set ::traiteWindow(page_web) "1040aligner"
      }
      ::audace::showHelpItem "$::help(dir,images)" "$::traiteWindow(page_web).htm"
   }


   #---------------------------------------------------------------------------
   #  brief adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This

      #---
      set ::traiteWindow(avancement)    ""
      set ::traiteWindow(in)            ""
      set ::traiteWindow(nb)            ""
      set ::traiteWindow(valeur_indice) "1"
      set ::traiteWindow(out)           ""
      #---
      set ::traiteWindow(image_A)        $::caption(pretraitement,image_generique_entree)
      set ::traiteWindow(nombre)         $::caption(pretraitement,image_nombre)
      set ::traiteWindow(premier_indice) $::caption(pretraitement,image_premier_indice)
      set ::traiteWindow(image_B)        $::caption(pretraitement,image_generique_sortie)
      #---
      switch $::traiteWindow(operation) {
         "aligner" {
            pack $This.usr.4 -in $This.usr -side bottom -fill both
            pack $This.usr.1 -in $This.usr -side top -fill both
            pack $This.usr.2 -in $This.usr -side top -fill both
            pack $This.usr.2a -in $This.usr -side top -fill both
            pack $This.usr.3a -in $This.usr -side top -fill both
         }
      }
   }

   #---------------------------------------------------------------------------
   #  brief ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      #--- Fenetre parent
      set fenetre "$::audace(base).traiteWindow"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $::audace(rep_images) $::audace(bufNo) "1" ]
      #--- Le fichier selectionne doit imperativement etre dans le repertoire des images
      if { [ file dirname $filename ] != $::audace(rep_images) } {
         tk_messageBox -title "$::caption(pretraitement,attention)" -type ok \
            -message "$::caption(pretraitement,rep-images)"
         return
      }
      #--- Extraction du nom du fichier
      if { $In_Out == "1" } {
         set ::traiteWindow(info_filename_in) [ ::tkutil::afficherNomGenerique [ file tail $filename ] ]
         set ::traiteWindow(in)               [ lindex $::traiteWindow(info_filename_in) 0 ]
         set ::traiteWindow(nb)               [ lindex $::traiteWindow(info_filename_in) 1 ]
         set ::traiteWindow(valeur_indice)    [ lindex $::traiteWindow(info_filename_in) 2 ]
      } elseif { $In_Out == "2" } {
         if { $::traiteWindow(operation) == "aligner" } {
            set ::traiteWindow(info_filename_out) [ ::tkutil::afficherNomGenerique [ file tail $filename ] ]
            set ::traiteWindow(out)               [ lindex $::traiteWindow(info_filename_out) 0 ]
         } else {
            set ::traiteWindow(out)               [ file rootname [ file tail $filename ] ]
         }
      }
   }
}

########################### Fin du namespace traiteWindow ###########################

## namespace audace

#
## @brief  ajuste et soustrait une gaussienne dans la fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::subfitgauss { visuNo } {

   set bufNo [visu$visuNo buf]
   if {![buf$bufNo imageready] == "1"} {return}

   #--- Je memorise le nom du fichier
   set filename [::confVisu::getFileName $visuNo]

   #--- Je capture la fenetre d'analyse
   set box [::confVisu::getBox $visuNo]

   if { $box == "" } {
      set choix [ tk_messageBox -title $::caption(pretraitement,attention) -type yesno \
         -message "$::caption(pretraitement,tracer_boite)\n$::caption(pretraitement,appuyer)" ]
      if { $choix == "yes" } {
         ::audace::subfitgauss $visuNo
         return
      } elseif { $choix == "no" } {
         return
      }
   }

   if {[lindex [buf$bufNo getkwd NAXIS3] 1] eq "3"} {

      #--   decompose l'image RGB
      set ext [file extension $filename]
      set nom_sans_extension [file rootname $filename]
      ::conv2::Do_rgb2r+g+b $filename $nom_sans_extension

      #--   traite chaque plan
      foreach plan {r g b} {
         buf$bufNo load ${nom_sans_extension}$plan$ext
         set valeurs [ buf$bufNo fwhm $box ]
         set fwhmx   [ lindex $valeurs 0 ]
         set fwhmy   [ lindex $valeurs 1 ]
         buf$bufNo fitgauss $box -sub -fwhmx $fwhmx -fwhmy $fwhmy
         buf$bufNo save ${nom_sans_extension}$plan$ext
      }

      #--   convertit les plans couleurs en RGB
      ::conv2::Do_r+g+b2rgb $nom_sans_extension tmp

      #--   charge l'image du buffer
      buf$bufNo load tmp$ext

      #--   efface les plans couleurs et le fichier tmp
      file delete ${nom_sans_extension}r$ext ${nom_sans_extension}g$ext ${nom_sans_extension}b$ext
      file delete tmp$ext

   } else {

      #--   calcule fwhmx et fwhmy de l'etoile
      set valeurs [ buf$bufNo fwhm $box ]
      set fwhmx   [ lindex $valeurs 0 ]
      set fwhmy   [ lindex $valeurs 1 ]

      #--   traite une image non-RGB
      buf$bufNo fitgauss $box -sub -fwhmx $fwhmx -fwhmy $fwhmy

   }

   #--- Je rafraichis l'affichage
   ::confVisu::autovisu $visuNo
}

#
## @brief cicatrise l'intérieur d'une fenêtre d'une image
#  @param visuNo numéro de la visu
#
proc ::audace::scar { visuNo } {

   set bufNo [visu$visuNo buf]
   if {![buf$bufNo imageready] == "1"} {return}

   #--- Je memorise le nom du fichier
   set filename [::confVisu::getFileName $visuNo]

   #--- Je capture la fenetre d'analyse
   set box [::confVisu::getBox $visuNo]

   if { $box == "" } {
      set choix [ tk_messageBox -title $::caption(pretraitement,attention) -type yesno \
         -message "$::caption(pretraitement,tracer_boite)\n$::caption(pretraitement,appuyer)" ]
      if { $choix == "yes" } {
         ::audace::scar $visuNo
         return
      } elseif { $choix == "no" } {
         return
      }
   }

   if {[lindex [buf$bufNo getkwd NAXIS3] 1] eq "3"} {

      #--   decompose l'image RGB
      set ext [file extension $filename]
      set nom_sans_extension [file rootname $filename]
      ::conv2::Do_rgb2r+g+b $filename $nom_sans_extension

      #--   traite chaque plan
      foreach plan {r g b} {
         buf$bufNo load ${nom_sans_extension}$plan$ext
         buf$bufNo scar $box
         buf$bufNo save ${nom_sans_extension}$plan$ext
      }

      #--   convertit les plans couleurs en RGB
      ::conv2::Do_r+g+b2rgb $nom_sans_extension tmp

      #--   charge l'image du buffer
      buf$bufNo load tmp$ext

      #--   efface les plans couleurs et le fichier tmp
      file delete ${nom_sans_extension}r$ext ${nom_sans_extension}g$ext ${nom_sans_extension}b$ext
      file delete tmp$ext

   } else {

      #--   traite une image non-RGB
      buf$bufNo scar $box

   }

   #--- Je rafraichis l'affichage
   ::confVisu::autovisu $visuNo
}

############################## Fin du namespace audace ##############################

## namespace traiteFilters

namespace eval ::traiteFilters {

   #
   # ::traiteFilters::run sousMenu typeFiltre
   # Lance la boite de dialogue pour les traitements sur une image
   #
   proc run { sousMenu typeFiltre } {
      variable This
      variable widget

      #---
      ::traiteFilters::initConf
      ::traiteFilters::confToWidget
      #---
      set this $::audace(base).traiteFilters
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         #--- Mise a jour du titre
         wm title $This "$::caption(audace,menu,images) - $sousMenu"
         #--- Selection de la liste des fonction du menubutton
         if { $sousMenu == $::caption(audace,menu,transform) } {
            set list_traiteFilters [ list \
                  $::caption(audace,menu,tfd) \
                  $::caption(audace,menu,tfdi) \
                  $::caption(audace,menu,acorr) \
                  $::caption(audace,menu,icorr) \
               ]
         } elseif { $sousMenu == $::caption(audace,menu,convoluer) } {
            set list_traiteFilters [ list $::caption(audace,menu,convolution) ]
         }
         #--- Mise a jour de la liste des fonction du menubutton
         $This.usr.1.but1.menu delete 0 20
         foreach traitement $list_traiteFilters {
            $This.usr.1.but1.menu add radiobutton -label "$traitement" \
               -indicatoron "1" \
               -value "$traitement" \
               -variable ::traiteFilters(operation) \
               -command { }
         }
         #---
         focus $This
      } else {
         if { [ info exists ::traiteFilters(geometry) ] } {
            set deb [ expr 1 + [ string first + $::traiteFilters(geometry) ] ]
            set fin [ string length $::traiteFilters(geometry) ]
            set widget(traiteFilters,position) "+[string range $::traiteFilters(geometry) $deb $fin]"
         }
         createDialog $sousMenu
      }
      #---
      set ::traiteFilters(operation) "$typeFiltre"
   }

   #
   # ::traiteFilters::initConf
   # Initialisation des variables de configuration
   #
   proc initConf { } {
      if { ! [ info exists ::conf(traiteFilters,position) ] } { set ::conf(traiteFilters,position) "+350+75" }
      if { ! [ info exists ::conf(tfd_ordre) ] }              { set ::conf(tfd_ordre)              "tfd_centre" }
      if { ! [ info exists ::conf(tfd_format) ] }             { set ::conf(tfd_format)             "tfd_polaire" }

      return
   }

   #
   # ::traiteFilters::confToWidget
   # Charge les variables de configuration dans des variables locales
   #
   proc confToWidget { } {
      variable widget

      set widget(traiteFilters,position) $::conf(traiteFilters,position)
   }

   #
   # ::traiteFilters::widgetToConf
   # Charge les variables locales dans des variables de configuration
   #
   proc widgetToConf { } {
      variable widget

      set ::conf(traiteFilters,position) $widget(traiteFilters,position)
   }

   #
   # ::traiteFilters::recup_position
   # Recupere la position de la fenetre
   #
   proc recup_position { } {
      variable This
      variable widget

      set ::traiteFilters(geometry) [wm geometry $This]
      set deb [ expr 1 + [ string first + $::traiteFilters(geometry) ] ]
      set fin [ string length $::traiteFilters(geometry) ]
      set widget(traiteFilters,position) "+[string range $::traiteFilters(geometry) $deb $fin]"
      #---
      ::traiteFilters::widgetToConf
   }

   #
   # ::traiteFilters::createDialog sousMenu
   # Creation de l'interface graphique
   #
   proc createDialog { sousMenu } {
      variable This
      variable widget

      #--- Initialisation
      set ::traiteFilters(choix_mode) "0"
      set ::traiteFilters(image_in)   ""
      set ::traiteFilters(image_out)  ""
      set ::traiteFilters(image_out1) ""
      set ::traiteFilters(image_out2) ""
      set ::traiteFilters(image_in1)  ""
      set ::traiteFilters(image_in2)  ""

      #---
      set ::traiteFilters(avancement)     ""
      set ::traiteFilters(afficher_image) "$::caption(pretraitement,afficher_image_fin)"
      set ::traiteFilters(disp_1)         "1"

      #--- Selection de la liste des fonction du menubutton
      if { $sousMenu == $::caption(audace,menu,transform) } {
         set list_traiteFilters [ list \
               $::caption(audace,menu,tfd) \
               $::caption(audace,menu,tfdi) \
               $::caption(audace,menu,acorr) \
               $::caption(audace,menu,icorr) \
            ]
      } elseif { $sousMenu == $::caption(audace,menu,convoluer) } {
         set list_traiteFilters [ list $::caption(audace,menu,convolution) ]
      }

      #---
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$::caption(audace,menu,images) - $sousMenu"
      wm geometry $This $widget(traiteFilters,position)
      wm transient $This $::audace(base)
      wm protocol $This WM_DELETE_WINDOW ::traiteFilters::cmdClose

      #---
      frame $This.usr -borderwidth 0 -relief raised
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.radiobutton -borderwidth 0 -relief raised
            #--- Bouton radio 'image affichee'
                  radiobutton $This.usr.1.radiobutton.rad0 -anchor nw -highlightthickness 0 -padx 0 -pady 0 -state normal \
                      -text "$::caption(pretraitement,image_affichee)" -value 0 -variable ::traiteFilters(choix_mode) \
                      -command {
                          ::traiteFilters::change n1 n2 op
                          ::traiteFilters::griser "$::audace(base).traiteFilters"
                      }
                  pack $This.usr.1.radiobutton.rad0 -anchor w -side top -padx 10 -pady 5
                  #--- Bouton radio 'image a choisir sur le disque dur'
                  radiobutton $This.usr.1.radiobutton.rad1 \
                      -anchor nw \
                      -highlightthickness 0 \
                      -padx 0 \
                      -pady 0 \
                      -state normal \
                      -text "$::caption(pretraitement,image_a_choisir)" \
                      -value 1 \
                      -variable ::traiteFilters(choix_mode) \
                      -command {
                          ::traiteFilters::change n1 n2 op
                          ::traiteFilters::activer "$::audace(base).traiteFilters"
                      }
                  pack $This.usr.1.radiobutton.rad1 -anchor w -side top -padx 10 -pady 5
           # pack $This.usr.1.radiobutton -side left -padx 10 -pady 5

            #---
            menubutton $This.usr.1.but1 -textvariable ::traiteFilters(operation) -menu $This.usr.1.but1.menu -relief raised
            pack $This.usr.1.but1 -side right -padx 10 -pady 5 -ipady 5
            set m [menu $This.usr.1.but1.menu -tearoff 0]
            foreach traitement $list_traiteFilters {
               $m add radiobutton -label "$traitement" \
                  -indicatoron "1" \
                  -value "$traitement" \
                  -variable ::traiteFilters(operation) \
                  -command { }
            }

         pack $This.usr.1 -side top -fill both -ipady 5

         frame $This.usr.2 -borderwidth 1 -relief raised
         pack $This.usr.2 -side top -fill both -ipady 5

         frame $This.usr.3 -borderwidth 0 -relief raised
            frame $This.usr.3.1 -borderwidth 0 -relief flat
               label $This.usr.3.1.lab1 -text "$::caption(pretraitement,entree)"
               pack $This.usr.3.1.lab1 -side left -padx 5 -pady 5
               entry $This.usr.3.1.ent1 -textvariable ::traiteFilters(image_in)
               pack $This.usr.3.1.ent1 -side left -padx 10 -pady 5 -fill x -expand 1
               button $This.usr.3.1.explore -text "$::caption(pretraitement,parcourir)" -width 1 \
                  -command { ::traiteFilters::parcourir 1 }
               pack $This.usr.3.1.explore -side left -padx 10 -pady 5 -ipady 5
            pack $This.usr.3.1 -side top -fill both
        # pack $This.usr.3 -side top -fill both

         set f [ frame $This.usr.tfd_ordre -borderwidth 0 -relief raised ]
         set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
         label ${g}.l -text "$::caption(pretraitement,tfd_ordre)"
         pack ${g}.l -side top -padx 5 -pady 5
         pack $g -side left -fill both
         set g [ frame ${f}.2 -borderwidth 0 -relief flat ]
         foreach champ [ list tfd_centre tfd_normal ] {
            radiobutton ${g}.$champ -text $::caption(pretraitement,${champ}) -value $champ -variable ::traiteFilters(tfd_ordre)
            pack ${g}.$champ -side left
         }
         pack $g -side right -fill both

         set f [ frame $This.usr.tfd_format -borderwidth 0 -relief raised ]
         set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
         label ${g}.l -text "$::caption(pretraitement,tfd_format)"
         pack ${g}.l -side top -padx 5 -pady 5
         pack $g -side left -fill both
         set g [ frame ${f}.2 -borderwidth 0 -relief flat ]
         foreach champ [ list tfd_polaire tfd_cartesien ] {
            radiobutton ${g}.$champ -text $::caption(pretraitement,${champ}) -value $champ -variable ::traiteFilters(tfd_format)
            pack ${g}.$champ -side left
         }
         pack $g -side right -fill both

         set f [ frame $This.usr.tfd_sortie2 -borderwidth 0 -relief raised ]
         set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
         label ${g}.l -text "$::caption(pretraitement,tfd_sortie1)"
         pack ${g}.l -side left -padx 5 -pady 5
         entry ${g}.e -textvariable ::traiteFilters(image_out1)
         pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${g}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::choix_nom_sauvegarde 3 }
         pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
         set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
         label ${h}.l -text "$::caption(pretraitement,tfd_sortie2)"
         pack ${h}.l -side left -padx 5 -pady 5
         entry ${h}.e -textvariable ::traiteFilters(image_out2)
         pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${h}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::choix_nom_sauvegarde 4 }
         pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
         pack $g $h -side top -fill both

         set f [ frame $This.usr.tfd_entree2 -borderwidth 0 -relief raised ]
         set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
         label ${g}.l -text "$::caption(pretraitement,tfd_entree1)"
         pack ${g}.l -side left -padx 5 -pady 5
         entry ${g}.e -textvariable ::traiteFilters(image_in1)
         pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${g}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::parcourir 5 }
         pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
         set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
         label ${h}.l -text "$::caption(pretraitement,tfd_entree2)"
         pack ${h}.l -side left -padx 5 -pady 5
         entry ${h}.e -textvariable ::traiteFilters(image_in2)
         pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${h}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::parcourir 6 }
         pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
         pack $g $h -side top -fill both

         set f [ frame $This.usr.icorr_entree2 -borderwidth 0 -relief raised ]
         set g [ frame ${f}.1 -borderwidth 0 -relief flat ]
         label ${g}.l -text "$::caption(pretraitement,icorr_entree1)"
         pack ${g}.l -side left -padx 5 -pady 5
         entry ${g}.e -textvariable ::traiteFilters(image_in1)
         pack ${g}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${g}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::parcourir 5 }
         pack ${g}.explore -side left -padx 10 -pady 5 -ipady 5
         set h [ frame ${f}.2 -borderwidth 0 -relief flat ]
         label ${h}.l -text "$::caption(pretraitement,icorr_entree2)"
         pack ${h}.l -side left -padx 5 -pady 5
         entry ${h}.e -textvariable ::traiteFilters(image_in2)
         pack ${h}.e -side left -padx 10 -pady 5 -fill x -expand 1
         button ${h}.explore -text "$::caption(pretraitement,parcourir)" -width 1 -command { ::traiteFilters::parcourir 6 }
         pack ${h}.explore -side left -padx 10 -pady 5 -ipady 5
         pack $g $h -side top -fill both

      pack $This.usr -side top -fill both -expand 1

      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$::caption(pretraitement,ok)" -width 7 \
            -command { ::traiteFilters::cmdOk }
         if { $::conf(ok+appliquer)=="1" } {
            pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$::caption(pretraitement,appliquer)" -width 8 \
            -command { ::traiteFilters::cmdApply }
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$::caption(pretraitement,fermer)" -width 7 \
            -command { ::traiteFilters::cmdClose }
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$::caption(pretraitement,aide)" -width 7 \
            -command { ::traiteFilters::afficheAide }
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Entry actives ou non
      if { $::traiteFilters(choix_mode) == "0" } {
         ::traiteFilters::griser "$::audace(base).traiteFilters"
      } else {
         ::traiteFilters::activer "$::audace(base).traiteFilters"
      }
      #---
      uplevel #0 trace variable ::traiteFilters(operation) w ::traiteFilters::change
      #---
      bind $This <Key-Return> {::traiteFilters::cmdOk}
      bind $This <Key-Escape> {::traiteFilters::cmdClose}
      #--- Focus
      focus $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::traiteFilters::cmdOk
   # Procedure correspondant a l'appui sur le bouton OK
   #
   proc cmdOk { } {
      if { [ ::traiteFilters::cmdApply ] == "0" } { return }
      ::traiteFilters::cmdClose
   }

   #
   # ::traiteFilters::cmdApply
   # Procedure correspondant a l'appui sur le bouton Appliquer
   #
   proc cmdApply { } {
      #---
      set ::traiteFilters(avancement) "$::caption(pretraitement,en_cours) "
      #---
      set ::audace(artifice) "@@@@"
      set image_in           $::traiteFilters(image_in)
      set image_out          $::traiteFilters(image_out)
      set image_out1         $::traiteFilters(image_out1)
      set image_out2         $::traiteFilters(image_out2)
      set image_in1          $::traiteFilters(image_in1)
      set image_in2          $::traiteFilters(image_in2)
      set tfd_ordre          $::traiteFilters(tfd_ordre)
      set tfd_format         $::traiteFilters(tfd_format)
      #--- Sauvegarde des réglages
      set ::conf(tfd_ordre)  $::traiteFilters(tfd_ordre)
      set ::conf(tfd_format) $::traiteFilters(tfd_format)
      if { ( $::traiteFilters(operation) == $::caption(audace,menu,tfdi) )
       || ( $::traiteFilters(operation) == $::caption(audace,menu,icorr) )
       || ( $::traiteFilters(operation) == $::caption(audace,menu,convolution) ) } {
         # La TFD inverse, l'intercorrelation et la convolution requièrent 2 images en entrée
         if { ( $::traiteFilters(image_in1) == "" ) || ( $::traiteFilters(image_in2) == "" ) } {
            tk_messageBox -title $::caption(pretraitement,attention) -type ok -message $::caption(pretraitement,choix_image_dd)
            set ::traiteFilters(avancement) ""
            return 0
         }
      } else {
         #--- Il faut saisir la constante
         if { $::traiteFilters(choix_mode) == "0" } {
            if { [ buf$::audace(bufNo) imageready ] == "0" } {
               tk_messageBox -title $::caption(pretraitement,attention) -type ok -message $::caption(pretraitement,header_noimage)
               set ::traiteFilters(avancement) ""
               return 0
            }
         } elseif { $::traiteFilters(choix_mode) == "1" } {
            if { $::traiteFilters(image_in) == "" } {
               tk_messageBox -title $::caption(pretraitement,attention) -type ok -message $::caption(pretraitement,choix_image_dd)
               set ::traiteFilters(avancement) ""
               return 0
            }
         }
      }

      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $::traiteFilters(operation) \
      "$::caption(audace,menu,tfd)" {
         set extension_fit $::conf(extension,defaut)
         set dft_format "polar"
         if { $tfd_format == "tfd_cartesien" } { set dft_format "cartesian" }
         set dft_order "centered"
         if { $tfd_ordre == "tfd_normal" } { set dft_order "regular" }
         if { ( $image_out1 == $image_out2 ) && ( $::traiteFilters(choix_mode) == "1" ) } {
            tk_messageBox -title $::caption(pretraitement,attention) -icon error \
               -message $::caption(pretraitement,tfd_images_differentes)
            set ::traiteFilters(avancement) ""
            return 0
         }
         if { $::traiteFilters(choix_mode) == "1" } {
            if { [ catch { dft2d $image_in$extension_fit $image_out1$extension_fit $image_out2$extension_fit $dft_format $dft_order } message_erreur ] } {
               tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
            } else {
               buf$::audace(bufNo) load $image_out1$extension_fit
               ::confVisu::autovisu $::audace(visuNo) "-dovisu" $image_out1$extension_fit
            }
         } else {
            if { $dft_format == "polar" } {
               set nom_1 [ file join $::audace(rep_images) modulus$extension_fit ]
               set nom_2 [ file join $::audace(rep_images) argument$extension_fit ]
            } else {
               set nom_1 [ file join $::audace(rep_images) real$extension_fit ]
               set nom_2 [ file join $::audace(rep_images) imaginary$extension_fit ]
            }
            set nom [ file join $::audace(rep_images) [ clock milliseconds ] ]
            append nom $extension_fit
            buf$::audace(bufNo) save $nom
            if { [ catch { dft2d $nom $nom_1 $nom_2 $dft_format $dft_order } message_erreur ] } {
               tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
            } else {
               buf$::audace(bufNo) load $nom_1
               ::confVisu::autovisu $::audace(visuNo) "-dovisu" $nom_1
            }
            file delete $nom
         }
      } \
      "$::caption(audace,menu,tfdi)" {
         set extension_fit $::conf(extension,defaut)
         # Génération d'un nom aléatoire
         set dest [ file join $::audace(rep_images) image$extension_fit ]
         if { [ catch { idft2d $image_in1$extension_fit $image_in2$extension_fit $dest } message_erreur ] } {
            tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
         } else {
            buf$::audace(bufNo) load $dest
            ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
         }
      } \
      "$::caption(audace,menu,acorr)" {
         set extension_fit $::conf(extension,defaut)
         if { $::traiteFilters(choix_mode) == "1" } {
            set dest [ file join $::audace(rep_images) autocorrelation$extension_fit ]
            if { [ catch { acorr2d ${image_in}$extension_fit $dest } message_erreur ] } {
               tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
            } else {
               buf$::audace(bufNo) load $dest
               ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
            }
         } else {
            # Génération d'un nom aléatoire
            set nom_s [ file join $::audace(rep_images) [ clock milliseconds ] ]
            append nom_s $extension_fit
            set nom_d [ file join $::audace(rep_images) autocorrelation$extension_fit ]
            buf$::audace(bufNo) save $nom_s
            if { [ catch { acorr2d $nom_s $nom_d } message_erreur ] } {
               tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
            } else {
               buf$::audace(bufNo) load $nom_d
               ::confVisu::autovisu $::audace(visuNo) "-dovisu" $nom_d
            }
            file delete $nom_s
         }
      } \
      "$::caption(audace,menu,icorr)" {
         set extension_fit $::conf(extension,defaut)
         set dest [ file join $::audace(rep_images) crosscorrelation$extension_fit ]
         if { [ catch { icorr2d ${image_in1}$extension_fit ${image_in2}$extension_fit $dest } message_erreur ] } {
            tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
         } else {
            buf$::audace(bufNo) load $dest
            ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
         }
      } \
      "$::caption(audace,menu,convolution)" {
         set extension_fit $::conf(extension,defaut)
         set dest [ file join $::audace(rep_images) convolution$extension_fit ]
         if { [ catch { conv2d ${image_in1}$extension_fit ${image_in2}$extension_fit $dest denorm } message_erreur ] } {
            tk_messageBox -title $::caption(pretraitement,attention) -icon error -message $message_erreur
         } else {
            buf$::audace(bufNo) load $dest
            ::confVisu::autovisu $::audace(visuNo) "-dovisu" $dest
         }
      }
      ::traiteFilters::recup_position
   }

   #
   # ::traiteFilters::afficheAide
   # Procedure correspondant a l'appui sur le bouton Aide
   #
   proc afficheAide { } {
      if { $::traiteFilters(operation) == $::caption(audace,menu,tfd) } {
         set ::traiteFilters(page_web) "1120TFD"
      } elseif { $::traiteFilters(operation) == $::caption(audace,menu,tfdi) } {
         set ::traiteFilters(page_web) "1130TFDInverse"
      } elseif { $::traiteFilters(operation) == $::caption(audace,menu,acorr) } {
         set ::traiteFilters(page_web) "1140autocorrelation"
      } elseif { $::traiteFilters(operation) == $::caption(audace,menu,icorr) } {
         set ::traiteFilters(page_web) "1150intercorrelation"
      } elseif { $::traiteFilters(operation) == $::caption(audace,menu,convolution) } {
         set ::traiteFilters(page_web) "1160convolution"
      }

      #---
      ::audace::showHelpItem "$::help(dir,images)" "$::traiteFilters(page_web).htm"
   }

   #
   # ::traiteFilters::cmdClose
   # Procedure correspondant a l'appui sur le bouton Fermer
   #
   proc cmdClose { } {
       variable This

       ::traiteFilters::recup_position
       destroy $This
       unset This
   }

   #
   # ::traiteFilters::change n1 n2 op
   # Adapte l'interface graphique en fonction du choix
   #
   proc change { n1 n2 op } {
      variable This

      #--- Initialisation des variables
      set ::traiteFilters(avancement)   ""
      set ::traiteFilters(tfd_ordre)    $::conf(tfd_ordre)
      set ::traiteFilters(tfd_format)   $::conf(tfd_format)
      #--- Switch passe au format sur une seule ligne logique : Les accolades englobant la liste
      #--- des choix du switch sont supprimees pour permettre l'interpretation des variables TCL
      #--- a l'interieur. Un '\' est ajoute apres chaque choix (sauf le dernier) pour indiquer
      #--- que la commande switch continue sur la ligne suivante
      switch $::traiteFilters(operation) \
         "$::caption(audace,menu,tfd)" {
            if { $::traiteFilters(choix_mode) == "0" } {
               pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
               pack $This.usr.3 $This.usr.tfd_sortie2 -in $This.usr.2 -side top -fill both
               pack $This.usr.tfd_ordre -in $This.usr.2 -side top -fill both
               pack $This.usr.tfd_format -in $This.usr.2 -side top -fill both
               pack forget $This.usr.tfd_entree2
               pack forget $This.usr.icorr_entree2
            } elseif { $::traiteFilters(choix_mode) == "1" } {
               pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
               pack $This.usr.3 $This.usr.tfd_sortie2 -in $This.usr.2 -side top -fill both
               pack $This.usr.tfd_ordre -in $This.usr.2 -side top -fill both
               pack $This.usr.tfd_format -in $This.usr.2 -side top -fill both
               pack forget $This.usr.tfd_entree2
               pack forget $This.usr.icorr_entree2
            }
         } \
         "$::caption(audace,menu,tfdi)" {
            pack forget $This.usr.1.radiobutton
            pack forget $This.usr.3
            pack $This.usr.tfd_entree2 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.tfd_ordre
            pack forget $This.usr.tfd_format
            pack forget $This.usr.tfd_sortie2
            pack forget $This.usr.icorr_entree2
         } \
         "$::caption(audace,menu,acorr)" {
            pack $This.usr.1.radiobutton -side left -padx 10 -pady 5 -before $This.usr.1.but1
            pack $This.usr.3 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.tfd_ordre
            pack forget $This.usr.tfd_format
            pack forget $This.usr.tfd_entree2
            pack forget $This.usr.tfd_sortie2
            pack forget $This.usr.icorr_entree2
         } \
         "$::caption(audace,menu,icorr)" {
            pack forget $This.usr.1.radiobutton
            pack forget $This.usr.3
            pack $This.usr.icorr_entree2 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.tfd_ordre
            pack forget $This.usr.tfd_format
            pack forget $This.usr.tfd_sortie2
            pack forget $This.usr.tfd_entree2
         } \
         "$::caption(audace,menu,convolution)" {
            pack forget $This.usr.1.radiobutton
            pack forget $This.usr.3
            pack $This.usr.icorr_entree2 -in $This.usr.2 -side top -fill both
            pack forget $This.usr.tfd_ordre
            pack forget $This.usr.tfd_format
            pack forget $This.usr.tfd_sortie2
            pack forget $This.usr.tfd_entree2
         }
      #--- Rend toujours visible le nom du fichier dans les entry
      update
      $This.usr.3.1.ent1 xview end
      $This.usr.tfd_sortie2.1.e xview end
      $This.usr.tfd_sortie2.2.e xview end
      $This.usr.tfd_entree2.1.e xview end
      $This.usr.icorr_entree2.1.e xview end
      $This.usr.tfd_entree2.2.e xview end
      $This.usr.icorr_entree2.2.e xview end
   }

   #
   # ::traiteFilters::parcourir
   # Ouvre un explorateur pour choisir un fichier
   #
   proc parcourir { In_Out } {
      variable This

      #--- Fenetre parent
      set fenetre "$::audace(base).traiteFilters"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_load $fenetre $::audace(rep_images) $::audace(bufNo) "1" ]
      #--- Nom du fichier avec le chemin et sans son extension
      if { $In_Out == "1" } {
         set ::traiteFilters(image_in) [ file rootname $filename ]
         $This.usr.3.1.ent1 xview end
      } elseif { $In_Out == "5" } {
         set ::traiteFilters(image_in1) [ file rootname $filename ]
         $This.usr.tfd_entree2.1.e xview end
         $This.usr.icorr_entree2.1.e xview end
      } elseif { $In_Out == "6" } {
         set ::traiteFilters(image_in2) [ file rootname $filename ]
         $This.usr.tfd_entree2.2.e xview end
         $This.usr.icorr_entree2.2.e xview end
      }
   }

   #
   # ::traiteFilters::choix_nom_sauvegarde
   # Ouvre un explorateur pour choisir un nom de fichier
   #
   proc choix_nom_sauvegarde { In_Out } {
      variable This

      #--- Fenetre parent
      set fenetre "$::audace(base).traiteFilters"
      #--- Ouvre la fenetre de choix des images
      set filename [ ::tkutil::box_save $fenetre $::audace(rep_images) $::audace(bufNo) "1" ]
      #--- Nom du fichier avec le chemin et sans son extension
      if { $In_Out == "3" } {
         set ::traiteFilters(image_out1) [ file rootname $filename ]
         $This.usr.tfd_sortie2.1.e xview end
      } elseif { $In_Out == "4" } {
         set ::traiteFilters(image_out2) [ file rootname $filename ]
         $This.usr.tfd_sortie2.2.e xview end
      }
   }

   #
   # ::traiteFilters::griser this
   # Grise les widgets disabled
   # this : Chemin de la fenetre
   #
   proc griser { this } {
      variable This

      #--- Initialisation des variables
      set ::traiteFilters(avancement) ""
      #--- Fonction destinee a inhiber et griser des widgets
      set This $this
      $This.usr.3.1.explore configure -state disabled
      $This.usr.3.1.ent1 configure -state disabled
      $This.usr.tfd_sortie2.1.e configure -state disabled
      $This.usr.tfd_sortie2.1.explore configure -state disabled
      $This.usr.tfd_sortie2.2.e configure -state disabled
      $This.usr.tfd_sortie2.2.explore configure -state disabled
   }

   #
   # ::traiteFilters::activer this
   # Active les widgets
   # this : Chemin de la fenetre
   #
  proc activer { this } {
      variable This

      #--- Initialisation des variables
      set ::traiteFilters(avancement) ""
      #--- Fonction destinee a activer des widgets
      set This $this
      $This.usr.3.1.explore configure -state normal
      $This.usr.3.1.ent1 configure -state normal
      $This.usr.tfd_sortie2.1.e configure -state normal
      $This.usr.tfd_sortie2.1.explore configure -state normal
      $This.usr.tfd_sortie2.2.e configure -state normal
      $This.usr.tfd_sortie2.2.explore configure -state normal
   }

   #--------------------------------------------------------------------------
   #  ::traiteFilters::JMFunctions {0|nom_de_fonction}
   #  Cree le dictionnaire des fonctions de conversion
   #  Retourne la liste des fonctions ou les parametres d'une fonction
   #--------------------------------------------------------------------------

   proc JMFunctions {function} {
      variable JM

      dict set JM "$::caption(audace,menu,tfd)"            fun "tfd"
      dict set JM "$::caption(audace,menu,tfdi)"           fun "tfdi"
      dict set JM "$::caption(audace,menu,acorr)"          fun "acorr"
      dict set JM "$::caption(audace,menu,icorr)"          fun "icorr"
      dict set JM "$::caption(audace,menu,convolution)"    fun "convolution"

      if {$function ne "0"} {
         foreach key {fun} {
            lappend result "[dict get $JM $function $key]"
         }
      } else {
         set result "[dict keys $JM]"
      }
      return $result
   }

}
########################## Fin du namespace traiteFilters ##########################

## namespace convfltr
# @brief Scripts pour le filtrage par convolution spatiale d'images N&B ou RGB, FITS ou non
# @author Raymond Zachantke

namespace eval ::convfltr {

   #---------------------------------------------------------------------------
   ##  @brief initialise le widget
   #
   proc run { } {
      variable private

      set visuNo $::audace(visuNo)
      set private(convfltr,visuNo) $visuNo
      set bufNo [visu$visuNo buf]
      if {![buf$bufNo imageready] == "1"} {return}

      initConf

      set private(convfltr,position) $::conf(convfltr,position)

      #--   liste les fichiers dans $home/filter
      set userFilters [lsort -dictionary [glob -nocomplain -type f -tails -dir $::conf(rep_userFiltre) *]]

      #--   identifie leur extension
      set extension [file extension [lindex $userFilters 0]]

      #--   ote l'extension a tous les noms de filtres
      regsub -all "$extension" $userFilters "" filterNames

      #--   compare l'extension a l'extension par defaut de l'utilisateur
      if {$extension ne "$::conf(extension,defaut)"} {
         foreach name $filterNames {
            file rename -force [file join $::conf(rep_userFiltre) $name$extension] \
                [file join $::conf(rep_userFiltre) $name$::conf(extension,defaut)]
         }
      }

      set private(convfltr,filtres) $filterNames

      set ::convfltr::norm "norm"

      ::convfltr::createDialog $visuNo
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Convolution"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - ::conf(convfltr,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if {![info exists ::conf(convfltr,position)]} { set ::conf(convfltr,position) "+200+200" }
   }

   #---------------------------------------------------------------------------
   #  brief construit l'interface graphique
   #  param visuNo numéro de la visu
   #
   proc createDialog { visuNo } {
      variable This $::audace(base).cfltr
      variable private

      if {[winfo exists $This]} {destroy $This}

      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$::caption(audace,menu,convfltr)"
      wm transient $This $::audace(base)
      wm geometry $This $private(convfltr,position)
      wm protocol $This WM_DELETE_WINDOW "::convfltr::cmdClose"

      #--   selection du filtre
      frame $This.f -relief raised -borderwidth 1
      pack $This.f -ipady 5
      label $This.f.label -text "$::caption(convfltr,selectfiltr)" -width 10

      set labelwidth "0"
      foreach label $private(convfltr,filtres) {
         set l [string length $label]
      if {$l > $labelwidth} {set labelwidth $l}
      }
      ComboBox $This.f.fltr -textvariable ::convfltr::kernel -relief sunken \
         -height 10 -width $labelwidth -values $private(convfltr,filtres)
      pack $This.f.label $This.f.fltr -side left -pady 5
      $This.f.fltr setvalue @0

      frame $This.opt -relief raised -borderwidth 1
      pack $This.opt -fill x

      #--   option
      checkbutton $This.opt.norm -text "$::caption(convfltr,normalise)" \
         -variable ::convfltr::norm -indicatoron 1 -offvalue denorm -onvalue norm
      pack $This.opt.norm -padx 10 -pady 10 -anchor w

      #---  commandes habituelles
      set w [frame $This.cmd -relief raised -borderwidth 1]
      button $w.ok -text "$::caption(convfltr,ok)" -width 7 -borderwidth 2 \
         -relief raised -command "::convfltr::cmdOk"
      if {$::conf(ok+appliquer) eq 1} {
         pack $w.ok -side left -padx 3 -pady 3
      }
      button $w.appliquer -text "$::caption(convfltr,appliquer)" -width 7 \
         -borderwidth 2 -relief raised -command "::convfltr::cmdApply"
      pack $w.appliquer -side left -padx 3 -pady 3
      button $w.no -text "$::caption(convfltr,annuler)" -width 7 -borderwidth 2 \
         -relief raised -command "::convfltr::cmdClose"
      button $w.hlp -text "$::caption(convfltr,hlp)" -width 7 \
         -command "::audace::showHelpItem $::help(dir,images) 1170kernel.htm conv_spatiale"
      pack $w.no $w.hlp -side right -padx 3 -pady 3
      pack $w -fill x -ipady 5

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable This
      variable private

      ::convfltr::configButtons disabled

      set visuNo $private(convfltr,visuNo)
      set bufNo [visu$visuNo buf]
      set naxis [lindex [buf$bufNo getkwd NAXIS] 1]
      set nom_noyau $::convfltr::kernel
      set userExtension $::conf(extension,defaut)

      #--   chemin complet du filtre
      set filtre [file join $::conf(rep_userFiltre) $nom_noyau$userExtension]

      #--   image d'entree
      set fileNameIn [::confVisu::getFileName $visuNo]
      set generiqueIn [file rootname [file tail $fileNameIn]]
      set extIn [file extension $fileNameIn]

      #--   nom generique court de l'image de sortie
      set generiqueOut ${nom_noyau}_$generiqueIn
      #--   chemin complet de l'image de sortie
      set fileOut [file join [file dirname $fileNameIn] $generiqueOut$extIn]

      #--   dans tous les cas on travaille dans ::audace(rep_temp)
      #--   pour eviter un ecrasement de fichiers

      #--   recopie une image FITS ou transforme une image non FITS en FITS
      set baseFile [file join $::audace(rep_temp) $generiqueIn]
      buf$bufNo save $baseFile$userExtension

      #--   generique de sortie provisoire
      set tempOut [file join $::audace(rep_temp) ${nom_noyau}_$generiqueIn]

      #--   decompose une image FITS-RGB
      if {$naxis == 3} {
         #--   decompose l'image RGB en plans couleurs
         ::conv2::Do_rgb2r+g+b $baseFile$userExtension $baseFile
         set listIn [ list "${baseFile}r" "${baseFile}g" "${baseFile}b" ]
         set listOut [ list "${tempOut}r" "${tempOut}g" "${tempOut}b" ]
      } else {
         #--   image non RGB
         set listIn [ list "$baseFile" ]
         set listOut [ list "$tempOut" ]
      }

      #--   applique le filtre a chaque plan couleur
      foreach in $listIn out $listOut {
         if {[catch {conv2d $in$userExtension $filtre $out$userExtension $::convfltr::norm} errInfo]} {
            tk_messageBox -title "$::caption(convfltr,attention) " \
               -icon error -message $errInfo
         }
      }

      if {$naxis == 3} {
        #--   verifie l'existance des plans couleurs
         foreach file $listOut {
            if {![file exists $file$userExtension]} {return}
         }

         #--   convertit les plans couleurs en RGB
         ::conv2::Do_r+g+b2rgb $tempOut $tempOut

         #--   efface les plans couleurs de l'image d'entree et de sortie
         foreach  file [concat $listIn $listOut] {
            file delete $file$userExtension
         }
      }

      set src $tempOut$userExtension
      buf$bufNo load $src
      buf$bufNo save $fileOut

      ::confVisu::autovisu $visuNo -dovisu $fileOut

      file delete $baseFile$userExtension $src

      #--   sauve la position de la fenetre
      regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" ::conf(convfltr,position)

      ::convfltr::configButtons normal
   }

   #---------------------------------------------------------------------------
   #  brief configure l'état des boutons
   #  param state normal ou disabled
   #
   proc configButtons { state } {
      variable This

      foreach w [list ok appliquer hlp no] {
         $This.cmd.$w configure -state $state
      }
      update
   }

   #---------------------------------------------------------------------------
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      ::convfltr::cmdApply
      ::convfltr::cmdClose
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Quitter"
   #
   proc cmdClose { } {
      variable This

      destroy $This
   }

}
########################## Fin du namespace convfltr ##########################

## namespace kernel
# @brief Scripts pour la confection de noyaux de convolution spatiale
# @author Raymond Zachantke

namespace eval ::kernel {

   #--un filtre   ==> une image dans le buffer de la visu
   #              ==> un nom "${nom}_${sum}_${drow}x${dcol}" d'extension $::conf(extension,defaut)
   #              ==> un chemin complet [file join $::conf(rep_userFiltre) ${nom}$::conf(extension,defaut)]
   #              ==> une matrice : private(kernel,matrix) de dimensions drow X dcol
   #              ==> l'image de cellules de la matrice dans le GUI : ::kernel::m_${row}_${col}

   #---------------------------------------------------------------------------
   ##  @brief initialise le widget
   #
   proc run { } {
      variable private

      initConf

      set private(kernel,position) $::conf(kernel,position)

      ::kernel::createDialog
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Editeur de noyaux"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(kernel,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if {![info exists ::conf(kernel,position)]} { set ::conf(kernel,position) "+200+200" }
   }

   #--------------------------- les commandes  --------------------------------

   #---------------------------------------------------------------------------
   ## @brief commande de la combobox de sélection du filtre
   #  @details affiche et édite le noyau sélectionné
   #  @param visuNo numéro de la visu
   #
   proc cmdSelectFilter { visuNo } {
      variable private

      set noyau $::kernel::kernel

      #--   si selection de  <nouveau>
      if {$noyau eq "$::caption(kernel,new)"} {
         #--   cree une nouvelle matrice
         ::kernel::cmdFormatMatrix $visuNo
         return
      }

      #--   si selection d'un filtre existant, charge l'image du noyau
      ::kernel::seeFiltr $visuNo [file join $::conf(rep_userFiltre) $noyau$::conf(extension,defaut)]

      #--   lit les valeurs dans le buffer
      ::kernel::buffer2Matrix [visu$visuNo buf]

      #--   transfere la matrice vers l'affichage
      ::kernel::configMatrix "$private(kernel,tbl).grid" $::kernel::drow $::kernel::dcol

      #--   remplit les cases de la matrice affichee
      ::kernel::formatGrid
   }

   #---------------------------------------------------------------------------
   ## @brief commande des combobox de dimensionnement de la matrice
   #  @details formate le nombre de lignes et de colonnes d'une nouvelle matrice ;
   #  invoquée par createDialog et selectFilter
   #  @param visuNo numéro de la visu
   #
   proc cmdFormatMatrix { visuNo } {
      variable private

      set drow $::kernel::drow
      set dcol $::kernel::dcol

      #--   en dehors des matrices 1 ligne ou 1 colonne, la matrice est carree
      if {[info exists private(kernel,size)]} {
         regexp {([1-9])x([1-9])} $private(kernel,size) match r c
         lassign [list "" ""] modif stable
         #--   identifie la variable modifiee
         if {$drow ne "$r"} {
            set modif drow
            set stable dcol
         } elseif {$dcol ne "$c"} {
            set modif dcol
            set stable drow
         }

         #--   egalise les deux dimensions si la dimension stable n'est pas egale a 1
         if {$modif ne "" && [set $stable] ne "1" && [set $modif] ne "1"} {
            set ::kernel::$stable [set $modif]
         }
      }

      #--
      ::kernel::clearVisu $visuNo
      set kernel::norm 0

      set drow $::kernel::drow
      set dcol $::kernel::dcol
      set private(kernel,size) "${drow}x${dcol}"

      #--   cree une nouvelle matrice composee de 0
      ::kernel::createNulMatrix $drow $dcol

      #--   configure la grille pour la saisie
      ::kernel::configMatrix "$private(kernel,tbl).grid" $drow $dcol

      #--   formate les valeurs
      ::kernel::formatGrid

      #--   positionne la combobox sur <nouveau>
      set ::kernel::kernel "$::caption(kernel,new)"
   }

   #---------------------------------------------------------------------------
   ## @brief commande du checkbutton "Normaliser"
   #  @details normalise les valeurs du noyau
   #  @param args arguments
   #
   proc cmdNormMatrix { args } {
      variable private

      set sum $::kernel::sum

      #--   arrete si la somme est nulle
      if {$sum == 0} { return}

      if {$::kernel::norm eq "1"} {
         #--   arrete si deja normalise
         if {$sum == 1} {
            set ::kernel::norm 0
            return
         }

         set matrice [::kernel::grid2Matrix]
         set dim [llength $matrice]

         blt::vector create temp -watchunset 1
         for {set row 0} {$row < $dim} {incr row} {
            temp set [lindex $matrice $row]
            temp expr {temp/$sum}
            set matrice [lreplace $matrice $row $row [temp range 0 end]]
         }
         #--   rafraichit les valeurs
         set ::kernel::kernel "$::caption(kernel,new)"
         set private(kernel,matrix) $matrice

         ::blt::vector destroy temp

         ::kernel::formatGrid
      }
   }

   #---------------------------------------------------------------------------
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      ::kernel::cmdApply
      ::kernel::cmdClose
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable This
      variable private

      set visuNo $private(kernel,visuNo)
      set nom_noyau $::kernel::kernel
      set err 0

      #--   arrete si nom non conforme ou incorrect
      if {$nom_noyau eq "" || $nom_noyau eq "$::caption(kernel,new)"} {
         set err 1
      } else {
         regexp -all {[\w_-]+} $nom_noyau match
         if {$nom_noyau ne "$match"} {
            set err 1
         }
      }
      if {$err eq "1" } {
         ::kernel::avertiUser err_nom
         return
      }

      #--   recupere les valeurs
      set private(kernel,matrix) [::kernel::grid2Matrix]

      #--   verifie que toutes les valeurs sont numeriques
      set drow $::kernel::drow
      set dcol $::kernel::dcol

      blt::vector create essai -watchunset 1
      #--   la creation des vecteurs produit une erreur si valeur non numerique
      for {set i 0} {$i < $drow} {incr i} {
         if {[catch {essai set [lindex $private(kernel,matrix) $i]}]} {
            set err 1
            break
         }
      }
      blt::vector destroy essai

      #--   arrete si erreur
      if {$err == 1} {return}

      set private(kernel,size) "${drow}x${dcol}"

      #--   extrait le nom generique du noyau au cas ou l'uilisateur aurait ecrit les dim
      regsub {_[0-9]_([0-9]+)_[0-9]x[0-9]} $nom_noyau "" noyau

      set file [::kernel::createFilterInVisu $visuNo $noyau]

      ::kernel::seeFiltr $visuNo $file

      #--   met a jour la combobox
      ::kernel::updateListFilters [file rootname [file tail $file]]

      regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" ::conf(kernel,position)
   }

   #---------------------------------------------------------------------------
   ## @brief commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable This
      variable private

      ::kernel::clearVisu $private(kernel,visuNo)
      trace remove variable "::kernel::norm" write "::kernel::cmdNormMatrix"

     destroy $This
   }

   #---------------------------------------------------------------------------
   #  brief contrôle les saisies (numériques)
   #  details binding avec les cases de la matrice
   #  param row nombre de lignes
   #  param col nombre de colonnes
   #
   proc captureValue { row col } {
      variable private

      upvar ::kernel::m_${row}_${col} value

      #--   controle la saisie
      regsub {[^0-9.-]} $value "" result

      if {$result eq "$value"} {
         set private(kernel,matrix) [::kernel::grid2Matrix]
      } else {
         ::kernel::avertiUser err_noyau
      }
   }

   #--------------------------- les routines  math-----------------------------

   #---------------------------------------------------------------------------
   #  brief construit une matrice de dimension m x n avec des  0
   #  details invoquée par cmdSelectFilter et cmdFormatMatrix
   #  param drow nombre de lignes
   #  param dcol nombre de colonnes
   #
   proc createNulMatrix { drow dcol } {
      variable private

      set matrice ""

      for {set i 0} {$i < $drow} {incr i} {
         set liste ""
         for {set j 0} {$j < $dcol} {incr j} {
            lappend liste "0"
         }
         lappend matrice $liste
      }

      set private(kernel,matrix) $matrice
      set ::kernel::sigma "/"
   }

   #---------------------------------------------------------------------------
   #  brief formate les valeurs (entières ou flottantes) de la grille
   #  details invoquée par cmdSelectFilter et cmdFormatMatrix
   #
   proc formatGrid { } {
      variable private

      set drow $::kernel::drow
      set dcol $::kernel::dcol
      set matrice $private(kernel,matrix)
      set sum "0"

      set format [::kernel::getFormat $matrice]

      #--   adapte le format des nombres affiches
      for {set row 1} {$row <= $drow} {incr row} {
         for {set col 1} {$col <= $dcol} {incr col} {
            set value [gsl_mindex $matrice $row $col]
            if {$format eq "integer"} {
               set ::kernel::m_${row}_${col} [format %.f $value]
            } else {
               set ::kernel::m_${row}_${col} [format %.3f $value]
            }
            set sum [expr {$sum+$value}]
         }
      }
      set ::kernel::sum [expr {int($sum)}]

      update
   }

   #---------------------------------------------------------------------------
   #  brief retourne le type de données (entières ou décimales) contenues dans la matrice
   #  details invoquée par formatGrid
   #  param matrice la matrice
   #  return format de la matrice
   #
   proc getFormat { matrice } {
      set drow $::kernel::drow
      set dcol $::kernel::dcol
      set f 0

      blt::vector create decimal entier -watchunset 1

      for {set i 0} {$i < $drow} {incr i} {
         if {![catch {decimal set [lindex $matrice $i]}]} {
            entier expr {round(decimal)}
            entier expr {entier == decimal}
            #-- si toutes les colonnes de la lignes sont identiques
            if {[llength [entier search 1]] eq "$dcol"} {
               incr f
            }
         }
      }

      #-- si toutes les lignes sont identiques
      if {$f eq "$drow"} {
         set format "integer"
      } else {
         set format "float"
      }
      blt::vector destroy decimal entier

      return $format
   }

   #---------------------------------------------------------------------------
   #  brief lit les valeurs affichées dans la grille
   #  details invoquée par cmdNormMatrix, cmdApply et createFilterInVisu
   #  return matrice affichée (liste de listes)
   #
   proc grid2Matrix { } {
      set drow $::kernel::drow
      set dcol $::kernel::dcol

      set matrice ""
      set sum "0"

      for {set row 1} {$row <= $drow} {incr row} {
         set liste ""
         for {set col 1} {$col <= $dcol} {incr col} {
            set value [set ::kernel::m_${row}_${col}]
            lappend liste $value
            set sum [expr {$sum+$value}]
         }
         lappend matrice $liste
      }
      set ::kernel::sum [expr {int(round($sum))}]

      ::kernel::selectElement $matrice

      return $matrice
   }

   #---------------------------------------------------------------------------
   #  brief sélectionne les éléments pour évaluer sigma
   #  details invoquee par grid2Matrix et cmdCreateMatrix
   #  param matrice la matrice
   #
   proc selectElement { matrice } {
      set drow $::kernel::drow
      set dcol $::kernel::dcol
      lassign [list "" "" ""] sigma_x sigma_y sigma

      #--   cas de la matrice 1x1 et par defaut
      lassign [list "" ""] index_x index_y
      if {$drow ne "1" && $dcol ne "1"} {
         #--   cas general
         set index_x [expr {$dcol/2}]
         set index_y [expr {$drow/2}]
      } elseif {$drow eq "1" && $dcol ne "1"} {
         #--   matrice 1xn
         set index_x [expr {$dcol/2}]
         set index_y 0

      } elseif {$drow ne "1" && $dcol eq "1"} {
         #--   matrice nx1
         set index_x 0
         set index_y [expr {$dcol/2}]
      }

      if {$index_x ne "" && $index_y ne ""} {
         #--   selectionne la ligne
         set liste [lindex $matrice $index_y]
         set sigma_x [::kernel::getSigma $liste]

         #--   constitue la liste en colonne
         set liste ""
         for {set i 0} {$i < $drow} {incr i} {
            lappend liste [lindex $matrice $i $index_x]
         }
         set sigma_y [::kernel::getSigma $liste]
      }
      set ::kernel::sigma "$sigma_x/$sigma_y"
      update
   }

   #---------------------------------------------------------------------------
   #  brief calcule la valeur de sigma
   #  details invoquée par selectElement
   #  param vector nom du vecteur
   #  return sigma
   #
   proc getSigma { vector } {
      set sigma ""
      ::blt::vector create temp z -watchunset 1
      temp set $vector
      set l [temp length]

      #--   filtre le cas des vecteurs nuls
      if {[llength [temp search 0]] == $l} {
         return
      }

      #--   normalise
      temp expr {temp/$temp(max)}

      #--   verifie que le maximum est au centre
      set centre [temp search $temp(max)]
      if {$centre == "[expr {$l/2}]"} {
         #--   expansion d'un coefficient 10
         temp populate z 9
         z expr {z >= 0.50}
         set indexes [z search 1]
         set i_min [lindex $indexes 0]
         set i_max [lindex $indexes end]
         set fwhm [expr {($i_max-$i_min)/10.}]
         set sigma [format %.1f [expr {$fwhm/2.35482}]]
      }

      ::blt::vector destroy temp z
      return $sigma
   }

   #--------------------------------GUI---------------------------------------

   #---------------------------------------------------------------------------
   #  brief construit l'interface
   #
   proc createDialog { } {
      variable This $::audace(base).k
      variable private

      set visuNo $::audace(visuNo)
      set private(kernel,visuNo) $visuNo
      set ::kernel::norm 0
      set dim_max [list 1 3 5 7 9]

      if {[winfo exists $This]} {destroy $This}

      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$::caption(audace,menu,kernel)"
      wm transient $This $::audace(base)
      wm geometry $This $private(kernel,position)
      wm protocol $This WM_DELETE_WINDOW "::kernel::cmdClose"

      set tbl "$This.kernel"
      set private(kernel,tbl) $tbl
      frame $tbl

      #--   cree les frames inclus dans la table
      foreach frame {nom taille grid data action cmd} {
         frame $tbl.$frame
      }
      $tbl.grid configure -relief raised -borderwidth 1
      $tbl.cmd configure -relief raised -borderwidth 1

      label $tbl.nom.label_select -text "$::caption(kernel,nom)" -width 10
      ComboBox $tbl.nom.type -textvariable ::kernel::kernel -relief sunken -height 10 \
         -editable 1 -modifycmd "::kernel::cmdSelectFilter $visuNo"
      pack $tbl.nom.label_select $tbl.nom.type -side left

      set w "$tbl.taille"
      label $w.label -text "$::caption(kernel,taille)"
      pack $w.label -in $w -padx 10 -side left
      foreach type {row col} {
         label $w.label_$type -text "$::caption(kernel,$type)"
         ComboBox $w.$type -textvariable ::kernel::d$type -relief sunken \
            -height 4 -width 3 -editable 1 -values $dim_max \
            -modifycmd "::kernel::cmdFormatMatrix $visuNo"
         pack $w.label_$type $w.$type -in $w -side left
      }

      LabelEntry $tbl.data.div -label "$::caption(kernel,diviseur)" -labelanchor w \
         -labelwidth 10 -textvariable ::kernel::sum \
         -width 7 -justify center -editable 0
      checkbutton $tbl.data.norm -text "$::caption(kernel,normalise)" -width 10 \
         -variable ::kernel::norm -indicatoron 1 -offvalue 0 -onvalue 1 -state normal
      pack $tbl.data.div $tbl.data.norm -side left -padx 10 -pady 5
      LabelEntry $tbl.sigma -label "$::caption(kernel,sigma)" -labelanchor w \
         -labelwidth 10 -textvariable ::kernel::sigma -width 7 -justify center -editable 1

      #---  les commandes habituelles
      button $tbl.cmd.ok -text "$::caption(kernel,ok)" -width 7 -borderwidth 2 \
         -relief raised -command "::kernel::cmdOk"
      if {$::conf(ok+appliquer) eq 1} {
         pack $tbl.cmd.ok -side left -padx 3 -pady 3
      }
      button $tbl.cmd.appliquer -text "$::caption(kernel,appliquer)" \
         -width 7 -borderwidth 2 -relief raised \
         -command "::kernel::cmdApply"
      pack $tbl.cmd.appliquer -side left -padx 3 -pady 3
      button $tbl.cmd.no -text "$::caption(kernel,annuler)" -width 7 -borderwidth 2 \
         -relief raised -command "::kernel::cmdClose"
      button $tbl.cmd.hlp -text "$::caption(kernel,hlp)" -width 7 \
         -command "::audace::showHelpItem $::help(dir,images) 1170kernel.htm editeur_noyau"
      pack $tbl.cmd.no -side right -padx 3 -pady 3
      pack $tbl.cmd.hlp -side right -padx 3 -pady 3

      #--   positionne les elements permanents dans le frame
      ::blt::table $tbl $tbl.nom 0,0 $tbl.taille 1,0 $tbl.grid 2,0 \
      $tbl.data 3,0 $tbl.sigma 3,1 $tbl.cmd 4,0
      pack $tbl -in $This
      ::blt::table configure $tbl $tbl.nom $tbl.taille $tbl.grid $tbl.cmd -columnspan 2
      ::blt::table configure $tbl $tbl.nom $tbl.taille $tbl.cmd -fill x -height {40}
      ::blt::table configure $tbl $tbl.grid -pady 10 -padx 10
      ::blt::table configure $tbl $tbl.sigma -padx 10

      #--   rafraichit la liste des filtres de la combobox
      ::kernel::updateListFilters

      #--   initialise les combobox
      $w.row setvalue @1
      $w.col setvalue @1

      trace add variable "::kernel::norm" write "::kernel::cmdNormMatrix"

      ::kernel::cmdFormatMatrix $visuNo

      #--- Focus
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #---------------------------------------------------------------------------
   #  brief rafraichît l'inventaire du répertoire et la combobox ;
   #  details si nécessaire modifie l'extension ;
   #  invoquée par createDialog et cmdCreateMatrix
   #
   proc updateListFilters { {nom ""} } {
      variable private

      set w $private(kernel,tbl).nom.type
      set rep $::conf(rep_userFiltre)

      #--   liste les fichiers dans $home/filter
      set userFilters [lsort -dictionary [glob -nocomplain -type f -tails -dir $rep *]]

      #--   identifie leur extension
      set extension [file extension [lindex $userFilters 0]]

      #--   ote l'extension a tous les noms de filtres
      regsub -all "$extension" $userFilters "" filtres

      #--   modifie l'extension des fichiers
      if {$extension ne "$::conf(extension,defaut)"} {
         foreach name $filtres {
            file rename -force [file join $rep $name$extension] [file join $rep $name$::conf(extension,defaut)]
         }
      }

      #--   complete la liste avec <nouveau>
      if {$nom eq ""} {
         set filtres [linsert $filtres 0 "$::caption(kernel,new)"]
      }

      #--   calcule la largeur de la combobox
      set labelwidth [::tkutil::lgEntryComboBox $filtres]

      #--   reconfigure la combobox
      $w configure -width $labelwidth -values $filtres
      $w setvalue @[lsearch -exact $filtres $nom]
      update
   }

   #---------------------------------------------------------------------------
   #  brief configure la matrice dans la fenêtre
   #  details invoquée par cmdSelectFilter et cmdFormatMatrix
   #
   proc configMatrix { w drow dcol } {
      #--   tue les entry existantes
      set children [winfo children $w]
      if {$children ne ""} {
         foreach child $children {
            destroy $child
         }
      }

      #--   reconstruit la matrice
      for {set row 1} {$row <= $drow} {incr row} {
        frame $w.$row
        for {set col 1} {$col <= $dcol} {incr col} {
            Entry $w.$row.$col -width 6 -relief raised -justify center \
               -textvariable ::kernel:::m_${row}_${col}
            grid $w.$row.$col -column $col -row $row -ipady 4 -in $w.$row
            bind $w.$row.$col <Leave> [list ::kernel::captureValue $row $col]
         }
         grid $w.$row -in $w
      }
   }

   #--------------------------------------------------------------------------
   #  brief affiche une fenêtre d'avertissement
   #  param err variable du caption
   #
   proc avertiUser { err } {
      tk_messageBox -title "$::caption(kernel,attention)" -type ok \
         -message "$::caption(kernel,$err)"
   }

   #--------------proc concernant la visu & le buffer---------------------------

   #---------------------------------------------------------------------------
   #  brief récupère les valeurs de la matrice dans l'image du filtre
   #  details invoquée par cmdSelectFilter
   #  param bufNo numéro du buffer
   #
   proc buffer2Matrix { bufNo } {
      variable private

      set ::kernel::drow [lindex [buf$bufNo getkwd NAXIS2] 1]
      set ::kernel::dcol [lindex [buf$bufNo getkwd NAXIS1] 1]
      set drow $::kernel::drow
      set dcol $::kernel::dcol
      set private(kernel,size) "${drow}x${dcol}"
      set private(kernel,matrix) ""

      #--   pour tenir compte de l'inversion de l'axe des y
      for {set row $drow} {$row >= 1} {incr row "-1"} {
         set liste ""
         for {set col 1} {$col <= $dcol} {incr col} {
            set coords [list $col $row]
            lappend liste "[lindex [buf$bufNo getpix $coords] 1]"
         }
         lappend private(kernel,matrix) $liste
      }
   }

   #---------------------------------------------------------------------------
   #  brief créé l'image du noyau à partir de la matrice
   #  details invoquée par cmdApply
   #  param visuNo numéro de la visu
   #  param nom nom du filtre
   #  return chemin du fichier créé
   #
   proc createFilterInVisu { visuNo nom } {
      variable private

      set bufNo [visu$visuNo buf]
      set matrice $private(kernel,matrix)

      lassign [split $private(kernel,size) "x"] drow dcol
      set sum "[expr {int($::kernel::sum)}]"
      set file [file join $::conf(rep_userFiltre) ${nom}_${sum}_${drow}x${dcol}$::conf(extension,defaut)]

      #--   pour eviter d'ecrire une image de dimension 0
      if {$drow eq "0" || $dcol eq "0"} {return}

      ::confVisu::setZoom $visuNo 8
      buf$bufNo setpixels CLASS_GRAY $dcol $drow FORMAT_FLOAT COMPRESS_NONE 0
      buf$bufNo bitpix float

      for {set row 1} {$row <= $drow} {incr row} {
         for {set col 1} {$col <= $dcol} {incr col} {
            set coords [list $col [expr {$drow+1-$row}]]
            buf$bufNo setpix $coords [gsl_mindex $matrice $row $col]
         }
      }
      buf$bufNo stat
      buf$bufNo save $file

      return $file
   }

   #---------------------------------------------------------------------------
   #  brief efface la visu
   #  details invoquee par cmdClose et cmdFormatMatrix
   #  param visuNo numéro de la visu
   #
   proc clearVisu { visuNo } {
      variable private

      if {[info exists private(kernel,previous_zoom)]} {
         ::confVisu::setZoom $visuNo $private(kernel,previous_zoom)
      }
      ::confVisu::clear $visuNo
   }

   #---------------------------------------------------------------------------
   #  brief rafraichît l'affichage
   #  details invoquee par selectFilter et createFilterInVisu
   #  param visuNo numéro de la visu
   #  param file chemin du fichier
   #
   proc seeFiltr { visuNo file } {
      variable private

      if {[info exists private(kernel,previous_zoom)]} {
         set private(kernel,previous_zoom) $::conf(audace,visu$visuNo,zoom)
      }
      #--   memorise le zoom et passe a 8
      ::confVisu::setZoom $visuNo 8
      ::confVisu::autovisu $visuNo -dovisu $file
   }

}

######################## Fin du namespace kernel ##########################

## namespace ser2fits
#  @brief Scripts pour la conversion d'images .ser en images .fits
#  @author : Raymond ZACHANTKE

namespace eval ::ser2fits {

   #------------------------------------------------------------
   ## @brief pilote la conversion
   #  @param file nom court du fichier source .ser
   #
   proc go2Convert { file } {
      variable private
      variable bd

      #--   raccourcis
      set visuNo $::audace(visuNo)
      set bufNo [visu$visuNo buf]
      set dir $::audace(rep_images)
      set ext $::conf(extension,defaut)
      set dirOut $private(dest)
      set img $private(racine)
      set start $private(start)
      set end $private(end)
      set bitpix $private(bitpix)

      set private(src) [file join $dir $file]
      set kwdFile [file join $dirOut kwdFile.txt]
      set header [file join $dirOut header$ext]

      visu$visuNo clear

      #--   etape 1 : cree une image grise contenant le header des images
      if {$bitpix == 8} {
         set format FORMAT_BYTE
      } elseif {$bitpix eq "+16"} {
         set format FORMAT_USHORT
      }
      buf$bufNo setpixels CLASS_GRAY $private(naxis1) $private(naxis2) $format COMPRESS_NONE pixeldata 0 -keepkeywords 0
      buf$bufNo save $header
      buf$bufNo clear

      #--   etape 2 : si le fichier d'info .txt existe
      #--   extrait les mots cles et les dates du fichier .txt vers l'array bd
      set txtExist [readSerInfoFile [file rootname $private(src)]]

      #--   a partir de l'array bd cree le fichier des mots cles a incorporer dans le header
      buildKwdFile $kwdFile

      #--   integre les mots cles communs aux images et le contraint au bon bitpix
      ttscript2 "IMA/SERIES \"$dirOut\" \"header\" . . $ext \"$dirOut\" \"header\" . $ext HEADERFITS \"file=$kwdFile\" bitpix=$bitpix"

      #--   etape 3 : extrait les images FITS
      for {set i $start} {$i <= $end} {incr i} {

        #--   definit le nom de l'image
         set fileName [file join $dirOut ${img}${i}$ext]

         #--   duplique l'image grise
         file copy -force $header $fileName

         #--   calcule l'adresse de depart des donnees de l'image dans le fichier .ser
         set startAdress [expr { 178 + ($i-1)*$private(imageSize) }]

         #--   extrait l'image du fichier source
         extractImg $fileName $startAdress $bitpix
      }

      #--   etape 4 : si le fichier d'info .txt existe
      #     incorpore la date de prise de vue dans chaque image
      if {$txtExist == 1 || [lindex [array get bd $start] 1] ne ""} {
         for {set i $start} {$i <= $end} {incr i} {
            #--   produit un petit fichier avec l'heure
            lassign [lindex [array get bd $i] 1] kwd value type comment unit
            set fileID [open $kwdFile w]
            puts $fileID $kwd\n$value\n$type\n$comment\n$unit
            chan close $fileID
            #--   integre le mot cle
            ttscript2 "IMA/SERIES \"$dirOut\" \"${img}${i}\" . . $ext \"$dirOut\" \"${img}${i}\" . $ext HEADERFITS \"file=$kwdFile\" "
            file delete $kwdFile
         }
      }

      #--   etape 5 : flip les images pour qu'elles soient identiques au film
      ttscript2 "IMA/SERIES \"$dirOut\" \"$img\" $start $end $ext \"$dirOut\" \"$img\" $start $ext INVERT FLIP"

      #--   charge la derniere image
      ::confVisu::autovisu $visuNo -no $fileName

      #--   detruit les fichiers du header
      file delete $header $kwdFile

      array unset bd
   }

   #------------------------------------------------------------
   ## @brief ajoute les donn褥s de l'image au header
   #  @param fitsFile chemin complet du fichier image .FITS
   #  @param startAdress de l'adresse de départ
   #  @param bitpix valeur du bitpix
   #
   proc extractImg { fitsFile startAdress bitpix } {
      variable private

      set size $private(imageSize)

      #--   longueur du header FITS
      set headerLength 2880

      set srcID [open $private(src) r]
      fconfigure $srcID -translation binary
      set destID [open $fitsFile r+]
      fconfigure $destID -translation binary

      seek $srcID $startAdress
      seek $destID $headerLength

      if {$bitpix == 8} {
         fcopy $srcID $destID -size $size
      }  elseif {$bitpix eq "+16"} {
         #--   conversion en bigEndian
         binary scan [read $srcID $size] s* out
         puts -nonewline $destID [binary format S* $out]
      }

      chan close $srcID
      chan close $destID
   }

   #------------------------------------------------------------
   ## @brief extrait les valeurs des mots clés du fichier .TXT
   #  @param infoFile chemin complet du fichier .txt d'info accompagnant le fichier .ser
   #  @return  0 (no file) ou 1 ok
   #
   proc readSerInfoFile { infoFile } {
      variable private
      variable bd

      set logFile [file join $infoFile.txt]
      if {![file exists $logFile]} {
         return 0
      }

      set acqSoft [lindex [lindex [array get bd SWCREATE] 1] 1]
      #--   liste les rubriques a rechercher
      if {$acqSoft eq "GenikaAstro"} {
         set listParam [list "Active filter" "Object" "Diameter" "Native F/D" Amplifier\
            "Pixel size" "Exposure in µS" "BinX" "BinY"]
      } elseif {$acqSoft eq "GENICAP-RECORD"} {
         set listParam [list "Diametre" "Telescope" "Début" "Fin" "F/D" "Modèle" \
            "Taille" "Planete" "Exposition" "Filtre" "Binning" "Image"]
      } else {
         #--   ignore tout des fchiers LUCAM-RECORDER et PlxCapture
         return 0
      }

      set fd [open $logFile r]
      set contenu [split [read $fd] \n]
      close $fd

      foreach param $listParam {

         set k [lsearch -regexp $contenu $param]
         if {$k == -1} {continue}
         lassign [split [lindex $contenu $k] ":"] -> value
         set value [string trim $value]
         if {$value eq ""} {continue}

         #--   remplace la virgule par un point
         regsub "," $value "." value

         if {$acqSoft eq "GenikaAstro"} {

            switch -exact $param {
               Diameter    {  set aptdia [expr { $value/1000. }]
                              array set bd [list  APTDIA [format [formatKeyword  APTDIA] $aptdia]]
                           }
               "Native F/D" { set fond $value;}
               Amplifier   {  regsub "x" $value "" amplifier}
               Object      {  array set bd [list OBJECT [format [formatKeyword OBJECT] Planete]]
                              array set bd [list OBJNAME [format [formatKeyword OBJNAME] $value]]
                           }
               Filter      {  array set bd [list FILTER [format [formatKeyword FILTER] $value]]}
               BinX        {  set bin1 $value
                              array set bd [list BIN1 [format [formatKeyword BIN1] $value]]}
               BinY        {  set bin2 $value
                              array set bd [list BIN2 [format [formatKeyword BIN2] $value]]
                           }
               "Pixel size" {  set pixsize1 $value ; set pixsize2 $value
                              array set bd [list  PIXSIZE1 [format [formatKeyword  PIXSIZE1] $value]]
                              array set bd [list  PIXSIZE2 [format [formatKeyword  PIXSIZE2] $value]]
                           }
               "Exposure in µS" {set exposure [expr { $value/1000000. }]
                              array set bd [list EXPOSURE [format [formatKeyword EXPOSURE] $exposure]]
                           }
            }

         } elseif {$acqSoft eq "GENICAP-RECORD"} {


            if {[regexp -all {(Image)} $title] ==0} {

               #--   extrait les mots cles
               switch -exact $param {
                  Telescope   {  array set bd [list TELESCOP [format [formatKeyword TELESCOP] $value]]}
                  Diametre    {  set aptdia [expr { $value/1000. }]
                                 array set bd [list APTDIA [format [formatKeyword APTDIA] $aptdia]]
                              }
                  Début       {  lassign [formatDateObs4GENICAP_RECORD $value] -> date_start
                                 set data [list DATE-BEG [format [formatKeyword "DATE-BEG"] $date_start]]
                              }
                  Fin         {  lassign [formatDateObs4GENICAP_RECORD $value] -> date_end
                                 set data [list DATE-END [format [formatKeyword "DATE-END"] $date_end]]
                              }
                  F/D         {  set fond $value}
                  Modèle      {  array set bd [list DETNAM [format [formatKeyword DETNAM] $value]]}
                  Taille      {  set xpixsz $value ; set ypixsz $value
                                 array set bd [list XPIXSZ [format [formatKeyword XPIXSZ] $xpixsz]]
                                 array set bd [list YPIXSZ [format [formatKeyword YPIXSZ] $ypixsz]]
                              }
                  Planete     {  array set bd [list OBJECT [format [formatKeyword OBJECT] Planete]]
                                 array set bd [list OBJNAME [format [formatKeyword OBJNAME] $objname]]
                              }
                  Exposition  {  set value [expr { $value/1000. }]
                                 array set bd [list EXPOSURE [format [formatKeyword EXPOSURE] $value]]}
                  Filtre      {  if {$value ne "pas de filtre"} {set value C}
                                 array set bd [list FILTER [format [formatKeyword FILTER] $value]]
                              }
                  Binning     {  set bin1 $value ; set bin2 $value
                                 array set bd [list BIN1 [format [formatKeyword BIN1] $bin1]]
                                 set pixsize1 [expr { $bin1 * $xpixsz }]
                                 array set bd [list PIXSIZE1 [format [formatKeyword PIXSIZE1] $pixsize1]]
                                 array set bd [list BIN2 [format [formatKeyword BIN2] $bin2]]
                                 set pixsize2 [expr { $bin2 * $ypixsz }]
                                 array set bd [list PIXSIZE2 [format [formatKeyword PIXSIZE2] $pixsize2]]
                              }
               }

            } else {
               #--   identifie le N° de l'image
               regsub -all {[a-zA-Z:\s]} [string range $title 0 $index] "" imgNo
               lassign [formatDateObs4GENICAP_RECORD $value] datemjd
               array set bd [list $imgNo [format [formatKeyword "MJD-OBS"] $datemjd]]
            }
         }
      }

      #--   complete la bd
      if {[info exist aptdia] == 1 && [info exist fond] == 1} {
         set foclen [expr { $fond*$aptdia }]
         if {[info exist amplifier]} {
            set foclen [expr { $foclen*$amplifier }]
         }
         array set bd [list FOCLEN [format [formatKeyword FOCLEN] $foclen]]
      }

      if {$private(frameCount) > 1 } {
         if {$acqSoft in [list GENICAP_RECORD GenikaAstro]} {
            for {set i 1} {$i <= $private(frameCount)} {incr i} {
               #--   pm : la date est la fin d'exposition
               set datemjd [lindex [lindex [array get bd $i] 1] 1]
               #--   retire le temps d'exposition
               set datemjd [expr { $datemjd-$exposure/86400 }]
               #--   met a jour la bd
               array set bd [list $i [format [formatKeyword "MJD-OBS"] $datemjd]]
            }
         }

         set mediane [getTimeElapse $private(frameCount)]
         #--   donne le temps entre images
         array set bd [list TELAPSE [format [formatKeyword "TELAPSE"] $mediane]]
      }

      lassign [getCdelt $private(naxis1) $private(naxis2) $pixsize1 $pixsize2 $foclen] cdeltx cdelty
      array set bd [list CDELT1 [format [formatKeyword CDELT1] $cdeltx]]
      array set bd [list CDELT2 [format [formatKeyword CDELT2] $cdelty]]

      #foreach kwd [lsort -ascii [array names bd]] {
      #   ::console::affiche_resultat "[array get bd $kwd]\n"
      #}

      return 1
   }

   #------------------------------------------------------------
   ## @brief prépare le fichier kwdFile des mots clés à incorporer avec libtt
   #  @param kwdFile chemin complet du fichier .txt à integrer
   #
   proc buildKwdFile { kwdFile } {
      variable bd

      package require struct::set

      #--   evalue l'intersection entre la liste des noms contenus dans l'array
      #  et la liste theorique pour filtrer les seuls mots cles existants
      set kwdList [list APTDIA BIN1 BIN2 BZERO CDELT1 CDELT2 "DATE-BEG" "DATE-END" \
         DETNAM EXPOSURE FILTER FOCLEN INSTRUME OBJECT OBJNAME OBSERVER \
         PIXSIZE1 PIXSIZE2 SWCREATE SWMODIFY TELAPSE TELESCOP XPIXSZ YPIXSZ]
      set bdList [array names bd]

      #--   intersection entre les deux listes
      set shortList [::struct::set intersect $kwdList $bdList]

      set fileID [open $kwdFile w]
      foreach kwd $shortList {
         lassign [lindex [array get bd $kwd] 1] kwd value type comment unit
         puts $fileID $kwd\n$value\n$type\n$comment\n$unit
      }
      chan close $fileID
   }

   #------------------------------------------------------------
   ## @brief explore le header de l'image
   #  @details commande associée à chaque rubrique du menuButton, d'après SER_Doc_V2.pdf
   #  @param w chemin de la combobox
   #
   proc exploreHeader { w } {
      variable private
      variable bd

      #--   rafraichit le nom generique
      set private(racine) [file rootname $private(choice)]

      array unset bd
      set file [file join $::audace(rep_images) [$w get]]

      set fileID [open $file r]
      fconfigure $fileID -blocking 0 -buffering none -buffersize 1 \
         -encoding utf-8 -eofchar {} -translation auto

     #--   va a la fin du fichier
      seek $fileID 0 end

      #--   recupere l'adresse
      set endOfFile [tell $fileID]

      seek $fileID 0 start

      #--   decode les champs du header
      #     14 caracteres pour record (logiciel de capture) ; #--   GENICAP-RECORD - GenikaAstro - LUCAM-RECORDER - PlxCapture
      #      1 entier de 32 bits pour LuID, non exploite
      #      1 entier de 32 bits pour ColorID (=0 pour monochrome), non exploite
      #      1 entier de 32 bits pour LittleEndian (0 -->donnees BigEndian)
      #      1 entier de 32 bits pour naxis1
      #      1 entier de 32 bits pour naxis2
      #      1 entier de 32 bits pour PixelDepth (8 ou 12 --> codage sur 1 ou 2 octets)
      #      1 entier de 32 bits pour FrameCount
      #     40 caracteres pour Observeur
      #     40 caracteres pour Instrument
      #     40 caracteres pour Telescope
      #      8 bytes pour DateTime
      #      8 bytes pour DateTimeUTC
      binary scan [read $fileID 162] A14iiiiiiiA40A40A40 record LuID ColorID LittleEndian \
         naxis1 naxis2 PixelDepth FrameCount Observeur Instrument Telescope

      #--   traite les chaines de caracteres
      set entities [list à a â a ç c é e è e ê e ë e î i ï i ô o ö o û u ü u ü u ' "" Observeur "" Instrument "" Telescope ""]
      foreach kwd [list record Observeur Instrument Telescope ] {
         #--   modifie les caracteres indesirables
         set $kwd [string map -nocase $entities [set $kwd]]
         #--   ote les espaces superflus
         set $kwd [string trim [set $kwd]]
         if {[llength [set $kwd]] > 1} {
            set $kwd [list [set $kwd]]
         }
         #--   rem : pour les mots sans interet la definition est une liste vide
      }

      #--   si la profondeur est de 8, il faut 1 byte/pixel sinon 2
      if {$PixelDepth == 8} {
         set BytePerPixel 1
         set bitpix 8
      } elseif {$PixelDepth == 12 || $PixelDepth == 16} {
         set BytePerPixel 2
         set bitpix "+16"
      }

      #--   calcule le nb de bytes/image
      set ImageSize [expr { $naxis1*$naxis2*$BytePerPixel }]

      #--   configure le channel
      fconfigure $fileID -encoding binary

      #--   decode l'horodatage (8 bytes) de debut de prise de vues en temps local
      binary scan [read $fileID 8] w localCount100ns
      #--   decode l'horodatage (8 bytes) de debut de prise de vues en temps tu
      binary scan [read $fileID 8] w tuCount100ns
      lassign [formatDateTime $tuCount100ns] -> startDateTime ; #-- temps TU
      array set bd [list DATE-BEG [format [formatKeyword "DATE-BEG"] $startDateTime]]
      #--   calcule la difference
      set deltaT [expr { $localCount100ns-$tuCount100ns }]

      #--   calcule l'offset pour atteindre la fin des images
      set endOfImages [expr { 178+$FrameCount*$ImageSize } ]

      #--   va a la fin des images pour decoder l'horodatage de chacune
      seek $fileID $endOfImages start
      if {$endOfFile != $endOfImages} {

         #--   attention : l'horodatage est la fin de prise de vue en temps local
         for {set imgNo 1} {$imgNo <= $FrameCount} {incr imgNo} {
            seek $fileID [expr { $endOfImages+($imgNo-1)*8 }] start
            #--   lit 8 bytes en LittleEndian
            binary scan [read $fileID 8] w count100ns
            #--   passe en temps TU
            set count100ns [expr { $count100ns-$deltaT }]
            lassign [formatDateTime $count100ns] datemjd datett
            array set bd [list $imgNo [format [formatKeyword "MJD-OBS"] $datemjd]]
            #--   memorise l'horodatage du debut
            if {$imgNo == $FrameCount} {
               array set bd [list DATE-END [format [formatKeyword "DATE-END"] $datett]]
            }
         }
         #--   si plus d'une image
         if {$FrameCount > 1} {
            set mediane [getTimeElapse $FrameCount]
         }
      }

      chan close $fileID

      #--   preparation de l'array contenant les mots cles
      if {[info exists mediane]} {
         #--   donne le temps entre images
         array set bd [list TELAPSE [format [formatKeyword "TELAPSE"] $mediane]]
      }
      if {$Instrument ne ""} {
         array set bd [list INSTRUME [format [formatKeyword INSTRUME] "$Instrument"]]
      }
      if {$Observeur ne ""} {
         array set bd [list OBSERVER [format [formatKeyword OBSERVER] "$Observeur"]]
      }
      if {$Telescope ne ""} {
         array set bd [list TELESCOP [format [formatKeyword TELESCOP] $Telescope]]
      }
      if {$record ne ""} {
         array set bd [list SWCREATE [format [formatKeyword SWCREATE] "$record"]]
      }
      array set bd [list SWMODIFY [format [formatKeyword SWMODIFY] "AudeLA"]]

      #--   met a jour les variables dans la fenetre
      #set private(racine) [file rootname $private(choice)]
      #set private(start) 1
      #set private(end) $FrameCount
      set private(frameCount) $FrameCount
      set private(imageSize) $ImageSize
      set private(naxis1) $naxis1
      set private(naxis2) $naxis2
      set private(bitpix) $bitpix
   }

   #------------------------------------------------------------
   ## @brief formate l'horodatage
   #  @param count100ns 8 bytes (64 bits) lus dans le fichier ser ;
   #l'unité vaut 100 ns
   #  @return dateMJD et date ISO 8601
   #
   proc formatDateTime { count100ns } {
      #--   filtre les 62 bits significatifs
      set count100ns [expr { $count100ns & 0x3fffffffffffffff }]

      #--   100 nanosecondes en duree julienne !
      set k [expr { 100/(86400*1E9) }]

      #--   si pas d'indication dans le header
      #--   horodatage == 0001:01::03T00:00::00.000 == date de reference de l'horodatage des fichiers ser
      set datett "0001-01-03T00:00:00.000" ; # temps 0 par defaut
      set refJD [mc_date2jd $datett]

      #--   calcule le temps MJD et la date ISO8601
      set datemjd [expr { $refJD+$count100ns*$k-2400000.5 }]
      if {$datemjd != "-678575.0"} {
         set datett [mc_date2iso8601 $datemjd]
      }

      return [list $datemjd $datett]
   }

   #------------------------------------------------------------
   ## @brief formate l'horodatage
   #  @param date date du fichier .ser.txt de GENICAP_RECORD
   #  @return dateMJD et date ISO 8601
   #
   proc formatDateObs4GENICAP_RECORD { date } {
      lassign $date cal month day time year
      set entities [list Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 \
         Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12]

      #--   remplace le nom du mois par son numero
      set month [string map -nocase $entities $month]

      lassign [split $time ":"] h m s ms
      if {$ms eq ""} {
         set ms "000"
      }
      append s "." $ms

      set datejd [mc_date2jd [list $year $month $day $h $m $s]]

      #--   calcule le temps MJD et la date ISO8601
      set datemjd [expr {$datejd-2400000.5}]
      set datett [mc_date2iso8601 $datemjd]

      return [list $datemjd $datett]
   }

   #------------------------------------------------------------
   #  brief interface graphique
   #
   proc buildGui { args } {
      variable This $::audace(base).serfile
      variable private

      set dir $::audace(rep_images)

      set listeSer {}
      if { $::tcl_platform(platform) == "windows" } {
         #--- la recherche de l'extension est insensible aux minuscules/majuscules ... sous windows uniquement
         set listeSer [glob -nocomplain -type f -tails -directory $dir *.ser]
      } else {
         #--- la recherche de l'extension est _sensible_ aux minuscules/majuscules dans tous les autres cas
         foreach extension { SER ser Ser } {
            set listeSer [ concat $listeSer [ glob -nocomplain -type f -directory $dir *.$extension ] ]
         }
      }

      #--   arrete si la liste est vide
      if {$listeSer eq ""} {
         tk_messageBox -title "$::caption(ser2fits,attention)" -icon error -type ok \
            -message "$::caption(ser2fits,no_ser)"
         return
      }

      if {[winfo exists $This]} {
         destroy $This
      }

      initConf

      #--- cree la fenetre
      toplevel $This
      wm resizable $This 0 0
      wm title $This "$::caption(audace,menu,ser2fits)"
      wm geometry $This $::conf(ser2fits,position)
      wm protocol $This WM_DELETE_WINDOW "::ser2fits::cmdClose"

      frame $This.fr1 -relief raised -borderwidth 1
      pack $This.fr1 -side top -ipady 5 -fill both -expand yes

      label $This.fr1.lab_convert -text "$::caption(audace,menu,convertir)"
      grid $This.fr1.lab_convert -row 0 -column 0 -sticky w

      #--   cree la combobox des fichiers ser
      set labelwidth [::tkutil::lgEntryComboBox $listeSer]
      ComboBox $This.fr1.choice -textvariable ::ser2fits::private(choice) \
         -relief sunken -height [llength  $listeSer] -width $labelwidth  \
         -values $listeSer -editable 0 \
         -modifycmd "::ser2fits::exploreHeader $This.fr1.choice"
      grid $This.fr1.choice -row 0 -column 1 -columnspan 3 -sticky e

      label $This.fr1.lab_start -text "$::caption(ser2fits,start)"
      grid $This.fr1.lab_start -row 1 -column 0 -sticky w

      entry $This.fr1.start -textvariable ::ser2fits::private(start) \
         -justify right -width 6
      grid $This.fr1.start -row 1 -column 1 -sticky w

      label $This.fr1.lab_end -text "$::caption(ser2fits,end)"
      grid $This.fr1.lab_end -row 1 -column 2 -sticky ew

      entry $This.fr1.end -textvariable ::ser2fits::private(end) \
           -justify right -width 6
      grid $This.fr1.end -row 1 -column 3 -sticky e

      label $This.fr1.lab_dest -text "$::caption(ser2fits,dest)"
      grid $This.fr1.lab_dest -row 2 -column 0 -sticky w

      entry $This.fr1.dest -textvariable ::ser2fits::private(dest) \
         -justify right -width $labelwidth -state disabled
      grid $This.fr1.dest -row 2 -column 1 -columnspan 3 -sticky ew
      $This.fr1.dest xview end

      #--   cree le bouton "..."
      button $This.fr1.search -text "$::caption(ser2fits,search)" \
         -width 2 -command {::ser2fits::getDirName}
      grid $This.fr1.search -row 2 -column 4 -padx 5 -pady 10 -sticky news

      label $This.fr1.lab_racine -text "$::caption(ser2fits,racine)"
      grid $This.fr1.lab_racine -row 3 -column 0 -sticky w

      entry $This.fr1.racine -textvariable ::ser2fits::private(racine) \
         -justify right -width $labelwidth
      grid $This.fr1.racine -row 3 -column 1 -columnspan 3 -sticky e

      grid columnconfigure $This.fr1 0 -weight 20 -pad 5
      grid rowconfigure $This.fr1 [list 0 1 2 3 4] -pad 10

      #--   cree le widget d'info
      label $This.labURL -text "$::caption(ser2fits,en_cours)" -justify center \
         -borderwidth 1 -relief raised -fg $::color(blue)

      frame $This.cmd -relief raised -borderwidth 1

         set cmdList [list apply left close right hlp right]
         if { $::conf(ok+appliquer)=="1" } {
            set cmdList [linsert $cmdList 0 ok left]
         }
         foreach {but side} $cmdList  {
            pack [button $This.cmd.$but -text "$::caption(ser2fits,$but)" -width 10] \
            -side $side -padx 10 -pady 3 -ipady 3
         }
         #-- specialisation des boutons
         if {[winfo exists $This.cmd.ok]} {
            $This.cmd.ok configure -command "::ser2fits::cmdOk"
         }
         $This.cmd.apply configure -command "::ser2fits::cmdApply"
         $This.cmd.hlp configure   -command "::audace::showHelpItem $::help(dir,images) 1180ser2fits.htm"
         $This.cmd.close configure -command "::ser2fits::cmdClose"

      pack $This.cmd -side bottom -fill both

      #--   bindings

      bind $This.fr1.start <Leave> {::ser2fits::testIndex start}
      bind $This.fr1.end <Leave> {::ser2fits::testIndex end}
      bind $This.fr1.racine <Leave> {::ser2fits::testRacine}

      #--   initialisation des variables
      set private(choice) [lindex $listeSer 0]
      set private(dest) $dir
      set private(racine) [file rootname $private(choice)]
      set private(start) 1
      set private(prev,start) 1
      ::ser2fits::exploreHeader $This.fr1.choice
      set private(end) $private(frameCount)
      set private(prev,end) $private(end)

      if {[trace info variable ::audace(rep_images)] eq ""} {
         trace add variable ::audace(rep_images) write "::ser2fits::buildGui"
      }

      #--- La fenetre est active
      focus $This

      #--- mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Convertir SER ---> FITS"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(ser2fits,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if {![info exists ::conf(ser2fits,position)]} { set ::conf(ser2fits,position) "+800+500" }

   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable private

      configButtons disabled
      go2Convert $private(choice)
      configButtons normal
   }

   #------------------------------------------------------------
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable This

      if {[trace info variable ::audace(rep_images)] ne ""} {
         trace remove variable ::audace(rep_images) write "::ser2fits::buildGui"
      }

      #--   equivalent de widgetToConf
      regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" ::conf(ser2fits,position)

      destroy $This
   }

   #------------------------------------------------------------
   ##  @brief commande du bouton "..." de saisie du nom générique de sortie
   #capture le nom d'un répertoire
   #
   proc getDirName { } {
      variable private

      set initialDir $::audace(rep_images)

      set dirname [tk_chooseDirectory -title "$::caption(ser2fits,dest)" \
         -initialdir $initialDir]

      if {$dirname eq "" || $dirname eq "$initialDir"} {
         set dirname $initialDir
      }

      if {[string index $dirname end] ne "/"} {
         append dirname "/"
      }

      set private(dest) $dirname
   }

   #---------------------------------------------------------------------------
   #  brief inhibe/désinhibe tous les boutons
   #  param state normal disabled
   #
   proc configButtons { state } {
      variable This

      foreach w [list fr1.search cmd.ok cmd.apply cmd.hlp cmd.close] {
         $This.$w configure -state $state
      }
      if {$state eq "normal"} {
         pack forget $This.labURL
      } else {
         pack $This.labURL -ipady 5 -fill both
      }

      update
   }

   #---------------------------------------------------------------------------
   #  brief valide les saisies numériques
   #  param child nom de la variable modifiée
   #
   proc testIndex { child } {
      variable private

      set newValue $private($child)
      set ok 0

      if {([TestReel $newValue] == 1) && ($private(start) <= $private(end)) && \
         ($newValue > 0) && ($newValue <= $private(frameCount))} {

         #--   remplace l'ancienne valeur par la nouvelle
         set private(prev,$child) $newValue
         set ok 1
      }

      #--   si echec, message et retablit l'ancienne valeur
      if {$ok == 0} {

         #--   message si echec
         tk_messageBox -title "$::caption(ser2fits,attention)" -icon error -type ok \
            -message [format $::caption(ser2fits,invalid) $newValue "$::caption(ser2fits,$child)"]

         set private($child) $private(prev,$child)
      }
   }

   #---------------------------------------------------------------------------
   #  brief valide le nom générique
   #
   proc testRacine { } {
      variable private

      set racine $private(racine)

      #--   nom generique correct ?
      regexp -all {[\w_-]+} $racine match

      #--   si echec, message et retablit la valeur par defaut
      if {![info exists match] || $match ne "$racine"} {
         tk_messageBox -title "$::caption(ser2fits,attention)" -icon error -type ok \
            -message [format $::caption(ser2fits,invalid) $racine "$::caption(ser2fits,racine)"]
         set private(racine) [file rootname $private(choice)]
      }
   }

   #--------------------------------------------------------------------------
   #  brief dictionnaire des mos clés
   #  param kwd (optionnel)
   #
   proc formatKeyword { {kwd " "} } {
      dict set dicokwd APTDIA    {APTDIA %s float Diameter m}
      dict set dicokwd BIN1      {BIN1 %s int {} {}}
      dict set dicokwd BIN2      {BIN2 %s int {} {}}
      dict set dicokwd BZERO     {BZERO %s int {offset data range to that of unsigned short} {}}
      dict set dicokwd CDELT1    {CDELT1 %s double {Scale along Naxis1} deg/pixel}
      dict set dicokwd CDELT2    {CDELT2 %s double {Scale along Naxis2} deg/pixel}
      dict set dicokwd DATE-BEG  {DATE-BEG %s string {Start of video.FITS standard} {ISO 8601}}
      dict set dicokwd DATE-END  {DATE-END %s string {End of video.FITS standard} {ISO 8601}}
      dict set dicokwd DETNAM    {DETNAM %s string {Camera used} {}}
      dict set dicokwd EQUINOX   {EQUINOX %s string {System of equatorial coordinates} {}}
      dict set dicokwd EXPOSURE  {EXPOSURE %s float {Total time of exposure} s}
      dict set dicokwd FILTER    {FILTER %s string {C U B V R I J H K} {}}
      dict set dicokwd FOCLEN    {FOCLEN %s float {Resulting Focal length} m}
      dict set dicokwd IMAGETYP  {IMAGETYP %s string {Image Type} {}}
      dict set dicokwd INSTRUME  {INSTRUME %s string {Camera used} {}}
      dict set dicokwd MJD-OBS   {MJD-OBS %s double {Start of exposure} d}
      dict set dicokwd OBJECT    {OBJECT %s string {Object observed} {}}
      dict set dicokwd OBJNAME   {OBJNAME %s string {Object Name} {}}
      dict set dicokwd OBSERVER  {OBSERVER %s string {Observers Names} {}}
      dict set dicokwd PIXSIZE1  {PIXSIZE1 %s float {Pixel Width (with binning)} mum}
      dict set dicokwd PIXSIZE2  {PIXSIZE2 %s float {Pixel Height (with binning)} mum}
      dict set dicokwd SWCREATE  {SWCREATE %s string {Acquisition Software} {}}
      dict set dicokwd SWMODIFY  {SWMODIFY %s string {Processing Software} {}}
      dict set dicokwd TELAPSE   {TELAPSE %s float {Elapsed time of observation} {s}}
      dict set dicokwd TELESCOP  {TELESCOP %s string {Telescope (name barlow reducer)} {}}
      dict set dicokwd XPIXSZ    {XPIXSZ %s float {Pixel Width (without binning)} mum}
      dict set dicokwd YPIXSZ    {YPIXSZ %s float {Pixel Height (without binning)} mum}

      set kwd_list [dict keys $dicokwd]
      if {$kwd eq " "} {return $kwd_list}
      if {$kwd ni "$kwd_list"} {return "keyword \"$kwd\" {not in dictionnary}"}

      return [dict get $dicokwd $kwd]
   }

   #---------------------------------------------------------------------------
   # brief calcule les cdelt en arcsec/pixel
   #  param naxis1
   #  param naxis2
   #  param pixsize1 dimension des pixels en x (avec bining) en mum
   #  param pixsize2 dimension des pixels en y (avec bining) en mum
   #  param foclen longueur focale en m
   #  return liste de cdelt en x et en y
   #
   proc getCdelt { naxis1 naxis2 pixsize1 pixsize2 foclen } {
      #--   test OR
      if {"-" in [list $naxis1 $naxis2 $pixsize1 $pixsize2 $foclen]} {
         return [lrepeat 2 -]
      }

      set factor [expr { 360. / (4*atan(1.)) }]

      set tgx [expr { $pixsize1 * 1e-6 / $foclen / 2. }]
      set tgy [expr { $pixsize2 * 1e-6 / $foclen / 2. }]

      set cdeltx [expr { -atan ($tgx) * $factor * 3600. }]
      set cdelty [expr { atan ($tgy) * $factor * 3600. }]

      return [list $cdeltx $cdelty]
   }

   #---------------------------------------------------------------------------
   ## @brief retourne le temps médian entre les images
   #  @param frameCount nombre total d'images dans le fichier
   #  @return temps médian
   #
   proc getTimeElapse { frameCount } {
      variable bd

      blt::vector create Vmed result -watchunset 1
      Vmed offset 1
      result offset 1

      #--   remplit le vecteur avec les valeurs
      for { set i 1} {$i <= $frameCount} {incr i} {
         Vmed append [lindex [lindex [array get bd $i] 1] 1]
      }

      #--   recopie du 1er au dernier
      result set [Vmed range 2 end]

      #--   efface le dernier
      Vmed delete end

      #--   fait la difference des mjd et transforme en secondes
      result expr {(result-Vmed)*86400}

      #--   obtient la mediane
      result expr {median(result)}
      set mediane $result(1)

      blt::vector destroy Vmed result

      return $mediane
   }

}

######################## Fin du namespace ser2fits ##########################

## namespace trichro
#  @brief Scripts pour transformer 3 plans couleurs en image RGB
#  @author Raymond ZACHANTKE

namespace eval ::trichro {

   #------------------------------------------------------------
   ## @brief pilote la conversion
   #  @param files liste de trois fichiers
   #  @param nameOut nom complet de l'image trichro (avec extension)
   #  @return code erreur { 0 | 1}
   #
   proc go2Trichro { files nameOut } {

      set visuNo $::audace(visuNo)

      #--   raccourcis
      set buf buf[visu$visuNo buf]
      set ext [file extension $nameOut]
      set gene [file rootname $nameOut]
      set to_destroy ""

      set err [ catch {
         #--- charge, modifie les en-tetes et sauve les trois images
         foreach img $files k { 1 2 3 } {

            #--- charge chaque image (dans l'ordre : R, G et B)
            $buf load $img

            #--- au cas ou les seuils n'existeraient pas
            $buf stat

            #--- construit les en-tetes des seuils couleurs
            set color [string map [list 1 R 2 G 3 B] $k]
            foreach kwd { "MIPS-HI" "MIPS-LO" } level [ list "Hight" "Low" ] {
               set val [ lindex [ $buf getkwd ${kwd} ] 1 ]
               switch $color {
                  R  {  set ${kwd}$color [ list ${kwd}$color $val float "Red $level Cut" "adu" ] }
                  G  {  set ${kwd}$color [ list ${kwd}$color $val float "Green $level Cut" "adu" ] }
                  B  {  set ${kwd}$color [ list ${kwd}$color $val float "Blue $level Cut" "adu" ] }
               }
            }

            #--
            set filename ${gene}$k$ext

            #--- sauve les images avec un index numerique
            $buf save $filename

            #--- memorise les fichiers a detruire
            lappend to_destroy $filename
         }

         #--- conversion en une image
         fitsconvert3d ${gene} 3 $ext ${gene}
         $buf load $nameOut

         #--- inscrit les seuils couleurs dans l'en-tete
         foreach kwd [ list "MIPS-LOR" "MIPS-HIR" "MIPS-LOG" "MIPS-HIG" "MIPS-LOB" "MIPS-HIB" ] {
            $buf setkwd [ set $kwd ]
         }
         if {[$buf getkwd RGBFILTR] ne ""} {
            $buf delkwd RGBFILTR
         }

         #--- sauve l'image couleur
         $buf save $nameOut

         ::confVisu::autovisu $visuNo

         #--- supprime les images intermediaires
         foreach file $to_destroy {
            if {[file exists $file]} { file delete $file }
         }
      } msg ]

      if { $err == "1" } {
         ::trichro::errorMsg [format $::caption(trichro,echec) $msg]
      }
      return $err
   }

   #------------------------------------------------------------
   ## @brief filtre les images qui peuvent être des plans couleurs
   #  @return nombre de fichiers
   #
   proc getAllFiles { } {
      variable private
      variable bd

      set dir $::audace(rep_images)

      #--   Liste les fichiers du repertoire images
      set listeOfFiles [ glob -nocomplain -type f -type f -tails -dir $dir * ]

      #--   arrete si la liste est vide
      if {$listeOfFiles eq ""} {return 0}

      set nbRGB   "0"
      set nbCFA   "0"
      set nbAutre "0"

      #--   Filtre exclusivement les images en eliminant les fichiers .txt, .ser
      foreach fichier $listeOfFiles {
         set index [lsearch $listeOfFiles $fichier]
         set err [ catch { set kwdsList [ fitsheader [file join $dir $fichier] ] } ]

         if {$err == 0} {

            #--   Cree un array avec les mots cles
            foreach kwd $kwdsList {
               array set kwds [list [lindex $kwd 0] [lindex $kwd 1]]
            }

            if {[lindex [array get kwds NAXIS3] 1] == 3} {
               #--   Image couleur : supprime l'image de la liste
               set listeOfFiles [lreplace $listeOfFiles $index $index]
               incr nbRGB
            } else {
               #--   Image avec naxis == 2
               set rgbfiltr  [lindex [array get kwds RGBFILTR] 1]
               set rawfilte  [lindex [array get kwds RAWFILTE] 1]
               set rawfilter [lindex [array get kwds RAWFILTER] 1]
               #--   Plan couleur ou N&B (pas couleur ni CFA)
               if {$rgbfiltr eq "" && $rawfilte eq "" && $rawfilter eq "" || $rgbfiltr ne "" } {
                  set naxis1    [lindex [array get kwds NAXIS1] 1]
                  set naxis2    [lindex [array get kwds NAXIS2] 1]
                  #--   Plan couleur ou N&B (pas couleur ni CFA)
                  array set bd [list $fichier [list $naxis1 $naxis2]]
               } else {
                  #--   Image CFA : supprime l'image de la liste
                  set listeOfFiles [lreplace $listeOfFiles $index $index]
                  incr nbCFA
                }
            }

            array unset kwds
         } else {
            #--   Supprime le fichier (.txt, .ser, .CR2, erreur dans le FitsHeader, etc.) de la liste
            set listeOfFiles [lreplace $listeOfFiles $index $index]
            incr nbAutre
         }
      }

      #--   Message dans la console
      set tot [expr { $nbCFA+$nbRGB+$nbAutre }]
      if {$tot != 0} {
         ::trichro::errorMsg "[format $::caption(trichro,manquant) $tot]"
       }

      set nb [llength $listeOfFiles]
      if {$nb != 0} {
         set private(files) $listeOfFiles
      }

      return $nb
   }

   #------------------------------------------------------------
   #  brief buildGui Interface graphique
   #
   proc buildGui { args } {
      variable This $::audace(base).trichro
      variable private
      variable bd

      set private(trichro,visuNo) $::audace(visuNo)

      #--   Liste les fichiers du repertoire images et
      #--   Arrete si pas de fichier valable
      if {[::trichro::getAllFiles] == 0} {
         ::trichro::errorMsg "$::caption(trichro,no_file)"
         return
      }

      if {[winfo exists $This]} {
         destroy $This
      }

      initConf

      #--- cree la fenetre
      toplevel $This
      wm resizable $This 0 0
      wm title $This "$::caption(audace,menu,trichro)"
      wm geometry $This $::conf(trichro,position)
      wm protocol $This WM_DELETE_WINDOW "::trichro::cmdClose"

      frame $This.fr1 -relief raised -borderwidth 1
      pack $This.fr1 -side top -ipady 5 -fill both -expand yes

      #--   Calcule la largeur et la hauteur des combobox
      set labelwidth [::tkutil::lgEntryComboBox $private(files)]
      set len [llength $private(files)]

      #--   Selection du plan R
      label $This.fr1.lab_red -text "$::caption(trichro,red)"
      grid $This.fr1.lab_red -row 0 -column 0 -sticky w

      #--   cree la combobox des fichiers du repertoire
      ComboBox $This.fr1.sel_red -textvariable ::trichro::private(selected_red) \
         -relief sunken -height $len -width $labelwidth  \
         -values $$private(files) -editable 0
      grid $This.fr1.sel_red -row 0 -column 1 -columnspan 3 -sticky e

      #--   Selection du plan G
      label $This.fr1.lab_green -text "$::caption(trichro,green)"
      grid $This.fr1.lab_green -row 1 -column 0 -sticky w

      #--   cree la combobox des fichiers du repertoire
      ComboBox $This.fr1.sel_green -textvariable ::trichro::private(selected_green) \
         -relief sunken -height $len -width $labelwidth  \
         -values $$private(files) -editable 0
      grid $This.fr1.sel_green -row 1 -column 1 -columnspan 3 -sticky e

      #--   Selection du plan B
      label $This.fr1.lab_blue -text "$::caption(trichro,blue)"
      grid $This.fr1.lab_blue -row 2 -column 0 -sticky w

      #--   cree la combobox des fichiers du repertoire
      ComboBox $This.fr1.sel_blue -textvariable ::trichro::private(selected_blue) \
         -relief sunken -height $len -width $labelwidth  \
         -values $private(files) -editable 0
      grid $This.fr1.sel_blue -row 2 -column 1 -columnspan 3 -sticky e

      #--   Definition du repertoire de sortie
      label $This.fr1.lab_dest -text "$::caption(trichro,dest)"
      grid $This.fr1.lab_dest -row 3 -column 0 -sticky w

      entry $This.fr1.dest -textvariable ::trichro::private(dest) \
         -justify right -width $labelwidth -state disabled
      grid $This.fr1.dest -row 3 -column 1 -columnspan 3 -sticky ew
      $This.fr1.dest xview end

      #--   cree le bouton "..."
      button $This.fr1.search -text "$::caption(trichro,search)" \
         -width 2 -command {::trichro::getDirName}
      grid $This.fr1.search -row 3 -column 4 -padx 5 -pady 10 -sticky news

      #--   Définition du nom de l'image de sortie
      label $This.fr1.lab_racine -text "$::caption(trichro,name)"
      grid $This.fr1.lab_racine -row 4 -column 0 -sticky w

      entry $This.fr1.racine -textvariable ::trichro::private(racine) \
         -justify right -width $labelwidth
      grid $This.fr1.racine -row 4 -column 1 -columnspan 3 -sticky ew
      bind $This.fr1.racine <Leave> {::trichro::testRacine}

      grid columnconfigure $This.fr1 0 -weight 20 -pad 5
      grid rowconfigure $This.fr1 [list 0 1 2 3 4] -pad 10

      #--   cree le widget d'info

      label $This.labURL -text "$::caption(trichro,en_cours)" -justify center \
         -borderwidth 1 -relief raised -fg $::color(blue)

      frame $This.cmd -relief raised -borderwidth 1

         set cmdList [list apply left close right hlp right]
         if { $::conf(ok+appliquer)=="1" } {
            set cmdList [linsert $cmdList 0 ok left]
         }
         foreach {but side} $cmdList  {
            pack [button $This.cmd.$but -text "$::caption(trichro,$but)" -width 10] \
            -side $side -padx 10 -pady 3 -ipady 3
         }
         #-- specialisation des boutons
         if {[winfo exists $This.cmd.ok]} {
            $This.cmd.ok configure -command "::trichro::cmdOk"
         }
         $This.cmd.apply configure -command "::trichro::cmdApply"
         $This.cmd.hlp configure   -command "::audace::showHelpItem $::help(dir,images) 1190trichro.htm"
         $This.cmd.close configure -command "::trichro::cmdClose"

      pack $This.cmd -side bottom -fill both

      #--   initialisation des variables
      set private(selected_red)   "[lindex $private(files) 0]"
      set private(selected_green) "$private(selected_red)"
      set private(selected_blue)  "$private(selected_red)"
      set private(dest)           "$::audace(rep_images)"
      set private(racine)         "$::caption(trichro,racine)"

      #--   Pour suivre le changement de repertoire image par l'utilisateur
      if {[trace info variable ::audace(rep_images)] eq ""} {
         trace add variable ::audace(rep_images) write "::trichro::buildGui"
      }

      #--- La fenetre est active
      focus $This

      #--- mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Trichromie"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(trichro,position) définit la position de la fenêtre
   #
   proc initConf { } {
      if {![info exists ::conf(trichro,position)]} { set ::conf(trichro,position) "+800+500" }
   }

   #------------------------------------------------------------
   #  brief valide le nom
   #
   proc testRacine { } {
      variable private

      set racine $private(racine)

      #--   nom generique correct ?
      regexp -all {[\w_-]+} $racine match

      #--   si echec, message et retablit la valeur par defaut
      if {![info exists match] || $match ne "$racine"} {
         ::trichro::errorMsg "[format $::caption(trichro,invalid) \"$racine\" "$::caption(trichro,name)"]"
         set private(racine) "$::caption(trichro,racine)"
      }
   }

   #------------------------------------------------------------
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      cmdApply
      cmdClose
   }

   #------------------------------------------------------------
   ## @brief commande du bouton "Appliquer"
   #
   proc cmdApply { } {
      variable private

      set dir $::audace(rep_images)

      ::trichro::configButtons disabled
      set imagNameOut [file join $private(dest) $private(racine)$::conf(extension,defaut)]

      if {[::trichro::verify] == 0} {
         set files [list \
            [file join $dir $private(selected_red)] \
            [file join $dir $private(selected_green)] \
            [file join $dir $private(selected_blue)] \
         ]
         ::trichro::go2Trichro $files $imagNameOut
      } else {
         ::trichro::errorMsg "$::caption(trichro,err_dim)"
      }
      ::trichro::configButtons normal
   }

   #---------------------------------------------------------------------------
   #  brief vérifie la cohérence de la sélection
   #
   proc verify { } {
      variable private
      variable bd

      set err 0
      #-- Verifie si naxis1 (indice 0) et naxis2 (indice 1) des trois images sont identiques
      foreach index [list 0 1] {
         set dim1 [lindex [lindex [array get bd $private(selected_red)] 1 ] 0]
         set dim2 [lindex [lindex [array get bd $private(selected_green)] 1 ] 0]
         set dim3 [lindex [lindex [array get bd $private(selected_blue)] 1 ] 0]
         if {$dim1 ne $dim2 || $dim1 ne $dim3} { incr err }
      }

      return $err
   }

   #---------------------------------------------------------------------------
   #  brief inhibe/désinhibe tous les boutons
   #  param visuNo numéro de la visu
   #
   proc configButtons { state } {
      variable This

      foreach w [list fr1.search cmd.ok cmd.apply cmd.hlp cmd.close] {
         $This.$w configure -state $state
      }
      if {$state eq "normal"} {
         pack forget $This.labURL
      } else {
         pack $This.labURL -ipady 5 -fill both
      }
      update
   }

   #------------------------------------------------------------
   ## @brief Commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable This

      #--   Supprime la trace
      if {[trace info variable ::audace(rep_images)] ne ""} {
         trace remove variable ::audace(rep_images) write "::trichro::buildGui"
      }

      #--   equivalent de widgetToConf
      regsub {([0-9]+x[0-9]+)} [wm geometry $This] "" ::conf(trichro,position)

      destroy $This
   }

   #--------------------------------------------------------------------------
   ## @brief Commande du bouton "..." de saisie du nom générique de sortie ;
   #  capture le nom d'un répertoire
   #
   proc getDirName { } {
      variable private

      set initialDir $::audace(rep_images)

      set dirname [tk_chooseDirectory \
         -title "$::caption(trichro,dest)" \
         -initialdir $initialDir]

      if {$dirname eq "" || $dirname eq "$initialDir"} {
         set dirname $initialDir
      }

      if {[string index $dirname end] ne "/"} {
         append dirname "/"
      }

      set private(dest) $dirname
   }

   #------------------------------------------------------------
   #  brief affiche une fenetre d'erreur
   #  param msg contenu du message à afficher
   #
   proc errorMsg { msg } {
      tk_messageBox -title $::caption(trichro,attention)\
         -icon error -type ok -message $msg
   }

}

######################## Fin du namespace trichro ##########################


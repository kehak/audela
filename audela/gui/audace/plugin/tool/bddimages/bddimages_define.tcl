## @file bddimages_define.tcl
#  @brief     Gestion/modification des ent&ecirc;tes des images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_define.tcl]
#  @endcode

# $Id: bddimages_define.tcl 13886 2016-05-22 21:55:06Z jberthier $

##
# @namespace bddimages_define
# @brief Gestion/modification des ent&ecirc;tes des images
# @pre Requiert le fichier d'internationalisation \c bddimages_define.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_define {

   global audace
   global bddconf

   variable progress


   #--- Chargement des captions
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   # Definitions des cles BDI
   set bdi_key_state [list "RAW" "CORR" "CATA" "?"]
   set bdi_key_type  [list "IMG" "FLAT" "DARK" "OFFSET" "?"]

   # Variable d'action en sortie de la GUI
   set bdi_define_close ""

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
   proc run { this {listname ?} } {
      variable This
      global entetelog

      set entetelog "liste"
      set This $this
      createDialog $listname
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
   proc fermer { } {
      variable This

      ::bddimages_define::recup_position
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
   proc recup_position { } {
      variable This
      global audace
      global conf
      global bddconf

      set bddconf(list_geom_stat) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
      set fin [ string length $bddconf(list_geom_stat) ]
      set bddconf(list_pos_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
      #---
      set conf(bddimages,list_pos_stat) $bddconf(list_pos_stat)
      return
   }

   #--------------------------------------------------
   #  remove_requete { }
   #--------------------------------------------------
   #
   #    fonction  : Enleve une requete
   #
   #    procedure externe :
   #
   #    variables en entree :
   #
   #    variables en sortie :
   #
   #--------------------------------------------------
   proc remove_requete { {framereq ""} } {
   
      variable This
      global indicereq
      global list_req

      for {set x 1} {$x<=$indicereq} {incr x} {
         set err [catch {set a [$framereq.$x.sup cget -state]} msg ]
         if {!$err} {
            if {$a == "active" } {set i $x}
         }
      }

      set list_req($i,valide) "no"
      destroy $framereq.$i

   }


   proc ::bddimages_define::set_progress { cur max } {

      set ::bddimages_define::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
      update
   }


   #--------------------------------------------------
   #  get_list_box_champs { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       fournit la liste des champs
   #
   #    procedure externe :
   #
   #    variables en entree : none
   #
   #    variables en sortie : liste
   #
   #--------------------------------------------------
   proc get_list_box_champs { } {
   
      global list_key_to_var
   
      set list_box_champs [list ]
      set nbl1 0
      set sqlcmd "select distinct keyname,variable from header order by keyname;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         bddimages_sauve_fich "Erreur de lecture de la liste des header par SQL"
         return -code error "Erreur de lecture de la liste des header par SQL"
      }
      foreach line $resultsql {
         set key [lindex $line 0]
         set var [lindex $line 1]
         set list_key_to_var($key) $var
         if {$nbl1<[string length $key]} {
            set nbl1 [string length $key]
         }
         lappend list_box_champs $key
      }
      set nbl1 [expr $nbl1 + 3]
      return [list $nbl1 $list_box_champs]
   }

   #--------------------------------------------------
   #  get_var_type { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       ...
   #
   #    procedure externe :
   #
   #    variables en entree : 
   #       var ...
   #
   #    variables en sortie : liste
   #
   #--------------------------------------------------
   proc get_var_type { var } {
   
      set i [regexp -all {^[-+]?[0-9]+$} $var]
      if {$i == 1 } {return "int"}
   
      set i [regexp -all {^[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?$} $var]
      if {$i == 1 } {return "double"}
   
      set i [regexp -nocase {^.*[a-z].*$} $var]
      if {$i == 1 } {return "string"}
   
      return
   
   }

#   #--------------------------------------------------
#   #  init_main_bdi_key { }
#   #--------------------------------------------------
#   #
#   #    fonction  :
#   #       Initialisations des valeurs des cles BDI STATE et TYPE
#   #       a partir des headers des images
#   #
#   #    variables en entree : none
#   #
#   #    variables en sortie : liste
#   #
#   #--------------------------------------------------
#   proc init_main_bdi_key {  } {
#
#      global bddconf
#
#      set val_key_state ""
#      set val_key_type ""
#      set ok_key_state 0
#      set ok_Key_type 0
#      
#      ::console::affiche_resultat "Length = [llength $bddconf(define)] \n"
#      foreach idbddimg $bddconf(define) {      
#         # charge l'image
#         set ident [bddimages_image_identification $idbddimg]
#         set fileimg  [lindex $ident 1]
#         if {$fileimg != -1} {
#            # Chargement de l'image
#            set bufno [::buf::create]
#            buf$bufno load $fileimg
#            # Extraction de la valeur du mot cle STATE
#            set key [buf$bufno getkwd "BDDIMAGES STATE"]
#            if { ! [string equal -nocase $val_key_state [lindex $key 1]]} {
#               set val_key_state [lindex $key 1]
#               incr ok_key_state 1
#            }
#            # Extraction de la valeur du mot cle TYPE
#            set key [buf$bufno getkwd "BDDIMAGES TYPE"]
#            if { ! [string equal -nocase $val_key_type [lindex $key 1]]} {
#               set val_key_type [lindex $key 1]
#               incr ok_key_type 1
#            }
#         }
#      }
#
#      # Si toutes les valeurs de la cle STATE sont identiques
#      if {$ok_key_state == 1} {
#         set bdi_key(state) $val_key_state
#      } else {
#         set bdi_key(state) ""
#      }
#      # Si toutes les valeurs de la cle TYPE sont identiques
#      if {$ok_key_type == 1} {
#         set bdi_key(type) $val_key_type
#      } else {
#         set bdi_key(type) ""
#      }
#
#      return [array get bdi_key]
#   }

   #--------------------------------------------------
   #  accept { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       Execute les modifications dans l'entete de l'image d'apres 
   #       les choix de l'utilisateur
   #
   #    procedure externe :
   #
   #    variables en entree : none
   #
   #    variables en sortie : liste
   #
   #--------------------------------------------------
   proc ::bddimages_define::accept { } {
   
      global bddconf
      global caption
      global form_req
      global indicereq
      global list_req
      global def_cles_bdi
      
      set cpt 0
      set nbtotal [llength $bddconf(define)]
      # Pour chaque image selectionnee ...
      foreach idbddimg $bddconf(define) {
   
         #::console::affiche_resultat "idbddimg = $idbddimg  \n"
         set change "no"

         # charge l'image
         set ident [bddimages_image_identification $idbddimg]
         set fileimg  [lindex $ident 1]
         set filecata [lindex $ident 3]
         #::console::affiche_resultat "Chargement de $ident -> $fileimg \n"
         if {$fileimg == -1} {
            ::console::affiche_resultat "Fichier image inexistant ($idbddimg) \n"
            ::bddimages_define::fermer
            return
         }
         set bufno [::buf::create]
         buf$bufno load $fileimg
         
         # Verifie la compatibilite si le check button est clique
         if {$form_req(type_req_check) == 1} {
            if {[::bddimagesAdmin::bdi_compatible $bufno] == 0 } {
               ::bddimagesAdmin::bdi_setcompat $bufno
               set change "yes"
            }
         }

         # Modifie le header fits de l'image si la cle BDI STATE est non nulle
         if {! [string equal $def_cles_bdi(state) ""]} {
            if {[string first "BDDIMAGES STATE" [buf$bufno getkwd "BDDIMAGES STATE"]] == -1} {
               set key [list "BDDIMAGES STATE" $def_cles_bdi(state) "string" "RAW | CORR | CATA | ?" ""]
            } else {
               set key [buf$bufno getkwd "BDDIMAGES STATE"]
               set key [lreplace $key 1 1 $def_cles_bdi(state)]
            }
            buf$bufno setkwd $key
            set change "yes"
         } else {
            
         }
         # Modifie le header fits de l'image si la cle BDI TYPE est non nulle
         if {! [string equal $def_cles_bdi(type) ""]} {
            if {[string first "BDDIMAGES TYPE" [buf$bufno getkwd "BDDIMAGES TYPE"]] == -1} {
               set key [list "BDDIMAGES TYPE" $def_cles_bdi(type) "string" "IMG | FLAT | DARK | OFFSET | ?" ""]
            } else {
               set key [buf$bufno getkwd "BDDIMAGES TYPE"]
               set key [lreplace $key 1 1 $def_cles_bdi(type)]
            }
            buf$bufno setkwd $key
            set change "yes"
         }
         
         # Modifie le header fits de l'image en fct des regles
         for { set x 1 } { $x <= $indicereq } { incr x } {
            if {$list_req($x,valide) == "ok"} {
               set key [buf$bufno getkwd $list_req($x,champ)]
               set key [lreplace $key 0 0 $list_req($x,champ)]
               set key [lreplace $key 1 1 $list_req($x,valeur)]
               set vartype [lindex $key 2]
               set evalvartype [get_var_type [lindex $key 1]]
               if {$vartype == "none"} {
                  set key [lreplace $key 2 2 $evalvartype]
               } elseif {$vartype != $evalvartype} {
                  ::console::affiche_erreur "WARNING ! le type de variable a change $vartype -> $evalvartype \n"
                  set key [lreplace $key 2 2 $evalvartype]
               }
               buf$bufno setkwd $key
               #set key [buf$bufno getkwd $list_req($x,champ)]
               set change "yes"
            }
         }
   
         if {$change == "yes"} {
            # enregistre les modif dans l image
            set fichtmpunzip [unzipedfilename $fileimg]
            set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
            set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]

            createdir_ifnot_exist $bddconf(dirtmp)
            buf$bufno save $filetmp
            lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg
            #set errnum [catch {exec gzip -c $filetmp > $filefinal} msg ]

            # copie l image dans incoming, ainsi que le fichier cata si il existe
            if {$filecata != -1} {
               set err [catch {file rename -force -- $filecata $bddconf(dirinco)/.} msg ]
               if {$err} {
                  gren_erreur "insertion_solo : Impossible de deplacer le fichier cata du disque vers incoming :"
                  gren_erreur "<filecata=$filecata>"
                  gren_erreur "<err=$err>"
                  gren_erreur "<msg=$msg>"
                  bddimages_sauve_fich "insertion_solo : Impossible de deplacer le fichier cata du disque vers incoming : <filecata=$filecata> <err=$err> <msg=$msg>"
               }
            }
  
            # efface l image dans la base et le disque
            bddimages_image_delete_fromsql $ident
            bddimages_image_delete_fromdisk $ident

            # insere l image et le cata dans la base
            gren_info "insertion_solo : ident = $ident\n"
            gren_info "insertion_solo : filefinal = $filefinal\n"
            insertion_solo $filefinal
            if {$filecata!=-1} {
               set filecata [file join $bddconf(dirinco) [file tail $filecata]]
               gren_info "insertion_solo filecata = $filecata\n"
               if {![file exists $filecata]} {
                  gren_erreur "cata : $filecata file not exist\n"
               } else {
                  insertion_solo $filecata
               }
            }

            set errnum [catch {file delete -force $filetmp} msg ]
            incr cpt
            ::console::affiche_resultat "$cpt/$nbtotal \n"

         }
         ::bddimages_define::set_progress $cpt $nbtotal

         buf$bufno clear
      }

      # Variable d'action en sortie de GUI
      set ::bddimages_define::bdi_define_close "close"
      # Fermeture du dialogue
      ::bddimages_define::fermer
   }

   #--------------------------------------------------
   #  add_requete { }
   #--------------------------------------------------
   #
   #    fonction  :
   #       ajout d'une requete
   #
   #    procedure externe :
   #
   #    variables en entree : 
   #       frame la reference du frame dans lequel sont affichees les requetes
   #
   #    variables en sortie : none
   #
   #--------------------------------------------------
   proc add_requete { {framereq ""} } {
   
      variable This
      global audace
      global caption
      global bddconf
      global indicereq
      global list_req

      #--- Initialisation des combox
      set result [get_list_box_champs]
      set list_box_champs [lindex $result 1]
      set nbrows1 [ llength $list_box_champs ]
      set nbcols1 [lindex $result 0]
      set list_combobox "="
      set nbrows2 1
      set nbcols2 13
   
      #--- Initialisation de la liste des requetes
      set indicereq [expr $indicereq + 1]
   
      if { [ info exists list_req($indicereq,champ) ] } {
         set list_req($indicereq,valide) "ok"
      } else {
         set list_req($indicereq,champ) [lindex $list_box_champs 0]
         set list_req($indicereq,condition) "="
         set list_req($indicereq,valeur) ""
         set list_req($indicereq,valide) "ok"
      }
   
      #--- Cree un frame pour la requete
      set frchch $framereq.$indicereq
      frame $frchch -borderwidth 1 -relief solid
#      pack $frchch -in $framereq -anchor w -side top -expand 0 -fill both -padx 3 -pady 0
   
       #--- Cree la liste des champs
       ComboBox $frchch.combo1 \
          -width $nbcols1 -height 15 \
          -relief sunken -borderwidth 1 -editable 0 \
          -textvariable list_req($indicereq,champ) \
          -values $list_box_champs
       pack $frchch.combo1 -anchor center -side left -fill x -expand 1
       grid $frchch -sticky new
       #--- Cree la liste des conditions
       label $frchch.combo -font $bddconf(font,arial_10_b) -text "="
       pack $frchch.combo -in $frchch -side left -anchor w -padx 1
       #--- Cree une ligne d'entree pour la variable
       entry $frchch.dat -textvariable list_req($indicereq,valeur) -borderwidth 1 -relief groove -width 25 -justify left
       pack $frchch.dat -in $frchch -side left -anchor w -padx 1
       #--- Cree un bouton supprime requete
       button $frchch.sup -state normal -borderwidth 1 -relief groove -anchor c -height 1 \
          -text "-" -command [list ::bddimages_define::remove_requete $framereq]
   
       pack $frchch.sup -in $frchch -side left -anchor w -padx 1
       #--- Cree un bouton ajout requete
       button $frchch.add -state active -borderwidth 1 -relief groove -anchor c -height 1 \
          -text "+" -command [list ::bddimages_define::add_requete $framereq]
       pack $frchch.add -in $frchch -side left -anchor w -padx 1
   
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
   proc createDialog { listname } {

      variable This
      global audace
      global caption
      global color
      global conf
      global bddconf
      global intellilisttotal
      global indicereq
      global form_req
      global list_req
      global def_cles_bdi

      # Initialisations
      set ::bddimages_define::progress 0

      set indicereq 0
      set list_comb1 [list $caption(bddimages_define,toutes) $caption(bddimages_define,nimporte)]
      set list_comb2 [list $caption(bddimages_define,elem)]
      set list_comb3 [list $caption(bddimages_define,alea) \
                           $caption(bddimages_define,dateobs) \
                           $caption(bddimages_define,telescope) \
                           $caption(bddimages_define,plrecmod) \
                           $caption(bddimages_define,morecmod) \
                           $caption(bddimages_define,plrecajo) \
                           $caption(bddimages_define,morecajo) ]

      set form_req(name) "Newlist[ expr $::nbintellilist + 1 ]"
      set form_req(type_req_check) 1
      set form_req(type_requ) [lindex $list_comb1 0]
      set form_req(choix_limit_result) ""
      set form_req(limit_result) "25"
      set form_req(type_result) [lindex $list_comb2 0]
      set form_req(type_select) [lindex $list_comb3 0]
      set form_req(nbimg) "?"

      set edit 0
      if { ! ($listname eq "?") } {
        set edit 1
        set editname $listname
        set editid [get_intellilist_by_name $listname]
      }

      set indicereqinit 0

      if { $edit } {
         set  l $intellilisttotal($editid)
         foreach e $l {
            set key [lindex $e 0]
            if { [string is integer $key] } {
               set list_req($key,champ) [lindex $e 1]
               set list_req($key,condition) [lindex $e 2]
               set list_req($key,valeur) [lindex $e 3]
               if { $indicereqinit < $key } { set indicereqinit $key }
            } else {
               set a($key) [lindex $e 1]
            }
         }
         set form_req(name) $a(name)
         set form_req(type_req_check) $a(type_req_check)
         set form_req(type_requ) $a(type_requ)
         set form_req(choix_limit_result) $a(choix_limit_result)
         set form_req(limit_result) $a(limit_result)
         set form_req(type_select) $a(type_select)
         parray form_req
         parray list_req
         array unset a
      } else {
         array unset list_req
      }

      # Initialisations des valeurs des cles BDI STATE et TYPE a partir des images
#      array set def_cles_bdi [::bddimages_define::init_main_bdi_key] 
      array set def_cles_bdi {state "" type ""}

      #--- initConf
      if { ! [ info exists conf(bddimages,list_pos_stat) ] } { set conf(bddimages,list_pos_stat) "+80+40" }

      #--- confToWidget
      set bddconf(list_pos_stat) $conf(bddimages,list_pos_stat)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         return
      }

      #---
      if { [ info exists bddconf(list_geom_stat) ] } {
         set deb [ expr 1 + [ string first + $bddconf(list_geom_stat) ] ]
         set fin [ string length $bddconf(list_geom_stat) ]
         set bddconf(list_geom_stat) "+[ string range $bddconf(list_geom_stat) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This $bddconf(list_pos_stat)
      wm resizable $This 1 1
      wm title $This "$caption(bddimages_define,main_title)"
      wm protocol $This WM_DELETE_WINDOW { ::bddimages_define::fermer }

         #--- Cree un frame pour le titre
         set framecurrent $This.title
         frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
         pack $framecurrent -in $This -anchor c -side top -expand 0 -fill x -padx 5 -pady 5
           #--- Cree un label
           label $framecurrent.titre -font $bddconf(font,arial_12_b) -text "$caption(bddimages_define,title)"
           pack $framecurrent.titre -in $framecurrent -side top -padx 5 -pady 5
   
         #--- Cree un frame pour choisir la compatibilite BDI
         set framecurrent $This.compatbdi
         frame $framecurrent -borderwidth 0 -cursor arrow
         pack $framecurrent -in $This -anchor c -side top -expand 0 -padx 5 -pady 5
            #--- Bouton check
            checkbutton $framecurrent.check -highlightthickness 0 -state normal -variable form_req(type_req_check) \
               -command {  }
            pack $framecurrent.check -in $framecurrent -side left -padx 2
            #--- Cree un label
            label $framecurrent.txt1 -font $bddconf(font,arial_10_b) -text "$caption(bddimages_define,majCompat)"
            pack $framecurrent.txt1 -in $framecurrent -side left -padx 2
            #--- Bouton Info
            button $framecurrent.info -text "?" -borderwidth 1 \
               -command { tk_messageBox -message "$caption(bddimages_define,infoCompat)" -type ok }
            pack $framecurrent.info -in $framecurrent -side left -padx 2

         #--- Frame pour saisir les cles BDI STATE et TYPE
         set framecurrent $This.compatbdicle
         frame $framecurrent -borderwidth 1 -cursor arrow -relief groove
         pack $framecurrent -in $This -anchor c -side top -expand 0 -padx 5 -pady 5
            #--- Frame de la premiere cle
            frame $framecurrent.state -borderwidth 0 -cursor arrow
            pack $framecurrent.state -in $framecurrent -anchor c -side top -expand 0 -padx 5 -pady 2
               #--- Cle bdi state
               label $framecurrent.state.labcle -text "BDI STATE =" -width 12 -anchor e
               pack $framecurrent.state.labcle -in $framecurrent.state -side left -anchor e -padx 1
               #--- valeurs possibles
               ComboBox $framecurrent.state.combo1 \
                  -relief sunken -borderwidth 1 -editable 0 -width 10 \
                  -textvariable def_cles_bdi(state) -values $::bddimages_define::bdi_key_state
               pack $framecurrent.state.combo1 -in $framecurrent.state -side left -padx 2
            #--- Frame de la deuxieme cle
            frame $framecurrent.type -borderwidth 0 -cursor arrow
            pack $framecurrent.type -in $framecurrent -anchor c -side top -expand 0 -padx 5 -pady 2
               #--- Cle bdi state
               label $framecurrent.type.labcle -text "BDI TYPE =" -width 12 -anchor e
               pack $framecurrent.type.labcle -in $framecurrent.type -side left -anchor e  -padx 1
               #--- valeurs possibles
               ComboBox $framecurrent.type.combo1 \
                  -relief sunken -borderwidth 1 -editable 0 -width 10 \
                  -textvariable def_cles_bdi(type) -values $::bddimages_define::bdi_key_type
               pack $framecurrent.type.combo1 -in $framecurrent.type -side left -padx 2

         #--- Cree un frame pour ajouter des requetes
         set framereqcurrent $This.addreq
         frame $framereqcurrent -borderwidth 0 -cursor arrow
         pack $framereqcurrent -in $This -anchor s -side top -fill x -padx 5 -pady 5
            #--- Cree un bouton d'ajout de requete
            button $framereqcurrent.add -state active -borderwidth 1 -width 45 -text "$caption(bddimages_define,addrule)" \
               -command [list ::bddimages_define::add_requete $framereqcurrent.framereq]
            pack $framereqcurrent.add -in $framereqcurrent -side top -padx 5 -pady 5 
            #--- Cree un frame pour afficher les requetes
            frame $framereqcurrent.framereq -borderwidth 0 -cursor arrow
            pack $framereqcurrent.framereq -in $framereqcurrent -anchor s -side top -expand 1 -fill both
            #--- Ajout des requetes
            for { set x 0 } { $x < $indicereqinit } { incr x } {
               ::bddimages_define::add_requete $framereqcurrent.framereq
            }

         #--- Cree un frame pour y mettre la barre de progression
         frame $This.frameprogress -borderwidth 0 -cursor arrow
         pack $This.frameprogress -in $This -anchor s -side top -expand 0 -fill x

               set pf [ ttk::progressbar $This.frameprogress.p -variable ::bddimages_define::progress -orient horizontal -length 350 -mode determinate]
               pack $pf -in $This.frameprogress -side top -anchor c

         #--- Cree un frame pour y mettre les boutons
         frame $This.frame11 -borderwidth 0 -cursor arrow
         pack $This.frame11 -in $This -anchor s -side bottom -expand 0 -fill x

            #--- Creation du bouton annuler
            button $This.frame11.but_annuler \
               -text "$caption(bddimages_define,annuler)" -borderwidth 2 \
               -command { ::bddimages_define::fermer }
            pack $This.frame11.but_annuler \
               -in $This.frame11 -side right -anchor e \
               -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

            #--- Creation du bouton ok
            button $This.frame11.but_ok \
               -text "$caption(bddimages_define,ok)" -borderwidth 2 \
               -command { ::bddimages_define::accept }
            pack $This.frame11.but_ok \
               -in $This.frame11 -side right -anchor e \
               -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

            #--- Creation du bouton aide
            button $This.frame11.but_aide \
               -text "$caption(bddimages_define,aide)" -borderwidth 2 \
               -command {lecture_info This}
            pack $This.frame11.but_aide \
               -in $This.frame11 -side right -anchor e \
               -padx 2 -pady 2 -ipadx 2 -ipady 2 -expand 0

      #--- La fenetre est active
      focus $This
      #--- Et prend la main...
      grab set $This
      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}


## @file skybot_resolver.tcl
# @brief  Resolution du nom d'un objet du systeme solaire par le service SkyBoT (http://vo.imcce.fr/webservices/skybot)
# @author J. Berthier (berthier@imcce.fr)
# @par Ressource
# @code source [file join $audace(rep_install) gui audace plugin tool vo_tools skybot_resolver.tcl]
# @endcode

# $Id: skybot_resolver.tcl 13890 2016-05-23 16:35:52Z jberthier $

##
# @namespace skybot_Resolver
# @brief Affiche le statut de la base de donnees SkyBoT (http://vo.imcce.fr/webservices/skybot)
# @pre Requiert le fichier d'internationalisation \c skybot_search.cap .
#
namespace eval ::skybot_Resolver {
   global audace
   global voconf

   package require xml

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool vo_tools skybot_resolver.cap ]

   ## @brief Cree la fenetre de resolution du nom d'un objet du systeme solaire
   # @param this chemin de la fenetre
   #
   proc run { this } {
      variable This
      variable column_format
      global caption

      array set column_format { }
      #---
      set column_format(Num)          [ list 9  "$caption(resolver,num)"        right ]
      set column_format(Name)         [ list 12 "$caption(resolver,name)"       left ]
      set column_format(RAh)          [ list 12 "$caption(resolver,rah)"        right ]
      set column_format(DEdeg)        [ list 14 "$caption(resolver,dedeg)"      right ]
      set column_format(Class)        [ list 8  "$caption(resolver,class)"      left ]
      set column_format(Mv)           [ list 8  "$caption(resolver,mv)"         right ]
      set column_format(Errarcsec)    [ list 12 "$caption(resolver,errarcsec)"  right ]
      set column_format(darcsec)      [ list 11 "$caption(resolver,darcsec)"    right ]
      set column_format(dRAarcsec/h)  [ list 15 "$caption(resolver,draarcsec)"  right ]
      set column_format(dDECarcsec/h) [ list 16 "$caption(resolver,ddecarcsec)" right ]
      set column_format(Dgua)         [ list 17 "$caption(resolver,dgua)"       right ]
      set column_format(Dhua)         [ list 17 "$caption(resolver,dhua)"       right ]
      #---
      global myurl
      set myurl(iau_codes)   "http://cfa-www.harvard.edu/iau/lists/ObsCodes.html"
      set myurl(astorb,CDS)  "http://vizier.u-strasbg.fr/cgi-bin/VizieR-5?-source=B/astorb/astorb&Name==="
      set myurl(vizier,CDS)  "http://vizier.u-strasbg.fr/cgi-bin/VizieR-5?-source=B/astorb/astorb&Name==="
      set myurl(simbad,CDS)  "http://simbad.u-strasbg.fr/sim-id.pl?Ident="
      #---
      set This $this
      createDialog
      tkwait visibility $This
   }

   ## @brief Fonction appellee lors de l'appui sur le bouton 'Fermer'
   #
   proc fermer { } {
      variable This

      ::skybot_Resolver::recup_position
      destroy $This
   }

   ## @brief Permet de recuperer et de sauvegarder la position de la fenetre
   #
   proc recup_position { } {
      variable This
      global audace
      global conf
      global voconf

      set voconf(geometry_resolver) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $voconf(geometry_resolver) ] ]
      set fin [ string length $voconf(geometry_resolver) ]
      set voconf(position_resolver) "+[ string range $voconf(geometry_resolver) $deb $fin ]"
      #---
      set conf(vo_tools,resolver,position) $voconf(position_resolver)
   }

   ## @brief Affichage d'un message sur le format d'une saisie
   # @param subject string mot cle du message a afficher
   #
   proc GetInfo { subject } {
      global caption
      global voconf
      switch $subject {
         target      { set msg $caption(resolver,format_target) }
         epoch       { set msg $caption(resolver,format_epoch) }
         loc         { set msg $caption(resolver,format_loc) }
         dim_fov     { set msg $caption(resolver,format_dim_fov) }
         filter      { set msg $caption(resolver,format_filter) }
         default     { set msg $caption(resolver,param_none) }
      }
      tk_messageBox -title $caption(resolver,msg_format) -type ok -message $msg
      return 1
   }

   ## @brief Parser pour la sortie xml de Sesame (CDS)
   # @param xml chaine de caractere contenant la sortie XML de Sesame (CDS)
   # @return chaine analysee
   #
   proc xml2list { xml } {

     regsub -all {>\s*<} [string trim $xml " \n\t<>"] "\} \{" xml
     set xml [string map {? ""  > "\} \{#text \{" < "\}\} \{"}  $xml]
     regsub -all  {\{![\-]+(.*)[\-]+\}} $xml "" xml
     regsub -all  {xml version="1.0" encoding="UTF-8"\} \{} $xml "" xml

     set res ""   ;# string to collect the result
     set stack {} ;# track open tags
     set rest {}
     foreach item "{$xml}" {
         switch -regexp -- $item {
            ^# {
               append res "{[lrange $item 0 end]} " ; #text item
            }
            ^/ {
               regexp {/(.+)} $item -> tagname ; # end tag
               set expected [lindex $stack end]
               if {$tagname != $expected} {error "$item != $expected"}
               set stack [lrange $stack 0 end-1]
               append res "\}\} "
            }
            /$ { # singleton - start and end in one <> group
               regexp {([^ ]+)( (.+))?/$} $item -> tagname - rest
               set rest [lrange [string map {= " "} $rest] 0 end]
               append res "{$tagname [list $rest] {}} "
            }
            ^! { # comment <!-- -->
               # nothing to do, just skip the comments in the xml document
            }
            default {
               set tagname [lindex $item 0] ;# start tag
               set rest [lrange [string map {= " "} $item] 1 end]
               lappend stack $tagname
               append res "\{$tagname [list $rest] \{"
            }
         }
         if {[llength $rest]%2} { error [concat "att's not paired: $rest"] }
     }
     if [llength $stack] { error [concat "unresolved: $stack"] }
     string map {"\} \}" "\}\}"} [lindex $res 0]
     return $res
   }

   ## @brief Extraction des donnees dans la reponse XML de Sesame
   # @param xml chaine de caractere contenant la sortie XML de Sesame (CDS)
   # @return string donnees Sesame
   #
   proc Extract_Sesame_Data { xml } {

      set ok(name) 0
      set ok(ra) 0
      set ok(de) 0
      # Extraction des enfants de Resolver dans la liste de listes xml
      # Exemple de fichier XML retourne par Sesame (dec. 2008)
      # <Target>
      #   <name>ic434</name>
      #   <!-- Q315553 #1 -->
      #   <Resolver name="S=Simbad (CDS, via client/server)">
      #     <INFO>from cache</INFO>
      #     <otype>HII</otype>
      #     <jpos>05:41:00.00 -02:30:00.0</jpos>
      #     <jradeg>85.25</jradeg>
      #     <jdedeg>-2.5</jdedeg>
      #     <errRAmas>1080000</errRAmas><errDEmas>1080000</errDEmas>
      #     <oname>IC 434</oname>
      #     <alias>IC 434</alias>
      #     <nrefs>37</nrefs>
      #   </Resolver>
      # </Target>
      # </Sesame>
      set data [ lindex [ xml2list $xml ] 0 2 0 2 1 2 ]
      # Pour chaque enfant on recupere element->value
      for { set i 0 } { $i <= [ expr [ llength $data ] - 1 ] } { incr i } {
         set key   [ lindex $data $i 0 ]
         set value [ string map {\{\#text "" \{ "" \} ""} [ lindex $data $i 2 ] ]
         # Sauvegarde des parametres souhaites
         switch $key {
            oname  { set sesame(oname) $value;  set ok(name) 1 }
            jradeg { set sesame(jradeg) $value; set ok(ra)   1 }
            jdedeg { set sesame(jdedeg) $value; set ok(de)   1 }
            otype  { set sesame(otype) $value }
         }
      }
      if { $ok(name) && $ok(ra) && $ok(de) } {
         set response [concat "# Num, Name, RA(h), DE(deg), Class, Mv, Err(arcsec), dRA(arcsec/h), dDEC(arcsec/h), Dg(ua), Dh(ua) ; -|$sesame(oname)|[expr $sesame(jradeg)/15.0]|$sesame(jdedeg)|$sesame(otype)|||||| " ]
      } else {
         set response "1"
      }
      return $response
   }

   ## @brief Creation de l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace
      global caption
      global conf
      global voconf
      global myurl

      #--- Initialisation
      set voconf(nom_objet)        ""
      set voconf(date_ephemerides) ""
      set voconf(ad_objet)         ""
      set voconf(dec_objet)        ""
      set voconf(taille_champ_x)   "600"
      set voconf(taille_champ_y)   ""
      set voconf(taille_champ)     ""
      set voconf(filter)           "120"
      set voconf(iau_code_obs)     "500"
      set voconf(type)             "?"

      set voconf(but_skybot)       1
      set voconf(but_sesame)       1
      set voconf(sesame_server)    "CDS"

      #--- initConf
      if { ! [ info exists conf(vo_tools,resolver,position) ] } { set conf(vo_tools,resolver,position) "+80+40" }

      #--- confToWidget
      set voconf(position_resolver) $conf(vo_tools,resolver,position)

      #---
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frame6.but_fermer
         return
      }

      #---
      if { [ info exists voconf(geometry_resolver) ] } {
         set deb [ expr 1 + [ string first + $voconf(geometry_resolver) ] ]
         set fin [ string length $voconf(geometry_resolver) ]
         set voconf(position_resolver) "+[ string range $voconf(geometry_resolver) $deb $fin ]"
      }

      #---
      toplevel $This -class Toplevel
      wm geometry $This $voconf(position_resolver)
      wm resizable $This 1 1
      wm title $This $caption(resolver,main_title)
      wm protocol $This WM_DELETE_WINDOW { ::skybot_Resolver::fermer }

      #--- Cree un frame pour les parametres de calcul
      frame $This.frame1 -borderwidth 0
      pack $This.frame1 \
         -in $This -anchor s -side top -expand 0 -fill x \
         -pady 6

        #--- Cree un label pour le titre objet celeste
        label $This.frame1.titre -text "$caption(resolver,titre_objet)" \
          -borderwidth 0 -relief flat
        pack $This.frame1.titre \
          -in $This.frame1 -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour la saisie du corps celeste
        set objet [frame $This.frame1.param -borderwidth 1 -relief solid]
        pack $objet \
          -in $This.frame1 -anchor w -side top -expand 0 -fill x -padx 10

           #--- Cree un label
           label $objet.lab -text "$caption(resolver,nom_objet)"
           pack $objet.lab \
              -in $objet -side left -anchor center \
              -padx 3 -pady 3
           #--- Cree une ligne d'entree
           entry $objet.ent -textvariable voconf(nom_objet) \
              -borderwidth 1 -relief groove -width 50 -justify center
           pack $objet.ent \
              -in $objet -side left -anchor center -fill x -expand 1 \
              -padx 3 -pady 3
           #--- Cree un bouton pour une info sur la saisie de l'epoque
           button $objet.help -state active \
              -borderwidth 0 -relief flat -anchor c \
              -text "$caption(resolver,info)" \
              -command { ::skybot_Resolver::GetInfo "target" }
           pack $objet.help \
              -in $objet -side right -anchor c \
              -padx 6 -pady 3

      #--- Cree un frame pour les parametres de calcul
      frame $This.frame2 -borderwidth 0
      pack $This.frame2 \
         -in $This -anchor s -side top -expand 0 -fill x \
         -pady 6

        #--- Cree un label pour le titre des parametres
        label $This.frame2.titre -text "$caption(resolver,titre_param)" \
          -borderwidth 0 -relief flat
        pack $This.frame2.titre \
          -in $This.frame2 -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour les parametres de calcul
        set param [frame $This.frame2.param -borderwidth 1 -relief solid]
        pack $param \
          -in $This.frame2 -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un frame pour les labels
          frame $param.lab -borderwidth 0
          pack $param.lab \
             -in $param -side left \
             -padx 3 -pady 3
            #--- Cree un label pour l'epoque des calculs
            label $param.lab.epoch \
               -text "$caption(resolver,epoch)" \
               -borderwidth 0 -relief flat
            pack $param.lab.epoch \
               -in $param.lab -side top -anchor w \
               -padx 3 -pady 3
            #--- Cree un label pour la localisation de l'observateur
            label $param.lab.loc \
               -text "$caption(resolver,loc)" \
               -borderwidth 0 -relief flat
            pack $param.lab.loc \
               -in $param.lab -side top -anchor w \
               -padx 3 -pady 3

          #--- Cree un frame pour les saisies
          frame $param.input -borderwidth 0
          pack $param.input \
             -in $param -side left -anchor w -expand 0 -fill x \
             -padx 3 -pady 3
            #--- Cree une ligne d'entree pour la saisie de l'epoque
            entry $param.input.epoch \
               -textvariable voconf(date_ephemerides) \
               -borderwidth 1 -relief groove -width 23 -justify center
            pack $param.input.epoch \
               -in $param.input -side top
            #--- Cree une ligne d'entree pour la loc de l'observateur
            entry $param.input.loc \
               -textvariable voconf(iau_code_obs) \
               -borderwidth 1 -relief groove -width 23 -justify center
            pack $param.input.loc \
               -in $param.input -side top

          #--- Cree un frame pour les boutons associes
          frame $param.but -borderwidth 0
          pack $param.but \
             -in $param -side left -anchor w -expand 0 -fill x \
             -padx 3 -pady 3
            #--- Cree un bouton pour inserer la date courante
            button $param.but.epoch \
               -text "$caption(resolver,date_crte)" -borderwidth 1 \
               -command { set voconf(date_ephemerides) [ mc_date2iso8601 now ] }
            pack $param.but.epoch \
               -in $param.but -side top -fill x
            #--- Cree un bouton pour afficher la liste des code UAI
            button $param.but.loc \
               -text "$caption(resolver,liste_code_uai)" -borderwidth 1 \
               -command { ::audace::Lance_Site_htm $myurl(iau_codes) }
            pack $param.but.loc \
               -in $param.but -side top -fill x

          #--- Cree un frame pour l'aide
          frame $param.help -borderwidth 0
          pack $param.help \
               -in $param -side left \
               -padx 3 -pady 3
            #--- Cree un bouton pour une info sur la saisie de l'epoque
            button $param.help.epoch -state active \
               -borderwidth 0 -relief flat -anchor c \
               -text "$caption(resolver,info)" \
               -command { ::skybot_Resolver::GetInfo "epoch" }
            pack $param.help.epoch \
              -in $param.help -side top -anchor c \
              -padx 3 -pady 3
            #--- Cree un bouton pour une info sur la saisie de l'epoque
            button $param.help.loc -state active \
               -borderwidth 0 -relief flat -anchor c \
               -text "$caption(resolver,info)" \
               -command { ::skybot_Resolver::GetInfo "loc" }
            pack $param.help.loc \
              -in $param.help -side top -anchor c \
              -padx 3 -pady 3

      #--- Cree un frame pour le bouton calcul des ephemerides
      frame $This.frame3 -borderwidth 0
      pack $This.frame3 \
         -in $This -anchor s -side top -expand 0 -fill x \
         -padx 10 -pady 3

        #--- Cree un frame pour le bouton Calcul ephem.
        frame $This.frame3.eph -borderwidth 0
        pack $This.frame3.eph \
           -in $This.frame3 -anchor c -side top
          #--- Creation du bouton
          button $This.frame3.eph.but_calcul -text "$caption(resolver,calcul_ephemerides)" \
             -borderwidth 2 \
             -command { ::skybot_Resolver::cmdResolver }
          pack $This.frame3.eph.but_calcul \
             -in $This.frame3.eph -side left -anchor c \
             -ipadx 5 -ipady 5 -expand 0
          #--- Cree un frame pour les 2 checkbuttons
          frame $This.frame3.eph.cb -borderwidth 0
          pack $This.frame3.eph.cb \
             -in $This.frame3.eph -anchor c -side left
            #--- Creation des checkbutton pour activer ou non la resolution par Skybot
            checkbutton $This.frame3.eph.cb.but_skybot -text "$caption(resolver,but_skybot)" \
               -variable voconf(but_skybot) -bg "red"
            pack $This.frame3.eph.cb.but_skybot \
               -in $This.frame3.eph.cb -side top -anchor w -padx 3
            #--- Cree un frame pour mettre l'acitvation du resolver Sesame et pour le choix du serveur
            frame $This.frame3.eph.cb.sesame -borderwidth 0
            pack $This.frame3.eph.cb.sesame \
               -in $This.frame3.eph.cb -side top -anchor w
              #--- Creation du checkbutton pour activer ou non la resolution par Sesame
              checkbutton $This.frame3.eph.cb.sesame.but_sesame -text "$caption(resolver,but_sesame)" \
                 -variable voconf(but_sesame)
              pack $This.frame3.eph.cb.sesame.but_sesame \
                 -in $This.frame3.eph.cb.sesame -side left -anchor c -padx 3
              #--- Creation du bouton menu pour choisir le serveur de Sesame
              label $This.frame3.eph.cb.sesame.lab -text "@" -borderwidth 0 -relief flat
              pack $This.frame3.eph.cb.sesame.lab \
                 -in $This.frame3.eph.cb.sesame -side left -anchor c
              menubutton $This.frame3.eph.cb.sesame.but_server \
                 -textvariable voconf(sesame_server) -menu $This.frame3.eph.cb.sesame.but_server.m \
                 -borderwidth 1 -relief raised
              pack $This.frame3.eph.cb.sesame.but_server \
                 -in $This.frame3.eph.cb.sesame -side left -anchor c
                #--- Menu server
                menu $This.frame3.eph.cb.sesame.but_server.m
                $This.frame3.eph.cb.sesame.but_server.m add radiobutton -label "CDS" -variable voconf(sesame_server)
                $This.frame3.eph.cb.sesame.but_server.m add radiobutton -label "ADAC" -variable voconf(sesame_server)
 #               $This.frame3.eph.cb.sesame.but_server.m add radiobutton -label "ADS" -variable voconf(sesame_server)
 #               $This.frame3.eph.cb.sesame.but_server.m add radiobutton -label "CADC" -variable voconf(sesame_server)

      #--- Cree un frame pour l'affichage du resultat de la recherche
      frame $This.frame5
      pack $This.frame5 -expand yes -fill both -padx 3 -pady 6

         #--- Cree un acsenseur vertical
         scrollbar $This.frame5.vsb -orient vertical \
            -command { $::skybot_Resolver::This.frame5.lst1 yview } -takefocus 1 -borderwidth 1
         pack $This.frame5.vsb \
            -in $This.frame5 -side right -fill y

         #--- Cree un acsenseur horizontal
         scrollbar $This.frame5.hsb -orient horizontal \
            -command { $::skybot_Resolver::This.frame5.lst1 xview } -takefocus 1 -borderwidth 1
         pack $This.frame5.hsb \
            -in $This.frame5 -side bottom -fill x

         #--- Creation de la table
         ::skybot_Resolver::createTbl $This.frame5
         pack $This.frame5.tbl \
            -in $This.frame5 -expand yes -fill both

      #--- Cree un frame pour les parametres du FOV
      frame $This.frame4 -borderwidth 0

        #--- Cree un label pour le titre des param. du FOV
        label $This.frame4.titre -text "$caption(resolver,titre_fov)" \
          -borderwidth 0 -relief flat
        pack $This.frame4.titre \
          -in $This.frame4 -side top -anchor w \
          -padx 3 -pady 3

        #--- Cree un frame pour la saisie des parametres du FOV
        set fov [frame $This.frame4.fov -borderwidth 1 -relief solid]
        pack $fov \
          -in $This.frame4 -anchor w -side top -expand 0 -fill x -padx 10

          #--- Cree un frame pour les labels
          frame $fov.lab -borderwidth 0
          pack $fov.lab -in $fov -anchor w -side left
            #--- Cree le label
            label $fov.lab.dim -text "$caption(resolver,taille_champ)" \
               -borderwidth 0 -relief flat
            pack $fov.lab.dim \
               -in $fov.lab -side top -anchor w -padx 3 -pady 3
            #--- Cree le label
            label $fov.lab.filter -text "$caption(resolver,filter)" \
               -borderwidth 0 -relief flat
            pack $fov.lab.filter \
               -in $fov.lab -side top -anchor w -padx 3 -pady 3

          #--- Cree un frame pour la saisie des param. du FOV
          frame $fov.param -borderwidth 0
          pack $fov.param \
             -in $fov -anchor w -side left -expand 0 -fill x
            #--- Cree un frame pour la saisie des dimension du FOV
            frame $fov.param.dim -borderwidth 0
            pack $fov.param.dim -in $fov.param -anchor w -side top -padx 3 -pady 3
              #--- Cree une ligne d'entree
              entry $fov.param.dim.x \
                 -textvariable voconf(taille_champ_x) \
                 -borderwidth 1 -relief groove -width 6 -justify center
              pack $fov.param.dim.x \
                 -in $fov.param.dim -side left
              #--- Cree un label
              label $fov.param.dim.f1 -text "x" \
                 -borderwidth 0 -relief flat
              pack $fov.param.dim.f1 \
                 -in $fov.param.dim -side left
              #--- Cree une ligne d'entree
              entry $fov.param.dim.y \
                 -textvariable voconf(taille_champ_y) \
                 -borderwidth 1 -relief groove -width 6 -justify center
              pack $fov.param.dim.y \
                 -in $fov.param.dim -side left
              #--- Cree un label
              label $fov.param.dim.f2 -text " arcsec" \
                 -borderwidth 0 -relief flat
              pack $fov.param.dim.f2 \
                 -in $fov.param.dim -side left
            #--- Cree un frame pour la saisie de la valeur du filtre
            frame $fov.param.filter -borderwidth 0
            pack $fov.param.filter \
               -in $fov.param -anchor w -side top -padx 3 -pady 3
              #--- Cree une ligne d'entree pour la saisie du param. filter
              spinbox $fov.param.filter.in \
                  -textvariable voconf(filter) \
                  -from 0 -to 1000 -increment 10 -width 6 -borderwidth 1 -relief groove
              pack $fov.param.filter.in \
                 -in $fov.param.filter -anchor w -side left
              #--- Cree un label
              label $fov.param.filter.f -text " arcsec" \
                 -borderwidth 0 -relief flat
              pack $fov.param.filter.f \
                 -in $fov.param.filter -side left

          #--- Cree un frame pour une info sur les param. du FOV
          frame $fov.help -borderwidth 0
          pack $fov.help \
             -in $fov -anchor w -side left
            #--- Cree un bouton pour une info sur la dimension du FOV
            button $fov.help.dim -state active -text "$caption(resolver,info)" \
               -borderwidth 0 -relief flat -anchor c \
               -command { ::skybot_Resolver::GetInfo "dim_fov" }
            pack $fov.help.dim \
              -in $fov.help -side top -anchor c \
              -padx 3 -pady 3
            #--- Cree un bouton pour une info sur la dimension du FOV
            button $fov.help.filter -state active -text "$caption(resolver,info)" \
               -borderwidth 0 -relief flat -anchor c \
               -command { ::skybot_Resolver::GetInfo "filter" }
            pack $fov.help.filter \
              -in $fov.help -side top -anchor c \
              -padx 3 -pady 3

      #--- Cree un frame pour y mettre les boutons Recherche, Aide, Fermer
      frame $This.frame6 -borderwidth 0
      pack $This.frame6 -in $This -anchor s -side bottom -expand 0 -fill x

        #--- Creation du bouton
        button $This.frame6.but_recherche \
           -text "$caption(resolver,recherche)" -borderwidth 2 \
           -command { ::skybot_Resolver::cmdSearchResolver }
        pack $This.frame6.but_recherche \
           -in $This.frame6 -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton de recherche des caracteristiques de l'objet
        button $This.frame6.but_caract -relief raised -state disabled \
           -text "$caption(resolver,caract_objet)" -borderwidth 2 \
           -command { if { $voconf(type) == "SIMBAD" } {
                         set goto_url [ concat $myurl(simbad,CDS)[string trim $voconf(name)] ]
                      } else {
                         set goto_url [ concat $myurl(astorb,CDS)[string trim $voconf(name)] ]
                      }
                      ::audace::Lance_Site_htm $goto_url
                    }
        pack $This.frame6.but_caract \
           -in $This.frame6 -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton visualisation dans Aladin
        button $This.frame6.but_aladin -relief raised -state disabled \
           -text "$caption(resolver,view_aladin)" -borderwidth 2 \
           -command { set radius [ expr $voconf(taille_champ_x)/60.0 ]
                      if { $voconf(taille_champ_y) != "" } {
                         set radius [ expr sqrt($voconf(taille_champ_x)*$voconf(taille_champ_x)+$voconf(taille_champ_y)*$voconf(taille_champ_y))/60.0 ]
                      }
                      vo_launch_aladin [ concat "\"$voconf(ad_objet) $voconf(dec_objet)\"" ] $radius "DSS2" "USNO2" [ mc_date2jd $voconf(date_ephemerides) ]
                    }
        pack $This.frame6.but_aladin \
           -in $This.frame6 -side left -anchor w \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton fermer
        button $This.frame6.but_fermer \
           -text "$caption(resolver,fermer)" -borderwidth 2 \
           -command { ::skybot_Resolver::fermer }
        pack $This.frame6.but_fermer \
           -in $This.frame6 -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

        #--- Creation du bouton aide
        button $This.frame6.but_aide \
           -text "$caption(resolver,aide)" -borderwidth 2 \
           -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] \
              [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] field_3 }
        pack $This.frame6.but_aide \
           -in $This.frame6 -side right -anchor e \
           -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

      #--- Desactivation du bouton de Recherche
      $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state disabled

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Choix par defaut du curseur
      $This configure -cursor arrow

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   ## @brief Affiche la table avec ses scrollbars dans un frame
   # @param frame chemin de la fenetre parent contenant la table
   #
   proc createTbl { frame } {
      variable This
      global audace
      global caption
      global voconf

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl
      set menu $frame.menu

      #--- Table des objets
      set titre_colonnes { Num Name RA(h) DE(deg) Class Mv Err(arcsec) d(arcsec) dRA(arcsec/h) dDEC(arcsec/h) Dg(ua) Dh(ua) }
      tablelist::tablelist $tbl \
         -labelcommand ::skybot_Resolver::cmdSortColumn \
         -xscrollcommand [ list $frame.hsb set ] -yscrollcommand [ list $frame.vsb set ] \
         -selectmode extended \
         -activestyle none

      #--- Scrollbars verticale et horizontale
      $frame.vsb configure -command [ list $tbl yview ]
      $frame.hsb configure -command [ list $tbl xview ]

      #--- Menu pop-up associe a la table
      menu $popupTbl -tearoff no
      #--- Acces au mode Goto
      $popupTbl add command -label $caption(resolver,goto) -state disabled
      #--- Separateur
      $popupTbl add separator
      #--- Acces a l'aide
      $popupTbl add command -label $caption(resolver,aide) \
         -command { ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::vo_tools::getPluginType ] ] \
            [ ::vo_tools::getPluginDirectory ] [ ::vo_tools::getPluginHelp ] field_3 }

      #--- Gestion des evenements
      bind [$tbl bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
      bind $tbl <<ListboxSelect>>          [ list ::skybot_Resolver::cmdButton1Click $This.frame5 ]
   }

   ## @brief Trie les lignes par ordre alphabetique de la colonne (est appele quand on clique sur le titre de la colonne)
   # @param tbl chemin de la table a trier
   # @param col colonne triee
   #
   proc cmdSortColumn { tbl col } {
      tablelist::sortByColumn $tbl $col
   }

   ## @brief Charge l'item selectionne avec la souris dans la liste
   # @param frame chemin de la fenetre parent contenant la table
   #
   proc cmdButton1Click { frame } {
      variable This
      global caption
      global voconf
      global ok

      #--- Quelques raccourcis utiles
      set tbl $frame.tbl
      set popupTbl $frame.popupTbl

      #--- Selection d'une ligne
      set selection [ $tbl curselection ]

      #--- Retourne immediatemment si aucun item selectionne
      if { "$selection" == "" } { return }

      #--- Nom de l'objet selectionne
      set num_line [ lindex $selection 0 ]
      set erreur [ catch { lindex [ $tbl cellconfigure $num_line,1 -text ] 4 } voconf(name) ]
      if { $erreur == "1" } {
         set voconf(name) ""
         #--- Gestion des boutons
         $::skybot_Resolver::This.frame6.but_caract configure -state disabled
         $::skybot_Resolver::This.frame6.but_aladin configure -state disabled
         #--- Desactivation de l'acces au mode Goto
         $popupTbl entryconfigure $caption(resolver,goto) -state disabled
      } else {
         #--- Gestion des boutons
         $::skybot_Resolver::This.frame6.but_caract configure -state normal
         $::skybot_Resolver::This.frame6.but_aladin configure -state normal
         #--- Affectation du type de l'objet
         if { $ok(sesame) == "1" && $num_line == 0 } {
            set voconf(type) "SIMBAD"
         } else {
            set voconf(type) [ lindex [ $tbl cellconfigure $num_line,4 -text ] 4 ]
         }
         #--- Activation de l'acces au mode Goto
         $popupTbl entryconfigure $caption(resolver,goto) -state normal \
            -command { set newVisu [ ::skybot_Resolver::afficheOutilTlscp ]
                       ::cataGoto::gestionCata $newVisu $caption(resolver,asteroide)
                       set ::catalogue(asteroide_choisi) $voconf(name)
                     }
      }
   }

   ## @brief Affiche l'outil Telescope de Audela
   # @return numero de la visu de l'outil telescope
   #
   proc afficheOutilTlscp { } {
      global audace panneau

      #--- Je verifie qu'il y a un telescope connecte
      if { [ ::tel::list ] == "" } {
         ::confTel::run
      }

      #--- Je verifie si l'outil Telescope est deja actif dans une visu
      foreach visuNo [ ::visu::list ] {
         if { [ ::confVisu::getTool $visuNo ] == "tlscp" } {
            return $visuNo
         }
      }

      #--- Sinon j'affiche l'outil Telescope dans newVisu
      set liste ""
      foreach m [array names panneau menu_name,*] {
         lappend liste [list "$panneau($m) " $m]
      }
      foreach m [lsort $liste] {
         set m [lindex $m 1]
         if { $m == "menu_name,tlscp" } {
            if { [scan "$m" "menu_name,%s" ns] == "1" } {
               #--- Creation de la visu pour l'outil Telescope
               set newVisu [ ::confVisu::create ]
               #--- Lancement automatique de l'outil Telescope
               ::confVisu::selectTool $newVisu ::$ns
            }
         }
      }
      return $newVisu
   }

   ## @brief Definit la largeur, la traduction du titre et la justification des colonnes
   # @param column_name nom de la colonne a formater
   # @return string le format de la colonne
   #
   proc cmdFormatColumn { column_name } {
      variable column_format

      #--- Suppression des caracteres "(" et ")"
      regsub -all {[\(]} $column_name "" column_name
      regsub -all {[\)]} $column_name "" column_name
      #---
      set a [ array get column_format $column_name ]
      if { [ llength $a ] == "0" } {
         set format [ list 10 $column_name left ]
      } else {
         set format [ lindex $a 1 ]
      }
      return $format
   }

   ## @brief Verifie que la date saisie appartient a la periode reconnue par SkyBoT
   # @param date_calcul date a verifier
   # @param btn_rech    chemin du bouton a configurer
   #
   proc valideDate { date_calcul btn_rech } {
      variable This
      global caption
      global voconf

      #--- Interrogation de la base de donnees
      set erreur [ catch { vo_skybotstatus text [mc_date2iso8601 $date_calcul]} statut ]
      if { $erreur != "0"} {
         return $caption(resolver,msg_notavailable)
      } else {
         set flag [lindex $statut 1]
#         set ticket [lindex $statut 3]
#         set statutTranche [lindex [split [lindex $statut 5] ";"] 1]
         #--- ok, pas d'erreur et date reconnue
         if { $flag == "1" } {
            return 0
         #--- ooopps, date non couverte par Skybot
         } else {
            set voconf(date_ephemerides) ""
            focus $This.frame2.param.input.epoch
            $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
            if { $btn_rech } { $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal }
            $::skybot_Resolver::This configure -cursor arrow
            return $caption(resolver,msg_date_unk)
         }
      }

   }

   ## @brief Effectue la resolution du nom de l'objet
   #
   proc cmdResolver { } {
      variable This
      global audace
      global caption
      global color
      global voconf
      global myurl
      global ok

      #--- Statut de la commande
      $::skybot_Resolver::This configure -cursor watch

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief groove -state disabled
      $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state disabled
      $::skybot_Resolver::This.frame6.but_caract configure -relief raised -state disabled
      $::skybot_Resolver::This.frame6.but_aladin configure -relief raised -state disabled

      #--- Traitement de la presence du nom de l'objet
      if { $voconf(nom_objet) == "" } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message "$caption(resolver,msg_notarget)"
         focus $This.frame1.param.lab
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Tests sur l'existence d'une date
      if { $voconf(date_ephemerides) == "" } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_noepoch)
         set voconf(date_ephemerides) ""
         focus $This.frame2.param.input.epoch
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Conversion de la date en JD
      set date_calcul [ mc_date2jd $voconf(date_ephemerides) ]

      #--- Verifie que la date JD est couverte par le service Skybot (si demande)
      if { $voconf(but_skybot) } {
         set erreur [ valideDate $date_calcul 0 ]
         if { $erreur != "0" } {
            tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $erreur
            $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
            $::skybot_Resolver::This configure -cursor arrow
            return
         }
      }

      #--- Traitement du nom des objets
      set voconf(nom_objet) [ suppr_accents $voconf(nom_objet) ]

      #--- Invocation du web service Sesame@$voconf(sesame_server)
      set ok(sesame) 0
      if { $voconf(but_sesame) } {
         set erreur [ catch { vo_sesame $voconf(nom_objet) "xi" $voconf(sesame_server) } response ]
         if { $erreur == "0" } {
            set rep [ Extract_Sesame_Data $response ]
            if { $rep != "1" } {
               set ok(sesame) 1
               set voconf(sesame) $rep
               set voconf(type) "SIMBAD"
            } else {
               set ok(sesame) 2
               set voconf(sesame) [ concat "SESAME -> The celestial object '$voconf(nom_objet)' was not resolved by Sesame@$voconf(sesame_server)" ]
               set voconf(type) "?"
            }
         } else {
            set ok(sesame) 3
            set voconf(sesame) [concat "SESAME -> $erreur"]
            set voconf(type) "?"
         }
      }

      #--- Invocation du web service skybotResolver
      set ok(skybot) 0
      if { $voconf(but_skybot) } {
         set erreur [ catch { vo_skybotresolver $date_calcul $voconf(nom_objet) text basic $voconf(iau_code_obs) } voconf(skybot) ]
         if { $erreur == "0" } {
            if { [ lindex $voconf(skybot) 0 ] == "no" } {
               set ok(skybot) 2
               set voconf(skybot)  [ concat "SKYBOTResolver -> The solar system object '$voconf(nom_objet)' was not resolved by SkyBoT" ]
               set voconf(type) "?"
            } else {
               set ok(skybot) 1
               set voconf(type) "OSS"
            }
         } else {
            set ok(skybot) 3
            set voconf(skybot) [concat "SKYBOTResolver -> Error: $erreur : $voconf(skybot)"]
            set voconf(type) "?"
         }
      }

      #--- Gestion des erreurs
      if { $ok(sesame) == "1" || $ok(skybot) == "1" } {

         #--- ok, pas d'erreur, au moins une reponse
         set erreur 0
         if { $ok(sesame) == "1" } { set voconf(liste) $voconf(sesame) }
         if { $ok(skybot) == "1" } { set voconf(liste) $voconf(skybot) }

      } else {

         #--- pas ok, erreur ou non reponse ?
         if { $ok(sesame) == "0" && $ok(skybot) == "0" } {
            #--- aucun des resolvers n'a ete invoque
            set erreur -1
            set voconf(liste) $caption(resolver,msg_noresolver)
         } else {
            #--- au moins un resolver a ete invoque mais:
            if { $ok(sesame) == "2" && $ok(skybot) == "2" } {
               #--- les 2 resolvers n'ont pas trouve
               set erreur -2
               set voconf(liste) [ concat "$caption(resolver,msg_objnotfound)$voconf(sesame_server)" ]
            } else {
               #--- l'un des resolver invoque n'a rien trouve ou a genere une erreur
               set erreur -3
               if { $ok(sesame) == "2" || $ok(sesame) == "3" } { set voconf(liste) $voconf(sesame) }
               if { $ok(skybot) == "2" || $ok(skybot) == "3" } { set voconf(liste) $voconf(skybot) }
            }
         }
      }

      #--- RAZ de la liste
      $::skybot_Resolver::This.frame5.tbl delete 0 end
      if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
         $::skybot_Resolver::This.frame5.tbl deletecolumns 0 end
      }

      #--- Affichage des resultats
      if { $erreur == "0" } {
         #--- Les resultats se presentent sous la forme d'une chaine de caractere, chaque ligne
         #--- etant separees par un ';' et chaque donnees par un '|'
         set voconf(liste) [split $voconf(liste) ";"]

         #--- Extraction, suppression des virgules et creation des colonnes du tableau
         set liste_titres [ lindex $voconf(liste) 0 ]
         regsub -all "," $liste_titres "" liste_titres
         for { set i 1 } { $i <= [ expr [ llength $liste_titres ] - 1 ] } { incr i } {
            set format [ ::skybot_Resolver::cmdFormatColumn [ lindex $liste_titres $i ] ]
            $::skybot_Resolver::This.frame5.tbl insertcolumns end [ lindex $format 0 ] [ lindex $format 1 ] [ lindex $format 2 ]
         }
         #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
         if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
            $::skybot_Resolver::This.frame5.tbl columnconfigure 1 -sortmode dictionary
         }
         #--- Extraction du resultat
         #--- Attention : si la requete provient de skybot les champs
         # sont au format hms ou dms et si la requete provient de sesame
         # ils sont au format h ou deg.
         set vo_objet(1) [ split [ lindex $voconf(liste) 1 ] "|" ]
         #--- Initialisation de RA et DEC pour la Recherche dans le FOV
         set voconf(ad_objet) [ expr 15.0 * [mc_angle2deg [ lindex $vo_objet(1) 2 ]] ]
         set voconf(dec_objet) [mc_angle2deg [ lindex $vo_objet(1) 3 ]]
         #--- Mise en forme de l'ascension droite
         set ad [ expr 15.0 * [mc_angle2deg [ lindex $vo_objet(1) 2 ] ]]
         #--- Mise en forme de la declinaison
         set dec [mc_angle2deg [ lindex $vo_objet(1) 3 ]]
         #--- Insertion des objets dans la table
         $::skybot_Resolver::This.frame5.tbl insert end [ string trim $vo_objet(1) ]
         #---
         if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
            #--- Trie par ordre alphabetique de la premiere colonne
            ::skybot_Resolver::cmdSortColumn $::skybot_Resolver::This.frame5.tbl 1
            #--- Mise en forme des resultats
            for { set i 0 } { $i <= [ expr [ llength $voconf(liste) ] - 2 ] } { incr i } {
               #--- Les noms des objets sont en bleu
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,1 -fg $color(blue)
               #--- Mise en forme de l'ascension droite
               set ad [ mc_angle2deg [ $::skybot_Resolver::This.frame5.tbl cellcget $i,2 -text ] ]
               set ad [ expr $ad * 15.0 ]
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,2 -text [ mc_angle2hms $ad 360 zero 2 auto string ]
               #--- Mise en forme de la declinaison
               set dec [ mc_angle2deg [ $::skybot_Resolver::This.frame5.tbl cellcget $i,3 -text ] ]
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,3 -text [ mc_angle2dms $dec 90 zero 2 + string ]
            }
         }
         #--- Pack les frames Parametres FOV et bouton lancer recherche
         pack $This.frame4 -in $This -before $This.frame6 -anchor s -side top -expand 0 -fill x -pady 6
         #--- Active le bouton de Recherche
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal

      } else {

         #--- cas ou les 2 resolvers n'ont pas trouve l'objet ou cas d'erreur
         $::skybot_Resolver::This.frame5.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
         $::skybot_Resolver::This.frame5.tbl insert end [ list $voconf(liste) ]
         $::skybot_Resolver::This.frame5.tbl cellconfigure 0,0 -fg $color(red)
         set voconf(ad_objet)        ""
         set voconf(dec_objet)       ""

      }

      #--- Statut de la commande
      $::skybot_Resolver::This configure -cursor arrow
      #--- Gestion des boutons
      $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   ## @brief Recherche des objets environnants dans le champ de vue
   #
   proc cmdSearchResolver { } {
      variable This
      global audace
      global caption
      global color
      global voconf
      global ok

      #--- Statut de la commande
      $::skybot_Resolver::This configure -cursor watch

      #--- Gestion des boutons
      $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state disabled
      $::skybot_Resolver::This.frame6.but_recherche configure -relief groove -state disabled
      $::skybot_Resolver::This.frame6.but_caract configure -relief raised -state disabled
      $::skybot_Resolver::This.frame6.but_aladin configure -relief raised -state disabled

      #--- Tests pour les donnees indispensables
      if { ( $voconf(ad_objet) == "" ) || ( $voconf(dec_objet) == "" ) } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_nodata)
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Tests sur l'ascension droite
      if { ( [ string is double -strict $voconf(ad_objet) ] == "0" ) || \
           ( $voconf(ad_objet) == "" ) || ( $voconf(ad_objet) < "0.0" ) || \
           ( $voconf(ad_objet) > "360.0" ) } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_reel_ad)
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Tests sur la declinaison
      if { ( [ string is double -strict $voconf(dec_objet) ] == "0" ) \
            || ( $voconf(dec_objet) == "" ) || ( $voconf(dec_objet) < "-90.0" ) \
            || ( $voconf(dec_objet) > "90.0" ) } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_reel_dec)
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Tests sur les dimensions du champ
      if { ( [ string is double -strict $voconf(taille_champ_x) ] == "0" ) || ( $voconf(taille_champ_x) == "" ) || \
           ( $voconf(taille_champ_x) <= "0" ) || ( $voconf(taille_champ_x) > "36000.0" ) } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_reel_fov)
         set voconf(taille_champ_x) ""
         focus $This.frame4.fov.param.dim.x
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }
      if { $voconf(taille_champ_y) != "" && ( ( [ string is double -strict $voconf(taille_champ_y) ] == "0" ) || \
           ( $voconf(taille_champ_y) <= "0" ) || ( $voconf(taille_champ_y) > "36000.0" ) ) } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_reel_fov)
         set voconf(taille_champ_y) ""
         focus $This.frame4.fov.param.dim.y
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }
      set voconf(taille_champ) $voconf(taille_champ_x)
      if { $voconf(taille_champ_y) != "" } {
        set voconf(taille_champ) [ concat $voconf(taille_champ_x)x$voconf(taille_champ_y) ]
      }

      #--- Tests sur l'existence d'une date
      if { $voconf(date_ephemerides) == "" } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $caption(resolver,msg_noepoch)
         set voconf(date_ephemerides) ""
         focus $This.frame2.param.input.epoch
         $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Conversion de la date en JD
      set date_calcul [ mc_date2jd $voconf(date_ephemerides) ]
      set erreur [ valideDate $date_calcul 1 ]
      if { $erreur != "0" } {
         tk_messageBox -title $caption(resolver,msg_erreur) -type ok -message $erreur
         $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
         $::skybot_Resolver::This configure -cursor arrow
         return
      }

      #--- Invocation du web service skybot
      set ok(skybot) 0
      set erreur [ catch { vo_skybotconesearch $date_calcul $voconf(ad_objet) $voconf(dec_objet) $voconf(taille_champ) \
                                     text basic $voconf(iau_code_obs) $voconf(filter) } voconf(skybot) ]

      if { $erreur == "0" } {
         if { [ lindex $voconf(skybot) 0 ] == "no" } {
            set ok(skybot) 2
            set voconf(skybot) $caption(search,msg_no_objet)
         } else {
            set ok(skybot) 1
         }
      } else {
         set ok(skybot) 3
         set voconf(skybot) [concat "SKYBOT -> $voconf(skybot)"]
      }

      #--- Gestion des erreurs
      set erreur 0
      if { $ok(skybot) != "1" } { set erreur -1 }
      set voconf(liste) $voconf(skybot)

      #--- RAZ de la liste
      $::skybot_Resolver::This.frame5.tbl delete 0 end
      if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
         $::skybot_Resolver::This.frame5.tbl deletecolumns 0 end
      }

      #--- Affichage des resultats
      if { $erreur == "0" } {
         #--- Les resultats se presentent sous la forme d'une chaine de caractere, chaque ligne
         #--- etant separees par un ';' et chaque donnees par un '|'
         set voconf(liste) [ lrange [ split $voconf(liste) ";" ] 0 end-1 ]

         #--- Extraction, suppression des virgules et creation des colonnes du tableau
         set liste_titres [ lindex $voconf(liste) 0 ]
         regsub -all "," $liste_titres "" liste_titres
         for { set i 1 } { $i <= [ expr [ llength $liste_titres ] - 1 ] } { incr i } {
            set format [ ::skybot_Resolver::cmdFormatColumn [ lindex $liste_titres $i ] ]
            $::skybot_Resolver::This.frame5.tbl insertcolumns end [ lindex $format 0 ] [ lindex $format 1 ] [ lindex $format 2 ]
         }
         #--- Classement des objets par ordre alphabetique sans tenir compte des majuscules/minuscules
         if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
            $::skybot_Resolver::This.frame5.tbl columnconfigure 1 -sortmode dictionary
         }
         #--- Si l'objet a ete resolu par Sesame, on l'ajoute dans la table
         if { $ok(sesame) == "1" } {
            set liste_sesame [ split $voconf(sesame) ";" ]
            set obj_sesame [ split [ lindex $liste_sesame 1 ] "|" ]
            #--- Mise en forme de l'ascension droite
            set ad [ expr 15.0 * [ lindex $obj_sesame 2 ] ]
            #--- Mise en forme de la declinaison
            set dec [ lindex $obj_sesame 3 ]
            #--- Insertion de l'objet dans la table
            $::skybot_Resolver::This.frame5.tbl insert end $obj_sesame
            #--- Le nom de l'objet sesame est en rouge
            $::skybot_Resolver::This.frame5.tbl cellconfigure 0,1 -fg $color(red)
            #--- Mise en forme de l'ascension droite
            set ad [ $::skybot_Resolver::This.frame5.tbl cellcget 0,2 -text ]
            set ad [ expr $ad * 15.0 ]
            $::skybot_Resolver::This.frame5.tbl cellconfigure 0,2 -text [ mc_angle2hms $ad 360 zero 2 auto string ]
            #--- Mise en forme de la declinaison
            set dec [ $::skybot_Resolver::This.frame5.tbl cellcget 0,3 -text ]
            $::skybot_Resolver::This.frame5.tbl cellconfigure 0,3 -text [ mc_angle2dms $dec 90 zero 2 + string ]
         }
         #--- Extraction du resultat
         for { set i 1 } { $i <= [ expr [ llength $voconf(liste) ] - 1 ] } { incr i } {
            set vo_objet($i) [ split [ lindex $voconf(liste) $i ] "|" ]
            #--- Mise en forme de l'ascension droite
            set ad [ expr 15.0 * [ lindex $vo_objet($i) 2 ] ]
            #--- Mise en forme de la declinaison
            set dec [ lindex $vo_objet($i) 3 ]
            #--- Insertion des objets dans la table
            $::skybot_Resolver::This.frame5.tbl insert end $vo_objet($i)
         }
         #--- Si un objet a ete resolu par Sesame et affiche, on commence a 1
         set idx_0 0
         if { $ok(sesame) == "1" } { set idx_0 1 }
         #--- Mise en forme des resultats
         if { [ $::skybot_Resolver::This.frame5.tbl columncount ] != "0" } {
            for { set i $idx_0 } { $i <= [ expr [ llength $voconf(liste) ] - 2+$idx_0 ] } { incr i } {
               #--- Les noms des objets sont en bleu
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,1 -fg $color(blue)
               #--- Mise en forme de l'ascension droite
               set ad [ $::skybot_Resolver::This.frame5.tbl cellcget $i,2 -text ]
               set ad [ expr $ad * 15.0 ]
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,2 -text [ mc_angle2hms $ad 360 zero 2 auto string ]
               #--- Mise en forme de la declinaison
               set dec [ $::skybot_Resolver::This.frame5.tbl cellcget $i,3 -text ]
               $::skybot_Resolver::This.frame5.tbl cellconfigure $i,3 -text [ mc_angle2dms $dec 90 zero 2 + string ]
            }
            #--- Trie par ordre des distances a la cible
            ::skybot_Resolver::cmdSortColumn $::skybot_Resolver::This.frame5.tbl 7
            #--- Bilan des objets trouves dans le FOV
            if { $i > "1" } {
               ::console::disp "$caption(resolver,msg_nbre_objets) $i \n\n"
            } else {
               ::console::disp "$caption(resolver,msg_nbre_objet) $i \n\n"
            }
         }

      } else {

         #--- cas sans reponse ou cas d'erreur
         $::skybot_Resolver::This.frame5.tbl insertcolumns end 100 "$caption(resolver,msg_erreur)" left
         $::skybot_Resolver::This.frame5.tbl insert end [ list $voconf(liste) ]
         $::skybot_Resolver::This.frame5.tbl cellconfigure 0,0 -fg $color(red)

      }

      #--- Statut de la commande
      $::skybot_Resolver::This configure -cursor arrow
      #--- Gestion des boutons
      $::skybot_Resolver::This.frame3.eph.but_calcul configure -relief raised -state normal
      $::skybot_Resolver::This.frame6.but_recherche configure -relief raised -state normal
      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

}

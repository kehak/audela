#
# Fichier : ohp.tcl
# Auteur : Alain KLOTZ
# Lancement du script : source audace/scripts/ohp.tcl
# Mise à jour $Id: ohp.tcl 10210 2013-09-14 19:43:35Z robertdelmas $
#

namespace eval ::ohp {

   proc run { {positionxy 20+20} } {
      global conf
      global audace
      global caption
      global color

      if { [ string length [ info commands .ohp.* ] ] != "0" } {
         destroy .ohp
      }

      set caption(ohp,titre)                            "Traitement et analyse d'images pour l'Observatoire de Haute-Provence"
      set caption(ohp,titre2)                           "OHP image processing"
      set caption(ohp,namerawfits)                      "Fichiers images avant bifsconv"
      set caption(ohp,nameraw)                          "Fichiers images brutes"
      set caption(ohp,telescope)                        "Télescope"
      set caption(ohp,ra)                               "R.A. (seulement pour astrométrie t80)"
      set caption(ohp,dec)                              "DEC. (seulement pour astrométrie t80)"
      set caption(ohp,pathcat)                          "Dossier catalogue"
      set caption(ohp,dark)                             "Fichier image dark"
      set caption(ohp,flat)                             "Fichier image flat"
      set caption(ohp,box)                              "Boîte registerwin"
      set caption(ohp,namein)                           "Nom d'entrée spectro"
      set caption(ohp,nameout)                          "Nom de sortie Spectro"
      set caption(ohp,load_button)                      "Load conf."
      set caption(ohp,save_button)                      "Save conf."
      set caption(ohp,go_button)                        "GO"
      set caption(ohp,files_button)                     "See files"
      set caption(ohp,purge_button)                     "Delete files"
      set caption(ohp,getbox_button)                    "Get box coord."
      set caption(ohp,folder)                           "Répertoire"

      set caption(ohp,save)                             "Enregistre la configuration actuelle"
      set caption(ohp,load)                             "Charge une configuration"
      set caption(ohp,rawfiles)                         "Fichiers bruts"
      set caption(ohp,otherfiles)                       "Autres fichiers"

      set caption(ohp,methode,bifsconv)                 "bifsconv : format FITS (*.fits -> *-#.fit)"
      set caption(ohp,methode,convert)                  "convert : entete FITS (*-#.fit -> *-#.fit)"
      set caption(ohp,methode,copy)                     "copy : renome (*-#.fit -> tempa#.fit)"
      set caption(ohp,methode,makedark)                 "makedark : synthèse superdark (*.fit -> .fit)"
      set caption(ohp,methode,makeflat)                 "makeflat : synthèse superflat (*.fit -> .fit)"
      set caption(ohp,methode,cordark)                  "cordark : pretraitement (tempa#.fit -> tempi#.fit)"
      set caption(ohp,methode,corflat)                  "corflat : pretraitement (tempi#.fit -> tempj#.fit)"
      set caption(ohp,methode,noffset)                  "noffset : fond de ciel (tempj#.fit -> tempj#.fit)"
      set caption(ohp,methode,cosmetic)                 "cosmetic : cosmiques (tempj#.fit -> tempj#.fit)"
      set caption(ohp,methode,astrometry)               "astrometry : entete FITS (tempj#.fit -> tempj#.fit)"
      set caption(ohp,methode,register)                 "register : recentrage auto (tempj#.fit -> tempk#.fit)"
      set caption(ohp,methode,registerwin)              "registerwin : recentrage fenêtre (tempj#.fit -> tempk#.fit)"
      set caption(ohp,methode,makeflat_spectro)         "makeflat_spectro : synthèse superflat (*.fit -> .fit)"
      set caption(ohp,methode,pretraite_stack_spectro)  "pretraite_stack_spectro : (tempa#.fit -> tempj.fit)"
      set caption(ohp,methode,pretraite_serie_spectro)  "pretraite_serie_spectro : (tempa#.fit -> tempj#.fit)"
      set caption(ohp,methode,extraction_spectro)       "extraction_spectro : (tempj.fit -> .txt)"
      set caption(ohp,methode,extraction_serie_spectro) "extraction_serie_spectro : (tempj#.fit -> *.txt)"

      # =======================================
      # === Initialisation of the variables
      # === Initialisation des variables
      # =======================================

      #--- Definition of colorohps
      #--- Definition des couleurs
      set audace(ohp,color,backpad)  #F0F0FF
      set audace(ohp,color,backdisp) $color(white)
      set audace(ohp,color,textkey)  $color(blue_pad)
      set audace(ohp,color,textdisp) #FF0000

      set geomohp(larg) 970
      set geomohp(long) 500

      set audace(ohp,configuration) example
      set audace(ohp,telescope)     t80
      set audace(ohp,namerawfits)   p33009f1
      set audace(ohp,nameraw)       frostia-
      set audace(ohp,ra)            00h00m00s
      set audace(ohp,dec)           +00d00m00s
      set audace(ohp,pathcat)       "c:/microcat/"
      set audace(ohp,dark)          "dark90"
      set audace(ohp,flat)          "flatr"
      set audace(ohp,box)           {205 366 295 420}
      set audace(ohp,namein)        "tempj"
      set audace(ohp,nameout)       "atami"
      set audace(ohp,methodes)      ""

      set audace(ohp,font,c10b) [ list {Courier} 10 bold ]

      set audace(ohp,allmethodes) ""
      lappend audace(ohp,allmethodes) "bifsconv"
      lappend audace(ohp,allmethodes) "convert"
      lappend audace(ohp,allmethodes) "copy"
      lappend audace(ohp,allmethodes) "makedark"
      lappend audace(ohp,allmethodes) "makeflat"
      lappend audace(ohp,allmethodes) "cordark"
      lappend audace(ohp,allmethodes) "corflat"
      lappend audace(ohp,allmethodes) "noffset"
      lappend audace(ohp,allmethodes) "cosmetic"
      lappend audace(ohp,allmethodes) "astrometry"
      lappend audace(ohp,allmethodes) "register"
      lappend audace(ohp,allmethodes) "registerwin"
      lappend audace(ohp,allmethodes) "makeflat_spectro"
      lappend audace(ohp,allmethodes) "pretraite_stack_spectro"
      lappend audace(ohp,allmethodes) "pretraite_serie_spectro"
      lappend audace(ohp,allmethodes) "extraction_spectro"
      lappend audace(ohp,allmethodes) "extraction_serie_spectro"

      foreach allmethode $audace(ohp,allmethodes) {
         set k [lsearch -exact $audace(ohp,methodes) $allmethode]
         if {$k>=0} {
            set audace(ohp,methode,$allmethode) 1
         } else {
            set audace(ohp,methode,$allmethode) 0
         }
      }

      # =========================================
      # === Setting the graphic interface
      # === Met en place l'interface graphique
      # =========================================

      #--- Cree la fenetre .ohp de niveau le plus haut
      toplevel .ohp -class Toplevel -bg $audace(ohp,color,backpad)
      wm geometry .ohp $geomohp(larg)x$geomohp(long)+$positionxy
      wm resizable .ohp 0 0
      wm title .ohp $caption(ohp,titre)
      wm protocol .ohp WM_DELETE_WINDOW "::ohp::stop"

      #--- Create the title
      #--- Cree le titre
      label .ohp.title \
         -font [ list {Arial} 16 bold ] -text "$caption(ohp,titre2)" \
         -borderwidth 0 -relief flat -bg $audace(ohp,color,backpad) \
         -fg $audace(ohp,color,textkey)
      pack .ohp.title \
         -in .ohp -fill x -side top

      # --- boutons
      frame .ohp.buttons -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         button .ohp.load_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,load_button)" \
            -command {::ohp::load}
         pack  .ohp.load_button -in .ohp.buttons -side left -fill none -padx 3
         button .ohp.save_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,save_button)" \
            -command {::ohp::save}
         pack  .ohp.save_button -in .ohp.buttons -side left -fill none -padx 3
         button .ohp.go_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,go_button)" \
            -command {::ohp::go}
         pack  .ohp.go_button -in .ohp.buttons -side left -fill none -padx 3
         button .ohp.files_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,files_button)" \
            -command {::ohp::files}
         pack  .ohp.files_button -in .ohp.buttons -side left -fill none -padx 3
         button .ohp.purge_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,purge_button)" \
            -command {::ohp::files 1}
         pack  .ohp.purge_button -in .ohp.buttons -side left -fill none -padx 3
         button .ohp.getbox_button  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,getbox_button)" \
            -command {::ohp::getbox}
         pack  .ohp.getbox_button -in .ohp.buttons -side left -fill none -padx 3
      pack .ohp.buttons -in .ohp -fill x -pady 3 -padx 3 -anchor s -side bottom

      frame .ohp.met -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
      foreach allmethode $audace(ohp,allmethodes) {
         frame .ohp.met.met_${allmethode} -borderwidth 0 -relief flat -bg $audace(ohp,color,backpad)
            label .ohp.met.met_${allmethode}.label  \
               -font $audace(ohp,font,c10b) \
               -text "$caption(ohp,methode,$allmethode) " -bg $audace(ohp,color,backpad) \
               -fg $audace(ohp,color,textkey) -relief flat
            pack  .ohp.met.met_${allmethode}.label -in .ohp.met.met_${allmethode} -side left -fill none
            checkbutton  .ohp.met.met_${allmethode}.checkbutton  \
               -variable audace(ohp,methode,$allmethode) -bg $audace(ohp,color,backdisp) \
               -fg $audace(ohp,color,textdisp) -offvalue 0 -onvalue 1
            pack  .ohp.met.met_${allmethode}.checkbutton -in .ohp.met.met_${allmethode} -side left -fill none
         pack .ohp.met.met_${allmethode} -in .ohp.met -fill none -pady 1 -padx 5 -anchor ne
         #bind .ohp.met.met_${allmethode}.checkbutton <Leave> { ::ohp::parameters  }
      }
      pack .ohp.met -in .ohp -fill y -pady 3 -padx 3 -anchor w -side left

      #--- IMAGES BRUTES .FITS
      frame .ohp.namerawfits -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.namerawfits.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,namerawfits) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.namerawfits.label -in .ohp.namerawfits -side left -fill none
         entry  .ohp.namerawfits.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,namerawfits) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.namerawfits.entry -in .ohp.namerawfits -side left -fill none
      pack .ohp.namerawfits -in .ohp -fill none -pady 1 -padx 12

      #--- IMAGES BRUTES
      frame .ohp.nameraw -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.nameraw.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,nameraw) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.nameraw.label -in .ohp.nameraw -side left -fill none
         entry  .ohp.nameraw.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,nameraw) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.nameraw.entry -in .ohp.nameraw -side left -fill none
      pack .ohp.nameraw -in .ohp -fill none -pady 1 -padx 12

      #--- TELESCOPE
      frame .ohp.telescope -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.telescope.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,telescope) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.telescope.label -in .ohp.telescope -side left -fill none
         entry  .ohp.telescope.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,telescope) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 10
         pack  .ohp.telescope.entry -in .ohp.telescope -side left -fill none
      pack .ohp.telescope -in .ohp -fill none -pady 1 -padx 12

      #--- RA
      frame .ohp.ra -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.ra.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,ra) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.ra.label -in .ohp.ra -side left -fill none
         entry  .ohp.ra.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,ra) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 10
         pack  .ohp.ra.entry -in .ohp.ra -side left -fill none
      pack .ohp.ra -in .ohp -fill none -pady 1 -padx 12

      #--- DEC
      frame .ohp.dec -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.dec.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,dec) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.dec.label -in .ohp.dec -side left -fill none
         entry  .ohp.dec.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,dec) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 10
         pack  .ohp.dec.entry -in .ohp.dec -side left -fill none
      pack .ohp.dec -in .ohp -fill none -pady 1 -padx 12

      #--- dark
      frame .ohp.dark -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.dark.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,dark) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.dark.label -in .ohp.dark -side left -fill none
         entry  .ohp.dark.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,dark) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.dark.entry -in .ohp.dark -side left -fill none
      pack .ohp.dark -in .ohp -fill none -pady 1 -padx 12

      #--- flat
      frame .ohp.flat -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.flat.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,flat) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.flat.label -in .ohp.flat -side left -fill none
         entry  .ohp.flat.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,flat) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.flat.entry -in .ohp.flat -side left -fill none
      pack .ohp.flat -in .ohp -fill none -pady 1 -padx 12

      #--- pathcat
      frame .ohp.pathcat -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.pathcat.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,pathcat) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.pathcat.label -in .ohp.pathcat -side left -fill none
         entry  .ohp.pathcat.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,pathcat) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.pathcat.entry -in .ohp.pathcat -side left -fill none
      pack .ohp.pathcat -in .ohp -fill none -pady 1 -padx 12

      #--- box
      frame .ohp.box -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.box.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,box) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.box.label -in .ohp.box -side left -fill none
         entry  .ohp.box.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,box) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.box.entry -in .ohp.box -side left -fill none
      pack .ohp.box -in .ohp -fill none -pady 1 -padx 12

      #--- namein
      frame .ohp.namein -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.namein.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,namein) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.namein.label -in .ohp.namein -side left -fill none
         entry  .ohp.namein.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,namein) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.namein.entry -in .ohp.namein -side left -fill none
      pack .ohp.namein -in .ohp -fill none -pady 1 -padx 12

      #--- nameout
      frame .ohp.nameout -borderwidth 3 -relief sunken -bg $audace(ohp,color,backpad)
         label .ohp.nameout.label  \
            -font $audace(ohp,font,c10b) \
            -text "$caption(ohp,nameout) " -bg $audace(ohp,color,backpad) \
            -fg $audace(ohp,color,textkey) -relief flat
         pack  .ohp.nameout.label -in .ohp.nameout -side left -fill none
         entry  .ohp.nameout.entry  \
            -font $audace(ohp,font,c10b) \
            -textvariable audace(ohp,nameout) -bg $audace(ohp,color,backdisp) \
            -fg $audace(ohp,color,textdisp) -relief flat -width 20
         pack  .ohp.nameout.entry -in .ohp.nameout -side left -fill none
      pack .ohp.nameout -in .ohp -fill none -pady 1 -padx 12

      ohp::parameters
      while {1==1} {
         vwait audace
         catch {ohp::parameters}
      }

   }

   proc stop { } {
      global conf
      global audace

      if { [ winfo exists .ohp ] } {
         #--- Enregistre la position de la fenetre
         set geom [wm geometry .ohp]
         set deb [expr 1+[string first + $geom ]]
         set fin [string length $geom]
         set conf(ohp,position) "+[string range $geom $deb $fin]"
      }

      #--- Supprime la fenetre
      destroy .ohp

      return
   }

   proc go { } {
      global audace
      # --- initialisations générales
      set path $audace(rep_images)/
      set astromcat MICROCAT
      set namein j
      set nameout $namein
      # --- initialisations particulières
      set namerawfits $audace(ohp,namerawfits)
      set nameraw $audace(ohp,nameraw)
      set telescope $audace(ohp,telescope)
      set ra [mc_angle2deg $audace(ohp,ra)]
      set dec [mc_angle2deg $audace(ohp,dec) 90]
      set pathcat $audace(ohp,pathcat)
      set dark $audace(ohp,dark)
      set flat $audace(ohp,flat)
      set box $audace(ohp,box)
      set namein $audace(ohp,namein)
      set nameout $audace(ohp,nameout)
      # ---- La liste methodes contient, dans l'ordre, les etapes à effectuer.
      set methodes ""
      foreach allmethode $audace(ohp,allmethodes) {
         if {$audace(ohp,methode,$allmethode)==1} {
            lappend methodes "$allmethode"
         }
      }
      # ------------- Grande boucle sur les etapes
      ::console::affiche_resultat "Methodes : $methodes \n"
      foreach methode $methodes {

         ::console::affiche_resultat "Début étape $methode \n"

         # --- convertion *.fit(s) -> *.fit de fichiers
         # --- pour corriger les entetes hors norme FITS
         if {$methode=="bifsconv"} {
            # --- serie A
            set gene "${path}${namerawfits}*.fits"
            set fics [lsort [glob -nocomplain $gene]]
            set n [llength $fics]
            if {$n==0} {
               ::console::affiche_resultat " Pas de fichiers répondant au critère $gene\n"
            } else {
               set k 0
               foreach fic $fics {
                  set extout .fit
                  set dirname [file dirname $fic]
                  set tail [file tail $fic]
                  set shortname [file rootname $tail]
                  set shortname2 $nameraw
                  incr k
                  #set fic2 ${dirname}/${shortname}${extout}
                  set fic2 ${dirname}/${shortname2}${k}${extout}
                  file copy -force $fic $fic2
                  set err [catch {buf$audace(bufNo) load $fic2} msg]
                  ::console::affiche_resultat " err=$err msg=$msg\n"
                  if {$err==0} {
                     ::console::affiche_resultat " ${shortname}.fits -> ${shortname2}${k}.fit (copy)\n"
                  } else {
                     set fic2 ${dirname}/${shortname2}${k}.fits
                     file copy -force $fic $fic2
                     bifsconv $fic2
                     file delete $fic2
                     ::console::affiche_resultat " ${shortname}.fits -> ${shortname2}${k}.fit (bifsconv)\n"
                  }
               }
            }
         }

         # --- convertion *.fit(s) -> *.fit de fichiers
         # --- + completion de l'entete FITS pour l'astrométrie
         if {$methode=="convert"} {
            if {$telescope=="t80"} {
               set fics [glob "${path}${nameraw}*.fit"]
            }
            if {$telescope=="t120"} {
               set fics [glob "${path}${nameraw}*.fit"]
            }
            if {$telescope=="t193"} {
               set fics [glob "${path}${nameraw}*.fit"]
            }
            set extout .fit
            set n [llength $fics]
            set kdeb 0
            set kfin $n
            set pi [expr 4.*atan(1.)]
            for {set k $kdeb} {$k<$kfin} {incr k} {
               set fullname [lindex $fics $k]
               set dirname [file dirname $fullname]
               set tail [file tail $fullname]
               set shortname [file rootname $tail]
               set fullname2 ${dirname}/${shortname}${extout}
               ::console::affiche_resultat " $telescope : $fullname -> $fullname2 \n"
               if {$telescope=="t80"} {
                  buf$audace(bufNo) load $fullname
                  set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
                  set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
                  set pixsize 13.5e-6
                  set foclen 13.0
                  set crota 180.
                  set cdelt [expr $pixsize/$foclen*180./$pi]
                  buf$audace(bufNo) setkwd [list PIXSIZE1 $pixsize float "Pixel dimension" "m"]
                  buf$audace(bufNo) setkwd [list PIXSIZE2 $pixsize float "Pixel dimension" "m"]
                  buf$audace(bufNo) setkwd [list FOCLEN $foclen float "Focal length" "m"]
                  buf$audace(bufNo) setkwd [list RA $ra double "RA J2000.0" "deg"]
                  buf$audace(bufNo) setkwd [list DEC $dec double "DEC J2000.0" "deg"]
                  buf$audace(bufNo) setkwd [list CRVAL1 $ra double "" "deg"]
                  buf$audace(bufNo) setkwd [list CRVAL2 $dec double "" "deg"]
                  buf$audace(bufNo) setkwd [list CDELT1 [expr -$cdelt] double "X scale" "deg/pix"]
                  buf$audace(bufNo) setkwd [list CDELT2 $cdelt double "Y scale" "deg/pix"]
                  buf$audace(bufNo) setkwd [list CROTA2 $crota double "" "deg"]
                  buf$audace(bufNo) save $fullname2
                  buf$audace(bufNo) setkwd [list CRPIX1 [expr $naxis1/2] double "" "pix"]
                  buf$audace(bufNo) setkwd [list CRPIX2 [expr $naxis2/2] double "" "pix"]
               }
               if {$telescope=="t120"} {
                  catch {file copy -force $fullname $fullname2}
                  buf$audace(bufNo) load $fullname2
                  set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
                  set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
                  catch {buf$audace(bufNo) delkwd COMMENT=}
                  set pixsize 24e-6
                  set foclen 7.2
                  set crota 0.
                  set cdelt [expr $pixsize/$foclen*180./$pi]
                  buf$audace(bufNo) setkwd [list PIXSIZE1 $pixsize float "Pixel dimension" "m"]
                  buf$audace(bufNo) setkwd [list PIXSIZE2 $pixsize float "Pixel dimension" "m"]
                  buf$audace(bufNo) setkwd [list FOCLEN  $foclen float "Focal length" "m"]
                  buf$audace(bufNo) setkwd [list CDELT1 [expr -$cdelt] double "X scale" "deg/pix"]
                  buf$audace(bufNo) setkwd [list CDELT2 $cdelt double "Y scale" "deg/pix"]
                  buf$audace(bufNo) setkwd [list CROTA2 $crota double "" "deg"]
                  buf$audace(bufNo) setkwd [list CRPIX1 [expr $naxis1/2] double "" "pix"]
                  buf$audace(bufNo) setkwd [list CRPIX2 [expr $naxis2/2] double "" "pix"]
                  set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
                  set kk [string first T $date_obs]
                  if {$kk<0} {
                     set jour [string range $date_obs 0 1]
                     set mois [string range $date_obs 3 4]
                     set annee [string range $date_obs 6 9]
                     set instant [lindex [buf$audace(bufNo) getkwd TM-START] 1]
                     set instant [mc_angle2hms [expr $instant/240.]]
                     set heure [format %02d [lindex $instant 0]]
                     set minute [format %02d [lindex $instant 1]]
                     set seconde [format %05.2f [lindex $instant 2]]
                     set date_obs ${annee}-${mois}-${jour}T${heure}:${minute}:${seconde}
                     buf$audace(bufNo) setkwd [list DATE-OBS $date_obs string "debut de pose" "iso8601"]
                     set exposure [lindex [buf$audace(bufNo) getkwd TM-EXPOS] 1]
                     buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
                     set ra [lindex [buf$audace(bufNo) getkwd POSTN-RA] 1]
                     set dec [lindex [buf$audace(bufNo) getkwd POSTN-DE] 1]
                  } else {
                     set exposure [lindex [buf$audace(bufNo) getkwd EXPTIME] 1]
                     buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
                  }
                  buf$audace(bufNo) setkwd [list RA $ra double "RA J2000.0" "deg"]
                  buf$audace(bufNo) setkwd [list DEC $dec double "DEC J2000.0" "deg"]
                  buf$audace(bufNo) setkwd [list CRVAL1 $ra double "" "deg"]
                  buf$audace(bufNo) setkwd [list CRVAL2 $dec double "" "deg"]
                  buf$audace(bufNo) save $fullname2
               }
               if {$telescope=="t193"} {
                  catch {file copy -force $fullname $fullname2}
                  buf$audace(bufNo) load $fullname2
                  set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
                  set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
                  #catch {buf$audace(bufNo) delkwd COMMENT=}
                  set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
                  set kk [string first T $date_obs]
                  if {$kk<0} {
                     set jour [string range $date_obs 8 9]
                     regsub -all " " $jour "0" res
                     set jour $res
                     set mois [string range $date_obs 5 6]
                     regsub -all " " $mois "0" res
                     set mois $res
                     set annee [string range $date_obs 0 3]
                     set instant [lindex [buf$audace(bufNo) getkwd TM-START] 1]
                     set instant [mc_angle2hms [expr $instant/240.]]
                     set heure [format %02d [lindex $instant 0]]
                     set minute [format %02d [lindex $instant 1]]
                     set seconde [format %05.2f [lindex $instant 2]]
                     set date_obs ${annee}-${mois}-${jour}T${heure}:${minute}:${seconde}
                     buf$audace(bufNo) setkwd [list DATE-OBS $date_obs string "debut de pose" "iso8601"]
                     set exposure [lindex [buf$audace(bufNo) getkwd TM-EXPOS] 1]
                     buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
                     set ra [lindex [buf$audace(bufNo) getkwd POSTN-RA] 1]
                     set dec [lindex [buf$audace(bufNo) getkwd POSTN-DE] 1]
                  } else {
                     set exposure [lindex [buf$audace(bufNo) getkwd EXPTIME] 1]
                     buf$audace(bufNo) setkwd [list EXPOSURE $exposure float "duree de pose" "s"]
                  }
                  buf$audace(bufNo) setkwd [list RA $ra double "RA J2000.0" "deg"]
                  buf$audace(bufNo) setkwd [list DEC $dec double "DEC J2000.0" "deg"]
                  buf$audace(bufNo) save $fullname2
               }
            }
         }

         if {$methode=="copy"} {
            ::ohp::files 1
            set kk 0
            # --- serie A
            set fics [glob "${path}${nameraw}*.fit"]
            set n [llength $fics]
            set kdeb 1
            set kfin $n
            for {set k $kdeb} {$k<=$kfin} {incr k} {
               incr kk
               file copy -force "${path}${nameraw}$k.fit" "${path}tempa$kk.fit"
            }
         }

         if {$methode=="makedark"} {
            set fics [glob "${path}${nameraw}*.fit"]
            set n [llength $fics]
            smedian ${nameraw} $dark $n
         }

         if {$methode=="makeflat"} {
            set fics [glob "${path}${nameraw}*.fit"]
            set n [llength $fics]
            sub2 ${nameraw} $dark tempi 0 $n
            ngain2 tempi tempi 10000 $n
            smedian tempi $flat $n
         }

         if {$methode=="cordark"} {
            set fics [glob "${path}tempa*.fit"]
            set n [llength $fics]
            sub2 tempa $dark tempi 0 $n
         }

         if {$methode=="corflat"} {
            set fics [glob "${path}tempi*.fit"]
            set n [llength $fics]
            div2 tempi $flat tempj 10000 $n
         }

         if {$methode=="noffset"} {
            set fics [glob "${path}tempj*.fit"]
            set n [llength $fics]
            noffset2 tempj tempj 300 $n
         }

         if {$methode=="cosmetic"} {
            set fics [glob "${path}tempj*.fit"]
            set n [llength $fics]
            uncosmic2 tempj tempj $n 0.9
         }

         if {$methode=="astrometry"} {
            set extout .fit
            set fics [glob "${path}tempj*$extout"]
            set n [llength $fics]
            set kdeb 1
            set kfin $n
            for {set k $kdeb} {$k<=$kfin} {incr k} {
               set shortname tempj$k
               ::console::affiche_resultat "   $shortname "
               set erreur [ catch { ttscript2 "IMA/SERIES \"$path\" \"$shortname\" . . \"$extout\" \"$path\" \"$shortname\" . \"$extout\" STAT \"objefile=obj$extout\" detect_kappa=20" } msg ]
               if {$erreur==1} { ::console::affiche_resultat " ERREUR : $msg\n" }
               set erreur [ catch { ttscript2 "IMA/SERIES \"$path\" \"$shortname\" . . \"$extout\" \"$path\" \"$shortname\" . \"$extout\" CATCHART \"path_astromcatalog=$pathcat\" astromcatalog=$astromcat \"catafile=cat$extout\" \"jpegfile_chart2=${path}ia.jpg\" " } msg ]
               if {$erreur==1} { ::console::affiche_resultat " ERREUR : $msg\n" }
               set erreur [ catch { ttscript2 "IMA/SERIES \"$path\" \"$shortname\" . . \"$extout\" \"$path\" \"$shortname\" . \"$extout\" ASTROMETRY delta=5 epsilon=0.002" } msg ]
               if {$erreur==1} { ::console::affiche_resultat " ERREUR : $msg\n" }
               buf$audace(bufNo) load ${path}${shortname}${extout}
               set catastar [lindex [buf$audace(bufNo) getkwd CATASTAR] 1]
               ::console::affiche_resultat "=> calibration avec $catastar etoiles USNO.\n"
            }
         }

         if {$methode=="register"} {
            set fics [glob "${path}tempj*.fit"]
            set n [llength $fics]
            register tempj tempk $n
         }

         if {$methode=="registerwin"} {
            set fics [glob "${path}tempj*.fit"]
            set n [llength $fics]
            register tempj tempk $n -box $box
         }

         if {$methode=="makeflat_spectro"} {
            set fics [glob "${path}${nameraw}*.fit"]
            set n [llength $fics]
            set saturation yes
            ohp_spectro_make_flat $nameraw $flat $n $dark $telescope $saturation
         }

         if {$methode=="pretraite_stack_spectro"} {
            set fics [glob "${path}tempa*.fit"]
            set n [llength $fics]
            ohp_spectro_pretraitement tempa tempj $n $dark $flat $telescope
         }

         if {$methode=="pretraite_serie_spectro"} {
            set fics [glob "${path}tempa*.fit"]
            set nin [llength $fics]
            for {set k 1} {$k<=$nin} {incr k} {
               set nameink tempa$k
               set nameoutk tempj$k
               set nink 0
               ohp_spectro_pretraitement $nameink $nameoutk $nink $dark $flat $telescope
            }
         }

         if {$methode=="extraction_spectro"} {
            set pathh $audace(rep_images)
            ohp_spectro_extract $pathh $namein $nameout $telescope
         }

         if {$methode=="extraction_serie_spectro"} {
            set fics [glob "${path}${namein}*.fit"]
            set nin [llength $fics]
            if {$telescope=="t193"} {
               set expkwd EXPOSURE
            } else {
               set expkwd EXPOSURE
            }
            for {set k 1} {$k<=$nin} {incr k} {
               set pathh $audace(rep_images)
               set nameink ${namein}$k
               buf$audace(bufNo) load "${path}${namein}${k}.fit"
               set dateobs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
               set exposure [expr [lindex [buf$audace(bufNo) getkwd $expkwd] 1]/86400./2]
               set dateobs [mc_date2iso8601 [mc_datescomp $dateobs + $exposure]]
               set y [string range $dateobs 0 3]
               set m [string range $dateobs 5 6]
               set d [string range $dateobs 8 9]
               set hh [string range $dateobs 11 12]
               set mm [string range $dateobs 14 15]
               set dateobs "${y}${m}${d}t${hh}${mm}"
               set nameoutk ${nameout}_$dateobs
               set nameoutk ${nameout}_$k
               ohp_spectro_extract $pathh $nameink $nameoutk $telescope
            }
         }

         ::console::affiche_resultat "Fin étape $methode \n"

      }
      ::console::affiche_resultat "==================== TERMINE ====================\n"
   }

   proc save { } {
      global conf
      global audace
      global caption
      set vars [array name audace]
      set texte ""
      foreach var $vars {
         set ident [string range $var 0 3]
         if {[string compare $ident "ohp,"]==0} {
            if {[string compare $var ohp,allmethodes]==0} {
               continue
            }
            append texte "set audace($var) \"$audace($var)\" \n"
         }
      }
      #::console::affiche_resultat "$texte"
      set filename [ tk_getSaveFile -title "$caption(ohp,save)" -filetypes {{configuration *.ohp}} -initialdir "$audace(rep_images)" ]
      set n [string length $filename]
      set ext [string range $filename [expr $n-4] end]
      if {[string compare $ext ".ohp"]!=0} {
         append filename .ohp
      }
      set f [open $filename w]
      puts -nonewline $f $texte
      close $f
   }

   proc load { } {
      global conf
      global audace
      global caption
      set filename [ tk_getOpenFile -title "$caption(ohp,load)" -filetypes {{configuration *.ohp}} -initialdir "$audace(rep_images)" ]
      source $filename
   }

   proc getbox { } {
      global audace
      set audace(ohp,box) [::confVisu::getBox 1]
      .ohp.box.entry configure -textvariable audace(ohp,box)
      update
   }

   proc rename { {purge 0} } {
      global conf
      global audace
      global caption
      set fichiers [lsort -unique [glob $audace(rep_images)/*]]
      foreach fichier $fichiers {
         set fichier_tail [file tail $fichier]
         set n [string length $fichier_tail]
         ::console::affiche_resultat "<$fichier_tail> => "
         for {set k 0} {$k<[expr $n-0]} {incr k} {
            set c [string index $fichier_tail $k]
            set kdeb1 0
            set kfin1 [expr $k-1]
            if {$kfin1<$kdeb1} {set kfin1 $kdeb1}
            set kdeb2 [expr $k+1]
            set kfin2 [expr $n-1]
            if {$kfin2<$kdeb2} {set kdeb2 $kfin2}
            set car $c
            if {$c=="_"} {
               set car -
            }
            if {$c=="-"} {
               set car _
            }
            if {$k==0} {
               set fichier_tail "${car}[string range $fichier_tail $kdeb2 $kfin2]"
            } elseif {$k==[expr $n-1]} {
               set fichier_tail "[string range $fichier_tail $kdeb1 $kfin1]${car}"
            } else {
               set fichier_tail "[string range $fichier_tail $kdeb1 $kfin1]${car}[string range $fichier_tail $kdeb2 $kfin2]"
            }
         }
         ::console::affiche_resultat "<$fichier_tail> \n"
         catch {file rename "$fichier" "$audace(rep_images)/$fichier_tail"}
      }
   }

   proc files { {purge 0} } {
      global conf
      global audace
      global caption
      set fichiers [lsort -unique [glob $audace(rep_images)/*]]
      ##
      ::console::affiche_resultat "======================== DEBUT fichiers\n"
      ::console::affiche_resultat "$caption(ohp,folder) : $audace(rep_images)\n"
      ::console::affiche_resultat "------------------------\n"
      ::console::affiche_resultat "$caption(ohp,rawfiles):\n"
      set name0 ""
      set ext0 ""
      set n 1
      foreach fichier $fichiers {
         set fichier_tail [file tail $fichier]
         set ext [file extension $fichier_tail]
         set k [string last - $fichier_tail]
         if {$k<0} { continue }
         set name [string range $fichier_tail 0 [expr $k]]
         #::console::affiche_resultat " fichier_tail=$fichier_tail : $name ($k)\n"
         if {([string compare $name $name0]==0)&&([string compare $ext $ext0]==0)} {
            incr n
         } else {
            if {[string compare $name0 ""]==0} {
               set name0 $name
               set ext0 $ext
               continue
            }
            ::console::affiche_resultat " ${name0}*${ext0} ($n)\n"
            set n 1
            set name0 $name
            set ext0 $ext
         }
      }
      if {$n>1} {
         ::console::affiche_resultat " ${name0}*${ext0} ($n)\n"
      }
      ##
      ::console::affiche_resultat "------------------------\n"
      ::console::affiche_resultat "$caption(ohp,otherfiles):\n"
      set name0 ""
      set ext0 ""
      set n 1
      foreach fichier $fichiers {
         set fichier_tail [file tail $fichier]
         set ext [file extension $fichier_tail]
         set k [string last - $fichier_tail]
         if {$k>=0} { continue }
         set name [file rootname $fichier_tail]
         set kc [regexp {[0-9]+} "$name" c]
         if {$kc==1} {
            set k [string last $c $name]
            set name [string range $name 0 [expr $k-1]]

         }
         #::console::affiche_resultat " fichier_tail=$fichier_tail : $name ($k)\n"
         if {([string compare $name $name0]==0)&&([string compare $ext $ext0]==0)} {
            incr n
         } else {
            if {[string compare $name0 ""]==0} {
               set name0 $name
               set ext0 $ext
               continue
            }
            if {$n==1} { set c "" } else { set c * }
            ::console::affiche_resultat " ${name0}${c}${ext0} ($n)\n"
            if {($purge==1)&&($n>1)} {
               for {set k 1} {$k<=$n} {incr k} {
                  catch {
                     file delete $audace(rep_images)/${name0}${k}${ext0}
                     ::console::affiche_resultat " => delete ${name0}${k}${ext0}\n"
                  }
               }
            }
            set n 1
            set name0 $name
            set ext0 $ext
         }
      }
      if {$n>1} {
         if {$n==1} { set c "" } else { set c * }
         ::console::affiche_resultat " ${name0}${c}${ext0} ($n)\n"
         if {($purge==1)&&($n>1)} {
            for {set k 1} {$k<=$n} {incr k} {
               catch {
                  file delete $audace(rep_images)/${name0}${k}${ext0}
                  ::console::affiche_resultat " => delete ${name0}${k}${ext0}\n"
               }
            }
         }
      }
      ::console::affiche_resultat "======================== FIN fichiers\n"
   }

   proc parameters { } {
      global audace
      #::console::affiche_resultat "=============================================================\n"
      #foreach allmethode $audace(ohp,allmethodes) {
      #   ::console::affiche_resultat "audace(ohp,methode,$allmethode)=$audace(ohp,methode,$allmethode)\n"
      #}
      if {($audace(ohp,methode,bifsconv)==1)} {
         .ohp.namerawfits.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.namerawfits.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.namerawfits configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.namerawfits.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.namerawfits.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.namerawfits configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,bifsconv)==1)||($audace(ohp,methode,convert)==1)||($audace(ohp,methode,copy)==1)||($audace(ohp,methode,makedark)==1)||($audace(ohp,methode,makeflat)==1)||($audace(ohp,methode,makeflat_spectro)==1)} {
         .ohp.nameraw.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.nameraw.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.nameraw configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.nameraw.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.nameraw.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.nameraw configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,astrometry)==1)} {
         .ohp.pathcat.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.pathcat.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.pathcat configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.pathcat.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.pathcat.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.pathcat configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,cordark)==1)||($audace(ohp,methode,makedark)==1)||($audace(ohp,methode,makeflat)==1)||($audace(ohp,methode,makeflat_spectro)==1)||($audace(ohp,methode,pretraite_stack_spectro)==1)||($audace(ohp,methode,pretraite_serie_spectro)==1)} {
         .ohp.dark.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.dark.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.dark configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.dark.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.dark.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.dark configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,corflat)==1)||($audace(ohp,methode,makeflat)==1)||($audace(ohp,methode,makeflat_spectro)==1)||($audace(ohp,methode,pretraite_stack_spectro)==1)||($audace(ohp,methode,pretraite_serie_spectro)==1)} {
         .ohp.flat.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.flat.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.flat configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.flat.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.flat.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.flat configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,registerwin)==1)} {
         .ohp.box.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.box.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.box configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.box.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.box.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.box configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,extraction_spectro)==1)||($audace(ohp,methode,extraction_serie_spectro)==1)} {
         .ohp.namein.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.namein.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.namein configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.namein.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.namein.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.namein configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,extraction_spectro)==1)||($audace(ohp,methode,extraction_serie_spectro)==1)} {
         .ohp.nameout.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.nameout.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.nameout configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.nameout.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.nameout.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.nameout configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,convert)==1)||($audace(ohp,methode,makeflat_spectro)==1)||($audace(ohp,methode,pretraite_stack_spectro)==1)||($audace(ohp,methode,pretraite_serie_spectro)==1)||($audace(ohp,methode,extraction_spectro)==1)||($audace(ohp,methode,extraction_serie_spectro)==1)} {
         .ohp.telescope.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.telescope.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.telescope configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.telescope.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.telescope.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.telescope configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,convert)==1)} {
         .ohp.ra.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.ra.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.ra configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.ra.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.ra.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.ra configure -relief flat -bg $audace(ohp,color,backpad)
      }
      if {($audace(ohp,methode,convert)==1)} {
         .ohp.dec.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,textkey) -relief flat
         .ohp.dec.entry configure -bg $audace(ohp,color,backdisp) -fg $audace(ohp,color,textdisp) -relief flat
         .ohp.dec configure -relief sunken -bg $audace(ohp,color,backpad)
      } else {
         .ohp.dec.label configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.dec.entry configure -bg $audace(ohp,color,backpad) -fg $audace(ohp,color,backpad) -relief flat
         .ohp.dec configure -relief flat -bg $audace(ohp,color,backpad)
      }
      update
   }

}

proc ohp_interpol { ls lrefs frefs } {
   set nl [llength $ls]
   set l0 [lindex $ls 0]
   set l1 [lindex $ls 1]
   set dl [expr $l1-$l0]
   set nref [llength $lrefs]
   set nref1 [expr $nref-3]
   set fatm ""
   if {$dl>0} {
      set kref 0
      set lmin [lindex $lrefs [expr $kref+0]]
      set fmin [lindex $frefs [expr $kref+0]]
      set lmax [lindex $lrefs [expr $kref+1]]
      set fmax [lindex $frefs [expr $kref+1]]
      set df [expr $fmax-$fmin]
      for {set kl 0} {$kl<$nl} {incr kl} {
         set l [lindex $ls $kl]
         while {($l>=$lmax)&&($kref<$nref1)} {
            incr kref
            set lmin [lindex $lrefs [expr $kref+0]]
            set fmin [lindex $frefs [expr $kref+0]]
            set lmax [lindex $lrefs [expr $kref+1]]
            set fmax [lindex $frefs [expr $kref+1]]
            set df [expr $fmax-$fmin]
         }
         set fref [expr [lindex $frefs $kref]+($l-$lmin)/($lmax-$lmin)*$df]
         #::console::affiche_resultat "+kl=$kl l=$l $lmin $lmax $\n"
         lappend fatm $fref
      }
   } else {
      set kref [expr $nref-2]
      set lmin [lindex $lrefs [expr $kref+0]]
      set fmin [lindex $frefs [expr $kref+0]]
      set lmax [lindex $lrefs [expr $kref+1]]
      set fmax [lindex $frefs [expr $kref+1]]
      for {set kl 0} {$kl<$nl} {incr kl} {
         set l [lindex $ls $kl]
         while {$l<=$lmin} {
            incr kref -1
            set lmin [lindex $lrefs [expr $kref+0]]
            set fmin [lindex $frefs [expr $kref+0]]
            set lmax [lindex $lrefs [expr $kref+1]]
            set fmax [lindex $frefs [expr $kref+1]]
            set df [expr $fmax-$fmin]
         }
         set fref [expr [lindex $frefs $kref]+($l-$lmin)/($lmax-$lmin)*$df]
         #::console::affiche_resultat "-kl=$kl l=$l $lmin $lmax kref=$kref\n"
         lappend fatm $fref
      }
   }
   return $fatm
}

proc ohp_respt80 { ls } {
   # RESPONSE OF THE T80 SPECTROGRAPH WITH THE order-filter
   # (A.D.U/s) / (ergs/cm2/A)
   # mestheo=mesobs/tobs./response;
   set lrefs [list  4.0000000e+003  4.0707071e+003  4.1414141e+003  4.2121212e+003  4.2828283e+003  4.3535354e+003  4.4242424e+003  4.4949495e+003  4.5656566e+003  4.6363636e+003  4.7070707e+003  4.7777778e+003  4.8484848e+003  4.9191919e+003  4.9898990e+003  5.0606061e+003  5.1313131e+003  5.2020202e+003  5.2727273e+003  5.3434343e+003  5.4141414e+003  5.4848485e+003  5.5555556e+003  5.6262626e+003  5.6969697e+003  5.7676768e+003  5.8383838e+003  5.9090909e+003  5.9797980e+003  6.0505051e+003  6.1212121e+003  6.1919192e+003  6.2626263e+003  6.3333333e+003  6.4040404e+003  6.4747475e+003  6.5454545e+003  6.6161616e+003  6.6868687e+003  6.7575758e+003  6.8282828e+003  6.8989899e+003  6.9696970e+003  7.0404040e+003  7.1111111e+003  7.1818182e+003  7.2525253e+003  7.3232323e+003  7.3939394e+003  7.4646465e+003  7.5353535e+003  7.6060606e+003  7.6767677e+003  7.7474747e+003  7.8181818e+003  7.8888889e+003  7.9595960e+003  8.0303030e+003  8.1010101e+003  8.1717172e+003  8.2424242e+003  8.3131313e+003  8.3838384e+003  8.4545455e+003  8.5252525e+003  8.5959596e+003  8.6666667e+003  8.7373737e+003  8.8080808e+003  8.8787879e+003  8.9494949e+003  9.0202020e+003  9.0909091e+003  9.1616162e+003  9.2323232e+003  9.3030303e+003  9.3737374e+003  9.4444444e+003  9.5151515e+003  9.5858586e+003  9.6565657e+003  9.7272727e+003  9.7979798e+003  9.8686869e+003  9.9393939e+003  1.0010101e+004  1.0080808e+004  1.0151515e+004  1.0222222e+004  1.0292929e+004  1.0363636e+004  1.0434343e+004  1.0505051e+004  1.0575758e+004  1.0646465e+004  1.0717172e+004  1.0787879e+004  1.0858586e+004  1.0929293e+004  1.1000000e+004]
   set frefs [list -7.5579601e+010 -1.1424333e+011 -1.1259199e+011 -1.5883323e+011 -1.1123457e+011 -1.2233893e+011 -1.8676900e+011 -2.4997823e+011 -2.8456390e+011 -3.2335529e+011 -2.9025253e+011 -3.2600099e+011 -3.5340708e+011 -2.8886255e+011 -4.1048646e+011 -2.0315184e+011 -1.1318002e+011  2.4796311e+011  4.2005344e+011  9.2451021e+011  2.7978164e+012  2.4486626e+013  1.4015006e+014  3.3745489e+014  5.2339759e+014  6.6675055e+014  7.4831974e+014  8.0121208e+014  8.4228401e+014  8.2801275e+014  8.7633498e+014  8.7405724e+014  8.7223961e+014  8.8043511e+014  8.9857824e+014  8.9015495e+014  8.6682670e+014  8.7973245e+014  8.8281742e+014  8.6433809e+014  8.1885938e+014  7.9920174e+014  7.8543823e+014  7.8635608e+014  7.5460894e+014  6.9812906e+014  6.5324725e+014  6.4883246e+014  6.4229634e+014  6.2413617e+014  5.5957032e+014  4.2720428e+014  4.1804422e+014  4.5186161e+014  4.5328675e+014  4.3412069e+014  4.0640299e+014  3.7069879e+014  3.2681802e+014  2.8122650e+014  2.5182419e+014  2.3771309e+014  2.3101082e+014  2.1328365e+014  2.0088528e+014  1.8475474e+014  1.7347791e+014  1.6298646e+014  1.5931027e+014  1.4923383e+014  1.3259606e+014  1.0538228e+014  9.3514006e+013  8.5857136e+013  7.3916194e+013  5.8448798e+013  3.0150961e+013  2.5280081e+013  2.2722691e+013  1.9226605e+013  1.9544757e+013  2.1655733e+013  1.9445323e+013  1.6439764e+013  1.4565668e+013  1.2859463e+013  7.5935812e+012  5.6896017e+012  4.6143713e+012  3.9162433e+012  1.8998690e+012  9.6289464e+011  6.6745747e+011  1.3234549e+011 -3.6846950e+010  5.2497138e+009 -4.1376704e+010 -2.1036675e+010 -6.8603515e+010 -8.6545737e+009]
   set f [ohp_interpol $ls $lrefs $frefs]
   set fs ""
   set s 1.
   foreach ff $f {
      set ffs $ff
      if {$ff<0} {
         set ffs 0.
      }
      lappend fs $ffs
   }
   return $fs
}

proc ohp_atmext { ls {airmass 1.} } {
   # ATMOSPHERIC EXTINCTION (MAGNITUDES) AT AIRMASS 1.00 at alt=600m
   set lrefs [list 2.9000000e+003  3.0000000e+003  3.1500000e+003  3.1600000e+003  3.1700000e+003  3.1800000e+003  3.1900000e+003  3.2000000e+003  3.2100000e+003  3.2200000e+003  3.2300000e+003  3.2400000e+003  3.2500000e+003  3.2600000e+003  3.2700000e+003  3.2800000e+003  3.2900000e+003  3.3000000e+003  3.3200000e+003  3.3400000e+003  3.3600000e+003  3.3800000e+003  3.4000000e+003  3.4500000e+003  3.5000000e+003  3.6000000e+003  3.7000000e+003  3.8000000e+003  3.9000000e+003  4.0000000e+003  4.1000000e+003  4.2000000e+003  4.3000000e+003  4.4000000e+003  4.5000000e+003  4.6000000e+003  4.7000000e+003  4.8000000e+003  4.9000000e+003  5.0000000e+003  5.2000000e+003  5.4000000e+003  5.6000000e+003  5.8000000e+003  6.0000000e+003  6.1000000e+003  6.2000000e+003  6.5000000e+003  6.8200000e+003  7.3400000e+003  7.3600000e+003  7.5600000e+003  7.5700000e+003  7.6800000e+003  7.6900000e+003  7.7000000e+003  7.9000000e+003  8.1000000e+003  8.3500000e+003  8.3600000e+003  8.6250000e+003  8.8900000e+003  8.9000000e+003  9.8600000e+003  9.8700000e+003  1.1200000e+004  1.2500000e+004]
   set frefs [list 9.7513564e-007  2.4494300e-004  2.5648681e-001  2.8253030e-001  2.9940912e-001  3.1554771e-001  3.3102823e-001  3.4599118e-001  3.5897568e-001  3.7073623e-001  3.8112289e-001  3.9071945e-001  4.0018889e-001  4.0838053e-001  4.1558994e-001  4.2370641e-001  4.3158370e-001  4.3879839e-001  4.5275685e-001  4.6501293e-001  4.7540641e-001  4.8290870e-001  4.9052939e-001  5.0473687e-001  5.3587689e-001  5.6893812e-001  6.0071023e-001  6.2382824e-001  6.5022705e-001  6.8401406e-001  7.0837794e-001  7.2889510e-001  7.4587325e-001  7.6254421e-001  7.7887010e-001  7.9262001e-001  8.0438697e-001  8.1332670e-001  8.2160870e-001  8.2768490e-001  8.3611310e-001  8.4462713e-001  8.4930764e-001  8.5322786e-001  8.6749110e-001  8.7874938e-001  8.8769757e-001  9.0170615e-001  9.0753844e-001  9.1593579e-001  9.1677979e-001  9.1847011e-001  9.1847011e-001  9.2016356e-001  9.2101145e-001  9.2186012e-001  9.2355982e-001  9.2441084e-001  9.2696861e-001  9.2696861e-001  9.2867773e-001  9.2953346e-001  9.2953346e-001  9.3554575e-001  9.3554575e-001  9.3727068e-001  9.3899878e-001]
   set f [ohp_interpol $ls $lrefs $frefs]
   set fs ""
   set s 1.
   foreach ff $f {
      if {$ff>1} { set ff 1. }
      if {$ff<1e-10} {
         set ffs 0.
      } else {
         set abs [expr -log($ff)]
         set abscor [expr $abs*$s*$airmass]
         set ffs [expr exp(-$abscor)]
      }
      lappend fs $ffs
   }
   return $fs
}

proc ohp_convmag { ls } {
   # MAGNITUDE COVERSION
   set lrefs [list 3.6000000e+003  3.6747475e+003  3.7494949e+003  3.8242424e+003  3.8989899e+003  3.9737374e+003  4.0484848e+003  4.1232323e+003  4.1979798e+003  4.2727273e+003  4.3474747e+003  4.4222222e+003  4.4969697e+003  4.5717172e+003  4.6464646e+003  4.7212121e+003  4.7959596e+003  4.8707071e+003  4.9454545e+003  5.0202020e+003  5.0949495e+003  5.1696970e+003  5.2444444e+003  5.3191919e+003  5.3939394e+003  5.4686869e+003  5.5434343e+003  5.6181818e+003  5.6929293e+003  5.7676768e+003  5.8424242e+003  5.9171717e+003  5.9919192e+003  6.0666667e+003  6.1414141e+003  6.2161616e+003  6.2909091e+003  6.3656566e+003  6.4404040e+003  6.5151515e+003  6.5898990e+003  6.6646465e+003  6.7393939e+003  6.8141414e+003  6.8888889e+003  6.9636364e+003  7.0383838e+003  7.1131313e+003  7.1878788e+003  7.2626263e+003  7.3373737e+003  7.4121212e+003  7.4868687e+003  7.5616162e+003  7.6363636e+003  7.7111111e+003  7.7858586e+003  7.8606061e+003  7.9353535e+003  8.0101010e+003  8.0848485e+003  8.1595960e+003  8.2343434e+003  8.3090909e+003  8.3838384e+003  8.4585859e+003  8.5333333e+003  8.6080808e+003  8.6828283e+003  8.7575758e+003  8.8323232e+003  8.9070707e+003  8.9818182e+003  9.0565657e+003  9.1313131e+003  9.2060606e+003  9.2808081e+003  9.3555556e+003  9.4303030e+003  9.5050505e+003  9.5797980e+003  9.6545455e+003  9.7292929e+003  9.8040404e+003  9.8787879e+003  9.9535354e+003  1.0028283e+004  1.0103030e+004  1.0177778e+004  1.0252525e+004  1.0327273e+004  1.0402020e+004  1.0476768e+004  1.0551515e+004  1.0626263e+004  1.0701010e+004  1.0775758e+004  1.0850505e+004  1.0925253e+004  1.1000000e+004]
   set frefs [list 4.2200000e-009  4.7006220e-009  5.1145768e-009  5.4651679e-009  5.7556987e-009  5.9894727e-009  6.1697935e-009  6.2999645e-009  6.3832892e-009  6.4230712e-009  6.4226139e-009  6.3852208e-009  6.3141955e-009  6.2128413e-009  6.0844619e-009  5.9323607e-009  5.7598412e-009  5.5702069e-009  5.3667613e-009  5.1528078e-009  4.9316501e-009  4.7065916e-009  4.4809357e-009  4.2579861e-009  4.0410461e-009  3.8334192e-009  3.6382809e-009  3.4567377e-009  3.2882222e-009  3.1321192e-009  2.9878136e-009  2.8546899e-009  2.7321330e-009  2.6195276e-009  2.5162585e-009  2.4217103e-009  2.3352678e-009  2.2563158e-009  2.1842390e-009  2.1184221e-009  2.0582500e-009  2.0031072e-009  1.9523786e-009  1.9054489e-009  1.8617029e-009  1.8205252e-009  1.7813007e-009  1.7434146e-009  1.7064125e-009  1.6702234e-009  1.6348320e-009  1.6002233e-009  1.5663822e-009  1.5332935e-009  1.5009421e-009  1.4693128e-009  1.4383906e-009  1.4081603e-009  1.3786069e-009  1.3497151e-009  1.3214698e-009  1.2938560e-009  1.2668585e-009  1.2404622e-009  1.2146519e-009  1.1894126e-009  1.1647291e-009  1.1405862e-009  1.1169690e-009  1.0938621e-009  1.0712506e-009  1.0491193e-009  1.0274531e-009  1.0062368e-009  9.8545528e-010  9.6509350e-010  9.4513630e-010  9.2556854e-010  9.0637511e-010  8.8754089e-010  8.6905074e-010  8.5088955e-010  8.3304219e-010  8.1549355e-010  7.9822848e-010  7.8123188e-010  7.6448861e-010  7.4798356e-010  7.3170160e-010  7.1562760e-010  6.9974645e-010  6.8404302e-010  6.6850218e-010  6.5310881e-010  6.3784779e-010  6.2270399e-010  6.0766230e-010  5.9270758e-010  5.7782471e-010  5.6299857e-010]
   set f [ohp_interpol $ls $lrefs $frefs]
   return $f
}

proc ohp_spectro_make_offset { namein nameout nin } {
   #smedian Offset- offset 5
   smedian $namein $nameout $nin
}

proc ohp_spectro_make_dark { namein nameout nin } {
   #smedian Dark_1200s- dark1200 6
   smedian $namein $nameout $nin
}

proc ohp_spectro_make_flat { namein nameout nin namedark telescope saturation } {
   global audace
   sub2 $namein $namedark tempi 0 $nin
   if {$telescope=="t193"} {
      ngain2 tempi tempj 15000 $nin
      smedian tempj tempj $nin
      loadima tempj
   } else {
      smedian tempi tempi $nin
      loadima tempi
   }
   set sature yes
   if {$saturation=="no"} {
      buf$audace(bufNo) imaseries "BACK beck_kernel=15 back_threshold=0.4 div"
   } else {
      set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
      set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
      if {$telescope=="t193"} {
         set x1 900
         set x2 1200
      } else {
         set x1 550
         set x2 700
      }
      buf$audace(bufNo) imaseries "BINX x1=$x1 x2=$x2 width=$naxis1"
      if {$telescope=="t193"} {
         ngain 15000
      } else {
         set box {11 365 136 574}
         set res [buf$audace(bufNo) stat $box]
         set maxi [lindex $res 2]
         set mult [expr 15000./$maxi]
         mult $mult
      }
   }
   saveima $nameout
}

proc ohp_spectro_pretraitement { namein nameout nin namedark nameflat telescope } {
   global audace
   # --- preprocessing
   if {$nin>0} {
      sub2 $namein $namedark tempi 0 $nin
      div2 tempi $nameflat tempj 15000 $nin
      sadd tempj $nameout $nin bitpix=-32
   } else {
      loadima $namein
      sub $namedark 0
      div $nameflat 15000
      buf$audace(bufNo) bitpix float
      saveima $nameout
   }
   # --- cosmetic
   if {$telescope=="t80"} {
      loadima $nameout
      set x 562
      set y1 400
      set y2 600
      for {set y $y1} {$y<=$y2} {incr y} {
         set p1 [buf$audace(bufNo) getpix [list [expr $x-1] $y]]
         if { [ lindex $p1 0 ] == "1" } {
            set intens1 [ lindex $p1 1 ]
         } elseif { [ lindex $p1 0 ] == "3" } {
            set intens1R [ lindex $p1 1 ]
            set intens1V [ lindex $p1 2 ]
            set intens1B [ lindex $p1 3 ]
         }
         set p2 [buf$audace(bufNo) getpix [list [expr $x+1] $y]]
         if { [ lindex $p2 0 ] == "1" } {
            set intens2 [ lindex $p2 1 ]
         } elseif { [ lindex $p2 0 ] == "3" } {
            set intens2R [ lindex $p2 1 ]
            set intens2V [ lindex $p2 2 ]
            set intens2B [ lindex $p2 3 ]
         }
         if { [ lindex $p1 0 ] == "1" } {
            set p [expr ($intens1+$intens2)/2.]
            buf$audace(bufNo) setpix [list $x $y] $p
         } elseif { [ lindex $p1 0 ] == "3" } {
            set pR [expr ($intens1R+$intens2R)/2.]
            set pV [expr ($intens1V+$intens2V)/2.]
            set pB [expr ($intens1B+$intens2B)/2.]
            buf$audace(bufNo) setpix [list $x $y] $pR $pV $pB
         }
      }
      uncosmic 0.9
      saveima $nameout
   }
   # --- display header informations
   for {set k 0} {$k<=$nin} {incr k} {
      if {$nin>0} {
         set name tempj$k
         set namei ${namein}$k
         if {$k==0} {
            continue
         }
      } else {
         set name ${nameout}
         set namei ${namein}
      }
      loadima $name
      uncosmic 0.7
      set date_obs [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]
      set exposure [lindex [buf$audace(bufNo) getkwd EXPOSURE] 1]
      if {$telescope=="t80"} {
         set box {119 459 170 504}
         set flux [lindex [buf$audace(bufNo) phot $box] 0]
         set boxcuts {437 457 862 532}
      } else {
         set flux ?
         set boxcuts {1 50 200 200}
      }
      set res [buf$audace(bufNo) stat $boxcuts]
      visu visu$audace(visuNo) [lrange $res 0 1]
      ::console::affiche_resultat "$namei : $date_obs $exposure (flux= $flux) \n"
      saveima $name
   }
}

proc ohp_spectro_profil { path name telescope } {
   global audace
   # --- recherche la position y du spectre
   loadima $name
   set naxis1 [lindex [buf$audace(bufNo) getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$audace(bufNo) getkwd NAXIS2] 1]
   if {$telescope=="t193"} {
      buf$audace(bufNo) imaseries "BINX x1=1 x2=$naxis1 width=$naxis1"
      set box {21 307 104 600}
   } else {
      #buf$audace(bufNo) imaseries "BINX x1=500 x2=600 width=$naxis1"
      #set box {505 437 599 538}
      #set box {129 383 180 574}
      set box {121 400 177 520}
   }
   #buf$audace(bufNo) bitpix -32
   #saveima loc
   set res [buf$audace(bufNo) fitgauss $box]
   set yc [lindex $res 5]
   set yl [lindex $res 6]
   ::console::affiche_resultat "yc=$yc \n"
   if {$telescope=="t193"} {
      set yl 7
   } else {
      set yl 7
   }
   loadima $name
   buf$audace(bufNo) imaseries "BINY y1=[expr int($yc-2*$yl)] y2=[expr int($yc+2*$yl)] heigth=10"
   buf$audace(bufNo) bitpix -32
   saveima obj
   loadima $name
   buf$audace(bufNo) imaseries "BINY y1=[expr int(4*$yl+$yc-2*$yl)] y2=[expr int(4*$yl+$yc+2*$yl)] heigth=10"
   buf$audace(bufNo) bitpix -32
   saveima sky1
   loadima $name
   buf$audace(bufNo) imaseries "BINY y1=[expr int(-4*$yl+$yc-2*$yl)] y2=[expr int(-4*$yl+$yc+2*$yl)] heigth=10"
   buf$audace(bufNo) bitpix -32
   saveima sky2
   smean sky sky 2
   loadima obj
   sub sky 0
   #sub sky2 0
   saveima objseul
   set xs ""
   set valeurs ""
   for {set k 1} {$k<=$naxis1} {incr k} {
      lappend xs $k
      set p2 [buf$audace(bufNo) getpix [list $k 1]]
      if { [ lindex $p2 0 ] == "1" } {
         set valeur [ lindex $p2 1 ]
      } elseif { [ lindex $p2 0 ] == "3" } {
         set vr [ lindex $p2 1 ]
         set vv [ lindex $p2 2 ]
         set vb [ lindex $p2 3 ]
         set valeur [expr ($vr+$vv+$vb)/3.]
      }
      lappend valeurs $valeur
   }
   return [list $xs $valeurs]
}

proc ohp_spectro_extract { path namein nameout telescope } {
   global audace
   # --- lecture des mots cles
   loadima $namein
   set texp [lindex [buf$audace(bufNo) getkwd EXPOSURE] 1]
   if {$texp==""} {
      set texp [lindex [buf$audace(bufNo) getkwd EXPTIME] 1]
   }
   set ra [lindex [buf$audace(bufNo) getkwd RA] 1]
   set dec [lindex [buf$audace(bufNo) getkwd DEC] 1]
   set jdbeg [mc_date2jd [lindex [buf$audace(bufNo) getkwd DATE-OBS] 1]]
   set jd [expr $jdbeg+$texp/86400./2.]
   set home {MPC 5.7157 0.72140 +0.69034}
   set res [mc_radec2altaz $ra $dec $home $jd]
   set elev [lindex $res 1]
   if {$elev<5.} {
      set elev 45.
   }
   set z [expr (90.-$elev)*3.1416/180.]
   set secz 1
   catch { set secz [expr 1./cos($z)] }
   # Bemporad formula for airmass
   set airmass [expr $secz-0.0018167*$secz+0.02875*$secz*$secz+0.0008083*$secz*$secz*$secz]
   ::console::affiche_resultat "RA=[mc_angle2hms $ra] \n"
   ::console::affiche_resultat "DEC=[mc_angle2dms $dec 90] \n"
   ::console::affiche_resultat "DATE=[mc_date2iso8601 $jd] \n"
   ::console::affiche_resultat "ELEV=$elev \n"
   ::console::affiche_resultat "AIRMASS=$airmass \n"
   # --- extraction du profil [pixels][adu] -> pixels fadus
   set res [ohp_spectro_profil $path $namein $telescope]
   set pixels [lindex $res 0]
   set fadus [lindex $res 1]
   # --- calibration des longueurs d'onde [Angstroms] -> lambdas
   if {$telescope=="t193"} {
      set ech -1.7899; # A/pix
      set pix0 0
      set l0 7615.6
   } else {
      set ech 15.17
      set pix0 138.
      set valmax -1e5
      # -- recherche le pic de l'ordre zero
      for {set k 100} {$k<170} {incr k} {
         set val [lindex $fadus $k]
         if {$val>$valmax} {
            set valmax $val
            set pix0 $k
         }
      }
      set l0 0.
   }
   set lambdas ""
   set n [llength $pixels]
   for {set k 0} {$k<$n} {incr k} {
      set p [lindex $pixels $k]
      set l [expr ($p-$pix0)*$ech+$l0]
      lappend lambdas $l
   }
   # --- extinction de l'atmosphere [] -> fatms
   set fatms [ohp_atmext $lambdas $airmass]
   # --- correction hors atmosphere [ADU] -> faduouts
   set faduouts ""
   set k 0
   foreach fadu $fadus {
      set fatm [lindex $fatms $k]
      set faduout $fadu
      if {$fatm>1e-3} {
         set faduout [expr $fadu/$fatm]
      }
      lappend faduouts $faduout
      incr k
   }
   # --- reponse instrumentale [(A.D.U/s) / (ergs/cm2/A)] -> resps
   if {$telescope=="t80"} {
      set resps [ohp_respt80 $lambdas]
   } else {
      set resps ""
      foreach lambda $lambdas {
         lappend resps 0
      }
   }
   # --- fonction de conversion (ergs/s/cm2/A)=>(mag) -> convmags
   set convmags [ohp_convmag $lambdas]
   # --- flux calibré (ergs/s/cm2/A) & (mag)
   set fcals ""
   set k 0
   foreach lambda $lambdas {
      set resp [lindex $resps $k]
      set convmag [lindex $convmags $k]
      if {$resp>0} {
         set fcal 0.
         catch { set fcal [expr [lindex $faduouts $k]/$texp/$resp] }
         set ratio [expr $fcal/$convmag]
         if {$ratio>1e-6} {
            set mcal [expr -2.5*log10($ratio)]
         } else {
            set mcal 0.
         }
      } else {
         set fcal 0.
         set mcal 0.
      }
      lappend fcals $fcal
      lappend mcals $mcal
      incr k
   }
   # --- ecriture du fichier ASCCI
   set f [open ${path}/${nameout}.txt w]
   set n [llength $lambdas]
   for {set k 0} {$k<$n} {incr k} {
      set lambda [lindex $lambdas $k]
      set fadu [lindex $fadus $k]
      set fatm [lindex $fatms $k]
      set faduout [lindex $faduouts $k]
      set fcal [lindex $fcals $k]
      set mcal [lindex $mcals $k]
      puts $f "[format %+10.3f $lambda] [format %+8e $fadu] [format %5f $fatm] [format %+8e $faduout] [format %+8e $fcal] [format %+7.3f $mcal]"
   }
   close $f
   # --- graphique
   ::plotxy::figure 1
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::plot $lambdas $fadus r- 0
   #::plotxy::hold on
   #::plotxy::plot $lambdas $faduouts b- 0
   ::plotxy::position {40 40 600 600}
   ::plotxy::xlabel "Wavelengths (Angstroms)"
   ::plotxy::ylabel "Flux (ADU)"
   ::plotxy::title "$nameout"
   set ax [::plotxy::axis]
   set ax1 [lindex $ax 0]
   set ax2 [lindex $ax 1]
   set ax3 [lindex $ax 2]
   set ax4 [lindex $ax 3]
   set ax3 [expr -0.05*($ax4)]
   set ax [list $ax1 $ax2 $ax3 $ax4]
   ::plotxy::axis $ax
   ::plotxy::writegif ${path}/${nameout}.gif
   #
   if {$telescope=="t80"} {
      set k1 543
      for {set k $k1} {$k<813} {incr k} {
         set mcal [lindex $mcals $k]
         if {$mcal==0} {
            break
         }
      }
      incr k -1
      set k2 $k
      if {$k2<=$k1} { set k2 [expr $k1+1] }
      set lambda2s [lrange $lambdas $k1 $k2]
      set mcal2s [lrange $mcals $k1 $k2]
      ::plotxy::figure 2
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::plot $lambda2s $mcal2s b- 0
      ::plotxy::position {40 40 600 600}
      ::plotxy::xlabel "Wavelengths (Angstroms)"
      ::plotxy::ylabel "Magnitude"
      ::plotxy::title "$nameout"
      ::plotxy::ydir reverse
      set ax [::plotxy::axis]
      set ax1 [lindex $ax 0]
      set ax2 [lindex $ax 1]
      set ax3 [lindex $ax 2]
      set ax4 [lindex $ax 3]
      set ax [list $ax1 $ax2 $ax3 $ax4]
      ::plotxy::axis $ax
   }
}

::ohp::run


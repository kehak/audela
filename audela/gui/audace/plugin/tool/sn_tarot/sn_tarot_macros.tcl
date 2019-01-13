#
## @file sn_tarot_macros.tcl
#  @brief Macros des scripts pour la recherche de supernovae
#  @author Alain KLOTZ
#  $Id: sn_tarot_macros.tcl 14058 2016-10-02 22:27:19Z alainklotz $
#  @code source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl
#  @endcode
#  @todo documentation des fonctions à vérifier et à compléter par Alain

#------------------------------------------------------------
#  brief recherche les coordonnées du centre de la galaxie
#
proc ::sn_tarot::snGalaxyCenter { } {
   global snvisu snconfvisu num

   set afflog  "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
     set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,host_coords) "$ra $dec"
}

#------------------------------------------------------------
#  brief
#
proc ::sn_tarot::snStarRef { } {
   global snvisu snconfvisu num

   set afflog "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
      set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,starref_coords) "$ra $dec"
}

#------------------------------------------------------------
#  brief
#
proc ::sn_tarot::snCandidate { } {
   global snvisu snconfvisu num

   set afflog "$snvisu(afflog)"
   if { $afflog==0 } {
      set bufNo $num(buffer1)
   } else {
      set bufNo $num(buffer1b)
   }
   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [lindex $snvisu(candidate,xy) 0]
   set y [lindex $snvisu(candidate,xy) 1]
   set x [expr $x/$snconfvisu(zoom_normal)]
   set y [expr $y/$snconfvisu(zoom_normal)]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 1 auto string]
   set dec [mc_angle2dms $dec 90 zero 0 + string]
   set snvisu(candidate,sn_coords) "$ra $dec"
}

#------------------------------------------------------------
#  brief
#
proc ::sn_tarot::snCreateCandidateId { } {
   variable This
   global audace snvisu snconfvisu num caption rep

   set textes ""

   #--   fenetre de sortie
   set fcand $This.snvisu.cand

   if { [ winfo exists $fcand ] } {
      destroy $fcand
   }

   #--- Create the toplevel window $This.snvisu.cand
   #--- Cree la fenetre $This.snvisu.cand de niveau le plus haut
   toplevel $fcand -class Toplevel
   wm title $fcand $caption(sn_tarot,candidate)
   regsub -all {[\+|x]} [ wm geometry $This.snvisu ]  " " pos
   wm geometry $fcand 600x600+[expr {[ lindex $pos 1 ] + 20 } ]+[ expr {[ lindex $pos 2 ] + 0} ]
   wm resizable $fcand 1 1
   wm transient $fcand $This.snvisu
   wm protocol $fcand WM_DELETE_WINDOW "destroy $fcand"

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fcand.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fcand.frame1.label -text "$caption(sn_tarot,candidate) in [file rootname $snvisu(name)]" \
         -borderwidth 0 -relief flat
      pack $fcand.frame1.label -fill x -side left -padx 5 -pady 5
   pack $fcand.frame1 -side top -fill both -expand 0

   #--- cree un acsenseur vertical pour la console de retour d'etats
   frame $fcand.fra1
      scrollbar $fcand.fra1.scr1 -orient vertical \
         -command "$fcand.fra1.lst1 yview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr1 \
         -in $fcand.fra1 -side right -fill y
      set snvisu(status_scrl) $fcand.fra1.scr1

      scrollbar $fcand.fra1.scr2 -orient horizontal \
         -command "$fcand.fra1.lst1 xview" -takefocus 0 -borderwidth 1
      pack $fcand.fra1.scr2 \
         -in $fcand.fra1 -side bottom -fill x
      set snvisu(status_scrlx) $fcand.fra1.scr2

      #--- cree la console de retour d'etats
      text $fcand.fra1.lst1 \
         -borderwidth 1 -relief sunken  -height 6 -font {courier 8 bold} \
         -yscrollcommand "$fcand.fra1.scr1 set"  -xscrollcommand "$fcand.fra1.scr2 set" -wrap none
      pack $fcand.fra1.lst1 \
         -in $fcand.fra1 -expand yes -fill both \
         -padx 3 -pady 3
      set snvisu(status_list) $fcand.fra1.lst1
   pack $fcand.fra1 -side top -fill both -expand 1

   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait)\n"
   $snvisu(status_list) yview moveto 1.0
   update

   #--- Create the button 'Modify'
   #--- Cree le bouton 'Modify'
   button $fcand.but_modify -text $caption(sn_tarot,modify) \
      -borderwidth 2 -command {
         global snvisu audace
         set res [$snvisu(status_list) dump -text 1.0 end]
         set snvisu(candidate,textes) ""
         set n [llength $res]
         for {set k 1} {$k<$n} {incr k 3} {
            #::console::affiche_resultat "[lindex $res $k]"
            append snvisu(candidate,textes) [lindex $res $k]
         }
         set fichier "$snvisu(candidate,candidate_file)"
         set f [open $fichier w]
         puts -nonewline $f $snvisu(candidate,textes)
         close $f
       }
   pack $fcand.but_modify -side left -anchor w -padx 5 -pady 5
   $fcand.but_modify configure  -state disabled

   #--- Create the button 'OK'
   #--- Cree le bouton 'OK'
   button $fcand.but_ok -text $caption(sn_tarot,ok) -width 8 \
      -borderwidth 2 -command "destroy $fcand"
   pack $fcand.but_ok -side right -anchor w -padx 5 -pady 5
   $fcand.but_ok configure  -state disabled

   #--- La fenetre est active
   focus $fcand

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fcand

   # --- calculs
   set bufNo $num(buffer1)
   set ra_host [lindex $snvisu(candidate,host_coords) 0]
   set dec_host [lindex $snvisu(candidate,host_coords) 1]
   set ra_starref [lindex $snvisu(candidate,starref_coords) 0]
   set dec_starref [lindex $snvisu(candidate,starref_coords) 1]
   set ra_sn [lindex $snvisu(candidate,sn_coords) 0]
   set dec_sn [lindex $snvisu(candidate,sn_coords) 1]
   set pi [expr 4*atan(1.)]
   set dec [expr [mc_angle2deg $dec_host 90]*$pi/180.]
   set cosdec [expr cos($dec)]
   set dra [expr ([mc_angle2deg $ra_sn]-[mc_angle2deg $ra_host])*3600.]
   set ddec [expr ([mc_angle2deg $dec_sn 90]-[mc_angle2deg $dec_host 90])*3600.]
   set dratan [expr $dra/$cosdec]
   if {$dratan<0} { set sensew W } else { set sensew E }
   set dratan [expr abs($dratan)]
   if {$ddec<0} { set sensns S } else { set sensns N }
   set ddec [expr abs($ddec)]
   # --- taille de la fenetre de mesure
   set cdelt2 [lindex [buf$bufNo getkwd CDELT2] 1]
   set ech [expr abs($cdelt2)*3600]
   set dbox [expr int(10./$ech)]
   set exptime [lindex [buf$bufNo getkwd EXPOSURE] 1]
   # --- flux de l'etoile de reference
   set err [catch {vo_neareststar $ra_starref $dec_starref} starref]
   set err2 1
   if {$err==0} {
      set magoff 0
      set magr [lindex [lindex $starref 0] 5]
      set err2 [catch {expr $magr} magr]
   }
   if {($err==0)&&($err2==0)} {
      set mag_ref [expr $magr+$magoff]
      set xy [buf$bufNo radec2xy [list [mc_angle2deg $ra_starref] [mc_angle2deg $dec_starref 90]]]
      set x [lindex $xy 0]
      set y [lindex $xy 1]
      set x1 [expr int($x-$dbox/2)] ; set x2 [expr $x1+$dbox]
      set y1 [expr int($y-$dbox/2)] ; set y2 [expr $y1+$dbox]
      set box [list $x1 $y1 $x2 $y2]
      set valeurs [ buf$bufNo fitgauss $box ]
      set dif 0.
      set intx [lindex $valeurs 0]
      set xc [lindex $valeurs 1]
      set fwhmx [lindex $valeurs 2]
      set bgx [lindex $valeurs 3]
      set inty [lindex $valeurs 4]
      set yc [lindex $valeurs 5]
      set fwhmy [lindex $valeurs 6]
      set bgy [lindex $valeurs 7]
      set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
      set if1 [ expr $intx*$if0 ]
      set if2 [ expr $inty*$if0 ]
      set if0 [ expr ($if1+$if2)/2. ]
      set dif [ expr abs($if1-$if0) ]
      set flux_ref $if0
   } else {
      set flux_ref [expr 5000.*$exptime/240.]
      set mag_ref 15.4
   }
   # --- flux de l'etoile du GRB
   set xy [buf$bufNo radec2xy [list [mc_angle2deg $ra_sn] [mc_angle2deg $dec_sn 90]]]
   set x [lindex $xy 0]
   set y [lindex $xy 1]
   set x1 [expr int($x-$dbox/2)] ; set x2 [expr $x1+$dbox]
   set y1 [expr int($y-$dbox/2)] ; set y2 [expr $y1+$dbox]
   set box [list $x1 $y1 $x2 $y2]
   set valeurs [ buf$bufNo fitgauss $box ]
   set dif 0.
   set intx [lindex $valeurs 0]
   set xc [lindex $valeurs 1]
   set fwhmx [lindex $valeurs 2]
   set bgx [lindex $valeurs 3]
   set inty [lindex $valeurs 4]
   set yc [lindex $valeurs 5]
   set fwhmy [lindex $valeurs 6]
   set bgy [lindex $valeurs 7]
   set if0 [ expr $fwhmx*$fwhmy*.601*.601*3.14159265 ]
   set if1 [ expr $intx*$if0 ]
   set if2 [ expr $inty*$if0 ]
   set if0 [ expr ($if1+$if2)/2. ]
   set dif [ expr abs($if1-$if0) ]
   set flux_sn $if0
   set intxy [expr ($intx+$inty)/2.]
   set sigma [lindex [buf$bufNo stat $box] 7]
   set snr [expr $intxy/$sigma]
   set dmag [expr 1.1/$snr]
   # --- magnitude
   set mag [expr $mag_ref-2.5*log10($flux_sn/$flux_ref)]
   #
   set date [lindex [buf$bufNo getkwd DATE-OBS] 1]
   set dateref [lindex [buf$num(buffer2) getkwd DATE-OBS] 1]
   set telescop [lindex [buf$bufNo getkwd TELESCOP] 1]
   if {$telescop=="TAROT CALERN"} { set telescop "TAROT Calern observatory, France" ; set codmpc 910 }
   if {$telescop=="TAROT CHILI"} { set telescop "TAROT La Silla observatory, Chile" ; set codmpc 809 }
   if {$telescop=="Zadko Australia"} { set telescop "Zadko observatory, Australia " ; set codmpc D20 }
   #
   set ra [mc_angle2hms $ra_sn 360 zero 2 auto list]
   set dec [mc_angle2dms $dec_sn 90 zero 1 + list]
   set ra_sn [lindex $ra 0]h[lindex $ra 1]m[lindex $ra 2]s
   set dec_sn "[lindex $dec 0]o[lindex $dec 1]'[lindex $dec 2]\""
   set radec_sn "[lindex $ra 0] [lindex $ra 1] [lindex $ra 2] [lindex $dec 0] [lindex $dec 1] [lindex $dec 2]"
   set ra [mc_angle2hms $ra_host 360 zero 2 auto list]
   set dec [mc_angle2dms $dec_host 90 zero 1 + list]
   set ra_host [lindex $ra 0]h[lindex $ra 1]m[lindex $ra 2]s
   set dec_host "[lindex $dec 0]o[lindex $dec 1]'[lindex $dec 2]\""
   set radec_host "[lindex $ra 0] [lindex $ra 1] [lindex $ra 2] [lindex $dec 0] [lindex $dec 1] [lindex $dec 2]"
   #
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_mp)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   set minorplanets [::sn_tarot::MPChecker $date $ra_host $dec_host $codmpc]
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_sn)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   set recentsupernovae [::sn_tarot::SNChecker $date $ra_sn $dec_sn]
   #
   append textes "------------------------------------------\n"
   set texte "Personal comment about this candidate :"
   append textes "$texte\n\n"
   append textes "------------------------------------------\n"
   set texte "Example of email :"
   append textes "$texte\n\n"
   set texte "Send to: cbat@cfa.harvard.edu and copies to dgreen@cfa.harvard.edu & green@cfa.harvard.edu"
   append textes "$texte\n\n"
   set texte "Title: SN in [file rootname $snvisu(name)]"
   append textes "$texte\n\n"
   set texte "X. YYYYY on behalf of the TAROT Collaboration"
   append textes "$texte\n"
   set texte "reports the discovery of an apparent"
   append textes "$texte\n"
   set texte "supernova (mag about [format %.1f $mag] +/- [format %.1f $dmag]) on $date"
   append textes "$texte\n"
   set texte "using public images of the 0.25m robotic telescope"
   append textes "$texte\n"
   set texte "${telescop}."
   append textes "$texte\n"
   set texte "SN is located at about R.A. = $ra_sn, Decl. = $dec_sn"
   append textes "$texte\n"
   set texte "(equinox J2000.0), which is [format %.0f $dratan]\" $sensew and [format %.0f $ddec]\" $sensns from the nucleus of"
   append textes "$texte\n"
   set texte "[file rootname $snvisu(name)] ($ra_host $dec_host)."
   append textes "$texte\n"
   set texte "The supernova does not appear in an image taken $dateref."
   append textes "$texte\n"
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Check minor planets from MPC Checker:"
   append textes "$texte\n\n"
   set texte "$minorplanets"
   append textes "$texte\n"
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Check recent supernovae from CBAT:"
   append textes "$texte\n\n"
   set texte "$recentsupernovae"
   append textes "$texte\n"
   #
   $snvisu(status_list) insert end "$caption(sn_tarot,cand_wait_ar)\n"
   $snvisu(status_list) yview moveto 1.0
   update
   catch {
      set fichiers [lsort -decreasing [::sn_tarot::searchinArchives [file rootname $snvisu(name)]]]
      #
      append textes "\n"
      append textes "------------------------------------------\n"
      set texte "List of archives containing this galaxy:"
      append textes "$texte\n"
      foreach fichier $fichiers {
         set texte "$fichier"
         append textes "$texte\n"
      }
   }
   #
   append textes "\n"
   append textes "------------------------------------------\n"
   set texte "Details of computation:"
   append textes "$texte\n"
   set texte "snvisu(candidate,host_coords)=$snvisu(candidate,host_coords)"
   append textes "$texte\n"
   set texte "snvisu(candidate,starref_coords)=$snvisu(candidate,starref_coords)"
   append textes "$texte\n"
   set texte "snvisu(candidate,sn_coords)=$snvisu(candidate,sn_coords)"
   append textes "$texte\n"
   set texte "sampling=$ech arcsec/pix"
   append textes "$texte\n"
   set texte "starref=$starref"
   append textes "$texte\n"
   set texte "mag_ref=$mag_ref flux_ref=$flux_ref exptime=$exptime"
   append textes "$texte\n"
   set texte "mag=$mag flux_sn=$flux_sn"
   append textes "$texte\n"
   set texte "radec_host=$radec_host"
   append textes "$texte\n"
   #
   ::console::affiche_resultat "\n$textes"
   set candidate_file "[file rootname $snvisu(name)]_$snconfvisu(night)"
   set path "$rep(archives)/../alert"
   file mkdir $path
   set snvisu(candidate,candidate_file) [file normalize "$path/${candidate_file}.txt"]
   set snvisu(candidate,textes) "$textes"
   set fichier "$snvisu(candidate,candidate_file)"
   set f [open $fichier w]
   puts -nonewline $f $snvisu(candidate,textes)
   close $f

   $snvisu(status_list) delete 1.0 end
   $snvisu(status_list) insert end "$textes"
   $snvisu(status_list) yview moveto 0.0
   $fcand.but_modify configure  -state normal
   $fcand.but_ok configure  -state normal
   $fcand.frame1.label configure -text $snvisu(candidate,candidate_file)
   $fcand.fra1.lst1 configure -font {courier 8 bold}
   update
}

#------------------------------------------------------------
## @brief recherche les fichiers du dossier archives répondant
#  au nom d'une galaxie en particulier en excluant refgaltarot
#
#  utile pour rechercher les images d'une candidate
#
#  @param name nom de la galaxie
#  @return liste de fichiers
#
proc ::sn_tarot::searchinArchives { name } {
   global audace rep

   #--   chemin de unzip.exe
   if { $::tcl_platform(os) == "Linux" } {
      set tarot_unzip unzip
   } else {
      set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
   }

   set name [ string toupper $name ].fit
   set fichiers ""
   foreach archive $rep(list_archives) {
      set contents [ exec $tarot_unzip -l [ file join $rep(archives) $archive ] ]
      set k [ string first $name $contents ]
      if { $k>0 } { lappend fichiers $archive }
   }
   return $fichiers
}

# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl ; package require http
#------------------------------------------------------------
#  brief appel au Cheker SN des supernovae
#  @code
#  Exemple set lignes [::sn_tarot::SNChecker {2012 01 06.96} 21h12m08.86s -47d03'13.4  rochester_snlocations]
#  @endcode
#  param date courante
#  param ra
#  param dec
#  param urlsource rochester_snlocations par défaut
#  return liste des objets
#
proc ::sn_tarot::SNChecker { date ra dec {urlsource rochester_snlocations} } {
   global panneau caption

   set ra_cand [mc_angle2deg $ra ]
   set dec_cand [mc_angle2deg $dec 90 ]

   if {$urlsource=="rochester_snlocations"} {
      set url http://www.rochesterastronomy.org/snimages/snlocations.html
      if { [catch { set tok [ ::http::geturl $url ] } ErrInfo ] } {
         return "No internet connection."
      }

      upvar #0 $tok state

     if { [ ::http::status $tok ] != "ok" } {
         return "Problem while reading the html code."
      }

      #--   verifie le contenu
      set key [ string range [ ::http::data $tok ] 0 4 ]

      if { $key == "<?xml" } {
         return "Problem while decoding the html code."
      }

      set lignes [::http::data $tok ]
      ::http::cleanup $tok

      set lignes [split $lignes \n]
      set n [llength $lignes]
      set np 0
      set planets ""
      append planets "R.A.         Decl.        R.A.(hour) Decl.      Date           Host       Offsets   Typ Mag. Name\n"
      for {set k 0} {$k<$n} {incr k} {
         set ligne [lindex $lignes $k]
         #::console::affiche_resultat "A <$ligne>\n"
         if {$ligne==""} { continue }
         set key1 [string range $ligne 0 7]
         if {$key1!="<tr><td>"} {
            continue
         }
         #          1         2         3         4         5         6         7         8         9        10
         # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
         #<tr><td>00:00:09.340</td><td>-01:15:20.57</td><td>00.0025944</td><td>-01.255714</td><td>2016/08/30.428</td><td>Anonymous</td><td align="center">0.0</td><td>Ia</td><td>18.7*</td><td><a href="../supernova.html#pt2016foc" target="_self">2016foc</a></td><td></td></tr>
         set ligne [string range $ligne 8 end]
         set ligne [regsub -all " " $ligne "_"]
         set ligne [regsub -all "</td><td>" $ligne " "]
         set ligne [regsub -all "</td><td_align=\"center\">" $ligne " "]
         set k1 [string first < $ligne]
         set k2 [string first > $ligne]
         set ligne "[string range $ligne 0 [expr $k1-1]] [string range $ligne [expr $k2+1] end]"
         set k1 [string first < $ligne]
         set ligne "[string range $ligne 0 [expr $k1-1]]"
         # ---
         #           1         2         3         4         5         6         7         8         9        10
         #  123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
         # 00:05:16.120 -16:29:33.00 00.0878111 -16.492500 2016/05/16.310 2MASX_J00051603-1629348 1.5W_2.5N Ia 16.5  2016cky
         # R.A.         Decl.        R.A.(hour) Decl.      Date           Host                    Offsets   Typ Mag. Name
         set ra  [mc_angle2deg [string range $ligne  0   1]h[string range $ligne   3   4]m[string trim [string range $ligne   6  11]]s ]
         set dec [mc_angle2deg [string range $ligne 13  15]d[string range $ligne  17  18]m[string trim [string range $ligne  20  24]]s 90]
         set sep_arcmin [expr 60*[lindex [mc_sepangle $ra $dec $ra_cand $dec_cand] 0]]
         if {$sep_arcmin<3} {
            append planets "$ligne\n"
            incr np
         }
      }
      if {$np==0} {
         set planets "No recent supernova found from Rochester snlocations."
      }
   }
   if {$urlsource=="cbat_recent"} {
      set url http://www.cbat.eps.harvard.edu/lists/RecentSupernovae.html
      if { [catch { set tok [ ::http::geturl $url ] } ErrInfo ] } {
         return "No internet connection."
      }

      upvar #0 $tok state

     if { [ ::http::status $tok ] != "ok" } {
         return "Problem while reading the html code."
      }

      #--   verifie le contenu
      set key [ string range [ ::http::data $tok ] 0 4 ]

      if { $key == "<?xml" } {
         return "Problem while decoding the html code."
      }

      set lignes [::http::data $tok ]
      ::http::cleanup $tok

      set np 0
      set planets ""
      append planets "SN      Host Galaxy      Date         R.A.    Decl.    Offset   Mag.   Disc. Ref.            SN Position         Posn. Ref.       Type  SN      Discoverer(s)\n"
      set lignes [regsub -all \" $lignes " "]
      set lignes [regsub -all \{ $lignes " "]
      set lignes [regsub -all \} $lignes " "]
      set lignes [split $lignes \n]
      set n [llength $lignes]
      set valid 0
      for {set k 0} {$k<$n} {incr k} {
         set ligne [lindex $lignes $k]
         #::console::affiche_resultat "A <$ligne>\n"
         if {$ligne==""} { continue }
         set key1 [lindex $ligne 0]
         set key2 [lindex $ligne 1]
         if {($key1=="SN")&&($key2=="Host")} {
            set valid 1
            incr k 1
            continue
         }
         if {($key1=="</pre>")} {
            break
         }
         if {$valid>=1} {
            #          1         2         3         4         5         6         7         8         9        10
            # 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
            #2011jx  Anon.            2011 12 29  10 29.1 +46 05
           #SN      Host Galaxy      Date         R.A.    Decl.    Offset   Mag.   Disc. Ref.            SN Position         Posn. Ref.       Type  SN      Discoverer(s)
            #2011iv  NGC 1404         2011 12 02  03 38.9 -35 36    7W   8N  12.8   CBET 2940       03 38 51.35 -35 35 32.0   CBET 2940        Ia    2011iv  Parker

            # --- on enleve les balises <>
            set k2 [string first < $ligne]
            set reste [string range $ligne [expr $k2+1] end]
            set newligne ""
            for {set kk 0} {$kk<20} {incr kk } {
               set k1 [string first > $reste]
               set k2 [string first < $reste]
               if {$k2==-1} {
                  set isole [string range $reste [expr $k1+1] end]
               } else {
                  set isole [string range $reste [expr $k1+1] [expr $k2-1]]
               }
               append newligne "$isole"
               if {$k2==-1} { break }
               set reste [string range $reste [expr $k2+1] end]
            }
            set ligne $newligne
            set ra  [mc_angle2deg [string range $ligne 87  88]h[string range $ligne  90  91]m[string range $ligne  93  97]s ]
            set dec [mc_angle2deg [string range $ligne 99 101]d[string range $ligne 103 104]m[string range $ligne 106 109]s 90 ]
            set sep_arcmin [expr 60*[lindex [mc_sepangle $ra $dec $ra_cand $dec_cand] 0]]
            #::console::affiche_resultat "[lindex $ligne 0] sep_arcmin=$sep_arcmin    ($ra $dec $ra_cand $dec_cand)\n"
            if {$sep_arcmin<3} {
               append planets "$ligne\n"
               incr np
            }
            incr valid
         }
      }
      if {$np==0} {
         set planets "No recent supernova found from CBAT."
      }
   }
   return $planets
}

#------------------------------------------------------------
#  brief appel au Cheker MPC des astéroïdes
#  @code
#  Exemple [::sn_tarot::MPChecker {2012 01 06.96} {10 34 67 h} {3 45 10} 500]
#  @endcode
#  param date courante
#  param ra
#  param dec
#  param obscod code l'observatoire
#  return liste des objets
#
proc ::sn_tarot::MPChecker { date ra dec {obscod 500} } {

   #set date {2012 01 06.96}
   #set ra {10 34 67 h}
   #set dec {3 45 10}
   #set obscod 500
   set res [mc_date2ymdhms $date]
   set y [lindex $res 0]
   set m [lindex $res 1]
   set d [format %.2f [expr 1.*[lindex $res 2]+[lindex $res 3]/24.+[lindex $res 4]/1440.+[lindex $res 5]/86400.]]
   set ra [mc_angle2hms $ra 360 zero 2 auto list]
   set dec [mc_angle2dms $dec 90 zero 1 auto list]
   #::console::affiche_resultat "<ra=$ra> <dec=$dec>\n"
   set radius 10
   # set url http://mpcapp1.cfa.harvard.edu/cgi-bin/mpcheck.cgi
   #set url http://scully.cfa.harvard.edu/cgi-bin/mpcheck.cgi
   #set url http://www.minorplanetcenter.net/cgi-bin/mpeph2.cgi ; # ne fonctionne pas
   set url  http://www.minorplanetcenter.net/cgi-bin/mpcheck.cgi

   set query [::http::formatQuery year $y month $m day $d which pos ra $ra decl $dec TextArea {} radius $radius limit 22 oc $obscod sort d mot m tmot t pdes u needed f ps n type p]
   #::console::affiche_resultat "< $query >\n"

   if { [catch { set tok [ ::http::geturl $url -query $query ] } ErrInfo ] } {
      return "No internet connection."
   }

   upvar #0 $tok state

  if { [ ::http::status $tok ] != "ok" } {
      return "Problem while reading the html code."
   }

   #--   verifie le contenu
   set key [ string range [ ::http::data $tok ] 0 4 ]

   if { $key == "<?xml" } {
      return "Problem while decoding the html code."
   }

   set lignes [::http::data $tok ]
   ::http::cleanup $tok

   set np 0
   set planets ""
   append planets " Object designation         R.A.      Decl.     V       Offsets     Motion/min  Orbit  Further observations?\n"
   append planets "                           h  m  s     d  '  \"        R.A.   Decl.  Mot.   PA          Comment (Elong/Decl/V at date 1)\n"
   set lignes [regsub -all \" $lignes " "]
   set lignes [split $lignes \n]
   set n [llength $lignes]
   set valid 0
   for {set k 0} {$k<$n} {incr k} {
      set ligne [lindex $lignes $k]
      set key1 [lindex $ligne 0]
      set key2 [lindex $ligne 1]
      if {($key1=="Object")&&($key2=="designation")} {
         set valid 1
         incr k 2
         continue
      }
      if {($key1=="</pre>")} {
         break
      }
      if {$valid==1} {
         #::console::affiche_resultat "$ligne\n"
         append planets "$ligne\n"
         incr np
      }
   }
   if {$np==0} {
      set planets "No minor planet found in the image."
   }
   return $planets
}

#------------------------------------------------------------
#  brief
#  param home coordonnées GPS
#  return date de la nuit courante et créneau horaire
#
proc ::sn_tarot::prevnight { home } {

   set date [::audace::date_sys2ut]
   set jd [mc_date2jd $date]
   set elev_sun_set 0
   set elev_sun_twilight 0
   set res [mc_nextnight $date $home $elev_sun_set $elev_sun_twilight]
   set mer2mer [lindex $res 0]
   set rise2rise [lindex $res 1]
   set prev_sun_rise [lindex $rise2rise 0]
   set mer [lindex $rise2rise 1]
   set sun_set [lindex $rise2rise 2]
   set dusk [lindex $rise2rise 3]
   set dawn [lindex $rise2rise 4]
   set next_sun_rise [lindex $rise2rise 5]
   if {$jd<$sun_set} {
      set skylight Day
   } elseif {$jd<$dusk} {
      set skylight Dusk
   } elseif {$jd<$dawn} {
      set skylight Night
   } else {
      set skylight Dawn
   }
   set res [mc_date2ymdhms [expr $prev_sun_rise-1]]
   set res "[format %04d [lindex $res 0]][format %02d [lindex $res 1]][format %02d [lindex $res 2]]"
   return [list $res $skylight]
}


#------------------------------------------------------------
#  brief
#  param bufNo numéro du buffer
#  return 0 ou 1
#
proc ::sn_tarot::snVerifWCS { bufNo } {

   set calib 1
   foreach kwd [ list CRPIX1 CRPIX2 CRVAL1 CRVAL2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0 ] eq ""} {  set calib 0 }
   }
   set nouveau 0
   foreach kwd [ list CD1_1 CD1_2 CD2_1 CD2_2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0 ] != ""} { incr nouveau }
   }
   set classic 0
   foreach kwd [ list CDELT1 CDELT2 CROTA1 CROTA2 ] {
      if { [ lindex [buf$bufNo getkwd $kwd ] 0] != ""} { incr classic }
   }

   if {(($calib == 1)&&($nouveau==4)) || (($calib == 1)&&($classic>=3)) } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  brief
#  param bufNo numéro du buffer
#  return liste RA et DEC
#
proc ::sn_tarot::snCenterRaDec { bufNo } {

   set res [snVerifWCS $bufNo]
   if {$res==0} {
      return ""
   }
   set x [expr [buf$bufNo getpixelswidth]/2.]
   set y [expr [buf$bufNo getpixelsheight]/2.]
   set radec [buf$bufNo xy2radec [list $x $y]]
   set ra [lindex $radec 0]
   set dec [lindex $radec 1]
   set ra [mc_angle2hms $ra 360 zero 2 auto list]
   set dec [mc_angle2dms $dec 90 zero 1 + list]
   return "{ $ra $dec }"
}

#------------------------------------------------------------
#  brief établit les coordonnées du centre de l'image et son champ
#  les paramètres sont issus des mot clés de l'image ; les valeurs angulaires sont en degrés
#  param naxis1
#  param naxis2
#  param crota2
#  param cdelt1
#  param cdelt2
#  param crpix1
#  param crpix2
#  param crval1
#  param crval2
#  return liste des coordonnées RaDec du centre de l'image et champ de l'image en degrés
#
proc ::sn_tarot::getImgCenterRaDec { naxis1 naxis2 crota2 cdelt1 cdelt2 crpix1 crpix2 crval1 crval2 } {

   set pi [ expr {4*atan(1)} ]
   set coscrota2 [expr cos($crota2*$pi/180.)]
   set sincrota2 [expr sin($crota2*$pi/180.)]
   set cd11 [expr $pi/180*($cdelt1*$coscrota2)]
   set cd12 [expr $pi/180*(abs($cdelt2)*$cdelt1/abs($cdelt1)*$sincrota2)]
   set cd21 [expr $pi/180*(-abs($cdelt1)*$cdelt2/abs($cdelt2)*$sincrota2)]
   set cd22 [expr $pi/180*($cdelt2*$coscrota2)]

   set x [expr $naxis1/2.]
   set y [expr $naxis2/2.]
   set dra  [expr $cd11*($x-($crpix1-0.5)) + $cd12*($y-($crpix2-0.5))]
   set ddec [expr $cd21*($x-($crpix1-0.5)) + $cd22*($y-($crpix2-0.5))]
   set coscrval2 [expr cos($crval2*$pi/180.)]
   set sincrval2 [expr sin($crval2*$pi/180.)]
   set delta [expr $coscrval2 -$ddec*$sincrval2 ]
   set gamma [expr sqrt($dra*$dra + $delta*$delta) ]
   set ra [expr $crval1 + 180./$pi*atan($dra/$delta)]
   set dec [expr 180./$pi*atan( ($sincrval2+$ddec*$coscrval2)/$gamma )]

   set fov_x [ format %.6f [expr abs($cdelt1)*$naxis1]]
   set fov_y [ format %.6f [expr abs($cdelt2)*$naxis2]]

   return [ list $ra $dec $fov_x $fov_y ]
}

# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl ; ::sn_tarot::cmdAnalyzeCandidateId
#------------------------------------------------------------
## @brief commande du bouton "Bilan des candidates" du panneau
#
proc ::sn_tarot::cmdAnalyzeCandidateId { } {
   variable This
   global audace snvisu snconfvisu num caption rep

   set textes ""

   #--   fenetre de sortie
   set fancand $This.snvisu.ancand

   if { [ winfo exists $fcand ] } {
      destroy $fancand
   }

   #--- Create the toplevel window $This.snvisu.ancand
   #--- Cree la fenetre $This.snvisu.ancand de niveau le plus haut
   toplevel $fancand -class Toplevel
   wm title $fancand $caption(sn_tarot,candidate)
   regsub -all {[\+|x]} [ wm geometry $fancand ]  " " pos
   wm geometry $fancand 600x600+[expr {[ lindex $pos 1 ] + 20 } ]+[ expr {[ lindex $pos 2 ] + 0} ]
   wm resizable $fancand 1 1
   if {[info exists $This.snvisu]==1} {
      wm transient $fancand $This.snvisu
   }
   wm protocol $fancand WM_DELETE_WINDOW "destroy $fancand"

   #--- Create the label and the radiobutton
   #--- Cree l'etiquette et les radiobuttons
   frame $fancand.frame1 -borderwidth 0 -relief raised
      #--- Label
      label $fancand.frame1.label -text " " \
         -borderwidth 0 -relief flat
      pack $fancand.frame1.label -fill x -side left -padx 5 -pady 5
   pack $fancand.frame1 -side top -fill both -expand 0

   #--- cree un acsenseur vertical pour la console de retour d'etats
   frame $fancand.fra1
      scrollbar $fancand.fra1.scr1 -orient vertical \
         -command "$fancand.fra1.lst1 yview" -takefocus 0 -borderwidth 1
      pack $fancand.fra1.scr1 \
         -in $fancand.fra1 -side right -fill y
      set snvisu(status_scrl) $fancand.fra1.scr1

      scrollbar $fancand.fra1.scr2 -orient horizontal \
         -command "$fancand.fra1.lst1 xview" -takefocus 0 -borderwidth 1
      pack $fancand.fra1.scr2 \
         -in $fancand.fra1 -side bottom -fill x
      set snvisu(status_scrlx) $fancand.fra1.scr2

      #--- cree la console de retour d'etats
      text $fancand.fra1.lst1 \
         -borderwidth 1 -relief sunken  -height 6 -font {courier 8 bold} \
         -yscrollcommand "$fancand.fra1.scr1 set"  -xscrollcommand "$fancand.fra1.scr2 set" -wrap none
      pack $fancand.fra1.lst1 \
         -in $fancand.fra1 -expand yes -fill both \
         -padx 3 -pady 3
      set snvisu(status_list) $fancand.fra1.lst1
   pack $fancand.fra1 -side top -fill both -expand 1

   $snvisu(status_list) insert end "$caption(sn_tarot,ancand_wait)\n"
   $snvisu(status_list) yview moveto 1.0
   update

   #--- Create the button 'Modify'
   #--- Cree le bouton 'Modify'
#    button $fancand.but_modify -text $caption(sn_tarot,modify) \
#       -borderwidth 2 -command {
#          global snvisu audace
#          set res [$snvisu(status_list) dump -text 1.0 end]
#          set snvisu(candidate,textes) ""
#          set n [llength $res]
#          for {set k 1} {$k<$n} {incr k 3} {
#             #::console::affiche_resultat "[lindex $res $k]"
#             append snvisu(candidate,textes) [lindex $res $k]
#          }
#          set fichier "$snvisu(candidate,candidate_file)"
#          set f [open $fichier w]
#          puts -nonewline $f $snvisu(candidate,textes)
#          close $f
#        }
#    pack $fancand.but_modify -side left -anchor w -padx 5 -pady 5
#    $fancand.but_modify configure  -state disabled

   #--- Create the button 'OK'
   #--- Cree le bouton 'OK'
   button $fancand.but_ok -text $caption(sn_tarot,ok) -width 8 \
      -borderwidth 2 -command "destroy $fancand"
   pack $fancand.but_ok -side right -anchor w -padx 5 -pady 5
   $fancand.but_ok configure  -state disabled

   #--- La fenetre est active
   focus $fancand

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $fancand

   # --- File readings
   update
   set path "$rep(archives)/../alert"
   set fichiers [lsort [glob -nocomplain ${path}/*.txt]]
   set ficlists ""
   set objname0 ""
   set objdates ""
   foreach fichier $fichiers {
      set fics [split [file tail $fichier] _]
      set objname [lindex $fics 0]
      set objdate [lindex $fics 3]
      if {$objname!=$objname0} {
         if {$objname0!=""} {
            lappend ficlists $comment
         }
         set comment [list $objname $objdate $fichier]
      } else {
         lappend comment $fichier
      }
      set objname0 $objname
   }
   set ficlists [lsort -index 1 -decreasing $ficlists]
   set objname0 ""
   set comments "$caption(sn_tarot,result_analysis)\n\n"
   foreach ficlist $ficlists {
      set objname [lindex $ficlist 0]
      set fichiers [lrange $ficlist 2 end]
      append comments "---------------------------\n"
      append comments "--- $objname ---\n"
      foreach fichier $fichiers {
         append comments "[file tail $fichier]\n"
         #::console::affiche_resultat "fichier=[file normalize $fichier]\n"
         $snvisu(status_list) insert end "[file normalize $fichier]\n"
         $snvisu(status_list) yview moveto 1.0
         set f [open $fichier r]
         set lignes [split [read $f] \n]
         close $f
         set fics [split [file tail $fichier] _]
         set objname [lindex $fics 0]
         set objdate [lindex $fics 3]
         if {$objname!=$objname0} {
            set comment ""
         }
         set n [expr [llength $lignes]-1]
         #::console::affiche_resultat "n=$n\n"
         for {set k 0} {$k<$n} {incr k} {
            set ligne [lindex $lignes $k]
            set key [string range $ligne 0 36]
            #::console::affiche_resultat "<$key>\n"
            if {[string compare $key "Personal comment about this candidate"]==0} {
               incr k
               for {set kk $k} {$kk<$n} {incr kk} {
                  set ligne [lindex $lignes $kk]
                  set key [string range $ligne 0 4]
                  if {$key=="-----"} {
                     break
                  } else {
                     if {$ligne!=""} {
                        append comments "$ligne\n"
                     }
                  }
               }
            }
         }
      }
      set arfichiers [lsort -decreasing [::sn_tarot::searchinArchives [file rootname $objname]]]
      append comments "-> List of archives:\n"
      foreach arfichier $arfichiers {
         append comments "$arfichier\n"
      }
      append comments "---------------------------\n\n"

   }

   #
   ::console::affiche_resultat "\n$comments"

   $snvisu(status_list) delete 1.0 end
   $snvisu(status_list) insert end "$comments"
   $snvisu(status_list) yview moveto 0.0
   #$fcand.but_modify configure  -state normal
   $fcand.but_ok configure  -state normal
   #$fcand.frame1.label configure -text $snvisu(candidate,candidate_file)
   $fcand.fra1.lst1 configure -font {courier 8 bold}
   update
}

# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl ; ::sn_tarot::subopt
#-------------------------------------------------------------------------------------------------
# brief subopt pour soustraire les objets d'une image à partir d'une image de référence
# utile pour effectuer la photométrie des supernovae
#
# Entrées :
# * file_image : Fichier FITS de l'image numéro 1
# * file_image_reference : Fichier FITS de l'image numéro 2 (référence)
# * clear_stars : =0 n'efface pas les étoiles
#                 =1 efface toutes les étoiles sauf celle du centre
#                 =2 efface toutes les étoiles et rayon de 2 autour de celle du centre
#                 =3 efface toutes les étoiles
# * kappa : Dans les cas clear_stars>0 c'est le coef de la FWHM pour supprimer les étoiles
#
# List :
# col0  : RA (deg)
# col1  : DEC (deg)
# col2  : DATE-OBS image 1 (JD)
# col3  : EXPOSURE image 1 (s)
# col4  : X 1 (pixel)
# col5  : Y 1 (pixel)
# col6  : FLUX image 1 (ADU)
# col7  : FLUXERR image 1 (ADU)
# col8  : FWHM image 1 (pixel)
# col9  : BACKGROUND image 1 (pixel)
# col10 : DIST_CENTER image 1 (pixel)
# col11 : DATE-OBS image 2 (JD)
# col12 : EXPOSURE image 2 (s)
# col13 : X 2 (pixel)
# col14 : Y 2 (pixel)
# col15 : FLUX image 2 (ADU)
# col16 : FLUXERR image 2 (ADU)
# col17 : FWHM image 2 (pixel)
# col18 : BACKGROUND image 2 (pixel)
# col19 : DIST_CENTER image 2 (pixel)
#
proc ::sn_tarot::subopt { file_image file_image_reference clear_stars {kappa 1.8} } {
   global audace

   ::console::disp "$file_image\n$file_image_reference\nclear_stars $clear_stars\nkappa $kappa\n"

   set radius_over 5.
   set bufno $audace(bufNo)
   # --- Verif images
   set pathim $audace(rep_images)
   set res [file split ${file_image}]
   if {[llength $res]==1} {
      set fic1 "${pathim}/${file_image}"
   } else {
      set fic1 "${file_image}"
   }
   if {[string length [file extension $fic1]]==0} {
      append fic1 [buf$bufno extension]
   }
   loadima $fic1
   set exposure1 [lindex [buf$bufno getkwd EXPOSURE] 1]
   set dateobsjd1 [mc_date2jd [lindex [buf$bufno getkwd DATE-OBS] 1]]
   set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]
   set res [file split ${file_image_reference}]
   if {[llength $res]==1} {
      set fic2 "${pathim}/${file_image_reference}"
   } else {
      set fic2 "${file_image_reference}"
   }
   if {[string length [file extension $fic2]]==0} {
      append fic2 [buf$bufno extension]
   }
   loadima $fic2
   set exposure2 [lindex [buf$bufno getkwd EXPOSURE] 1]
   set dateobsjd2 [mc_date2jd [lindex [buf$bufno getkwd DATE-OBS] 1]]
   # --- Sextractor
   set pathsex [pwd]
   #::console::affiche_resultat "sextractor $fic1\n"
   sextractor $fic1
   file copy -force -- "$pathsex/catalog.cat" "$pathsex/catalog1.txt"
   #::console::affiche_resultat "sextractor $fic2\n"
   sextractor $fic2
   file copy -force -- "$pathsex/catalog.cat" "$pathsex/catalog2.txt"
   # --- params
   #::console::affiche_resultat "analyze $pathsex/config.param\n"
   set f [open "$pathsex/config.param" r]
   set lignes [split [read $f] \n]
   close $f
   set params ""
   foreach ligne $lignes {
      set ligne [lindex $ligne 0]
      if {$ligne==""} {
         continue
      }
      set diese [string index $ligne 0]
      if {$diese=="#"} {
         continue
      }
      lappend params $ligne
   }
   set k [lsearch $params X_IMAGE]
   set kx $k
   set k [lsearch $params Y_IMAGE]
   set ky $k
   set k [lsearch $params FLUX_BEST]
   set kflux $k
   set k [lsearch $params FLUXERR_BEST]
   set kfluxerr $k
   set k [lsearch $params FWHM_IMAGE]
   set kfwhm $k
   set k [lsearch $params BACKGROUND]
   set kbackground $k
   #::console::affiche_resultat "indexes x=$kx y=$ky flux=$kflux fluxerr=$kfluxerr\n"
   # ---
   set vignetting 1
   #::console::affiche_resultat "vignetting=$vignetting\n"
   #::console::affiche_resultat "analyze star list 1\n"
   loadima $fic1
   set err [catch {set radec [buf$bufno xy2radec [list 1 1]]} msg ]
   if {$err==0} {
      set wcs 1
      #::console::affiche_resultat "wcs keywords found\n"
   } else {
      set wcs 0
      error "wcs keywords not found"
   }
   set f [open "$pathsex/catalog1.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set t ""
   set stars ""
   set exposure $exposure1
   set vignetting2 [expr $vignetting*$vignetting]
   foreach ligne $lignes {
      if {[lindex $ligne 0]==""} {
         continue
      }
      set x [lindex $ligne $kx]
      set y [lindex $ligne $ky]
      if {$vignetting<1} {
         set dx [expr 1.*($x-$naxis1/2)/($naxis1/2)]
         set dy [expr 1.*($y-$naxis2/2)/($naxis2/2)]
         set r2 [expr $dx*$dx+$dy*$dy]
         if {$r2>$vignetting2} {
            continue
         }
      }
      set dx [expr $x-$naxis1/2.]
      set dy [expr $y-$naxis2/2.]
      set distc [expr sqrt($dx*$dx+$dy*$dy)]
      set radec [buf$bufno xy2radec [list $x $y]]
      set ra [lindex $radec 0]
      set dec [lindex $radec 1]
      set flux [expr [lindex $ligne $kflux]/1.]
      set fluxerr [expr [lindex $ligne $kfluxerr]/1.]
      set fwhm [lindex $ligne $kfwhm]
      set background [lindex $ligne $kbackground]
      lappend stars [list $x $y $ra $dec $flux $fluxerr $fwhm $background $distc]
   }
   set star1s [lsort -increasing -real -index 3 $stars]
   #::console::affiche_resultat "[llength $star1s] stars found in the list 1\n"
   # ---
   #::console::affiche_resultat "analyze star list 2\n"
   loadima $fic2
   set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]
   set f [open "$pathsex/catalog2.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set t ""
   set stars ""
   set exposure $exposure2
   foreach ligne $lignes {
      if {[lindex $ligne 0]==""} {
         continue
      }
      set x [lindex $ligne $kx]
      set y [lindex $ligne $ky]
      if {$vignetting<1} {
         set dx [expr 1.*($x-$naxis1/2)/($naxis1/2)]
         set dy [expr 1.*($y-$naxis2/2)/($naxis2/2)]
         set r2 [expr $dx*$dx+$dy*$dy]
         if {$r2>$vignetting2} {
            continue
         }
      }
      set dx [expr $x-$naxis1/2.]
      set dy [expr $y-$naxis2/2.]
      set distc [expr sqrt($dx*$dx+$dy*$dy)]
      set radec [buf$bufno xy2radec [list $x $y]]
      set ra [lindex $radec 0]
      set dec [lindex $radec 1]
      set flux [expr [lindex $ligne $kflux]/1.]
      set fluxerr [expr [lindex $ligne $kfluxerr]/1.]
      set fwhm [lindex $ligne $kfwhm]
      set background [lindex $ligne $kbackground]
      lappend stars [list $x $y $ra $dec $flux $fluxerr $fwhm $background $distc]
   }
   set star2s [lsort -increasing -real -index 3 $stars]
   #::console::affiche_resultat "[llength $star2s] stars found in the list 2\n"
   # --- appariement
   #::console::affiche_resultat "match stars in the two lists\n"
   if {$wcs==1} {
      set res [lindex [buf$bufno getkwd CDELT1] 1]
      set sepmax [expr abs($res*3600)*$radius_over] ; # 1 pixel en arcsec
   } else {
      set sepmax [expr 1.*$radius_over] ; # 1 pixel
   }
   set stars ""
   set nstar 0
   set k1 0
   foreach star1 $star1s {
      set x1 [lindex $star1 0]
      set y1 [lindex $star1 1]
      set ra1 [lindex $star1 2]
      set dec1 [lindex $star1 3]
      set flux1 [lindex $star1 4]
      set fluxerr1 [lindex $star1 5]
      set fwhm1 [lindex $star1 6]
      set background1 [lindex $star1 7]
      set distc1 [lindex $star1 8]
      set kmatch -1
      set n [llength $star2s]
      for {set k 0} {$k<$n} {incr k} {
         set star2 [lindex $star2s $k]
         if {$star2==""} {
            continue
         }
         set x2 [lindex $star2 0]
         set y2 [lindex $star2 1]
         set ra2 [lindex $star2 2]
         set dec2 [lindex $star2 3]
         set flux2 [lindex $star2 4]
         set fluxerr2 [lindex $star2 5]
         set fwhm2 [lindex $star2 6]
         set background2 [lindex $star2 7]
         set distc2 [lindex $star2 8]
         set ddec [expr ($dec2-$dec1)*3600.]
         if {$ddec<-$sepmax} {
            continue
         }
         if {$ddec>$sepmax} {
            break
         }
         set dra [expr abs($ra2-$ra1)]
         if {$dra>180} {
            set dra [expr 360.-$dra]
         }
         set dra [expr $dra*3600.]
         if {$dra>$sepmax} {
            continue
         }
         set flux1 [lindex $star1 4]
         set flux2 [lindex $star2 4]
         set texte ""
         append texte "[format %9.5f $ra1] [format %+9.5f $dec1]"
         append texte "   "
         append texte "[format %15.6f $dateobsjd1] [format %e $exposure1] [format %7.2f $x1] [format %7.2f $y1] [format %e $flux1] [format %e $fluxerr1] [format %5.2f $fwhm1] [format %8.1f $background1] [format %5.1f $distc1]"
         append texte "   "
         append texte "[format %15.6f $dateobsjd2] [format %e $exposure2] [format %7.2f $x2] [format %7.2f $y2] [format %e $flux2] [format %e $fluxerr2] [format %5.2f $fwhm2] [format %8.1f $background2] [format %5.1f $distc2]"
         append stars "$texte\n"
         incr nstar
         #::console::affiche_resultat "[format %5d $nstar] : [lrange $texte 0 1]\n"
         #::console::affiche_resultat "=== [format %5d $nstar] : $x1 $y1   $x2 $y2\n"
         set kmatch $k
         break
      }
      if {$kmatch>=0} {
         set star2s [lreplace $star2s $kmatch $kmatch ""]
      }
      incr k1
   }
   #::console::affiche_resultat "$nstar stars matched in the two lists\n"
   # --- sauve le fichier resultat
#    set fic "$pathim/${file_common}.txt"
#    ::console::affiche_resultat "save common star list in file $fic\n"
#    set f [open $fic w]
#    puts -nonewline $f $stars
#    close $f
   set stars [lrange [split $stars \n] 0 end-1]
   # --- Calcule le coefficient multiplicateur
   set mults ""
   foreach star $stars {
      set flux1 [lindex $star  6]
      set flux2 [lindex $star 15]
      set mult [expr $flux1/$flux2]
      lappend mults $mult
   }
   set mults [lsort -real $mults]
   set nm [llength $mults]
   set mult [lindex $mults [expr int($nm/2)]]
   #::console::affiche_resultat "mult=$mult ($mults)\n"
   # --- efface les etoiles de la premiere image
   loadima $fic2
   mult $mult
   saveima mask
   buf$bufno imaseries "REGISTERFINE delta=3 oversampling=10 file=${fic1}"
   saveima mask2
   loadima $fic1
   sub mask2 0
   if {$clear_stars>=1} {
      foreach star $stars {
         set xc [lindex $star 4]
         set yc [lindex $star 5]
         set fwhm1 [lindex $star 8]
         set background1 [lindex $star 9]
         set distc1 [lindex $star 10]
         set background2 [lindex $star 18]
         if {($distc1<3)&&($clear_stars==1)} {
            continue
         } elseif {($distc1<3)&&($clear_stars==2)} {
            set rayon 2
         } else {
            set rayon [expr ${kappa}*$fwhm1]
         }
         set rayon2 [expr $rayon*$rayon]
         set x1 [expr int($xc-$rayon)] ; if {$x1<1} {set x1 1}
         set x2 [expr int($xc+$rayon)] ; if {$x2>$naxis1} {set x2 $naxis1}
         set y1 [expr int($yc-$rayon)] ; if {$y1<1} {set y1 1}
         set y2 [expr int($yc+$rayon)] ; if {$y2>$naxis2} {set y2 $naxis2}
         set val [expr $background1-$background2*$mult]
         for {set x $x1} {$x<=$x2} {incr x} {
            set dx [expr $x-$xc]
            for {set y $y1} {$y<=$y2} {incr y} {
               set dy [expr $y-$yc]
               set dist2 [expr $dx*$dx+$dy*$dy]
               if {$dist2>$rayon2} { continue }
               buf$bufno setpix [list $x $y] $val
            }
         }
      }
   }
   return $stars
}

# source $audace(rep_install)/gui/audace/plugin/tool/sn_tarot/sn_tarot_macros.tcl ; ::sn_tarot::snAnalyzeAll
#------------------------------------------------------------
#  brief
#
proc ::sn_tarot::snAnalyzeAll { } {
   global audace snvisu snconfvisu num caption rep

   set textes ""

   # --- File readings
   set ficlists ""
   set objname0 ""
   set objdates ""
   foreach path0 {alert alert/old} {
      set path "$rep(archives)/../${path0}"
      set fichiers [lsort [glob -nocomplain ${path}/*.txt]]
      foreach fichier $fichiers {
        set fics [split [file tail $fichier] _]
        set objname [lindex $fics 0]
        set objdate [lindex $fics 3]
        if {$objname!=$objname0} {
          if {$objname0!=""} {
            lappend ficlists $comment
          }
          set comment [list $objname $objdate $fichier]
        } else {
          lappend comment $fichier
        }
        set objname0 $objname
      }
   }

   set name_note_comment ""
   set nctotal 0
   #
   set ficlists [lsort -index 1 -decreasing $ficlists]
   set objname0 ""
   set comments "$caption(sn_tarot,result_analysis)\n\n"
   foreach ficlist $ficlists {
      set objname [lindex $ficlist 0]
      set fichiers [lrange $ficlist 2 end]
      append comments "---------------------------\n"
      append comments "--- $objname ---\n"
      foreach fichier $fichiers {
         append comments "[file tail $fichier]\n"
         #::console::affiche_resultat "fichier=[file normalize $fichier]\n"
         set f [open $fichier r]
         set lignes [split [read $f] \n]
         close $f
         set fics [split [file tail $fichier] _]
         set objname [lindex $fics 0]
         set objdate [lindex $fics 3]
         if {$objname!=$objname0} {
            set comment ""
         }
         set n [expr [llength $lignes]-1]
         #::console::affiche_resultat "n=$n\n"
         for {set k 0} {$k<$n} {incr k} {
            set ligne [lindex $lignes $k]
            set key [string range $ligne 0 36]
            #::console::affiche_resultat "<$key>\n"
            if {[string compare $key "Personal comment about this candidate"]==0} {
               incr k
               for {set kk $k} {$kk<$n} {incr kk} {
                  set ligne [lindex $lignes $kk]
                  set key [string range $ligne 0 4]
                  if {$key=="-----"} {
                     break
                  } else {
                     set note -1
                     if {[string first /5 $ligne]==1} {
                        set note [lindex [regsub /5 $ligne " "] 0]
                     } else {
                        if {[string first ( [string trim $ligne]]==0} {
                           set note -2
                        }
                     }
                     if {$ligne!=""} {
                        incr nctotal
                        if {($note==-1)||($note==0)} { set note 1 }
                        incr nctotals($note)
                        append name_note_comment "$objname $note \"${ligne}\" \n"
                        append comments "$ligne\n"
                    }
                  }
               }
            }
         }
      }
      append comments "---------------------------\n\n"

   }
   ::console::affiche_resultat "\n$comments"

   ::console::affiche_resultat "\n$name_note_comment\n"
   #--   chemin de unzip.exe
   if { $::tcl_platform(os) == "Linux" } {
      set tarot_unzip unzip
   } else {
      set tarot_unzip [ file join $audace(rep_plugin) tool sn_tarot unzip.exe ]
   }
   foreach site {Calern Chili} {
      set nftotal 0
      foreach path0 {archives archives/old} {
         set path "$rep(archives)/../${path0}"
         set fichiers [lsort [glob -nocomplain ${path}/Tarot_${site}*.zip]]
         foreach fichier $fichiers {
            catch { exec $tarot_unzip -l $fichier } res
            set nf [lindex [string range $res end-25 end] 0]
            incr nftotal $nf
         }
      }
      ::console::affiche_resultat "Total $site = $nftotal images\n"
   }

   ::console::affiche_resultat "Total candidates = $nctotal candidates\n"
   set names [lsort -real [array names nctotals]]
   foreach name $names {
      ::console::affiche_resultat "Total candidates $name = $nctotals($name) candidates [format %.1f [expr 100.*$nctotals($name)/$nctotal]]%\n"
   }

}


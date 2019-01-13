#
## @file tkutil.tcl
#  @brief Regroupement d'utilitaires
#  @author Robert DELMAS
#  @namespace tkutil
#  @brief Regroupement d'utilitaires
#  $Id: tkutil.tcl 13995 2016-07-17 10:09:29Z robertdelmas $
#  @todo vérifier et compléter la documentation
#

namespace eval ::tkutil {
   #--- Chargement des captions
   source [ file join $::audace(rep_caption) tkutil.cap ]
}

#
#  brief gère les différentes extensions des fichiers images, ainsi que le cas où l'extension
#  des fichiers FITS est différente de .fit
#
proc ::tkutil::getOpenFileType { } {
   variable openFileType

   #---
   set openFileType [ list ]
   #---
   if { ( $::conf(extension,defaut) != ".fit" ) && ( $::conf(extension,defaut) != ".fts" ) &&
      ( $::conf(extension,defaut) != ".fits" ) } {
      lappend openFileType \
         [ list "$::caption(tkutil,image_file)" $::conf(extension,defaut) ] \
         [ list "$::caption(tkutil,image_file)" $::conf(extension,defaut).gz ] \
         [ list "$::caption(tkutil,image_fits)" $::conf(extension,defaut) ] \
         [ list "$::caption(tkutil,image_fits)" $::conf(extension,defaut).gz ]
   }

   #---
   lappend openFileType \
      [ list "$::caption(tkutil,image_file)"       {.fit}                ] \
      [ list "$::caption(tkutil,image_file)"       {.fit.gz}             ] \
      [ list "$::caption(tkutil,image_file)"       {.fts}                ] \
      [ list "$::caption(tkutil,image_file)"       {.fts.gz}             ] \
      [ list "$::caption(tkutil,image_file)"       {.fits}               ] \
      [ list "$::caption(tkutil,image_file)"       {.fits.gz}            ] \
      [ list "$::caption(tkutil,image_file)"       {.crw .cr2 .nef .dng} ] \
      [ list "$::caption(tkutil,image_file)"       {.CRW .CR2 .NEF .DNG} ] \
      [ list "$::caption(tkutil,image_file)"       {.jpeg .jpg}          ] \
      [ list "$::caption(tkutil,image_file)"       {.bmp}                ] \
      [ list "$::caption(tkutil,image_file)"       {.gif}                ] \
      [ list "$::caption(tkutil,image_file)"       {.png}                ] \
      [ list "$::caption(tkutil,image_file)"       {.tiff .tif}          ] \
      [ list "$::caption(tkutil,image_fits)"       {.fit}                ] \
      [ list "$::caption(tkutil,image_fits)"       {.fit.gz}             ] \
      [ list "$::caption(tkutil,image_fits)"       {.fts}                ] \
      [ list "$::caption(tkutil,image_fits)"       {.fts.gz}             ] \
      [ list "$::caption(tkutil,image_fits)"       {.fits}               ] \
      [ list "$::caption(tkutil,image_fits)"       {.fits.gz}            ] \
      [ list "$::caption(tkutil,image_raw)"        {.crw .cr2 .nef .dng} ] \
      [ list "$::caption(tkutil,image_raw)"        {.CRW .CR2 .NEF .DNG} ] \
      [ list "$::caption(tkutil,image_jpeg)"       {.jpeg .jpg}          ] \
      [ list "$::caption(tkutil,image_bmp)"        {.bmp}                ] \
      [ list "$::caption(tkutil,image_gif)"        {.gif}                ] \
      [ list "$::caption(tkutil,image_png)"        {.png}                ] \
      [ list "$::caption(tkutil,image_tiff)"       {.tiff .tif}          ] \
      [ list "$::caption(tkutil,image_jpeg)"       {}      JPEG          ] \
      [ list "$::caption(tkutil,image_gif)"        {}      GIFF          ] \
      [ list "$::caption(tkutil,image_png)"        {}      PNGF          ] \
      [ list "$::caption(tkutil,image_tiff)"       {}      TIFF          ] \
      [ list "$::caption(tkutil,fichier_tous)"     *                     ]
}

#
# box_load parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers a proposer au chargement (hors fichiers html)
#
proc ::tkutil::box_load { { parent } { initialdir } { numero_buffer } { type } { visuNo "1" } } {
   variable openFileType

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,charger_image) (visu$visuNo)"
      ::tkutil::getOpenFileType
      set filetypes "$openFileType"
   } elseif { $type == "2" } {
      set title "$::caption(tkutil,editer_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tcl)" ".tcl" ] \
         [ list "$::caption(tkutil,fichier_txt)" ".txt" ] [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "3" } {
      set title "$::caption(tkutil,lancer_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tcl)" ".tcl" ] ]
   } elseif { $type == "4" } {
      set title "$::caption(tkutil,editer_notice)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_pdf)" ".pdf" ] ]
   } elseif { $type == "5" } {
      set title "$::caption(tkutil,editer_catalogue)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_txt)" ".txt" ] ]
   } elseif { $type == "6" } {
      set title "$::caption(tkutil,editeur_script)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "7" } {
      set title "$::caption(tkutil,editeur_pdf)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "8" } {
      set title "$::caption(tkutil,editeur_page_web)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "9" } {
      set title "$::caption(tkutil,editeur_image)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "10" } {
      set title "$::caption(tkutil,editer_modpoi)"
      set filetypes [ list [ list "Tpoint model" ".xml .txt" ] [ list "XML" ".xml" ] [ list "TXT " ".txt" ] ]
   } elseif { $type == "11" } {
      set title "$::caption(tkutil,editer_fichier)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "12" } {
      set title "$::caption(tkutil,executable_java)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   } elseif { $type == "13" } {
      set title "$::caption(tkutil,executable_aladin)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_tous)" "*" ] ]
   }
   set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# box_load_html parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers html a proposer au chargement
#
proc ::tkutil::box_load_html { { parent } { initialdir } { numero_buffer } { type } } {
   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,editer_site_web)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_html)" ".htm" ] ]
   }
   set filename [ file join file:///[ tk_getOpenFile -title $title \
      -filetypes $filetypes -initialdir $initialdir -parent $parent ] ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# box_load_avi parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers avi a proposer au chargement
#
proc ::tkutil::box_load_avi { { parent } { initialdir } { numero_buffer } { type } } {
   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,editer_avi)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_avi)" ".avi" ] ]
   }
   set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# box_load_csv parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers csv a proposer au chargement
#
proc ::tkutil::box_load_csv { { parent } { initialdir } { numero_buffer } { type } } {
   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,editer_csv)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_csv)" ".csv" ] ]
   }
   set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
# box_load_csv parent initialdir numero_buffer type
#    Ouvre la fenetre de selection des fichiers csv a proposer au chargement
#
proc ::tkutil::box_load_atos { { parent } { initialdir } { numero_buffer } { type } } {
   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,editer_atos)"
      set filetypes [ list [ list "$::caption(tkutil,fichier_atos)" ".atos" ] ]
   }
   set filename [ tk_getOpenFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent ]
   #---
   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- car sous Linux la fenetre n'est pas detruite a la fin de
      #--- l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }
   #---
   return $filename
}

#
#  gère les différentes extensions des fichiers images, ainsi que le cas où l'extension
#  des fichiers FITS est différente de .fit, de .fts et de .fits
#
proc ::tkutil::getSaveFileType { } {
   variable saveFileType

   #---
   set saveFileType [ list ]
   #---
   if { ( $::conf(extension,defaut) != ".fit" ) && ( $::conf(extension,defaut) != ".fts" ) &&
      ( $::conf(extension,defaut) != ".fits" ) && ( $::conf(extension,defaut) != ".crw" ) &&
      ( $::conf(extension,defaut) != ".CRW" ) && ( $::conf(extension,defaut) != ".cr2" ) &&
      ( $::conf(extension,defaut) != ".CR2" ) && ( $::conf(extension,defaut) != ".nef" ) &&
      ( $::conf(extension,defaut) != ".NEF" ) && ( $::conf(extension,defaut) != ".dng" ) &&
      ( $::conf(extension,defaut) != ".DNG" ) } {
      set x [ list "$::caption(tkutil,image_fits)"    $::conf(extension,defaut) ]
      set y [ list "$::caption(tkutil,image_fits) gz" $::conf(extension,defaut).gz ]
   }

   #---
   set a [ list "$::caption(tkutil,image_fits) "  {.fit}     ]
   set b [ list "$::caption(tkutil,image_fits) 1" {.fit.gz}  ]
   set c [ list "$::caption(tkutil,image_fits) 2" {.fts}     ]
   set d [ list "$::caption(tkutil,image_fits) 3" {.fts.gz}  ]
   set e [ list "$::caption(tkutil,image_fits) 4" {.fits}    ]
   set f [ list "$::caption(tkutil,image_fits) 5" {.fits.gz} ]
   set g [ list "$::caption(tkutil,image_raw) "   {.crw}     ]
   set h [ list "$::caption(tkutil,image_raw) 1"  {.CRW}     ]
   set i [ list "$::caption(tkutil,image_raw) 2"  {.cr2}     ]
   set j [ list "$::caption(tkutil,image_raw) 3"  {.CR2}     ]
   set k [ list "$::caption(tkutil,image_raw) 4"  {.nef}     ]
   set l [ list "$::caption(tkutil,image_raw) 5"  {.NEF}     ]
   set m [ list "$::caption(tkutil,image_raw) 6"  {.dng}     ]
   set n [ list "$::caption(tkutil,image_raw) 7"  {.DNG}     ]
   set o [ list "$::caption(tkutil,image_jpeg)"   {.jpg}     ]
   set p [ list "$::caption(tkutil,image_bmp)"    {.bmp}     ]
   set q [ list "$::caption(tkutil,image_png)"    {.png}     ]
   set r [ list "$::caption(tkutil,image_tiff)"   {.tif}     ]

   if { $::conf(extension,defaut) == ".fit" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $b $a $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } elseif { $::conf(extension,defaut) == ".fts" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $c $d $a $b $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $d $c $a $b $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } elseif { $::conf(extension,defaut) == ".fits" } {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $e $f $a $b $c $d $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $f $e $a $b $c $d $g $h $i $j $k $l $m $n $o $p $q $r
      }
   } else {
      if { $::conf(fichier,compres) == "0" } {
         lappend saveFileType $x $y $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      } elseif { $::conf(fichier,compres) == "1" } {
         lappend saveFileType $y $x $a $b $c $d $e $f $g $h $i $j $k $l $m $n $o $p $q $r
      }
   }
}

#
## @brief ouvre la fenêtre de sélection des fichiers à proposer à la sauvegarde
#  @param parent
#  @param initialdir
#  @param numero_buffer
#  @param type
#  @param visuNo numéro de la visu (1 par défaut)
#
proc ::tkutil::box_save { { parent } { initialdir } { numero_buffer } { type } { visuNo 1 } } {
   variable saveFileType

   #--- Ouvre la fenetre de choix des fichiers
   if { $type == "1" } {
      set title "$::caption(tkutil,sauver_image) (visu$visuNo)"
      ::tkutil::getSaveFileType
      set filetypes "$saveFileType"
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent -defaultextension $::conf(extension,defaut) ]
   } elseif { $type == "2" } {
      set title "$::caption(tkutil,sauver_image_jpeg) (visu$visuNo)"
      set filetypes [ list [ list "$::caption(tkutil,image_jpeg)" ".jpg" ] ]
      set filename [ tk_getSaveFile -title $title -filetypes $filetypes -initialdir $initialdir -parent $parent -defaultextension ".jpg" ]
   }
   if { $filename == "" } {
      return
   }
   return $filename
}

#
## @brief fournit la largeur de l'entry d'une combobox adaptée au plus long élément de la liste
#  @param liste des éléments
#  @return largeur de l'entrée la plus longue
#
proc ::tkutil::lgEntryComboBox { liste } {
   set a "0"
   set lgListe [ llength $liste ]
   for { set k 1 } { $k <= $lgListe} { incr k } {
      set index [ expr $k - 1 ]
      set lgElement [ string length [ lindex $liste $index ] ]
      set b $lgElement
      if { $b > $a } {
         set a $b
      }
   }
   if { $a == "0" } {
      set a "5"
   }
   set longEntryComboBox [ expr $a + 2 ]
   return $longEntryComboBox
}

#
# afficherNomGenerique
#    Affiche le nom generique des fichiers d'une serie si c'en est une, le nombre
#    d'elements de la serie et le premier indice de la serie s'il est different de 1
#    Renumerote la serie s'il y a des trous ou si elle debute par un 0
#
proc ::tkutil::afficherNomGenerique { filename { animation 0 } } {
   global audace caption conf

   #--- Est-ce un nom generique de fichiers ?
   set nom_generique  [ lindex [ decomp $filename ] 1 ]
   set index_serie    [ lindex [ decomp $filename ] 2 ]
   set ext_serie      [ lindex [ decomp $filename ] 3 ]
   #--- J'extrais la liste des index de la serie
   set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
   if { $error == "0" } {
      #--- Pour une serie du type 1 - 2 - 3 - etc.
      set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
   } else {
      #--- Pour une serie du type 01 - 02 - 03 - etc.
      set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
   }
   #--- Longueur de la liste des index
   set longueur_serie [ llength $liste_serie ]
   if { $index_serie != "" && $longueur_serie >= "1" } {
      ::console::disp "$caption(tkutil,nom_generique_ok)\n\n"
   } else {
      tk_messageBox -title "$caption(tkutil,attention)" -type ok \
         -message "$caption(tkutil,nom_generique_ko)"
      #--- Ce n'est pas un nom generique, sortie anticipee
      set nom_generique  ""
      set longueur_serie ""
      set indice_min     "1"
      return [ list $nom_generique $longueur_serie $indice_min ]
   }
   #--- Identification du type de numerotation
   set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
   if { $error == "0" } {
      #--- Pour une serie du type 1 - 2 - 3 - etc.
      set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
   } else {
      #--- Pour une serie du type 01 - 02 - 03 - etc.
      set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
   }
   #--- Longueur de la serie
   set longueur_serie [ llength $liste_serie ]
   #--- Premier indice de la serie
   set indice_min [ lindex $liste_serie 0 ]
   #--- La serie ne commence pas par 0
   if { $indice_min != "0" } {
      set new_indice_min [ string trimleft $indice_min 0 ]
      #--- La serie commence par 1
      if { $new_indice_min == "1" } {
         #--- Est-ce une serie avec des fichiers manquants ?
         set etat_serie [ numerotation_usuelle $nom_generique ]
         if { $etat_serie == "0" } {
            #--- Il manque des fichiers dans la serie, je propose de renumeroter la serie
            set choix [ tk_messageBox -title "$caption(tkutil,attention)" \
               -message "$caption(tkutil,fichier_manquant)\n$caption(tkutil,renumerotation)" \
               -icon question -type yesno ]
            if { $choix == "yes" } {
               renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
               ::console::disp "$caption(tkutil,renumerote_termine)\n\n"
            } else {
               tk_messageBox -title "$caption(tkutil,attention)" -type ok \
                  -message "$caption(tkutil,pas_renumerotation)"
               #--- Sortie anticipee
               set nom_generique  ""
               set longueur_serie ""
               set indice_min     "1"
               return [ list $nom_generique $longueur_serie $indice_min ]
            }
         } else {
            #--- Il ne manque pas de fichiers dans la serie
            ::console::disp "$caption(tkutil,numerotation_ok)\n$caption(tkutil,pas_fichier_manquant)\n\n"
         }
      #--- La serie ne commence pas par 1
      } else {
         #--- J'extrais la liste des index de la serie
         set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
         if { $error == "0" } {
            #--- Pour une serie du type 1 - 2 - 3 - etc.
            set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
         } else {
            #--- Pour une serie du type 01 - 02 - 03 - etc.
            set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
         }
         #--- J'extrais la longueur, le premier et le dernier indice de la serie
         set longueur_serie [ llength $liste_serie ]
         set indice_min [ lindex $liste_serie 0 ]
         set indice_max [ lindex $liste_serie [ expr $longueur_serie - 1 ] ]
         #--- Je signale l'absence d'index autre que 1
         if { $animation == "0" } {
            if { [ expr $indice_max - $indice_min + 1 ] != $longueur_serie } {
               tk_messageBox -title "$caption(tkutil,attention)" -type ok \
                  -message "$caption(tkutil,renumerote_manuel)"
               #--- Sortie anticipee
               set nom_generique  ""
               set longueur_serie ""
               set indice_min     "1"
               return [ list $nom_generique $longueur_serie $indice_min ]
            }
         } elseif { $animation == "1" } {
            #--- J'extrais la liste des index de la serie
            set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
            if { $error == "0" } {
               #--- Pour une serie du type 1 - 2 - 3 - etc.
               set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
            } else {
               #--- Pour une serie du type 01 - 02 - 03 - etc.
               set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
            }
            #--- J'extrais la longueur et le premier indice de la serie
            set longueur_serie [ llength $liste_serie ]
            set indice_min [ lindex $liste_serie 0 ]
            ::console::disp "$caption(tkutil,liste_serie) $liste_serie \n\n"
            ::console::disp "$caption(tkutil,nom_generique) $nom_generique \n"
            ::console::disp "$caption(tkutil,image_nombre) $longueur_serie \n"
            ::console::disp "$caption(tkutil,image_premier_indice) $indice_min \n\n"
            return [ list $nom_generique $longueur_serie $indice_min $liste_serie ]
         }
      }
   #--- La serie commence par 0
   } else {
      #--- Je recherche le dernier indice de la liste
      set dernier_indice [ expr [ lindex $liste_serie [ expr $longueur_serie - 1 ] ] + 1 ]
      #--- Je renumerote le fichier portant l'indice 0
      set buf_pretrait [ ::buf::create ]
      buf$buf_pretrait extension $conf(extension,defaut)
      buf$buf_pretrait load [ file join $audace(rep_images) $nom_generique$indice_min$ext_serie ]
      buf$buf_pretrait save [ file join $audace(rep_images) $nom_generique$dernier_indice$ext_serie ]
      ::buf::delete $buf_pretrait
      file delete [ file join $audace(rep_images) $nom_generique$indice_min$ext_serie ]
      #--- Est-ce une serie avec des fichiers manquants ?
      set etat_serie [ numerotation_usuelle $nom_generique ]
      if { $etat_serie == "0" } {
         #--- Il manque des fichiers dans la serie, je propose de renumeroter la serie
         set choix [ tk_messageBox -title "$caption(tkutil,attention)" \
            -message "$caption(tkutil,indice_pas_1)\n$caption(tkutil,fichier_manquant)\n$caption(tkutil,renumerotation)" \
            -icon question -type yesno ]
         if { $choix == "yes" } {
            renumerote $nom_generique -rep "$audace(rep_images)" -ext "$ext_serie"
            ::console::disp "$caption(tkutil,renumerote_termine)\n$caption(tkutil,fichier_indice_0)\n\n"
         } else {
            tk_messageBox -title "$caption(tkutil,attention)" -type ok \
               -message "$caption(tkutil,pas_renumerotation)\n$caption(tkutil,fichier_indice_0)"
            #--- Sortie anticipee
            set nom_generique  ""
            set longueur_serie ""
            set indice_min     "1"
            return [ list $nom_generique $longueur_serie $indice_min ]
         }
      } else {
         #--- Il ne manque pas de fichiers dans la serie
         ::console::disp "$caption(tkutil,indice_pas_1)\n$caption(tkutil,pas_fichier_manquant)\n$caption(tkutil,fichier_indice_0)\n\n"
      }
   }
   #--- J'extrais la liste des index de la serie
   set error [ catch { lsort -integer [ liste_index $nom_generique ] } msg ]
   if { $error == "0" } {
      #--- Pour une serie du type 1 - 2 - 3 - etc.
      set liste_serie [ lsort -integer [ liste_index $nom_generique ] ]
   } else {
      #--- Pour une serie du type 01 - 02 - 03 - etc.
      set liste_serie [ lsort -ascii [ liste_index $nom_generique ] ]
   }
   #--- J'extrais la longueur et le premier indice de la serie
   set longueur_serie [ llength $liste_serie ]
   set indice_min [ lindex $liste_serie 0 ]
   ::console::disp "$caption(tkutil,liste_serie) $liste_serie \n\n"
   ::console::disp "$caption(tkutil,nom_generique) $nom_generique \n"
   ::console::disp "$caption(tkutil,image_nombre) $longueur_serie \n"
   ::console::disp "$caption(tkutil,image_premier_indice) $indice_min \n\n"
   return [ list $nom_generique $longueur_serie $indice_min $liste_serie ]
}

#
## @brief affiche le contenu de \::errorInfo dans la Console et dans une fenêtre modale
#  avec éventuellement un message optionnel
#  @param title titre
#  @param messageOptionnel (defaut) ""
#
proc ::tkutil::displayErrorInfo { title { messageOptionnel "" } } {
   #--- j'affiche le message d'erreur complet dans la Console
   ::console::affiche_erreur "$::errorInfo\n\n"
   #--- j'affiche le message d'erreur complet dans une fenetre modale
   tk_messageBox -icon error -title $title \
      -message "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]$messageOptionnel"
}

#
#  brief affiche le contenu de \::errorInfo dans la Console et dans une fenêtre modale
#  avec éventuellement un message optionnel avec une limitation du message dans
#  la Console en fonction du message d'erreur renvoyé par le telescope
#  param title
#  param messageOptionnel (defaut) ""
#
proc ::tkutil::displayErrorInfoTelescope { title { messageOptionnel "" } } {
   #--- j'affiche le message d'erreur complet dans la Console
   if { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Error GOTO RA\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Error GOTO DEC\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Error Synchro RA\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Error Synchro DEC\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Error too many Digits\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Object below Horizon\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "Object below Higher\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } elseif { [string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]] == "State Standby ON\n" } {
      ::console::affiche_erreur "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]\n\n"
   } else {
      ::console::affiche_erreur "$::errorInfo\n\n"
   }
   #--- j'affiche le message d'erreur complet dans une fenetre modale
   tk_messageBox -icon error -title $title \
      -message "[string range $::errorInfo 0 [string first "\n    while executing" $::errorInfo]]$messageOptionnel"
}

#
## @brief traduit une date (jour et mois) dans la langue de l'utilisateur
#  @param date date dans la langue de l'utilisateur
#
proc ::tkutil::transalteDate { date } {
   global caption

   #--- Je recupere le jour
   set nameDay     [ lindex $date 0 ]
   set listDay     [ list nihil Monday Tuesday Wednesday Thursday Friday Saturday Sunday ]
   set listeJour   [ list nihil $caption(tkutil,lundi) $caption(tkutil,mardi) $caption(tkutil,mercredi) $caption(tkutil,jeudi) \
                   $caption(tkutil,vendredi) $caption(tkutil,samedi) $caption(tkutil,dimanche) ]
   set jourLettres [ lindex $listeJour [ lsearch -regexp $listDay $nameDay ] ]

   #--- Je recupere le mois
   set nameMonth   [ lindex $date 2 ]
   set listMonth   [ list nihil January February March April May June July August September October November December ]
   set listeMois   [ list nihil $caption(tkutil,janvier) $caption(tkutil,fevrier) $caption(tkutil,mars) $caption(tkutil,avril) \
                   $caption(tkutil,mai) $caption(tkutil,juin) $caption(tkutil,juillet) $caption(tkutil,aout) \
                   $caption(tkutil,septembre) $caption(tkutil,octobre) $caption(tkutil,novembre) $caption(tkutil,decembre) ]
   set moisLettres [ lindex $listeMois [ lsearch -regexp $listMonth $nameMonth ] ]

   #--- Je formate la date dans la langue de l'utilisateur
   set date [ list $jourLettres [ lindex $date 1 ] $moisLettres [ lindex $date 3 ] ]
}

#
## @brief vérifie la valeur saisie dans un widget
#  @code Cette vérification est activée en ajoutant les options suivantes au widget :
#  -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s <class> <minValue> <maxValue> <errrorVariable> }
#  Exemple -validatecommand { ::tkutil::validateNumber %W %V %P %s "numRef" integer -360 360 }
#  @endcode
#  @param  win      : nom tk du widget renseigne avec %W
#  @param  event    : evenement (key, focusout,...) sur le widget renseigne avec %V
#  @param  newValue : valeur apres l'evenement renseignee avec %P
#  @param  oldValue : valeur avant l'evenement renseignee avec %s
#  @param  class    : classe de la valeur attendue
#  - boolean  : booleen ( 0, 1, false, true, no, yes , off , on)
#  - double   : nombre décimal
#  - integer  : nombre entier
#  @param  minValue      : valeur minimale du nombre
#  @param  maxValue      : valeur maximale du nombre
#  @param  errorVariable :nom de la variable d'erreur associée au widget
#
#  @return
#  - 1 si OK
#  - 0 si erreur (la saisie du caractère est annulée)
#  @public
#
proc ::tkutil::validateNumber { win event newValue oldValue class minValue maxValue { errorVariable "" } } {
   variable widget

   set result 0
   set warning 0
   if { $event == "key" || $event == "focusout"  } {
      #--- cas des nombres negatifs
      if { $minValue < 0 } {
         if { $newValue == "-" } {
            set result 1
            return $result
         }
      }
      #--- je verifie la classe
      set classCheck [string is $class -failindex charIndex $newValue]
      if { $classCheck == 0 } {
         set fullCheck $classCheck
         if { $errorVariable != "" } {
            set $errorVariable [format $::caption(tkutil,badCharacter) "\"$newValue\"" "\"[string range $newValue $charIndex $charIndex]\"" ]
         }
         set result 0
      } else {
         #--- je verifie la plage
         if {$minValue > $maxValue} {
            #--- je verifie l'ordre des bornes de l'intervalle
            set tmp $minValue; set minValue $maxValue; set maxValue $tmp
         }
         if { $newValue == "" } {
            set textVariable [$win cget -textvariable]
            set newValue $minValue
         }
         if { $newValue < $minValue } {
            #--- je signale une erreur , mais result=1 pour permettre la saisie du caractere
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,numberTooSmall) $newValue $minValue ]
            }
            set warning 1
            set result  1
         } elseif { $newValue > $maxValue } {
            #--- je signale une erreur , mais result=1 pour permettre la saisie du caractere
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,numberTooGreat) $newValue $maxValue ]
            }
            set warning 1
            set result 1
         } else {
            set result 1
            set warning 0
         }
      }
      if { $result == 0 } {
         #--- Je retourne 0 pour que la saisie du carctere est annulée
         #--- J'emet un beep pour avertir l'utilisateur
         bell
      } else {
         if { $warning == 1 } {
            #--- Je retourne 1 pour conserver le caractere saisi et permettre a l'utilsateur de corriger.
            #--- en particulier quand la valeur min  n'est pas nulle.
            #--- Mais j'affiche en inverse video pour signaler que la valeur du widget n'est pas entre les valeurs min et max
            $win configure -bg $::color(lightred) -fg $::audace(color,entryTextColor)
         } else {
            #--- Il n'y a pas d'erreur . Je supprime la variable d'erreur si elle existe.
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
            #--- j'affiche normalement
            $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
         }
      }
   } else {
      #--- je ne traite pas les evenements autres que key et focusout
      set result 1
   }
   return $result
}

#
## @brief vérifie le caractère saisi dans un widget
#  @code Cette vérification est activée en ajoutant les options suivantes au widget :
#  -validate  all -validatecommand { ::tkutil::validateNumber %W %V %P %s <class> <minLength> <maxLength> ?<errrorVariable>? }
#  Exemple 1
#   -validatecommand { ::tkutil::validateString %W %V %P %s fits 1 70 }
#  Exemple 2 : avec variable de controle
#  entry .frame.yyy -validatecommand { ::tkutil::validateString %W %V %P %s fits 1 70 ::xxxx::widget($visuNo,error,yyy) }
#  puis faire les contrôles dans la procédure ::xxxx::apply
#  if { [array names ::xxxx::widget $visuNo,error,* ] != "" } {
#     #--- j'affiche un message d'erreur s'il existe au moins une variable ::xxxx::widget($visuNo,error,...)
#     ...
#  }
#  @endcode
#
#  @param  win      : nom tk du widget renseigne avec %W
#  @param  event    : evenement sur le widget renseigne avec %V (key, focusout,...)
#  @param  newValue : valeur apres l'evenement renseignee avec %P
#  @param  oldValue : valeur avant l'evenement renseignee avec %s
#  @param  class    : classe de la valeur attendue
#            - alnum     : caracteres alphabetiques ou numeriques
#            - alpha     : caracteres alphabetiques
#            - ascii     : caracteres ASCII dont le code est inferieur ou egal a 127
#            - binning   : caracteres autorises dans un binning (1x1, 2x2, 3x5, ...)
#            - boolean   : booleen ( 0, 1, false, true, no, yes , off , on)
#            - fits      : caracteres autorises dans un mot cle FITS
#            - wordchar  : caracteres alphabetiques ou numeriques ou underscore
#            - wordchar1 : caracteres de wordchar avec "-", sans "\" et "µ"
#            - wordchar2 : caracteres de wordchar avec "-", ".", "/" et ":", sans "\" et "µ"
#            - xdigit    : caracteres hexadecimaux
#  @param  minLength      : longueur minimale de la chaine
#  @param  maxLength      : longueur maximale de la chaine
#  @param  errorVariable  : nom de la variable d'erreur associee au widget
#
#  @return
#  - 1 si OK
#  - 0 si erreur
#  @private
#
proc ::tkutil::validateString { win event newValue oldValue class minLength maxLength { errorVariable "" } } {
   variable widget

   set result 0
   set charIndex -1
   if { $event == "key" || $event == "focusout" } {
      #--- je verifie la classe
      if { $class == "fits" } {
         set classCheck [string is ascii -failindex charIndex $newValue]
        ### set classCheck [expr [[regexp -all {[\u0000-\u0029]|[\u007F-\u00FF]} $newValue ] != 0 ] ]
      } elseif { $class == "binning" } {
         set binx ""
         set biny ""
         set ctrl [ scan $newValue "%dx%d" binx biny ]
         set ctrlValue [ format $binx%s$biny x ]
         if { $ctrlValue != $newValue } {
            set classCheck 0
            set charIndex  ""
         } else {
            set classCheck 1
         }
      } elseif { $class == "wordchar1" } {
         set charIndex [string first "\\" $newValue]
         if { $charIndex != -1} {
            #--- je refuse le caractere antislash
            set classCheck 0
         } else {
            set charIndex [string first "µ" $newValue]
            if { $charIndex != -1} {
               #--- je refuse le caractere machin
               set classCheck 0
            } else {
               #--- je supprime le caractere "-"  de la chaine car il est autorise
               set newValue2 [string map { "-" "" } $newValue ]
               #--- je verifie les caracteres restant
               set classCheck [string is wordchar -failindex charIndex $newValue2]
            }
         }
      } elseif { $class == "wordchar2" } {
         set charIndex [string first "\\" $newValue]
         if { $charIndex != -1} {
            #--- je refuse le caractere antislash
            set classCheck 0
         } else {
            set charIndex [string first "µ" $newValue]
            if { $charIndex != -1} {
               #--- je refuse le caractere machin
               set classCheck 0
            } else {
               #--- je supprime les caracteres "-", ".", ":" et "/" de la chaine car ils sont autorises
               set newValue2 [string map { "-" "" "." "" ":" "" "/" "" } $newValue ]
               #--- je verifie les caracteres restant
               set classCheck [string is wordchar -failindex charIndex $newValue2]
            }
         }
      }
      if { $classCheck == 0} {
         if { $charIndex != -1 && $errorVariable != ""  } {
            set $errorVariable [format $::caption(tkutil,badCharacter) "\"$newValue\"" "\"[string range $newValue $charIndex $charIndex]\"" ]
         }
         set result 0
     } else {
         #--- je verifie la longueur de la chaine
         if {$minLength > $maxLength} {
            #--- je verifie l'ordre des bornes de longueur
            set tmp $minLength; set minLength $maxLength; set maxLength $tmp
         }
         set xLength [string length $newValue]
         if { $xLength < $minLength } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,stringTooShort) "\"$newValue\"" $minLength]
            }
            set result 0
         } elseif { $xLength > $maxLength } {
            if { $errorVariable != "" } {
               set $errorVariable [format $::caption(tkutil,stringTooLarge) "\"$newValue\"" $maxLength]
            }
            set result 0
         } else {
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
            set result 1
         }
      }
      #--- je change de couleur si la longueur est incorrecte
      if { $result == 0 } {
         bell
      }
   } else {
      #--- je ne traite pas l'evenement
      set result 1
   }
   return $result
}


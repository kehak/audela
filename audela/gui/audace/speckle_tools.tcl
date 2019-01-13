#
## @file speckle_tools.tcl
#  @brief Tools for speckle imagery
#  @author Alain KLOTZ
#  $Id: speckle_tools.tcl 13788 2016-04-30 15:46:29Z rzachantke $
#  @todo speckle_calibwcs, speckle_acq2avi, speckle_distrho
#  plus VO tools that interract with the databases
#

#  source "$audace(rep_install)/gui/audace/speckle_tools.tcl"
#

proc speckle_acq2avi { nb_images filename_avi } {
   global audace

   set path $audace(rep_images)
   set bufno $audace(bufNo)

   # --- open the .avi file
   ::avi::create ::av4l_tools_avi::avispeckle1
   #
   # TODO...
   #
   # --- close the .avi file
   ::av4l_tools_avi::avispeckle1 close
   rename ::av4l_tools_avi::avispeckle1 ""
}

## @brief create the intercorrelation image from the .avi file
#  @warning spécifique à Linux ;
#  sous Windows on un message d'erreur # invalid command name "::avi::create"
#  @code
#  Exemple 1 :
#  speckle_avi2intercor dzeta_boo_test_ralenti_7_fois.avi fsum
#  # 1000
#  Exemple 2 :
#  speckle_avi2intercor dzeta_boo_test_ralenti_7_fois.avi fsum 10
#  @endcode
#  @param filename_avi      nom du fichier avi
#  @param filename_intercor nom du fichier de sortie
#  @param nb_images         nombre d'images à traiter, 0 par défaut
#  @param first_index       index de la première image
#  @param verbose
#  - 1 : load the intercorrelation image
#  - 2 : edit the process delay + load the intercorrelation image
#  @return nb_images if param nb_images==0
#
proc speckle_avi2intercor { filename_avi filename_intercor {nb_images 0} {first_index 1} {verbose 2} } {
   global audace

   set path $audace(rep_images)
   set bufno $audace(bufNo)

   # --- open the .avi file
   ::avi::create ::av4l_tools_avi::avispeckle1

   set fullfileavi "${path}/${filename_avi}"
   set err [catch {::av4l_tools_avi::avispeckle1 load $fullfileavi} msg]
   if {$err==1} {
      # --- close the .avi file
      ::av4l_tools_avi::avispeckle1 close
      rename ::av4l_tools_avi::avispeckle1 ""
      # --- error message
      if {[file exists $fullfileavi]==0} {
         append msg " The file $fullfileavi does not exists"
      }
      error "${msg}"
   }
   # --- set the starting and ending indexes
   set kdeb [expr int($first_index)]
   set nb_frames [::av4l_tools_avi::avispeckle1 get_nb_frames]
   if {$kdeb<0} { set kdeb 1 }
   if {$nb_images==0} {
      # --- close the .avi file
      ::av4l_tools_avi::avispeckle1 close
      rename ::av4l_tools_avi::avispeckle1 ""
      # --- return the number of frames
      return $kfin
   } else {
      set kfin [expr $nb_images-$kdeb+1]
   }
   if {$kfin>$nb_frames} {
     set kfin $nb_frames
   }
   # --- loop over each selected image of the .avi file
   set t0 [clock seconds]
   for {set k $kdeb} {$k<=$kfin} {incr k} {
      if {$verbose>=2} {
         console::affiche_resultat "Image $k / $kfin\n"
      }
      # --- load the next .avi image
      ::av4l_tools_avi::avispeckle1 next
      if {$verbose>=1} {
         update
      }
      # --- intercorrelation
      buf${bufno} bitpix float
      saveima o
      prod o 1
      saveima o2
      icorr2d ${path}/o2[buf${bufno} extension] ${path}/o[buf${bufno} extension] ${path}/f[buf${bufno} extension]
      buf${bufno} load ${path}/f[buf${bufno} extension]
      if {$k==$kdeb} {
         saveima fsum
      } else {
         buf${bufno} add ${path}/fsum[buf${bufno} extension] 0
         saveima fsum
      }
   }
   # --- close the .avi file
   ::av4l_tools_avi::avispeckle1 close
   rename ::av4l_tools_avi::avispeckle1 ""
   # --- set the outputs
   set dt [expr [clock seconds]-$t0]
   if {$verbose>=2} {
      console::affiche_resultat "Processed in $dt seconds\n"
   }
   if {$verbose>=1} {
      loadima fsum
   } else {
      buf${bufno} load ${path}/fsum[buf${bufno} extension]
   }
   saveima $filename_intercor
}


## @brief create the highpass of the intercorrelation image to help the analysis
#  @code  Exemple :
#  speckle_intercorhighpass fsum 8
#  @endcode
#  @param filename_intercor
#  @param highpass_threshold
#  @note load the highpass image fsumf at end
#
proc speckle_intercorhighpass { filename_intercor {highpass_threshold 10} } {
   global audace

   set path $audace(rep_images)
   set bufno $audace(bufNo)
   set rc $highpass_threshold
   if {$rc<=0} {
      loadima $filename_intercor
      return ""
   }
   # --- FFT on the intercorrelation image
   dft2d ${path}/${filename_intercor}[buf${bufno} extension] ${path}/famp[buf${bufno} extension] ${path}/fpha[buf${bufno} extension]
   # --- set the limits of the high pass gaussian filter
   loadima famp
   set naxis1 [buf${bufno} getpixelswidth]
   set naxis2 [buf${bufno} getpixelsheight]
   set xc [expr $naxis1/2+1]
   set yc [expr $naxis2/2+1]
   set rcx [expr 1.*$rc]
   set rcy [expr 1.*$rc*$naxis2/$naxis1]
   set rc2 [expr $rcx*$rcy]
   set etenduex [expr $rcx*5.]
   set etenduey [expr $rcy*5.]
   set etenduex2 [expr $etenduex*$etenduex]
   set etenduey2 [expr $etenduey*$etenduey]
   set etendue2 [expr $etenduex2+$etenduey2]
   set x1 [expr int($xc-$etenduex)] ; if {$x1<1} {set x1 1}
   set x2 [expr int($xc+$etenduex)] ; if {$x2>$naxis1} {set x2 $naxis1}
   set y1 [expr int($yc-$etenduey)] ; if {$y1<1} {set y1 1}
   set y2 [expr int($yc+$etenduey)] ; if {$y2>$naxis2} {set y2 $naxis2}
   # --- filtering in the Fourier domain
   set fs {famp fpha}
   foreach f $fs {
      loadima $f
     for {set x $x1} {$x<=$x2} {incr x} {
         set dx [expr $x-$xc]
         set dx2 [expr $dx*$dx]
         if {$dx2>$etenduex2} {
            continue
         }
         for {set y $y1} {$y<=$y2} {incr y} {
            set dy [expr $y-$yc]
            set dy2 [expr $dy*$dy]
            if {$dy2>$etenduey2} {
               continue
            }
            set r2 [expr $dx2+$dy2]
            if {$r2<$etendue2} {
               set filtre [expr 1.-exp(-0.5*$r2/$rc2)]
               set val [lindex [buf${bufno} getpix [list $x $y] ] 1]
               set newval [expr $val*$filtre]
               buf${bufno} setpix [list $x $y] $newval
            }
         }
      }
      saveima ${f}f
   }
   # --- inverse FFT
   idft2d ${path}/fampf[buf${bufno} extension] ${path}/fphaf[buf${bufno} extension] ${path}/fsumf[buf${bufno} extension]
   loadima fsumf
}

## @brief create the module of the FFT of the intercorrelation image to help the analysis
#  @code Exemple :
#  speckle_intercorfft fsum
#  @endcode
#  @param filename_intercor name of the intercorrelation image
#  @note load the amplitude image famp at end
#
proc speckle_intercorfft { filename_intercor } {
   global audace

   set path $audace(rep_images)
   set bufno $audace(bufNo)
   # --- FFT on the intercorrelation image
   dft2d ${path}/${filename_intercor}[buf${bufno} extension] ${path}/famp[buf${bufno} extension] ${path}/fpha[buf${bufno} extension]
   # --- return the amplitude image
   loadima famp
}

## @brief automatise l'outil d'extraction d'ATOS d'images fits d'un fichier avi
#  @details fonctionne aussi sous Windows, même si l'outil ATOS est désactivé
#  @warning il faut attendre la fin de l'extraction ; le script propose l'intercorrelation.
#  @code  Exemple :
#  speckle_avi2fits dzeta_boo_test_ralenti_7_fois.avi fsum test 3
#  @endcode
#  @param avifilename nom court du fichier avi dans \$audace(rep_images)
#  @param filename_intercor nom du fichier de sortie
#  @param prefix racine des images .fits
#  @param nb_images
#  - 0   --> nombre total d'images ; il faut saisir les autres informations
#  - valeur souhaitée
#  @param first_index valeur par défaut 0
#  @note
#  - l'image \$filename_intercor est chargée à la fin du script
#  - toutes les images fits sont dans le répertoire \$audace(rep_images)
#
proc speckle_avi2fits { avifilename {filename_intercor fsum} {prefix test} {nb_images 0} {first_index 1} } {

   set visuNo $::audace(visuNo)
   set bufNo $::audace(bufNo)
   set ext [buf$bufNo extension]
   set path $::audace(rep_images)
   set full_filename [file join $path $avifilename]
   set toolName ::atos

   if {[file exists $full_filename] ==1} {

      set atosReady [::confVisu::isReady $visuNo $toolName]

      #--   ouvre le panneau ATOS s'il n'est pas deja actif
      if {$atosReady eq "0"} {
          set ::tcl_precision 17
         ::confVisu::selectTool $visuNo $toolName
      }

      set This .audace.atos_extraction

      #-- invoque la proc qui ouvre la fenetre d'extraction
      ::atos_extraction::createdialog $This $visuNo

      #-- chemin de la fenetre d'extraction
      set this "$This.frm_atos_extraction"

      #-- nom du fichier dans le namespace
      set ::atos_tools::avi_filename $full_filename

      #-- renseigne le fichier a traiter
      #    car il n'y a pas de variable associee a entry
      $this.open.avipath insert 0 $::atos_tools::avi_filename

      #-- invoque la proc du bouton "Ouvrir"
      ::atos_tools::open_flux $visuNo

      #-- get number of frames
      set nb_frames $::atos_tools::nb_open_frames

      #-- set the starting and ending indexes
      set kdeb [expr int($first_index)]
      if {$nb_images==0} {
         # --- return the number of frames
         return $nb_frames
      } else {
         set kfin [expr $nb_images-$kdeb+1]
      }
      if {$kfin > $nb_frames} {
         set kfin $nb_frames
      }

      #-- renseigne les indices de début et de fin d'extraction
      #    car il n'y a pas de variable associee a entry
      $this.posmin insert 0 $kdeb
      $this.posmax insert 0 $kfin

      #--  renseigne le repertoire de destination et le prefixe des fichiers .fits
      #    car il n'y a pas de variable associee a entry
      $this.form.v.destdir insert 0 $path
      $this.form.v.prefix insert 0 $prefix
      update

      #-- invoque la proc du bouton "Extraction"
      ::atos_extraction::extract $visuNo

      #-- invoque la peroc du bouton "Fermer"
      ::atos_extraction::closeWindow $This $visuNo

      #-- ferme le panneau ATOS s'il n'etait pas ouvert au lancement
      if {$atosReady eq "0"} {
         ::confVisu::stopTool $visuNo ::atos
      }

      update

      set res [tk_messageBox -message "Intercorrelation ?" -type yesno]

      if {$res eq "yes"} {
         for {set k $kdeb} {$k<=$kfin} {incr k} {

            #::console::affiche_resultat "Image $k / $kfin\n"

            #-- intercorrelation
            buf${bufNo} load [file join $path ${prefix}${k}$ext]
            buf${bufNo} bitpix float
            saveima o
            prod o 1
            saveima o2
            icorr2d [file join $path o2$ext] [file join $path o$ext] [file join $path f$ext]

            #-- sum
            buf$bufNo load [file join $path f$ext]
            if {$k==$kdeb} {
               saveima fsum
            } else {
               buf${bufNo} add [file join $path fsum$ext] 0
               saveima fsum
            }
         }

         buf${bufNo} load [file join $path fsum$ext]
         ::confVisu::autovisu $visuNo

         saveima ${filename_intercor}$ext

         #-- nettoyage
         file delete [file join $path o$ext] [file join $path o2$ext]

         #speckle_intercorhighpass $filename_intercor 10
         #speckle_intercorfft $filename_intercor
      }

      ::console::affiche_resultat "\n[expr { $kfin-$kdeb+1 }] images handled\n"

   } else {
      ::console::affiche_erreur "file \"$full_filename\" does not exist\n"
   }
}
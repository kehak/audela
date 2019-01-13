#
## @file image.tcl
#  @brief Manipulation des images
#  @author Michel PUJOL
#  @namespace Image
#  @brief Manipulation des images
#  $Id: image.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#  @todo à deplacer dans aud1.tcl

namespace eval ::Image {

   #------------------------------------------------------------------------------
   ## @brief charge un film dans la fenêtre standard
   #  @param visuNo numéro de la visu
   #  @param filename nom complet du fichier
   #
   proc loadmovie { visuNo filename } {
      variable private

      #--- je masque la fenetre des images
      $::confVisu::private($visuNo,hCanvas) itemconfigure display -state hidden

      #--- j'affiche le film
      set result [::Movie::open $visuNo $filename 0 0 "nw"]

      if { $result == 0 } return

      #--- j'adapte les scollbars
      set w_zoomed [$::confVisu::private($visuNo,hCanvas) itemcget avi -width]
      set h_zoomed [$::confVisu::private($visuNo,hCanvas) itemcget avi -height]
      $::confVisu::private($visuNo,hCanvas) configure -scrollregion [list 0 0 $w_zoomed $h_zoomed ]

      #--- je raffraichis l'affichage du reticule
      ::confVisu::redrawCrosshair $visuNo
   }

   #------------------------------------------------------------------------------
   ## @brief analyse si un fichier est un GIF animé ou non
   #  @code
   #  ::Image::isAnimatedGIF (filename)
   #  @endcode
   #  @param filename nom complet du fichier
   #  @return
   #  - 1 si c'est un fichier GIF contenant au moins 2 images
   #  - 0 sinon
   #
   proc isAnimatedGIF { filename } {
      if { [ string tolower [ file extension "$filename" ]] == ".gif" } {
         #--- je tente de charger la deuxieme image (index=1)
         set error [ catch {
               set result [image create photo image_test -file "$filename" -format {gif 1}]
            } msg ]
         if { $error == 0 } {
            if { "$result" == "image_test" } {
               #--- il existe au moins deux images dans le fichier
               image delete image_test
               return 1
            } else {
               return 0
            }
         } else {
            return 0
         }
      } else {
         return 0
      }
   }

   #------------------------------------------------------------
   ## @brief lance une animation si le fichier est au GIF et contient plusieurs images
   #  @code
   #   ::Image::startGifAnimation filename delay
   #  @endcode
   #  @param hImage
   #  @param zoom
   #  @param filename nom du fichier gif
   #  @param delay délai entre deux images (en secondes)
   #
   proc startGifAnimation { hImage zoom filename { delay "0.2" } } {
      variable private

      array set imgPriv { }

      set private(hImage)         $hImage
      set private(zoom)           $zoom
      set private(filename)       "$filename"
      set private(animationDelay) $delay
      set private(nbimage)        0
      set private(animationState) 1

      #--- je lance l'affichage de la premiere image en differe
      set private(animationAfterId) [after 10 ::Image::nextStep "0" "file" ]
   }

   #------------------------------------------------------------
   #  brief
   #  param index
   #  param option
   #
   proc nextStep { index option } {
      variable private
      variable imgPriv

      set filename "$private(filename)"

      #--- si une demande d'arret a deja ete faite, je ne fais plus rien
      if { $private(animationState) == 0 } {
         return
      }

      #--- j'affiche l'image
      if { $option == "file" } {
         set result [catch "image create photo \"gif$index\" -file \"$filename\" -format \{gif -index $index\} " msg]
         if { $result == 1 } {
            if { "$msg" == "no image data for this index" } {
               #--- toute les images sont chargees
               set option "memory"
            } else {
               #--- autre erreur => j'arrete l'animation
               console::affiche_erreur "Animation GIF : $msg \n"
               stopGifAnimation
               return
            }
         } else {
            #--- chargement ok, j'ajoute le nom de l'image dans le tableau
            set imgPriv(image$index) "gif$index"
            incr private(nbimage)
         }
      }

      #--- je remets a zero l'index s'il a depasse le nombre d'image existantes
      if { ![info exists imgPriv(image$index)] } {
         set index 0
      }

      #--- j'affiche l'image
      if { $private(zoom) >= 1 } {
          $private(hImage) copy $imgPriv(image$index) -zoom $private(zoom)
      } elseif { $private(zoom)< 1 } {
          $private(hImage) copy $imgPriv(image$index) -subsample [expr round(1/$private(zoom))]
      }

      #--- j'incremente l'index pour pointer l'image suivante
      incr index

      #--- je lance l'iteration suivante en differe
      if { $private(animationState) == 1 } {
         set result [ catch { set delay [expr round($private(animationDelay) * 1000) ] } ]
         if { $result != 0 } {
            #--- remplace le delai incorrect
            set delay "500"
         }
         set private(animationAfterId) [after $delay ::Image::nextStep "$index" $option]
      }
   }

   #------------------------------------------------------------------------------
   ## @brief arrête l'animation
   #  @code
   #  ::Image::stopGifAnimation
   #  @endcode
   proc stopGifAnimation { } {
      variable private
      variable imgPriv

      set private(animationState) "0"
      if { "$private(animationAfterId)" != "" } {
         after cancel $private(animationAfterId)
         set private(animationAfterId) ""
      }

      #--- je supprime les images de la memoire
      foreach im [array names imgPriv *] {
         image delete $imgPriv($im)
         unset imgPriv($im)
      }
   }
}

array set ::Image::private {
   animationState      "0"
   animationAfterId    ""
   animationDelay      ".5"
}


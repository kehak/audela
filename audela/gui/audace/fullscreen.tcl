#
## @file fullscreen.tcl
#  @brief Fenêtre plein écran pour afficher des images ou des films
#  @author Michel PUJOL
#  @namespace FullScreen
#  @brief Fenêtre plein écran pour afficher des images ou des films
#  $Id: fullscreen.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::FullScreen {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_caption) fullscreen.cap ]

   #------------------------------------------------------------------------------
   # createFullscreen
   #  brief ouvre la fenêtre plein écran
   #  param visuNo numéro de la visu
   #  param hCanvas chemin du canvas
   #
   proc createFullscreen { visuNo hCanvas } {
      variable private
      global audace

      initConf

      #--- je recupere le nom de la toplevel
      set private($visuNo,toplevel) [winfo toplevel $hCanvas]
      set private($visuNo,hCanvas)  $hCanvas

      set private($visuNo,image)             ""
      set private($visuNo,bufNo)             ""
      set private($visuNo,this)              ""
      set private($visuNo,slideShow)         "0"
      set private($visuNo,hWindow)           ""
      set private($visuNo,zoom)              $::confVisu::private($visuNo,zoom)
      set private($visuNo,directory)         ""
      set private($visuNo,files)             ""
      set private($visuNo,currentItemIndex)  "0"
      set private($visuNo,fileImage)         "Image"
      set private($visuNo,fileMovie)         "Film"
      set private($visuNo,animation)         "0"
      set private($visuNo,SlideShowAfterId)  ""
      set private($visuNo,slideShowDelay)    "1"
      set private($visuNo,gif_anime)         "0"

      #--- je recupere la liste des frames qui sont dans la toplevel
      set private($visuNo,slaves) [grid slaves $private($visuNo,toplevel)]

      #--- je masque les frames, sauf le canvas
      foreach slave $private($visuNo,slaves) {
         #--- je sauvegarde les parametre de chaque frame
         set private($visuNo,$slave,pack_config) "[grid info $slave]"
         #--- je cache la frame sauf celle du canvas
         if { [string compare -length [string length $slave] "$slave" "$private($visuNo,hCanvas)" ] != 0 } {
            ##pack forget $slave
            grid forget $slave
         }
      }

      #--- je sauvegarde la taille de la fenetre
      set private($visuNo,geometry) [wm geometry $private($visuNo,toplevel)]

      #--- je sauvegarde le menu principal
      set private($visuNo,menu) [$private($visuNo,toplevel) cget -menu ]

      #--- je desactive le menu principal
      $private($visuNo,toplevel) configure -menu ""

      #--- je cree le popup menu
      createPopupMenu $visuNo

      #--- j'iconifie la fenetre Console
      wm iconify $audace(Console)

      #--- je masque les scollbars
      set private($visuNo,scrollx) [lindex [$private($visuNo,hCanvas) cget -xscrollcommand] 0]
      grid remove $private($visuNo,scrollx)
      set private($visuNo,scrolly) [lindex [$private($visuNo,hCanvas) cget -yscrollcommand] 0]
      grid remove $private($visuNo,scrolly)

      #--- j'affiche la fenetre en plein ecran
      set maxsize [wm maxsize $private($visuNo,toplevel)]
      wm geometry $private($visuNo,toplevel) [lindex $maxsize 0]x[lindex $maxsize 1]+0+0

      #--- je recupere la largeur de l'ecran en pixels
      set private($visuNo,largeur_ecran) [ lindex $maxsize 0 ]

      #--- je recupere la hauteur de l'ecran en pixels
      set private($visuNo,hauteur_ecran) [ lindex $maxsize 1 ]

      #--- je supprime le titre et les bordures de la fenetre
      wm overrideredirect $private($visuNo,toplevel) 1

      #--- je deplace l'image au centre du canvas
      $private($visuNo,hCanvas) itemconfigure display -anchor center
      $private($visuNo,hCanvas) move display [expr [lindex $maxsize 0]/2] [expr [lindex $maxsize 1]/2]

      #--- je recupere la largeur de l'image en pixels
      set private($visuNo,largeur_image) [ lindex [ buf[ visu$visuNo buf ] getkwd NAXIS1 ] 1 ]

      #--- je recupere la hauteur de l'image en pixels
      set private($visuNo,hauteur_image) [ lindex [ buf[ visu$visuNo buf ] getkwd NAXIS2 ] 1 ]

      #--- j'isole dans une variable la couleur du canvas de la fenetre principale d'Aud'ACE
      set private($visuNo,bgcolor) [ $private($visuNo,hCanvas) cget -bg ]

      #--- je mets a jour la couleur du canvas plein ecran
      $::FullScreen::private($visuNo,hCanvas) configure -bg $::conf(FullScreen,color)

      #--- je donne le focus a la fenetre plein ecran
      focus $private($visuNo,toplevel)

      set private($visuNo,currentItemIndex) "0"

   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Configuration de la fenêtre plein écran"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(FullScreen,slideShowDelay)
   #  - conf(FullScreen,autoStartAnim)
   #  - conf(FullScreen,color)
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(FullScreen,slideShowDelay) ] } { set conf(FullScreen,slideShowDelay) "2" }
      if { ! [ info exists conf(FullScreen,autoStartAnim) ] }  { set conf(FullScreen,autoStartAnim)  "0" }
      if { ! [ info exists conf(FullScreen,color) ] }          { set conf(FullScreen,color)          "#000000" }
   }

   #------------------------------------------------------------------------------
   ## @brief  ouvre la fenêtre plein écran
   #  et affiche l'image contenu dans le buffer
   #  @code
   #  ::FullScreen::showBuffer visuNo hCanvas
   #   ouvre la fenêtre plein écran et affiche l'image ou le film contenu dans un buffer
   #  @endcode
   #  @param visuNo numéro de la visu
   #  @param hCanvas chemin du canvas
   #
   proc showBuffer { visuNo hCanvas } {
      variable private

      set private($visuNo,directory)        ""
      set private($visuNo,files)            ""
      set private($visuNo,currentItemIndex) "0"

      set ::confVisu::private($visuNo,fullscreen) "1"

      #--- je cree la fenetre plein ecran
      createFullscreen $visuNo $hCanvas
   }

   #------------------------------------------------------------------------------
   ## @brief ouvre la fenêtre plein écran et affiche les images ou les films contenus dans les fichiers
   #  @code
   #  ::FullScreen::showFiles visuNo hCanvas directory files
   #  ouvre la fenêtre plein écran et affiche les images ou les films contenus dans les fichiers
   #  @endcode
   #  param visuNo numéro de la visu
   #  param hCanvas chemin du canvas
   #  param directory
   #  param files
   #
   proc showFiles { visuNo hCanvas directory files } {
      variable private

      set private($visuNo,directory)        $directory
      set private($visuNo,files)            $files
      set private($visuNo,currentItemIndex) "0"

      set ::confVisu::private($visuNo,fullscreen) "1"
      #--- je cree la fenetre plein ecran
      createFullscreen $visuNo $hCanvas
      #--- j'affiche l'image ou le film contenu dans le premier fichier
      loadItem $visuNo
   }

   #------------------------------------------------------------------------------
   #  brief charge le fichier ou le buffer
   #  param visuNo numéro de la visu
   #
   proc loadItem { visuNo } {
      variable private
      global conf

      if { "$private($visuNo,files)" != "" } {
         #--- j'affiche l'image ou le film contenu dans le fichier

         #--- si une animation est en cours, j'arrete l'animation
         if { $private($visuNo,animation) == "1" } {
            #--- j'arrete l'animation
            stopAnimation
         }

         #--- si un film est en cours, j'arrete le film
         ::Movie::close $visuNo

         #--- je recupere le nom du fichier selectionne
         set index $private($visuNo,currentItemIndex)
         set name [lindex [lindex $private($visuNo,files) $index] 0 ]
         set type [lindex [lindex $private($visuNo,files) $index] 1 ]
         set filename [file join "$private($visuNo,directory)" "$name"]

         if { [string first "$private($visuNo,fileImage)" "$type" ] != "-1" } {
            #--- j'affiche l'image
            loadimage $visuNo $filename $private($visuNo,zoom)
            if { [::Image::isAnimatedGIF "$filename"] == "1" } {
               setAnimationState "1"
            } else {
               setAnimationState "0"
            }
         } elseif { "$type" == "$private($visuNo,fileMovie)" } {
            #--- j'affiche la premiere image du film
            loadmovie $visuNo $filename
            setAnimationState "1"
         }

         #--- si une animation est en cours, je relance l'animation
         if { [::Image::isAnimatedGIF "$filename"] == "1" || "$type" == "$private($visuNo,fileMovie)" } {
            set private($visuNo,gif_anime) "1"
            if { $conf(FullScreen,autoStartAnim) == "1" } {
               startAnimation $visuNo
            }
         } else {
            set private($visuNo,gif_anime) "0"
         }
      } else {
         ::confVisu::autovisu $visuNo
      }
   }

   #------------------------------------------------------------------------------
   ## @brief ferme la fenêtre plein écran
   #  @code
   #  ::FullScreen::cmdClose visuNo
   #  ferme la fenêtre plein écran
   #  (la fenetre peut être aussi fermée en appyuant sur la touche ESCAPE)
   #  @endcode
   #  @param visuNo numéro de la visu
   #
   proc cmdClose { visuNo } {
      variable private
      global audace

      if { $::confVisu::private($visuNo,fullscreen) == "1" } {
         #--- j'arrete le diaporama s'il est en cours
         if { $private($visuNo,slideShow) == "1" } {
            stopSlideShow $visuNo
         }

         stopAnimation $visuNo

         catch {
            ::Movie::close $visuNo
         }

         #--- je deconifie la fenetre Console
         wm deiconify $audace(Console)

         #--- je place l'image dans le coin en haut a gauche et je restitue la couleur
         #--- du canvas de la fenetre principale
         $private($visuNo,hCanvas) itemconfigure display -anchor nw
         $private($visuNo,hCanvas) configure -bg $private($visuNo,bgcolor)
         set coords [$private($visuNo,hCanvas) coord display]
         $private($visuNo,hCanvas) move display -[lindex $coords 0] -[lindex $coords 1]

         #--- je restaure le reticule
         set ::confVisu::private($visuNo,crosshairstate) $::confVisu::private($visuNo,tempCrosshairState)
         ::confVisu::redrawCrosshair $visuNo

         #--- je restaure le menu avant de restaurer la taille pour conserver celle d'origine
         $private($visuNo,toplevel) configure -menu $private($visuNo,menu)

         #--- je restaure la taille
         wm geometry $private($visuNo,toplevel) $private($visuNo,geometry)

         #--- je restaure les srcollbars
         grid $private($visuNo,scrollx)
         grid $private($visuNo,scrolly)

         #--- je restaure le zoom
         set ::confVisu::private($visuNo,zoom) $::FullScreen::private($visuNo,zoom)

         #--- je restaure les bordures et le titre
         wm overrideredirect $private($visuNo,toplevel) 0

         #--- je restaure les fenetres filles
         foreach slave $private($visuNo,slaves) {
            set a_exec "grid $slave $private($visuNo,$slave,pack_config)"
            eval $a_exec
         }

         #--- je desactive le bind du clic droit sur la fenetre plein ecran
         bind $private($visuNo,hCanvas) <ButtonPress-3>

         #--- je desactive les autres binds
         bind $private($visuNo,hCanvas) <Key-S>
         bind $private($visuNo,hCanvas) <Key-s>
         bind $private($visuNo,hCanvas) <Key-Down>

         bind $private($visuNo,hCanvas) <Key-P>
         bind $private($visuNo,hCanvas) <Key-p>
         bind $private($visuNo,hCanvas) <Key-Up>

         bind $private($visuNo,hCanvas) <MouseWheel>
         bind $private($visuNo,hCanvas) <Key-Escape>
         bind $private($visuNo,hCanvas) <Key-space>

         #--- je detruis la fenetre
         destroy $private($visuNo,popupmenu)

         #--- je positionne l'indicateur de plein ecran a 0
         set ::confVisu::private($visuNo,fullscreen) "0"

         #--- je restaure le bind du clic droit sur une image
         bind $private($visuNo,hCanvas) <ButtonPress-3> [list tk_popup $::confVisu::private($visuNo,popupmenuButton3) %X %Y]

         #--- je restaure les binds par defaut
         ::confVisu::createBindDialog $visuNo
         set private($visuNo,visuNo)         ""
         set private($visuNo,image)          ""
         set private($visuNo,bufNo)          ""
         set private($visuNo,hWindow)        ""
         set private($visuNo,visuNo,hCanvas) ""
      }
   }

   #------------------------------------------------------------------------------
   #  brief affiche l'image suivante
   #  param visuNo numéro de la visu
   #
   proc loadNextItem { visuNo } {
      variable private

      if { $private($visuNo,currentItemIndex) < [expr [llength $private($visuNo,files) ]-1] } {
         incr private($visuNo,currentItemIndex)
      } else {
         set private($visuNo,currentItemIndex) "0"
         bell
      }
      loadItem $visuNo
   }

   #------------------------------------------------------------------------------
   #  brief affiche l'image précédente
   #  param visuNo numéro de la visu
   #
   proc loadPreviousItem { visuNo } {
      variable private

      if { $private($visuNo,currentItemIndex) > "0" } {
         set private($visuNo,currentItemIndex) [expr $private($visuNo,currentItemIndex) -1]
      } else {
         set private($visuNo,currentItemIndex) [expr [llength $private($visuNo,files) ] -1]
         bell
      }
      loadItem $visuNo
   }

   #------------------------------------------------------------------------------
   #  brief lance ou stope le diaporama
   #  param visuNo numéro de la visu
   #
   proc toggleSlideShow { visuNo } {
      variable private

      if { $private($visuNo,slideShow) == "1" } {
         startSlideShow $visuNo
      } else {
         stopSlideShow $visuNo
      }
   }

   #------------------------------------------------------------------------------
   ## @brief lance le diaporama
   #  @param visuNo numéro de la visu
   #
   proc startSlideShow { visuNo } {
      variable private

      if { $private($visuNo,currentItemIndex) < [expr [llength $private($visuNo,files) ]-1] } {
         incr private($visuNo,currentItemIndex)
      } else {
         set private($visuNo,currentItemIndex) "0"
         bell
      }
      set private($visuNo,SlideShowAfterId) [after 10 ::FullScreen::showNextSlide $visuNo ]
   }

   #------------------------------------------------------------------------------
   ## @brief stoppe le diaporama
   #  @param visuNo numéro de la visu
   #
   proc stopSlideShow { visuNo } {
      variable private

      set private($visuNo,slideShow) "0"
      if { "$private($visuNo,SlideShowAfterId)" != "" } {
         #--- je tue l'iteration en attente
         after cancel $private($visuNo,SlideShowAfterId)
         set private($visuNo,SlideShowAfterId) ""
      }
   }

   #------------------------------------------------------------------------------
   #  brief affiche l'image suivante du diaporama
   #  param visuNo numéro de la visu
   #
   proc showNextSlide { visuNo } {
      variable private
      variable widget

      loadItem $visuNo

      #--- j'incremente currentItemIndex
      if { $private($visuNo,currentItemIndex) < [expr [llength $private($visuNo,files) ]-1] } {
         incr private($visuNo,currentItemIndex)
      } else {
         set private($visuNo,currentItemIndex) "0"
      }

      #--- je lance l'iteration suivante
      if { $private($visuNo,slideShow) == "1" } {
         set result [ catch { set delay [expr round($::FullScreen::config::widget(slideShowDelay) * 1000) ] } ]
         if { $result != 0 } {
            #--- remplace le delai incorrect
            set delay "1000"
         }
         set private($visuNo,SlideShowAfterId) [after $delay ::FullScreen::showNextSlide $visuNo ]
      }
   }

   #------------------------------------------------------------------------------
   ## @brief change la valeur du zoom private($visuNo,zoom)
   #  et affiche l'image ou le film avec le nouveau facteur de zoom
   #  @param visuNo numéro de la visu
   #  @param zoom valeur du zoom
   #
   proc changeZoom { visuNo zoom } {
      variable private
      global conf

      if { $zoom == "auto" } {
         #--- determination du coefficient de zoom automatique
         set zoom_auto_largeur [ expr $private($visuNo,largeur_ecran). / $private($visuNo,largeur_image). ]
         set zoom_auto_hauteur [ expr $private($visuNo,hauteur_ecran). / $private($visuNo,hauteur_image). ]
         if { $zoom_auto_largeur >= $zoom_auto_hauteur } {
            set private($visuNo,zoom_auto) $zoom_auto_hauteur
         } else {
            set private($visuNo,zoom_auto) $zoom_auto_largeur
         }
         set private($visuNo,zoom) "$private($visuNo,zoom_auto)"
      } else {
         set private($visuNo,zoom) "$zoom"
      }

      #--- application du zoom
      visu$visuNo zoom $private($visuNo,zoom)

      #--- rafraichissement de l'image avec le nouveau zoom
      visu$visuNo clear
      while { 1 } {
         set catchResult [catch { visu$visuNo disp } msg ]
         if { $catchResult == 1 && $msg == "NO MEMORY FOR DISPLAY" } {
            #--- en cas d'erreur "NO MEMORY FOR DISPLAY", j'essaie avec un zoom inferieur
            set private($visuNo,zoom) [expr double($private($visuNo,zoom)) / 2]
            if { $private($visuNo,zoom) >= 1 } {
                set private($visuNo,zoom) [expr int($private($visuNo,zoom))]
            }
            visu$visuNo zoom $private($visuNo,zoom)
            ::console::affiche_erreur "WARNING: NO MEMORY FOR DISPLAY, visuNo=$visuNo set zoom=$private($visuNo,zoom)\n"
         } else {
            break
         }
      }

      #--- je rafraichis l'affichage du canvas
      loadItem $visuNo
   }

   #------------------------------------------------------------------------------
   ## @brief charge une image en plein écran
   #  @param visuNo numéro de la visu
   #  @param filename nom du fichier
   #  @param zoom valeur du zoom
   #
   proc loadimage { visuNo filename zoom } {
      variable private

      #--- je masque la fenetre des films
      ::Movie::close $visuNo

      set image   image$visuNo
      set buf     buf[visu$visuNo buf]
      set hCanvas $::confVisu::private($visuNo,hCanvas)

      #--- je charge le fichier dans le buffer
      set result [$buf load $filename]
      if {$result == ""} {
         image delete $image
         image create photo $image
         set seuil_haut [lindex [$buf getkwd MIPS-HI] 1]
         set seuil_bas  [lindex [$buf getkwd MIPS-LO] 1]
         #--- affiche l'image avec les seuils enregistres dans l'image
         visu$visuNo zoom $zoom
         ::confVisu::autovisu $visuNo
      }
      $::confVisu::private($visuNo,hCanvas) itemconfigure display -state normal
   }

   #------------------------------------------------------------------------------
   ## @brief charge un film dans la fenêtre plein écran
   #  @param visuNo numéro de la visu
   #  @param filename nom du fichier
   #
   proc loadmovie { visuNo filename } {
      variable private
      global audace

      #--- je masque la fenetre des images
      $::confVisu::private($visuNo,hCanvas) itemconfigure display -state hidden

      #--- je place la fenetre des films dans le canvas
      set maxsize [wm maxsize $audace(base)]
      set xc [expr [lindex $maxsize 0] /2 ]
      set yc [expr [lindex $maxsize 1] /2 ]

      #--- j'affiche le film
      ::Movie::open $visuNo $filename $xc $yc "center"
   }

   #------------------------------------------------------------------------------
   #  brief active ou désactive le bouton de commande de l'animation
   #  param visuNo numméro de la visu
   #  param state normal ou disabled
   #
   proc setAnimationState { visuNo state } {
      variable private
      global caption

      set menu $private($visuNo,popupmenu)

      #--- je configure le popup menu
      if { $state == "1" } {
         #--- j'active les commandes d'animation
         $menu entryconfigure $caption(fullscreen,animation) -state normal
      }  else {
         #--- je desactive les commandes d'animation
         $menu entryconfigure $caption(fullscreen,animation) -state disabled
      }
   }

   #------------------------------------------------------------------------------
   #  brief lance ou stoppe une animation (film ou GIF anime)
   #  param visuNo numéro de la visu
   #
   proc toggleAnimation { visuNo } {
      variable private

      if { $private($visuNo,animation) == "1" } {
         startAnimation $visuNo
      } else {
         stopAnimation
      }
   }

   #------------------------------------------------------------------------------
   ## @brief lance une animation (film ou GIF anime)
   #  @param visuNo numéro de la visu
   #
   proc startAnimation { visuNo } {
      variable private

      #--- je recupere le nom du fichier selectionne
      set index $private($visuNo,currentItemIndex)
      set name [lindex [lindex $private($visuNo,files) $index] 0 ]
      set type [lindex [lindex $private($visuNo,files) $index] 1 ]
      set filename [file join "$private($visuNo,directory)" "$name"]

      if { "$type" == "$private($visuNo,fileImage)" } {
         ::Image::startGifAnimation image$visuNo $private($visuNo,zoom) "$filename"
      } elseif { "$type" == "$private($visuNo,fileMovie)" } {
         ::Movie::start $visuNo
      }
      set private($visuNo,animation) "1"
      update
   }

   #------------------------------------------------------------------------------
   ## @brief arrête une animation (film ou GIF anime)
   #  @param visuNo numéro de la visu
   #
   proc stopAnimation { visuNo } {
      variable private

      #--- je recupere le nom du fichier selectionne
      set index $private($visuNo,currentItemIndex)
      set name [lindex [lindex $private($visuNo,files) $index] 0 ]
      set type [lindex [lindex $private($visuNo,files) $index] 1 ]
      set filename [file join "$private($visuNo,directory)" "$name"]

      if { "$type" == "$private($visuNo,fileImage)" } {
         ::Image::stopGifAnimation
      } elseif { "$type" == "$private($visuNo,fileMovie)" } {
         ::Movie::stop $visuNo
      }
      set private($visuNo,animation) "0"
      update
   }

   #------------------------------------------------------------------------------
   #  brief creation du menu en popup
   #  param visuNo numéro de la visu
   #
   proc createPopupMenu { visuNo } {
      variable private
      global caption
      global conf
      global help

      set menu $private($visuNo,toplevel).menufullscreen
      set private($visuNo,popupmenu) "$menu"

      menu $menu -tearoff no
      if { ( $private($visuNo,files) == "" ) || ( [ llength $private($visuNo,files) ] == "1" ) } {
         $menu add command -label $caption(fullscreen,next_image) \
            -command "::FullScreen::loadNextItem $visuNo" -state disabled
         $menu add command -label $caption(fullscreen,previous_image) \
            -command "::FullScreen::loadPreviousItem $visuNo" -state disabled
         $menu add checkbutton -label $caption(fullscreen,slide_show) \
            -variable ::FullScreen::private($visuNo,slideShow) \
            -command "::FullScreen::toggleSlideShow $visuNo" -state disabled
      } else {
         $menu add command -label $caption(fullscreen,next_image) \
            -command "::FullScreen::loadNextItem $visuNo" -state normal
         $menu add command -label $caption(fullscreen,previous_image) \
            -command "::FullScreen::loadPreviousItem $visuNo" -state normal
         $menu add checkbutton -label $caption(fullscreen,slide_show) \
            -variable ::FullScreen::private($visuNo,slideShow) \
            -command "::FullScreen::toggleSlideShow $visuNo" -state normal
      }

      $menu add separator
      $menu add cascade -label $caption(fullscreen,zoom) -menu $menu.zoom
      menu $menu.zoom -tearoff no

      foreach zoom $::confVisu::private($visuNo,zoomList) {
         $menu.zoom add radiobutton -label "$caption(fullscreen,zoom) x $zoom" \
            -indicatoron "1" \
            -value "$zoom" \
            -variable ::FullScreen::private($visuNo,zoom) \
            -command "::FullScreen::changeZoom $visuNo $zoom"
      }
      $menu.zoom add radiobutton -label "$caption(fullscreen,zoom_auto)" \
         -indicatoron "1" \
         -value "auto" \
         -variable ::FullScreen::private($visuNo,zoom) \
         -command "::FullScreen::changeZoom $visuNo auto" \
         -state disabled

      $menu add separator
      $menu add checkbutton -label $caption(fullscreen,animation) \
         -variable ::FullScreen::private($visuNo,animation) \
         -command "::FullScreen::toggleAnimation $visuNo"

      if { $private($visuNo,gif_anime) == "0" } {
         $menu entryconfigure $caption(fullscreen,animation) -state disabled
      }
      $menu add command -label $caption(fullscreen,configure) \
         -command "::FullScreen::configure $visuNo"
      $menu add command -label $caption(fullscreen,help) \
         -command "::audace::showHelpPlugin tool visio2 visio2.htm fullscreen"

      $menu add separator
      $menu add command -label $caption(fullscreen,close) \
         -command "::FullScreen::cmdClose $visuNo"

      bind $private($visuNo,hCanvas) <ButtonPress-1> ""
      bind $private($visuNo,hCanvas) <ButtonPress-3> [list tk_popup $menu %X %Y]
      bind $private($visuNo,hCanvas) <Key-S>      "::FullScreen::loadNextItem $visuNo"
      bind $private($visuNo,hCanvas) <Key-s>      "::FullScreen::loadNextItem $visuNo"
      bind $private($visuNo,hCanvas) <Key-Down>   "::FullScreen::loadNextItem $visuNo"

      bind $private($visuNo,hCanvas) <Key-P>      "::FullScreen::loadPreviousItem $visuNo"
      bind $private($visuNo,hCanvas) <Key-p>      "::FullScreen::loadPreviousItem $visuNo"
      bind $private($visuNo,hCanvas) <Key-Up>     "::FullScreen::loadPreviousItem $visuNo"

      bind $private($visuNo,hCanvas) <MouseWheel> {
         if { %D > 0 } {
            ::FullScreen::loadNextItem $visuNo
         } else {
            ::FullScreen::loadPreviousItem $visuNo
         }
      }
      bind $private($visuNo,toplevel) <Key-Escape> "::FullScreen::cmdClose $visuNo"
      bind $private($visuNo,toplevel) <Key-space>  "::FullScreen::cmdClose $visuNo"
   }

   #------------------------------------------------------------------------------
   #  brief ouvre la fenêtre de configuration
   #  param visuNo numéro de la visu
   #
   proc configure { visuNo } {
      variable private
      global audace

      #--- j'affiche la fenetre de configuration
      ::confGenerique::run $visuNo $audace(base).configfullscreen "::FullScreen::config" -modal 0
      raise $private($visuNo,toplevel)
      focus $private($visuNo,toplevel)
   }

}

################################################################
# namespace ::FullScreen::config
#    fenetre de configuration de FullScreen
################################################################

namespace eval ::FullScreen::config {

   #==============================================================
   # Fonctions de configuration generiques appelees par ::confGenerique::run
   #
   # getLabel        retourne le titre de la fenetre de config
   # confToWidget    copie les parametres du tableau conf() dans les variables des widgets
   # cmdApply        copie les variable des widgets dans le tableau conf()
   # fillConfigPage  affiche la fenetre de config
   #==============================================================

   #------------------------------------------------------------
   # ::FullScreen::config::getLabel
   #   retourne le nom de la fenetre de configuration
   #------------------------------------------------------------
   proc getLabel { } {
      global caption

      return "$caption(fullscreen,title)"
   }

   #------------------------------------------------------------
   # ::FullScreen::config::showHelp
   #   affiche l'aide de cette fenetre de configuration
   #------------------------------------------------------------
   proc showHelp { } {
      global help

      ::audace::showHelpPlugin "tool" "visio2" "visio2.htm" "fullscreen_config"
   }

   #------------------------------------------------------------
   # ::FullScreen::config::confToWidget
   #   copie les parametres du tableau conf() dans les variables des widgets
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable widget
      global conf

      set widget(slideShowDelay) "$conf(FullScreen,slideShowDelay)"
      set widget(autoStartAnim)  "$conf(FullScreen,autoStartAnim)"
      set widget(color)          "$conf(FullScreen,color)"
   }

   #------------------------------------------------------------
   # ::FullScreen::config::cmdApply
   #   copie les variable des widgets dans le tableau conf()
   #------------------------------------------------------------
   proc cmdApply { visuNo } {
      variable private
      variable widget
      global conf

      #--- j'enregistre la nouvelle configuration dans conf(...)
      set conf(FullScreen,slideShowDelay) $widget(slideShowDelay)
      set conf(FullScreen,autoStartAnim)  $widget(autoStartAnim)
      set conf(FullScreen,color)          $widget(color)

      #--- j'applique la nouvelle configuration
      $::FullScreen::private($visuNo,hCanvas) configure -bg $conf(FullScreen,color)
   }

   #------------------------------------------------------------
   # ::FullScreen::config::fillConfigPage
   #   fenetre de configuration du panneau
   #   return rien
   #------------------------------------------------------------
   proc fillConfigPage { frm visuNo } {
      variable widget
      global caption

      #--- je memorise la reference de la frame
      set widget(frm) $frm

      #--- j'initialise les variables des widgets
      confToWidget $visuNo

      #--- frame choix du delai pour le diaporama
      frame $frm.slideShow -borderwidth 1 -relief raised
      pack $frm.slideShow -side top -fill both -expand 1

      label $frm.slideShow.label -text "$caption(fullscreen,slide_show1)"
      pack $frm.slideShow.label -in $frm.slideShow -anchor center -side left -padx 10 -pady 10

      label $frm.slideShow.label_delay -text "$caption(fullscreen,slide_show_delai)"
      pack $frm.slideShow.label_delay -in $frm.slideShow -anchor center -side left -padx 0 -pady 10

      set list_combobox [ list "0.5" "1" "2" "3" "5" "10" ]
      ComboBox $frm.slideShow.delay \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [llength $list_combobox] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 1       \
         -takefocus 1      \
        -textvariable FullScreen::config::widget(slideShowDelay) \
         -values $list_combobox
      pack $frm.slideShow.delay -in $frm.slideShow -anchor center -expand 0 -fill none -side left

      label $frm.slideShow.labdelay -borderwidth 1 -text "$caption(fullscreen,seconde)"
      pack $frm.slideShow.labdelay -in $frm.slideShow -anchor center -expand 0 -fill none -side left

      #--- demarrage automatique des animations
      frame $frm.frameAnim -borderwidth 1 -relief raised
      pack $frm.frameAnim -side top -fill both -expand 1

      checkbutton $frm.frameAnim.animation -text "$caption(fullscreen,auto_start_anim)" \
         -highlightthickness 0 -variable FullScreen::config::widget(autoStartAnim)
      pack $frm.frameAnim.animation -anchor center -side left -padx 10 -pady 10

      #--- frame choix couleur de fond
      frame $frm.frameColor -borderwidth 1 -relief raised
      pack $frm.frameColor -side top -fill both -expand 1

      label $frm.frameColor.labColor -text "$caption(fullscreen,color_label)"
      pack $frm.frameColor.labColor -in $frm.frameColor -anchor center -side left -padx 10 -pady 10

      button $frm.frameColor.butColor_color_invariant -relief raised -width 6 -bg $widget(color)\
         -command {
            set temp [ tk_chooseColor -initialcolor ${FullScreen::config::widget(color)} \
               -parent ${FullScreen::config::widget(frm)} -title ${caption(fullscreen,title)} ]
            if  { "$temp" != "" } {
               set FullScreen::config::widget(color) "$temp"
               ${FullScreen::config::widget(frm)}.frameColor.butColor_color_invariant configure \
                  -bg ${FullScreen::config::widget(color)}
            }
         }
      pack $frm.frameColor.butColor_color_invariant -in $frm.frameColor -anchor center -side left -padx 10 -pady 5 -ipady 5

   }

}


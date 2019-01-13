#
## @file movie.tcl
#  @brief lecture des films avi, mov, mpeg (pour plateforme Windows uniquement)
#  @author Michel PUJOL
#  @namespace Movie
#  @brief lecture des films avi, mov, mpeg (pour plateforme Windows uniquement)
#  $Id: movie.tcl 13757 2016-04-27 09:27:24Z rzachantke $
#

namespace eval ::Movie {

   #------------------------------------------------------------
   ## @brief ouvre le fichier du film et affiche la première image
   #  @code
   #  ::Movie::open visuNo filename x y anchor
   #  @endcode
   #  @param visuNo numéro de la visu
   #  @param fileName chemin du fichier
   #  @param x 0 abscisse du coin supérieur gauche
   #  @param y 0 ordonnée du coin supérieur gauche
   #  @param anchor ancre nw
   #
   proc open { visuNo fileName x y anchor} {
      variable private

      Movie::close $visuNo
      #--- je verifie que le package tmci est present
      set result [catch { package require tmci } msg]
      if { $result == 1} {
         set message "error : package \"tmci\" not found "
         console::affiche_erreur "$message \n"
         tk_messageBox -title "Movie.tcl" -type ok -message "$message" -icon error
         return
      }

      set zoom [::confVisu::getZoom $visuNo]
      set hCanvas [::confVisu::getCanvas $visuNo]
      set hWindow [createMovieWindow $visuNo $x $y $anchor]
      catch {
         #--- je ferme la session
         #mci "close aliasmovie"
      }

      #--- j'ouvre le film et associe a la fenetre de style child
      set result [catch { mci "open \"$fileName\" alias aliasmovie$visuNo " } msg]
      if { $result == 1} {
         return 0
      }

      #--- je recupere les dimensions du film
      set frameSize [mci "where aliasmovie$visuNo source"]
      set w [lindex $frameSize 2]
      set h [lindex $frameSize 3]

      #--- calcul des dimensions en fonction du zoom
      set w_zoomed [expr int(${zoom}*$w)]
      set h_zoomed [expr int(${zoom}*$h)]
      set private($visuNo,hWindow) $hWindow

      #--- j'adapte les dimensions de la fenetre
      $hCanvas itemconfigure avi -width $w_zoomed -height $h_zoomed
      #--- je mets la fenetre au premier plan
      $hCanvas raise $private($visuNo,hWindow)

      #--- j'adapte la taille de l'image en fonction du zoom
      mci "put aliasmovie$visuNo destination at 0 0 $w_zoomed $h_zoomed"

      #--- je recupere le handle WINDOWS de la fenetre
      scan [winfo id $private($visuNo,hWindow) ] 0x%x canvasid
      #--- j'associe le handle WINDOWS a l'alias MCI
      mci "window aliasmovie$visuNo handle $canvasid"
      #after 5 { mci "update aliasmovie$visuNo hdc 0 wait" }
      #--- j'affiche la premiere image du film par dessus le background de la fenetre
      mci "update aliasmovie$visuNo hdc 0"
      update

      #--- je raffraichis l'affichage du reticule
      #--- je redessine le reticule
      set ::confVisu::private($visuNo,picture_w) $w
      set ::confVisu::private($visuNo,picture_h) $h
      ::confVisu::redrawCrosshair $visuNo

      #--- je cree un bind pour raffraichir l'affichage chaque fois que le curseur de la souris revient sur la fenetre
      #--- j'affiche la premiere image du film par dessus le background de la fenetre
      bind $hWindow <Enter> "mci \"update aliasmovie$visuNo hdc 0\""

      set private($visuNo,opened) 1
      #mci "play aliasmovie$visuNo from 0:0:0 to 0:0:0 wait"
      after 100 "mci \"update aliasmovie$visuNo hdc 0\""
      update
   }

   #------------------------------------------------------------
   ## @brief ferme le film et masque la fenêtre
   #  @code
   #  ::Movie::close visuNo
   #  @endcode
   #  @param visuNo numéro de la visu
   #
   proc close { visuNo } {
      variable private

      if { [info exists private($visuNo,opened) ]==0 || $private($visuNo,opened) == 0 } return

      set hCanvas [::confVisu::getCanvas $visuNo]
      catch {
         #--- j'annule le bind
         bind $hCanvas.movie <Enter> {}
      }

      catch {
         #--- je ferme la session mci
         mci "close aliasmovie$visuNo"
      }
      #--- je supprime le canvas
      deleteMovieWindow $visuNo
      set private($visuNo,opened) 0
   }

   #------------------------------------------------------------
   ## @brief démarre la lecture du film
   #  @code
   #  ::Movie::start visuNo
   #  @endcode
   #  @param visuNo numéro de la visu
   #
   proc start { visuNo } {
      catch { mci "play aliasmovie$visuNo from 0:0:0" }
   }

   #------------------------------------------------------------
   ## @brief arrête la lecture du film
   #  @code
   #  ::Movie::stop visuNo
   #  @endcode
   #  @param visuNo numéro de la visu
   #
   proc stop { visuNo } {
      catch { mci "stop aliasmovie$visuNo" }
   }

   #------------------------------------------------------------
   ## @brief créé la fenêtre pour les films et l'ajoute au canvas
   #  @param visuNo numéro de la visu
   #  @param x 0 abscisse du coin supérieur gauche
   #  @param y 0 ordonnée du coin supérieur gauche
   #  @param anchor ancre nw
   #  @return \$hWindow
   proc createMovieWindow { visuNo x y anchor} {

      set hCanvas [::confVisu::getCanvas $visuNo]
      set hWindow $hCanvas.movie
      #--- je cree une fenetre pour visualiser le film
      if { ![winfo exists $hWindow ] } {
         #--- le widget "label" est la plus simple des fenetres
         label $hWindow -bg darkGreen
      }
      #--- je declare le label comme item du canvas
      $hCanvas create window $x $y -tag avi -anchor $anchor -window $hWindow -width 1 -height 1
      return $hWindow
   }

   #------------------------------------------------------------
   #  brief detruit la canvasItem car il n'est pas possible de la masquer
   #  param visuNo numéro de la visu
   #
   proc deleteMovieWindow { visuNo } {

      set hCanvas [::confVisu::getCanvas $visuNo]
      $hCanvas delete avi
   }
}


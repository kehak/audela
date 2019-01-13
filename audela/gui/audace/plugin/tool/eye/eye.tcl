## @file      eye.tcl
#  @brief     Projet EYE : Pilotage d un chercheur electronique asservissant une monture
#  @author    Frederic Vachier
#  @date      2013
#  @copyright GNU Public License.
#  @warning   Outil en developpement
#  @par       Ressource
#  @code      source [file join $audace(rep_install) gui audace plugin tool eye eye.tcl]
#  @endcode
#  @version   1.3
#  $Id: eye.tcl 14055 2016-10-01 00:20:40Z fredvachier $

##
# @defgroup eye_notice_fr Eye
#
# Eye est un outil permettant de piloter un télescope en
# utilisant un chercheur électronique.
#
# @warning Outil en développement
#
# @defgroup eye_presentation Présentation
# @ingroup  eye_notice_fr
#
# Eye est un outil compact et se décline sur plusieurs onglets.
#
# - <b> Coordonnees </b>: propose un moyen de choisir les objets à pointer par une connexion avec carte du ciel, une liste d'etoiles brillantes
# visibles a l'instant de l'observation, un catalogue Perso pour ajouter ses propres objets, les planètes, les objets du systeme solaire, les Messier.
# On y trouve les coordonnées de l'objet à pointer, la position de la monture fournie par le télescope, la position du champs de vue issue de
# l'astrometrie du champ du chercheur electronique, le differentiel de pointage issue de la difference entre l astrometrie du chercheur électronique
# et la coordonnées de l'objet à pointer, les infos sur l'entraînement du télescope. Chaque coordonnée peut servir à synchroniser la monture
# pour amèliorer le modèle de pointage autour de la zone observée.
#
# - <b> FOV </b>: permet de choisir la position du réticule dans l'image du chercheur électronique pour fixer la zone observée par la caméra au foyer
# primaire. Un outil de simulation d'image pour representer au mieux ce qui est vu dans le chercheur electronique, en ajoutant des étoiles et en
# effectuant une rotation dans l'image. Un outil de mesure du centre mécanique de la monture, et de son alignement avec le pôle céleste.
#
# - <b> Mots Cles </b>: affiche le contenu du WCS issu de l'astrométrie du chercheur électronique.
#
# - <b> Config </b>: des paramètres de configuration de l'outil
#
# - <b> Game &  Gameconf </b>: un système de prise de décision proposant un storyboard en vue de proposer étape par étape le déroulement d'une occultation réussie
#
# - <b> Dev </b>: le coin des développeurs avec ressource des script et de la gui, simulation de champs de vue réel sur différentes étoiles.
# .
#
# @todo Choses à faire
# - Fonctionnel
#   - Différencier les types de montures EQ5 et EQ6 pour l'EQMOD
#   - Ajouter le pilotage par le protocole LX200 et vérifier la compatibilité de l'outil
#   - Modifier le catalogue stellaire de la simulation en prennant HIPPARCOS dàs qu'il sera disponible
#   - Ajouter les objets diffus dans les images simulées et dans la visualisation du chercheur par sélection
#   .
# .

   #============================================================
   ##
   # @brief    Pilotage d'une monture et d'un chercheur electronique
   # @warning  Requiert les ressources de bddimages et d'ATOS
   #
   #============================================================
   namespace eval ::eye {

      global caption
      package provide eye 1.3
      source [ file join [file dirname [info script]] eye.cap ]

      # @var variable tableau qui concerne la simulation d'image
      variable fov
   }

   #============================================================
   ##
   # @brief    Mise a jour des scripts Eye dans Audela
   # @return   void
   # @warning  Ressource au passage tout bddimages et wcs_tools.tcl
   #
   #============================================================
   proc ::eye::ressource {  } {

      global audace

      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.cap ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.test.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.methode.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.methode.bogumil.tcl      ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.methode.calibwcs_new.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.methode.calibwcs.tcl     ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.header.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.display.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.coord.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.telescop.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.camera.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.fov.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.event.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.stars.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.game.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.game.tree.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.game.scenarii.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.game.view.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.demo.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.targets.tcl ]\""
      uplevel #0 "source \"[ file join $audace(rep_plugin) tool eye eye.funcs.joystick.tcl ]\""

      uplevel #0 "source \"[ file join $audace(rep_install) src libtel libeqmod extra src eqmod.tcl  ]\""

      source $audace(rep_install)/gui/audace/wcs_tools.tcl

      ::bddimages::ressource
      ::console::clear

   }

   #============================================================
   ##
   # @brief    Mise a jour des scripts et de la GUI Eye dans Audela
   # @return   void
   #
   #============================================================
   proc ::eye::recharge {  } {

      ::eye::ressource
      ::eye::cmdClose $::eye::visuNo
      destroy $::eye::tkbase
      ::eye::startTool $::eye::visuNo

   }

   #============================================================
   ##
   # @brief    Met a jour les captions
   # @return   void
   #
   #============================================================
   proc ::eye::setcaption {  } {

      global caption

   }

   #============================================================
   ##
   # @brief    Met a jour les captions
   # @param    propertyName Nom de la propriete
   # @return   valeur de la propriete , ou "" si la propriete n'existe pas
   #
   #============================================================
   proc ::eye::getPluginProperty { propertyName } {
      switch $propertyName {
         function     { return "analysis" }
         subfunction1 { return "astrometry" }
         display      { return "window" }
      }
   }

   #============================================================
   ##
   # @brief    Retourne le nom du fichier d'aide principal
   # @return   nom du fichier
   #
   #============================================================
   proc ::eye::getPluginHelp { } {
      return "editimage.htm"
   }

   #============================================================
   ##
   # @brief    Retourne le titre du plugin dans la langue de l'utilisateur
   # @return   Titre du plugin
   #
   #============================================================
   proc ::eye::getPluginTitle { } {
      global caption
      return "$caption(eye,title)"
   }

   #============================================================
   ##
   # @brief    Retourne le type de plugin
   # @return   Type
   #
   #============================================================
   proc ::eye::getPluginType { } {
      return "tool"
   }

   #============================================================
   ##
   # @brief    Retourne le repertoire du plugin
   # @return   Repertoire du plugin
   #
   #============================================================
   proc ::eye::getPluginDirectory { } {
      return "eye"
   }

   #============================================================
   ##
   # @brief    Retourne le ou les OS de fonctionnement du plugin
   # @return   Type d'OS
   #
   #============================================================
   proc ::eye::getPluginOS { } {
      return [list Linux Windows]
   }

   #============================================================
   ##
   # @brief    Cree une instance de l'outil
   # @param    tkbase : Racine de la base Tk
   # @param   visuNo : Numero de la visu (1 par defaut)
   # @return   Racine de l'outil Tk EYE
   #
   #============================================================
   proc ::eye::createPluginInstance { tkbase { visuNo 1 } } {

      global conf
      global audace
      global caption

      package require Tablelist

      ::eye::ressource

      set ::eye::visuNo    $visuNo
      set ::eye::tkbase    "$tkbase.eye"
      set ::eye::bufNo     [confVisu::getBufNo $::eye::visuNo]

      set ::eye::hCanvas   [::confVisu::getCanvas $::eye::visuNo]
      set ::eye::extension [buf$::eye::bufNo extension]
      set ::eye::tel 1

      set ::eye::evt_bufNo [::buf::create]
      #buf$::eye::evt_bufNo setkwd {{NAXIS1} 752 {int} {  } { }}
      #buf$::eye::evt_bufNo setkwd {{NAXIS2} 576 {int} {  } { }}

      #--- Creation des variables si elles n'existaient pas
      if { ! [ info exists conf(eye,position) ] }      { set conf(eye,position)      "300x200+500+600" }
      if { ! [ info exists conf(eye,kappa) ] }         { set conf(eye,kappa)         "3"               }
      if { ! [ info exists conf(eye,delta) ] }         { set conf(eye,delta)         "4"               }
      if { ! [ info exists conf(eye,epsilon) ] }       { set conf(eye,epsilon)       "0.0002"          }
      if { ! [ info exists conf(eye,cataloguePath) ] } { set conf(eye,cataloguePath) ""                }
      if { ! [ info exists conf(eye,magnitude) ] }     { set conf(eye,magnitude)     "10"              }
      if { ! [ info exists conf(eye,catalogue) ] }     { set conf(eye,catalogue)     "USNOA2"          }
      if { ! [ info exists conf(eye,methode) ] }       { set conf(eye,methode)       "BOGUMIL"         }
      if { ! [ info exists conf(eye,fov_diam) ] }      { set conf(eye,fov_diam)      "5"               }
      if { ! [ info exists conf(eye,threshin) ] }      { set conf(eye,threshin)      "10"              }
      if { ! [ info exists conf(eye,fwhm) ] }          { set conf(eye,fwhm)          "4"               }
      if { ! [ info exists conf(eye,radius) ] }        { set conf(eye,radius)        "4"               }
      if { ! [ info exists conf(eye,threshold) ] }     { set conf(eye,threshold)     "10"              }
      if { ! [ info exists conf(eye,uneimage) ] }      { set conf(eye,uneimage)      ""                }
      if { ! [ info exists conf(eye,simu_catalog) ] }  { set conf(eye,simu_catalog)  "/astrodata/Catalog/Stars/TYCHO2_facon_USNO"}
      if { ! [ info exists conf(eye,simu_dra) ] }      { set conf(eye,simu_dra)      "20"              }
      if { ! [ info exists conf(eye,simu_ddec) ] }     { set conf(eye,simu_ddec)     "20"              }
      if { ! [ info exists conf(eye,calib_tmpdir) ] }  { set conf(eye,calib_tmpdir)  "."               }
      if { ! [ info exists conf(eye,dev,isit) ] }      { set conf(eye,dev,isit)      0                 }

      #--- J'affiche la fenetre
      set ::eye::visuNo    $visuNo
      if { [winfo exists $::eye::tkbase ] == 0 } {
         #--- j'affiche la fenetre
         ::confGenerique::run $::eye::visuNo $::eye::tkbase [namespace current] \
            -modal 0 \
            -geometry $::conf(eye,position) \
            -resizable 1 \

      } else {
         focus $::eye::tkbase
      }

      # @todo Decrementer le dernier nombre de 28 pixel : set conf(eye,position) "300x200+500+600" (600 - 28)

      return $::eye::tkbase
   }

   #============================================================
   ##
   # @brief    Suppprime l'instance du plugin
   # @param    visuNo : Numero de la visu (1 par defaut)
   # @return   void
   #
   #============================================================
   proc ::eye::deletePluginInstance { visuNo } {
      gren_info "deletePluginInstance: stop\n"
   }


   #------------------------------------------------------------
   ## affiche la fenetre de l'outil
   # @return void
   #
   proc ::eye::startTool { visuNo } {

      #--- j'active la mise a jour automatique de l'affichage quand on change de zoom
      ::confVisu::addZoomListener     $visuNo "::eye::onChangeDisplay"
      ::confVisu::addFileNameListener $visuNo "::eye::displayWcs"

      #--- j'affiche les mots cles de l'image presente dans la visu
      ::eye::displayWcs
   }

   #------------------------------------------------------------
   ## masque la fenetre de l'outil
   # @param visuNo numéro de la visu
   # @return void
   #
   proc ::eye::stopTool { visuNo } {

      #--- je desactive l'adaptation de l'affichage quand on change de zoom
      ::confVisu::removeZoomListener     $visuNo "::eye::onChangeDisplay"
      ::confVisu::removeFileNameListener $visuNo "::eye::displayWcs"

      #--- sauve la conf eye
      ::eye::widget_to_conf

   }



   #------------------------------------------------------------
   ## Fetourne le nom de la fenetre de configuration
   # @return nom de la fenetre de configuration
   #
   proc ::eye::getLabel { } {
      global caption
      return "$caption(eye,title)"
   }

   #------------------------------------------------------------
   ## Ferme la fenetre de l'outil
   # @return void
   #
   proc ::eye::cmdClose { visuNo } {


      # Effacement des traces dans les images
      ::eye::deleteStar

      # TODO : Cloture de la visu de la simulation

      # Arret de l outil
      ::eye::stopTool $visuNo

      # Sans ce "update" la fenetre ne se ferme pas !!!!
      update
   }







   #------------------------------------------------------------
   ## Affiche la fenetre pour choisir le repertoire du catalogue.
   # @pre       On garde au cas ou on a un besoin quelconque d ouverture de repertoire
   # @warning   Outil qui devrait devenir obsolete
   # @return void
   #
   proc ::eye::onChooseDirectory  { } {

      set result [ tk_chooseDirectory -title $::caption(eye,calatoguePath) -initialdir $::conf(eye,cataloguePath) -parent $::eye::frmbase  ]
      if {$result!=""} {
         set widget(obsolete) [file nativename $result]
      }
   }

   #------------------------------------------------------------
   ## Chargement d'une image de test
   # @pre       L'image a pu etre sauver auparavent pour l outil acquisition
   # @warning
   # @return void
   #
   proc ::eye::charge_une_image_test { { star "" } } {

      global conf audace

      if { $star == "" } {
         set ::eye::widget(camera,test,uneimage) [string trim $::eye::widget(camera,test,uneimage)]
         if {$::eye::widget(camera,test,uneimage) != ""} {
            set conf(eye,uneimage) $::eye::widget(camera,test,uneimage)
            gren_info "conf(eye,uneimage) = $conf(eye,uneimage) \n"
            loadima $::eye::widget(camera,test,uneimage)

            set ::eye::widget(keys,img,ra)       [mc_angle2hms [lindex [buf$::eye::bufNo getkwd "CRVAL1"]  1] 360 zero 1 auto string]
            set ::eye::widget(keys,img,dec)      [mc_angle2dms [lindex [buf$::eye::bufNo getkwd "CRVAL2"] 1] 90 zero 1 + string]
            set ::eye::widget(keys,img,equinox)  [lindex [buf$::eye::bufNo getkwd "EQUINOX"] 1]
            set ::eye::widget(keys,img,pixsize1) [lindex [buf$::eye::bufNo getkwd "PIXSIZE1"] 1]
            set ::eye::widget(keys,img,pixsize2) [lindex [buf$::eye::bufNo getkwd "PIXSIZE2"] 1]
            set ::eye::widget(keys,img,crpix1)   [lindex [buf$::eye::bufNo getkwd "CRPIX1"] 1]
            set ::eye::widget(keys,img,crpix2)   [lindex [buf$::eye::bufNo getkwd "CRPIX2"] 1]
            set ::eye::widget(keys,img,crval1)   [lindex [buf$::eye::bufNo getkwd "CRVAL1"] 1]
            set ::eye::widget(keys,img,crval2)   [lindex [buf$::eye::bufNo getkwd "CRVAL2"] 1]
            set ::eye::widget(keys,img,foclen)   [lindex [buf$::eye::bufNo getkwd "FOCLEN"] 1]
            set ::eye::widget(keys,img,crota2)   [lindex [buf$::eye::bufNo getkwd "CROTA2"] 1]
            set ::eye::widget(keys,img,cdelt1)   [lindex [buf$::eye::bufNo getkwd "CDELT1"] 1]
            set ::eye::widget(keys,img,cdelt2)   [lindex [buf$::eye::bufNo getkwd "CDELT2"] 1]

            set ::eye::widget(keys,new,ra)       $::eye::widget(keys,img,ra)
            set ::eye::widget(keys,new,dec)      $::eye::widget(keys,img,dec)
            set ::eye::widget(keys,new,equinox)  $::eye::widget(keys,img,equinox)
            set ::eye::widget(keys,new,pixsize1) $::eye::widget(keys,img,pixsize1)
            set ::eye::widget(keys,new,pixsize2) $::eye::widget(keys,img,pixsize2)
            set ::eye::widget(keys,new,crpix1)   $::eye::widget(keys,img,crpix1)
            set ::eye::widget(keys,new,crpix2)   $::eye::widget(keys,img,crpix2)
            set ::eye::widget(keys,new,crval1)   $::eye::widget(keys,img,crval1)
            set ::eye::widget(keys,new,crval2)   $::eye::widget(keys,img,crval2)
            set ::eye::widget(keys,new,foclen)   $::eye::widget(keys,img,foclen)
            set ::eye::widget(keys,new,crota2)   $::eye::widget(keys,img,crota2)
            set ::eye::widget(keys,new,cdelt1)   $::eye::widget(keys,img,cdelt1)
            set ::eye::widget(keys,new,cdelt2)   $::eye::widget(keys,img,cdelt2)
         }
         return
      }

      if { $star == "Polaris" } {
         #set ::eye::widget(coord,wanted,raJ2000)  "02h31m49.1s"
         #set ::eye::widget(coord,wanted,decJ2000) "+89d15m51s"
         set ::eye::widget(coord,wanted,raJ2000)  "02h31m52.740s"
         set ::eye::widget(coord,wanted,decJ2000) "+89d15m50.60s"
         loadima [file join $audace(rep_plugin) tool eye imgtest Polaris.fit]
         return
      }
      if { $star == "Mizar" } {
         set ::eye::widget(coord,wanted,raJ2000)  "13h23m55.5s"
         set ::eye::widget(coord,wanted,decJ2000) "+54d55m31s"
         loadima [file join $audace(rep_plugin) tool eye imgtest Mizar.fit]
         return
      }
      if { $star == "Alkaid" } {
         set ::eye::widget(coord,wanted,raJ2000)  "13h47m32.4s"
         set ::eye::widget(coord,wanted,decJ2000) "+49d18m48s"
         loadima [file join $audace(rep_plugin) tool eye imgtest Alkaid.fit]
         return
      }
      if { $star == "KausAustralis" } {
         set ::eye::widget(coord,wanted,raJ2000)  "18h24m10.2s"
         set ::eye::widget(coord,wanted,decJ2000) "-34d23m6.7s"
         loadima [file join $audace(rep_plugin) tool eye imgtest KausAustralis.fit]
         return
      }

   }

   #------------------------------------------------------------
   ## Appliquer
   # @pre       copie les variables widget() dans le tableau conf()
   # @warning
   # @return void
   #
   proc ::eye::widget_to_conf { } {

      global conf

      if {[info exists ::eye::frmbase]} {
         if {[winfo exists $::eye::frmbase]} {
            set conf(eye,position) [winfo geometry [winfo toplevel $::eye::frmbase ]]
         }
      }

      set conf(eye,methode)      $::eye::widget(methode)
      set conf(eye,delta)        $::eye::widget(methode,delta)
      set conf(eye,epsilon)      $::eye::widget(methode,epsilon)
      set conf(eye,magnitude)    $::eye::widget(methode,magnitude)
      set conf(eye,catalogue)    $::eye::widget(methode,catalogue)

      set conf(eye,kappa)        $::eye::widget(methode,stat,kappa)

      set conf(eye,threshin)     $::eye::widget(methode,bogumil,threshin)
      set conf(eye,fwhm)         $::eye::widget(methode,bogumil,fwhm)
      set conf(eye,radius)       $::eye::widget(methode,bogumil,radius)
      set conf(eye,threshold)    $::eye::widget(methode,bogumil,threshold)

      set conf(eye,fov_diam)     $::eye::widget(telescope,fov,diam)

      set conf(eye,simu_catalog) $::eye::widget(simu,catalog)
      set conf(eye,simu_dra)     $::eye::widget(simu,dra)
      set conf(eye,simu_ddec)    $::eye::widget(simu,ddec)

      set conf(eye,calib_tmpdir) $::eye::widget(methode,calib_tmpdir)

      set conf(eye,dev,isit)     $::eye::widget(dev,isit)

   }



   #------------------------------------------------------------
   ## fenetre de configuration
   # @param frm    : frame de l outil
   # @param visuNo : numéro de la visu
   # @return void
   #
   proc ::eye::fillConfigPage { frm visuNo } {

      variable widget
      global caption conf audace

      set ::eye::frmbase $frm

      set ::eye::visuNo $visuNo

      set ::eye::dir_img [ file join $audace(rep_plugin) tool eye img ]

      #--- j'initialise les variables des widgets
      set ::eye::widget(methode)                   $conf(eye,methode)
      set ::eye::widget(methode,catalogue)         $conf(eye,catalogue)
      set ::eye::widget(methode,delta)             $conf(eye,delta)
      set ::eye::widget(methode,epsilon)           $conf(eye,epsilon)
      set ::eye::widget(methode,magnitude)         $conf(eye,magnitude)
      set ::eye::widget(methode,stat,kappa)        $conf(eye,kappa)
      set ::eye::widget(methode,bogumil,threshin)  $conf(eye,threshin)
      set ::eye::widget(methode,bogumil,fwhm)      $conf(eye,fwhm)
      set ::eye::widget(methode,bogumil,radius)    $conf(eye,radius)
      set ::eye::widget(methode,bogumil,threshold) $conf(eye,threshold)
      set ::eye::widget(telescope,fov,diam)        $conf(eye,fov_diam)
      set ::eye::widget(camera,test,uneimage)      $conf(eye,uneimage)

      set ::eye::widget(simu,catalog)              $conf(eye,simu_catalog)
      set ::eye::widget(simu,dra)                  $conf(eye,simu_dra)
      set ::eye::widget(simu,ddec)                 $conf(eye,simu_ddec)

      set ::eye::widget(telescope,reticule,select) 0
      set ::eye::widget(camera,integ,sum)          1

      set ::eye::widget(dev,isit)                  $conf(eye,dev,isit)

# TODO

      wm geometry .audace.tool.eye 1598x242+0+640

      set ::eye::widget(fov,boxradius) 20
      set ::eye::widget(fov,nbref) 20
      set ::eye::widget(fov,rdiff) 5
      set ::eye::widget(fov,driftspeed) 10

      set ::eye::widget(methode,cataloguePath) "/astrodata/Catalog/USNOA2"
      set ::eye::widget(methode,pixsize1) 8.6
      set ::eye::widget(methode,pixsize2) 8.3
      set ::eye::widget(methode,foclen) 0.025

      set ::eye::widget(methode,calib_tmpdir) $conf(eye,calib_tmpdir)

      set ::eye::widget(methode,calibwcs_new,delta)     3.5
      set ::eye::widget(methode,calibwcs_new,nmax)      35
      set ::eye::widget(methode,calibwcs_new,fluxcrit)  0
      set ::eye::widget(methode,calibwcs,tycho_facon_usno) "/astrodata/Catalog/Stars/TYCHO2_facon_USNO"
      set ::eye::widget(methode,calibwcs,catalog) "TYCHO2"
      set ::eye::widget(methode,calibwcs,maglimit) 11
      set ::eye::widget(tree,origin) 1
      set ::eye::widget(tree,verif) 1
      set ::eye::widget(tree,pdf) 0
      set ::eye::widget(joystick,vitesse,1) 0.25
      set ::eye::widget(joystick,vitesse,2) 0.5
      set ::eye::widget(joystick,vitesse,3) 0.75
      set ::eye::widget(joystick,vitesse,4) 1


      ::eye::setcaption

      ::eye::init_mesure $::eye::visuNo

      set onglets [frame $frm.onglets -borderwidth 4  ]
      grid $onglets -in $frm  -columnspan 1 -rowspan 1 -sticky ewns

#      grid $onglets    -in $frm -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

#           pack [ttk::notebook $onglets.nb] -expand yes -fill both
         grid [ttk::notebook $onglets.nb ] -sticky ewns

         set f_coord [ frame $onglets.nb.f_coord ]
         set f_meth  [ frame $onglets.nb.f_meth  ]
         set f_keys  [ frame $onglets.nb.f_keys  ]
         set f_point [ frame $onglets.nb.f_point ]
         set f_guid  [ frame $onglets.nb.f_guid  ]
         set f_cam   [ frame $onglets.nb.f_cam   ]
         set f_tools [ frame $onglets.nb.f_tools ]
         set f_fov   [ frame $onglets.nb.f_fov   ]
         set f_setup [ frame $onglets.nb.f_setup ]
         set f_gconf [ frame $onglets.nb.f_gconf ]
         set f_game  [ frame $onglets.nb.f_game  ]
         set f_joy   [ frame $onglets.nb.f_joy   ]
         set f_dev   [ frame $onglets.nb.f_dev   ]

         $onglets.nb add $f_coord -text "Coordonnees" -underline 0
         #$onglets.nb add $f_point -text "Pointeurs"   -underline 0
         $onglets.nb add $f_fov   -text "FOV"         -underline 0
         if {$::eye::widget(dev,isit)} {$onglets.nb add $f_meth  -text "Methodes"    -underline 0}
         $onglets.nb add $f_keys  -text "Mots Cles"   -underline 2
         if {$::eye::widget(dev,isit)} {$onglets.nb add $f_guid  -text "Guidage"     -underline 0}
         if {$::eye::widget(dev,isit)} {$onglets.nb add $f_cam   -text "Camera"      -underline 1}
         if {$::eye::widget(dev,isit)} {$onglets.nb add $f_tools -text "Outils"      -underline 0}
         $onglets.nb add $f_setup -text "Config"      -underline 0
         $onglets.nb add $f_gconf -text "GameConf"    -underline 0
         $onglets.nb add $f_game  -text "Game"        -underline 0
         $onglets.nb add $f_joy   -text "Joystick"    -underline 0
         $onglets.nb add $f_dev   -text "Dev"         -underline 0

         #$onglets.nb select $f_coord
         $onglets.nb select $f_game
         ttk::notebook::enableTraversal $onglets.nb


# Onglet : Coordonnees

         set frmtable [frame $f_coord.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white ]
         pack $frmtable -in $f_coord -expand no -fill none
         #grid $frmtable -in $f_coord -sticky news


         set ablock [ frame $frmtable.a ]

            TitleFrame $ablock.selectobj -borderwidth 2 -text "Target"

               Button $ablock.selectobj.carte   -text "Carte"    -width 8 -command "::eye::getRadecFromChart"
               Button $ablock.selectobj.myliste -text "Etoiles"  -width 8 -command "::eye::getRadecFromStarList"
               Button $ablock.selectobj.planet  -text "Planete"  -width 8 -command "" -state disabled
               Button $ablock.selectobj.perso   -text "Perso"    -width 8 -command "::eye::targets_perso"

               Button $ablock.selectobj.messier -text "Messier"  -width 8 -command "" -state disabled
               Button $ablock.selectobj.sso     -text "SSO"      -width 8 -command "" -state disabled
               Button $ablock.selectobj.park    -text "Parking"  -width 8 -command "::eye::tel_goto_parking"

         set bblock [ frame $frmtable.b ]

            TitleFrame $bblock.grab -borderwidth 2 -text "$caption(eye,coords)"

               label  $bblock.grab.name_new_raJ2000  -text "RA J2000"
               entry  $bblock.grab.new_raJ2000       -textvariable ::eye::widget(coord,wanted,raJ2000)  -width 15 -justify center
               label  $bblock.grab.name_new_decJ2000 -text "DEC J2000"
               entry  $bblock.grab.new_decJ2000      -textvariable ::eye::widget(coord,wanted,decJ2000)  -width 15 -justify center
               Button $bblock.grab.goto              -text "GOTO"  -width 8 \
                                                       -command "::eye::tel_goto"
               Button $bblock.grab.sync              -text "Sync"  -width 8 \
                                                       -command "::eye::tel_init_pos_on_map"

            TitleFrame $bblock.mount -borderwidth 2 -text "Position de la monture"

               label  $bblock.mount.status        -text "Status :"
               label  $bblock.mount.stat          -textvariable ::eye::widget(coord,mount,state)
               label  $bblock.mount.distance      -text "Distance :"
               label  $bblock.mount.dist          -textvariable ::eye::widget(coord,mount,dist)

               label  $bblock.mount.name_raJ2000  -text "RA J2000"
               entry  $bblock.mount.raJ2000       -textvariable ::eye::widget(coord,mount,raJ2000) -width 15 -justify center
               label  $bblock.mount.name_decJ2000 -text "DEC J2000"
               entry  $bblock.mount.decJ2000      -textvariable ::eye::widget(coord,mount,decJ2000) -width 15 -justify center
               Button $bblock.mount.refresh       -text "Refresh"  -width 8 \
                                                    -command "::eye::tel_get_pos"
         set cblock [ frame $frmtable.c ]

            TitleFrame $cblock.calib -borderwidth 2 -text "Position du champ de vue du telescope"

               label  $cblock.calib.nraJ2000   -text "RA J2000"
               entry  $cblock.calib.eraJ2000   -textvariable ::eye::widget(coord,reticule,raJ2000) \
                                                    -width 15 -justify center -state disabled
               label  $cblock.calib.ndecJ2000  -text "DEC J2000"
               entry  $cblock.calib.edecJ2000  -textvariable ::eye::widget(coord,reticule,decJ2000) \
                                                    -width 15 -justify center -state disabled
               Button $cblock.calib.calib      -text "Calibration"  -width 8 \
                                                 -command "::eye::startCalibration"
               Button $cblock.calib.sync       -text "Sync"  -width 8 \
                                                 -command "::eye::tel_init_pos_on_calib"

            TitleFrame $cblock.precis -borderwidth 2 -text "Differentiel de pointage"

               label  $cblock.precis.ndraJ2000  -text "Delta Ra"
               entry  $cblock.precis.edraJ2000  -textvariable ::eye::widget(coord,reticule,draJ2000) \
                                                    -width 12 -justify center -state disabled
               label  $cblock.precis.nddecJ2000 -text "Delta Dec"
               entry  $cblock.precis.eddecJ2000 -textvariable ::eye::widget(coord,reticule,ddecJ2000) \
                                                    -width 12 -justify center -state disabled
               label  $cblock.precis.ndistJ2000 -text "Distance"
               entry  $cblock.precis.edistJ2000 -textvariable ::eye::widget(coord,reticule,distJ2000) \
                                                    -width 12 -justify center -state disabled
               Button $cblock.precis.move       -text "Move"  -width 8 \
                                                  -command "::eye::tel_move_offset"

         set dblock [ frame $frmtable.d ]

            TitleFrame $dblock.tracking -borderwidth 2 -text "Tracking"

               Button $dblock.tracking.check -text "Check Motor" -command "::eye::tel_tracking"
               entry  $dblock.tracking.value -textvariable ::eye::widget(coord,mount,motor) \
                                                    -width 12 -justify center -state disabled
               Button $dblock.tracking.ton   -text "Tracking ON" -command "::eye::tel_tracking_on"
               Button $dblock.tracking.toff  -text "Tracking OFF" -command "::eye::tel_tracking_off"



         grid $ablock $bblock $cblock $dblock -in $frmtable -sticky nw

            grid $ablock.selectobj -in $ablock -sticky nw

               grid $ablock.selectobj.carte    -in [$ablock.selectobj getframe]  -row 0 -column 0  -sticky w
               grid $ablock.selectobj.myliste  -in [$ablock.selectobj getframe]  -row 1 -column 0  -sticky w
               grid $ablock.selectobj.planet   -in [$ablock.selectobj getframe]  -row 2 -column 0  -sticky w
               grid $ablock.selectobj.perso    -in [$ablock.selectobj getframe]  -row 3 -column 0  -sticky w

               grid $ablock.selectobj.messier  -in [$ablock.selectobj getframe]  -row 0 -column 1  -sticky w
               grid $ablock.selectobj.sso      -in [$ablock.selectobj getframe]  -row 1 -column 1  -sticky w
               grid $ablock.selectobj.park     -in [$ablock.selectobj getframe]  -row 2 -column 1  -sticky w

            grid $bblock.grab     -in $bblock -sticky nw

               grid $bblock.grab.name_new_raJ2000  -in [$bblock.grab getframe]  -row 0 -column 0  -sticky nws
               grid $bblock.grab.new_raJ2000       -in [$bblock.grab getframe]  -row 0 -column 1  -sticky nws
               grid $bblock.grab.name_new_decJ2000 -in [$bblock.grab getframe]  -row 0 -column 2  -sticky nws
               grid $bblock.grab.new_decJ2000      -in [$bblock.grab getframe]  -row 0 -column 3  -sticky nws
               grid $bblock.grab.goto              -in [$bblock.grab getframe]  -row 0 -column 4  -sticky nse
               grid $bblock.grab.sync              -in [$bblock.grab getframe]  -row 0 -column 5  -sticky nse

            grid $bblock.mount    -in $bblock -sticky nw

               grid $bblock.mount.status          -in [$bblock.mount getframe]  -row 0 -column 0  -sticky nws
               grid $bblock.mount.stat            -in [$bblock.mount getframe]  -row 0 -column 1  -sticky nws
               grid $bblock.mount.distance        -in [$bblock.mount getframe]  -row 0 -column 2  -sticky nws
               grid $bblock.mount.dist            -in [$bblock.mount getframe]  -row 0 -column 3  -sticky nws

               grid $bblock.mount.name_raJ2000    -in [$bblock.mount getframe]  -row 1 -column 0  -sticky nws
               grid $bblock.mount.raJ2000         -in [$bblock.mount getframe]  -row 1 -column 1  -sticky nws
               grid $bblock.mount.name_decJ2000   -in [$bblock.mount getframe]  -row 1 -column 2  -sticky nws
               grid $bblock.mount.decJ2000        -in [$bblock.mount getframe]  -row 1 -column 3  -sticky nws
               grid $bblock.mount.refresh         -in [$bblock.mount getframe]  -row 1 -column 4  -sticky nse

            grid $cblock.calib -in $cblock -sticky nw

               grid $cblock.calib.nraJ2000   -in [$cblock.calib getframe]  -row 0 -column 0  -sticky nws
               grid $cblock.calib.eraJ2000   -in [$cblock.calib getframe]  -row 0 -column 1  -sticky nws
               grid $cblock.calib.ndecJ2000  -in [$cblock.calib getframe]  -row 0 -column 2  -sticky nws
               grid $cblock.calib.edecJ2000  -in [$cblock.calib getframe]  -row 0 -column 3  -sticky nws
               grid $cblock.calib.calib      -in [$cblock.calib getframe]  -row 0 -column 4  -sticky nse
               grid $cblock.calib.sync       -in [$cblock.calib getframe]  -row 0 -column 5  -sticky nse

            grid $cblock.precis -in $cblock -sticky nw
               grid $cblock.precis.ndraJ2000  -in [$cblock.precis getframe]  -row 0 -column 0  -sticky news
               grid $cblock.precis.edraJ2000  -in [$cblock.precis getframe]  -row 0 -column 1  -sticky news
               grid $cblock.precis.nddecJ2000 -in [$cblock.precis getframe]  -row 0 -column 2  -sticky news
               grid $cblock.precis.eddecJ2000 -in [$cblock.precis getframe]  -row 0 -column 3  -sticky news
               grid $cblock.precis.ndistJ2000 -in [$cblock.precis getframe]  -row 0 -column 4  -sticky news
               grid $cblock.precis.edistJ2000 -in [$cblock.precis getframe]  -row 0 -column 5  -sticky news
               grid $cblock.precis.move       -in [$cblock.precis getframe]  -row 0 -column 6  -sticky news

            grid $dblock.tracking -in $dblock -sticky nw

               grid $dblock.tracking.check -in [$dblock.tracking getframe]  -row 0 -column 0  -sticky news
               grid $dblock.tracking.value -in [$dblock.tracking getframe]  -row 1 -column 0  -sticky news
               grid $dblock.tracking.ton   -in [$dblock.tracking getframe]  -row 2 -column 0  -sticky news
               grid $dblock.tracking.toff  -in [$dblock.tracking getframe]  -row 3 -column 0  -sticky news

# Onglet : Methodes

           set frmtable [frame $f_meth.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white ]

              TitleFrame $frmtable.selection -borderwidth 2 -text "$caption(eye,selection)"
                 set selection [frame $frmtable.selection.path]
                    radiobutton $selection.calibwcs -highlightthickness 0 -padx 0 -pady 0 -state normal \
                       -text $caption(eye,calibwcs) -value "CALIBWCS" \
                       -variable ::eye::widget(methode) \
                       -command "::eye::chg_calib_method $frmtable"
                    radiobutton $selection.calibwcs_new -highlightthickness 0 -padx 0 -pady 0 -state normal \
                       -text "calibwcs_new" -value "CALIBWCS_NEW" \
                       -variable ::eye::widget(methode) \
                       -command "::eye::chg_calib_method $frmtable"
                    radiobutton $selection.stat -highlightthickness 0 -padx 0 -pady 0 -state disabled \
                       -text $caption(eye,stat) -value "STAT" \
                       -variable ::eye::widget(methode) \
                       -command "::eye::chg_calib_method $frmtable"
                    radiobutton $selection.bogumil -highlightthickness 0 -padx 0 -pady 0 -state disabled \
                       -text $caption(eye,bogumil) -value "BOGUMIL" \
                       -variable ::eye::widget(methode) \
                       -command "::eye::chg_calib_method $frmtable"


              TitleFrame $frmtable.catalogue -borderwidth 2 -text "$caption(eye,catalogue)"
                 LabelEntry $frmtable.catalogue.ra -label "RA" \
                    -labeljustify left -labelwidth 20 -justify left \
                    -textvariable ::eye::widget(methode,ra)
                 LabelEntry $frmtable.catalogue.dec -label "DEC" \
                    -labeljustify left -labelwidth 20 -justify left \
                    -textvariable ::eye::widget(methode,dec)
                 LabelEntry $frmtable.catalogue.pixsize1 -label "PIXSIZE1" \
                    -labeljustify left -labelwidth 20 -justify left \
                    -textvariable ::eye::widget(methode,pixsize1)
                 LabelEntry $frmtable.catalogue.pixsize2 -label "PIXSIZE2" \
                    -labeljustify left -labelwidth 20 -justify left \
                    -textvariable ::eye::widget(methode,pixsize2)
                 LabelEntry $frmtable.catalogue.foclen -label "FOCLEN" \
                    -labeljustify left -labelwidth 20 -justify left \
                    -textvariable ::eye::widget(methode,foclen)
                 Button $frmtable.catalogue.test  -text "Test" -command "::eye::test_calibration"



              # S affiche selon le choix de la methode : CalibWCS
              TitleFrame $frmtable.calibwcs -borderwidth 2 -text "Calibwcs"
                 label $frmtable.calibwcs.lab -text "Ref. cata: " -width 12 -anchor e
                 ComboBox $frmtable.calibwcs.combo -height 3 -width 10 -relief sunken -borderwidth 1 -editable 0 \
                      -textvariable ::eye::widget(methode,calibwcs,catalog) \
                      -values [list TYCHO2 USNOA2]
                 LabelEntry $frmtable.calibwcs.dirtyc -label "TYCHO faÃ§on USNO :" \
                    -labeljustify left -labelwidth 20 -width 50 -justify left \
                    -textvariable ::eye::widget(methode,calibwcs,tycho_facon_usno)
                 LabelEntry $frmtable.calibwcs.maglimit -label "Mag Limit :" \
                    -labeljustify left -labelwidth 12 -width 4 -justify left \
                    -textvariable ::eye::widget(methode,calibwcs,maglimit)

              # S affiche selon le choix de la methode : Calibwcs_new
              TitleFrame $frmtable.calibwcs_new -borderwidth 2 -text "Calibwcs_new"
                 label $frmtable.calibwcs_new.lab -text "Ref. cata: " -width 12 -anchor e
                 ComboBox $frmtable.calibwcs_new.combo -height 3 -relief sunken -borderwidth 1 -editable 0 \
                      -textvariable ::eye::widget(methode,calibwcs_new,catalog) \
                      -values [list TYCHO2 USNOA2 UCAC2 UCAC3 UCAC4 PPMX PPMXL NOMAD1 2MASS]
                 LabelEntry $frmtable.calibwcs_new.delta -label "Delta :" \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,calibwcs_new,delta)
                 LabelEntry $frmtable.calibwcs_new.nmax -label "Nmax :" \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,calibwcs_new,nmax)
                 LabelEntry $frmtable.calibwcs_new.fluxcrit -label "Flux Crit. :" \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,calibwcs_new,fluxcrit)


              # S affiche selon le choix de la methode : Statistique
              TitleFrame $frmtable.statistique -borderwidth 2 -text "$caption(eye,stat)"
                 LabelEntry $frmtable.statistique.kappa -label $caption(eye,kappa) \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,stat,kappa)
                 LabelEntry $frmtable.statistique.delta -label $caption(eye,delta) \
                    -labeljustify left -labelwidth 8 -width 8 -justify right \
                    -textvariable ::eye::widget(methode,delta)
                 LabelEntry $frmtable.statistique.epsilon -label $caption(eye,epsilon) \
                    -labeljustify left -labelwidth 8 -width 8 -justify right \
                    -textvariable ::eye::widget(methode,epsilon)



              # S affiche selon le choix de la methode : Bogumil
              TitleFrame $frmtable.bogumil -borderwidth 2 -text "$caption(eye,bogumil)"
                 LabelEntry $frmtable.bogumil.threshin -label $caption(eye,threshin) \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,bogumil,threshin)
                 LabelEntry $frmtable.bogumil.fwhm -label $caption(eye,fwhm) \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,bogumil,fwhm)
                 LabelEntry $frmtable.bogumil.radius -label $caption(eye,radius) \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,bogumil,radius)
                 LabelEntry $frmtable.bogumil.threshold -label $caption(eye,threshold) \
                    -labeljustify left -labelwidth 8 -width 4 -justify right \
                    -textvariable ::eye::widget(methode,bogumil,threshold)
                 LabelEntry $frmtable.bogumil.delta -label $caption(eye,delta) \
                    -labeljustify left -labelwidth 8 -width 8 -justify right \
                    -textvariable ::eye::widget(methode,delta)
                 LabelEntry $frmtable.bogumil.epsilon -label $caption(eye,epsilon) \
                    -labeljustify left -labelwidth 8 -width 8 -justify right \
                    -textvariable ::eye::widget(methode,epsilon)

                 checkbutton $frmtable.bogumil.check_orient -highlightthickness 0  \
                             -variable ::eye::widget(methode,bogumil,check_orient) \
                             -text "Recherche de l'orientation" -justify left
                 LabelEntry $frmtable.bogumil.pas_orient -label "Avec un pas de " \
                    -labeljustify left -labelwidth 15 -width 8 -justify right \
                    -textvariable ::eye::widget(methode,bogumil,pas_orient)



              TitleFrame $frmtable.nbstars -borderwidth 2 -text "$caption(eye,nbstars)"

                 label $frmtable.nbstars.name_new_imageStarNb     -text "l'image"
                 label $frmtable.nbstars.name_new_catalogueStarNb -text "le catalogue"
                 label $frmtable.nbstars.name_new_matchedStarNb   -text "appareillees"

                 entry $frmtable.nbstars.new_imageStarNb     -width 8 -justify center -textvariable ::eye::widget(methode,imageStarNb)     -state disabled
                 entry $frmtable.nbstars.new_catalogueStarNb -width 8 -justify center -textvariable ::eye::widget(methode,catalogueStarNb) -state disabled
                 entry $frmtable.nbstars.new_matchedStarNb   -width 8 -justify center -textvariable ::eye::widget(methode,matchedStarNb)   -state disabled





           pack $frmtable -in $f_meth -expand yes -fill both
           #grid $frmtable -in $f_meth -sticky news

              grid $frmtable.selection -in $frmtable -sticky ewns
                 grid $selection -in [$frmtable.selection getframe] -sticky ewns
                    grid $selection.calibwcs -in $selection -row 0 -column 0  -sticky ewns
                    grid $selection.calibwcs_new -in $selection -row 0 -column 1  -sticky ewns
                    grid $selection.stat     -in $selection -row 0 -column 2  -sticky ewns
                    grid $selection.bogumil  -in $selection -row 0 -column 3  -sticky ewns

              grid $frmtable.catalogue -in $frmtable -sticky ewns
                 grid $frmtable.catalogue.ra       -in [$frmtable.catalogue getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.catalogue.dec      -in [$frmtable.catalogue getframe] -row 1 -column 0 -sticky ewns
                 grid $frmtable.catalogue.pixsize1 -in [$frmtable.catalogue getframe] -row 2 -column 0 -sticky ewns
                 grid $frmtable.catalogue.pixsize2 -in [$frmtable.catalogue getframe] -row 3 -column 0 -sticky ewns
                 grid $frmtable.catalogue.foclen   -in [$frmtable.catalogue getframe] -row 4 -column 0 -sticky ewns
                 grid $frmtable.catalogue.test     -in [$frmtable.catalogue getframe] -row 5 -column 0 -sticky ewns

              grid $frmtable.calibwcs -in $frmtable -sticky wns
                 grid $frmtable.calibwcs.lab $frmtable.calibwcs.combo  -in [$frmtable.calibwcs getframe] -sticky wns
                 grid $frmtable.calibwcs.dirtyc -in [$frmtable.calibwcs getframe]   -columnspan 2 -sticky wns
                 grid $frmtable.calibwcs.maglimit -in [$frmtable.calibwcs getframe] -columnspan 2 -sticky wns

              grid $frmtable.calibwcs_new -in $frmtable -sticky ewns
                 grid $frmtable.calibwcs_new.lab $frmtable.calibwcs_new.combo -in [$frmtable.calibwcs_new getframe] -sticky ewns
                 grid $frmtable.calibwcs_new.delta $frmtable.calibwcs_new.nmax  $frmtable.calibwcs_new.fluxcrit   -in [$frmtable.calibwcs_new getframe] -sticky ewns

              grid $frmtable.statistique -in $frmtable -sticky ewns
                 grid $frmtable.statistique.kappa    -in [$frmtable.statistique getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.statistique.delta    -in [$frmtable.statistique getframe] -row 1 -column 0 -sticky ewns
                 grid $frmtable.statistique.epsilon  -in [$frmtable.statistique getframe] -row 1 -column 1 -sticky ewns

               grid $frmtable.bogumil -in $frmtable -sticky ewns
                 grid $frmtable.bogumil.threshin     -in [$frmtable.bogumil getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.bogumil.fwhm         -in [$frmtable.bogumil getframe] -row 0 -column 1 -sticky ewns
                 grid $frmtable.bogumil.radius       -in [$frmtable.bogumil getframe] -row 1 -column 0 -sticky ewns
                 grid $frmtable.bogumil.threshold    -in [$frmtable.bogumil getframe] -row 1 -column 1 -sticky ewns
                 grid $frmtable.bogumil.delta        -in [$frmtable.bogumil getframe] -row 2 -column 0 -sticky ewns
                 grid $frmtable.bogumil.epsilon      -in [$frmtable.bogumil getframe] -row 2 -column 1 -sticky ewns
                 grid $frmtable.bogumil.check_orient -in [$frmtable.bogumil getframe] -row 3 -column 0 -sticky w
                 grid $frmtable.bogumil.pas_orient   -in [$frmtable.bogumil getframe] -row 4 -column 0 -columnspan 2 -sticky w


              grid $frmtable.nbstars -in $frmtable -sticky ewns
                 grid $frmtable.nbstars.name_new_imageStarNb      -in [$frmtable.nbstars getframe]  -row 0 -column 0  -sticky w
                 grid $frmtable.nbstars.name_new_catalogueStarNb  -in [$frmtable.nbstars getframe]  -row 0 -column 2  -sticky e
                 grid $frmtable.nbstars.name_new_matchedStarNb    -in [$frmtable.nbstars getframe]  -row 0 -column 4  -sticky e
                 grid $frmtable.nbstars.new_imageStarNb           -in [$frmtable.nbstars getframe]  -row 0 -column 1  -sticky w
                 grid $frmtable.nbstars.new_catalogueStarNb       -in [$frmtable.nbstars getframe]  -row 0 -column 3  -sticky e
                 grid $frmtable.nbstars.new_matchedStarNb         -in [$frmtable.nbstars getframe]  -row 0 -column 5  -sticky e

          ::eye::chg_calib_method $frmtable


# Onglet : Mots Cles

           set frmtable [frame $f_keys.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]

              label $frmtable.name_col       -text "Mots-Cles de l'image d'origine"
              label $frmtable.name_ra        -text "RA"
              label $frmtable.name_dec       -text "DEC"
              label $frmtable.name_equinox   -text "EQUINOX"
              label $frmtable.name_pixsize1  -text "PIXSIZE1"
              label $frmtable.name_pixsize2  -text "PIXSIZE2"
              label $frmtable.name_crpix1    -text "CRPIX1"
              label $frmtable.name_crpix2    -text "CRPIX2"
              label $frmtable.name_crval1    -text "CRVAL1 (J2000)"
              label $frmtable.name_crval2    -text "CRVAL2 (J2000)"
              label $frmtable.name_foclen    -text "FOCLEN"
              label $frmtable.name_crota2    -text "CROTA2"
              label $frmtable.name_cdelt1    -text "CDELT1"
              label $frmtable.name_cdelt2    -text "CDELT2"

              entry $frmtable.ra        -textvariable ::eye::widget(keys,img,ra) -state disabled
              entry $frmtable.dec       -textvariable ::eye::widget(keys,img,dec) -state disabled
              entry $frmtable.equinox   -textvariable ::eye::widget(keys,img,equinox) -state disabled
              entry $frmtable.pixsize1  -textvariable ::eye::widget(keys,img,pixsize1) -state disabled
              entry $frmtable.pixsize2  -textvariable ::eye::widget(keys,img,pixsize2) -state disabled
              entry $frmtable.crpix1    -textvariable ::eye::widget(keys,img,crpix1) -state disabled
              entry $frmtable.crpix2    -textvariable ::eye::widget(keys,img,crpix2) -state disabled
              entry $frmtable.crval1    -textvariable ::eye::widget(keys,img,crval1) -state disabled
              entry $frmtable.crval2    -textvariable ::eye::widget(keys,img,crval2) -state disabled
              entry $frmtable.foclen    -textvariable ::eye::widget(keys,img,foclen) -state disabled
              entry $frmtable.crota2    -textvariable ::eye::widget(keys,img,crota2) -state disabled
              entry $frmtable.cdelt1    -textvariable ::eye::widget(keys,img,cdelt1) -state disabled
              entry $frmtable.cdelt2    -textvariable ::eye::widget(keys,img,cdelt2) -state disabled

              label $frmtable.name_new_col       -text "Derniere calibration"
              label $frmtable.name_new_ra        -text "RA"
              label $frmtable.name_new_dec       -text "DEC"
              label $frmtable.name_new_equinox   -text "EQUINOX"
              label $frmtable.name_new_pixsize1  -text "PIXSIZE1"
              label $frmtable.name_new_pixsize2  -text "PIXSIZE2"
              label $frmtable.name_new_crpix1    -text "CRPIX1"
              label $frmtable.name_new_crpix2    -text "CRPIX2"
              label $frmtable.name_new_crval1    -text "CRVAL1 (J2000)"
              label $frmtable.name_new_crval2    -text "CRVAL2 (J2000)"
              label $frmtable.name_new_foclen    -text "FOCLEN"
              label $frmtable.name_new_crota2    -text "CROTA2"
              label $frmtable.name_new_cdelt1    -text "CDELT1"
              label $frmtable.name_new_cdelt2    -text "CDELT2"

              entry $frmtable.new_ra          -textvariable ::eye::widget(keys,new,ra)
              entry $frmtable.new_dec         -textvariable ::eye::widget(keys,new,dec)
              entry $frmtable.new_equinox     -textvariable ::eye::widget(keys,new,equinox)
              entry $frmtable.new_pixsize1    -textvariable ::eye::widget(keys,new,pixsize1)
              entry $frmtable.new_pixsize2    -textvariable ::eye::widget(keys,new,pixsize2)
              entry $frmtable.new_crpix1      -textvariable ::eye::widget(keys,new,crpix1)
              entry $frmtable.new_crpix2      -textvariable ::eye::widget(keys,new,crpix2)
              entry $frmtable.new_crval1      -textvariable ::eye::widget(keys,new,crval1)
              entry $frmtable.new_crval2      -textvariable ::eye::widget(keys,new,crval2)
              entry $frmtable.new_foclen      -textvariable ::eye::widget(keys,new,foclen)
              entry $frmtable.new_crota2      -textvariable ::eye::widget(keys,new,crota2)
              entry $frmtable.new_cdelt1      -textvariable ::eye::widget(keys,new,cdelt1)
              entry $frmtable.new_cdelt2      -textvariable ::eye::widget(keys,new,cdelt2)

           pack $frmtable -in $f_keys -expand yes -fill both

              #grid $frmtable.name_col      -in $frmtable -row 0  -column 0 -columnspan 2 -sticky ewns
              grid $frmtable.name_ra       -in $frmtable -row 0  -column 0 -sticky ewns
              grid $frmtable.name_dec      -in $frmtable -row 1  -column 0 -sticky ewns
              grid $frmtable.name_equinox  -in $frmtable -row 2  -column 0 -sticky ewns
              grid $frmtable.name_pixsize1 -in $frmtable -row 3  -column 0 -sticky ewns
              grid $frmtable.name_pixsize2 -in $frmtable -row 4  -column 0 -sticky ewns

              grid $frmtable.ra            -in $frmtable -row 0  -column 1 -sticky ewns
              grid $frmtable.dec           -in $frmtable -row 1  -column 1 -sticky ewns
              grid $frmtable.equinox       -in $frmtable -row 2  -column 1 -sticky ewns
              grid $frmtable.pixsize1      -in $frmtable -row 3  -column 1 -sticky ewns
              grid $frmtable.pixsize2      -in $frmtable -row 4  -column 1 -sticky ewns

              grid $frmtable.name_crpix1   -in $frmtable -row 0  -column 2 -sticky ewns
              grid $frmtable.name_crpix2   -in $frmtable -row 1  -column 2 -sticky ewns
              grid $frmtable.name_crval1   -in $frmtable -row 2  -column 2 -sticky ewns
              grid $frmtable.name_crval2   -in $frmtable -row 3  -column 2 -sticky ewns
              grid $frmtable.name_foclen   -in $frmtable -row 4  -column 2 -sticky ewns

              grid $frmtable.crpix1        -in $frmtable -row 0  -column 3 -sticky ewns
              grid $frmtable.crpix2        -in $frmtable -row 1  -column 3 -sticky ewns
              grid $frmtable.crval1        -in $frmtable -row 2  -column 3 -sticky ewns
              grid $frmtable.crval2        -in $frmtable -row 3  -column 3 -sticky ewns
              grid $frmtable.foclen        -in $frmtable -row 4  -column 3 -sticky ewns

              grid $frmtable.name_crota2   -in $frmtable -row 0  -column 4 -sticky ewns
              grid $frmtable.name_cdelt1   -in $frmtable -row 1  -column 4 -sticky ewns
              grid $frmtable.name_cdelt2   -in $frmtable -row 2  -column 4 -sticky ewns

              grid $frmtable.crota2        -in $frmtable -row 0  -column 5 -sticky ewns
              grid $frmtable.cdelt1        -in $frmtable -row 1  -column 5 -sticky ewns
              grid $frmtable.cdelt2        -in $frmtable -row 2  -column 5 -sticky ewns

              #grid $frmtable.name_new_col      -in $frmtable -row 0  -column 2  -columnspan 2 -sticky ewns
              #grid $frmtable.name_new_ra       -in $frmtable -row 1  -column 2  -sticky ewns
              #grid $frmtable.name_new_dec      -in $frmtable -row 2  -column 2  -sticky ewns
              #grid $frmtable.name_new_equinox  -in $frmtable -row 3  -column 2  -sticky ewns
              #grid $frmtable.name_new_pixsize1 -in $frmtable -row 4  -column 2  -sticky ewns
              #grid $frmtable.name_new_pixsize2 -in $frmtable -row 5  -column 2  -sticky ewns
              #grid $frmtable.name_new_crpix1   -in $frmtable -row 6  -column 2  -sticky ewns
              #grid $frmtable.name_new_crpix2   -in $frmtable -row 7  -column 2  -sticky ewns
              #grid $frmtable.name_new_crval1   -in $frmtable -row 8  -column 2  -sticky ewns
              #grid $frmtable.name_new_crval2   -in $frmtable -row 9  -column 2  -sticky ewns
              #grid $frmtable.name_new_foclen   -in $frmtable -row 10 -column 2  -sticky ewns
              #grid $frmtable.name_new_crota2   -in $frmtable -row 11 -column 2  -sticky ewns
              #grid $frmtable.name_new_cdelt1   -in $frmtable -row 12 -column 2  -sticky ewns
              #grid $frmtable.name_new_cdelt2   -in $frmtable -row 13 -column 2  -sticky ewns

              #grid $frmtable.new_ra       -in $frmtable -row 1  -column 3  -sticky ewns
              #grid $frmtable.new_dec      -in $frmtable -row 2  -column 3  -sticky ewns
              #grid $frmtable.new_equinox  -in $frmtable -row 3  -column 3  -sticky ewns
              #grid $frmtable.new_pixsize1 -in $frmtable -row 4  -column 3  -sticky ewns
              #grid $frmtable.new_pixsize2 -in $frmtable -row 5  -column 3  -sticky ewns
              #grid $frmtable.new_crpix1   -in $frmtable -row 6  -column 3  -sticky ewns
              #grid $frmtable.new_crpix2   -in $frmtable -row 7  -column 3  -sticky ewns
              #grid $frmtable.new_crval1   -in $frmtable -row 8  -column 3  -sticky ewns
              #grid $frmtable.new_crval2   -in $frmtable -row 9  -column 3  -sticky ewns
              #grid $frmtable.new_foclen   -in $frmtable -row 10 -column 3  -sticky ewns
              #grid $frmtable.new_crota2   -in $frmtable -row 11 -column 3  -sticky ewns
              #grid $frmtable.new_cdelt1   -in $frmtable -row 12 -column 3  -sticky ewns
              #grid $frmtable.new_cdelt2   -in $frmtable -row 13 -column 3  -sticky ewns


# Onglet : Pointeurs

           set frmtable [frame $f_point.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]

              TitleFrame $frmtable.telescope -borderwidth 2 -text "Selection du reticule du foyer du telescope"
                 Button $frmtable.telescope.select -text "Select" -borderwidth 4 \
                          -command "::eye::selection_reticule_foyer_telescope $frmtable"
                 LabelEntry $frmtable.telescope.taille -label " Taille du champs (arcmin) : " \
                   -labeljustify left -labelwidth 25 -width 10 -justify center \
                   -textvariable ::eye::widget(telescope,fov,diam)

           pack $frmtable -in $f_point -expand yes -fill both
           #grid $frmtable -in $f_point -row 0 -column 0 -sticky ewns
              grid $frmtable.telescope -in $frmtable -row 0 -column 0 -sticky ewns
                 grid $frmtable.telescope.select -in [$frmtable.telescope getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.telescope.taille -in [$frmtable.telescope getframe] -row 0 -column 1 -sticky ewns

# Onglet : Guidage

           set frmtable [frame $f_guid.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
           pack $frmtable -in $f_guid -expand yes -fill both



# Onglet : Camera

           set frmtable [frame $f_cam.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]

              TitleFrame $frmtable.test -borderwidth 2 -text "Chargement d'une image de test"

                 Button     $frmtable.test.polaris -text "Polaris"  -command "::eye::charge_une_image_test Polaris"
                 Button     $frmtable.test.mizar   -text "Mizar"    -command "::eye::charge_une_image_test Mizar"
                 Button     $frmtable.test.alkaid  -text "Alkaid"   -command "::eye::charge_une_image_test Alkaid"
                 Button     $frmtable.test.kausaustralis  -text "KausAustralis"   -command "::eye::charge_une_image_test KausAustralis"

              TitleFrame $frmtable.testperso -borderwidth 2 -text "Image de test personnalisee"

                 Button     $frmtable.testperso.charge -text "Charger"  -command "::eye::charge_une_image_test"
                 Button     $frmtable.testperso.dialog -text "..."  -command ""
                 LabelEntry $frmtable.testperso.chemin -label " Chemin : " \
                   -labeljustify right -labelwidth 10 -width 60 -justify left \
                   -textvariable ::eye::widget(camera,test,uneimage)

              TitleFrame $frmtable.cam -borderwidth 2 -text "Utilisation d'une camera"

                 Button     $frmtable.cam.init -text "Init"  -command "::eye::camera_init"
                 Button     $frmtable.cam.acq  -text "Acquisition"  -command "::eye::acq_une_image"
                 LabelEntry $frmtable.cam.integ -label "  Somme d'images :" \
                   -labeljustify center -labelwidth 20 -width 5 -justify center \
                   -textvariable ::eye::widget(camera,integ,sum)
                 Button     $frmtable.cam.cont -text "Acq. Continue"  -command "::eye::acq_continue"
                 Button     $frmtable.cam.stop -text "Stop"  -command "::eye::acq_stop"

              TitleFrame $frmtable.simu -borderwidth 2 -text "Simulation"

                 Button     $frmtable.simu.start -text "Start" -command "::eye::camera_simulation"
                 label  $frmtable.simu.name_cata  -text "Catalogue"
                 entry  $frmtable.simu.cata       -textvariable ::eye::widget(simu,catalog) -width 40 -justify center -state disabled
                 label  $frmtable.simu.name_dra   -text "Offset RA (min)"
                 entry  $frmtable.simu.dra        -textvariable ::eye::widget(simu,dra) -width 5 -justify center
                 label  $frmtable.simu.name_ddec  -text "Offset DEC (min)"
                 entry  $frmtable.simu.ddec       -textvariable ::eye::widget(simu,ddec) -width 5 -justify center


           pack $frmtable -in $f_cam -expand yes -fill both
           #grid $frmtable -in $f_cam -row 0 -column 0 -sticky ewns

              grid $frmtable.test -in $frmtable -sticky ewns
                 grid $frmtable.test.polaris -in [$frmtable.test getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.test.mizar   -in [$frmtable.test getframe] -row 0 -column 1 -sticky ewns
                 grid $frmtable.test.alkaid  -in [$frmtable.test getframe] -row 0 -column 2 -sticky ewns
                 grid $frmtable.test.kausaustralis  -in [$frmtable.test getframe] -row 0 -column 3 -sticky ewns

              grid $frmtable.testperso -in $frmtable -sticky ewns
                 grid $frmtable.testperso.charge  -in [$frmtable.testperso getframe] -row 0 -column 0 -sticky ewns
                 grid $frmtable.testperso.dialog  -in [$frmtable.testperso getframe] -row 0 -column 1 -sticky ewns
                 grid $frmtable.testperso.chemin  -in [$frmtable.testperso getframe] -row 0 -column 2 -sticky ewns

              grid $frmtable.cam -in $frmtable -sticky ewns
                 grid $frmtable.cam.init  -in [$frmtable.cam getframe] -row 0 -column 0 -sticky e
                 grid $frmtable.cam.acq   -in [$frmtable.cam getframe] -row 0 -column 1 -sticky e
                 grid $frmtable.cam.integ -in [$frmtable.cam getframe] -row 0 -column 2 -sticky w
                 grid $frmtable.cam.cont  -in [$frmtable.cam getframe] -row 0 -column 3 -sticky w
                 grid $frmtable.cam.stop  -in [$frmtable.cam getframe] -row 0 -column 4 -sticky w

              grid $frmtable.simu -in $frmtable -sticky ewns
                 grid $frmtable.simu.start -in [$frmtable.simu getframe] -sticky w
                 grid $frmtable.simu.name_cata $frmtable.simu.cata -in [$frmtable.simu getframe] -sticky w
                 grid $frmtable.simu.name_dra  $frmtable.simu.dra  -in [$frmtable.simu getframe] -sticky w
                 grid $frmtable.simu.name_ddec $frmtable.simu.ddec -in [$frmtable.simu getframe] -sticky w


# Onglet : Outils

           set frmtable [frame $f_tools.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]


              TitleFrame $frmtable.tools -borderwidth 2 -text "Outils"

                 Button $frmtable.tools.ressource  -text "Ressource"                 -command "::eye::ressource"
                 Button $frmtable.tools.kml        -text "$caption(eye,convertKml)"  -command "::eye::convertKml"
                 Button $frmtable.tools.deleteStar -text "$caption(eye,deleteStar)"  -command "::eye::deleteStar"

           pack $frmtable -in $f_tools -expand yes -fill both
           #grid $frmtable -in $f_tools -sticky news

              grid $frmtable.tools    -in $frmtable  -columnspan 1 -rowspan 1 -sticky ewns

                 grid $frmtable.tools.ressource    -in [$frmtable.tools getframe]  -row 0 -column 0  -sticky we
                 grid $frmtable.tools.deleteStar   -in [$frmtable.tools getframe]  -row 0 -column 1  -sticky we
                 grid $frmtable.tools.kml          -in [$frmtable.tools getframe]  -row 0 -column 2  -sticky we


# Onglet : FOV

      set frmtable [frame $f_fov.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
      pack $frmtable -in $f_fov -expand yes -fill both

         set ablock [ frame $frmtable.a ]

            TitleFrame $ablock.simu -borderwidth 2 -text "Simu"

               set ::eye::widget(fov,methode) simulimage
               #label $ablock.fov.lab -text "Methode " -width 12 -anchor e
               #ComboBox $ablock.fov.combo -height 3 -width 10 -relief sunken -borderwidth 1 -editable 0 \
               #     -textvariable ::eye::widget(fov,methode) \
               #     -values [list simulimage libcatalog]

               Button $ablock.simu.visu  -text "View" -command "::eye::fov_view"
               Button $ablock.simu.close  -text "Close" -command "::eye::fov_close"

               checkbutton $ablock.simu.xflip -highlightthickness 0  \
                           -variable ::eye::widget(fov,xflip) \
                           -text "Flip X" -justify left -command "::eye::fov_simulimage"
               checkbutton $ablock.simu.yflip -highlightthickness 0  \
                           -variable ::eye::widget(fov,yflip) \
                           -text "Flip Y" -justify left -command "::eye::fov_simulimage"

         set bblock [ frame $frmtable.b ]

            TitleFrame $bblock.scale -borderwidth 2 -text "QualitÃ©"
               scale $bblock.scale.nbstars -from 1 -to 100 -length 300 -variable ::eye::widget(fov,nbstars) \
                  -label "Nb Stars" -orient horizontal -state normal -showvalue 0

               scale $bblock.scale.orient -from 0 -to 360 -length 300 -variable ::eye::widget(fov,orient) \
                  -label "Orientation" -orient horizontal -state normal

               bind $bblock.scale.nbstars <ButtonRelease> "::eye::fov_simulimage"
               bind $bblock.scale.orient  <ButtonRelease> "::eye::fov_simulimage"

         set cblock [ frame $frmtable.c ]

            TitleFrame $cblock.tools -borderwidth 2 -text "Centrage"

            set ::eye::widget(fov,tools) $cblock.tools

               Button $cblock.tools.cent  -text "Objet"      -command "::eye::center_object"
               Button $cblock.tools.reset -text "Reset"      -command "::eye::fov_reset"
               Button $cblock.tools.meca  -text "Mecanique"  -command "::eye::get_pole meca"
               Button $cblock.tools.cele  -text "Celeste"    -command "::eye::get_pole celeste"

         set dblock [ frame $frmtable.d ]

            TitleFrame $dblock.config -borderwidth 2 -text "Config"

               label  $dblock.config.lbox -text "Taille boite de mesure"              -width 32 -justify left
               entry  $dblock.config.vbox -textvariable ::eye::widget(fov,boxradius)  -width 4  -justify center
               label  $dblock.config.lnbr -text "Nb etoile de reference"              -width 32 -justify left
               entry  $dblock.config.vnbr -textvariable ::eye::widget(fov,nbref)      -width 4  -justify center
               label  $dblock.config.lrdf -text "Rayon d acceptance en pixel"         -width 32 -justify left
               entry  $dblock.config.vrdf -textvariable ::eye::widget(fov,rdiff)      -width 4  -justify center
               label  $dblock.config.ldrf -text "Drift meca facteur sideral"          -width 32 -justify left
               entry  $dblock.config.vdrf -textvariable ::eye::widget(fov,driftspeed) -width 4  -justify center

         set eblock [ frame $frmtable.e ]

            TitleFrame $eblock.telescope -borderwidth 2 -text "Reticule du telescope"

               Button $eblock.telescope.select -text "Select" -borderwidth 4  \
                        -command "::eye::selection_reticule_foyer_telescope $eblock"

               LabelEntry $eblock.telescope.taille -label "Taille du champs (arcmin) : " \
                 -labeljustify left -labelwidth 25 -width 13 -justify center \
                 -textvariable ::eye::widget(telescope,fov,diam)

               Button $eblock.telescope.setsize -text "Set" -borderwidth 4  \
                        -command "::eye::reticule_set_pos $eblock"
                 
               LabelEntry $eblock.telescope.pos -label "Positions pixel (x y): " \
                 -labeljustify left -labelwidth 25 -width 13 -justify center \
                 -textvariable ::eye::widget(telescope,fov,pos) 

               Button $eblock.telescope.setpos -text "Set" -borderwidth 4  \
                        -command "::eye::reticule_set_size $eblock"
                 

         set fblock [ frame $frmtable.f ]

            TitleFrame $fblock.event -borderwidth 2 -text "Gestionnaire d'evenement"

               set ::eye::widget(event) $fblock.event

               Button $fblock.event.start -text "Start" -command "::eye::start_boucle"
               Button $fblock.event.stop  -text "Stop"  -command "::eye::stop_boucle"

               checkbutton $fblock.event.check_uneimg      -highlightthickness 0  -variable ::eye::widget(event,check,uneimg)
               checkbutton $fblock.event.check_calibration -highlightthickness 0  -variable ::eye::widget(event,check,calibration)
               checkbutton $fblock.event.check_objet       -highlightthickness 0  -variable ::eye::widget(event,check,objet)
               checkbutton $fblock.event.check_telescope   -highlightthickness 0  -variable ::eye::widget(event,check,telescope)

               Button $fblock.event.uneimg      -text "Une image"                 -command "::eye::evt_uneimg"
               Button $fblock.event.calibration -text "$caption(eye,calibration)" -command "::eye::evt_calibration"
               Button $fblock.event.objet       -text "Objet a pointer"           -command "::eye::evt_objet"
               Button $fblock.event.telescope   -text "Mouvement telescope"       -command "" -state disabled

               label  $fblock.event.cursor_uneimg      -width 15 -textvariable ::eye::widget(event,workinglabel,uneimg)      -background green  -relief groove
               label  $fblock.event.cursor_calibration -width 15 -textvariable ::eye::widget(event,workinglabel,calibration) -background yellow -relief groove
               label  $fblock.event.cursor_objet       -width 15 -textvariable ::eye::widget(event,workinglabel,objet)       -background red    -relief groove
               label  $fblock.event.cursor_telescope   -width 15 -textvariable ::eye::widget(event,workinglabel,telescope)   -background grey   -relief groove

               image create photo .igreen  -format png -file [ file join $::eye::dir_img green_16.png  ]
               image create photo .ired    -format png -file [ file join $::eye::dir_img red_16.png    ]
               image create photo .iorange -format png -file [ file join $::eye::dir_img orange_16.png ]
               image create photo .iblue   -format png -file [ file join $::eye::dir_img blue_16.png   ]
               image create photo .igray   -format png -file [ file join $::eye::dir_img gray_16.png   ]
               button $fblock.event.feu_uneimg      -image .igray -borderwidth 0 -width 32 -height 16 -takefocus 1 -compound center
               button $fblock.event.feu_calibration -image .igray -borderwidth 0 -width 32 -height 16 -takefocus 1 -compound center
               button $fblock.event.feu_objet       -image .igray -borderwidth 0 -width 32 -height 16 -takefocus 1 -compound center
               button $fblock.event.feu_telescope   -image .igray -borderwidth 0 -width 32 -height 16 -takefocus 1 -compound center

               label  $fblock.event.duree_uneimg      -textvariable ::eye::widget(event,duree,uneimg)      -justify right
               label  $fblock.event.duree_calibration -textvariable ::eye::widget(event,duree,calibration) -justify right
               label  $fblock.event.duree_objet       -textvariable ::eye::widget(event,duree,objet)       -justify right
               label  $fblock.event.duree_telescope   -textvariable ::eye::widget(event,duree,telescope)   -justify right

         set gblock [ frame $frmtable.g ]

            TitleFrame $gblock.view -borderwidth 2 -text "View"

               Button $gblock.view.table -text "Ref Stars" -command "::eye::table_ref_stars"


         grid $eblock $ablock $bblock $cblock $fblock $gblock -in $frmtable -sticky news

            grid $ablock.simu -in $ablock -sticky news

               grid $ablock.simu.visu    -in [$ablock.simu getframe]  -row 0 -column 0  -sticky news
               grid $ablock.simu.close   -in [$ablock.simu getframe]  -row 1 -column 0  -sticky news
               grid $ablock.simu.xflip   -in [$ablock.simu getframe]  -row 2 -column 0  -sticky news
               grid $ablock.simu.yflip   -in [$ablock.simu getframe]  -row 3 -column 0  -sticky news

            grid $bblock.scale     -in $bblock -sticky news

               grid $bblock.scale.nbstars -in [$bblock.scale getframe]  -row 0 -column 0  -sticky news
               grid $bblock.scale.orient  -in [$bblock.scale getframe]  -row 1 -column 0  -sticky news

            grid $cblock.tools     -in $cblock -sticky news

               grid $cblock.tools.cent  -in [$cblock.tools getframe]  -row 0 -column 0  -sticky news
               grid $cblock.tools.reset -in [$cblock.tools getframe]  -row 1 -column 0  -sticky news
               grid $cblock.tools.meca  -in [$cblock.tools getframe]  -row 2 -column 0  -sticky news
               grid $cblock.tools.cele  -in [$cblock.tools getframe]  -row 3 -column 0  -sticky news

            grid $dblock.config     -in $dblock -sticky news

               grid $dblock.config.lbox $dblock.config.vbox -in [$dblock.config getframe]  -row 0 -column 0  -sticky nes
               grid $dblock.config.lnbr $dblock.config.vnbr -in [$dblock.config getframe]  -row 1 -column 0  -sticky nes
               grid $dblock.config.lrdf $dblock.config.vrdf -in [$dblock.config getframe]  -row 2 -column 0  -sticky nes
               grid $dblock.config.ldrf $dblock.config.vdrf -in [$dblock.config getframe]  -row 3 -column 0  -sticky nes

            grid $eblock.telescope -in $eblock -sticky news

               grid $eblock.telescope.select  -in [$eblock.telescope getframe]  -row 0 -column 0  -columnspan 1 -sticky w
               grid $eblock.telescope.taille  -in [$eblock.telescope getframe]  -row 1 -column 0  -sticky news
               grid $eblock.telescope.pos     -in [$eblock.telescope getframe]  -row 2 -column 0  -sticky news

               grid $eblock.telescope.setpos  -in [$eblock.telescope getframe]  -row 1 -column 1  -sticky news
               grid $eblock.telescope.setsize -in [$eblock.telescope getframe]  -row 2 -column 1  -sticky news

            grid $fblock.event -in $fblock -sticky news

               grid $fblock.event.start -in [$fblock.event getframe]  -row 0 -column 0  -sticky e
               grid $fblock.event.stop  -in [$fblock.event getframe]  -row 2 -column 0  -sticky e

               grid $fblock.event.check_uneimg       -in [$fblock.event getframe]  -row 0 -column 1 -sticky we
               grid $fblock.event.check_calibration  -in [$fblock.event getframe]  -row 1 -column 1 -sticky we
               grid $fblock.event.check_objet        -in [$fblock.event getframe]  -row 2 -column 1 -sticky we
               grid $fblock.event.check_telescope    -in [$fblock.event getframe]  -row 3 -column 1 -sticky we

               grid $fblock.event.uneimg             -in [$fblock.event getframe]  -row 0 -column 2 -sticky we
               grid $fblock.event.calibration        -in [$fblock.event getframe]  -row 1 -column 2 -sticky we
               grid $fblock.event.objet              -in [$fblock.event getframe]  -row 2 -column 2 -sticky we
               grid $fblock.event.telescope          -in [$fblock.event getframe]  -row 3 -column 2 -sticky we

               grid $fblock.event.feu_uneimg         -in [$fblock.event getframe]  -row 0 -column 3 -sticky we
               grid $fblock.event.feu_calibration    -in [$fblock.event getframe]  -row 1 -column 3 -sticky we
               grid $fblock.event.feu_objet          -in [$fblock.event getframe]  -row 2 -column 3 -sticky we
               grid $fblock.event.feu_telescope      -in [$fblock.event getframe]  -row 3 -column 3 -sticky we

               grid $fblock.event.cursor_uneimg      -in [$fblock.event getframe]  -row 0 -column 4 -sticky we
               grid $fblock.event.cursor_calibration -in [$fblock.event getframe]  -row 1 -column 4 -sticky we
               grid $fblock.event.cursor_objet       -in [$fblock.event getframe]  -row 2 -column 4 -sticky we
               grid $fblock.event.cursor_telescope   -in [$fblock.event getframe]  -row 3 -column 4 -sticky we

               grid $fblock.event.duree_uneimg       -in [$fblock.event getframe]  -row 0 -column 5 -sticky we
               grid $fblock.event.duree_calibration  -in [$fblock.event getframe]  -row 1 -column 5 -sticky we
               grid $fblock.event.duree_objet        -in [$fblock.event getframe]  -row 2 -column 5 -sticky we
               grid $fblock.event.duree_telescope    -in [$fblock.event getframe]  -row 3 -column 5 -sticky we

            grid $gblock.view -in $gblock -sticky news

               grid $gblock.view.table -in [$gblock.view getframe]  -row 0 -column 0  -sticky e

# Onglet : Config

      set frmtable [frame $f_setup.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
      pack $frmtable -in $f_setup -expand yes -fill both

         set ablock [ frame $frmtable.a ]

            TitleFrame $ablock.fov -borderwidth 2 -text "fov"

               label  $ablock.fov.lbox -text "Taille boite de mesure"              -width 32 -justify left
               entry  $ablock.fov.vbox -textvariable ::eye::widget(fov,boxradius)  -width 4  -justify center
               label  $ablock.fov.lnbr -text "Nb etoile de reference"              -width 32 -justify left
               entry  $ablock.fov.vnbr -textvariable ::eye::widget(fov,nbref)      -width 4  -justify center
               label  $ablock.fov.lrdf -text "Rayon d acceptance en pixel"         -width 32 -justify left
               entry  $ablock.fov.vrdf -textvariable ::eye::widget(fov,rdiff)      -width 4  -justify center
               label  $ablock.fov.ldrf -text "Drift meca facteur sideral"          -width 32 -justify left
               entry  $ablock.fov.vdrf -textvariable ::eye::widget(fov,driftspeed) -width 4  -justify center

         set bblock [ frame $frmtable.b ]

            TitleFrame $bblock.dir -borderwidth 2 -text "Repertoires"

            label  $bblock.dir.lab_starcat -text "Tycho2 facon USNO: "
            entry  $bblock.dir.dir_starcat -textvariable ::eye::widget(simu,catalog) -width 60 -justify left

            label  $bblock.dir.lab_tmpdir -text "TMP dir: "
            entry  $bblock.dir.dir_tmpdir -textvariable ::eye::widget(methode,calib_tmpdir) -width 60 -justify left

         grid $ablock $bblock -in $frmtable -sticky news

            grid $ablock.fov     -in $ablock -sticky news

               grid $ablock.fov.lbox $ablock.fov.vbox -in [$ablock.fov getframe]  -row 0 -column 0  -sticky nes
               grid $ablock.fov.lnbr $ablock.fov.vnbr -in [$ablock.fov getframe]  -row 1 -column 0  -sticky nes
               grid $ablock.fov.lrdf $ablock.fov.vrdf -in [$ablock.fov getframe]  -row 2 -column 0  -sticky nes
               grid $ablock.fov.ldrf $ablock.fov.vdrf -in [$ablock.fov getframe]  -row 3 -column 0  -sticky nes

            grid $bblock.dir     -in $bblock -sticky news

               grid $bblock.dir.lab_starcat $bblock.dir.dir_starcat -in [$bblock.dir getframe] -sticky w
               grid $bblock.dir.lab_tmpdir  $bblock.dir.dir_tmpdir  -in [$bblock.dir getframe] -sticky w


# Onglet : Game Config

        set frmtable [frame $f_gconf.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
        pack $frmtable -in $f_gconf -expand yes -fill both

        set ablock [ frame $frmtable.a ]

              TitleFrame $ablock.select -borderwidth 2 -text "Selection des options"

                 checkbutton $ablock.select.dem -highlightthickness 0  \
                             -variable ::eye::widget(game,demo) \
                             -text "Mode Demo" -justify left
                 checkbutton $ablock.select.mes -highlightthickness 0  \
                             -variable ::eye::widget(game,mes) \
                             -text "Mise en station avec Chercheur electronique" -justify left

                 checkbutton $ablock.select.con -highlightthickness 0  \
                             -variable ::eye::widget(game,con) \
                             -text "J ai l'EQMOD" -justify left
                 checkbutton $ablock.select.che -highlightthickness 0  \
                             -variable ::eye::widget(game,che) \
                             -text "J ai un chercheur electronique" -justify left
                 checkbutton $ablock.select.gps -highlightthickness 0  \
                             -variable ::eye::widget(game,gps) \
                             -text "J'ai un GPS Ã  main" -justify left

        set bblock [ frame $frmtable.b ]

              TitleFrame $bblock.action -borderwidth 2 -text "Game"

                 Button $bblock.action.reg -text "Regles"    -command "::eye::game_regles"
                 Button $bblock.action.run -text "Run"       -command "::eye::game_run"

        set cblock [ frame $frmtable.c ]

              TitleFrame $cblock.action -borderwidth 2 -text "Arbre"

                 label  $cblock.action.lst -text "Etape" -width 5 -justify left
                 entry  $cblock.action.vst -textvariable ::eye::widget(tree,origin) -width 4  -justify center
                 checkbutton $cblock.action.pdf -highlightthickness 0  \
                             -variable ::eye::widget(tree,pdf) \
                             -text "PDF" -justify left
                 Button $cblock.action.vew -text "Voir" -command "::eye::game_tree_view_all"
                 Button $cblock.action.gen -text "Regenere"  -command "::eye::game_create_tree"
                 checkbutton $cblock.action.ver -highlightthickness 0  \
                             -variable ::eye::widget(tree,verif) \
                             -text "Verification" -justify left

        set dblock [ frame $frmtable.d ]

              TitleFrame $dblock.action -borderwidth 2 -text "Dev"

                 Button $dblock.action.res -text "Ressource" -command "::eye::ressource"
                 Button $dblock.action.rec -text "Recharge"  -command "::eye::recharge"

         grid $ablock $bblock $cblock $dblock -in $frmtable -sticky news

            grid $ablock.select -in $ablock  -columnspan 1 -rowspan 1 -sticky news

                 grid $ablock.select.dem -in [$ablock.select getframe] -column 0 -row 0 -sticky nws
                 grid $ablock.select.mes -in [$ablock.select getframe] -column 0 -row 1 -sticky nws

                 grid $ablock.select.con -in [$ablock.select getframe] -column 1 -row 0 -sticky nws
                 grid $ablock.select.che -in [$ablock.select getframe] -column 1 -row 1 -sticky nws
                 grid $ablock.select.gps -in [$ablock.select getframe] -column 1 -row 2 -sticky nws

            grid $bblock.action -in $bblock  -columnspan 1 -rowspan 1 -sticky news
                 grid $bblock.action.reg -in [$bblock.action getframe] -sticky news
                 grid $bblock.action.run -in [$bblock.action getframe] -sticky news

            grid $cblock.action -in $cblock  -columnspan 1 -rowspan 1 -sticky news
                 grid $cblock.action.lst $cblock.action.vst -in [$cblock.action getframe] -sticky news
                 grid $cblock.action.pdf -in [$cblock.action getframe] -sticky news -columnspan 2
                 grid $cblock.action.vew -in [$cblock.action getframe] -sticky news -columnspan 2
                 grid $cblock.action.gen -in [$cblock.action getframe] -sticky news -columnspan 2
                 grid $cblock.action.ver -in [$cblock.action getframe] -sticky news -columnspan 2

            grid $dblock.action -in $dblock  -columnspan 1 -rowspan 1 -sticky news
                 grid $dblock.action.res -in [$dblock.action getframe] -sticky news
                 grid $dblock.action.rec -in [$dblock.action getframe] -sticky news


# Onglet : Game

        set frmtable [frame $f_game.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
        pack $frmtable -in $f_game -expand yes -fill both

        # Description de l etape sous forme de question
        set ablock [ frame $frmtable.a -pady 5]

            label  $ablock.etape -text "Appuyer sur Run" -font { Times -14 bold }
            set ::eye::widget(game,etape) $ablock.etape

            # Reponses
            set ::eye::widget(game,reponses) [frame $ablock.rep -borderwidth 2 -width 20]

               Button $::eye::widget(game,reponses).go     -text "Go"       -command "::eye::game_step_next"
               Button $::eye::widget(game,reponses).ok     -text "Ok"       -command "::eye::game_step_next"
               Button $::eye::widget(game,reponses).yes    -text "Oui"      -command ""
               Button $::eye::widget(game,reponses).no     -text "Non"      -command ""
               Button $::eye::widget(game,reponses).pass   -text "Je passe" -command ""
               Button $::eye::widget(game,reponses).echec  -text "Echec"    -command "::eye::game_step_echec"
               Button $::eye::widget(game,reponses).back   -text "Retour"   -command "::eye::game_step_back"

            Button $ablock.rec  -text "Rc"    -command "::eye::recharge"
            Button $ablock.res  -text "Rs"    -command "::eye::ressource"
            Button $ablock.arb  -text "Arbre" -command "::eye::game_tree_view_all"
            Button $ablock.run  -text "Run"   -command "::eye::game_run"

        # Liste des differentes etapes
        set liste [ frame $frmtable.l ]

            set cols [list 0  "Id"           right  \
                           0  "Action"       left   \
                           0  "statut"       center \
                           0  "duree"        left   \
                           0  "boutons"      left   \
                     ]

            set ::eye::game_tab $liste.tab
            tablelist::tablelist $::eye::game_tab \
               -columns $cols \
               -width 0 \
               -height 6 \
               -showlabels 0 \
               -labelcommand tablelist::sortByColumn \
               -yscrollcommand [ list $liste.vsb set ] \
               -selectmode extended \
               -activestyle none \
               -stripebackground "#e0e8f0" \
               -showseparators 1

            scrollbar $liste.vsb -orient vertical -command [list $::eye::game_tab yview]
            pack $liste.vsb -in $liste -side left -fill y
            #bind [$::eye::table_ref_stars_tab bodypath] <Double-1> [ list ::eye::select_starlist $::eye::game_tab]
            pack $::eye::game_tab -in $liste -expand yes -fill both

            $::eye::game_tab columnconfigure 0 -sortmode integer
            $::eye::game_tab columnconfigure 1 -sortmode dictionary




        # Grid

        pack $ablock -in $frmtable
        pack $liste -in $frmtable -expand yes -fill both


        # grid $ablock $bblock -in $frmtable -sticky news
            pack $ablock.arb   -in $ablock -side left
            pack $ablock.rec   -in $ablock -side left
            pack $ablock.res   -in $ablock -side left
            pack $ablock.run   -in $ablock -side left

            pack $ablock.etape -in $ablock -side left

            pack $ablock.rep   -in $ablock -side left


# Onglet : Joystick

         set frmtable [frame $f_joy.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
         pack $frmtable -in $f_joy

         set ablock [ frame $frmtable.a ]

            TitleFrame $ablock.connect -borderwidth 2 -text "Action"

               Button $ablock.connect.on  -text "Connect"   -command "::eye::joystick_connect"
               Button $ablock.connect.off -text "Stop"      -command "::eye::joystick_close"
               Button $ablock.connect.res -text "Ressource" -command "::eye::ressource"

         set bblock [ frame $frmtable.b ]

            TitleFrame $bblock.vit -borderwidth 2 -text "Vitesse Axes"

               label  $bblock.vit.l1 -text "1" -width 5 -justify left
               entry  $bblock.vit.v1 -textvariable ::eye::widget(joystick,vitesse,1) -width 4  -justify center
               label  $bblock.vit.l2 -text "2" -width 5 -justify left
               entry  $bblock.vit.v2 -textvariable ::eye::widget(joystick,vitesse,2) -width 4  -justify center
               label  $bblock.vit.l3 -text "3" -width 5 -justify left
               entry  $bblock.vit.v3 -textvariable ::eye::widget(joystick,vitesse,3) -width 4  -justify center
               label  $bblock.vit.l4 -text "4" -width 5 -justify left
               entry  $bblock.vit.v4 -textvariable ::eye::widget(joystick,vitesse,4) -width 4  -justify center

         grid $ablock $bblock -in $frmtable -sticky news

            grid $ablock.connect -in $ablock  -columnspan 1 -rowspan 1 -sticky news
                 grid $ablock.connect.on  -in [$ablock.connect getframe] -sticky news
                 grid $ablock.connect.off -in [$ablock.connect getframe] -sticky news
                 grid $ablock.connect.res -in [$ablock.connect getframe] -sticky news

            grid $bblock.vit -in $bblock  -columnspan 1 -rowspan 1 -sticky news
                 grid $bblock.vit.l1 $bblock.vit.v1 -in [$bblock.vit getframe] -sticky news
                 grid $bblock.vit.l2 $bblock.vit.v2 -in [$bblock.vit getframe] -sticky news
                 grid $bblock.vit.l3 $bblock.vit.v3 -in [$bblock.vit getframe] -sticky news
                 grid $bblock.vit.l4 $bblock.vit.v4 -in [$bblock.vit getframe] -sticky news

# Onglet : Dev

        set frmtable [frame $f_dev.frmtable -borderwidth 4 -cursor arrow -relief sunken -background white]
        pack $frmtable -in $f_dev

        set ablock [ frame $frmtable.a ]

              TitleFrame $ablock.charge -borderwidth 2 -text "Rechargement des scritps"

                 Button $ablock.charge.res -text "Ressource" -command "::eye::ressource"
                 Button $ablock.charge.rec -text "Recharge" -command "::eye::recharge"
                 Button $ablock.charge.cle -text "Effacer les marques" -command "::eye::deleteStar"

              TitleFrame $ablock.devoloppeur -borderwidth 2 -text ""

                 checkbutton $ablock.devoloppeur.iam -highlightthickness 0  \
                             -variable ::eye::widget(dev,isit) \
                             -text "Je suis un developpeur" -justify left -command ""

        set bblock [ frame $frmtable.b ]

              TitleFrame $bblock.test -borderwidth 2 -text "Image Test"

                 Button     $bblock.test.polaris -text "Polaris"  -command "::eye::charge_une_image_test Polaris"
                 Button     $bblock.test.mizar   -text "Mizar"    -command "::eye::charge_une_image_test Mizar"
                 Button     $bblock.test.alkaid  -text "Alkaid"   -command "::eye::charge_une_image_test Alkaid"
                 Button     $bblock.test.kausaustralis  -text "KausAustralis"   -command "::eye::charge_une_image_test KausAustralis"

         grid $ablock $bblock -in $frmtable -sticky news

            grid $ablock.charge -in $ablock  -columnspan 1 -rowspan 1 -sticky news
                 grid $ablock.charge.res $ablock.charge.rec $ablock.charge.cle -in [$ablock.charge getframe] -sticky news

            grid $ablock.devoloppeur -in $ablock  -columnspan 1 -rowspan 1 -sticky news
                 grid $ablock.devoloppeur.iam  -in [$ablock.devoloppeur getframe]  -sticky news

            grid $bblock.test -in $bblock  -columnspan 1 -rowspan 1 -sticky news
                 grid $bblock.test.polaris -in [$bblock.test getframe] -sticky news
                 grid $bblock.test.mizar   -in [$bblock.test getframe] -sticky news
                 grid $bblock.test.alkaid  -in [$bblock.test getframe] -sticky news
                 grid $bblock.test.kausaustralis  -in [$bblock.test getframe] -sticky news

      return
   }


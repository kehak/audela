AudeLA-3.x.0


1. Introduction
===============

AudeLA est un logiciel de pilotage d'instruments astronomiques amateurs, et
de traitement d'images. Sa particularité est de proposer une modularité unique
dans son domaine grâce à un puissant langage de script. C'est le fruit du
travail d'astronomes amateurs, réalisé pendant leur temps libre, dans le but
d'améliorer leurs conditions d'observations. Leur souhait est de partager cet
outil avec d'autres personnes, autant astronomes amateurs, qu'informaticiens
amateurs, afin de le faire progresser : N'hésitez pas à nous contacter si vous
souhaitez apporter votre contribution.

Ce logiciel est libre, reportez-vous au paragraphe 4 pour plus de détails.

Pour tout support, veuillez vous inscrire à la mailing list audela-dev :
http://fr.groups.yahoo.com/group/audeladev/


2. Matériel supporté
====================

AudeLA est capable de piloter les caméras CCD suivantes :
- AndorTech,
- APN (Appareil Photo Numérique, CANON et NIKON),
- Apogée,
- Caméras compatibles ASCOM,
- Atik,
- Audine (Kaf séries 400, 401, 401E, 1600, 1602, 1602E et 3200E),
- Cagire,
- Cemes,
- EPIX - OWL,
- EPIX - Raptor,
- Finger Lakes Instruments,
- QSI (tous les modèles),
- SBIG (tous les modèles),
- WebCam et caméra vidéo par l'intermédiaire d'un grabber,
- Nikon CoolPix (port série) : Uniquement créée par l'outil Acquisition APN CoolPix.

Les caméras supportées avec les versions antérieures (2.x) et plus avec les versions 3.x sont :
- CB245,
- Hi-SIS 11,
- Hi-SIS 22 (12 et 14 bits),
- Hi-SIS 23,
- Hi-SIS 24,
- Hi-SIS 33,
- Hi-SIS 36,
- Hi-SIS 39,
- Hi-SIS 43,
- Hi-SIS 44,
- Hi-SIS 48,
- Kitty 2,
- SCR1300XTC,
- MX516,
- MX916,
- HX516,
- TH7852A.

AudeLA est capable de piloter les montures suivantes :
- Montures compatibles ASCOM,
- AudeCom (ex-carte Kauffmann),
- Celestron,
- Delta Tau,
- DFM,
- EQMOD,
- Etel,
- LX200 ou n'importe quelle monture répondant au protocole LX200,
- MCMT II/32,
- Ouranos (codeurs absolus),
- T193 de l'OHP,
- TelScript (T94 de Saint Caprais par exemple),
- Temma (monture Takahashi avec module Temma).

AudeLA est capable de piloter les interfaces de communication suivantes :
- EthernAude (interface Ethernet pour caméras CCD),
- GPhoto2,
- Manuel,
- Oscadine,
- Port parallèle,
- Port série,
- QuickAudine (interface USB pour caméras Audine),
- QuickRemote (interface USB pour APN, WebCam longue pose, raquette de télescope,
  mise au point, etc.),
- Velleman K8055,
- Velleman K8056.

AudeLA est capable de piloter les équipements suivants :
- Focaliseur AudeCom,
- Focaliseur JMI,
- Focaliseur LX200,
- Focaliseur T193,
- Focaliseur USB_Focus,
- Lhires 3,
- Roue à filtres développée dans le cadre de l'Association Aude,
- ScopeDome,
- Station météo.

Bien entendu les auteurs ne disposent pas de tout ce matériel cité. Ils les ont
intégrés en fonction des moyens et des connaissances disponibles, n'étant pas à
l'abris de quelques spécificités de ce matériel se traduisant soit par un
dysfonctionnement, soit par une baisse de performance, soit par une absence de
fonctionnalité.

AudeLA fonctionne avec :
Ordinateur PC,
Pentium 75 minimum
16 Mo Ram
Windows 95, 98, ME, NT, 2000, XP, Vista, Windows 7,
Linux.

* Particularité Windows :
La plupart des caméras supportées exigent l'utilisation du port parallèle.
L'utilisation du port parallèle ne cause pas de difficulté sous Win95, 98, ME
ou Linux (root). En revanche, pour utiliser le port parallèle sous WinNT, XP,
2000, etc., l'utilitaire "allowio" s'installe automatiquement au premier démarrage
pour donner accès aux ports. Si une version antérieure d'allowio est détectée
il sera proposé de la désinstaller et de la remplacer par la version fournie
avec AudeLA.

* Particularité Linux :
AudeLA n'utilise pas de kernel driver pour communiquer avec les caméras, mais
utilise les accès directs au port parallèle. Il faut donc avoir les droits de
superviseur pour pouvoir réaliser des acquisitions.


3. Quelle est la différence entre AudeLA et Aud'ACE ?
=====================================================

"AudeLA" est un exécutable qui ne fait que charger un ensemble de librairies
(traitement d'images, mécanique céleste, acquisition, pilotage, autres), et
démarre ensuite un interpréteur TCL/TK. Ces librairies ont été écrites soit
par les auteurs, soit par des contributeurs, et reposent également sur des
librairies externes (TCL, FITSIO, GZIP, JPEG, et certains drivers de caméras).

Par la suite on entend par "modules propres à AudeLA" ceux qui ont réellement
été écrits par les auteurs ou contributeurs directs. Cela correspond aux
répertoires audela, libak, libaudela, libcam, libgsl, libgzip, libjm, libmc,
librgb, libtel, libtt.

"Aud'ACE" est une interface graphique qui exploite les possibilités de
"AudeLA". "Aud'ACE" a été écrit en TCL/TK par les auteurs, et utilise bon
nombre de librairies externes (affichage, widgets, formats d'image, etc.).


4. Licence
==========

Les modules propres à AudeLA et Aud'ACE sont distribués sous la licence
GPL (GNU Public Licence). En quelques mots, cela veut dire que c'est un
logiciel libre : Vous êtes libres de le copier, le distribuer, et le
modifier. La GPL impose que si vous distribuez ce programme, alors vous
devez donner les mêmes droits au récipiendaire que ceux que vous avez reçus.
En particulier vous devez rendre les sources accessibles, y-compris les
modifications que vous auriez éventuellement pu apporter au programme.

La licence GPL est faite pour développer le logiciel libre. Elle impose donc
que si vous écrivez un logiciel utilisant tout ou partie de "AudeLA", alors
celui-ci devra être GPL, à l'image de "Aud'ACE".

Ce programme ne comporte aucune garantie de fonctionnement (on essaye
quand même de faire quelque chose qui marche :-)), et est livré "en l'état".
En particulier, les auteurs ne s'engagent en aucune manière à devoir
corriger des bugs, s'il y en avait ; Et ils ne peuvent en aucun cas être
tenus responsables d'une quelconque dégradation du fait d'un événement
ayant une relation avec AudeLA. Le disclaimer suivant résume la situation :

<<<
   This program is free software; You can redistribute it and/or modify
   it under the terms of the GNU General Public Licence as published by
   the Free Software Foundation; Either version 2 of the Licence, or (at
   your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; Without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public Licence for more details.
>>>

Consultez le site http://www.gnu.org pour plus de renseignements sur le
monde des logiciels libres.

AudeLA et Aud'ACE utilisent des librairies externes. Ces modules ont été
écrits par des gens que nous ne connaissons même pas (mais que nous remercions
au passage), et sont distribuées avec des licences diverses. Qu'il soit bien
clair que nous n'appliquons pas la licence GPL à ces modules.

Nous avons autant que possible respecté la volonté des auteurs, lorsque
celle-ci est stipulée, concernant la redistribution de leur travail. Nous
vous invitons à naviguer dans l'arborescence de AudeLA afin de consulter les
différents fichiers de licence. Pour information, seuls les sources de
gzip ont légèrement été modifiés afin de pouvoir générer une librairie partagée.

Enfin, certaines librairies sont distribuées sans licence, voire même sans
code source. Nous les redistribuons avec l'intention de rendre service à
l'utilisateur, et avec l'espoir de ne pas aller à l'encontre de la volonté
de leurs auteurs. Si tel était le cas, qu'ils veuillent bien nous contacter.

Si les ayatollahs du logiciel libre le veulent, ils peuvent supprimer ces fichiers
après leur installation afin de ne pas teinter leur machine.


5. Installation et démarrage
============================

5.1 Windows
-----------

Vous aurez probablement téléchargé un exécutable d'installation.

Dans ce cas, exécutez-le. A l'issue de l'installation, il y aura un menu AudeLA
dans votre "Menu Démarrer", et aussi une icône sur votre bureau. C'est ce qui vous
permet de lancer AudeLA.

Note aux utilisateurs de caméras SBIG : Installez le driver système pour la caméra
avec le logiciel proposé par SBIG: "SetupDriverChecker.exe", disponible gratuitement
à l'adresse suivante: ftp://ftp.sbig.com/pub/SetupDriverChecker.exe

Note aux utilisateurs d'APN (Appareil Photo Numérique) :
   La liaison USB entre AudeLA et les APN requiert libusb-win32 qui est disponible
   sur le site  http://libusb-win32.sourceforge.net
   Télécharger le fichier libusb-win32-filter-bin-0.1.10.1.exe
   Puis installer libusb-win32 en exécutant ce fichier.

Note aux utilisateurs de QuickAudine et de QuickRemote :
   La liaison USB entre AudeLA et QuickAudine ou QuickRemote nécessite le driver FTDI
   qui est disponible sur le site http://www.ftdichip.com/
   (menu Drivers->D2XX)

   Pour Windows XP 64 bits, télécharger le fichier
        http://www.ftdichip.com/Drivers/CDM/WinXPx64/CDM%202.00.00%20x64.zip
   Pour Windows XP 32 bits, télécharger le fichier
        http://www.ftdichip.com/Drivers/CDM/Win2000/CDM%202.00.00.zip
   Pour Windows 98 ou Me, télécharger le fichier
        http://www.ftdichip.com/Drivers/D2XX/Win98/D30104.zip

   Puis dézipper le fichier dans un répertoire temporaire et lancer l'installation
   en suivant la procédure décrite dans
   http://www.ftdichip.com/Documents/InstallGuides.htm

5.2 Linux
---------

5.2.1 Prérequis
---------------

AudeLA exploite la philosophie linux, basée sur le partage et la mise en commun
d'éléments de base: Outre un noyau consistant de fonctions propres, AudeLA utilise
de nombreux autres morceaux de logiciels. Mais pour limiter la taille des sources
à diffuser, les autres modules sont à télécharger et installer suivant les pratiques
de chaque plateforme (paquets Debian, archives RPM, etc.).

Les briques suivantes sont requises. Le paquet Debian correspondant est mentionné.
  Tcl (the Tool Command Language) v8.5 - run-time files         (tcl8.5)
  Tk toolkit for Tcl and X11, v8.5 - run-time files             (tk8.5)
  Extended image format support for Tcl/Tk                      (libtk-img)
  GNU Scientific Library (GSL) -- library package               (libgsl0)
  Userspace USB programming library                             (libusb-0.1-4)

Les outils pour compiler/développer :
  Automatic configure script builder                            (autoconf)
  File comparison utilities                                     (diff)
  The GNU version of the "make" utility                         (make)
  The GNU C compiler                                            (gcc  >4.1)
  The GNU C++ compiler                                          (g++  >4.1)
  GNU Scientific Library (GSL) -- Development package           (libgsl0-dev)
  Userspace USB programming library development files           (libusb-dev)
  Linux Kernel Headers for development                          (linux-kernel-headers)
  Apply a diff file to an original                              (patch)
  Tcl (the Tool Command Language) v8.5 - Development files      (tcl8.5-dev)
  Tk toolkit for Tcl and X11, v8.5 - Development files          (tk8.5-dev)

5.2.2 Lancer AudeLA
-------------------

Aller dans le répertoire bin, et exécuter ./audela.sh

5.2.3 Utilisation de QuickRemote ou QuickAudine
-----------------------------------------------

Cette action peut être nécessaire seulement pour les liaisons avec
QuickRemote et QuickAudine.

Il se peut que les services hotplug qui surveillent le branchement des
équipements prennent la main de manière exclusive sur les périphériques
à base de FTDI, tels que QuickRemote et QuickAudine.

Pour savoir si tel est le cas, brancher un des deux équipements et lancer
la commande shell lsmod pour lister les drivers utilisés par le kernel.
Généralement celui correspondant à l'identifiant USB de QuickRemote
s'appelle ftdi_sio. Si ce service existe, le supprimer.

Pour lister les services, utiliser la commande lsmod.
Pour arrêter un service, utiliser la commande rmmod.

Attention, ces commandes sont à exécuter en ayant les privilèges root.

Exemple :
  # su root
  # lsmod |grep ftdi_sio
    ftdi_sio               31940  0
    usbserial              26920  1 ftdi_sio
    usbcore               106008  5 ftdi_sio,usbserial,ehci-hcd,uhci-hcd
  # rmmod ftdi_sio
  # lsmod |grep ftdi_sio
  #

Remarques :
  - Le service est relancé automatiquement chaque fois que QuickRemote est
    rebranché. Je n'ai pas trouvé la commande qui désactive définitivement
    le hotplug pour cet équipement.
  - Pour relancer le service hotplug manuellement, taper la commande
    "modprobe ftdi_sio" sous root.

5.3 Organisation des répertoires
--------------------------------
bin : Répertoire où sont stockés tous les binaires après compilation.
      C'est également depuis ce répertoire qu'on exécute AudeLA.
gui : Contient les différentes interfaces graphiques, en particulier
      Aud'ACE dans le répertoire gui/audace.
src : Répertoire des sources.
lib : Contient les librairies TCL additionnelles.


6. Auteurs
==========

Les auteurs initiaux de AudeLA sont :
 - Alain KLOTZ <alain.klotz@free.fr> et
 - Denis MARCHAIS <denis.marchais@free.fr>.

Par la suite, ils ont été rejoints par :
 - Robert DELMAS <delmas.robert@wanadoo.fr>,
 - Christian JASINSKI <christian.jasinski@gmail.com>,
 - Michel PUJOL <michel-pujol@orange.fr>.

Ils forment "The AudeLA Core Team" (TACT), nom employé pour le copyright dans
les sources.


7. Contributions
================

Un bon nombre de personnes ont contribué à AudeLA ou Aud'ACE. Citons dans le désordre :
 - Jacques MICHELET <jacques.michelet@laposte.net> : Librairie libjm et
   outils GPS et King, scripts de photométrie (calaphot) et de tri par
   fwhm (tri_fwhm).
 - François COCHARD <francois.cochard@wanadoo.fr> : Outils Acquisition et
   Prétraitement.
 - Olivier THIZY <thizy@free.fr> : Script de photométrie (calaphot).
 - Raymond ZACHANTKE <zachantk@club-internet.fr> : Outil APN, monture
   Ouranos et divers scripts pour le traitement d'images d'APN.
 - Philippe KAUFFMANN <philippe.kauffmann@free.fr> : Monture AudeCom.
 - Guillaume SPITZER <gspitzer@free.fr> : Librairie libgs pour
   l'interfaçage avec "Guide".
 - Benoit MAUGIS <benoit.maugis@laposte.net> : Librairie libbm, traitement
   de séries d'images, gestion d'images FITS polychromes (poly), traitement
   d'images stellaires, utilisation conjointe d'AudeLA et d'Iris, outils
   Visionneuse et Acquisition fenêtrée.
 - Pierre THIERRY : Imagerie couleur et obturateur "thierry".
 - Patrick CHEVALLEY <pchev@gmx.ch> : Driver WebCam longue pose.
 - Arkadius KALICKI : Driver WebCam.
 - Michel MEUNIER <michel.meunier100@wanadoo.fr> : Driver Ethernaude.
 - Vincent COTREZ <vincentcotrez@yahoo.fr> : Script de détection (detection).
 - Benjamin MAUCLAIRE <bmauclaire@underlands.org> : Filtres pour traitements
   d'images et scripts pour la spectroscopie (spcaudace).
 - Harald RISCHBIETER : Traitement d'images matriciel.
 - Xavier REY-ROBERT <xrr@altern.org> : Utilitaire scriptis pour exécuter
   des scripts de commande Iris.
 - Raoul BEHREND <raoul.behrend@obs.unige.ch> : Utilitaires pour la
   conversion d'images au format FITS.
 - Jérôme BERTHIER <berthier@imcce.fr> : Outil pour l'Observatoire Virtuel.
 - Frédéric VACHIER <vachier@imcce.fr> : Outil pour l'Observatoire Virtuel.
 - Stéphane VAILLANT <vaillant@imcce.fr> : Outil pour l'Observatoire Virtuel.
 - Sylvain GIRARD <zesly@wanadoo.fr> : Driver libk2 de la caméra Kitty2.
 - Jim CADIEN <jcadien1@gmail.com> : Support pour la caméra Cookbook et SBIG (Linux).
 - Laurent JORDA : Traitement d'images de comètes (AfRho).
 - Jean-François COLIAC : Traitement d'images de comètes (AfRho).
 - Dark VADOR <vador@darkstar.com> : Inspiration permanente.
 - Christian JASINSKI, Dez FUTAK, Dan HOLLER : Traduction anglaise.
 - Fausto MANENTI, Emanuele PAVONI, Livia MORETTI : Traduction italienne.
 - Rafael GONZALEZ FUENTETAJA, Cristobal GARCIA, Jesus IGLESIAS : Traduction espagnole.
 - Philippe KAUFFMANN, Joerg HOEBELMANN : Traduction allemande.
 - Luis GOUVEIA, Leandro FONSECA : Traduction portugaise.
 - Knud STRANDBAEK : Traduction danoise.
 - Oleg MALIY : Traduction ukrainienne.
 - Oleg MALIY : Traduction russe.

Que ceux qui ont été oubliés nous excusent, et se manifestent auprès des auteurs
pour rectifier l'injustice qu'ils subissent.


8. Librairies et logiciels externes
===================================
 - BLT : Trace des courbes sous TK (histogramme, plotxy, etc.).
 - BWidget : Définition de nouveaux widgets TK.
 - DialogWin : tk_messageBox évolué.
 - Dp : Communication sur protocole IP de bas niveau (TCP, RCP, UDP, SMTP, etc.).
 - HelpViewer : Affichage d'une aide.
 - Img : Librairie de chargement de formats d'images standards (jpg, bmp, etc.).
 - Math : Librairie pour les calculs mathématiques.
 - Memchan : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Mk4tcl : Librairie pour l'outil "Mise à jour d'AudeLA".
 - MySqlTcl : Librairie pour la gestion de bases de données.
 - SuperGrid : Positionne automatiquement les widgets dans une grille.
 - TableList : Affichage d'une liste avec paramétrage des colonnes (outil Visionneuse bis).
 - TclDOM : Extension DOM pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - Tcllib : Outils divers (ftp, http, irc, ntp, etc.).
 - TclSoap : Extension SOAP pour skybot/virtual observatory. http://tclsoap.sourceforge.net
 - TclXML : Extension XML pour skybot/virtual observatory. http://tclxml.sourceforge.net
 - TCom : Protocole Microsoft COM (pour interfaces ASCOM).
 - Thread : Multi-thread.
 - TkHtml : Widget permettant d'afficher une page HTML.
 - Tls : Communication par https.
 - TMCI : Gestion du format vidéo avi.
 - Trf : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Twapi : Extension qui donne accès à des fonctions de l'API de Windows via Tcl (Tcl Windows API).
 - Vfs : Librairie pour l'outil "Mise à jour d'AudeLA".
 - Zlibtcl : Librairie pour l'outil "Mise à jour d'AudeLA".
 - CFITSIO.
 - Sextractor.
 - jpeg6b.
 - GZIP.
 - Porttalk.
 - SBIG driver.
 - FLI driver.


Bonne Utilisation !!

Les Auteurs.


AudeLA, page d'accueil : http://www.audela.org

Copyright (C)1999-2015, The AudeLA Core Team.


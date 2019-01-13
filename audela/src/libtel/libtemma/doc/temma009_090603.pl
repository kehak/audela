#!/usr/bin/perl -w

#####
# driver Perl/Tk pour montures Takahashi Temma1/Temma2
# version fonctionnelle avec Perl 5.6 et 5.8 +module Perl Tk800.022, Tk800.023, Tk800.024
# compatible Linux et Windows
# fichier script principal :	temma009_ddmmyy.pl (ce fichier)
# fichiers scripts lib :	polarisfinder.pm , zview.pm
# date creation :		10/07/02
# date dernieres modifs : 	09/06/03
# remi.petitdemange@calixo.net ou info@optique-unterlinden.com
#
# tests :
# Lien avec Linux/XEphem 3.52 via demon lx200xed
#####

# en cours :
# get_saisie_radec : verif de validités des saisies


##### historique :
#
##### fait :
# toutes les fonctions connues du protocole Temma sont utilisées ds ce script exceptée : LG autoguide ON
# config du port série proposée au 1er demarrage du script -> creation du fichier temmaRS232.cfg
# params du port serie avec fonctions : ouvrir_fconfigRS232, configRS232 et open_serialport
# test de connexion avec : test_serialportalias et test_getTemmaVersion
# config du site proposée au 1er demarrage du script -> création du fichier user_site.txt
# param du site avec fonction set_usersite, save_usersite
# fichier liste courte d'objets persos : ./listeperso.txt
# fichiers de listes d'objets faits avec XEphem (listes filtrées) :
# ./listegoto.edb => objets fixes et ./listegoto.txt => objets fixes et non fixes
# calcul tracking : calcvecteur avec $dtmpos paramètrable ($dtmpos = delta temps entre les 2 coords, ex 10min)
# curpos_zview : affiche la position courante sur minicarte ZView
# pos_sur_zview : affiche petit cercle vert de préselection sur ZView (appelée par get_saisie_radec)
# fonction redo_lastsynchro <Ctrl+s> rappel les dernieres valeurs nomObjet/RA/DEC synchro (pour re-synchro)
# ctrl_gotoRADEC : verif RADEC courante, sync et goto pour prévenir des retournements pendant goto
# ouvrir_gotodialogbox : choix du mode goto (controle Temma par defaut ou par le driver)
# gotodriverRADEC: goto direct lors des passages méridien (selon modif valeur decallage meridien virtuel)
# gotoRADEC : goto par defaut sous controle de la Temma (avec retournement selon direction du pointage)
# historique de session : liste des gotos ds fichier historic.txt
# raquette de commande avec commut HighSpeed/NormalSpeed, réglage correctionSpeed, inverseurs, stopcodeurs
#
#####
# liaison avec XEphem 3.52 :
# pour affichage position telescope sur Skyview et recup d'objets cliqués
# lien avec les fifos xephem via demon lx200xed :
# ecriture des coords : fonctions ecrit_xephem_in_fifo -> ok
# lecture des données : fonctions recup_xephem_loc_fifo et read_xephem_loc_fifo -> ok non bloquant avec Perl 5.6
# 			fonction lire_xephem_loc_fifo -> ok mais bloquant avec Perl 5.6 et 5.8
# creation manuelle des fifos de xephem :
# mkfifo -m 0666 xephem_loc_fifo
# mkfifo -m 0666 xephem_in_fifo
#
# todo XEphem3.52 : temma_xed.pl -> process demon de lecture/ecriture des fifos de xephem
# todo XEphem3.6 : recup des données xml
#
#
#
##### todo applic :
# scripts separés : commandes sur la monture
# nommer les fichiers de config du RS232: temmaconfig.lin et temmaconfig.win
# temporisation de l'applic indépendante du temps de latence du port (ex thread pour get_temma_radec)
# fonctions de controle des saisies manuelles : verif_saisieLAT, verif saisieLONG
# 1 boite de dialogue pour tous les cas de messages d'erreurs
# sauvegarde params tracking : tracking.txt (option=valeur) pour recup si Temma mise hors tension
# param applic pour hemisphere sud avec repercussion sur zview
# scripts sur listes d'objets : automatisation des pointages (à lier avec la ccd)
# faire PEC sur RA et Dec : enregistrer les corrections de l'autoguidage ou de la raquette soft
# fonctionnement en réseau
# aide utilisateur (howto XEphem +driver)
# lien img webcam : analyse de courbe pour err periodique err mise en station et pb de micro-vibration
#
#
##### todo verifs system au lancement :
# - pour windows :
# procedure simplifiée d'inclusion des modules avec require et use et aide à l'install
# - pour linux (et windows) :
# 1 si les droits sont ok sur le port serie, sur les fifos d'XEphem et le demon de communication
# 2 si presence des modules requis est ok : Tk et Device::SerialPort0.07 sinon connexion/install sur CPAN
# 3 si port serie ok et monture ok (trouver le port serie si adaptateur USB2serial) -> ok en cours de test
# 4 si les fichiers de config de l'appli sont présents -> fait en partie sauf pour les fichiers pm
#   sinon afficher init_pb_msg1 /2 /3 /4
#
# install avec placement des fichiers necessaires dans /home/user/temma/
#####


### debut du script

#### modules perl utilisés et compatibles Linux et Windows :
#use lib $ENV{PWD};	# si les modules utilisés sont dans le repertoire courant (si pb d'install sous windows)
use Tk; 		# versions ok depuis : Tk800.022, Tk800.023, Tk800.024
use Fcntl;
use Tk::BrowseEntry;
use Tk::ROText;
use Tk::DialogBox;

# modules pour script : listes.pm
require Tk::NoteBook;
use Tk::HList;
use Tk::ItemStyle;
require listes;		# script d'utilsation des listes d'objets de XEphem

require zview;		# fichier zview.pm : fenetre et fonction zview, mini carte +ligne d'horizon
require polarisfinder;	# fichier polarisfinder.pm : utilitaire de mise en stations au viseur polaire

# todo si utile : require Tk::ErrorDialog; # exploiter messages d'erreur ds $@

# detection de l'OS pour choix du bon module SerialPort
# init du module Device::SerialPort pour Linux
# init du module Win32::SerialPort pour windows
# todo : routine d'install par internet du module SerialPort
BEGIN {
        $OS_win = ($^O eq "MSWin32") ? 1 : 0;
        if ($OS_win) {
            eval "use Win32::SerialPort";	# pris sur CPAN en version 0.19 faute de mieux
	    die "$@\n" if ($@);			# todo : proposer de l'aide à l'install du module
        }
        else {
            eval "use Device::SerialPort"; 	# pris sur CPAN en version 0.07 faute de mieux
	    die "$@\n" if ($@);			# todo : proposer de l'aide à l'install du module
        }
} # End BEGIN


# detection de l'OS : particularités à placer ici
# si le driver est lancé sous Windows
if ($OS_win) {
	$fonte='Helvetica -14 normal';	# type taille graisse des polices pour Windows
	$fonte_grande='Helvetica -16 bold';
}

# si le driver est lancé sous Linux
else {	$fonte='Helvetica -12 normal';	# type taille graisse des polices pour Linux
	$fonte_grande='Helvetica -14 bold';
	# fifos de communication avec XEphem
	$chemin_fifo_in= '/usr/lib/xephem/fifos/xephem_in_fifo'; # todo : share dir ou private dir ->faire modif perso
	$chemin_fifo_loc='/usr/lib/xephem/fifos/xephem_loc_fifo';# todo : share dir ou private dir ->faire modif perso
	# pour éviter les process zombies avec ouverture/fermeture du script edit_liste forké
	$SIG{CHLD}='IGNORE'; # voir si compatible avec windows
	$driverTemma_pid=$$;			# pas utilisé pour le moment
	$pere_ppid=getppid;			# pas utilisé pour le moment
}

######
# script indépendant d'edition de listes d'objets : exec_listing_pl
#$listing_pl="./edit_liste.pl"; #### preciser ici la version à exec ##### todo test if -e (if exist)
#
# script indépendant de lecture de xephem_loc_fifo
#$temma_xed_pl="./temma_xed.pl"; # todo test if -e (if exist)
######

# variable de recup du nom de ce script
$nom_du_script=$0;
$perl_version=sprintf ("%vd",$^V);


print "---------- Ouverture de $nom_du_script ----------\n\n";

print "Version Perl :\t\t$perl_version\n";
print "Real user ID :\t\t$<\nEffective user ID :\t$<\n"; # voir si ok sous windows



# --------------- ################################################### ----------------
# --------------- # interface graphique perl/Tk: fenetre principale # ----------------
# --------------- ################################################### ----------------

$fenetre_driver = MainWindow->new(-background=>'black', -title=>"driver Temma");
$fenetre_driver->geometry("380x450+0+0");
$fenetre_driver->protocol('WM_DELETE_WINDOW',\&quitter);# fonction quitter avec bouton croix fermeture system
$fenetre_driver->bind	 ('<Control-q>' =>\&quitter);	# fonction quitter raccourcis clavier

$main_script_name=$fenetre_driver->name;		# appname pour utiliser la methode send
print "version en cours :\t$main_script_name\n";

if (defined($driverTemma_pid) && defined($pere_ppid))
	{
	print "pid :\t\t\t$driverTemma_pid\n";	# pour linux, pas utilisé pour le moment
	print "ppid :\t\t\t$pere_ppid\n";	# pour linux, pas utilisé pour le moment
	}

$etat_sessionTemma=0;	# 0->Temma non connectée , 1->Temma connectée = session ouverte
$decal_lstmerid=1;	# valeur 1 -> si tube longs / valeur 2 -> si tube court

#$frame_driver=$fenetre_driver->Frame(			# todo : placer des frame pour clarté
#				-label=>"Utilisation",
#				-relief=>"groove",
#				-width=>380,
#				-height=>100,
#				-background=>'black')->place(-x=>2, -y=>2);# gestion du gui avec "place"

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Position RA/Dec :")->place(-x=>5, -y=>12);

# coordonnées en cours -> RA hh:mm:ss.s Dec dd:mm:ss
$sortieFormatEncodeurs=$fenetre_driver->Label(
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	#-font=>'-*-Helvetica-Bold-R-Normal-*-*-140-*-*-*-*-*-*',
	-font=>$fonte_grande,	#'Helvetica -14 bold',
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$temmaRAhmsDECdms)->place(-x=>110, -y=>10);

# retour d'infos positions Est/Ouest du telescope sur monture d'après monture (byte E/W)
$sortieByteEW=$fenetre_driver->Label(
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte_grande,		#'Helvetica -14 bold',
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$infoCurPos_brut)->place(-x=>335, -y=>10);

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Pointage Objet :")->place(-x=>5, -y=>37);

# nom de l'objet pointé (objet cliqué ds XEphem ou objet perso)
$visu_astre_pointe = $fenetre_driver->Label(
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$astre_pointe)->place(-x=>110, -y=>37);


# valeur PTE/PTW en cours : position reelle du tube d'après utilisateur
$sortie_tubesideEW=$fenetre_driver->Label(
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$tubesideEW,
	)->place(-x=>335, -y=>37);


$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Synchro Objet :")->place(-x=>5, -y=>60);

# objet synchro (objet cliqué ds XEphem ou objet perso)
$visu_astre_sync = $fenetre_driver->Label(
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$astre_sync)->place(-x=>110, -y=>60);


$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"TSL/TU :")->place(-x=>5, -y=>85);

$sortie_TSL = $fenetre_driver->Label(		# sortie TSL
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$lst_hms)->place(-x=>110, -y=>85);

$sortie_TUSYS = $fenetre_driver->Label(		# sortie TU_system
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$TU_system)->place(-x=>195, -y=>85);# $TU_system->TU long $TU_system_hms-> TU court

# appliquer &calcLST sur labels de sorties TU/TSL avec maj de timeout 1 sec
@sorties_T =($sortie_TUSYS,$sortie_TSL);
@sorties_T =$fenetre_driver->repeat(1000,\&calcLST);


# ---- phase 1 : CHOIX ou PARAM SITE ----------------------------------------- INIT SITE

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Site :")->place(-x=>5, -y=>110);

$sortieNomSite = $fenetre_driver->Label(	# sortie nom site
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-width=>"10",
	-textvariable=>\$sortie_nomsite)->place(-x=>110, -y=>110);

$bouton_editsite = $fenetre_driver->Button(	# editer les params du site
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	#-height=>"1",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"EditSite",
	-command=>\&editparamsite
	)->place(-x=>195, -y=>110, -height=>20);

$bouton_fconfigRS232 = $fenetre_driver->Button(	# fenetre de config du port serie
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	#-height=>"1",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"RS-232c",
	-command=>\&ouvrir_fconfigRS232
	)->place(-x=>285, -y=>110, -height=>20);

# ---- Connexion du driver avec la Temma
$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Pilotage monture")->place(-x=>110, -y=>145);

################## bouton d'ouverture de session : fonction start_temma ###################
# demarrage de la connexion Temma avec lecture permanente des coordonnées pointées
$bouton_start_temma = $fenetre_driver->Button(
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"14",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"tomato3",	#"Sienna3",
	-text=>"Temma Connect",
	-command=>\&start_temma
	)->place(-x=>240, -y=>145, -height=>20);

# ---- phase 2 : CHOIX POSITIONS TELESCOPE SUR MONTURE (PTW/PTE) -----------------------
$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Pos télescope :")->place(-x=>5, -y=>180);


# BOUTON RADIO pour donner la position physique du telescope/monture, cde PTE : fonction set_tubesideEW
# si cliqué (après retournement) : $tubesideEW = PTE (pos Est)

$tubesideEW=""; # valeur d'init pos telescope non definie au demarrage, en attente de confirmation utilisateur
$bRadio_PosTel_Est = $fenetre_driver->Radiobutton(
	-state=>'disable',	# desactivé au lancement du driver ou après clic
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-font=>$fonte,
	#-foreground=>"tomato3",
	-indicatoron=>"0",
	-background=>"DimGrey",
	-selectcolor=>"DarkSeaGreen4",
	-width=>"10",
	-text=>"Côté Est",
	-value=>"PTE",
	-variable=>\$tubesideEW,
	-command=>\&set_tubesideEW)->place(-x=>110, -y=>180, -height=>20);

# BOUTON RADIO pour donner la position physique du telescope/monture cde PTW : fonction set_tubesideEW
# val par defaut au démarrage reconnue en pos W ou si cliqué (après retournement) : $tubesideEW=PTW (pos W)
$bRadio_PosTel_Ouest=$fenetre_driver->Radiobutton(
	-state=>'disable',	# desactivé au lancement du driver
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-font=>$fonte,
	#-foreground=>"tomato3",
	-indicatoron=>"0",
	-background=>"DimGrey",
	-selectcolor=>"DarkSeaGreen4",
	-width=>"10",
	-text=>"Côté Ouest",
	-value=>"PTW",
	-variable=>\$tubesideEW,
	-command=>\&set_tubesideEW)->place(-x=>195, -y=>180, -height=>20);

# init zenith facultatif : fonction intégrée ds setsynchro pour calculs interne des coords par la Temma
#$bouton_initZenith = $fenetre_driver->Button(
#	-state=>'disable',# -state=>"normal"
	#-borderwidth=>"1",
#	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
#	-relief=>"raised",
#	-width=>"7",
#	-font=>$fonte,
#	-foreground=>"black",
#	-background=>"DeepSkyBlue4",#RosyBrown
#	-text=>"Init Z",
#	-command=>\&initZenith
#	)->place(-x=>285, -y=>180, -height=>20);


# ouvrir ZView : fenetre type carte zenithale
$bouton_ZView = $fenetre_driver->Button(
	-state=>'disable',# -state=>"normal"
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",#RosyBrown
	-text=>"ZView",
	-command=>\&fenetre_zview
	)->place(-x=>285, -y=>180, -height=>20);


# phase 3 : SYNCHRONISATION SUR ETOILE ------------------------------------------

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Selection objet :")->place(-x=>5, -y=>230);

# ouvrir fenetre liste etoiles jalons et listes objets
$bouton_selectionListe = $fenetre_driver->Button(
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	#-height=>"1",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"Listes",
	-command=>\&listing		#&ouvrir_fenetreliste
	)->place(-x=>195, -y=>230, -height=>20);

# ouverture fenetre de communication avec fifos de XEphem (ok pour Linux, pas testé sur windows)
$bouton_XEphem = $fenetre_driver->Button(
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	#-height=>"1",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"XEphem",
	-command=>\&ouvrir_fenetreXephem
	)->place(-x=>285, -y=>230, -height=>20);


$nom_objet="objetX";		# init nom de l'objet selectionné pour synchro ou goto

# entrée manuelle ou affichage du nom de l'objet (selection ds liste ou cliqué ds XEphem)
$entreeNOM_astre = $fenetre_driver->Entry(
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-width=>"10",
	-font=> $fonte,
	-foreground=>"Tomato3",
	-background=>"gray30",
	-textvariable=>\$nom_objet)->place(-x=>110, -y=>230);

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"RA (h:m:s) ->")->place(-x=>5, -y=>260);

# entrée manuelle RA ou affichage RA selectionnée ds listes
$entreeRA_astre = $fenetre_driver->Entry(
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"Tomato3",
	-background=>"gray30",
	-width=>"10",
	-textvariable=>\$RA_hms_objet)->place(-x=>110, -y=>260);

# entrée manuelle DEC ou affichage DEC selectionnée ds listes
$entreeDEC_astre = $fenetre_driver->Entry(
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"Tomato3",
	-background=>"gray30",
	-width=>"10",
	-textvariable=>\$DEC_dms_objet)->place(-x=>195, -y=>260);
$entreeDEC_astre->bind('<Return>'=>\&get_saisie_radec);


$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"Tomato3",
	-background=>"black",
	-text=>"<- Dec (d:m:s)")->place(-x=>285, -y=>260);

$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Cde / objet :")->place(-x=>5, -y=>290);


# synchro sur RADEC saisis ou selec de l'étoile jalon : fonction setsynchro
$bouton_synchro=$fenetre_driver->Button(
#	-borderwidth=>"1",
	-state=>'disable',# -state=>"normal" ou "active"
	-text=>"Synchro",
	-highlightbackground=>"gray60",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"RosyBrown",
	-command=>\&setsynchro)->place(-x=>110, -y=>290, -height=>20);

# goto sur RADEC saisis ou selec de l'objet : fonction gotoRADEC
$bouton_goto=$fenetre_driver->Button(
#	-borderwidth=>"1",
	-state=>'disable',# -state=>"normal"
	-text=>"Goto",
	-highlightbackground=>"gray60",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DarkSeaGreen4",
	-command=>\&ctrl_gotoRADEC)->place(-x=>195, -y=>290, -height=>20); # controle avant goto

# bouton STOP GOTO d'urgence en cas d'erreur de goto
$bouton_stopgoto=$fenetre_driver->Button(
#	-borderwidth=>"1",
	-state=>'disable',# -state=>"normal"
	-text=>"StopGoto",
	-highlightbackground=>"gray60",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"firebrick",
	-command=>\&stopGoto)->place(-x=>285, -y=>290, -height=>20);

# liste des boutons de cde sur objet : action syncho, goto et stopGoto
@boutons_actionObjet=($bouton_synchro, $bouton_goto, $bouton_stopgoto);

############# param tracking
$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Tracking actuel :")->place(-x=>5, -y=>340);

# bouton radio pour choix tracking sideral (activé par defaut si Temma connectée)
$bRadio_choixTrackingSideral = $fenetre_driver->Radiobutton(
	-borderwidth=>"1",
	-state=>'disable',
	-highlightbackground=>"gray30",
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-selectcolor=>"tomato3",
	-width=>"10",
	-indicatoron=>"0",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	-text=>"Sidéral",
	-value=>"sid",
	-variable=>\$choix_tracking,
	-command=>\&set_tracking
	)->place(-x=>110, -y=>340, -height=>20);

# bouton radio pour choix tracking solaire
$bRadio_choixTrackingSoleil = $fenetre_driver->Radiobutton(
	-borderwidth=>"1",
	-state=>'disable',
	-highlightbackground=>"gray30",
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-selectcolor=>"tomato3",
	-indicatoron=>"0",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	-width=>"10",
	-text=>"Solaire",
	-value=>"sun",
	-variable=>\$choix_tracking,
	-command=>\&set_tracking
	)->place(-x=>285, -y=>340, -height=>20);

# bouton radio pour choix tracking vecteur (Lune, comète...)
$bRadio_choixTrackingVecteur = $fenetre_driver->Radiobutton(
	-borderwidth=>"1",
	-state=>'disable',
	-highlightbackground=>"gray30",
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-selectcolor=>"tomato3",
	-width=>"10",
	-indicatoron=>"0",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	-text=>"Vecteur",
	-value=>"vec",
	-variable=>\$choix_tracking,
	#-command=>\&clic_paramvecteur # change la couleur des textes des 2 autre BR
	-command=>\&ouvrir_calculTracking
	)->place(-x=>195, -y=>340, -height=>20);


$fenetre_driver->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Paramètres :")->place(-x=>5, -y=>370, -height=>20);

# retour de la chaine des params de tracking formatée pour la Temma (saisie non ok pour eviter erreur)
$entree_paramTracking = $fenetre_driver->Entry(
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"gray30",
	-width=>"20",
	#-textvariable=>\$saisieTracking # fait $entree_paramTracking->get
	)->place(-x=>110, -y=>370, -height=>20);

# ouvrir outil d'aide au calcul de tracking
#$fenetre_driver->Button(
	#-borderwidth=>"1",
	#-state=>'disable',# -state=>"normal"
#	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
#	-relief=>"raised",
#	-width=>"7",
#	-font=>$fonte,
#	-foreground=>"black",
#	-background=>"DeepSkyBlue4",
#	-text=>"Changer",
#	-command=>\&set_tracking
#	)->place(-x=>285, -y=>370, -height=>20);

# fonction ouvrir_cdemanu (cdes manuelles avec retours des chaines Temma brutes)
$bouton_ouvrirCdeManu = $fenetre_driver->Button(
#	-borderwidth=>"1",
	-state=>'disable',# -state=>"normal"
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"CdeManu",
	-command=>\&ouvrir_cdemanu
	)->place(-x=>110, -y=>410, -height=>20);

# fonction ouvrir_raquette
# todo : commandes de la raquettes
$bouton_raquette = $fenetre_driver->Button(
#	-borderwidth=>"1",
	#-state=>'disable', # à decommenter quand la raquette sera fonctionnelle
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"Raquette",
	-command=>\&ouvrir_raquette
	)->place(-x=>195, -y=>410, -height=>20);

# fonction polarisfinder : réticule des viseurs polaires EM-10, NJP et EM500
$bouton_polaire = $fenetre_driver->Button(
#	-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-text=>"Polaire",
	-command=>\&polarisfinder
	)->place(-x=>10, -y=>410, -height=>20);

# fermeture du driver
$bouton_quitter=$fenetre_driver->Button(
#	-borderwidth=>"2",
#	-highlightbackground=>"gray60",
	-relief=>"raised",
	-text=>"Quitter",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-command=>\&quitter	# test avec &ouvrir_cablemessagebox ou &ouvrir_cabledialogbox
	)->place(-x=>285, -y=>410, -height=>20);



#### init du driver Temma -> params site : nomsite, latitude et longitude ####
# recup des params ds fichier user_site.txt si existe sinon ouvrir fenetre de params site ou param par defaut en dur ds le script
&get_usersite;


#### init du driver Temma -> params port serie
# test 1 : existance du fichier de config du module serialport
# test 2 : existance du port serie en cas de port type USB2Serial non branché ou non reconnu
&open_serialport;


MainLoop();



# -------------------------------- ####################### -------------------------------- #
# -------------------------------- # ---- FONCTIONS ---- # -------------------------------- #
# -------------------------------- ####################### -------------------------------- #


# ------------ fonction quitter : fermeture du driver ------ QUITTER
sub quitter {
	undef $ob;
	untie *PORT;
	print "\n---------- Fermeture de driverTemma.pl ----------\n\n";
	exit;
} #----------- fin de quitter




# ---------- fonction exec_listing_pl ----------------------- editeur de listes en chantier
sub exec_listing_pl{
# todo : équiv pour windows de la fonction exec_listing_pl (forkée sous Linux)
if ($OS_win) {
	print "fonction en cours de test sous windows\n";
	eval "use Win32::Process";	# à prendre sur CPAN ou Activestate
	die "$@\n" if ($@);
	Win32::Process->Create(
	my $processchild,
	"c:\\Perl\\bin\\perl.exe",
	"perl $listing_pl",
	0,
	#DETACHED_PROCESS,
	NORMAL_PRIORITY_CLASS,
	'.',)
	#or die Win32::FormatMessage(Win32::GetLastError);
	or die "Create: $!";
}

# si le driver est lancé sous Linux
else {	#$listing_pl="./hliste_270203.pl"; # à changer le nom selon les maj
	$pid = fork();
	exec($listing_pl) if (!$pid); #or die "echec du fork_exec de $listing_pl : $!\n";
	# waitpid($pid, 0); bloque le driver tant que le fils est exec
}
} # ---------- fin de exec_listing_pl -------------------------




# ---------- fonction open_serialport -------------------------- OUVRIR RS-232
sub open_serialport{

$configFile = 'temmaRS232.cfg';		# fichier de config lu au lancement normal
print "\nInit connexion serie...\nParamètres du port ->\tdans fichier de config temmaRS232.cfg\n";

if(-e $configFile){
	print "temmaRS232.cfg\t\tpresent\n";
######## detection de l'OS pour usage du module SerialPort +fichier de config
	if ($OS_win) { 	# si Windows

	# init connexion port serie avec le module Win32::SerialPort -> test au 18/02/03 OK pour Windows XP
	$ob = Win32::SerialPort->start ($configFile) || die "pb : can't open serial port config file $configFile: $^E\n";
	
	# init connexion port serie avec le module Device::SerialPort (constructeur TIEHANDLE)	 -> non ok sous windows
	#$ob=tie(*PORT,'Device::SerialPort',$configFile)||die "pb : can't open serial port config file $configFile: $^E\n";
	}

	else { 	# si Linux
	
	# init connexion port serie avec le module Device::SerialPort (constructeur TIEHANDLE)	 -> ok
	$ob=tie(*PORT,'Device::SerialPort',$configFile)||die "pb : can't open serial port config file $configFile: $^E\n";

	# init connexion port serie avec le module Device::SerialPort	# -> ok
	#$ob = Device::SerialPort->start ($configFile) || die "pb : open serial port config file $configFile: $^E\n";
	}

# todo : dialog d'erreur sur abscence du module serialport avec possibilté d'aide à l'install du module
die "Can't open serial port $port: $^E\n" unless ($ob);

# test de validité du port serie, avec alias port serie retourné par le module serialport
&test_serialportalias;

# test si connexion Temma ok, verifie que la monture est bien connectée et sous tension
&test_getTemmaVersion;

} else	{
	print "temmaRS232.cfg\t\tnon present -> faire config du port serie\n";
	$bouton_start_temma -> configure(
				-state=>'disable',	# desactiver le bouton de connexion Temma
				-text=>"Temma Connect",
				-foreground=>"Black");
	# message d'etat connexion pour fenetre param port serie
	$msg_configport="Conseils :\nSelectionnez le port serie de la Temma\nex : COM1 pour Windows\nex : \/dev\/ttyS0 pour Linux\net cliquez sur Valider\n";
	# ouvrir fenetre param port serie
	&ouvrir_fconfigRS232;
	}

} #----------- fin de open_serialport



# ---------- fonction activer_boutonsCdeObjet ------------------
sub activer_boutonsCdeObjet{
if (defined($RA_hms_objet)&&defined($DEC_dms_objet)){
	foreach $boutons_actionObjet(@boutons_actionObjet){
	$boutons_actionObjet -> configure(-state=>'normal');}# reactiver les boutons d'actions sur Objets
	$fenetre_driver->update;
	}
} #----------- fin de activer_boutonsCdeObjet



# ---------- fonction start_temma --------------------- OUVRIR SESSION DE COMMUNICATION AVEC LA TEMMA
sub start_temma{
print "\nOuverture Session Temma sur $aliasport...\n";
print "$TU_system $lst_hms\n";

$ob->lookclear; 	# empty buffers

# fonctions lancées à la connexion de la monture pour init Temma dans que la monture est sous tension
&getTemmaVersion;	# recup version monture, info non utile pour le moment
&set_latitude;		# init latitude ds la Temma -> 1er lancement avec param COLMAR si user_site.txt abscent
&get_latitude;		# recup latitude ds la Temma
&set_temmaLST;		# init LST ds la Temma
&get_temmaLST;		# recup LST ds la Temma
&get_tracking;		# recup le mode du tracking en cours ds la Temma
&get_corspeedHemis;	# recup vitesse de corrections et hemisphere N/S ds la Temma
&get_temma_radec;	# recup RADEC et byte E/W pour position du telescope probable : $postelEW_prob


#### --- lecture permanente de RADEC en cours
# liste des widgets labels concernés pour l'affichage de : RADEC_brute, RAhms DECdms, byte E/W/F/H
#my @sorties_labels_enc = ($sortieBrutEncodeurs,$sortieFormatEncodeurs,$sortieByteEWFH);

# todo : Thread ou process indépendant pour fonction get_temma_radec

# ci-dessous fonctionnel mais applic mal temporisé sous linux et très saccadée sous windows
#@sorties_labels_enc = $fenetre_driver->repeat(500,\&get_temma_radec);# retour positions RADEC (encodeurs) timeout 500 ms

#### test pour temporiser la lecture sans retarder la mainloop
#@sorties_labels_enc=$fenetre_driver->fileevent(*PORT, 'readable',[\&boucle_get_temma_radec]);# test boucle non bloquante
$fenetre_driver->repeat(500,\&boucle_get_temma_radec);# fonction d'appel de get_temma_radec (RADEC en cours timeout 500 ms)

# liste des boutons à activer une fois le session Temma ouverte :
@boutons_action_monture=(
			#$bouton_initZenith,
			$bouton_ZView,
			$bRadio_choixTrackingSideral,
			$bRadio_choixTrackingSoleil,
			$bRadio_choixTrackingVecteur,
			$bouton_ouvrirCdeManu,
			$bouton_raquette
			);

foreach $boutons_action_monture(@boutons_action_monture){
$boutons_action_monture -> configure(-state=>'normal');}# reactiver les boutons d'actions sur monture

$bouton_start_temma -> configure(
				-state=>'disable',	# desactiver le bouton de connexion monture
				-text=>"Temma running",
				-foreground=>"Black"
				);

#$fenetre_driver->update;

# activer bouton radio d'affichage du curseur de pos courante sur XEphem/Skyview
if(Exists($fenetreFifoXephem)){ $bRadio_writefifoin -> configure(-state=>'normal');
				$fenetreFifoXephem -> update;}

# affichage état connexion ds fenetre param port serie
$msg_configport="Session Temma ouverte\nsur $aliasport\n"; # message d'etat connexion pour fenetre param port serie
if(Exists($fenetre_configRS232)){
	$text_msg_retour->insert('end', $msg_configport);# affichage info ds fenetre param port serie
	}

# activer le bouton de param du tracking
if(Exists($fenetre_ptracking)){$bouton_appliquer_tracking -> configure(-state=>'normal');}

# detection position telescope : probable OUEST
if ($infoCurPos_brut eq "W")
	{
	$postelEW_prob = "OUEST";
	print "Pos probable tube :\t$postelEW_prob\n";
	}

# detection position telescope : probable EST
if ($infoCurPos_brut eq "E")
	{
	$postelEW_prob = "EST";
	print "Pos probable tube :\t$postelEW_prob\n";
	}

$etat_sessionTemma=1; 	# etat de la connexion avec la monture
&ouvrir_EWdialogbox;	# demande la position reelle E/W du tube optique sur monture

} # ---------- fin de start_temma -----------------------------



# ---------- fonction boucle_get_temma_radec ------------------ lecture continue de RADEC
sub boucle_get_temma_radec{
# lecture de RADEC sur Temma timeout 500ms
&get_temma_radec;
$fenetre_driver->update;

} # ---------- fin de boucle_get_temma_radec ------------------



# ---------- fonction getTemmaVersion --------------------------- GET TEMMA VERSION
sub getTemmaVersion{
# get Temma version : v
$ob->write("v\r\n");
select (undef, undef, undef, 0.25);
$getTemmaVersion = $ob->input;		# lecture $getTemmaVersion
select (undef, undef, undef, 0.25);
chomp($getTemmaVersion);
print "get TemmaVersion :\t$getTemmaVersion\n";
# todo : faire qqchose avec TemmaVersion si Temma1 Jr +tracking comete/lune...
} # ---- fin de getTemmaVersion



# ---------- fonction set_temmaLST -------------------------
sub set_temmaLST{
# pour eviter le retour garbage
$ob->write("T$temma_lst\r\n");
select (undef, undef, undef, 0.25);
print("set Temma LST :\t\tT$temma_lst\n");
} #----------- fin de set_temmaLST



# ---------- fonction get_temmaLST ------------------------- GET TEMMA LST
# get LST : g
sub get_temmaLST{			#devrait s'appeller get_last_set_temmaLST
$ob->write("g\r\n");			# get Temma LST
select (undef, undef, undef, 0.25);
$get_temmaLST = $ob->input;		# lecture $get_temmaLST
#select (undef, undef, undef, 0.25);
chomp $get_temmaLST;
print("get Temma LST :\t\t$get_temmaLST\n");
} # ---- fin de get_temmaLST


# ---------- fonction get_temmaModifLST -------------------- GET TEMMA MODIF LST (MERIDIEN VIRTUEL)
# get LST : g
sub get_temmaModifLST{			#devrait s'appeller get_last_set_temmaLST
$ob->write("g\r\n");			# get Temma LST
select (undef, undef, undef, 0.25);
$get_temmaModifLST = $ob->input;	# lecture $get_temmaModifLST
#select (undef, undef, undef, 0.25);
chomp $get_temmaModifLST;
print("get Temma modif LST :\t$get_temmaModifLST\n");
} # ---- fin de get_temmaModifLST



# ---------- fonction get_corspeedHemis -------------------- GET Correction Speed and hemisph
sub get_corspeedHemis{
$ob->write("lg\r\n");
select (undef, undef, undef, 0.25);
$get_corspeedHemis = $ob->input;	# lecture get_corspeedHemis
select (undef, undef, undef, 0.25);
chomp $get_corspeedHemis;
print "CorSpeed et Hemis :\t$get_corspeedHemis\n";
} #----------- fin de get_corspeedHemis --------------------



# ---------- fonction set_correctionNS -------------------- SET Correction Speed
sub set_correctionNS{
if($valetat_para_nsradec==1)
	{
	$paraRADEC_ns_val=$RA_ns_scale->get();	# recup val de correction NS RA/DEC
	$RA_ns_val=$DEC_ns_val=$paraRADEC_ns_val;
	}

if($valetat_para_nsradec==0)
	{
	$RA_ns_val=$RA_ns_scale->get();		# recup val de correction NS RA
	$DEC_ns_val=$DEC_ns_scale->get();	# recup val de correction NS RA
	}

	print "Set CorSpeed RA :\t$RA_ns_val\n";
	print "Set CorSpeed DEC :\t$DEC_ns_val\n";

	$ob->write("LA$RA_ns_val\r\n"); 	# envoi val correction NS RA
	select (undef, undef, undef, 0.25);
	$ob->write("LB$DEC_ns_val\r\n"); 	# envoi val correction NS DEC
	select (undef, undef, undef, 0.25);
	&get_corspeedHemis;			# recup valeur Temma

# todo get_correctionNS cde : la, lb

} #----------- fin de set_correctionNS --------------------




# ---------- fonction resync_surplace : resync sur position courante si retournement manuel
# pour eviter retour de RA+12h
sub resync_surplace{

# todo si utile : 1 seule fonction synchro avec arg

# recup de RADEC en cours de pointage
$RA_resync=sprintf("%02d%02d%02d",$curLocRAh,$curLocRAm,($curLocRAs*1.666666667));

# DECdms->DEC deg mindeci (+48:05:30 -> +48055)
$DEC_resync=sprintf("%3s%02d%1d",$curLocDECd,$curLocDECm,int($curLocDECs*0.166666667));

# RADEC formatée pour Temma depuis pos RADEC en cours (format 010203+040506)
$RADEC_resync=sprintf("%06d%+06d",$RA_resync,$DEC_resync); # format pour re-synchro


#### todo ici : appel de synchro($RADEC_resync, $astre_pointe)
#--- 3) CDE SYNCHRO sur position RADEC objet en cours de pointage
print "fonction resync_surplace : resynchro sur le pointage actuel...\n";

if (defined $astre_pointe){	$astre_resync=$astre_pointe; # recup nom objet en cours pour info synchro
				print "Si retournement manuel, repointer : $astre_pointe\n";}

# protocole de synchro
# resynchro : 1-> do set LST
&set_temmaLST;				# set Temma LST
&get_temmaLST;				# ajout pour maj de la variable $get_temmaLST
print "$TU_system $lst_hms (brut Temma LST : $temma_lst)\n";

# resynchro : 2-> set Z
$ob->write("Z\r\n");			# set Zenith
select (undef, undef, undef, 0.25);	# tempo 0.25s
print "set zenith Z\n";

# resynchro : 3-> set LST again
&set_temmaLST;				# set Temma LST

# resynchro : 4->D999999+99999 (050100+48050)
$ob->write("D$RADEC_resync\r\n");	# envoi RADEC resynchro
select (undef, undef, undef, 0.25);

# retour de set location R* =(R0->ok / R1->RA error / R2->Dec error / R3->too many digits)
$temma_resync_msg = $ob->input;	# lecture $temma_resync_msg (message de valid ou d'erreur)
#select (undef, undef, undef, 0.25);
chomp $temma_resync_msg;		# pour val ="R0\r" au lieu de "R0\r\n"
print "Temma resynchro Msg:\t$temma_resync_msg\n";	# retourne R0 si ok

if ($temma_resync_msg eq "R0\r"){
	print "Resynchro sur place ok\nPosition telescope :\t$tubesideEW $temmaRAhmsDECdms\n";
	if (defined $astre_resync){
		$astre_sync=$astre_resync; # $ctrl_synchro_coords; visu astre sync et info pour redo_lastsynchro
		print "$astre_resync RADEC brute Temma : $RADEC_resync\n";
	}
}

# messages d'erreurs de resynchro
if ($temma_resync_msg eq "R1\r")
	{print "Erreur coords resynchro RA $RADEC_resync\nressaisir RA\n\n";
	$astre_sync="RA resync error";}
if ($temma_resync_msg eq "R2\r")
	{print "Erreur coords resynchro DEC $RADEC_resync\nressaisir Dec\n\n";
	$astre_sync="Dec resync error";}
if ($temma_resync_msg eq "R3\r")
	{print "Erreur coords resynchro RA/Dec $RADEC_resync\nverifier saisies RA et Dec\n\n";
	$astre_sync="RA/Dec resync error";}

} #----------- fin de resync_surplace ------------




# ---------- fonction initZenith ----------------- INIT ZENITH
# init facultative, peut servir pour un goto sur étoile jalon (si pointage zenith avec mise à niveau)
sub initZenith{
# ---- SET Z LOCATION ---- avec POS telescope à l'W par défaut (étoile jalon à l'Est)
print "\nCommande ->Init Zenith...\npos tube sur monture :\t$tubesideEW\n";
print "$TU_system $lst_hms\n";
# 1-> do set LST - info LST pour Temma
&set_temmaLST;				# set Temma LST
# 2-> Z (confirme à la Temma que le pointage du tube au zenith et ok -> Z FACULTATIF)
$ob->write("Z\r\n");	# set_posEWtelescope->PTW par defaut (telescope à l'W du zenith) ou clic/PTE si Est
select (undef, undef, undef, 0.25);
&get_temmaLST;				# ajout pour maj de la variable $get_temmaLST
$astre_pointe="Zenith";

} #----------- fin de initZenith




# ---------- fonction set_tubesideEW ---------- retournement PTE/PTW manuel du tube
sub set_tubesideEW{
# cde par les boutons radio coté Est / coté Ouest

print "\nCommande ->set pos tube : $tubesideEW (retournement manuel du telescope)\n";
&set_temmaLST;
&get_temmaLST;

print "$TU_system $lst_hms (brut Temma LST : $temma_lst)\n";
print "pos RADEC en cours\t$temmaRAhmsDECdms\n";

# protole Temma : set PTE ou PTW ->particularité ou bug ds Temma : retourne position RA+12h
$ob->write("$tubesideEW\r\n");
select (undef, undef, undef, 0.25);

&resync_surplace; # correction RA-12h et re-synchro sur l'objet en cours
#&set_bRadioEW; # configure les boutons radio PTE/PTW

} #----------- fin de set_tubesideEW ----------




# ---------- fonction inv_byteEW --------------
sub inv_byteEW{
# pour faire un retournement du tube au (re)lancement du driver
# cde depuis EWdialogbox (fonction ouvrir_EWdialogbox)
if($infoCurPos_brut eq "E"){$inv_byteEW = "PTW";} # donne W
if($infoCurPos_brut eq "W"){$inv_byteEW = "PTE";} # donne E

# protole Temma : set PTE ou PTW ->particularité ou bug ds Temma : retourne position RA+12h
$ob->write("$inv_byteEW\r\n");
select (undef, undef, undef, 0.25);

print "Inversion byte EW d'après commande $inv_byteEW\n";
&resync_surplace; # correction RA-12h et re-synchro sur l'objet en cours
#&set_bRadioEW; # configure les boutons radio PTE/PTW inutile
} #----------- fin de inv_byteEW --------------




# ---------- fonction set_bRadioEW ----------- configurer les boutons radio PTE/PTW selon E/W [->obsolete]
sub set_bRadioEW{

# init de variable pour fonction initZ $do_initZ : si choix oui/non de initZ au demarrage
#$do_initZ = &initZenith;

# empecher 2 clics sur le même bouton radio sinon bug E/E ou W/W au lieu de W/E ou E/W
if($tubesideEW eq "PTW")
	{
	# si pos OUEST télescope cliquée (ou par defaut au demarrage)
	$bRadio_PosTel_Ouest->configure(-state=>'disable'); 	# desactive bouton radio coté Ouest
	$bRadio_PosTel_Est->configure(-state=>'normal');	# reactive bouton radio coté Est
	}

if($tubesideEW eq "PTE")
	{
	# si pos EST télescope cliquée
	$bRadio_PosTel_Est->configure(-state=>'disable');	# desactive bouton radio coté Est
	$bRadio_PosTel_Ouest->configure(-state=>'normal');	# reactive bouton radio coté Ouest
	}

} #----------- fin de set_bRadioEW -----------




# ---------- fonction ouvrir_EWdialogbox -------- DIALOG pos reelle E/W du tube sur monture
sub ouvrir_EWdialogbox{
$EW_dialogbox=$fenetre_driver->DialogBox(
					-title=>"Position tube sur monture",
					-buttons=>["EST", "OUEST"],
					-default_button=>"$postelEW_prob");

$EW_dialogbox->add("Label",
-text=>"Coordonnées en cours : $temmaRAhmsDECdms\nPosition probable du tube coté : $postelEW_prob\n
infos :\n- pos OUEST par défaut à la mise sous tension\nou\n- dernière pos supposée si relance du driver\n
- attention au trepied\nconfirmez la position du tube svp\n"
)->pack;


# checkbutton si init zenith au demarrage (facultatif)
$valetat_initz=0;	# pas d'init zenith par defaut
$EW_dialogbox->add("Checkbutton",
	-borderwidth=>"1",
	-highlightbackground=>"gray30",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	#-foreground=>"DarkSeaGreen4",
	#-indicatoron=>"0",
	#-background=>"Black",
	#-selectcolor=>"tomato3",
	#-width=>"14",
	-text=>"Init Zenith",
	-variable=>\$valetat_initz,
)->pack;


my $userchoice=$EW_dialogbox->Show();

# conditions pour garder la coherence entre : la position du tube/monture PTE/PTW et byte E/W
# si PTE/E ou PTW/W coherence ok
# sinon on force pour la coherence en demandant de positionner le tube correctement

if (($userchoice eq "EST") && ($infoCurPos_brut eq "W"))
	{
	# si choix utilisateur position tube/monture EST avec byte W : forçage set byte E
	print "Confirmation pos tube :\tEST avec set byte E\n";
	print "Verifier le positionnement EST du tube sur la monture\n";
	$tubesideEW ="PTE";
	$bRadio_PosTel_Est->configure(-state=>'disable');	# desactive bouton radio coté Est
	$bRadio_PosTel_Ouest->configure(-state=>'normal');	# reactive bouton radio coté Ouest
	&inv_byteEW; # signale à la Temma la vrai position EST avec byte E à l'init
	}

if (($userchoice eq "EST") && ($infoCurPos_brut eq "E"))
	{
	# si choix utilisateur position tube/monture EST
	print "Confirmation pos tube :\tEST d'apres detection byte E\n";
	$tubesideEW ="PTE";
	$bRadio_PosTel_Est->configure(-state=>'disable');	# desactive bouton radio coté Est
	$bRadio_PosTel_Ouest->configure(-state=>'normal');	# reactive bouton radio coté Ouest
	}

if (($userchoice eq "OUEST") && ($infoCurPos_brut eq "E"))
	{
	# si choix utilisateur position tube/monture OUEST avec byte E : forçage set byte W
	print "Confirmation pos tube :\tOUEST avec set byte W\n";
	print "Verifier le positionnement OUEST du tube sur la monture\n";
	$tubesideEW ="PTW";
	$bRadio_PosTel_Ouest->configure(-state=>'disable'); 	# desactive bouton radio coté Ouest
	$bRadio_PosTel_Est->configure(-state=>'normal');	# reactive bouton radio coté Est
	&inv_byteEW; # signale à la Temma la vrai position EST avec byte E à l'init
	}


if (($userchoice eq "OUEST") && ($infoCurPos_brut eq "W"))
	{
	# si choix utilisateur position tube/monture OUEST (par defaut au demarrage)
	print "Confirmation pos tube :\tOUEST d'apres detection byte W (par defaut)\n";
	$tubesideEW ="PTW";
	$bRadio_PosTel_Ouest->configure(-state=>'disable'); 	# desactive bouton radio coté Ouest
	$bRadio_PosTel_Est->configure(-state=>'normal');	# reactive bouton radio coté Est
	}


# init zenith au demarrage oui/non
if($valetat_initz==1){	print "Choix init Zenith :\toui\n";
			&initZenith;
			}

if($valetat_initz==0){	print "Choix init Zenith :\tnon\n";
			}


&get_temma_radec;
print "Session Temma ouverte\n";
print "Coords en cours :\t$temmaRAhmsDECdms\n"; # retour console position RADEC au demarrage (ou au redemarrage)

# todo aide utilisateur si RADEC = 0:0:0 ->1er demarrage après monture sur OFF ou redemarrage
# todo verif existance de variable etoile de sync pour connaitre param de session temma
# enregister params de session ds un fichier "sessiontemma$date.txt"

} # ---- fin de ouvrir_EWdialogbox ------------------------




# todo : finir et utiliser fonction ci-dessous
# ---------- fonction save_param_session ------------------ sauvegarde params session dans session.cfg
sub save_param_session{
print "Sauvegarde fichier session.cfg\n";

# $last_synchro
#$astre_sync;		# memorisation nom astre sync
#$RA_hms_objet_sync;	# memorisation RA sync
#$DEC_dms_objet_sync;	# memorisation DEC sync

if(defined($tubesideEW) or defined($last_synchro) or defined($last_goto))
	{
	%params_session=(
	"positiontube"	=>"$tubesideEW", # utile ?
	"last_sync"	=>"$last_synchro",
	"last_goto"	=>"$last_goto",);

# todo : à universaliser
open(SESSION,">./session.cfg") or warn "PB open/write session.cfg :$!\n"; # todo : à universaliser

# écriture ds fichier user_site.txt
print (SESSION "\# si vous editez ce fichier, gardez la syntaxe ci-dessous :\n\# param =\tvaleur\n\n");
print (SESSION "positiontube =\t$params_session{positiontube}\n");
print (SESSION "last_sync =\t$params_session{last_sync}\n");
print (SESSION "last_goto =\t$params_session{last_goto}\n");


#print SESSION "positiontube = $tubesideEW\n";
close (SESSION) or warn "PB close session.cfg :$!\n";

}# fin de if defined

}#----------- fin de save_param_session



# todo : finir et utiliser fonction ci-dessous
# ---------- fonction get_param_session ------------------- recup params session dans session.cfg
sub get_param_session{
print "Ouvre fichier session.cfg\n";
#open(SESSION,"<./session.cfg") or warn "PB open/read session.cfg :$!\n"; # todo : à universaliser
#$tubesideEW=<SESSION>;
#close (SESSION) or warn "PB close session.cfg :$!\n";
#chomp $tubesideEW;
#print "Derniere position tube :\t\t$tubesideEW\n";

# vérifie l'existance du fichier sinon param position OUEST par defaut
if(-e "./session.cfg"){
%params_session=();
open(SESSION,"<./session.cfg") or warn "PB open/read session.cfg :$!\n"; # todo : à universaliser
while(<SESSION>){
	chomp;		# sup retour ligne
	s/#.*//;	# sup comment
	s/^\s+//;	# sup espace debut
	s/\s+$//;	# sup espaces fin
	next unless length;# s'il reste qqch
	my ($var, $valeur)=split (/\s*=\s*/,$_,2);
	$params_session{$var}=$valeur;
	}
close (SESSION) or warn "PB close session.cfg :$!\n";

$tubesideEW=$params_session{positiontube};
$last_sync=$params_session{last_sync};
$last_goto=$params_session{last_goto};

# retour console params du fichier
print "Params session\n";
print "session.cfg\t\tpresent\n";
print "Position tube :\t\t$params_session{positiontube}\n";
print "latitude :\t\t$params_session{last_sync}\n";
print "longitude :\t\t$params_session{last_goto}\n";
}# fin de if existe session.cfg

else{print "fichier session.cfg abscent, params position tube OUEST par defaut\n"}

}#----------- fin de get_param_session





# ---------- fonction setsynchro --------------------- SYNCHRO etoile jalon
sub setsynchro{
# SET STAR LOCATION en 4 etapes avec postelescope à l'W et pointage sur étoile jalon à l'Est
$astre_pointe="";
$astre_sync="";
print "\nCommande ->synchro...\npos tube reelle :\t$tubesideEW\n";

# 1-> do set LST
&set_temmaLST;				# set Temma LST
&get_temmaLST;				# ajout pour maj de la variable $get_temmaLST
print "$TU_system $lst_hms (brut Temma LST : $temma_lst)\n";

# retour console des dernières coords de synchro sur étoile
#$nom_objet;
$ctrl_synchro_coords=sprintf("RA %8s Dec %9s", $RA_hms_objet,$DEC_dms_objet);
print "set synchro sur :\t$nom_objet $ctrl_synchro_coords\n";

# formatage coords pour Temma
$RA_synchroTemma=sprintf("%02d%02d%02d",$RA_h,$RA_m,($RA_s*1.666666667));
# DECdms->DEC deg mindeci (+48:05:30 -> +48055)
$DEC_synchroTemma=sprintf("%3s%02d%1d",$DEC_d,$DEC_m,int($DEC_s*0.166666667));# $DEC_d = %3s pour signer -0

# envoi coords vers Temma depuis saisie ou XEphem (format 010203+040506)
#$RADEC_sync=sprintf("%02d%02d%02d%+06d",$RA_h,$RA_m,($RA_s*1.666666667),$DEC_synchroTemma);# ok pour -0:00:20
$RADEC_sync=sprintf("%06d%+06d",$RA_synchroTemma,$DEC_synchroTemma); # format pour synchro Temma

# 2-> set Z
$ob->write("Z\r\n");			# set Zenith
select (undef, undef, undef, 0.25);	# tempo 0.25s
print "set zenith Z\n";

# 3-> set LST again
&set_temmaLST;				# set Temma LST

# 4->D999999+99999 (050100+48050)
$ob->write("D$RADEC_sync\r\n");	# envoi de RADEC synchro
#$ob->write("D$RA_synchroTemma$DEC_synchroTemma\r\n");	# envoi de RADEC synchro
select (undef, undef, undef, 0.25);

# retour de set location R* =(R0->ok / R1->RA error / R2->Dec error / R3->too many digits)
$repTemmaSetLocationMsg = $ob->input;	# lecture $repTemmaSetLocationMsg (message de valid ou d'erreur)
#select (undef, undef, undef, 0.25);
chomp $repTemmaSetLocationMsg;		# pour val ="R0\r" au lieu de "R0\r\n"
print "Temma synchro Msg:\t$repTemmaSetLocationMsg\n";	# retourne R0 si ok

if ($repTemmaSetLocationMsg eq "R0\r")
	{print "synchro:\t\tok\n";
	$fenetre_driver->bind('<Control-s>'=>\&redo_lastsynchro);# acces possible à fonction redo_lastsynchro

	$RA_hms_objet_sync =$RA_hms_objet;	# memorisation RA sync pour redo_lastsynchro
	$DEC_dms_objet_sync=$DEC_dms_objet;	# memorisation DEC sync pour redo_lastsynchro

	if (defined $nom_objet){
		$astre_sync=$nom_objet;	# $ctrl_synchro_coords; visu driver astre sync et info pour redo_lastsynchro
		$astre_pointe=$astre_sync;
		print "synchro ok sur :\t$astre_sync $ctrl_synchro_coords (brute Temma : $RADEC_sync)\n";
	}
}

# messages d'erreurs de synchro
if ($repTemmaSetLocationMsg eq "R1\r")
	{print "Erreur coords synchro RA $RADEC_sync\nressaisir RA\n\n";
	$astre_sync="RA sync error";}
if ($repTemmaSetLocationMsg eq "R2\r")
	{print "Erreur coords synchro DEC $RADEC_sync\nressaisir Dec\n\n";
	$astre_sync="Dec sync error";}
if ($repTemmaSetLocationMsg eq "R3\r")
	{print "Erreur coords synchro RA/Dec $RADEC_sync\nverifier saisies RA et Dec\n\n";
	$astre_sync="RA/Dec sync error";}

} # ---- fin de setsynchro



# ---------- fonction redo_lastsynchro --------------- REDO LAST SYNCHRO <Control-s> (<Control-z> dans TT2000)
# equiv à undoPosition de TT2000 revient à la derniere synchro sur Temma (repointer manuellement le télescope)
sub redo_lastsynchro{
# retour sur RADEC sync memorisée et retour console des dernières coords de synchro sur étoile
$astre_pointe="";
# $astre_sync="";
$nom_objet = $astre_sync;		# retour sur memorisation nom astre sync
$RA_hms_objet =	$RA_hms_objet_sync;	# retour sur memorisation RA sync
$DEC_dms_objet= $DEC_dms_objet_sync;	# retour sur memorisation DEC sync
print "redo_lastsynchro sur $astre_sync RA: $RA_hms_objet DEC: $DEC_dms_objet\n";
print "repointez manuellement et resynchronisez cet objet selon PTW ou PTE\n";

&get_saisie_radec; # objet de last_synchro pret à recevoir commande synchro ou goto
} # ---- fin de redo_lastsynchro ---------------------




# ---------- fonction calcLST ----------------------------------- calcul LST
sub calcLST{

# ---- variables temps pour TU_system et lst
# $sec,$min,$heure,$mjour,$mois,$annee,$sjour,$ajour,$est_dst)=gmtime();
# 0    1    2	   3	  4	5      6      7	     8

($gm_jour, $gm_mois, $gm_annee)=(gmtime)[3,4,5];
#printf ("date system :\t%02d/%02d/%02d\n",$gm_jour, $gm_mois+1, $gm_annee+1900); # control date

$jour = $gm_jour;
$mois = $gm_mois + 1;
$annee = $gm_annee + 1900;

($gmheure,$gmmin,$gmsec)=(gmtime)[2,1,0];	# gmtime recup TU system

# retour TU long : date @ hms
$TU_system=sprintf("TU %02d/%02d/%02d @ %02d:%02d:%02d",$jour,$mois,($annee%100),$gmheure,$gmmin,$gmsec);
# retour TU court : hms
#$TU_system_hms=sprintf("TU %02d:%02d:%02d",$gmheure,$gmmin,$gmsec);

$delta_TUh = ($longi_deci * 4)/60;		# delta TU heures decimal
#print "delta TU h:\tTU+ $delta_TUh h\n";

$TU_deci = $gmheure +(($gmmin + ($gmsec/60))/60);# TU heure deci
#print "TUh deci :\t$TU_deci h\n";

#$TU_loc_deci = $TU_deci + $delta_TUh;		# TU local heure deci non utile
#print "TU loc deci :\t$TU_loc_deci h\n";

# ---- JD selon Jean Meeus
$jour_deci = $jour + ($TU_deci /24);		# j.h (valeur deci) remplace $TU_deci $TU_loc_deci
#print "jour deci :\t$jour_deci\n";
##$annee_cor = $annee;
##$mois_cor = $mois;
if($mois > 2){$annee_cor = $annee; $mois_cor = $mois;}
if($mois < 3){$annee_cor = $annee -1; $mois_cor = $mois + 12;}
$A=int($annee_cor * 0.01);
$B=2-$A+int($A*0.25);
$JD=int(365.25*($annee_cor+4716))+int(30.6001*($mois_cor+1))+$jour_deci+$B-1524.5;
#print "gmJD :\t\t$JD \n"; # sortie brut jmJD
#printf("gm JD :\t\t%.5f\n",$JD);# sortie formattée avec 5 chiffres derriere la virgule

# ---- lst Greenwich
$glst_deci=($JD-2451545)/36525;
#print "glst deci:\t$glst_deci\n";

# ---- conversion en glst_deg deci Greenwich selon Jean Meeus
$glst_deg=280.46061837+360.98564736629*($JD-2451545)
 +0.000387933*($glst_deci*$glst_deci)
 -(($glst_deci*$glst_deci*$glst_deci)/38710000);
#print "glst deg:\t$glst_deg\n";	# control $glst_deg

$lst_horaire=$glst_deg/15-$delta_TUh;	# conversion glst_deg ->$lst_horaire
#print "lst horaire:\t$lst_horaire\n";	# control lst horaire local brut
$lst_decih=($lst_horaire/24-(int($lst_horaire/24)))*24;	# conversion en multiple de 24h
#print "lst h deci:\t$lst_decih\n";

if($lst_decih>=24) {$lst_corhdeci=$lst_decih-24;} 	# correction pour interval 0h-23h
else {$lst_corhdeci=$lst_decih;}
#print "lst corhdeci:\t$lst_corhdeci\n";		# retour pour infos

$lst_h=int($lst_corhdeci);				# conversion lst décimal ->hms
$lst_m=int(($lst_corhdeci-$lst_h)*60);
$lst_s=int(((($lst_corhdeci-$lst_h)*60)-$lst_m)*60);

### sorties LST
#printf ("LST hms :\t%02d:%02d:%02d\n",$lst_h,$lst_m,$lst_s);	# sortie formatée pour interface LST hh:mm:ss
$lst_hms=sprintf("TSL %02u:%02u:%02u",$lst_h,$lst_m,$lst_s);	# recup pour affichage TSL->Tk
#$lst_hms_lcd=sprintf("%02u %02u %02u",$lst_h,$lst_m,$lst_s);	# recup pour affichage TSL->Tk::LCD
$temma_lst = sprintf("%02u%02u%02u", $lst_h,$lst_m,$lst_s);	# sortie formatée pour Temma set_LST
# print "temma_lst : $temma_lst $lst_hms\n";


### calcul de LST modifié pour goto sous controle du driver (pour meridien virtuel de base au goto)
# todo : réglage de $moins_val et $plus_val selon hauteur au sol du porte oculaire (verrou long de tube)
# todo : provoquer un retournement auto avec retour sur pointage courant en cas d'approche critique du trépied
# todo : placement sur zview les meridiens modifiés selon valeur de $decal_lstmerid
# todo : utiliser $temma_lst_modif et $decal_lstmerid


if ($decal_lstmerid==1){ # defaut pour les tubes longs
# condition ci-dessous ok avec decallage en dur +/-1h sur position meridien (AH=1h ou AH=23)

	if($lst_h==0){	$temma_lst_moins_val=sprintf("%02u%02u%02u", ($lst_h+23),$lst_m,$lst_s); # limite +22
			$AH_meridien_modif=1;
			}

	else		{$temma_lst_moins_val=sprintf("%02u%02u%02u", ($lst_h-1),$lst_m,$lst_s);  # limite -2
			$AH_meridien_modif=23;
			}

	if ($lst_h==23){$temma_lst_plus_val=sprintf("%02u%02u%02u", ($lst_h-23),$lst_m,$lst_s);  # limite -22
			$AH_meridien_modif=1;
			}

	else		{$temma_lst_plus_val=sprintf("%02u%02u%02u", ($lst_h+1),$lst_m,$lst_s);   # limite +2
			$AH_meridien_modif=23;
			}
}

# ajout au 08/06/03
elsif ($decal_lstmerid==2){ # si tube court on va plus loin du méridien pour les goto
# condition ci-dessous ok avec decallage en dur +/-2h sur position meridien (AH=2h ou AH=22)

	if($lst_h<=1){	$temma_lst_moins_val=sprintf("%02u%02u%02u", ($lst_h+22),$lst_m,$lst_s); # limite +22
			$AH_meridien_modif=2;
			}

	else		{$temma_lst_moins_val=sprintf("%02u%02u%02u", ($lst_h-2),$lst_m,$lst_s);  # limite -2
			$AH_meridien_modif=22;
			}

	if ($lst_h==22){$temma_lst_plus_val=sprintf("%02u%02u%02u", ($lst_h-22),$lst_m,$lst_s);  # limite -22
			$AH_meridien_modif=2;
			}

	else		{$temma_lst_plus_val=sprintf("%02u%02u%02u", ($lst_h+2),$lst_m,$lst_s);   # limite +2
			$AH_meridien_modif=22;
			}
}


&calcpospolaire; # pour incrémenter la position d'angle horaire de l'étoile polaire

} # ---- fin de calcLST




# ---------- fonction calcpospolaire : calcul de position étoile polaire pour polarisfinder
sub calcpospolaire{
$adpolaire=(0.01875*$annee)-34.9574;		# calcul AD polaire selon année en heure décimale
$adpolh=int($adpolaire);			# conversion AD polaire en heures+minutes selon année
$adpolmin=int(($adpolaire-$adpolh)*60);
$adpolmsec=int(((($adpolaire-$adpolh)*60)-$adpolmin)*60);
#$adpolaire_hms=sprintf("%02d:%02d:%02d",$adpolh,$adpolmin,$adpolmsec);

$angle=$lst_horaire-$adpolaire;#+0.5/60;		# angle position polaire >>>>> controler ici <<<<<
$angle_modulo=($angle/24-(int($angle/24)))*24;

$angle_heure=int($angle_modulo);		# conversion angle_modulo décimal en hms
$angle_min=int(($angle_modulo-$angle_heure)*60);
$angle_sec=int(((($angle_modulo-$angle_heure)*60)-$angle_min)*60);
$angle_hms_polaire=sprintf("%02u:%02u:%02u",$angle_heure,$angle_min,$angle_sec);# angle horaire polaire
#$angle_hms_polaire="$angle_heure:$angle_min:$angle_sec";# angle horaire polaire
#print "$angle_hms_polaire\n"; # verif

#### mise en place des coordonnées x,y polaire pour canvas ####
# pi=3.1415926535 ;  pi/12=0.26180;  pi/180=0.017453293
# calcul du rayon position polaire en fonction de la précession (rayon réticule 1985=220)
$rayon=220-($annee-1985)/30*36;
$x_polaire=int(286+($rayon*(sin(0.26180*$angle_modulo)))); 	# $rayon centre xy : 286,245
$y_polaire=int(245+($rayon*(cos(0.26180*$angle_modulo))));	# $rayon centre xy : 286,245
### fin de calculs rayon,x,y pour canvas ###

} # ---- fin de calcpospolaire


###################
### fonctions : polarisfinder, positionpolaire dans fichier : polarisfinder.pm
###################




# ---------- fonction get_temma_radec --------- LECTURE DE POSITION RADEC EN COURS (CONTINUE pendant temma_session)
sub get_temma_radec{
# protocole de recup RADEC en cours
# ---- GET CURRENT LOCATION : E ----		LECTURE RADEC EN COURS SUR ENCODEURS
$ob->write("E\r\n");				# get Temma current location
select (undef, undef, undef, 0.25);
$repTemmaGetCurLocation = $ob->input;		# $repTemmaGetCurLocation = coords brutes
#select (undef, undef, undef, 0.25);
chomp $repTemmaGetCurLocation;
#read(PORT,$repTemmaGetCurLocation,16,0) or die "$!";
#select (undef, undef, undef, 0.25);
#print "getcurloc :\t$repTemmaGetCurLocation\n";# retour console pour infos
#	E 0 7 5 6 1 1	+4 1 5 5 0 W H \r\n
#	1,6		7,6		  17

$temmaRADECbrut=substr($repTemmaGetCurLocation,1,12);		# ajout au 03/11/02 pour gotoauto
$curLoc_RA_hms_brut = substr($repTemmaGetCurLocation,1,6); 	# recup RA hms brut depuis string brut
$curLoc_DEC_dm_brut = substr($repTemmaGetCurLocation,7,6); 	# recup DEC dm_deci brut signée depuis string brut
$infoCurPos_brut = substr($repTemmaGetCurLocation,13,1); 	# recup byte E/W (/F H) depuis string brut
# todo : recup byte F H en fin de string brut

# traitement sortie RA hms brut : 005950 DEC dm brut : -01555 (coords brut de get_temma_radec (getcurloc))
$curLocRAh=substr($curLoc_RA_hms_brut,0,2);			# formatage RA h (RA hms.s)
$curLocRAm=substr($curLoc_RA_hms_brut,2,2);			# formatage RA m
$curLocRAs=(substr($curLoc_RA_hms_brut,4,2))*0.6;		# formatage RA s deci ds interval 0.1 - 59.9

$curLocDECd = substr($curLoc_DEC_dm_brut,0,3);			# DEC d signé
$curLocDECm = substr($curLoc_DEC_dm_brut,3,2);			# DEC m
$curLocDECs = (substr($curLoc_DEC_dm_brut,5,1))*6;		# DEC s decimale

# RADEC en cours formatée pour affichage ds fenetre principale
$temmaRAhmsDECdms=sprintf("RA %02d:%02d:%02.1f Dec %3s:%02d:%02d",$curLocRAh,$curLocRAm,$curLocRAs,$curLocDECd,$curLocDECm,$curLocDECs);

# conversion position en cours RA/DEC en heures decimales
$RA_heures_deci = $curLocRAh +($curLocRAm/60) + ($curLocRAs/3600);
$DEC_degres_deci_ns=abs($curLocDECd)+(abs($curLocDECm/60))+(abs($curLocDECs/3600));# DEC deg deci non signée

$temmaDEC_concat=sprintf("%3s%02d%02d",$curLocDECd,$curLocDECm,$curLocDECs);# garde le signe dec
if($temmaDEC_concat<0){$DEC_degres_deci=$DEC_degres_deci_ns*(-1);}	# DEC deg decimal de signe -
if($temmaDEC_concat>0){$DEC_degres_deci=$DEC_degres_deci_ns;}		# DEC deg decimal de signe +
if($temmaDEC_concat==0){$DEC_degres_deci=0;}				# DEC deg decimal 0

# pour l'envoi au fifo XEphem : xephem_in_fifo
# conversion en radian de la position courante
$curposRA_rad = ($RA_heures_deci * 3.141592654)/12;
$curposDEC_rad = ($DEC_degres_deci * 3.141592654)/180;

# sortie formatée pour xephem -> curseur du pointage en cours sur la SkyView
$RaDec_to_xephem=sprintf("RA: %9.6f Dec: %9.6f Epoch:2000.000\n",$curposRA_rad,$curposDEC_rad);
#RA:%9.6f Dec:%9.6f Epoch:2000.000\n ->source lx200xed


########################################################
# --- opérations diverses pendant la boucle continue ---
########################################################

# --- VISU DU RETOURNEMENT AUTOMATIQUE DU TELESCOPE PENDANT UN GOTO : lecture du byte E/W
# empecher un clique double sur le même bouton radio de positionnement sinon bug E/E ou W/W au lieu de W/E ou E/W
# recupérer (ou envoyer) la position du télescope vue par la monture, valeur de PT en cours : W ou E
if(($infoCurPos_brut eq "W")&&($tubesideEW eq "PTE"))		# W renvoyé par la Temma par defaut au demarrage
	{
	$tubesideEW = "PTW";					# valeur PTW pour signaler la pos OUEST du telescope
	$bRadio_PosTel_Ouest->configure(-state=>'disable'); 	# desactive bouton radio coté Ouest
	$bRadio_PosTel_Est->configure(-state=>'normal');	# reactive bouton radio coté Est
	}

elsif(($infoCurPos_brut eq "E")&&($tubesideEW eq "PTW"))	# E renvoyé par la Temma si pos EST télescope cliquée
	{
	$tubesideEW = "PTE";					# valeur PTE pour signaler la pos EST telescope
	$bRadio_PosTel_Est->configure(-state=>'disable');	# desactive bouton radio coté Est
	$bRadio_PosTel_Ouest->configure(-state=>'normal');	# reactive bouton radio coté Ouest
	}

# --- DETECTION DE GOTO OBJET TERMINE
# lecture du byte F retourné par la Temma après un goto ok vers un objet
elsif($infoCurPos_brut eq "F")
	{
	#$tag_gotocible = 1;
	$byte_F=sprintf("%s",$infoCurPos_brut);
	push (@list_byteF_goto_end, $byte_F);	# liste de F retournés (remis à 0 ds goto_radec et gotodriver_radec)
	$nb_byteF=@list_byteF_goto_end;		# nb de F retournés (remis à 0 ds goto_radec et gotodriver_radec)
	if (($nb_byteF>=3) && ($nb_byteF<=8)){	### controler si ok avec win
		print "@list_byteF_goto_end\n"; # retour console pour infos
		$astre_pointe=$nom_objet; 	# visu fenetre principale objet pointé quand le goto terminé

		# memo objet pointé avec goto
		#$goto_objet = "$nom_objet $RA_hms_objet $DEC_dms_objet $TU_system $lst_hms"; # old val
		$goto_objet = "$nom_objet $ctrl_goto_coords $TU_system $lst_hms";
		# $ctrl_goto_coords
		print "Goto ok :\t\t$goto_objet\n";	# retour console pour infos
		&stateGoto;		# controle etat goto
		&ajout_historic;	# memoriser les objets pointés dans fichier historic.txt
	}
		# liste des gotos effectués
		#push (@historic_goto_objet, $goto_objet);
		#print "@historic_goto_objet";
	}

# --- DETECTION DES RAPPROCHEMENTS TUBE/TREPIED
# if (){

# --- LIAISON XEPHEM
# pour l'envoi au fifo XEphem : xephem_in_fifo -> curseur du pointage en cours sur la carte
#$temmaDEC_concat=sprintf("%3s%02d%02d",$curLocDECd,$curLocDECm,$curLocDECs);# garde le signe dec
#&conv2radRaDec;

&curpos_zview;# position courante affichée ds mini carte zview ajout 16/03/03

} # ---- fin de get_temma_radec




# ---------- fonction ajout_historic ------------------- historic.txt->append
sub ajout_historic{
#print "transfert de l'objet dans historic.txt\n";
open(HISTORIC,">>./historic.txt") or warn "PB open historic.txt :$!\n"; # todo : à universaliser
#print HISTORIC "$goto_objet\n";

# sortie formatée
write (HISTORIC);
format HISTORIC =
@<<<<<<<<<<<<<<<<<<<<<|RA @<<<<<<<<<|DEC @<<<<<<<<<<|@<<<<<<<<<<<<<<<<<<<<<
$TU_system,	       $RA_hms_sf,   $DEC_dms_sf,    $nom_objet
.

close (HISTORIC) or warn "PB close historic.txt :$!\n";
}#----------- fin de ajout_historic -------------------




# ---------- fonction conv2radRaDec : conversion RADEC courante en radian pour envoi dans fifo_in de XEphem
sub conv2radRaDec{
# --- conversions RA/DEC en valeurs radian decimales pour xephem

#### deplace ds boucle lecture radec
# 1 conversion RA et DEC en heures decimales
#$RA_heures_deci = $curLocRAh +($curLocRAm/60) + ($curLocRAs/3600);
#$DEC_degres_deci_ns=abs($curLocDECd)+(abs($curLocDECm/60))+(abs($curLocDECs/3600));# Decdeg deci non signée

#if($temmaDEC_concat<0){$DEC_degres_deci=$DEC_degres_deci_ns*(-1);}	# si Dec de signe -
#if($temmaDEC_concat>0){$DEC_degres_deci=$DEC_degres_deci_ns;}		# si Dec de signe +
#if($temmaDEC_concat==0){$DEC_degres_deci=0;}				# si Dec = 0:0:0

# 2 conversion en radian
$curposRA_rad = ($RA_heures_deci * 3.141592654)/12;
$curposDEC_rad = ($DEC_degres_deci * 3.141592654)/180;

# resultat sortie formatée pour xephem
#$RaDec_to_xephem=sprintf("RA: %9.6f Dec: %9.6f Epoch:2000.000",$curposRA_rad,$curposDEC_rad);
$RaDec_to_xephem=sprintf("RA: %9.6f Dec: %9.6f Epoch:2000.000\n",$curposRA_rad,$curposDEC_rad);
#RA:%9.6f Dec:%9.6f Epoch:2000.000\n ->source lx200xed
}#----------- fin de conv2radRaDec




# ---------- fonction curpos_zview -------------------- PLACEMENT DU RETICULE DE POSITION EN COURS SUR ZVIEW
sub curpos_zview{
# pour position courante RA sur ZView (d'après l'angle horaire de RA en cours)
$angleH=$lst_horaire-$RA_heures_deci;#+0.5/60;
$angleH_modulo=($angleH/24-(int($angleH/24)))*24;

# pour position courante DEC sur ZView
$posDECzview=(90-$DEC_degres_deci)*(180/90);				# repere coords equatoriale
$x_curpos=int(246+($posDECzview*(sin(0.26180*$angleH_modulo)))); 	# $rayon centre xy : 246,215
$y_curpos=int(215+($posDECzview*(cos(0.26180*$angleH_modulo))));	# $rayon centre xy : 246,215

# todo : use $lati_degdeci pour placer la ligne d'horizon selon latitude

} # ------- fin de curpos_zview -----------------------




# ---------- fonction get_saisie_radec ---------------- GET SAISIE RADEC
# recup nom/RA/DEC de l'objet depuis saisie manuelle ou listes ou XEphem avant commande sur objet
sub get_saisie_radec{
$RA_hms_objet = $entreeRA_astre->get();		# recup champ RA objet
$DEC_dms_objet= $entreeDEC_astre->get();	# recup champ DEC objet
$nom_objet=$entreeNOM_astre->get();		# recup champ nom objet
#print("SelecObj manu :\t\t$nom_objet RA $RA_hms_objet Dec $DEC_dms_objet\n");# retour console

###### todo : controler la validité des saisies et ouvrir boite de dialogue d'aide si erreur
# split pour RA h:m:s et DEC d:m:s
($RA_h, $RA_m, $RA_s)	 = (split (/:/ , $RA_hms_objet));
($DEC_d, $DEC_m, $DEC_s) = (split (/:/ , $DEC_dms_objet));


$RA_hms_objet =sprintf("%02d:%02d:%02.1f",$RA_h,$RA_m,$RA_s);
#if ($DEC_d =~/^-0/)
# if (/^-/)
$DEC_dms_objet=sprintf("%+3s:%02d:%02d",$DEC_d, $DEC_m, $DEC_s);


########## en cours de test au 11/05/03 ###
# formatage propre de RADEC pour historic.txt
#
$RA_hms_sf = sprintf("%02d:%02d:%02.1f",$RA_h,$RA_m,$RA_s);
$DEC_dms_sf= sprintf("%+3s:%02d:%02d",$DEC_d,$DEC_m,$DEC_s);
#
print("get objet :\t\t$nom_objet RA $RA_hms_objet Dec $DEC_dms_objet\n");# retour console
#$goto_radec=sprintf("%02d%02d%02d",$RA_h,$RA_m,$RA_s);
##########


# conversion RA en heure decimale pour synchro, ctrl_gotoRADEC et pos_sur_zview
$RA_h_deci = $RA_h +($RA_m/60) + ($RA_s/3600); # approx 0.6s

# conversion DEC en deg decimale pour ctrl_gotoRADEC et pos_sur_zview
$DEC_d_deci_ns=abs($DEC_d)+abs($DEC_m/60)+abs($DEC_s/3600);	# non signée

$saisieDEC_concat=sprintf("%3s%02d%02d",$DEC_d, $DEC_m, $DEC_s);# garde le signe dec
if($saisieDEC_concat<0){$DEC_d_deci=$DEC_d_deci_ns*(-1);}	# DEC deg decimal de signe -
if($saisieDEC_concat>0){$DEC_d_deci=$DEC_d_deci_ns;}		# DEC deg decimal de signe +
if($saisieDEC_concat==0){$DEC_d_deci=0;}			# DEC deg decimal 0


#if(($DEC_d<0)or($DEC_d eq "-0")or($DEC_d eq " -0")or($DEC_d eq "  -0"))
#	{$DEC_d_deci=$DEC_d_deci_ns*(-1);}	# DEC deg deci signe -

#elsif($DEC_d>=0)
#	{$DEC_d_deci=$DEC_d_deci_ns;}		# DEC deg deci signe +

#elsif(($DEC_d == 0)&&($DEC_m == 0)&&($DEC_s == 0))
#	{$DEC_d_deci=0;}			# DEC deg deci = 0


if($etat_sessionTemma==1){
	&activer_boutonsCdeObjet;  # si la session Temma est ouverte on reactive les boutons de cdes sur la Temma

	if(!Exists($fenetre_zview))# demande l'affichage de fenetre zview avant de placer le repere sur la carte
		{
		&fenetre_zview;	   # ouvre la fenetre de zview -> todo : warning si manque fichier zview
		&pos_sur_zview;   # place le cercle de visu de la position selectionnée sur la zview
		}

		else	{&pos_sur_zview;
			#$fenetre_zview->deiconify();	# ralenti l'affichage du cercle
			#$fenetre_zview->raise();	# ralenti l'affichage du cercle
			} # si zview ouverte on place le reticule de visu position en cours sur la zview
		}
else {print "todo : boite de dialogue session Temma non ouverte\n"}
}#----------- fin de get_saisie_radec




# ---------- fonction ctrl_gotoRADEC -------- CONTROLE GOTO RADEC avant cde Temma +placement cercle/zview
sub ctrl_gotoRADEC{
print "\nCommande Goto -> verif des coords de $nom_objet\n";

# --- 1) recup des coords goto saisies ou recup XEphem
# recup valeurs de get_saisie_radec : $RA_h $RA_m $RA_s $DEC_d $DEC_m $DEC_s
&get_saisie_radec;

my $RA_h_goto = $RA_h;
my $RA_m_goto = $RA_m;
my $RA_s_goto = $RA_s;
my $DEC_d_goto= $DEC_d;
my $DEC_m_goto= $DEC_m;
my $DEC_s_goto= $DEC_s;


# memoriser les gotos
# @objet_goto=($nom_objet, $RA_hms_objet, $DEC_dms_objet)
# push @objetgoto @liste_objetgoto

# --- 2) conversion DECdms->DEC dmdeci (+48:05:30 -> +48055) prepa au formatage pour Temma
#my $DEC_dm01m_goto=sprintf("%+02d%02d%01d",$DEC_d_goto,$DEC_m_goto,int($DEC_s_goto*0.166666667));
my $DEC_dm01m_goto=sprintf("%3s%02d%01d",$DEC_d_goto,$DEC_m_goto,int($DEC_s_goto*0.166666667));

# --- 3) RA DEC formatée pour Temma cde P (pour envoi coords vers Temma goto)
#$RADEC_goto=sprintf("%02d%02d%02d%+06d",$RA_h_goto,$RA_m_goto,($RA_s_goto*1.666666667),$DEC_dm01m_goto); # goto par defaut
$goto_radec=sprintf("%02d%02d%02d%+06d",$RA_h_goto,$RA_m_goto,($RA_s_goto*1.666666667),$DEC_dm01m_goto); # goto par defaut

# info retour console saisie coords goto
#$ctrl_goto_coords=sprintf("RA: %8s Dec: %9s", $RA_hms_objet,$DEC_dms_objet);
$ctrl_goto_coords=sprintf("RA %10s Dec %9s", $RA_hms_sf,$DEC_dms_sf);


print "Goto coords :\t\t$ctrl_goto_coords\n";
# info test sur les valeurs
print "cde temma P:\t\t$goto_radec\n";


# --- 4) prevention du retournement auto pendant goto si passage meridien ou autres cas particuliers Temma

###### test du mode goto approprié (controle par driver ou par Temma):
print "\nRecherche du mode goto approprié\n";

# conversion DEC goto en degré decimale non signée
# $DEC_d_deci_ns_goto = abs($DEC_d_goto) + (abs($DEC_m_goto/60)) + (abs($DEC_s_goto/3600));# approx 6s

# conversion RA goto en heures decimales
$RA_h_deci_goto = $RA_h_goto + ($RA_m_goto/60) + ($RA_s_goto/3600); # approx 0.6s

##### doublon avec $RA_heures_deci
# conversion RA en cours en heures decimales
#$curLocRA_hdeci =$curLocRAh + ($curLocRAm/60) + ($curLocRAs/3600);
#####

# recup TLS actuel (heure decimale) : $lst_corhdeci

# conversion RA_goto en angle horaire (heures decimales)
$HA_h_deci_goto=$lst_corhdeci-$RA_h_deci_goto;
if($HA_h_deci_goto<=0) {$HA_h_deci_goto=24-abs($HA_h_deci_goto);} 	# correction pour interval 0h-23h

# conversion RA_encours en angle horaire (heures decimales) : pour trouver la direction E/W du goto
#$HA_h_deci_curloc=$lst_corhdeci-$curLocRA_hdeci;
$HA_h_deci_curloc=$lst_corhdeci-$RA_heures_deci;
if($HA_h_deci_curloc<=0) {$HA_h_deci_curloc=24-abs($HA_h_deci_curloc);} # correction pour interval 0h-23h


# use var $direction_pointage =$HA_h_deci_curloc - $HA_h_deci_goto

# tests de position de l'objet à pointer (par rapport au meridien) :

# $decal_lstmerid = 1 || 2

# --- si W : $infoCurPos_brut : byte W
if (($HA_h_deci_goto>12) && ($infoCurPos_brut eq "W")) # pointage à l'EST du meridien direct par defaut
	{
	$suggesmodegoto="TemmaGoto";
	$type_de_goto="goto direct";
	print "goto zone EST meridien byte W : pointage direct avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}

# pointage direction OUEST direct à l'OUEST du meridien sous controle du driver
if (($HA_h_deci_goto<=$decal_lstmerid)&&($infoCurPos_brut eq "W")) #&&($HA_h_deci_curloc<$HA_h_deci_goto)
	{
	$suggesmodegoto="DriverGoto";
	$type_de_goto="goto direct";
	print "goto direction OUEST meridien -$decal_lstmerid h byte W : pointage direct avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}

# pointage à l'OUEST du meridien avec retournement
if (($HA_h_deci_goto>$decal_lstmerid)&&($HA_h_deci_goto<=12)&&($infoCurPos_brut eq "W"))
	{
	$suggesmodegoto="TemmaGoto";
	$type_de_goto="goto avec retournement";
	print "goto direction OUEST meridien hors limite byte W : retournement avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}


# --- si E : $infoCurPos_brut : retour byte E
# pointage à l'OUEST du meridien direct par defaut
if (($HA_h_deci_goto<=12) && ($infoCurPos_brut eq "E"))
	{
	$suggesmodegoto="TemmaGoto";
	$type_de_goto="goto direct";
	print "goto direction OUEST meridien byte E : pointage direct avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}
# pointage à l'EST du meridien sous controle du driver
if (($HA_h_deci_goto>(24-$decal_lstmerid))&&($infoCurPos_brut eq "E"))
	{
	$suggesmodegoto="DriverGoto";
	$type_de_goto="goto direct";
	print "goto direction EST meridien +$decal_lstmerid h byte E : pointage direct avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}
# pointage à l'EST du meridien sous controle du driver
if (($HA_h_deci_goto>12)&&($HA_h_deci_goto<(24-$decal_lstmerid))&&($infoCurPos_brut eq "E"))
	{
	$suggesmodegoto="TemmaGoto";
	$type_de_goto="goto avec retournement";
	print "goto direction EST meridien byte E : retournement avec mode suggeré : $suggesmodegoto\n";
	&ouvrir_gotodialogbox;
	}

# recap ds console pour controle :
print "\nvaleurs de calculs\n";
print "LSTh_deci : $lst_corhdeci\n";
print "RAhcurloc : $RA_heures_deci\n";
print "HAhcurloc : $HA_h_deci_curloc\n";
print "RAh_goto  : $RA_h_deci_goto\n";
print "HAh_goto  : $HA_h_deci_goto\n";
print "direction : todo\n\n";

# todo placer des verrous de pointages d'après HA, PTW/PTE et E/W : pour éviter les collisions avec trépied

#########################################################
# todo : appeler la fonction goto appropriée sans passer par le dialog intermediaire
#
# fonction goto par defaut gérée par la Temma
# &gotoRADEC;
#
# fonction goto gerée par le driver
# &gotodriverRADEC;
#
# ou dialog pour aider à choisir le mode goto approprié
# # &ouvrir_gotodialogbox;
#########################################################


}#----------- fin de ctrl_gotoRADEC



# ---------- fonction ouvrir_gotodialogbox ------ DIALOG DE SELECTION MANUELLE DU MODE GOTO (pour suivi des tests)
sub ouvrir_gotodialogbox{
# boite de dialogue pour choisir le mode goto par defaut ou par le driver
# todo : tester les conditions PTW/W ou PTE/E et PTW/E ou PTE/W et appeler le mode goto adhoc

$goto_dialogbox=$fenetre_driver->DialogBox(
					-title=>"Selection du mode Goto",
					-buttons=>["DriverGoto", "TemmaGoto", "Annuler"],
					-default_button=>"$suggesmodegoto");

$goto_dialogbox->add("Label",
-text=>"$type_de_goto vers $nom_objet\navec mode suggeré : $suggesmodegoto\n
Validez le mode souhaité :\n
Attention aux collisions avec trepied"
)->pack;
my $userchoice=$goto_dialogbox->Show();

if ($userchoice eq "DriverGoto"){print "Choix DriverGoto : goto sous controle du driver\n";
				&gotodriverRADEC;}# goto controlé par le driver

if ($userchoice eq "TemmaGoto")	{print "Choix TemmaGoto : goto par defaut sous controle du system Temma\n";
				&gotoRADEC;}# goto controlé par la Temma, mode par defaut

if ($userchoice eq "Annuler")	{print "Choix annuler goto\n";} # simple annulation de la commande goto

} # ---- fin de ouvrir_gotodialogbox ------------------------




# ---------- fonction gotodriverRADEC -- GOTO CONTROLE PAR DRIVER : LST +/-$delta_lst (selon long tube et dec)
sub gotodriverRADEC {
print "\nGoto sous controle du driver en cours...\n";
#$tag_gotocible = 0; 			# init var d'etat du goto (pour projet gotolisteauto)
$repTemmaGetGotoMsg="";			# init var retour Temma goto msg R0, R1, R2, R3

# protocole de goto
# 1) Do a Set LST : ici on leurre la monture avec valeur de test lst +/-1
# todo : reglage possible de cette valeur en fonction de la longueur du tube et de RADEC : $temma_lst_modif
if ($infoCurPos_brut eq "W") # use $temma_lst_moins_val : leurre avec decallage meridien 1h vers l'OUEST
	{
	$ob->write("T$temma_lst_moins_val\r\n");
	select (undef, undef, undef, 0.25);
	print("set Temma LST moins :\tT$temma_lst_moins_val\n");
	}

if ($infoCurPos_brut eq "E") # use $temma_lst_plus_val : leurre avec decallage meridien 1h vers l'EST
	{
	$ob->write("T$temma_lst_plus_val\r\n");
	select (undef, undef, undef, 0.25);
	print("set Temma LST plus :\tT$temma_lst_plus_val\n");
	}

#&get_temmaLST;				# get Temma LST modifié pour verif de la valeur modifiée
&get_temmaModifLST;			# get Temma LST modifié pour verif de la valeur modifiée
print "$TU_system $lst_hms\n";# retour console pour info

# 2) envoi de RADEC goto vers Temma
# P999999+/-99999 = PRA....+/-Dec..	entrer coordonnées de l'astre cible pour pointage Goto
$ob->write("P$goto_radec\r\n");	 	# envoi des coordonnées formatées pour Temma cde P (goto)
select (undef, undef, undef, 0.25);
#reply structure for cde Goto
$repTemmaGetGotoMsg = $ob->input;	# lecture $repTemmaGetGotoMsg
#select (undef, undef, undef, 0.25);
chomp $repTemmaGetGotoMsg;
print "Temma goto Msg :\t$repTemmaGetGotoMsg\n";	# reply R0 = Ok

if($repTemmaGetGotoMsg eq "R0\r")			# si reponse msg OK
	{
	print "Goto en cours vers :\t";
	if(defined $nom_objet)		# todo : voir si if defined utile
		{
		print "$nom_objet ";
		$astre_pointe="goto en cours vers $nom_objet";
		}
	print "$ctrl_goto_coords (brute Temma $goto_radec)\n";
	@list_byteF_goto_end=(); # reinit
	&stateGoto; 		# controle etat goto
	}

# cas d'erreur de coords goto
if($repTemmaGetGotoMsg eq "R1\r")			# msg erreur R1, R2, R3 de la Temma
	{print "Erreur coords Goto RA $goto_radec\nressaisir RA\n\n";
	$astre_pointe="RA goto error";}
if($repTemmaGetGotoMsg eq "R2\r")
	{print "Erreur coords Goto Dec $goto_radec\nressaisir Dec\n\n";
	$astre_pointe="Dec goto error";}
if($repTemmaGetGotoMsg eq "R3\r")
	{print "Erreur de saisie coords Goto $goto_radec\nverifier saisie RA et Dec\n\n";
	$astre_pointe="RADec goto error";}

#Reply Structure: R * (messages d'erreurs Temma)
# if Re R0 = Ok -> goto ok, pointage en cours
# if Re R1 = RA Error
# if Re R2 = Dec Error
# if Re R3 = Too many digits

} # ---- fin de gotodriverRADEC ------------------------




# ---------- fonction gotoRADEC ---------------- MODE GOTO RADEC CONTROLE PAR TEMMA (MODE PAR DEFAUT)
sub gotoRADEC {
print "\nGoto en cours...\n";

#$tag_gotocible = 0; 			# init var d'etat du goto (pour projet gotolisteauto)
$repTemmaGetGotoMsg="";			# init var retour Temma goto msg R0, R1, R2, R3

# protocole de goto
# 1) Do a Set LST
&set_temmaLST;				# set Temma LST au moment du goto
&get_temmaLST;				# get Temma LST pour verif

print "$TU_system $lst_hms (brut Temma LST : $temma_lst)\n";# retour console pour info

# 2) envoi de RADEC goto vers Temma
# P999999+/-99999 = PRA....+/-Dec..	entrer coordonnées de l'astre cible pour pointage Goto
$ob->write("P$goto_radec\r\n");	 	# envoi des coordonnées formatées pour Temma cde P (goto)
select (undef, undef, undef, 0.25);
#reply structure for cde Goto
$repTemmaGetGotoMsg = $ob->input;	# lecture $repTemmaGetGotoMsg
#select (undef, undef, undef, 0.25);
chomp $repTemmaGetGotoMsg;
print "Temma goto Msg :\t$repTemmaGetGotoMsg\n";	# reply R0 = Ok

if($repTemmaGetGotoMsg eq "R0\r")			# si reponse msg OK
	{
	print "Goto en cours vers :\t";
	if(defined $nom_objet)
		{
		print "$nom_objet ";
		$astre_pointe="goto en cours vers $nom_objet";
		}
	print "$ctrl_goto_coords (brute Temma $goto_radec)\n";
	@list_byteF_goto_end=(); # reinit
	#if($tag_gotocible == 1){print "Goto ok :\t$nom_objet\n";}
	&stateGoto;		# controle etat goto
	}

# cas d'erreur de coords goto
if($repTemmaGetGotoMsg eq "R1\r")			# msg erreur R1, R2, R3 de la Temma
	{print "Erreur coords Goto RA $goto_radec\nressaisir RA\n\n";
	$astre_pointe="RA goto error";}
if($repTemmaGetGotoMsg eq "R2\r")
	{print "Erreur coords Goto Dec $goto_radec\nressaisir Dec\n\n";
	$astre_pointe="Dec goto error";}
if($repTemmaGetGotoMsg eq "R3\r")
	{print "Erreur de saisie coords Goto $goto_radec\nverifier saisie RA et Dec\n\n";
	$astre_pointe="RADec goto error";}

#Reply Structure: R * (messages d'erreurs Temma)
# if Re R0 = Ok -> goto ok, pointage en cours
# if Re R1 = RA Error
# if Re R2 = Dec Error
# if Re R3 = Too many digits
} #----------- fin de &gotoRADEC


# ---------- fonction stateGoto ------------------------------- ETAT GOTO
sub stateGoto {
$ob->write("s\r\n");
select (undef, undef, undef, 0.25);
print "Commande -> s (requette etat goto)\n";	# sortie console
$repTemmaStateGoto = $ob->input; 	# reponse monture s0 -> tracking ou s1 -> goto en cours
select (undef, undef, undef, 0.25);
chomp $repTemmaStateGoto;

if($repTemmaStateGoto eq "s1\r"){
	print "Etat goto actif :\t$repTemmaStateGoto\n";# sortie console
	}

elsif($repTemmaStateGoto eq "s0\r"){
	print "Etat goto inactif :\t$repTemmaStateGoto\n";# sortie console
	# remmettre lst vrai dans Temma après goto
	print "Reset TemmaLST (true LST) :\n";		# sortie console
	&set_temmaLST;
	&get_temmaLST;
	}
} #----------- fin de &stopGoto



# ---------- fonction &stopGoto ------------------------------- STOP GOTO
sub stopGoto {
$ob->write("PS0\r\n");
print "Commande ->Goto Stop\n";		# sortie console stopGoto cliqué
$astre_pointe="StopGo $nom_objet";
# todo : fonction retour_posdepart : revenir à la position précédant le goto stop : repointage manuel
# todo : faire des verrou de pointage + appel de stopGoto
} #----------- fin de &stopGoto



# todo : test de fonction senAgain avec PS1 : correspond à quoi ds TT2000 ???
# ---------- fonction sendAgainGoto --------------------------- SEND AGAIN GOTO en cours de test
sub sendAgainGoto {
$ob->write("PS1\r\n");
print "Commande ->sendAgainGoto\n";	# sortie console send again cliqué
$astre_pointe="sendAgain $nom_objet";
} #----------- fin de sendAgainGoto



# ---------- fonction retournement_surplace ------------------ RETOURNEMENT SUR PLACE en cours de test
# commande manuelle (ou auto) de retournement et repointage sur l'objet en cours
# cde possible que si la positionRA courante et ds l'intervalle [lst +/-1 heure maxi]
# todo : detection de la situation critique qui appelera cette fonction (depuis boucle get_temma_radec)

sub retournement_surplace {

# recup RADEC en cours de pointage
$RA_retournesurplace=sprintf("%02d%02d%02d",$curLocRAh,$curLocRAm,($curLocRAs*1.666666667));

# DECdms->DEC deg mindeci (+48:05:30 -> +48055)
$DEC_retournesurplace=sprintf("%3s%02d%1d",$curLocDECd,$curLocDECm,int($curLocDECs*0.166666667));

# RADEC formatée pour Temma depuis pos RADEC en cours modifiée (format 010203+040506)

if($infoCurPos_brut eq "W"){ # retranche 1.2 arcsec sur RA
	$RADEC_retournesurplace=sprintf("%06d%+06d",$RA_retournesurplace-2,$DEC_retournesurplace); # format Temma
	}

if($infoCurPos_brut eq "E"){ # ajoute 1.2 arcsec sur RA
	$RADEC_retournesurplace=sprintf("%06d%+06d",$RA_retournesurplace+2,$DEC_retournesurplace); # format Temma
	}

#### todo ici : appel de goto($RADEC_retournesurplace, $astre_pointe)
#--- 3) CDE RETOURNEMENT sur position RADEC objet en cours de pointage
print "fonction retournement_surplace : retournement du tube sur le pointage actuel...\n";

# info pas utile
#if (defined $astre_pointe){	$astre_retournesurplace=$astre_pointe; # recup nom objet en cours pour info

# todo : controler la qualité du centrage de l'objet, voir si resync_surplace necessaire
} #----------- fin de retournement_surplace




############## &send_cdeManu ---------------------------------- COMMANDES MANUELLES
sub send_cdeManu {
$ob->write("$cde_manu\r\n");		# ecriture des commandes manuelles
select (undef, undef, undef, 0.25);
$repTemmaCdeManu = $ob->input; 		# (si) reponse monture
select (undef, undef, undef, 0.25);
chomp $repTemmaCdeManu;
print "Cde manuelle :\t$cde_manu -> $repTemmaCdeManu\n"; # sortie console

# update des champs de fenetreCdemanu
#&getTemmaVersion;	# recup version monture, info non utile pour le moment
&get_corspeedHemis;	# recup vitesse de corrections et hemisphere, info non utile pour le moment
&get_latitude;		# recup latitude ds la monture
&get_temmaLST;		# verif LST de la monture
&get_tracking;		# recup tracking
$fenetre_cdemanu->update;
} #----------- fin de &send_cdeManu



############## &cde_test --------------------------------------- COMMANDES DE TEST
sub cde_test {
print "Lecture des donnees brutes en cours (dans Temma):\n"; # sortie console

# update des champs de fenetreCdemanu
&getTemmaVersion;	# recup version monture, info non utile pour le moment
&get_corspeedHemis;	# recup vitesse de corrections et hemisphere, info non utile pour le moment
&get_latitude;		# recup latitude ds la monture
&get_temmaLST;		# verif LST de la monture
&get_tracking;		# recup tracking
$fenetre_cdemanu->update;
} #----------- fin de &cde_test






# ************************************************************* fonctionnelle mais en cours de dev
# +++++++++++++++++ FENETRE DE LIAISON XEPHEM +++++++++++++++++ lecture/ecriture ds fifos xephem
# *************************************************************

# todo :
# placer cette fonction dans un script separé (ex : require xephem352.pl)
# verifier :
# - presence et appartenance des fifos de xephem
# - lancement en cours et appartenance du demon lx200xed

# ---------- fonction ouvrir_fenetreXephem : communication avec xephem
sub ouvrir_fenetreXephem {

if(!Exists($fenetreFifoXephem)){
print "\nOuverture fenetre de liaison avec XEphem -----\n";

$fenetreFifoXephem = $fenetre_driver->Toplevel(	-width=>380,
						-height=>450,
						-background=>"black"
						); # Toplevel $fenetreFifoXephem

$fenetreFifoXephem->title("Liaison avec XEphem");

#my $frameFifoXephem = $fenetreFifoXephem->Frame(
#	-width=>380,
#	-height=>380,
#	-background=>"black",
	#-borderwidth=>1,
#	)->pack;#place(-x=>5, -y=>5);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"fifo_in :")->place(-x=>5, -y=>10);

# positions RA/Dec radian formatée pour XEphem/Skyview via fifo_in
$sortieFormatEncodeursRappel=$fenetreFifoXephem->Label(
	-borderwidth=>"0",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$RaDec_to_xephem)->place(-x=>60, -y=>12); # equiv rad de $temmaRAhmsDECdms

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"fifo_loc :")->place(-x=>5, -y=>40);

# affichage brut du contenu de fifo_loc : $contenu_fifoloc
$sortie_fifoloc = $fenetreFifoXephem->Label(
	-borderwidth=>"0",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$contenu_fifoloc)->place(-x=>60, -y=>42);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Position courante sur Skyview ->")->place(-x=>5, -y=>90);

# bouton radio pour ecriture dans xephem_fifo_in : affichage sur la SkyView de la position courante
$valetat_posreticule=0; # init du bouton radio
$bRadio_writefifoin = $fenetreFifoXephem->Checkbutton(
	#-state=>'disable',# -state=>"normal" selon clic sur bouton connexion monture
	-anchor=>'w',
	-borderwidth=>"1",
	-highlightbackground=>"gray30",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	#-indicatoron=>"0",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-activeforeground=>"DarkSeaGreen4",
	-background=>"Black",
	-activebackground=>"Black",
	-selectcolor=>"tomato3",
	-width=>"14",
	-text=>"Voir marqueur",
	-variable=>\$valetat_posreticule,
	-command=> sub{
		if($valetat_posreticule==1){
			print "Ouverture liaison avec xephem_in_fifo\n";
			# open(FIFO_IN, ">$chemin_fifo_in") or die "cannot open xephem_in_fifo : $!\n";
			# sysopen +flags ci-dessous ne cree pas de fichier si le fifo est manquant
			sysopen(FIFO_IN, $chemin_fifo_in, O_WRONLY | O_NONBLOCK) or die "PB sysopen $chemin_fifo_in : $!\n";
			$idwfifoin=$bRadio_writefifoin->repeat(1000,\&ecrit_xephem_in_fifo);
		}
		if($valetat_posreticule==0){
			print "Couper liaison avec xephem_in_fifo\n";
			$idwfifoin->cancel();
			close (FIFO_IN) || warn "PB close xephem_in_fifo :$!\n";
			select (undef, undef, undef, 0.25);
		}
	}# fin de sub
)->place(-x=>240, -y=>90, -height=>20);

if ($etat_sessionTemma == 1)	{$bRadio_writefifoin -> configure(-state=>'normal');
				$fenetreFifoXephem->update;}
if ($etat_sessionTemma == 0)	{$bRadio_writefifoin -> configure(-state=>'disable');
				 $fenetreFifoXephem->update;}

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Récupérations d'objets cliqués ->")->place(-x=>5, -y=>120);

# --- widgets de lecture des données dans xephem_fifo_loc
# detection de la version perl utilisée
if (substr($perl_version,0,3) eq "5.6"){
	# routine non blocante ok avec perl 5.6 sur RedHat 7.3
	# bouton radio pour lecture de xephem_fifo_loc : pour prendre les objets sur la SkyView en continu
	$valetat_fifoloc=0; # init du bouton radio
	$bRadio_readfifoloc = $fenetreFifoXephem->Checkbutton(
	#-state=>'disable',# todo : -state=>"normal" si xephem présent
	-anchor=>'w',
	-borderwidth=>"1",
	-highlightbackground=>"gray30",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	#-indicatoron=>"0",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-activeforeground=>"DarkSeaGreen4",
	-background=>"Black",
	-activebackground=>"Black",
	-selectcolor=>"tomato3",
	-width=>"14",
	-text=>"Prendre objet",
	-variable=>\$valetat_fifoloc,
	-command=> sub{
		if($valetat_fifoloc==1){
			print "Ouverture liaison avec xephem_loc_fifo\n";
			#open(FIFO_LOC, "<$chemin_fifo_loc") or die "cannot open xephem_loc_fifo : $!\n";
			sysopen(FIFO_LOC, $chemin_fifo_loc, O_RDONLY | O_NONBLOCK) or die "PB sysopen $chemin_fifo_loc : $!\n";
			#$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', \&recup_xephem_loc_fifo);
			$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', \&read_xephem_loc_fifo);
			#$idrfifoloc=$bRadio_readfifoloc->repeat(1000,\&recup_xephem_loc_fifo);# test au 21/04/03 : 500 ms
		}

		if($valetat_fifoloc==0){
			print "Couper liaison avec xephem_loc_fifo\n";
			$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', "");
			close (FIFO_LOC) or warn "PB close fifo_loc :$!\n";
		}
		}# fin de sub
	)->place(-x=>240, -y=>120, -height=>20);
} # de de if perl 5.6.x

else{	# bouton de lecture au coup par coup de xephem_fifo_loc----- EN TRAVAUX
	$bouton_lireFifo_LOC_XEphem = $fenetreFifoXephem->Button( # bouton prendre objet
		#-borderwidth=>"1",
		#-highlightthickness=>"1",
		#-relief=>"sunken",
		-font=>$fonte,
		-highlightbackground=>"gray30",
		-foreground=>"black",
		-background=>"DeepSkyBlue4",
		-text=>"Prendre objet",
		-width=>"14",
		-command=>\&lire_xephem_loc_fifo 	# routine ok : attente bloquante du contenu ds le fifo
		#-command=>\&lecture_xephem_loc_fifo	# test : attente bloquante du contenu ds le fifo
		#-command=>\&get_data_from_locfifo	# test au 18/04/03
	)->place(-x=>240, -y=>120, -height=>20);
} # fin de else pour perl version autre que 5.6x (5.8x)

# --- fin des widgets de lecture xephem_fifo_loc


$fenetreFifoXephem->Label(	# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Infos sur l'objet cliqué :")->place(-x=>5, -y=>170);


# details objet cliqué ds XEphem (contenu du fifo_loc)
$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Nom :")->place(-x=>5, -y=>200);

$sortie_nom_astre_XE = $fenetreFifoXephem->Label(		# sortie nom astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$xeAstre_nom)->place(-x=>60, -y=>200);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Type :")->place(-x=>5, -y=>220);

$sortie_type_astre_XE = $fenetreFifoXephem->Label(		# sortie type astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$xeAstre_type)->place(-x=>60, -y=>220);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Coords :")->place(-x=>5, -y=>240);

$sortie_RADEC_XE = $fenetreFifoXephem->Label(			# sortie RA/DEC astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$RaDec_from_xephem)->place(-x=>60, -y=>240);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Epoc :")->place(-x=>5, -y=>260);

$sortie_epoc_XE = $fenetreFifoXephem->Label(			# sortie epoc astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$xeAstre_epoc)->place(-x=>60, -y=>260);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Size :")->place(-x=>5, -y=>280);

$sortie_size_astre_XE = $fenetreFifoXephem->Label(		# sortie size astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$xeAstre_size)->place(-x=>60, -y=>280);

$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"VMag :")->place(-x=>5, -y=>300);

$sortie_mag_astre_XE = $fenetreFifoXephem->Label(		# sortie mag astre cliqué ds XEphem
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=> $fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$xeAstre_mag)->place(-x=>60, -y=>300);


$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"1) Sélectionner l'objet pour la monture :")->place(-x=>5, -y=>350);

# Selection Objet de XEphem
$bouton_selecObjetXE=$fenetreFifoXephem->Button(# bouton selecObjetXEphem->copie RADEC pour driver/f main
	-state=>'disable',# -state=>"normal" ou "active" avec arrivee de donnee par xephem_loc_fifo
	-text=>"SelecObj",# SelecObj
	-font=>$fonte,
	-highlightbackground=>"gray30",
	-foreground=>"black",
	-background=>"DarkOrange4",
	-width=>"7",
	-command=>\&selecObjetXE
	)->place(-x=>285, -y=>350, -height=>20); # (170)


$fenetreFifoXephem->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"2) Option : ajouter l'objet ds listeperso.txt :")->place(-x=>5, -y=>380);


$bouton_ajoutObjetXElistepersotxt=$fenetreFifoXephem->Button(# bouton ajout ds listeperso.txt astre XEphem
	-state=>'disable',# -state=>"active" avec bouton SelecObj
	-text=>"Ajouter",
	-font=>$fonte,
	-highlightbackground=>"gray30",
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-width=>"7",
	-command=>\&ajout_dslisteperso)->place(-x=>285, -y=>380, -height=>20);#-x=>60, -y=>330


$boutonMasquer_frameFifoXEphem=$fenetreFifoXephem->Button(	# bouton masquer fenetre fifo XEphem
	-text=>"Masquer",
	-font=> $fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-command => sub{$fenetreFifoXephem->withdraw;
			print "Masquer fenetre de liaison avec XEphem\n";
	}
)->place(-x=>285, -y=>410, -height=>20);} # fin de if Exists toplevel
else	{
	print "fenetre de liaison avec XEphem deja ouverte\n";
	$fenetreFifoXephem->deiconify();
	$fenetreFifoXephem->raise();
	}

}#----------- fin de ouvrir_fenetreXephem




# ---------- fonction ecrit_xephem_in_fifo ---- ecriture continue ds xephem_in_fifo : delay repeat 500ms ok
# envoi la position courante radec_radian sur XEphem/Skyview
sub ecrit_xephem_in_fifo{
select((select(FIFO_IN),$| =1)[0]);			# pour vider tampon
$ecrit_dsfifoin=syswrite(FIFO_IN, $RaDec_to_xephem, 44);# length($RaDec_to_xephem)=43 ou 44 avec le \n
warn "echec de syswrite xephem_in_fifo : $!\n" unless $ecrit_dsfifoin==length($RaDec_to_xephem);
}#----------- fin de ecrit_xephem_in_fifo




# ---------- fonction lecture_xephem_loc_fifo
sub lecture_xephem_loc_fifo{
open FIFO_LOC, "<$chemin_fifo_loc" or die "$chemin_fifo_loc: $!\n";
$SIGCHLD=sub{wait()};
$pid_loc_fifo = fork();
die "echec du fork : $!\n" unless defined ($pid_loc_fifo);
if ($pid_loc_fifo==0){  # fils
			while (defined ($contenu_fifoloc=<FIFO_LOC>))
				{
				#print "$contenu_fifoloc\n";
				&getXEphemRaDec;
				}
			POSIX::exit(0); # sortie du fils
			}
close (FIFO_LOC);

#while(<FIFO_LOC>){
#	$contenu_fifoloc .=$_;}
#	print "$contenu_fifoloc\n";
#close (FIFO_LOC);

# version non forkée :
#open FIFO_LOC, "<$chemin_fifo_loc" or die "$chemin_fifo_loc: $!\n";

#if ($pid_loc_fifo==0){
#	$temma_xed_pid=$$;
#	$pere_temma_xed_ppid=getppid;
#	print "pid : $temma_xed_pid\nlancement par $pere_temma_xed_ppid\n";
#
#	while (1) {
#		#sysread (FIFO_LOC, $contenu_fifoloc, 1024);
#		$sysread_etat = sysread (FIFO_LOC, $sysread_buf, 1024);
#		die "read_xephem_fifo_loc : erreur sysread $!" unless defined $sysread_etat;
#		if ($sysread_etat>0){
#			$contenu_fifoloc .= $sysread_buf;
#			print "$contenu_fifoloc\n";
#			&getXEphemRaDec;
#			POSIX::exit(0);
#			#exit;
#		}
#	}
#} else	{waitpid($pid_loc_fifo, 0); # bloque le driver tant que le fils est exec
#
#	}
	#$pid_loc_fifo = fork();
	#exec($temma_xed_pl) if (!$pid_loc_fifo); #or die "echec du fork_exec de $temma_xed_pl : $!\n";
	#print "exec process temma_xed de lecture_fifo_loc\n";
	#waitpid($pid_loc_fifo, 0); # bloque le driver tant que le fils est exec
}#----------- fin de lecture_xephem_loc_fifo




# --------- fonction read_xephem_loc_fifo : lecture fifo_loc en continu ok avec Perl 5.6 et non ok avec Perl 5.8
sub read_xephem_loc_fifo{
my ($sysread_buf,  $sysread_data, $sysread_etat, $sysread_wait);

$sysread_etat = sysread (FIFO_LOC, $sysread_buf, 1024);
die "read_xephem_fifo_loc : erreur sysread $!" unless defined $sysread_etat;

if ($sysread_etat>0){
$sysread_data .= $sysread_buf;
if ($sysread_data=~ /$EOF$/s)
	{
	$contenu_fifoloc=$sysread_data;
	print "fifo_loc : $contenu_fifoloc\n";
	&getXEphemRaDec;
	$sysread_wait++;
	}

$fenetreFifoXephem->waitVariable(\$sysread_wait);
$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', "");
#$contenu_fifoloc;
}

if ($sysread_etat==0)
	{
	$sysread_wait++;
	$fenetreFifoXephem->waitVariable(\$sysread_wait);
	$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', "");
	$contenu_fifoloc;
	}

} # ------- fin de read_xephem_loc_fifo




# --------- fonction recup_xephem_loc_fifo : lecture fifo_loc en continu ok avec Perl 5.6
sub recup_xephem_loc_fifo{
# todo : verif si pipe cassé (abscence d'écrivain ds le fifo)

#if (eof(FIFO_LOC)){
#	$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', "");
#	return;
#	}

if (sysread (FIFO_LOC, $contenu_fifoloc, 1024)) {
	print "fifo_loc : $contenu_fifoloc\n";
	&getXEphemRaDec;
	}

else	{
	$bRadio_readfifoloc->fileevent(FIFO_LOC, 'readable', "");
	}

} # ------- fin de recup_xephem_loc_fifo




# ---------- fonction lire_xephem_loc_fifo ---- lecture au coup par coup : pour Perl 5.8
# prend un objet de XEphem (mode bloquant)
sub lire_xephem_loc_fifo{
# methode Busy / Unbusy sur le curseur après clic bouton prendre objet : attend l'objet XEphem
$fenetreFifoXephem -> Busy(-recurse=>1);# curseur d'attente
$fenetre_driver -> Busy(-recurse=>1);	# curseur d'attente sur fenetre principale

use POSIX qw(:errno_h);
$SIG{PIPE} = 'IGNORE';
# lire de xephem -> driver
open(FIFO_LOC, "<$chemin_fifo_loc") or die "PB open/lecture de $chemin_fifo_loc: $!\n";

# lire de xephem -> driver (ouverture non bloquante)
#sysopen(FIFO_LOC,$chemin_fifo_loc,O_NONBLOCK|O_RDONLY) or die "PB sysopen xephem_loc_fifo : $!\n";

sysread(FIFO_LOC, $contenu_fifoloc, 1024) or warn "PB sysread xephem_loc_fifo : $!\n";
#$contenu_fifoloc = <FIFO_LOC>;# unless (!defined $contenu_fifoloc);

close (FIFO_LOC) or warn "PB close fifo_loc :$!\n";
select (undef, undef, undef, 0.25);

print "\nRecup objet XEphem :\nxephem_loc_fifo :\t$contenu_fifoloc\n";
&getXEphemRaDec;

$fenetre_driver -> Unbusy; # remet le curseur normal après arrivée des donnée ds le fifo
$fenetreFifoXephem->Unbusy;

if(!$contenu_fifoloc && $! == EPIPE){warn "pas de données dans xephem_loc_fifo\n";}

# ex de valeurs de retour de xephem_loc_fifo :
# M31,f|G,0:42:44.3,41:16:6,4.3,2000,11346|3702|35
# Cep Zeta,f|V|K1,22:10:51.3, 58:12:04,  3.35,2000,0
# fichier d'erreur log XEphem
# driverTemma004c.pl -m /usr/lib/xephem/fifos/xephem_in_fifo -g /usr/lib/xephem/fifos/xephem_loc_fifo -e
} # ------- fin de &lire_xephem_loc_fifo




# ---------- fonction getXEphemRaDec ------------------------- utilisation des coords objets XEphem
#recup des coords de xephem/skyview/telescope goto
sub getXEphemRaDec{
# init/reinit des vars du fifo_loc
$xeAstre_nom="";
$xeAstre_type="";
$xeAstre_ra_hms="";
$xeAstre_dec_dms="";
$RaDec_from_xephem="";
$xeAstre_mag="";
$xeAstre_epoc="";
$xeAstre_size="";
$xeAstre_spec="";

($xeAstre_nom,$xeAstre_type,$xeAstre_ra_hms,$xeAstre_dec_dms,$xeAstre_mag,$xeAstre_epoc,$xeAstre_size)=(split(/,/,$contenu_fifoloc));

# determiner le type d'objet cliqué ds XEphem/Skyview
if ($contenu_fifoloc =~ /,f/){	# si objet fixe on prend les infos qui sont completes

	# formatage RA recup XEphem
	($xeAstre_ra_h,$xeAstre_ra_m,$xeAstre_ra_s)=(split (/:/ , $xeAstre_ra_hms));
	$xeAstre_ra_hms=sprintf("%02d:%02d:%02.1f",$xeAstre_ra_h,$xeAstre_ra_m,$xeAstre_ra_s);

	# formatage Dec recup XEphem avec ajout signe + si positive
	($xeAstre_dec_d,$xeAstre_dec_m,$xeAstre_dec_s)=(split (/:/ , $xeAstre_dec_dms));
	$xeAstre_dec_dms=sprintf("%+3s:%02d:%02d",$xeAstre_dec_d,$xeAstre_dec_m,$xeAstre_dec_s);

	# pour fichier listeperso.txt et liste.pm
	$xeAstre_spec="$xeAstre_mag $xeAstre_type $xeAstre_size";

	print("Objet XEphem :\t\t$xeAstre_nom RA $xeAstre_ra_hms Dec $xeAstre_dec_dms Spec $xeAstre_spec\n");

	# pour affichage des caract objet ds fenetre xephem
	$RaDec_from_xephem="RA: $xeAstre_ra_hms Dec: $xeAstre_dec_dms";

	$bouton_selecObjetXE -> configure(-state=>'normal');# reactive le bouton SelecObj
} # fin de if type f

else {
	$xeAstre_ra_hms="non dispo";
	$xeAstre_dec_dms="non dispo";
	$RaDec_from_xephem="non dispo";
	$xeAstre_mag="non dispo";
	$xeAstre_epoc="non dispo";
	$xeAstre_size="non dispo";

# todo ouvrir liste ou autre source d'infos pour les autres objets
} # fin du else

#$fenetreFifoXephem->update;
}#----------- fin de getXEphemRaDec



# ---------- fonction selecObjetXE --------------------- selection objet de XEphem pour action sur objet
sub selecObjetXE{

$bouton_ajoutObjetXElistepersotxt-> configure(-state=>'normal');# degeler le bouton de copie objet ds listeperso.txt
$RA_hms_objet = $xeAstre_ra_hms;# recup nom,RA,DEC de l'objet XEphem pour synchro, goto ou ajout ds liste perso
$DEC_dms_objet= $xeAstre_dec_dms;
$nom_objet=$xeAstre_nom;
print("SelecObj XEphem :\t$nom_objet RA $RA_hms_objet Dec $DEC_dms_objet\n");

# si la session Temma est ouverte on reactive les boutons de cdes sur la Temma
if($etat_sessionTemma==1){&get_saisie_radec; 	# pour recup RA/DEC et visu sur zview avant commande sur Temma
			  &activer_boutonsCdeObjet;}	# active les boutons de commandes sync et goto
$fenetre_driver->update;


# todo : placer sur zview
# $icone_objet=$icone_objet_fixe;
}#----------- fin de selecObjetXE ---------------------




# *************************************************************
# +++++++++++++++++++ FENETRE PARAM SITE ++++++++++++++++++++++
# *************************************************************

# ---------- fonction editparamsite---------------------------- PARAMETRES SITE todo : choix plusieurs sites
sub editparamsite{
if(!Exists($fenetre_paramsite)){
print "\nOuverture fenetre paramètres site -----\n";
#print "Entrez les paramètres de votre site\n";

$fenetre_paramsite = $fenetre_driver->Toplevel(	#-width=>380,
						#-height=>280,
						-background=>"black"
						); # Toplevel $fenetre_paramsite

$fenetre_paramsite->raise($fenetre_driver);
$fenetre_paramsite->geometry("380x450+420+20");

$fenetre_paramsite->title("Paramètres du site");
#$fenetre_paramsite->Label(-text => "param_site");

#my $frame_paramsite = $fenetre_paramsite->Frame(
#	-width=>380,
#	-height=>220,
#	-background=>"black",
	#-borderwidth=>1,
#	)->pack;#place(-x=>5, -y=>5);

$fenetre_paramsite->Label(		# titre
	-font=>$fonte_grande,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Paramètres du site")->place(-x=>10, -y=>7);

$fenetre_paramsite->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Entrées :")->place(-x=>170, -y=>10);

$fenetre_paramsite->Label(		# titre
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-text=>"Params actuels :")->place(-x=>260, -y=>10);

$fenetre_paramsite->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Nom (en 10 lettres) ->")->place(-x=>10, -y=>40);

$entreeNomSite = $fenetre_paramsite->Entry(# entrée nom site
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"gray30",
	-width=>"10",
	-textvariable=>\$entree_nomsite)->place(-x=>170, -y=>40);

$sortieNomSite = $fenetre_paramsite->Label(# sortie nom site
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-width=>"10",
	-textvariable=>\$sortie_nomsite)->place(-x=>260, -y=>40);

$fenetre_paramsite->Label(		# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Latitude (+/-dd:mm:ss) ->")->place(-x=>10, -y=>70);

$entreeLatitude = $fenetre_paramsite->Entry(# entrée latitude
	#-borderwidth=>"1",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"gray30",
	-width=>"10",
	-textvariable=>\$entree_lat_dms)->place(-x=>170, -y=>70);

$sortieLatitude = $fenetre_paramsite->Label(# sortie latitude
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-width=>"10",
	#-textvariable=>\$getLatitude
	-textvariable=>\$sortie_lat_dms
	)->place(-x=>260, -y=>70);

$fenetre_paramsite->Label(			# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Longitude (+/-dd:mm:ss) ->\nlongitudes Est négatives")->place(-x=>10, -y=>100);

$entreeLongitude = $fenetre_paramsite->Entry(	# entrée longitude (init dans le script)
	#-borderwidth=>"1",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"gray30",
	-width=>"10",
	-textvariable=>\$entree_longi_dms)->place(-x=>170, -y=>100);

$entreeLongitude->bind('<Return>'=>\&set_usersite);


$sortieLongitude = $fenetre_paramsite->Label(	# sortie longitude
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-width=>"10",
	-textvariable=>\$sortie_longi_dms)->place(-x=>260, -y=>100); 	#$sortie_longi_dms

$bouton_appliquerInitSite = $fenetre_paramsite->Button(	# bouton set init site
	#-borderwidth=>"1",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-highlightbackground=>"gray30",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DarkOrange4",
	-text=>"Appliquer",
	-width=>"7",
	-command=>\&set_usersite
	)->place(-x=>170, -y=>135, -height=>20);

$bouton_EnregistrerInitSite = $fenetre_paramsite->Button( # bouton save init site ->temma_site.cfg
	#-borderwidth=>"1",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-highlightbackground=>"gray30",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DarkSeaGreen4",
	-text=>"Save",
	-width=>"7",
	-command=>\&save_usersite
	)->place(-x=>260, -y=>135, -height=>20);

$fenetre_paramsite->Label(			# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"TU système :")->place(-x=>10, -y=>175);

$sortie_TUSYS = $fenetre_paramsite->Label(	# sortie TU_system
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$TU_system)->place(-x=>170, -y=>175);# $TU_system -> TU long avec date

$fenetre_paramsite->Label(			# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Temps Sidéral Local :")->place(-x=>10, -y=>200);

$sortie_TSL = $fenetre_paramsite->Label(	# sortie TSL
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$lst_hms)->place(-x=>170, -y=>200);

	
# param de $decal_lstmerid selon longueur de tube
#$fenetre_paramsite->Label(			# titre
#	-font=>$fonte,
#	-foreground=>"tomato3",
#	-background=>"black",
#	-text=>"Méridien virtuel :")->place(-x=>10, -y=>240);

# init $decal_lstmerid : 1
# $decal_lstmerid = 1;
#$BE_decal_lstmerid = $fenetre_paramsite->BrowseEntry(
    	#-labelBorderwidth=>1,
	#-labelFont=>$fonte,
	#-font=>$fonte,
	#-labelForeground=>"grey",
	#-labelBackground=>"black",
#	-highlightbackground=>"gray30",
#	-label => "Decallage H : ",
#  	-variable => \$decal_lstmerid,
#	-choices=>[qw/1 2/],
#	-background=>"black",
#	-foreground=>"tomato3", #"DarkSeaGreen4",
#	-relief=> "groove",
#	-width=>5,
#	-listwidth=>10,
#	-browsecmd=>sub{if($decal_lstmerid==1)
#				{
#				$canvaszv->itemconfigure("meridien2",-outline=>'DarkSeaGreen4');
#				$canvaszv->itemconfigure("meridien1",-outline=>'DeepSkyBlue4');
#				}
#			elsif($decal_lstmerid==2)
#				{
#				$canvaszv->itemconfigure("meridien2",-outline=>'DeepSkyBlue4');
#				$canvaszv->itemconfigure("meridien1",-outline=>'DarkSeaGreen4');
#				}
#			print "Decallage méridien utilisable : $decal_lstmerid\n";
#			} # fin de sub
#	)->place(-x=>170, -y=>240);



# pour affichage de la var $msg_infosite : conseil ou retour d'info pour l'utilisateur
$text_msg_infosite = $fenetre_paramsite->Scrolled ("ROText",
		-scrollbars => 'se',
		)->place(-x=>10, -y=>290, -width=>360, -height=>100);

$boutonFermer_fenetre_paramsite=$fenetre_paramsite->Button( # bouton fermer fenetre_paramsite
	-text=>"Fermer",
	-font=> $fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	#-command=>\&annulerfenetrePcam
	-width=>"7",
	-command => sub{$fenetre_paramsite->withdraw;
			#destroy $fenetre_paramsite;
			print "Fermer fenetre paramètres site\n";}
			)->place(-x=>260, -y=>410, -height=>20);
						} # fin de if Exists toplevel
					else	{
						print "Fenetre paramètres site deja ouverte\n";
						$fenetre_paramsite->deiconify();
						$fenetre_paramsite->raise();
						}

# afficher les infos ou conseils pour les params du site
$text_msg_infosite->insert('end', $msg_infosite);

# todo : annulation ou reset anciens params et sauvegarde de plusieurs sites
}#----------- fin de paramsite



# ---------- fonction set_usersite ----------- bouton Appliquer paramsite

# todo : tester la validité des saisies des params

sub set_usersite{
if (!defined($entree_nomsite)){$entree_nomsite=$sortie_nomsite;}
	else{$sortie_nomsite=$entree_nomsite;}

if (!defined($entree_lat_dms)){$entree_lat_dms=$sortie_lat_dms;}
	else{$sortie_lat_dms=$entree_lat_dms;}

if (!defined($entree_longi_dms)){$entree_longi_dms=$sortie_longi_dms;}
	else{$sortie_longi_dms=$entree_longi_dms;}

&set_longitude;	# pour changer longitude en cours d'utilisation
&set_latitude;	# pour changer latitude en cours d'utilisation

print "Param site OK\nCliquez sur Save sauvegardera vos paramètres\n";
$msg_infosite="Param site OK\nCliquez sur Save sauvegardera vos paramètres\n";
if(Exists($fenetre_paramsite)){
	$text_msg_infosite->insert('end', $msg_infosite);# affichage info ds fenetre param site
	}
} # -------- fin de set_usersite



############## sub set_latitude ------------------------------------------- SET LATITUDE
# set/get LATITUDE : I/i
sub set_latitude{
#print "Commande ->Init Temma latitude...\n";
if (defined($sortie_lat_dms))
{
($lat_d, $lat_m, $lat_s) = (split (/:/ , $sortie_lat_dms));
# conversion LATdms->LAT dmdeci (+48:05:30 -> +48055)
$latitude_dmd=sprintf("%+2d%02d%01d",$lat_d,$lat_m,int($lat_s*0.166666667));
#print "set user latitude :\t$sortie_lat_dms\n";
} else	{
$latitude_dmd="+48050"; # init latitude par defaut Colmar si undef
$lat_d="+48";
$lat_m="05";
$lat_s="00";
$sortie_lat_dms=sprintf("%+02d:%02d:%02d",$lat_d,$lat_m,$lat_s); # lat formatée sortie Tk
print "set latitude par defaut :\t$sortie_lat_dms\n";# latitude par defaut si undef
	}
print "set Temma latitude :\tI$latitude_dmd (user latitude $sortie_lat_dms)\n";
$ob->write("I$latitude_dmd\r\n");	# set Temma Lat (type +48050)
select (undef, undef, undef, 0.25);


# ajout au 16/03/03 calcule de la latitude decimale signée
$lati_degdeci_ns=abs($lat_d)+(abs($lat_m/60))+(abs($lat_s/3600));# latitude deg deci non signée
if($latitude_dmd<0){$lati_degdeci=$lati_degdeci_ns*(-1);}	# si latitude de signe -
if($latitude_dmd>0){$lati_degdeci=$lati_degdeci_ns;}		# si latitude de signe +
if($latitude_dmd==0){$lati_degdeci=0;}				# si latitude = 0:0:0

# faux # $lati_degdeci=$lat_d + ($lat_m*60) + ($lat_s *3600);

#&get_latitude; # todo voir encore utile ici
#&set_longitude;
} # ---- fin de set_latitude


# ---------- fonction get_latitude ----------------------------------------- GET LATITUDE
# get LATITUDE : i
sub get_latitude{
$ob->write("i\r\n");			# get Temma Lat
select (undef, undef, undef, 0.25);
$getLatitude = $ob->input;		# lecture $getLatitude
chomp $getLatitude;
print "get Temma latitude :\t$getLatitude\n";
} # ---- fin de get_latitude



# ---------- fonction set_longitude --------------------------------------- SET LONGITUDE
sub set_longitude{
#print "Init driver -> longitude...\n";
#if (defined($sortie_longi_dms)){
($longi_deg,$longi_min,$longi_sec) = (split (/:/ , $sortie_longi_dms));
	print "Init driver longitude\t$sortie_longi_dms\n";

# conditions de signe sur $longi_deci
if ($longi_deg > 0){$longi_deci=$longi_deg+($longi_min /60);}	#/# ajouter les sec +($longi_sec/3600)
if ($longi_deg < 0){$longi_deci = $longi_deg - ($longi_min /60);}#/#
if ($longi_deg eq "+0" && $longi_min != 0){$longi_deci = $longi_min /60;}	#/# signe +longi_deg
if ($longi_deg eq "-0" && $longi_min != 0){$longi_deci = ($longi_min /60)*(-1);}#/# signe -longi_deg
if ($longi_deg == 0 && $longi_min == 0){$longi_deci = 0;}			# longi 0:0:0
} # ---- fin de set_longitude



# ---------- fonction save_usersite ---------------------------------------
sub save_usersite{
if(defined($entree_nomsite) or defined($entree_lat_dms) or defined($entree_longi_dms))
	{
	%params_usersite=(
	"nomsite"	=>"$entree_nomsite",
	"latitude"	=>"$entree_lat_dms",
	"longitude"	=>"$entree_longi_dms",);

# todo : à universaliser
open(USER_SITE_TXT,">./user_site.txt") or warn "PB ouverture user_site.txt :$!\n";

# écriture ds fichier user_site.txt
print (USER_SITE_TXT "\# si vous editez ce fichier, gardez la syntaxe ci-dessous :\n\# param =\tvaleur\n\n");
print (USER_SITE_TXT "nomsite =\t$params_usersite{nomsite}\n");
print (USER_SITE_TXT "latitude =\t$params_usersite{latitude}\n");
print (USER_SITE_TXT "longitude =\t$params_usersite{longitude}\n");

close (USER_SITE_TXT) or warn "PB close user_site.txt :$!\n";
	}#fin de if defined

print "Param site OK\nVotre site est enregistré dans user_site.txt\n";
$msg_infosite="Param site OK\nVotre site est enregistré dans user_site.txt\n";
if(Exists($fenetre_paramsite)){
	$text_msg_infosite->insert('end', $msg_infosite);# affichage info ds fenetre param site
	}

&get_usersite;
}# ------------ fin de save_usersite



# ---------- fonction get_usersite --------------------------------------
sub get_usersite{
print "Paramètres du site ->\t";

# test existance du fichier user_site.txt et recup les params du site
# sinon on applique les params en dur par defaut et on ouvre la fenetre param site
if(-e "./user_site.txt"){
	%params_usersite=();
	open(USER_SITE_TXT,"<./user_site.txt") or warn "PB ouverture user_site.txt :$!\n";

	while(<USER_SITE_TXT>){
		chomp;		# sup retour ligne
		s/#.*//;	# sup comment
		s/^\s+//;	# sup espace debut
		s/\s+$//;	# sup espaces fin
		next unless length;# s'il reste qqch
		my ($var, $valeur)=split (/\s*=\s*/,$_,2);
		$params_usersite{$var}=$valeur;
		}
	close (USER_SITE_TXT) or warn "PB close user_site.txt:$!\n";

	$sortie_nomsite=$params_usersite{nomsite};
	$sortie_lat_dms=$params_usersite{latitude};
	$sortie_longi_dms=$params_usersite{longitude};

	# retour console params du fichier
	print "dans fichier user_site.txt\n";
	print "user_site.txt\t\tpresent\n";
	print "nom du site :\t\t$params_usersite{nomsite}\n";
	print "latitude :\t\t$params_usersite{latitude}\n";
	print "longitude :\t\t$params_usersite{longitude}\n";

	# affiche retour pour l'utilisateur dans fenetre param site
$msg_infosite="Contenu du fichier user_site.txt\n
site :\t\t$params_usersite{nomsite}\nlatitude :\t$params_usersite{latitude}\nlongitude :\t$params_usersite{longitude}\n";

}# fin de if existe user_site

else{	# recup paramsite en dur si fichier user_site abscent
	print "\nfichier user_site.txt\tnon present\n";
	print "params site\t\tset default :\n";
	$sortie_nomsite="Colmar";
	$sortie_lat_dms="+48:05:00";
	$sortie_longi_dms="-7:21:00";
	print "nom du site :\t\t$sortie_nomsite\n";
	print "latitude :\t\t$sortie_lat_dms\n";
	print "longitude :\t\t$sortie_longi_dms\n";
	print "Entrez et enregistrez les paramètres de votre site\n";
	# affiche conseils pour l'utilisateur
$msg_infosite="Le fichier user_site.txt n'existe pas encore\n1) Entrez vos paramètres\n2) Appliquez\n3) Save\n";
	### ouvre la fenetre de saisie des params site perso
	##&editparamsite;
	### affichage de conseil pour utilisateur ds fenetre param site
	##if(Exists($fenetre_paramsite)){
	##	$text_msg_infosite->insert('end', $msg_infosite);
	##}
}# fin du else

# init du driver avec longitude et TSL saisies utilisateur ou valeurs par defaut
&set_longitude;
&calcLST;

}#----------- fin de get_usersite ---------------------




# ---------- fonction ajout_dslisteperso (from XEphem)------------------- listeperso.txt->append
sub ajout_dslisteperso{
print "transfert de l'objet XEphem dans listeperso.txt\n";
#$RA_hms_liste = $xeAstre_ra_hms;
#$DEC_dms_liste= $xeAstre_dec_dms;
#$nom_astre_liste=$xeAstre_nom;
open(LISTE_PERSO,">>./listeperso.txt") or warn "PB open listeperso.txt :$!\n"; # todo : à universaliser
#print LISTE_PERSO "$nom_astre_liste,$RA_hms_liste,$DEC_dms_liste\n";
print LISTE_PERSO "$xeAstre_nom,$xeAstre_ra_hms,$xeAstre_dec_dms,$xeAstre_spec\n";
close (LISTE_PERSO) or warn "PB close listeperso.txt :$!\n";
}#----------- fin de ajout_dslisteperso




# todo :
# ---------- fonction ouvrir_aide ------------------------------------ aide fenetre par fenetre
sub ouvrir_aide{
print "todo : fonction ouvrir_aide\n";
}#----------- fin de ouvrir_aide




############## &set_tracking ------------------------------ MODIF TRACKING
# cde tracking double axe compatible avec :
# EM-200/NJP/EM-500 TemmaPC et toutes versions Temma2 Jr/Temma2
# les EM-10/200 TemmaPC Jr ne gèrent qu'un seul moteur à la fois
# cde tracking : LM+3168,-60 (ralentir de 13.2deg/jour, dec+60min/jour)
# ex : LM+3168,-12 (pour Lune au 29/07/02)
# 3168=>nb de sec temps à ajouter pour RA /jour sid
# -12 =>nb de min arc à effectuer en DEC+ /jour sid
# code ci-dessous pour Temma PC/Temma2Jr/Temma2

sub set_tracking {
if($choix_tracking eq "sid"){
	$ob->write("LM0,0\r\n");
	select (undef, undef, undef, 0.25);
	print "Set sideral tracking :\tLM0,0\n";# sortie console tracking sideral
	&get_tracking;				# retour immediat controle tracking ds TK
	}
if($choix_tracking eq "sun"){
	$ob->write("LMLK\r\n");
	select (undef, undef, undef, 0.25);
	print "Set Soleil tracking :\tLMLK\n";	# sortie console tracking Soleil
	&get_tracking;				# retour immediat controle tracking ds TK
	}
if($choix_tracking eq "vec"){
# 1 jour_sid = 84164 sec -> tracking_sid=LM,0,0
# test de vitesse lunaire avec param tracking : LM+3168,-60 (ralentir de 13.2deg/jour, dec+60min/jour)
	#recup du tracking ds fenetre principale formaté pour envoi à la Temma
	$entree_paramTracking->delete("0", "end");	# effacer/ecraser l'ancienne valeur si on recalcule
	$entree_paramTracking->insert("0", $vecteurRADEC); # affichage résultat dans fenetre principale

	$saisieTracking= $entree_paramTracking->get;
	print "Saisie valeurs tracking :\t$saisieTracking\n";
	# test
	#if (defined($saisieTracking) && saisiecorrecte($saisieTracking)){
	($delta_RA,$delta_DEC)=(split (/,/ , $saisieTracking));
	if(($delta_RA>=-99999)or($delta_RA<=99999)&&($delta_DEC>=-9999)or($delta_DEC<=9999)){
		$ob->write("LM$delta_RA,$delta_DEC\r\n");# modifié au au 26/02/03
		#$ob->write("LM$saisieTracking\r\n");	# modifié au au 21/02/03
		#$ob->write("LM$TemmaObVecteur\r\n");	# ancien
		#$ob->write("LM+3168,-12\r\n"); 	# entrée en dur
		select (undef, undef, undef, 0.25);
		#print "Set vecteur :\t$TemmaObVecteur\n";# sortie console tracking vecteur RADEC
		print "Set vecteur tracking :\t$delta_RA,$delta_DEC\n";# console delta RADEC
		&get_tracking;				# retour immediat controle tracking ds TK
		&clic_paramvecteur;
	}#fin de if
	else {print "Saisie du tracking incorrecte\n";
		$ob->write("LM0,0\r\n");
		select (undef, undef, undef, 0.25);
		&get_tracking;
	}
}# fin de if vec

} #----------- fin de set_tracking ------------------------


# todo controle de la saisie
sub saisiecorrecte{
#warn "has nondigits"        if     /\D/;
return;
}

############## &clic_paramvecteur ------------------------- retour aux couleurs par defaut des BR non cliqués
sub clic_paramvecteur{
$bRadio_choixTrackingSoleil->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
$bRadio_choixTrackingSideral->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
}

############## &get_tracking ------------------------------ RETOUR DU TRACKING EN COURS
sub get_tracking {
$ob->write("lm\r\n");			# requette vitesse tracking
select (undef, undef, undef, 0.25);
$repTemmaGetTracking = $ob->input; 	# reponse monture valeur du tracking
select (undef, undef, undef, 0.25);
chomp $repTemmaGetTracking;

# si get_tracking retourne un tracking sideral (par defaut à la mise sous tension)
if($repTemmaGetTracking eq "lmLM0,0\r" or $repTemmaGetTracking eq "lmLM+0,+0\r")
	{
	$mode_tracking="sid";
	$bRadio_choixTrackingSideral->configure(-foreground=>"Black");		# modif aspect couleur de police
	$bRadio_choixTrackingSoleil->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	$bRadio_choixTrackingVecteur->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	#$valeurs_tracking="0,0";	# test en dur
	# supprime les 4 premiers caract lmLM pour ne garder que la valeur du tracking
	$valeurs_tracking=substr($repTemmaGetTracking,4,-1);
	}

# si get_tracking retourne un tracking solaire (commande utilisateur)
elsif($repTemmaGetTracking eq "lmLMLK\r")
	{
	$mode_tracking="sun";
	$bRadio_choixTrackingSoleil->configure(-foreground=>"Black");		# modif aspect couleur de police
	$bRadio_choixTrackingSideral->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	$bRadio_choixTrackingVecteur->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	#$valeurs_tracking="LK";
	# supprime les 4 premiers caract lmLM pour ne garder que la valeur du tracking
	$valeurs_tracking=substr($repTemmaGetTracking,4,-1); # test au 02/03/03
	}

# sinon get_tracking retoune un tracking type vecteur (commande utilisateur)
else	{
	$mode_tracking="vec";		# pour retour radiobutton
	$bRadio_choixTrackingVecteur->configure(-foreground=>"Black");		# modif aspect couleur de police
	$bRadio_choixTrackingSideral->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	$bRadio_choixTrackingSoleil->configure(-foreground=>"DarkSeaGreen4");	# modif aspect couleur de police
	# supprime les 4 premiers caract lmLM pour ne garder que la valeur du tracking
	$valeurs_tracking=substr($repTemmaGetTracking,4,-1);
	}

$choix_tracking=$mode_tracking; # identifie le mode de tracking pour modifier l'aspect des bradio selon $mode_tracking
print "get mode tracking : \t$mode_tracking valeur : $valeurs_tracking\n";	# sortie console mode et valeur tracking
print "get valeur tracking :\t$repTemmaGetTracking\n";				# sortie console valeur brute tracking

# ajout du retour de get_tracking dans fenetre principale
#$entree_paramTracking->configure(-foreground=>"DarkSeaGreen4");# modifie la couleur des caracts (rouge=mode saisie; vert=retour tracking)
$entree_paramTracking->delete("0", "end");	# effacer l'ancienne valeur pour l'écraser si on (re)calcule un tracking
$entree_paramTracking->insert("0", $valeurs_tracking);	# affichage le résultat du tracking calculé
#$fenetre_driver->update;
} #----------- fin de get_tracking





# *************************************************************
# +++++++++++++++++ FENETRE CALCUL_TRACKING +++++++++++++++++++
# *************************************************************

# ---------- fonction ouvrir_calculTracking-----------------

sub ouvrir_calculTracking{
if(!Exists($fenetre_ptracking)){
print "\nOuverture fenetre calcul tracking ----\n";

$fenetre_ptracking = $fenetre_driver->Toplevel(-background=>"black");
$fenetre_ptracking->title("Calcul du tracking");

my $bord = 2; # bordures des widgets

# cadre pere tous les widgets
my $cadreglobal = $fenetre_ptracking->Frame(
			-background=>"black",
			-relief => 'groove',
			-borderwidth => $bord,
			-label=>'Entrez les valeurs demandées dans les champs',
			-labelPack=>[-side=>'top', -anchor=>'n',-pady =>5 ])->pack(-padx =>2,-pady =>2);

# cadres pour les widgets
my $cadreRA1=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre RA 1
my $cadreDEC1=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre DEC 1
my $cadreRA2=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre RA 2
my $cadreDEC2=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre DEC 2
my $cadredeltaT=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre deltaT
my $cadreBcalculer=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>6);# cadre bouton calculer
my $cadreresultat=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>2);# cadre résultat
my $cadreBeffacer=$cadreglobal->Frame(-relief=>'flat',-borderwidth=>$bord,-background=>"black")
->pack(-padx =>4,-pady =>6);# cadre bouton clear
my $cadreBfermer=$cadreglobal->Frame(-relief=>'groove',-borderwidth=>$bord,-background=>"black")
->pack(-expand=>1,-anchor=>'s',-fill=>'both',-padx =>0,-pady =>0);# cadre bouton fermer



# labels
$cadreRA1->Label(-text=>'Position 1 RA  (h:m:s) :',
		-font=>$fonte,-width=>24,-background=>"black",-foreground=>"tomato3")
->pack(-side=>'left');
$cadreDEC1->Label(-text=>'Position 1 DEC (d:m:s) :',
		-font=>$fonte,-width=>24,-background=>"black",-foreground=>"tomato3")
->pack(-side=>'left');
$cadreRA2->Label(-text=>'Position 2 RA  (h:m:s) :',
		-font=>$fonte,-width=>24,-background=>"black",-foreground=>"tomato3")
->pack(-side=>'left');
$cadreDEC2->Label(-text=>'Position 2 DEC (d:m:s) :',
		-font=>$fonte,-width=>24,-background=>"black",-foreground=>"tomato3")
->pack(-side=>'left');
$cadredeltaT->Label(-text=>'Decallage temps  (min) :',
		-font=>$fonte,-width=>24,-background=>"black",-foreground=>"tomato3")
->pack(-side=>'left');


# entry
$dtmpos=10; # valeur par defaut de 10 min pour le décallage entre les 2 coordonnées
$cadreRA1->Entry(-font=>$fonte,
		-highlightbackground=>"gray30",
		-highlightthickness=>"0",
		-relief=>"groove",
		-font=>$fonte,
		-foreground=>"Tomato3",
		-background=>"gray30",
		-width=>"15",
		-textvariable=>\$RA_hms1)
->pack(-side=>'right');

$cadreDEC1->Entry(-font=>$fonte,
		-highlightbackground=>"gray30",
		-highlightthickness=>"0",
		-relief=>"groove",
		-font=>$fonte,
		-foreground=>"Tomato3",
		-background=>"gray30",
		-width=>"15",
		-textvariable=>\$DEC_dms1)
->pack(-side=>'right');

$cadreRA2->Entry(-font=>$fonte,
		-highlightbackground=>"gray30",
		-highlightthickness=>"0",
		-relief=>"groove",
		-font=>$fonte,
		-foreground=>"Tomato3",
		-background=>"gray30",
		-width=>"15",
		-textvariable=>\$RA_hms2)
->pack(-side=>'right');

$cadreDEC2->Entry(-font=>$fonte,
		-highlightbackground=>"gray30",
		-highlightthickness=>"0",
		-relief=>"groove",
		-font=>$fonte,
		-foreground=>"Tomato3",
		-background=>"gray30",
		-width=>"15",
		-textvariable=>\$DEC_dms2)
->pack(-side=>'right');

$cadredeltaT->Entry(-font=>$fonte,
		-highlightbackground=>"gray30",
		-highlightthickness=>"0",
		-relief=>"groove",
		-font=>$fonte,
		-foreground=>"Tomato3",
		-background=>"gray30",
		-width=>"15",
		-textvariable=>\$dtmpos)
->pack(-side=>'right');


$cadreBcalculer->Button(  # todo : edition fichier coords lune, comete ou asteroide pour calcul du tracking
	-text => "Fichier",
	-font=>$fonte,
	-width=>10,
	-highlightbackground=>"gray60",
	-highlightthickness=>"1",
	-relief=>"raised",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
 	-command => sub { print "Todo : ouvrir fichier pour calcul du vecteur\n";}
	)->pack(-side => 'left', -padx =>4);

$bouton_calculer_tracking=$cadreBcalculer->Button(
	#-state=>'disable',
	-text => "Calculer",
	-font=>$fonte,
	-width=>10,
	-highlightbackground=>"gray60",
	-highlightthickness=>"1",
	-relief=>"raised",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
 	-command => sub { print "Calculer le vecteur\n";
                                 &calcvecteur;})->pack(-side => 'right', -padx =>4);


# label résultat et résultat
$cadreresultat->Label(	-text => 'Vecteur Temma : LM',
				-font=>$fonte,
				-background=>"black",
				-foreground=>"tomato3",
				-width => 18,
				-justify => 'left')->pack(-side => 'left');

# widget Text pour affichage du résultat calculé variable $vecteurRADEC (exemple "+3668,-2315")
$text_resultat=$cadreresultat->Text(
				-highlightbackground=>"gray30",
				-highlightthickness=>"0",
				-relief=>"groove",
				-font=>$fonte,
				-foreground=>"Tomato3",
				-background=>"gray30",
				-width=>"15",
				-height => 1,
				-borderwidth => $bord
				)->pack(-side => 'left');

# bouton effacer tous les champs
$bouton_clear_tracking=$cadreBeffacer->Button(
	-state=>'disable',
	-text => "Effacer",
	-font=>$fonte,
	-width=>10,
	-highlightbackground=>"gray60",
	-highlightthickness=>"1",
	-relief=>"raised",
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
        -command => sub { print"Effacer les saisies\n";
			 &effacersaisies;
})->pack(-side => 'left', -padx =>4);


# bouton appliquer le nouveau tracking (envoi la chaine valeurs +/-9999,+/-9999 à la commande LM)
$bouton_appliquer_tracking=$cadreBeffacer->Button(
	-state=>'disable',# -state=>"normal" selon clic sur bouton connexion Temma
	-text=>"Appliquer",
	-font=>$fonte,
	-width=>10,
	-highlightbackground=>"gray60",
	-highlightthickness=>"1",
	-relief=>"raised",
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-command=>sub{	$choix_tracking = "vec";
			&set_tracking;}
	)->pack(-side => 'right', -padx =>4);



$cadreBfermer->Button(	# bouton masquer la fenetre
	-text=>"Fermer",
	-font=>$fonte,
	-width=>10,
	#-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-foreground=>"black",
	-background=>"SlateGray4",
	-command => sub{$fenetre_ptracking->withdraw;
			&get_tracking;
			print "Fermer fenetre calcul tracking\n";}
	)->pack(-pady =>4);}
	else	{
		print "Fenetre calcul tracking deja ouverte\n";
		$fenetre_ptracking->deiconify();
		$fenetre_ptracking->raise();
		}

}#----------- fin de ouvrir_calculTracking -----------------




# ----------- calcvecteur ----------------------------------
sub calcvecteur{
if($dtmpos<=0){$dtmpos=1440; print"warning vecteur : saisie dTm<=0 remet dTm=1440, ressaisir dTm>0\n";}

# pos1-> $RA_hms1, $DEC_dms1 = RA/Dec position 1 maintenant)
# pos2-> $RA_hms2, $DEC_dms2 = RA/Dec position 2 à TU+ $dtmpos (soit TU +nb de min plus tard)
# différentiel minute de temps entre pos1 et pos2 : $dtmpos= 10m par defaut (24H = 1440m)

# --- RA :
($RA_h1,$RA_m1,$RA_s1) = (split (/:/ , $RA_hms1));
($RA_h2,$RA_m2,$RA_s2) = (split (/:/ , $RA_hms2));
$RA_decisec1=($RA_h1*3600)+($RA_m1*60)+$RA_s1;
$RA_decisec2=($RA_h2*3600)+($RA_m2*60)+$RA_s2;

# --- DEC :
($DEC_d1,$DEC_m1,$DEC_s1) = (split (/:/ , $DEC_dms1));
($DEC_d2,$DEC_m2,$DEC_s2) = (split (/:/ , $DEC_dms2));

# conditions de signe Dec
if($DEC_d1 eq "-0")	{$DEC_decimin1=($DEC_m1+($DEC_s1/60))*(-1);}
if($DEC_d1 < 0)		{$DEC_decimin1=(abs($DEC_d1*60)+$DEC_m1+($DEC_s1/60))*(-1);}
if($DEC_d1 >=0)		{$DEC_decimin1=($DEC_d1*60)+$DEC_m1+($DEC_s1/60);}
if($DEC_d2 eq "-0")	{$DEC_decimin2=($DEC_m2+($DEC_s2/60))*(-1);}
if($DEC_d2<0)		{$DEC_decimin2=(abs($DEC_d2*60)+$DEC_m2+($DEC_s2/60))*(-1);}
if($DEC_d2>=0)		{$DEC_decimin2=($DEC_d2*60)+$DEC_m2+($DEC_s2/60);}

# différentiel RA en sec/j : $delta_RA
#$delta_RA=sprintf("%+0d", $RA_decisec1-$RA_decisec2);	# val- =>accelere ; val+ =>ralenti tracking RA
$delta_RA=sprintf("%+0d",(($RA_decisec1-$RA_decisec2)*(1440/$dtmpos)));
# val- =>accelere ; val+ =>ralenti tracking RA

# différentiel DEC en min/j : $delta_DEC
#$delta_DEC=sprintf("%+0d", $DEC_decimin1-$DEC_decimin2);# val- =>augmente DEC ; val+ =>diminue DEC
$delta_DEC=sprintf("%+0d",(($DEC_decimin1-$DEC_decimin2)*(1440/$dtmpos)));
# val- =>augmente DEC ; val+ =>diminue DEC

# infos sur resultats de $delta_RA et $delta_DEC :
# LM+deltara_x tsec,+/-deltadec_y tmin
# si $delta_RA >0 on ralentit le tracking RA
# si $delta_DEC>0 on diminue la Dec

#sortie formattée pour Temma
#$TemmaObVecteur=sprintf("%s,%s",$delta_RA,$delta_DEC);# chaine avec valeurs deltaRA,deltaDEC
#print "Params vecteur objet :\t$TemmaObVecteur\n";	# sortie console

# afficher le résultat dans le widget $text_resultat
$vecteurRADEC="$delta_RA,$delta_DEC";		# formatage pour Temma (sans la commande LM)
$text_resultat->delete("1.0", "end");		# effacer/ecraser l'ancienne valeur si on recalcule
$text_resultat->insert("end", $vecteurRADEC);	# affichage résultat dans fenetre outils
print "$vecteurRADEC (avec dTm $dtmpos min)\n";

#recup du tracking ds fenetre principale formaté pour envoi à la Temma
#$entree_paramTracking->delete("0", "end");	# effacer/ecraser l'ancienne valeur si on recalcule
#$entree_paramTracking->insert("0", $vecteurRADEC); # affichage résultat dans fenetre principale

# etat des boutons tracking selon etat de la Temma (en connexion/hors connexion) et selon valeurs de calculs
if($etat_sessionTemma==1 && defined ($vecteurRADEC)){
			#$bouton_calculer_tracking -> configure(-state=>'normal');
			$bouton_clear_tracking -> configure(-state=>'normal');
			$bouton_appliquer_tracking -> configure(-state=>'normal');
			}


} # ----------- fin de calcvecteur -------------------------



#-------------- effacersaisies -----------------------------
sub effacersaisies{
$RA_hms1="";
$DEC_dms1="";
$RA_hms2="";
$DEC_dms2="";
$vecteurRADEC="";
$dtmpos=10;
$text_resultat->delete("1.0","end");
$fenetre_ptracking->update;
} # ----------- fin de effacersaisies ----------------------



#-------------- recup_tracking ----------------------------- non utilisée
#sub recup_tracking{
# envoi du resultat $vecteurRADEC ds entry $entree_paramTracking
#$entree_paramTracking->delete("1.0", "end");
#$entree_paramTracking->insert("end", $vecteurRADEC);	# affichage résultat dans fenetre driver
#} # ----------- fin de recup_tracking ----------------------




# *************************************************************
# ++++++++++++++++++++ FENETRE CDE_MANU +++++++++++++++++++++++
# *************************************************************

# ---------- fonction commandes manuelles ---------------------
sub ouvrir_cdemanu{
if(!Exists($fenetre_cdemanu)){
print "\nOuverture fenetre de commandes manuelles ----\n";

$fenetre_cdemanu = $fenetre_driver->Toplevel(	-width=>380,
						-height=>450,
						-background=>"black"
						); # Toplevel $fenetre_cdemanu

$fenetre_cdemanu->title("Commandes manuelles et données brutes");

# zone de commandes manuelles
#my $frame_cdemanu = $fenetre_cdemanu->Frame(
#	-width=>380,
#	-height=>360,
#	-background=>"black",
	#-borderwidth=>1,
#	)->pack;#place(-x=>5, -y=>5);

$fenetre_cdemanu->Label(				# titre
	-font=>$fonte_grande,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Commandes manuelles et retours (protocole)")->place(-x=>5, -y=>5);

# entree/sortie des commandes manuelles
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Commande/Temma ->")->place(-x=>5, -y=>45);

$entreeCdeManu = $fenetre_cdemanu->Entry(		# entrée CdeManu
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"gray30",
	-width=>"18",
	-textvariable=>\$cde_manu)->place(-x=>140, -y=>45);

$entreeCdeManu->bind("<Return>"=>\&send_cdeManu);

$boutonValiderCdeManu=$fenetre_cdemanu->Button(		# bouton tester send_cdeManu
	-text=>"Send",
	-font=>$fonte,
	-highlightbackground=>"gray30",
	-foreground=>"black",
	-background=>"DeepSkyBlue4",	#"DarkOrange4",
	-width=>"7",
	-command=>\&send_cdeManu)->place(-x=>290, -y=>45, -height=>20);#-x=>290

$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Retour cde :")->place(-x=>5, -y=>75);

$sortieCdeManu = $fenetre_cdemanu->Label(		# label sortie CdeManu
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-width=>"31",
	-textvariable=>\$repTemmaCdeManu)->place(-x=>140, -y=>75);


### zone des differentes infos retours

$fenetre_cdemanu->Label(				# titre
	-font=>$fonte_grande,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Données brutes en cours (retour Temma)")->place(-x=>5, -y=>125);

# sortie brute Temmaversion :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"TemmaVersion (v) :")->place(-x=>5, -y=>165);

$sortie_getTemmaVersion=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$getTemmaVersion)->place(-x=>140, -y=>165);# retour de $getTemmaVersion

# sortie getCorSpeedHemis
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"CSpeed/Hemis (lg) :")->place(-x=>5, -y=>190);

$sortie_get_corspeedHemis=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$get_corspeedHemis)->place(-x=>140, -y=>190);# retour de $getTemmaVersion

# sortie brute :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Tracking (lm) :")->place(-x=>5, -y=>215);

$sortie_get_tracking=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$repTemmaGetTracking)->place(-x=>140, -y=>215);# retour de get_latitude

# sortie brute get_latitude :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Latitude (i) :")->place(-x=>5, -y=>240);

$sortie_getLastsetLATI=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$getLatitude)->place(-x=>140, -y=>240);# retour de get_latitude

# sortie brute getLastsetLST (retour du dernier setLST) :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"LST/LST modif (g) :")->place(-x=>5, -y=>265);

$sortie_getLastsetLST=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$get_temmaLST)->place(-x=>140, -y=>265);# retour du dernier set LST

# sortie brute getLastsetModifLST (retour du dernier setLST modifié pour meridien virtuel) :
$sortie_getLastsetModifLST=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$get_temmaModifLST)->place(-x=>280, -y=>265);# retour du dernier set LST modifié

# sortie brute getcurloc (recup de la positions brutes encodeurs) :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Pos RA Dec (E) :")->place(-x=>5, -y=>290);

$sortieBrutEncodeurs=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$repTemmaGetCurLocation)->place(-x=>140, -y=>290);#$sortieBrutEncodeurs

# sortie brute setsynchro
$fenetre_cdemanu->Label(	# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Synchro RA Dec (D) :")->place(-x=>5, -y=>315);#y=>325

$sortieBrut_setsynchro=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$RADEC_sync)->place(-x=>140, -y=>315);#$sortie Brut setsynchro

$sortieBrut_setsynchroMSG=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$repTemmaSetLocationMsg)->place(-x=>280, -y=>315);#error msg $repTemmaSetLocationMsg

# sortie brute gotoRADEC :
$fenetre_cdemanu->Label(				# titre
	-font=>$fonte,
	-foreground=>"tomato3",
	-background=>"black",
	-text=>"Goto RA Dec (P) :")->place(-x=>5, -y=>340);

$sortieBrut_setgoto=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$goto_radec)->place(-x=>140, -y=>340);#$sortieBrut $goto_radec

$sortieBrut_setgotoMSG=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$repTemmaGetGotoMsg)->place(-x=>280, -y=>340);#error msg $repTemmaGetGotoMsg

$sortieBrut_stateGoto=$fenetre_cdemanu->Label(
	-highlightthickness=>"0",
	-highlightbackground=>"gray30",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-textvariable=>\$repTemmaStateGoto)->place(-x=>310, -y=>340);# etat goto : en cours oui->s0 / non->s1



# init zenith facultatif : fonction intégrée ds setsynchro pour calculs interne des coords par la Temma
$bouton_initZenith = $fenetre_cdemanu->Button(
	-state=>'normal',
	#-state=>'disable',
	#-borderwidth=>"1",
	-highlightbackground=>"gray60",
	#-highlightthickness=>"1",
	-relief=>"raised",
	-width=>"7",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",#RosyBrown
	-text=>"Init Z",
	-command=>\&initZenith
	)->place(-x=>15, -y=>410, -height=>20);

# bouton pour lancer des tests sur ce que memorise la Temma : fonctions cde_test
$bouton_lancerCdeTest=$fenetre_cdemanu->Button(
	-text=>"Relire données",
	#-width=>"8",
	-font=>$fonte,
	-highlightbackground=>"gray30",
	-foreground=>"black",
	-background=>"DeepSkyBlue4", #"DarkOrange4",
	-command=>\&cde_test)->place(-x=>140, -y=>410, -height=>20);

$bouton_Fermer_cdemanu=$fenetre_cdemanu->Button( # bouton masquer la fenetre
	-text=>"Masquer",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-command => sub{$fenetre_cdemanu->withdraw;
			print "Masquer fenetre commandes manuelles\n";}
	)->place(-x=>290, -y=>410, -height=>20);} # fin de if Exists toplevel
	else	{
		print "Fenetre commandes manuelles deja ouverte\n";
		$fenetre_cdemanu->deiconify();
		$fenetre_cdemanu->raise();
		}
}# ---- fin de commandes manuelles





# *************************************************************
# +++++++++++++++ FENETRE CONFIG DU PORT SERIE ++++++++++++++++
# *************************************************************


# ---------- fonction ouvrir_fconfig_RS232 : fenetre de config du port serie
sub ouvrir_fconfigRS232{

# use Tk::BrowseEntry;
if(!Exists($fenetre_configRS232)){
print "\nOuverture fenetre de config du port serie -----\n";

$fenetre_configRS232 = $fenetre_driver->Toplevel(
						#-width=>380,
						#-height=>300,
						#-background=>"black"
						); # Toplevel $fenetreListe

$fenetre_configRS232->raise($fenetre_driver);
$fenetre_configRS232->geometry("380x450+400+0");

$fenetre_configRS232->title("Config du port serie pour Temma");

$fenetre_configRS232->Label(	# titre
	-font=>$fonte,
	#-foreground=>"tomato3",
	#-background=>"black",
	-text=>"Selection du port serie selon votre système :")->place(-x=>10, -y=>10);

# liste de ports serie possibles si windows
if (!defined ($nomPortserieWindows)) {$nomPortserieWindows = "COM1";}
my $BEportcom = $fenetre_configRS232->BrowseEntry(
    	#-labelBorderwidth=>1,
	#-labelFont=>$fonte,
	#-font=>$fonte,
	#-labelForeground=>"grey",
	#-labelBackground=>"black",
#-highlightbackground=>"gray30",
-label => "Windows : ",
-variable => \$nomPortserieWindows,
#-background=>"black",#SlateGray3
#-foreground=>"DarkSeaGreen4",#black
-relief=> "groove",#sunken
-width=>7,
-listwidth=>40);

$BEportcom->place(-x=>10, -y=>40);
$BEportcom->insert("end", "COM1");
$BEportcom->insert("end", "COM2");
$BEportcom->insert("end", "COM3");
$BEportcom->insert("end", "COM4");
$BEportcom->insert("end", "COM5");
$BEportcom->insert("end", "COM6");

# liste de port serie possibles si Linux
if (!defined ($nomPortserieLinux)) {$nomPortserieLinux = "/dev/ttyS0";}
#$nomPortserieLinux = "/dev/ttyS0";
my $BEporttty = $fenetre_configRS232->BrowseEntry(
	#-labelBorderwidth=>1,
    	#-labelFont=>$fonte,
    	#-font=>$fonte,
	#-labelForeground=>"grey",
	#-labelBackground=>"black",
#-highlightbackground=>"gray30",
-label => "Linux : ",
-variable => \$nomPortserieLinux, # $objetperso,
#-background=>"black",#SlateGray3
#-foreground=>"DarkSeaGreen4",#black
-relief=> "groove",#sunken
-width=>14,
-listwidth=>40);

$BEporttty->place(-x=>200, -y=>40);
$BEporttty->insert("end", "/dev/ttyS0");
$BEporttty->insert("end", "/dev/ttyS1");
$BEporttty->insert("end", "/dev/ttyS2");
$BEporttty->insert("end", "/dev/ttyS3");
$BEporttty->insert("end", "/dev/ttyS4");
$BEporttty->insert("end", "/dev/ttyS5");
$BEporttty->insert("end", "/dev/ttyUSB0");
$BEporttty->insert("end", "/dev/ttyUSB1");
$BEporttty->insert("end", "/dev/ttyUSB2");
$BEporttty->insert("end", "/dev/ttyUSB3");
$BEporttty->insert("end", "/dev/ttyUSB4");
$BEporttty->insert("end", "/dev/ttyUSB5");

### param pour TEMMA 19200,8,N,1 (defaut : 19200,E,8,1)
$fenetre_configRS232->Label(	# titre
	-font=>$fonte,
	#-foreground=>"tomato3",
	#-background=>"black",
	-text=>"Paramètres par defaut :")->place(-x=>10, -y=>80);

### param pour TEMMA 19200,8,N,1 (defaut : 19200,E,8,1)
$fenetre_configRS232->Label(	# titre
	-font=>$fonte,
	#-foreground=>"tomato3",
	#-background=>"black",
	-text=>"19200,E,8,1")->place(-x=>150, -y=>80);

$fenetre_configRS232->Label(
	-font=>$fonte,
	#-foreground=>"tomato3",
	#-background=>"black",
	-text=>"Testez ces paramètres :")->place(-x=>10, -y=>110);

$param_port_temma="19200,E,8,1";
$fenetre_configRS232->Entry(
	-width => 15,
	-font=>$fonte,
	#-foreground=>"tomato3",
	#-background=>"gray30",
	-textvariable=>\$param_port_temma)->place(-x=>150, -y=>110);

my $bouton_valider_port=$fenetre_configRS232->Button(
	-text => "Valider",
	-command =>\&config_RS232,
	-font=>$fonte,
	#-highlightbackground=>"gray30",
	#-foreground=>"black",
	#-background=>"DarkOrange4",
	-width=>"7"
	#-relief => "groove"
	)->place(-x=>290, -y=>110);#, -height=>20

# label : message de retour du test du port
#my $label_msg_retour = $fenetre_configRS232->Label(
#	-borderwidth=>"1",
#	#-highlightbackground=>"blue",
#	-highlightthickness=>"0",
#	-relief=>"groove",
#	-font=>$fonte,
#	#-foreground=>"tomato3",
#	#-background=>"black",
#	-textvariable=>\$msg_configport)->place(-x=>10, -y=>150);


# zone de Text pour les messages d'état de la connexion sur le port serie et sur la Temma
$text_msg_retour = $fenetre_configRS232->Scrolled ("ROText",
		-scrollbars => 'se',
		)->place(-x=>10, -y=>160, -width=>360, -height=>230);



$bouton_fermerfconfigRS232=$fenetre_configRS232->Button(	# bouton masquer la fenetre
	-text=>"Fermer",
	-font=>$fonte,
	#-foreground=>"black",
	#-background=>"SlateGray4",
	-width=>"7",
	-command => sub{$fenetre_configRS232->withdraw;
			print "Fermeture fenetre de config du port serie\n";}
	)->place(-x=>290, -y=>410);} # fin de if Exists toplevel , -height=>20

	else	{
		print "Fenetre de config du port serie deja ouverte\n";
		$fenetre_configRS232->deiconify();
		$fenetre_configRS232->raise();
		}

if(defined($msg_configport)){ # affichage du dernier mesg d'etat possible
	$text_msg_retour->insert('end', $msg_configport);# affichage msg d'etat ds fenetre param port serie
	}
} # --------- fin de ouvrir_fconfig_RS232




# ---------- fonction config_RS232 --- script de config du port
# selon l'OS Linux ou Windows: ecriture fichier de config : temmaRS232.cfg
sub config_RS232{

if ($OS_win) {
	$port =$nomPortserieWindows;
    	#$port = 'COM1';
    	$ob = Win32::SerialPort->new ($port);
	}
else {	$port =$nomPortserieLinux;
    	#$port = '/dev/temma';	# si lien symb
    	#$port = '/dev/ttyS0';	# si port serie
    	#$port = '/dev/ttyUSB0';# si USB2Serial
    	$ob = Device::SerialPort->new ($port);
	}
die "Can't open serial port $port: $^E\n" unless ($ob);


# retour d'infos
print "Port serie validé :\t$port $param_port_temma\n";	# retour console
print "Params port serie :\t$param_port_temma\n";	# retour console
$msg_configport= "Port : $port\nParams : $param_port_temma\n";	# message d'etat connexion pour fenetre param port serie
$text_msg_retour->insert('end', $msg_configport);		# affichage msg d'etat ds fenetre param port serie

$ob->user_msg(1);	# misc. warnings
$ob->error_msg(1);	# hardware and data errors

### param pour TEMMA 19200,8,N,1 (defaut : 19200,E,8,1)
$ob->baudrate(19200);	# vitesse de transfert
#$ob->parity("none");	# si pas de parité
$ob->parity_enable(1);  # for any parity except "none"
$ob->parity("even");	# "even" (=paire), "odd" (=impaire), "none"
$ob->databits(8);	# bit de données
$ob->stopbits(1);	# bit d'arret
$ob->handshake('rts');	# controle de flux

$ob->write_settings;	# enregistrement des parametres
$ob->save("temmaRS232.cfg");# ecriture du fichier de config
select (undef, undef, undef, 0.25);

# retour d'infos
print "Config du port serie :\tsemble OK\nSauvegarde config :\ttemmaRS232.cfg\n"; # retour console
$msg_configport="Sauvegarde config : temmaRS232.cfg\n"; # message d'etat connexion pour fenetre param port serie
$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie

# restart de la config du port
$ob->restart("temmaRS232.cfg"); # pour tester la config et l'existante du fichier temmaRS232.cfg
select (undef, undef, undef, 0.25);

# retour d'infos
print "Restart config avec fichier temmaRS232.cfg\n"; # retour console
$msg_configport="Restart config\n"; # message d'etat connexion pour fenetre param port serie
$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie

&test_serialportalias;

# test de connexion avec lecture temma_version et afficher ds Temma version ds label fenetre param port
&test_getTemmaVersion;

}#----------- fin de config_RS232



# ---------- fonction test_serialportalias ----- pour verif présence du port avec le module serialport
sub test_serialportalias{
# test sur l'alias nom du port
$aliasport = $ob->alias;
select (undef, undef, undef, 0.25);
# $ob->lookclear;

if (defined $aliasport){
	print "Test serialport alias :\t$aliasport\n";	# retour console
	print "Test serialport alias :\tOK\n"; 		# retour console port serie ok
	$msg_configport="connexion possible sur $aliasport\n";	# message d'etat connexion pour fenetre param port serie

	if ($OS_win) { # si Windows
		$nomPortserieWindows=$aliasport;
	} else	{$nomPortserieLinux=$aliasport;}

	if(Exists($fenetre_configRS232)){
		$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie
		#$fenetre_configRS232->update;
	}
}else{	#print "Test serialport alias :\tFAIL\n";	# retour console port serie non ok
	$msg_configport="Test serialport alias : Echec\nFaire config du port\n";# message d'etat connexion pour fenetre param port serie
	print "$msg_configport";
	&ouvrir_fconfigRS232;
	&ouvrir_cabledialogbox;				# affiche dialog erreur
}

}#----------- fin de test_serialportaliasalias



# ---------- fonction test_getTemmaVersion ----- TEST GET TEMMA VERSION pour verif connexion et alimentation Temma
sub test_getTemmaVersion{
$getTemmaVersion = "0"; # init var
# get Temma version : v
$ob->lookclear;
#select (undef, undef, undef, 0.25);
$ob->write("v\r\n");
select (undef, undef, undef, 0.25);
$getTemmaVersion = $ob->input;		# lecture $getTemmaVersion
select (undef, undef, undef, 0.25);
chomp($getTemmaVersion);

# TEST CABLAGE ET ALIM : port serie et connexion temma ok si retour même partiel de la chaine $getTemmaVersion
# test si les 3 premiers caracteres retournés sont "ver" ou "er" ou "r"
#$try_ver=substr($getTemmaVersion,0,3);
#print "Test cablages ver :\t$try_ver\n";
$try_nl=substr($getTemmaVersion,-1);
if(($getTemmaVersion=~ m/er/)or($try_nl eq "\r")){ # todo : mieux
#if(($try_ver eq "ver") or ($try_ver eq "er ") or ($try_ver eq "  r")){ # pas sur
	print "Test getTemmaVersion :\t$getTemmaVersion\n";
	print "Test connexion Temma :\tOK\n";
	print "Session Temma :\t\tpossible -> cliquez sur Temma Connect\n";
	print "et vérifiez les paramètres de votre site\n";

	# message d'etat connexion pour fenetre param port serie
	if(Exists($fenetre_configRS232)){
		$msg_configport="Temma Version : $getTemmaVersion\nTest connexion Temma : OK\nSession Temma possible\n";
		$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie
		$msg_configport="Fermez cette fenetre\nCliquez sur Temma Connect\nVérifiez les paramètres du site\n";
		$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie
	}

# reactiver le bouton de connexion manuelle à la Temma (si desactivé sinon ecrase les valeurs)
$bouton_start_temma -> configure(
			-state=>'normal',
			-text=>"Temma Connect",
			-foreground=>"Black");
} # fin du if

# todo : faire qqchose avec TemmaVersion si Temma1 Jr +tracking comete/lune...
# verif si Temma branchée ou si cablages ok sinon DialogBox et message d'erreur ds fenetre param serialport
else {	$msg_configport="Test connexion Temma : Echec PB alimentation\nFermez le driver\n";
	print "$msg_configport";

	$bouton_start_temma -> configure(
			-state=>'disable',
			-text=>"Temma Connect",
			-foreground=>"Black");

# ouverture dialogue $cable_dialogbox pour message d'erreur cablage :
&ouvrir_fconfigRS232;
&ouvrir_cabledialogbox;

} # fin du else
} # ---- fin de test_getTemmaVersion -------------------------





# ---------- fonction ouvrir_cabledialogbox ------------------ DIALOG PB CABLAGE PORT SERIE->TEMMA
sub ouvrir_cabledialogbox{
# boite de dialogue pour les messages d'erreurs type PB d'alim ou de cablage
$cable_dialogbox=$fenetre_driver->DialogBox(
					-title=>"Probleme de cablage",
					-buttons=>["Fermer", "Continuer"],
					-default_button=>"Fermer");

$cable_dialogbox->add("Label",
	-text=>"Echec de connexion sur la Temma\n1) Fermez le driver\n2) Vérifiez le cablage sur le port serie\n3) Vérifiez l'alimentation de la Temma"
	)->pack;
my $userchoice=$cable_dialogbox->Show();
if ($userchoice eq "Fermer"){	print "Fermer le driver\n";
				&quitter;}
else {	print "Continuer\n";
	#&test_getTemmaVersion; # re-test mais bloque l'applic
	# message d'etat connexion pour fenetre param port serie
	if(Exists($fenetre_configRS232)){
		#$msg_configport="Temma Version : $getTemmaVersion\nTest connexion Temma : OK\nSession Temma possible\n";
		#$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie
		#$msg_configport="Test connexion Temma : Echec -> PB alimentation\nFermez le driver\n";		$msg_configport="Test connexion Temma : Echec -> PB alimentation\nFermez le driver\n";
		$text_msg_retour->insert('end', $msg_configport); # affichage msg d'etat ds fenetre param port serie
	}
}
} # ---- fin de ouvrir_cabledialogbox ------------------------



# ---------- fonction ouvrir_aliasdialogbox ------------------ DIALOG PB CABLAGE PC->PORT SERIE
sub ouvrir_aliasdialogbox{
# boite de dialogue pour les messages d'erreurs type PB de connexion ou abscence du port serie
$alias_dialogbox=$fenetre_driver->DialogBox(
					-title=>"Probleme de port serie",
					-buttons=>["Fermer", "Continuer"],
					-default_button=>"Fermer");

$alias_dialogbox->add("Label",
	-text=>"Echec de connexion sur port serie\n1) Fermez le driver\n2) Vérifier le cablage sur le port serie\n3) Vérifier config et cablage si USB2Serial"
	)->pack;
my $userchoice=$alias_dialogbox->Show();
if ($userchoice eq "Fermer"){	print "Fermer le driver\n";
				&quitter;}
else {print "Continuer\n";}
} # ---- fin de ouvrir_aliasdialogbox ------------------------






# *************************************************************
# ++++++++++++++++++++ FENETRE RAQUETTE +++++++++++++++++++++++
# *************************************************************

# ---------- fonction ouvrir_raquette -------------------------
sub ouvrir_raquette{
if(!Exists($fenetre_raquette)){
print "\nOuverture fenetre raquette de commande ----\n";

$fenetre_raquette = $fenetre_driver->Toplevel(	-width=>220,
						-height=>310,
						-background=>"black"
						); # Toplevel $fenetre_raquette

$fenetre_raquette->title("Raquette");


#my $frame_raquette = $fenetre_raquette->Frame(
#	-width=>150,
#	-height=>200,
#	-background=>"black",
	#-borderwidth=>1,
#	)->pack;#place(-x=>5, -y=>5);



# ---- RAQUETTE DE CDE : dessin de la zone raquette

$valetat_CBinvRA=0;				# init du Checkbutton INV RA pour rattrapages RA ok avec PTW
$CB_invRA=$fenetre_raquette->Checkbutton(	# inverseur RA
	#-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"black",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"gray30",
	#-activebackground=>"tomato3",
	-selectcolor=>"DarkSeaGreen4",
	-text=>"inv\nRA",
	-variable=>\$valetat_CBinvRA,
	-command=> sub{
		if(($valetat_CBinvRA==1)&&($etat_sessionTemma==1)){
			print "Switch inv RA ON\n";
			&raquette_invRA;
			}
		if(($valetat_CBinvRA==0)&&($etat_sessionTemma==1)){
			print "Switch inv RA OFF\n";
			&raquette_invRA; # par defaut
			}
		}# fin de sub
)->place(-anchor=>'ne',-x=>55, -y=>10,-width=>30, -height=>30);#-width=>30,-height=>30


$valetat_CBswitchHSNS=0;			# init du Checkbutton HS/NS sur HS
$CB_switchHSNS=$fenetre_raquette->Checkbutton(	# switch vitesse rapide HS / normal NS
	#-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"black",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"firebrick",
	#-activebackground=>"tomato3",
	-selectcolor=>"DarkSeaGreen4",
	-text=>"HS",
	-variable=>\$valetat_CBswitchHSNS,
	-command=> sub{
		if(($valetat_CBswitchHSNS==0)&&($etat_sessionTemma==1)){
			print "Switch HS\n";
			$CB_switchHSNS->configure(-text=>"HS");
		}
		if(($valetat_CBswitchHSNS==1)&&($etat_sessionTemma==1)){
			print "Switch NS\n";
			$CB_switchHSNS->configure(-text=>"NS");
			#&set_correctionNS; # tester si utile ici
		}
		}# fin de sub
)->place(-anchor=>'nw',-x=>60, -y=>10,-width=>30, -height=>30);#-width=>30,


$valetat_CBinvDEC=0;				# init du Checkbutton INV DEC pour rattrapages DEC ok avec PTW
$CB_invDEC=$fenetre_raquette->Checkbutton(	# inverseur DEC
	#-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"black",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"gray30",
	#-activebackground=>"tomato3",
	-selectcolor=>"DarkSeaGreen4",
	-text=>"inv\nDec",
	-variable=>\$valetat_CBinvDEC,
	-command=> sub{
		if(($valetat_CBinvDEC==1)&&($etat_sessionTemma==1)){
			print "Switch inv DEC ON\n";
			&raquette_invDEC;
			}
		if(($valetat_CBinvDEC==0)&&($etat_sessionTemma==1)){
			print "Switch inv DEC OFF\n";
			&raquette_invDEC; # par defaut
			}
		}# fin de sub
)->place(-anchor=>'nw',-x=>95, -y=>10,-width=>30, -height=>30);#-width=>30,



# CB autoguide : todo fonction autoguide
$valetat_autoguide=0; # init autoguide OFF
$CB_autoguide=$fenetre_raquette->Checkbutton(
	#-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"black",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"gray30",
	#-activebackground=>"tomato3",
	-selectcolor=>"firebrick",#"DarkSeaGreen4",
	-text=>"AG",
	-variable=>\$valetat_autoguide,
	-command=> sub{
		if(($valetat_autoguide==1)&&($etat_sessionTemma==1)){
			print "Switch autoguide ON\n";
			$CB_autoguide->configure(-foreground=>"yellow");
			#&autoguide(ON); # session autoguide->ON
			}
		if(($valetat_autoguide==0)&&($etat_sessionTemma==1)){
			print "Switch autoguide OFF\n";
			$CB_autoguide->configure(-foreground=>"black");
			#&autoguide(OFF); # par defaut
			}
		}# fin de sub
)->place(-anchor=>'nw',-x=>160, -y=>10,-width=>40, -height=>30);#-width=>30,x=>147


$B_DECplusHS=$fenetre_raquette->Button(		# --- bouton DEC+
	-text=>"^",
	-font=>$fonte,
	-foreground=>"yellow",
	-background=>"DeepSkyBlue4",
	-activebackground=>"DeepSkyBlue3",
#	-command=>\&raquetteDECplus,
)->place(-x=>60, -y=>70, -width=>30, -height=>30);

$B_DECmoinsHS=$fenetre_raquette->Button(	# --- bouton DEC-
	-text=>"v",
	-font=>$fonte,
	-foreground=>"yellow",
	-background=>"DeepSkyBlue4",
	-activebackground=>"DeepSkyBlue3",
#	-command=>\&raquetteDECmoins,
)->place(-x=>60, -y=>150, -width=>30, -height=>30);

$valetat_encodeur=1;					# init du Checkbutton encodeurs ON/OFF sur ON
$CB_encodeurONOFF=$fenetre_raquette->Checkbutton(	# bouton encodeur ON/OFF
	#-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	-foreground=>"#00ff00",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"gray30",
	#-activebackground=>"tomato3",
	-selectcolor=>"DarkSeaGreen4",
	-text=>"E",
	-variable=>\$valetat_encodeur,
	-command=> sub{
		if(($valetat_encodeur==1)&&($etat_sessionTemma==1)){
			print "Encodeurs ON\n";
			$CB_encodeurONOFF->configure(-foreground=>"#00ff00");
			}
		if(($valetat_encodeur==0)&&($etat_sessionTemma==1)){
			print "Encodeurs OFF\n";
			$CB_encodeurONOFF->configure(-foreground=>"black");
			}
		}# fin de sub
)->place(-x=>60, -y=>110, -width=>30, -height=>30);


$B_RAplusHS=$fenetre_raquette->Button(		# --- bouton RA+
	-text=>"<",
	-font=>$fonte,
	-foreground=>"yellow",
	-activebackground=>"tomato3",
	-background=>"firebrick",
# 	-command=>\&raquetteRAplus,
)->place(-x=>20, -y=>110, -width=>30, -height=>30);

$B_RAmoinsHS=$fenetre_raquette->Button(		# --- bouton RA-
	-text=>">",
	-font=>$fonte,
	-foreground=>"yellow",
	-activebackground=>"tomato3",
	-background=>"firebrick",# tomato3
#	-command=>\&raquetteRAmoins,
)->place(-x=>100, -y=>110, -width=>30, -height=>30);



# checkbutton pour option parallelisme des scales : $RA_ns_val=$DEC_ns_val
#$RA_ns_val=$DEC_ns_val=$paraRADEC_ns_val=90;# init des valeurs de rattrapages NS (vitesses lentes)
$paraRADEC_ns_val=90;		# init des valeurs de rattrapages NS (vitesses lentes sur RA/DEC)
$valetat_para_nsradec=1; 	# init du Checkbutton
$CB_para_nsradec = $fenetre_raquette->Checkbutton(
	#-state=>'disable',
	#-anchor=>'w',#center
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"DarkSeaGreen4",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"gray30",#"DeepSkyBlue4",
	-activebackground=>"tomato3",
	-selectcolor=>"tomato3",
	-width=>5,
	#-height=>1,
	-text=>"Lier",
	-variable=>\$valetat_para_nsradec,
	-command=> sub{
		if($valetat_para_nsradec==1){
			print "Parallelisme sur reglage des rattrapages NS RA/DEC\n";
			$RA_ns_scale->configure(-variable=>\$paraRADEC_ns_val);
			$DEC_ns_scale->configure(-variable=>\$paraRADEC_ns_val);
			#$RA_ns_val=$DEC_ns_val=0;
			#&set_correctionNS;
			}

		if($valetat_para_nsradec==0){
			print "Non parallelisme sur reglage des rattrapages NS RA/DEC\n";
			$RA_ns_scale->configure(-variable=>\$RA_ns_val);
			$DEC_ns_scale->configure(-variable=>\$DEC_ns_val);
			#$paraRADEC_ns_val=0;
			#&set_correctionNS;
			}
		}# fin de sub
)->place(-x=>160, -y=>206,-width=>40,-height=>20);


$boutonSET_corNS=$fenetre_raquette->Button(		# bouton set valeurs correction speed NS
	-text=>"Set",
	-font=>$fonte,
	-highlightbackground=>"gray30",
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	#-width=>"3",
	-command=>\&set_correctionNS
)->place(-x=>160, -y=>233,-width=>40,-height=>20);


# barre de réglage progressif vitesse lente RA
$RA_ns_scale=$fenetre_raquette->Scale(	-from=>0,
					-to=>90,
					-resolution=>1,
					-sliderlength=>50,
					-orient=>'horizontal',
					-variable=>\$paraRADEC_ns_val,
					-foreground=>"tomato3",
					-background=>"black",
					-troughcolor=>"gray30",
					-highlightcolor=>"gray30",
					-borderwidth=>1
)->place(-x=>23, -y=>210);#, -width=>30, -height=>30
#
## barre de réglage progressif vitesse lente DEC
$DEC_ns_scale=$fenetre_raquette->Scale(	-from=>0,
					-to=>90,
					-resolution=>1,
					-sliderlength=>50,
					-orient=>'vertical',
					-variable=>\$paraRADEC_ns_val,
					-foreground=>"tomato3",
					-background=>"black",
					-troughcolor=>"gray30",
					-highlightcolor=>"gray30",
					-borderwidth=>1
)->place(-x=>160, -y=>70);#, -width=>30, -height=>30

$bouton_Fermer_raquette=$fenetre_raquette->Button(	# bouton masquer la fenetre
	-text=>"Masquer",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-command => sub{$fenetre_raquette->withdraw;
			print "Masquer fenetre raquette\n";}
)->place(-x=>50, -y=>280, -height=>20);


} # fin de if Exists toplevel
else	{
	print "Fenetre raquette deja ouverte\n";
	$fenetre_raquette->deiconify();
	$fenetre_raquette->raise();
	}

&raquette_invRA; # inverseur RA
&raquette_invDEC;# inverseur DEC
} # ------- fin de ouvrir_raquette



# emulation de l'ancienne raquette avec inverseurs RA et Dec + switch High Speed / Normal Speed
# liaisons fonctions pour boutons raquette selon inverseurs RA/DEC
# @boutons_raquette=($B_DECplusHS,$B_DECmoinsHS,$B_RAplusHS,$B_RAmoinsHS);

# ---- raquette_invDEC
sub raquette_invDEC{
if ($valetat_CBinvDEC==0){ # par defaut et en coherence avec PTW (ou si inversion DEC re-cliqué)
	# --- bouton DEC+
	$B_DECplusHS->bind("<ButtonPress-1>", sub {
		$idB_DECplusHS=$B_DECplusHS->repeat(500,\&raquetteDECplus);# 1000ms=>ok
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_DECplusHS->bind("<ButtonRelease-1>", sub {
		$B_DECplusHS->afterCancel($idB_DECplusHS);
		$ob->write("MA\r\n");		# arrêt deplacement raquette : MA
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});

	# --- bouton DEC-
	$B_DECmoinsHS->bind("<ButtonPress-1>", sub {
		$idB_DECmoinsHS=$B_DECmoinsHS->repeat(500,\&raquetteDECmoins);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_DECmoinsHS->bind("<ButtonRelease-1>", sub {
		$B_DECmoinsHS->afterCancel($idB_DECmoinsHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});
} # fin du if

if ($valetat_CBinvDEC==1){ # en coherence avec PTE si inversion DEC cliqué
	# --- bouton DEC+ inversé
	$B_DECplusHS->bind("<ButtonPress-1>", sub {
		$idB_DECplusHS=$B_DECplusHS->repeat(500,\&raquetteDECmoins);# 1000ms=>ok
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_DECplusHS->bind("<ButtonRelease-1>", sub {
		$B_DECplusHS->afterCancel($idB_DECplusHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});

	# --- bouton DEC- inversé
	$B_DECmoinsHS->bind("<ButtonPress-1>", sub {
		$idB_DECmoinsHS=$B_DECmoinsHS->repeat(500,\&raquetteDECplus);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_DECmoinsHS->bind("<ButtonRelease-1>", sub {
		$B_DECmoinsHS->afterCancel($idB_DECmoinsHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});
} # fin du if
} # fin de raquette_invDEC


# ---- raquette_invRA
sub raquette_invRA{
if ($valetat_CBinvRA==0){ # par defaut et en coherence avec PTW (ou si inversion RA re-cliqué)
	# --- bouton RA- par defaut
	$B_RAmoinsHS->bind("<ButtonPress-1>", sub {
		$idB_RAmoinsHS=$B_RAmoinsHS->repeat(500,\&raquetteRAmoins);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_RAmoinsHS->bind("<ButtonRelease-1>", sub {
		$B_RAmoinsHS->afterCancel($idB_RAmoinsHS);
		$ob->write("MA\r\n"); 		# arrêt deplacement raquette : MA
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});

	# --- bouton RA+ par defaut
	$B_RAplusHS->bind("<ButtonPress-1>", sub {
		$idB_RAplusHS=$B_RAplusHS->repeat(500,\&raquetteRAplus);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_RAplusHS->bind("<ButtonRelease-1>", sub {
		$B_RAplusHS->afterCancel($idB_RAplusHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});
} # fin du if

if ($valetat_CBinvRA==1){ # si inversion RA cliqué et en coherence avec PTE
	# --- bouton RA- inversé
	$B_RAmoinsHS->bind("<ButtonPress-1>", sub {
		$idB_RAmoinsHS=$B_RAmoinsHS->repeat(500,\&raquetteRAplus);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_RAmoinsHS->bind("<ButtonRelease-1>", sub {
		$B_RAmoinsHS->afterCancel($idB_RAmoinsHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});

	# --- bouton RA+ inversé
	$B_RAplusHS->bind("<ButtonPress-1>", sub {
		$idB_RAplusHS=$B_RAplusHS->repeat(500,\&raquetteRAmoins);
		$astre_pointe="recentrage raquette $nom_objet";
	});
	$B_RAplusHS->bind("<ButtonRelease-1>", sub {
		$B_RAplusHS->afterCancel($idB_RAplusHS);
		$ob->write("MA\r\n");
		select (undef, undef, undef, 0.25);
		$astre_pointe=$nom_objet;
	});
} # fin du if
} # fin de raquette_invRA





############### Commandes raquette (protocole) ###############

# --- raquetteDECmoins : DEC HS ou NS enc ON ou OFF
sub raquetteDECmoins{
if(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==0)){
	print "raquetteDECmoins HS enc ON : MQ\n";
	$ob->write("MQ\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==0)){
	print "raquetteDECmoins HS enc OFF : Mq\n";
	$ob->write("Mq\r\n");
	select (undef, undef, undef, 0.25);
	}

elsif(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==1)){
	print "raquetteDECmoins NS enc ON : MP\n";
	$ob->write("MP\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==1)){
	print "raquetteDECmoins NS enc OFF : Mp\n";
	$ob->write("Mp\r\n");
	select (undef, undef, undef, 0.25);
	}
} # fin de raquetteDECmoins


# --- raquetteDECplus
sub raquetteDECplus{
if(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==0)){
	print "raquetteDECplus HS enc ON : MI\n";
	$ob->write("MI\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==0)){
	print "raquetteDECplus HS enc OFF : Mi\n";
	$ob->write("Mi\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==1)){
	print "raquetteDECplus NS enc ON : MH\n";
	$ob->write("MH\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==1)){
	print "raquetteDECplus NS enc OFF : Mh\n";
	$ob->write("Mh\r\n");
	select (undef, undef, undef, 0.25);
	}
} # fin de raquetteDECplus


# --- raquetteRAplus:  RA HS ou NS enc ON ou OFF
sub raquetteRAplus{
if(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==0)){
	print "raquetteRAplus HS enc ON : ME\n";
	$ob->write("ME\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==0)){
	print "raquetteRAplus HS enc OFF : Me\n";
	$ob->write("Me\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==1)){
	print "raquetteRAplus NS enc ON : MD\n";
	$ob->write("MD\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==1)){
	print "raquetteRAplus NS enc OFF : Md\n";
	$ob->write("Md\r\n");
	select (undef, undef, undef, 0.25);
	}
} # fin de raquetteRAplus


# --- raquetteRAmoins
sub raquetteRAmoins{
if(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==0)){
	print "raquetteRAmoins HS enc ON : MC\n";
	$ob->write("MC\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==0)){
	print "raquetteRAmoins HS enc OFF : Mc\n";
	$ob->write("Mc\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==1)&&($valetat_CBswitchHSNS==1)){
	print "raquetteRAmoins NS enc ON : MB\n";
	$ob->write("MB\r\n");
	select (undef, undef, undef, 0.25);
	}
elsif(($valetat_encodeur==0)&&($valetat_CBswitchHSNS==1)){
	print "raquetteRAmoins NS enc OFF : Mb\n";
	$ob->write("Mb\r\n");
	select (undef, undef, undef, 0.25);
	}
} # fin de raquetteRAmoins






####################### ------------ INFOS ------------- ######################
# ENCODEURS ET MONTURES TEMMA
# EM-200 Temma-2 (et Jr)
# encodeur RA  1tr->12arcmin (480arcsec)  reso-> 800pas (200pas*4) soit precision RA  : 0.6sec
# encodeur DEC 1tr->80arcmin (4800arcsec) reso->1200pas (300pas*4) soit precision DEC : 6sec
#
#
# protocole cde s : retourne s0 pendant la session en cours et s1 pendant un goto
# autoguidage ON/OFF : cde LG
#
# info sur lx200xed process
#[remi@pcremix temma]$ ps axw | grep lx200xed
# 1627 ?  S  0:00 lx200xed -m /usr/lib/xephem/fifos/xephem_in_fifo
# 			   -g /usr/lib/xephem/fifos/xephem_loc_fifo -e


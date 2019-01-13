##!/usr/bin/perl -w

#### fichier lib pour driverTemma.pl [ou fork+exec]
# script listes.pm
# date dernière modif : 08/06/03
# remi.petitdemange@calixo.net


# script d'affichage des fichiers listes d'objets celestes de XEphem
# formats compatibles : edb, txt
# todo : xml et html

#use Tk;
#require Tk::NoteBook;
#use Tk::HList;	  # pour hlist
#use Tk::ItemStyle;# pour hlist





# -------------------------------- ####################### -------------------------------- #
# -------------------------------- # - FENETRE LISTING - # -------------------------------- #
# -------------------------------- ####################### -------------------------------- #

sub listing{
# --- interface

if(!Exists($fenetre_listes)){
print "\nOuverture fenetre listes ----\n";
$fenetre_listes = $fenetre_driver->Toplevel(-background=>"black"); # Toplevel $fenetre_listes
$fenetre_listes->geometry("560x450+380+470");
$fenetre_listes->title("Listes");

#$fenetre_listes->bind('<Control-g>' => \&get_hlist_selection);
#$fenetre_listes->bind('<ButtonRelease-1>' => \&get_hlist_selection);

#$script_name=$fenetre_listes->appname;	# appname pour utiliser la methode send
#print "\n\n------ ouverture de script $script_name ------\n";
#print "version en cours :\t$script_name\n";



# --- frame globale
$frame_globale = $fenetre_listes->Frame(-relief=>'flat',
					-background=>'black'
					)->pack(-side=>'top',-expand=>0,-fill=>'both',-padx =>4,-pady =>4);#exp 1

# --- frame notebook
$frame_notebook = $frame_globale->Frame(-relief=>'flat',
					-background=>'black'
					)->pack(-side=>'top',-expand=>0,-fill=>'both',-padx =>0,-pady =>0);#exp 1


# --- creation et affichage du notebook
$nb=$frame_notebook->NoteBook()->pack(-side=>'top',-expand=>0,-fill=>'both',-padx =>0,-pady =>0);#exp 1

# config des pages du notebook

$page_star=$nb->add('page_star',
		-label=>'liste étoiles',
		-createcmd=>\&affiche_hlist_star,		# creation de hlist_star
		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
				print "$page_visible\n"; 	# test retour console
				$boutonChoisir->configure(-state=>'disable');
				$hlist = $hlist_star;
				$hlist->bind('<ButtonRelease-1>' => \&test_selec_hlist);
				$boutonUpdateListe->configure(-state=>'normal');
				}
		);

$page_perso=$nb->add('page_perso',
		-label=>'liste perso',
		-createcmd=>\&affiche_hlist_perso,		#creation de hlist_perso
		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
				print "$page_visible\n"; 	# test retour console
				$boutonChoisir->configure(-state=>'disable');
				$hlist = $hlist_perso;
				$hlist->bind('<ButtonRelease-1>' => \&test_selec_hlist);
				$boutonUpdateListe->configure(-state=>'normal');
				}
		);

$page_edb=$nb->add('page_edb',
		-label=>'liste edb',
		-createcmd=>\&affiche_hlist_edb,		# creation de hlist_edb
		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
				print "$page_visible\n"; 	# test retour console
				$boutonChoisir->configure(-state=>'disable');
				$hlist = $hlist_edb;
				$hlist->bind('<ButtonRelease-1>' => \&test_selec_hlist);
				$boutonUpdateListe->configure(-state=>'normal');
				}
		);

$page_txt=$nb->add('page_txt',
		-label=>'liste txt',
		-createcmd=>\&affiche_hlist_txt,		# creation de hlist_txt
		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
				print "$page_visible\n"; 	# test retour console
				$boutonChoisir->configure(-state=>'disable');
				$hlist = $hlist_txt;
				$hlist->bind('<ButtonRelease-1>' => \&test_selec_hlist);
				$boutonUpdateListe->configure(-state=>'normal');
				}
		);

################################# onglets supplémentaires non utilisés pour le moment
# todo
#$page_html=$nb->add('page_html',
#		-label=>'liste html',
#		-createcmd=>sub	{# creation de frame
#				$frame_hlisthtml = $page_html->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
#				},
#		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
#				print "$page_visible\n"; 	# test retour console
#				$hlist=0;
#				@objetselec=();
#				#$hlist->bind('<Control-g>', [Tk::break]); # test
#				$boutonUpdateListe->configure(-state=>'disable'); # provisoire
#				$boutonChoisir->configure(-state=>'disable');# provisoire
#				}
#		);

# todo
#$page_xml=$nb->add('page_xml',
#		-label=>'liste xml',
#		-createcmd=>sub	{# creation de frame
#				$frame_hlistxml = $page_xml->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
#				},
#		-raisecmd=>sub	{$page_visible=$nb->raised();	# voir si page affichée (raisecmd)
#				print "$page_visible\n"; 	# test retour console
#				$hlist=0;
#				@objetselec=();
#				#$hlist->bind('<Control-g>', [Tk::break]); # test
#				$boutonUpdateListe->configure(-state=>'disable'); # provisoire
#				$boutonChoisir->configure(-state=>'disable');# provisoire
#				}#fin de sub de raisecmd
#		);
#################################


# --- cadre pour boutons sur hlist
$frame_boutonlistetransfer = $fenetre_listes->Frame(	#-relief=>'groove',
				#-borderwidth=>1,
				-background=>'black',
)->pack(-side=>'top',-expand=>0, -fill=>'both',-padx =>4,-pady =>0);


# bouton update hlist visible
$boutonUpdateListe=$frame_boutonlistetransfer->Button(
	-state=>'disable',
	-text => "Update",
	-command => \&update_fichier,
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DeepSkyBlue4",
	#-width=>7,
	#-height=>1,
	#-relief => "groove"
	)->pack(-side=>'left',-anchor=>'nw',-expand=>0,-fill=>'none',-padx =>4,-pady =>2);

# bouton choisir : transfert objets de hlist visible vers Lisbox
$boutonChoisir=$frame_boutonlistetransfer->Button(
	-state=>'disable',
	-text => "Choisir",
	-command => \&get_hlist_selection,
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DeepSkyBlue4",
	#-width=>7,
	#-height=>1,
	#-relief => "groove"
	)->pack(-side=>'left',-anchor=>'nw',-expand=>0,-fill=>'none',-padx =>4,-pady =>2);#4 2


# checkbutton d'affichage des objets ds listbox sur ZView
$valetat_zview=0; # init du check bouton zview
#$CB_placesurZView = $frame_boutons_ls->Checkbutton(
$CB_placesurZView=$frame_boutonlistetransfer->Checkbutton(
	-state=>'disable',
	#-anchor=>'w',#center
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"DarkSeaGreen4",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"DeepSkyBlue4",
	-activebackground=>"tomato3",
	-selectcolor=>"tomato3",
	-width=>7,
	-height=>1,
	-text=>"ZView",
	-variable=>\$valetat_zview,
	-command=> sub{
		if(($valetat_zview==1)&&($etat_sessionTemma==1)){
			print "Visu ZView ON\n";
			&listeobjetzview;
			$id_posliste=$canvaszv->repeat(1000,\&update_posliste); # update pos pixmap/zview selon lst (timeout ok à 1s)
			$CB_placesurZView->configure(-state=>'disable');
		}
		if(($valetat_zview==1)&&($etat_sessionTemma==0)){ ######## verifier ici
			print "Visu ZView non ok\n";
			#&listeobjetzview;
			#$id_posliste=$canvaszv->repeat(1000,\&update_posliste); # update pos pixmap sur zview selon lst
			#$CB_placesurZView->configure(-state=>'disable');
		}
		#else{print "Visu ZView OFF\n";}
		#if($valetat_zview==0){
		#	print "Visu ZView OFF\n";
		#	#$CB_placesurZView->afterCancel($id_posliste);# stop update pos pixmap sur zview selon lst
		#	#$id_posliste->cancel(); # stop update pos pixmap sur zview selon lst
		#}
		}# fin de sub
#)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>2,ipady=>3);
)->pack(-side=>'left',-anchor=>'nw',-expand=>0,-fill=>'none',-padx =>4,-pady =>2);



# --- liste des objets sélectionnés
# cadre pour listbox
$frame_LBtransfer = $fenetre_listes->Frame(	#-relief=>'groove',
				#-borderwidth=>1,
				-background=>'black',
)->pack(-side=>'top',-expand=>1, -fill=>'both',-padx =>4,-pady =>4);



@listetransferee=();
$LBlistetransferee = $frame_LBtransfer->Scrolled("Listbox", -scrollbars => 'e',
						-takefocus=>1,
						-font=>$fonte,
						-width=>35,
						-height=>6,
						-relief => 'groove',
						-foreground=>'DarkSeaGreen4',
						-highlightbackground=>'gray30',
						-highlightcolor=>'gray60',
						-selectforeground=>'tomato3',
						-selectbackground=>'gray30',
						##-setgrid=>0,
						-background=>'black',
)->pack(-side=>'left',-anchor=>'n',-padx =>4,-pady =>0,-fill=>'both', -expand=>1);

$LBlistetransferee->Subwidget("yscrollbar")->configure(-background=>'black',
						-highlightbackground=>'gray30',
						-highlightcolor=>'gray30',
						#-width=>10,
						-activebackground=>'black',
						-relief=>'groove',
						-activerelief=>'groove',
						-borderwidth=>0,
						-elementborderwidth=>1,
						-troughcolor=>'black'
						);


# ajout des widgets operations sur liste selections
# cadre op manu
$frame_operations = $frame_LBtransfer->Frame(	-relief=>'groove',
						-borderwidth=>2,
						-background=>'black',
)->pack(-anchor=>'ne',-expand=>1, -fill=>'both',-padx =>0,-pady =>0);

# Radiobutton operation mauelles
$choix_operation="opmanu";
$operation_manu=$frame_operations->Radiobutton(
	-borderwidth=>"1",
	-justify=>"left",
	-anchor=>'w',
	#-state=>'disable',
	-highlightbackground=>"gray30",
	-foreground=>"DarkSeaGreen4",
	-activeforeground=>"DarkSeaGreen4",
	-background=>"black",
	-activebackground=>"black",
	-selectcolor=>"tomato3",
	-width=>"18",
	#-indicatoron=>"0",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	-text=>"Opération manuelle",
	-value=>"opmanu",
	-command=>sub{	print "Opération manuelle\n";
			$entree_temps_obs->configure(-state=>'disable');
			$boutonStartGoto->configure(-state=>'disable');
			# reconfig des boutons de script sur liste
			$valetat_pause=0;
			$boutonStartGoto->configure(-state=>'disable',-text=>'Start');
			$CB_pauseGoto->configure(-state=>'disable');
			$boutonStopGoto->configure(-state=>'disable');
			},
	-variable=>\$choix_operation
)->pack(-side=>'top',-anchor=>'nw',-padx =>4,-pady =>4, -expand=>0);#-fill=>'x',



# param commandes gotoauto
# cadre op auto
$frame_ctrlpointageauto = $frame_operations->Frame(-relief=>'groove',
						#-borderwidth=>2,
						-background=>'black',
						#-label=>"Opérations sur objets selectionnés"
)->pack(-anchor=>'nw',-expand=>0, -fill=>'both',-padx =>0,-pady =>0);#-side=>'left',

# Radiobutton operation auto
$operation_auto=$frame_ctrlpointageauto->Radiobutton(
	-borderwidth=>"1",
	-justify=>"left",
	-anchor=>'w',
	#-state=>'disable',
	-highlightbackground=>"gray30",
	-foreground=>"DarkSeaGreen4",
	-activeforeground=>"DarkSeaGreen4",
	-background=>"black",
	-activebackground=>"black",
	-selectcolor=>"tomato3",
	-width=>"18",
	#-indicatoron=>"0",
	#-highlightthickness=>"1",
	#-relief=>"sunken",
	-font=>$fonte,
	-text=>"Opération auto",
	-value=>"opauto",
	-command=>sub{	print "Opération auto\n";
			$entree_temps_obs->configure(-state=>'normal');
			$boutonStartGoto->configure(-state=>'normal');},
	-variable=>\$choix_operation
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>4, -expand=>0);


$frame_ctrlpointageauto->Label(		# titre
	-font=>$fonte,
	-foreground=>"DarkSeaGreen4",
	-background=>"black",
	-text=>"T obs(s)->"
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>4, -expand=>0);

$entree_temps_obs = $frame_ctrlpointageauto->Entry(	# saisie de durée des pointages
	-state=>'disable',
	#-borderwidth=>"1",
	-highlightthickness=>"0",
	-relief=>"groove",
	-font=>$fonte,
	-foreground=>"Tomato3",
	-background=>"gray30",
	-width=>"4",
	-textvariable=>\$temps_pointage
)->pack(-side=>'left',
	-anchor=>'ne',
	-padx =>4,
	-pady =>4,
	-expand=>0);

# commandes gotoauto
# cadre bouton goto auto
$frame_cdepointageauto = $frame_operations->Frame(-relief=>'groove',
						#-borderwidth=>2,
						-background=>'black',
						#-label=>"Opérations sur objets selectionnés"
)->pack(-side=>'left',-anchor=>'nw',-expand=>1, -fill=>'both',-padx =>0,-pady =>0);

$boutonStartGoto=$frame_cdepointageauto->Button(
    	-state=>'disable',
	-text=>'Start',
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DarkSeaGreen4",
	#-width=>"5",
	-command=>sub{	print "Start Goto liste\n";
			$boutonStartGoto->configure(-state=>'disable',-text=>'Run',);
			$CB_pauseGoto->configure(-state=>'normal');
			$boutonStopGoto->configure(-state=>'normal');},
)->pack(-side=>'left',-anchor=>'nw',-fill=>'none',-expand=>0,-padx =>4,-pady =>2);

### Checkbutton Pause
$valetat_pause=0; # init du check bouton pause
$CB_pauseGoto = $frame_cdepointageauto->Checkbutton(
	-state=>'disable',
	#-anchor=>'w',#center
	#-borderwidth=>"1",
	-highlightbackground=>"gray30",
	###-highlightthickness=>"1",
	###-relief=>"sunken",
	-indicatoron=>"0",
	-font=>$fonte,
	#-foreground=>"DarkSeaGreen4",
	#-activeforeground=>"DarkSeaGreen4",
	-background=>"DeepSkyBlue4",
	-activebackground=>"RosyBrown",#"tomato3",
	-selectcolor=>"RosyBrown",#"tomato3",
	-width=>7,
	-height=>1,
	-text=>"Pause",
	-variable=>\$valetat_pause,
	-command=> sub{
		if($valetat_pause==1){
			print "Pause ON\n";
			$boutonStartGoto->configure(-state=>'disable',-text=>'Pause');
			$boutonStopGoto->configure(-state=>'normal');

		}

		if($valetat_pause==0){
			print "Pause OFF\n";
			$boutonStartGoto->configure(-state=>'disable',-text=>'Run');
			$boutonStopGoto->configure(-state=>'normal');

		}
		}# fin de sub
	)->pack(-side=>'left',-anchor=>'nw',-fill=>'none',-expand=>0,-padx =>4,-pady =>2,ipady=>3);

$boutonStopGoto=$frame_cdepointageauto->Button(
    	-state=>'disable',
	-text=>"Stop",
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"firebrick",
	#-width=>"5",
	-command=>sub{	print "Stop Goto liste\n";
			$boutonStartGoto->configure(-state=>'normal',-text=>'Start');
			$CB_pauseGoto->configure(-state=>'disable');#,-text=>"Pause"
			$boutonStopGoto->configure(-state=>'disable');
			$valetat_pause=0;
			}
)->pack(-side=>'left',-anchor=>'nw',-fill=>'none',-expand=>0,-padx =>4,-pady =>2);


### --- fonctions sur Lisbox (cdes sur liste d'objets selectionnés) :
# cadre pour boutons sur Listbox
my $frame_boutons_ls=$fenetre_listes->Frame(-relief=>'flat',
				-background=>'black'
)->pack(-side=>'left',-anchor=>'w',-padx =>4,-pady =>0,-expand=>0);#, -fill=>'both'

$boutonDeleteAllObjet=$frame_boutons_ls->Button(	# vide la listbox
    	-state=>'disable',
	-text=>"DelAll",
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DeepSkyBlue4",
	#-width=>"7",
	-command=>\&deleteAllselection
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>2);

$boutonDeleteObjet=$frame_boutons_ls->Button(		# Supprim Objet selec ds listbox
    	-state=>'disable',
	-text=>"DelObj",
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DeepSkyBlue4",
	#-width=>"7",
	-command=>\&deleteselection
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>2);

$boutonSelecObjet=$frame_boutons_ls->Button(		# Selection d'objet pour Temma
    	-state=>'disable',
	-text=>"SelObj",
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DarkOrange4",
	#-width=>"7",
	-command=>\&selectionObjet
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>2);


### bouton ZView


# sauvegarde la liste des objets selectionnés dans fichier gotoliste.txt
$boutonSauveListe=$frame_boutons_ls->Button(
    	-state=>'disable',
	-text=>"Save",
	-font=>$fonte,
	-foreground=>"black",
	-highlightbackground=>"gray30",
	-background=>"DeepSkyBlue4",
	#-width=>"7",
	-command =>\&sauveliste
	#-command =>sub{	#&sauveliste;
	#		print "Sauvegarde selec liste\n";}
)->pack(-side=>'left',-anchor=>'nw',-padx =>4,-pady =>2);



# cadre pour boutons fermer
my $frame_boutons_close=$fenetre_listes->Frame(-relief=>'flat',
				-background=>'black'
				)->pack(-side=>'top',-fill=>'both',-padx =>10,-pady =>10,-expand=>0);

$bouton_Fermer_liste=$frame_boutons_close->Button(			# bouton masquer la fenetre
	-text=>"Masquer",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-command => sub{print "Masquer fenetre listes\n";
			$fenetre_listes->withdraw; #destroy();
			}

)->pack(-side=>'bottom',-anchor=>'se',-padx =>10,-pady =>4);
}	# fin de if !Exists toplevel


else	{
	print "Fenetre listes deja ouverte\n";
	$fenetre_listes->deiconify();
	$fenetre_listes->raise();
	}


# style d'affichage des données des hlist
#$style_eblue = $hlist_star->ItemStyle('text', -foreground=>'#000080', -anchor=>'e');
#$style_centerblack = $hlist_star->ItemStyle('text', -foreground=>'#000000', -anchor=>'center');

####### test
#@hlistframe=qw($frame_hliststar $frame_hlistperso $frame_hlistedb $frame_hlisttxt $frame_hlisthtml $frame_hlistxml);
#@page_nb=qw($page_star $page_perso $page_edb $page_txt $page_html $page_xml),
#@hlist=qw($hlist_star $hlist_perso $hlist_edb $hlist_txt $hlist_html $hlist_xml);
#&affiche_struchlist;
####### fin de test

} #----------- fin de listing --------------------------

#MainLoop;


# -------------------------------- ####################### -------------------------------- #
# -------------------------------- # ---- FONCTIONS ---- # -------------------------------- #
# -------------------------------- ####################### -------------------------------- #



#------------- quitter -----------------------------------
#sub quitter{
#	print "\n------ fin de script $script_name ------\n\n";
#	exit;
#	#POSIX::_exit(0);
#} #----------- fin de quitter ----------------------------



####### test
#sub affiche_struchlist{
#foreach $hlist_frame (@hlistframe){print "$hlist_frame\n";}
#foreach ($page_visible) {print "$hlist_frame\n";}
#}
####### fin de test



#------------- test_selec_hlist ------------------------- sur les hlist
sub test_selec_hlist{
# test sur les hlist si un objet est selectionné
@objetselec=$hlist->infoSelection;	#idem à selectionGet
if(@objetselec){
	#$boutonUpdateListe->configure(-state=>'normal');# todo : uniquement si -e fichier
	$boutonChoisir->configure(-state=>'normal');
	$hlist->bind('<Control-g>' => \&get_hlist_selection);
	}

} #----------- fin de test_selec_hlist ------------------






### --- ouverture et affichage fichiers listes d'objets

#------------- open_listestar --------------------------
# liste des étoiles jalons
sub open_listestar{
my $file="./etoilesjalons.txt";
my $ligne="";
my $path="";
if(-e $file){
print "ouvrir fichier : $file\n";# controle console
open(ETOILES,"<$file") or warn "PB ouverture lecture $file :$!\n";
while(<ETOILES>){
	s/#.*//;	# sup comment
	#s/^\s+//;	# sup espace debut
	#s/\s+$//;	# sup espaces fin
	next unless length;# s'il reste qqch
	@liste_etoiles=<ETOILES>;
	}
chomp @liste_etoiles;
close (ETOILES) or warn "PB close $file :$!\n";

# recup éléments principaux de liste
foreach $ligne(@liste_etoiles)
	{
	#print " $ligne\n";# controle console
	($nom_etoile,$RAhms_etoile,$DECdms_etoile,$spec_etoile)=(split(/,/,$ligne));
	my $nbobjet=(@liste_etoiles).(" objets listés");# nombre d'objets ds la liste
	$path++;					# index de liste pour hlist valeur de 1 à N
	#$epoc=" -> epoc $obedb_epoc";
	#print "$path\n";# test
	#print "objets listés : $nbobjet\n";# test
	#&convert2thc;
	#&affiche_listeedb;

# remplissage avec $path : valeur indicee de 1 à N selon $ligne(évite les pb avec les noms en doubles)
	foreach ($nom_etoile){
		$hlist_star->add($path);#,	-data=>\$objetinfo
		$hlist_star->itemCreate($path, 0, -text=>$nom_etoile);
		$hlist_star->itemCreate($path, 1, -text=>$RAhms_etoile, -style=>$style_eblue);
		$hlist_star->itemCreate($path, 2, -text=>$DECdms_etoile, -style=>$style_eblue);
		$hlist_star->itemCreate($path, 3, -text=>$spec_etoile, -style=>$style_eblack);
		#$hlist_star->itemCreate($path, 4, -text=>$type_etoile);
		##$hlist->itemCreate($path, 5, -text=>$thcradec_etoile, -style=>$style_centerblue);
		#print "$path\n";# control de path
		} # fin de foreach
	} # fin de foreach

#$boutonUpdateListe->configure(-state=>'disable'); # voir si update de ce fichier utile

#$hlist->update;
}# fin du if -e

else{print "todo : msg alerte fichier $file manquant\n";}

}#----------- fin de open_listestar --------------------




#------------- open_listeperso ---------------------------
# liste des objets perso
sub open_listeperso{
my $file="./listeperso.txt";
my $ligne="";
my $path="";
if(-e $file){
print "ouvrir fichier : $file\n";# controle console
open(PERSO,"<$file") or warn "PB ouverture lecture $file :$!\n";
while(<PERSO>){
	s/#.*//;	# sup comment
	#s/^\s+//;	# sup espace debut
	#s/\s+$//;	# sup espaces fin
	next unless length;# s'il reste qqch
	@liste_perso=<PERSO>;
	}
chomp @liste_perso;
close (PERSO) or warn "PB close $file :$!\n";

# recup éléments principaux de liste
foreach $ligne(@liste_perso)
	{
	#print " $ligne\n";# controle console
	($nom_perso,$RAhms_perso,$DECdms_perso,$spec_perso)=(split(/,/,$ligne));
	my $nbobjet=(@liste_perso).(" objets listés");	# nombre d'objets ds la liste
	$path++;					# index de liste pour hlist valeur de 1 à N
	#$epoc=" -> epoc $obedb_epoc";
	#print "$path\n";# test
	#print "objets listés : $nbobjet\n";# test
	#&convert2thc;
	#&affiche_listeedb;

# remplissage avec $path : valeur indicee de 1 à N selon $ligne(évite les pb avec les noms en doubles)
	foreach ($nom_perso){
		$hlist_perso->add($path);#,	-data=>\$objetinfo
		$hlist_perso->itemCreate($path, 0, -text=>$nom_perso);
		$hlist_perso->itemCreate($path, 1, -text=>$RAhms_perso, -style=>$style_eblue);
		$hlist_perso->itemCreate($path, 2, -text=>$DECdms_perso, -style=>$style_eblue);
		$hlist_perso->itemCreate($path, 3, -text=>$spec_perso, -style=>$style_eblack);
		#$hlist_perso->itemCreate($path, 4, -text=>$type_perso);
		##$hlist->itemCreate($path, 5, -text=>$thcradec_perso, -style=>$style_centerblue);
		#print "$path\n";# control de path
		} # fin de foreach
	} # fin de foreach

#$boutonUpdateListe->configure(-state=>'normal');
#$hlist->update;
}# fin du if -e

else{print "todo : msg alerte fichier $file manquant\n";}

}#----------- fin de open_listeperso ---------------------



#------------- open_listeedb ---------------------------
# liste des objets edb
sub open_listeedb{
my $file="./listegoto.edb"; # todo : possibilité de choisir un autre fichier
my $ligne="";
my $path="";
if(-e $file){
print "ouvrir fichier : $file\n";# controle console
open(EDB,"<$file") or warn "PB ouverture lecture $file :$!\n";
while(<EDB>){
	s/#.*//;	# sup comment
	#s/^\s+//;	# sup espace debut
	#s/\s+$//;	# sup espaces fin
	next unless length;# s'il reste qqch
	@liste_edb=<EDB>;
	}
chomp @liste_edb;
close (EDB) or warn "PB close $file :$!\n";

# recup éléments principaux de liste
foreach $ligne(@liste_edb)
	{
	#print " $ligne\n";# controle console
	($nom_edb,$type_edb,$RAhms_edb,$DECdms_edb,$mag_edb,$epoc_edb,$size_edb)=(split(/,/,$ligne));
	$spec_edb="$mag_edb $type_edb";
	my $nbobjet=(@liste_edb).(" objets listés");	# nombre d'objets ds la liste
	$path++;					# index de liste pour hlist valeur de 1 à N
	#$epoc=" -> epoc $epoc_edb";
	#print "$path\n";# test
	#print "objets listés : $nbobjet\n";# test
	#&convert2thc;
	#&affiche_listeedb;

# remplissage avec $path : valeur indicee de 1 à N selon $ligne(évite les pb avec les noms en doubles)
	foreach ($nom_edb){
		$hlist_edb->add($path);#,	-data=>\$objetinfo
		$hlist_edb->itemCreate($path, 0, -text=>$nom_edb);
		$hlist_edb->itemCreate($path, 1, -text=>$RAhms_edb, -style=>$style_eblue);
		$hlist_edb->itemCreate($path, 2, -text=>$DECdms_edb, -style=>$style_eblue);
		$hlist_edb->itemCreate($path, 3, -text=>$spec_edb, -style=>$style_eblack);
		#$hlist_edb->itemCreate($path, 4, -text=>$type_edb);
		##$hlist->itemCreate($path, 5, -text=>$thcradec_edb, -style=>$style_centerblue);
		#print "$path\n";# control de path
		} # fin de foreach
	} # fin de foreach

#$boutonUpdateListe->configure(-state=>'normal');
#$hlist->update;
}# fin du if -e

else{print "todo : msg alerte fichier $file manquant\n";}

}#----------- fin de open_listeedb ---------------------




#------------- open_listetxt ---------------------------
# liste des objets txt
sub open_listetxt{
my $file="./listegoto.txt"; # todo : possibilité de choisir un autre fichier
my $ligne="";
my $path="";
if(-e $file){
print "ouvrir fichier : $file\n";# controle console
open(TXT,"<$file") or warn "PB ouverture lecture $file :$!\n";
while(<TXT>){
	s/#.*//;	# sup comment
	#s/^\s+//;	# sup espace debut
	#s/\s+$//;	# sup espaces fin
	next unless length;# s'il reste qqch
	@liste_txt=<TXT>;
	}
chomp @liste_txt;
close (TXT) or warn "PB close $file :$!\n";

# recup éléments principaux de liste txt
# exemple :
#NGC 7790              23:58:24.20  61:12:30.0  8.5 Open Cluster
foreach $ligne(@liste_txt)
	{
	#print " $ligne\n";# controle console

	# decoupage ligne $obSelectxtline en variables (format fichier txt utilisé par xephem):
	$nom_txt=substr($ligne,0,21);	# nom objet
	for($nom_txt){s/\s+$//;}  # supprimer les espaces en fin de chaine

	$RAhms_txt=substr($ligne,22,11); # RA objet
	$DECdms_txt=substr($ligne,35,10);# DEC objet
	$spec_txt=substr($ligne,46); 	# spec objet
	#$mag_txt=substr($ligne,46,4); 	 # magnitude objet
	# voir si utiles
	#$size_txt=substr($ligne,46,5); 	# taille objet
	#$mag_txt=substr($ligne,52,4);	# magnitude objet
	#$type_txt=substr($ligne,56); # type objet

	#($nom_txt,$type_txt,$RAhms_txt,$DECdms_txt,$mag_txt,$epoc_txt,$size_txt)=(split(/,/,$ligne));
	my $nbobjet=(@liste_txt).(" objets listés");	# nombre d'objets ds la liste
	$path++;					# index de liste pour hlist valeur de 1 à N
	#$epoc=" -> epoc $epoc_edb";
	#print "$path\n";# test
	#print "objets listés : $nbobjet\n";# test
	#&convert2thc;
	#&affiche_listeedb;

# remplissage avec $path : valeur indicee de 1 à N selon $ligne(évite les pb avec les noms en doubles)
	foreach ($nom_txt){
		$hlist_txt->add($path);#,	-data=>\$objetinfo
		$hlist_txt->itemCreate($path, 0, -text=>$nom_txt);
		$hlist_txt->itemCreate($path, 1, -text=>$RAhms_txt, -style=>$style_eblue);
		$hlist_txt->itemCreate($path, 2, -text=>$DECdms_txt, -style=>$style_eblue);
		$hlist_txt->itemCreate($path, 3, -text=>$spec_txt, -style=>$style_eblack);
		#$hlist_txt->itemCreate($path, 4, -text=>$type_txt);
		##$hlist->itemCreate($path, 5, -text=>$thcradec_edb, -style=>$style_centerblue);
		#print "$path\n";# control de path
		} # fin de foreach
	} # fin de foreach

#$boutonUpdateListe->configure(-state=>'normal');
#$hlist->update;
}# fin du if -e

else{print "todo : msg alerte fichier $file manquant\n";}

}#----------- fin de open_listeedb ---------------------



		### --- affichage des structures des widgets hlist

#------------- affiche_hlist_star -----------------------
# affichage structure de HList
sub affiche_hlist_star{
$frame_hliststar = $page_star->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
$hlist_star=$frame_hliststar->Scrolled("HList",
			-scrollbars => 'se',
			-columns=>4,
			-header=>1,
			-itemtype=>'text',
			-selectmode=>'extended'#multiple
			#-command=>
			);

# affichage des hlist
$hlist_star->pack(-expand=>1,
		-fill=>'both',
		-side=>'left',# bottom
		-anchor=>'w'
		);

# style d'affichage des données des hlist
$style_eblue = $hlist_star->ItemStyle('text', -foreground=>'#000080', -anchor=>'e');
$style_centerblack = $hlist_star->ItemStyle('text', -foreground=>'#000000', -anchor=>'center');
$style_eblack = $hlist_star->ItemStyle('text', -foreground=>'#000000', -anchor=>'e');


# creation entete colonnes
$hlist_star->headerCreate(0, -text=>"Nom");
$hlist_star->headerCreate(1, -text=>"RA", -style=>$style_centerblack);
$hlist_star->headerCreate(2, -text=>"DEC", -style=>$style_centerblack);
$hlist_star->headerCreate(3, -text=>"Spec", -style=>$style_centerblack);
#$hlist_star->headerCreate(3, -text=>"Mag", -style=>$style_centerblack);
#$hlist_star->headerCreate(4, -text=>"Type");

# creation tailles colonnes
$hlist_star->columnWidth(0, -char,24); # nom
$hlist_star->columnWidth(1, -char,12); # RA
$hlist_star->columnWidth(2, -char,12); # DEC
$hlist_star->columnWidth(3, -char,27); # spec
#$hlist_star->columnWidth(4, -char,24); # type
#$hlist_star->columnWidth(5, -char,16); # RADEC pour THC

&open_listestar;
}#----------- fin de affiche_hlist_star -----------------



#------------- affiche_hlist_perso -----------------------
# affichage structure de HList
sub affiche_hlist_perso{
$frame_hlistperso = $page_perso->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
$hlist_perso=$frame_hlistperso->Scrolled("HList",
			-scrollbars => 'se',
			-columns=>4,
			-header=>1,
			-itemtype=>'text',
			-selectmode=>'extended'#multiple
			#-command=>
			);

# affichage des hlist
$hlist_perso->pack(	-expand=>1,
		-fill=>'both',
		-side=>'left',# bottom
		-anchor=>'w'
		);

# style d'affichage des données des hlist
$style_eblue = $hlist_perso->ItemStyle('text', -foreground=>'#000080', -anchor=>'e');#-justify=>'right'
$style_centerblack = $hlist_perso->ItemStyle('text', -foreground=>'#000000', -anchor=>'center');
$style_eblack = $hlist_perso->ItemStyle('text', -foreground=>'#000000', -anchor=>'e');
#$style_centerblue = $hlist->ItemStyle('text', -foreground=>'#000080', -anchor=>'center'); # pour THC

# creation entete colonnes
$hlist_perso->headerCreate(0, -text=>"Nom");
$hlist_perso->headerCreate(1, -text=>"RA", -style=>$style_centerblack);
$hlist_perso->headerCreate(2, -text=>"DEC", -style=>$style_centerblack);
$hlist_perso->headerCreate(3, -text=>"Spec", -style=>$style_centerblack);
#$hlist_perso->headerCreate(3, -text=>"Mag", -style=>$style_centerblack);
#$hlist_perso->headerCreate(4, -text=>"Type");
#$hlist->headerCreate(5, -text=>"RADEC THC", -style=>$style_centerblack);

# creation tailles colonnes
$hlist_perso->columnWidth(0, -char,24); # nom
$hlist_perso->columnWidth(1, -char,12); # RA
$hlist_perso->columnWidth(2, -char,12); # DEC
$hlist_perso->columnWidth(3, -char,27); # Spec
#$hlist_perso->columnWidth(4, -char,24); # type
#$hlist_perso->columnWidth(5, -char,16); # RADEC pour THC

&open_listeperso;
}#----------- fin de affiche_hlist_perso -----------------




#------------- affiche_hlist_edb -----------------------
# affichage structure de HList
sub affiche_hlist_edb{
$frame_hlistedb = $page_edb->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
$hlist_edb=$frame_hlistedb->Scrolled("HList",
			-scrollbars => 'se',
			-columns=>4,
			-header=>1,
			-itemtype=>'text',
			-selectmode=>'extended'#multiple
			#-command=>
			);

# affichage des hlist
$hlist_edb->pack(-expand=>1,
		-fill=>'both',
		-side=>'left',# bottom
		-anchor=>'w'
		);

# style d'affichage des données des hlist
$style_eblue = $hlist_edb->ItemStyle('text', -foreground=>'#000080', -anchor=>'e');#-justify=>'right'
$style_centerblack = $hlist_edb->ItemStyle('text', -foreground=>'#000000', -anchor=>'center');
$style_eblack = $hlist_edb->ItemStyle('text', -foreground=>'#000000', -anchor=>'e');
#$style_centerblue = $hlist->ItemStyle('text', -foreground=>'#000080', -anchor=>'center'); # pour THC

# creation entete colonnes
$hlist_edb->headerCreate(0, -text=>"Nom");
$hlist_edb->headerCreate(1, -text=>"RA", -style=>$style_centerblack);
$hlist_edb->headerCreate(2, -text=>"DEC", -style=>$style_centerblack);
$hlist_edb->headerCreate(3, -text=>"Spec", -style=>$style_centerblack);
#$hlist_edb->headerCreate(3, -text=>"Mag", -style=>$style_centerblack);
#$hlist_edb->headerCreate(4, -text=>"Type");
#$hlist->headerCreate(5, -text=>"RADEC THC", -style=>$style_centerblack);

# creation tailles colonnes
$hlist_edb->columnWidth(0, -char,24); # nom
$hlist_edb->columnWidth(1, -char,12); # RA
$hlist_edb->columnWidth(2, -char,12); # DEC
$hlist_edb->columnWidth(3, -char,27); # Spec
#$hlist_edb->columnWidth(4, -char,24); # type
#$hlist_edb->columnWidth(5, -char,16); # RADEC pour THC

&open_listeedb;
}#----------- fin de affiche_hlist_edb -----------------




#------------- affiche_hlist_txt -----------------------
# affichage structure de HList
sub affiche_hlist_txt{
$frame_hlisttxt = $page_txt->Frame()->pack(-side=>'top',-expand=>1, -fill=>'both');
$hlist_txt=$frame_hlisttxt->Scrolled("HList",
			-scrollbars => 'se',
			-columns=>4,
			-header=>1,
			-itemtype=>'text',
			-selectmode=>'extended'#multiple
			#-command=>
			);

# affichage des hlist
$hlist_txt->pack(	-expand=>1,
		-fill=>'both',
		-side=>'left',# bottom
		-anchor=>'w'
		);

# style d'affichage des données des hlist
$style_eblue = $hlist_txt->ItemStyle('text', -foreground=>'#000080', -anchor=>'e');#-justify=>'right'
$style_centerblack = $hlist_txt->ItemStyle('text', -foreground=>'#000000', -anchor=>'center');
$style_eblack = $hlist_txt->ItemStyle('text', -foreground=>'#000000', -anchor=>'e');
#$style_centerblue = $hlist->ItemStyle('text', -foreground=>'#000080', -anchor=>'center'); # pour THC

# creation entete colonnes
$hlist_txt->headerCreate(0, -text=>"Nom");
$hlist_txt->headerCreate(1, -text=>"RA", -style=>$style_centerblack);
$hlist_txt->headerCreate(2, -text=>"DEC", -style=>$style_centerblack);
$hlist_txt->headerCreate(3, -text=>"Spec", -style=>$style_centerblack);
#$hlist_txt->headerCreate(3, -text=>"Mag", -style=>$style_centerblack);
#$hlist_txt->headerCreate(4, -text=>"Type");
#$hlist->headerCreate(5, -text=>"RADEC THC", -style=>$style_centerblack);

# creation tailles colonnes
$hlist_txt->columnWidth(0, -char,24); # nom
$hlist_txt->columnWidth(1, -char,12); # RA
$hlist_txt->columnWidth(2, -char,12); # DEC
$hlist_txt->columnWidth(3, -char,27); # Spec
#$hlist_txt->columnWidth(4, -char,24); # type
#$hlist_txt->columnWidth(5, -char,16); # RADEC pour THC

&open_listetxt;
}#----------- fin de affiche_hlist_txt -----------------



#------------ update_fichier --------------------------- UPDATE DU FICHIER AFFICHE
sub update_fichier{

# udpate fichier liste selon page visible :
if($page_visible eq "page_star")
	{$hlist = $hlist_star;
	my $file="./etoilesjalons.txt";
	print "Update $file\n";
	$hlist->delete('all'); 	# sup contenu de la liste
	&open_listestar;
	}

elsif($page_visible eq "page_perso")
	{$hlist = $hlist_perso;
	my $file="./listeperso.txt";
	print "Update $file\n";
	$hlist->delete('all'); 	# sup contenu de la liste
	&open_listeperso;
	}

elsif($page_visible eq "page_edb")
	{$hlist = $hlist_edb;
	my $file="./listegoto.edb";
	print "Update $file\n";
	$hlist->delete('all'); 	# sup contenu de la liste
	&open_listeedb;
	}

elsif($page_visible eq "page_txt")
	{$hlist = $hlist_txt;
	my $file="./listegoto.txt";
	print "Update $file\n";
	$hlist->delete('all'); 	# sup contenu de la liste
	&open_listetxt;
	}

### --- si onglets supplémentaires
#elsif($page_visible eq "page_html")	{$hlist = 0;
#					$LBlistetransferee->insert("end", "pas de données html");}

#elsif($page_visible eq "page_xml")	{$hlist = 0;
#					$LBlistetransferee->insert("end", "pas de données xml");}

else {	$hlist = 0;
	$LBlistetransferee->insert("end", "erreur");}

}#----------- fin de update_fichier --------------------





		### --- fonctions sur les listes de recup affichées

#------------- get_hlist_selection --------------------- recup liste d'objets pour listbox (liste vers driver)
sub get_hlist_selection{ # from hlist
my $ligne_selec="";
my @objetselec=();

if ($hlist){
	@objetselec=$hlist->infoSelection;	#idem à selectionGet
	foreach $objet_selec(@objetselec){
		$nom_selec    =	$hlist->itemCget($objet_selec, 0, -text);
		$RAhms_selec  =	$hlist->itemCget($objet_selec, 1, -text);
		$DECdms_selec = $hlist->itemCget($objet_selec, 2, -text);
		#$mag_selec   =	$hlist->itemCget($objetselec, 3, -text);
		#$type_selec  =	$hlist->itemCget($objetselec, 4, -text);
		#$thcradec_selec=$hlist->itemCget($objetselec, 5, -text);

		$ligne_selec="$nom_selec, $RAhms_selec, $DECdms_selec"; # ligne objet pour Lisbox
		$LBlistetransferee->insert("end", "$ligne_selec");
		$LBlistetransferee->selectionClear(0, 'end'); 	# deselectionne les objets précédents transférés
		$LBlistetransferee->selectionSet('end'); 	# selection les objets transférés
		$LBlistetransferee->activate('end');
		$LBlistetransferee->focus();
		print "Selec $page_visible :\t$ligne_selec\n"; 		# retour console
		push (@listetransferee, $ligne_selec);#unless ($hash_driv{$ligne_selec}++)
		#chomp @listetransferee;
		}# fin de foreach

		# retablir l'etat actif des boutons de cde sur listbox si elle contient des données
		$boutonDeleteObjet->configure(-state=>'normal');
		$boutonDeleteAllObjet->configure(-state=>'normal');
		$boutonSelecObjet->configure(-state=>'normal');
		$boutonSauveListe->configure(-state=>'normal');
		if(($valetat_zview==0)&&($etat_sessionTemma==1)){ # n'activer qu'une seule fois ce Checktutton
			$CB_placesurZView->configure(-state=>'normal');}
		$LBlistetransferee->bind('<Return>'=>\&selectionObjet);

		#$LBlistetransferee->bind('<ButtonRelease-1>'=>\&test_selec_listbox); # test si clic ds listbox
}# fin de if hlist

}#----------- fin de get_hlist_selection ---------------



		### ---- fonctions sur LISTE VERS DRIVER ----

# ---------- fonction deleteselection ------------------ SUPPRIM OBJET SELEC DS LISTE
sub deleteselection{
$indiceSelecObjet=$LBlistetransferee->curselection();
foreach($indiceSelecObjet){
#@listeindiceSelecObjet=$LBlistetransferee->curselection();
#foreach $indiceSelecObjet(@listeindiceSelecObjet){
	#@listetransferee=$LBlistetransferee->get(0,"end"); 	# TEST liste des objets restant
	$LBlistetransferee->delete($indiceSelecObjet);
	$deleteObjet=$listetransferee[$indiceSelecObjet];	# objet delete
	delete($listetransferee[$indiceSelecObjet]);		# maj listetranferee sur objet delete
	#print "SupprObj ->\t\t$deleteObjet\n";			# retour console
	$qteObjetdslistbox=$LBlistetransferee->size();		# qte d'objets restant ds lisbox
	if($qteObjetdslistbox!=0){
		@listetransferee=$LBlistetransferee->get(0,"end"); 	# liste des objets restant
		$LBlistetransferee->selectionClear(0, 'end'); 	# deselectionne les objets précédents
		$LBlistetransferee->selectionSet($indiceSelecObjet);

		if(!$LBlistetransferee->selectionIncludes('end'))
			{$LBlistetransferee->selectionSet($indiceSelecObjet-1);}
		#if(!$LBlistetransferee->selectionIncludes('end'))
			#{$LBlistetransferee->selectionSet('end');}

		#$LBlistetransferee->activate(0);
		$LBlistetransferee->focus();
		print "SupprObj ->\t\t$deleteObjet\n";			# retour console
		}
	else	{
		# retablir l'etat disable des boutons de cde sur liste transferée si elle est vide
		$boutonDeleteObjet->configure(-state=>'disable');
		$boutonDeleteAllObjet->configure(-state=>'disable');
		$boutonSelecObjet->configure(-state=>'disable');
		$boutonSauveListe->configure(-state=>'disable');
		print "Vidage listbox d'objets selec\n";
		}
	} # fin de foreach

}#----------- fin de deleteselection -------------------





# ---------- fonction deleteAllselection --------------- VIDE LA LISTE COMPLETE
sub deleteAllselection{
$LBlistetransferee->delete(0,"end");
#@indicedeleteAllObjet=$LBlistetransferee->get(0,"end");# liste des objets actuels pour memo si undo
#@listetransferee=@indiceAlldeleteObjet; 		# liste des objets supprimés si recup par undo
@listetransferee=();					# liste des objets transférés->vidée
print "Vidage listbox d'objets selec\n";

#if(!@listetransferee){
	# retablir l'etat disable des boutons de cde sur liste transferée si elle est vide
	$boutonDeleteObjet->configure(-state=>'disable');
	$boutonDeleteAllObjet->configure(-state=>'disable');
	$boutonSelecObjet->configure(-state=>'disable');
	#$boutonPlacesurZView->configure(-state=>'disable');
	$boutonSauveListe->configure(-state=>'disable');
#	}
}#----------- fin de deleteAllselection -------------------




# ---------- fonction preselectionObjet ------------------- PRE-SELECTION OBJET DS LISBOX ***** utile ???
sub preselectionObjet{
$qteObjetdslistbox=$LBlistetransferee->size();		# qte d'objets restant ds lisbox
if($qteObjetdslistbox!=0){
	$LBlistetransferee->focus();
	@indicePreSelecObjet=$LBlistetransferee->curselection();
	foreach (@indicePreSelecObjet){
		#$selectionlistecomp=$LBlisteedbcomplete->selectionSet($_);# selectionSet
		$obPreSelec=$listetransferee[$_];
		#($obSelec_nom,$obSelec_type,$obSelec_RAhms,$obSelec_DECdms,$obSelec_mag)=(split(/\t/,$obSelec_edb));#long
		($obPreSelec_nom,$obPreSelec_RAhms,$obPreSelec_DECdms)=(split(/,/,$obPreSelec));# court
		$RA_hms_objet = $obPreSelec_RAhms; # RA brute
		$DEC_dms_objet= $obPreSelec_DECdms;# Dec brute
		$nom_objet = $obPreSelec_nom;
		print "PreSelec Objet listé->\t$obPreSelec_nom RA $obPreSelec_RAhms Dec $obPreSelec_DECdms\n";

# conversion RA en heure decimale pour synchro, ctrl_gotoRADEC et pos_sur_zview
$RA_h_deci = $RA_h +($RA_m/60) + ($RA_s/3600); # approx 0.6s
# conversion DEC en deg decimale pour ctrl_gotoRADEC et pos_sur_zview
$DEC_d_deci = $DEC_d +($DEC_m/60) + ($DEC_s/3600);

		}
	}
} #----------- fin de preselectionObjet -------------------




# ---------- fonction selectionObjet ------------------- SELECTION OBJET DS LISBOX
sub selectionObjet{
$qteObjetdslistbox=$LBlistetransferee->size();		# qte d'objets restant ds lisbox
if($qteObjetdslistbox!=0){
	$LBlistetransferee->focus();
	@indiceSelecObjet=$LBlistetransferee->curselection();
	foreach (@indiceSelecObjet){
		#$selectionlistecomp=$LBlisteedbcomplete->selectionSet($_);# selectionSet
		$obSelec=$listetransferee[$_];
		#($obSelec_nom,$obSelec_type,$obSelec_RAhms,$obSelec_DECdms,$obSelec_mag)=(split(/\t/,$obSelec_edb));#long
		($obSelec_nom,$obSelec_RAhms,$obSelec_DECdms)=(split(/,/,$obSelec));# court
		$RA_hms_objet = $obSelec_RAhms; # RA brute
		$DEC_dms_objet= $obSelec_DECdms;# Dec brute
		$nom_objet = $obSelec_nom;
		print "Selec Objet listé->\t$obSelec_nom RA $obSelec_RAhms Dec $obSelec_DECdms\n";

###### todo : formatage avec split et join et sprintf -> pour possibilité de tri et recherche ds Listbox
#	#$RA_hms_objet = sprintf("%02d:%02d:%02.1f",$RA_h,$RA_m,$RA_s);
#	#$DEC_dms_objet= sprintf("%+02d:%02d:%02d",$DEC_d,$DEC_m,$DEC_s);
#
#	# formatage RA recup XEphem
#	($xeAstre_ra_h,$xeAstre_ra_m,$xeAstre_ra_s)=(split (/:/ , $xeAstre_ra_hms));
#	$xeAstre_ra_hms=sprintf("%02d:%02d:%02.1f",$xeAstre_ra_h,$xeAstre_ra_m,$xeAstre_ra_s);
#
#	# formatage Dec recup XEphem avec ajout signe + si positive
#	($xeAstre_dec_d,$xeAstre_dec_m,$xeAstre_dec_s)=(split (/:/ , $xeAstre_dec_dms));
#	$xeAstre_dec_dms=sprintf("%+3s:%02d:%02d",$xeAstre_dec_d,$xeAstre_dec_m,$xeAstre_dec_s);
#
#	# pour fichier listeperso.txt et liste.pm
#	$xeAstre_spec="$xeAstre_mag $xeAstre_type $xeAstre_size";
#
#	print("Objet XEphem :\t\t$xeAstre_nom RA $xeAstre_ra_hms Dec $xeAstre_dec_dms Spec $xeAstre_spec\n");
#
###### fin de toto

	# si la session Temma est ouverte on reactive les boutons de cdes sur la Temma
		if($etat_sessionTemma==1)
			{&get_saisie_radec; 		# pour recup RA/DEC et visu sur zview avant cde sur Temma
		 	&activer_boutonsCdeObjet;	# active les boutons de commandes sync et goto
			}
		#$fenetre_driver->update;

		else	{print "Récup objet non ok Temma non connectée\n";}
		} # fin de foreach
	}# fin du if
}#----------- fin de selectionObjet --------------------




# ---------- fonction listeobjetzview		PLACEMENT LISTE OBJETS SUR ZVIEW
sub listeobjetzview{
# recup selection d'objet ds listes pour zview

#$icone_objet=$icone_objet_fixe;# pixmap sur zview pour objets fixes
$icone_objet=""; # pixmap sur zview
@liste_objetsurzview=();
@liste_objetsurzview=$LBlistetransferee->get(0,"end");
foreach $objetsurzview (@liste_objetsurzview){
	($obzview_nom,$obzview_RAhms,$obzview_DECdms)=(split(/,/,$objetsurzview));

	# pixmap sur zview si planete
	if(($obzview_nom eq "Sun")	or
	 ($obzview_nom eq "Mercury")	or
	 ($obzview_nom eq "Venus")	or
	 ($obzview_nom eq "Mars")	or
	 ($obzview_nom eq "Moon")	or
	 ($obzview_nom eq "Jupiter")	or
	 ($obzview_nom eq "Saturn")	or
	 ($obzview_nom eq "Uranus")	or
	 ($obzview_nom eq "Neptun")	or
	 ($obzview_nom eq "Pluton"))
		{$icone_objet=$icone_planete;}

	# todo : type de pixmap sur zview si cometes ou asteroides d'après listegoto.txt ->type : $obSelectxttype

	# pixmap sur zview si objets fixes
	else	{$icone_objet=$icone_objet_fixe;}

	# split pour RA h:m:s et DEC d:m:s
	($obzviewRA_h, $obzviewRA_m, $obzviewRA_s)	= (split (/:/ , $obzview_RAhms));
	($obzviewDEC_d, $obzviewDEC_m, $obzviewDEC_s)	= (split (/:/ , $obzview_DECdms));

	#$obzviewRA_h=substr($obzviewRA_h,0,-1);	# RA
	#for($obzviewRA_h){s/\s+$//;}  # supprimer les espaces en fin de chaine

	# conversion RA en heure decimale pour placement sur zview
	$obzviewRA_h_deci = $obzviewRA_h +($obzviewRA_m/60) + ($obzviewRA_s/3600); # approx 0.6s

	# conversion DEC en deg decimal pour placement sur zview
	$obzviewDEC_d_deci_ns=abs($obzviewDEC_d)+abs($obzviewDEC_m/60)+abs($obzviewDEC_s/3600);#non signée

	if(($obzviewDEC_d<0)or($obzviewDEC_d eq "-0"))
		{$obzviewDEC_d_deci=$obzviewDEC_d_deci_ns*(-1);}# DEC deg deci signe -
	elsif($obzviewDEC_d>=0)
		{$obzviewDEC_d_deci=$obzviewDEC_d_deci_ns;}	# DEC deg deci signe +
	elsif(($obzviewDEC_d == 0)&&($obzviewDEC_m == 0)&&($obzviewDEC_s == 0))
		{$obzviewDEC_d_deci=0;}				# DEC deg deci = 0

	# ------ pour pos xy zview
	# RA objet sur ZView (avec l'angle horaire)
	$angleHobjet=$lst_horaire-$obzviewRA_h_deci;#+0.5/60;
	$angleHobjet_modulo=($angleHobjet/24-(int($angleHobjet/24)))*24;
	# DEC objet sur ZView
	$posDECobjetzview=(90-$obzviewDEC_d_deci)*(180/90);
	$x_objetpos=int(246+($posDECobjetzview*(sin(0.26180*$angleHobjet_modulo)))); # $rayon centre xy : 246,215
	$y_objetpos=int(215+($posDECobjetzview*(cos(0.26180*$angleHobjet_modulo)))); # $rayon centre xy : 246,215
	# ------

	if($etat_sessionTemma==1){
		if(!Exists($fenetre_zview))# affiche fenetre zview et place les objets
			{# ouvre la fenetre de zview -> todo : warning si manque fichier zview
			&fenetre_zview;
			#&place_listeob_zview;# ok
			# test sur liste objets : contenu fonction place_listeob_zview ici
			$x_objetpos*=$facteur_scale;
			$y_objetpos*=$facteur_scale;
			# placement du ou des pixmap(s) objets fixes
			$pos_objet=$canvaszv->createImage($x_objetpos,$y_objetpos,-image=>$icone_objet,-tags=>"objettag");
			}

		else	{ # zview ouverte, place les objets
			#&place_listeob_zview;# ok
			#$fenetre_zview->deiconify();	# ralenti l'affichage du cercle
			#$fenetre_zview->raise();	# ralenti l'affichage du cercle
			# test sur liste objets : contenu fonction place_listeob_zview ici
			$x_objetpos*=$facteur_scale;
			$y_objetpos*=$facteur_scale;
			# placement du ou des pixmap(s) objets fixes
			$pos_objet=$canvaszv->createImage($x_objetpos,$y_objetpos,-image=>$icone_objet,-tags=>"objettag");
			}
	}
	else {print "todo : boite de dialogue session Temma non ouverte\n"}
}# fin de foreach

} #----------- fin de listeobjetzview ------------------



# ---------- fonction sauveliste ----------------------- # en cours -> todo : sauvegarde sur fichier listing.txt
sub sauveliste{
print "Sauvegarde selec liste\n";
@liste_sauve=$LBlistetransferee->get(0,"end");
foreach $line (@liste_sauve){print "$line\n";}
#print "@liste_sauve\n";

} #----------- fin de sauveliste -----------------------



# ---------- fonction update_posliste ---------------- deplacement sideral sur la liste d'objets affichés
sub update_posliste{
$canvaszv->delete("objettag");
&listeobjetzview;
}# ------- fin de update_posliste --------------------


1;

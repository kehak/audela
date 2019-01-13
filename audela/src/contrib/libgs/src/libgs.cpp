/*********************************************************************/
/* Guillaume Spitzer (C) 2002                                        */
/*                                                                   */
/* Librairie d'extension TCL                                         */
/*                                                                   */
/* Ajoute des fonctions de pilotage de Guide                         */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/* Syntaxe :                                                         */
/*                                                                   */
/*   gs_guide objet M109 [JD=2452447.30275]                          */
/*                                                                   */
/*   gs_guide coord 22h17m45.2s -3d16m23s [JD=2452447.30275]         */
/*                                                                   */
/*   gs_guide zoom 9                                                 */
/*                                                                   */
/*   gs_guide version                                                */
/*                                                                   */
/*   gs_guide show                                                   */
/*                                                                   */
/*   gs_guide hide                                                   */
/*                                                                   */
/*   gs_guide restore                                                */
/*                                                                   */
/*   gs_guide capture nom_fichier                                    */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*                                                                   */
/* Liste des codes d'erreurs renvoyés à l'interpréteur :             */
/*                                                                   */
/*  0 = Tout s'est bien passé                                        */
/*  1 = Guide n'a pas été trouvé.                                    */
/*  2 = Pas assez de paramètres                                      */
/*  3 = Mot-clé non trouvé                                           */
/*  4 = Erreur paramètre de zoom (non numérique par ex.)             */
/*  5 = Le zoom n'est pas compris entre 1 et 20.                     */
/*  6 = l'Objet ne commence pas par M, NGC ou IC ou pas une planete. */
/*  7 = Erreur d'exécution de la commande Guide (pas implémenté)     */
/*                                                                   */
/*                                                                   */
/*********************************************************************/
#define DEBUG 0

#define $VERSION$ "0.20"

/* === OS independant includes files === */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <process.h>
#include <winsock.h>
#include <time.h>

#include "libgs.h"


typedef struct refplanete {
	char nomaudela[10];
	int  hwndGuide8;
	int  hwndGuide7;
	int  hwndGuide6;
} REFPLANETE;

typedef struct libelle_Dlg {
	char libelle[25];
	int  taille;
} LIBELLE_DLG;

// Définition des handles des boutons de la fenetre 'planete' sous Guide 8 et autres versions
//                                 Guide8 Guide7 Guide6
REFPLANETE planete[10]={"SUN",     0x7D0,      0,     0,
					    "MOON",    0x7DA,      0,     0,
					    "MERCURY", 0x7D1,      0,     0,
					    "VENUS",   0x7D2,      0,     0,
					    "MARS",    0x7D4,      0,     0,
					    "JUPITER", 0x7D5,      0,     0,
					    "SATURN",  0x7D6,      0,     0,
					    "URANUS",  0x7D7,      0,     0,
					    "NEPTUNE", 0x7D8,      0,     0,
					    "PLUTO",   0x7D9,      0,     0};
LIBELLE_DLG WTimeZone[6]={"TIME BOX", 8,
	 				      "ZITEINGABE", 10,
						  "AFFICHAGE DU TEMPS", 18,
						  "CUADRO DE TIEMPO", 16,
						  "CASELLA DEL TEMPO", 17,
						  "TIJD BOX", 8};
LIBELLE_DLG SaisieJD[6]={"ENTER JD", 8,
						 "EINGABE DES", 11,
						 "ENTRER LE JJ", 12,
						 "PONER DJ", 8,
						 "DIGITARE IL", 11,
						 "GEEF JD", 7};
LIBELLE_DLG WPlanete[6]={"GO TO PLANET", 12,
					     "PLANETEN ODER", 13,
					     "CHOISIR UNE", 11,
					     "IR A PLANETA", 12,
					     "SELEZIONARE IL", 14,
					     "GA NAAR PLANEET", 15};
LIBELLE_DLG WSaisieRADEC[6]={"ENTER RA/DEC", 12,
							"EINGABE REKTASZENSION", 21,
							"ENTRER AD/D", 11,
							"PONER AR", 8,
							"DIGITARE AR", 11,
							"INVOER RK", 9};
LIBELLE_DLG WSaisieLevel[6]={"SELECT LEVEL", 12,
							 "AUSWAHL STUFE", 13,
							 "CHOISIR UN NIVEAU", 17,
							 "ESCOGE NIVEL", 12,
							 "SELEZIONARE IL LIVELLO", 22,
							 "KIES NIVEAU", 11};

// ID du bouton de la Date Julienne dans la fenetre Setup/Time
// (dans l'ordre Guide8, Guide7, Guide6
int ID_Time_JD[3]={ 0x118, 0x118, 0x118 };
// ID du le bouton OK dans la fenetre Setup/Time
// (dans l'ordre Guide8, Guide7, Guide6
int ID_Time_Ok[3]={ 0x001, 0x001, 0x001 };


// ID du bouton OK de la Fenetre de saisie de la JD
// col. 1 = Handle Guide 8
// col. 2 = Handle Guide 7
// col. 3 = Handle Guide 6
int ID_StaticJD[3]={0x15F, 0x15F, 0xFFFF};
int ID_EditJD[3]={0x06B, 0x06B, 0x06B};
int ID_OkJD[3]={0x001, 0x001, 0x001};
int ID_EditObjet[3]={0x06B, 0x06B, 0x06B};
int ID_OkObjet[3]={0x001, 0x001, 0x001};

int ID_EditRA[3]={0x0DC, 0x0DC, 0x0DC};
int ID_EditDEC[3]={0x066, 0x066, 0x066};
int ID_EditEpoque[3]={0x067, 0x067, 0x067};
int ID_OkRADEC[3]={0x001, 0x001, 0x001};

int Version(ClientData client_data, Tcl_Interp* interp, int argc, char *argv[])
{
  char s[256];

  sprintf(s,$VERSION$, argv[0]);
  Tcl_SetResult(interp,s,TCL_VOLATILE);
  return TCL_OK;
}

/*
char * maj(char *msg)
{
  char *p;

  for (p = msg; p < msg + strlen( msg ); p++ ) {
	  *p = toupper(*p);
  }
  return msg;
}
*/

char * maj(char *msg)
{
  char *p;
  static char sortie[256];
  int k;

  for (p = msg, k=0; p < msg + strlen( msg ); p++, k++ ) {
	  sortie[k] = toupper(*p);
  }
  sortie[k]='\0';
  return sortie;
}

//===================================================================
//        Ancienne méthode : Simulation d'évènement clavier
//===================================================================
void Envoie_Touche(char ch, BOOL modificateur, BYTE touche)
{
  BYTE lo;

  lo = LOBYTE(VkKeyScan(ch));
  if (modificateur) keybd_event(touche, 0, 0, 0);
  if (lo != 0) keybd_event(lo, 0, 0, 0);
  if (lo != 0) keybd_event(lo, 0, KEYEVENTF_KEYUP, 0);
  if (modificateur) keybd_event(touche, 0, KEYEVENTF_KEYUP, 0);
}

void Envoie_ToucheEx(BOOL dwn, BYTE touche)
{
  if (dwn)
    keybd_event(touche, 0, 0, 0);
  else
    keybd_event(touche, 0, KEYEVENTF_KEYUP, 0);
}
//===================================================================

// Recherche WTimeZone / WPlanete / WSaisieRADEC / WSaisieLevel
HWND Recherche_Fenetre(LIBELLE_DLG *structure)
{
	HWND hw;
	int r;
	char nom[31];

/*	while (1) { // On boucle jusqu'à ce qu'on trouve la fenetre.
		for(r=0;r<6;r++) { // 6 langues traitées
			if (hw=FindWindow(0, structure[r].libelle))
				return hw;
		}
	} */
	hw = GetTopWindow(0); // Première fenetre du Z-Order
	while (1) { // On boucle jusqu'à ce qu'on trouve la fenetre.
		if (hw==0) hw = GetTopWindow(0);
		for(r=0;r<6;r++) { // 6 langues traitées
			GetWindowText(hw, nom, 30);
			if ( !strncmp(maj(nom), structure[r].libelle, structure[r].taille) )
				return hw;
		}
		hw = GetWindow(hw, GW_HWNDNEXT);
	}
}

HWND Recherche_Fenetre_Saisie(void)
{
	HWND hw;

	while ( !(hw=FindWindow("#32770", "GUIDE")) ) {}
	return hw;
}

void Fonction_JD(HWND h, Tcl_Interp* interp, int IndexGuide, char *jd)
{
	HWND he, ht;
	HWND hb1, hb2, hb3, hb4;
	HMENU hm, hsetup;
	int htime;

	if (!(*jd)) return; // Si c'est une chaine vide

	// Plus sûr que la méthode précédente (envoi d'évènement clavier par keybd_event)
	// car on est sûr de s'adresser à la bonne fenetre.
	// Dans le cas précédent, les actions sont envoyées à la fenetre qui a le focus.
	// Si le focus venait à changer, il y aurait problème.
	hm = GetMenu(h);
	if (IndexGuide == 0) {  // GUIDE 8
		hsetup = GetSubMenu(hm, 2); // Menu Setup
		htime = GetMenuItemID(hsetup, 1); // Option Time Dialog
	} else
		if (IndexGuide == 1) {  // GUIDE 7
			hsetup = GetSubMenu(hm, 2); // Menu Setup
			htime = GetMenuItemID(hsetup, 1); // Option Time Dialog
		} else
			if (IndexGuide == 2) {  // GUIDE 6
				hsetup = GetSubMenu(hm, 2); // Menu Setup
				htime = GetMenuItemID(hsetup, 4); // Option Time Dialog
			}

	SendMessage(h, WM_COMMAND, htime, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(100);

	// Obtient le handle de la fenetre 'Time Zone'
	// Il faut trouver une meilleure solution que de rechercher le titre de la fenetre.
	he = Recherche_Fenetre(WTimeZone);

	// Récupère le handle des boutons utilisé dans la fenetre 'Time Zone'
	hb1 = GetDlgItem(he, ID_Time_JD[IndexGuide]); // Julian Date
	hb2 = GetDlgItem(he, ID_Time_Ok[IndexGuide]); // OK button
	// On appuie sur le bouton JulianDate de la Fenetre Time
	// SendNotifyMessage force la fenetre cible à traiter immédiatement les messages.
	SendNotifyMessage(hb1, WM_LBUTTONDOWN, 0, 0);
	SendNotifyMessage(hb1, WM_LBUTTONUP, 0, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(100);

	// Obtient le handle de la fenetre de saisie 'JD'
	ht = Recherche_Fenetre_Saisie();

	// Récupère les handles des boutons de la fenetre de saisie
	hb3 = GetDlgItem(ht, ID_EditJD[IndexGuide]); // Julian Date
	hb4 = GetDlgItem(ht, ID_OkJD[IndexGuide]); // OK button

	// Envoi la nouvelle date julienne dans le champs de saisie
	SendMessage(hb3, WM_SETTEXT, 0, (LPARAM)jd);

	// Valide la saisie
	SendMessage(hb4, WM_LBUTTONDOWN, 0, 0);
	SendMessage(hb4, WM_LBUTTONUP, 0, 0);

	// Appuie sur le bouton OK de la fenetre Time
	SendMessage(hb2, WM_LBUTTONDOWN, 0, 0);
	SendMessage(hb2, WM_LBUTTONUP, 0, 0);
}



//================================================
// Action a effectuer dans le Menu GOTO
//
// Code retour:
// 0 = Pas d'erreur
// 1 = Objet MESSIER hors limites
// 2 = Objet NGC hors limites
// 3 = Objet IC hors limites
// 4 = Astéroïdes (pas encore utilisé)
//================================================
int	Action_Guide_NGCIC(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
	char chx;
	char *num;
	HWND hb1, hb2, hs;
	HMENU hm, hsetup;
	int htime;

	chx = toupper(*argv[2]);

    if (chx == 'M') num = argv[2]+1;
    if (chx == 'N') num = argv[2]+3;
    if (chx == 'I') num = argv[2]+2;
    if (chx == 'A') num = argv[2]+1;

	hm = GetMenu(h);

	if ( IndexGuide == 0 ) {  // GUIDE 8
		hsetup = GetSubMenu(hm, 1); // Menu GOTO
		switch (chx) {
			case 'M' :
				htime = GetMenuItemID(hsetup, 2); // Messier
				break;
			case 'N' :
				htime = GetMenuItemID(hsetup, 3); // NGC
				break;
			case 'I' :
				htime = GetMenuItemID(hsetup, 4); // IC
				break;
			case 'A' :
				htime = GetMenuItemID(hsetup, 11); // Astéroïdes
				break;
		}
	} else
		if ( IndexGuide == 1 ) {  // GUIDE 7
			hsetup = GetSubMenu(hm, 1); // Menu GOTO
			switch (chx) {
				case 'M' :
					htime = GetMenuItemID(hsetup, 2); // Messier
					break;
				case 'N' :
					htime = GetMenuItemID(hsetup, 3); // NGC
					break;
				case 'I' :
					htime = GetMenuItemID(hsetup, 4); // IC
					break;
				case 'A' :
					htime = GetMenuItemID(hsetup, 11); // Astéroïdes
					break;
			}
		} else
			if ( IndexGuide == 2 ) {  // GUIDE 6
				hsetup = GetSubMenu(hm, 1); // Menu GOTO
				switch (chx) {
					case 'M' :
						htime = GetMenuItemID(hsetup, 0); // Messier
						break;
					case 'N' :
						htime = GetMenuItemID(hsetup, 1); // NGC
						break;
					case 'I' :
						htime = GetMenuItemID(hsetup, 2); // IC
						break;
					case 'A' :
						htime = GetMenuItemID(hsetup, 10); // Astéroïdes
						break;
				}
			}

	SendMessage(h, WM_COMMAND, htime, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(100);

	hs = Recherche_Fenetre_Saisie();

	hb1 = GetDlgItem(hs, ID_EditObjet[IndexGuide]); // Edit
	hb2 = GetDlgItem(hs, ID_OkObjet[IndexGuide]); // OK button

	SendMessage(hb1, WM_SETTEXT, 0, (LPARAM)num);
	// Valide la saisie
	SendMessage(hb2, WM_LBUTTONDOWN, 0, 0);
	SendMessage(hb2, WM_LBUTTONUP, 0, 0);

	return 0;
}


int Action_Guide_Planetes(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
	HWND he; // Handle de la fenetre enfant ouverte
	HWND hb; // Handle d'un bouton
	int n;
	HMENU hm, hsetup;
	int htime;

	hm = GetMenu(h);
	if ( IndexGuide == 0) {  // GUIDE 8
		// Action dans les menus
		hsetup = GetSubMenu(hm, 1); // Menu GOTO
		htime = GetMenuItemID(hsetup, 8); // SubMenu planete
	} else
		if ( IndexGuide == 1) {  // GUIDE 7
			// Action dans les menus
			hsetup = GetSubMenu(hm, 1); // Menu GOTO
			htime = GetMenuItemID(hsetup, 8); // SubMenu planete
		} else
			if ( IndexGuide == 2) {  // GUIDE 6
				// Action dans les menus
				hsetup = GetSubMenu(hm, 1); // Menu GOTO
				htime = GetMenuItemID(hsetup, 8); // SubMenu planete
			}

	SendMessage(h, WM_COMMAND, htime, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(100);

	he = Recherche_Fenetre(WPlanete);

	// On appuie sur le bouton correspondant à la planète.
	// Même ID pour toutes les versions de Guide
	for(n=0;n<10;n++) {
		if (!strcmp(argv[2], planete[n].nomaudela)) {
			hb = GetDlgItem(he, planete[n].hwndGuide8);
			SendMessage(hb, WM_LBUTTONDOWN, 0, 0);
			SendMessage(hb, WM_LBUTTONUP, 0, 0);
			break;
		}
	}

	return 0;
}

int Action_Guide_RADEC(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
	HWND he, he1, he2, he3, hb1;
	HMENU hm, hsetup;
	int htime;

	hm = GetMenu(h);
	if (IndexGuide == 0) {   // GUIDE 8
		// Action dans les menus
		hsetup = GetSubMenu(hm, 1); // Menu GOTO
		hsetup = GetSubMenu(hsetup, 20); // SubMenu Coordonnées
		htime = GetMenuItemID(hsetup, 0); // Option RADEC
	} else
		if (IndexGuide == 1) {   // GUIDE 7
			// Action dans les menus
			hsetup = GetSubMenu(hm, 1); // Menu GOTO
			hsetup = GetSubMenu(hsetup, 20); // SubMenu Coordonnées
			htime = GetMenuItemID(hsetup, 0); // Option RADEC
		} else
			if (IndexGuide == 2) {   // GUIDE 6
				// Action dans les menus
				hsetup = GetSubMenu(hm, 1); // Menu GOTO
				hsetup = GetSubMenu(hsetup, 13); // SubMenu Coordonnées
				htime = GetMenuItemID(hsetup, 0); // Option RADEC
			}

	SendMessage(h, WM_COMMAND, htime, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(200);

	he = Recherche_Fenetre(WSaisieRADEC);

	he1 = GetDlgItem(he, ID_EditRA[IndexGuide]); // Edit
	he2 = GetDlgItem(he, ID_EditDEC[IndexGuide]); // Edit
	he3 = GetDlgItem(he, ID_EditEpoque[IndexGuide]); // Edit
	hb1 = GetDlgItem(he, ID_OkRADEC[IndexGuide]); // Bouton

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(200);

	SendMessage(he1, WM_SETTEXT, 0, (LPARAM)argv[2]);
	SendMessage(he2, WM_SETTEXT, 0, (LPARAM)argv[3]);
	SendMessage(he3, WM_SETTEXT, 0, (LPARAM)argv[4]);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(200);

	// Appuie sur le bouton OK de la fenetre Time
	SendMessage(hb1, WM_LBUTTONDOWN, 0, 0);
	SendMessage(hb1, WM_LBUTTONUP, 0, 0);

	return 0;
}

int Action_Guide_Zoom(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
	int i;
	HMENU hMain, hSetting;
	HWND he, hb;
	int htime;

	// Verifie le type du parametre de level
	if (sscanf(argv[2], "%d", &i) != 1) { return 4; }

	// Vérifie qu'il est compris entre 1 et 19 (20, on sait pas faire simplement)
	if (i < 1 || i > 20) { return 5; }

	hMain = GetMenu(h);
	if (IndexGuide == 0) {   // GUIDE 8
		// Action dans les menus
		hSetting = GetSubMenu(hMain, 2); // Menu Setting
		htime = GetMenuItemID(hSetting, 4); // Option Level
	} else
		if (IndexGuide == 1) {  // GUIDE 7
			// Action dans les menus
			hSetting = GetSubMenu(hMain, 2); // Menu Setting
			htime = GetMenuItemID(hSetting, 4); // Option Level
		} else
			if (IndexGuide == 2) {  // GUIDE 6
				// Action dans les menus
				hSetting = GetSubMenu(hMain, 2); // Menu Setting
				htime = GetMenuItemID(hSetting, 7); // Option Level
			}

	SendMessage(h, WM_COMMAND, htime, 0);

	// Passe la main aux autres thread (pour que Guide prenne en compte les messages)
	Sleep(100);

	he = Recherche_Fenetre(WSaisieLevel);

	hb = GetDlgItem(he, 0x7D0+i-1); // Meme ID pour les 3 versions de Guide
	SendMessage(hb, WM_LBUTTONDOWN, 0, 0);
	SendMessage(hb, WM_LBUTTONUP,   0, 0);

	return 0;
}

int Action_Guide_Capture(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
	// Class Guide 8 : AfxFrameOrView42s
	// Class Guide 7 :
	// Class Guide 6 :
	return 0;
}

int Action_Guide_Refresh(HWND h, Tcl_Interp* interp, int IndexGuide, int argc, char *argv[])
{
    HWND hw;

	hw = GetWindow(h, GW_CHILD);

	SendMessage(hw, WM_KEYDOWN, 0x72, 0x3D0001);
	SendMessage(hw, WM_KEYUP, 0x72, 0x3D0001);

	return 0;
}

int SelectGuide(ClientData client_data, Tcl_Interp* interp, int argc, char *argv[])
{
	HWND h;
//	HANDLE ThreadH;
	char nom[100], cn[100];
	int VersionGuide, IndexGuide;
	int i, res;
    char s[256];
	char *p, *q;
	char *jd;

//	ThreadH = GetCurrentProcess();
//	SetPriorityClass(ThreadH, NORMAL_PRIORITY_CLASS);
//	SetThreadPriority(ThreadH, THREAD_PRIORITY_HIGHEST);

	jd=NULL;
    // Controle du nombre de parametres attendus
	if ( argc < 2 ) {
		sprintf(s, "Usage: %s action ?parametres? ?options?", argv[0]);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return TCL_ERROR;
	}
	if (argc > 1) {
		if (!strcmp(maj(argv[1]), "HELP")) {
			sprintf(s, "Usage: %s action ?parametres? ?options?", argv[0]);
			Tcl_SetResult(interp, s, TCL_VOLATILE);
			Tcl_AppendResult(interp, "\naction = OBJET objet", NULL);
			Tcl_AppendResult(interp, "\n         objet = M106, NGC1234, IC234, A234, Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto", NULL);
			Tcl_AppendResult(interp, "\n         niveau = 1 à 20", NULL);
			Tcl_AppendResult(interp, "\naction = COORD ra dec", NULL);
			Tcl_AppendResult(interp, "\naction = ZOOM niveau", NULL);
			Tcl_AppendResult(interp, "\noptions = JD=date julienne", NULL);
			return TCL_ERROR;
		}
		//***********************************************
		//*  Traitement des options
		//***********************************************
		if (argc > 2) {
			for(i=3;i<argc;i++) {
				if ( !strncmp(maj(argv[i]), "JD=", 3) )
				{
					jd=argv[i]+3;
				}
			}
		}
	}

	// ======================================================
	//       Recherche de la fenetre GUIDE 6, 7 ou 8
	// ======================================================
	h = GetTopWindow(0);
	while (1) {
		h = GetWindow(h, GW_HWNDNEXT);
		if (h == 0) {
			// On a atteint la fin de la liste Z-order
			// Guide n'est pas trouvé, la fonction gs_guide renvoie "1".
			Tcl_SetResult(interp, "1", TCL_VOLATILE);  // Guide non trouvé
			return TCL_OK;
		}
		GetWindowText(h, nom, 100);
		GetClassName(h, cn, 100);
		if ( !strncmp(maj(nom), "GUIDE6", 6) ||
			 !strncmp(maj(cn), "AFXFRAMEORVIEW", 14) ) // Identification Guide 6
		{
			VersionGuide = 6;
			IndexGuide=2;
			break;
		}

		if ( !strncmp(maj(nom), "GUIDE 7.0", 9) ) // Identification Guide 7 et 8
		{
			VersionGuide = 7;
			IndexGuide=1;
			break;
		}
		if ( !strncmp(maj(nom), "GUIDE 8.0", 9) ||
			 !strncmp(maj(cn), "AFX:400000:B:10011:", 19) ) // Identification Guide 7 et 8
		{
			VersionGuide = 8;
			IndexGuide=0;
			break;
		}
	}

	//************************************************************
	//*  OBJET
	//************************************************************
	if (!strcmp(maj(argv[1]), "OBJET")) {
		if (argc < 3) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		p = argv[2];
		q = argv[3];

		// S'il y a une date julienne en paramètre, on commence par positionner celle-ci
		if (jd) Fonction_JD(h, interp, IndexGuide, jd);

		// Orientation vers le menu approprié
		//===================================
		// Le ciel profond
		if ( ((strncmp(maj(p), "M", 1)   == 0) && *(p+1) >= '0' && *(p+1) <= '9' ) ||
		 	  (strncmp(maj(p), "NGC", 3) == 0) ||
			  (strncmp(maj(p), "IC", 2)  == 0) ||
			  (strncmp(maj(p), "A", 1)   == 0) )
		{
			Action_Guide_NGCIC(h, interp, IndexGuide, argc, argv);
			Tcl_SetResult(interp, "0", TCL_VOLATILE);
			return TCL_OK;
		}

		// Les planetes
		if ( (strncmp(maj(p), "MOON", 4)    == 0) ||
			 (strncmp(maj(p), "SUN", 3)     == 0) ||
			 (strncmp(maj(p), "MERCURY", 7) == 0) ||
			 (strncmp(maj(p), "VENUS", 5)   == 0) ||
			 (strncmp(maj(p), "MARS", 4)    == 0) ||
			 (strncmp(maj(p), "JUPITER", 7) == 0) ||
			 (strncmp(maj(p), "SATURN", 6)  == 0) ||
			 (strncmp(maj(p), "URANUS", 6)  == 0) ||
			 (strncmp(maj(p), "NEPTUNE", 7) == 0) ||
			 (strncmp(maj(p), "PLUTO", 5)   == 0) )
		{
			Action_Guide_Planetes(h, interp, IndexGuide, argc, argv);
			Tcl_SetResult(interp, "0", TCL_VOLATILE);
			return TCL_OK;
		}

		Tcl_SetResult(interp, "6", TCL_VOLATILE);
		return TCL_OK;
	} // End-OBJET

	//************************************************************
	//*  COORDONNEES
	//************************************************************
	if (!strcmp(maj(argv[1]), "COORD")) {
		if (argc < 5) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		p = argv[2];
		q = argv[3];

		// S'il y a une date julienne en paramètre, on commence par positionner celle-ci
		if (jd) Fonction_JD(h, interp, IndexGuide, jd);

		// Envoie les coordonnées
		Action_Guide_RADEC(h, interp, IndexGuide, argc, argv);

		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "ZOOM")) {
		if (argc < 3) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		res = Action_Guide_Zoom(h, interp, IndexGuide, argc, argv);

		sprintf(s, "%d", res);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "VERSION")) {
		if (argc < 1) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		sprintf(s, "GUIDE%d", VersionGuide);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "SHOW")) {
		if (argc < 2) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}
		ShowWindow(h, SW_MAXIMIZE);
		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "HIDE")) {
		if (argc < 2) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}
		ShowWindow(h, SW_MINIMIZE);
		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "RESTORE")) {
		if (argc < 2) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}
		ShowWindow(h, SW_RESTORE);
		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "CAPTURE")) {
		if (argc < 2) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		res = Action_Guide_Capture(h, interp, IndexGuide, argc, argv);

		sprintf(s, "%d", res);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return TCL_OK;
	}

	if (!strcmp(maj(argv[1]), "REFRESH")) {
		if (argc < 2) {
			Tcl_SetResult(interp, "2", TCL_VOLATILE); // Pas assez de paramètres
			return TCL_OK;
		}

		res = Action_Guide_Refresh(h, interp, IndexGuide, argc, argv);

		sprintf(s, "%d", res);
		Tcl_SetResult(interp, s, TCL_VOLATILE);
		return TCL_OK;
	}

	Tcl_SetResult(interp, "3", TCL_VOLATILE); // Mot-clé non trouvé
	return TCL_OK;
}

////////////////////////////////////
// Point d'entrée de la librairie //
////////////////////////////////////
int Gs_Init(Tcl_Interp *interp)

{

   if(Tcl_InitStubs(interp,"8.3",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libxx.",TCL_STATIC);
      return TCL_ERROR;
   }

	Tcl_CreateCommand(interp, "gs_version", (Tcl_CmdProc *)Version, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
	Tcl_CreateCommand(interp, "gs_guide", (Tcl_CmdProc *)SelectGuide, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

   return TCL_OK;
}

// CarteADLink.hxx: interface for the CarteADLink class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CARTEADLINK_HXX__A63FADDE_87E5_44EA_83C3_3BC5103F6B46__INCLUDED_)
#define AFX_CARTEADLINK_HXX__A63FADDE_87E5_44EA_83C3_3BC5103F6B46__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <exception> // les mecanismes d'exceptions
#include <Windows.h> // definitions de types utilisés par la librairie de la carte
#include "Dask.h" // la librairie de la carte AD-Link

class CarteADLink {
public :
	bool getNextData(unsigned short *array, unsigned long sx, unsigned long sy, bool *done);
	bool getNextImaqData(unsigned short *array, unsigned long sx, unsigned long sy, bool *done, int *nbimage);
	unsigned m_bufextracted;
	bool m_continue;
	bool m_readrunning;
	unsigned long m_bufcount;
	// constructeur
	CarteADLink(bool configurer=true);

	// lecture auxilaires

	// configuration acquisition
//	setPolarite( bool polaDeclencheur=true, bool polaRequete=false, bool polaAcquittement=true);

	// operations buffer
//	unsigned long setBuffer(unsigned short *inBuffer, unsigned long inTaille);
//	void detruireBuffer();

	// acquisition
	bool lancerAcquisition(unsigned long sx, unsigned long sy);
	bool testerFinAcquisition();
	void stopperAcquisition();
	bool HasWorkingHardware();

	// destructeur
	~CarteADLink();
	int identificateur;
	friend DWORD ReadThreadProc(void *param);
	bool ecrireAuxiliaire( unsigned int  ligne,	unsigned short donnee  );
	unsigned short lireAuxiliaire(unsigned int ligne);
	bool ecrireport ( char donnee);
	bool calculecarttype (double *sigma1,double *sigma2,double *sigma3,double *sigma4);
	bool NombreEchant(int nombreechant);


	bool savePLU(int savePLUon);// modif tb traitement d'image mars 2006 
	
private :
	char blancfile[100];
	char noirfile[100];
	int mode_bias;
	double moy_blanc;
	unsigned short *img_blanc; 
	unsigned short *img_noir;
	int traitement; 
	unsigned long moyennePLU;  
	unsigned short PLU[2080*2080];
//modif tb écart type...temporaire/pour les tests 
	unsigned short cadran1[1500]; 
	unsigned short cadran2[1500]; 
	unsigned short cadran3[1500]; 
	unsigned short cadran4[1500];
	bool ecarttype;
	unsigned long nombreimage;
	unsigned int nombreechantillon;

	bool sendData(unsigned short val);
	int provisoire;
	unsigned long logID;
	char m_logname[200];
	bool hashardware;
	unsigned long m_numofstripes;
	unsigned long m_numofimages;
	unsigned long m_pixelsperstripe;
	unsigned long adsx;
	unsigned long adsy;
	HANDLE m_thread;
	DWORD m_threadid;
	HMODULE dask;

	void chargerConfiguration(void);
	unsigned long lireAuxiliaire();
	
	unsigned long setTaille(unsigned long inTaille);

	// parametres de configuration
	unsigned int largeurPort;
	unsigned int horloge;
	unsigned int declencheur;
	unsigned int terminator;
	unsigned int polariteReq;
	unsigned int polariteAck;
	unsigned int polariteTrig;
	bool viderFile;
	bool desactiverAN;

	// donnees buffer mots
	unsigned int taille;
	unsigned short *buffer;
	unsigned short *bufferout;// modif tb pour écrire sur le port de sortie PB0PB15

	// lecture
	unsigned int modeSynchro;
	double taux;
	unsigned long m_tailleMax;					// donne la capa max de donnees kon peut acquerir

	// les constantes
	// enregistrement
	static unsigned int Type;
	static unsigned int Numero;
	// lecture et écriture auxiliaire
	static unsigned int PortEntreeAuxiliaire;
	static unsigned int PortSortieAuxiliaire;
	static unsigned int PortSortie;
	// lecture et écriture principale
	static unsigned int PortEntreeMots; 
	static unsigned int PortSortieMots;

	// niveau de debogage 0 rien, 1 pas de demux des data et conserve la synchro
	int m_affbrut;
	HFILE m_Dump;
	bool ReadExoFile(char * fpgaFile, char * dataBuf, char bitnumber, long *count);
	bool ReadRbtFile(char * fpgaFile, char * dataBuf, char bitnumber, long *count);

public:
	// ajuste le niveau du debug
	void SetDebugLevel(int lelvel);
	// télécharger en slave serial le code des FPGA
	bool SerialDownload(void);
	bool ModeBias(short modebiasvalue);
	bool RESET();

};

#endif // !defined(AFX_CARTEADLINK_HXX__A63FADDE_87E5_44EA_83C3_3BC5103F6B46__INCLUDED_)

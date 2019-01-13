// controleur.h: interface for the Ccontroleur class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CONTROLEUR_H__1ACB3878_A7EB_430A_B4C2_AE37EA2EC33C__INCLUDED_)
#define AFX_CONTROLEUR_H__1ACB3878_A7EB_430A_B4C2_AE37EA2EC33C__INCLUDED_

#include "CarteADLink.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifdef CID_API_EXPORTS
#define CID_API __declspec(dllexport)
#else
#define CID_API __declspec(dllimport)
#endif


#include "port.h"

class CID_API Ccontroleur  
{
public:
	bool ReadRegister(int add, long *octet);
	bool WriteRegister(int add, int val);
	bool savePLU(int savePLUon);//modif tb traitement image mars 2006
	bool SetImageSize(unsigned long sx, unsigned long sy);
	bool GetImageSize(unsigned long *sx, unsigned long *sy);
	bool Stop(bool immediat=false);
	bool Abort(bool immediat=false);
	bool ecrit_registre(unsigned char add, long val);
	bool lit_registre(unsigned char add, long *val);
	unsigned long PrendrePhoto(unsigned short *data, unsigned long taille);
	unsigned long PrendreImaqPhoto(unsigned short *data, unsigned long taille);
	bool Start(void);
	Ccontroleur();
	CarteADLink *adlink;
	virtual ~Ccontroleur();
	bool GetStatusCamera(bool *etat0, bool *etat1);
	bool SetAmplisObtu(bool on,bool on2,bool on3,bool on4,int on5);
	void GetPOLALimits(int voie, float * min1,  float *max1);
	bool SetPOLA(unsigned int n, float val);
	bool SetDECALAGE(unsigned int n, unsigned int val);
	double GetPOLAConsigne(unsigned int n);
	bool GetStatusAmplis(bool *comG, bool *comBP, bool *comL, bool *ampliam, bool *ampliof);
	bool GetStatusObtu(bool *onoff, bool *am, bool *ouvfer);
	bool m_camerastarted;
	bool SetConfCalcul(short ConfCalcul);
	bool EcrireAuxiliaire(unsigned int ligne,unsigned short donnee);
	unsigned short LireAuxiliaire( unsigned int  ligne);
	bool EcrirePORT (unsigned short donnee);
	bool CalculEcartType (double *sigma1,double *sigma2,double *sigma3,double *sigma4);
	bool nombreEchant(int nombreechant);
	bool SerialDownload();
	bool ModeBias(short modebiasvalue);


private:
	bool valtohex(long v, short nboctets, char * buf);
	bool hextoval(char *buf, short nboctets, long *val);
	unsigned long m_sizey;
	unsigned long m_sizex;
	int valeur_binning;
	bool valeur_HV;
	unsigned char hasworkingadlink();
	unsigned short * bufferAcquisition;
	float *gainarray;
	unsigned short dclevel;
	float m_polmax[20];
	float m_polmin[20];
	unsigned int polatoentier(unsigned char voie, float v);
	bool m_polchanged;
	bool m_amplison;
	double m_pol[30];
	double m_polHV[30];
	double polHV[30];
	double polHR[30];
	bool debugfpga;
		
	char m_portname[20];
	char m_logname[200];
	HFILE m_Dump;
	unsigned long logID;
	long m_baudrate;
	long m_binningx;
	long m_binningy;
	double m_timeout;
	int m_debuglevel;
	port *p;
	
	// recalcule la taille de l'image pour le binning en cours et l'aire choisie
	void AdjustImageSize(void);
public:
	void Initialise(bool fromregistry = true);
	void SaveRegistry();
	bool Reset(void);
	// // coordonnées du point haut à gauche (fenetre toujours centrée)
	bool SetArea(unsigned short x0, unsigned short y0, unsigned short xb = 10000, unsigned short yb = 10000);
	bool GetArea(unsigned short *x0, unsigned short *y0, unsigned short *xb, unsigned short *yb);
	// Lit les données d'une images
	unsigned long GetNextImage(unsigned short * data, bool parbandes, bool *fin_image, int *nbimage);
	void SetDebugLevel(int level);
	bool SetModeBinning(bool HV, unsigned int binning, unsigned int vitesse, bool debug);

	bool SetTempsExposition(double pose, bool *erreur);
	bool GetStatusCameraVhdl(bool *bit7 , bool *bit6 , bool *bit5 , bool *bit4 , bool *bit3 , bool *bit2 , bool *bit1 , bool *bit0);
	bool GetStatusWordCameraVhdl(long *mot);
	
	bool GetTempsExposition(double *pose,bool *erreur );
	bool ResetADLINK();
	bool GetTargetRegistry(int *TargetStatic, int *TargetDynamic, int *TargetStaticB,int *TargetDynamicB,int *TargetStaticHV,int *TargetDynamicHV);
	bool SetTempsExposition2(double pose, bool *erreur);
	bool GetTempsExposition2(double *pose, bool *erreur );
	bool SetTempsExpositionLimit(bool *erreur);
	bool GetTempsExpositionLimit(double *pose, bool *erreur); 
	//double ReadMyDoubleKey2(CString keyvalue, double defval);
	double ReadMyDoubleKey2(char keyvalue[100], double defval);
	/*double ReadMyDoubleKeyDEC1(double defval);
	double ReadMyDoubleKeyDEC2(double defval);
	double ReadMyDoubleKeyDEC3(double defval);
	double ReadMyDoubleKeyDEC4(double defval);*/

};

#endif // !defined(AFX_CONTROLEUR_H__1ACB3878_A7EB_430A_B4C2_AE37EA2EC33C__INCLUDED_)

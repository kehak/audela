// Alims.h: interface for the CAlims class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ALIMS_H__76E383B0_B800_4361_BB34_1AA3F966C08B__INCLUDED_)
#define AFX_ALIMS_H__76E383B0_B800_4361_BB34_1AA3F966C08B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include "port.h"


#ifdef CID_API_EXPORTS
#define CID_API __declspec(dllexport)
#else
#define CID_API __declspec(dllimport)
#endif


class CID_API Cthermo
{
public:
	Cthermo(char * type);
	double todegre(unsigned int mic);
	unsigned int fromdegre(double t);

private:
	double A, B, C;
};

class CID_API CAlims  
{
public:
	bool GetTemperature(int n, double *temp);
	Cthermo *th1;
	Cthermo *th2;
	bool SetBasseTension(bool on);
	double GetVRConsigne(unsigned int n);
	bool GetStatus(bool *alert, bool *supply, bool *peltier, bool *bt, bool *tachedefond);
	bool SetPeltierConsigne(unsigned int cons);
	bool GetSupply(float  *v5, float  *v15, float *vm15, float * v18, float *vm18);
	void GetVRLimits(int voie, float * min,  float *max);
	bool GetVR(unsigned int n, float *val);
	bool SetVR(unsigned int n, float val);
	bool SetPeltier(bool on);
	bool SetSupply(bool onoff);
	bool SetModeTension(bool HR,unsigned int binning);
	CAlims();
	virtual ~CAlims();

private:
	float m_vmax[7];
	float m_vmin[7];
	float microtovolt(unsigned char voie, unsigned char mic);
	unsigned int volttomicro(unsigned char voie, float v);
	double convtempECH(unsigned int val);
	double convtempDF(unsigned int val);
	double convcourpelt(unsigned int val);
	unsigned int doubletoint(double valeur);
	double inttodouble (unsigned int valeur);
	double m_timeout;
	long m_baudrate;
	char m_portname[20];
	bool m_supplyon;
	bool m_bassetension;
	bool m_vrchanged;
	bool m_tempchanged;
	bool m_peltier;
	double m_consigne;
	double m_vr[8];
	double vrHV[7];
	double vrHR[7];
	double sup_coefs[5];
	bool vinv[7];
	bool VRset;
	port *p;
};

#endif // !defined(AFX_ALIMS_H__76E383B0_B800_4361_BB34_1AA3F966C08B__INCLUDED_)

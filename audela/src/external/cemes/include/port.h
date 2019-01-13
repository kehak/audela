/* Port Série */

#ifndef PORT_H
#define PORT_H
#include <windows.h>

class  __declspec(dllexport) port {
public:
	void stop();
	void clear();
	port();
	~port();
	unsigned long start(char *nom_port, long baudrate , float time_out);
	
	int write(char*, int);
	int read(char*, int);
	
	void set_ti(int ti);
	HANDLE	_h;
	char	_inbuf[200];
	int	_inpos;
	void fin_tr();
	bool begin_tr(); 
	
private:
	COMMCONFIG _conf;
	COMMTIMEOUTS _oldTimeouts;
	COMMTIMEOUTS _Timeouts;
	char	_name[20];
	DCB		_initialdcb;
	bool	_started;
	bool	realccd;
	float _time_out;
	HANDLE mutex;
	long counter;
};
#endif

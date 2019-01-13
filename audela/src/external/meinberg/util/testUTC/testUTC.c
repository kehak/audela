#include <stdio.h>
#include <sys/time.h>
#include <sys/timex.h>
#include <stdint.h>
#include <stdlib.h>
/* --- MEINBERG INCLUDES ---*/
#include <mbgdevio.h>
#include <toolutil.h>
#include <pcpsutil.h>

MBG_DEV_HANDLE dh;

int main(int argc, char **argv) {

	int i,c,devices_found,num_meas;
	struct timespec cl_start, cl_stop;
	struct ntptimeval ntpts;
	struct timeval tv;
	struct tm *ptm;
	struct tm *sysptm;
	FILE *f;
	/* --- Meinberg variables ---*/
	int32_t hns_latency = 0;
	PCPS_TIME_STAMP ts;

	if ( argc < 3 ) {
		fprintf(stderr, "Usage: %s measures output_file\n",argv[0]);
		return -2;
	}

	/* --- number of measures to be taken --- */
	num_meas = atoi(argv[1]);

	/* --- OPEN MEINBERG --- */
	c = mbgdevio_get_version();
	fprintf(stderr,"version = %d\n",c);
	devices_found = mbg_find_devices();
	if (devices_found == 0) {
		fprintf(stderr,"No GPS meinberg card found Meinberg\n");
		return -1;
	}
	i = devices_found-1;
	dh = mbg_open_device(i);
	if ( dh == MBG_INVALID_DEV_HANDLE ) {
		fprintf(stderr,"Can't open GPS device Meinberg\n");
		return -1;
	}
	fprintf(stderr,"Connection with Meinberg is opened\n");

	/* --- open output measure file ---*/
	f=fopen(argv[2],"w");
	fprintf(f,"# MeinbergUTC [s]\tlatency [us]\tSysTime [s]\tNTP_UTC [s]\testerr [us]\tmaxerr [us]\tinterval [ns]\n");
	fprintf(f,"# Times are expressed in seconds from midnight\n");

	/* --- MAIN CYCLE ---*/
	for ( i=0; i<num_meas; i++) {
		clock_gettime(CLOCK_MONOTONIC,&cl_start);
		gettimeofday( &tv, NULL );
		/* --- GET MEINBERG TIMESTAMP ---*/
		mbg_get_fast_hr_timestamp_comp( dh, &ts, &hns_latency );
		/* --- GET SYSTEM TIMESTAMP --- */
		ntp_gettime( &ntpts );
		clock_gettime(CLOCK_MONOTONIC,&cl_stop);
		printf("FRAME %d\n",i);
		printf("Interval %lu nsec ( %f usec )\n",(unsigned long)(cl_stop.tv_nsec-cl_start.tv_nsec),(cl_stop.tv_nsec-cl_start.tv_nsec)/1000.);
		printf("MEINBERG ");
		mbg_print_hr_timestamp( &ts, hns_latency, NULL, 0, 0);
		ptm = gmtime(&ntpts.time.tv_sec);
		sysptm = gmtime(&tv.tv_sec);
		printf("System timestamp: %2d:%02d:%02d.%06lu\n",sysptm->tm_hour,sysptm->tm_min,sysptm->tm_sec,(unsigned long)tv.tv_usec);
		printf("NTP timestamp: %2d:%02d:%02d.%06lu, estimated error %ld, maximum error %ld\n",ptm->tm_hour,ptm->tm_min,ptm->tm_sec,(unsigned long)ntpts.time.tv_usec,ntpts.esterror,ntpts.maxerror);
		fprintf(f,"%u.%07u\t%d\t%lu.%06lu\t%lu.%06lu\t%ld\t%ld\t%lu\n",ts.sec,frac_sec_from_bin(ts.frac,PCPS_HRT_FRAC_SCALE),hns_latency,(unsigned long)tv.tv_sec,(unsigned long)tv.tv_usec,(unsigned long)ntpts.time.tv_sec,(unsigned long)ntpts.time.tv_usec,ntpts.esterror,ntpts.maxerror,(unsigned long)(cl_stop.tv_nsec-cl_start.tv_nsec));
	}
	fclose(f);

	/* --- CLOSE MEINBERG ---*/
	mbg_close_device( &dh );
	fprintf(stderr,"Connection with meinberg is closed\n");
	return 0;
}	

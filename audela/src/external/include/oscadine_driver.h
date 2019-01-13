//
// Oscadine driver
//

#ifndef __OSCADINE_DRIVER_H__
#define __OSCADINE_DRIVER_H__

#ifdef __cplusplus
extern "C" {
#endif

	struct camera_struct {
		/* Dummy pixels present at the begining and at the end of each lines depending on the CCD */
		/* 10 + 2 for KAAF400 & KAF1600 & 12 + 3 for KAF3200 */
		int start_dummy_pixels;
		int end_dummy_pixels;
		float exptime;
		int shutterindex;
		int nb_photox;
		int nb_photoy;
		int binx;
		int biny;
		int x1;
		int x2;
		int y1;
		int y2;
		int h;
		int w;
	};
	
	int init_usb(void);
	int close_usb(void);
    void setLedModeOff();
	void setLedModeOn();
    void *capture(void * threadid);
	void get_image(unsigned short *image);
	void open_shutter();
	void close_shutter();
    void init_cam_parameters(struct camera_struct *cam);
	void stop_exp();
	void launch_capture_thread();
	
#ifdef __cplusplus
}
#endif

#endif


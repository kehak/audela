
#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#if defined(OS_LIN)
#include <unistd.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <math.h>
#include <libcam/util.h>

#include "camera.h"
#include "oscadine_driver.h"

// modif michel
#ifdef  _WIN32  
#if _MSC_VER >= 1900
// definition de stdout et stderr pour oscadine.lib compilée avec un ancien Visual studio
FILE _iob[] = { *stdin, *stdout, *stderr };
extern "C" FILE * __cdecl __iob_func(void) { return _iob; }
#endif 
#endif

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf401",			/* ccd name */
     784, 520,			/* maxx maxy 768, 512 + overscan*/
     4, 12,			/* overscans x */
     4, 4,			/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf1602",			/* ccd name */
     1552, 1032,		/* maxx maxy 1536,1024 + overscan */
     4, 12,				/* overscans x */
     4, 4,				/* overscans y */
     9e-6, 9e-6,		/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    {"Audine",			/* camera name */
     "audine",			/* camera product */
     "kaf3200",			/* ccd name */
     2252, 1510,		/* maxx maxy 2184, 1472 + overscan */ 
     34, 34,			/* overscans x */
     4, 34,				/* overscans y */
     6.8e-6, 6.8e-6,	/* photosite dim (m) */
     32767.,			/* observed saturation */
     1.,			/* filling factor */
     11.,			/* gain (e/adu) */
     11.,			/* readnoise (e) */
     1, 1,			/* default bin x,y */
     1.,			/* default exptime */
     1,				/* default state of shutter (1=synchro) */
     0,				/* default port index (0=lpt1) */
     1,				/* default cooler index (1=on) */
     -15.,			/* default value for temperature checked */
     1,				/* default color mask if exists (1=cfa) */
     0,				/* default overscan taken in acquisition (0=no) */
     1.				/* default focal lenght of front optic system */
     },
    CAM_INI_NULL
};

int hideOverscan 		= 0; // 1 to hide overscan
int overscanUpdated 	= 0;
struct camera_struct *camera;

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop * cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);
void update_camera_params(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
    cam_init,			/* init */
    cam_close,			/* close */
    cam_set_binning,		/* set_binning */
    cam_update_window,		/* update_window */
    cam_start_exp,		/* start_exp */
    cam_stop_exp,		/* stop_exp */
    cam_read_ccd,		/* read_ccd */
    cam_shutter_on,		/* shutter_on */
    cam_shutter_off,		/* shutter_off */
    NULL,			/* ampli_on */
    NULL,			/* ampli_off */
    NULL,	/* measure_temperature */
    NULL,		/* cooler_on */
    NULL,		/* cooler_off */
    NULL		/* cooler_check */
};

/*
 * Echange deux entiers pointes par a et b.
 */
/*void libcam_swap(int *a, int *b)
{
    register int t;
    t = *a;
    *a = *b;
    *b = t;
}*/

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */


/* --------------------------------------------------------- */
/* ---							 --- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* ---							 --- */
/* --------------------------------------------------------- */
int cam_init(struct camprop *cam, int argc, const char **argv)
{
	char *ccd;
	int i;

	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_init \n");
	///////////////////////////////////////////////////

	/* je remplace les valeurs par defaut par les valeurs choisies  */
	/* par l'utilisateur dans le panneau de configuration de audace */
	for (i = 0; i < argc - 1; i++) {
	printf("     %s\n",argv[i]);

		if (strcmp(argv[i], "-ledsettings") == 0) {

		     if ((i + 1) <= (argc - 1)) {
				if (strcmp(argv[i + 1], "1") == 0) {
					setLedModeOff();
		        }
				else {
					setLedModeOn();
				}
			}  
    	}
		else if (strcmp(argv[i], "-overscansettings") == 0) {

		     if ((i + 1) <= (argc - 1)) {
				if (strcmp(argv[i + 1], "1") == 0) {
					hideOverscan = 1;
		        }
				else {
					hideOverscan = 0;
				}
			}  
    	}
		else if (strcmp(argv[i], "-ccd") == 0) {
		     if ((i + 1) <= (argc - 1)) {
				ccd = (char*) argv[i + 1];
			}  
    	}	
		
	}

	cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
	
	/* --- pour l'amplificateur des Kaf-401 (synchro by default) --- */
	cam->ampliindex = 0;
	cam->nbampliclean = 60;
	/* --- pour les obturateurs montes en sens inverse --- */
	cam->shutteraudinereverse = 0;
	/* --- pour le type de CAN --- */
	cam->cantypeindex = 0;


	// simplified camera structure declared in the driver
	camera = (struct camera_struct *) calloc(1, sizeof(struct camera_struct));

	update_camera_params(cam);

	//printf("%s", ccd);
	if(strncmp(ccd, "kaf32", 5) == 0) {
		//printf("KAAAAAAAAAAAAAAFFFFFFF 3200\n");
		camera->start_dummy_pixels 	= START_DUMMY_PIXELS_320x;
		camera->end_dummy_pixels	= END_DUMMY_PIXELS_320x;
	}
	else {
		//printf("KAAAAAAAAAAAAAAFFFFFFF 400 1600\n");
		camera->start_dummy_pixels 	= START_DUMMY_PIXELS_40x_160x;
		camera->end_dummy_pixels	= END_DUMMY_PIXELS_40x_160x;	
	}

	return init_usb();
}

void update_camera_params(struct camprop *cam) 
{
	camera->exptime 			= cam->exptime;
	camera->shutterindex 		= cam->shutterindex;
	camera->nb_photox 			= cam->nb_photox;
	camera->nb_photoy 			= cam->nb_photoy;
	camera->binx 				= cam->binx;
	camera->biny 				= cam->biny;
	camera->x1 					= cam->x1;
	camera->x2 					= cam->x2;
	camera->y1 					= cam->y1;
	camera->y2 					= cam->y2;
	camera->h					= cam->h;
	camera->w 					= cam->w;

	printf("%f --- %d", cam->exptime, cam->shutterindex);
}

int cam_close(struct camprop * cam)
{	
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_close\n");
	///////////////////////////////////////////////////

	free(camera);

	return close_usb();
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_start_exp\n");
	///////////////////////////////////////////////////

	// Retrieve User parameters
	update_camera_params(cam);

	// We send cature parameters to Oscadine
	init_cam_parameters(camera);

	// Exposition time is managed by the Oscadine to ensure more precise values
	// So we launch the capture now 
	// This is done this way to let Audela show the progress bar (even it's not precise)
	// When cam_read_ccd will be called, it will just retrive the image pointer already available
	launch_capture_thread();

}

void cam_stop_exp(struct camprop *cam)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_stop_exp\n");
	///////////////////////////////////////////////////

	// On arrête l'exposition si la capture n'a pas commencé.
	if(cam->exptimeTimer > 0) {
		stop_exp();
	}
		
}

void cam_read_ccd(struct camprop *cam, float *p)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_read_ccd\n");
	//////////////////////////////////////////////////
	
   unsigned short* pushort = (unsigned short*) malloc(  cam->w * cam->h * sizeof(unsigned short)); 
   if( pushort==NULL) {
      return;
   }
   // je lis l'image
	get_image(pushort);

   // je copie l'image dans le buffer de sortie
   int pixelNb = cam->w*cam->h;
   while(pixelNb--) {
      *(p++) = *(pushort++);
   }
   free(pushort);

	overscanUpdated = 0;
	printf("%i x %i px\n", cam->w, cam->h);
}

void cam_shutter_on(struct camprop *cam)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_shutter_on %d \n", cam->shutterindex);
	///////////////////////////////////////////////////

	open_shutter();
}

void cam_shutter_off(struct camprop *cam)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_shutter_off %d \n", cam->shutterindex);
	///////////////////////////////////////////////////

	close_shutter();
}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_set_binning\n");
	///////////////////////////////////////////////////
	cam->binx = binx;
	cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
	int maxx;
	int maxy;

	///////////////////////////////////////////////////
	printf("@@@@@@@@ OSCADINE  cam_update_window\n");
	///////////////////////////////////////////////////

	// Si l'overscan est caché on crée en fait un fenêtrage.
	// Dans le cas d'une acquisition fenêtrée les dimensions d'overscan sont aussi aujoutées
	// overscanUpdated est utilisé car cam_update_window est appellé plusieurs fois
	if(hideOverscan == 1 && !overscanUpdated) {
		cam->x1 += cam->nb_deadbeginphotox;
		cam->y1 += cam->nb_deadbeginphotoy;

		cam->x2 -= cam->nb_deadendphotox;
		cam->y2 -= cam->nb_deadendphotoy;

		overscanUpdated = 1;
	}
	
	maxx = cam->nb_photox;
	maxy = cam->nb_photoy;
    
	if (cam->x1 > cam->x2)
		libcam_swap(&(cam->x1), &(cam->x2));
	if (cam->x1 < 0)
		cam->x1 = 0;
	if (cam->x2 > maxx - 1)
		cam->x2 = maxx - 1;

	if (cam->y1 > cam->y2)
		libcam_swap(&(cam->y1), &(cam->y2));
	if (cam->y1 < 0)
		cam->y1 = 0;
	if (cam->y2 > maxy - 1)
		cam->y2 = maxy - 1;

	cam->w = (cam->x2 - cam->x1) / cam->binx + 1;
	cam->x2 = cam->x1 + cam->w * cam->binx - 1;
	cam->h = (cam->y2 - cam->y1) / cam->biny + 1;
	cam->y2 = cam->y1 + cam->h * cam->biny - 1;

	if (cam->x2 > maxx - 1) {
		cam->w = cam->w - 1;
		cam->x2 = cam->x1 + cam->w * cam->binx - 1;
	}

	if (cam->y2 > maxy - 1) {
		cam->h = cam->h - 1;
		cam->y2 = cam->y1 + cam->h * cam->biny - 1;
	}
}



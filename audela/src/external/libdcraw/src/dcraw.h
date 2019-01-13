// File   :libdcraw.h .
// Date   :05/08/2005
// Author :Michel Pujol

#define CLASS

#ifdef WIN32
typedef long off_t;
#endif


#define ushort UshORt
typedef unsigned char uchar;
typedef unsigned short ushort;

extern   ushort (*image)[4];
extern   char *ifname, *meta_data;
extern   FILE *ifp;
extern   char make[64];
extern   char model[72];
extern   float flash_used, iso_speed, shutter, aperture, focal_len;
extern   time_t timestamp;
extern   int flip;
extern   unsigned filters;
extern   unsigned meta_length;
extern   int verbose;
extern   int output_color;
extern   off_t data_offset;

extern   ushort iheight, iwidth, shrink;
extern   ushort height, width, fuji_width;
extern   ushort top_margin, left_margin;
extern   unsigned colors;
extern   unsigned is_foveon;
extern   int document_mode;
//extern   int quick_interpolate;
//extern   int xmag, ymag;
extern   int histogram[3][0x2000];
extern   float bright;
extern   unsigned is_raw;
extern   unsigned black, maximum, use_gamma;
extern   float pre_mul[4];
extern   float rgb_cam[3][4];
//extern   int raw_height, raw_width, top_margin, left_margin;
//extern   int clip_color;

extern void CLASS identify ();
extern void CLASS merror (void *ptr, char *where);
extern void CLASS bad_pixels();
extern void CLASS foveon_interpolate();
extern void CLASS scale_colors();
extern void CLASS lin_interpolate();
extern void CLASS vng_interpolate();
extern void CLASS ahd_interpolate();
extern void CLASS fuji_rotate();
extern void CLASS convert_to_rgb();
extern void CLASS flip_image();
extern void CLASS cam_to_cielab (ushort cam[4], float lab[3]);
extern void CLASS pre_interpolate();

extern void (*load_raw)();
//extern void write_ppm(FILE *);
extern void (*write_fun)(FILE *);

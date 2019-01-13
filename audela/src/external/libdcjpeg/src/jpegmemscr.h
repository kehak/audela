
// File   :jpegmemsrc.h .
// Date   :05/08/2005
// Author :Michel Pujol

#ifndef __JPEG_MEM_SRC_H__
#define __JPEG_MEM_SRC_H__

#include "jpeglib.h"

#ifdef __cplusplus
extern "C" {
#endif

void               mem_init_source (j_decompress_ptr cinfo);
boolean            mem_fill_input_buffer (j_decompress_ptr cinfo);
void               mem_skip_input_data (j_decompress_ptr cinfo, long num_bytes);

void               mem_term_source (j_decompress_ptr cinfo);
void               jpeg_mem_src (j_decompress_ptr cinfo, unsigned char *mbuff, int mbufflen);

#ifdef __cplusplus
}
#endif

#endif


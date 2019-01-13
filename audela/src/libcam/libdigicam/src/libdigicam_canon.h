// File   :libdigicam_canon.h .
// Date   :05/08/2005
// Author :Michel Pujol

// Description : simple API for libgphoto2 library

#pragma once

float canonShutterValueIndexToTime(int shutterIndex);
float canonShutterValueLabelToTime(char* exposureTimeLabel);
int canonShutterValueTimeToIndex(float timeValue);
const char * canonShutterValueTimeToLabel(float timeValue) ;

int canon_getQualityList(char *list);


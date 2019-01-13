// CropDialogListener.cpp: implementation of the CCropConfig class.
//
//////////////////////////////////////////////////////////////////////

#include <windows.h>
#include "CropConfig.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCropConfig::CCropConfig()
{
    x1 = 0;
    y1 = 0;
    x2 = 99999;
    y2 = 99999;
    maxHeight = 100000;
    maxWidth  = 100000;
}

CCropConfig::~CCropConfig()
{

}

long CCropConfig::getX1(){ return x1; }
long CCropConfig::getY1(){ return y1; }
long CCropConfig::getX2(){ return x2; }
long CCropConfig::getY2(){ return y2; }
long CCropConfig::getMaxWidth() { return maxWidth; }
long CCropConfig::getMaxHeight(){ return maxHeight; }

long CCropConfig::getWidth() { return x2-x1+1; }
long CCropConfig::getHeight(){ return y2-y1+1; }
long CCropConfig::getLeft() { return x1; }
long CCropConfig::getTop() { return maxHeight - y2 -1; }


BOOL CCropConfig::setX1(long value){
    BOOL result;
    if( value >= 0 && value < maxWidth -1 ) {
        x1 = value;
        if( x1 >= x2 )  x2 = x1 +1 ;
        result = TRUE;
    } else {
        result = FALSE;
    }

    return result;
}

BOOL CCropConfig::setY1(long value){
    BOOL result;
    if( value >= 0 && value < maxHeight -1 ) {
        y1 = value;
        if( y1 >= y2 )  y2 = y1 +1 ;
        result = TRUE;
    } else {
        result = FALSE;
    }
    return result;
}

BOOL CCropConfig::setX2(long value){
    BOOL result;
    if( value > 1 && value < maxWidth ) {
        x2 = value;
        if( x1 >= x2 )  x1 = x2 -1 ;
        result = TRUE;
    } else {
        result = FALSE;
    }
    return result;
}

BOOL CCropConfig::setY2(long value){
    BOOL result;
    if( value > 1 && value < maxHeight ) {
        y2 = value;
        if( y1 >= y2 )  y1 = y2 -1 ;
        result = TRUE;
    } else {
        result = FALSE;
    }

    return result;
}


BOOL CCropConfig::setMaxWidth(long value){
    BOOL result;

    if(value > 1 ) {
        maxWidth = value;
        if( x1 >= value )  x1 = value -2;
        if( x2 >= value )  x2 = value -1;
        result = TRUE;
    } else {
        result = FALSE;
    }

    return result;
}

BOOL CCropConfig::setMaxHeight(long value){
    BOOL result;
    
    if(value > 1 ) {
        maxHeight = value;
        if( y1 >= value )  y1 = value -2;
        if( y2 >= value )  y2 = value -1;
        result = TRUE;
    } else {
        result = FALSE;
    }

    return result;

}

/**
 *  getCropRect
 *  
 */
void CCropConfig::getCropRect(RECT *lpRect) {
    lpRect->left = x1;
    lpRect->top  = maxHeight - y2 -1;
    lpRect->right = x2;
    lpRect->bottom = maxHeight - y1 -1;
}


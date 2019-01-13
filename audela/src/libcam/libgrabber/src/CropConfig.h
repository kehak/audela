// CropInfo.h: interface for the CCropInfo class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CROPCONFIG_H__7C86C716_348B_405B_A285_37201EFDAEDA__INCLUDED_)
#define AFX_CROPCONFIG_H__7C86C716_348B_405B_A285_37201EFDAEDA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif				// _MSC_VER > 1000


class CCropConfig {
  public:
    CCropConfig();
    virtual ~ CCropConfig();
    long getX1();
    long getY1();
    long getX2();
    long getY2();
    long getMaxWidth();
    long getMaxHeight();
    BOOL setX1(long value);
    BOOL setY1(long value);
    BOOL setX2(long value);
    BOOL setY2(long value);
    BOOL setMaxHeight(long value);
    BOOL setMaxWidth(long value);

    long getLeft();
    long getTop();
    long getWidth();
    long getHeight();
    void getCropRect(RECT * lpRect);


  protected:
    long x1;
    long y1;
    long x2;
    long y2;
    long maxWidth;
    long maxHeight;

};

#endif				// !defined(AFX_CROPCONFIG_H__7C86C716_348B_405B_A285_37201EFDAEDA__INCLUDED_)

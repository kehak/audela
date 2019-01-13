av4l Documentation                         {#mainpage}
============

Synopsis
--------

The AudeLA contrib/av4l provides :

 - a library for reading AVI files under Linux and Windows.

 - a video recorder for Linux (but not for Windows) for USB grabbers.


The AVI library
---------------

The AVI library provides a TCL extension that permit to read an AVI
file into the Audace visu. For example, the ATOS analysis tool use it either to
directly analyze each frame from an AVI file or to extract frames
from an AVI to a series of FITS files.


The video recorder
------------------

The Linux video recorder is an executable that records autonomously
an AVI file. It is called from the Audace interface and provides
feedback of the recording process. It relies on the video4linux2 API
of the Linux kernel. And has been exclusively designed to support
videos provided by USB grabbers which image format is 720x576 pixels
with color encoding in packed YUV422 at 25 fps.

The output is an AVI file encoded in the 720x576 YUV422 planar format
at 25fps; frames are compressed with the lossless compression huffyuv.


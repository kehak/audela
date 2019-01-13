This folder contains the C sources of the HEALPix library.
For more information about HEALPix see http://healpix.jpl.nasa.gov
and read the file src/READ_Copyrights_Licences.txt.

AudeLA uses C sources of the HEALPix library embeded in Tcl.
To do that the C sources are restructured into a single
file that can be included in Tcl extension librairies.

To build the single C source file, execute the Tcl script:

source "$audace(rep_install)/src/external/healpix/build_healpix.tcl"

The files are:
"$audace(rep_install)/src/external/healpix/chealpix.c"
"$audace(rep_install)/src/external/healpix/chealpix.h"

For example, they are used in the libak Tcl extension library.

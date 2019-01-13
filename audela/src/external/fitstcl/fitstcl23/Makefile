HD_COMPONENT_NAME	= ftools

HD_COMPONENT_VERS	= 

HD_LIBRARY_ROOT		= fitstcl

HD_LIBRARY_SRC_c	= fitsCmds.c fitsInit.c fitsIO.c fitsTcl.c \
			  fitsUtils.c fvTcl.c tclShared.c

HD_CFLAGS		= -I${CFITSIO_DIR} ${HD_STD_CFLAGS}

HD_INSTALL_LIBRARIES	= ${HD_LIBRARY_ROOT}

HD_INSTALL_HEADERS	= fitsTcl.h fitsTclInt.h

HD_INSTALL_HELP		= fitsTcl.html

default: build-libfitstcl

all: default publish

include ${HD_STD_MAKEFILE}

# Get cfitsio source files and prepend ${CFITSIO_DIR} prefix to each filename.
CFITSIO_OBJ_TMP		= ${shell ${MAKE} -f ${CFITSIO_DIR}/Makefile cfitsioLibObjs | grep buffers}

CFITSIO_OBJ		= ${shell echo ${CFITSIO_OBJ_TMP} | sed "s: : ../../../heacore/cfitsio/:g" | sed "s:^:../../../heacore/cfitsio/:"}

${CFITSIO_OBJ}:
	@for file in ${CFITSIO_OBJ}; do \
		if [ ! -f $$file ]; then \
			echo "Cannot find CFITSIO object $$file"; exit 1; \
		fi; \
	done

WCSLIB_OBJ		= ../../../heacore/wcslib/C/wcstrig.o

${WCSLIB_OBJ}:
	@for file in ${WCSLIB_OBJ}; do \
		if [ ! -f $$file ]; then \
			echo "Cannot find WCS object $$file"; exit 1; \
		fi; \
	done

build-libfitstcl:
	@if [ "x${CFITSIO_OBJ}" = x ]; then \
		echo "CFITSIO_OBJ macro is empty";  exit 1; \
	fi
	${HD_MAKE} fitstcl HD_LIBRARY_ROOT=fitstcl \
		HD_LIBRARY_OBJ="${HD_LIBRARY_SRC_c:.c=.${OSUF}} ${CFITSIO_OBJ} ${WCSLIB_OBJ}"

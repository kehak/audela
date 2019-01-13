.PHONY: all build clean cleanall distclean install uninstall 
.PHONY: check_ffmpeg_build check_ffmpeg_install

include ../../../Makefile.defs

FFMPEG=../../../external/ffmpeg/ffmpeg-0.8.5
SRC=../src
VPATH = ../src

CFLAGS = -Wall -g -O2
LDFLAGS = 
#TARGET_ARCH = -m32

INCLUDES_FFMPEG =
INCLUDES_FFMPEG += -I $(FFMPEG)

LDFLAGS_FFMPEG =
LDFLAGS_FFMPEG += -L$(FFMPEG)/libavformat -L$(FFMPEG)/libavcodec
LDFLAGS_FFMPEG += -L$(FFMPEG)/libavutil -L$(FFMPEG)/libavdevice -L$(FFMPEG)/libswscale


all:
	@-test -e $(FFMPEG)/libavcodec/libavcodec.so.53 && \
	test -e $(FFMPEG)/libavfilter/libavfilter.so.2 && \
	test -e $(FFMPEG)/libavformat/libavformat.so.53 && \
	test -e $(FFMPEG)/libavutil/libavutil.so.51 && \
	test -e $(FFMPEG)/libswscale/libswscale.so.2 && \
	test -e $(FFMPEG)/libavdevice/libavdevice.so.53 || \
	{ echo "CONTRIB/AV4L: ERREUR: external/ffmpeg n'a pas ete compile"; exit 1; } && $(MAKE) build
	@-test -e $(ROOT)/../bin/libavcodec.so.53 && \
	test -e $(ROOT)/../bin/libavfilter.so.2 && \
	test -e $(ROOT)/../bin/libavformat.so.53 && \
	test -e $(ROOT)/../bin/libavutil.so.51 && \
	test -e $(ROOT)/../bin/libswscale.so.2 && \
	test -e $(ROOT)/../bin/libavdevice.so.53 || \
	{ echo "CONTRIB/AV4L: WARNING: external/ffmpeg n'a pas ete installe." ; \
	  echo " Le module av4l ne fonctionnera pas correctement" ; \
	  exit 0 ; } && $(MAKE) install


build: check_ffmpeg_build check_ffmpeg_install libavi.so grab


cleanall: clean

distclean: clean uninstall

clean:
	rm -f libavi.so avi.o
	rm -f grab grab.o proto_filex.o proto_null.o 
	rm -rf dox ../doxygen_documentation


libavi.so: CFLAGS += -shared -fPIC
libavi.so: CPPFLAGS += $(INCLUDES_FFMPEG) $(AUD_TCL_INCLUDE_SPEC)
libavi.so: LDFLAGS += $(LDFLAGS_FFMPEG) -shared -fPIC
libavi.so: LDLIBS = -lavformat -lavcodec -lavutil -lswscale -lm $(AUD_TCL_STUB_LIB_SPEC)
libavi.so: avi.o
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@


grab: CPPFLAGS += $(INCLUDES_FFMPEG)
grab: LDFLAGS += $(LDFLAGS_FFMPEG)
grab: LDLIBS += -lavformat -lavcodec -lavutil -lavdevice -lswscale -lm -lpthread
grab: grab.o proto_filex.o proto_null.o
	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@


doc: $(SRC)/Doxyfile $(SRC)/avi.c $(SRC)/grab.c $(SRC)/proto_filex.c $(SRC)/proto_null.c $(SRC)/mainpage.md
	( cd $(SRC) && doxygen )


uninstall: clean
	rm -f ../../../../bin/libavi.so
	rm -f ../../../../bin/av4l-grab

install: check_ffmpeg_install libavi.so grab
	cp -vf libavi.so ../../../../bin/
	cp -vf grab ../../../../bin/av4l-grab


check_ffmpeg_build:
	@test -e $(FFMPEG)/libavcodec/libavcodec.so.53 && \
	test -e $(FFMPEG)/libavfilter/libavfilter.so.2 && \
	test -e $(FFMPEG)/libavformat/libavformat.so.53 && \
	test -e $(FFMPEG)/libavutil/libavutil.so.51 && \
	test -e $(FFMPEG)/libswscale/libswscale.so.2 && \
	test -e $(FFMPEG)/libavdevice/libavdevice.so.53 || \
	{ echo "CONTRIB/AV4L: ERREUR: external/ffmpeg n'a pas ete compile"; exit 1; }

check_ffmpeg_install:
	@test -e $(ROOT)/../bin/libavcodec.so.53 && \
	test -e $(ROOT)/../bin/libavfilter.so.2 && \
	test -e $(ROOT)/../bin/libavformat.so.53 && \
	test -e $(ROOT)/../bin/libavutil.so.51 && \
	test -e $(ROOT)/../bin/libswscale.so.2 && \
	test -e $(ROOT)/../bin/libavdevice.so.53 || \
	{ echo "CONTRIB/AV4L: WARNING: external/ffmpeg n'a pas ete installe." ; \
	  echo " Le module av4l ne fonctionnera pas correctement" ; \
	  exit 0 ; }


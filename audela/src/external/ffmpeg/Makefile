.PHONY: all clean cleanall distclean install uninstall 
.PHONY: ffmpeg-clean ffmpeg-config ffmpeg ffmpeg-uninstall ffmpeg-install

include ../../Makefile.defs
DIR = ffmpeg-0.8.5

ifeq ($(TARGET_ARCH),-m32)
 ffmpeg_config_extra = --extra-cflags=-m32 --extra-ldflags=-m32
else
 ffmpeg_config_extra =
endif

build:
	@if test ! -e $(DIR)/config.mak || test ../../Makefile.defs -nt $(DIR)/config.mak; then \
		cd $(DIR) || exit ; \
		chmod +x configure ; \
		./configure --prefix=`pwd`/../.. \
			--enable-pic --enable-shared --enable-static $(ffmpeg_config_extra) \
			--disable-doc --disable-pthreads --disable-network \
			--disable-outdevs \
			--disable-indevs --enable-indev=v4l2 \
			--disable-protocols --enable-protocol=file \
			--disable-encoders --enable-encoder=ffvhuff --enable-encoder=huffyuv --enable-encoder=rawvideo \
			--disable-decoders --enable-decoder=ffvhuff --enable-decoder=huffyuv --enable-decoder=rawvideo --enable-decoder=h264 \
			--disable-muxers --enable-muxer=avi \
			--disable-demuxers --enable-demuxer=avi \
			--disable-bsfs \
			--disable-parsers \
			--disable-yasm \
		|| exit ; \
	fi
	$(MAKE) -C $(DIR)

install:
	cp -vf $(DIR)/libavcodec/libavcodec.so.53 ../../../bin/
	cp -avf $(DIR)/libavcodec/libavcodec.so ../../../bin/
	cp -vf $(DIR)/libavfilter/libavfilter.so.2 ../../../bin/
	cp -avf $(DIR)/libavfilter/libavfilter.so ../../../bin/
	cp -vf $(DIR)/libavformat/libavformat.so.53 ../../../bin/
	cp -avf $(DIR)/libavformat/libavformat.so ../../../bin/
	cp -vf $(DIR)/libavutil/libavutil.so.51 ../../../bin/
	cp -avf $(DIR)/libavutil/libavutil.so ../../../bin/
	cp -vf $(DIR)/libswscale/libswscale.so.2 ../../../bin/
	cp -avf $(DIR)/libswscale/libswscale.so ../../../bin/
	cp -avf $(DIR)/libavdevice/libavdevice.so ../../../bin/
	cp -vf $(DIR)/libavdevice/libavdevice.so.53 ../../../bin/

clean:
	$(MAKE) -C $(DIR) clean

distclean:
	$(MAKE) -C $(DIR) distclean
	rm -f *~ *.bak

uninstall:
	rm -f ../../../bin/{libavcodec.*,libavfilter.*,libavformat.*,libavutil.*,libswscale.*,libavdevice.*}


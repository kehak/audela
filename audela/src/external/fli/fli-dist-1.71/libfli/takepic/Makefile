CC	= gcc

INC	= .. $(HOME)/templates /usr/local/include/libpng /usr/pkg/include

#CFLAGS	= -Wall -O2 $(patsubst %, -I%, $(INC))
CFLAGS	= -Wall -g $(patsubst %, -I%, $(INC))
CFLAGS	+= -DUSEPNG
CFLAGS	+= -DUSEFITS

LIBS	= fli png cfitsio
LIBPATH	= .. /usr/local/lib /usr/pkg/lib
LDLIBS	= $(patsubst %, -l%, $(LIBS))
LOADLIBES= $(patsubst %, -L%, $(LIBPATH))

takepic: takepic.c #png.c
	$(CC) $(CFLAGS) -o $@ $^ $(LOADLIBES) $(LDLIBS)

.PHONY: clean
clean:
	rm -f takepic

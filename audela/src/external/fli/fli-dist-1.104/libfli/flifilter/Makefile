CC	= gcc

INC	= .. $(HOME)/templates /usr/pkg/include

#CFLAGS	= -Wall -O2 $(patsubst %, -I%, $(INC))
CFLAGS	= -Wall -g $(patsubst %, -I%, $(INC))

LIBS	= fli m
LIBPATH	= .. /usr/local/lib /usr/pkg/lib
LDLIBS	= $(patsubst %, -l%, $(LIBS))
LOADLIBES= $(patsubst %, -L%, $(LIBPATH))

flifilter: flifilter.c
	$(CC) $(CFLAGS) -o $@ $^ $(LOADLIBES) $(LDLIBS)

.PHONY: clean
clean:
	rm -f flifilter

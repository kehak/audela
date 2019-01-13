OUTPUT = CCD_Driver.so

#CXXFLAGS = -c -fno-common -fPIC -Wall -O2 -I $(SRCDIR)
#LDFLAGS  = -shared -ldl -lpthread

SRC  = $(SRCDIR)/CCD_Driver.c $(SRCDIR)/ethernaude_make.c
SRC += $(SRCDIR)/ethernaude_util.c $(SRCDIR)/etherlinkudp.c
SRC += $(SRCDIR)/UDPSocketComponent.c $(SRCDIR)/direct_driver.c

OBJ  = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

LDFLAGS += -lpthread

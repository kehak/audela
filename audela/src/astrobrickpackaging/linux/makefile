#  makefile.vc 
#  deploy astrobricks

include ../../Makefile1

BIN=../../../bin
ASTROBRICK_CSHARP=../../../astrobrick_user/csharp
ASTROBRICK_PYTHON=../../../astrobrick_user/python

SRC= $(BIN)/libabsimple.so \
     $(BIN)/libcatalog.so

DEST_CSHARP = $(patsubst $(BIN)%, $(ASTROBRICK_CSHARP)%, $(SRC))
DEST_PYTHON = $(patsubst $(BIN)%, $(ASTROBRICK_PYTHON)%, $(SRC))

#-- regle pour copier la librairie de BIN vers ASTROBRICK_CSHARP
$(ASTROBRICK_CSHARP)%.so: $(BIN)/%.so
	$(CP) $< $@	

#-- regle pour copier la librairie de BIN vers ASTROBRICK_PYTHON
$(ASTROBRICK_PYTHON)%.so: $(BIN)/%.so
	$(CP) $< $@	

#--- build : copy ab libraries to astrobrick user folder
all: $(DEST_CSHARP) $(DEST_PYTHON)

#--- clean	
clean: 
	echo " clean log"
	$(RM) $(DEST_CSHARP) $(DEST_PYTHON)

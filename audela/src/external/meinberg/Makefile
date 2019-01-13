CP=cp -f
RM=rm -f
RMDIR=rm -rf

SOURCE=.
LIB_BIN=$(SOURCE)/linux
SRC_INC=$(SOURCE)/include
SRC_LIB=$(SOURCE)/src
BINARY=../../../bin
INCLUDE=../include
INC_MEIN=$(INCLUDE)/meinberg
LIBRARY=../lib

build:
	make -C $(LIB_BIN)

install:
	test -d $(INCLUDE) || mkdir $(INCLUDE)
	test -d $(INC_MEIN) || mkdir $(INC_MEIN)
	$(CP) $(SRC_INC)/*.h $(INC_MEIN)
	$(CP) $(SRC_LIB)/meinberg.h $(INC_MEIN)
	test -d $(LIBRARY) || mkdir $(LIBRARY)
	$(CP) $(LIB_BIN)/libmeinberg.so $(BINARY)

clean:
	$(RMDIR) $(INC_MEIN)
	$(RM) $(BINARY)/libmeinberg.so
	$(RM) $(LIB_BIN)/*.o $(LIB_BIN)/*.so 



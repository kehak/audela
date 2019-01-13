OUTPUT   = libcatalog.so
OUTPUT_HEADER = libcatalog.h

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -fvisibility=hidden -DLIBCATALOG_EXPORTS

#-- copy le header dans le repertoire src/include
$(INCLUDE)/$(OUTPUT_HEADER) : $(SRCDIR)/$(OUTPUT_HEADER)
	$(CP) $(SRCDIR)/$(OUTPUT_HEADER) $@ 

all: $(OUTPUT) $(INCLUDE)/$(OUTPUT_HEADER)

astrobrick-clean:
	$(RM) $(INCLUDE)/$(OUTPUT_HEADER)

clean: astrobrick-clean

.PHONY : build  clean

OUTPUT=audela_csharp
SRCDIR=.

all: $(OUTPUT)

SRC = $(wildcard *.cs)

$(OUTPUT):  $(SRC) 
	mcs $(SRC) -out:$(OUTPUT)

clean:
	@rm -f $(OUTPUT)


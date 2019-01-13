include ../Makefile.defs

MYTARGETS = $(LIBLINKS)

all: $(MYTARGETS)

.PHONY: $(MYTARGETS) clean cleanall

$(MYTARGETS):
	(cd $@/linux; make)

clean cleanall:
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR)/linux $@ ; )


.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~

dist-clean: local-clean
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR)/linux distclean -o makedep ; )

dist: dist-clean
	mkdir $(distdir)
	cp -r * $(distdir)

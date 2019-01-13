.phony: install uninstall

COPY=cp
REMOVE=rm
TARGET=acq
INST_DIR=/usr/local/bin

install: $(TARGET).py
	$(COPY) $(TARGET).py $(INST_DIR)/$(TARGET)

uninstall:
	test -e $(INST_DIR)/$(TARGET) && $(REMOVE) $(INST_DIR)/$(TARGET)

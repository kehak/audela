.phony: install uninstall

COPY=cp
REMOVE=rm
INSTALL_DIR=/usr/local/sbin
TARGET=pixci.sh

install: $(TARGET)
	$(CC) $(TARGET) $(INSTALL_DIR)/$(TARGET)

uninstall:
	test -e $(INSTALL_DIR)/$(TARGET) || $(REMOVE) $(INSTALL_DIR)/$(TARGET)

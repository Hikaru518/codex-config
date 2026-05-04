INSTALL_DIR ?= $(HOME)/.local/bin
SCRIPT := $(CURDIR)/bin/codex-config-init
LINK := $(INSTALL_DIR)/codex-config-init

install:
	mkdir -p "$(INSTALL_DIR)"
	chmod +x "$(SCRIPT)"
	ln -sf "$(SCRIPT)" "$(LINK)"
	@echo "Installed: codex-config-init -> $(LINK)"
	@echo ""
	@echo "Make sure $(INSTALL_DIR) is in your PATH."

uninstall:
	rm -f "$(LINK)"
	@echo "Uninstalled: $(LINK)"

.PHONY: install uninstall

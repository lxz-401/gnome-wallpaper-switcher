PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
SYSTEMD_USER_DIR ?= $(PREFIX)/lib/systemd/user
BASH_COMPLETION_DIR ?= $(PREFIX)/share/bash-completion/completions
ZSH_COMPLETION_DIR ?= $(PREFIX)/share/zsh/site-functions
DOCDIR ?= $(PREFIX)/share/doc/gnome-wallpaper-switcher
LICENSEDIR ?= $(PREFIX)/share/licenses/gnome-wallpaper-switcher

.PHONY: all install uninstall

all:
	@echo "gnome-wallpaper-switcher is a shell script and does not need compilation."
	@echo "Run 'sudo make install' to install system-wide, or 'make install PREFIX=\$$HOME/.local' for user install."

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 bin/gnome-wallpaper-switcher $(DESTDIR)$(BINDIR)/gnome-wallpaper-switcher
	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)
	install -m 644 systemd/gnome-wallpaper-switcher.service $(DESTDIR)$(SYSTEMD_USER_DIR)/gnome-wallpaper-switcher.service
	install -d $(DESTDIR)$(BASH_COMPLETION_DIR)
	install -m 644 completions/bash/gnome-wallpaper-switcher $(DESTDIR)$(BASH_COMPLETION_DIR)/gnome-wallpaper-switcher
	install -d $(DESTDIR)$(ZSH_COMPLETION_DIR)
	install -m 644 completions/zsh/_gnome-wallpaper-switcher $(DESTDIR)$(ZSH_COMPLETION_DIR)/_gnome-wallpaper-switcher
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 config/config.conf.example $(DESTDIR)$(DOCDIR)/config.conf.example
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/README.md
	install -d $(DESTDIR)$(LICENSEDIR)
	install -m 644 LICENSE $(DESTDIR)$(LICENSEDIR)/LICENSE

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/gnome-wallpaper-switcher
	rm -f $(DESTDIR)$(SYSTEMD_USER_DIR)/gnome-wallpaper-switcher.service
	rm -f $(DESTDIR)$(BASH_COMPLETION_DIR)/gnome-wallpaper-switcher
	rm -f $(DESTDIR)$(ZSH_COMPLETION_DIR)/_gnome-wallpaper-switcher
	rm -rf $(DESTDIR)$(DOCDIR)
	rm -rf $(DESTDIR)$(LICENSEDIR)

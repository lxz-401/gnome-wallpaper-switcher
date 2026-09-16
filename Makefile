PKGNAME ?= gnome-wallpaper-switcher
VERSION ?= 1.2.0
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
SYSTEMD_USER_DIR ?= $(PREFIX)/lib/systemd/user
BASH_COMPLETION_DIR ?= $(PREFIX)/share/bash-completion/completions
ZSH_COMPLETION_DIR ?= $(PREFIX)/share/zsh/site-functions
DOCDIR ?= $(PREFIX)/share/doc/$(PKGNAME)
LICENSEDIR ?= $(PREFIX)/share/licenses/$(PKGNAME)

.PHONY: all install uninstall deb pacman packages dist clean

all:
	@echo "$(PKGNAME) is a shell script and does not need compilation."
	@echo "Build targets:"
	@echo "  make install         - Install to \$$(DESTDIR)\$$(PREFIX) (default /usr)"
	@echo "  make uninstall       - Remove installed files"
	@echo "  make deb             - Build Debian/Ubuntu (.deb) package for APT"
	@echo "  make pacman          - Build Arch Linux (.pkg.tar.zst) package"
	@echo "  make packages        - Build both .deb and .pkg.tar.zst packages"
	@echo "  make dist            - Create source release tarball"

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

deb:
	@chmod +x scripts/build-deb.sh
	./scripts/build-deb.sh

pacman:
	@echo ":: Building Arch Linux package via makepkg..."
	makepkg -f --nodeps

packages: deb pacman
	@echo "✓ All packages built successfully:"
	@ls -lh *.deb *.pkg.tar.zst 2>/dev/null || true

dist:
	@echo ":: Creating release tarball $(PKGNAME)-$(VERSION).tar.gz..."
	git archive --format=tar.gz --prefix=$(PKGNAME)-$(VERSION)/ -o $(PKGNAME)-$(VERSION).tar.gz HEAD
	@echo "✓ Created $(PKGNAME)-$(VERSION).tar.gz"

clean:
	rm -rf pkg src *.pkg.tar.zst *.deb $(PKGNAME)-*.tar.gz

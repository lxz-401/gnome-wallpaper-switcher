#!/usr/bin/env bash
# ==============================================================================
# build-deb.sh: Builds standard Debian/Ubuntu (.deb) package without dpkg-deb
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

PKG_NAME="gnome-wallpaper-switcher"
VERSION="1.2.0"
REVISION="1"
ARCH="all"
DEB_FILE="${PKG_NAME}_${VERSION}-${REVISION}_${ARCH}.deb"

BUILD_DIR="$(mktemp -d /tmp/deb-build.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

echo ":: Building Debian package: $DEB_FILE"

# 1. Install files into staging directory
DEST="$BUILD_DIR/data"
mkdir -p "$DEST"
make DESTDIR="$DEST" PREFIX=/usr install

# Install Debian docs & changelog
DOC_DIR="$DEST/usr/share/doc/$PKG_NAME"
mkdir -p "$DOC_DIR"
cp debian/copyright "$DOC_DIR/copyright"
gzip -9n -c debian/changelog > "$DOC_DIR/changelog.Debian.gz"
chmod 644 "$DOC_DIR/copyright" "$DOC_DIR/changelog.Debian.gz"

# Compute installed-size in KiB
INSTALLED_SIZE=$(du -sk "$DEST" | cut -f1)

# 2. Prepare control directory
CTRL="$BUILD_DIR/control"
mkdir -p "$CTRL"
cp debian/control "$CTRL/control"

# Append Installed-Size to control file
echo "Installed-Size: $INSTALLED_SIZE" >> "$CTRL/control"
chmod 644 "$CTRL/control"

# Optional md5sums
(
    cd "$DEST"
    find . -type f ! -path "./DEBIAN/*" -exec md5sum {} + | sed 's| \./| |' > "$CTRL/md5sums"
    chmod 644 "$CTRL/md5sums"
)

# 3. Create debian-binary
echo "2.0" > "$BUILD_DIR/debian-binary"

# 4. Pack control.tar.xz
(
    cd "$CTRL"
    tar --sort=name --owner=0 --group=0 --numeric-owner -cJf "$BUILD_DIR/control.tar.xz" *
)

# 5. Pack data.tar.xz
(
    cd "$DEST"
    tar --sort=name --owner=0 --group=0 --numeric-owner -cJf "$BUILD_DIR/data.tar.xz" *
)

# 6. Assemble .deb using ar (exact order: debian-binary, control.tar.xz, data.tar.xz)
rm -f "$SCRIPT_DIR/$DEB_FILE"
(
    cd "$BUILD_DIR"
    ar -qc "$SCRIPT_DIR/$DEB_FILE" debian-binary control.tar.xz data.tar.xz
)

echo "✓ Successfully created: $DEB_FILE ($(du -h "$SCRIPT_DIR/$DEB_FILE" | cut -f1))"

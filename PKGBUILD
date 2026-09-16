# Maintainer: lxz-401 <lxz-401@users.noreply.github.com>

pkgname=gnome-wallpaper-switcher
pkgver=1.2.0
pkgrel=1
pkgdesc="Modular CLI wallpaper switcher and daemon for GNOME on Arch Linux"
arch=('any')
url="https://github.com/lxz-401/gnome-wallpaper-switcher"
license=('MIT')
depends=('bash' 'glib2')
optdepends=(
    'libnotify: desktop notifications on wallpaper change'
)
source=()
sha256sums=()

package() {
    if [ -d "$srcdir/$pkgname-$pkgver" ]; then
        cd "$srcdir/$pkgname-$pkgver"
    else
        cd "$startdir"
    fi

    make DESTDIR="$pkgdir" PREFIX=/usr install
}

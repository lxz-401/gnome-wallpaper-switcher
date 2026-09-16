#!/usr/bin/env bash
# ==============================================================================
# setup-local-pacman-repo.sh: Configures a local Arch pacman repository so that
# 'sudo pacman -S gnome-wallpaper-switcher' installs directly from pacman.
# ==============================================================================
set -euo pipefail

REPO_DIR="/var/cache/pacman/custom"
REPO_NAME="custom"
PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_FILE="$PKG_DIR/gnome-wallpaper-switcher-1.2.0-1-any.pkg.tar.zst"

if [[ ! -f "$PKG_FILE" ]]; then
    echo ":: Package not found. Building it now..."
    (cd "$PKG_DIR" && make pacman)
fi

echo ":: 1. Repozitoriya papkasini yaratish ($REPO_DIR)..."
sudo mkdir -p "$REPO_DIR"

echo ":: 2. Paketni repozitoriyaga ko'chirish..."
sudo cp "$PKG_FILE" "$REPO_DIR/"

echo ":: 3. repo-add orqali ma'lumotlar bazasini yangilash..."
sudo repo-add -R "$REPO_DIR/$REPO_NAME.db.tar.zst" "$REPO_DIR/$(basename "$PKG_FILE")"

echo ":: 4. /etc/pacman.conf sozlamalarini tekshirish..."
if ! grep -q "^\[$REPO_NAME\]" /etc/pacman.conf; then
    echo ":: [$REPO_NAME] repozitoriyasini /etc/pacman.conf ga qo'shish..."
    sudo tee -a /etc/pacman.conf <<EOF

[$REPO_NAME]
SigLevel = Optional TrustAll
Server = file://$REPO_DIR
EOF
    echo "✓ /etc/pacman.conf muvaffaqiyatli yangilandi."
else
    echo "✓ [$REPO_NAME] allaqachon /etc/pacman.conf faylida mavjud."
fi

echo ":: 5. Pacman keshini yangilash..."
sudo pacman -Sy

echo ""
echo -e "\033[1;32m===================================================================\033[0m"
echo -e "\033[1;36m🎉 TABRIKLAYMIZ! Pacman repozitoriyasi muvaffaqiyatli ulandi!\033[0m"
echo -e "\033[1;32m===================================================================\033[0m"
echo -e "Endi to'g'ridan-to'g'ri quyidagi buyruq orqali o'rnatishingiz mumkin:"
echo ""
echo -e "   \033[1;33msudo pacman -S gnome-wallpaper-switcher\033[0m"
echo ""

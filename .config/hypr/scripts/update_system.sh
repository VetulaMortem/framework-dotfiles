sudo pacman -Syu && yay -Syu
#&& flatpak update; sleep 1; grep "Name=(Flatpak) "  /var/lib/flatpak/exports/share/applications/*.desktop -L | sudo xargs -I% sed -i 's/Name=/Name=\(Flatpak\) /g' %

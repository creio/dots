#!/bin/sh
set -ex
if type find &>/dev/null; then
	printf "\n"
else
	printf "missing findutils\n"
	exit 1
fi
if type convert &>/dev/null; then
	printf "\n"
else
	printf "missing imagemagick\n"
	exit 1
fi
_basedir="$(dirname "$(readlink -f "${0}")")"
cd "$_basedir"
if [ -d "$_basedir"/icons ]; then
	rm -rf "$_basedir"/icons
fi
mkdir -p "$_basedir"/icons
###16px
for _f in $(find "$_basedir"/../../../../../icons/DarK/16x16/pool -mindepth 1 -name '*.png' \
-not -name "gnome-*" -not -name "x-content*" -not -name "application-*" -not -name "image-*" \
-not -name "audio-*" -not -name "video-*" -not -name "stock_*" -not -name "stock-*" \
-not -name "battery-*" -not -name "csd-*" -not -name "cs-*" -not -name "gimp-*" -not -name "gpm-*" \
-not -name "gtk-*" -not -name "mypaint-*" -not -name "org.*" -not -name "package_*" -not -name "pidgin-*" \
-not -name "si-*" -not -name "weather-*" -not -name "xfce4-*" -not -name "xfce-*" -not -name "xfpm-*" -not -name "yast-*" \
-not -name "view-*" -not -name "zoom-*" -not -name "document-*" -not -name "zoom-*" -not -name "view-*" -not -name "edit-*" \
-not -name "edit-*" -not -name "fcitx-*" -not -name "e-module-*" -not -name "path-*" -not -name "media-*" -not -name "draw-*" \
-not -name "applications-*" -not -name "brasero-*" -not -name "blueman-*" -not -name "format-*" -not -name "network-*" \
-not -name "nm-*" -not -name "object-*" -not -name "package-*" -not -name "text-*" -not -name "tool-*" -not -name "mate-*" \
-not -name "align-*" -not -name "bluebery-*" -not -name "byzanz-*" -not -name "paint-*" -not -name "*-applet-*" -not -name "show-*" \
-not -name "transform-*" -not -name "snap-*" -not -name "text_*" -not -name "user-*" -not -name "mail-*" -not -name "dialog-*" \
-not -name "drive-*" -not -name "gajim-*" -not -name "glables-*" -not -name "goa-*" -not -name "go-*" -not -name "gtg-*" \
-not -name "hb-*" -not -name "help-*" -not -name "ibus-*" -not -name "im-*" -not -name "inode-*" -not -name "input-*" \
-not -name "insert-*" -not -name "kali-*" -not -name "kbd-*" -not -name "kdenlive-*" -not -name "kipi-*" -not -name "kwave_*" \
-not -name "libreoffice*" -not -name "light-*" -not -name "multimedia-player-*" -not -name "node-*" -not -name "openofficeorg*" \
-not -name "pattern-*" -not -name "preferences-*" -not -name "printer-*" -not -name "progress-*" -not -name "template_*");do
	convert $_f $(echo $_f| sed 's\^.*/\icons/\;s\.png\_16x16.xpm\')
done

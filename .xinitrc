#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# sh ~/Scripts/wal.sh

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

xset b off
xsetroot -cursor_name left_ptr &
xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/artwiz-fonts &
xset +fp /usr/share/fonts/misc &
xset +fp /usr/share/fonts/bitmap &
xset +fp ~/.fonts &
xset fp rehash &
fc-cache -fv &

# exec i3
# exec openbox-session

#### autostarting applications bspwm
setxkbmap -layout us,ru -option "grp:win_space_toggle,grp_led:scroll" &
compton -b --config ~/.config/compton.conf &
hsetroot -center $HOME/.wall/wl3.jpg &
$HOME/.config/bspwm/polybar/launch.sh &
tint2 -c ~/.config/tint2/tray.tint2rc &
dunst &
thunar --daemon &
numlockx &
# xsettingsd &
xfce4-power-manager &
pulseaudio --start &
# mpd &
/usr/lib/xfce-polkit/xfce-polkit &
cornora -bl "skippy-xd" -tr "rofi -show run" &
telegram-desktop &
redshift-gtk &
greenclip daemon &
unclutter &
# udiskie -t &
# nm-applet &
# volumeicon &
megasync &
# caffeine &

sxhkd &
exec bspwm
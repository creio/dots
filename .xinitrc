#!/bin/sh

usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
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

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# xset b off
xsetroot -cursor_name left_ptr &
xset +fp /usr/share/fonts/local &
xset +fp /usr/share/fonts/misc &
xset +fp /usr/share/fonts/bitmap &
xset +fp ~/.fonts &
xset fp rehash &
# fc-cache -fv &

# dbus-update-activation-environment --all

# flashfocus &
# ~/.config/frankenwm/autostart &
# exec frankenwm
# exec monsterwm

# exec xmonad > $HOME/.xmonad/log.txt 2>&1
# exec 2bwm
# exec awesome
# exec dwm
# exec i3
exec openbox-session
# exec startinstantos

# exec gnome-session

# hsetroot -fill ~/.wall/lcrow.png &
# exec startxfce4

# ~/.config/xfwm/autostart &
# exec xfwm4

# sxhkd -c $HOME/.config/berry/sxhkdrc &
# exec berry

# ### bspwm autostart
# [ -f /etc/xprofile ] && source /etc/xprofile
# [ -f ~/.xprofile ] && source ~/.xprofile
# sh "${HOME}/.config/bspwm/autostart" &
# exec bspwm

# sh "${HOME}/.config/sowm/autostart" &
# exec sowm

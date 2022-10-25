#!/bin/sh

sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
usermodmap=$HOME/.Xmodmap

[[ -f $sysresources ]] && xrdb -merge $sysresources
[[ -f ~/.Xresources ]] && xrdb -merge $HOME/.Xresources
[[ -f $sysmodmap ]] && xmodmap $sysmodmap
[[ -f $usermodmap ]] && xmodmap $usermodmap

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xset -b off
# xsetroot -cursor_name left_ptr
# xset +fp /usr/share/fonts/local &
# xset +fp /usr/share/fonts/misc &
# xset +fp /usr/share/fonts/bitmap &
# xset +fp ~/.fonts &
# xset fp rehash &
# fc-cache -fv &

# dbus-update-activation-environment --all

### openbox-session|bspwm|frankenwm
DEFAULT_SESSION=bspwm

case $1 in
    xfce)
        exec startxfce4
    ;;
    kde)
        exec startkde
    ;;
    gnome)
        exec gnome-session
    ;;
    bspwm)
        exec bspwm
    ;;
    frankenwm)
        ~/.config/frankenwm/autostart &
        exec frankenwm
    ;;
    *)
        exec ${DEFAULT_SESSION:-openbox-session}
    ;;
esac

# flashfocus &
# exec monsterwm
# exec awesome
# exec dwm
# exec spectrwm
# exec leftwm

# python $HOME/.local/bin/i3-layouts &
# exec i3

# ~/.config/shod/autostart.sh &
# exec shod

# ~/.config/2bwm/autostart &
# exec 2bwm

# sh ~/.config/xfwm/autostart &
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

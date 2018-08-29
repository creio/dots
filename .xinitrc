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

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

case $session in
    awesome       ) exec awesome;;
    bspwm         ) exec bspwm;;
    catwm         ) exec catwm;;
    cinnamon      ) exec cinnamon-session;;
    dwm           ) exec dwm;;
    enlightenment ) exec enlightenment_start;;
    ede           ) exec startede;;
    evilwm        ) exec evilwm;;
    fluxbox       ) exec startfluxbox;;
    gnome         ) exec gnome-session;;
    gnome-classic ) exec gnome-session --session=gnome-classic;;
    i3            ) exec i3;;
    icewm         ) exec icewm-session;;
    jwm           ) exec jwm;;
    kde           ) exec startkde;;
    mate          ) exec mate-session;;
    monster       ) exec monsterwm;;
    notion        ) exec notion;;
    openbox       ) exec openbox-session;;
    lxde          ) exec startlxde;;
    swm           ) exec swm;;
    unity         ) exec unity;;
    xfce          ) exec startxfce4;;
    xmonad        ) exec xmonad;;
    # No known session, try to run it as command
    *) exec $1;;
esac

session=${1:-openbox}
# session=${1:-xfce}
#!/bin/bash


sublime_conf="$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
qt_conf="$HOME/.config/qt5ct/qt5ct.conf"


# preferences for light theme mode
PREF_LIGHT_THEME="lui"
PREF_LIGHT_DECO="lui"
PREF_LIGHT_BG="$HOME/.wall/Crowl.png"
PREF_LIGHT_ICO="lui-ico"

sublime_theme_light="gruvbox"
sublime_colorscheme_light="Packages\\/User\\/Boxy Yesterday.tmTheme"
# preferences for dark theme mode
PREF_DARK_THEME="dui"
PREF_DARK_DECO="dui"
PREF_DARK_BG="$HOME/.wall/lcrow.png"
PREF_DARK_ICO="dui-ico"

sublime_theme_dark="gruvbox"
sublime_colorscheme_dark="Packages\\/One Dark Color Scheme\\/One Dark.tmTheme"


# Xresources color theme ~/.colors
xresources_conf="$HOME/.Xresources"

xresources_color_light="colors\\/lui"
xresources_color_dark="colors\\/dui"

# rofi conf
rofi_conf="$HOME/.config/rofi/config"

# gtk.css
gtk_css="$HOME/.config/gtk-3.0/gtk.css"
br_color_light="#F4F5F6"
br_color_dark="#2B2C33"


de_theme="$(xfconf-query -c xsettings -p /Net/ThemeName)"


if [[ "$de_theme" == "$PREF_LIGHT_THEME" ]]; then
    xfconf-query -c xsettings -p /Net/ThemeName -s $PREF_DARK_THEME
    xfconf-query -c xfwm4 -p /general/theme -s $PREF_DARK_DECO
    xfconf-query -c xsettings -p /Net/IconThemeName -s $PREF_DARK_ICO
    hsetroot -fill $PREF_DARK_BG
    # for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l|egrep -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
    #     # if [ ! -z "$PREF_DARK_BG" ]; then xfconf-query -c xfce4-desktop -p $i -n -t string -s $PREF_DARK_BG ; fi
    #     if [ ! -z "$PREF_DARK_BG" ]; then xfconf-query -c xfce4-desktop -p $i -s $PREF_DARK_BG ; fi
    #     # if [ ! -z "$PREF_DARK_BG" ]; then xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s $PREF_DARK_BG ; fi
    # done
    xfconf-query -c xsettings -p /Gtk/DecorationLayout -s menu:minimize,maximize,close

    gsettings set org.gnome.desktop.interface gtk-theme $PREF_DARK_THEME
    gsettings set org.gnome.desktop.wm.preferences button-layout '"menu:minimize,maximize,close"'

    sed -i -e "s/$sublime_colorscheme_light/$sublime_colorscheme_dark/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_light.sublime-theme/$sublime_theme_dark.sublime-theme/g" "$sublime_conf"

    sed -i -e "s/$xresources_color_light/$xresources_color_dark/g" "$xresources_conf"
    # https://github.com/budlabs/youtube/tree/master/letslinux/021-urxvt-reload
    xrdb -merge $HOME/.Xresources
    # kill -1 $(pidof urxvtd)

    sed -i -e "s/$PREF_LIGHT_ICO/$PREF_DARK_ICO/g" "$rofi_conf"

    # sed -i -e "s/$br_color_light/$br_color_dark/g" "$gtk_css"

    sed -i -e "s/icon_theme=$PREF_LIGHT_ICO/icon_theme=$PREF_DARK_ICO/g" "$qt_conf"

else
    xfconf-query -c xsettings -p /Net/ThemeName -s $PREF_LIGHT_THEME
    xfconf-query -c xfwm4 -p /general/theme -s $PREF_LIGHT_DECO
    xfconf-query -c xsettings -p /Net/IconThemeName -s $PREF_LIGHT_ICO
    hsetroot -fill $PREF_LIGHT_BG
    # for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l|egrep -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
    #     # if [ ! -z "$PREF_LIGHT_BG" ]; then xfconf-query -c xfce4-desktop -p $i -n -t string -s $PREF_LIGHT_BG ; fi
    #     if [ ! -z "$PREF_LIGHT_BG" ]; then xfconf-query -c xfce4-desktop -p $i -s $PREF_LIGHT_BG ; fi
    #     # if [ ! -z "$PREF_LIGHT_BG" ]; then xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s $PREF_LIGHT_BG ; fi
    # done
    xfconf-query -c xsettings -p /Gtk/DecorationLayout -s menu:minimize,maximize,close

    gsettings set org.gnome.desktop.interface gtk-theme $PREF_LIGHT_THEME
    gsettings set org.gnome.desktop.wm.preferences button-layout '"menu:minimize,maximize,close"'

    sed -i -e "s/$sublime_colorscheme_dark/$sublime_colorscheme_light/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_dark.sublime-theme/$sublime_theme_light.sublime-theme/g" "$sublime_conf"

    sed -i -e "s/$xresources_color_dark/$xresources_color_light/g" "$xresources_conf"
    # https://github.com/budlabs/youtube/tree/master/letslinux/021-urxvt-reload
    xrdb -merge $HOME/.Xresources
    # kill -1 $(pidof urxvtd)

    sed -i -e "s/$PREF_DARK_ICO/$PREF_LIGHT_ICO/g" "$rofi_conf"

    # sed -i -e "s/$br_color_dark/$br_color_light/g" "$gtk_css"

    sed -i -e "s/icon_theme=$PREF_DARK_ICO/icon_theme=$PREF_LIGHT_ICO/g" "$qt_conf"
fi

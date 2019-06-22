#!/bin/bash


sublime_conf="$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
qt_conf="$HOME/.config/qt5ct/qt5ct.conf"
ob_rc="$HOME/.config/openbox/rc.xml"
ob_autostart="$HOME/.config/openbox/autostart"
xsettings_d="$HOME/.xsettingsd"


# preferences for light theme mode
OB_LIGHT_THEME="obll"
PREF_LIGHT_THEME="ll"
PREF_LIGHT_DECO="ll"
PREF_LIGHT_BG="$HOME/.wall/wl1.jpg"
PREF_LIGHT_BG_OB=".wall\\/wl1.jpg"
PREF_LIGHT_ICO="ll-ico"

sublime_theme_light="gruvbox"
sublime_colorscheme_light="Packages\\/User\\/Boxy Yesterday.tmTheme"

sublime_theme_dark="gruvbox"
sublime_colorscheme_dark="Packages\\/One Dark Color Scheme\\/One Dark.tmTheme"

# preferences for dark theme mode
OB_DARK_THEME="obln"
PREF_DARK_THEME="ln"
PREF_DARK_DECO="ln"
PREF_DARK_BG="$HOME/.wall/wl3.jpg"
PREF_DARK_BG_OB=".wall\\/wl3.jpg"
PREF_DARK_ICO="ln-ico"


# Xresources color theme ~/.colors
xresources_conf="$HOME/.Xresources"

xresources_color_light="colors\\/ll"
xresources_color_dark="colors\\/ln"


de_theme="$(xfconf-query -c xsettings -p /Net/ThemeName)"


if [[ "$de_theme" == "$PREF_LIGHT_THEME" ]]; then
    xfconf-query -c xsettings -p /Net/ThemeName -s $PREF_DARK_THEME
    # xfconf-query -c xsettings -p /Gtk/DecorationLayout -s menu:

    gsettings set org.gnome.desktop.interface gtk-theme $PREF_DARK_THEME
    # gsettings set org.gnome.desktop.wm.preferences button-layout '"menu:"'
    
    # sublime text
    sed -i -e "s/$sublime_colorscheme_light/$sublime_colorscheme_dark/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_light.sublime-theme/$sublime_theme_dark.sublime-theme/g" "$sublime_conf"

    # ~/.xsettingsd
    sed -i -e "s/$PREF_LIGHT_THEME/$PREF_DARK_THEME/g" "$xsettings_d"
    sed -i -e "s/$PREF_LIGHT_ICO/$PREF_DARK_ICO/g" "$xsettings_d"
    killall xsettingsd
    xsettingsd &

    # openbox theme
    sed -i -e "s/$OB_LIGHT_THEME/$OB_DARK_THEME/g" "$ob_rc"
    sed -i -e "s/$PREF_LIGHT_BG_OB/$PREF_DARK_BG_OB/g" "$ob_autostart"
    openbox --reconfigure

    # urxvt color palet
    # sed -i -e "s/$xresources_color_light/$xresources_color_dark/g" "$xresources_conf"
    # xrdb -merge $HOME/.Xresources
    # kill -1 $(pidof urxvt)

    # kitty
    # kitty @ set-colors -a $HOME/.config/kitty/night.conf

    # qt5ct
    sed -i -e "s/icon_theme=$PREF_LIGHT_ICO/icon_theme=$PREF_DARK_ICO/g" "$qt_conf"

    # wall
    hsetroot -fill $PREF_DARK_BG
else
    xfconf-query -c xsettings -p /Net/ThemeName -s $PREF_LIGHT_THEME
    # xfconf-query -c xsettings -p /Gtk/DecorationLayout -s menu:

    gsettings set org.gnome.desktop.interface gtk-theme $PREF_LIGHT_THEME
    # gsettings set org.gnome.desktop.wm.preferences button-layout '"menu:"'
    
    # sublime text
    sed -i -e "s/$sublime_colorscheme_dark/$sublime_colorscheme_light/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_dark.sublime-theme/$sublime_theme_light.sublime-theme/g" "$sublime_conf"

    # ~/.xsettingsd
    sed -i -e "s/$PREF_DARK_THEME/$PREF_LIGHT_THEME/g" "$xsettings_d"
    sed -i -e "s/$PREF_DARK_ICO/$PREF_LIGHT_ICO/g" "$xsettings_d"
    killall xsettingsd
    xsettingsd &

    # openbox theme
    sed -i -e "s/$OB_DARK_THEME/$OB_LIGHT_THEME/g" "$ob_rc"
    sed -i -e "s/$PREF_DARK_BG_OB/$PREF_LIGHT_BG_OB/g" "$ob_autostart"
    openbox --reconfigure

    # urxvt color palet
    # sed -i -e "s/$xresources_color_light/$xresources_color_dark/g" "$xresources_conf"
    # xrdb -merge $HOME/.Xresources
    # kill -1 $(pidof urxvt)

    # kitty
    # kitty @ set-colors -a $HOME/.config/kitty/light.conf

    # qt5ct
    sed -i -e "s/icon_theme=$PREF_DARK_ICO/icon_theme=$PREF_LIGHT_ICO/g" "$qt_conf"

    # wall
    hsetroot -fill $PREF_LIGHT_BG
fi
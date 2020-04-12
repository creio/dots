#!/bin/bash

openbox_autostart="$HOME/.config/openbox/autostart"
ob_rc_xml="$HOME/.config/openbox/rc.xml"
xsettingsd_conf="$HOME/.xsettingsd"
qt_conf="$HOME/.config/qt5ct/qt5ct.conf"
sublime_conf="$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"


# preferences for light theme mode
PREF_LIGHT_THEME="lui"
PREF_LIGHT_BG="$HOME/.wall/Crowl.png"
PREF_LIGHT_ICO="lui-ico"

sublime_theme_light="gruvbox"
sublime_colorscheme_light="Packages\\/User\\/Boxy Yesterday.tmTheme"

# preferences for dark theme mode
PREF_DARK_THEME="dui"
PREF_DARK_BG="$HOME/.wall/lcrow.png"
PREF_DARK_ICO="dui-ico"

sublime_theme_dark="gruvbox"
sublime_colorscheme_dark="Packages\\/One Dark Color Scheme\\/One Dark.tmTheme"


# wall
hsetroot_autostart_light="hsetroot -fill ~\\/.wall\\/Crowl.png"
hsetroot_autostart_dark="hsetroot -fill ~\\/.wall\\/lcrow.png"


# Xresources color theme ~/.colors
xresources_conf="$HOME/.Xresources"

xresources_color_light="colors\\/lui"
xresources_color_dark="colors\\/dui"


ob_theme="$(awk -F "[<,>]" '/<theme/ {getline; print $3}' "$ob_rc_xml")"


if [[ "$ob_theme" == "$PREF_LIGHT_THEME" ]]; then
    hsetroot -fill $PREF_DARK_BG
    sed -i -e "s/$hsetroot_autostart_light/$hsetroot_autostart_dark/g" "$openbox_autostart"
    sed -i -e "s/$PREF_LIGHT_THEME/$PREF_DARK_THEME/g" "$ob_rc_xml"
    openbox --reconfigure

    sed -i -e "s/$PREF_LIGHT_THEME/$PREF_DARK_THEME/g" "$xsettingsd_conf"
    sed -i -e 's/IconThemeName "$PREF_LIGHT_ICO"/IconThemeName "$PREF_DARK_ICO"/g' "$xsettingsd_conf"
    xsettingsd &

    sed -i -e "s/$sublime_colorscheme_light/$sublime_colorscheme_dark/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_light.sublime-theme/$sublime_theme_dark.sublime-theme/g" "$sublime_conf"

    sed -i -e "s/$xresources_color_light/$xresources_color_dark/g" "$xresources_conf"
    xrdb -merge $HOME/.Xresources
    kill -1 $(pidof urxvtd)

    sed -i -e "s/icon_theme='$PREF_LIGHT_ICO'/icon_theme='$PREF_DARK_ICO'/g" "$qt_conf"

else
    hsetroot -fill $PREF_LIGHT_BG
    sed -i -e "s/$hsetroot_autostart_dark/$hsetroot_autostart_light/g" "$openbox_autostart"
    sed -i -e "s/$PREF_DARK_THEME/$PREF_LIGHT_THEME/g" "$ob_rc_xml"
    openbox --reconfigure

    sed -i -e "s/$PREF_DARK_THEME/$PREF_LIGHT_THEME/g" "$xsettingsd_conf"
    sed -i -e 's/IconThemeName "$PREF_DARK_ICO"/IconThemeName "$PREF_LIGHT_ICO"/g' "$xsettingsd_conf"
    xsettingsd &

    sed -i -e "s/$sublime_colorscheme_dark/$sublime_colorscheme_light/g" "$sublime_conf"
    sed -i -e "s/$sublime_theme_dark.sublime-theme/$sublime_theme_light.sublime-theme/g" "$sublime_conf"

    sed -i -e "s/$xresources_color_dark/$xresources_color_light/g" "$xresources_conf"
    xrdb -merge $HOME/.Xresources
    kill -1 $(pidof urxvtd)

    sed -i -e "s/icon_theme='$PREF_DARK_ICO'/icon_theme='$PREF_LIGHT_ICO'/g" "$qt_conf"
fi

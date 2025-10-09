#!/usr/bin/env bash
if [[ -z $2 ]]; then
    echo " "
    echo 'usage: colorize.sh "bg color" "fg color"'
    echo " "
    echo 'example: colorize.sh "112233" "efefef"'
    echo 'or :'
    echo 'example: colorize.sh "#16191f" "#9baec8" "#9baec8"'
    echo " "
    exit 1
fi

xrgc() {
case $1 in 
    fg)
        xrdb -query | egrep -m1 "^\*\.?foreground:" | awk '{print $NF}' 
    ;;
    bg)
        xrdb -query | egrep -m1 "^\*\.?background:" | awk '{print $NF}' 
    ;;
    *) 
        xrdb -query | egrep -m1 "^\*\.?color$1:" | awk '{print $NF}'
    ;;
esac
}

pushd $(dirname $(readlink -f $0))/../openbox-3/
cp themerc themerc.bak
cat > themerc <<EOF
# Section: menu
menu.border.width:                      15
menu.border.color:                      $2
menu.separator.color:                   $2
menu.*.bg:                              flat
menu.*.bg.color:                        $2
menu.*.text.color:                      $1
menu.*.text.justify:                    center 
menu.*.disabled.text.color:             $2
menu.*.active.text.color:               $2
menu.*.active.bg.color:                 $1

# Section: osd
osd.border.width:                       0
osd.border.color:                       $2
osd.bg:                                 flat
osd.bg.color:                           $2
osd.label.bg:                           flat solid
osd.label.bg.color:                     $2
osd.label.text.color:                   $1
osd.highlight.bg:                       flat solid
osd.highlight.bg.color:                 $2
osd.unhighlight.bg:                     flat
osd.unhighlight.bg.color:               $2
osd.button.unpressed.bg:                flat
osd.button.unpressed.bg.color:          $2
osd.button.unpressed.*.border.color:    $2
osd.button.pressed.bg:                  flat
osd.button.pressed.bg.color:            $2
osd.button.pressed.*.border.color:      $2
osd.button.focused.bg:                  flat  
osd.button.focused.bg.color:            $2
osd.button.focused.*.border.color:      $2
osd.button.focused.box.color:           $2

# Section: window
window.*.bg:                            flat parentrelative
window.*.*.bg:                          flat parentrelative
window.*.*.*.bg:                        flat parentrelative
window.*.text.justify:                  left
window.active.button.*.*.image.color:   $1
window.active.label.text.color:         $1
window.active.title.bg.color:           $3
window.active.title.separator.color:    $3
window.active.border.color:             $3
window.inactive.button.*.*.image.color: $1
window.inactive.label.text.color:       $3
window.inactive.title.bg.color:         $(xrgc 8)
window.inactive.title.separator.color:  $(xrgc 8)
window.inactive.border.color:           $3

window.*.button.*.image.color:           $1
window.*.label.text.color:               $1
window.*.title.bg.color:                 $2
window.*.title.separator.color:          $2
window.*.border.color:                   $2
window.*.handle.bg.color:                $2

# Section: fonts
window.active.label.text.font:          shadow=n
window.inactive.label.text.font:        shadow=n
menu.items.font:                        shadow=n
menu.title.text.font:                   shadow=n

# Section: misc
border.width:                           0
padding.width:                          10
padding.height:                         7
window.client.padding.height:           0
window.client.padding.width:            0
window.label.text.justify:              left
EOF

popd
openbox --reconfigure
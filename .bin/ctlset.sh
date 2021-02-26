#!/bin/bash
# https://github.com/cjungmann/yaddemo

if [[ $(command -v yad) && $(command -v haveged) ]]; then
  echo "OK: yad, haveged"
else
  echo "ERROR: pacman -S yad haveged" && exit
fi

if [[ $EUID -ne 0 ]]; then
  echo "run root" && exit
fi

pacman_key() {
haveged -w 1024
pacman-key --init
pacman-key --populate
pacman-key --refresh-keys --keyserver hkp://keys.gnupg.net
pkill haveged
}

pacman_mir() {
reflector --verbose -p https,http -l 30 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy --noconfirm
}

system_up() {
pacman -Syyuu --noconfirm
}

export -f pacman_key
export -f pacman_mir
export -f system_up

menu=(
"Обновить ключи Pacman|bash -c pacman_key"
"Обновление зеркал pacman|bash -c pacman_mir"
"Обновление системы|bash -c system_up"
)

yad_opts=(
--center --width=350 --borders=15 --form
--title="Ctlos Settings"
--text="<span font='12'>Выберите действие</span>\n"
--window-icon="gtk-execute"
--image="dialog-question"
--text-info
--buttons-layout=center
--button="Close":1 --button="Ok":2
)

for m in "${menu[@]}"
do
  yad_opts+=( --field="${m%|*}:CHK" )
done

IFS='|' read -ra ans < <( yad "${yad_opts[@]}" )

for i in "${!ans[@]}"; do
  if [[ ${ans[$i]} == TRUE ]]; then
    m=${menu[$i]}
    name=${m%|*}
    cmd=${m#*|}
    echo "Selected: $name ($cmd)"
    $cmd
  fi
done

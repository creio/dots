#!/usr/bin/env bash
# Download random images from wallhaven.cc
# By mhess

FOLDER=/tmp/wallhaven
WALL=/tmp/list.txt

[ -d ${FOLDER} ] && rm ${FOLDER}/* || mkdir -p ${FOLDER}
[ -e ${WALL} ] && rm ${WALL}

down() {
for num in {1..2}; do
    curl -s "https://wallhaven.cc/search?q=&resolutions=1920x1080&sorting=random&page=$num" --compressed |
    grep -o -E 'https://wallhaven.cc/w/([0-9 & A-Z & a-z]+)' |
    cut -f2 -d '-' >> ${WALL}
done

for list in $(cat /tmp/list.txt); do

  wget --quiet -O ${FOLDER}/${list}.jpg "https://w.wallhaven.cc/full/wallhaven-${list}.jpg"
  FILE="${FOLDER}/${list}"

  if [ $(du -h ${FILE}.jpg | cut -f1) = "0" ]; then
  rm ${FILE}.jpg
  wget --quiet -O ${FOLDER}/${list}.png "https://w.wallhaven.cc/full/wallhaven-${list}.png"
  fi
done
}
down &>/dev/null &

pid=$!
spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"

echo -n "Downloading wallpapers... ${spin[0]}"
while kill -0 $pid &>/dev/null
do
  for i in "${spin[@]}"
  do
        echo -ne "\b$i"
        sleep 0.1
  done
done

printf "\nFinished! All wallpapers has been saved on ${FOLDER}\n"

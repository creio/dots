#!/bin/bash
## yay -S curl jq xclip

[[ -s ~/.env ]] && . ~/.env

kutt_key="$KUTT_API_KEY"
target_url=$1
short_name=$2
short_pass=$3
short_expire=$4
short_desc=$5

generate_data()
{
  cat <<LOL
{
  "target": "${target_url}",
  "customurl": "${short_name}",
  "password": "${short_pass}",
  "expire_in": "${short_expire}",
  "description": "${short_desc}",
  "reuse": true,
  "domain": "kutt.it"
}
LOL
}

if [[ -n "$target_url" && "$1" != "-l" && "$1" != "-d" ]]; then
  result="$(curl -s -H "X-API-KEY:$kutt_key" --data "$(generate_data)" -H "Content-Type: application/json" -X POST https://kutt.it/api/v2/links)"
  echo $result | jq -r "." | tr -d '{}'
  echo $result | jq -r ".link"| xclip -selection c
elif [[ "$1" == "-l" ]]; then
  echo -e "\nlist shorts"
  curl -s -H "X-API-KEY:$kutt_key" https://kutt.it/api/v2/links | jq -r ".data[] | .id,.link,.target"
elif [[ "$1" == "-d" && -n "$2" ]]; then
  curl -s -H "X-API-KEY:$kutt_key" -X DELETE "https://kutt.it/api/v2/links/$2" | jq -r ".[]"
elif [[ "$1" == "-d" ]]; then
  echo -e "list id: $ kutt.sh -l\n$ kutt.sh -d id"
else
  echo "random short"
  echo "$ kutt.sh https://target_url"
  echo -e "\ncustom short"
  echo "$ kutt.sh https://target_url short_name password \"2 minutes/hours/days\" description"
  echo -e "\nlist shorts"
  echo "$ kutt.sh -l"
  echo -e "\ndelete short"
  echo "$ kutt.sh -d id-id-id"
fi

#!/bin/sh

# init variables
version="v2020.07.05"
ENDPOINT="https://ttm.sh"
flag_options=":hvcufs::"
flag_version=0
flag_help=0
flag_file=0
flag_url=0
flag_colors=0
data=""

# help message available via func
show_help() {
  cat > /dev/stdout << END
pb [options] filename
or
(command-with-stdout) | pb

Uploads a file or data to the tilde 0x0 paste bin

OPTIONAL FLAGS:
  -h                        Show this help
  -v                        Show current version number
  -f                        Explicitly interpret stdin as filename
  -c                        Pretty color output
  -u                        Shorten URL
  -s server_address         Use alternative pastebin server address
END
}

show_usage() {
  cat > /dev/stdout << END
usage: pb [-hfvcux] [-s server_address] filename
END
}

# helper for program exit, supports error codes and messages
die () {
  msg="$1"
  code="$2"
  # exit code defaults to 1
  if printf "%s" "${code}" | grep -q '^[0-9]+$'; then
    code=1
  fi
  # output message to stdout or stderr based on code
  if [ -n "${msg}" ]; then
    if [ "${code}" -eq 0 ]; then
      printf "%s\\n" "${msg}"
    else
      printf "%s%s%s\\n" "$ERROR" "${msg}" "$RESET" >&2
    fi
  fi
  exit "${code}"
}

# is not interactive shell, use stdin
if [ -t 0 ]; then
  flag_file=1
else
  data="$(cat < /dev/stdin )"
fi

# attempt to parse options or die
if ! parsed=$(getopt ${flag_options} "$@"); then
  printf "pb: unknown option\\n"
  show_usage
  exit 2
fi

# handle options
eval set -- "${parsed}"
while true; do
  case "$1" in
    -h|?)
      flag_help=1
      ;;
    -v)
      flag_version=1
      ;;
    -c)
      flag_colors=1
      ;;
    -f)
      flag_file=1
      ;;
    -s)
      shift
      ENDPOINT="$1"
      ;;
    -u)
      flag_url=1
      ;;
    --)
      shift
      break
      ;;
    *)
      die "Internal error: $1" 3
      ;;
  esac
  shift
done

# if data variable is empty (not a pipe) use params as fallback
if [ -z "$data" ]; then
  data="$*"
fi

# display current version
if [ ${flag_version} -gt 0 ]; then
  printf "%s\\n" "${version}"
  die "" 0
fi

# display help
if [ ${flag_help} -gt 0 ]; then
  show_help
  die "" 0
fi

# Colors
if [ ${flag_colors} -gt 0 ]; then
  SUCCESS=$(tput setaf 190)
  ERROR=$(tput setaf 196)
  RESET=$(tput sgr0)
else
  SUCCESS=""
  ERROR=""
  RESET=""
fi

# URL shortening reference

# If URL mode detected, process URL shortener and end processing without
# checking for a file to upload to the pastebin
if [ ${flag_url} -gt 0 ]; then

  if [ -z "${data}" ]; then
    # if no data
    # print error message
    printf "%sProvide URL to shorten%s\\n" "$ERROR" "$RESET"
  else
    # shorten URL and print results
    result=$(curl -sF"shorten=${data}" "${ENDPOINT}")
    printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
  fi
  die "" 0
fi

if [ ${flag_file} -gt 0 ]; then
  # file mode
  if [ -z "${data}" ]; then
    # if no data
    # print error message
    printf "%sProvide data to upload%s\\n" "$ERROR" "$RESET"
  elif [ ! -f "${data}" ]; then
    # file not found with name provided
    # print error messagse
    printf "%s%s%s\\tFile not found.%s\\n" "$RESET" "${data}" "$ERROR" "$RESET"
    # attempt to split data string (multi-line?) and upload each string as file
    for f in ${data}; do
      # if there's nothing to parse, skip this loop
      if [ "$f" = "$data" ]; then
        break;
      fi
      # check if file exists
      if [ -f "${f}" ]; then
        # send file to endpoint
        result=$(curl -sF"file=@${f}" "${ENDPOINT}")
        printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
      else
        # print error message
        printf "%sFile not found.%s\\n" "$ERROR" "$RESET"
      fi
    done
  else
    # data available in file
    # send file to endpoint
    result=$(curl -sF"file=@${data}" "${ENDPOINT}")
    printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
  fi
else
  # non-file mode
  if [ -z "${data}" ]; then
    # if no data
    # print error message
    printf "%sNo data found for upload. Please try again.%s\\n" "$ERROR" "$RESET"
  else
    # data available
    # send data to endpoint, print short url
    result=$(printf "%s" "${data}" | curl -sF"file=@-;filename=null.txt" "${ENDPOINT}")
    printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
  fi
fi

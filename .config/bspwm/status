#!/bin/sh

set -e

daemon=${1:?}
state="%{F#9baec8}off%{F-}"
cmd="$(systemctl status $daemon | grep -i run 2>/dev/null || echo '')"

[[ "$cmd" ]] && state="%{F#8485CE}on%{F-}"

echo "%{F#8485CE}${daemon}%{F-} ${state}"
exit 0

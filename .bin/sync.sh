#!/usr/bin/bash

## Install rclone, inotify-tools
## Run: rclone config
## chown +x sync.sh
## sudo loginctl enable-linger $USER
## Run: sync.sh systemd_setup

RCLONE_SYNC_PATH="/home/creio/clouds/globalsync"
RCLONE_CLOUD="google"
RCLONE_REMOTE="$RCLONE_CLOUD:/globalsync"

# RCLONE_CMD: The sync command and arguments:
RCLONE_CMD="rclone -v sync ${RCLONE_SYNC_PATH} ${RCLONE_REMOTE}"
# WATCH_EVENTS: The file events that inotifywait should watch for:
WATCH_EVENTS="modify,delete,create,move"
# SYNC_DELAY: Wait this many seconds after an event, before synchronizing:
SYNC_DELAY=5
# SYNC_INTERVAL: Wait this many seconds between forced synchronizations:
SYNC_INTERVAL=3600
# NOTIFY_ENABLE: Enable Desktop notifications
NOTIFY_ENABLE=true
# SYNC_SCRIPT: dynamic reference to the current script path
SYNC_SCRIPT=$(realpath $0)

notify() {
	MESSAGE=$1
	if test ${NOTIFY_ENABLE} = "true"; then
		notify-send "rclone ${RCLONE_REMOTE}" "${MESSAGE}"
	fi
}

rclone_sync() {
set -x
notify "Startup"
${RCLONE_CMD}
while [[ true ]]; do
	inotifywait --recursive --timeout ${SYNC_INTERVAL} -e ${WATCH_EVENTS} \
	${RCLONE_SYNC_PATH} 2>/dev/null
	if [[ $? -eq 0 ]]; then
		sleep ${SYNC_DELAY} && ${RCLONE_CMD} && \
		notify "Synchronized new file changes"
	elif [[ $? -eq 1 ]]; then
		notify "inotifywait error exit code 1"
		sleep 10
	elif [[ $? -eq 2 ]]; then
		${RCLONE_CMD}
	fi
done
}

systemd_setup() {
set -x
if loginctl show-user ${USER} | grep "Linger=no"; then
	echo "User account does not allow systemd Linger."
	echo "To enable lingering, run as root: loginctl enable-linger $USER"
	echo "Then try running this command again."
	exit 1
fi
mkdir -p ${HOME}/.config/systemd/user
SERVICE_FILE=${HOME}/.config/systemd/user/rclone_sync.${RCLONE_CLOUD}.service
if test -f ${SERVICE_FILE}; then
	echo "Unit file already exists: ${SERVICE_FILE} - Not overwriting."
else
cat <<EOF > ${SERVICE_FILE}
[Unit]
Description=rclone_sync ${RCLONE_REMOTE}

[Service]
ExecStart=${SYNC_SCRIPT}

[Install]
WantedBy=default.target
EOF
fi
systemctl --user daemon-reload
systemctl --user enable --now rclone_sync.${RCLONE_CLOUD}
systemctl --user status rclone_sync.${RCLONE_CLOUD}
echo "You can watch the logs with this command:"
echo "journalctl --user --unit rclone_sync.${RCLONE_CLOUD}"
}

if test $# = 0; then
	rclone_sync
else
	CMD=$1; shift;
	${CMD} $@
fi

#!/bin/sh

# export BORG_REPO=ssh://username@example.com:2022/~/backup/main
# export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'
# export BORG_RSH='ssh -i ~/.ssh/id_rsa'
[ -s /home/creio/.env_borg ] && . /home/creio/.env_borg

cmd_list="$(borg list 2>/dev/null)"

if [ "$cmd_list" ]; then
  echo "yes repo"
elif [ "$1" = "-n" ]; then
  echo "init repo none encryp"
  borg init --info -e none
else
  echo "init repo"
  borg init --info -e repokey-blake2
fi

# echo $BORG_PASSPHRASE
# exit

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

borg create --verbose --filter AME --list --stats --show-rc --compression lz4 --exclude-caches \
    --exclude '/dev/*' \
    --exclude '/proc/*' \
    --exclude '/sys/*' \
    --exclude '/tmp/*' \
    --exclude '/run/*' \
    --exclude '/mnt/*' \
    --exclude '/media/*' \
    --exclude '/var/lib/aurbuild' \
    --exclude '/var/lib/docker' \
    --exclude '/var/lib/pacman/sync/*' \
    --exclude '/var/cache/*' \
    --exclude '/var/tmp/*' \
    --exclude '/snapshots' \
    --exclude '/root.x86_64' \
    --exclude '/root/.cache' \
    --exclude '/lost+found' \
    --exclude '/**/lost+found' \
    --exclude '/home/*/.chroot' \
    --exclude '/home/*/.config/nvm' \
    --exclude '/home/*/.config/duc' \
    --exclude '/home/*/.thumbnails/*' \
    --exclude '/home/*/.cache/*' \
    --exclude '/home/*/.local/share/Trash/*' \
    --exclude '/home/*/.gvfs/*' \
    --exclude '/home/*/.build/*' \
    --exclude '/home/*/.duc.db/*' \
    --exclude '/home/*/.qvirt/*' \
    --exclude '/home/*/.vbox/*' \
    --exclude '/home/*/clouds' \
    --exclude '/home/*/ctlosiso' \
                                    \
    ::'{hostname}-{now}'            \
    /                               \

backup_exit=$?

info "Pruning repository"

borg prune --list --show-rc \
    --prefix '{hostname}-' \
    --keep-daily 7 --keep-weekly 4 --keep-monthly 1 \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi

exit ${global_exit}

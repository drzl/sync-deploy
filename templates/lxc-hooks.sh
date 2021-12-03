#! /bin/bash

#exit

#echo "=============================" >> /tmp/lxhooks.log
#echo "$(date) $@" >> /tmp/lxhooks.log
#echo "type=$3" >> /tmp/lxhooks.log
#echo "name=$LXC_NAME" >> /tmp/lxhooks.log
#set >> /tmp/lxhooks.log

NAME="$1"
TYPE="$3"

#if [[ "$TYPE" == 'start-host' ]]; then
#    lxc-ls -f -F IPV4,NAME -1 > /run/lxc/running-hosts
#fi

EXPORT='/mnt/export'

if ! [[ -d "$EXPORT" ]]; then
    exit
fi

if [[ "$TYPE" == 'pre-start' ]]; then
    if ! [[ -d "$EXPORT/$NAME" ]]; then
        mkdir "$EXPORT/$NAME"
    fi
    if mountpoint -q "$EXPORT/$NAME/run"; then
        umount "$EXPORT/$NAME/run"
        rmdir "$EXPORT/$NAME/run"
    fi
    mkdir "$EXPORT/$NAME/run"
    mount -t tmpfs runfs "$EXPORT/$NAME/run"
    exit
fi

if [[ "$TYPE" == 'mount' ]]; then
    if mountpoint -q "$EXPORT/$NAME/run"; then
        mount --bind "$EXPORT/$NAME/run" "$LXC_ROOTFS_MOUNT"/run
    fi
    exit
fi

if [[ "$TYPE" == 'start-host' ]]; then
    if ! [[ -d "$EXPORT/$NAME" ]]; then
        #echo "no dir $EXPORT/$NAME" >> /tmp/lxhooks-err.log
        exit
    fi

    local mode='none'
    if [[ -f "$LXC_ROOTFS_PATH" ]]; then
        mode='file'
    elif [[ -d "$LXC_ROOTFS_PATH" ]]; then
        mode='dir'
    fi
    if [[ "$mode" == 'none' ]]; then
        exit
    fi

    if mountpoint -q "$EXPORT/$NAME/root"; then
        umount "$EXPORT/$NAME/root"
        rmdir "$EXPORT/$NAME/root"
    fi
    mkdir "$EXPORT/$NAME/root"

    if [[ "$mode" == 'file' ]]; then
        mount -o loop "$LXC_ROOTFS_PATH" "$EXPORT/$NAME/root" #2>&1 | cat >> /tmp/lxhooks.log
    else
        mount --bind "$LXC_ROOTFS_PATH" "$EXPORT/$NAME/root" #2>&1 | cat >> /tmp/lxhooks.log
    fi
    exit
fi

if [[ "$TYPE" == 'post-stop' ]]; then
    if mountpoint -q "$EXPORT/$NAME/run"; then
        umount "$EXPORT/$NAME/run" || true
        rmdir "$EXPORT/$NAME/run" || true
    fi
    if mountpoint -q "$EXPORT/$NAME/root"; then
        umount "$EXPORT/$NAME/root" || true
        rmdir "$EXPORT/$NAME/root" || true
    fi
    if [[ -d "$EXPORT/$NAME" ]]; then
        rmdir "$EXPORT/$NAME" || true
    fi
    exit
fi

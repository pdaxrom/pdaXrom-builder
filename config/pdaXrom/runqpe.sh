#!/bin/sh

export HOME=/home/root
export QTDIR=/opt/Qtopia
export QTEDIR=/opt/Qtopia
export QPEDIR=/opt/Qtopia

export PATH=$QTDIR/bin:$PATH
export LD_LIBRARY_PATH=$QTDIR/lib

export QWS_DISPLAY="Transformed:Rot270:0"

echo "0 0 0 0" >/proc/sys/kernel/printk

trap 'exec /sbin/getty 9600 tty1 ; exit 0' SIGUSR1
trap 'exec qpe 2>/dev/null >/dev/null ; exit 0' SIGUSR2


MYPID=`ps x | grep '/bin/bash /opt/Qtopia/runqpe.sh' | grep -v 'grep' | sed 's/^ *//' | tr '\n' ' ' | cut -d ' ' -f 1`
#echo "PPID=[$MYPID]"

echo

for cnt in 5 4 3 2 1 ; do
    printf  "Press OK for login ... $cnt\r"
    old_tty_settings=`stty -g`
    stty -icanon min 0 time 10
    read -s -t 1 SYSY
    if [ "$?" = "0" ]; then
	stty "$old_tty_settings"
	kill -s USR1 $MYPID
    fi
    stty "$old_tty_settings"
done

clear
kill -s USR2 $MYPID

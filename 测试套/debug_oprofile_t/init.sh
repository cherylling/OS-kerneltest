
##
echo "RUNNING INIT.SH, hahaha"
export OPROFILE_EVENTS_DIR=/usr/share/oprofile/

if [ $TARGET_PROMPT="MCCA" ];then
    mkdir /tmp/root
    cp -r /root/.ssh  /tmp/root/
    mount /tmp/root/ /root -o loop

    mount -t debugfs nodev /sys/kernel/debug/
    echo 1 > /sys/kernel/debug/tracing/tracing_on
    umount /sys/kernel/debug/
fi

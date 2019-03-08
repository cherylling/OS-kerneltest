#!/bin/sh
set -e
cp expectconf.in expectconf
sed -i "s/IP_ADDR/${TARGET_IP}/" expectconf
install_dir="`grep "TARGET_INSTALL_DIR" hostconf | sed "s/'//g" | head -n 1`"
install_dir=${install_dir#*=}
install_dir=`echo $install_dir | sed "s/\//\\\\\\\\\//g"`
sed -i "s/INSTALL_DIR/${install_dir}/" expectconf
target_user="`grep "TARGET_USER" hostconf | sed "s/'//g" | head -n 1`"
target_user=${target_user#*=}
target_user=`echo $target_user | sed "s/\//\\\\\\\\\//g"`
sed -i "s/TARGET_USER/${target_user}/" expectconf
set +e
exit 0

#!/bin/sh

RET=0

for klp_ko in `ls klp*.ko`
do
###insmod
        insmod $klp_ko
        if [ $? -ne 0 ]; then
                echo "`dmesg | tail -n 1`" 
                RET=$(($RET+1))
        fi
###enable
        name=`echo $klp_ko | awk -F'.' '{print $1}'`
        klp_ko_name=`echo ${name//-/_}`

        echo 1 > /sys/kernel/livepatch/$klp_ko_name/enabled
	if [ $? -ne 0 ]; then
		echo "enable klp failed"
		RET=$(($RET+1))
	fi

###test
	date -s 00:00:00
	dmesg |grep "livepatch CI testcase for add funca test"
	if [ $? -eq 0 ];then
                echo "test01 pass"
        else
		echo "test01 fail"
		RET=$(($RET+1))
        fi

	dmesg |grep "livepatch CI testcase for modifing the var"
        if [ $? -eq 0 ];then
                echo "test02 pass"
        else
		echo "test02 fail"
                RET=$(($RET+1))
        fi

###disable
        echo 0 > /sys/kernel/livepatch/$klp_ko_name/enabled

        dmesg | tail -n 10 | grep "enabling patch '$klp_ko_name'" && \
        dmesg | tail -n 10 | grep "disabling patch '$klp_ko_name'"
        if [ $? -ne 0 ];then
		RET=$(($RET+1))
        fi

###rmmod
        rmmod $klp_ko
done

exit $RET

#!/bin/bash

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

insmod arm64_register_nmi_handler.ko cpu_status=-1
if [ $? -eq 0 ];then
	echo "Failed:set cpu_status=-1 success which is unexpected."
	nmi_cleanup
	exit 1
fi

insmod arm64_register_nmi_handler.ko cpu_status=3
if [ $? -eq 0 ];then
	echo "Failed:set cpu_status=3 success which is unexpected."
	nmi_cleanup
	exit 1
fi

exit 0

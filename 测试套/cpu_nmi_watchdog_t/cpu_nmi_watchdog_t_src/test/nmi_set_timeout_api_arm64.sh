#!/bin/bash

nmi_cleanup()
{
	rmmod arm64_register_nmi_handler.ko
}

insmod arm64_register_nmi_handler.ko time_out=-1
if [ $? -eq 0 ];then
	echo "Failed:set cpu timeout=-1 success which is unexpected."
	nmi_cleanup
	exit 1
fi

insmod arm64_register_nmi_handler.ko time_out=0
if [ $? -eq 0 ];then
	echo "Failed:set cpu timeout=0 success which is unexpected."
	nmi_cleanup
	exit 1
fi

insmod arm64_register_nmi_handler.ko time_out=65535
if [ $? -eq 0 ];then
        echo "Failed:set cpu timeout=65535 success which is unexpected."
        nmi_cleanup
        exit 1
fi

insmod arm64_register_nmi_handler.ko time_out=65536
if [ $? -eq 0 ];then
        echo "Failed:set cpu timeout=65536 success which is unexpected."
        nmi_cleanup
        exit 1
fi

exit 0

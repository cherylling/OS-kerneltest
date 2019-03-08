#!/bin/bash

. ../conf/suite_api.sh
oprofile_ko_check
if [ $? -ne 0 ];then
	exit 1
fi
rtos_msg_color 32 "opcontrol --init pass"

opcontrol --session-dir=/var/lib/oprofile
if [ $? -ne 0 ];then
	rtos_msg_color 31 "oparchive --session-dir=/var/lib/oprofile fail"
	exit 1
fi

opcontrol -s
if [ $? -ne 0 ];then
	rtos_msg_color 31 "opcontrol -s start data collection fail"
	opcontrol -h
	exit 1
fi

opcontrol --dump
if [ $? -ne 0 ];then
	rtos_msg_color 31 "opcontrol --dump fail"
	opcontrol -h
	exit 1
fi
rtos_msg_color 32 "opcontrol --dump pass"

opjitconv -d /var/lib/oprofile 0 10
if [ $? -ne 0 ];then
	rtos_msg_color 31 "opjitconv -d /var/lib/oprofile 0 10 fail"
	opcontrol -h
	exit 1
fi
rtos_msg_color 32 "opjitconv -d /var/lib/oprofile 0 10 -f pass"
opcontrol -h




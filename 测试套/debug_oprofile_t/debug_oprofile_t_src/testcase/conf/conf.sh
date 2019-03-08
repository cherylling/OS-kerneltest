#!/bin/bash
#======================================================
# Author: dingzengjian - d00228505
# 
# Last modified: 2013-03-25 11:00
# 
# Filename: conf.sh
# 
# Description:  
# 
#======================================================
RET=""
VERSION=""
EVENT_SUPPORT=""
DEFAULT_EVENT=""

# for color promt
# usage: msg pass|fail|info message
msg(){
	case $1 in
		fail)
			echo -e "\033[1;31m[FALL] $2\033[0m"
			;;
		pass)
			echo -e "\033[1;32m[PASS] $2\033[0m"
			;;
		info)
			echo -e "\033[1;35m[INFO] $2\033[0m"
			;;
		*)
			echo "$*"
			;;
	esac
}

# get default event
# according to the value of  $EVENT_SUPPORT to set $DEFAULT_EVENT
get_default_event(){
	opcontrol -l | grep -i "oprofile: available events"
	if [ $? -eq 0 ];then
		# support = 0
		EVENT_SUPPORT=0
	else	
		# not support = 1
		EVENT_SUPPORT=1
	fi

	# if support get default event
	if [ $EVENT_SUPPORT -eq 0 ];then
		ophelp -d
		if [ $? -eq 0 ];then
			DEFAULT_EVENT=`ophelp -d | awk -F':' '{print $1}'`
		else
			# CPU_CYCLES for hert/sd5130/hi1210/hi1212
			DEFAULT_EVENT="CPU_CYCLES"
			# CPU_CLK  for P2041/P1010
			DEFAULT_EVENT="CPU_CLK"
			# other?

		fi

	fi

	return $EVENT_SUPPORT
}

# For compatibility of "opcontrol --session-dir" before version 0.9.7
# 
set_session_dir(){
	opcontrol --setup --no-vmlinux --session-dir=$* 
}

# for environment setting
# NOTICE: must initialize RET before setenv called!!
#
setenv(){
	msg info "setenv..."
	# clean last time environment
	opcontrol --stop
	opcontrol --shutdown
	opcontrol --deinit
	if [ $? -ne 0 ];then
		# device busy? kill the process
		msg fail "device busy? do something here to kill the process"
	fi

	opcontrol --init
	if [ $? -ne 0 ];then
		RET=$(($RET+1))
		return $RET
	fi

	if [ ! -d /dev/oprofile ];then
		msg fail "cannot find /dev/oprofile dir after opcontrol --init"
		RET=$(($RET+1))
		return $RET
	else
		OPFILE=`ls /dev/oprofile`
		if [ -z "$OPFILE" ];then
			msg fail  "There's no files in $OPFILE after opcontrol --init"
			RET=$(($RET+1))
			return $RET
		fi
	fi

	# get current version
	VERSION=`opcontrol -v | awk '{print $3}'|awk -F'.' '{print $1$2$3}'`

	set_session_dir /tmp/lo
	if [ $? -ne 0 ];then
		msg fail "opcontrol --session-dir=/tmp/lo fail"
		RET=$(($RET+1))
		return $RET
	fi

	return $RET
}

# for cleaning environment
# 
do_clean(){
	msg info "do_clean..."
	opcontrol --stop
	opcontrol --shutdown
	opcontrol --deinit
}

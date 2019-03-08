#!/bin/bash

. conf.sh

KO=testRegKprobe_010.ko
grep_dmesg="register_kprobe pass"
echo_mesg="register_kprobe failed!"
grep_dmesg1="pre_handler"
echo_mesg1="Active kprobe failed!"
echo_mesg2_1="Disable kprobe succeed!"
echo_mesg2_2="Disable kprobe failed!"

#kp.flags = 0 || KPROBE_FLAG_GONE || KPROBE_FLAG_DISABLED || KPROBE_FLAG_OPTIMIZED || KPROBE_FLAG_FTRACE;
#test 0 :kp.flags = 0
set_up
insmod_success "$KO kp_flag=0" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

#test 1: KPROBE_FLAG_GONE 1     : breakpoint has already gone
set_up
insmod_success "$KO kp_flag=1" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

#test 2: KPROBE_FLAG_DISABLED 2 : probe is temporarily disabled
set_up
insmod_success "$KO kp_flag=2" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg2_1" ; then
	echo $echo_mesg2_2
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

#test 3: KPROBE_FLAG_OPTIMIZED 4
set_up
insmod_success "$KO kp_flag=4" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

#test 4: KPROBE_FLAG_FTRACE 8   : probe is using ftrace 
set_up
insmod_success "$KO kp_flag=8" || exit 1

if ! grep_mesg "$KO" "$grep_dmesg" "$echo_mesg" ; then
        clean_up $KO
        exit 1
fi

ls > /dev/null
if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0

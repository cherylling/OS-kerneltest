#!/bin/bash
###########################################################################
#    Notice:Offset is signed parameters,such as -4(negative ),resulting   #
# in inserting module is not successful,but in the case,armA15/armA9 will #
# be a strong negative  conversion into infinite integers, the actual     # 
# insertion case success. All expectations are wrong.                     #               
###########################################################################

. conf.sh

TEST_KO=testRegKprobe_008.ko

grep_dmesg="register_kprobe failed"

set_up

#skip the test in arch32 and ppc
arch64=`uname -m | grep -E 'aarch64|x86_64' | wc -l`
if [ $arch64 -gt 0 ]
then
	insmod_fail "$TEST_KO p_offset=-4" "$grep_dmesg" ||exit 1
fi
exit 0

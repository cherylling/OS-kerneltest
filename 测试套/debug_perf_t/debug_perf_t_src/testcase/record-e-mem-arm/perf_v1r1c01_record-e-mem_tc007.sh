#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-09
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record监控各字节数的-k边界值测试(监控不带符号，即:"u:<-1","U:<-1","<-1")
##- @Detail: 1.构建用户态程序，运行
##-          2.对地址addr分别进行监控r1,r2,r4,w1,w2,w4
##-          3.使用-k u:>xx,u:=xx,u:<xx,（U，无字符)对于1,2,4字节分别进行筛选,其中xx为1字节，2字节，4字节的左右边界
##- @Expect: 边界值的检测，对于溢出值，如256，将被解析为0，判断表达式中溢出，则报错。其他检测与正常只检测相同
##- @Level: Level 3
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e-mem_common.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp_recordemem

    cmd="${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    addr_bound1=`get_monitor_addr ${program} 'u_bound1'`
    addr_bound2=`get_monitor_addr ${program} 'u_bound2'`
    addr_bound4=`get_monitor_addr ${program} 'u_bound4'`

    #the same in common_record-e-mem_1.c
    left1=0
    left2=0
    left4=0
    right1=255
    right2=65535
    right4=0xffffffff
    cd ${TCTMP}
}

######################################################################
##- @Description: 
######################################################################
record_outofrange()
{
    local chk_addr eq_num outofrange filename g_e_l
    #record -k "s:>num" if num is lower than left bound,will get "input out of range"
    for ri in 1 2 4;do
        chk_addr=`eval echo '$'addr_bound${ri}`
        eq_num=${left1}
        outofrange=$((eq_num-1))
        for which_k in gt eq lt;do
            filename=bound${ri}_lt_left_${which_k}-${temp_num}
            g_e_l="`echo $which_k | sed 's/gt/>/' | sed 's/eq/=/g' | sed 's/lt/</g'`"
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r$ri -k "u:${g_e_l}${outofrange}" ${cmd} >u_${filename}.report4 2>/dev/null
            check_ret_code $? 1
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r$ri -k "U:${g_e_l}${outofrange}" ${cmd} >U_${filename}.report4 2>/dev/null
            check_ret_code $? 1
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r$ri -k "${g_e_l}${outofrange}" ${cmd} >${filename}.report4 2>/dev/null
            check_ret_code $? 1
        done
    done

    #record -k "s:>num" if num is bigger than right bound,will get "invalid hwbp_filter:"
    for ri in 1 2 4;do
        chk_addr=`eval echo '$'addr_bound${ri}`
        eq_num=`eval echo '$'right${ri}`
        outofrange=$((eq_num+1))
        for which_k in gt eq lt;do
            filename=bound${ri}_gt_right_${which_k}-${temp_num}
            g_e_l=`echo $which_k | sed 's/gt/>/' | sed 's/eq/=/g' | sed 's/lt/</g'`
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r$ri -k "u:${g_e_l}${outofrange}" ${cmd} >u_${filename}.report2 2>/dev/null
            check_ret_code $? 1
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r$ri -k "U:${g_e_l}${outofrange}" ${cmd} >U_${filename}.report2 2>/dev/null
            check_ret_code $? 1
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r$ri -k "${g_e_l}${outofrange}" ${cmd} >${filename}.report2 2>/dev/null
            check_ret_code $? 1

            if [ $ri -eq 4 ];then
                mv u_${filename}.report2 u_${filename}.report4
                mv U_${filename}.report2 U_${filename}.report4
                mv ${filename}.report2 ${filename}.report4
            fi
        done
    done
}
######################################################################
##- @Description: 
######################################################################
dotest()
{
    #*.report0:report nothing
    #*.report1:do report something
    #*.report2:record error and get "invalid hwbp_filter:"

    #left bound of bound1
    local chk_addr eq_num filename g_l left_right which_bound

    record_outofrange

    #s:>leftbound and s:<rightbound
    for left_right_s in left_sgt right_slt;do
        left_right=${left_right_s%_*}
        which_bound=`echo $left_right_s | sed 's/left_sgt/0/g' | sed 's/right_slt/1/g'`
        g_l=`echo $left_right_s | sed 's/left_sgt/>/g' | sed 's/right_slt/</g'`
        for ri in 1 2 4;do
            chk_addr=`eval echo '$'addr_bound${ri}`
            eq_num=`eval echo '$'"${left_right}${ri}"`
            filename=bound${ri}_${left_right_s}_gt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            #eg:256 is 0xff+1 that is 0; 65536 is 0xffff+1 that is 0
            perf report -i u_${filename}.data > u_${filename}.report1
            perf report -i U_${filename}.data > U_${filename}.report1
            perf report -i ${filename}.data > ${filename}.report1

            filename=bound${ri}_${left_right_s}_eq-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0

            filename=bound${ri}_${left_right_s}_lt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            #eg:-1 is 0xff that is 255; -1 is 0xffff that is 65535
            perf report -i u_${filename}.data > u_${filename}.report1
            perf report -i U_${filename}.data > U_${filename}.report1
            perf report -i ${filename}.data > ${filename}.report1
        done
    done
    #s:=leftbound and s:=rightbound
    for left_right_s in left_seq right_seq;do
        left_right=${left_right_s%_*}
        which_bound=`echo $left_right_s | sed 's/left_seq/0/g' | sed 's/right_seq/1/g'`
        for ri in 1 2 4;do
            chk_addr=`eval echo '$'addr_bound${ri}`
            eq_num=`eval echo '$'"${left_right}${ri}"`
            filename=bound${ri}_${left_right_s}_gt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:=${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:=${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "=${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0

            filename=bound${ri}_${left_right_s}_eq-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:=${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:=${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "=${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report1
            perf report -i U_${filename}.data > U_${filename}.report1
            perf report -i ${filename}.data > ${filename}.report1

            filename=bound${ri}_${left_right_s}_lt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:=${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:=${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "=${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0
        done
    done
    #s:<leftbound and s:>rightbound
    for left_right_s in left_slt right_sgt;do
        left_right=${left_right_s%_*}
        which_bound=`echo $left_right_s | sed 's/left_slt/0/g' | sed 's/right_sgt/1/g'`
        g_l=`echo $left_right_s | sed 's/left_slt/</g' | sed 's/right_sgt/>/g'`
        for ri in 1 2 4;do
            chk_addr=`eval echo '$'addr_bound${ri}`
            eq_num=`eval echo '$'"${left_right}${ri}"`
            filename=bound${ri}_${left_right_s}_gt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} 1 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0

            filename=bound${ri}_${left_right_s}_eq-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} 0 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0

            filename=bound${ri}_${left_right_s}_lt-${temp_num}
            perf record -o u_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "u:${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o U_${filename}.data -e mem:0x${chk_addr}:r${ri} -k "U:${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf record -o ${filename}.data -e mem:0x${chk_addr}:r${ri} -k "${g_l}${eq_num}" ${cmd} ${which_bound} -1 2>/dev/null
            perf report -i u_${filename}.data > u_${filename}.report0
            perf report -i U_${filename}.data > U_${filename}.report0
            perf report -i ${filename}.data > ${filename}.report0
        done
    done
    
    has_content_file_list="`ls *.report1` `ls *.report2`"
    no_content_file_list=`ls *.report0`
    #check report files have content or not
    has_content $has_content_file_list
    has_content 0 $no_content_file_list
    #out of range
    for chk_file in `ls *.report2`;do
        check_in_file "input out of range" $chk_file
    done
    #invalid
    for chk_file in `ls u_*.report4`;do
        check_in_file "invalid hwbp_filter: u:" $chk_file
    done
    for chk_file in `ls U_*.report4`;do
        check_in_file "invalid hwbp_filter: U:" $chk_file
    done
    for chk_file in `ls *.report4 | grep -v "^u" | grep -v "^U"`;do
        check_in_file "invalid hwbp_filter: " $chk_file
    done
    #report something of bound1
    bound1_GT_left_val="`get_check_val 01`"" 00 00 00"
    bound1_EQ_right_val="`get_check_val ff`"" 00 00 00"
    bound1_LT_right_val="`get_check_val fe`"" 00 00 00"

    #report something of bound2
    bound2_GT_left_val="`get_check_val 00 01`"" 00 00"
    bound2_EQ_right_val="`get_check_val ff ff`"" 00 00"
    bound2_LT_right_val="`get_check_val ff fe`"" 00 00"

    #report something of bound4
    bound4_GT_left_val=`get_check_val 00 00 00 01`
    bound4_EQ_right_val=`get_check_val ff ff ff ff`
    bound4_LT_right_val=`get_check_val ff ff ff fe`

    EQ_left_val="00 00 00 00"
    EQ_left_memval=0x0
    for ri in 1 2 4;do
        GT_left_val=`eval echo '$'bound${ri}_GT_left_val`
        GT_left_memval=`get_check_memval $GT_left_val`
        EQ_right_val=`eval echo '$'bound${ri}_EQ_right_val`
        EQ_right_memval=`get_check_memval $EQ_right_val`
        LT_right_val=`eval echo '$'bound${ri}_LT_right_val`
        LT_right_memval=`get_check_memval $LT_right_val`
        chk_addr=`eval echo '$'addr_bound${ri}`
        
        for fileprefix in bound U_bound u_bound;do
            check_in_file "===> ${chk_addr}: $EQ_left_val" ${fileprefix}${ri}_left_seq_eq-${temp_num}.report1
            check_in_file "memval:   $EQ_left_memval$" ${fileprefix}${ri}_left_seq_eq-${temp_num}.report1
            check_in_file "===> ${chk_addr}: $GT_left_val" ${fileprefix}${ri}_left_sgt_gt-${temp_num}.report1
            check_in_file "memval:   $GT_left_memval$" ${fileprefix}${ri}_left_sgt_gt-${temp_num}.report1
            #-1 is 0xff that is right bound
            check_in_file "===> ${chk_addr}: $EQ_right_val" ${fileprefix}${ri}_left_sgt_lt-${temp_num}.report1
            check_in_file "memval:   $EQ_right_memval$" ${fileprefix}${ri}_left_sgt_lt-${temp_num}.report1
            check_in_file "===> ${chk_addr}: $EQ_right_val" ${fileprefix}${ri}_right_seq_eq-${temp_num}.report1
            check_in_file "memval:   $EQ_right_memval$" ${fileprefix}${ri}_right_seq_eq-${temp_num}.report1
            check_in_file "===> ${chk_addr}: $LT_right_val" ${fileprefix}${ri}_right_slt_lt-${temp_num}.report1
            check_in_file "memval:   $LT_right_memval$" ${fileprefix}${ri}_right_slt_lt-${temp_num}.report1
            #256 is 0x00 that is left bound
            check_in_file "===> ${chk_addr}: $EQ_left_val" ${fileprefix}${ri}_right_slt_gt-${temp_num}.report1
            check_in_file "memval:   $EQ_left_memval$" ${fileprefix}${ri}_right_slt_gt-${temp_num}.report1
        done
    done
}

######################################################################
##-@ Description:  main function
######################################################################
cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv

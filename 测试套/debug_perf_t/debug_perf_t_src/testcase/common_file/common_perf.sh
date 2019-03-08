#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_record_common
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: functions for perf test
##- @Detail: 
#######################################################################*/

######################################################################
##- @Description: check is the option of perf supported
#       $1 should be the help file which created by init.sh
#       like:check is perf record support -G, do
#       func_is_support file=$TCCFG/record.help -G
######################################################################
func_is_support()
{
    for ac_option
    do
        case ${ac_option} in
            --*)
            local get_optin=${ac_option#--}
            local ac_slashslash="${ac_slashslash} --${get_optin}"
            grep "\-\-${get_optin}" $file > /dev/null 2>&1
            if [ $? -eq 0 ];then
                echo "TINFO : --${get_optin} is supported"
                return 1
            fi
            ;;
            -*)
            local get_optin=${ac_option#-}
            local ac_slash="${ac_slash} -${get_optin}"
            grep "\-${get_optin}," $file > /dev/null 2>&1
            if [ $? -eq 0 ];then
                echo "TINFO : -${get_optin} is supported"
                return 1
            fi
            ;;
            *=*)
            local file=${ac_option#*=}
            ;;
            *)
            ;;
        esac
    done
    echo "TFAIL: do not support $ac_slash $ac_slashslash"
    exit 1
}
######################################################################
##- @Description: set RC=0 and mkdir TCTMP
######################################################################
prepare_tmp()
{
    RC=0
    TCTMP=${TCBIN}./perf-tmp-$$
    mkdir ${TCTMP}
}
######################################################################
##- @Description: rm -rf TCTMP and exit, use in the end of testcase
######################################################################
clean_end()
{
    rm -rf $TCTMP
    while [ $RC -gt 256 ];do
        RC=$((RC - 256))
    done
    [ $RC -eq 256 ] && RC=250
    exit $RC
}
######################################################################
##- @Description: check are files exists
##-     filename should not be "1" or "0"
##-     if contains 0,means files should not exists
##-     contains 1(default),means files should exists
######################################################################
has_file()
{
    local has_file=1
    local files="x"
    local filenames="x"
    for ac_option
    do
        case ${ac_option} in
            1 | 0)
            has_file=${ac_option}
            ;;
            *)
            files="${files} ${ac_option}"
            filenames="${filenames} ${ac_option##*/}"
            ;;
        esac
    done

    [ "$files" = "x" ] && echo "TFAIL: no file to check" && RC=$((RC + 1)) && return 0
    files=${files##x }
    filenames=${filenames##x }

    if [ $has_file -eq 1 ];then
        for file in $files;do
            if [ ! -f $file ];then
                RC=$((RC + 1))
                echo "TFAIL: file $file missing"
                return 0
            fi
        done
        echo "TPASS: all files($filenames) exists"
    else
        for file in $files;do
            if [ -f $file ];then
                RC=$((RC + 1))
                echo "TFAIL: $file should not exists"
                return 0
            fi
        done
        echo "TPASS: all files($filenames) not exists"
    fi
    return 0
}
######################################################################
##- @Description: check are files have content or not
##-     filename should not be "1" or "0"
##-     if contains 0,means files should have no content
##-     contains 1(default),means files should have content
######################################################################
has_content()
{
    local has_content=1
    local files="x"
    local filenames="x"
    for ac_option
    do
        case ${ac_option} in
            1 | 0)
            has_content=${ac_option}
            ;;
            *)
            files="${files} ${ac_option}"
            filenames="${filenames} ${ac_option##*/}"
            ;;
        esac
    done

    [ "$files" = "x" ] && echo "TFAIL: no file to check" && RC=$((RC + 1)) && return 0
    files=${files##x }
    filenames=${filenames##x }

    if [ $has_content -eq 1 ];then
        for file in $files;do
            local lines=`cat $file | wc -l`
            if [ $lines -eq 0 ];then
                RC=$((RC + 1))
                echo "TFAIL: $file do not have content"
                return 0
            fi
        done
        echo "TPASS: all files($filenames) have content"
    else
        for file in $files;do
            local lines=`cat $file | wc -l`
            if [ $lines -ne 0 ];then
                RC=$((RC + 1))
                echo "TFAIL: $file do have content"
                return 0
            fi
        done
        echo "TPASS: all files($filenames) have no content"
    fi
    return 0
}
######################################################################
##- @Description: check file contains content "$chk" or not
##-     $1:$chk
##-     $2:$file
##-     $3:1:contains(default) 0:do not contain
######################################################################
check_in_file()
{
    local chk=$1
    local file=${2:-nosuchfile}
    local filename=`basename $file`
    local is_contain=${3:-1}
    local ret=`grep "$chk" $file | wc -l`

    case $is_contain in
        1)
        if [ $ret -ne 0 ];then
            echo "TPASS: \"${chk}\" checked in ${filename}"
            return $ret
        else
            echo "TFAIL: \"${chk}\" missing in ${filename}"
            RC=$((RC+1))
        fi
        ;;
        0)
        if [ $ret -eq 0 ];then
            echo "TPASS: \"${chk}\" checked in ${filename}"
        else
            echo "TFAIL: ${filename} should not contains \"${chk}\""
            RC=$((RC+1))
            return $ret
        fi
        ;;
        *)
        echo "TINFO: wrong usage" && RC=$((RC+1))
        ;;
    esac
}
######################################################################
##- @Description: check the return code
##-     $1:$?
##-     $2:0:return code should be 0 (default)
##-        1:return code should not be 0
######################################################################
check_ret_code()
{
    local ret=$1
    local should_be=${2:-0}
    case $should_be in
        1)
        if [ $ret -ne 0 ];then
            echo "TPASS: return code checked"
        else
            echo "TFAIL: return code error, should be ~0"
            RC=$((RC+1))
        fi
        ;;
        0)
        if [ $ret -eq 0 ];then
            echo "TPASS: return code checked"
        else
            echo "TFAIL: return code error, should be 0"
            RC=$((RC+1))
        fi
        ;;
        *)
        echo "TINFO: wrong usage" && RC=$((RC+1))
        ;;
    esac
}
######################################################################
##- @Description: decide use hugetlb to fork a user_prg or not
######################################################################
use_huge()
{
    for ac_option
    do
        case ${ac_option} in
            hugetlb)
            if [ ${IS_SUPPORT_HUGETLBFS} -eq 0 ];then
                echo "TFAIL: Do not support hugetlbfs"
                exit 1
            fi
            USE_HUGE=huge_
            ;;
            *);;
        esac
    done
}
######################################################################
##- @Description: check is file1 the same with file2
######################################################################
func_is_diff()
{
    local file1=$1
    local file2=$2
    local filename1=`basename $file1`
    local filename2=`basename $file2`
    diff $file1 $file2
    if [ $? -ne 0 ];then
        echo "TFAIL: $filename1 and $filename2 are different"
        RC=$((RC + 1))
    else 
        echo "TPASS: $filename1 and $filename2 are the same"
    fi
}

######################################################################
##- @Description: check the perf version
##- input: the perf version eg: input "4 1" (perf.4.1.11.xx)
##- return: 
##-        the perf version(system command) >= the perf version(input) = 1
##-        the perf version(system command) <  the perf version(input) = 0
######################################################################
perf_vcmp()
{
	local v1=$1
	local v2=$2

	local perf_v1="`perf --version |awk -F" " '{print $3}' |awk -F"." '{print $1}'`"
	local perf_v2="`perf --version |awk -F" " '{print $3}' |awk -F"." '{print $2}'`"

	if [ "$perf_v1" -gt "$v1" ]; then
        	return 1
	elif [ "$v1" -gt "$perf_v1" ]; then
        	return 0
	else
		if [ "$perf_v2" -ge "$v2" ]; then
			return 1
		else
			return 0
		fi
	fi
}

#!/bin/bash

export FILESCG_ROOT_DIR=/dev/files
FILESCG_MOUNT_OPTS='rw,nosuid,nodev,noexec,relatime,files'

#mount filescg if necessary
filescg_init()
{ 
	if  [ -z "`cat /proc/cgroups |grep ^files`" ];then
		echo "filescgroup is not"
		return 1
	fi
	if [ -n "`mount |grep ' cgroup ' |grep -E ',files,|\(files,|,files\)'`" ];then
		FILESCG_ROOT_DIR=`mount |grep ' cgroup ' |grep -E ',files,|\(files,|,files\)'|head -n1|awk '{print $3}'`
	else
		mkdir -p $FILESCG_ROOT_DIR
		mount -t cgroup -o $FILESCG_MOUNT_OPTS cgroup $FILESCG_ROOT_DIR
		if [ $? -ne 0 ];then
			echo "filescgroup mount failed"
			return 1
		fi
	fi
	return 0

}
#clean tasks and rmdir child filescg
#TODO recurrsive
filescg_clean()
{
	local ret=0	
	for cg in `ls -l $FILESCG_ROOT_DIR |grep ^d |awk '{print $NF}'`
	do
		for pid in `cat $FILESCG_ROOT_DIR/$cg/cgroup.procs`
		do
			kill -9 $pid #violently
		done
		rmdir $FILESCG_ROOT_DIR/$cg
		if [ $? -ne 0 ];then
			echo "rmdir $FILESCG_ROOT_DIR/$cg failed"
			ret=1
		fi
	done
	return $ret

}

#input limit && open_count
filescg_test()
{
	local ret=0
	local limit=$1
	local count=$2
	test_cg_dir=$FILESCG_ROOT_DIR/test_cg
	mkdir $test_cg_dir

	echo $limit > $test_cg_dir/files.limit
	usage_0=`cat $test_cg_dir/files.usage`
	#stdin stdout stder
	./$TEST_PROGRAM $count 1 &
	pid=$!
	echo $pid > $test_cg_dir/cgroup.procs
	if [ $limit -lt 3 ];then
		if [ 0 -ne `cat $test_cg_dir/cgroup.procs |wc -l` ];then
			echo "less than limit(3),but binary program add to filegroup"
			kill -9 $pid
			rm testfile*
			ret=1
		fi
	        rmdir $test_cg_dir
		ret=$((ret+$?))
		return $ret
	fi
	sleep 1

	usage_1=`cat $test_cg_dir/files.usage`
	sleep 12
	usage_2=`cat $test_cg_dir/files.usage`
	if [ $count -ge $((limit-3)) ];then
              if [ $usage_2 -ne $limit ];then
		      echo "fds occupied failed:$usage_1:$usage_2:$count:$limit"
		      ret=1
	      fi
        else
	      diff=$((usage_2-usage_1))
	      if [ $diff -ne $count ];then
	          echo "fds occupied failed:$usage_1:$usage_2"
	      	  ret=1
	      fi
        fi
	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir/files.usage` -ne $usage_0 ];then
		echo "filescg fd recovery failed : $usage_0"
		ret=1
	fi
	rmdir $test_cg_dir
	ret=$((ret+$?))
	return 	$ret       
}

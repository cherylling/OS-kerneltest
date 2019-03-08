#!/bin/bash
. ./lib_files_cg.sh
TEST_PROGRAM=test_open

#basic check filescg create/destroy/read/write(files.limit files.usage)
testcase_1()
{
	test_cg_dir=$FILESCG_ROOT_DIR/cg1
	mkdir $test_cg_dir
	files_limit='0 1 10 100 1000 10000 12345678901234'
	for limit in $files_limit
	do
		echo $limit > $test_cg_dir/files.limit
		if [ $limit -ne `cat $test_cg_dir/files.limit` ];then
			echo "$test_cg_dir/files.limit is not equal to $limit"
			rmdir $test_cg_dir
			return 1
		fi
	done
	if [ `cat $test_cg_dir/files.usage` -ne 0 ];then
		echo "fd is used unexpectedly"
		rmdir $test_cg_dir
		return 1
	fi
	original_limit=`cat $test_cg_dir/files.limit`
	files_limit='-1 abcdef'
	for limit in $files_limit
	do
		echo $limit > $test_cg_dir/files.limit
		if [ $original_limit -ne `cat $test_cg_dir/files.limit` ];then
			echo "$test_cg_dir/files.limit is not equal to $original_limit : $limit"
			rmdir $test_cg_dir
			return 1
		fi
	done
	rmdir $test_cg_dir
	return $?
}

#filescg create pressure (count && depth)
testcase_2()
{ 
	local ret=0
	local count=1000
	local  i=0
	for((i=1;i<=$count;i++))
	do
		mkdir $FILESCG_ROOT_DIR/test_cg${i} 
	done
	if [ $count -ne `ls -l $FILESCG_ROOT_DIR/ |grep ^d |grep 'test_cg' |wc -l` ];then
		echo "child filescg create failed in one hierachy"
		ret=1
	fi
	for((i=1;i<=$count;i++))
	do
		rmdir $FILESCG_ROOT_DIR/test_cg${i}
	done
	if [ 0 -ne `ls -l $FILESCG_ROOT_DIR/ |grep ^d |grep 'test_cg' |wc -l` ];then
		echo "child filescg removed failed in one hierachy"
		ret=1
	fi

	depth=1000
	dir_path=$FILESCG_ROOT_DIR
	for((i=1;i<=$count;i++))
	do
		dir_path=$dir_path/cg
		mkdir $dir_path  
	done
	#echo $dir_path
	[ ! -d $dir_path ] && echo "child filescg depth 1000 create failed" && ret=1
	for((i=1;i<=$count;i++))
	do
		rmdir $dir_path
		dir_path=${dir_path%/*}
	done
	[ -d $FILESCG_ROOT_DIR/cg ] && echo "child filescg depth 1000 remove failed" && ret=1
	return $ret

}

#one process open one file once
testcase_3()
{
	local ret=0
	test_cg_dir=$FILESCG_ROOT_DIR/test_cg
	mkdir $test_cg_dir
	echo 100 > $test_cg_dir/files.limit
	./$TEST_PROGRAM 1 0 &
	pid=$!
	echo $pid > $test_cg_dir/cgroup.procs
	sleep 1

	usage_1=`cat $test_cg_dir/files.usage`
	sleep 12
	usage_2=`cat $test_cg_dir/files.usage`
	diff=$((usage_2-usage_1))
	if [ $diff -ne 1 ];then
		echo "one fd occupied failed:$usage_1:$usage_2"
		ret=1
	fi

	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir/tasks |wc -l` -ne 0 ];then
		echo "pid removed failed"
		ret=1
	fi
	rmdir $test_cg_dir
	ret=$((ret+$?))
	return $ret
}

#one process open one file (counts)
testcase_4()
{
	local ret=0
	local limit=100
	local count=20
	test_cg_dir=$FILESCG_ROOT_DIR/test_cg
	mkdir $test_cg_dir

	echo $limit > $test_cg_dir/files.limit
	usage_0=`cat $test_cg_dir/files.usage`
	./$TEST_PROGRAM $count 0 &
	pid=$!
	echo $pid > $test_cg_dir/cgroup.procs
	sleep 1

	usage_1=`cat $test_cg_dir/files.usage`
	sleep 12
	usage_2=`cat $test_cg_dir/files.usage`
	diff=$((usage_2-usage_1))
	if [ $diff -ne $count ];then
		echo "fds occupied failed:$usage_1:$usage_2"
		ret=1
	fi
	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir/files.usage` -ne $usage_0 ];then
		echo "filescg fd recovery failed : $usage_0"
		ret=1
	fi
	rmdir $test_cg_dir
	ret=$((ret+$?))
	return $ret
}

#one process open different files (counts)
testcase_5()
{
	local ret=0
	local limit=100
	local count=20
	test_cg_dir=$FILESCG_ROOT_DIR/test_cg
	mkdir $test_cg_dir

	echo $limit > $test_cg_dir/files.limit
	usage_0=`cat $test_cg_dir/files.usage`
	./$TEST_PROGRAM $count 1 &
	pid=$!
	echo $pid > $test_cg_dir/cgroup.procs
	sleep 1

	usage_1=`cat $test_cg_dir/files.usage`
	sleep 12
	usage_2=`cat $test_cg_dir/files.usage`
	diff=$((usage_2-usage_1))
	if [ $diff -ne $count ];then
		echo "fds occupied failed:$usage_1:$usage_2"
		ret=1
	fi
	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir/files.usage` -ne $usage_0 ];then
		echo "filescg fd recovery failed : $usage_0"
		ret=1
	fi
	rmdir $test_cg_dir
	ret=$((ret+$?))
	return $ret
}

#corner cases (limit->0 ;count(usage)=limit ;limitexceed limit)
testcase_6()
{
	local ret=0
	filescg_test 0 3
	ret=$((ret+$?))
	filescg_test 6 3
	ret=$((ret+$?))
	filescg_test 20 100
	ret=$((ret+$?))
	return $ret

}

#multi process
testcase_7()
{
	local i=1
	local ret=0
	local limit=10000
	local count=1025
	test_cg_dir=$FILESCG_ROOT_DIR/test_cg
	mkdir $test_cg_dir

	echo $limit > $test_cg_dir/files.limit
	usage_0=`cat $test_cg_dir/files.usage`
	local pids=''
	for((i=1;i<=$count;i++))
	do
		./$TEST_PROGRAM 1 0 &
		pids="$! $pids"
	done
	for pid in $pids
	do
		echo $pid > $test_cg_dir/cgroup.procs
	done
	sleep 1

	usage_1=`cat $test_cg_dir/files.usage`
	sleep 12
	usage_2=`cat $test_cg_dir/files.usage`
	diff=$((usage_2-usage_1))
	if [ $diff -ne $count ];then
		echo "fds occupied failed:$usage_1:$usage_2"
		ret=1
	fi
	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir/files.usage` -ne $usage_0 ];then
		echo "filescg fd recovery failed : $usage_0"
		ret=1
	fi
	rmdir $test_cg_dir
	ret=$((ret+$?))
	return  $ret
}

#cgroup migration
testcase_8()
{
	local i=1
	local ret=0
	local limit=10000
	local count=1025
	test_cg_dir_1=$FILESCG_ROOT_DIR/test_cg_1
	test_cg_dir_2=$FILESCG_ROOT_DIR/test_cg_2
	mkdir $test_cg_dir_1 $test_cg_dir_2
	echo $limit > $test_cg_dir_1/files.limit
	echo $limit > $test_cg_dir_2/files.limit
	
	usage_0=`cat $test_cg_dir_2/files.usage`
	./$TEST_PROGRAM $count 0 &
	pid=$!
	echo $pid > $test_cg_dir_1/cgroup.procs
	sleep 13
	echo $pid > $test_cg_dir_2/cgroup.procs
        
	usage_2=`cat $test_cg_dir_2/files.usage`
	if [ $usage_2 -ne $((count+3)) ];then
		echo "fds occupied failed: $usage_2"
		ret=1
	fi
	sleep 10
	[ -d /proc/$pid ] && kill -9 $pid
	if [ `cat $test_cg_dir_2/files.usage` -ne $usage_0 ];then
		echo "filescg fd recovery failed : $usage_0"
		ret=1
	fi
	rmdir $test_cg_dir_1
	rmdir $test_cg_dir_2
	ret=$((ret+$?))


}
TESTCASE_COUNT=8
filescg_init
if [ $? -ne 0 ];then
	exit 1
fi

for((i=1;i<=$TESTCASE_COUNT;i++))
do
	testcase_$i
	if [ $? -eq 0 ];then
		echo "testcase_$i : PASS"
	else
		echo "testcase_$i : FAIL"
	fi
done
filescg_clean

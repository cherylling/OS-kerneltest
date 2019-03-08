#!/bin/sh
. ../../../conf/hostconf
cd `dirname $0`

clean_env()
{
	target_load "cd $TARGET_INSTALL_DIR_BASE ; rm -rf ${TESTSUITE_NAME}"
}

clean_env

target_script_name=`basename $0`
target_script_name=${target_script_name#HOST-}

if [ "`ls ../.. | grep bin`" != "bin" ]
then
	echo "Directory ../../bin doesn't exist"
	clean_env
	exit 1
fi

#copy conf to target
target_copy ../../../conf/testconf ${TARGET_INSTALL_DIR_BASE}/${TESTSUITE_NAME}/conf
if [ $? -ne 0 ]
then
    echo "scp ../../../conf/testconf to ${TARGET_IP}:${TARGET_INSTALL_DIR_BASE}/${TESTSUITE_NAME}/conf fail"
    clean_env
    exit 1
fi

target_copy ../../../conf/hostconf ${TARGET_INSTALL_DIR_BASE}/${TESTSUITE_NAME}/conf
if [ $? -ne 0 ]
then
    echo "scp ../../../conf/hostconf to ${TARGET_IP}:${TARGET_INSTALL_DIR_BASE}/${TESTSUITE_NAME}/conf fail"
    clean_env
    exit 1
fi

Cp_objects="cloudran_docker_save_100M.sh init.sh"

#copy testsuite to target
for cp_object in $Cp_objects
do
	target_copy ../../bin/docker/${cp_object} ${TARGET_INSTALL_DIR}/docker
	if [ $? -ne 0 ]
	then
		echo "scp ../../bin/docker/${cp_object} to ${TARGET_IP}:${TARGET_INSTALL_DIR}/docker fail"
		#clean_env
		exit 1
	fi
done

target_load "cd ${TARGET_INSTALL_DIR}/docker ; bash ${target_script_name}" 
if [ $? -ne 0 ]
then
	echo "${target_script_name} : fail"
	#clean_env
	exit 1
fi
rm -f ./result.tmp
scp ${TARGET_USER}@${TARGET_IP}:${TARGET_INSTALL_DIR}/docker/../../${DOCKER_RESULT} ./result.tmp
if [ $? -ne 0 ]
then
	echo "copy result from target board fail "
	#clean_env
	exit 1
fi
result_testcase=`echo $0 | awk -F '-' '{print $2}' | awk -F '.' '{print $1}'`
cat ./result.tmp >> ../../${DOCKER_RESULT} > $PERF_RESULT_DIR/${result_testcase}.perfdata
rm -f ./result.tmp
clean_env
exit 0

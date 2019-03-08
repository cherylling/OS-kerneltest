#!/bin/sh
cd `dirname ${0}`

. ./hostconf

#FIX ME
cd .

rm -f $FILENAME
cp performance_format.xml $FILENAME

lmbench_data()
{
    if [ $# != 2 ]
    then
        echo "This function need two parameters"
        return 1
    fi
    local first_row=$1
    local second_row=`expr $first_row '+' 1`
    local third_row=`expr $first_row '+' 2`
    local column_num=$2
    local column_num_current=0
    local column_count=1
    local flag=0
    local first_ch
    local second_ch
    local third_ch
    local start_byte=0
    local end_byte=0
    while :
    do
        first_ch=`sed -n ${first_row}p $LMBENCH_RESULT | cut -c $column_count` 
        second_ch=`sed -n ${second_row}p $LMBENCH_RESULT | cut -c $column_count`
        third_ch=`sed -n ${third_row}p $LMBENCH_RESULT | cut -c $column_count`
        if [ $flag = 0 ]
        then
            echo "${first_ch}${second_ch}${third_ch}" | grep "[^[:blank:]]" > /dev/null
            if [ $? -eq 0 ]
            then
                flag=1
                column_num_current=`expr $column_num_current '+' 1`
                if [ $column_num_current -eq $column_num ]
                then
                    start_byte=$column_count
                else 
                    if [ $column_num_current -gt $column_num ]
                    then
                        echo "Second parameter error"
                        return 1
                    fi
                fi
            fi
        fi
        if [ $flag = 1 ]
        then
            #don't add double quotation marks here
            echo ${first_ch}${second_ch}${third_ch} | grep "." > /dev/null   
            if [ $? -ne 0 ]
            then
                flag=0
                #it seems that this is not necessary , but for safe
                end_byte=`expr $column_count '-' 1`
            fi
        fi
        if [ "$start_byte" != 0 ] && [ "$flag" = 0 ]
        then
            break
        fi
        column_count=`expr $column_count '+' 1`
    done
    fret=`sed -n \`expr $first_row '+' 3\`p $LMBENCH_RESULT | cut -c ${start_byte}-${end_byte}`
    if [ $? -ne 0 ]
    then
        echo "Get data fail,line $first_row ,the $column_num index"
        return 1
    fi
    fret=${fret%\.}
    echo $fret
    return 0
}

getdata_lmbench()
{
    if [ ! -f $LMBENCH_RESULT ]
    then
        echo "$LMBENCH_RESULT doesn't exist"
        return 1
    fi
    Str_context_switching_2p_0k=`lmbench_data 15 3` 
    Str_context_switching_2p_16k=`lmbench_data 15 4` 
    Str_context_switching_2p_64k=`lmbench_data 15 5` 
    Str_context_switching_8p_16k=`lmbench_data 15 6`
    Str_context_switching_8p_64k=`lmbench_data 15 7`
    Str_context_switching_16p_16k=`lmbench_data 15 8`
    Str_context_switching_16p_64k=`lmbench_data 15 9`
    Str_sig_inst=`lmbench_data 8 9`
    Str_sig_hndl=`lmbench_data 8 10`
    Str_fork_proc_latency=`lmbench_data 8 11`
    Str_exec_proc_latency=`lmbench_data 8 12`
    Str_sh_proc_latency=`lmbench_data 8 13`
    Str_null_call=`lmbench_data 8 4`
    Str_page_fault=`lmbench_data 29 7`
    Str_prot_fault=`lmbench_data 29 6`
    Str_local_communication_ctxsw_latency=`lmbench_data 22 3`
    Str_local_communication_pipe_latency=`lmbench_data 22 4`
    Str_local_communication_AF_UNIX_latency=`lmbench_data 22 5`
    Str_local_communication_UDP_latency=`lmbench_data 22 6`
    Str_local_communication_RPC_UDP_latency=`lmbench_data 22 7`
    Str_local_communication_TCP_latency=`lmbench_data 22 8`
    Str_local_communication_RPC_TCP_latency=`lmbench_data 22 9`
    Str_local_communication_TCP_conn_latency=`lmbench_data 22 10`
    Str_processor_null_IO=`lmbench_data 8 5`
    Str_processor_stat=`lmbench_data 8 6`
    Str_processor_open_close=`lmbench_data 8 7`

    #Str_FILE_create_delete has two data,create latency and delete latency
    Str_FILE_create_delete=`lmbench_data 29 3`
    Str_FILE_create_delete=${Str_FILE_create_delete##^ *}
    Str_FILE_create_delete=${Str_FILE_create_delete%%^ *}
    echo $Str_FILE_create_delete | grep "[^[:blank:]]" > /dev/null
    if [ $? -eq 0 ]
    then
        Str_FILE_create_delete=`echo "$Str_FILE_create_delete" | sed "s/[[:blank:]]\{1,\}/\\\\\\\\\//"`
    fi
    Str_FILE_mmap_latency=`lmbench_data 29 5`
    Str_FILE_100fd_select=`lmbench_data 29 8`
    return 0
}

fill_sheet_lmbench()
{
    if [ ! -f $FILENAME ]
    then
        echo "$FILENAME doesn't exist"
        return 1
    fi
    sed -i "s/Data_context_switching_2p_0k/${Str_context_switching_2p_0k}/" $FILENAME
    sed -i "s/Data_context_switching_2p_16k/${Str_context_switching_2p_16k}/" $FILENAME
    sed -i "s/Data_context_switching_2p_64k/${Str_context_switching_2p_64k}/" $FILENAME
    sed -i "s/Data_context_switching_8p_16k/${Str_context_switching_8p_16k}/" $FILENAME
    sed -i "s/Data_context_switching_8p_64k/${Str_context_switching_8p_64k}/" $FILENAME
    sed -i "s/Data_context_switching_16p_16k/${Str_context_switching_16p_16k}/" $FILENAME
    sed -i "s/Data_context_switching_16p_64k/${Str_context_switching_16p_64k}/" $FILENAME
    sed -i "s/Data_sig_inst/${Str_sig_inst}/" $FILENAME
    sed -i "s/Data_sig_hndl/${Str_sig_hndl}/" $FILENAME
    sed -i "s/Data_fork_proc_latency/${Str_fork_proc_latency}/" $FILENAME
    sed -i "s/Data_exec_proc_latency/${Str_exec_proc_latency}/" $FILENAME
    sed -i "s/Data_sh_proc_latency/${Str_sh_proc_latency}/" $FILENAME
    sed -i "s/Data_null_call/${Str_null_call}/" $FILENAME
    sed -i "s/Data_page_fault/${Str_page_fault}/" $FILENAME
    sed -i "s/Data_prot_fault/${Str_prot_fault}/" $FILENAME
    sed -i "s/Data_local_communication_ctxsw_latency/${Str_local_communication_ctxsw_latency}/" $FILENAME
    sed -i "s/Data_local_communication_pipe_latency/${Str_local_communication_pipe_latency}/" $FILENAME
    sed -i "s/Data_local_communication_AF_UNIX_latency/${Str_local_communication_AF_UNIX_latency}/" $FILENAME
    sed -i "s/Data_local_communication_UDP_latency/${Str_local_communication_UDP_latency}/" $FILENAME
    sed -i "s/Data_local_communication_RPC_UDP_latency/${Str_local_communication_RPC_UDP_latency}/" $FILENAME
    sed -i "s/Data_local_communication_TCP_latency/${Str_local_communication_TCP_latency}/" $FILENAME
    sed -i "s/Data_local_communication_RPC_TCP_latency/${Str_local_communication_RPC_TCP_latency}/" $FILENAME
    sed -i "s/Data_local_communication_TCP_conn_latency/${Str_local_communication_TCP_conn_latency}/" $FILENAME
    sed -i "s/Data_processor_null_IO/${Str_processor_null_IO}/" $FILENAME
    sed -i "s/Data_processor_stat/${Str_processor_stat}/" $FILENAME
    sed -i "s/Data_processor_open_close/${Str_processor_open_close}/" $FILENAME
    sed -i "s/Data_FILE_create_delete/${Str_FILE_create_delete}/" $FILENAME
    sed -i "s/Data_FILE_mmap_latency/${Str_FILE_mmap_latency}/" $FILENAME
    sed -i "s/Data_FILE_100fd_select/${Str_FILE_100fd_select}/" $FILENAME
    return 0
}

do_lmbench()
{
    getdata_lmbench
    if [ $? -ne 0 ]
    then
        echo "getdata_lmbench fail"
        return 1
    fi
    fill_sheet_lmbench
    if [ $? -ne 0 ]
    then
        echo "fill_sheet_lmbench fail"
        return 1
    fi
    return 0
}

performance_data()
{
    local index_name=$1
    local fret=""
    local str_add=""
    index_name=`echo $index_name | tr [[:upper:]] [[:lower:]]`
    if [ ! -f $PERFORMANCE_TESTSUITE_RESULT ]
    then
        echo "$PERFORMANCE_TESTSUITE_RESULT doesn't exist"
        return 1
    fi

    if [ "X$index_name" = X ]
    then
        echo 'Usage: performance_data <index_name>'        
        return 1
    fi

    case $index_name in
    "cpu_occupy_error") 
    grep -i "^cpu_occupy_error[[:blank:]]" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
    if [ $? -ne 0 ]
    then
        fret=""
    else
        fret="`grep -i \"^cpu_occupy_error[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
        | awk '{print $2,$3}' | tail -n 1`"
        echo $fret
        return 0
    fi
    ;;
    "ipi_per_sec")
    grep -i "^ipi_per_sec[[:blank:]]" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
    if [ $? -ne 0 ]
    then
        fret=""
    else
        fret="`grep -i \"^ipi_per_sec[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
        | awk '{print $2}' | tail -n 1`"
        echo $fret
        return 0
    fi
    ;;

	"protocol_stack_consumption_transmit_littlepackage")
	grep -i "^protocol_stack_consumption_transmit_littlepackage[[:blank:]]" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
	if [ $? -ne 0 ]
	then
		fret=""
	else
		fret="`grep -i \"^protocol_stack_consumption_transmit_littlepackage[[:blank:]]\" \
		$PERFORMANCE_TESTSUITE_RESULT | awk '{print $2}' | tail -n 1`"
		echo $fret
		return 0
	fi
	;;

	"protocol_stack_consumption_transmit_bigpackage")
	grep -i "^protocol_stack_consumption_transmit_bigpackage[[:blank:]]" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
	if [ $? -ne 0 ]
	then
		fret=""
	else
		fret="`grep -i \"^protocol_stack_consumption_transmit_bigpackage[[:blank:]]\" \
		$PERFORMANCE_TESTSUITE_RESULT | awk '{print $2}' | tail -n 1`"
		echo $fret
		return 0
	fi
	;;

	#"sleeper_accuracy")
	#echo "sleep_accuracy needs a label,use do_performance_testsuite_label instead"
	#return 1
	#;;
    *)
    grep -i "^${index_name}[[:blank:]]" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
    if [ $? -ne 0 ]
    then
        fret=""
    else
        if [ x"`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
            | awk '{print $3}' | grep -v \"[[:digit:]]\"`" != x ]
        then
            fret="min="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $2,$3}' | tail -n 1`"
            fret="${fret}${str_add}\&\#10"
            fret="${fret}max="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $4,$5}' | tail -n 1`"
            fret="${fret}${str_add}\&\#10"
            fret="${fret}avg="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $6,$7}' | tail -n 1`"
            fret="${fret}${str_add}"                     
        elif [ "`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
            | awk '{print NF}'`" -ge 4 ]
        then
            fret="min="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $2}' | tail -n 1`"
            fret="${fret}${str_add}\&\#10"
            fret="${fret}max="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $3}' | tail -n 1`"
            fret="${fret}${str_add}\&\#10"
            fret="${fret}avg="
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
            | awk '{print $4}' | tail -n 1`"  
            if [ "`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
                | awk '{print NF}'`" -gt 4 ]
            then
                fret="${fret}${str_add}\&\#10"
                fret="${fret}error_rate="
                str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT \
                | awk '{print $5}' | tail -n 1`"
                fret="${fret}${str_add}"
            else
                fret="${fret}${str_add}"
            fi
        elif [ "`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
             | awk '{print NF}'`" -ge 2 ]
        then
            fret="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
            | awk '{print $2}'`"
            str_add="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1 \
            | awk '{print $3}'`"
            if [ x$str_add != x ]
            then
                fret="${fret} ${str_add}"
            fi
        else
            fret="`grep -i \"^${index_name}[[:blank:]]\" $PERFORMANCE_TESTSUITE_RESULT | tail -n 1`"
        fi
    fi
    esac
    echo $fret
    return 0
}

#this function is not use now
do_performance_testsuite_label()
{
    local Sleep_times="500 600 700 800 900 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 20000 30000 40000 \
    50000 60000 70000 80000 90000 100000"
    local Data_min
    local Data_max
    local Data_avg
    if [ ! -f $PERFORMANCE_TESTSUITE_RESULT ]
    then
        echo "$PERFORMANCE_TESTSUITE_RESULT doesn't exist"
        return 1
    fi                     
    count=1
    for Sleep_time in $Sleep_times
    do
        grep "^sleeper_accuracy.*sleep time=${Sleep_time} ns" $PERFORMANCE_TESTSUITE_RESULT > /dev/null
        if [ $? -ne 0 ]
        then
            echo "Get data for sleeper_min_accuracy fail,sleep_time=${Sleep_time}"
            continue
        fi
        Data_min=`grep "^sleeper_accuracy.*sleep time=${Sleep_time} ns" $PERFORMANCE_TESTSUITE_RESULT \
        | awk '{print $2,$3}' | tail -n 1`
        Data_max=`grep "^sleeper_accuracy.*sleep time=${Sleep_time} ns" $PERFORMANCE_TESTSUITE_RESULT \
        | awk '{print $4,$5}' | tail -n 1`
        Data_avg=`grep "^sleeper_accuracy.*sleep time=${Sleep_time} ns" $PERFORMANCE_TESTSUITE_RESULT \
        | awk '{print $6,$7}' | tail -n 1`
        sed -i "s/SHEET_MIN_${count}</${Data_min}</"  $FILENAME
        sed -i "s/SHEET_MAX_${count}</${Data_max}</"  $FILENAME
        sed -i "s/SHEET_AVG_${count}</${Data_avg}</"  $FILENAME
        count=`expr $count '+' 1`
    done
    return 0
}

getdata_performance_testsuite()
{
    if [ ! -f $PERFORMANCE_TESTSUITE_RESULT ]
    then
        echo "$PERFORMANCE_TESTSUITE_RESULT doesn't exist"
        return 1
    fi
    Str_kernel_interrupt_latency=`performance_data kernel_interrupt_latency`
    Str_uio_latency=`performance_data uio_latency`
    Str_thread_switch_latency_FIFO=`performance_data thread_switch_latency_FIFO`
    Str_thread_switch_latency_CFS=`performance_data thread_switch_latency_CFS`
    Str_process_race_latency_FIFO_FIFO=`performance_data process_race_latency_FIFO_FIFO`
    Str_process_race_latency_CFS_CFS1=`performance_data process_race_latency_CFS_CFS1`
    Str_process_race_latency_CFS_CFS2=`performance_data process_race_latency_CFS_CFS2`
    Str_pthread_create_exit_latency=`performance_data pthread_create_exit_latency`
    Str_pthread_create_latency=`performance_data pthread_create_latency`
    Str_fork_only_latency=`performance_data fork_latency`
    Str_exec_only_latency=`performance_data exec_latency`
    Str_gettimeofday_function_latency=`performance_data gettimeofday_function_latency`
    Str_page_alloc_latency=`performance_data page_alloc_latency`
    Str_write_copy_latency=`performance_data write_copy_latency`
    Str_ipi_latency=`performance_data ipi_latency`
    Str_cpu_timer_diff=`performance_data timer_error_between_cpus`
    Str_cpu_occupy_error=`performance_data cpu_occupy_error`
    Str_ipi_per_sec=`performance_data ipi_per_sec`
    
    #new cases for source consume
    Str_cpu_occupy_no_load=`performance_data cpu_occupy_no_load`
    Str_memory_consume_no_load=`performance_data memory_consume_no_load`

	#all for sleep accuracy
	Str_sleeper_accuracy_nsleep_1_FIFO=`performance_data sleeper_accuracy_nsleep_1_FIFO`
	Str_sleeper_accuracy_nsleep_10_FIFO=`performance_data sleeper_accuracy_nsleep_10_FIFO`
	Str_sleeper_accuracy_nsleep_100_FIFO=`performance_data sleeper_accuracy_nsleep_100_FIFO`
	Str_sleeper_accuracy_nsleep_1000_FIFO=`performance_data sleeper_accuracy_nsleep_1000_FIFO`
	Str_sleeper_accuracy_nsleep_1_CFS=`performance_data sleeper_accuracy_nsleep_1_CFS`
	Str_sleeper_accuracy_nsleep_10_CFS=`performance_data sleeper_accuracy_nsleep_10_CFS`
	Str_sleeper_accuracy_nsleep_100_CFS=`performance_data sleeper_accuracy_nsleep_100_CFS`
	Str_sleeper_accuracy_nsleep_1000_CFS=`performance_data sleeper_accuracy_nsleep_1000_CFS`
	Str_sleeper_accuracy_usleep_1_FIFO=`performance_data sleeper_accuracy_usleep_1_FIFO`
	Str_sleeper_accuracy_usleep_10_FIFO=`performance_data sleeper_accuracy_usleep_10_FIFO`
	Str_sleeper_accuracy_usleep_100_FIFO=`performance_data sleeper_accuracy_usleep_100_FIFO`
	Str_sleeper_accuracy_usleep_1000_FIFO=`performance_data sleeper_accuracy_usleep_1000_FIFO`
	Str_sleeper_accuracy_usleep_1_CFS=`performance_data sleeper_accuracy_usleep_1_CFS`
	Str_sleeper_accuracy_usleep_10_CFS=`performance_data sleeper_accuracy_usleep_10_CFS`
	Str_sleeper_accuracy_usleep_100_CFS=`performance_data sleeper_accuracy_usleep_100_CFS`
	Str_sleeper_accuracy_usleep_1000_CFS=`performance_data sleeper_accuracy_usleep_1000_CFS`
	#end of sleep accuracy

	#for network cases
	Str_protocol_stack_consumption_transmit_littlepackage=`performance_data protocol_stack_consumption_transmit_littlepackage`
	Str_protocol_stack_consumption_transmit_bigpackage=`performance_data protocol_stack_consumption_transmit_bigpackage`

	#do_performance_testsuite_label
	#if [ $? -ne 0 ]
	#then
	#    echo "get data for sleeper_min_accuracy fail"
	#    return 1
	#fi
    return 0
}


fill_sheet_performance_testsuite()
{
    if [ ! -f $FILENAME ]
    then
        echo "$FILENAME doesn't exist"
        return 1
    fi
    sed -i "s/Data_kernel_interrupt_latency/${Str_kernel_interrupt_latency}/" $FILENAME  
    sed -i "s/Data_uio_latency/${Str_uio_latency}/" $FILENAME
    sed -i "s/Data_thread_switch_latency_CFS/${Str_thread_switch_latency_CFS}/" $FILENAME
    sed -i "s/Data_thread_switch_latency_FIFO/${Str_thread_switch_latency_FIFO}/" $FILENAME
    sed -i "s/Data_process_race_latency_FIFO_FIFO/${Str_process_race_latency_FIFO_FIFO}/" $FILENAME
    sed -i "s/Data_process_race_latency_CFS_CFS1/${Str_process_race_latency_CFS_CFS1}/" $FILENAME
    sed -i "s/Data_process_race_latency_CFS_CFS2/${Str_process_race_latency_CFS_CFS2}/" $FILENAME
    sed -i "s/Data_pthread_create_exit_latency/${Str_pthread_create_exit_latency}/" $FILENAME
    sed -i "s/Data_pthread_create_latency/${Str_pthread_create_latency}/" $FILENAME
    sed -i "s/Data_fork_only_latency/${Str_fork_only_latency}/" $FILENAME
    sed -i "s/Data_exec_only_latency/${Str_exec_only_latency}/" $FILENAME
    sed -i "s/Data_gettimeofday_function_latency/${Str_gettimeofday_function_latency}/" $FILENAME
    sed -i "s/Data_page_alloc_latency/${Str_page_alloc_latency}/" $FILENAME
    sed -i "s/Data_write_copy_latency/${Str_write_copy_latency}/" $FILENAME
    sed -i "s/Data_ipi_latency/${Str_ipi_latency}/" $FILENAME
    sed -i "s/Data_cpu_timer_diff/${Str_cpu_timer_diff}/" $FILENAME
    sed -i "s/Data_cpu_occupy_error/${Str_cpu_occupy_error}/" $FILENAME
    sed -i "s/Data_ipi_per_sec/${Str_ipi_per_sec}/" $FILENAME

    #new cases for source consume
    sed -i "s/Data_cpu_occupy_no_load/${Str_cpu_occupy_no_load}/" $FILENAME
    sed -i "s/Data_memory_consume_no_load/${Str_memory_consume_no_load}/" $FILENAME
    
	
	#all for the testcase sleep accuracy
    sed -i "s/Data_sleeper_accuracy_nsleep_1_FIFO/${Str_sleeper_accuracy_nsleep_1_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_10_FIFO/${Str_sleeper_accuracy_nsleep_10_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_100_FIFO/${Str_sleeper_accuracy_nsleep_100_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_1000_FIFO/${Str_sleeper_accuracy_nsleep_1000_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_1_CFS/${Str_sleeper_accuracy_nsleep_1_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_10_CFS/${Str_sleeper_accuracy_nsleep_10_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_100_CFS/${Str_sleeper_accuracy_nsleep_100_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_nsleep_1000_CFS/${Str_sleeper_accuracy_nsleep_1000_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_1_FIFO/${Str_sleeper_accuracy_usleep_1_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_10_FIFO/${Str_sleeper_accuracy_usleep_10_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_100_FIFO/${Str_sleeper_accuracy_usleep_100_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_1000_FIFO/${Str_sleeper_accuracy_usleep_1000_FIFO}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_1_CFS/${Str_sleeper_accuracy_usleep_1_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_10_CFS/${Str_sleeper_accuracy_usleep_10_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_100_CFS/${Str_sleeper_accuracy_usleep_100_CFS}/" $FILENAME
    sed -i "s/Data_sleeper_accuracy_usleep_1000_CFS/${Str_sleeper_accuracy_usleep_1000_CFS}/" $FILENAME
	#end of sleep accuracy

	#for network cases
	sed -i "s/Data_protocol_stack_consumption_transmit_littlepackage/${Str_protocol_stack_consumption_transmit_littlepackage}/" $FILENAME
	sed -i "s/Data_protocol_stack_consumption_transmit_bigpackage/${Str_protocol_stack_consumption_transmit_bigpackage}/" $FILENAME
	return 0
}

do_performance_testsuite()
{
    getdata_performance_testsuite
    if [ $? -ne 0 ]
    then
        return 1
    fi
    fill_sheet_performance_testsuite
    if [ $? -ne 0 ]
    then
        return 1
    fi
    return 0
}

getdata_aim9()
{
    if [ ! -f $AIM9_RESULT ]
    then
        echo "$AIM9_RESULT doesn't exist"
        return 1
    fi
    grep "[[:digit:]] shared_memory.*Shared Memory Operations/second" $AIM9_RESULT > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Shared_memory data not found"
        return 1
    fi
    Str_share_memory_latency=`grep "[[:digit:]] shared_memory.*Shared Memory Operations/second" $AIM9_RESULT \
    | awk '{print $6}'`
    return 0
}

fill_sheet_aim9()
{
    if [ ! -f $AIM9_RESULT ]
    then
        echo "$AIM9_RESULT doesn't exist"
        return 1
    fi
    sed -i "s/Data_share_memory_latency/${Str_share_memory_latency}/" $FILENAME
    return 0
}

do_aim9()
{
    getdata_aim9   
    if [ $? -ne 0 ]
    then
        return 1
    fi
    fill_sheet_aim9
    if [ $? -ne 0 ]
    then
        return 1
    fi
    return 0
}

getdata_cyclibtest()
{
    if [ ! -f $CYCLIBTEST_RESULT ]
    then
        echo "$CYCLIBTEST_RESULT doesn't exist"
        return 1
    fi
    
    Str_timer_trig_latency=`cat $CYCLIBTEST_RESULT | grep "^timer_trig_latency" | awk -F ':' '{print $2}' \
    | tail -n 1 | sed "s/,/\\\\\\\\\&\#10/g"` 
    if [ $? -ne 0 ]
    then
        return 1
    fi
    Str_signal_latency=`cat $CYCLIBTEST_RESULT | grep "^signal_latency" | awk -F ':' '{print $2}' \
    | tail -n 1 | sed "s/,/\\\\\\\\\&\#10/g"` 
    if [ $? -ne 0 ]
    then
        return 1
    fi
    Str_sleep_wakeup_latency=`cat $CYCLIBTEST_RESULT | grep "^sleep_wakeup_latency" | awk -F ':' '{print $2}' \
    | tail -n 1 | sed "s/,/\\\\\\\\\&\#10/g"` 
    if [ $? -ne 0 ]
    then
        return 1
    fi
    return 0
}

fill_sheet_cyclibtest()
{
    if [ ! -f $CYCLIBTEST_RESULT ]
    then
        echo "$CYCLIBTEST_RESULT doesn't exist"
        return 1
    fi
    sed -i "s/Data_process_race_latency/${Str_process_race_latency}/" $FILENAME
    sed -i "s/Data_timer_trig_latency/${Str_timer_trig_latency}/" $FILENAME
    sed -i "s/Data_signal_latency/${Str_signal_latency}/" $FILENAME
    sed -i "s/Data_sleep_wakeup_latency/${Str_sleep_wakeup_latency}/" $FILENAME
    return 0
}

do_cyclibtest()
{
    getdata_cyclibtest
    if [ $? -ne 0 ]
    then
        return 1
    fi
    fill_sheet_cyclibtest
    if [ $? -ne 0 ]
    then
        return 1
    fi
    return 0
}

getdata_iozone3()
{
	local Str_add
	cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" > /dev/null
	if [ $? -eq 0 ]
	then
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $2}'`
		Str_little_file_throughput="${Str_add}k:"
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $3}'`
		Str_little_file_throughput="${Str_little_file_throughput} ${Str_add}\/"
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $4}'`
		Str_little_file_throughput="${Str_little_file_throughput}${Str_add} kbytes\/s\&\#10 "
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $5}'`
		Str_little_file_throughput="${Str_little_file_throughput}${Str_add}k:"
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $6}'`
		Str_little_file_throughput="${Str_little_file_throughput} ${Str_add}\/"
		Str_add=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $7}'`
		Str_little_file_throughput="${Str_little_file_throughput}${Str_add} kbytes\/s"
		Str_little_file_size=`cat $IOZONE_RESULT | grep -i "^little_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $8}'`
	fi

	cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" > /dev/null
	if [ $? -eq 0 ]
	then
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $2}'`
		Str_big_file_throughput="${Str_add}k:"
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $3}'`
		Str_big_file_throughput="${Str_big_file_throughput} ${Str_add}\/"
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $4}'`
		Str_big_file_throughput="${Str_big_file_throughput}${Str_add} kbytes\/s\&\#10 "
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $5}'`
		Str_big_file_throughput="${Str_big_file_throughput}${Str_add}k:"
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $6}'`
		Str_big_file_throughput="${Str_big_file_throughput} ${Str_add}\/"
		Str_add=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $7}'`
		Str_big_file_throughput="${Str_big_file_throughput}${Str_add} kbytes\/s"
		Str_big_file_size=`cat $IOZONE_RESULT | grep -i "^big_file_throughput[[:blank:]]" | tail -n 1 | awk '{print $8}'`
	fi
	return 0
}

fill_sheet_iozone3()
{
    sed -i "s/Data_little_file_size/${Str_little_file_size}/" $FILENAME
    sed -i "s/Data_big_file_size/${Str_big_file_size}/" $FILENAME
    sed -i "s/Data_little_file_throughput/${Str_little_file_throughput}/" $FILENAME
    sed -i "s/Data_big_file_size/${Str_big_file_throughput}/" $FILENAME
	return 0
}

do_iozone3()
{
    if [ ! -f $IOZONE_RESULT ]
    then
        echo "$IOZONE_RESULT doesn't exist"
        return 1
    fi
	
	getdata_iozone3
	if [ $? -ne 0 ]
	then
		return 1
	fi
	fill_sheet_iozone3
	if [ $? -ne 0 ]
	then
		return 1
	fi
	return 0
}

do_fill_sheet()
{
    RET_ALL=0
	
	if [ -f $LMBENCH_RESULT ]
	then
		do_lmbench
	    if [ $? -ne 0 ]
		then
	        echo "do_lmbench fail"
		    RET_ALL=`expr $RET_ALL '+' 1`
		fi
	fi

	if [ -f $PERFORMANCE_TESTSUITE_RESULT ]
	then
	    do_performance_testsuite
		if [ $? -ne 0 ]
	    then
		    echo "do_performance_testsuite fail"
	        RET_ALL=`expr $RET_ALL '+' 1`
		fi
	fi

	if [ -f $AIM9_RESULT ]
    then
		do_aim9
		if [ $? -ne 0 ]
		then
			echo "do_aim9 fail"
			RET_ALL=`expr $RET_ALL '+' 1`
		fi
	fi
	
    if [ -f $CYCLIBTEST_RESULT ]
	then
		do_cyclibtest
	    if [ $? -ne 0 ]
		then
			echo "do_cyclibtest fail"
			RET_ALL=`expr $RET_ALL '+' 1`
		fi
	fi

	if [ -f $IOZONE_RESULT ]
	then
		do_iozone3
		if [ $? -ne 0 ]
		then
			echo "do_iozone3 fail"
			RET_ALL=`expr $RET_ALL '+' 1`
		fi
	fi

    return $RET_ALL
}

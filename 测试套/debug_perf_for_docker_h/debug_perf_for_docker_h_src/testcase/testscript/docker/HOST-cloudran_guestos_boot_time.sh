#! /bin/bash 
 
cycle=$1 
ip=$2 
vm=$3
result_f=$(date +%Y%m%d%H%M%S)

ping_vm()
{
    ping -c 1 -w 1 $ip
    while [ $? -ne 0 ]
    do
        echo "."
        ping -c 1 -w 1 $ip
    done
}

run_one_cycle()
{
    virsh shutdown $vm
    sleep 20
    start=$(date +%s)
    virsh start $vm
    
    while [ $? -ne 0 ]
    do
        sleep 1
        start=$(date +%s)
        virsh start $vm
    done

    ping_vm

    end=$(date +%s)  
    total_time=$(( $end - $start ))  
    echo $total_time >> ./tst_rst_$vm$result_f
}

main()
{
    touch ./tst_rst_$vm$result_f
    for ((i=1; i<=$cycle; i++))
    do
        run_one_cycle
    done
}

main

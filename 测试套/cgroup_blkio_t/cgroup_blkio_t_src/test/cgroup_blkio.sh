#!/bin/bash
. lib_blkio_cg.sh

test_0()
{
mkdir /sys/fs/cgroup/blkio/test_tmp 2> /dev/null
rmdir /sys/fs/cgroup/blkio/test_tmp 2> /dev/null

    if [ -d /sys/fs/cgroup/blkio/test_tmp ];then
           echo "$1 failed" 
           return 1
    fi
    echo "$1 passed"
    return 0
}

#test_0 test_0


test_1()
{
  set +m
  reset_blkio

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1 &> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 22000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_1 test_1 

test_2()
{
  reset_blkio

  echo "253:4 10" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 0 -a $bytes -le 300 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_2 test_2


test_3()
{
  reset_blkio

  echo "253:4 10000000000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 200000000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_3 test_3


test_4()
{
  reset_blkio
  echo "253:4 1" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "253:4 9999999999" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "253:x4 10000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_4 test_4


test_5()
{
  reset_blkio

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=64k count=1000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 22000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_5 test_5 


test_6()
{
  reset_blkio

  echo "253:4 10" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  echo "253:4 10000000000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  if [ $bytes -ge 0 -a $bytes -le 300 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_6 test_6 


test_7()
{
  reset_blkio

  echo "253:4 10000000000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 200000000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_7 test_7 


test_8()
{
  reset_blkio
  echo "253:4 1" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "253:4 9999999999" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "253:x4 10000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_8 test_8 

test_9()
{
  reset_blkio

  echo "253:4 20" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=32k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 12000000 -a $bytes -le 14000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_9 test_9 

test_10()
{
  reset_blkio

  echo "253:4 1" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=32k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 600000 -a $bytes -le 700000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_10 test_10


test_11()
{
  reset_blkio

  echo "253:4 10000000000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 200000000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_11 test_11


test_12()
{
  reset_blkio
  echo "253:4 5" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "253:4 9999999999" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "253:x4 10000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_12 test_12


test_13()
{
  reset_blkio

  echo "253:4 20" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=64k count=1000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 18000000 -a $bytes -le 30000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_13 test_13


test_14()
{
  reset_blkio

  echo "253:4 1" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=16k count=2000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 300000 -a $bytes -le 400000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_14 test_14 


test_15()
{
  reset_blkio

  echo "253:4 10000000000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 200000000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_15 test_15 


test_16()
{
  reset_blkio
  echo "253:4 7" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "253:4 9999999999" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "253:x4 10000" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_16 test_16 



test_17()
{
  reset_blkio

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  echo "253:4 20" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 380000 -a $bytes -le 450000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_17 test_17 


test_18()
{
  reset_blkio

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  echo "253:4 200" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1 dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=32k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 18000000 -a $bytes -le 22000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_18 test_18 


test_19()
{
  reset_blkio

  echo "100" > /sys/fs/cgroup/blkio/test1/blkio.weight
  echo "500" > /sys/fs/cgroup/blkio/test2/blkio.weight
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/home/test oflag=direct bs=1M count=1000 1> /dev/null 2> /dev/null
  sync
  cgexec -g blkio:test1 dd if=/home/test of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1k count=2000000 &
  pid1=$!
  cgexec -g blkio:test2 dd if=/home/test of=/tmp/thin_sdb/thin2_sdb/test oflag=direct bs=1k count=2000000 &
  pid2=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  /bin/kill -SIGTERM $pid2  1> /dev/null 2> /dev/null
  bytes_1=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  bytes_2=`cat /sys/fs/cgroup/blkio/test2/blkio.throttle.io_service_bytes | grep "253:5 Write" | awk '{print $3}'` 
  if [ $bytes_2 -ge $bytes_1 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_19 test_19 


test_20()
{
  reset_blkio

  echo "100" > /sys/fs/cgroup/blkio/test1/blkio.weight
  echo "500" > /sys/fs/cgroup/blkio/test2/blkio.weight
  echo "100" > /sys/fs/cgroup/blkio/blkio.leaf_weight
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/home/test oflag=direct bs=1M count=1000 1> /dev/null 2> /dev/null
  sync
  cgexec -g blkio:test1 dd if=/home/test of=/tmp/thin_sdb/thin1_sdb/test_1 oflag=direct bs=1k count=2000000 &
  pid1=$!
  cgexec -g blkio:test2 dd if=/home/test of=/tmp/thin_sdb/thin1_sdb/test_2 oflag=direct bs=1k count=2000000 &
  pid2=$!
  cgexec -g blkio:/ dd if=/home/test of=/tmp/thin_sdb/thin1_sdb/test_3 oflag=direct bs=1k count=2000000 &
  pid3=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  /bin/kill -SIGTERM $pid2  1> /dev/null 2> /dev/null
  /bin/kill -SIGTERM $pid3  1> /dev/null 2> /dev/null
  bytes_1=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  bytes_2=`cat /sys/fs/cgroup/blkio/test2/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  bytes_3=`cat /sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes_2 -ge $bytes_1 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_20 test_20 



test_21()
{
  reset_blkio
  echo "10" > /sys/fs/cgroup/blkio/test1/blkio.weight
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "1000" > /sys/fs/cgroup/blkio/test1/blkio.weight
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "999999999" > /sys/fs/cgroup/blkio/test1/blkio.weight 2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "25x" > /sys/fs/cgroup/blkio/test1/blkio.weight  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_21 test_21 


test_22()
{
  reset_blkio
  echo "8:16 10" > /sys/fs/cgroup/blkio/test1/blkio.weight_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 1000" > /sys/fs/cgroup/blkio/test1/blkio.weight_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 999999999" > /sys/fs/cgroup/blkio/test1/blkio.weight_device 2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "8:16 x25x" > /sys/fs/cgroup/blkio/test1/blkio.weight_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 0" > /sys/fs/cgroup/blkio/test1/blkio.weight_device  2> /dev/null
   echo "$1 passed"
   return 0
}

#test_22 test_22 


test_23()
{
  reset_blkio
  echo "10" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "1000" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "999999999" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight 2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "25x" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

   echo "$1 passed"
   return 0
}

#test_23 test_23 


test_24()
{
  reset_blkio
  echo "8:16 10" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 1000" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight_device
  if [ $? -eq 1 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 999999999" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight_device 2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi


  echo "8:16 x25x" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight_device  2> /dev/null
  if [ $? -eq 0 ] ; then
    echo "$1 failed"
    return 1
  fi

  echo "8:16 0" > /sys/fs/cgroup/blkio/test1/blkio.leaf_weight_device  2> /dev/null
   echo "$1 passed"
   return 0
}

#test_24 test_24 

test_25()
{
  reset_blkio

  echo 1 > /sys/fs/cgroup/blkio/test1/test1_child/blkio.reset_stats
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  echo "500" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.weight

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  echo "253:4 2097152" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  cgexec -g blkio:test1/test1_child dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=64k count=100000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 20000000 -a $bytes -le 22000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_25 test_25 

test_26()
{
  reset_blkio

  echo 1 > /sys/fs/cgroup/blkio/test1/test1_child/blkio.reset_stats
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  echo "500" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.weight

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  echo "253:4 524688" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches
  
  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test  oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1/test1_child dd  if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=64k count=100000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 10000000 -a $bytes -le 12000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_26 test_26


test_27()
{
  reset_blkio

  echo 1 > /sys/fs/cgroup/blkio/test1/test1_child/blkio.reset_stats
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  echo "500" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.weight

  echo "253:4 50" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_iops_device
  echo "253:4 100" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches
 
  sleep 10
  cgexec -g blkio:test1/test1_child dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=4k count=1000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.io_service_bytes | grep "253:4 Write" | awk '{print $3}'` 
  if [ $bytes -ge 3500000 -a $bytes -le 6000000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_27 test_27 

test_28()
{
  reset_blkio

  echo 1 > /sys/fs/cgroup/blkio/test1/test1_child/blkio.reset_stats
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  echo "500" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.weight

  echo "253:4 100" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  echo "253:4 50" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  sync
  echo 3 > /proc/sys/vm/drop_caches
  
  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test  oflag=direct bs=1M count=1000 1> /dev/null 2> /dev/null
  sync
  sleep 1
  cgexec -g blkio:test1/test1_child dd  if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=100000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 800000 -a $bytes -le 1200000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_28 test_28


test_29()
{
  reset_blkio

  echo 1 > /sys/fs/cgroup/blkio/test1/test1_child/blkio.reset_stats
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_bps_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 0 " > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.write_iops_device
  echo "500" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.weight

  echo "253:4 100" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_iops_device
  echo "253:4 50" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_iops_device
  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  echo "253:4 524688" > /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches
  
  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test  oflag=direct bs=1M count=1000 1> /dev/null 2> /dev/null
  sync
  sleep 1
  cgexec -g blkio:test1/test1_child dd  if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=100000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/test1_child/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
  if [ $bytes -ge 800000 -a $bytes -le 1200000 ] ; then
    echo "$1 passed"
    return 0
  fi

   echo "$1 failed"
   return 1
}

#test_29 test_29


test_30()
{
  reset_blkio

  echo "253:4 1048576" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

  dd if=/dev/zero of=/tmp/thin_sdb/thin1_sdb/test oflag=direct bs=1M count=2000 1> /dev/null 2> /dev/null
  cgexec -g blkio:test1 dd if=/tmp/thin_sdb/thin1_sdb/test of=/home/test iflag=direct bs=1k count=2000000 &
  pid1=$!
  sleep 20
  /bin/kill -SIGTERM $pid1  1> /dev/null 2> /dev/null
  bytes=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_service_bytes | grep "253:4 Read" | awk '{print $3}'` 
   if [ $bytes -ge 20000000 -a $bytes -le 22000000 ] ; then
     bytes_1=`cat /sys/fs/cgroup/blkio/test1/blkio.throttle.io_serviced | grep "253:4 Read" | awk '{print $3}'` 
      if [ $bytes_1 -ge 20000 -a $bytes_1 -le 22000 ] ; then
       echo "$1 passed"
       return 0
   fi
  fi

   echo "$1 failed"
   return 1
}

 bw_B=0

check_fio_result()
{
  bw_B=0
  bw=`cat log | grep "bw=" | awk -F ',' '{print $2}' | sed 's/^.*=//g' | sed 's/[0-9.]//g'`
 
  if [ "$bw" = "MB/s" ] ;then
   bw_MB=`cat log | grep "bw=" | awk -F ',' '{print $2}' | sed 's/^.*=//g' | sed 's/[KM]B.*$//g' | awk -F '.' '{print $1}'`  
   bw_B=`expr $bw_MB \* 1024\*1024`
   return 0 
  elif [ "$bw" = "KB/s" ] ;then 
   bw_KB=`cat log | grep "bw=" | awk -F ',' '{print $2}' | sed 's/^.*=//g' | sed 's/[KM]B.*$//g' | awk -F '.' '{print $1}'`  
   bw_B=`expr $bw_KB \* 1024`
   return 0 
  fi
  bw_B=`cat log | grep "bw=" | awk -F ',' '{print $2}' | sed 's/^.*=//g' | sed 's/[KM]B.*$//g' | sed 's/B.*$//g'| awk -F '.' '{print $1}'`
}

test_31()
{
  reset_blkio

  echo "253:4 2097152" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

   rm -rf /tmp/thin_sdb/thin1_sdb/test*
   rm -rf /tmp/thin_sdb/thin1_sdb/mytest*
   cgexec -g blkio:test1  fio --directory=/tmp/thin_sdb/thin1_sdb/ -direct=1 -iodepth 1 -thread -rw=read -ioengine=sync -bs=16k -size=100M -numjobs=10 -runtime=100 -group_reporting -name=mytest-read > log
   check_fio_result 
   bytes_1=$bw_B

   if [ $bytes_1 -ge 1800000 -a $bytes_1 -le 2200000 ] ; then
       echo "$1 passed"
       return 0
   fi

   echo "$1 failed"
   return 1
}
#test_31 test_31


test_32()
{
  reset_blkio

  echo "253:4 2097152" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

   rm -rf /tmp/thin_sdb/thin1_sdb/mytest*
   cgexec -g blkio:test1  fio --directory=/tmp/thin_sdb/thin1_sdb/ -direct=1 -iodepth 1 -thread -rw=write -ioengine=sync -bs=16k -size=100M -numjobs=10 -runtime=100 -group_reporting -name=mytest-write > log
   check_fio_result 
   bytes_1=$bw_B

   if [ $bytes_1 -ge 1800000 -a $bytes_1 -le 2200000 ] ; then
       echo "$1 passed"
       return 0
   fi

   echo "$1 failed"
   return 1
}
#test_32 test_32


test_33()
{
  reset_blkio

  echo "253:4 2097152" > /sys/fs/cgroup/blkio/test1/blkio.throttle.read_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

   rm -rf /tmp/thin_sdb/thin1_sdb/mytest*
   cgexec -g blkio:test1  fio --directory=/tmp/thin_sdb/thin1_sdb/ -direct=1 -iodepth 1 -thread -rw=randread -ioengine=sync -bs=16k -size=100M -numjobs=10 -runtime=100 -group_reporting -name=mytest-read > log
   check_fio_result 
   bytes_1=$bw_B

   if [ $bytes_1 -ge 1800000 -a $bytes_1 -le 2500000 ] ; then
       echo "$1 passed"
       return 0
   fi

   echo "$1 failed"
   return 1
}
#test_33 test_33


test_34()
{
  reset_blkio

  echo "253:4 2097152" > /sys/fs/cgroup/blkio/test1/blkio.throttle.write_bps_device
  sync
  echo 3 > /proc/sys/vm/drop_caches

   rm -rf /tmp/thin_sdb/thin1_sdb/mytest*
   cgexec -g blkio:test1  fio --directory=/tmp/thin_sdb/thin1_sdb/ -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=sync -bs=16k -size=100M -numjobs=10 -runtime=100 -group_reporting -name=mytest-write > log
   check_fio_result 
   bytes_1=$bw_B

   if [ $bytes_1 -ge 18000 -a $bytes_1 -le 2500000 ] ; then
       echo "$1 passed"
       return 0
   fi

   echo "$1 failed"
   return 1
}
#test_34 test_34

check_env
if [ $? -ne 0 ];then
   echo "thin pool env not ready.."
   exit 1
fi
ret=0
for((i=0;i<=34;i++));
do
  sleep 10
  "test_"${i}"" "test_"${i}"" 
   ret=$((ret+$?))
  rm -rf /tmp/thin_sdb/thin1_sdb/test*
  rm -rf /tmp/thin_sdb/thin1_sdb/mytest*
  rm -rf log
done
exit $ret





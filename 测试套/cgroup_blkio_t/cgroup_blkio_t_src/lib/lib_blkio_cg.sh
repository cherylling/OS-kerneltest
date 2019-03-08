#!/bin/bash

check_kernel_version()
{
  version=`uname -a | awk '{print $3}' | awk -F '-' '{print $1}'`
  if [ "$version" != "3.10.0" ] ;then
    return 1
  fi
  return 0
}

check_cgroup_blkio()
{
  blkio=`mount | grep blkio | awk '{print $3}'`
  if [ "$blkio" != "/sys/fs/cgroup/blkio" ] ;then
      return 1
  fi
  return 0
}

check_sdb()
{
  sdb=`mount | grep sdb | wc -l`
  if [ "$sdb" != "0" ] ;then
      return 1
  fi
  return 0
}


check_sdb_partition()
{
  sdb1=`fdisk -l /dev/sdb | grep sdb1 | awk '{print $4}'`
  sdb2=`fdisk -l /dev/sdb | grep sdb2 | awk '{print $4}'`
  size=3145728
  if [[ $sdb1 -ge $size ]] ;then
      
       if [[ $sdb2 -ge $size ]] ;then
        return 0
       fi
  fi
  return 1
}


creat_thin_device()
{
  dmsetup create thin_pool_sdb --table '0 6291456 thin-pool /dev/sdb1  /dev/sdb2 128 65536 1 skip_block_zeroing'
  dmsetup message /dev/mapper/thin_pool_sdb 0 "create_thin 0"
  dmsetup create thin1_sdb --table "0 6291456 thin /dev/mapper/thin_pool_sdb 0"
  dmsetup message /dev/mapper/thin_pool_sdb 0 "create_thin 1"
  dmsetup create thin2_sdb --table "0 6291456 thin /dev/mapper/thin_pool_sdb 1"
  mkfs.ext4 /dev/mapper/thin1_sdb
  mkfs.ext4 /dev/mapper/thin2_sdb
  mkdir -p /tmp/thin_sdb/thin1_sdb
  mkdir -p /tmp/thin_sdb/thin2_sdb
  mount /dev/mapper/thin1_sdb /tmp/thin_sdb/thin1_sdb
  mount /dev/mapper/thin2_sdb /tmp/thin_sdb/thin2_sdb
}

check_tool_fio()
{
  fio --help
  if [ $? -ne 0 ] ;then
    return 1
  fi
 return 0
}

########################################################################################################
setup_env()
{
    check_kernel_version
    if [ $? -eq 1 ]; then
            echo "test must be run with kernel 3.10.0; skipping testcases"
            exit 0
    elif [ ! -f /proc/cgroups ]; then
            echo "Kernel does not support for control groups; skipping testcases";
            exit 0
    elif [ "x$(id -ru)" != x0 ]; then
            echo "Test must be run as root; skipping testcases"
            exit 0
    fi
    
    
    check_cgroup_blkio
    if [ $? -eq 1 ]; then
           echo "cgroup must be mount on /sys/fs/cgroup/blkio; skipping testcases"
           exit 0
    fi
    
    
    check_sdb
    if [ $? -eq 1 ]; then
           echo "testcase work on sdb,sdb busy now,please check; skipping testcases"
           exit 0
    fi
    
    
    check_sdb_partition
    if [ $? -eq 1 ]; then
           echo "sdb need 2 primary partition, size > 3G, please use fdisk manually part the /dev/sdb"
           echo "skipping testcases"
           exit 0
    fi
    
    check_tool_fio
    if [ $? -eq 1 ]; then
           echo "please install fio; skipping testcases"
           exit 0
    fi
    creat_thin_device
}


check_env()
{
  thin1=`mount | grep thin1 | awk -F '(' '{print $1}'`
  if [ "$thin1" != "/dev/mapper/thin1_sdb on /tmp/thin_sdb/thin1_sdb type ext4 " ] ;then
      return 1
  fi
  thin2=`mount | grep thin2 | awk -F '(' '{print $1}'`
  if [ "$thin2" != "/dev/mapper/thin2_sdb on /tmp/thin_sdb/thin2_sdb type ext4 " ] ;then
      return 1
  fi

  return 0
}


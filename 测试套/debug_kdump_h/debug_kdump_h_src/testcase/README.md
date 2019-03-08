---
title: Kdump/Kexec test
---

## Kdump test steps
- precondition
modify dts and testcase(trigger panic in lpi and spi)
patch "0001-arm64-kdump-add-trigger-panic-in-sgi-testcase.patch" (trigger panic in sgi)

- kexec -p 
- trigger panic or oops
echo c > /proc/sysrq-trigger 
or insmod xxx.ko

- reboot to second kernel and dump, use makedumpfile

## Kexec test steps
- kexec -l
- kexec -e, reboot to second kernel

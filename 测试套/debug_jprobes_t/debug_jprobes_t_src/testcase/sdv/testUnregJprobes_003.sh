#!/bin/bash

. conf.sh

KO=testUnregJprobes_003.ko

set_up
insmod_success $KO || exit 1

rmmod_ko $KO || exit 1

exit 0

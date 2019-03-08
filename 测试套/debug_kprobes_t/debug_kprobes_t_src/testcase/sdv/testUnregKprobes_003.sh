#!/bin/bash

. conf.sh

KO=testUnregKprobes_003.ko

insmod_success $KO || exit 1

rmmod_ko $KO || exit 1

exit 0

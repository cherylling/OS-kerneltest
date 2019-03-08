#!/bin/bash
pid=$2
perf record -e mem:$1:r8 -f -p $pid
perf report

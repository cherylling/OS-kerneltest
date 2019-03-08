#!/bin/bash
pid=$2
perf record -e mem:$1:w8 -f -p $pid
perf report

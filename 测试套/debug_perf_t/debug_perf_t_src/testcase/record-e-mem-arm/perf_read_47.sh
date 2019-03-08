#!/bin/bash
pid=$2
perf record -e mem:$1:r -f -p $pid
perf report

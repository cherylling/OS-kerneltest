/*#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_while_1.c
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon:
##- @Brief:
##- @Detail: 1.set a random cpu
#            2.do while print
##- @Expect:
##- @Level:
##- @Auto:
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include "opt_perf_t_test.h"

#define TMPFILE "common_while_1.oncpu"

static int s_cnt1, s_cnt2;

void hotspot_2() {
    int i;
    for(i = 0; i<=100; i++) {
        s_cnt2++;
    }
}

void hotspot_1() {
    int i;
    while(1) {
        hotspot_2();
        for(i = 0; i<=100; i++) {
            s_cnt1++;
        }
    };
}
int main()
{
    int cpus = sysconf(_SC_NPROCESSORS_CONF);
    int oncpu;
    FILE *fp;

    srand((unsigned)time(NULL));
    oncpu = rand()%cpus;
    set_cpu(oncpu);

    fp = fopen(TMPFILE, "w");
    if (fp < 0) {
        printf("TFAIL : cannot open file!\n");
        return 0;
    }
    fprintf(fp, "%d", oncpu);
    fclose(fp);

    hotspot_1();
    printf("common_while_1: s_cnt1=%d, s_cnt2=%d\n", s_cnt1, s_cnt2);

    return 0;
}

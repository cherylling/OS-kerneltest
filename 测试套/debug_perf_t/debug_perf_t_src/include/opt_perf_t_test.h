/*********************************************************************
 @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
 @File name: opt_perf_t_test.h
 @Author1:star<yexinxin@huawei.com> ID:00197803
 @Date: 2013-04-16
 @Description: library for testcases
*********************************************************************/

/*********************************************************************
 include files, definitions, global variates here
*********************************************************************/
#define SAFE_FREE(p) { if (p) { free(p); (p)=NULL; } }
#define BUFFER 256
int set_cpu (int cpu);

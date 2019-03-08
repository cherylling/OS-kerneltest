/*######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: common_record-e-mem_1.c
##- @Author: y00197803
##- @Date: 2013-5-03
##- @Brief: 
##- @Detail: 提供数据断点被监控的程序，构造各种场景
##- @Modify:
#######################################################################*/
#include <stdio.h>
#include <stdlib.h>

#define DEF_VAL_INT 5
#define W_VAL_INT 9
#define DEF_VAL_CHAR 'a'
#define W_VAL_CHAR 'A'
#define INT_SIZE 4
#define SHORT_SIZE 2
#define LL_SIZE 8

#ifndef __GNUC__
    #define __attribute__(x) /* NOTHING */
#endif

#ifdef __aarch64__
#define DEFINE_PREFIX	__attribute__ ((aligned (8)))
#else
#define DEFINE_PREFIX
#endif

DEFINE_PREFIX static int read_only = DEF_VAL_INT;
DEFINE_PREFIX static int write_only = DEF_VAL_INT;
DEFINE_PREFIX static int write_same = DEF_VAL_INT;
DEFINE_PREFIX static int nothing __attribute__((unused)) = DEF_VAL_INT;
DEFINE_PREFIX static int read_write = DEF_VAL_INT;
static char char_rw[LL_SIZE] = {DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR, DEF_VAL_CHAR};

static signed char bound1[INT_SIZE] = {0};
static short int bound2[SHORT_SIZE] = {0};
static int bound4 = 0;

static unsigned char u_bound1[INT_SIZE] = {0};
static unsigned short u_bound2[SHORT_SIZE] = {0};
static unsigned int u_bound4 = 0;

static signed char max1 = 127;
static short max2 = 32767;
static int max4 = 2147483647;

static unsigned char u_max1 = 0xff;
static unsigned short u_max2 = 0xffff;
static unsigned int u_max4 = 0xffffffff;

void func_unused(void) __attribute__((unused));

/*######################################################################
##- @Description: do write the "write_only, write_same, read_write" for
##-               perf record -e mem:0xaddr:w
######################################################################*/
void func_do_write(void)
{
    write_only = W_VAL_INT;
    write_same = DEF_VAL_INT;
    read_write = W_VAL_INT;
}

/*######################################################################
##- @Description: do read the "read_only, read_write" for
##-               perf record -e mem:0xaddr:r
######################################################################*/
void func_do_read(void)
{
    int do_read __attribute__((unused));
    do_read = read_only;
    do_read = read_write;
}

/*######################################################################
##- @Description: for perf record -e mem:0xaddr:x
######################################################################*/
void func_unused(void)
{
}

/*######################################################################
##- @Description: do read and write char_rw[i]
######################################################################*/
void func_wr(int rwi)
{
    if (rwi >= LL_SIZE){
        printf("TFAIL: $1 is error!\n");
        exit(1);
    }
    char do_read __attribute__((unused));
    char_rw[rwi] = W_VAL_CHAR;
    do_read = char_rw[rwi];
}

/*######################################################################
##- @Description: do read and write bound1,bound2,bound4,u_bound4,for
##-               perf record -e mem:0xaddr:r -k "boundary"
######################################################################*/
void func_bound_wr(int which_bound, int g_e_l_bound)
{
    if (which_bound == 0){
        switch (g_e_l_bound){
            case -1:
                bound1[0] = -max1 - 2;
                bound2[0] = -max2 - 2;
                bound4 = -max4 - 2;
                u_bound1[0] = 0 - 1;
                u_bound2[0] = 0 - 1;
                u_bound4 = 0 - 1;
                break;
            case 0:
                bound1[0] = -max1 - 1;
                bound2[0] = -max2 - 1;
                bound4 = -max4 - 1;
                u_bound1[0] = 0;
                u_bound2[0] = 0;
                u_bound4 = 0;
                break;
            case 1:
                bound1[0] = -max1;
                bound2[0] = -max2;
                bound4 = -max4;
                u_bound1[0] = 1;
                u_bound2[0] = 1;
                u_bound4 = 1;
                break;
            default:
                break;
        }
    } else {
        switch (g_e_l_bound){
            case -1:
                bound1[0] = max1 - 1;
                bound2[0] = max2 - 1;
                bound4 = max4 - 1;
                u_bound1[0] = u_max1 - 1;
                u_bound2[0] = u_max2 - 1;
                u_bound4 = u_max4 - 1;
                break;
            case 0:
                bound1[0] = max1;
                bound2[0] = max2;
                bound4 = max4;
                u_bound1[0] = u_max1;
                u_bound2[0] = u_max2;
                u_bound4 = u_max4;
                break;
            case 1:
                bound1[0] = max1 + 1;
                bound2[0] = max2 + 1;
                bound4 = max4 + 1;
                u_bound1[0] = u_max1 + 1;
                u_bound2[0] = u_max2 + 1;
                u_bound4 = u_max4 + 1;
                break;
            default:
                break;
        }
    }
    bound1[0] = bound1[0];
    bound2[0] = bound2[0];
    bound4 = bound4;
    u_bound1[0] = u_bound1[0];
    u_bound2[0] = u_bound2[0];
    u_bound4 = u_bound4;
}

void func_write_file_address()
{
    FILE *file;

    file = fopen("usr_gvar_addr.tmp", "w+");
    fprintf(file, "%p\n", &read_only);
    fprintf(file, "%p\n", &write_only);
    fprintf(file, "%p\n", &write_same);
    fprintf(file, "%p\n", &nothing);
    fprintf(file, "%p\n", &read_write);
    fprintf(file, "%p\n", func_unused);
    fprintf(file, "%p\n", func_do_write);
    fclose(file);
    sleep(2);
}

int main(int argc, char**argv)
{
    int rw_byte, which_bound, g_e_l_bound;

    func_write_file_address();

    switch (argc) {
        case 1:
            printf("TINFO: normal read write\n");
            func_do_read();
            func_do_write();
            break;
        case 2:
            printf("TINFO: char_rw\n");
            rw_byte = atoi(argv[1]);
            func_wr(rw_byte - 1);
            break;
        case 3:
            printf("TINFO: bound test\n");
            which_bound = atoi(argv[1]);
            g_e_l_bound = atoi(argv[2]);
            func_bound_wr(which_bound, g_e_l_bound);
            break;
        default:
            printf("TFAIL: wrong use\n");
            break;
    }
    return 0;
}

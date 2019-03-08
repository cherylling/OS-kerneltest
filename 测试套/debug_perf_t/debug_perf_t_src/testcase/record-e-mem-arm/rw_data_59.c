#include<stdio.h>
#include<stdlib.h>

static int write_data=1;
static char write_char2=2;
static char write_char3=3;
static char write_char4=4;
static char write_char5=5;
int func(int n)
{
    int planck=1;
    if(n>1)
    {
        return func(n-1)+planck;
    }
    else if(n==1)
    {
        planck=write_char3;
        write_char3=3;
        return 1;
    }
}


int write_test_1(void)
{
    int write_1;
   return func(1);
}
int write_test_2(void)
{
    int write_2;
    return write_test_1();
}
int write_test_3(void)
{
   int write_3;
   return write_test_2();
}
int write_test_4(void)
{
    int write_4;
    return write_test_3();
}

int main(int argc,char **argv)
{
    int arg=0;
    int ret=0;
    if(2!=argc)
    {
        printf("please input tow param\n");
        return -1;
    }
    arg=atoi(argv[1]);
    //ret=func(arg);
    ret=write_test_4();
    printf("THE func exce return is %d\n",ret);
    return 0;
}

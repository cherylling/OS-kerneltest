#include<stdio.h>
#include<stdlib.h>
#include<string.h>

static int write_data1=1;
static int write_data2=2;
static char write_char3=1;
static char write_char4=4;
static char write_char5=5;
static char write_char6=6;
static char *p=NULL;

int func(int n)
{
    int planck_data=1;
    p=malloc(8);
    memset(p,'a',7);
    *(p+7)='\0';
    printf("%p\n",p);
    sleep(30);
    if(n>1)
    {
        return func(n-1)+1;
    }
    else if(n==1)
    {
        *(p+5)=1;
        return 1;
    }
}


int write_test_1(void)
{
    int read_1;
   return func(1);
}
int write_test_2(void)
{
    int read_2;
    return write_test_1();
}
int write_test_3(void)
{
   int read_3;
   return write_test_2();
}
int write_test_4(void)
{
    int read_4;
    return write_test_3();
}

int main(int argc,char **argv)
{
    int arg=0;
    int ret=0;
    arg=atoi(argv[1]);
    //ret=func(arg);
    ret=write_test_4();
    printf("THE func exce return is %d\n",ret);
    return 0;
}

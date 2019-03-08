/* Test accessing TLS based variable without any debug info compiled.  */

#include <pthread.h>
#include <stdio.h>
__thread int thread_local = 42;

int main(void)
{
    printf("thread:%d\n",thread_local);
    return 0;
}

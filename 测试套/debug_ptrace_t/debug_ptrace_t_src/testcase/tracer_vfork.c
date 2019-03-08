#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main()
{
    printf("gofork\n");
    pid_t child = vfork();
    printf("vfork\n");
    if (child) {
        printf("create a child %d\n", child);
        exit(0);
    }
    else
    {
        printf("I'm a child\n");
        sleep(1);
        exit(0);
    }
 //   int i = 0;
//    for(i=0; i<2; i++)
  //      sleep(1);
    //return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>


int  global_i = 100;

#ifdef PROTOTYPES
int main (void)
#else
main ()
#endif
{
  int  local_j = global_i+1;
  int  local_k = local_j+1;

  printf ("foll-exec is about to execlp(execd-prog)...\n");

  execlp ("./execd-prog",
          "./execd-prog",
          "execlp arg1 from foll-exec",
          (char *)0);

  printf ("foll-exec is about to execl(execd-prog)...\n");

  execl ("./execd-prog",
         "./execd-prog",
         "execl arg1 from foll-exec",
         "execl arg2 from foll-exec",
         (char *)0);

  {
    static char * argv[] = {
      (char *)"./execd-prog",
      (char *)"execv arg1 from foll-exec",
      (char *)0};

    printf ("foll-exec is about to execv(execd-prog)...\n");

    execv ("./execd-prog", argv);
  }
}

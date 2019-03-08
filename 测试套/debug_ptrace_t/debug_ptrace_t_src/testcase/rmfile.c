#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
//   system("touch fiss");
//   system("ls /");
//   unlink("fiss");
//  system("ls /");
    execl("/bin/ls", "ls", "/", NULL);
    return 0;
}

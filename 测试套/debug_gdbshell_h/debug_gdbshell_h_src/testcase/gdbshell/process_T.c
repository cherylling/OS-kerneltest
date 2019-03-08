#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    char str_name[32];
    memset(str_name, 0, 32);
    printf("Please input your name\n");
    scanf("%s", &str_name);
    printf("%s\n", str_name);
    return 0;
}

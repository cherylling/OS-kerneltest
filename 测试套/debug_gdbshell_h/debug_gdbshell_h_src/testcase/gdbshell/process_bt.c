#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

void ninth_floor_func()
{
    sleep(1000);
    return ;
}

void eighth_floor_func()
{
    ninth_floor_func();
    return ;
}
void seventh_floor_func()
{
    eighth_floor_func();
    return ;
}
void sixth_floor_func()
{
    seventh_floor_func();
    return ;
}
void fifthly_floor_func()
{
    sixth_floor_func();
    return ;
}
void fourthly_floor_func()
{
    fifthly_floor_func();
    return ;
}
void third_floor_func()
{
    fourthly_floor_func();
    return ;
}

void second_floor_func()
{
    third_floor_func();
    return ;
}

int first_floor_func()
{
    second_floor_func();
    return 0;
}

static void *thread_f9() 
{
    sleep(2);
    first_floor_func();
    exit(0);
}


int main (int argc, char** argv)
{
    thread_f9();
    return 0;
}


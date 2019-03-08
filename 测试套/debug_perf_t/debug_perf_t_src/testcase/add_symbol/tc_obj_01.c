#include "tc_obj.h"

int func_a(int a){
    return ++a;
}

int func_b(int b){
    int var_b[1000] = {0};
    int i;
    for(i=0; i<1000; i++){
       var_b[i]++;
    }

    return (b-1);
}

int func_c(int c){
    return (2*c);
}
int wrap_calc(){
    char *str="hello,world\n";
    int i=0;
    while(1){
        i=func_a(i);
        i=func_b(i);
        i=func_c(i);
    }
    return 0;
}

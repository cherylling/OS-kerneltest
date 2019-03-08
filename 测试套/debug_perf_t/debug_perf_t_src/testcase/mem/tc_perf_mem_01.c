
void longa(){

    int i,j;
    for(i=0; i < 100000; i++)
    {
        j=i;
        i=0;
        i=j;
        j=0;
    }
}

void foo2(){
    int i;
    for (i=0; i<100; i++)
        longa();
}

void foo1(){
    int i;
    for (i=0; i<1000; i++)
        longa();
}


int main(){
    foo1();
	foo2();
    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAX_COUNT 4096
#define TESTFILE "testfile"
int get_filescg(char* path)
{
	FILE* stream;
	int ret;
	stream = fopen(path,"r");
	if(stream == NULL) {
		printf("fopen failed: %s\n",path);
		return -1;
	} 
	fscanf(stream,"%d",ret);
	fclose(stream);
	return ret;
}
int set_filescg(char* path, int value)
{
	FILE* stream;
	int ret;
	stream = fopen(path,"w"); 
	if(stream == NULL) {
		printf("fopen failed: %s\n",path);
		return -1;
	}      
	ret = fprintf(stream,"%d",value);
	fclose(stream);
	return ret;
}
//input:open count; flag(0->smae file;1->different files)
int main(int argc ,char** argv)
{
	int fd[MAX_COUNT];
	int i, count, flag, ret =0;
	char path[128] = {'\0'};
	if (argc <= 1 ){
		count = 1;
		flag = 0;
	} else if (argc == 3){
		count = atoi(argv[1]);//unsafe
		flag  = atoi(argv[2]);//unsafe
	}
	if(count > MAX_COUNT) {
		printf("over MAX_COUNT:%d\n",count);
		return -1;
	}
	sleep(10);//NOTE
         //open fds	
	for( i=0; i<count ; i++ ) {
                if(flag == 0) {
    		     fd[i] = open(TESTFILE, O_RDWR|O_CREAT);
		} else if (flag == 1 )
		{
                      sprintf(path, TESTFILE"%d", i);
                      fd[i] = open(path,O_RDWR|O_CREAT);
		}
	}
	sleep(10);//NOTE
	//close fds
	for( i=0; i<count ; i++ ) {
		if (fd[i] <= 0 ){
	//		printf("%d open failed\n", i);
			ret = -1;
		} else {
			close(fd[i]);
		}

	}
	if(flag == 0) {
		remove(TESTFILE);
	} else if(flag == 1) {
		for( i=0; i<count ; i++ ) {
			sprintf(path, TESTFILE"%d", i);
			remove(path);
		}
	}
	
	return ret;
}

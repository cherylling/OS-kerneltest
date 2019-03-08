#include<stdio.h>
#include <unistd.h>
#include<string.h>


char is_num1(char *p);
char is_rouding(char *p);
char is_trapped(char *p);
char is_string(char *p);

/*
char strcmp_s(char **p,char *str,int n)
{
        int i;
        for(i=0;i<n;i++)
                if(strcmp(*(p+i),str)==0)
                return 0;
               
                return -1;
}
*/


int is_validity_float_testcase(const char *srcstr)
{
	char buf[256],buf1[5]={0,0,0,0,0};//buf2[256],buf3[256],buf4[256];
	unsigned char i=0,j=0,n=0;//cflag_3=0,cflag_4=0;
	char *addr1=NULL;
	char *srcs;
	char *addr[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,};
	char *test="->";
	char must=0,yes_must=0,zfc=0;
	memset(buf,0,256);
	strcpy(buf,srcstr);
//	printf("%s\n",buf);
	n=strlen(srcstr);
	for(i=0;i<n;i++)
		if(buf[i]==' ')
		{
		buf[i]='\0';
		addr[j]=&buf[i+1];//printf("%s\n",addr[0]);
		j++;
		}
//	for(i=0;i<j;i++)
//		printf("%s\n",addr[i]);
//	printf("%s\n",buf);
	for(i=0;i<j;i++)
		if(strcmp(test,addr[i])==0)
		{
		must=i;
		yes_must=1;
		break;
		}
	if(yes_must==0)//check "->"
		return -1;
	if(is_num1(buf)!=0)//check it  for example "b32*+"
		return -1;
//	printf("this is round %d\n",is_rouding(addr[0]));
	if(is_rouding(addr[0])!=0) //check rouding
		return -1;
//	printf("trapped is %d\n",is_trapped(addr[1]));
	if(is_trapped(addr[1])!=0) //check trapped
		{
		if(is_string(addr[1])!=0)
		return -1;
		zfc=1;
		}
	zfc=must+zfc;
	zfc=zfc-2;
//	printf("zfc %d\n",zfc);
	if(zfc>8) //check string no bigger than 8
		return -1;
	for(i=2;i<must;i++)
	
	{//	printf("string is %d\n",is_string(addr[i]));
		if(is_string(addr[i])!=0) //check is string or not
		return -1;}
//	printf("stringmust+1 is %d\n",is_string(addr[must+1]));
	if(is_string(addr[must+1])!=0)
		return -1;
//	printf("the j-must-2 is %d\n",(j-must-2));
//	if((j-must-2)!=1)
//		return -1;
	if((must+1)<(j-1))
		if(is_trapped(addr[j-1])!=0)
		return -1;
	return 0;
}



char is_num1(char *p)
{	char i=0;
	char *addr1=NULL;
	char buf1[15];
	memset(buf1,0,15);
	//strcpy(buf1,p);
//	printf("%s\n",p);
	for(i=0;i<3;i++)
		buf1[i]=p[i];
		buf1[3]='\0';
	for(i=0;i<4;i++)
		if(strcmp(basic_set[i],buf1)==0)
	{	addr1=&p[3];
		for(i=0;i<39;i++)
			if(strcmp(addr1,operations_set[i])==0)
		return 0;
	}
	
	 for(i=0;i<4;i++)
                buf1[i]=p[i];
                buf1[4]='\0';
        for(i=3;i<6;i++)
                if(strcmp(basic_set[i],buf1)==0)
        {       addr1=&p[4];
                for(i=0;i<39;i++)
                        if(strcmp(addr1,operations_set[i])==0)
                return 0;
        }
	return -1;

}


char is_rouding(char *p)
{	
	char i=0;
	for(i=0;i<5;i++)
	if(strcmp(rounding_set[i],p)==0)
	return 0;
	return -1;
}


char is_trapped(char *p)
{
	char i=0;
        for(i=0;i<5;i++)
        if(strcmp(trapped_set[i],p)==0)
        return 0;
        return -1;

}


char is_string(char *p)
{
	char buf[]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','A','B','C','D','E','F'};
	char begin[]={'+','-'};
	char n=0,i=0,dian=0,pp=0,x,j=0,k=0,aa=0;
	n=strlen(p);
	//for(i=0;i<n;i++)
	//if(i=0)
//	printf("strint is %s\n",p);
//	printf("p[0]!= is %d\n",(p[0]!='-'&&p[0]!='+'));
	if(p[0]!='-'&&p[0]!='+')
	return -1;
	
	for(i=1;i<n;i++)
		if(p[i]=='.')
		{
		dian++;
		j=i;
		}
	if(dian!=1)
		return -1;		
	for(i=0;i<n;i++)
		if(p[i]=='P')
		{
		pp++;
		k=i;	
		}
	if(pp!=1)
		return -1;
//	if((k-j)!=7)
//		return -1;
	for(i=1;i<j;i++)
		{
		for(x=0;x<22;x++)
			if(p[i]==buf[x])
			{aa=1;
			break;}
		if(aa!=1)
			return -1;
		aa=0;
		}
	for(i=j+1;i<k;i++)
		{
			for(x=0;x<22;x++)
				if(p[i]==buf[x])
				{
				aa=1;break;
				}
			if(aa!=1)
				return -1;
			aa=0;
		}
	for(i=k+1;i<n;i++)
		{if(i==(k+1))
			if(p[i]=='-')
			continue;
		for(x=0;x<22;x++)
			if(p[i]==buf[x])
			{
			aa=1;break;	
			}
		if(aa!=1)
			return -1;
		aa=0;
		}
	return 0;
}


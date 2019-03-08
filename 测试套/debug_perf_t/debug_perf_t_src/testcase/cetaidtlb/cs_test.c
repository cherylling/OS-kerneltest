#include <stdio.h>

int main(void)
{
    int i = 0;
    int buff[1024];

    for (i = 0; i < 1024; i++)
    {
        buff[i] = i;
    }

    printf("end of buff is:%d\n", buff[1023]);
	while (1)
	{
		if (i < 0)
		{
			break;
		}
	}

    return 0;
}

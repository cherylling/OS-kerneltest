#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <strings.h>

#include "float_lib.h"

//testcase conf file
char *operations_set[] = {
    "+","-","*","/","*+","V", "%", "rfi","cff", "cfi", "cif", "cfd",
    "cdf", "qC", "sC", "cp", "~", "A", "@", "S","L", "Na", "?", "?-", "?n",
    "?f", "?0", "?s", "?i", "?N", "?sN", "<C", ">C","<A", ">A", "=quant",
    "quant", "Nu", "Nd", "eq"};
char *rounding_set[] = {">", "<", "0", "=0", "=^"};
char trapped_set[] = "xuozi";
char *basic_set[] = {"b32", "b64", "d32", "d64", "b128", "d128", "b32b64", "b32b128"};
char *spec_num[] = {"Inf", "Zero", "Q", "S", "#"};

//trim space and \t at the begin of a string
//and trim space , \t ,\n, \b, \r at the end of a string
//

//solve strtof api

float shanks_strtof(const char *nptr, char **endptr)
{
    char *pos = NULL;
    if(nptr[0] == '+' || nptr[0] == '-')
    {
        if((strcasecmp(nptr, "+0x0.000001P-126")==0) 
            ||(strcasecmp(nptr, "-0x0.000001P-126")==0))
        {
            return 0x0.000000p+0;
        }
    }
    else
    {
        if((strcasecmp(nptr, "0x0.000001P-126")==0) 
            ||(strcasecmp(nptr, "0x0.000001P-126")==0))
        {
            return 0x0.000000p+0;
        }
        else
        {
            return strtof(nptr, endptr);
        }
    }
}

char *trim_space(char *srcstr)
{
    char str_temp[256];
    int len = 0;
    int i = 0;
    int space_num = 0;

    if (srcstr == NULL)
    {
        return NULL;
    }

    for (i=0; i<strlen(srcstr); i++)
    {
        if( (srcstr[i] == ' ') || (srcstr[i] == '\t'))
        {
            space_num++;
        }
        else
        {
            break;
        }
    }

    memset(str_temp, 0, 256);
    for (i=0; i<strlen(srcstr); i++)
    {
        str_temp[i] = srcstr[i+space_num];
    }

    len = strlen(str_temp);
    for(i=len-1; i>=0; i--)
    {
        if ((str_temp[i] != '\t') 
                && (str_temp[i] != '\n') 
                && (str_temp[i] != '\r') 
                && (str_temp[i] != ' ') 
                && (str_temp[i] != '\b'))
        {
            break;
        }
        str_temp[i] = '\0'; 
        len--;
    }

    strcpy(srcstr, str_temp);
    return srcstr;
}

char *operator_to_hexoperator(char *srcstr)
{
    char str_temp[256];
    int i = 0;
    int j = 0;
    int len=strlen(srcstr);

    if((srcstr[0] == '0') && ((srcstr[1] == 'x') || srcstr[1] == 'X'))
    {
        return srcstr;
    }

    memset(str_temp, 0, 256);
    if((srcstr[0] != '+' ) && (srcstr[0] != '-'))
    {
        str_temp[0]='0';
        str_temp[1]='x';
        for(j=2,i=0; i<len; i++)
        {
            str_temp[j]=srcstr[i];
            j++;
        }
    }
    else
    {
        str_temp[0]=srcstr[0];
        str_temp[1]='0';
        str_temp[2]='x';
        for(j=3,i=1; i<len; i++)
        {
            str_temp[j]=srcstr[i];
            j++;
        }
    }
    str_temp[j] = '\0';
    strcpy(srcstr, str_temp);
    return srcstr;
}

//get basic format for a float testcase listlink struct
int get_basic_format(const char *srcstr, char *retstr)
{
    int i = 0;
    char str_temp[8];
    memset(str_temp, 0, 8);
    //compare with basic_set element "b32b128", "b32b64"
    strncpy(str_temp, srcstr, 6);
    if (strcmp(str_temp, basic_set[6]) == 0)
    {
        strcpy(retstr, basic_set[6]);
        return 0;
    }
    
    memset(str_temp, 0, 8);
    strncpy(str_temp, srcstr, 7);
    if (strcmp(str_temp, basic_set[7]) == 0)
    {
        strcpy(retstr, basic_set[7]);
        return 0;
    }

    //compare with basic_set element "b128", "d128"
    memset(str_temp, 0, 8);
    strncpy(str_temp, srcstr, 4);
    for(i=4; i<=5; i++)
    {
        if (strcmp(str_temp, basic_set[i]) == 0)
        {
            strcpy(retstr, basic_set[i]);
            return 0;
        }
    }

    //compare with basic_set element "b32","b64","d32","d64"
    memset(str_temp, 0, 8);
    strncpy(str_temp, srcstr, 3);
    for(i=0; i<=3; i++)
    {
        if (strcmp(str_temp, basic_set[i]) == 0)
        {
            strcpy(retstr, basic_set[i]);
            return 0;
        }
    }

    return 1;
}



//get input operand listlink struct
int get_input_operand(const char *srcstr, struct operand_str **operand_stc, const char *basic)
{
    char str_temp[256];
    int i = 0;
    int j = 0;
    int seek = 0;
    int k = 0;
    int spec_flag = 0;
    int len = strlen(srcstr);

    struct operand_str *operand_head = *operand_stc;

    if ((srcstr == NULL) || (operand_stc == NULL))
    {	
        return 1;
    }

    while(seek < len)
    {
        struct operand_str *operand_temp;
        operand_temp = (struct operand_str *)malloc(sizeof(struct operand_str ));
        memset(str_temp, 0, 256);
        for(i=seek, j=0 ;i<len; i++, j++, seek++)
        {
            if ((srcstr[i] != ' ') && (srcstr[i] != '\0'))
            {
                str_temp[j] = srcstr[i];
            }
            else
            {
                str_temp[j] = '\0';
                break;
            }
        }

        char *pos;
        spec_flag = 0;
        for(k=0; k<5; k++)
        {
            pos = NULL;
            if((pos = strstr(str_temp, spec_num[k])) != NULL)
            {
                spec_flag = 1;
                break;
            }
        }
        if(spec_flag == 0 )
        {
            if((strcmp(basic, "d32") == 0)
                    ||(strcmp(basic, "d64") == 0)
                    ||(strcmp(basic, "d128") == 0))
            {
            }
            else
            {
                operator_to_hexoperator(str_temp);
            }
        }
        

        operand_temp->operand = (char *)malloc(sizeof(char) * 256);
        if (operand_temp->operand == NULL)
        {
            printf("malloc space for operand_stc->operand error\n");
            return 1;
        }

        seek++;
        strcpy(operand_temp->operand, str_temp);
        operand_temp->next = operand_head->next;
        operand_head->next = operand_temp;
        operand_head = operand_head->next;
    }

    *operand_stc= (*operand_stc)->next;

    return 0;
}

//phase a string to a float case listlink struct
int str_to_struct_float_case(const char *srcstr, struct float_case *test_case)
{
    int len = 0;
    int i = 0;
    int j = 0;
    int flaglen = 0;
    char str_temp[256];
    char str_seek[256]; 			//srcstr string seek flag
    int ret = 0;
    char *pos = NULL;
    int flag = 0;

    if (srcstr == NULL)
    {
        return 1;		
    }
    if (test_case == NULL)
    {
        return 1;
    }

    test_case->file_str = (char *)malloc(sizeof(char)*256);
    if (test_case->file_str == NULL)
    {
        printf("malloc space for test_case->file_str error\n");
        return 1;
    }

    strcpy(test_case->file_str, srcstr);

    memset(str_seek, 0, 256);
    // *****************************************************
    // "b32+ =0 x -1.7FFFFDP-6 +1.000000P-5 -> +1.400000P-28"
    //---------------------get basic format------------------------------------
    len = strlen(srcstr);
    memset(str_temp, 0, 256);
    strncpy(str_temp, srcstr, 8);
    trim_space(str_temp);
    test_case->basic_format = (char *)malloc(sizeof(char)*8);
    if (test_case->basic_format == NULL)
    {
        printf("malloc space for test_case->basic_format error\n");
        return 1;
    }
    ret = get_basic_format(str_temp, test_case->basic_format);
    if (ret != 0)
    {
        printf("get_basic_format for %s error\n", srcstr);
        return 1;
    }

    strcat(str_seek, test_case->basic_format);
    //---------------------get operation------------------------------------
    pos = strstr(srcstr, test_case->basic_format);
    if (pos == NULL)
    {
        printf("find sub str error %s --- %s\n", srcstr, test_case->basic_format);
        return 1;
    }
    memset(str_temp, 0, 256);
    strcpy(str_temp, pos+strlen(test_case->basic_format));

    i=0;
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if(str_temp[i] == ' ')
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }

    test_case->operation = (char *)malloc(sizeof(char) * 8);
    if (test_case->operation == NULL)
    {
        printf("malloc space for test_case->operation error\n");
        return 1;
    }

    for (i=0; i<40; i++)
    {
        if(strcmp(str_temp, operations_set[i]) == 0)
        {   
            flag = 1;
            strcpy(test_case->operation, operations_set[i]);
            break;
        }
    }

    if(flag == 0)
    {	
        printf("get operation from %s error\n", srcstr);
        return 1;
    }

    flag = 0;
    strcat(str_seek, test_case->operation);

    //------------------get rounding mode---------------------------------------
    pos = NULL;
    pos = strstr(srcstr, str_seek);
    if (pos == NULL)
    {
        printf("get sub str %s in %s error\n", str_seek, srcstr);
        return 1;
    }

    memset(str_temp, 0, 256);
    strcpy(str_temp, pos+strlen(str_seek));

    i=0;
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if(str_temp[i] == ' ')
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }

    test_case->rounding_mode = (char *)malloc(sizeof(char) * 8);
    if (test_case->rounding_mode == NULL)
    {
        printf("malloc space for test_case->rounding_mode error\n");
        return 1;
    }

    for (i=0; i<5; i++)
    {
        if(strcmp(str_temp, rounding_set[i]) == 0)
        {   
            flag = 1;
            strcpy(test_case->rounding_mode, rounding_set[i]);
            break;
        }
    }

    if(flag == 0)
    {	
        printf("get rounding mode from %s error\n", srcstr);
        return 1;
    }

    flag = 0;
    sprintf(str_seek,"%s %s", str_seek, test_case->rounding_mode);

    //----------------------------get trapped exceptions---------------------------
    pos = NULL;
    pos = strstr(srcstr, str_seek);
    if (pos == NULL)
    {
        printf("get sub str %s in %s error\n", str_seek, srcstr);
        return 1;
    }

    memset(str_temp, 0, 256);
    strcpy(str_temp, pos+strlen(str_seek));

    i=0;
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if(str_temp[i] == ' ')
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }

    test_case->trapped_exceptions = (char *)malloc(sizeof(char) * 8);
    if (test_case->trapped_exceptions == NULL)
    {
        printf("malloc space for test_case->trapped_exceptions error\n");
        return 1;
    }
    //add for OR exceptions 

    int len_trap=strlen(str_temp);
    for(j=0; j<len_trap; j++)
    {
        for (i=0; i<5; i++)
        {
            if(str_temp[j] == trapped_set[i])
            {
                break;
            }
        }
        if(i>=5)
        {
            //no trapped_exceptions
//            printf("the trapped_exceptions %s is invalid in %s\n", str_temp, trapped_set);
//            free(test_case->trapped_exceptions);
            test_case->trapped_exceptions = NULL;
            flag++;
            break;
        }
    }
    if(flag == 0)
    {
        strcpy(test_case->trapped_exceptions, str_temp);
        sprintf(str_seek,"%s %s", str_seek, test_case->trapped_exceptions);
    }
    flag = 0;
    //----------------------------get input operand---------------------------
    pos = NULL;
    pos = strstr(srcstr, str_seek);
    if (pos == NULL)
    {
        printf("get sub str %s in %s error\n", str_seek, srcstr);
        return 1;
    }

    memset(str_temp, 0, 256);
    strcpy(str_temp, pos+strlen(str_seek));

    i=0;
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if((str_temp[i] == '-') && (str_temp[i+1] == '>'))
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }

    test_case->input_operand = (struct operand_str *)malloc(sizeof(struct operand_str));
    if (test_case->input_operand == NULL)
    {
        printf("malloc space for test_case->input_operand error\n");
        return 1;
    }

    trim_space(str_temp);
    ret = get_input_operand(str_temp, &test_case->input_operand, test_case->basic_format);
    if (ret != 0 )
    {
        printf("get input operand error\n");
        return 1;
    }

    //----------------------------get output---------------------------
    pos = strstr(srcstr, "->");
    if (pos == NULL)
    {	
        printf("cannot find -> flag in %s\n", srcstr);
        return 1;
    }

    memset(str_temp, 0, 256);
    strcpy(str_temp, pos+2);

    i=0;
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if(str_temp[i] == ' ')
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }
    int k = 0;
    int spec_flag = 0;
    char *spos ;
    for(k=0; k<5; k++)
    {
        spos = NULL;
        if((spos = strstr(str_temp, spec_num[k])) != NULL)
        {
            spec_flag = 1;
            break;
        }
    }
    if(spec_flag == 0 )
    {
        if((strcmp(test_case->basic_format, "d32") == 0)
                ||(strcmp(test_case->basic_format, "d64") == 0)
                ||(strcmp(test_case->basic_format, "d128") == 0))
        {
        }
        else
        {
            operator_to_hexoperator(str_temp);
        }
    }

    test_case->output_result = (char *)malloc(sizeof(char)*256);
    if (test_case->output_result == NULL)
    {
        printf("malloc space for test_case->output_result error\n");
        return 1;
    }

    strcpy(test_case->output_result, str_temp);
    len = strlen(str_temp);

    //--------------------------get end exception_flag -----------------

    memset(str_temp, 0, 256);
    if((strcmp(test_case->basic_format, "d32") == 0)
            ||(strcmp(test_case->basic_format, "d64") == 0)
            ||(strcmp(test_case->basic_format, "d128") == 0))//decimal
    {
        //no specify operation
        strcpy(str_temp, pos + 2 + 1 + len + 1);
    }
    else//bit
    {
        if(spos != NULL )
        {
            //spos != NULL  means "...." is one of the string spec_num 
            //pos           "-> .... x"    
            //pos+2         " .... x"
            //pos+2+1       ".... x"
            //pos+2+len     " x"
            //pos+2+len+1   "x"
            strcpy(str_temp, pos + 2 + 1 + len + 1);
        }
        else
        {
            //spos == NULL  means "...." is not one of the string spec_num 
            //                          so for bit float ,it has added "0x" prefix of "...." 
            //pos           "-> .... x"    
            //pos+2         " .... x"
            //pos+2+1       ".... x"
            //pos+2+len     ""
            //pos+2+len+1   ""
            //pos+2+len+1-2 "x"
            strcpy(str_temp, pos + 2 + 1 + len + 1 - 2);
        }
    }

    i=0;		
    trim_space(str_temp);
    while(i < strlen(str_temp))
    {
        if(str_temp[i] == ' ')
        {
            str_temp[i] = '\0';
            break;
        }
        else
        {
            i++;
        }
    }

    test_case->exception_flag = (char *)malloc(sizeof(char) * 8);
    if (test_case->exception_flag == NULL)
    {
        printf("malloc space for test_case->exception_flag error\n");
        return 1;
    }

    int len_exp=strlen(str_temp);
    for(j=0; j<len_exp; j++)
    {
        for (i=0; i<5; i++)
        {
            if(str_temp[j] == trapped_set[i])
            {
                break;
            }
        }
        if(i>=5)
        {
//            printf("the exceptions %s is invalid in %s\n", str_temp, trapped_set);
//            free(test_case->exception_flag);
            test_case->exception_flag = NULL;
            flag++;
            break;
        }
    }
    if(flag == 0)
    {
        strcpy(test_case->exception_flag, str_temp);
    }
    return 0;
}

//freee space for the float case listlink struct
void free_struct(struct float_case *testcase)
{
    if( testcase->basic_format != NULL )
    {
        free(testcase->basic_format);
        testcase->basic_format = NULL;
    }

    if( testcase->operation != NULL )
    {
        free(testcase->operation);
        testcase->operation = NULL;
    }

    if( testcase->rounding_mode != NULL )
    {
        free(testcase->rounding_mode);
        testcase->rounding_mode = NULL;
    }
    if( testcase->trapped_exceptions != NULL )
    {
        free(testcase->trapped_exceptions);
        testcase->trapped_exceptions = NULL;
    }
    if( testcase->output_result != NULL )
    {
        free(testcase->output_result);
        testcase->output_result = NULL;
    }

    if( testcase->exception_flag != NULL )
    {
        free(testcase->exception_flag );
        testcase->exception_flag = NULL;
    }

    while( testcase->input_operand != NULL )
    {
        free(testcase->input_operand->operand );
        testcase->input_operand->operand = NULL;
        testcase->input_operand = testcase->input_operand->next;
    }

    testcase=testcase->next;
    if(testcase != NULL)
    {
        free_struct(testcase);
    }
}

//phase all testcases in ptest file
int phase_ptest_file(struct float_case **test_case, const char *file_name)
{
    int ret = 0;
    FILE *fp = NULL;
    char *out = "->";
    char strtmp[256];
    char *outpos = NULL;
    int nullflat = 0;

    struct float_case *testcase_head = *test_case;

    if (test_case == NULL) 
    {
        printf("the first param float_case is null\n");
        return 1;
    }
    if (file_name == NULL) 
    {
        printf("the second param file_name is null\n");
        return 1;
    }

    fp = fopen(file_name, "r");
    if (fp == NULL)
    {
        printf("fopen file of %s ERROR\n", file_name);
        return 1;
    }

    memset(strtmp, 0, 256);
    while(fgets(strtmp, sizeof(strtmp), fp) != NULL)
    {
        // add testcase validily func TBD
        outpos = strstr(strtmp, out);
        if (outpos == NULL)
        {
            memset(strtmp, 0, 256);
            continue;
        }
        else
        {
            nullflat = 1;
            struct float_case *testcase_temp;
            testcase_temp = (struct float_case *)malloc(sizeof(struct float_case)); 
            trim_space(strtmp);
            ret = str_to_struct_float_case(strtmp, testcase_temp);
            if (ret != 0)
            {
                printf("%s transform to test case listlink fail\n", strtmp);
                return ret;
            }

            testcase_temp->next = testcase_head->next;
            testcase_head->next = testcase_temp;
            testcase_head = testcase_head->next;
        }
        memset(strtmp, 0, 256);
    }

    if(nullflat == 0)
    {
        printf("NULL file\n");
        return 1;
    }
    *test_case = (*test_case)->next;
    return 0;
}


int float_string_to_float_operand(const char *srcstr, struct float_operand *retvalue)
{
    int len = strlen(srcstr);
    int i = 0;
    int j = 0;
    int float_part_hex = 0;
    int flag = 0;
    int src_exp = 0;
    char *pos;
    char strtemp[256];
    /* 
       if (srcstr[0] == '-' || srcstr[0] == '+')
       {
       retvalue->head_sign = srcstr[0];
       i++;
       }
       else
       {
       retvalue->head_sign = '+';
       }
       */  
    if ((pos = strstr(srcstr, ".")) == NULL)
    {
        printf("%s is not a float num\n", srcstr);
        return 1;
    }
    else
    {
        memset(strtemp, 0, 256);
        strtemp[0] = srcstr[0];
        i++;
        strcat(strtemp, "0x");
        for(j=3; i<len; i++)
        {
            strtemp[j] = srcstr[i];
            if(srcstr[i] == 'P')
            {
                strtemp[j] = '\0';
                break;
            }

            j++;
        }
    }


    memset(retvalue->force_part, 0, 256);
    strcpy(retvalue->force_part, strtemp);
    //    retvalue->force_part = strtol(strtemp, NULL, 16);

    //    i++;
    if ((pos = strstr(srcstr, "P")) != NULL)
        //            ((pos = strstr(srcstr, "E")) != NULL))
    {
        retvalue->ep_value = 2;
    }
    else
    {
        retvalue->ep_value = 0;
        return 0;
    }
    /*
       if(srcstr[i] == '-' || srcstr[i] == '+' )
       {
       retvalue->exp_sign = srcstr[i];
       i++;
       }
       else
       {
       retvalue->exp_sign = '+';
       }  
       */
    i++;
    memset(strtemp, 0, 256);
    for(j=0; i<len; i++, j++)
    {
        strtemp[j] = srcstr[i];
    }

    retvalue->exp = atoi(strtemp);
    /*
       if(retvalue->exp_sign == '-')
       {
       retvalue->exp = src_exp + float_part_hex * 4;
       }
       else
       {
       if(src_exp >= (float_part_hex * 4))
       retvalue->exp = src_exp - float_part_hex * 4;
       else
       {
       retvalue->exp = float_part_hex * 4 - src_exp;
       retvalue->exp_sign = '-';
       }
       }
       */		
    return 0;
}

float input_operand_trans_calc(struct float_operand  *float_operand_stc, int num, char *operation, struct float_operand *ret_operand_stc)
{
    int i=0;
    float ret_value = 0.00;
    int min_exp = float_operand_stc[0].exp;

    for(i = 1; i < num; i++)
    {
        if(min_exp > float_operand_stc[i].exp)
            min_exp = float_operand_stc[i].exp;	
    }

    for(i = 0; i < num; i++)
    {
        float_operand_stc[i].force_float = atof(float_operand_stc[i].force_part) * pow(2, (float_operand_stc[i].exp - min_exp));
        float_operand_stc[i].exp = min_exp;
    }

    ret_operand_stc->exp = min_exp;

    if(strcmp(operation, "+") == 0)
    {
        for(i = 0; i < num; i++)
        {
            ret_value += float_operand_stc[i].force_float ;
        }
    }
    else if(strcmp(operation, "-") == 0)
    {
        for(i = 0; i < num; i++)
        {
            ret_value -= float_operand_stc[i].force_float ;
        }
    }
    else
    {
        printf("----------------tbd\n");
    }

    ret_operand_stc->force_float = ret_value;
    ret_operand_stc->ep_value = 2; //

    return ret_value;
}

int input_calc_match_result(struct float_operand input_operand_stc, struct float_operand result_operand_stc)
{
    float ret_value = 0.00;

    result_operand_stc.force_float = atof(result_operand_stc.force_part) * pow(2, (input_operand_stc.exp - result_operand_stc.exp));
    if(result_operand_stc.force_float != input_operand_stc.force_float)
    {
        printf("%0.64f != %0.64f \n", result_operand_stc.force_float, input_operand_stc.force_float );
        return 1;
    }

    return 0;
}

float float_operand_to_float(struct float_operand src_operand)
{
    float ret_float = 0.00;
    /*
       if(src_operand.exp_sign == '+')
       {
       ret_float = src_operand.force_part * powl(src_operand.ep_value, src_operand.exp);
       }
       else
       {
       ret_float = src_operand.force_part / powl(src_operand.ep_value, src_operand.exp);
       }

       if (src_operand.head_sign == '+')
       {
       return ret_float;
       }
       else
       {
       return (0 - ret_float);
       }
       */
    return 0;
}


#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <strings.h>
//#include <signal.h>
#include <fenv.h>

#include "float_lib.h"

//testcase conf file
int gret = 0;
int operator_flag = 0;

int set_rounding_mode(const char *rounding_mode)
{
    int ret = 0;
    if(strcmp(rounding_mode, "=0") == 0)
    {
        ret = fesetround(FE_TONEAREST);
        if(ret != 0)
        {
            printf("fesetround FE_TONEAREST fail \n");
            return 1;
        }
    }
    if(strcmp(rounding_mode, "0") == 0)
    {
        ret = fesetround(FE_TOWARDZERO);
        if(ret != 0)
        {
            printf("fesetround FE_TOWARDZERO fail \n");
            return 1;
        }
    }
    if(strcmp(rounding_mode, ">") == 0)
    {
        ret = fesetround(FE_UPWARD);
        if(ret != 0)
        {
            printf("fesetround FE_UPWARD fail \n");
            return 1;
        }
    }
    if(strcmp(rounding_mode, "<") == 0)
    {
        ret = fesetround(FE_DOWNWARD);
        if(ret != 0)
        {
            printf("fesetround FE_DOWNWARD fail \n");
            return 1;
        }
    }

    return 0;
}

int set_tapped_exceptions(const char *trapped_exceptions)
{
    int ret = 0;
    if(trapped_exceptions == NULL) 
    {
        return 0;
    }
    if(strcmp(trapped_exceptions, "xo") == 0)
    {
        ret = feraiseexcept(FE_INEXACT|FE_OVERFLOW);
        if(ret != 0)
        {
            printf("feraiseexcept FE_INEXACT|FE_OVERFLOW  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "xu") == 0)
    {
        ret = feraiseexcept(FE_INEXACT|FE_UNDERFLOW);
        if(ret != 0)
        {
            printf("feraiseexcept FE_INEXACT|FE_UNDERFLOW  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "x") == 0)
    {
        ret = feraiseexcept(FE_INEXACT);
        if(ret != 0)
        {
            printf("feraiseexcept FE_INEXACT  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "u") == 0)
    {
        ret = feraiseexcept(FE_UNDERFLOW);
        if(ret != 0)
        {
            printf("feraiseexcept FE_UNDERFLOW  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "o") == 0)
    {
        ret = feraiseexcept(FE_OVERFLOW);
        if(ret != 0)
        {
            printf("feraiseexcept FE_OVERFLOW  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "z") == 0)
    {
        ret = feraiseexcept(FE_DIVBYZERO);
        if(ret != 0)
        {
            printf("feraiseexcept FE_DIVBYZERO  fail \n");
            return 1;
        }
    }
    else if(strcmp(trapped_exceptions, "i") == 0)
    {
        ret = feraiseexcept(FE_INVALID);
        if(ret != 0)
        {
            printf("feraiseexcept FE_INVALID  fail \n");
            return 1;
        }
    }
    else
    {
    }

    return 0;
}

int all_operation(struct float_case *src_test_case)
{
    float result = 0;
    float temp_value = 0;
//    double long b128value=0;
    double b64value=0;

    double dresult = 0;
    double  dtemp_value = 0;
//    long double d128value=0;
    int ret = 0;
    struct float_operand float_operand_stc;
    struct float_case *test_case = src_test_case;
    fexcept_t flagp_temp = 0;
    fexcept_t flagp = 0;

    int sole_flag = 0;

    //set float point env  FE_DIVBYZERO, FE_INEXACT, FE_INVALID, FE_OVERFLOW, FE_UNDERFLOW
    //clear exceptions
    ret = feclearexcept(FE_ALL_EXCEPT);
    if(ret != 0)
    {
        printf("feclearexcept FE_ALL_EXCEPT fail \n");
        return 1;
    }

    //set rounding_mode
    ret = set_rounding_mode(test_case->rounding_mode);
    if(ret != 0)
    {
        return 1;
    }

    //set trapped exceptions
    ret = set_tapped_exceptions(test_case->trapped_exceptions);
    if(ret != 0)
    {
        return 1;
    }

    //calc
    operator_flag = 0;
    if((strcmp(test_case->basic_format, "b32") == 0) 
            ||(strcmp(test_case->basic_format, "b64") == 0) 
            ||(strcmp(test_case->basic_format, "b128") == 0) 
            ||(strcmp(test_case->basic_format, "b32b64") == 0) 
            ||(strcmp(test_case->basic_format, "b32b128") == 0))
    {
        while(test_case->input_operand != NULL)
        {
            //    result = calc_operation(test_case->input_operand->operand, test_case->operation);
            // b
            if(strcmp(test_case->input_operand->operand, "+Inf") == 0)
            {
                temp_value = INFINITY;
//                temp_value = +0x1.FFFFFFP127;
            }
            else if(strcmp(test_case->input_operand->operand, "-Inf") == 0)
            {
                temp_value = -INFINITY;
//                temp_value = -0x1.FFFFFFP127;
            }
            else if(strcmp(test_case->input_operand->operand, "+Zero") == 0)
            {
                temp_value = +0x0.000000p+0;
            }
            else if(strcmp(test_case->input_operand->operand, "-Zero") == 0)
            {
                temp_value = -0x0.000000p+0;
            }
            else if(strcmp(test_case->input_operand->operand, "Q") == 0)
            {
                temp_value = -NAN;
            }
            else if(strcmp(test_case->input_operand->operand, "S") == 0)
            {
                temp_value = NAN;
            }
            else
            {
                temp_value = strtof(test_case->input_operand->operand, NULL);
            }

            if(operator_flag == 0)
            {
                result = temp_value;
                if(strcmp(test_case->operation, "?N") == 0) //isnan or not
                {
                    if(isnan(result))
                    {
                        sole_flag=1;
                    }       
                }
                if(strcmp(test_case->operation, "?i") == 0)//isinf or not
                {
                    if((isinf(result) == 1) || (isinf(result) == -1))
                    {
                        sole_flag=1;
                    }       
                }
                if(strcmp(test_case->operation, "?f") == 0) //isfinite or not 
                {//isfinite(x)   returns a non-zero value if
                //             (fpclassify(x) != FP_NAN && fpclassify(x) != FP_INFINITE)
                    if(isfinite(result))
                    {
                        sole_flag=1;
                    }
                }
                if(strcmp(test_case->operation, "cp") == 0)
                {
                }
                if(strcmp(test_case->operation, "cff") == 0)
                {
                }
                if(strcmp(test_case->operation, "?n") == 0) //isnormal or not
                {
                    if(isnormal(result))
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?0") == 0)
                {
                    if(fpclassify(result) == FP_ZERO)
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?sN") == 0)
                {
                }
                if(strcmp(test_case->operation, "?s") == 0)
                {
                    if(fpclassify(result) == FP_SUBNORMAL)
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?-") == 0)
                {
                    if(signbit(result))
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "A") == 0)
                {
                    result = fabsf(temp_value);
                }
                if(strcmp(test_case->operation, "~") == 0)
                {
                    result = 0 - temp_value;
                }
                if(strcmp(test_case->operation, "V") == 0)
                {
                    result = sqrtf(temp_value);
                }
            }
            else
            {
                if(strcmp(test_case->operation, "@") == 0)
                {
                    result = copysign(temp_value, result);
                }
                if(strcmp(test_case->operation, "+") == 0)
                {
                    result = temp_value + result;
                }
                if(strcmp(test_case->operation,  "-") == 0)
                {
                    result = result - temp_value;
                }
                if(strcmp(test_case->operation,  "*") == 0)
                {
                    result = result * temp_value;
                }
                if(strcmp(test_case->operation,  "/") == 0)
                {              
                    result = result / temp_value;
                }

                /*         if(strcmp(test_case->operation, "%") == 0)
                           {
                           result = result % temp_value;
                           }
                           */
                if(strcmp(test_case->operation,  "*+") == 0)
                {              
                    if(operator_flag == 1)
                        result = result * temp_value;
                    else
                        result = result + temp_value;
                }
                if(strcmp(test_case->operation,  "<C") == 0)
                {
                    if(result > temp_value)
                    {
                        result = temp_value;
                    }
                }
                if(strcmp(test_case->operation,  ">C") == 0)
                {
                    if(result < temp_value)
                    {
                        result = temp_value;
                    }
                }
                if(strcmp(test_case->operation,  ">A") == 0)
                {
                    if(fabsf(result) < fabsf(temp_value))
                    {
                        result = temp_value;
                    }
                }
                if(strcmp(test_case->operation,  "<A") == 0)
                {
                    if(fabsf(result) > fabsf(temp_value))
                    {
                        result = temp_value;
                    }
                }
            }

            ret = fegetexceptflag(&flagp_temp, FE_ALL_EXCEPT);
            if(ret != 0)
            {
                printf("fegetexceptflag  fail \n");
                return 1;
            }

            flagp = (flagp | flagp_temp);
            test_case->input_operand = test_case->input_operand->next;
            operator_flag++;
        }

        if(strcmp(test_case->output_result, "+Inf") == 0)
        {
            temp_value = INFINITY;
            //        temp_value = +0x1.FFFFFFP127;
//            temp_value = strtof("+0x1.FFFFFFP127", NULL);
        }
        else if(strcmp(test_case->output_result, "-Inf") == 0)
        {
            temp_value = -INFINITY;
//            temp_value = strtof("-0x1.FFFFFFP127", NULL);
        }
        else if(strcmp(test_case->output_result, "+Zero") == 0)
        {
            //        temp_value = +0x0.000000p+0;
            temp_value = strtof("+0x0.000000p+0", NULL);
        }
        else if(strcmp(test_case->output_result, "-Zero") == 0)
        {
            //        temp_value = -0x0.000000p+0;
            temp_value = strtof("-0x0.000000p+0", NULL);
        }
        else if(strcmp(test_case->output_result, "Q") == 0)
        {
            temp_value = -NAN;
        }
        else if(strcmp(test_case->output_result, "S") == 0)
        {
            temp_value = NAN;
        }
        else if(strcmp(test_case->output_result, "#") == 0)
        {
            temp_value = 0;
        }
        else
        {
            temp_value = strtof(test_case->output_result, NULL);
        }
        
        //for ?f ?N ?i  
        if(sole_flag == temp_value)
        {
            printf("%0.6a \t  #%0.6a \t :%s:%s:%d\t--simple operation test",
                    temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }

        if(strcmp(test_case->output_result, "#") == 0)
        {
            if((flagp & FE_INVALID) == FE_INVALID) 
            {    
                printf("%0.6a \t  #%0.6a \t :%s:%s:%d\t--no output with invalid exception",
                        temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 0;
            }
            else
            {
                printf("%0.6a \t  #%0.6a \t :%s:%s:%d\t--no output but with no invalid exception",
                        temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 1;
            }
        }

        if(isnan(temp_value) && isnan(result))
        {
            printf("%0.6a \t  %0.6a \t :%s:%s:%d\t",
                    temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }
        
        if(temp_value == result)
        {
            printf("%0.6a \t  %0.6a \t :%s:%s:%d\t",
                    temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }
        else
        {
            if(test_case->exception_flag == NULL)
            {
                printf("%0.6a \t  %0.6a \t :%s:%s:%d\t",
                        temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 1;
            }
            else
            {
                //            if((((flagp & FE_INEXACT) == FE_INEXACT) && (strcmp(test_case->exception_flag, "x") == 0))
                //            ||(((flagp & (FE_INEXACT|FE_OVERFLOW)) == (FE_INEXACT|FE_OVERFLOW)) && (strcmp(test_case->exception_flag, "xo") == 0))
                //            ||(((flagp & (FE_INEXACT|FE_UNDERFLOW)) == (FE_INEXACT|FE_UNDERFLOW)) && (strcmp(test_case->exception_flag, "xu") == 0)))
                if(((flagp & FE_INEXACT) == FE_INEXACT) 
                        ||((flagp & FE_OVERFLOW) == FE_OVERFLOW) 
                        ||((flagp & FE_UNDERFLOW) == FE_UNDERFLOW) 
                        ||((flagp & FE_INVALID) == FE_INVALID)) 
                    //            ||(((flagp & FE_OVERFLOW) == FE_OVERFLOW) && (strcmp(test_case->exception_flag, "o") == 0)))
                {
                    printf("%0.6a \t  %0.6a \t :%s:%s:%d\t",
                            temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                    return 0;
                }
                else
                {
                    printf("%0.6a \t  %0.6a \t :%s:%s:%d\t",
                            temp_value, result, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                    return 1;
                }
            }
        }
    }
    else //decimal
    {
        while(test_case->input_operand != NULL)
        {
            if(strcmp(test_case->input_operand->operand, "+Inf") == 0)
            {
                dtemp_value = +INFINITY;
            }
            else if(strcmp(test_case->input_operand->operand, "-Inf") == 0)
            {
                dtemp_value = -INFINITY;
            }
            else if(strcmp(test_case->input_operand->operand, "+Zero") == 0)
            {
                dtemp_value = +0.000000e+00;
            }
            else if(strcmp(test_case->input_operand->operand, "-Zero") == 0)
            {
                dtemp_value = -0.000000e+00;
            }
            else if(strcmp(test_case->input_operand->operand, "Q") == 0)
            {
                dtemp_value = -NAN;
            }
            else if(strcmp(test_case->input_operand->operand, "S") == 0)
            {
                dtemp_value = NAN;
            }
            else
            {
                dtemp_value = strtod(test_case->input_operand->operand, NULL);
            }

            if(operator_flag == 0)
            {
                dresult = dtemp_value;
                if(strcmp(test_case->operation, "?n") == 0)
                {
                    if(isnormal(dresult))
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?i") == 0)
                {
                    if((isinf(dresult) == 1) || (isinf(dresult) == -1))
                    {
                        sole_flag = 1;
                    }       
                }
                if(strcmp(test_case->operation, "?f") == 0)
                {
                    if(isfinite(dresult))
                    {
                        sole_flag = 1;
                    }       
                }
                if(strcmp(test_case->operation, "?0") == 0)
                {
                    if(fpclassify(dresult) == FP_ZERO)
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?sN") == 0)
                {
                }
                if(strcmp(test_case->operation, "?s") == 0)
                {
                    if(fpclassify(dresult) == FP_SUBNORMAL)
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "?-") == 0)
                {
                    if(signbit(dresult))
                    {
                        sole_flag = 1;
                    }
                }
                if(strcmp(test_case->operation, "cp") == 0)
                {
                }
                if(strcmp(test_case->operation, "cff") == 0)
                {
                }
                if(strcmp(test_case->operation, "?N") == 0)
                {
                    if(isnan(dresult))
                    {
                        sole_flag = 1;
                    }       
                }
                if(strcmp(test_case->operation, "A") == 0)
                {
                    dresult = fabs(dtemp_value);
                }
                if(strcmp(test_case->operation, "~") == 0)
                {
                    dresult = 0 - dtemp_value;
                }
                if(strcmp(test_case->operation, "V") == 0)
                {
                    dresult = sqrt(dtemp_value);
                }
            }
            else
            {
                if(strcmp(test_case->operation, "@") == 0)
                {
                    dresult = copysign(dtemp_value, dresult);
                }
                if(strcmp(test_case->operation, "+") == 0)
                {
                    dresult = dtemp_value + dresult;
                }
                if(strcmp(test_case->operation,  "-") == 0)
                {
                    dresult = dresult - dtemp_value;
                }
                if(strcmp(test_case->operation,  "*") == 0)
                {
                    dresult = dresult * dtemp_value;
                }
                if(strcmp(test_case->operation,  "/") == 0)
                {              
                    dresult = dresult / dtemp_value;
                }

                /*         if(strcmp(test_case->operation, "%") == 0)
                           {
                           dresult = dresult % dtemp_value;
                           }
                           */
                if(strcmp(test_case->operation,  "*+") == 0)
                {              
                    if(operator_flag == 1)
                        dresult = dresult * dtemp_value;
                    else
                        dresult = dresult + dtemp_value;
                }
                if(strcmp(test_case->operation,  "<C") == 0)
                {
                    if(dresult > dtemp_value)
                    {
                        dresult = dtemp_value;
                    }
                }
                if(strcmp(test_case->operation,  ">C") == 0)
                {
                    if(dresult < dtemp_value)
                    {
                        dresult = dtemp_value;
                    }
                }
                if(strcmp(test_case->operation,  ">A") == 0)
                {
                    if(fabs(dresult) < fabs(dtemp_value))
                    {
                        dresult = dtemp_value;
                    }
                }
                if(strcmp(test_case->operation,  "<A") == 0)
                {
                    if(fabs(dresult) > fabs(dtemp_value))
                    {
                        dresult = dtemp_value;
                    }
                }
            }

            ret = fegetexceptflag(&flagp_temp, FE_ALL_EXCEPT);
            if(ret != 0)
            {
                printf("fegetexceptflag  fail \n");
                return 1;
            }

            flagp = (flagp | flagp_temp);
            test_case->input_operand = test_case->input_operand->next;
            operator_flag++;
        }

        if(strcmp(test_case->output_result, "+Inf") == 0)
        {
            dtemp_value = INFINITY;
        }
        else if(strcmp(test_case->output_result, "-Inf") == 0)
        {
            dtemp_value = -INFINITY;
        }
        else if(strcmp(test_case->output_result, "+Zero") == 0)
        {
            dtemp_value = strtod("+0.000000e+00", NULL);
        }
        else if(strcmp(test_case->output_result, "-Zero") == 0)
        {
            dtemp_value = strtod("-0.000000e+00", NULL);
        }
        else if(strcmp(test_case->output_result, "Q") == 0)
        {
            dtemp_value = -NAN;
        }
        else if(strcmp(test_case->output_result, "S") == 0)
        {
            dtemp_value = NAN;
        }
        else if(strcmp(test_case->output_result, "#") == 0)
        {
            dtemp_value = 0;
        }
        else
        {
            dtemp_value = strtod(test_case->output_result, NULL);
        }

        //for ?f ?N ?i  ?n ?-
        if(sole_flag == dtemp_value)
        {
            printf("%e \t  #%e \t :%s:%s:%d\t--simple operation test",
                    dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }

        if(strcmp(test_case->output_result, "#") == 0)
        {
            if((flagp & FE_INVALID) == FE_INVALID) 
            {        printf("%e \t  #%e \t :%s:%s:%d\t--no output with invalid exception",
                        dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 0;
            }
            else
            {
                printf("%e \t  #%e \t :%s:%s:%d\t--no output but with no invalid exception",
                        dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 1;
            }
        }
        
        if(isnan(dtemp_value) && isnan(dresult))
        {
            printf("%e \t  %e \t :%s:%s:%d\t",
                    dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }

        if(dtemp_value == dresult)
        {
            printf("%e \t  %e \t :%s:%s:%d\t",
                    dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
            return 0;
        }
        else
        {
            if(test_case->exception_flag == NULL)
            {
                printf("%e \t  %e \t :%s:%s:%d\t",
                        dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                return 1;
            }
            else
            {
                //            if((((flagp & FE_INEXACT) == FE_INEXACT) && (strcmp(test_case->exception_flag, "x") == 0))
                //            ||(((flagp & (FE_INEXACT|FE_OVERFLOW)) == (FE_INEXACT|FE_OVERFLOW)) && (strcmp(test_case->exception_flag, "xo") == 0))
                //            ||(((flagp & (FE_INEXACT|FE_UNDERFLOW)) == (FE_INEXACT|FE_UNDERFLOW)) && (strcmp(test_case->exception_flag, "xu") == 0)))
                if(((flagp & FE_INEXACT) == FE_INEXACT) 
                        ||((flagp & FE_OVERFLOW) == FE_OVERFLOW) 
                        ||((flagp & FE_UNDERFLOW) == FE_UNDERFLOW) 
                        ||((flagp & FE_INVALID) == FE_INVALID)) 
                    //            ||(((flagp & FE_OVERFLOW) == FE_OVERFLOW) && (strcmp(test_case->exception_flag, "o") == 0)))
                {
                    printf("%0.6e \t  %0.6e \t :%s:%s:%d\t",
                            dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                    return 0;
                }
                else
                {
                    printf("%0.6e \t  %0.6e \t :%s:%s:%d\t",
                            dtemp_value, dresult, test_case->trapped_exceptions,test_case->exception_flag, flagp);
                    return 1;
                }
            }
        }
    }
}
/*   
     void handler()
     {
     FEP_SIG_FLAG=1;
     printf("SIGFPE signal generates \n");
     return;
     }
     */
int main(int argc, char **argv)
{
    int ret = 0;
    struct float_case *test_case;
    test_case=(struct float_case *)malloc(sizeof(struct float_case)); 
    if (test_case == NULL)
    {
        printf("malloc space for float_case struct\n");
        return 1;
    }
//	printf("%d,%d,%d,%d,%d\n", FE_DIVBYZERO, FE_INEXACT, FE_INVALID, FE_OVERFLOW, FE_UNDERFLOW);
	//2,16,1,4,8  for arm
//-
//char *conf_file = "../conf/Overflow.fptest";
//char *conf_file = "../conf/Add-Cancellation.fptest";
    char conf_file[256];
    memset(conf_file, 0, 256);
    strcpy(conf_file, "../conf/");
    strcat(conf_file, argv[1]);
    strcat(conf_file, ".fptest");
    
//

    ret = phase_ptest_file(&test_case,conf_file);
    if (ret != 0)
    {
        printf("phase_ptest_file %s FAIL\n", conf_file);
        free_struct(test_case);
        return 1;
    }


//    struct sigaction sa;
//    sa.sa_handler = handler;
//    sigemptyset(&sa.sa_mask);
//    sigaddset(&sa.sa_mask, 0);
//    sigaction(SIGFPE, &sa, NULL);
//      signal(SIGTRAP, handler);
/*     
    FILE *rufd = NULL;      
    FILE *cofd = NULL;      
    char rufilename[256];
    memset(rufilename, 0, 256);
    sprintf(rufilename, "../rudconf/%s", argv[1]);
    char cofilename[256];
    memset(cofilename, 0, 256);
    sprintf(cofilename, "../coconf/%s", argv[1]);

    rufd = fopen(rufilename, "a+");
    if(rufd == NULL)
    {
        printf("fopen rufilename %s fail\n",rufilename);
        return 1;
    }

    cofd = fopen(cofilename, "a+");
    if(cofd == NULL)
    {
        printf("fopen cofilename %s fail\n",cofilename);
        fclose(rufd);
        return 1;
    }

	printf("%d,%d,%d,%d,%d\n", FE_DIVBYZERO, FE_INEXACT, FE_INVALID, FE_OVERFLOW, FE_UNDERFLOW);
*/        
    struct float_case *save_link = test_case;
    int testnum = 1;
    while(test_case != NULL)
    {
//        printf("%s, %s, %s, %s, %s, %s\n", test_case->basic_format, test_case->operation, test_case->rounding_mode,
//                test_case->trapped_exceptions, test_case->output_result, test_case->exception_flag);

        ret = all_operation(test_case);
        if (ret != 0)
        {
//           fputs(test_case->file_str, rufd);
//            fputc('\n', rufd);
            printf("======== %s[%d] ----- [FAIL]\n", argv[1], testnum);
            gret++;
        }
        else
        {
//           fputs(test_case->file_str, cofd);
//           fputc('\n', cofd);
            
            printf("******** %s[%d] ----- [PASS]\n", argv[1], testnum);
        }

        testnum++;
//        while(test_case->input_operand != NULL)
//        {
//            printf("%s\n", test_case->input_operand->operand);
//            test_case->input_operand = test_case->input_operand->next;
//        }

        test_case = test_case->next;
    }
    //-------------------------------------------------------------
   
    free_struct(save_link);
//   fclose(rufd);
//    fclose(cofd);
    if (gret != 0 ) 
        return 1;
    else
        return 0;
} 



extern char *operations_set[]; 
extern char *rounding_set[];
extern char trapped_set[];
extern char *basic_set[];

//input operand listlink
struct operand_str
{
	char *operand;				//input operand
	struct operand_str *next;   //input operand listlink next
};

//float testcase listlink struct 
struct float_case
{
        char *file_str;
	char *basic_format;					//basic format 
	char *operation;					//operation
	char *rounding_mode;				//rounding mode
	char *trapped_exceptions;			//exceptions
	struct operand_str *input_operand;	//input operand listlink
	char *output_result;				//output result
	char *exception_flag;				//result trapped exceptions
	struct float_case *next;			//float testcase listlink struct next
};
 
struct float_operand
{
//    char head_sign;
    char force_part[256];
    double long force_float;
    int  ep_value;
//    char exp_sign;
    int exp;
};

//trim space and \t at the begin of a string
//and trim space , \t ,\n, \b, \r at the end of a string
float shanks_strtof(const char *nptr, char **endptr);
char *trim_space(char *srcstr);
char *operator_to_hexoperator(char *srcstr);
int get_basic_format(const char *srcstr, char *retstr);
int str_to_struct_float_case(const char *srcstr, struct float_case *test_case);
void free_struct(struct float_case *testcase);
int phase_ptest_file(struct float_case **test_case, const char *file_name);
int float_string_to_float_operand(const char *srcstr, struct float_operand *retvalue);
float float_operand_to_float(struct float_operand src_operand);
float input_operand_trans_calc(struct float_operand  *float_operand_stc, int num, char *operation, struct float_operand  *ret_operand_stc);
int input_calc_match_result(struct float_operand  input_operand_stc, struct float_operand result_operand_stc);
int get_input_operand(const char *srcstr, struct operand_str **operand_stc, const char *basic);

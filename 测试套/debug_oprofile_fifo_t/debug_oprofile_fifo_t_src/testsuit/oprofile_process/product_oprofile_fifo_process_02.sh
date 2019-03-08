
i=0
line=3000
while :
do
	echo "FUNC_DEFINE(test$i)">>oprofile_fifo_process_02.c
	i=$((i+1))
	if [ $i -gt $line ];then
		break;
	fi
done

echo "void call_all()" >>oprofile_fifo_process_02.c
echo "{" >>oprofile_fifo_process_02.c
i=0
while :
do
	echo "test$i();">>oprofile_fifo_process_02.c
	i=$((i+1))
	if [ $i -gt $line ];then
		break;
	fi
done

echo "}" >>oprofile_fifo_process_02.c

echo -e "int main(int argc, char* argv[]) \n
{	\n
	int i,n; \n	
	n=atoi(argv[1]);\n
	for(i=0;i<n;i++)\n
        call_all();\n
	return 0;\n
}">>oprofile_fifo_process_02.c


 #!/bin/bash


# if [ $# -lt 1 ];then
#     echo "$0 file"
#     exit 1
# fi

EXP_FILE=`ls *.exp`
for F in $EXP_FILE
do
    sed -i '1i\\#!\/usr\/bin\/expect -f' $F

    LINES=`cat $F |wc -l`

    sed -i ''$LINES'a\exit \$GRET\n\ninteract' $F

    i=0
    while [ 1 ]
    do
        i=`expr $i + 1`
        LSTRING=`cat $F |sed -n "$i"p`
        if [ -z "$LSTRING" ] ; then
            continue
        fi

        FIRST_CHAR=`echo $LSTRING |awk '{print substr($0,1,1)}'`
        if [ "$FIRST_CHAR" == "#" ] ; then
            continue
        fi

        break
    done


    sed -i ''$i'i\source ..\/lib\/gdb_proc.exp\nglobal target_dir\nglobal GRET;\nset GRET 0;\nglobal ARGC;\nglobal GDB_TOOL_DIR\nset ARGC \$argc\nglobal GDBPROMPT\nglobal gdb_prompt\nglobal target_ip\nglobal target_prompt\nglobal inferior_exited_re\nglobal test_username test_password  target_passwd\nglobal GDBSERVER_TOOL_DIR HOST_GDB_TOOL host_ip host_prompt host_passwd FLAG \n\nspawn su \$test_username\nexpect {\n    -timeout 2\n    -re \"Password:\" {\n        send \"\$test_password\\n\"\n        gdb_test \"whoami\" \"\$test_username\"\n    }\n    timeout {\n        gdb_test \"whoami\" \"\$test_username\"\n        if { \$GRET != 0 } {\n        send_user \"timeout su\"\n        }\n    }\n}\n\nif { \$GRET != 0 } {\n    send_user \"su \$test_username fail \"\n    exit \$GRET\n}\n\nssh_on_to_target \n\n if { \$GRET } {\n    send_user \"ssh on to \$target_ip fail\"\n    exit \$GRET\n }\n\nset target_prompt \"\/tmp\/for_gdbserver_test\/gdbserver.base\"\ngdb_test \"cd \$target_prompt\" \"\$target_prompt\"\ngdb_test \"export LD_LIBRARY_PATH=\$target_prompt\" \"\$target_prompt\"\n\nset testfile \"advance\"\nset srcfile \${testfile}.c\ngdb_test \"|\$GDBSERVER_TOOL_DIR|gdbserver \$host_ip:1111 \$testfile &\" \"\$gdb_prompt\"\ngdb_test \"exit\"  \"\$host_prompt\"\n\ngdb_test \"export LD_LIBRARY_PATH=.\"  \"\$host_prompt\"\ngdb_test \"\$HOST_GDB_TOOL \$testfile\" \"\$gdb_prompt\"\ngdb_test \"target remote \$target_ip:1111\" \"Remote debugging using \$target_ip:1111.\*\$gdb_prompt\"\n\ngdb_test \"set solib-search-path .\" \"\$gdb_prompt\"\n' $F

done

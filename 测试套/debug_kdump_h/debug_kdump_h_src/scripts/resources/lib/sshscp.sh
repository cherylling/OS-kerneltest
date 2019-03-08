#! /bin/sh




exelocal=1



####
#### Usage: sshcmd cmd testmathineip [password] [user]
#####     password:default huawei 
#####     user:root
#####     eg: sshcmd ls 128.20.76.3 huawei root
### Value of the sshcmd return:
### return 13: it means can not connect the mathine or password is wrong
### return 0: command execute successfully
### return others: command execute wrongly
####


sshcmd_comm()
{

	srccommand=$1
	descommand=$2
	password=${3-huawei}
	r_option=$4
	timeout=5

	if [ "$1x" = "x" ]; then
		echo "ssh_password cmd targetip [password] [user]"
		return 1
	fi

        if [ "x$srccommand" = "x" -o "x$descommand" = "x" ];then
                echo "wrong "
                exit 1
        fi

	if [ $r_option = 1 ]; then
		r_option="-r"
	else
		r_option=""
	fi

	expect <<-END1
		## set infinite timeout, because some commands maybe execute long time. 
		set timeout -1
	
		## remotly exectue command
		spawn scp -o "ConnectTimeout ${timeout}" ${r_option} $srccommand $descommand

		expect {

			#first connect, no public key in ~/.ssh/known_hosts

			"Are you sure you want to continue connecting (yes/no)?" {

				send "yes\r"

				expect -re "\[P|p]assword:"

				send "${password}\r"

			}

			## already has public key in ~/.ssh/known_hosts
			-re "\[P|p]assword:" {

				send "${password}\r"
          		}

			## connect target mathine time out
			timeout {
				send_user "connection to $targetip timed out: \$expect_out(buffer)\n"
				exit 13
        		}

			## Do not need input password. Becauese of ssh 
			eof {
				catch wait result
				#send_user  [lindex \$result 3]
				exit [lindex \$result 3] 
			}
       		}

		### We have input password,and the command may have been execute,except password is wrong or connctione is broken.
       		expect {
			## check exit status of the proccess of ssh 
		 	eof {
				catch wait result
				exit [lindex \$result 3] 
			}

			## Password is wrong!
	        	-re "\[P|p]assword:" {
				send_user "invalid password or account. \$expect_out(buffer)\n"
                		exit 13
        		}

			## timeout again
			timeout {
				send_user "connection to $targetip timed out : \$expect_out(buffer)\n"
				exit 13
			}

    	}
	
	END1

	return $?
}


delete_known_hosts()
{
	known_hosts=~/.ssh/known_hosts
	> ${known_hosts}
}



usage()
{
        echo "Usage: sshscp.sh -s src -d destination [-p login_password] -r"
	echo "       r: scp directory"
}
	
src=
des=

loginuser=root
loginpassword=huawei
r_option=0

while getopts "p:s:d:hr" OPTIONS
do
        case $OPTIONS in
                p) loginpassword="$OPTARG";;
                s) src="$OPTARG";;
                d) des="$OPTARG";;
		r) r_option=1;;
		h) usage; exit 1	
		;;
                \?) echo "ERROR - Invalid parameter"; echo "ERROR - Invalid parameter" >&2;usage;exit 1;;
                *) echo "ERROR - Invalid parameter"; echo "ERROR - Invalid parameter" >&2; usage;exit 1;;
        esac
done


if [ "x$src" = "x" -o "x$des" = "x" ];then
        usage
        exit 1
fi

delete_known_hosts
sshcmd_comm "$src" "$des" "$loginpassword" ${r_option}

exit $?

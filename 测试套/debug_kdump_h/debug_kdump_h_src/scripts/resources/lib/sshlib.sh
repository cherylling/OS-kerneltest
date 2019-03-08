#! /bin/sh
### The ip of test machine
testmachine=""
### The password of test machine
testmachinepassword="huawei"
### timeout for  ssh
timeout=10

set -x

### ssh command. usage: sshcmd "command of romote" ["user"] ["ip"] [password]
###  eg: sshcmd ls root 127.0.0.1"
### exchange key:## export SSHPASS=$password; sshpass -e ssh -o StrictHostKeyChecking=no
sshcmd()
{
    user=root
    testip=${3-${testmachine}}
    password=${4-${testmachinepassword}}
    if [ ! -z $2 ]; then
        user=$2	
    fi

    if [ ! -z $3 ]; then
        testip=$3
    fi

    >~/.ssh/known_hosts
    ##cmd testmathineip [password] [user]
    sshcmd_comm "$1" ${testip} "${password}" ${user} 
    ##ssh -o "ConnectTimeout ${timeout}"  ${user}@${testip}  "$1"

    if [ $? != 0 ]; then
        echo "Wrong When execute command($1) ,user ($user). Time: `date`" >&2 
        return 1
    fi
    return 0

}

### the mathine is up in some time. usage: isup + time testmathine password user

isup()
{

    total=$1
    cur=100
    plus=100

    testmachine=$2
    password=${3-${testmachinepassword}}
    user=${4-root}

    sleep 10
    for((; $cur < $total; cur=$cur+$plus))
    do
        sshcmd "ls > /dev/null" ${user} ${testmachine} ${password} > /dev/null 2>&1

        if [ $? = 0 ]; then
            return 0
        fi	

        ((plus = $plus / 2))

        ## have a check every 30s
        if [ $plus -lt 100 ]; then
            plus=30
        fi
        sleep $plus
    done

    return 1
}



### ten minutes must be up in 600s (ten minites), or I think the machine can not set up
###usage: rebootup testmathine [password] [user]

rebootup()
{
    if [ $# -ne 4 ];then
        echo "params not exact"
        return 1
    fi
    testip=$1
    if [ "x${testip}" = "x" ]; then
        testip=$testmachine
    fi
    password=${2-${testmachinepassword}}
    user=${3-root}
    most_time_up=$4

    isup $most_time_up ${testip} ${password} ${user}
    ret=$?

    return $ret
}


function sshx(){
    ssh -o ConnectTimeout=$timeout $1@$2 $3
}

function scpfile()
{
    file=$3
    for i in $file
    do  
        sshx $1 $2 "rm -fr /tmp/$i"
    done
    scp -r $3 $1@$2:/tmp > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "scp $* to target $TARGET_IP failed"
        return -1
    fi  
}

### get the testcase filename.
getdtsname()
{
    dtsname= basename `pwd`
    #	return $dtsname
}


### get the system boot time
getuptime()
{
    sshcmd "date -d \"\$(awk -F. '{print \$1}' /proc/uptime) second ago\" +\"%Y-%m-%d %H:%M\"" | tail -1
}


sshcmd_comm()
{

	cmd=$1
	testip=$2
	password=${3-huawei}
	user=${4-root}
	

	if [ "$1x" = "x" ]; then
		echo "ssh_password cmd targetip [password] [user]"
		return 1
	fi

	 if [ "x${testip}" = "x" ]; then
                testip=$testmachine
        fi

	### change \ to \\
	#cmd=${cmd//\\/\\\\}
	### change " to \"
	cmd=${cmd//\"/\\\"}
	### change $ to \$
	cmd=${cmd//\$/\\\$}

        if [ "x$testip" = "x" -o "x${cmd}" = "x" ];then
                echo "isup  time testmathine [password] [user]"
                exit 1
        fi
	expect <<-END1
		## set infinite timeout, because some commands maybe execute long time. 
		set timeout -1
	
		## remotly exectue command
		spawn ssh -o "ConnectTimeout ${timeout}" ${user}@${testip} "${cmd}"

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


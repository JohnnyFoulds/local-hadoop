#!/bin/bash 

# get the command line arguments
while getopts :u:p:s:i:h: option
	do
		 case "${option}" in
			u) USER_NAME=${OPTARG};;
			s) SERVER=${OPTARG};;
			i) IP_ADDRESS=${OPTARG};;
			h) HOST_NAME=${OPTARG};;
		 esac
	done

echo '---'
echo $USER_NAME
echo $PASSWORD
echo $SERVER
echo $IP_ADDRESS
echo $HOST_NAME
echo '---'

echo -e "\e[96mCopying remote config script...\e[39m"
scp remote-manconfig.sh $USER_NAME@$SERVER:~/

echo -e "\e[96mExecuting remote config script...\e[39m"
REMOTE_COMMAND="~/./remote-manconfig.sh -i ${IP_ADDRESS} -h ${HOST_NAME}"
ssh -t $USER_NAME@$SERVER $REMOTE_COMMAND

#scp config-manager.sh root@192.168.3.161:~/
#ssh -t root@192.168.3.161 '~/./config-manager.sh'
#!/bin/bash 

# set defaults
USER_NAME=root

# get the command line arguments
while getopts :u:p:s:i:h:d:g:n: option
	do
		 case "${option}" in
			u) USER_NAME=${OPTARG};;
			p) PASSWORD=${OPTARG};;
			s) SERVER=${OPTARG};;
			i) IP_ADDRESS=${OPTARG};;
			h) HOST_NAME=${OPTARG};;
			d) DNS=${OPTARG};;
			g) GATEWAY=${OPTARG};;
			n) NETMASK=${OPTARG};;
		 esac
	done

echo '---'
echo $USER_NAME
echo $PASSWORD
echo $SERVER
echo $IP_ADDRESS
echo $HOST_NAME
echo $DNS
echo $GATEWAY
echo $NETMASK
echo '---'

echo -e "\e[96mCopying remote config script...\e[39m"
sshpass -p $PASSWORD scp -oStrictHostKeyChecking=no remote-manconfig.sh $USER_NAME@$SERVER:~/

echo -e "\e[96mExecuting remote config script...\e[39m"
REMOTE_COMMAND="~/./remote-manconfig.sh -i ${IP_ADDRESS} -h ${HOST_NAME} -d${DNS} -g${GATEWAY} -n${NETMASK}"
sshpass -p $PASSWORD ssh -oStrictHostKeyChecking=no -t $USER_NAME@$SERVER $REMOTE_COMMAND
#!/bin/bash

# get the command line arguments
while getopts :i:h: option
	do
		 case "${option}" in
			i) IP_ADDRESS=${OPTARG};;
			h) HOST_NAME=${OPTARG};;
		 esac
	done

echo '---'
echo "R: $IP_ADDRESS"
echo "R: $HOST_NAME"
echo '---'



# get the network interface to work with
NETWORK_INTERFACE=$(ip addr | sed -n 's/^2: \(.*\):.*/\1/p')

echo $NETWORK_INTERFACE
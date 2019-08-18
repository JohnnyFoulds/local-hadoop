#!/bin/bash

# get the command line arguments
while getopts :i:h:d:g:n: option
	do
		 case "${option}" in
			i) IP_ADDRESS=${OPTARG};;
			h) HOST_NAME=${OPTARG};;
			d) DNS=${OPTARG};;
			g) GATEWAY=${OPTARG};;
			n) NETMASK=${OPTARG};;
		 esac
	done

echo '---'
echo "R: $IP_ADDRESS"
echo "R: $HOST_NAME"
echo "R: $DNS"
echo "R: $GATEWAY"
echo "R: $NETMASK"
echo '---'

# get the network interface to work with
NETWORK_INTERFACE=$(ip addr | sed -n 's/^2: \(.*\):.*/\1/p')

# configure the network settings
configureNetwork() {
	# get the network config file
	NETWORK_CONFIG_PATH="/etc/sysconfig/network-scripts"
	NETWORK_CONFIG_FILE="$NETWORK_CONFIG_PATH/ifcfg-${NETWORK_INTERFACE}"
	
	#make a backup of the network config file
	#cp $NETWORK_CONFIG_FILE "$NETWORK_CONFIG_FILE.bak"
	
	# write the new config file
	(
		echo "BOOTPROTO=static" 
		echo "DEFROUTE=yes"
		echo "IPV4_FAILURE_FATAL=no"
		echo "NAME=ens192"
		echo "DEVICE=ens192"
		echo "ONBOOT=yes"
		echo "IPADDR=${IP_ADDRESS}"
		echo "DNS1=${DNS}"
		echo "GATEWAY=${GATEWAY}"
		echo "NETMASK=${NETMASK}"
	) > $NETWORK_CONFIG_FILE
	
	cat $NETWORK_CONFIG_FILE
}

# disable SELinux
disableSELinux() {
	SEL_CONFIG="/etc/selinux/config"
	
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' $SEL_CONFIG
	
	cat $SEL_CONFIG
}

configureHosts() {
	HOSTS_FILE=/etc/hosts
	
	(
		echo "192.168.3.200	hadoop-manager.lan	hadoop-manager"
		echo "192.168.3.201	hadoop-worker01.lan	hadoop-worker01"
		echo "192.168.3.202	hadoop-worker02.lan	hadoop-worker02"
		echo "192.168.3.203	hadoop-worker03.lan	hadoop-worker03"
	) > $HOSTS_FILE
	
	cat $HOSTS_FILE
}

# configure the network settings
echo -e "\e[96mConfiguring Network Settings...\e[39m"
configureNetwork

# disable the firewall
echo -e "\e[96mDisabling Firewall...\e[39m"
systemctl disable firewalld
systemctl stop firewalld

# disable selinux
echo -e "\e[96mDisabling SELinux...\e[39m"
disableSELinux

# set the hostname
echo -e "\e[96mSetting the hostname...\e[39m"
hostnamectl set-hostname $HOST_NAME

# configure the dns entries for hosts in the cluster
echo -e "\e[96mSetting the cluster DNS entries...\e[39m"
configureHosts

# reboot the machine
echo -e "\e[96mRebooting the server...\e[39m"
reboot -h
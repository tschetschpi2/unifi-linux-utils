#!/bin/bash

#######################################################################
# A simple script for remotely rebooting a Ubiquiti UniFi access point
# Version 2.3 (Mar 28, 2018)
# by Steve Jenkins (http://www.stevejenkins.com/)
#
# Modified by B Duff (https://github.com/tschetschpi2) 3/29/2018 to wait
# for AP to come back up before moving to the next AP to minimize
# distruption to users
#
# Requires bash and sshpass (https://sourceforge.net/projects/sshpass/)
# which should be available via dnf, yum, or apt on your *nix distro.
#
# USAGE
# Update the user-configurable settings below, then run ./uap_reboot.sh from
# the command line. To reboot on a schedule, create a cronjob such as:
# 45 3 * * * /usr/local/bin/unifi-linux-utils/uap_reboot.sh > /dev/null 2>&1 #Reboot UniFi APs
# The above example will reboot the UniFi access point(s) every morning at 3:45 AM.
#######################################################################

# USER-CONFIGURABLE SETTINGS
username=ubnt
password=password
known_hosts_file=/dev/null
uap_list=( 192.168.0.2 192.168.0.3 192.168.1.2 192.168.1.3 )

# SHOULDN'T NEED TO CHANGE ANYTHING PAST HERE
for i in "${uap_list[@]}"; do
	echo "Rebooting UniFi access point at $i..."
	if sshpass -p $password ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=$known_hosts_file $username"@$i" reboot 2>/dev/null; then
		echo "Access point at $i rebooted" 1>&2
		echo "Waiting 15 seconds for AP to shut off"
		sleep 15
		echo -n "Waiting for $i to come back online"
		while [[ `sshpass -p $password ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=$known_hosts_file $username"@$i" exit 2>/dev/null` -ne 0 ]]; do
			sleep 1
		done
		echo -e "\n$i online, sleeping 15 seconds then moving to next AP"
		sleep 15
	else
                echo "Could not reboot access point at $i." 1>&2
	fi
done

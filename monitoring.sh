#!/bin/bash

##
# You have to create a simple script called monitoring.sh. It must be
# developed in bash. At server startup, the script will display some
# information (listed below) on all terminals every 10 minutes (take a
# look at wall). The banner is optional. No error must be visible.
# Your script must always be able to display the following information:
# - The architecture of your operating system and its kernel version.
# - The number of physical processors.
# - The number of virtual processors.
# - The current available RAM on your server and its utilization rate
#   as a percentage.
# - The current available storage on your server and its utilization rate
#   as a percentage.
# - The current utilization rate of your processors as a percentage.
# - The date and time of the last reboot.
# - Whether LVM is active or not.
# - The number of active connections.
# - The number of users using the server.
# - The IPv4 address of your server and its MAC address.
# - The number of command executed with the sudo program.

architecture=$(uname -a)
cpu_physical=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
cpu_virtual=$(grep "processor" /proc/cpuinfo | wc -l)
total_memory=$(free -m | awk '$1 == "Mem:" {print $2}')
used_memory=$(free -m | awk '$1 == "Mem:" {print $3}')
memory_usage=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
total_disk=$(df -Bg | grep '/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
used_disk=$(df -Bm | grep '/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_usage=$(df -Bm | grep '/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft += $2} END {printf("%d"), ut/ft*100}')
cpu_load=$(top -bn1 | grep '%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvm_count=$(lsblk | grep "lvm" | wc -l)
lvm_use=$(if [ $lvm_count -eq 0 ]; then echo no; else yes; fi)
connections_tcp=$(cat /proc/net/sockstat | awk '$1 == "TCP:" {print $3}')
user_log=$(users | wc -w)
ip_addr=$(hostname -I)
mac_addr=$(ip link show | awk '$1 == "link/ether" {print $2}')
sudo=$(journalctl -q _COMM=sudo | grep COMMAND | wc -l)

echo "	#Architecture: ${architecture}
	#CPU physical :  ${cpu_physical}
	#vCPU : ${cpu_virtual}
	#Memory Usage: ${used_memory}/${total_memory}MB (${memory_usage}%)
	#Disk Usage: ${used_disk}/${total_disk}Gb (${disk_usage}%)
	#CPU load: ${cpu_load}
	#Last boot: ${last_boot}
	#LVM use: ${lvm_use}
	#Connections TCP : ${connections_tcp}
	#User log: ${user_log}
	#Network: IP ${ip_addr} (${mac_addr})
	#Sudo :  ${sudo} cmd"

#!/bin/bash

# Arch & kernel
arc=$(uname -a)

# CPUs
pcpu=$(lscpu | grep "^Socket(s):" | awk '{print $2}')
vcpu=$(nproc)

# Memory (MB)
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
pram=$(free -m | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk (GB)
fdisk=$(df -BG --total | grep 'total' | awk '{print $2}' | tr -d 'G')
udisk=$(df -BG --total | grep 'total' | awk '{print $3}' | tr -d 'G')
pdisk=$(awk "BEGIN {printf(\"%.0f\", ($udisk/$fdisk)*100)}")

# CPU load
cpul=$(top -bn1 | grep "Cpu(s)" | awk '{printf("%.1f%%"), $2 + $4}')

# Last boot
lb=$(who -b | awk '{print $3 " " $4}')

# LVM
lvmu=$(if [ "$(lsblk | grep -c "lvm")" -eq 0 ]; then echo no; else echo yes; fi)

# Connections TCP
ctcp=$(ss -neopt state established | wc -l)

# Users
ulog=$(users | wc -w)

# Network
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link show | awk '/ether/ {print $2; exit}')

# Sudo comands
cmds=$(journalctl _COMM=sudo | grep -c COMMAND)

# Output
MESSAGE="  #Architecture: $arc
  #CPU physical: $pcpu
  #vCPU: $vcpu
  #Memory Usage: ${uram}/${fram}MB (${pram}%)
  #Disk Usage: ${udisk}/${fdisk}Gb (${pdisk}%)
  #CPU load: $cpul
  #Last boot: $lb
  #LVM use: $lvmu
  #Connections TCP: $ctcp ESTABLISHED
  #User log: $ulog
  #Network: IP $ip ($mac)
  #Sudo: $cmds cmd"

# Broadcast
HEADER="
Broadcast message from $(whoami)@$(hostname) ($(tty)) at $(date +"%a %b %d %H:%M")"

FULL_MSG="$HEADER

$MESSAGE
"

# Send to all active TTYs
for TTY in /dev/pts/* /dev/tty[1-6]; do
    if [ -w "$TTY" ]; then
        printf "%s\n" "$FULL_MSG" > "$TTY"
    fi
done
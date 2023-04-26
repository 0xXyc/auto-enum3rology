#!/bin/bash

# This script is a massive work-in-progress and will be changed many, many times.
# The motivation behind this script is to mash together MY entire enumeration methodology in an effort to save as much time as possible during engagements or in an exam environment.
# Still deciding on a name... Enum3r8 or Enumerology (enumeration+methodology)

#I decided to create a script with my recommended edits and then keep this one to add comments throughout
# I would recommend placing the commands into functions that you can call later on. This way if you would like to
# test different tools, it's easier to turn them off versus removing or commenting code out.

# I am a fan of ffuf as you will see in the edited script, I rarely use gobuster, feroxbuster or dirsearch anymore,
# But that is a personal preference as each tool has it's pros and cons.

set -e

Red='\033[0;31m'
# Red
Green='\033[0;32m'
# Green
Blue='\033[0;34m'
# Blue
Color_Off='\033[0m'
# No color

if ((EUID != 0)); then
	echo >&2 "Error: script not running as root or with sudo! Exiting..."
	exit 1
fi

echo -e "${Blue}
▓█████ ███▄    █ █    ██ ███▄ ▄███▓█████ ██▀███  ▒█████  ██▓    ▒█████   ▄███▓██   ██▓
▓█   ▀ ██ ▀█   █ ██  ▓██▓██▒▀█▀ ██▓█   ▀▓██ ▒ ██▒██▒  ██▓██▒   ▒██▒  ██▒██▒ ▀█▒██  ██▒
▒███  ▓██  ▀█ ██▓██  ▒██▓██    ▓██▒███  ▓██ ░▄█ ▒██░  ██▒██░   ▒██░  ██▒██░▄▄▄░▒██ ██░
▒▓█  ▄▓██▒  ▐▌██▓▓█  ░██▒██    ▒██▒▓█  ▄▒██▀▀█▄ ▒██   ██▒██░   ▒██   ██░▓█  ██▓░ ▐██▓░
░▒████▒██░   ▓██▒▒█████▓▒██▒   ░██░▒████░██▓ ▒██░ ████▓▒░██████░ ████▓▒░▒▓███▀▒░ ██▒▓░
░░ ▒░ ░ ▒░   ▒ ▒░▒▓▒ ▒ ▒░ ▒░   ░  ░░ ▒░ ░ ▒▓ ░▒▓░ ▒░▒░▒░░ ▒░▓  ░ ▒░▒░▒░ ░▒   ▒  ██▒▒▒ 
 ░ ░  ░ ░░   ░ ▒░░▒░ ░ ░░  ░      ░░ ░  ░ ░▒ ░ ▒░ ░ ▒ ▒░░ ░ ▒  ░ ░ ▒ ▒░  ░   ░▓██ ░▒░ 
   ░     ░   ░ ░ ░░░ ░ ░░      ░     ░    ░░   ░░ ░ ░ ▒   ░ ░  ░ ░ ░ ▒ ░ ░   ░▒ ▒ ░░  
   ░  ░        ░   ░           ░     ░  ░  ░        ░ ░     ░  ░   ░ ░       ░░ ░     
                                                                              ░ ░     
"

echo -e "${Green}                       Created by: https://github.com/jswinss\n"
echo -e "${Blue}Current Version: 0.3\n"
sleep 2

# Placing logic here for command line arg for obtaining IP address to be enumerated through the duration of the script
echo -e "${Red}Disclaimer: Enum3rology is not to be used as a full proof enumeration tool. You should still rely on your manual methodology!\n${Color_Off}"
sleep 1

# Check that an IP address was provided as an argument
if [ $# -ne 3 ]; then
	echo "Usage: $0 <target_ip_address> <target_url> <hostname>"
	exit 1
fi

# Store the IP address in a variable
ip_address=$1
target_url=$2
hostname=$3

echo -e "${Blue}Performing dependency checks:${Color_Off}"
sleep 1
echo -e "${Green}Checking if nmap is installed..."
if ! which nmap >/dev/null; then
	echo -e "Command not found! Install? (y/n) \c"
	read
	if [ "$REPLY" = "y" ]; then
		echo -e ''
		sudo apt-get install nmap
	fi
else
	echo -e "Already installed!"
	echo -e ''
	sleep 1
fi

echo -e "${Green}Checking if dirsearch is installed..."
if ! which dirsearch >/dev/null; then
	echo -e "Command not found! Install? (y/n) \c"
	read
	if [ "$REPLY" = "y" ]; then
		echo -e ''
		sudo apt-get install dirsearch
	fi
else
	echo -e "Already installed!"
	echo -e ''
	sleep 1
fi

echo -e "${Green}Checking if feroxbuster is installed..."
if ! which feroxbuster >/dev/null; then
	echo -e "Command not found! Install? (y/n) \c"
	read
	if [ "$REPLY" = "y" ]; then
		echo -e ''
		sudo apt-get install feroxbuster
	fi
else
	echo -e "Already installed!"
	echo -e ''
	sleep 1
fi

# Print the IP address to the console
echo -e "${Green}Targets:\n         IP: $ip_address"
echo -e "${Green}         Target URL: $target_url"
echo -e "${Green}         Target Hostname: $hostname\n"
read -p "Press ENTER to begin enumerating your target!"
echo -e "${Color_Off}"

# Performs a series nmap scans to the target IP address
rm -rf Enum3rology_Output
mkdir Enum3rology_Output
cd Enum3rology_Output
echo -e "${Blue}Beginning Nmap scans..."
echo -e "Now performing a TCP scan of all 65,535 ports on the target (-sV, -sC. -v):${Color_Off}"
nmap -sV -sC -v $ip_address -oN TCP-Scan
echo -e "${Blue}\nDo you want to conduct a UDP scan on your target?"
echo -e "(y/n)"
read
if [ "$REPLY" = "y" ]; then
	echo ''
	echo -e "${Blue}Now performing a UDP scan of the top 1,000 ports on the target (-sU -sV -sC -v) "
	echo ''
	nmap -sU -sV -sC -v $ip_address -oN UDP-Scan

else
	echo -e "Skipping UDP scan, let's continue enumerating!"
fi

echo -e "\n${Blue}The All scan output will be saved to TCP-scan"
echo -e "The UDP scan output will be saved to UDP-scan${Color_Off}"

# Performs a directory bruteforce on the specified target URL
echo -e "\n${Blue}Beginning directory bruteforce scan on $target_url:${Color_Off}"
dirsearch -u $target_url
echo -e "${Blue}\nBeginning recursive directory bruteforce with Feroxbuster${Color_Off}"
feroxbuster -u $target_url -e -g -o feroxbuster-report.txt #301 broke this. I would move whatweb before nmap to get domain name

# Performs subdomain enumeration of the target_url -- This one requires more testing due to lots of output and a need to re-run with a filter... perhaps put a note at the end of the script saying to do this?
echo -e "\n${Blue}Beginning subdomain enumeration:${Color_Off}"
gobuster dns -d $hostname -w /usr/share/wordlists/dirb/common.txt

# Performs web server fingerprinting with whatweb
echo -e "\n${Blue}Fingerprinting web server with whatweb.${Color_Off}"
TODO #recommend going with -a 1 to reduce requests to the server. It's a tradeoff forsure.
#I tend not to run aggressive scans on machines
whatweb $target_url -a 3 -v
#Here's a one liner I use for whatweb for CTFs and Bug Bounty. You can also set a custom user agent
#for tools so WAFs and other tooling are less likely to detect it.
#whatweb -a 1 -U=$AGENT -t 10 --wait=0.2 http://$IP/

# Performs a vulnerability scan with Nikto
# I stopped using nikto a long time ago. The return on investment is not worth it at least for CTFs it doesn't help me.
echo -e "\n${Blue}Starting vulnerability scan with Nikto. This may take awhile...${Color_Off}"
nikto -h $ip_address -output nikto-output.txt

# -------------------------------------------------------------------------------------------------------------------------------
# Additional Tips Section -- Still need to implement
echo -e "\n${Green}Things that I can't do that you should:"
echo -e "View the source code of the web site of HTML and blank PHP pages for secrets"
echo -e "Visually inspect the web server and manipulate the web app to see if you can get unexpected behavior ;)${Color_Off}"
echo -e "${Blue}Additional commands that should be ran manually:${Color_Off}"
echo -e "ffuf -u $target_url -H "Host: FUZZ.$hostname" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
#I will add some additional commands you can add to the script:
echo -e "ffuf -c -t 10 -rate 100 -p 0.1 -H "User-Agent: $AGENT" -r -ac -o $NAME.md -of md -mc 200,302,403 -w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt -u http://$DOMAIN/FUZZ"
# To-Do List:
# WPScan option
#--------------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

# This script is a massive work-in-progress and will be changed many, many times.
# The motivation behind this script is to mash together MY entire enumeration methodology in an effort to save as much time as possible during engagements or in an exam environment.
# Still deciding on a name... Enum3r8 or Enumerology (enumeration+methodology)

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
echo -e "${Blue}                                Current Version: 0.5\n"

# Placing logic here for command line arg for obtaining IP address to be enumerated through the duration of the script
echo -e "${Red}Disclaimer: Enum3rology is not to be used as a full proof enumeration tool. You should still rely on your manual methodology!\n${Color_Off}"

# Check that an IP address was provided as an argument
if [ $# -ne 3 ]; then
    echo "Usage: $0 <target_ip_address> <target_url> <hostname>"
    exit 1
fi

# Store the IP address and hostnames in variables
ip_address=$1
target_url=$2
hostname=$3

echo -e "${Blue}Performing dependency checks:${Color_Off}"
echo -e "${Green}Checking if nmap is installed..."
if ! which nmap > /dev/null; then
   echo -e "Command not found! Install? (y/n) \c"
   read
   if [ "$REPLY" = "y" ]; 
   then
      echo -e ''
      sudo apt-get install nmap
   fi
else
    echo -e "Already installed!"
    echo -e '' 
fi

echo -e "${Green}Checking if dirsearch is installed..."
if ! which dirsearch > /dev/null; then
   echo -e "Command not found! Install? (y/n) \c"
   read
   if [ "$REPLY" = "y" ]; 
   then
      echo -e ''
      sudo apt-get install dirsearch
   fi
else
    echo -e "Already installed!"
    echo -e ''
fi

echo -e "${Green}Checking if feroxbuster is installed..."
if ! which feroxbuster > /dev/null; then
   echo -e "Command not found! Install? (y/n) \c"
   read
   if [ "$REPLY" = "y" ]; 
   then
      echo -e ''
      sudo apt-get install feroxbuster
   fi
else
    echo -e "Already installed!\n"
fi

# Print the IP address to the console
echo -e "${Green}Targets:\n         IP: $ip_address"
echo -e "${Green}         Target URL: $target_url"
echo -e "${Green}         Target Hostname: $hostname\n"

echo -e "${Blue}\nDo you want to add your target IP and hostname to /etc/hosts?"
echo -e "(y/n)"
read
if [ "$REPLY" = "y" ];
    then
      echo "$1 $3" | sudo tee -a /etc/hosts > /dev/null
      echo -e "${Green}\nAdded target IP and hostname to /etc/hosts!\n"
else
    echo -e "${Green}You must have already added it! Great job, hacker!\n"
fi

read -p "You're ready to rock! Press ENTER to begin enumerating your target!"
echo -e "${Color_Off}"

# Creates an organized, working directory for us
rm -rf Enum3rology_Output
mkdir Enum3rology_Output
cd Enum3rology_Output

# Performs a series nmap scans to the target IP address and a DNS zone transfer attack if port 53 (DNS) is detected from the nmap output
echo -e "${Blue}Beginning Nmap scans..."
echo -e "Now performing a TCP scan of all 65,535 ports on the target (-p- -sV, -sC, -vv, -T4):${Color_Off}"
nmap -p- -sV -sC -vv -T4 -Pn $ip_address -oN TCP-Scan
#nmap_output=$(nmap -p- -sV -sC -vv -T4 $ip_address -oN TCP-Scan)
if cat 'TCP-Scan' | grep -q "53/tcp open"; then
    echo -e "\n${Blue}Port 53 is open, performing zone transfer attack...${Color_Off}"
    dig +short @${1} axfr $3
else
    echo -e "\n${Red}Port 53 is closed, skipping zone transfer attack."
fi
echo -e "${Blue}\nDo you want to conduct a UDP scan on your target? Note: This can take a long time.${Color_Off}"
echo -e "(y/n)"
read
if [ "$REPLY" = "y" ];
    then
      echo -e "\nNow performing a UDP scan of the top 1,000 ports on the target (-sU -sV -sC -v):\n"
      nmap -sU -sV -sC -v $ip_address -oN UDP-Scan
else
    echo -e "Skipping UDP scan, let's continue enumerating!"
fi

echo -e "\n${Blue}The All scan output will be saved to TCP-scan"
echo -e "The UDP scan output will be saved to UDP-scan${Color_Off}"

# Performs a directory bruteforce on the specified target URL
echo -e "\n${Blue}Beginning directory bruteforce scan on $target_url:${Color_Off}"
dirsearch -u $target_url
echo -e "${Blue}\nBeginning recursive directory bruteforce with Feroxbuster...${Color_Off}"
feroxbuster -u $target_url -e -g -o feroxbuster-report.txt

# Performs subdomain enumeration of the target_url -- This one requires more testing due to lots of output and a need to re-run with a filter... perhaps put a note at the end of the script saying to do this?
echo -e "\n${Blue}Beginning subdomain enumeration in DNS mode...${Color_Off}"
gobuster dns -d $hostname -w /usr/share/wordlists/dirb/common.txt
echo -e "${Blue}Beginning subdomain enumeration in VHOST mode...${Color_Off}"
gobuster vhost -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u $hostname -t 50 --append-domain

# Performs web server fingerprinting with whatweb
echo -e "\n${Blue}Fingerprinting web server with whatweb...${Color_Off}"
whatweb $target_url -a 3 -v

# Performs a vulnerability scan with Nikto

echo -e "${Blue}\nDo you want to perform a Nikto Vulnerability Scan?"
echo -e "(y/n)"
read
if [ "$REPLY" = "y" ];
    then
      nikto -h $ip_address -output nikto-output.txt
      echo -e "${Blue}\nPerforming Nikto Vulnerability Scan, results may take awhile...\n"
else
    echo -e "Skipping Nikto Vulnerability Scan, please review the tips section immediately following the script!\n"
fi

# -------------------------------------------------------------------------------------------------------------------------------
# Additional Tips Section
echo -e "${Green}Things that I can't do that you should:"
echo -e "View the source code of the web site of HTML and blank PHP pages for secrets"
echo -e "Visually inspect the web server and manipulate the web app to see if you can get unexpected behavior ;)${Color_Off}"
echo -e "${Blue}\nAdditional commands that should be ran manually:${Color_Off}"
echo -e "ffuf -u $target_url -H 'Host: FUZZ.$hostname' -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
echo -e "Be sure to check if port 53 (DNS) was open and if a zone transfer attack was successful. If it was, add the new hostname to /etc/hosts!"
echo -e "Be sure to run a wpscan if Wordpress is detected. e.g. wpscan --url $target_url --api-token=api-token-here -e"
echo -e "${Red}DO YOUR OSINT: Search EVERY VERSION NUMBER THAT YOU FIND ON GOOGLE AND SEARCHSPLOIT!${Color_Off}"

# To-Do List:
# WPScan option
# Call Python web server or wwwtree
# Ask to start burpsuite at the end of the tool?
# Move to functions?
#--------------------------------------------------------------------------------------------------------------------------------
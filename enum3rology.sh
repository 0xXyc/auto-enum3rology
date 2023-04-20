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
▓█████ ███▄    █ █    ██ ███▄ ▄███▓██▀███  ▒█████  ██▓    ▒█████   ▄███▓██   ██▓
▓█   ▀ ██ ▀█   █ ██  ▓██▓██▒▀█▀ ██▓██ ▒ ██▒██▒  ██▓██▒   ▒██▒  ██▒██▒ ▀█▒██  ██▒
▒███  ▓██  ▀█ ██▓██  ▒██▓██    ▓██▓██ ░▄█ ▒██░  ██▒██░   ▒██░  ██▒██░▄▄▄░▒██ ██░
▒▓█  ▄▓██▒  ▐▌██▓▓█  ░██▒██    ▒██▒██▀▀█▄ ▒██   ██▒██░   ▒██   ██░▓█  ██▓░ ▐██▓░
░▒████▒██░   ▓██▒▒█████▓▒██▒   ░██░██▓ ▒██░ ████▓▒░██████░ ████▓▒░▒▓███▀▒░ ██▒▓░
░░ ▒░ ░ ▒░   ▒ ▒░▒▓▒ ▒ ▒░ ▒░   ░  ░ ▒▓ ░▒▓░ ▒░▒░▒░░ ▒░▓  ░ ▒░▒░▒░ ░▒   ▒  ██▒▒▒ 
 ░ ░  ░ ░░   ░ ▒░░▒░ ░ ░░  ░      ░ ░▒ ░ ▒░ ░ ▒ ▒░░ ░ ▒  ░ ░ ▒ ▒░  ░   ░▓██ ░▒░ 
   ░     ░   ░ ░ ░░░ ░ ░░      ░    ░░   ░░ ░ ░ ▒   ░ ░  ░ ░ ░ ▒ ░ ░   ░▒ ▒ ░░  
   ░  ░        ░   ░           ░     ░        ░ ░     ░  ░   ░ ░       ░░ ░     
                                                                        ░ ░                                                                                                
"

echo -e "${Green}                       Created by: Jacob Swinsinski\n"
echo -e "${Blue}Current Version: 0.1\n"
sleep 2

# Placing logic here for command line arg for obtaining IP address to be enumerated through the duration of the script
echo -e "${Red}Disclaimer: Enum3rology is not to be used as a full proof enumeration tool. You should still rely on your manual methodology!\n${Color_Off}"
sleep 1

# Check that an IP address was provided as an argument
if [ $# -ne 3 ]; then
    echo "Usage: $0 <ip_address> <target_url> <hostname>"
    exit 1
fi

# Store the IP address in a variable
ip_address=$1
target_url=$2
hostname=$3

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
echo -e "\n${Blue}Beginning Nmap scans..."
echo -e "Now performing a TCP scan of all 65,535 ports on the target (-sV, -sC. -v):${Color_Off}"
nmap -sV -sC -v $ip_address -oN TCP-Scan
echo -e "Now performing a UDP scan of the top 1,000 ports on the target (-sU -sV -sC -v):${Color_Off}"
nmap -sU -sV -sC -v $ip_address -oN UDP-Scan

echo -e "\n${Blue}The All scan output will be saved to TCP-scan"
echo -e "The UDP scan output will be saved to UDP-scan${Color_Off}"

# Performs a directory bruteforce on the specified target URL
echo -e "\n${Blue}Beginning directory bruteforce scan on $target_url:${Color_Off}"
dirsearch -u $target_url
echo -e "${Blue}\nBeginning recursive directory bruteforce with Feroxbuster${Color_Off}"
feroxbuster -u $target_url -e -g -o feroxbuster-report.txt

# Performs subdomain enumeration of the target_url -- This one requires more testing due to lots of output and a need to re-run with a filter... perhaps put a note at the end of the script saying to do this?
echo -e "\n${Blue}Beginning subdomain enumeration:${Color_Off}"
gobuster dns -d $hostname -w /usr/share/wordlists/dirb/common.txt

# Performs web server fingerprinting with whatweb
echo -e "\n${Blue}Fingerprinting web server with whatweb.${Color_Off}"
whatweb $target_url -a 3 -v

# Performs a vulnerability scan with Nikto
echo -e "\n${Blue}Starting vulnerability scan with Nikto. This may take awhile...${Color_Off}"
nikto -h $ip_address -verbose -output nikto-output.txt














# Additional Tips Section -- Still need to implement
echo -e "\n${Green}Things that I can't do that you should:"
echo -e "View the source code of the web site of HTML and blank PHP pages for secrets"
echo -e "Visually inspect the web server and manipulate the web app to see if you can get unexpected behavior ;)${Color_Off}"
echo -e "${Blue}Additional commands that should be ran manually:${Color_Off}"
echo -e "ffuf -u $target_url -H "Host: FUZZ.$hostname" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

# To-Do List:
# WPScan option

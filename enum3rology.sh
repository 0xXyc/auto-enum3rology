#!/bin/bash

# I took out dirsearch, feroxbuster, and gobuster and went with ffuf to simplify things. I find ffuf can pretty much do it all with
# less overhead. Additionally, I removed nikto as in my experience I don't really glean anything useful from it on CTFs and it takes way too
# long to run with minimal return on investment.
#I tend to stick to rustscan, ffuf, and whatweb for the majority of my initial linux recon
# I vote Enum3r8 for the tool name.

set -e

Red='\033[0;31m'
# Red
Green='\033[0;32m'
# Green
Blue='\033[0;34m'
# Blue
Color_Off='\033[0m'
# No color

#I decided to remove sudo
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

echo -e "${Green}Created by: https://github.com/jswinss\n"
echo -e "${Red}Edited script by https://github/alexrf45"
sleep 2

# Placing logic here for command line arg for obtaining IP address to be enumerated through the duration of the script
echo -e "${Red}Disclaimer: Enum3rology is not to be used as a full proof enumeration tool. You should still rely on your manual methodology!\n${Color_Off}"
sleep 1

# Check that an IP address and target name are provided as arguments
if [ $# -ne 2 ]; then
	echo "Usage: $0 <target_ip_address> <target_name>"
	exit 1
fi

# Store the IP address in a variable and set User-Agent as desired
ip_address=$1
target_name=$2

#dependency checks are awesome!!
echo -e "${Blue}Performing dependency checks:${Color_Off}"
sleep 1
echo -e "${Green}Checking if nmap, ffuf & whatweb are installed..."
if ! which nmap && which ffuf && which whatweb >/dev/null; then
	echo -e "tools not found! Install? (y/n) \c"
	read
	if [ "$REPLY" = "y" ]; then
		echo -e ''
		sudo apt-get install nmap ffuf whatweb -y -qq >/dev/null
	fi
else
	echo -e "Already installed!"
	echo -e ''
	sleep 1
fi

# Print the IP address to the console
echo -e "${Green}Targets:\n         IP: $ip_address"
echo -e "${Green}         Target Name: $target_name"
read -p "Press ENTER to begin enumerating your target!"
echo -e "${Color_Off}"

# Performs a series nmap scans to the target IP address
if [ -d "./Enum3rology_Output" ]; then
	rm -rf Enum3rology_Output
else
	mkdir Enum3rology_Output && cd Enum3rology_Output
fi

function nmap_scan() {

	echo -e "${Blue}Beginning Nmap scans..."
	echo -e "Now performing a TCP scan of all 65,535 ports on the target (-sV, -sC. -v):${Color_Off}"
	nmap -sV -sC -v $ip_address -oN $target_name-TCP-Scan
	echo -e "${Blue}\nDo you want to conduct a UDP scan on your target?\n${Color_Off}"
	echo -e "(y/n)"
	read
	if [ "$REPLY" = "y" ]; then
		echo ''
		echo -e "${Blue}Now performing a fast UDP scan. re-run manually to confirm results,"
		echo -e "${Blue}as this scan is very fast and sends alot of packets\n adjust --min-rate for unstable targets${Color_Off}"
		sudo nmap -sU --min-rate 10000 -oN $target_name-UDP-Scan $ip_address -v
	else
		echo -e "Skipping UDP scan, let's continue enumerating!"
	fi

	echo -e "\n${Blue}The All scan output will be saved to TCP-scan"
	echo -e "The UDP scan output will be saved to UDP-scan${Color_Off}"
}

# Performs a directory bruteforce on the specified target URL
# I do rate limiting to be more kind to the box. It's more realistic and good to practice.
# I also set a custom user-agent to practice for bug bounty

function ffuf_directory() {
	echo -e "\n${Blue}Beginning directory bruteforce scan on $target_name:${Color_Off}"

	ffuf -c -t 50 -p 0.1 -rate 100 \
		-H "User-Agent: $AGENT" -ac \
		-o $target_name.csv -of csv \
		-mc 200,302,403 \
		-w /usr/share/seclists/Discovery/Web-Content/raft-small-words.txt \
		-u http://$DOMAIN/FUZZ

}

# Performs subdomain enumeration of the target_url using ffuf

# I do rate limiting to be more kind to the box. It's more realistic and good to practice.

function ffuf_subdomain() {
	echo -e "\n${Blue}Beginning subdomain enumeration:${Color_Off}"

	ffuf -c -t 40 -p 0.1 -rate 100 \
		-o $DOMAIN.csv -of csv \
		-H "User-Agent: $AGENT" -ac \
		-H "Host: FUZZ.$DOMAIN" \
		-w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt \
		-u http://$DOMAIN/ \
		-mc 200,403
}

# Performs web server fingerprinting with whatweb

#Here's a one liner I use for whatweb for CTFs and Bug Bounty. You can also set a custom user agent
#for tools so WAFs and other tooling are less likely to detect it.

function whatweb_scan() {
	whatweb -a 1 -t 10 -U="$AGENT" -t 10 --wait=0.2 http://$ip_address/ --log-brief=output.txt
}

#I also added some commands to extract the domain name from whatweb for use in ffuf.
#unfurl must be installed for this to work

#Ref: https://github.com/tomnomnom/unfurl

#quick installation instructions for testing
#wget https://github.com/tomnomnom/unfurl/releases/download/v0.0.1/unfurl-linux-amd64-0.0.1.tgz
#tar xzf unfurl-linux-amd64-0.0.1.tgz
#sudo mv unfurl /usr/bin/

function domain_extract() {
	grep -n ".htb".. output.txt |
		cut -d ' ' -f 10 | cut -d "[" -f 2 | cut -d "]" -f 1 >url.txt &&
		cat url.txt | unfurl domains >domain.txt

}

#exports the domain name to variable for use in ffuf
function domain_add() {
	sudo echo "${ip_address} $(cat domain.txt)" >>/etc/hosts && export DOMAIN=$(cat domain.txt)
}
#web enumeration function execution, I prefer to build functions and then call them later in the script
#This way if I need to remove one I can just remove the desired function call below

echo -e "\n${Blue}Fingerprinting web server with whatweb.${Color_Off}"
whatweb_scan
domain_extract
domain_add
nmap_scan
ffuf_directory
ffuf_subdomain

# -------------------------------------------------------------------------------------------------------------------------------
# Useful Tips Section:
echo -e "\n${Green}Things that I can't do that you should:"
echo -e "View the source code of the web site of HTML and blank PHP pages for secrets"
echo -e "Visually inspect the web server and manipulate the web app to see if you can get unexpected behavior ;)${Color_Off}"

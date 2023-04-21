# auto-enum3rology
Enumeration automation script best suited for web-based engagements.
Enumeration + Methodology = Enumerology
Be sure to add your hostname to your /etc/hosts file prior to using. If I am attacking an HTB box, I simply put box_name.htb.
# Usage
`sudo ./enum3rology.sh <ip_address_here> <target_url_here> <target_hostname_here>`
# What does it look like?
Yes, it was my first big automation script, you know I had to make it look cool.
![image](https://user-images.githubusercontent.com/42036798/233736984-d0c03f11-b1c7-4bab-a9de-bd6f791a715a.png)
# Capabilities
- Dependency checking
- Nmap (UDP and TCP scans)
- Directory bruteforcing with `feroxbuster` and `dirsearch`
- Subdomain enumeration with `gobuster` and `ffuf`
- Fingerprinting with `whatweb`
- Vulnerability scanning with `Nikto`
- Places all tool output neatly in a directory named "Enum3rology_Output"
# To-do
- If port 53 is open, conduct DNS reconaissance (i.e. zone transfer attack `dig axfr test.htb @IP_of_target` to broaden attack surface and append new findings to /etc/hosts
- Add additional tips -- analyze source code, load burp and manipulate web app, etc.
- Deciding whether `enum4linux` is necessary or not

# auto-enum3rology
Enumeration automation script best suited for web-based engagements.
Enumeration + Methodology = Enumerology
Be sure to add your hostname to your /etc/hosts file prior to using. If I am attacking an HTB box, I simply put box_name.htb.
# Usage
`sudo ./enum3rology.sh <ip_address_here> <target_url_here> <target_hostname_here>`
# What does it look like?
Yes, it was my first big automation script, you know I had to make it look cool.
![image](https://user-images.githubusercontent.com/42036798/234483284-a6281abe-c1f9-4769-a702-4c62bbf1a6d3.png)# Capabilities
- Dependency checking
- Nmap (UDP and TCP scans)
- Directory bruteforcing with `feroxbuster` and `dirsearch`
- Subdomain enumeration with `gobuster` and `ffuf`
- Fingerprinting with `whatweb`
- Vulnerability scanning with `Nikto`
- Places all tool output neatly in a directory named "Enum3rology_Output"
- DNS (Port 53) Zone Transfer Attack
- Add target IP and hostname to /etc/hosts (this is optional)
# To-do
- Deciding to add an option to start burpsuite after the script has finished
- Should we add an option to start a python web server `python3 -m http.server`? `wwwtree`?
- Is Nikto Useless? I added an option because of this thought
- Should we implement functions?
- Add additional tips -- analyze source code, load burp and manipulate web app, etc.
- Deciding whether `enum4linux` is necessary or not

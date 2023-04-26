# auto-enum3rology
Enumeration automation script best suited for web-based engagements.
Enumeration + Methodology = Enumerology

# Usage as an executable script 
***Ensure PATH is set***
```
chmod +x enum3rology.sh && sudo mv enum3rology.sh /usr/local/bin/

sudo enum3rology.sh IP TARGET_NAME
```

# What does it look like?
Yes, it was my first big automation script, you know I had to make it look cool.
![image](https://user-images.githubusercontent.com/42036798/233736984-d0c03f11-b1c7-4bab-a9de-bd6f791a715a.png)
# Capabilities
- Dependency checking
- Nmap (UDP and TCP scans)
- Directory bruteforcing with `ffuf`
- Subdomain enumeration with `ffuf`
- Fingerprinting with `whatweb` & domain name extraction
- Places all tool output neatly in a directory named "Enum3rology_Output"
# To-do
- If port 53 is open, conduct DNS reconaissance (i.e. zone transfer attack `dig axfr test.htb @IP_of_target` to broaden attack surface and append new findings to /etc/hosts
- Add additional tips -- analyze source code, load burp and manipulate web app, etc.
- Configure if statements to use ffuf on IP if domain name is not discovered during whatweb

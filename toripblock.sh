#!/bin/bash

#Installing custom rules for ModSecurity
#Block Tor nodes and exit nodes
clear

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo "Would you like to block Tor nodes and exit nodes with ModSecurity? (y/n/e)"
echo "y=yes | n=no | e=exit"
echo " "

#Adding the rules

read -n1 -r yesorno
echo " "

if [ "$yesorno" = y ]; then
	cd /opt || { echo "Failed going to /opt"; exit 1; }
	git clone https://github.com/SecOps-Institute/Tor-IP-Addresses
	cd /etc/nginx/modsec/coreruleset-3.3.2/ || { echo "Failed to change directory"; exit 1; }
	sed -i '96s/SecDefaultAction "phase:1,log,auditlog,pass"/SecDefaultAction "phase:1,log,auditlog,drop"/g' /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
	echo '#Added Tor Blocking List 
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-nodes.lst" "id:50068,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
	echo '#Added Tor Blocking List
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-exit-nodes.lst" "id:50067,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
	echo " "
    echo " "
    echo "Would you like to add the optional rule to see if it works properly? (y/n/e)"
    echo " "
    read -n1 -r -p "Answer: " test
        if [ "$test" = y ]; then
            echo '#Test on self
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/test.txt" "id:50001,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            echo " "
            echo "Whats your local IP address?"
            echo "Hint: You can find this by using hostname -I"
            echo " "
            read -r -p "Answer: " ip
            touch /opt/test.txt
            echo "$ip" >> /opt.test.txt
            echo "Test rule added."
            echo " "
            echo "Once you have completed the test, you can comment out the test rule, or delete it from the ruleset located at: /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
            echo " "
            echo "You can also delete /opt/test.txt as it's no longer needed after the test."
            echo " "
        elif [ "$test" = n ]; then
            echo " "
            echo "Skipping test..."
            return
        elif [ "$test" = e ]; then
            echo " "
            echo "Exiting. Goodbye!"
            exit 1
        else
            return
        fi
elif [ "$yesorno" = n ]; then
    echo " "
    echo "Not adding Tor Blocking Rule."
elif [ "$yesorno" = e ]; then
    echo " "
    echo "Exiting. Goodbye!"
    exit 1
else
    echo " "
    echo "Not a valid answer. Goodbye!"
    exit 1
fi

echo " "
echo " "
echo "Script complete. Goodbye!"
exit 1
#!/bin/bash

#Testing and adding user agents to blacklist

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Enter IP Address:"
read string
if grep -qF "$string" /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt; then
        echo " "
        echo "User-Agent Already Added to the Blacklist."
else
        echo "$string" >> /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt
        echo " "
        echo "User-Agent Added to the Blacklist"
fi
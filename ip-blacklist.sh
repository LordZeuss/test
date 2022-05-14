#!/bin/bash

#This script checks the blacklist for certain IP addresses and will add them to the block list if not added already

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "Enter IP Address:"
read string
if grep -qF "$string" /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt; then
        echo " "
        echo "IP Already Added to the Blacklist"
else
        echo "$string" >> /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt
        echo " "
        echo "IP Added to the Blacklist"
fi
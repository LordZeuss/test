#!/bin/bash

#Installing custom rules for ModSecurity
#(Block Non-US IP's)
clear

read -n1 yesorno

echo "Would you like to install OWASP custom rules to block non US IP's? (y/n/e)"
echo "y=yes | n=no | e=exit"
echo " "

if [ "$yesorno" = y]; then
#Install unzip and install coreruleset v3.3.2
  cd /etc/nginx/modsec
  wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
  yes | sudo dnf install unzip
  sudo unzip v3.3.2.zip -d /etc/nginx/modsec
  sudo cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
  echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
Include /etc/nginx/modsec/coreruleset-3.3.2/rules/*.conf" >> /etc/nignx/modsec/modsec-config.conf
#Test for functionality with nginx
  clear
  sudo nginx -t
  echo "The test should be successful if there is no errors."
  sleep 2
#Install GeoIP and covert it to a readable binary
  yes | sudo dnf install GeoIP
  yes | sudo yum install GeoIP
  yes | sudo dnf install geoip-devel
  yes | sudo yum install geoip-devel
  #Installed dependencies above.
  cd /etc/nginx/modsec
  git clone https://github.com/emphazer/GeoIP_convert-v2-v1
  cd GeoIP_convert-v2-v1
  chmod +x geoip_convert-v2-v1.sh
  ./geoip_convert-v2-v1.sh qsM9nImOBvlL
  #qsM9nImOBvlL is the license key for the geoip database
  sudo mkdir /etc/nginx/modsec/coreruleset-3.3.2/data
  sudo mkdir /etc/nginx/modsec/coreruleset-3.3.2/custom
  sudo touch geoip-allow.conf
  echo "SecGeoLookupDb ../data/GeoIP_country.dat
#SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,drop,msg:'Non-US IP address'"
SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,deny,log,msg:'Non-US IP address'"
#SecRule GEO:COUNTRY_CODE "!@streg US"
SecRule GEO:COUNTRY_CODE "!@pm US" >> /etc/nginx/modsec/coreruleset-3.3.2/custom/geoip-allow.conf
echo "Include /etc/nginx/modsec/coreruleset-3.3.2/custom/*.conf" >> /etc/nginx/modsec/modsec-config.conf
  read -n8 -p "Enter todays date in yyyymmdd format: " date
  cd $date
  sudo mv GeoIP_country.dat /etc/nginx/modsec/coreruleset-3.3.2/data/
#restart to apply
    read -n1 -p "Would you like to restart NGINX for these changes to apply? (y/n/e)" restart
    if [ "$restart" = y ]; then
      sudo systemctl restart nginx
      echo " "
      echo "NGINX should have successfully restarted."
      echo "To see status use: systemctl status nginx"
      echo " "
    elif [ "$restart" = n ]; then
      echo "Skipping Restart..."
      exit 1
    elif [ "$restart" = e]; then
      echo "Exiting..."
      exit 1
    else
      echo "Not a valid answer. Exiting..."
      exit 1
    fi
elif [ "$yesorno" = n ]; then
  echo "Not adding OWASP Custom Ruleset."
  exit 1
elif [ "$yesorno" = e ]; then
  echo "Exiting..."
  exit 1
else
  exit 1
fi

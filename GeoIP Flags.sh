#!/bin/bash

#Installing Geoip for ModSecurity

clear

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts ":hH" help; do
    case ${help} in
        h ) echo "This is the help menu. 

If you would like to add OWASP Core Ruleset, use the flag [-c] or [-C].

If you would like to install and configure GeoIP with ModSecurity, use the flag [-g] or [-G].

If you would like to test if Nginx is configured properly, use the flag [-t] or [-T].

If you would like to restart Nginx to apply changes, use the flag [-r] or [-R].
"
            ;;
        H ) echo "This is the help menu. 

If you would like to add OWASP Core Ruleset, use the flag [-c] or [-C].

If you would like to install and configure GeoIP with ModSecurity, use the flag [-g] or [-G].

If you would like to test if Nginx is configured properly, use the flag [-t] or [-T].

If you would like to restart Nginx to apply changes, use the flag [-r] or [-R].
"
            ;;
        \? ) echo "Usage: (-h) or (-H)"
            ;;
    esac
done


#Add Core Ruleset 
while getopts ":cC" core; do
    case ${core} in
        c ) 
            cd /etc/nginx/modsec || { echo "Failed to change directories"; exit 1; }
            wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
            dnf install unzip -y
            unzip v3.3.2.zip -d /etc/nginx/modsec
            cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf"
            echo " "
            echo "Added Coreruleset"
            ;;
        C ) 
            cd /etc/nginx/modsec || { echo "Failed to change directories"; exit 1; }
            wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
            dnf install unzip -y
            unzip v3.3.2.zip -d /etc/nginx/modsec
            cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf"
            echo " "
            echo "Added Coreruleset"
            ;;
        \? ) echo "Use [-h] or [-H] to see the help page."
            ;;
    esac
done

#Testing
while getopts ":tT" test; do
    case ${test} in
        t )    
            nginx -t
            echo "The test should be successful if there is no errors." ;
            ;;
        T )
            nginx -t
            echo "The test should be successful if there is no errors." ;
            ;;
        \? ) echo "Use [-h] or [-H] to see the help page."
            ;;
    esac
done

#Installing GeoIP and Configuring
geoip () {
    dnf install GeoIP -y
    yum install GeoIP -y
    dnf install geoip-devel -y
    yum install geoip-devel -y
    #Installed dependencies above.
    cd /etc/nginx/modsec || { echo "Failed to change directories"; exit 1; }
    git clone https://github.com/emphazer/GeoIP_convert-v2-v1
    cd GeoIP_convert-v2-v1 || { echo "Failed to change directories"; exit 1; }
    chmod +x geoip_convert-v2-v1.sh
    ./geoip_convert-v2-v1.sh qsM9nImOBvlL
     #qsM9nImOBvlL is the license key for the geoip database
    mkdir /etc/nginx/modsec/coreruleset-3.3.2/data
    mkdir /etc/nginx/modsec/coreruleset-3.3.2/custom
    touch geoip-allow.conf
    echo 'SecGeoLookupDb ../data/GeoIP_country.dat
#SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,drop,msg:'Non-US IP address'"
SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,deny,log,msg:'Non-US IP address'"
#SecRule GEO:COUNTRY_CODE "!@streg US"
SecRule GEO:COUNTRY_CODE "!@pm US"' >> /etc/nginx/modsec/coreruleset-3.3.2/custom/geoip-allow.conf
    echo "Include /etc/nginx/modsec/coreruleset-3.3.2/custom/*.conf" >> /etc/nginx/modsec/modsec-config.conf
    echo "Enter todays date in yyyymmdd format: "
    read -r -n8 -p "" date
    cd $date || { echo "Failed to change directories"; exit 1; }
    mv GeoIP_country.dat /etc/nginx/modsec/coreruleset-3.3.2/data/
}

#Installing GeoIP
while getopts ":gG" geoip; do
    case ${geoip} in
        g ) 
            dnf install GeoIP -y
            yum install GeoIP -y
            dnf install geoip-devel -y
            yum install geoip-devel -y
            #Installed dependencies above.
            cd /etc/nginx/modsec || { echo "Failed to change directories"; exit 1; }
            git clone https://github.com/emphazer/GeoIP_convert-v2-v1
            cd GeoIP_convert-v2-v1 || { echo "Failed to change directories"; exit 1; }
            chmod +x geoip_convert-v2-v1.sh
            ./geoip_convert-v2-v1.sh qsM9nImOBvlL
            #qsM9nImOBvlL is the license key for the geoip database
            mkdir /etc/nginx/modsec/coreruleset-3.3.2/data
            mkdir /etc/nginx/modsec/coreruleset-3.3.2/custom
            touch geoip-allow.conf
            echo 'SecGeoLookupDb ../data/GeoIP_country.dat
#SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,drop,msg:'Non-US IP address'"
SecRule REMOTE_ADDR "@geoLookup" "chain,id:22,deny,log,msg:'Non-US IP address'"
#SecRule GEO:COUNTRY_CODE "!@streg US"
SecRule GEO:COUNTRY_CODE "!@pm US"' >> /etc/nginx/modsec/coreruleset-3.3.2/custom/geoip-allow.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/custom/*.conf" >> /etc/nginx/modsec/modsec-config.conf
            echo "Enter todays date in yyyymmdd format: "
            read -r -n8 -p "" date
            cd $date || { echo "Failed to change directories"; exit 1; }
            mv GeoIP_country.dat /etc/nginx/modsec/coreruleset-3.3.2/data/
            ;;
        G ) $geoip
            ;;
        \? ) echo "Use [-h] or [-H] to see the help page."
            ;;
    esac
done

#Restart Nginx to apply changes
while getopts "rR" testing; do
    case ${testing} in
        r )
            systemctl restart nginx
            ;;
        R ) 
            systemctl restart nginx
            ;;
        \? ) 
            echo "Use [-h] or [-H] to see the help page."
    esac
done



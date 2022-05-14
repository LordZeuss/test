#!/bin/bash

#Install NGINX/ModSecurity/CoreRuleSet With Flags

#Followed this guide: https://www.linuxcapable.com/how-to-install-modsecurity-with-nginx-on-rocky-linux-8/

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo " "
echo "This script uses flags to run. Use [-h] or [-H] to see the help menu to get started."
echo " "
echo "Quitting..."
echo " "

#Install Dependencies
while getopts ":dD" depend; do
    case ${depend} in
        d ) 
            dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
            dnf install dnf-utils -y
            yum install epel-release -y
            ;;
        D ) 
            dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
            dnf install dnf-utils -y
            yum install epel-release -y
            ;;
        * ) 
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Installing and starting Nginx v.1.21.1
while getopts ":nN" nginx; do
    case ${nginx} in
        n )
            echo "[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true" >> /etc/yum.repos.d/nginx.repo
        dnf install nginx-1.21.1 -y
        systemctl start nginx
        systemctl enable nginx
            ;;
        N )
            echo "[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true" >> /etc/yum.repos.d/nginx.repo
        dnf install nginx-1.21.1 -y
        systemctl start nginx
        systemctl enable nginx
            ;;
        * ) 
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Installing ModSecurity
while getopts ":mM" modsec; do
    case ${modsec} in
        m ) 
            mkdir /usr/local/src/nginx 
            cd /usr/local/src/nginx || { echo "Failed to change directories"; exit 1; }
            wget http://nginx.org/download/nginx-1.21.1.tar.gz
            tar -xvzf nginx-1.21.1.tar.gz
            dnf install git -y
            git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/
            cd /usr/local/src/ModSecurity/ || { echo "Failed to change directories"; exit 1; }
            yes | dnf install gcc-c++ flex bison yajl curl-devel zlib-devel pcre-devel autoconf automake git curl make libxml2-devel pkgconfig libtool httpd-devel redhat-rpm-config wget openssl openssl-devel nano
            git submodule init
            git submodule update
            #Building and Configuring the binary/module for ModSecurity
            ./build.sh
            ./configure.sh
            make
            make install
            #ModSecurity Nginx connector module
            git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/
            cd /usr/local/src/nginx/nginx-1.21.1 || { echo "Failed to change directories"; exit 1; }
            ./configure --with-compat --add-dynamic-module=/usr/local/src/ModSecurity-nginx
            make modules
            cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/
            sed -i '5i\ load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
            sed -i '18i\ modsecurity on;' /etc/nginx/nginx.conf
            sed -i '19i\ modsecurity_rules_file /etc/nginx/modsec/modsec-config.conf;' /etc/nginx/nginx.conf
            #Editing essential ModSecurity files/folders
            mkdir -p /etc/nginx/modsec
            cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
            sed -i 's/DetectionOnly/On/' /etc/nginx/modsec/modsecurity.conf
            sed -i 's/ABIJDEFHZ/ABCEFHJKZ/' /etc/nginx/modsec/modsecurity.conf
            echo "Include /etc/nginx/modsec/modsecurity.conf" >> /etc/nginx/modsec/modsec-config.conf
            cp /usr/local/src/ModSecurity/unicode.mapping /etc/nginx/modsec/
                ;;
        M ) 
            mkdir /usr/local/src/nginx 
            cd /usr/local/src/nginx || { echo "Failed to change directories"; exit 1; }
            wget http://nginx.org/download/nginx-1.21.1.tar.gz
            tar -xvzf nginx-1.21.1.tar.gz
            dnf install git -y
            git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/
            cd /usr/local/src/ModSecurity/ || { echo "Failed to change directories"; exit 1; }
            yes | dnf install gcc-c++ flex bison yajl curl-devel zlib-devel pcre-devel autoconf automake git curl make libxml2-devel pkgconfig libtool httpd-devel redhat-rpm-config wget openssl openssl-devel nano
            git submodule init
            git submodule update
            #Building and Configuring the binary/module for ModSecurity
            ./build.sh
            ./configure.sh
             make
            make install
            #ModSecurity Nginx connector module
             git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/
            cd /usr/local/src/nginx/nginx-1.21.1 || { echo "Failed to change directories"; exit 1; }
            ./configure --with-compat --add-dynamic-module=/usr/local/src/ModSecurity-nginx
            make modules
            cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/
            sed -i '5i load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
            sed -i '18i modsecurity on;' /etc/nginx/nginx.conf
            sed -i '19i modsecurity_rules_file /etc/nginx/modsec/modsec-config.conf;' /etc/nginx/nginx.conf
            #Editing essential ModSecurity files/folders
            mkdir -p /etc/nginx/modsec
            cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
            sed -i 's/DetectionOnly/On/' /etc/nginx/modsec/modsecurity.conf
            sed -i 's/ABIJDEFHZ/ABCEFHJKZ/' /etc/nginx/modsec/modsecurity.conf
            echo "Include /etc/nginx/modsec/modsecurity.conf" >> /etc/nginx/modsec/modsec-config.conf
            cp /usr/local/src/ModSecurity/unicode.mapping /etc/nginx/modsec/
                ;;
        * ) 
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
                ;;
    esac
done

#Install OWASP CoreRuleSet
while getopts ":cC" core; do
    case ${core} in
        c ) 
            cd /etc/nginx/modsec || { echo "Failed to change directories."; exit 1; }
            wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
            dnf install unzip -y
            unzip v3.3.2.zip -d /etc/nginx/modsec
            cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf" >> /etc/nginx/modsec/modsec-config.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/rules/*.conf" >> /etc/nginx/modsec/modsec-config.conf
            ;;
        C ) 
            cd /etc/nginx/modsec || { echo "Failed to change directories."; exit 1; }
            wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
            dnf install unzip -y
            unzip v3.3.2.zip -d /etc/nginx/modsec
            cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf" >> /etc/nginx/modsec/modsec-config.conf
            echo "Include /etc/nginx/modsec/coreruleset-3.3.2/rules/*.conf" >> /etc/nginx/modsec/modsec-config.conf
            ;;
        * )
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Change firewall rules temp
while getopts ":t" firetemp; do
    case ${firetemp} in
        t )
            firewall-cmd --zone=public --add-service=http
            firewall-cmd --zone=public --add-service=https
            firewall-cmd --reload
            ;;
        * )
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Change firewall rules perm
while getopts ":p" fireperm; do
    case ${fireperm} in
        p ) 
            firewall-cmd --permanent --zone=public --add-service=http
      		firewall-cmd --permanent --zone=public --add-service=https
      		firewall-cmd --reload
            ;;
        * ) 
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#TorBlocking Rule
while getopts ":rR" rules; do
    case ${rules} in
        r )
            cd /opt || { echo "Failed going to /opt"; exit 1; }
	        git clone https://github.com/SecOps-Institute/Tor-IP-Addresses
	        cd /etc/nginx/modsec/coreruleset-3.3.2/ || { echo "Failed to change directory"; exit 1; }
	        sed -i '96s/SecDefaultAction "phase:1,log,auditlog,pass"/SecDefaultAction "phase:1,log,auditlog,drop"/g' /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
	        echo '#Added Tor Blocking List 
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-nodes.lst" "id:50068,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
	        echo '#Added Tor Blocking List
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-exit-nodes.lst" "id:50067,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        R ) 
            cd /opt || { echo "Failed going to /opt"; exit 1; }
	        git clone https://github.com/SecOps-Institute/Tor-IP-Addresses
	        cd /etc/nginx/modsec/coreruleset-3.3.2/ || { echo "Failed to change directory"; exit 1; }
	        sed -i '96s/SecDefaultAction "phase:1,log,auditlog,pass"/SecDefaultAction "phase:1,log,auditlog,drop"/g' /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
	        echo '#Added Tor Blocking List 
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-nodes.lst" "id:50068,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
	        echo '#Added Tor Blocking List
SecRule REMOTE_ADDR "@ipMatchFromFile /opt/Tor-IP-Addresses/tor-exit-nodes.lst" "id:50067,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        * ) 
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Blocking Certain User Agents
while getopts ":uU" agent; do
    case ${agent} in
        u )
            touch /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt
            echo "#Added User Agent Blocking" >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            echo 'SecRule REQUEST_HEADERS:User-Agent "@pmFromFile /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt" "id:77999907,phase:1,t:none,auditlog,drop,severity:2"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        U )
            touch /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt
            echo "#Added User Agent Blocking" >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            echo 'SecRule REQUEST_HEADERS:User-Agent "@pmFromFile /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt" "id:77999907,phase:1,t:none,auditlog,drop,severity:2"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        * )
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Blocking Certain IP Addresses
while getopts ":iI" ipaddr; do
    case ${ipaddr} in
        i )
            touch /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt
            echo "# Added IP Address Blocking" >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            echo 'SecRule REMOTE_ADDR "@ipMatchFromFile /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt" "id:50069,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        I )
            touch /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt
            echo "# Added IP Address Blocking" >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            echo 'SecRule REMOTE_ADDR "@ipMatchFromFile /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt" "id:50069,phase:1,log,drop"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
            ;;
        * )
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
            ;;
    esac
done

#Block all empty User Agents
while getopts ":eE" empty; do
    case ${empty} in
        e )
            echo '#
SecRule &REQUEST_HEADERS:User-Agent "@eq 0" \
     "id:'13009',phase:1,t:none,drop,status:403"
SecRule REQUEST_HEADERS:User-Agent "^$" \
     "id:'13006',phase:1,t:none,drop,status:403"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
        ;;
        E )
            echo '#
SecRule &REQUEST_HEADERS:User-Agent "@eq 0" \
     "id:'13009',phase:1,t:none,drop,status:403"
SecRule REQUEST_HEADERS:User-Agent "^$" \
     "id:'13006',phase:1,t:none,drop,status:403"' >> /etc/nginx/modsec/coreruleset-3.3.2/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
        ;;
        * )
            echo "Not a valid flag. use [-h] or [-H] to see the help menu."
        ;;
    esac
done

#Help Menu
while getopts ":hH" help; do
    case ${help} in
        h )
            echo "HELP MENU:

If you would like to install Nginx, use the [-n] or [-N] flag.

If you would like to install ModSecurity, use the [-m] or [-M] flag.

If you would like to install OWASP CoreRuleSet (ruleset for ModSecurity), use the [-c] or [-C] flag.

If you would like to change the firewall settings, use [-t] or [-T] for a Temporary allowance, or [-p] / [-P] for a Permanent allowance.

If you would like to add a ModSecurity rule to block Tor Nodes, use the [-r] or [-R] flag.

If you would like to add a ModSecurity rule to block certain user agents, use the [-u] or [-U] flag.

If you would like to add a ModSecurity rule to block empty user agents, use the [-e] or [-E] flag.

To apply any changes beyond installing Nginx, use the command: systemctl restart nginx
If you want to make sure that syntax is correct, use the command: nginx -temporary
Make sure you are root for the two above commands, or stick sudo in front of those commands.

#################################################################################################################################################

Nginx
------

Will install the Nginx v1.21.1 -compatable with ModSecurity.

Will start and enable Nginx via systemctl commands inside the script.

-----------------------------------------------------------------------------------------------------

ModSecurity
------------

ModSecurity will installed at the directory /usr/local/src/ModSecurity directory.

The Nginx version with ModSecurity will be installed in the /usr/local/src/nginx directory.

The ModSecurity-Nginx connector module will be instaleld at the /usr/local/src/ModSecurity-nginx directory.

You can find the Nginx, and ModSecurity configuation files located at /etc/nginx and for modsecurity: /etc/nginx/modsec.

(CoreRuleSet will be inside the modsec folder if you install that too.) 
-----------------------------------------------------------------------------------------------------

OWASP CoreRuleSet
------------------

This is the ruleset that works within ModSecurity to do the blocking that you may want to impliment.

The script will install CoreRuleSet v3.3.2 inside the /etc/nginx/modsec directory.

-----------------------------------------------------------------------------------------------------

Firewall Settings
------------------

Sometimes, to expose Nginx to http or https, you need to reload the firewall and or add that rule so it can apply, so you can see Nginx when visiting your local system IP in a web browser.

You can set this to be temporary, where when you reload the firewall it will no longer applied, or you can do it permenatly, where it will always be allowed.

-----------------------------------------------------------------------------------------------------

Tor Blocking Rule
------------------

If you would like to block Tor nodes with a coreruleset rule (using ModSecurity), you can do so with this rule. It will grab the updated list of Tor nodes and exit nodes off of GitHub, and it will then add those IP's to a blocklist.
Those IP addresses will not be blocked. To be specific, the connection they request will be dropped and recieve an error 403.

You can find the list of IP addresses located at /opt/Tor-IP-Addresses in the tor-nodes.lst and tor-exit-nodes.lst files.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------

Blocking User Agents Rule
--------------------------

If you would like to add a rule to coreruleset (using ModSecurity) to block certain user agents, add this rule.

If you would like to block empty user agents, use the [-e] or [-E] flag.

The script will add a blacklist to /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt

You can add the user agents you would like, into the blacklist and it will block them for you.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------

Blocking IP Addresses Rule
---------------------------

If you would like to block certain IP addresses, use the flag [-i] or [-I] to add this rule.

The script will add a blacklist file for IP addresses located at: /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt

You can add IP addresses that you want blocked to that file.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------"
                ;;
            H )
                echo "HELP MENU:

If you would like to install Nginx, use the [-n] or [-N] flag.

If you would like to install ModSecurity, use the [-m] or [-M] flag.

If you would like to install OWASP CoreRuleSet (ruleset for ModSecurity), use the [-c] or [-C] flag.

If you would like to change the firewall settings, use [-t] or [-T] for a Temporary allowance, or [-p] / [-P] for a Permanent allowance.

If you would like to add a ModSecurity rule to block Tor Nodes, use the [-r] or [-R] flag.

If you would like to add a ModSecurity rule to block certain user agents, use the [-u] or [-U] flag.

If you would like to add a ModSecurity rule to block empty user agents, use the [-e] or [-E] flag.

To apply any changes beyond installing Nginx, use the command: systemctl restart nginx
If you want to make sure that syntax is correct, use the command: nginx -temporary
Make sure you are root for the two above commands, or stick sudo in front of those commands.

#################################################################################################################################################

Nginx
------

Will install the Nginx v1.21.1 -compatable with ModSecurity.

Will start and enable Nginx via systemctl commands inside the script.

-----------------------------------------------------------------------------------------------------

ModSecurity
------------

ModSecurity will installed at the directory /usr/local/src/ModSecurity directory.

The Nginx version with ModSecurity will be installed in the /usr/local/src/nginx directory.

The ModSecurity-Nginx connector module will be instaleld at the /usr/local/src/ModSecurity-nginx directory.

You can find the Nginx, and ModSecurity configuation files located at /etc/nginx and for modsecurity: /etc/nginx/modsec.

(CoreRuleSet will be inside the modsec folder if you install that too.) 
-----------------------------------------------------------------------------------------------------

OWASP CoreRuleSet
------------------

This is the ruleset that works within ModSecurity to do the blocking that you may want to impliment.

The script will install CoreRuleSet v3.3.2 inside the /etc/nginx/modsec directory.

-----------------------------------------------------------------------------------------------------

Firewall Settings
------------------

Sometimes, to expose Nginx to http or https, you need to reload the firewall and or add that rule so it can apply, so you can see Nginx when visiting your local system IP in a web browser.

You can set this to be temporary, where when you reload the firewall it will no longer applied, or you can do it permenatly, where it will always be allowed.

-----------------------------------------------------------------------------------------------------

Tor Blocking Rule
------------------

If you would like to block Tor nodes with a coreruleset rule (using ModSecurity), you can do so with this rule. It will grab the updated list of Tor nodes and exit nodes off of GitHub, and it will then add those IP's to a blocklist.
Those IP addresses will not be blocked. To be specific, the connection they request will be dropped and recieve an error 403.

You can find the list of IP addresses located at /opt/Tor-IP-Addresses in the tor-nodes.lst and tor-exit-nodes.lst files.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------

Blocking User Agents Rule
--------------------------

If you would like to add a rule to coreruleset (using ModSecurity) to block certain user agents, add this rule.

If you would like to block empty user agents, use the [-e] or [-E] flag.

The script will add a blacklist to /etc/nginx/modsec/coreruleset-3.3.2/custom/blacklist.txt

You can add the user agents you would like, into the blacklist and it will block them for you.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------

Blocking IP Addresses Rule
---------------------------

If you would like to block certain IP addresses, use the flag [-i] or [-I] to add this rule.

The script will add a blacklist file for IP addresses located at: /etc/nginx/modsec/coreruleset-3.3.2/custom/ip-blacklist.txt

You can add IP addresses that you want blocked to that file.

Restart Nginx to apply changes. 

systemctl restart nginx  -restart
nginx -t 				 -test for errors

-----------------------------------------------------------------------------------------------------"
                ;;
            * )
                echo "Not a valid flag. use [-h] or [-H] to see the help menu."
                ;;
    esac
done
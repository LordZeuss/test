#!/bin/bash

#Install NGINX

#Followed this guide: https://www.linuxcapable.com/how-to-install-modsecurity-with-nginx-on-rocky-linux-8/

clear

echo "Would you like to Install NGINX? (y/n/e)"
echo "y=yes | n=no | e=exit"

read -n1 yesorno
echo " "

if [ "$yesorno" = y ]; then
#Installing pre-req packages
  yes | sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
  yes | sudo dnf install dnf-utils
  yes | sudo yum install epel-release
#Installing nginx
  sudo echo "[nginx-stable]
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
  yes | dnf install nginx-1.21.1
  sudo systemctl start nginx
  sudo systemctl enable nginx
#Installing modsecurity
  sudo mkdir /usr/local/src/nginx && cd /usr/local/src/nginx
  wget http://nginx.org/download/nginx-1.21.1.tar.gz
  tar -xvzf nginx-1.21.1.tar.gz
  yes | sudo dnf install git
  sudo git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/
  cd /usr/local/src/ModSecurity/
  yes | sudo dnf install gcc-c++ flex bison yajl curl-devel zlib-devel pcre-devel autoconf automake git curl make libxml2-devel pkgconfig libtool httpd-devel redhat-rpm-config wget openssl openssl-devel nano
  git submodule init
  git submodule update
  #Building and Configuring the binary/module for ModSecurity
  sudo ./build.sh
  sudo ./configure.sh
  sudo make
  sudo make install
#ModSecurity nginx connector module
  sudo git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/
  cd /usr/local/src/nginx/nginx-1.21.1
  sudo ./configure --with-compat --add-dynamic-module=/usr/local/src/ModSecurity-nginx
  sudo make modules
  sudo cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/
  sed -i '5i load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf
  sed -i '18i modsecurity on;' /etc/nginx/nginx.conf
  sed -i '19i modsecurity_rules_file' /etc/nginx/modsec/modsec-config.conf;
#Editing essential modsecurity files/folders
  sudo mkdir -p /etc/nginx/modsec
  sudo cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
  sed -i 's/DetectionOnly/On/' /etc/nginx/modsec/modsecurity.conf
  sed -i 's/ABIJDEFHZ/ABCEFHJKZ' /etc/nginx/modsec/modsecurity.conf
  echo "Include /etc/nginx/modsec/modsecurity.conf" >> /etc/nginx/modsec/modsec-config.conf
  sudo cp /usr/local/src/ModSecurity/unicode.mapping/etc/nginx/modsec/
#Test nginx
  sleep 1
  echo "Testing nginx..."
  echo " "
  sudo nginx -t
  echo " "
  echo "Test should be successful."
  sleep 1
#Installing OWASP coreruleset
  wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.2.zip
  yes | sudo dnf install unzip
  sudo unzip v3.3.2.zip -d /etc/nginx/modsec
  sudo cp /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf.example /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf
  echo "Include /etc/nginx/modsec/coreruleset-3.3.2/crs-setup.conf" >> /etc/nginx/modsec/modsec-config.conf
  echo "Include /etc/nginx/modsec/coreruleset-3.3.2/rules/*.conf" >> /etc/nginx/modsec/modsec-config.conf
  #test
  sleep 1
  sudo nginx -t
  echo "Test should be successful"
elif [ "$yesorno" = n ]; then
  echo "Not installing NGINX/ModSecurity/OWASP Coreruleset."
  exit 1
elif [ "$yesorno" = e ]; then
  echo "Goodbye!"
  exit 1
else
  echo "Not a valid answer. Exiting..."
  exit 1
fi

##########################################################################

	echo "Do you need to add the http/https service to the firewall (permanently or temporarily)? (y/n)"
  echo "t=temporarily | p=permanently | n=no"
  read -n1 -p "Answer:" firewall
		if [ "$firewall" = y ]; then
        echo " "
        echo "Would you like to allow it temporarily until nginx is restarted or permanently?"
        echo "t=temporarily | p=permanently"
        read -n1 -p "Answer:" answer
          if [ "$answer" = t ]; then
            sudo firewall-cmd --zone=public --add-service=http
            sudo firewall-cmd --zone=public --add-service=https
            sudo firewall-cmd --reload
            echo "Visit http://server_domain_name_or_IP"
          elif [ "$answer" = p ]; then
            sudo firewall-cmd --permanent --zone=public --add-service=http
      			sudo firewall-cmd --permanent --zone=public --add-service=https
      			sudo firewall-cmd --reload
      			echo "Visit http://server_domain_name_or_IP"
          else
            echo "Not a valid answer. Exiting..."
            exit 1
          fi
    elif [ "$firewall" = n ]; then
			echo "Cancelling http/https service addition"
			exit 1
    elif [ "$firewall" = e ]; then
      echo "Goodbye!"
      exit 1
    else
	exit 1
		fi



###Notes###
#Make sure nginx and modsecurity versions work. EX: had to downgrade nginx from 1.21.6 to 1.21.1 for ModSecurity to work.
#Make sure for GeoIP that you have the GeoIP-devel package

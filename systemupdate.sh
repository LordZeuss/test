#!/bin/bash

#Functions
update () { yes | dnf check-update && sudo dnf update && yum check-update && sudo yum update; }



#Update the System
clear

echo "Would you like to update the system? (y/n/e)"
echo "y=yes | n=no | e=exit"

read -n1 yesorno
echo " "

if [ "$yesorno" = y ]; then
	update
elif [ "$yesorno" = n ]; then
	echo "Skipping Update..."
elif [ "$yesorno" = e ]; then
	echo "Goodbye!"
	exit 1
else
	echo "Not a valid answer. Exiting..."
	exit 1
fi

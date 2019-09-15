#!/usr/bin/env bash
#
# ------------------------------------------------------------------------ #
# Script Name:   install_lamp.sh
# Description:   Install lamp stack (Apache, database, PHP).
# Written by:    Amaury Souza
# Maintenance:   Amaury Souza
# ------------------------------------------------------------------------ #
# Usage:
#       $ ./install_lamp.sh
# ------------------------------------------------------------------------ #
# Bash Version:
#              Bash 4.4.19
# ------------------------------------------------------------------------ #

function menuprincipal () {
	clear
	echo " "
	echo $0
	echo " "
	echo "Choose an option below to start!

		1 - Install Apache
		2 - Install Database (MariaDB)
		3 - Install PHP7.2
		4 - Install LAMP Stack
		0 - Exit application"
echo " "
echo -n "Chosen option: "
read opcao
case $opcao in
	1)
		function apache () {
		TIME=2
			echo Updating system...
			sleep $TIME
			apt update && apt upgrade -y
			echo Starting Apache installation... 
			sleep $TIME
			#sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
			#sudo ufw allow http
			#sudo chown www-data:www-data /var/www/html/ -R
			apt install -y apache2 apache2-utils
			sudo systemctl start apache2
			sudo systemctl enable apache2	
			echo " "
				if [ $? -eq 0 ] 
				then
					echo Installed Apache.
				else
					echo Ops, error in your instalation!
				fi
			}
			apache
			read -n 1 -p "<Enter> for main menul"
			menuprincipal
	;;

	2)
		function maria () {
		TIME=2
			echo Starting MariaDB installation...
			sleep $TIME
			sudo apt -y install mariadb-server mariadb-client
			sudo systemctl start mariadb
			sudo systemctl enable mariadb
				if [ $? -eq 0 ]
				then
					echo Now, setting database configuration...
					sleep $TIME
					sudo mysql_secure_installation
					echo " "
					echo Database installed!
					sleep $TIME
				else
					echo Ops, error in your installation.
				fi
			}
			maria
			read -n 1 -p "<Enter> for main menu"
			menuprincipal
	;;

	3)
		function php () {
			echo Starting PHP installation...
			sudo apt install -y php7.2 libapache2-mod-php7.2 php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline
			sudo a2enmod php7.2
			sudo systemctl restart apache2	
			echo " "
			echo PHP installed
			#Test PHP...
			#sudo vim /var/www/html/info.php <?php phpinfo(); ?>
			}
			php
			read -n 1 -p "<Enter> for main menu"
			menuprincipal
	;;

	4)
		function lamp () {
		TIME=2	
			#apache
			echo Starting LAMP Stack instalation... 
			sleep $TIME
			echo Installing Apache...
			sleep $TIME
			apt install -y apache2 apache2-utils
			sudo systemctl start apache2
			sudo systemctl enable apache2
			echo Installing database...
			sleep $TIME
			#banco de dados
			sudo apt -y install mariadb-server mariadb-client
			sudo systemctl start mariadb
			sudo systemctl enable mariadb
			#PHP
			echo Installing PHP...
			sleep $TIME
			sudo apt install -y php7.2 libapache2-mod-php7.2 php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline
			sudo a2enmod php7.2
			sudo systemctl restart apache2
			echo Nice, great work. Instalation ok!
			sleep $TIME
		}
			lamp
			read -n 1 -p "<Enter> for main menu"
			menuprincipal
	;;

	0)
		function sair () {
			TIME=2
			echo " "
			echo Exit application...
			sleep $TIME
			exit 0
		}
		sair
	;;

esac
}
menuprincipal

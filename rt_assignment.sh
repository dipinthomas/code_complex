#!/bin/bash

# ASSUMPTION - This script will run on all ubuntu 11.10 updated machine
#
#Updating the sources list so that latest packages are fetched and riken server is fast
#
sed -i '1i\
deb http://ftp.riken.jp/Linux/ubuntu/ oneiric universe \
deb http://ftp.riken.jp/Linux/ubuntu/ oneiric-updates universe \
deb http://ftp.riken.jp/Linux/ubuntu/ oneiric multiverse \
deb http://ftp.riken.jp/Linux/ubuntu/ oneiric-updates multiverse' /etc/apt/sources.list

#========================================================================================
#TASK 1 -  check nginx, mysql and php is installed, if not present install it. 

rt_var=`id -u`  #cheking if root user or not

if test $rt_var -eq 0;then

echo -e "Checking the packages"
	
	for i in nginx php mysql	
		do 	
		apt-mark showauto | grep $i 1> /dev/null  #This is to check is the package installed
		apa_value=`echo $?`			  #Exit status check
			if test $apa_value -eq 0;then	
				echo -e "\n $i is installed"
			else	
				case $i in
					nginx) apt-get install nginx ;;
					php)	apt-get install php5 && apt-get install php5-fpm && apt-get install php5-mysql ;;
					mysql)	apt-get install mysql-server ;;
					*) 	echo "Package not found" ;;
				esac
			fi
		done

#===============================================================================================================
##TASK 2 & 3: Asking for a new domain name  & Make host file entry for give domain name
#
#It is expected to run the script as root

for ((i=0 ; i<=10 ; i++ ))
 	do
		echo -e " \nPlease enter your prefered domain name\n"     # TASK 2
		
		read  dom_name
		grep $dom_name /etc/hosts 1> /dev/null
		mul_name=`echo $?`	
	
			if test $mul_name -eq 0;then
				echo -e  "\nThe name already exsist please select a new name"
			else 						# TASK 3	
				echo "127.0.0.1 $dom_name"  >> /etc/hosts
				prv_error=`echo $?`				#error checking 
				echo -e "\nYour name has been added"
				i=10
			fi
		done	
##==================================================================================================================
#
##TASK 4 : create nginx conf file for given domain name
##
mkdir /var/www/$dom_name
cd /var/www/$dom_name 

echo -e "server {\n\tlisten 80;
		 \n\tserver_name $dom_name;
 		\n\troot /var/www/$dom_name/;
		\n\t index index.php;
		\n

	location / {
			try_files "'$'"uri "'$'"uri/ /index.php?q="'$'"uri&"'$'"args;		
		}

         \n\tlocation ~ \.php$ {
             	        \nfastcgi_pass 127.0.0.1:9000;
                        \ninclude /etc/nginx/fastcgi_params;}
		}" >> /etc/nginx/sites-available/$dom_name


ln -s /etc/nginx/sites-available/$dom_name /etc/nginx/sites-enabled/$dom_name   #creating a soft link

/etc/init.d/nginx reload 1> /dev/null #Reloading 

echo -e "Config file made" # Final OUTPUT
##=================================================================================================================
#
#
##TASK 5 :Download the file from wordpress site to the domain name entered. 

 #echo "File getting downloaded"

wget http://wordpress.org/latest.tar.gz
tar -xvf lat* 1> /dev.null
cp -r wordpress/* .

#cp -r /home/sdrc/Downloads/wordpress/* /var/www/$dom_name/



#=======================================================================================================
#
#TASK 6: make proper database
#

echo -e "\n Log into mysql database, please provide username and password with previlage"
read db_user
read db_pass

mysqladmin -u $db_user -p$db_pass CREATE $dom_name"_db"   #mysql db creation

db_check=`echo $?`

	if test $db_check -eq 0; then

		echo -e "\nDatabase has been created thankyou"
	else
		echo -e "\n\tSORRY, worng password or username. please try again later"		
	fi

#=============================================================================================================
#
#TASK 6 : make wp-config.php with proper db_configuration
#

#making a backup copy of wp-config.php

cp wp-config-sample.php wp-config-sample.php_back
mv wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${dom_name}_db/g" wp-config.php  
sed -i "s/username_here/${db_user}/g" wp-config.php
sed -i "s/password_here/${db_pass}/g" wp-config.php
#===========================================================================================================
#
#Adding Salt 
#
#

 for i in {1..8..1}
        do

                sed -i "s/put your unique phrase here/hmbsdmnsdfjnaspoiuytrasghjklkjnbvcxcvbnmoijhgf/g" wp-config.php



        done


#
#============================================================================================================

else 
	echo " Sorry you need to be a root user to run this script"
fi


#===========================================================================================================
#
#The Code has been Completed
#


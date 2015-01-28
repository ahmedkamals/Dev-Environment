#!/bin/sh
#
# @file
# Local environment.
#
# Copyright © 2015, Nilecode for internet solutions and applications, Inc. (https://github.com/ahmedkamals)
#
# This file is part of Nilecode server configurations.
# ® Redistributions of files must retain the above copyright notice.
#
# @copyright     Ahmed Kamal (https://github.com/ahmedkamals)
# @link          https://github.com/ahmedkamals/dev-environment
# @package       AK
# @subpackage
# @version       1.0
# @since         2014-10-10 Happy day :)
# @license
# @author        Ahmed Kamal <me.ahmed.kamal@gmail.com>
# @modified      2015-01-25

name=$1
email=$2
environmentType=$3
currentEnvironment=DEVELOPMENT
apachePort=8090
apacheDirectoriesConfigInclude=/etc/apache2/conf-available/includes/directories
apacheHostsConfigInclude=/etc/apache2/conf-available/includes/hosts
projectsPath=/var/www/html/projects
toolsPath=/var/www/tools
authenticationPath=/var/www/authentication

##
# Checking parameters passed to the file.
#
# @param string	$1 	the name of the user.
# @param string	$2 	the email of the user.
#
# @return int 		0 or 1 depending if the all parameters passed or not.
#
checkParameters(){

	if [ ${#name} -eq 0 ]
	then
		echo "Name is missing"
		return 1
	elif [ ${#email} -eq 0 ]
	then
		echo "Email is missing"
		return 1
	else
	 	return 0
	fi

  # If environment value is not passed, then the default value is DEVELOPMENT
	if [ ${#environmentType} -eq 0 ||  ${#environmentType} -eq "D"]
		then

		${#currentEnvironment}=DEVELOPMENT
		return 1
	elif [ ${#environmentType} -eq "P" ]
		then

		${#currentEnvironment}=PRODUCTION
	fi

	# Checking for the number of passed variables
	[ ${#name} -ne 0 && ${#email} -ne 0 ] && return 0 || return 1
}

##
# Checking if directory exists.
#
# @return int 		0 or 1 depending if the all parameters passed or not.
#
isDirectoryExists(){

	[ -d $1 ] && return 0 || return 1
}

##
# Checking if file exists.
#
# @return int 		0 or 1 depending if the all parameters passed or not.
#
isFileExists(){

	[ -f $1 ] && return 0 || return 1
}

printLine(){

	local title=$1
	echo "\n******************************************************************\n $title \n******************************************************************\n"
}

updatePrivilage(){

	printLine "Updating privilage"

	# Using root privilages:
	sudo -v
}

addRepositories(){

	printLine "Adding repositories"

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		# Adding atom PPA:
		sudo add-apt-repository ppa:webupd8team/atom

		# Adding sublime 3 PPA:
		sudo add-apt-repository -y ppa:webupd8team/sublime-text-3

		# Android studio:
		sudo add-apt-repository ppa:paolorotolo/android-studio
	fi
}

addSourcesLists(){

	printLine "Adding sources lists"

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		# Google Chrome:
		wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
		echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

		# Skype:
		echo "deb http://archive.canonical.com/ubuntu/ $(lsb_release -cs) partner" | sudo tee /etc/apt/sources.list.d/skype.list > /dev/null

		# Virtualbox:
		wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
		echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null
	fi
}

update(){

	printLine "Updating"

	# Updating keys:
	sudo apt-key update

	# Updating pacakges:
	sudo apt-get update && sudo apt-get -y upgrade
}

prepare(){

	printLine "Preparing"

}

basicEnvironment(){

	# Installing memcached, mysql-server, curl, phantomjs, mongodb, git, postfix, drush, ruby-sass, ruby-compass, node-less, htop, httpie, rar, unrar-free, oracle-java8-set-default, oracle-java8-installer, apache2-mpm-worker, PHP-APC
	# apache2-utils for apache utilities like apache benchmark "ab"
	sudo apt-get install memcached mysql-server curl phantomjs mongodb git postfix drush ruby-sass ruby-compass node-less htop httpie rar unrar-free
}

devEnvironment(){

	printLine "devEnvironment"

	# Installing phpmyadmin, git-flow, filezilla, mysql-workbench, atom, sublime-text-installer, eclipse, android-studio, google-chrome-stable, skype, virtualbox-4.3, gimp, gparted, vlc, vuze
	sudo apt-get install phpmyadmin git-flow filezilla mysql-workbench atom sublime-text-installer eclipse android-studio google-chrome-stable skype virtualbox-4.3 gimp gparted vlc vuze -y

}

install(){

	printLine "Installing"

	basicEnvironment

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		devEnvironment
	fi
}

javaInstallation(){

	printLine "Java"

	# Adding java PPA:
	sudo add-apt-repository ppa:webupd8team/java

	# Automatically accepting the Oracle license:
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

	# Choosing default Java version:
	#sudo update-alternatives --config java
	#sudo update-alternatives --config javac

	# oracle-java8-set-default automatically set up the Java 8 environment variables
	sudo apt-get install oracle-java8-set-default oracle-java8-installer -y

	# Setting the JAVA_HOME environment variable:
	sudo sh -c "echo 'JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /etc/environment"

	# Reloading the environment variables file:
	source /etc/environment
}

##
# Used to prepare nginx configurations:
#
nginxInstallation(){

	printLine "Nginx"

	# Installing nginx:
	sudo apt-get install nginx -y

	# workerProcesses=`grep processor /proc/cpuinfo | wc -l`
	workerConnections=`ulimit -n`

	# Backing up, if there is no backup:
	if (! isFileExists "/etc/nginx/nginx.conf.orig")
	then

	sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
	sudo chmod a-x /etc/nginx/nginx.conf.orig

	fi

	sudo cp nginx/conf.d/*.conf /etc/nginx/conf.d -R

	sudo cp nginx/sites-available/*.conf /etc/nginx/sites-available -R

	sudo sed -i "s/worker_processes 1;/worker_processes auto;/" nginx/general/nginx.conf
	sudo sed -i "s/worker_connections 768;/worker_connections $workerConnections;/" nginx/general/nginx.conf

	sudo cp nginx/general/nginx.conf /etc/nginx/nginx.conf

	# Testing nginx configurations:
	sudo service nginx configtest
}

##
# Used to prepare varnish configurations:
#
varnishInstallation(){

	printLine "Varnish"

	# Installing varnish
	sudo apt-get install varnish -y

	# Maximum number of open files (for ulimit -n)
	maxOpenFiles=`ulimit -n`

	# Maximum locked memory size (for ulimit -l)
	# Used for locking the shared memory log in memory.  If you increase log size,
	# you need to increase this number as well
	maxLockedMemory=$(ulimit -l)

	# Backing up, if there is no backup
	if (! isFileExists "/etc/default/varnish.orig")
	then

	sudo cp /etc/default/varnish /etc/default/varnish.orig
	sudo chmod a-x /etc/default/varnish.orig

	fi

	if (! isFileExists "/etc/varnish/default.vcl.orig")
	then

	sudo cp /etc/varnish/default.vcl /etc/varnish/default.vcl.orig
	sudo chmod a-x /etc/varnish/default.vcl.orig

	fi

	sudo cp varnish/*.vcl /etc/varnish -R

	sudo sed -i "s/NFILES=131072/NFILES=$maxOpenFiles/" /etc/default/varnish
	sudo sed -i "s/MEMLOCK=82000/MEMLOCK=$maxLockedMemory/" /etc/default/varnish
}

apacheInstallation(){

	printLine "Apache"

	# Installing apache2, apache2-utils, libapache2-mod-fastcgi, cronolog:
	sudo apt-get install apache2 apache2-utils libapache2-mod-fastcgi cronolog  -y

	# libapache2-mod-rpaf The RPAF (Reverse Proxy Add Forward) module will make sure the IP of 127.0.0.1 will be replaced with the IP set in X-Forwarded-For set by Varnish as Apache will doesn't know who connects to it except the host ip address.

	# Enabling actions, fastcgi, rewrite, headers, expires, and macro modules:
	sudo a2enmod actions fastcgi rewrite headers expires macro proxy_fcgi

	# This will reduce the memory footprint of Apache, "negotiation" allows some languages negociation in the HTTP protocol between the browser and the server:
	sudo a2dismod autoindex cgid negotiation

	# Backing up, if there is no backup:
	if (! isFileExists "/etc/apache2/ports.conf.orig")
	then

	sudo cp /etc/apache2/ports.conf /etc/apache2/ports.conf.orig
	sudo chmod a-x /etc/apache2/ports.conf.orig
	fi

	# Check if one of the directories exists:
	if (! isDirectoryExists $apacheDirectoriesConfigInclude)
	then

	sudo mkdir -p $apacheDirectoriesConfigInclude
	sudo mkdir -p $apacheHostsConfigInclude
	fi

	# Changing listening port to be 8000 instead of 80:
	sudo sed -i 's/Listen 80/Listen 8000/' /etc/apache2/ports.conf

	# Copying apache configurations:
	sudo cp apache/conf-available/*.conf /etc/apache2/conf-available/ -R
	sudo cp apache/sites-available/*.conf /etc/apache2/sites-available/ -R

	# Enabling configurations
	sudo a2enconf settings *-macro

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		sudo a2enconf phpmyadmin
	fi

	# Copying virtual host sample:
	sudo cp apache/*.conf /etc/apache2/sites-available/ -R

	# Gracefully restart Apache (this method of restarting won't kill open connections):
	sudo apache2ctl graceful
}

phpInstallation(){

	printLine "PHP"

	# HHVM
	wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
	echo "deb http://dl.hhvm.com/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hhvm.list > /dev/null

	# Installing hhvm, php5, php5-fpm, php5-cli, php5-curl, php5-redis, php5-memcached, php5-mysql, php5-dev, phpunit, re2c, libpcre3-dev
	sudo apt-get install hhvm php5 php5-fpm php5-cli php5-curl php5-redis php5-memcached php5-mysql php5-dev phpunit re2c libpcre3-dev -y

	# Backing up php5-fpm configuration:
	sudo cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.orig

	# Backing up xdebug configuration:
	sudo cp /etc/php5/mods-available/xdebug.ini /etc/php5/mods-available/xdebug.ini.orig

	# Removing execution privilage:
	sudo chmod a-x /etc/php5/mods-available/xdebug.ini.orig


	if [ $currentEnvironment = DEVELOPMENT ]
	then

		# Installing php5-xdebug:
		sudo apt-get install php5-xdebug -y
		sudo sh -c "echo '
		[Remote settings]
		xdebug.remote_autostart=off
		xdebug.remote_connect_back=off
		xdebug.remote_enable=on
		xdebug.remote_log="/var/log/xdebug.log"
		xdebug.remote_handler=dbgp
		xdebug.remote_mode=req
		xdebug.remote_host=localhost
		xdebug.remote_port=9000

		[General]
		xdebug.auto_trace=off
		xdebug.collect_includes=on
		xdebug.collect_params=off
		xdebug.collect_return=off
		xdebug.default_enable=on
		xdebug.extended_info=1
		;xdebug.idekey=netbeans-xdebug
		xdebug.manual_url=http://www.php.net
		xdebug.max_nesting_level=100
		xdebug.show_local_vars=0
		xdebug.show_mem_delta=0
		xdebug.var_display_max_depth = -1
		xdebug.var_display_max_children = -1
		xdebug.var_display_max_data = -1

		[Profiling]
		xdebug.profiler_append=0
		xdebug.profiler_enable=0
		xdebug.profiler_enable_trigger=0
		xdebug.profiler_output_dir=/tmp
		xdebug.profiler_output_name=crc32

		[Trace options]
		xdebug.trace_format=0
		xdebug.trace_output_dir=/tmp
		xdebug.trace_options=0
		xdebug.trace_output_name=crc32' >> /etc/php5/mods-available/xdebug.ini"

	fi

	# Replacing listening port to be $apachePort:
	sudo sed -i "s/Listen 80/Listen $apachePort/" /etc/php5/fpm/pool.d/www.conf
}

environment(){

	printLine "Environment"

	# Configuring time:
	sudo dpkg-reconfigure tzdata

	# Creating projects, tools, and authentication directories:
	sudo mkdir -p $projectsPath
	sudo mkdir -p $toolsPath
	sudo mkdir -p $authenticationPath

	# To best share with multiple users who should be able to write in /var/www, it should be assigned a common group. For example the default group for web content on Ubuntu and Debian is www-data. Make sure all the users who need write access to /var/www are in this group:
	sudo usermod -a -G www-data $USER

	# Then set the correct permissions on projects path:
	sudo chown -R $USER:www-data $projectsPath

	# Additionally, you should make the directory and all directories below it "set GID", so that all new files and directories created under /var/www/html are owned by the www-data group:
	sudo find $projectsPath -type d -exec chmod 2775 {} \;

	# Find all files in /var/www and add read and write permission for owner and group:
	sudo find $projectsPath -type f -exec chmod ug+rw {} \;

	# Appending new line to the end of file:
	sudo find /etc -name "hosts" -exec sed -i '$a\\' {} ";"

	# Applying hosts file:
	sudo sh -c 'echo "\n127.0.0.1 ahmedkamal.com" >> /etc/hosts'
}

sshConfigurations(){

	printLine "SSH"

	# Creating SSH keys:
	ssh-keygen -t rsa -b 2048 -C "$email"
	ssh-keygen -t dsa -b 1024 -C "$email"
	eval $(ssh-agent -s)
	ssh-add
}

gitConfigurations(){

	printLine "Git"

	# Configuring git:
	git config --global user.name "$name"
	git config --global user.email "$email"
	git config --global core.fileMode false
}

composerConfigurations(){

	printLine "Composer"

	# Installing Composer at /usr/local/bin with executer as composer:
	curl -sS https://getcomposer.org/installer | php -- --help
	curl -sS https://getcomposer.org/installer | php -- --check
	curl -sS http://getcomposer.org/installer | sudo php -d suhosin.executor.include.whitelist=phar -- --install-dir=/usr/local/bin --filename=composer

	# Double checking that composer works:
	php -d suhosin.executor.include.whitelist=phar /usr/local/bin/composer about

	# (optional) Update composer:
	sudo php -d suhosin.executor.include.whitelist=phar /usr/local/bin/composer self-update
}

phalconPHPInstallation(){

	printLine "Phalconphp"

	# Phalconphp PPA:
	sudo apt-add-repository ppa:phalcon/stable

	# Installing phalconphp:
	sudo apt-get install php5-phalcon -y

	# On Linux you can easily compile and install the extension from source code.
	#sudo git clone --depth=1 git://github.com/phalcon/cphalcon.git $toolsPath/cphalcon
	#cd $toolsPath/cphalcon/build
	#sudo ./install

	#echo "[cpahlconphp]\n; configuration for cphalconphp module.\n; priority=25\nextension=phalcon.so" | sudo tee /etc/php5/mods-available/cphalconphp.ini > /dev/null

	# Enabling cphalconephp php module:
	#sudo php5enmod cphalconphp

	# Or alternatively:
	# Copying to php5-fpm modules:
	# sudo ln -s /etc/php5/mods-available/cphalconphp.ini /etc/php5/fpm/conf.d/25-cphalconphp.ini
	# Copying to PHP CLI:
	# sudo ln -s /etc/php5/mods-available/cphalconphp.ini /etc/php5/cli/conf.d/25-cphalconphp.ini

	# Installing phalconphp developer tools:
	cd  $toolsPath
#	echo '{
#	    "require": {
#		"phalcon/devtools": "dev-master"
#	    }
#	}' | sudo tee $toolsPath/composer.json
#	sudo composer install
	sudo composer require phalcon/devtools:dev-master

	sudo ln -s $toolsPath/vendor/phalcon/devtools/phalcon.php /usr/bin/phalcon
	sudo chmod ugo+x /usr/bin/phalcon
}


zephirInstallation(){

	printLine "Zephir"

	# Installing zephir:
	cd  $toolsPath
	sudo composer require phalcon/zephir:dev-master
	cd $toolsPath/vendor/phalcon/zephir
	sudo ./install -c
	zephir help
}

nodejsInstallation(){

	printLine "Nodejs"

	# Downloading, and adding nodejs PPA:
	curl -sL https://deb.nodesource.com/setup | sudo bash -

	# Installing nodejs, npm
	sudo apt-get install nodejs npm -y

	# In old releases environment variables needs to be set manually.
	# Setting the NODE_PATH environment variable:
	#sudo sh -c "echo 'NODE_PATH=/usr/local/lib/node_modules' >> /etc/environment"

	# Reloading the environment variables file:
	#source /etc/environment

	# Installing gulp globally, for automated tasks:
	sudo npm install -g gulp grunt-cli bower jade underscore cookie redis memcache socket.io msgpack-js
}

restartServers(){

	printLine "Restarting"

	# Restarting Servers:
	sudo service nginx restart & sudo service varnish restart & sudo service apache2 restart & sudo service php5-fpm restart & sudo service memcached restart
}


start(){

	printLine "Firing it on"

	if ( checkParameters )
	then

		updatePrivilage
		addRepositories
		addSourcesLists
		update
		prepare
		install
		javaInstallation
		nginxInstallation
		varnishInstallation
		apacheInstallation
		phpInstallation
		environment
		sshConfigurations
		gitConfigurations
		composerConfigurations
		phalconPHPInstallation
		zephirInstallation
		nodejsInstallation
		restartServers
	else
	 echo "Invalid number of parameters, command should be like:\n sh dev_env.sh \"<Ahmed Kamal>\" \"<me.ahmed.kamal@gmail.com>\" \"[D|P]\"\n Optional values: \n D = DEVELOPMENT \n P = PRODUCTION \n"
	fi

}

# Firing it on.
start

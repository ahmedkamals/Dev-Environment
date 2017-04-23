#!/bin/sh
#
# @file
# Local environment.
#
# Copyright © 2015, Ahmed Kamal. (https://github.com/ahmedkamals)
#
# This file is part of Ahmed Kamal's server configurations.
# ® Redistributions of files must retain the above copyright notice.
#
# @copyright     Ahmed Kamal (https://github.com/ahmedkamals)
# @link          https://github.com/ahmedkamals/dev-environment
# @package       AK
# @subpackage
# @version       1.0
# @since         2015-01-25 Happy day :)
# @license
# @author        Ahmed Kamal <me.ahmed.kamal@gmail.com>
# @modified      2015-01-25
#

name=$1
email=$2
environmentType=$3
currentEnvironment=PRODUCTION
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

  # If environment value is not passed, then the default value is PRODUCTION:
	if [ ${#environmentType} -eq 0 ||  ${#environmentType} -eq "P"]
		then

		${#currentEnvironment}=PRODUCTION
	elif [ ${#environmentType} -eq "P" ]
		then

		${#currentEnvironment}=DEVELOPMENT
	fi

	# Checking for the number of passed variables:
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
	echo -e "\n******************************************************************\n $title \n******************************************************************\n"
}

updatePrivilage(){

	printLine "Updating privilage"

	# Using root privilages:
	sudo -v
}

prepare(){

	printLine "Preparing"

	apt-get install -y \
	software-properties-common \
	nano \
	wget
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
	sudo apt-get -y update && sudo apt-get -y upgrade
}

basicEnvironment(){

	# Installing phantomjs, redis-server, memcached, mysql-server, mongodb, git, ruby-sass, ruby-compass, node-less, httpie, curl, postfix, htop, rar, unrar-free, xclip
	sudo apt-get install -y \
	build-essential \
	curl \
	phantomjs \
	redis-server \
	memcached \
	mysql-server \
	mongodb \
	git \
	ruby-sass \
	ruby-compass \
	node-less \
	postfix \
	httpie \
	htop \
	rar \
	unrar-free \
	xclip
}

devEnvironment(){

	printLine "devEnvironment"

	# Installing mysql-workbench, phpmyadmin, git-flow, filezilla, atom, sublime-text-installer, eclipse, android-studio, google-chrome-stable, skype, virtualbox-4.3, gimp, gparted, vlc, vuze
	sudo apt-get install -y \
	mysql-workbench \
	phpmyadmin \
	git-flow \
	filezilla \
	atom \
	sublime-text-installer \
	eclipse android-studio \
	google-chrome-stable \
	skype \
	virtualbox-4.3 \
	gimp \
	gparted \
	vlc \
	vuze
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

	# Installing oracle-java8-set-default, oracle-java8-installer
	# oracle-java8-set-default package will automatically set up the Java 8 environment variables
	sudo apt-get install -y oracle-java8-set-default oracle-java8-installer

	# Setting the JAVA_HOME environment variable:
	sudo sh -c "echo 'JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /etc/environment"

	# Reloading the environment variables file:
	source /etc/environment
}

##
# Used to install/configure Nginx:
#
nginxInstallation(){

	printLine "Nginx"

	# Installing nginx:
	sudo apt-get install -y nginx

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

	# Starting Nginx:
	sudo service nginx start
}

##
# Used to install/configure Varnish:
#
varnishInstallation(){

	printLine "Varnish"

	# Installing varnish
	sudo apt-get install -y varnish

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

	# Maximum number of open files (for ulimit -n)
	maxOpenFiles=`ulimit -n`

	# Maximum locked memory size (for ulimit -l)
	# Used for locking the shared memory log in memory.  If you increase log size,
	# you need to increase this number as well
	maxLockedMemory=$(ulimit -l)

	sudo sed -i "s/NFILES=131072/NFILES=$maxOpenFiles/" /etc/default/varnish
	sudo sed -i "s/MEMLOCK=82000/MEMLOCK=$maxLockedMemory/" /etc/default/varnish

	# Starting Varnish:
	sudo service varnish start
}

##
# Used to install/configure Apache:
#
apacheInstallation(){

	printLine "Apache"

	# Installing apache2, apache2-utils, libapache2-mod-fastcgi, cronolog:
	# apache2-utils for apache utilities like apache benchmark "ab"
	# apache2-mpm-worker should be used with fast-cgi.
	sudo apt-get install -y \
	apache2 \
	apache2-utils \
	libapache2-mod-fastcgi \
	cronolog

	# libapache2-mod-rpaf The RPAF (Reverse Proxy Add Forward) module will make sure the IP of 127.0.0.1 will be replaced with the IP set in X-Forwarded-For set by Varnish as Apache will doesn't know who connects to it except the host ip address.

	# Enabling actions, fastcgi, rewrite, headers, expires, macro, proxy_http, and proxy_fcgi modules:
	sudo a2enmod \
	actions \
	fastcgi \
	rewrite \
	headers \
	expires \
	macro \
	proxy_http \
	proxy_fcgi

	# This will reduce the memory footprint of Apache, "negotiation" allows some languages negociation in the HTTP protocol between the browser and the server:
	sudo a2dismod \
	autoindex \
	cgid \
	negotiation

	# Backing up, if there is no backup:
	if (! isFileExists "/etc/apache2/ports.conf.orig")
	then

		sudo cp /etc/apache2/ports.conf /etc/apache2/ports.conf.orig
		sudo chmod a-x /etc/apache2/ports.conf.orig

		# Changing listening port to be 8090 instead of 80:
		sudo sed -i 's/Listen 80/Listen 8090/' /etc/apache2/ports.conf
	fi

	# Check if one of the directories exists:
	if (! isDirectoryExists $apacheDirectoriesConfigInclude)
	then

		sudo mkdir -p $apacheDirectoriesConfigInclude
		sudo mkdir -p $apacheHostsConfigInclude
	fi

	# Copying apache configurations:
	sudo cp apache/conf-available/*.conf /etc/apache2/conf-available/ -R

	# Copying virtual host sample:
	sudo cp apache/sites-available/*.conf /etc/apache2/sites-available/ -R

	# Enabling configurations
	sudo a2enconf settings *-macro

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		sudo a2enconf phpmyadmin
	fi

	# Gracefully restart Apache (this method of restarting won't kill open connections):
	sudo apache2ctl graceful

	# Apache2 status:
	sudo service apache2 status
}

##
# Used to install/configure Environment:
#
environmentConfigurations(){

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
	sudo sh -c 'echo "\n127.0.0.1 ahmedkamal.local local.ahmedkamal.com" >> /etc/hosts'
}

##
# Used to install/configure PHP:
#
phpInstallation(){

	printLine "PHP"

	# HHVM
	wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
	echo "deb http://dl.hhvm.com/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hhvm.list > /dev/null

	# Installing hhvm, php5, php5-fpm, php5-curl, php-apc, php5-redis, php5-memcached, php5-mysql, php5-dev, phpunit, php-codesniffer, drush
	sudo apt-get install -y \
	hhvm \
	php5 \
	php-apc \
	php5-fpm \
	php5-curl \
	php5-gd \
	php5-redis \
	php5-memcached \
	php5-mysql \
	php5-dev \
	phpunit \
	php-codesniffer \
	drush

	# Backing up php5-fpm configuration:
	sudo cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf.orig

	if [ $currentEnvironment = DEVELOPMENT ]
	then

		# Installing php5-xdebug:
		sudo apt-get install -y php5-xdebug

		# Backing up, if there is no backup:
		if (! isFileExists "/etc/php5/mods-available/xdebug.ini.orig")
		then

			# Backing up xdebug configuration:
			sudo cp /etc/php5/mods-available/xdebug.ini /etc/php5/mods-available/xdebug.ini.orig

			# Removing execution privilage:
			sudo chmod a-x /etc/php5/mods-available/xdebug.ini.orig
		fi

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
		\n\n
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
		\n\n
		[Profiling]
		xdebug.profiler_append=0
		xdebug.profiler_enable=0
		xdebug.profiler_enable_trigger=0
		xdebug.profiler_output_dir=/tmp
		xdebug.profiler_output_name=crc32
		\n\n
		[Trace options]
		xdebug.trace_format=0
		xdebug.trace_output_dir=/tmp
		xdebug.trace_options=0
		xdebug.trace_output_name=crc32' >> /etc/php5/mods-available/xdebug.ini"

	fi

	# Replacing listening port to be $apachePort:
	sudo sed -i "s/Listen 80/Listen $apachePort/" /etc/php5/fpm/pool.d/www.conf

	# Starting php5-fpm:
	sudo service php5-fpm start
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
	sudo apt-get install -y php5-phalcon

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

	sudo apt-get install -y \
	re2c \
	libpcre3-dev

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

	# Installing nodejs, npm:
	sudo apt-get install -y \
	nodejs \
	npm

	# In old releases environment variables needs to be set manually.
	# Setting the NODE_PATH environment variable:
	#sudo sh -c "echo 'NODE_PATH=/usr/local/lib/node_modules' >> /etc/environment"

	if [ "${NODE_PATH}" = "" ]; then

		export NODE_PATH=$(npm -g root 2>/dev/null)
	fi

	#node ${1}

	# Reloading the environment variables file:
	#source /etc/environment

	# Installing node-inspector, gulp, grunt-cli, bower, jade, underscore, cookie, redis, memcache, socket.io, msgpack-js, forever, daemon:
	# gulp is used for automated tasks:
	npm install -g \
	node-inspector \
	gulp \
	grunt-cli \
	bower \
	jade \
	underscore \
	cookie \
	redis \
	memcache \
	socket.io \
	msgpack-js \
	forever \
	daemon
}

dockerInstallation(){

	wget -qO- https://get.docker.com/ | sh

	# Create the docker group and add your user.
	sudo usermod -aG docker $USER

}

amazonInstallation(){

	if [ $currentEnvironment = DEVELOPMENT ]
	then
		sudo apt-get install python-pip awscli -y
		sudo pip install awsebcli
		eb --help
		eb --version
	fi
}

jenkisInstallation(){

	wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
	sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
	sudo apt-get -y update
	sudo apt-get install -y jenkins
	sudo service jenkins start
}

startServers(){

	printLine "Restarting"

	# Restarting Servers:
	sudo service memcached start & sudo service redis-server start
}

start(){

	printLine "Firing it on"

	if ( checkParameters )
	then

		updatePrivilage
		prepare
		addRepositories
		addSourcesLists
		update
		install
		javaInstallation
		nginxInstallation
		varnishInstallation
		apacheInstallation
		environmentConfigurations
		phpInstallation
		sshConfigurations
		gitConfigurations
		composerConfigurations
		phalconPHPInstallation
		zephirInstallation
		nodejsInstallation
		dockerInstallation
		amazonInstallation
		jenkisInstallation
		restartServers
	else

	  echo -e "Invalid number of parameters, command should be like:\n sh dev_env.sh \"<Ahmed Kamal>\" \"<me.ahmed.kamal@gmail.com>\" \"[D|P]\"\n Optional values: \n D = DEVELOPMENT \n P = PRODUCTION \n Default is PRODUCTION\n"
	fi

}

# Firing it on.
start

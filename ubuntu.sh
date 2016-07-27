#!/bin/sh

# Print new line with the title
printLine(){

	local title=$1
	echo -e "\n******************************************************************\n $title \n******************************************************************\n"
}

# Updating keys
updateKeys() {

	printLine "Updating keys"
	sudo apt-key -y update
}

# Updating pacakges
update() {

	printLine "Updating packages"
	sudo apt-get -y update
}

# Upgrading pacakges
upgrade() {

	printLine "Upgrading packages"
	sudo apt-get -y upgrade
}

# Cleaning packages
clean() {
	printLine "Cleaning packages"
	sudo apt-get -y clean
}

# Tools Installation
toolsInstallation() {
	sudo apt-get install -y curl libtool
}

# Google Chrome
chromeInstallation() {
	printLine "Google chrome installation"

	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
	updateKeys
	update
	sudo apt-get install -y google-chrome-stable

}

javaInstallation(){

	printLine "Java"

	# Adding java PPA:
	sudo add-apt-repository -y ppa:webupd8team/java

	# Automatically accepting the Oracle license:
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

	# Choosing default Java version:
	#sudo update-alternatives --config java
	#sudo update-alternatives --config javac

	update
	# Installing oracle-java8-set-default, oracle-java8-installer
	# oracle-java8-set-default package will automatically set up the Java 8 environment variables
	sudo apt-get install -y oracle-java8-set-default oracle-java8-installer

	# Setting the JAVA_HOME environment variable:
	sudo sh -c "echo 'JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /etc/environment"

	# Reloading the environment variables file:
	source /etc/environment
}

# IntelliJ installation
intelliJInstallation() {

	printLine "IntelliJ"
	sudo apt-add-repository -y ppa:mmk2410/intellij-idea-community
	update
	sudo apt-get install -y intellij-idea-community
}

# Atom Installation
atomInstallation() {
	# Adding atom PPA:
	sudo add-apt-repository -y ppa:webupd8team/atom
	update
	sudo apt-get install -y atom
}

gitInstallation() {

	sudo apt-get install -y git

	git config --global core.autocrlf false

	# Working with Unix line endings (LF)
	git config --global core.eol LF

	# Prevent pushing all locally modified branches if the branch to push is not specified while 'git push'
	git config --global push.default nothing

	# Ignoring filemode changes for git calculation of file-is-modified
	git config --global core.filemode false

	# If you are too lazy for typing "git checkout", "git status" or "git branch" all the time, it might be useful for you.
	git config --global alias.co checkout
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.br branch
	git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'


	# Colored Branch Names
	#----------------------
	git config --global color.ui auto
}

# Go lang installation
goLangInstallation() {

	printLine "Go lang installation"
	
	local release "go1.6.2.linux-amd64.tar.gz"

	sudo mkdir -p ~/go/bin ~/go/src ~/go/pkg /usr/local/go
	
	wget https://storage.googleapis.com/golang/$relase > /tmp/$relase
	
	sudo tar -zxvf /tmp/$relase -C /usr/local/go	
	sudo rm -rf /tmp/$relase
	
	sudo sh -c "echo '\n# Go configuration
		export GOROOT=/usr/local/go
		export GOPATH=\$HOME/go
		# export GOBIN=\$GOPATH/bin
		export PATH=\$PATH:\$GOROOT/bin' >> ~/.profile"

	source ~/.profile
	
	# Adding protobuffer plugins
	go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
}

# Docker installation
dockerInstallation() {

	curl -fsSL https://get.docker.com/ | sh
}

# Docker machine installation
dockerMachineInstallation() {
	curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
	chmod +x /usr/local/bin/docker-machine && \
	docker-machine version

	sudo wget https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-prompt.bash -O /etc/bash_completion.d/docker-machine-prompt.bash
}
# Docker compose installation
dockerComposeInstallation() {

	sudo chown -R $(whoami) /usr/local/bin\
	 /etc/bash_completion.d

	curl -L https://github.com/docker/compose/releases/download/1.8.0-rc1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \

	chmod +x /usr/local/bin/docker-compose && \

	# Command completion
	curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose

	docker-compose --version
}

# Virtualbox installation
virtualboxInstallation() {

		printLine "Virtualbox installation"

		# The Oracle public key for apt-secure can be downloaded:
		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
		wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
		echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null

		update

		# dkms package to ensure that the VirtualBox host kernel modules (vboxdrv, vboxnetflt and vboxnetadp) are properly updated
	  sudo apt-get install -y virtualbox-5.0 dkms

		wget http://download.virtualbox.org/virtualbox/5.0.24/VBoxGuestAdditions_5.0.24.iso
		sudo mkdir /media/VBoxGuestAdditions
		sudo mount -o loop,ro VBoxGuestAdditions_5.0.24.iso /media/VBoxGuestAdditions
		sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
		rm VBoxGuestAdditions_5.0.24.iso
		sudo umount /media/VBoxGuestAdditions
		sudo rmdir /media/VBoxGuestAdditions
}

# vagrantInstallation
vagrantInstallation() {
		printLine "Vagrant installation"
		sudo apt-get install -y vagrant
}

# Composer installation
composerInstallation() {

	printLine "Composer"

	# Installing php cli
	sudo apt-get install -y php-cli

	# Installing Composer at /usr/local/bin with executer as composer:
	curl -sS https://getcomposer.org/installer | php -- --help
	curl -sS https://getcomposer.org/installer | php -- --check
	curl -sS http://getcomposer.org/installer | sudo php -d suhosin.executor.include.whitelist=phar -- --install-dir=/usr/local/bin --filename=composer

	# Double checking that composer works:
	php -d suhosin.executor.include.whitelist=phar /usr/local/bin/composer about

	# (optional) Update composer:
	sudo php -d suhosin.executor.include.whitelist=phar /usr/local/bin/composer self-update
}

start() {
	update
	upgrade
	toolsInstallation
	chromeInstallation
	javaInstallation
	intelliJInstallation
	atomInstallation
	gitInstallation
        goLangInstallation
	dockerInstallation
	dockerMachineInstallation
	dockerComposeInstallation
	virtualboxInstallation
	vagrantInstallation
	composerInstallation
	clean
}

start

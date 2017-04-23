#! bin/sh

# Installing Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

# Github for homebrew installation.
HOMEBREW_GITHUB_API_TOKEN="TOKEN"

# Environment prpeartions.
prepare() {
  echo -e "HOMEBREW_GITHUB_API_TOKEN=\"${HOMEBREW_GITHUB_API_TOKEN}\"\n" >> $HOME/.profile
}

getBashType() {
  echo $SHELL
}

setAutoCompletion() {
  # Defaulting to /bin/bash.
  COMPLETION_PATH="etc/bash_completion.d"
  case $(getBashType) in
    *bash) ;;
    *zsh)  COMPLETION_PATH="share/zsh/site-functions";;
  esac

  echo -e "\n# Auto Completions:\nHOMEBREW_HOME=\$(brew --prefix)
COMPLETION_PATH=\$(COMPLETION_PATH)
HOMEBREW_BASH_COMPLETION=\${HOMEBREW_HOME}/\${COMPLETION_PATH}\n"
  >> $HOME/.profile

  Completions[0]="\${HOMEBREW_BASH_COMPLETION}/brew"
  Completions[1]="\${HOMEBREW_BASH_COMPLETION}/brew-cask"
  Completions[2]="\${HOMEBREW_BASH_COMPLETION}/git-completion.bash"
  Completions[3]="\${HOMEBREW_BASH_COMPLETION}/git-prompt.sh"
  Completions[4]="\${HOMEBREW_BASH_COMPLETION}/git-flow-completion.bash"
  Completions[5]="\${HOMEBREW_BASH_COMPLETION}/docker"
  Completions[6]="\${HOMEBREW_BASH_COMPLETION}/docker-compose"
  Completions[7]="\${HOMEBREW_BASH_COMPLETION}/docker-machine"
  Completions[8]="\${HOMEBREW_BASH_COMPLETION}/docker-machine-prompt.bash"
  Completions[9]="\${HOMEBREW_BASH_COMPLETION}/docker-machine-wrapper.bash"
  Completions[10]="\${HOMEBREW_BASH_COMPLETION}/composer-completion.sh"
  Completions[11]="\${HOMEBREW_BASH_COMPLETION}/npm"
  Completions[12]="\${HOMEBREW_BASH_COMPLETION}/grunt"
  Completions[13]="\${HOMEBREW_BASH_COMPLETION}/scala"
  Completions[14]="\${HOMEBREW_BASH_COMPLETION}/aws_bash_completer"

  for i in ${Completions[@]}; do
      [ -f $i ] && echo -e "test -e \"$i\" && source \"$i\"" >> $HOME/.profile;
  done
}

# Git installation.
gitInstallation() {
  brew install git \
    git-flow

  git config --global core.autocrlf false

	# Working with Unix line endings (LF).
	git config --global core.eol LF

	# Prevent pushing all locally modified branches if the branch to push is not specified while 'git push'.
	git config --global push.default nothing

	# Ignoring filemode changes for git calculation of file-is-modified.
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
golangInstallation() {
  brew install go \
    golint \
    glide \
    godep \
    grpc/grpc/google-protobuf

    echo -e "\n# Go configurations:
GO_BINARY=\`which go\`
GO_BINARY_DIR=\`dirname \$GO_BINARY\`
GO_RELATIVE_BINARY_DIR=\$(dirname \`readlink \$GO_BINARY\`)
export GOROOT=\`cd \$GO_BINARY_DIR/\$GO_RELATIVE_BINARY_DIR/../libexec; pwd\`
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin:/usr/local/sbin" >> $HOME/.profile
}

# Scala installation.
scalaInstallation() {
  brew cask install java
  brew install scala
}

# PHP installation.
phpInstallation() {
  brew install homebrew/php/php71 \
    homebrew/php/php71-mcrypt \
    homebrew/php/php71-xdebug \
    homebrew/php/phpunit \
    behat \
    selenium-server-standalone \
    homebrew/php/codeception \
    homebrew/php/php-code-sniffer \
    homebrew/php/php-cs-fixer \
    homebrew/php/phpmd \
    homebrew/php/symfony-installer

  echo -e "\n#Xdebug configurations:\nPHP_IDE_CONFIG=\"serverName=Parku\"" >> $HOME/.profile
}

# Composer installation
composerInstallation() {
  brew install homebrew/php/composer \
    homebrew/completions/composer-completion
  # Disabling Xdebug.
  echo 'function composer() { COMPOSER="$(which composer)" || { echo "Could not find composer in path" >&2 ; return 1 ; } && php -n $COMPOSER "$@" ; STATUS=$? ; return $STATUS ; }' >> ~/.bash_aliases
  source ~/.bash_aliases
}

# Docker installation
dockerInstallation() {
	brew install docker \
    homebrew/completions/docker-completion \
  	docker-compose \
    homebrew/completions/docker-compose-completion \
  	docker-machine \
    homebrew/completions/docker-machine-completion \
    docker-machine-nfs \
    docker-swarm \
    Caskroom/cask/docker

  echo -e "\ndocker rm \$(docker ps -aqf status=exited -f status=dead)
docker rmi \$(docker images -aqf dangling=true)
docker volume rm \$(docker volume ls -qf dangling=true)
docker ps -a --format {{.Names}}" >> $HOME/.profile
}

# Softwares.
warezInstallation() {
  xcode-select --install
	brew install wget \
    htop-osx \
    tree \
    npm \
    awscli \
    homebrew/completions/brew-cask-completion \
    Caskroom/cask/google-chrome \
    Caskroom/versions/intellij-idea-ce \
    Caskroom/cask/phpstorm \
    Caskroom/cask/atom \
    Caskroom/cask/iterm2 \
    Caskroom/cask/mysqlworkbench \
    Caskroom/cask/sqlpro-for-mysql \
    Caskroom/cask/virtualbox \
    Caskroom/cask/slack \
  	Caskroom/cask/skype \
    Caskroom/cask/dropbox \
    Caskroom/cask/evernote \
    Caskroom/cask/google-drive \
    Caskroom/cask/google-hangouts \
    Caskroom/cask/1password \
    Caskroom/cask/caffeine \
    Caskroom/cask/grammarly

  npm install -g grunt
}

fire() {
  prepare
  gitInstallation
  golangInstallation
  scalaInstallation
  phpInstallation
  composerInstallation
  dockerInstallation
  warezInstallation
  setAutoCompletion
}

fire

#! bin/bash

# Github for homebrew installation.
HOMEBREW_GITHUB_API_TOKEN="TOKEN"

# Environment prpeartions.
prepare() {
  echo "#Homebrew github token:\nHOMEBREW_GITHUB_API_TOKEN=\"${HOMEBREW_GITHUB_API_TOKEN}\"" >> $HOME/.profile
}

getBashType() {
  echo $SHELL
}

# Homebrew installation.
brewInstallation() {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
}

# Git installation.
gitInstallation() {
  brew install git

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
    glide \
    godep \
    grpc/grpc/google-protobuf

    local GOPATH="$HOME/go"

    echo "\n# Go configurations:
GO_BINARY=\`which go\`
GO_BINARY_DIR=\`dirname \$GO_BINARY\`
GO_RELATIVE_BINARY_DIR=\$(dirname \`readlink \$GO_BINARY\`)
export GOROOT=\`cd \$GO_BINARY_DIR/\$GO_RELATIVE_BINARY_DIR/../libexec; pwd\`
export GOPATH=$GOPATH
export PATH=\$PATH:\$GOPATH/bin:/usr/local/sbin" >> $HOME/.profile

  go get golang.org/x/tools/cmd/cover
}

# Java installation.
javaInstallation() {
    brew cask install java
}

# Scala installation.
scalaInstallation() {
  brew install scala
}

# PHP installation.
phpInstallation() {
  brew install homebrew/php/php72 \
    homebrew/php/php72-mcrypt \
    homebrew/php/php72-xdebug \
    homebrew/php/phpunit \
    behat \
    selenium-server-standalone \
    homebrew/php/codeception \
    homebrew/php/php-code-sniffer \
    homebrew/php/php-cs-fixer \
    homebrew/php/phpmd \
    homebrew/php/symfony-installer

  echo "\n#Xdebug configurations:\nPHP_IDE_CONFIG=\"serverName=Localhost\"" >> $HOME/.profile
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

  echo "# Docker cleaning configuration:
test -n \"\$(docker ps -aqf status=exited -f status=dead)\" && docker rm \$(docker ps -aqf status=exited -f status=dead) || true
test -n \"\$(docker images -aqf dangling=true)\" && docker rmi \$(docker images -aqf dangling=true) || true
test -n \"\$(docker volume ls -qf dangling=true)\" && docker volume rm \$(docker volume ls -qf dangling=true) || true
docker ps -a --format \"{{.ID}} ==> {{.Names}}\"" >> $HOME/.profile
}

# Kubernetes
kubernetesInstallation() {
  brew install kubernetes-cli \
    kubernetes-helm
}

# Softwares.
warezInstallation() {
  #xcode-select --install
	brew install wget \
    tig \
    jq \
    tree \
    htop-osx \
    watch \
    awscli \
    homebrew/completions/brew-cask-completion

    brew cask install google-chrome \
    postman \
    jetbrains-toolbox \
    goland \
    intellij-idea-ce \
    phpstorm \
    atom \
    iterm2 \
    sourcetree \
    mysqlworkbench \
    virtualbox \
    slack \
    skype \
    dropbox \
    evernote \
    google-drive-file-stream \
    google-hangouts \
    caffeine \
    grammarly

    # Atom IDE packages.
    apm install atom-ide-ui \
      ide-php
}

# Commands auto completion.
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

fire() {
  prepare
  brewInstallation
  gitInstallation
  golangInstallation
  javaInstallation
#  scalaInstallation
#  phpInstallation
#  composerInstallation
  dockerInstallation
  kubernetes-helm
  warezInstallation
  setAutoCompletion
}

fire

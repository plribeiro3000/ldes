#!/bin/sh

Main() {
  if [ "$env" = "" ]
  then
    echo "Linux Dev Environment Setup"
    echo "------------------------------------------"
    echo "Options:"
    echo
    echo "1. Install Ruby Dev Enviroment on KDE"
    echo "0. Exit"
    echo
    echo -n "Choose an option:"
    read option
    case $option in
      1) RubyKDE ;;
      0) exit ;;
      *) "Option unknown" ; echo ; Main ;;
    esac
  else
    case $env in
      ruby) RubyKDE ;;
      *) echo "Environment unknown" ; exit ;;
    esac
  fi
}

RubyKDE(){
  su
  sudoers
  apt-get install -y kde-full
  add_repos
  apt-get update
  add_keys
  apt-get update
  apt-get dist-upgrade
  install_basic_pkgs
  install_vim
  install_browsers
  install_database
  install_sunjava
  install_git
  install_nodejs
  install_rvm
}

sudoers(){
  apt-get install sudoers
}

add_repos(){
cat <<EOF >> /etc/apt/sources.list

#Backports
deb http://backports.debian.org/debian-backports squeeze-backports main

#Debian-Multimedia
deb http://www.deb-multimedia.org squeeze main non-free

#Dotdeb
deb http://packages.dotdeb.org squeeze all
deb-src http://packages.dotdeb.org squeeze all

#Opera
deb http://deb.opera.com/opera-beta/ squeeze non-free

#Google
deb http://dl.google.com/linux/deb/ stable main non-free
deb http://dl.google.com/linux/talkplugin/deb/ stable main

#Mozilla
deb http://mozilla.debian.net/ squeeze-backports iceweasel-release
EOF
}

add_keys(){
  apt-get install debian-multimedia-keyring
  wget -q -O - http://www.dotdeb.org/dotdeb.gpg | apt-key add -
  wget -O - http://deb.opera.com/archive.key | apt-key add -
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
  wget http://mozilla.debian.net/pkg-mozilla-archive-keyring_1.0_all.deb
  dpkg -i pkg-mozilla-archive-keyring_1.0_all.deb
  rm pkg-mozilla-archive-keyring_1.0_all.deb
  wget -q -O - http://www.dotdeb.org/dotdeb.gpg | apt-key add -
}

install_basic_pkgs(){
  apt-get install -y gcc make smplayer unrar amarok bash curl
}

install_vim(){
  apt-get install -y vim exuberant-ctags ncurses-term
  git clone git@github.com:plribeiro3000/vimfiles.git ~/.vim --recursive
  echo "source ~/.vim/vimrc" > ~/.vimrc
}

install_browsers(){
  apt-get install -y opera google-chrome-unstable
  apt-get install -t squeeze-backports iceweasel
}

install_database(){
  apt-get install -y mysql-client mysql-server libmysqlclient18 libmysqlclient-dev mysql-workbench
}

install_sunjava(){
  apt-get install -y sun-java6*
  apt-get remove openjdk*
  update-java-alternatives -l
  update-java-alternatives -s java-6-sun
}

install_git(){
  apt-get install -y git-core git-flow qgit
  wget https://raw.github.com/git/git/master/contrib/completion/git-completion.bash -O ~/.git-completion
  echo "source ~/.git-completion" >> ~/.bashrc
  git config --global core.editor "vim"
}

install_nodejs(){
  echo "deb http://ftp.us.debian.org/debian/ sid main" > tmp
  mv tmp /etc/apt/sources.list.d/sid.list
  apt-get update
  apt-get install -y nodejs
  rm /etc/apt/sources.list.d/sid.list
  apt-get update
}

install_rvm(){
  exit
  wget https://get.rvm.io -O rvm
  bash rvm -s stable
  apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
  source ~/.bash_profile
  rvm install 1.8.7
  rvm install 1.9.2
  rvm install 1.9.3
}

display_help(){
  echo "%b" "
Usage

  ./debian [options]

Options

  -v                            - Verbose install
  -e                            - Environment to be installed [ruby]
  -d                            - Set default option to everything
  -h                            - Print this help

  Defaults:
    Any option will prompt the user to choose.
"
}

env=
verbose=false
default=false
while [ $# -gt 0 ]
do
  case "$1" in
    -e)	env="$2" ;;
    -v)	verbose=true ;;
    -d)	default=true ;;
    -h)	display_help
	exit;;
  esac
  shift
done

Main

#!/bin/bash

if [ `whoami` != "ehc" ]; then
echo "You need to be an egghead creative employee to run this!"
  exit 2
fi

################################################################
# Getting system ready #########################################
################################################################

# Uncomment partner sources for apt
line="quantal partner"
sudo sed -i "/${line}/ s/# *//" /etc/apt/sources.list

# Do a basic update
sudo apt-get update

# Install Git & Git Extras
sudo apt-get install --yes --force-yes git git-core git-extras tig


################################################################
# Rubies #######################################################
################################################################

function create_global_gems_file {
cat > ~/.rvm/gemsets/global.gems << EOF
rubygems-bundler
bundler
rake
rvm
cheat
awesome_print
looksee
hirb
pry
rails
foreman
unicorn
EOF
}

# Install RVM
which rvm &> /dev/null

if [ $? -eq 1 ]; then
  echo `curl -L https://get.rvm.io | bash -s stable`
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

  create_global_gems_file

  # Install different rubies
  # rvm install ree-1.8.7
  # rvm install 1.9.2
  rvm install 1.9.3
  # rvm install 2.0.0
fi

# Picking an RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
rvm --default use 1.9.3@global

################################################################
# Basic Essentials To Get Started ##############################
################################################################

# Install EHC dotfiles
dd="~/Workspace/dotfiles"
if [ -d ~/Workspace/dotfiles ]; then
 echo `cd ~/Workspace/dotfiles && git pull --rebase`
else
 echo `git clone git://github.com/ehc/dotfiles ~/Workspace/dotfiles`
fi

# Install Common Dotfiles
cd ~/Workspace/dotfiles && rake install

source ~/.bashrc

# Install basic packages needed to run this script
sudo apt-get install --yes --force-yes build-essential curl tree libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev linux-headers-`uname -r` vim openssh-server ia32-libs

# Adding libGL
sudo apt-get install --yes --force-yes libgl1-mesa-dev
sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

################################################################
# Removing remnants of older installations #####################
################################################################

# Remove openjdk
sudo apt-get remove --yes --force-yes openjdk-6-jre openjdk-7-jre openjdk-7-jdk default-jre default-jre-headless

# Remove Maven2
sudo apt-get purge --yes --force-yes maven2

# Eclipse
sudo apt-get remove eclipse eclipse-platform eclipse-jdt eclipse-cdt

# Remove un-necessary packages
sudo apt-get --yes --force-yes autoremove

################################################################
# Third party repos ############################################
################################################################

# Install Oracle Java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get install oracle-java7-installer

# Install MongoDB
sudo rm /etc/apt/sources.list.d/10gen.list
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
sudo apt-get install mongodb-10gen
sudo service mongodb restart

# Chromium
sudo apt-get install --yes --force-yes chromium-browser flashplugin-installer
sudo cp /usr/lib/flashplugin-installer/libflashplayer.so /usr/lib/chromium-browser/plugins

# Misc
sudo apt-get install pidgin xclip compizconfig-settings-manager

################################################################
# Databases ####################################################
################################################################

# Install MySql
sudo apt-get install --yes --force-yes mysql-server libmysqlclient-dev libmysql-ruby
sudo service mysql restart

# Install Postgresql
sudo apt-get install --yes --force-yes postgresql pgadmin3

# Install Node.js
sudo apt-get install --yes --force-yes nodejs npm

# Vim
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

# Android Initialization
which android &> /dev/null

# Make reference directory 
mkdir -p ~/Workspace/reference

if [ $? -eq 1 ]; then
  mkdir -p ~/opt/local
  cd ~/opt/local
  echo `wget http://dl.google.com/android/android-sdk_r22-linux.tgz`
  echo `gunzip android-sdk_r22-linux.tgz`
  echo `tar xvf android-sdk_r22-linux.tar`
  mv android-sdk-linux android-sdk
  rm android-sdk_r22-linux.tar
else
  android update sdk --no-ui --filter 1,10,23,38,39
fi

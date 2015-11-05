#!/bin/bash
#	Deluge road warrior installer for ubuntu 15.10
#	NAME: Deluge HRED
#	AUTHOR: Haseeb Ur Rehman
#	URL: haseeburrehman.com
#	LICENSE: Extended WTFPL, view the licence file

# This script was tested on Ubuntu 15.10 and works
# perfectly on new deluge installation. This isn't
# bulletproof but it will work if you need to install
if [ `whoami` != 'root' ]
  then
    echo "Sorry, you need to run this as root."
    exit
fi
echo "What do you want to do?"
echo ""
echo "    1) Install or Repair"
echo "    2) Remove"
read -p "Select an option [1-2]: " INIT_DELUGE_HRED_OPTION
if [ "$INIT_DELUGE_HRED_OPTION" = "2" ]
  then
    apt-get remove deluge deluged deluge-web deluge-console
	echo "Deluge has been removed"
	exit
fi
SERVICE_HANDLER=$(which systemctl)
if [ "$SERVICE_HANDLER" != "" ]
  then
    SH="systemctl"
else
    echo "systemctl not found, aborting"
	exit
fi
if [ -e /etc/lsb-release ]
  then
    OS=Ubuntu
	if ! grep -qs "15.10" "/etc/lsb-release"
	  then
	  echo "Only version 15.10 is supported, aborting"
	  exit
	fi
else
  echo "this installer only works on ubuntu, aborting"
  exit
fi
DELUGE_EXIST=$(which deluge)
if [ "$DELUGE_EXIST" != "" ]
  then
    echo "deluge exists moving on"
else
    add-apt-repository ppa:deluge-team/ppa
    apt-get update
    echo "installing deluge"
    apt-get install deluge
    echo "starting deluge"
	deluge
    adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
    echo "deluge installed"
fi
DELUGED_EXIST=$(which deluged)
if [ "$DELUGED_EXIST" != "" ]
  then
    echo "deluged already exists moving on"
else
    echo "installing delugded"
    apt-get install deluged
    echo "delugded installed"
    echo "setting up some files"
    touch /etc/systemd/system/deluged.service
    echo "[Unit]" > /etc/systemd/system/deluged.service
    echo "Description=Deluge Bittorrent Client Daemon" >> /etc/systemd/system/deluged.service
    echo "After=network-online.target" >> /etc/systemd/system/deluged.service
    echo "[Service]" >> /etc/systemd/system/deluged.service
    echo "Type=simple" >> /etc/systemd/system/deluged.service
    echo "User=deluge" >> /etc/systemd/system/deluged.service
    echo "Group=deluge" >> /etc/systemd/system/deluged.service
    echo "UMask=007" >> /etc/systemd/system/deluged.service
    echo "ExecStart=/usr/bin/deluged -d" >> /etc/systemd/system/deluged.service
    echo "Restart=on-failure" >> /etc/systemd/system/deluged.service
    echo "TimeoutStopSec=300" >> /etc/systemd/system/deluged.service
    echo "[Install]" >> /etc/systemd/system/deluged.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/deluged.service
       echo "starting deluged"
       systemctl start deluged
       echo "deluged status"
       systemctl status deluged
       echo "enabling deluged"
       systemctl enable deluged
fi
DELUGEWEB_EXIST=$(which deluge-web)
if [ "$DELUGEWEB_EXIST" != "" ]
  then
    echo "deluge-web already exists moving on"
else
    echo "installing deluge-web"
    apt-get install deluge-web
    echo "setting up some files"
    touch /etc/systemd/system/deluge-web.service
    echo "[Unit]" > /etc/systemd/system/deluge-web.service
    echo "Description=Deluge Bittorrent Client Web Interface" >> /etc/systemd/system/deluge-web.service
    echo "After=network-online.target" >> /etc/systemd/system/deluge-web.service
    echo "[Service]" >> /etc/systemd/system/deluge-web.service
    echo "Type=simple" >> /etc/systemd/system/deluge-web.service
    echo "User=deluge" >> /etc/systemd/system/deluge-web.service
    echo "Group=deluge" >> /etc/systemd/system/deluge-web.service
    echo "UMask=027" >> /etc/systemd/system/deluge-web.service
    echo "ExecStart=/usr/bin/deluge-web" >> /etc/systemd/system/deluge-web.service
    echo "Restart=on-failure" >> /etc/systemd/system/deluge-web.service
    echo "[Install]" >> /etc/systemd/system/deluge-web.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/deluge-web.service
        echo "starting deluge-web"
        systemctl start deluge-web
        echo "deluge-web stauts"
        systemctl status deluge-web
        echo "enabling deluge-web"
        systemctl enable deluge-web
fi
echo "starting deluge in background"
deluged &
DELUGECONSOLE_EXIST=$(which deluge-console)
if [ "$DELUGECONSOLE_EXIST" != "" ]
  then
    echo "deluge-console already exists moving on"
else
  read -p "Do you wish to install deluge-console? " -e -i Y DELUGE_CONSOLE_ASK
  if [ "$DELUGE_CONSOLE_ASK" = "y" ] || [ "$DELUGE_CONSOLE_ASK" = "Y" ]
    then
      echo "killing all deluged processes to setup deluge-console"
      killall deluged
      echo "installing deluge-console"
      apt-get install deluge-console
      read -p "Set a username: " -e -i haseeb DC_USER
      read -p "Set a password: " DC_PASS
	  touch ~/.config/deluge/auth
      echo "$DC_USER:$DC_PASS:10" >> ~/.config/deluge/auth
      echo "allowing remote connection"
      deluge-console "config -s allow_remote True"
      echo "configuring remote connection"
      deluge-console "config allow_remote"
      echo "starting deluge in background"
	  deluged &
  else
      echo "deluge-console was not installed"
	  exit
  fi
fi

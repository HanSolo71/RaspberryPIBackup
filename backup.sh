#!/bin/bash

#stop services
printf "Stopping Services\n \n"
systemctl stop unifi
~unms/app/unms-cli stop
systemctl stop mongod
systemctl stop telegraf
systemctl stop grafana-server
systemctl stop influxdb
printf "Services Stopped\n \n"

#backup pihole

printf "Starting Pi Hole Backup\n \n"

printf "Stop Pi Hole\n \n"
systemctl stop pihole-FTL
tar -cpf /backup/data/"$(date '+%Y-%m-%d')pihole.tar" /etc/pihole

printf "\n \nStart Pi Hole\n \n"

systemctl start pihole-FTL

printf "End Pi Hole Backup\n \n"

#create backup for everything else
printf "Backup Everything Else\n \n"
tar -cpf /backup/data/"$(date '+%Y-%m-%d')backup.tar" --exclude=/etc/pihole/ --exclude=/backup/data --exclude=/backup/final --exclude=/proc --exclude=/tmp --exclude=/mnt --exclude=/dev --exclude=/sys --exclude=/run --exclude=/media --exclude=/var/log --exclude=/var/cache/apt/archives --exclude=/usr/src/linux-headers* --exclude=/home/*/.gvfs --exclude=/home/*/.cache --exclude=/home/*/.local/share/Trash --exclude=/boot --exclude=/home/unms/data/firmwares --exclude=/usr/bin --exclude=/bin --exclude=/var/lib/docker --exclude=/var/lib/snapd --exclude=/var/cache --exclude=/usr/lib --exclude=/var/lib/apt --exclude=/usr/share --exclude=/usr/src --exclude=/usr/sbin --exclude=/snap --exclude=/usr/include /
dpkg --get-selections > /backup/data/$(date '+%Y-%m-%d')Package.list
tar -cpf /backup/data/"$(date '+%Y-%m-%d')sources.list.tar" /etc/apt/sources.list*
apt-key exportall > /backup/data/$(date '+%Y-%m-%d')Repo.keys

printf "\n \nFinished Backup\n \n"
#end backup

#start services
printf "Start Services\n \n"

systemctl start influxdb
systemctl start mongod
systemctl start telegraf
systemctl start grafana-server
~unms/app/unms-cli start
systemctl start unifi
printf "Services Started\n \n"


#compress all the data
printf "Compressing Data Please Wait\n \n"

XZ_OPT='-T0 -9e' tar -cJpf /backup/final/"$(date '+%Y-%m-%d')downingpibackup.tar.xz" /backup/data

printf "\n \nData Compressed\n \n"

#delete tars
printf "Deleting Tar Files\n \n"

rm /backup/data/*

printf "\n \nBackup Complete\n \n"

#update system
printf "Updating System\n \n"
sudo apt update
sudo apt upgrade -y

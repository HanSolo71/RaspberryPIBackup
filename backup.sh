#!/bin/sh

#stop services
printf "Stopping Services"
systemctl stop unifi
~unms/app/unms-cli stop
systemctl stop mongod
systemctl stop telegraf
systemctl stop grafana-server
systemctl stop influxdb
printf "Services Stopped"

#backup pihole

printf "Starting Pi Hole Backup"

printf "Stop Pi Hole"
systemctl stop pihole-FTL
tar -cpf /backup/data/"$(date '+%Y-%m-%d')pihole.tar" /etc/pihole

printf "Start Pi Hole"

systemctl start pihole-FTL

printf "End Pi Hole Backup"

#create backup for everything else
printf "Backup Everything Else"
tar -cpf /backup/data/"$(date '+%Y-%m-%d')backup.tar" --exclude=/etc/pihole/ --exclude=/backup/data --exclude=/backup/final --exclude=/proc --exclude=/tmp --exclude=/mnt --exclude=/dev --exclude=/s>dpkg --get-selections > /backup/data/$(date '+%Y-%m-%d')Package.list
tar -cpf /backup/data/"$(date '+%Y-%m-%d')sources.list.tar" /etc/apt/sources.list*
apt-key exportall > /backup/data/$(date '+%Y-%m-%d')Repo.keys

echo "Finished Backup"
#end backup

#start services
printf "start services"

systemctl start influxdb
systemctl start mongod
systemctl start telegraf
systemctl start grafana-server
~unms/app/unms-cli start
systemctl start unifi
printf "services started"

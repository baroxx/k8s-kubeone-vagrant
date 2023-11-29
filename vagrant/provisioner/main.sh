#!/bin/bash
set -e

readonly USER_NAME=$1
readonly PASSWORD=$2
readonly KEYMAP=$3
readonly SSH_KEY=$4

useradd $USER_NAME
echo $USER_NAME:$PASSWORD | sudo chpasswd
usermod -aG wheel $USER_NAME
usermod -aG sudo $USER_NAME

SSH_DIR=/home/$USER_NAME/.ssh
echo $SSH_KEY >> $SSH_DIR/authorized_keys
chown -R $USER_NAME:$USER_NAME $SSH_DIR

timedatectl set-timezone Europe/Berlin
localectl set-x11-keymap $KEYMAP

swapoff -a
sed -i '/swap/d' /etc/fstab

echo -e "finished..."
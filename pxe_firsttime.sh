#!/bin/sh

#mount CentOS iso

yum install dhcp tftp tftp-server syslinux wget vsftpd

MOUNT_POINT=/mnt/iso
TARGET_DIR=/var/ftp/pub/cent
TFTP_DIR=/var/lib/tftpboot

mkdir -p $TARGET_DIR/cent_every/pxeserver
mkdir -p $TARGET_DIR/cent_mini/pxeserver
mkdir -p $MOUNT_POINT
mkdir -p $TFTP_DIR
mkdir -p $TFTP_DIR/netboot

read -p "Please input the directory of CentOS.iso: " CENTOS_DIR
mount -o loop $CENTOS_DIR $MOUNT_POINT
cp /tmp/pxeserver/* $TARGET_DIR/cent_every/pxeserver
cp /tmp/pxeserver/ks.cfg $TARGET_DIR/cent_every
cp -r $MOUNT_POINT/* $TARGET_DIR/cent_every
cp $TARGET_DIR/cent_every/images/pxeboot/* $TFTP_DIR/netboot
cp -v /usr/share/syslinux/pxelinux.0 $TFTP_DIR
cp -v /usr/share/syslinux/menu.c32 $TFTP_DIR
cp -v /usr/share/syslinux/memdisk $TFTP_DIR
cp -v /usr/share/syslinux/mboot.c32 $TFTP_DIR
cp -v /usr/share/syslinux/chain.c32 $TFTP_DIR
chmod 777 -R /var/lib/tftpboot

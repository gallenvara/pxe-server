#!/bin/sh

#mount CentOS iso

yum install dhcp tftp tftp-server syslinux wget vsftpd

MOUNT_POINT=/mnt/iso
TARGET_DIR=/var/ftp/pub/cent
TFTP_DIR=/var/lib/tftpboot

mkdir -p $TARGET_DIR/cent_every/intel
mkdir -p $TARGET_DIR/cent_mini/intel
mkdir -p $MOUNT_POINT
mkdir -p $TFTP_DIR
mkdir -p $TFTP_DIR/netboot

mount -o loop /home/CentOS-7-x86_64-Everything-1503-01.iso $MOUNT_POINT
cp /tmp/intel/* $TARGET_DIR/cent_every/intel
cp /tmp/intel/ks.cfg $TARGET_DIR/cent_every
cp -r $MOUNT_POINT/* $TARGET_DIR/cent_every
cp $TARGET_DIR/cent_every/images/pxeboot/* $TFTP_DIR/netboot
cp -v /usr/share/syslinux/pxelinux.0 $TFTP_DIR
cp -v /usr/share/syslinux/menu.c32 $TFTP_DIR
cp -v /usr/share/syslinux/memdisk $TFTP_DIR
cp -v /usr/share/syslinux/mboot.c32 $TFTP_DIR
cp -v /usr/share/syslinux/chain.c32 $TFTP_DIR
chmod 777 -R /var/lib/tftpboot

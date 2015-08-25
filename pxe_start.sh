#!/bin/sh

function ftp_kickstart_prepare {
    file=$1
    sed -i "s/ftpserver/url --url=\"ftp:\/\/$ip_self\/pub\/cent\/cent_every\"/" $1
    sed -i "s/cp.* \/mnt\/stage2\/pxeserver\/\(.*\) \/tmp\/pxeserver/cd \/tmp\/pxeserver; wget -nH --cut-dirs=4 -m ftp:\/\/$ip_self\/pub\/cent\/cent_every\/pxeserver\/*.sh/" $1
}

TFTP_DIR=/var/lib/tftpboot

#find self ip address
ip_self=`ifconfig |grep "inet addr:" | sed -e 's/^[ \t]*//' | cut -d" " -f2 |cut -c6- | grep -v 127.0.0.1 | uniq`
ip_num=`echo "$ip_self" |wc -l`
if [ $ip_num -gt 1 ]; then
    echo "There are more than one IPs:"
    echo $ip_self
    read -p "Which one do you want PXE Server to be binded to? (Please input IP address): " ip_self
fi
echo "PXE Server IP is $ip_self."

echo ""
echo "##########################################################"
echo "Now you need to provide an IP address pool for PXE to use. This IPs must compliant with following requirements:"
echo "1. These IPs must be in the same LAN as this machine ip $ip_self so that they can connect to each other."
echo "2. To avoid conflict, this IP address pool must NOT used or to be used by any machine."
echo "   E.g. you give a pool 192.168.1.100 - 192.168.1.200. Then, these IPs can't be used by any machine (even the machine installed by this PXE)."
echo "##########################################################"
echo ""
read -p "Please input the start IP of this pool: " ip_start
read -p "Please input the end IP of this pool: " ip_end


netmask=`ifconfig |grep $ip_self | grep -o "Mask:[^ ]*" |cut -c6- | uniq`
gateway=`route |grep default | tr -s " " |cut -d" " -f2 | uniq`
subnet=`echo "$ip_self" | cut -d. -f1-3 | uniq`

#enable tftp server
sed -i "s/disable\([ \t]*\)=\([ \t]*\)yes/disable\1=\2no/g" /etc/xinetd.d/tftp

#setup dhcp server
echo -n "ignore client-updates;
authoritative;
allow booting;
allow bootp;
allow unknown-clients; 
subnet $subnet.0 netmask 255.255.255.0 
{   
    #option routers $gateway;
    option subnet-mask  $netmask;
    range $ip_start $ip_end;
    filename \"pxelinux.0\"; 
    next-server $ip_self; 
    default-lease-time 600; 
    max-lease-time 7200; 
} " > /etc/dhcp/dhcpd.conf 

#setup kickstart menu
mkdir -p $TFTP_DIR/pxelinux.cfg
echo "
default menu.c32
 prompt 0
 timeout 30
 MENU TITLE Welcome to CentOS 7 !

 LABEL centos7_x64
 MENU LABEL CentOS 7 X64
 KERNEL /netboot/vmlinuz
 APPEND  initrd=/netboot/initrd.img  inst.repo=ftp://$ip_self/pub/cent/cent_every  ks=ftp://$ip_self/pub/cent/cent_every/ks.cfg

 LABEL centos7_x64
 MENU LABEL CentOS 7 X64 (minimal)
 KERNEL /netboot/vmlinuz
 APPEND  initrd=/netboot/initrd.img  inst.repo=ftp://$ip_self/pub/cent/cent_mini  ks=ftp://$ip_self/pub/cent/cent_mini/ks.cfg
" >$TFTP_DIR/pxelinux.cfg/default 

cd /var/ftp/pub/cent/cent_every
ftp_kickstart_prepare ks.cfg
#start services
service vsftpd restart 
service xinetd restart 
service dhcpd restart 

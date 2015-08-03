#!/bin/sh

#configure network
cd /etc/sysconfig/network-scripts
echo "network configuration..."
read -p "please input host name: " HOSTNAME

echo "
NETWORKING=yes
HOSTNAME=${HOSTNAME}
" > /etc/sysconfig/network

needDNS="no"

function yesno_answer {
    resultOK="no"
    while [ $resultOK != "ok" ]; do
        read -p "$1" answer
        if [ "$answer" == "yes" ] || [ "$answer" == "y" ]
        then
            resultOK="ok"
            return 0
        fi
        if [ "$answer" == "no" ] || [ "$answer" == "n" ]
        then
            resultOK="ok"
            return 1
        fi
        if [ "$answer" == "" ]; then
            resultOK="ok"
            return $2
        fi
    done
}

netifList=`ls ifcfg-*`
for netif in $netifList
do
    #clean input buffer
    read -t 0 dummy

    netDevName=${netif:6}
    #skip loopback interface
    if [ "$netDevName" != "lo" ]
    then
        link=`ethtool $netDevName |grep "Link detected: yes"`
        line="unlinked"
        promp="yes or [no]"
        defaultVal="1"
        if [ "x$link" != "x" ]; then
            line="linked"
            promp="[yes] or no"
            defaultVal="0"
        fi
        echo
        echo "config network adapter $netDevName ..."
        #blink the interface to help indicate
        ethtool -p $netDevName 15 &> /dev/null & 
        ethpid=$!
        if yesno_answer "Do you want to enable $netDevName? It is currently cable $line. ($promp): " $defaultVal
        then
            if yesno_answer "Do you want to use DHCP for $netDevName (yes or [no])? " 1
            then
                echo "ONBOOT=yes
BOOTPROTO=dhcp
DHCP_HOSTNAME=$HOSTNAME
DEVICE=$netDevName" > $netif
            else
                needDNS="yes"
                read -p "Please input IP address for $netDevName: " ipaddr
                read -p "Please input netmask for $netDevName: " netmask
                read -p "Please input gateway for $netDevName: " gateway
                echo "ONBOOT=yes
BOOTPROTO=static
IPADDR=$ipaddr
NETMASK=$netmask
GATEWAY=$gateway
DEVICE=$netDevName" > $netif
            fi
        else
            echo "ONBOOT=no
DEVICE=$netDevName" > $netif
        fi
        #kill ethtool siliently
        kill $ethpid 2>/dev/null &
        wait $ethpid 2>/dev/null
    fi
done

if [ "$needDNS" = "yes" ]
then
    secondDNS=""
    thirdDNS=""
    #clean input buffer
    read -t 0 dummy

    echo ""
    read -p "please input first DNS server IP (10.248.2.5): " firstDNS
    if [ "x$firstDNS" != "x" ]; then
        read -p "please input second DNS server IP (10.239.27.228): " secondDNS
        if [ "x$secondDNS" != "x" ]; then
            read -p "please input third DNS server IP (172.17.6.9): " thirdDNS
        fi
    fi

    targetFile=/etc/resolv.conf
    rm $targetFile
    DOMAIN=${HOSTNAME#[^.]*\.}
    if [ "x$DOMAIN" != "x" ]; then
        echo "domain $DOMAIN" >> $targetFile
        echo "search $DOMAIN" >> $targetFile
    fi
    if [ "x$firstDNS" != "x" ]; then
        echo "nameserver $firstDNS" >> $targetFile
    fi
    if [ "x$secondDNS" != "x" ]; then
        echo "nameserver $secondDNS" >> $targetFile
    fi
    if [ "x$thirdDNS" != "x" ]; then
        echo "nameserver $thirdDNS" >> $targetFile
    fi
fi

source /etc/sysconfig/network
hostname $HOSTNAME

/etc/init.d/network restart
logger -t kickstart "network configured!"

#clean input buffer
read -t 0 dummy

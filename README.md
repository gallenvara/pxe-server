# pxe-server
pxe-server configuration.

    mkdir /tmp/pxeserver
    cp /root/pxe-server/* /tmp/pxeserver
    cd /tmp/pxeserver
    ./pxe_firsttime.sh
    ./pxe_start.sh
  
  Then reboot the client with network-boot and  wait for pxe auto-work finished.

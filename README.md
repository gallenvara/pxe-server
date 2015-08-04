# pxe-server
pxe-server configuration.

    cp CentOS-7-x86_64-Everything-1503-01.iso /home 
    mkdir /tmp/intel
    cp /root/pxe-server/* /tmp/intel
    cd /tmp/intel
    ./pxe_firsttime.sh
    ./pxe_start.sh
  
  Then reboot the client with network-boot and  wait for pxe auto-work finished.

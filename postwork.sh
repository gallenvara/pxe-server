#!/bin/sh

/tmp/pxeserver/disk_mount.sh
/tmp/pxeserver/network.sh
/tmp/pxeserver/ulimits.sh

read -t 0 dummy
read -t 60 -p "Press any key or wait 60s to continue... " dummy

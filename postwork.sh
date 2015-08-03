#!/bin/sh

/tmp/intel/disk_mount.sh
/tmp/intel/network.sh
/tmp/intel/ulimits.sh

read -t 0 dummy
read -t 60 -p "Press any key or wait 60s to continue... " dummy

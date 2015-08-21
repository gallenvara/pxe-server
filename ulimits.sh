#!/bin/sh
#modify system limit configuration

ulimit -n 327680
echo "*soft nofile = 327680
      *hard nofile = 655360" >>/etc/security/limits.conf

echo "ulimit -n 327680" >>/etc/profile

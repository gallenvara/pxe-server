#!/bin/sh
#modify system limit configuration

echo "*soft nofile = 32768
      *hard nofile = 65536" >>/etc/security/limits.conf

echo "ulimit -n 32768" >>/etc/profile

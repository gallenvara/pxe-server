#!/bin/sh 

hdNum=0

diskstr=`fdisk -l |grep "Disk /dev/sd" `
while read LINE
do
  hdNum=`expr $hdNum + 1`
done << EOF
  $diskstr
EOF

echo "You hava $hdNum disks."
i=1
while [ $i -lt $hdNum ]                  
do
j=`echo $i|awk '{printf "%c",97+$i}'` 
parted /dev/sd$j <<FORMAT               
mklabel gpt
mkpart primary 0 -1
ignore
quit
FORMAT
mkfs.ext4 -T largefile  /dev/sd${j}1    
mkdir /mnt/disk${i}
mount="/dev/sd${j}1       /mnt/disk${i}  ext4    defaults        0       0" 
rm -rf /mnt/disk${i}/*
echo $mount >>/etc/fstab                 
i=$(($i+1))
done
echo "/*****Formating  and Mounting have finished****/"
mount -a

read -t 0 dummy 

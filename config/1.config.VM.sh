#!/bin/sh
sudo yum -y install wget
wget ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/6.2/x86_64/updates/security/kernel-devel-2.6.32-220.23.1.el6.x86_64.rpm
sudo yum install kernel-devel-2.6.32-220.23.1.el6.x86_64.rpm -y
sudo yum install kernel-devel-2.6.32-358.18.1.el6.x86_64 -y
sudo yum install gcc -y
sudo bash
ln -s /usr/src/kernels/2.6.32-220.23.1.el6.x86_64 /usr/src/linux
exit
ln -s /usr/src/kernels/2.6.32-220.23.1.el6.x86_64 /usr/src/linux
mkdir rpm
cd rpm
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
sudo rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
sudo rpm -i rpmforge-release-0.5.2-2.el6.rf.*.rpm
sudo yum install dkms
sudo bash
mkdir /mnt/ISO
cd /home/cloudera/Downloads
wget http://download.virtualbox.org/virtualbox/4.2.18/VBoxGuestAdditions_4.2.18.iso 
mount -t iso9660 -o loop VBoxGuestAdditions_4.2.18.iso /mnt/ISO 
cd /mnt/ISO 
ls 
sh VBoxLinuxAdditions.run
reboot
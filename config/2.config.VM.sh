#!/bin/sh
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo yum -y install git R
sudo ln -s /etc/default/hadoop-0.20-mapreduce /etc/profile.d/hadoop.sh
cat /etc/profile.d/hadoop.sh | sed 's/export //g' > ~/.Renviron
wget http://download2.rstudio.org/rstudio-server-0.97.336-x86_64.rpm
sudo yum install --nogpgcheck rstudio-server-0.97.336-x86_64.rpm -y
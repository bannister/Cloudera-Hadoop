Configuring Cloudera VM on VirtualBox 
=====================================
adapted slightly from http://blogr-cs.blogspot.co.uk/2012/12/integration-of-r-rstudio-and-hadoop-in.html

1. Install VM
-------------

1. Download and install the latest release of VirtualBox (Ver 4.2.6 at the time of this post) for your platform (Here OS X)
```http://download.virtualbox.org/virtualbox/4.2.6/VirtualBox-4.2.6-82870-OSX.dmg```


2. Download 'Cloudera's Hadoop Demo VM archive for CDH4
(Latest: Ver 4.1.1 runs CentOS 6.2 64 bit VM)
```https://downloads.cloudera.com/demo_vm/virtualbox/cloudera-demo-vm-cdh4.1.1-virtualbox.tar.gz```


3. Extract 'Cloudera's Hadoop Demo VM' archive
It extracts virtual machine image file: 'cloudera-demo-vm.vmdk'


4. Copy this virtual machine image to a desired folder (eg:- folder named 'Cloudera Hadoop'). This folder and image file has to be the permanent location of your Hadoop installation (not to be deleted!)


5. We will now create a virtual machine on VirtualBox.
Open application: 'VirtualBox'. Click on 'New'.

Give a name to the VM. Here: 'Cloudera Hadoop'. 
Pick type: Linux
Choose version: Linux 2.6 (64 bit)
Click 'Continue'.

It is generally recommended to allocate at least 2 GB of RAM. I recommend more, since I encountered problems installing the R package 'Rcpp' with about 2 GB of RAM. I allocated 4 GB and resolved the issue.

Click 'Continue'.

Choose the option 'Use an existing virtual hard drive file' and select the virtual image file ( 'cloudera-demo-vm.vmdk' ) saved in folder 'Cloudera Hadoop' (refer to step 4).

Click 'Create'.


6. Click 'Settings' to make a few recommended changes.
Click on tab 'Advanced' under 'General' category.

Pick 'Bidirectional' option for items: 'Shared Clipboard' and 'Drag'n Drop'

Click on 'System' category. Ensure option 'Enable IO APIC' under 'Extended Features' is checked on (This is default!)
Click on 'Network' category. Choose Adapter 1 option 'Attached to:' as 'Bridged Adapter' (This gives you access to physical wifi. Default is 'NAT')

Click on 'Shared Folders' category. You may choose to pick a folder to share with the host OS (here Mac OS X)

Click 'OK'.

Now click 'Start' to initiate the virtual machine. You will several pages of output on a black screen until you finally see the desktop of the virtual machine.

Once you launch the VM, you are automatically logged in as the cloudera user. 
The account details are:
username: cloudera 
password: cloudera 
The cloudera account has sudo privileges in the VM.


7. For close integration and better performance we need to install "Guest additions" in the VM. 
There are some prerequisites to installation of 'Guest additions'.

2. Configure VM
---------------
Run console
Switch to root use, update linux kernel and reboot: 

```{bash}
$ sudo bash
$ yum install kernel -y
$ reboot
```

Next we install (and link where appropriate) wget, scientific linux kernel, gcc, rpmforge-release, dkms and VirtualBox Guest Additions.  

Bash script config/1.config.VM.sh

```{bash}
$ sudo yum -y install wget
$ wget ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/6.2/x86_64/updates/security/kernel-devel-2.6.32-220.23.1.el6.x86_64.rpm
$ sudo yum install kernel-devel-2.6.32-220.23.1.el6.x86_64.rpm -y
$ sudo yum install kernel-devel-2.6.32-358.18.1.el6.x86_64 -y
$ sudo yum install gcc -y
$ sudo bash
$ ln -s /usr/src/kernels/2.6.32-220.23.1.el6.x86_64 /usr/src/linux
$ exit
$ ln -s /usr/src/kernels/2.6.32-220.23.1.el6.x86_64 /usr/src/linux
$ mkdir rpm
$ cd rpm
$ wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
$ rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
$ sudo rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
$ sudo rpm -i rpmforge-release-0.5.2-2.el6.rf.*.rpm
$ sudo yum install dkms
$ sudo bash
$ mkdir /mnt/ISO
$ cd /home/cloudera/Downloads
$ wget http://download.virtualbox.org/virtualbox/4.2.18/VBoxGuestAdditions_4.2.18.iso 
$ mount -t iso9660 -o loop VBoxGuestAdditions_4.2.18.iso /mnt/ISO 
$ cd /mnt/ISO 
$ ls 
$ sh VBoxLinuxAdditions.run
$ reboot
```

3.Install R, RStudio and CRAN packages
--------------------------------------

Next we add the EPEL repository, intall git, wget and R. We , set Hadoop environment variables so R can find them install rstudio server

Bash script config/2.config.VM.sh

```{bash}
$ sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
$ sudo yum -y install git R
$ sudo ln -s /etc/default/hadoop-0.20-mapreduce /etc/profile.d/hadoop.sh
$ cat /etc/profile.d/hadoop.sh | sed 's/export //g' > ~/.Renviron
$ wget http://download2.rstudio.org/rstudio-server-0.97.336-x86_64.rpm
$ sudo yum install --nogpgcheck rstudio-server-0.97.336-x86_64.rpm -y
 ```

Access Rstudio from the browser (you may use any machine in the home network)
Check IP address by running command:
```{bash}
$ ifconfig
```
Access RStudio from browser by typing the address (uses port 8787) : e.g., http://10.0.1.15:8787/  or http://localhost:8787
Both username and password are 'cloudera'
Username: cloudera
Password: cloudera


Next we installation of RHadoop's rmr2 and pre-requisite packages. (Run R as root to install system-wide)

Bash script config/3.config.VM.sh

```{bash}
$ sudo R --no-save << EOF
$ install.packages(c('Rcpp', 'RJSONIO', 'itertools', 'digest', 'functional', 'plyr', 'stringr'), repos="http://cran.revolutionanalytics.com", INSTALL_opts=c('--byte-compile') )
$ EOF
$ wget --no-check-certificate https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr2_2.0.2.tar.gz
$ sudo R CMD INSTALL rmr2_2.0.2.tar.gz
$ sudo R CMD library(rmr2)
```


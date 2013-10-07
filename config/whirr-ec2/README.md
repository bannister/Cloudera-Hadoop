Whirr Configuration
===================

Install Whirr is as simple as expanding the tarball and modifying the path.

```{bash}
$ wget http://apache.mirrors.pair.com/whirr/whirr-0.8.2/whirr-0.8.2.tar.gz
$ tar zxf whirr-0.8.2.tar.gz
$ export PATH="~/whirr-0.8.2/bin:$PATH"
$ whirr version
```

Using the credentials from the your AWS account set them for your session
```{bash}
$ export AWS_ACCESS_KEY_ID="your access key id here" 
$ export AWS_SECRET_ACCESS_KEY="your secret access key here"
```

Create a key pair
```{bash}
$ ssh-keygen -t rsa -P ""
```


Launch cluster using Whirr
```{bash}
$ whirr launch-cluster --config ~/config/whirr-ec2/hadoop-ec2.properties 
```

Run scripts on each of the nodes that installs R, required CRAN packages and sets the Hadoop enviroment variabless.
```{bash}
$ whirr run-script --script ~/config/whirr-ec2/install-r+packages.sh --config ~/config/whirr-ec2/hadoop-ec2.properties
```

Specifiy location of current configuration files
```{bash}
$ sudo /usr/sbin/alternatives --display hadoop-0.20-conf
```

Whirr generates the config file we need to create a “conf.ec2” alternative 
```{bash}
$ sudo mkdir /etc/hadoop-0.20/conf.ec2 
$ sudo cp -r /etc/hadoop-0.20/conf.empty /etc/hadoop-0.20/conf.ec2 
$ sudo rm -f /etc/hadoop-0.20/conf.ec2/*-site.xml 
$ sudo cp ~/.whirr/hadoop-ec2/hadoop-site.xml /etc/hadoop-0.20/conf.ec2/ 
$ sudo /usr/sbin/alternatives --install /etc/hadoop-0.20/conf hadoop-0.20-conf /etc/hadoop-0.20/conf.ec2 30 
$ sudo /usr/sbin/alternatives --set hadoop-0.20-conf /etc/hadoop-0.20/conf.ec2 
$ sudo /usr/sbin/alternatives --display hadoop-0.20-conf
```

Whirr generates a proxy to connect your VM to the cluster.  Run this in another cmd line window...
```{bash}
~/.whirr/hadoop-ec2/hadoop-proxy.sh
```

Any hadoop commands executed on your VM should go to the cluster instead
```{bash}
hadoop dfsadmin -report
```

Download Jeffery Breen's fork of the ASA airline example, and get the first 1000 lines of the data.
```{bash}
mkdir hadoop-r 
cd hadoop-r 
git init 
git pull git://github.com/jeffreybreen/hadoop-R.git
curl http://stat-computing.org/dataexpo/2009/2004.csv.bz2 | bzcat | head -1000 > 2004-1000.csv
```
Put the data in HDFS
```{bash}
hadoop fs -mkdir /user/cloudera 
hadoop fs -mkdir asa-airline 
hadoop fs -mkdir asa-airline/data 
hadoop fs -mkdir asa-airline/out 
hadoop fs -put 2004-1000.csv asa-airline/data/
```

Run the forked streaming job
```{bash}
cd airline/src/deptdelay_by_month/R/streaming 
hadoop jar /usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-*.jar -input asa-airline/data -output asa-airline/out/dept-delay-month -mapper map.R -reducer reduce.R -file map.R -file reduce.R
[...]
hadoop fs -cat asa-airline/out/dept-delay-month/part-00000
```




Close the proxy (crtl C).
```{bash}
^C
```

Kill the cluser using Whirr
```{bash}
whirr destroy-cluster --config ~/config/whirr-ec2/hadoop-ec2.properties
```

Switch back to local Hadoop
```{bash}
sudo /usr/sbin/alternatives --set hadoop-conf /etc/hadoop/conf.cloudera.mapreduce1
```







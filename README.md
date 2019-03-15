# Dataproc Client VM Instance Startup Script

This repository provides a startup script and instructions for creating a Dataproc client VM which has client software installed and configured to submit jobs to a remote Dataproc cluster.


## Instructions

1. Clone this repo and go the the directory
```
git clone https://github.com/JessieJingxuGao/dataproc-client-vm-startup.git
cd dataproc-client-vm
```

2. Change permission of the create-client.sh
```
chmod 777 create-dproclient-vm.sh
```

3. Modify the [metadata.config](metadata.config) file: replacing `my-project` `my-dataproc-client` `my-service-account` `my-dataproc-cluster` and `my-bucket` with your own values. `my-dataproc-cluster` is the name of the dataproc cluster you want to create a client for.

4. Run the [create-client.sh](create-client.sh) file.
```
./create-dproclient-vm.sh
```
5. Access Zeppelin web UI (port:8080) and create a JDBC interpreter that connects Zeppelin with remote Dataproc cluster.
- default.driver -> org.apache.hive.jdbc.HiveDriver
- default.url -> jdbc:hive2://<target_dataproc_cluster_name-m>:10000/
- artifacts -> org.apache.hive:hive-jdbc:0.14.0 & org.apache.hadoop:hadoop-common:2.6.0

6. Access Hue web UI (port:8888) 

## How this works

The [create-dproclient-vm.sh](create-dproclient-vm.sh) contains the the following

- gcloud command that starts a Dataproc cluster serving as client with metadata variables for target cluster name and Cloud storage bucket name used to store those configurations files passed to the client environment. 

- SSH into the Dataproc client VM and run the  [install-client.sh](install-client.sh)


The [install-client.sh](install-client.sh) contains the the following

- The [startup.sh](startup.sh) replaces the `MASTER_HOSTNAMES` variable to use the master hostname of the target dataproc cluster. Then the Dataproc created files `/usr/local/share/google/dataproc/launch-agent.sh`, `/usr/local/share/google/dataproc/startup-script*.sh` will be run install services like Hadoop NameNode, YARN Resource Manager and Hive Metastore. When the script writes configuration files, all client software references the master of the target dataproc cluster. When starting `hive`, `spark-shell`, , `spark-submit`, the session will be created on the remote cluster instead of locally.

- The [zeppelin.sh](zeppelin.sh) and [hue.sh](hue.sh) scripts are the [initialization-actions bash files](initialization-actions) provided by Google, which will initilze Zeppelin and Hue 

- the scripts needed to swap the `/etc/hue/conf/hue.ini` hive_server_host setting to the target dataproc cluster instead of the local and also uncommented the hive_server_port configuration that are needed to have hue running query successfully.

Then, the Zeppelin configurations needed to allow Zeppelin to connect with the target dataproc hive server are set in step #6 above through web server UI.



## Trouble-shooting suggestions
1. Unmatched python versions on server and client sides
```
ERROR org.apache.spark.deploy.yarn.ApplicationMaster: User class threw exception: java.io.IOException: Cannot run program "/opt/conda/default/bin/python": error=2, No such file or directory
```    
`spark-submit` may fail even `spark-shell` or `pyspark` run correctly due to unmatched versions on server and client sides. Run `which python` and `python --version` to check if the python versions match. One example of mis-match may be as follow:
- Server side: Python 2.7.13 | /usr/bin/python 
- Client side: Python 3.6.5 :: Anaconda, Inc.| /opt/conda/default/bin/python .  

It may be a simple fix to match the python env on both machines after the client was created but it's suggested to select image with the same python package and same settings with the server during creation of the client. So the gcloud image-version flag in [create-client.sh](create-client.sh) should be "preview" if the server is using python3.5 with conda, or 1.3-deb9 (default as of March 2019) or older images that are using Python2.7.13 with python path /usr/bin/python.



## MISC
1. Create client dataproc vm with network flag that has filewall settings of 1) openning ports for spark history server web ui, hue web ui, zeppelin web ui 2) open hive, spark service ports from client to server

2. Testing
- running hive cli 
- running spark shell (spark-shell/pyspark)
- running spark-submit
- running hive query from zeppelin
- running hive query from hue

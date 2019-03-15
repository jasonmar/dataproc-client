# Dataproc Client VM Instance Startup Script

This repository provides a startup script and instructions for creating a Dataproc client VM which has client software installed and configured to submit jobs to a remote Dataproc cluster.


## Instructions

1. Clone this repo and go the the directory
```
git clone https://github.com/JessieJingxuGao/dataproc-client-vm-startup.git
cd dataproc-client-vm-startup
```

2. Change permission of the create-dproclient-vm.sh
```
chmod 777 create-dproclient-vm.sh
```

3. Modify the [metadata.config](metadata.config) file: replacing `my-project` `my-dataproc-client` `my-service-account` `my-dataproc-cluster` and `my-bucket` with your own values. `my-dataproc-cluster` is the name of the dataproc cluster you want to create a client for.

4. Run the [create-dproclient.sh](create-dproclient.sh) file.
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


Note: The following two erros can be ignored:
- During the process running [hue.sh](hue.sh), Hue installation process will try to restart and hadoop-hdfs-namenode, as we have swapped the `MASTER_HOSTNAMES` with the remote Dataproc server, this will pop up error 'Unable to restart hadoop-hdfs-namenode'. It will not stop the following process and this error can be ignored.
- When first time openning Hue web UI, the below error will pop up but can be ignored. There should be no problem running Hive queres that run on the server machine.
`Solr server could not be contacted properly: HTTPConnectionPool(host='......', port=8983): Max retries exceeded with url: /solr/admin/info/system?user.name=hue&doAs=admin&wt=json (Caused by NewConnectionError(': Failed to establish a new connection: [Errno 111] Connection refused',))`


## Trouble-shooting suggestions
1. Unmatched python versions on server and client sides
```
ERROR org.apache.spark.deploy.yarn.ApplicationMaster: User class threw exception: java.io.IOException: Cannot run program "/opt/conda/default/bin/python": error=2, No such file or directory
```    
`spark-submit` may fail even `spark-shell` or `pyspark` run correctly due to unmatched versions on server and client sides. Run `which python` and `python --version` to check if the python versions match. One example of mis-match may be as follow:
- Server side: Python 2.7.13 | /usr/bin/python 
- Client side: Python 3.6.5 :: Anaconda, Inc.| /opt/conda/default/bin/python .  

It may be a simple fix to match the python env on both machines after the client was created but it's suggested to select image with the same python package and same settings with the server during creation of the client. So the gcloud image-version flag in [create-dproclient-vm.sh](create-dproclient-vm.sh) should be "preview" if the server is using python3.5 with conda, or 1.3-deb9 (default as of March 2019) or older images that are using Python2.7.13 with python path /usr/bin/python.



## Test
1. Find the Dataproc Server cluster name and the image version to be referenced in the automation script
2. Decide the network tag to be used for the Dataproc client VM and use that to set up the firewall rules for the following ports to be opened.
- Hive: 10000 (hive server),9083 (hive metastore) - client to master
- spark: 7077 (spark master port),7078 (spark worker port) - client to master
- Hue web server: 8888 - user terminal to client
- Zeppelin web server: 8080 - user terminal to client
- Spark web server: 18080 (spark master web ui port), 18081  (spark worker web ui port) - user temrinal to master
3. Create Client Dataproc VM with the above instructions
4. Validate the success criterion have been met
- Test Hive CLI: User should be able to query tables stored on master Dataproc hive server
- Test Spark Shell ( `spark-shell` for scala and `pyspark` for python): The job submitted on client VM should be shown on master Dataproc spark history-server UI (http://<spark_host_ip>:18080)
- Test spark-submit: The job submitted on client VM should be shown on master Dataproc spark history-server UI (http://<spark_host_ip>:18080)
- Test running Hive Query from Zeppelin: User should be able to query tables stored on master Dataproc hive server
- Test running Hive Query from Hue: User should be able to query tables stored on master Dataproc hive server

## Remaining work
- create templates
- create vm from image and use systemd for running configuration changes needed from image

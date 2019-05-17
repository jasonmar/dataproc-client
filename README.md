# Dataproc Client

This repository provides a startup script and instructions for configuring a GCP VM Instance to submit jobs to a remote Dataproc cluster.

Supported clients:
* Zeppelin
* Hue
* Hive
* Beeline
* Hadoop / HDFS
* Spark Submit
* Spark Shell


## Instructions


1. Change working directory to repository root

```sh
cd dataproc-client-vm-startup
```


3. Modify [metadata.config](metadata.config)

Replace the following placeholders:

* `YOUR_PROJECT` The project name
* `YOUR_CLIENT` The Client Cluster name (DON"T include the '-m')
* `YOUR_SERVICE_ACCOUNT` The service account (in email format like 'hive-demo@project-name.iam.gserviceaccount.com`). It should have the required access to GCP APIs/services, for example, Dataproc, Compute Engine, GCS.
* `YOUR_BUCKET` The GCS bucket name that will be used to transfer the scripts to the client VM
* `YOUR_STORAGE_CLASS` The storage class for the GCS bucket, multi_regional recommended as there might be different regions where the client VM might be
* `YOUR_REGION` The region where you want to establish the client VM
* `YOUR_ZONE` The zone where you want to establish the client VM
* `YOUR_CLIENT_TAG ` The network tag to be used for the client VM
* `YOUR_NETWORK ` The network to be used for the client VM


4. Run setup script

[create-dproclient-vm.sh](create-dproclient-vm.sh)

```sh
./create-dproclient-vm.sh
```

5. Create an image using the just created single-nodel Dataproc VM disk, with name for example "dproclient-image"

6. Change working directory to from-img sub-folder

```sh
cd dataproc-client-vm-startup/from-img
```

7. Modify [metadata.config](metadata.config)

Replace the following placeholders:

* `YOUR_TARGET_CLUSTER` The server Dataproc Cluster name (DON"T include the '-m') where the client VM will point to to run Hive and Spark
* `YOUR_IMAGE` The Dataproc single-node master VM image created in step-5 that will be used to create the compute engine as client VM, for example "dproclient-image"
* `OLD_TARGET_CLUSTER` The current target hostname in the image. It should be the VM name (for example dproclient-cluster-m) used that was used to create the image.
* `IMG_MACHINE_TYPE` The machine type of the VM that was used to create the image. If use the current default settings in [create-dproclient-vm.sh](create-dproclient-vm.sh), then it should be "n1-standard-1".
* `IMG_BOOT_DISK_SIZE` The boot disk size of the VM that was used to create the image. If use the current default settings in [create-dproclient-vm.sh](create-dproclient-vm.sh), then it should be "200GB".
* `IMG_BOOT_DISK_TYPE` The boot disk type of the VM that was used to create the image. If use the current default settings in [create-dproclient-vm.sh](create-dproclient-vm.sh), then it should be "pd-standard".
* `YOUR_PROJECT` The project name
* `YOUR_CLIENT` The Client VM name
* `YOUR_REGION` The region where you want to establish the client VM
* `YOUR_ZONE` The zone where you want to establish the client VM
* `YOUR_CLIENT_TAG ` The network tag to be used for the client VM
* `YOUR_NETWORK ` The network to be used for the client VM
* `YOUR_SERVICE_ACCOUNT` The service account (in email format like 'hive-demo@project-name.iam.gserviceaccount.com`) 






8. Run setup script

[create-dproclient-from-img.sh](create-dproclient-from-img.sh)

```sh
./create-dproclient-from-img.sh
```


9. Access Zeppelin web UI hosted on the just created Client VM

[http://localhost:8080](http://localhost:8080)

Create a JDBC interpreter connecting Zeppelin with the remote Dataproc cluster:

- `default.driver` -> `org.apache.hive.jdbc.HiveDriver`
- `default.url` -> `jdbc:hive2://<target_dataproc_cluster_name-m>:10000/`
- `artifacts` -> `org.apache.hive:hive-jdbc:0.14.0 & org.apache.hadoop:hadoop-common:2.6.0`


10. Access Hue Web UI hosted on the just created Client VM

[http://localhost:8888](http://localhost:8888)



## How this works

The [create-dproclient-vm.sh](create-dproclient-vm.sh) contains the the following

- gcloud command that starts a Dataproc cluster serving as the image to be used to create the the final client VM, with Cloud storage bucket name used to store those configurations files passed to the client environment. 

- SSH into the Dataproc client VM and run [install-client.sh](install-client.sh) 

The [util/install-client.sh](util/install-client.sh) constains the following

- Installation of Hue and Zeppeline on it. The [zeppelin.sh](zeppelin.sh) and [hue.sh](hue.sh) scripts are the [initialization-actions bash files](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions) provided by Google, which will initilze Zeppelin and Hue 


The [from-img/create-startup.sh](from-img/create-startup.sh) will create the [from-img/startup-script.sh](from-img/startup-script.sh) 

- replace the hostnames in the Hadoop, Yarn, Hive, Spark files with the hostname with the hostname of the remote target server dataproc cluster. Thus, when starting `hive`, `spark-shell`, , `spark-submit`, the session will be created on the remote cluster instead of locally.

- swap the `/etc/hue/conf/hue.ini` hive_server_host setting to the target dataproc cluster instead of the local and also uncommented the hive_server_port configuration that are needed to have hue running query successfully.

- Note: The Zeppelin configurations needed to allow Zeppelin to connect with the target dataproc hive server are set in step #6 above through web server UI.  

The [from-img/create-dproclient-from-img.sh](from-img/create-dproclient-from-img.sh) will do the following

- read the [from-img/metadata.config](from-img/metadata.config) to get the metadata and run the [from-img/create-startup.sh](from-img/create-startup.sh) to create the [from-img/startup-script.sh](from-img/startup-script.sh) 

- gcloud command that starts the client VM using image 


*Note: The following error can be ignored:*
- When first time openning Hue web UI, the below error will pop up but can be ignored. There should be no problem running Hive queres that run on the server machine.
`Solr server could not be contacted properly: HTTPConnectionPool(host='......', port=8983): Max retries exceeded with url: /solr/admin/info/system?user.name=hue&doAs=admin&wt=json (Caused by NewConnectionError(': Failed to establish a new connection: [Errno 111] Connection refused',))`


## Troubleshooting

1. Unmatched python versions on server and client sides

```
ERROR org.apache.spark.deploy.yarn.ApplicationMaster: User class threw exception: java.io.IOException: Cannot run program "/opt/conda/default/bin/python": error=2, No such file or directory
```    

`spark-submit` may fail even `spark-shell` or `pyspark` run correctly due to unmatched versions on server and client sides.

Run `which python` and `python --version` to check if the python versions match.

One example of mis-match may be as follow:
- Server side: Python 2.7.13 | /usr/bin/python 
- Client side: Python 3.6.5 :: Anaconda, Inc.| /opt/conda/default/bin/python .  

It may be a simple fix to match the python env on both machines after the client was created but it's suggested to select image with the same python package and same settings with the server during creation of the client. So the gcloud image-version flag in [create-dproclient-vm.sh](create-dproclient-vm.sh) should be "preview" if the server is using python3.5 with conda, or 1.3-deb9 (default as of March 2019) or older images that are using Python2.7.13 with python path /usr/bin/python.


## Testing

1. Find the Dataproc Server cluster name and the image version to be referenced in the automation script

2. Decide the network tag to be used for the Dataproc client VM and use that to set up the firewall rules for the following ports to be opened.
- Client to master connection: for example, Hive: 10000 (hive server),9083 (hive metastore), spark: 7077 (spark master port), 7078 (spark worker port) 
- Hue web server: 8888 - user terminal to client
- Zeppelin web server: 8080 - user terminal to client
- Spark web server: 18080 (spark master web ui port), - user temrinal to master

3. Create Client Dataproc VM with the above instructions

4. Validate the success criterion have been met
- Test Hive CLI: User should be able to query tables stored on master Dataproc hive server
- Test Spark Shell ( `spark-shell` for scala and `pyspark` for python): Note that it might take a while to initiate the shell. The job submitted on client VM should be shown on master Dataproc spark history-server UI (http://<spark_host_ip>:18080) - but it may only be shown after `exit()` the shell. 
- Test spark-submit: The job submitted on client VM should be shown on master Dataproc spark history-server UI (http://<spark_host_ip>:18080)
- Test running Hive Query from Zeppelin: User should be able to query tables stored on master Dataproc hive server
- Test running Hive Query from Hue: User should be able to query tables stored on master Dataproc hive server



## To-do

- Automate the image creation and simple the steps for usinig the package.

- Image Version as input metadata that matches the server to be used to create the image  

- Currently opend all ports from client to server 

## Disclaimer

This is not an official Google project.

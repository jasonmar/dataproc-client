# Dataproc Client from a pre-configured VM instance

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
cd dataproc-client-vm-startup/from-img
```


3. Modify [metadata.config](metadata.config)

Replace the following placeholders:

* `my-project` project name
* `my-dataproc-client`
* `my-service-account` email address if your GCP service account
* `my-dataproc-cluster` name of the dataproc cluster you want to create a client for
* `my-bucket` GCS bucket


4. Run setup script

[create-dproclient-from-img.sh](create-dproclient-from-img.sh)

```sh
./create-dproclient-from-img.sh
```


5. Access Zeppelin web UI

[http://localhost:8080](http://localhost:8080)

Create a JDBC interpreter connecting Zeppelin with the remote Dataproc cluster:

- `default.driver` -> `org.apache.hive.jdbc.HiveDriver`
- `default.url` -> `jdbc:hive2://<target_dataproc_cluster_name-m>:10000/`
- `artifacts` -> `org.apache.hive:hive-jdbc:0.14.0 & org.apache.hadoop:hadoop-common:2.6.0`


6. Access Hue Web UI

[http://localhost:8888](http://localhost:8888)


7. Access Spark Web UI

[http://localhost:18080](http://localhost:18080)



## Disclaimer

This is not an official Google project.

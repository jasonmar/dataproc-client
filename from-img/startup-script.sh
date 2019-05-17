#!/bin/bash
sleep 45;
sudo sed -i "s/test-client-dp-demo-m/hive-server-bigger-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/test-client-vm-demo-m/hive-server-bigger-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/test-client-dp-demo-m/hive-server-bigger-m/g" /etc/hive/conf/hive-site.xml;
sudo sed -i "s/test-client-vm-demo-m/hive-server-bigger-m/g" /etc/spark/conf/spark-defaults.conf;
sudo sed -i "s/test-client-dp-demo-m/hive-server-bigger-m/g" /etc/spark/conf/spark-defaults.conf;
/etc/spark/conf/spark-env.sh;
sudo service spark-history-server restart;
sudo perl -pi -e s/hive_server_host=test-client-dp-demo-m.c.albatross-kvasilakakis-sandbox.internal/hive_server_host=hive-server-bigger-m.c.albatross-kvasilakakis-sandbox.internal/ /etc/hue/conf/hue.ini;
sudo systemctl restart hue;

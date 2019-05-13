#!/bin/bash
sleep 45;
sudo sed -i "s/hive-server-m/hive-server-2-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/test-client-opt-init-4-structured-m/hive-server-2-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/hive-server-m/hive-server-2-m/g" /etc/hive/conf/hive-site.xml;
sudo sed -i "s/test-client-opt-init-4-structured-m/hive-server-2-m/g" /etc/spark/conf/spark-defaults.conf;
sudo sed -i "s/hive-server-m/hive-server-2-m/g" /etc/spark/conf/spark-defaults.conf;
/etc/spark/conf/spark-env.sh;
sudo service spark-history-server restart;
cd /opt/huezep;
sudo chmod 777 hue.sh |& tee -a /opt/huezep/output.txt;
sudo ./hue.sh |& tee -a /opt/huezep/output.txt;
sudo chmod 777 zeppelin.sh |& tee -a /opt/huezep/output.txt;
sudo ./zeppelin.sh |& tee -a /opt/huezep/output.txt;
sudo perl -pi -e s/hive_server_host=test-client-opt-init-4-structured-m.c.albatross-kvasilakakis-sandbox.internal/hive_server_host=hive-server-2-m.c.albatross-kvasilakakis-sandbox.internal/ /etc/hue/conf/hue.ini;
sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini;
sudo systemctl restart hue;

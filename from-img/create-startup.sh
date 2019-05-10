#define parameters which are passed in
YOUR_TARGET_CLUSTER=$1

#define the template
cat  << EOF
#!/bin/bash
sleep 45;
sudo sed -i "s/hive-server-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/test-client-opt-init-4-structured-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/hive-server-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/hive/conf/hive-site.xml;
sudo sed -i "s/test-client-opt-init-4-structured-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/spark/conf/spark-defaults.conf;
sudo sed -i "s/hive-server-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/spark/conf/spark-defaults.conf;
/etc/spark/conf/spark-env.sh;
sudo service spark-history-server restart
EOF
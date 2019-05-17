#!/bin/bash
# Copyright 2019 Google, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


sudo mkdir /opt/huezep 
cd /opt/huezep

gsbucket="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
echo $gsbucket
sudo gsutil cp gs://$gsbucket/metadata.config /opt/huezep/  |& sudo tee -a /opt/huezep/output.txt
. metadata.config

sudo gsutil cp -r gs://$gsbucket/* /opt/huezep/ |& sudo tee -a /opt/huezep/output.txt

sudo sed -i "s/${YOUR_CLIENT}-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/${YOUR_CLIENT}-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/hive/conf/hive-site.xml;
sudo sed -i "s/${YOUR_CLIENT}-m/${YOUR_TARGET_CLUSTER}-m/g" /etc/spark/conf/spark-defaults.conf;
/etc/spark/conf/spark-env.sh;
sudo service spark-history-server restart;

cd /opt/huezep
sudo chmod 777 hue.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./hue.sh |& sudo tee -a /opt/huezep/output.txt

sudo chmod 777 zeppelin.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./zeppelin.sh |& sudo tee -a /opt/huezep/output.txt

. metadata.config

sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini
sudo perl -pi -e s/hive_server_host=${YOUR_CLIENT}-m.c.${YOUR_PROJECT}.internal/hive_server_host=${YOUR_TARGET_CLUSTER}-m.c.${YOUR_PROJECT}.internal/ /etc/hue/conf/hue.ini;

systemctl restart hue 

exit

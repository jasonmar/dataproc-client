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

sleep 45;
sudo sed -i "s/hive-server-bigger-2-m/hive-server-bigger-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/test-client-vm-demo-4-m/hive-server-bigger-m/g" /etc/hadoop/conf/core-site.xml /etc/hadoop/conf/hdfs-site.xml /etc/hadoop/conf/mapred-site.xml /etc/hadoop/conf/yarn-site.xml;
sudo sed -i "s/hive-server-bigger-2-m/hive-server-bigger-m/g" /etc/hive/conf/hive-site.xml;
sudo sed -i "s/test-client-vm-demo-4-m/hive-server-bigger-m/g" /etc/spark/conf/spark-defaults.conf;
sudo sed -i "s/hive-server-bigger-2-m/hive-server-bigger-m/g" /etc/spark/conf/spark-defaults.conf;
/etc/spark/conf/spark-env.sh;
sudo service spark-history-server restart;
sudo perl -pi -e s/hive_server_host=hive-server-bigger-2-m.c.albatross-kvasilakakis-sandbox.internal/hive_server_host=hive-server-bigger-m.c.albatross-kvasilakakis-sandbox.internal/ /etc/hue/conf/hue.ini;
sudo systemctl restart hue;

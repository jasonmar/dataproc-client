#!/bin/bash

# sudo su
# cd /
mkdir /opt/huezep
cd /opt/huezep

gsbucket="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
echo $gsbucket
gsutil cp gs://$gsbucket/metadata.config /opt/huezep/
. metadata.config


gsutil cp -r gs://$gsbucket/* /opt/huezep/

# target="$(/usr/share/google/get_metadata_value attributes/target-dataproc-cluster)-m"
# echo $target
# echo $script
# sed -i -e "s|^MASTER_HOSTNAMES=.*|MASTER_HOSTNAMES=($target)|" -e 's|export KERBEROS_ENABLED|return;export KERBEROS_ENABLED|' $script
# echo $script

chmod 777 startup.sh
./startup.sh


cd /usr/local/share/google/dataproc
chmod 777 launch-agent.sh
./launch-agent.sh

# cd /usr/local/share/google/dataproc
# chmod 777 startup-script-cloud_datarefinery_image_20190228_nightly-RC01.sh
# ./startup-script-cloud_datarefinery_image_20190228_nightly-RC01.sh

script_image=$(grep -m 1 STARTUP_SCRIPT_LOCATION /usr/local/share/google/dataproc/launch-agent.sh | awk -F= {'print $2'})
chmod 777 $script_image
exec $script_image



gsutil cp gs://$gsbucket/zeppelin.sh /opt/huezep/
gsutil cp gs://$gsbucket/hue.sh /opt/huezep/
cd /opt/huezep
chmod 777 hue.sh
./hue.sh
# bash -v hue.sh
# bash zeppelin.sh

chmod 777 zeppelin.sh
./zeppelin.sh

. metadata.config

# for hue configuration
sudo perl -pi -e s/hive_server_host=${YOUR_CLIENT}-m.c.${YOUR_PROJECT}.internal/hive_server_host=${YOUR_TARGET_CLUSTER}-m.c.${YOUR_PROJECT}.internal/ /etc/hue/conf/hue.ini
sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini

systemctl restart hue

logout
exit

#!/bin/bash



sudo mkdir /opt/huezep 
cd /opt/huezep


gsbucket="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
echo $gsbucket
sudo gsutil cp gs://$gsbucket/metadata.config /opt/huezep/  |& sudo tee -a /opt/huezep/output.txt
. metadata.config
sudo gsutil cp -r gs://$gsbucket/* /opt/huezep/ |& sudo tee -a /opt/huezep/output.txt


sudo su
sudo chmod 777 startup.sh |& sudo tee -a /opt/huezep/output.txt
sudo  ./startup.sh |& sudo tee -a /opt/huezep/output.txt 
cd /usr/local/share/google/dataproc
sudo chmod 777 launch-agent.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./launch-agent.sh |& sudo tee -a /opt/huezep/output.txt
script_image=$(grep -m 1 STARTUP_SCRIPT_LOCATION /usr/local/share/google/dataproc/launch-agent.sh | awk -F= {'print $2'})
sudo chmod 777 $script_image |& sudo tee -a /opt/huezep/output.txt
exec $script_image |& sudo tee -a /opt/huezep/output.txt
exit

cd /opt/huezep
sudo chmod 777 hue.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./hue.sh |& sudo tee -a /opt/huezep/output.txt

sudo chmod 777 zeppelin.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./zeppelin.sh |& sudo tee -a /opt/huezep/output.txt

. metadata.config

# for hue configuration
sudo perl -pi -e s/hive_server_host=${YOUR_CLIENT}-m.c.${YOUR_PROJECT}.internal/hive_server_host=${YOUR_TARGET_CLUSTER}-m.c.${YOUR_PROJECT}.internal/ /etc/hue/conf/hue.ini
sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini

systemctl restart hue 


logout
exit

#!/bin/bash


sudo mkdir /opt/huezep 
cd /opt/huezep

gsbucket="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
echo $gsbucket
sudo gsutil cp gs://$gsbucket/metadata.config /opt/huezep/  |& sudo tee -a /opt/huezep/output.txt
. metadata.config


sudo gsutil cp -r gs://$gsbucket/* /opt/huezep/ |& sudo tee -a /opt/huezep/output.txt


cd /opt/huezep
sudo chmod 777 hue.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./hue.sh |& sudo tee -a /opt/huezep/output.txt

sudo chmod 777 zeppelin.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./zeppelin.sh |& sudo tee -a /opt/huezep/output.txt

. metadata.config

sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini

systemctl restart hue 


exit

#!/bin/bash


#sudo su
#cd /
# cd /


sudo mkdir /opt/huezep 
cd /opt/huezep

gsbucket="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
echo $gsbucket
sudo gsutil cp gs://$gsbucket/metadata.config /opt/huezep/  |& sudo tee -a /opt/huezep/output.txt
. metadata.config


sudo gsutil cp -r gs://$gsbucket/* /opt/huezep/ |& sudo tee -a /opt/huezep/output.txt

# target="$(/usr/share/google/get_metadata_value attributes/target-dataproc-cluster)-m"
# echo $target
# echo $script
# sed -i -e "s|^MASTER_HOSTNAMES=.*|MASTER_HOSTNAMES=($target)|" -e 's|export KERBEROS_ENABLED|return;export KERBEROS_ENABLED|' $script
# echo $script


# sudo bash <<EOF

# sudo chmod 777 /usr/local/share/google/dataproc/bdutil/bdutil_env.sh 


sudo su

sudo chmod 777 startup.sh |& sudo tee -a /opt/huezep/output.txt
sudo  ./startup.sh |& sudo tee -a /opt/huezep/output.txt 


cd /usr/local/share/google/dataproc
sudo chmod 777 launch-agent.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./launch-agent.sh |& sudo tee -a /opt/huezep/output.txt



# cd /usr/local/share/google/dataproc
# sudo chmod 777 startup-script-cloud_datarefinery_image_20190510_nightly-RC01.sh |& sudo tee -a /opt/huezep/output.txt
#sudo ./startup-script-cloud_datarefinery_image_20190510_nightly-RC01.sh |& sudo tee -a /opt/huezep/output.txt



script_image=$(grep -m 1 STARTUP_SCRIPT_LOCATION /usr/local/share/google/dataproc/launch-agent.sh | awk -F= {'print $2'})
sudo chmod 777 $script_image |& sudo tee -a /opt/huezep/output.txt



# export BDUTIL_DIR=/usr/local/share/google/dataproc/bdutil 
# echo ${BDUTIL_DIR}
# ex -sc '2i|BDUTIL_DIR=/usr/local/share/google/dataproc/bdutil' -cx $script_image
# ex -sc '3i|echo ${BDUTIL_DIR}' -cx $script_image


# sudo -u root  
# sudo su |& sudo tee -a /opt/huezep/output.txt 
exec $script_image |& sudo tee -a /opt/huezep/output.txt

exit

# exit |& sudo tee -a /opt/huezep/output.txt


# sudo gsutil cp gs://$gsbucket/zeppelin.sh /opt/huezep/
#sudo gsutil cp gs://$gsbucket/hue.sh /opt/huezep/

cd /opt/huezep
sudo chmod 777 hue.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./hue.sh |& sudo tee -a /opt/huezep/output.txt
# bash -v hue.sh
# bash zeppelin.sh

sudo chmod 777 zeppelin.sh |& sudo tee -a /opt/huezep/output.txt
sudo ./zeppelin.sh |& sudo tee -a /opt/huezep/output.txt

. metadata.config

# for hue configuration
sudo perl -pi -e s/hive_server_host=${YOUR_CLIENT}-m.c.${YOUR_PROJECT}.internal/hive_server_host=${YOUR_TARGET_CLUSTER}-m.c.${YOUR_PROJECT}.internal/ /etc/hue/conf/hue.ini
sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini

systemctl restart hue 

# EOF

logout
exit

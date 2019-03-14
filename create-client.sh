#!/bin/bash


sudo su

. metadata.config

gcloud beta dataproc clusters create ${YOUR_CLIENT} \
  --region $YOUR_REGION --subnet $YOUR_NETWORK --zone $YOUR_ZONE \
  --single-node --master-machine-type n1-standard-2 \
  --master-boot-disk-size 200 --image-version preview \
  --tags $YOUR_CLIENT_TAG --project $YOUR_PROJECT \
  --service-account $YOUR_SERVICE_ACCOUNT \
  --metadata=target-dataproc-cluster=${YOUR_TARGET_CLUSTER}
  #(paused) todo: whether choice of image-version can be automated (feasible and worthwhile?) by picking the image used for the server dataproc
  # if the server was created using "preview" image (with python being 3.5 conda), then the image-version tag here should be "preview"
  # if the server was created using "1.3-deb9 " image for example (with python being 2.7), then the image-version tag should be "1.3-deb9"



gsutil mb -p ${YOUR_PROJECT} -c ${YOUR_STORAGE_CLASS} gs://${YOUR_BUCKET}
returnvalue=$?
if [ $returnvalue = 1 ]; \
then \
store=${YOUR_BUCKET}
storenew=${YOUR_STORAGE_BUCKET}
sudo sed -i "s/$store/$storenew/g" metadata.config 
. metadata.config
gsutil rm -r gs://${YOUR_BUCKET}
gsutil mb -p ${YOUR_PROJECT} -c ${YOUR_STORAGE_CLASS} gs://${YOUR_BUCKET};
else \
echo 'success'; \
fi


gsutil -m cp -r * gs://${YOUR_BUCKET}


# to-do: ssh into the client 
# gcloud compute ssh ${YOUR_CLIENT}

sudo su
mkdir /client-creation
cd /client-creation


# this ${YOUR_BUCKET} may not be recognized
gsutil cp gs://${YOUR_BUCKET}/* .
# is that possible we call another .startup-client.sh with the following and call .metadata.config first


chmod 777 startup.sh
 ./startup.sh


cd /usr/local/share/google/dataproc
chmod 777 launch-agent.sh 
./launch-agent.sh 


cd /usr/local/share/google/dataproc
chmod 777 lstartup-script-cloud_datarefinery_image_20190228_nightly-RC01.sh
./startup-script-cloud_datarefinery_image_20190228_nightly-RC01.sh
# to-do  this file may change name 

cd /client-creation
bash hue.sh
bash zeppelin.sh

# todo 
# no need now: add fix for hue for the mysql deny error: 
# https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/issues/479#issuecomment-472528203


# for hue configuration
sudo perl -pi -e s/hive_server_host=${YOUR_CLIENT}-m.c.${YOUR_PROJECT}.internal/hive_server_host=${YOUR_TARGET_CLUSTER}-m.c.${YOUR_PROJECT}.internal/ /etc/hue/conf/hue.ini
sudo perl -pi -e 's/## hive_server_port=10000/hive_server_port=10000/g' /etc/hue/conf/hue.ini



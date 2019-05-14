#!/bin/bash

. metadata.config

chmod 777 create-startup.sh

#./create-startup.sh ${YOUR_TARGET_CLUSTER} > startup-script.sh

./create-startup.sh ${YOUR_TARGET_CLUSTER} ${YOUR_PROJECT} > startup-script.sh


gcloud compute --project=$YOUR_PROJECT instances create ${YOUR_CLIENT} \
 --zone=$YOUR_ZONE --machine-type=n1-standard-1 --subnet=$YOUR_NETWORK \
 --network-tier=PREMIUM --maintenance-policy=MIGRATE \
 --service-account=$YOUR_SERVICE_ACCOUNT \
 --scopes=https://www.googleapis.com/auth/cloud-platform \
 --tags=$YOUR_CLIENT_TAG --image=${YOUR_IMAGE} \
 --image-project=$YOUR_PROJECT --boot-disk-size=200GB \
 --boot-disk-type=pd-standard --boot-disk-device-name=${YOUR_CLIENT} \
 --metadata-from-file startup-script=$PWD/startup-script.sh \
 --verbosity debug


. metadata.config

chmod 777 create-install-huezep.sh
./create-install-huezep.sh ${YOUR_TARGET_CLUSTER} ${YOUR_PROJECT} > install-huezep.sh

# no -m this time as it's vm
gcloud compute --project ${YOUR_PROJECT} ssh --zone ${YOUR_ZONE} ${YOUR_CLIENT}  --command 'bash -s' < $PWD/install-huezep.sh


 

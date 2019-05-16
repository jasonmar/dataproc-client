#!/bin/bash

. metadata.config

chmod 777 create-startup.sh

./create-startup.sh ${OLD_TARGET_CLUSTER} $YOUR_PROJECT ${YOUR_TARGET_CLUSTER} ${YOUR_CLIENT} > startup-script.sh


gcloud compute --project=$YOUR_PROJECT instances create ${YOUR_CLIENT} \
 --zone=$YOUR_ZONE --machine-type=${IMG_MACHINE_TYPE} --subnet=$YOUR_NETWORK \
 --service-account=$YOUR_SERVICE_ACCOUNT \
 --scopes=https://www.googleapis.com/auth/cloud-platform \
 --tags=$YOUR_CLIENT_TAG --image=${YOUR_IMAGE} \
 --image-project=$YOUR_PROJECT --boot-disk-size=${IMG_BOOT_DISK_SIZE} \
 --boot-disk-type=${IMG_BOOT_DISK_TYPE} --boot-disk-device-name=${YOUR_CLIENT} \
 --metadata-from-file startup-script=$PWD/startup-script.sh \
 --verbosity debug

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

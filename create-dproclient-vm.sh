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

gsutil mb -p ${YOUR_PROJECT} -c ${YOUR_STORAGE_CLASS} gs://${YOUR_BUCKET}
returnvalue=$?
if [ $returnvalue = 1 ]; \
then \
store=${YOUR_BUCKET}
storenew=${YOUR_STORAGE_BUCKET}
sudo sed -i "s/$store/$storenew/g" metadata.config 
. metadata.config
gsutil -m rm -r gs://${YOUR_BUCKET}
gsutil mb -p ${YOUR_PROJECT} -c ${YOUR_STORAGE_CLASS} gs://${YOUR_BUCKET};
else \
echo 'success'; \
fi

gsutil -m cp -r /$PWD/util/* gs://${YOUR_BUCKET}
gsutil -m cp create-dproclient-vm.sh gs://${YOUR_BUCKET}
gsutil -m cp metadata.config gs://${YOUR_BUCKET}

gcloud dataproc clusters create ${YOUR_CLIENT} \
  --region $YOUR_REGION --subnet $YOUR_NETWORK --zone $YOUR_ZONE \
  --single-node --master-machine-type n1-standard-2 \
  --master-boot-disk-size 200 --image-version 1.3-deb9 \
  --tags $YOUR_CLIENT_TAG --project $YOUR_PROJECT \
  --service-account $YOUR_SERVICE_ACCOUNT \
  --metadata=target-dataproc-cluster=${YOUR_TARGET_CLUSTER},gs-bucket-name=${YOUR_BUCKET} 
#  --initialization-actions=gs://${YOUR_BUCKET}/install-client.sh \
 
gcloud compute --project ${YOUR_PROJECT} ssh --zone ${YOUR_ZONE} ${YOUR_CLIENT}-m --command 'sudo bash -s' < /$PWD/util/install-client.sh >> local-output.txt
 
 


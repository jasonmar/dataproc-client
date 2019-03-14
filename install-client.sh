#!/bin/bash

sudo su
cd /
mkdir huezep
cd huezep

target="$(/usr/share/google/get_metadata_value attributes/gs-bucket-name)"
gsutil cp gs://$target/metadata.config /huezep/
. metadata.config

gsutil cp gs://${YOUR_BUCKET}/initialization-actions/zeppelin/zeppelin.sh /huezep/
gsutil cp gs://${YOUR_BUCKET}/initialization-actions/hue/* /huezep/
bash -v hue.sh
#bash zeppelin.sh

gsutil cp -r gs://${YOUR_BUCKET}/* /huezep/

target="$(/usr/share/google/get_metadata_value attributes/target-dataproc-cluster)-m"
echo $target
echo $script
sed -i -e "s|^MASTER_HOSTNAMES=.*|MASTER_HOSTNAMES=($target)|" -e 's|export KERBEROS_ENABLED|return;export KERBEROS_ENABLED|' $script
echo $script

cp /huezep/hue-configure.service /lib/systemd/system/
sudo mkdir -p /etc/hue
cp /huezep/metadata.config /etc/hue/
cp /huezep/hue-configure.sh /usr/bin/

logout
exit

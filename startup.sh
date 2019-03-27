#!/bin/bash
target="$(/usr/share/google/get_metadata_value attributes/target-dataproc-cluster)-m"
script=$(grep -m 1 STARTUP_SCRIPT_LOCATION /usr/local/share/google/dataproc/launch-agent.sh | awk -F= {'print $2'})
sed -i -e "s|^MASTER_HOSTNAMES=.*|MASTER_HOSTNAMES=($target)|" -e 's|export KERBEROS_ENABLED|return;export KERBEROS_ENABLED|' $script

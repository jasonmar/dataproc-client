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
#!/usr/bin/env bash

# Run as root on Dataproc master node after dataproc-startup-script

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
  return 1
}

function info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
}

function wait_for_startup() {
  for ((i = 0; i < 60; i++)); do
  	egrep -q 'All done$' /var/log/dataproc-startup-script.log 2>/dev/null
  	e=$?
    [ $e -eq 0 ] && return 0
    sleep 30
    info "Waiting for dataproc-startup-script..."
  done
  err "Timed out waiting for dataproc-startup-script"
}

wait_for_startup || exit 1

cat <<EOF>> /etc/inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOF

set -e
set -x

cd /usr/share/google
BUCKET=$(/usr/share/google/get_metadata_value attributes/config-bucket)
FILES="config-files configure.sh create-templates.sh disable-services.sh"
for f in $FILES; do
  gsutil cp "gs://$BUCKET/$f" .
done
chmod +x configure.sh create-templates.sh disable-services.sh

# Install configuration startup service
gsutil cp "gs://$BUCKET/google-edgenode-configure.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable google-edgenode-configure

# Disable services that are unnecessary on edge nodes
/usr/share/google/disable-services.sh

# Create configuration templates
/usr/share/google/create-templates.sh

# Shutdown instance for image capture
shutdown -h now

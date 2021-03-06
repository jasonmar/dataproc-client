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

# run as root

DATAPROC_MASTER=$(/usr/share/google/get_metadata_value attributes/dataproc-master)

# Creates configuration templates
for f in $(cat /usr/share/google/config-files); do
  if [ -f "${f}" ]; then
    echo "Creating template: ${f}"
    sed -e "s|${DATAPROC_MASTER}|{{ DATAPROC_MASTER }}|g" "${f}" > "${f}.template"
  fi
done

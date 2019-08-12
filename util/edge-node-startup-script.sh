#!/usr/bin/env bash
gsutil cp "gs://$(/usr/share/google/get_metadata_value attributes/config-bucket)/setup_edge_node.sh" "/usr/share/google/"
nohup bash /usr/share/google/setup_edge_node.sh >/var/log/edgenode-startup.log 2>&1 &
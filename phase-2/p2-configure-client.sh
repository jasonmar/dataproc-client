
#!/bin/bash

cp hue-configure.service /lib/systemd/system/
sudo mkdir -p /etc/hue
cp metadata.config /etc/hue/
cp hue-configure.sh /usr/bin/
chmod u+x /usr/bin/hue-configure.sh
sudo systemctl enable hue-configure.service
sudo systemctl start hue-configure.service

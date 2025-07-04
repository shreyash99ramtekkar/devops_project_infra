#!/bin/sh
sudo apt update -y
sudo apt install openjdk-17-jdk -y
wget https://download.sonatype.com/nexus/3/nexus-3.81.1-01-linux-x86_64.tar.gz
mkdir -p /opt/sonatype
sudo tar -xvzf nexus-3.81.1-01-linux-x86_64.tar.gz -C /opt/sonatype/
ln -s /opt/sonatype/nexus-3.81.1-01 /opt/sonatype/nexus
sudo groupadd nexus
sudo useradd -r -g nexus -d /opt/sonatype/nexus -s /bin/sh nexus
sudo chown -R nexus:nexus /opt/sonatype
echo 'run_as_user="nexus"' > /opt/sonatype/nexus/bin/nexus.rc
sed -i 's/-Xms[0-9]*m/-Xms1024m/' /opt/sonatype/nexus/bin/nexus.vmoptions
sed -i 's/-Xmx[0-9]*m/-Xmx1024m/' /opt/sonatype/nexus/bin/nexus.vmoptions
echo "[Unit]
Description=nexus service
After=network.target
  
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/sonatype/nexus/bin/nexus start
ExecStop=/opt/sonatype/nexus/bin/nexus stop

User=nexus
Restart=on-abort
TimeoutSec=600
  
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/nexus.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service


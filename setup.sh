sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y

#########

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list

sudo apt-get update
sudo apt-get install metricbeat -y
sudo apt-get install filebeat -y

sudo cp /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.bak.yml
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.bak.yml

sudo nano /etc/metricbeat/metricbeat.yml
sudo nano /etc/filebeat/filebeat.yml

sudo mv /etc/filebeat/modules.d/system.yml.disabled /etc/filebeat/modules.d/system.yml

sudo diff /etc/metricbeat/metricbeat.bak.yml /etc/metricbeat/metricbeat.yml || true
sudo diff /etc/filebeat/filebeat.bak.yml /etc/filebeat/filebeat.yml || true

sudo systemctl enable metricbeat
sudo systemctl enable filebeat

sudo systemctl start metricbeat
sudo systemctl start filebeat

sudo systemctl status metricbeat
sudo systemctl status filebeat

#########

wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install apt-transport-https

sudo apt-get install dotnet-sdk-2.2 -y
sudo apt-get install powershell -y

dotnet --version
pwsh -v

#########

sudo apt-get install git -y
sudo apt-get install docker.io -y
sudo apt-get install curl -y

#########

echo "tmpfs  /mnt/ramdisk  tmpfs  defaults,noatime,nosuid,nodev,mode=1777,size=32G  0  0" | sudo tee -a /etc/fstab

#########

sudo adduser teamcity
sudo usermod -a -G docker teamcity

wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jre_x64_linux_hotspot_8u202b08.tar.gz
tar -xf OpenJDK8U-jre_x64_linux_hotspot_8u202b08.tar.gz
sudo mv jdk8u202-b08-jre ../teamcity/jre
export PATH=/home/teamcity/jre/bin:$PATH
chown teamcity:teamcity ../teamcity/jre
java -version

# wget https://www.jetbrains.com/teamcity/download/download-thanks.html?platform=linux
wget https://download.jetbrains.com/teamcity/TeamCity-2018.2.2.tar.gz
tar -xf TeamCity-2018.2.2.tar.gz
cp buildAgent.properties TeamCity/buildAgent/conf
sudo mv TeamCity/buildAgent ../teamcity/tcagent
chown teamcity:teamcity ../teamcity/tcagent
rm -rf TeamCity


echo '[Unit]
Description=TeamCity Build Agent
After=network.target

[Service]
Type=oneshot

User=teamcity
Group=teamcity
ExecStart=/home/teamcity/tcagent/bin/agent.sh start
ExecStop=-/home/teamcity/tcagent/bin/agent.sh stop

# Support agent upgrade as the main process starts a child and exits then
RemainAfterExit=yes
# Support agent upgrade as the main process gets SIGTERM during upgrade and that maps to exit code 143
SuccessExitStatus=0 143

[Install]
WantedBy=default.target' | sudo tee -a /etc/systemd/system/teamcity.service

sudo systemctl enable teamcity
sudo systemctl start teamcity

#########

echo 'date
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y' > update.sh

echo $'date
docker container prune -f
docker images prune -f
docker system prune -f
docker images -a | grep "\.azurecr\." | grep -v "minutes ago" | awk \'{print $3}\' | xargs docker rmi -f' > prune_docker.sh

crontab -e
# * * * * * /home/$USER/update.sh >> update.log
# * * * * * /home/$USER/prune_docker.sh >> prune_docker.log
# * * * * * sudo /usr/bin/pwsh /home/$USER/prune_builds.ps1 >> prune_builds.log

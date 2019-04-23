sudo apt-get update && apt-get upgrade -y
sudo apt-get dist-upgrade -y

sudo apt autoremove -y
sudo sh -c 'echo "sudo apt autoremove -y" >> /etc/cron.monthly/autoremove'
sudo chmod +x /etc/cron.monthly/autoremove
sudo reboot now

sudo apt-get update
sudo apt-get install --install-recommends linux-virtual -y
sudo apt-get install linux-tools-virtual linux-cloud-tools-virtual -y
reboot now

sudo nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="elevator=noop"
sudo update-grub
sudo reboot now

date
sudo timedatectl set-timezone Europe/Berlin

sudo nano /etc/netplan/50-cloud-init.yaml

network:
    ethernets:
        eth0:
            addresses:
            - 192.168.1.4/24
            gateway4: 192.168.1.1
            nameservers:
                addresses:
                - 192.168.1.1
                search: []
            optional: true
    version: 2

sudo netplan apply

#misc
sudo apt-get install cockpit -y
sudo apt-get install htop -y
sudo apt-get install haveged -y





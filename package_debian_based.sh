#!/bin/bash

OS_ARCH=$(uname -p)

if [[ "$(id -u)" -ne 0 || ${OS_ARCH} == "x86_64" && "$(stat -c %d:%i /)" == "$(stat -c %d:%i /proc/1/root/.)" ]]; then

	echo "you are not in the chroot !"
	exit 0

fi

swapoff -a
touch /etc/apt/sources.list

/bin/cat /dev/null > /etc/apt/sources.list
/bin/cat <<etc_apt_sources_list >> /etc/apt/sources.list
deb http://cdn-fastly.deb.debian.org/debian stretch main contrib non-free
deb-src http://cdn-fastly.deb.debian.org/debian stretch main contrib non-free

etc_apt_sources_list

apt -y update

list_to_install="usbutils bash-completion isc-dhcp-client isc-dhcp-common net-tools iputils-ping psmisc tar tcpd usbutils dhcpcd5 neofetch
util-linux ntp dnsutils udev kmod ethtool lsb-base lsb-release nano dropbear bash-completion netbase unzip git perl python  
wget libnl-route-3-200 libnl-3-200 libnl-genl-3-200 iw crda libssl-dev ifupdown iproute2 tzdata fake-hwclock sudo isc-dhcp-server"

apt -y install --reinstall dbus
apt-get -y clean
apt remove --purge -y rsyslog
apt -y install busybox-syslogd
apt -y install locales 
dpkg-reconfigure locales
apt -y install --no-install-recommends console-common console-data console-setup console-setup-linux iptables iptables-persistent netfilter-persistent		     	
apt -y install --no-install-recommends ${list_to_install}
apt -y upgrade

##########################################################
## Setup #################################################
##########################################################

RPIUSER=pi

useradd -s /bin/bash -G sudo,adm,netdev,www-data -m ${RPIUSER}
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/${RPIUSER}/.bashrc
echo -en 'if [ -f /tmp/rw ];then\n\n\tPS1="[rw][\u@\h]:\w$ "\n\nelse\n\n\techo && neofetch\n\nfi\n' >> /home/${RPIUSER}/.bashrc

echo "${RPIUSER}:raspberry" | chpasswd
# echo "root:raspberryroot" | chpasswd

echo "Etc/Universal" >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# /etc/hostname
rm -rf /etc/hostname /etc/hosts
touch /etc/hostname /etc/hosts
HOSTNAME_RPI=a404dded
echo ${HOSTNAME_RPI} >> /etc/hostname

# /etc/hosts
echo -en "::1 localhost localhost.localdomain ${HOSTNAME_RPI}.localdomain\n127.0.0.1 localhost localhost.localdomain ${HOSTNAME_RPI}.localdomain\n
The following lines are desirable for IPv6 capable hosts\n::1		ip6-localhost ip6-loopback\nfe00::0		ip6-localnet\n
ff00::0		ip6-mcastprefix\nff02::1		ip6-allnodes\nff02::2		ip6-allrouters\n\n127.0.1.1\t${HOSTNAME_RPI}\n" >> /etc/hosts

# Don't wait forever and a day for the network to come online
if [ -s /lib/systemd/system/networking.service ]; then

	sed -i -e "s/TimeoutStartSec=5min/TimeoutStartSec=5sec/" /lib/systemd/system/networking.service

fi
if [ -s /lib/systemd/system/ifup@.service ]; then

	echo "TimeoutStopSec=5s" >> /lib/systemd/system/ifup@.service

fi

###########
## mkdir ##
###########

rm -rf /lib/firmware
mkdir -p  /lib/firmware /etc/network

##################
## /lib/systemd ##
##################

################
# fake-hwclock #
################

# service

/bin/cat /dev/null > /lib/systemd/system/fake-hwclock1h.service
/bin/cat <<fake_hwclock1h >> /lib/systemd/system/fake-hwclock1h.service
[Unit]
Description=write hardware clock every hour

[Service]
Type=simple        
ExecStart=/bin/bash -c "/sbin/fake-hwclock1h"

[Install]
WantedBy=multi-user.target 

fake_hwclock1h

cp /lib/systemd/system/fake-hwclock1h.service /etc/systemd/system/fake-hwclock1h.service

# timer

/bin/cat /dev/null > /lib/systemd/system/fake-hwclock1h.timer
/bin/cat <<fake_hwclock1h_timer >> /lib/systemd/system/fake-hwclock1h.timer
[Unit]
Description=write hardware clock every hour

[Timer]
OnBootSec=0min
OnUnitActiveSec=1h

[Install]
WantedBy=multi-user.target fake-hwclock1h.service

fake_hwclock1h_timer

cp /lib/systemd/system/fake-hwclock1h.timer /etc/systemd/system/fake-hwclock1h.timer


###########
## /etc/ ##
###########

##############
# interfaces #
##############

/bin/cat /dev/null > /etc/network/interfaces
/bin/cat <<etc_network_interfaces >> /etc/network/interfaces
source-directory /etc/network/interfaces.d

etc_network_interfaces

#########
# fstab #
#########

/bin/cat /dev/null > /etc/fstab
/bin/cat <<etc_fstab >> /etc/fstab
# classic
proc            /proc           proc    defaults        0       0
/dev/mmcblk0p1  /boot           vfat    defaults,ro     0       2
/dev/mmcblk0p2  /               ext4    defaults,nodiratime,noatime     0       1

# ramdisk
tmpfs		/tmp	tmpfs	nodiratime,noatime,nodev,nosuid,size=8M		0	0

# squashfs
/boot/firmware.squashfs          /lib/firmware           squashfs        loop    0       0

etc_fstab

#################
# journald.conf #
#################

/bin/cat /dev/null > /etc/systemd/journald.conf
/bin/cat <<journald_conf >> /etc/systemd/journald.conf
[Journal]
Storage=volatile
Compress=yes

journald_conf

###########
## /usr/ ##
###########

################
# fake-hwclock #
################

rm -rf /etc/cron.hourly/fake-hwclock
/bin/cat /dev/null > /sbin/fake-hwclock1h
/bin/cat <<fake_hwclock >> /sbin/fake-hwclock1h
#!/bin/bash

###########################
## Fake hwclock file gen ##
###########################

if [[ \$(id -u) -ne 0 ]];then

	echo "only root can save the clock"

else
	
	/sbin/fake-hwclock save

fi

fake_hwclock

chmod 0600 /etc/network/interfaces
chmod 0644 /etc/systemd/system/fake-hwclock1h.service
chmod 0644 /etc/systemd/system/fake-hwclock1h.timer
chmod 0750 /sbin/fake-hwclock1h
systemctl enable fake-hwclock1h.service
systemctl enable fake-hwclock1h.timer
systemctl disable cron
systemctl mask cron

##########################################################
## Clean local logs ######################################
##########################################################

apt-get clean && apt-get autoclean

logs=`find /var/log -type f`
for i in $logs
do
	> $i
done

rm -rf /home/$(id -nu 1000)/.bash_history
touch /home/$(id -nu 1000)/.bash_history

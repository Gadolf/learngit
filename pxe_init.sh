###Install PXE Require Package
yum -y install syslinux tftp tftp-server dhcp httpd vim openssh-clients

#### Create Directory
mkdir -p /var/www/html/tftpboot
mkdir -p /var/www/html/centos
cp -rf /mnt/* /var/www/html/centos/
mkdir -p /var/www/html/centos/ks/
mkdir -p /var/www/html/tftpboot/pxelinux.cfg


#### Copy Require File to Directory
cp /usr/share/syslinux/pxelinux.0  /var/www/html/tftpboot
cp /usr/share/syslinux/vesamenu.c32 /var/www/html/tftpboot
cp /usr/share/syslinux/menu.c32 /var/www/html/tftpboot
cp /mnt/images/pxeboot/initrd.img /var/www/html/tftpboot
cp /mnt/images/pxeboot/vmlinuz /var/www/html/tftpboot
cp /mnt/isolinux/isolinux.cfg /var/www/html/tftpboot/pxelinux.cfg/default
chmod 644 /var/www/html/tftpboot/pxelinux.cfg/default

#### Configure TFTP SELINUX And DHCP
sed -i 's/\/var\/lib\/tftpboot/\/var\/www\/html\/tftpboot/g' /etc/xinetd.d/tftp
sed -i 's/yes/no/g' /etc/xinetd.d/tftp
sed -i 's/600/30/g' /var/www/html/tftpboot/pexlinux.cfg/default
sed -i '22s/$/ ksdevice=eth0 ks=http:\/\/192.168.1.1\/centos\/ks\/ks.cfg/g' /var/www/html/tftpboot/pxelinux.cfg/default
sed -i 's/enforcing/disabled/g' /etc/selinux/config
sed -i '11s/^/#/g' /etc/selinux/config

echo "ddns-update-style	 none;" > /etc/dhcp/dhcpd.conf
echo "default-lease-time	3600;" >> /etc/dhcp/dhcpd.conf
echo "max-lease-time		7200;" >> /etc/dhcp/dhcpd.conf
echo "subnet 192.168.1.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
echo "		range 192.168.1.100 192.168.1.200;" >> /etc/dhcp/dhcpd.conf
echo "		option subnet-mask 255.255.255.0;" >> /etc/dhcp/dhcpd.conf
echo "		next-server 192.168.1.1;" >> /etc/dhcp/dhcpd.conf
echo '		filename "pxelinux.0";' >> /etc/dhcp/dhcpd.conf
echo "		allow booting;" >> /etc/dhcp/dhcpd.conf
echo "		allow bootp;" >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf


#### Start Service
service iptables stop
setenforce 0
service httpd start
service xinetd start
chkconfig --level 35 iptables off

##CentOS7Update4 with Mellanox & PBS Pro
##Compute node Post installation pdsh "wget -O - http://puppet/gcm-content/repo/script/post-compute.sh | bash"
#!/bin/sh

cat >/etc/yum.repos.d/local.repo<< EOF
[mlnx]
name=MLNX
baseurl=http://puppet/gcm-content/repo/
enabled=1
gpgcheck=0

[centos]
name=CentOS7Update4-local
baseurl=http://puppet/gcm-content/repo/CentOS7Update4/
enabled=1
gpgcheck=0

[rpm]
name=Custom RPM
baseurl=http://puppet/gcm-content/repo/rpm/
enabled=1
gpgcheck=0

EOF


yum install  tcl tk vim numactl-devel -y
yum groupinstall 'Development tools' -y
yum groupinstall 'MLNX_OFED HPC' -y


cat > /etc/sysconfig/network-scripts/ifcfg-ib0 <<EOF
DEVICE=ib0
TYPE=InfiniBand
ONBOOT=yes
BOOTPROTO=none
IPV6INIT=no
CONNECTED_MODE=yes
NETMASK=255.255.255.0
EOF


first="$(/sbin/ip -o -4 addr list em1 | awk '{print $4}' | cut -d/ -f1 |  cut -d. -f1-2)"
second=2
third="$(/sbin/ip -o -4 addr list em1 | awk '{print $4}' | cut -d/ -f1 | cut -d. -f4)"
echo "IPADDR=$first.$second.$third" >> /etc/sysconfig/network-scripts/ifcfg-ib0


systemctl enable openibd
systemctl enable pbs
systemctl disable ip6tables.service
systemctl disable autofs


cat >/etc/pbs.conf << EOF
PBS_EXEC=/opt/pbs
PBS_SERVER=master.local
PBS_START_SERVER=0
PBS_START_SCHED=0
PBS_START_COMM=0
PBS_START_MOM=1
PBS_HOME=/var/spool/pbs
PBS_CORE_LIMIT=unlimited
PBS_SCP=/bin/scp
EOF

cat >/etc/profile.d/module.sh << EOF
export  MODULEPATH=/home/module
EOF

wget http://10.1.1.10/install/post/script/cuda_9.1.85_387.26_linux.run -O /tmp/cuda_9.1.85_387.26_linux.run
wget http://10.1.1.10/install/post/script/config -O /var/spool/pbs/mom_priv/config
wget http://10.1.1.10/install/post/mlnx/docs/scripts/openibd-post-start-configure-interfaces/post-start-hook.sh -O /etc/infiniband/post-start-hook.sh

chmod +x /etc/infiniband/post-start-hook.sh

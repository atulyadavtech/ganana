##File Location /opt/locuz/ganana/vol/lib/cobbler/kickstarts/compute-rhel7.ks
#platform=x86, AMD64, or Intel EM64T
# Kickstart file for RHEL7
# System authorization information
auth --useshadow --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# RHEL Install Key
# TODO: key $getVar('rhel_key', '--skip')
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# GCM repo definition
$SNIPPET('gcm_repo')
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot
#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone Asia/Kolkata
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system disks as needed
$SNIPPET('gcm_partition')
# Add driver disk if available
driverdisk --source=http://$server:$http_port/index.php/g_cm/manage/driverdisk?profile=$getVar('profile', '')

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('gcm_kickstart_start')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
%end


%packages --nobase --ignoremissing --excludedocs
@core --nodefaults
-rdma
-firewalld
-iwl*firmware
-libertas*
-kexec-tools
-NetworkManager*
-plymouth*
-postfix
yum-utils
curl
ruby
$SNIPPET('puppet_install_if_enabled')
%end


%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
$SNIPPET('gcm_time_sync')
$SNIPPET('gcm_kickstart_post_start')
# Disable all existing Base repositories,this must be before yum_config_stanza.
yum-config-manager --disable \*
# Start yum configuration
$yum_config_stanza
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('gcm_puppet')
$SNIPPET('puppet_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
$SNIPPET('kickstart_done')
$SNIPPET('gcm_reboot_check')
# Add prfile based user postscript
$SNIPPET('gcm_postscript')
$SNIPPET('gcm_kickstart_done')
# End final steps
%end

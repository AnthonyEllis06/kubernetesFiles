#!/bin/bash 

#semanage install
echo Installing SEManage
dnf -y install policycoreutils-python-utils

#apply correct SELinux labels to executable program files
echo Binaries
for Binary in crictl kubectl kubelet kube-proxy runc; do
	echo $Binary
	restorecon -v /usr/local/bin/$Binary
done

#update SELinux registry and apply labels to service files.
echo Services
for Service in containerd kubelet kube-proxy; do
	semanage fcontext -a -t systemd_unit_file_t "/usr/lib/systemd/system/$Service.service"
	restorecon -v "/etc/systemd/system/$Service.service"
done

#fix security labes on the config folders using -Recursive
echo Config Files
for ConfigFile in "/etc/containerd/" "/var/lib/kubelet/" "/var/lib/kube-proxy/" "/etc/cni/net.d/" "/opt/cni/bin/"; do
restorecon -R -v $ConfigFile
done

echo finished setting up worker nodes



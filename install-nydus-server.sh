#!/bin/bash
#set -x
set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 install/uninstall"
    exit 1
fi

root="/host"
mkdir -p ${root}/usr/lib/systemd/system

checkanduninstallnydus() {
  echo "[-] check old nydus service "
  if [ -f ${root}/usr/lib/systemd/system/nydus.service ]; then
    echo "[-] has old nydus service, will uninstall it..."
    cd /tmp/ && ./go-systemctl stop nydus.service
    rollbackcontainerd
  fi


  echo "[-] remove old nydus service"
  if [ -f ${root}/usr/bin/containerd-nydus-grpc ]; then rm ${root}/usr/bin/containerd-nydus-grpc; fi
  if [ -f ${root}/usr/bin/ctr-remote ]; then rm ${root}/usr/bin/ctr-remote; fi
  if [ -f ${root}/usr/binnydusctl/ ]; then rm ${root}/usr/bin/nydusctl; fi
  if [ -f ${root}/usr/bin/nydusd ]; then rm ${root}/usr/bin/nydusd; fi
  if [ -f ${root}/usr/bin/nydus_graphdriver ]; then rm ${root}/usr/bin/nydus_graphdriver; fi
  if [ -f ${root}/usr/bin/nydusify ]; then rm ${root}/usr/bin/nydusify; fi
  if [ -f ${root}/usr/bin/nydus-image ]; then rm ${root}/usr/bin/nydus-image; fi
  if [ -f ${root}/usr/bin/nydus-overlayfs ]; then rm ${root}/usr/bin/nydus-overlayfs; fi
  if [ -f ${root}/usr/lib/systemd/system/nydus.service ]; then rm ${root}/usr/lib/systemd/system/nydus.service; fi
  if [ -d ${root}/var/lib/containerd-nydus ]; then rm -rf ${root}/var/lib/containerd-nydus; fi
}

installnydus() {
  echo "[-] start install new nydus service"
  cp -f /tmp/nydus-snapshotter/containerd-nydus-grpc ${root}/usr/bin/
  cp -f /tmp/nydus-static/ctr-remote ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydusctl ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydusd ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydus_graphdriver ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydusify ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydus-image ${root}/usr/bin/
  cp -f /tmp/nydus-static/nydus-overlayfs ${root}/usr/bin/

  cp -f /tmp/nydus.service ${root}/usr/lib/systemd/system

  cd /tmp/ && ./go-systemctl restart nydus.service

  echo "[-] nydus service is running"
}

updatecontainerd() {
  echo "[-] update containerd to use nydus"
  cd /tmp && ./conf-patch -o ${root}/etc/containerd/config.toml -p /tmp/containerd-patch.toml > /tmp/config.toml
  if [ $? -eq 0 ]; then
      echo "[-] patch config.toml success, will restart containerd"
      mv ${root}/etc/containerd/config.toml ${root}/etc/containerd/config.toml.bakup
      mv /tmp/config.toml ${root}/etc/containerd/config.toml
      cd /tmp && ./go-systemctl restart containerd
  else
      echo "[-] patch config.toml failed, will not restart containerd"
  fi
}

rollbackcontainerd() {
  echo "[-] rollback containerd to use overlayfs"
  cd /tmp && ./conf-patch -o ${root}/etc/containerd/config.toml -p /tmp/containerd-rollback-patch.toml > /tmp/config.toml
  if [ $? -eq 0 ]; then
      echo "[-] patch config.toml success, will restart containerd"
      mv ${root}/etc/containerd/config.toml ${root}/etc/containerd/config.toml.bakup
      mv /tmp/config.toml ${root}/etc/containerd/config.toml
      cd /tmp && ./go-systemctl restart containerd
  else
      echo "[-] patch config.toml failed, will not restart containerd"
  fi
}

if [ "$1" = "install" ]; then
    echo "[-] will install nydus"
    checkanduninstallnydus
    installnydus  
    updatecontainerd
else
    echo "[-] will uninstall nydus"
    checkanduninstallnydus
fi

# Nydus-server 
Install nydus in node and config containerd to use nydus

## Introduction
auto install nydus in node and config containerd to use nydus
auto uninstall nydus from node and rollback containerd to use overlayfs

## Useage
### build image
```
docker build -t nydus-server .
```

### install nydus
```
docker run --rm=true --name nydus -v /:/host -v /run:/run nydus-server install
```

### uninstall nydus
```
docker run --rm=true --name nydus -v /:/host -v /run:/run nydus-server uninstall
```

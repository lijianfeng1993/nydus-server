FROM busybox

ADD ./nydus-static-v2.1.4-linux-amd64.tgz /tmp/
ADD ./nydus-snapshotter-v0.8.0-x86_64.tgz /tmp/
ADD ./go-systemctl /tmp/
ADD ./conf-patch /tmp/
ADD ./containerd-patch.toml /tmp
ADD ./containerd-rollback-patch.toml /tmp
ADD ./nydus.service /tmp/
Add ./install-nydus-server.sh /tmp/

ENTRYPOINT ["sh", "/tmp/install-nydus-server.sh"]

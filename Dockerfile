FROM busybox

ADD ./nydus-snapshotter /tmp/nydus-snapshotter
ADD ./nydus-static /tmp/nydus-static
ADD ./go-systemctl /tmp/
ADD ./conf-patch /tmp/
ADD ./containerd-patch.toml /tmp
ADD ./containerd-rollback-patch.toml /tmp
ADD ./nydus.service /tmp/
Add ./install-nydus-server.sh /tmp/

ENTRYPOINT ["sh", "/tmp/install-nydus-server.sh"]

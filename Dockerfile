FROM almalinux:8.6
MAINTAINER Star Lab <info@starlab.io>

ENV LANG=C.utf-8
ENV LC_ALL=C.utf-8
ENV container=docker

# DNF repo config
RUN \
    # Limit updates to 8.6 minor release
    echo 8.6 > /etc/dnf/vars/releasever && \
    \
    # Update existing packages
    dnf update -y && \
    \
    dnf clean all && \
    rm -rf /tmp/* /var/tmp/* /var/cache

# Extra DNF packages
RUN dnf install --setopt=install_weak_deps=False -y \
    \
    # Convenience & documentation
    bash-completion \
    file \
    man-db \
    man-pages \
    procps-ng \
    sudo \
    which \
    \
    # Runtime dependencies
    augeas \
    bzip2 \
    cpio \
    cyrus-sasl \
    cyrus-sasl-gssapi \
    dmidecode \
    dnsmasq \
    fuse \
    genisoimage \
    gettext \
    glusterfs-cli \
    hexedit \
    iproute-tc \
    iptables-ebtables \
    iscsi-initiator-utils \
    kernel \
    kernel-debug-core \
    kmod \
    libconfig \
    libguestfs-appliance \
    libiscsi \
    libosinfo \
    libpciaccess \
    libssh \
    lvm2 \
    lzop \
    mdevctl \
    netcf \
    nfs-utils \
    nmap-ncat \
    numactl \
    numad \
    parted \
    perl-hivex \
    perl-interpreter \
    perl-libintl-perl \
    polkit \
    python3-argcomplete \
    python3-gobject-base \
    python3-libxml2 \
    python3-requests \
    qemu-img \
    qemu-kvm \
    sanlock \
    swtpm-tools \
    systemd-container \
    xfsprogs \
    yajl \
    && \
    dnf clean all && \
    rm -rf /tmp/* /var/tmp/* /var/cache

# Import updated libosinfo DB
ARG OSINFO_DB=osinfo-db-20220516.tar.xz
COPY ${OSINFO_DB} /root/
RUN osinfo-db-import --system "/root/${OSINFO_DB}" && \
    rm -rf "/root/${OSINFO_DB}"

# Enable login services
RUN systemctl unmask getty.target console-getty.service systemd-logind.service && \
    systemctl enable console-getty.service && \
# Don't run graphical target
    systemctl set-default multi-user.target

# Use the systemd halt.target for docker stop
STOPSIGNAL SIGRTMIN+3

# Enable root autologin and halt on shell exit
COPY autologin.conf /etc/systemd/system/console-getty.service.d/

# Apply some nice bash defaults
COPY mybash.sh /etc/profile.d/

# Launch systemd on startup
CMD [ "/sbin/init" ]

FROM ubuntu:16.10

ENV DEBIAN_FRONTEND noninteractive

WORKDIR  /root/Downloads

# Xorg xorg-x11-drivers mesa-dri-drivers atomic libXxf86vm libXrandr glx-utils
RUN apt-get update && \
    apt-get install -y gnome-shell sudo fish xcalib socat pavucontrol wget lxterminal pulseaudio-utils \
                       firefox gnome-terminal passwd pulseaudio docker docker-compose && \
    true

RUN \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /etc/systemd/system/systemd-remount-fs.service && \
    rm -f /etc/systemd/system/systemd-journald.socket && \
    rm -f /etc/systemd/system/systemd-journald.service && \
    rm -f /etc/systemd/system/systemd-journald-dev-log.socket && \
    rm -f /etc/systemd/system/systemd-journald-audit.socket && \
    rm -f /etc/systemd/system/systemd-journal-flush.service && \
    rm -f /etc/systemd/system/upower.service && \
    rm -f /etc/systemd/system/systemd-logind.service && \
    rm -f /lib/systemd/system/multi-user.target.wants/*  && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/* && \
    ln -s /dev/null /etc/systemd/system/systemd-remount-fs.service && \
    ln -s /dev/null /etc/systemd/system/systemd-journald.socket && \
    ln -s /dev/null /etc/systemd/system/systemd-journald.service && \
    ln -s /dev/null /etc/systemd/system/systemd-journald-dev-log.socket && \
    ln -s /dev/null /etc/systemd/system/systemd-journald-audit.socket && \
    ln -s /dev/null /etc/systemd/system/systemd-journal-flush.service && \
    ln -s /usr/lib/systemd/system/upower.service /etc/systemd/system/upower.service && \
    ln -s /usr/lib/systemd/system/system-logind.service /etc/systemd/system/systemd-login.service && \
    true

RUN mkdir -p /run/udev && \
    mkdir -p /run/dbus && \
    mkdir -p /run/systemd/system && \
    cp /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime && \
    adduser rancher && \
    usermod -aG video rancher && \
    usermod -aG audio rancher && \
    usermod -aG sudo rancher && \
    usermod -aG docker rancher && \
    sed -e 's/^root.*/root\tALL=(ALL)\tALL\nrancher\tALL=(ALL)\tALL/g' /etc/sudoers > /etc/sudoers.new && \
    mv /etc/sudoers.new /etc/sudoers && \
    cat /etc/bashrc | sed 's/\(.*PROMPT_COMMAND=\).*033K.*/\1'"'"'PRINTF "\\033];%S@%S:%S\\033\\\\" "${USER}" "${HOSTNAME%%.*}" "${PWD\/#$HOME\/~}"'"'"'/g' > /etc/tmp && \
    mv /etc/tmp /etc/bashrc && \
    echo  '12345678900987654321234567890987' > /etc/machine-id && \
    true

CMD /bin/bash -c '\
/bin/systemd --system & \
sleep 10; \
chmod a+w /var/run/dbus/system_bus_socket; \
X & \
su - rancher -c "export DISPLAY=\":0\"; gnome-session;" \
'


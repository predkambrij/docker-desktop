FROM ubuntu:16.10

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y xfce4 sudo pulseaudio pavucontrol pulseaudio-utils

ARG ARG_UID
ARG ARG_GID
ARG ARG_DOCKERGID

RUN rm -f /etc/systemd/system/*.wants/* && \
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
    mkdir -p /run/udev && \
    mkdir -p /run/dbus && \
    mkdir -p /run/systemd/system && \
    \
    echo "Europe/Ljubljana" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    /bin/bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf' && \
    true

RUN \
    apt-get install -y passwd dirmngr apt-transport-https && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list && \
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    apt-get update && \
    apt-get install -y docker-engine && \
    export uid=$ARG_UID gid=$ARG_GID dgid=$ARG_DOCKERGID && \
    mkdir -p /home/user && \
    echo "user:x:${uid}:${gid}:User,,,:/home/user:/bin/bash" >> /etc/passwd && \
    echo "user:x:${uid}:" >> /etc/group && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    chown ${uid}:${gid} -R /home/user && \
    /bin/bash -c "echo 'user:user' | chpasswd" && \
# ssh https://docs.docker.com/examples/running_ssh_service/
#   and SSH login fix. Otherwise user is kicked off after login
    apt-get install -y openssh-server && \
    usermod -aG video user && \
    usermod -aG audio user && \
    usermod -aG sudo user && \
    usermod -aG docker user && \
    sed -i "s|docker:x:\([0-9]\+\):|docker:x:${dgid}:|" /etc/group && \
    cat /etc/bashrc | sed 's/\(.*PROMPT_COMMAND=\).*033K.*/\1'"'"'PRINTF "\\033];%S@%S:%S\\033\\\\" "${USER}" "${HOSTNAME%%.*}" "${PWD\/#$HOME\/~}"'"'"'/g' > /etc/tmp && \
    mv /etc/tmp /etc/bashrc && \
    echo  '12345678900987654321234567890987' > /etc/machine-id && \
    true
RUN \
#    apt-get install -y docker-compose && \
    true

VOLUME ["/home/user"]
CMD /bin/bash -c '\
/bin/systemd --system & \
sleep 10; \
chmod a+w /var/run/dbus/system_bus_socket; \
X & \
su - user -c "export DISPLAY=\":0\"; xfce4-session;" \
'


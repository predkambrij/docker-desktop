echo -n "" > .env
echo "ARG_IMAGE=predkambrij/desktop:16dec20" >> .env
echo "ARG_HOSTNAME=desktop.localdomain" >> .env
echo "ARG_UID=$(id -u)" >> .env
echo "ARG_GID=$(id -g)" >> .env
echo "ARG_DOCKERGID=$(sed -n 's|^docker:x:\([0-9]\+\):.*|\1|p' /etc/group)" >> .env


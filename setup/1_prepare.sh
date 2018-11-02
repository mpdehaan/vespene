#!/bin/bash

source ./0_common.sh

echo "PIP=$PIP"

echo "Installing core packages..."
if [ "$DISTRO" == "redhat" ]; then
    # this just covers CentOS for now
    sudo yum -y install centos-release-scl
    # on Red Hat
    # sudo yum-config-manager --enable rhel-server-rhscl-7-rpms ?
    sudo yum -y install epel-release
    sudo yum -y install gcc python36 python36-devel supervisor rh-postgresql10
    sudo python36 -m ensurepip
    sudo tee /etc/profile.d/enable_pg10.sh >/dev/null << END_OF_PG10
    #!/bin/bash
    source scl_source enable rh-postgresql10
END_OF_PG10
    sudo chmod +x /etc/profile.d/enable_pg10.sh 
elif [ "$DISTRO" == "ubuntu" ]; then
    sudo apt-add-repository universe
    sudo apt-get update
    sudo apt-get install -y gcc libssl-dev postgresql-client python3 python3-pip python3-setuptools supervisor
elif [ "$DISTRO" == "archlinux" ]; then
    sudo pacman --noconfirm -Sy python python-pip python-setuptools postgresql supervisor sudo
elif [ "$DISTRO" == "MacOS" ]; then
    brew install python@3 postgresql supervisor
fi

if [ "$DISTRO" != "MacOS" ]; then
    sudo adduser vespene
fi

echo "Setting up directories..."

sudo mkdir -p /opt/vespene
sudo mkdir -p /var/spool/vespene
sudo mkdir -p /etc/vespene/settings.d/
sudo mkdir -p /var/log/vespene/

echo "Cloning the project into /opt/vespene..."
rm -rf /opt/vespene/*
sudo cp -a ../* /opt/vespene

echo "APP_USER=$APP_USER"
sudo chown -R $APP_USER /opt/vespene
sudo chown -R $APP_USER /var/spool/vespene
sudo chown -R $APP_USER /etc/vespene/settings.d/
sudo chown -R $APP_USER /var/log/vespene

echo "Installing python packages..."
CMD="sudo $PYTHON -m pip install -r ../requirements.txt --trusted-host pypi.org --trusted-host files.pypi.org --trusted-host files.pythonhosted.org"
echo $CMD
$CMD

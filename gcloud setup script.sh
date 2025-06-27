# Install github cli

(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Get icons and script for setting display scale
git clone https://github.com/jacobm-tech/google-cloud-setup


# Basic packages

sudo apt-get --assume-yes install autoconf
sudo apt-get --assume-yes install libtool
sudo apt-get --assume-yes install pkg-config
sudo apt-get --assume-yes install libssl-dev
sudo apt-get --assume-yes install libpam0g-dev
sudo apt-get --assume-yes install libx11-dev
sudo apt-get --assume-yes install libxfixes-dev
sudo apt-get --assume-yes install libxrandr-dev
sudo apt-get --assume-yes install libxkbfile-dev
sudo apt-get --assume-yes install make
sudo apt-get --assume-yes install nasm
sudo apt-get --assume-yes install xfce4
sudo apt-get --assume-yes install xserver-xorg-dev

sudo apt-get --assume-yes install locate
sudo updatedb

# Xrdp install.

git clone https://github.com/neutrinolabs/xrdp.git

cd xrdp
./bootstrap
./configure --with-freetype2 --enable-x264 --enable-ipv6
make

# First edit is necessary to start the Xorg server, others set xrdp to
# run as non-privileged user.

sed -i 's/^param=Xorg/param=\/usr\/lib\/xorg\/Xorg/' sesman/sesman.ini
sed -i 's/^#runtime_user=xrdp/runtime_user=xrdp/' xrdp/xrdp.ini
sed -i 's/^#runtime_group=xrdp/runtime_group=xrdp/' xrdp/xrdp.ini
sed -i 's/^#SessionSockdirGroup=xrdp/SessionSockdirGroup=xrdp/' sesman/sesman.ini

sudo make install

# Make a bigger font for the login screen

xrdp-mkfv1 -p36 /usr/share/fonts/truetype/ubuntu/UbuntuMono-B.ttf sans-36.fv1
sudo cp sans-36.fv1 /usr/local/share/xrdp
sudo chmod og+r /usr/local/share/xrdp/sans-36.fv1

# TODO
# need to edit xrdp.ini

cd ..

# xorgrdp contains drivers necessary for xrdp to run.

git clone https://github.com/neutrinolabs/xorgxrdp.git
cd xorgxrdp
./bootstrap
./configure
make
sudo make install

# Change file permissions as needed to run xrdp as non-privileged.
# Use /usr/local/share/xrdp/xrdp-chkpriv to show needed changes

sudo useradd -r -s /bin/false xrdp
sudo adduser xrdp xrdp
sudo usermod --lock xrdp

sudo chmod g+r /etc/xrdp/rsakeys.ini
sudo chgrp xrdp /etc/xrdp/rsakeys.ini

sudo chgrp xrdp /etc/xrdp/cert.pem 
sudo chgrp xrdp /etc/xrdp/key.pem
sudo chmod g+r /etc/xrdp/cert.pem /etc/xrdp/key.pem

sudo systemctl enable xrdp
sudo systemctl start xrdp

# to prevent dropping connections

echo 60 | sudo tee /proc/sys/net/ipv4/tcp_keepalive_time   ;# Set keepalive timer to 1 minute
echo 10 | sudo tee /proc/sys/net/ipv4/tcp_keepalive_intvl   ;# 10 seconds between probes
echo 3 | sudo tee /proc/sys/net/ipv4/tcp_keepalive_probes   ;# 3 probes max

# put in /etc/sysctl.d/10-tcp-keepalive.conf for permanent effect

echo "net.ipv4.tcp_keepalive_time = 60" | sudo tee -a /etc/sysctl.d/10-tcp-keepalive.conf
echo "net.ipv4.tcp_keepalive_intvl = 10" | sudo tee -a /etc/sysctl.d/10-tcp-keepalive.conf 
echo "net.ipv4.tcp_keepalive_probes = 3" | sudo tee -a /etc/sysctl.d/10-tcp-keepalive.conf 

sudo sysctl --system # to reload these rules

# Set up xfce4.
cd ~/google-cloud-setup
sudo cp default.xml /etc/xdg/xfce4/panel/default.xml 
sudo cp scale*.desktop /usr/local/share/applications/
sudo cp scale.sh /usr/local/bin/scale.sh
sudo cp number*.png /usr/share/icons/hicolor/512x512/stock/text/

# Stop annoying color management authentication popup with xrdp


############ Ubuntu 22.04 ONLY ###########################
#sudo echo -e '[Allow Colord all Users]\nIdentity=unix-group:tsusers\nAction=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile\nResultAny=no\nResultInactive=no\nResultActive=yes' | sudo tee -a /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla > /dev/null
##########################################################

############ Ubuntu 24.04 ################################
sudo echo -e 'polkit.addRule(function(action, subject){\n    if(action.id.match(/^org\.freedesktop\.color\-manager\.create\-*/))\n        return polkit.Result.YES;\n    if(action.id.match(/^org\.freedesktop\.color\-manager\.delete\-*/))\n        return polkit.Result.YES;\n    if(action.id.match(/^org\.freedesktop\.color\-manager\.modify\-*/))\n        return polkit.Result.YES;\n});' | sudo tee -a /etc/polkit-1/rules.d/99-allow_colord.rules > /dev/null
##########################################################

# Python install

tar -xvf Python-$ver.tar.xz

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev
sudo apt-get install -y libgdbm-compat-dev

cd /tmp/
wget https://www.python.org/ftp/python/3.13.3/Python-3.13.3.tgz
tar xzf Python-3.13.3.tgz
cd Python-3.13.3

sudo ./configure --enable-optimizations
sudo make -j "$(grep -c ^processor /proc/cpuinfo)"
sudo make altinstall
sudo rm /tmp/Python-3.13.3.tgz

# Python packages

sudo /usr/local/bin/pip3.13 install spyder

# Various libraries needed by Qt - spyder will not run without them.
# export QT_DEBUG_PLUGINS=1 before running spyder will help debug
# missing libraries.

sudo apt-get install -y libxkbcommon-x11-0
sudo apt-get install -y libxcb-cursor0
sudo apt-get install -y libxcb-icccm4-dev
sudo apt-get install -y libxcb-keysyms1
sudo apt-get install -y libxcb-xinerama0

# Additional Python packages

sudo /usr/local/bin/pip3.13 install numpy
sudo /usr/local/bin/pip3.13 install matplotlib
sudo /usr/local/bin/pip3.13 install scipy
sudo /usr/local/bin/pip3.13 install pygame

# Install PyTorch with CUDA (works also on machines with no GPU)

sudo /usr/local/bin/pip3.13 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126


### Set up any users needed in this way

sudo adduser jacob  # set password here
echo xfce4-session | sudo tee ~jacob/.xsession # necessary on Ubuntu 24.04

# group tsusers is checkd by both xrdp and the policy kit rule below
sudo addgroup tsusers
sudo adduser jacob tsusers





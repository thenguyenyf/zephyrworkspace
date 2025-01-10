#!/bin/bash

echo "This script should be ran with sudo privileges"

# Use apt to install the required dependencies
sudo apt update
sudo apt install --no-install-recommends git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler wget \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

# Install python venv
sudo apt install python3-venv

# Create a virtual environment
python3 -m venv ./.venv

# Activate the virtual environment
source ./.venv/bin/activate

# Install west
pip install west

# Get the Zephyr source code
west init .
west update

# Export a Zephyr CMake package
west zephyr-export

west completion bash >> ~/.bashrc
echo 'if [ -n "$(find . -type f -name 'zephyr-env.sh')" ]; then source $(find . -type f -name 'zephyr-env.sh' -print -quit); fi' >> ~/.bashrc
source ~/.bashrc

# Install the required python packages
west packages pip --install

# Install zephyr sdk
cd ./zephyr
west sdk install

# Install the segger jlink tools
wget https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.tgz --post-data="accept_license_agreement=accepted" -O JLink_Linux_x86_64.tgz --no-check-certificate
tar -xvf JLink_Linux_x86_64.tgz
sudo mkdir /opt/SEGGER
sudo mv ./JLink_Linux_*/ /opt/SEGGER/JLink
rm -rf JLink_Linux_*
ln -s /opt/SEGGER/JLink /usr/local/bin/JLink
sudo cp /usr/local/bin/JLink/99-jlink.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules; sudo udevadm trigger

# Install commit hook
pip install gitlint
gitlint install-hook
echo '#!/bin/sh
remote="$1"
url="$2"

z40=0000000000000000000000000000000000000000

echo "Run push hook"

while read local_ref local_sha remote_ref remote_sha
do
    args="$remote $url $local_ref $local_sha $remote_ref $remote_sha"
    exec ${ZEPHYR_BASE}/scripts/series-push-hook.sh $args
done

exit 0' > .git/hooks/pre-push
chmod +x .git/hooks/pre-push

#!/bin/bash
# This script installs the Fortran compilers provided in Intel OneAPI.
# Usage: bash install_oneapi_linux.sh

# do the job in the temporary directory of the system
cd /tmp || exit 42

# use wget to fetch the Intel repository public key
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

# add to your apt sources keyring so that archives signed with this key will be trusted.
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

# optionally, remove the public key
rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

# the installation
echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
sudo add-apt-repository "deb https://apt.repos.intel.com/oneapi all main"
sudo apt update
#sudo apt install intel-basekit intel-hpckit  # Instead of this line, the following line seems to suffice
sudo apt install -y intel-oneapi-common-vars intel-oneapi-compiler-fortran
installer_exit_code=$?

# Run the script that sets the necessary environment variables and then damp them to $GITHUB_ENV
# so that they are available in subsequent steps.
if [[ -f /opt/intel/oneapi/setvars.sh ]] ; then
    source /opt/intel/oneapi/setvars.sh
    env | grep -i 'intel\|oneapi' >> "$GITHUB_ENV"
else
    exit 1
fi

# Show the result of the installation.
echo "The latest ifort installed is:"
ifort --version
echo "The path to ifort is:"
command -v ifort
echo "The latest ifx installed is:"
ifx --version
echo "The path to ifx is:"
command -v ifx

# Exit with the installer exit code.
exit $installer_exit_code

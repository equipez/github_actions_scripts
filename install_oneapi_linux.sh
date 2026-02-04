#!/usr/bin/env bash
# This script installs the Fortran compilers provided in Intel OneAPI.
# Usage: bash install_oneapi_linux.sh

# do the job in the temporary directory of the system
cd /tmp || exit 42

# download the key to system keyring
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

# add signed entry to apt sources and configure the APT client to use Intel repository:
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    | sudo tee /etc/apt/sources.list.d/oneAPI.list

# installation
sudo apt update
#sudo apt install intel-basekit intel-hpckit  # Instead of this line, the following line seems to suffice
sudo apt install -y intel-oneapi-common-vars intel-oneapi-compiler-fortran
installer_exit_code=$?
sudo apt clean  # Remove the .deb

# Run the script that sets the necessary environment variables and then dump them to $GITHUB_ENV
# so that they are available in subsequent steps.
if [[ -f /opt/intel/oneapi/setvars.sh ]] ; then
    source /opt/intel/oneapi/setvars.sh
    env | grep -i 'intel\|oneapi' >> "$GITHUB_ENV"
else
    exit 1
fi

# Show the result of the installation.
echo "The ifx installed is:"
ifx --version
echo "The path to ifx is:"
command -v ifx

# Exit with the installer exit code.
exit $installer_exit_code

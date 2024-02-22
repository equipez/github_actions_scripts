#!/bin/bash
# This script installs the Fortran compilers provided in Intel OneAPI.
# See https://github.com/oneapi-src/oneapi-ci
# https://github.com/oneapi-src/oneapi-ci/blob/master/scripts/install_macos.sh
#
# Usage: bash install_oneapi_macos.sh
#
# Zaikun Zhang (www.zhangzk.net), January 9, 2023

# URL for the offline installer of Intel OneAPI Fortran compiler. To get the latest URL, search for
# "Intel Fortran Compiler Classic for macOS" at
# https://www.intel.com/content/www/us/en/developer/articles/tool/oneapi-standalone-components.html
# and take the URL for the "Offline" installer.
# Default version: 2023.2.0 (updated on 20231015)
URL="https://registrationcenter-download.intel.com/akdlm/IRC_NAS/2fbce033-15f4-4e13-8d14-f5a2016541ce/m_fortran-compiler-classic_p_2023.2.0.49001_offline.dmg"
if [[ $# -ge 1 ]] ; then
    if [[ $1 = "2022" ]] ; then
        URL="https://registrationcenter-download.intel.com/akdlm/irc_nas/18977/m_HPCKit_p_2022.3.1.15344_offline.dmg"
    fi
    if [[ $1 = "2021" ]] ; then
        URL="https://registrationcenter-download.intel.com/akdlm/irc_nas/18242/m_HPCKit_p_2021.4.0.3389_offline.dmg"
    fi
fi

# Component to install.
COMPONENTS=intel.oneapi.mac.ifort-compiler

# Download the installer. curl is included by default in macOS.
cd "$TMPDIR" || exit 42
curl --output webimage.dmg --url "$URL" --retry 5 --retry-delay 5
hdiutil attach webimage.dmg

# Install the compiler.
sudo /Volumes/"$(basename "$URL" .dmg)"/bootstrapper.app/Contents/MacOS/bootstrapper -s --action install --components="$COMPONENTS" --eula=accept --log-dir=.
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
echo "The ifort installed is:"
ifort --version
echo "The path to ifort is:"
command -v ifort

# Remove the installer
rm webimage.dmg
hdiutil detach /Volumes/"$(basename "$URL" .dmg)" -quiet

# Exit with the installer exit code.
exit $installer_exit_code

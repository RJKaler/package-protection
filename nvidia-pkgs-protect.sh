#!/bin/bash -e

#shellcheck disable=all

# NOTE: THIS IS A MACHINE SPECIFIC SCRIPT THAT NEEDS EDITS FOR ANY RELEVANT OS AND SOFTWARE STACK. 
# This will require edits.
#
# OS Environment for testing:
# lsb_release -a | grep -i descript:
# Description:    Ubuntu 24.04.3 LTS
# You can easily alter this for any given package that needs to be safeguarded 

short="$(basename "$0")"
log_file="$HOME/logs/$short.log"
tmp_log="$HOME/tmp/$short.log"

mkdir -p "$HOME/logs" "$HOME/tmp"

# Core Nvidia 580 packages to hold
packages=(
    "nvidia-driver-580-open"
    "nvidia-dkms-580-open"
    "nvidia-kernel-common-580"
    "nvidia-utils-580"
    "libnvidia-gl-580"
    "xserver-xorg-video-nvidia-580"
    "nvidia-compute-utils-580"
    "libnvidia-cfg1-580"
    "libnvidia-extra-580"
)

{
    for pkg in "${packages[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            if sudo apt-mark hold "$pkg" &>/dev/null; then
                echo "The package '$pkg' has been placed on hold."
            else
                echo "Error: failed to place '$pkg' on hold."
            fi
        else
            echo "Package '$pkg' not installed, skipping."
        fi
    done

    date
    echo "==============================="
    echo "Finished marking Nvidia packages as held."
    echo "Currently held packages:"
    apt-mark showhold | grep nvidia;
} | tee -a "$log_file" "$tmp_log"

#!/bin/bash -e 


# ==============================================================================
#  PACKAGE PROTECTION SCRIPT: markmanproc.sh
# ==============================================================================
#  Purpose:
#    Mark all installed packages as "manually installed" to prevent them
#    from being inadvertently removed by package managers (e.g. apt autoremove).
#
#  Why:
#    - Ensures critical system packages remain protected.
#    - Reduces risk of breakage during unattended upgrades or dependency changes.
#    - Useful in workstation / server environments where stability is critical.
#
#  Notes:
#    - This script was built and tested on:
#        Ubuntu 24.04.3 LTS (Noble Numbat)
#    - Safe to re-run multiple times; idempotent design.
#    - Uses parallel jobs (configurable) for speed.
#    - Outputs a log to ~/tmp/markmanual.log
#
#  WARNING:
#    This is a machine-specific utility. Adjust as needed for other OSes
#    or package managers.
#
# ==============================================================================



# Log file path
log_file="/home/richie/tmp/markmanual.log"

# Get the list of installed packages
apt_list_output=$(apt list --installed 2>/dev/null | grep -v 'Listing...' | awk -F '/' '{print $1}')

# Define maximum parallel jobs
max_jobs=4
jobs=()

# Function to mark packages as manually installed
markmanproc() {
    local package="$1"
    local supporting_package
    supporting_package=$(dpkg-query -S "$package" | cut -d':' -f1 | awk -F ': ' '{print $1}')

    if sudo apt-mark manual "$supporting_package" 2>/dev/null; then
        printf "The following package '%s' has been marked as manually installed.\n" "$supporting_package" >> "$log_file"
    else
        printf "Error marking package '%s' as manually installed.\n" "$supporting_package" >> "$log_file"
    fi
}

while IFS= read -r package; do
    echo "Working on $package ..."
    markmanproc "$package" &
    jobs+=($!)  # Store the PID of the background job

    # Limit the number of parallel jobs
    if [[ ${#jobs[@]} -ge $max_jobs ]]; then
        # Wait for any background job to complete
        wait -n
        # Remove finished jobs from the list
        jobs=("${jobs[@]:1}")
    fi
done <<< "$apt_list_output"

# Wait for all remaining background jobs to complete
wait

# Final log entry
{
    date
    printf "===============================\n"
    printf "Finished marking packages - nothing to do.\n"
} | tee -a "$log_file"



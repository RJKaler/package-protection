#!/bin/bash -e

#shellcheck disable=all

#!/bin/bash -e

short="$(basename "$0")"
log_file="$HOME/logs/$short.log"
mkdir -p "$HOME/logs"

# Prompt until a valid package is given
while read -rep 'Please enter the package to protect from removal: ' package
do
    if dpkg -s "$package" &>/dev/null; then
        break
    else
        echo "Package '$package' not found. Please try again."
    fi
done

# Now log everything else
{
    if sudo apt-mark hold "$package" &>/dev/null; then
        echo "The package '$package' has been placed on hold."
    else
        echo "Error: failed to place '$package' on hold."
        exit 1
    fi

    date
    echo "==============================="
    echo "Finished marking package as held."
} | tee -a "$log_file"

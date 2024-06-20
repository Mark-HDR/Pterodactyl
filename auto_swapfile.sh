#!/bin/bash

# Function to detect the total RAM in the system (in GB)
detect_total_ram() {
    free -g | awk '/^Mem:/{print $2}'
}

# Function to create and enable swapfile
create_swapfile() {
    local swap_size=$1

    # Create the swapfile with the determined size
    echo "Creating a swapfile of size $swap_size..."
    if fallocate -l "$swap_size" /swapfile; then
        echo "Swapfile created."
    else
        echo "Failed to create swapfile."
        exit 1
    fi

    # Set the correct permissions for the swapfile
    chmod 600 /swapfile

    # Setup the swap space
    if mkswap /swapfile; then
        echo "Swap space setup completed."
    else
        echo "Failed to setup swap space."
        exit 1
    fi

    # Enable the swap space
    if swapon /swapfile; then
        echo "Swap space enabled."
    else
        echo "Failed to enable swap space."
        exit 1
    fi

    # Add the swapfile entry to /etc/fstab for persistence
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab > /dev/null
    fi

    echo "Swapfile configuration is persistent across reboots."
    swapon --show
}

# Main logic to determine the swapfile size based on RAM size
main() {
    local total_ram
    total_ram=$(detect_total_ram)

    case $total_ram in
        32)
            create_swapfile "16G"
            ;;
        16)
            create_swapfile "32G"
            ;;
        *)
            echo "RAM size is not 16GB or 32GB."
            read -rp "Please enter the size of the swapfile (e.g., 4G, 8G): " custom_swap_size
            create_swapfile "$custom_swap_size"
            ;;
    esac
}

# Execute the main function
main

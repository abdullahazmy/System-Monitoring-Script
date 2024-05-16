#!/bin/bash

# Function to get CPU usage
get_cpu_usage() {
    cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Usage: $cpu%"
}

# Function to get memory usage
get_memory_usage() {
    memory=$(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
    echo "$memory"
}

# Function to get disk usage
get_disk_usage() {
    disk=$(df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}')
    echo "$disk"
}

# Function to get network usage
get_network_usage() {
    network=$(ifstat 1 1 | awk 'NR>2{print "Received: "$6"  Transmitted: "$8}')
    echo "$network"
}

# Main function
main() {
    echo "System Monitoring:"

    while true; do
        get_cpu_usage
        get_memory_usage
        get_disk_usage
        get_network_usage
        echo "--------------------------------"
        sleep 5  # Update every 5 seconds
    done
}

# Run the main function
main

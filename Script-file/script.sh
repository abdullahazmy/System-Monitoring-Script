#!/bin/bash

# Function to get CPU temperature (using sensors or acpi)
get_cpu_temp() {
  # Check for lm-sensors first (preferred method)
  if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
  # If lm-sensors not available, use acpi as a fallback
  elif which acpi >/dev/null 2>&1; then
    cpu_temp=$(acpi -t | awk '{print $NF}')
  else
    echo "WARNING: Could not find a suitable tool to get CPU temperature."
  fi

  # Convert to Celsius or Fahrenheit based on user preference
  if [[ "$1" == "-c" ]]; then
    # Celsius (default)
    echo "CPU Temp: $cpu_temp°C"
  elif [[ "$1" == "-f" ]]; then
    # Fahrenheit
    temp_f=$(echo "scale=2; (9/5) * $cpu_temp + 32" | bc)
    echo "CPU Temp: $temp_f°F"
  else
    # Default to Celsius
    echo "CPU Temp: $cpu_temp°C"
  fi
}

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
  network=$(ifstat 1 1 | awk 'NR>2{print "Received: "$6" Transmitted: "$8}')
  echo "$network"
}

# Main function
main() {
  echo "System Monitoring:"

  while true; do
    get_cpu_temp  # Call get_cpu_temp without arguments (default Celsius)
    get_cpu_usage
    get_memory_usage
    get_disk_usage
    get_network_usage
    echo "--------------------------------"
    sleep 3  # Update every 3 seconds
  done
}

# Run the main function
main

# Allow user to specify temperature unit (optional)
if [[ "$1" == "-c" || "$1" == "-f" ]]; then
  main "$1"
fi

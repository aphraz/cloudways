#!/bin/bash

# Ask the user if they want to specify custom paths or use default paths
read -p "Do you want to specify a custom plugin path? (y/n): " use_custom_paths <&1

# If a custom path is specified, ask for the path, otherwise use the default path
if [ "$use_custom_paths" == "y" ]; then
  read -p "Enter the path to the plugins directory: " plugins_path <&1
else
  # Default paths
  plugins_path="./wp-content/plugins"
fi

# Ask the user if they want to specify a custom slow log path or use the default path
read -p "Do you want to specify a custom slow log path? (y/n): " use_custom_log <&1
 
if [ "$use_custom_log" == "y" ]; then
  read -p "Enter the path to the slow log file: " log_path <&1
else
  # Default slow log path
  log_path="../logs/php-app.slow.log"
fi

# Get a list of all plugins
plugins=$(find "$plugins_path" -maxdepth 1 -type d | sed 's|.*/||')

# Initialize an associative array to store the counts of each plugin
declare -A plugin_counts

# Loop through each plugin and search for entries in the slow logs
for plugin in $plugins; do
  # Search the slow logs for entries related to the current plugin and extract the plugin name
  log_entries=$(grep -o "plugins/$plugin/." "$log_path" | sed 's/plugins\/.\///')

  # If there are log entries, print them and update the count for the plugin
  if [ -n "$log_entries" ]; then
    echo "Entries for plugin $plugin:"
    echo "$log_entries"
    echo ""
    for entry in $log_entries; do
      (( plugin_counts[$plugin]++ ))
    done
  fi
done

# Print the top N plugins with the highest counts
echo "Top plugins by count:"
for plugin in "${!plugin_counts[@]}"; do
  echo "${plugin_counts[$plugin]} $plugin"
done | sort -rn | head -n 10

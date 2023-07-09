#!/bin/bash

# Download warp-reg binary
curl -sLo /tmp/warp-reg "https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64"
chmod +x /tmp/warp-reg

# Run warp-reg and capture the output
output=$(/tmp/warp-reg)

# Parse the output to extract key-value pairs
declare -A values
while IFS=':' read -r key value; do
  values["$key"]="${value# }"
done <<< "$output"

# Print the extracted values
for key in "${!values[@]}"; do
  echo "$key=${values[$key]}"
done

# Replace values in config.json
config_file="config.json"
config_new_file="config_new.json"
cp "$config_file" "$config_new_file"

for key in "${!values[@]}"; do
  sed -i "s#_REPLACE_WITH_${key}_#${values[$key]}#g" "$config_new_file"
done

# Clean up temporary files
rm /tmp/warp-reg

echo "Configuration completed."

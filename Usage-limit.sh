#!/bin/bash

# OPIranCluB
# Delay message
echo -n "$(tput setaf 3)"

# Iterate through each letter and display with delay
for letter in "O" "P" "I" "r" "a" "n" "C" "l" "u" "B" " " "S" "e" "t" "t" "i" "n" "g" " " "u" "p" " " "t" "r" "a" "f" "f" "i" "c" " " "c" "o" "n" "t" "r" "o" "l"; do
  sleep 0.1
  echo -n "$letter"
done

echo "$(tput sgr0)"

# Function to calculate data usage in gigabytes
calculate_data_usage() {
  local bytes="$1"
  local gb=$(echo "scale=2; $bytes / (1024 * 1024 * 1024)" | bc)
  echo "$gb"
}

# Function to check if user data usage is already set
is_user_data_limit_set() {
  local username="$1"
  local uid=$(id -u "$username")
  if iptables -t mangle -L OUTPUT -n | grep -q "$uid"; then
    return 0
  else
    return 1
  fi
}

# Function to check user data usage
check_user_data_usage() {
  local username="$1"
  local uid=$(id -u "$username")
  local data_usage=$(iptables -nvx -L OUTPUT -t mangle | awk -v user="$uid" '$11 == user { sum += $2 } END { print sum }')

  if [ -z "$data_usage" ]; then
    echo -e "\e[33mNo data usage found for user $username\e[0m"
    data_usage=0
  fi

  local usage_gb=$(calculate_data_usage "$data_usage")
  echo -e "\e[32mUser $username data usage: $usage_gb GB\e[0m"
}

# Function to set the user data usage limit
set_user_data_limit() {
  local username="$1"
  local limit="$2"

  # Set up iptables rules for traffic accounting
  local uid=$(id -u "$username")
  iptables -t mangle -A OUTPUT -m owner --uid-owner "$uid" -j MARK --set-mark 1
  iptables -t mangle -A OUTPUT -m owner --uid-owner "$uid" -j RETURN
  iptables -t mangle -A PREROUTING -i tun0 -m mark --mark 1 -j RETURN
  iptables -t mangle -A PREROUTING -i eth0 -m mark --mark 1 -j DROP

  # Set up iproute2 rules for traffic accounting
  ip rule add fwmark 1 lookup 100
  ip route add local default dev lo table 100

  echo -e "\e[32mData limit of $limit GB set for user $username\e[0m"
}

# Main script

while true; do
  # Prompt for option
  echo -e $'Select an option:'
  echo -e $'\t\e[33m(A)\e[0m Check the status (Type \e[33mA\e[0m)'
  echo -e $'\t\e[33m(B)\e[0m Set the data limit (Type \e[33mB\e[0m)'
  read -p $'\e[33mEnter your choice: \e[0m' option

  case "$option" in
    [Aa])
      read -p $'\e[33mEnter the username: \e[0m' username
      if is_user_data_limit_set "$username"; then
        check_user_data_usage "$username"
      else
        echo -e "\e[33mNo data limit is set for user $username\e[0m"
      fi
      break
      ;;
    [Bb])
      read -p $'\e[33mEnter the username: \e[0m' username
      if is_user_data_limit_set "$username"; then
        echo -e "\e[33mData limit is already set for user $username\e[0m"
      else
        read -p $'\e[33mEnter the monthly data limit in gigabytes: \e[0m' limit
        set_user_data_limit "$username" "$limit"
      fi
      break
      ;;
    *)
      echo -e "\e[33mInvalid option selected\e[0m"
      ;;
  esac
done

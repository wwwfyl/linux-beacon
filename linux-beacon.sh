#!/bin/bash

source /etc/linux-beacon/altbeacon.config

if [ "$AD_Data_ID1" = "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00" ]; then
# Generate a random identifier
    ri=$(openssl rand -hex 16)
    AD_Data_ID1="${ri:0:2} ${ri:2:2} ${ri:4:2} ${ri:6:2} ${ri:8:2} ${ri:10:2} ${ri:12:2} ${ri:14:2} ${ri:16:2} ${ri:18:2} ${ri:20:2} ${ri:22:2} ${ri:24:2} ${ri:26:2} ${ri:28:2} ${ri:30:2}"
    sed -i "s/AD_Data_ID1=.*/AD_Data_ID1=\"$AD_Data_ID1\"/" /etc/linux-beacon/altbeacon.config
fi

# Set up advertising data flags
AD_Flags=`echo "$AD_Length_Flags $AD_Type_Flags $AD_Data_Flags"`

# Set up AltBeacon advertisement
AltBeacon_Advertisement=`echo "$AD_Length_Data $AD_Type_Manufacturer_Specific_Data $AD_Data_Company_Identifier $AD_Data_Proximity_Type"`
AltBeacon_Advertisement=`echo "$AltBeacon_Advertisement $AD_Data_ID1 $AD_Data_ID2 $AD_Data_ID3 $AD_Data_Reference_RSSI $AD_Data_Manufacturer_Reserved"`

echo "Transmitting AltBeacon profile with the following identifiers:"
echo "ID1: $AD_Data_ID1"
echo "ID2: $AD_Data_ID2"
echo "ID3: $AD_Data_ID3"
echo "MFG RESERVED: $AD_Data_Manufacturer_Reserved"
echo ""
echo "AltBeacon Advertisement: $AltBeacon_Advertisement"
echo ""


if which hciconfig >/dev/null; then
  echo "hciconfig is installed"

  # Set Bluetooth device ID
  BLUETOOTH_DEVICE=$(hciconfig -a | grep -e "Type: Primary" | awk '{print $1}')

  # Command Bluetooth device up
  sudo hciconfig $BLUETOOTH_DEVICE up

  # Stop LE advertising
  sudo hciconfig $BLUETOOTH_DEVICE noleadv

  # HCI_LE_Set_Advertising_Data command
  # Command parameters: Advertising_Data_Length (1f), Advertising_Data
  sudo hcitool -i $BLUETOOTH_DEVICE cmd 0x08 0x0008 1f $AD_Flags $AltBeacon_Advertisement

  # Start LE advertising (non-connectable)
  sudo hciconfig $BLUETOOTH_DEVICE leadv 3

else
  echo "hciconfig is not installed, pls install it"
fi

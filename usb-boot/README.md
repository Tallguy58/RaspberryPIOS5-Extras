# Running Raspberry Pi OS on USB Devices : Made Easy
A recurring topic of discussion is how to configure and reliably run Raspberry Pi OS on a USB flash drive, USB hard drive, or USB SSD instead of an SD card.<br>
A Raspberry Pi 4 or Raspberry Pi 5 has a native USB boot mode that is reliable and should be used.<br>
A Raspberry Pi 3B+ has a native USB boot mode (this mode has to be manually enabled by setting an OTP bit on a Raspberry Pi 3B).  This native USB boot mode has serious compatibility issues.<br>
A bootcode.bin file is available for older Raspberry Pi models.  Unfortunately, these have serious limitations and once working, can easily become broken.<br>
The easiest and most reliable way to run Raspberry Pi OS on a USB device with any Raspberry Pi prior to the model 4 or 5 is to leave an SD card containing Raspberry Pi OS in place, but use it only for starting the Raspberry Pi OS that is residing on a USB device.<br>
If usb-boot is running on a Raspberry Pi 4 or Raspberry Pi 5, usb-boot first prompts: 'Use SD card to boot the USB device?'<br>
If 'No' is selected, the SD card will not be altered and the direct USB boot capability of the Raspberry Pi 4 or Raspberry Pi 5 will be used.<br>
If usb-boot is running on a Raspberry Pi 3B+ or a Raspberry Pi 3B with its OTP bit set, usb-boot first prompts: 'Use SD card to boot the USB device (recommended)?'<br>
If 'No' is selected, the SD card will not be altered, but booting the USB device may be limited and/or unreliable as described above.<br>
usb-boot then presents a list of available USB mass storage devices and prompts: 'Select the USB mass storage device to boot'<br>
Use the arrow keys on your keyboard to navigate to the desired device and press the spacebar to select it.  Then use the tab key to navigate to the 'Ok' or 'Cancel' button and press the return key.<br>
usb-boot will then prompt: 'Replicate BOOT/ROOT contents from /dev/mmcblk0 to /dev/sdX?'<br>
/dev/mmcblk0 is the SD card and /dev/sdX is the USB device.<br>
Select 'No' if the USB device already has Raspberry Pi OS on it and you wish to use it (nothing will be copied).<br>
Select 'Yes' if you want to copy the Raspberry Pi OS on your SD card to the USB device (everything will be copied).<br>
If you select 'Yes', usb-boot will then prompt: 'Select the partition table type to use (MBR = 2TB Maximum)'<br>
usb-boot will then prompt: 'All existing data on USB device /dev/sdX will be destroyed!' and ask: 'Do you wish to continue?'<br>
If you select 'Yes', the copy will begin.  The time required for this process will depend on the amount of data on your SD card and the speed of your storage devices.<br>
usb-boot will then complete the configuration process and warn you of any potential conflicts it detects.<br>
When usb-boot has finished, you should be able to reboot and be running Raspberry Pi OS on the USB device (first power off and remove the SD card if not using the SD card to boot the USB device).<br>
# sdc-boot provides a convenient way to select which attached device will be booted.
Usage syntax is:<br>
`sdc-boot [ /dev/sdX2 | /dev/nvmeXn1p2 | /dev/mmcblk0p2 | hhhhhhhh-02 | hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh ]`<br>
/dev/sdX2 is a USB device<br>
/dev/nvmeXn1p2 is an NVME device<br>
/dev/mmcblk0p2 is the SD card<br>
hhhhhhhh-02 | hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh is a device identified by its PARTUUID<br>
If no device is specified, the currently selected boot device will be displayed.<br>
# GPT partition tables are necessary for devices whose size is over 2TB.
mbr2gpt converts an MBR partition table on a USB device to a GPT partition table, as well as optionally expanding the ROOT partition and enabling booting via an SD card.<br>
mbr2gpt converts any size USB device, including SD cards placed in a USB adapter.<br>
!!! DO NOT PROCEED UNLESS YOU HAVE A RELIABLE BACKUP OF THE DEVICE BEING CONVERTED !!!<br>
Usage syntax is:<br>
`mbr2gpt /dev/sdX or mbr2gpt /dev/nvmeXn1`<br>
mbr2gpt will prompt for permission to perform the following optional functions:<br>
1. Convert the USB device to use GPT partition tables<br>
2. Expand the ROOT partition to use all available space<br>
3. Set the SD card to boot the USB device
# set-partuuid displays or changes the ROOT partition PARTUUID on a device.
Usage syntax is:<br>
`set-partuuid device [ hhhhhhhh-02 | hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh | random ]`<br>
device may be /dev/sdX2 or /dev/nvmeXn1p2 or /dev/mmcblk0p2<br>
If no partuuid is specified, the current ROOT partition PARTUUID will be displayed.<br>

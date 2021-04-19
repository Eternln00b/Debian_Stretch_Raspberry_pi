# Debian Stretch ( 32 bit or 64 bit ) for any Raspberry pi hardware. 

usage : 

Raspberry Pi 4 in 64bits: Debian_Stretch_Raspberry.sh -4 64bits
Raspberry Pi 4 in 32bits: Debian_Stretch_Raspberry.sh -4 32bits
=================================================================
Raspberry Pi 3 in 64bits: Debian_Stretch_Raspberry.sh -3 64bits
Raspberry Pi 3 in 32bits: Debian_Stretch_Raspberry.sh -3 32bits
=================================================================
Raspberry Pi 2 in 32bits: Debian_Stretch_Raspberry.sh -2
=================================================================
Raspberry Pi 0,1 in 32bits: Debian_Stretch_Raspberry.sh -1
=================================================================

kernel configuration : Debian_Stretch_Raspberry.sh -4 64bits -c

The usage is simple. if you want Debian for the Raspberry pi 4 in 64 bit, write the command line : " Debian_Stretch_Raspberry.sh -4 64bits ".                                     If you want Debian for the Raspberry pi 2, write this command : " Debian_Stretch_Raspberry.sh -2 " Et cetera.

If you need to configure the kernel, write the command with the switch "-c" at the end : " Debian_Stretch_Raspberry.sh -3 32bits -c "


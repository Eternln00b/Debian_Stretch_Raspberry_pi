usage : 

Raspberry Pi 4 :

in 64bits: Debian_Stretch_Raspberry.sh -4 64bits

in 32bits: Debian_Stretch_Raspberry.sh -4 32bits

=================================================================

Raspberry Pi 3 :

in 64bits: Debian_Stretch_Raspberry.sh -3 64bits

in 32bits: Debian_Stretch_Raspberry.sh -3 32bits

=================================================================

Raspberry Pi 2 in : Debian_Stretch_Raspberry.sh -2

=================================================================

Raspberry Pi 0 and 1 : Debian_Stretch_Raspberry.sh -1

=================================================================

kernel configuration : Debian_Stretch_Raspberry.sh -4 64bits -c

=================================================================

The main purpose of my project, is to build a lightw Debian image ( less than 900MB ) for Raspberry Pi hardwares. Normally, the builded image with my script is ready to use for a server using. But, if you have a very specific project , you have maybe to custom the scripts.

Anyway, the usage is simple. if you want Debian for the Raspberry pi 4 in 64 bit, write the command line : " Debian_Stretch_Raspberry.sh -4 64bits ".                                     If you want Debian for the Raspberry pi 2, write this command : " Debian_Stretch_Raspberry.sh -2 " Et cetera.

If you need to configure the kernel, write the command with the switch "-c" at the end : " Debian_Stretch_Raspberry.sh -3 32bits -c "

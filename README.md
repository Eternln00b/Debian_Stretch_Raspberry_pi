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

[31/10/2021]

The main purpose of my project, is to build a lightweight Debian image ( less than 950MB ) for Raspberry Pi hardwares. 

By default, the builded image with my scripts is for server use. The username is "pi", the password is "raspberry", the timezone is "Etc/Universal" and the hostname is "a404dded". 
The logs are managed by busybox-syslogd. The ssh server is managed by Dropbear. The closed sources firmwares is a squashed folder in the boot partition and mounted in the folder "/lib/firmware". 

For the task scheduling, you have to use the service manager systemD. Cron is disabled.

So, if you want to change theses defaults setups or if you have a very specific project, you have to custom the scripts.

Anyway, the usage is simple. if you want Debian for the Raspberry pi 4 in 64 bit, write the command line : " Debian_Stretch_Raspberry.sh -4 64bits ".                                     If you want Debian for the Raspberry pi 2, write this command : " Debian_Stretch_Raspberry.sh -2 " Et cetera.

If you need to configure the kernel, write the command with the switch "-c" at the end : " Debian_Stretch_Raspberry.sh -3 32bits -c "

I will maybe update the project for the raspberry pi zero 2 w

=================================================================

![alt text](https://zupimages.net/up/21/48/f5wm.png)

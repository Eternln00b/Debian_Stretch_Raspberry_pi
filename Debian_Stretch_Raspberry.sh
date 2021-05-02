#!/bin/bash

############################################
## Author : https://github.com/Eternln00b ##
##########################################################################################
## based on this script https://gist.github.com/stewdk/f4f36c3f6599072583bd40f15b5cdbef ##
##########################################################################################

WRKDIR=/home/$(id -nu 1000)/Debian_Rpi_Build_a404dded/
OUTPUT_IMG_DIR=$(pwd)
NPROC=$(nproc)
MNTRAMDISK=/mnt/ramdisk/
MNTROOTFS=/mnt/rpi-rootfs/
MNTBOOT=${MNTROOTFS}boot/

finish () {
  
	cd ${WRKDIR}
	sync
	umount -l ${MNTROOTFS}proc || true
	umount -l ${MNTROOTFS}dev/pts || true
	umount -l ${MNTROOTFS}dev || true
	umount -l ${MNTROOTFS}sys || true
	umount -l ${MNTROOTFS}tmp || true
	umount -l ${MNTBOOT} || true
	umount -l ${MNTROOTFS} || true
	kpartx -dvs ${IMGFILE} || true
	rmdir ${MNTROOTFS} || true
	mv ${IMGFILE} . || true
	umount -l ${MNTRAMDISK} || true
	rmdir ${MNTRAMDISK} || true
	output_img_to_move=$(ls -1 ${WRKDIR}*.img)
	chown $(id -nu 1000):$(id -nu 1000) ${output_img_to_move} &> /dev/null
	[[ ! -d ${OUTPUT_IMG_DIR}/images ]] && mkdir -p ${OUTPUT_IMG_DIR}/images && chown $(id -nu 1000):$(id -nu 1000) ${OUTPUT_IMG_DIR}/images
	mv ${output_img_to_move} ${OUTPUT_IMG_DIR}/images

}

packages() {

	local softwares=("g++-arm-linux-gnueabi" "gcc-aarch64-linux-gnu" "g++-aarch64-linux-gnu" "gcc-arm-linux-gnueabihf" "g++-arm-linux-gnueabihf" "gcc-arm-linux-gnueabi" "pkg-config-aarch64-linux-gnu" "pkg-config-arm-linux-gnueabihf"  
	"pkg-config-arm-linux-gnueabi" "bison" "flex" "debootstrap" "qemu-utils" "kpartx" "qemu-user-static" "binfmt-support" "parted" "bc" "libncurses5-dev" "libssl-dev" "device-tree-compiler" "squashfs-tools" "wpasupplicant"
	"git" "wget")

	for checking_softwares in "${softwares[@]}"
	do

		if [[ $(dpkg-query --show --showformat='${db:Status-Status}\n' ''$checking_softwares'') == "not-installed" ]];then 
	 
    			echo "The package $checking_softwares is being installed ..."
			apt install -y $checking_softwares -qq &> /dev/null

		fi

	done

}

Which_Raspberry_pi() {

	local LIGNE1="===================================================="
	local MESSAGE1=""
	MESSAGE1="\nwhich Raspberry Pi please with which kernel please ?\n\n${LIGNE1}\n
	Raspberry Pi 4 in 64bits: Debian_RPI.sh -4 64bits\nRaspberry Pi 4 in 32bits: Debian_RPI.sh -4 32bits\n\n${LIGNE1}\n
	Raspberry Pi 3 in 64bits: Debian_RPI.sh -3 64bits\nRaspberry Pi 3 in 32bits: Debian_RPI.sh -3 32bits\n\n${LIGNE1}\n
	Raspberry Pi 2 in 32bits: Debian_RPI.sh -2\n\n${LIGNE1}\n\nRaspberry Pi 0,1 in 32bits: Debian_RPI.sh -1\n\n${LIGNE1}
	\nkernel configuration : Debian_RPI.sh -4 64bits -c\n\n"
	
	local MESSAGE2="\nWhich kernel please ? 64bits or 32bits ?\n\n"
	local MESSAGE3="\nThe first argument do not require an argument\n\n"
	
	[[ $1 == "MESSAGE1" ]] && local MESSAGE=$MESSAGE1
	[[ $1 == "MESSAGE2" ]] && local MESSAGE=$MESSAGE2
	[[ $1 == "MESSAGE3" ]] && local MESSAGE=$MESSAGE3
	
	echo -en "$MESSAGE" | tr -d "\t"

}

Options_processing() {

	while getopts ":4:3:21c" options ; do
	case $options in


		4)

			if [[ $OPTARG == "64bits" || $OPTARG == "32bits" ]];then

				[[  $OPTARG == "64bits" ]] && KERNEL="kernel8" 
				[[  $OPTARG == "32bits" ]] && KERNEL="kernel7l" 
				OS=${OPTARG}
				pi="4"

			fi		
			;;

		3)

			if [[ $OPTARG == "64bits" || $OPTARG == "32bits" ]];then

				[[  $OPTARG == "64bits" ]] && KERNEL="kernel8" 
				[[  $OPTARG == "32bits" ]] && KERNEL="kernel7" 
				OS=${OPTARG}
				pi="3"

			fi	
			;;

		2)

			KERNEL="kernel7"
			pi="2"
			;;

		1)

			KERNEL="kernel"	
			pi="1"
			;;	

		c)

			KERNEL_CONFIGURE=true
			;;
		
		:)

			Which_Raspberry_pi "MESSAGE2"
			exit 1
			;;


		\?)

			Which_Raspberry_pi "MESSAGE1" 
			exit 1
			;;

		*)

			Which_Raspberry_pi "MESSAGE1" 
			exit 1
			;;

	esac
	done

	[[ -f /tmp/config.kernel.tmp ]] && rm -rf /tmp/config.kernel.tmp
	if [[ ${pi} == "4" || ${pi} == "3" ]];then

		echo "${pi}:${OS}:${KERNEL}" >> /tmp/config.kernel.tmp

	else

		echo "${pi}:${KERNEL}" >> /tmp/config.kernel.tmp

	fi
	
}

set_compiler() {

	if [[ $1 == "kernel8" ]];then

		DARCH="arm64"
		KARCH="arm64"
		QARCH="aarch64"
		CROSS_COMPILER=aarch64-linux-gnu-
		KERNEL_IMG="Image"
		[[ $pi == "3" ]] && RPI_DEFCONFIG="bcmrpi3_defconfig"
		[[ $pi == "4" ]] && RPI_DEFCONFIG="bcm2711_defconfig"
		echo -en "\nCompiling Debian for the Raspberry Pi ${pi} in 64 bits\n\n"

	else

		DARCH="armhf"
		KARCH="arm"
		QARCH="arm"
		CROSS_COMPILER=arm-linux-gnueabihf-
		KERNEL_IMG="zImage"
		[[ $1 == "kernel" ]] && RPI_DEFCONFIG="bcmrpi_defconfig"
		[[ $1 == "kernel7" ]] && RPI_DEFCONFIG="bcm2709_defconfig"
		[[ $1 == "kernel7l" ]] && RPI_DEFCONFIG="bcm2711_defconfig"
		echo -en "\nCompiling Debian for the Raspberry Pi ${pi} in 32 bits\n\n"

	fi

	if [[ $pi == "1" ]]; then

		IMGNAME=Debian_Stretch_${QARCH}_rpi0_1		

	else

		IMGNAME=Debian_Stretch_${QARCH}_rpi${pi}

	fi 

	IMGFILE=${MNTRAMDISK}${IMGNAME}.img

}

download_the_sources() {

	local projects=("https://github.com/RPi-Distro/firmware-nonfree.git" "https://github.com/raspberrypi/linux.git" "https://github.com/raspberrypi/firmware.git")
	local folders=("${WRKDIR}closed_firmware" "${WRKDIR}kernel_linux_${QARCH}" "${WRKDIR}raspberry_firmware")
	local positions=("-150" "+100" "80")

	echo -en "Checking if the sources are here ! \n\n"
	for ((d=0;d<${#projects[@]};d++))
	do

		if [[ ! -d ${folders[$d]} ]];then

			if [[ "${KERNEL}" == "kernel8" && "${projects[$d]}" == "https://github.com/raspberrypi/linux.git" ]]; then
					
				 xterm -geometry ${positions[$d]} -e 'git clone --branch rpi-4.19.y --single-branch '${projects[$d]}' '${folders[$d]}' && chown -R $(id -nu 1000):$(id -nu 1000) '${folders[$d]}'' &

			else

				 xterm -geometry ${positions[$d]} -e 'git clone --single-branch '${projects[$d]}' '${folders[$d]}' && chown -R $(id -nu 1000):$(id -nu 1000) '${folders[$d]}'' &
					
			fi
				
			local pid_git=$!
			[[ -z $( ps -p $pid_git -o pid= ) ]] && echo "can't download the sources for somes reasons ..." && exit 1

		else

			[[ -d ${folders[$d]} && "${folders[$d]}" == "${WRKDIR}closed_firmware" ]] && echo "The closed firmwares are in the folder ${WRKDIR}closed_firmware !" 
			if [[ -d ${folders[$d]} && "${folders[$d]}" == "${WRKDIR}kernel_linux_${QARCH}" ]]; then

				echo "The kernel sources are in the folder ${WRKDIR}kernel_linux_${QARCH} !" 
				[[ ! -f ${WRKDIR}kernel_linux_${QARCH}/config.kernel ]] && cp /tmp/config.kernel.tmp ${WRKDIR}kernel_linux_${QARCH}/config.kernel 
			
			fi 
			[[ -d ${folders[$d]} && "${folders[$d]}" == "${WRKDIR}raspberry_firmware" ]] && echo "The raspberry pi firmwares sources are in the folder ${WRKDIR}raspberry_firmware !"
			
		fi
		
	done
	wait
	echo
	
}

kernel_compile() {

	if [[ $(diff -s /tmp/config.kernel.tmp ${WRKDIR}kernel_linux_${QARCH}/config.kernel > /dev/null ; echo $?) -eq 1 || ${KERNEL_CONFIGURE} ]];then

		cd ${WRKDIR}kernel_linux_${QARCH}
		make -j ${NPROC} mrproper &> /dev/null
		rm -rf ${WRKDIR}kernel_linux_${QARCH}/config.kernel
		cp /tmp/config.kernel.tmp ${WRKDIR}kernel_linux_${QARCH}/config.kernel
			
	fi
	
	cd ${WRKDIR}kernel_linux_${QARCH}
	make ARCH=${KARCH} CROSS_COMPILE=${CROSS_COMPILER} ${RPI_DEFCONFIG} -j ${NPROC} &> /dev/null
	[[ ${KERNEL_CONFIGURE} ]] && xterm -geometry 210x200+100-10 -e 'make ARCH='${KARCH}' CROSS_COMPILE='${CROSS_COMPILER}' -j '${NPROC}' menuconfig '

	echo -en "Building kernel. This takes a while ... \n\n"
	cd ${WRKDIR}kernel_linux_${QARCH}
	xterm -geometry 80 -e 'make ARCH='${KARCH}' CROSS_COMPILE='${CROSS_COMPILER}' '${KERNEL_IMG}' modules dtbs -j '${NPROC}''
	
}

Debian_build() {

	echo -en "Building Debian image ! \n\n"

	mkdir -p ${MNTRAMDISK} ${MNTROOTFS}
	mount -t tmpfs -o size=3g tmpfs ${MNTRAMDISK}

	qemu-img create -f raw ${IMGFILE} 850M > /dev/null 
	(echo "n"; echo "p"; echo "1"; echo "2048"; echo "+230M"; echo "n"; echo "p"; echo "2"; echo ""; echo ""; echo "t"; echo "1"; echo "c"; echo "w") | fdisk ${IMGFILE} > /dev/null
	LOOPDEVS=$(kpartx -avs ${IMGFILE} | awk '{print $3}')
	LOOPDEVBOOT=/dev/mapper/$(echo ${LOOPDEVS} | awk '{print $1}')
	LOOPDEVROOTFS=/dev/mapper/$(echo ${LOOPDEVS} | awk '{print $2}')

	mkfs.vfat ${LOOPDEVBOOT} 
	mkfs.ext4 ${LOOPDEVROOTFS} 

	fatlabel ${LOOPDEVBOOT} Boot
	e2label ${LOOPDEVROOTFS} Debian
	echo

	mount ${LOOPDEVROOTFS} ${MNTROOTFS}
	xterm -geometry 215-100+5 -e 'qemu-debootstrap --keyring /usr/share/keyrings/debian-archive-stretch-stable.gpg --include=ca-certificates --arch='${DARCH}' stretch '${MNTROOTFS}' http://cdn-fastly.deb.debian.org/debian/'
	mount ${LOOPDEVBOOT} ${MNTBOOT}
	
	mksquashfs ${WRKDIR}closed_firmware ${MNTBOOT}firmware.squashfs -b 1048576 -comp xz -Xdict-size 100%
	echo -en "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 cgroup_enable=memory elevator=deadline rootwait\n" >> ${MNTBOOT}cmdline.txt
	echo -en "kernel=${KERNEL}.img\nenable_uart=1\n" >> ${MNTBOOT}config.txt

	mount -o bind /proc ${MNTROOTFS}proc
	mount -o bind /dev ${MNTROOTFS}dev
	mount -o bind /dev/pts ${MNTROOTFS}dev/pts
	mount -o bind /sys ${MNTROOTFS}sys
	mount -o bind /tmp ${MNTROOTFS}tmp

	cp $( which qemu-${QARCH}-static ) ${MNTROOTFS}usr/bin/
	cp ${WRKDIR}raspberry_firmware/boot/bootcode.bin ${WRKDIR}raspberry_firmware/boot/fixup*.dat ${WRKDIR}raspberry_firmware/boot/start*.elf ${MNTBOOT}
	cp ${OUTPUT_IMG_DIR}/package_debian_based.sh /tmp
	chmod +x /tmp/package_debian_based.sh
	xterm -geometry 210x200+100-10 -e 'chroot '${MNTROOTFS}' /tmp/package_debian_based.sh'
	# xterm -geometry 210x200+100-10 -e 'chroot '${MNTROOTFS}' /bin/bash'

}

if [[ $(id -u) -ne 0 || $( wget -q -o /dev/null --spider https://www.google.com; echo $? ) -ne 0 || $( id -nu 1000 > /dev/null; echo $?) -ne 0 ]]; then

	echo "[!] This script must run as root or you are not connected to internet or you do not have an user with the id 1000"
	exit 1

fi

if [[ $(lsb_release -i | grep -o "Ubuntu") != "Ubuntu" ]];then

	echo "[!] This script was made only for Ubuntu"
	exit 1

else

	if [[ -z $( which dpkg-query ) || -z $( which apt ) ]];then
	
		echo "[!] dpkg-query or apt are there ?"
		exit 1

	fi

fi

if [[ "$#" -eq 0 ]];then
	
	Which_Raspberry_pi "MESSAGE1"
	exit 1 

elif [[  $3 == "-c" ]];then

	[[ $1 == "-1" || $1 == "-2" ]] && { 
		
		Which_Raspberry_pi "MESSAGE3"
		exit 1 

	}
	
fi

Options_processing "$@"

if [[ -n $KERNEL ]];then

	packages
	set_compiler "$KERNEL"
	trap finish EXIT
	[[ -f ${OUTPUT_IMG_DIR}/images ]] && rm -rf ${OUTPUT_IMG_DIR}/images
	download_the_sources

	if [[ ! -f ${WRKDIR}kernel_linux_${QARCH}/arch/${KARCH}/boot/${KERNEL_IMG} || ${KERNEL_CONFIGURE} || $(diff -s /tmp/config.kernel.tmp ${WRKDIR}kernel_linux_${QARCH}/config.kernel > /dev/null ; echo $?) -eq 1 ]];then

		build_image_routines=( kernel_compile Debian_build )
		for build_image in "${build_image_routines[@]}" 
		do 
		
			$build_image & 
		
		done 
		wait

	else
		
		Debian_build

	fi

	echo -en "\nInstalling the kernel ...\n\n"
	cp ${WRKDIR}kernel_linux_${QARCH}/arch/${KARCH}/boot/${KERNEL_IMG} ${MNTBOOT}${KERNEL}.img
    	[[ ${KARCH} == "arm" ]] && cp ${WRKDIR}kernel_linux_${QARCH}/arch/${KARCH}/boot/dts/*.dtb ${MNTBOOT}
	[[ ${KARCH} == "arm64" ]] && cp ${WRKDIR}kernel_linux_${QARCH}/arch/${KARCH}/boot/dts/broadcom/*.dtb ${MNTBOOT}
    	cd ${WRKDIR}kernel_linux_${QARCH}
    	make ARCH=${KARCH} CROSS_COMPILE=${CROSS_COMPILER} INSTALL_MOD_PATH=${MNTROOTFS} modules_install -j ${NPROC} &> /dev/null

else

	Which_Raspberry_pi "MESSAGE2"
	exit 1

fi

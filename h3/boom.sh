#!/bin/bash

# set -x

usage()
{
	echo "$0 arch | build | dump"
	echo "    dump: 	Copy backup imgs to H3 & Dump disk img to local file"
	echo "    arch: 	Backup H3 part[1,2,3] to rootfs.img.gz opt.img.gz vars.img.gz"
	echo "   build: 	Setup failsafe files to H3 disk"
	echo "	"
	echo "	Any questions: fengmushu@gmail.com"
	exit 1
}


archive_part()
{
	local PART=$1
	local FNAME=`echo $PART | cut -c 6-`
	local WKDIR=/tmp/archive_part

	case $PART in
		*sd[a-z]1)
			FNAME="rootfs"
		;;
		*sd[a-z]2)
			FNAME="opt"
		;;
		*sd[a-z]3)
			FNAME="vars"
		;;
		*)
			return 0
		;;
	esac

	mkdir -p $WKDIR || exit 1
	echo "archive $PART to $FNAME.gz"

	sudo mount $PART $WKDIR || {
		echo "mount $PART failed"
		return 1
	}
	cd $WKDIR && {
		# strip the DELETED zone
		sudo dd if=/dev/zero of=zero bs=1M conv=fsync 2>/dev/null; sudo rm zero
		sync
		cd -
	}
	sudo umount $WKDIR || {
		echo "umount $PART from $WKDIR failed"
		exit 1
	}
	# DO archive
	sudo sh -c "cat $PART | gzip -9 > $FNAME.img.gz"
}

check_disk()
{
	local DEVICE=$1

	sudo hexdump -C $DEVICE -s 0x2000 -n 0x40 2>/dev/null | grep "eGON.BT0" && {
		echo "found H3 image disk $DEVICE"
		return 0
	}
	return 1
}

do_archive()
{
	local DEVICE=$1

	for part in `ls ${DEVICE}[0-9]`;
	do
		echo "archive $part ..."
		archive_part $part
	done
}

do_dump()
{
	local DEVICE=$1
	local PART="${DEVICE}4"
	local WKDIR="/tmp/dump_$$"
	local DUMP_TO="qpt-full.img.gz"

	echo "backup use $PART ..."
	sudo mkfs.vfat $PART || {
		echo "error format vfat backup part"
		exit -1
	}

	mkdir -p $WKDIR || exit -1
	echo "mount $PART to $WKDIR ..."
	sudo mount $PART $WKDIR || {
		echo "error mount vfat backup part"
		exit -2
	}

	echo "copy files img ..."
	sudo cp *.img.gz $WKDIR/ || {
		echo "error cp imgs to backup part"
		sudo umount $WKDIR
		exit -2
	}

	echo "unmount $WKDIR ..."
	sudo umount $WKDIR || {
		echo "error umount $WKDIR"
		exit -2
	}

	echo "dump full disk to $DUMP_TO ..."
	sudo sh -c "cat $DEVICE | gzip -9 > $DUMP_TO" || {
		echo "dump full disk image failed"
		exit -3
	}

	echo "finished create backup images & dump full disk"
}

dd_image()
{
	[ $# -ge 3 ] || return 1

	[ -f $1 ] || {
		echo "$1 file not found!"
		exit 1
	}

	sudo dd if=$1 of=$2 bs=1024 seek=$3 conv=fsync >/dev/null 2>&1 || exit 1
}

do_build()
{
	local DISK=$1
	# 
	# 0x42000000 $BOARD/kernel.bin 		//2048 : 0x100000
	# 0x43000000 $BOARD/dtb.bin 		//1024 : 0x080000
	# 0x43300000 $BOARD/initfs.bin		//16384: 0x800000
	# 0x43100000 $BOARD/boot-scr.bin	//1152 : 0x090000
	#

	[ -b $DISK ] || {
		echo "not valid disk $DISK~!"
		exit 1
	}

	echo "write kernel ..."
	dd_image kernel.bin $DISK 2048 

	echo "write hw discription ..."
	dd_image dtb.bin $DISK 1024
	
	echo "write boot scripts ..."
	dd_image boot-scr.bin $DISK 1152
	
	echo "write ramfs ..."
	dd_image initfs.bin $DISK 16384

	return 0
}

main()
{
	local DEVICE

	for device in `ls /dev/sd[a-z]`;
	do
		echo "test $device ..."
		check_disk $device && {
			DEVICE=$device
		}
	done

	[ -n "$DEVICE" ] || {
		echo "H3 device not found"
		exit 0
	}

	case $1 in
		arch)
			do_archive $DEVICE
		;;
		build)
			do_build $DEVICE
		;;
		dump)
			do_dump $DEVICE
		;;
		*)
			usage
	;;
	esac
}

main $@

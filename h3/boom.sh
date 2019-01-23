#!/bin/bash

#set -x 

usage()
{
	echo "$0"
	exit 1
}


archive_part()
{
	local PART=$1
	local FNAME=`echo $PART | cut -c 6-`
	local WKDIR=/tmp/archive_part

	mkdir -p $WKDIR || exit 1

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
	sudo sh -c "cat $PART | gzip -9 > $FNAME.gz"
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

main()
{
	for device in `ls /dev/sd[a-z]`;
	do
		echo "test $device ..."
		check_disk $device && {
			for part in `ls ${device}[0-9]`;
			do
				echo "archive $part ..."
				archive_part $part
			done
		}
	done
}

main

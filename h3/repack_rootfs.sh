#!/bin/sh

ROOT=`pwd`

uIMG=$2
zIMG=${uIMG}.gz

#set -x

usage()
{
	echo $0 un/re uInitd
	exit -1
}

unpack()
{
	dumpimage -i ${uIMG} ${zIMG} || {
		echo "error dumpimage ${uIMG}"
		exit 1
	}
	[ -d ${ROOT}/rootfs ] && {
		echo "fakeroot dir existed, please rm it first"
		exit 1
	}
	mkdir -p ${ROOT}/rootfs || {
		echo "error make fakeroot"
		exit 1
	}
	cd ${ROOT}/rootfs && {
		gunzip ../${zIMG} -c | cpio -idmv && ls . -lht
	}
}

repack()
{
	cd ${ROOT}/rootfs && {
		find . -print0 2>/dev/null | cpio --null --create --format=newc | gzip -9 > ../${uIMG}.new || {
			echo "error repack cpio"
			exit 2
		}
	}
	cd ${ROOT} && {
		mkimage -A arm -T ramdisk -C gzip -d ${uIMG}.new ${uIMG}
	}
}

[ $# -ge 2 ] || usage

case $1 in
	un)
	unpack
;;
	re)
	repack
;;
	*)
	usage
;;
esac


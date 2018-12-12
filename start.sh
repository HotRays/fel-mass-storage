#!/bin/bash

BOARD=$1
[ -n $BOARD ] || BOARD=h3

echo "Connect '$BOARD' device in FEL mode and press <Enter>"
read

case $BOARD in
    h3)
	sunxi-fel -p uboot $BOARD/u-boot-sunxi-with-spl.bin \
		write 0x42000000 $BOARD/zImage \
		write 0x43000000 $BOARD/script.bin \
		write 0x43300000 $BOARD/uInitrd \
		write 0x43100000 $BOARD/boot.scr
	read
    ;;
    h6)
	### write 0x4fe00000 initramfs.uimg ###
	sunxi-fel -v -p spl $BOARD/sunxi-spl.bin \
		write 0x104000 $BOARD/bl31.bin \
		write 0x4a000000 $BOARD/u-boot.bin \
		write 0x40080000 $BOARD/linux-failsafe \
		write 0x4fa00000 $BOARD/dtb-failsafe \
		write 0x4fc00000 $BOARD/boot.scr \
		reset64 0x104000
	read
    ;;
    *)
	echo "unsupported platform $BOARD"
    ;;
esac


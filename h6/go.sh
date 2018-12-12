#!/bin/bash

#write 0x4fe00000 initramfs.uimg \

sunxi-fel -v -p spl sunxi-spl.bin \
	write 0x104000 bl31.bin \
	write 0x4a000000 u-boot.bin \
	write 0x40080000 linux-failsafe \
	write 0x4fa00000 dtb-failsafe \
	write 0x4fc00000 boot.scr \
	reset64 0x104000

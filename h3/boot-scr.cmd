setenv machid 1029
setenv bootm_boot_mode sec
bootz ${kernel_addr_r} ${ramdisk_addr_r}

# mkimage -C none -A arm -T script -d boot-scr.cmd boot-scr.bin

setenv bootargs "earlyprintk=ttyS0,115200 console=ttyS0,115200 panic=10 loglevel=7 initcall_debug=0"
setenv machid 1029
setenv bootm_boot_mode sec
bootz ${kernel_addr_r} ${ramdisk_addr_r}

# mkimage -C none -A arm -T script -d boot.cmd boot.scr

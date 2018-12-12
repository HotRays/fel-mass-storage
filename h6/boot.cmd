setenv bootargs "earlyprintk console=ttyS0,115200 root=/dev/ram0 init=/init rootwait"
booti ${kernel_addr_r} - ${fdt_addr_r}

#mkimage -C none -A arm -T script -d boot.cmd boot.scr

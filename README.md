# 修改部分说明

## H3-QPT平台, 变砖修复支持

### 镜像编辑/制作工具:
- h3/boom.sh : 用于生产镜像制作
- h3/repack_rootfs.sh : cpio.uboot 格式镜像的打包/解压工具
- start.sh [board:h3/h6] : fel-mass-storage 方式启动终端

### 快速修复:
- dd写入32MB的变砖修复数据到mmcblk0 (如果系统能起动,可直接写入,如果不能,使用fel-mass-storage方式写入)
- 终端重启,灯闪时按reset键,等待终端启动完成
- 用双头usb-type-a的线将设备otg接口连接到linux主机,用vfat格式化第四分区,并将三个分区备份文件写入该分区
- 终端重启,并按第2步,进入reset操作,自动完成变砖修复

# Preparations
![image](https://github.com/fengmushu/fel-mass-storage/blob/master/firehouse.png?raw=true)

## Linux and OS X

- compile and install [sunxi-tools](https://github.com/linux-sunxi/sunxi-tools)

- (optional) add udev rule to allow access to USB devices to users belonging to (previously created) "sunxi-fel" group:

```
SUBSYSTEMS=="usb", ATTR{idVendor}=="1f3a", ATTR{idProduct}=="efe8", GROUP="sunxi-fel"
```

## Windows

- download [Zadig](http://zadig.akeo.ie/)

- connect board in FEL mode to your PC

- launch "Zadig"

- check "Options\List all devices"

- select device with VID=`1F3A` and PID=`EFE8` (i.e. `USB Device(VID_1f3a_PID_efe8)`)

- install "WinUSB" driver (tested on Win8.1 x86)


# Notes

If eMMC is not detected, SD card will be exported instead

Some boards (like [Orange Pi PC Plus](https://linux-sunxi.org/Orange_Pi_PC#Orange_Pi_PC_Plus)) which don't have FEL button require using special SD image to [enter FEL mode](https://linux-sunxi.org/FEL#Entering_FEL_mode):

Use `dd`, `Rufus` or `Etcher` to flash fel-sdboot.img to SD card like any OS image and use this card to boot the board in FEL mode.

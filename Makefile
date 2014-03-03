all: testroot pindestino.img

testroot:
	@if [ "$$(whoami)" != "root" ]; then echo "Must be root. Run with sudo."; exit 1; fi

raspbian.zip:
	wget http://downloads.raspberrypi.org/raspbian_latest -O raspbian.zip

raspbian.img: raspbian.zip
	unzip raspbian.zip
	mv ????-??-??-wheezy-raspbian.img raspbian.img
	touch raspbian.img

pindestino.img: raspbian.img
	cp raspbian.img pindestino.img
	mkdir -p work
	mount -o loop,offset=62914560 -t ext4 pindestino.img work
	echo "" >work/etc/ld.so.preload
	echo 'KERNEL=="sda", SYMLINK+="mmcblk0"' >work/etc/udev/rules.d/90-qemu.rules
	echo 'KERNEL=="sda?", SYMLINK+="mmcblk0p%n"' >>work/etc/udev/rules.d/90-qemu.rules
	echo 'KERNEL=="sda2", SYMLINK+="root"' >>work/etc/udev/rules.d/90-qemu.rules
	sync
	umount work
	rmdir work

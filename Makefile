run: kernel.img rootfs.img
	qemu-system-x86_64 -kernel kernel.img -append "root=/dev/ram rdinit=/sbin/init" -initrd rootfs.img -net nic,model=e1000 -net user

debug: kernel.img rootfs.img
	qemu-system-x86_64 -kernel kernel.img -append "root=/dev/ram rdinit=/sbin/init kgdboc=ttyS0,115200 kgdbwait" -initrd rootfs.img -net nic,model=e1000 -net user -serial tcp::1234,server &
	TMPFILE=$$(mktemp) && echo "target remote localhost:1234" > $$TMPFILE && gdb -x $$TMPFILE linux/vmlinux

install linux/.config busybox/.config:
	./install

kernel.img: linux/.config
	make -C linux bzImage -j4
	cp linux/arch/x86/boot/bzImage $@

rootfs.img: busybox/.config
	make -C busybox install -j4
	./mkrootfs $@

.PHONY: run debug install

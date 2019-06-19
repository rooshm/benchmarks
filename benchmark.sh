#!/usr/bin/env bash

modprobe null_blk irqmode=2
lsblk
cd /home/roosh/benchmarks/fio
rm -rf reshost*
for i in {1..3}
do
    fio -o ../res_host$i -threads-per-queue=1 r1.fio r64.fio w1.fio w64.fio
done
cd ../../qemu
for i in threads native io_uring
do
    x86_64-softmmu/qemu-system-x86_64 -M accel=kvm -m 1G -cdrom my-seed.iso \
    -drive file=my-disk.qcow2,format=qcow2,cache=none,if=virtio,aio=native \
    -drive file=/dev/nullb0,format=raw,cache=none,if=virtio,aio=$i \
    -nographic -nic none 
done
systemctl restart sshd
x86_64-softmmu/qemu-system-x86_64 -M accel=kvm -m 1G -cdrom my-seed.iso \
-drive file=my-disk.qcow2,format=qcow2,cache=none,if=virtio,aio=native \
-nographic -nic user,model=virtio-net-pci
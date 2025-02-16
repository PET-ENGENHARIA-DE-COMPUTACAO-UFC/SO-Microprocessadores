nasm -f bin -o mybootloader.bin mybootloader.asm 
nasm -f bin -o kernel.bin microkernel.asm 

dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc
dd if=mybootloader.bin of=disk.img bs=512 count=1 conv=notrunc

qemu-system-x86_64 -drive format=raw,file=disk.img

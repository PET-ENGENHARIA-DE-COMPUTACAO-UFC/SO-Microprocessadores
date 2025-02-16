nasm -f bin -o bootloader.bin bootloader.asm 
nasm -f bin -o kernel.bin kernel.asm 
nasm -f bin -o composer.bin composer.asm 
nasm -f bin -o texteditor.bin text_editor.asm 

dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc
dd if=composer.bin of=disk.img bs=512 seek=4 conv=notrunc
dd if=texteditor.bin of=disk.img bs=512 seek=6 conv=notrunc
dd if=bootloader.bin of=disk.img bs=512 count=1 conv=notrunc

qemu-system-x86_64 -drive format=raw,file=disk.img

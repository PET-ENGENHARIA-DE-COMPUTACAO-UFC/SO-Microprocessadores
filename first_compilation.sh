set -x  # Habilitar modo de debug para mostrar comandos e saídas

clear

# Compilação dos arquivos de bootloader e kernel
nasm -f bin -o bootloader.bin bootloader.asm
nasm -f bin -o kernel.bin kernel.asm

dd if=/dev/zero of=disk.img bs=1M count=5

# Particionar a imagem do disco
parted disk.img --script -- mklabel msdos
parted disk.img --script -- mkpart primary 1MiB 4MiB
parted disk.img --script -- set 1 boot on

dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc
dd if=mybootloader.bin of=disk.img bs=512 count=1 conv=notrunc

parted disk.img set 1 boot on

# Executar no QEMU especificando o formato raw
qemu-system-x86_64 -drive format=raw,file=disk.img

org 0x7c00
bits 16
start: jmp boot

; Mensagens
msg_welcome db "Welcome to AGOs-V!", 0ah, 0dh, 0h
msg_error db "An error occurred loading the kernel", 0ah, 0dh, 0h
msg_sector_error db "An error occurred reading the sectors", 0ah, 0dh, 0h
msg_debug db "Kernel loaded!", 0ah, 0dh, 0h
msg_debug_read db "Reading sectors...", 0ah, 0dh, 0h

bootdrive db 0

boot:
    cli
    cld

    ; Exibir mensagem de boas-vindas
    mov si, msg_welcome
    call print_string

    ; Configuração inicial dos registradores de segmentos
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov sp, 0x7a00

    mov byte [bootdrive], 0x80 ; Define o drive de boot

    mov si, msg_debug_read     ; Mensagem de depuração
    call print_string

    call read_sectors          ; Lê os setores do kernel

    mov si, msg_debug          ; Mensagem de depuração
    call print_string

    ; Salto para o kernel
    jmp 0x0000:0x1000 

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0Eh
    int 10h
    jmp print_string
done:
    ret

read_sectors:
    pusha 
    mov cx, 3                  ; Número de setores a ler
    mov ch, 0				   ; Define leitura na track 0
    mov cl, 2                  ; Seta setor inicial 2
    mov dh, 0                  ; Seta cabeçote 0
    xor ax, ax
    mov bx, 0x1000             ; Seta offset como 0x1000 e define o segmento de memória
    mov es, ax                 ; como sendo 0 

.read_sectors_loop:
    mov ah, 0x02               ; Função de leitura de setor
    mov al, 1                  ; Lê 1 setor por vez
    mov dl, [bootdrive]
    int 0x13                   ; Chama BIOS para ler o setor
    jc sector_error            ; Se falhar, mostra erro
	
    add bx, 512                ; Pula para o próximo setor na memória
    loop .read_sectors_loop
    popa 
    ret

sector_error:
    mov si, msg_sector_error
    call print_string
    call halt

error: 
    mov si, msg_error
    call print_string
    call halt

halt:
    cli
    hlt
    jmp halt

; Assinatura de boot
times 510 - ($-$$) db 0
dw 0xAA55

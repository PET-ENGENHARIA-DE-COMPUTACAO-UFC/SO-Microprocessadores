[BITS 16]
[ORG 0x1000]  ; Endereço de carregamento

start:
	;reinicia buffer
	mov byte [buffer_index], 0
	mov di, buffer
	mov cx, 16
	xor al, al
	rep stosb
	
    ; Definir modo de vídeo 80x25
    mov ax, 0x0003
    int 0x10

    mov ax, 0x0600       ; Scroll up
    mov bh, 0x8F         ; Fundo cinza e texto branco 
    mov cx, 0x0000       ; Linha 0, coluna 0
    mov dx, 0x184F       ; Linha 24, coluna 79
    int 0x10

    ; Escrever título na tela
    mov ax, 0x1301
    mov bh, 0
    mov bl, 0x8F
    mov dh, 11           ; Linha 2 (dentro da janela)
    mov dl, 30           ; Coluna centralizada
    mov cx, title_len1
    mov bp, title
    int 0x10
    
    ; Escrever aperte qualquer botão na tela
    mov ax, 0x1301
    mov bh, 0
    mov bl, 0x8F
    mov dh, 20           ; Linha 20
    mov dl, 22           ; Coluna centralizada
    mov cx, title_len2
    mov bp, press_any_buttom 
    int 0x10

	mov ah, 0x00
	int 0x16
	jmp main_kernel

main_kernel:
    mov ax, 0x0600       ; Scroll up
    mov bh, 0x0F         ; Fundo preto e texto branco 
    mov cx, 0x0000       ; Linha 0, coluna 0
    mov dx, 0x184F       ; Linha 24, coluna 79
    int 0x10
    
    ; move cursor para canto superior esquerdo da tela
    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10
    
.loop:
    mov ah, 0x00
	int 0x16

	; se apertar esc volta pra tela inicial
    cmp al, 0x1B
    je start
    
    ;se apertar backspace deleta última letra
    cmp al, 0x08
    je .backspace
    
    ; se apertar enter pula linha ou executa código
    cmp al, 0x0D
    je .enter

    mov si, buffer
    add si, [buffer_index]
    mov [si], al
    inc byte [buffer_index]
    
    ;motrar caractere digitado
    mov ah, 0x0A
    mov bh, 0
    mov cx, 1
    int 0x10
    
    ;mudar posição do cursor
    inc dl
    mov ah, 0x02
    mov bh, 0
    mov dh, dh
    int 0x10
    
    jmp .loop
.backspace:
	cmp dl, 0
	je .loop

    dec dl
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
	mov ah, 0x0A
    mov bh, 0
    mov al, ' '
    mov cx, 1
    int 0x10
      
    ; deleta último caractere do buffer
    dec byte [buffer_index]
    mov si, buffer
    add si, [buffer_index]
    mov byte [si], 0
    
    jmp .loop

	
.enter:
	inc dh
    mov dl, 0
	mov ah, 0x02
    mov bh, 0
    int 0x10
    
    ;se buffer estiver vazio volta para o loop
    cmp byte [buffer_index], 0
    je .loop
    
    jmp .verify_word

.verify_word:
	mov si, buffer
	mov di, end_system
	mov cx, end_system_len

.end_system:
	lodsb
	scasb
	jne .id_archive1
	loop .end_system
	jmp power_off
	
.id_archive1:
	mov si, buffer
	mov di, archive1_name
	mov cx, archive1_name_len
.compare_archive1:	
	lodsb
	scasb
	jne .id_archive2
	loop .compare_archive1
	jmp execute_archive1

.id_archive2:
	mov si, buffer
	mov di, archive2_name
	mov cx, archive2_name_len
.compare_archive2:	
	lodsb
	scasb
	jne .invalid_entry
	loop .compare_archive2
	jmp execute_archive2
	
.invalid_entry:
    mov ax, 0x1301
    mov bh, 0
    mov bl, 0x0F
    mov cx, msg_invalid_entry_len
    mov bp, msg_invalid_entry
    int 0x10

	inc dh
    mov dl, 0
	mov ah, 0x02
    mov bh, 0
    int 0x10
    
	jmp .restart_buffer
	
.restart_buffer:
	mov byte [buffer_index], 0
	mov di, buffer
	mov cx, 16
	xor al, al
	rep stosb
	jmp .loop
	
power_off:
    mov ax, 0x1301
    mov bh, 0
    mov bl, 0x0F
    mov cx, msg_ending_system_len
    mov bp, msg_ending_system
    int 0x10
    hlt
	
execute_archive1:
    mov ax, 0x0000
    mov es, ax          
    mov bx, 0x3000      
    mov ah, 0x02        
    mov al, 2           
    mov ch, 0           
    mov cl, 4
    mov dh, 0           
    mov dl, 0x80        
    int 0x13
    
    jmp 0x0000:0x3000
    
execute_archive2:
    mov ax, 0x0000
    mov es, ax          
    mov bx, 0x4000      
    mov ah, 0x02        
    mov al, 2           
    mov ch, 0           
    mov cl, 6
    mov dh, 0           
    mov dl, 0x80        
    int 0x13
    
    jmp 0x0000:0x4000
    
title db "Bem Vindo ao AGOs-V", 0
archive1_name db "compor", 0
archive1_name_len equ 6

msg_invalid_entry db "Comando invalido", 0
msg_invalid_entry_len equ 16

end_system db "desligar", 0
end_system_len equ 8

msg_ending_system db "encerrado", 0
msg_ending_system_len equ 9

press_any_buttom db "Aperte qualquer botao para continuar", 0
title_len1 equ 19
title_len2 equ 36

archive2_name db "editor de texto", 0
archive2_name_len equ 15

buffer times 16 db 0
buffer_index db 0

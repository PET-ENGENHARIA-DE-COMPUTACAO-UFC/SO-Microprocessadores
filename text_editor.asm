[BITS 16]
[ORG 0x4000]

start:	
    ; Inicializar a pilha 
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7A00      ; Endereço seguro para a pilha

	mov ax, 0x0003
    int 0x10
    
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
    
    jmp main_editor
  
main_editor:	
  	mov ah, 0x00
	int 0x16
    
    ;se apertar esc sai do editor e volta pro kernel
    cmp al, 0x1B
    je .exit
    
    ;se apertar backspace deleta última letra
    cmp al, 0x08
    je .backspace
    
    ; se apertar enter pula linha ou executa código
    cmp al, 0x0D
    je .enter

    ;motrar caractere digitado
    mov ah, 0x0A
    mov bh, 0
    mov cx, 1
    int 0x10
    
    ;mudar posição do cursor
    inc dl
    mov ah, 0x02
    int 0x10
    
    jmp main_editor
    
.backspace:
	cmp dl, 0
	je .backspace_treatment

    dec dl
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
	mov ah, 0x0A
    mov bh, 0
    mov al, ' '
    mov cx, 1
    int 0x10
    
    jmp main_editor
    
.backspace_treatment:
	cmp dh, 0
	je main_editor
	
	pop dx
	dec dh
	jmp main_editor
	
.enter:
	inc dh
	push dx
    mov dl, 0
	mov ah, 0x02
    mov bh, 0
    int 0x10
    
    jmp main_editor
    
.exit:
	mov ax, 0x0000
    mov es, ax          
    mov bx, 0x1000      
    mov ah, 0x02        
    mov al, 2           
    mov ch, 0           
    mov cl, 2
    mov dh, 0           
    mov dl, 0x80        
    int 0x13
    
    jmp 0x0000:0x1000

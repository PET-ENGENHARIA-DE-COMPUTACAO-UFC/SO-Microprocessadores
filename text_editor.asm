[BITS 16]
[ORG 0x4000]

start:	
    ; Inicializar a pilha 
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7A00      ; Endereço seguro para a pilha

    ; Define modo de vídeo
    mov ax, 0x0003
    int 0x10

    ; Configura a tela para deixa-la bonitinha
    mov ax, 0x0600       ; Limpa tela
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
    ; Lê um caractere digitado
    mov ah, 0x00
    int 0x16
    
    ;se apertar esc sai do editor e volta pro kernel
    cmp al, 0x1B
    je .exit
    
    ;se apertar backspace deleta última letra
    cmp al, 0x08
    je .backspace
    
    ; se apertar enter pula linha
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
    ; Se estiver na primeira coluna, verifica em qual linha está e escolhe entre voltar a linha ou não fazer nada
    cmp dl, 0
    je .backspace_treatment

    ; Posiciona o cursor uma coluna para trás
    dec dl
    mov ah, 0x02
    mov bh, 0
    int 0x10

    ; Escreve um espaço no lugar onde tinha uma letra, para "limpar" essa casa
    mov ah, 0x0A
    mov bh, 0
    mov al, ' '
    mov cx, 1
    int 0x10
    
    jmp main_editor
    
.backspace_treatment:
        ; Se estiver na primeira linha, não faz nada
	cmp dh, 0
	je main_editor

        ; Se estiver em outra linha, restaura coluna em que foi apertado enter anteriormente e volta para ela
	pop dx
	dec dh
	jmp main_editor
	
.enter:
    ; Pula para a linha de baixo na primeira coluna 
    inc dh
    push dx
    mov dl, 0
    mov ah, 0x02
    mov bh, 0
    int 0x10
    
    jmp main_editor
    
.exit:
    ; Volta para o kernel
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

[BITS 16]
[ORG 0x3000]

section .data
    prompt db "Compositor de Musica (Pressione ESC para sair):", 0x0D, 0x0A, 0
    buffer times 256 db 0      ; Buffer para armazenar a melodia
    buffer_index dw 0          ; Índice atual no buffer

    ; Frequências das notas (em Hz)
    note_frequencies dw 262, 277, 294, 311, 330, 349, 370, 392, 415, 440, 466, 494
    ; Teclas correspondentes: a, w, s, e, d, f, t, g, y, h, u, j

section .text
_start:
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

    ; Exibir o prompt
    mov si, prompt             ; SI aponta para o prompt
    call print_string          ; Exibe o prompt

    ; Inicializar o buffer e o índice
    mov word [buffer_index], 0 ; Zera o índice do buffer

    ; Loop principal do compositor
.composer_loop:
    ; Capturar entrada do teclado
    mov ah, 0x00               ; Função 0x00 da BIOS: ler caractere do teclado
    int 0x16                   ; Chama a BIOS para ler o caractere

    ; Verificar se o usuário pressionou ESC
    cmp al, 0x1B               ; 0x1B é o código ASCII para ESC
    je .exit_composer          ; Se pressionou ESC, sair do compositor

    ; Verificar se o usuário pressionou Enter
    cmp al, 0x0D               ; 0x0D é o código ASCII para Enter
    je .play_melody            ; Se pressionou Enter, tocar a melodia

    ; Verificar se o usuário pressionou espaço
    cmp al, 0x20               ; 0x20 é o código ASCII para espaço
    je .add_space              ; Se pressionou espaço, adicionar intervalo

    ; Mapear teclas para notas
    call map_key_to_note       ; Mapeia a tecla para uma nota
    jc .composer_loop          ; Se a tecla não for válida, ignorar

    ; Armazenar a nota no buffer
    mov bx, [buffer_index]     ; BX = índice atual no buffer
    cmp bx, 255                ; Verificar se o buffer está cheio
    jge .composer_loop         ; Se estiver cheio, ignorar a entrada

    mov [buffer + bx], al      ; Armazena a nota no buffer
    inc word [buffer_index]    ; Incrementa o índice do buffer

    ; Exibir o caractere na tela
    mov ah, 0x0E               ; Função 0x0E da BIOS: exibir caractere
    mov bh, 0x00               ; Página de vídeo 0
    mov bl, 0x07               ; Cor do texto (branco)
    int 0x10                   ; Exibe o caractere

    jmp .composer_loop         ; Volta ao início do loop

.add_space:
    ; Adicionar intervalo (espaço) ao buffer
    mov bx, [buffer_index]     ; BX = índice atual no buffer
    cmp bx, 255                ; Verificar se o buffer está cheio
    jge .composer_loop         ; Se estiver cheio, ignorar a entrada

    mov byte [buffer + bx], ' ' ; Armazena um espaço no buffer
    inc word [buffer_index]    ; Incrementa o índice do buffer

    ; Exibir o espaço na tela
    mov ah, 0x0E               ; Função 0x0E da BIOS: exibir caractere
    mov al, ' '                ; Caractere de espaço
    int 0x10                   ; Exibe o espaço

    jmp .composer_loop         ; Volta ao início do loop

.play_melody:
    ; Tocar a melodia
    mov si, buffer             ; SI aponta para o buffer
.play_loop:
    lodsb                      ; Carrega o próximo caractere de SI em AL
    or al, al                  ; Verifica se AL é 0 (fim do buffer)
    jz .exit_composer          ; Se for 0, terminar

    cmp al, ' '                ; Verifica se é um espaço (intervalo)
    je .play_silence           ; Se for espaço, tocar silêncio

    ; Mapear o caractere para uma frequência
    call map_note_to_frequency ; Mapeia a nota para uma frequência
    jc .play_loop              ; Se a nota não for válida, ignorar

    ; Tocar a nota
    call play_sound            ; Toca a nota
    jmp .play_loop             ; Repete para o próximo caractere

.play_silence:
    ; Tocar silêncio (intervalo)
    call delay                 ; Espera um pouco
    jmp .play_loop             ; Repete para o próximo caractere

.exit_composer:

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

print_string:
    ; Função para exibir uma string terminada em 0
    mov ah, 0x0E               ; Função 0x0E da BIOS: exibir caractere
    mov bh, 0x00               ; Página de vídeo 0
    mov bl, 0x07               ; Cor do texto (branco)

.print_char:
    lodsb                      ; Carrega o próximo caractere de SI em AL
    or al, al                  ; Verifica se AL é 0 (fim da string)
    jz .done                   ; Se for 0, termina
    int 0x10                   ; Chama a BIOS para exibir o caractere
    jmp .print_char            ; Repete para o próximo caractere

.done:
    ret                        ; Retorna da função

map_key_to_note:
    ; Mapeia a tecla para uma nota
    ; Entrada: AL = tecla pressionada
    ; Saída: AL = nota correspondente (ou CF = 1 se a tecla não for válida)
    cmp al, 'a'                ; DO
    je .do
    cmp al, 'w'                ; DO#
    je .do_sharp
    cmp al, 's'                ; RE
    je .re
    cmp al, 'e'                ; RE#
    je .re_sharp
    cmp al, 'd'                ; MI
    je .mi
    cmp al, 'f'                ; FA
    je .fa
    cmp al, 't'                ; FA#
    je .fa_sharp
    cmp al, 'g'                ; SOL
    je .sol
    cmp al, 'y'                ; SOL#
    je .sol_sharp
    cmp al, 'h'                ; LA
    je .la
    cmp al, 'u'                ; LA#
    je .la_sharp
    cmp al, 'j'                ; SI
    je .si
    stc                        ; Tecla inválida: define CF = 1
    ret

.do:
    mov al, 'C'                ; DO
    clc                        ; Tecla válida: limpa CF
    ret
.do_sharp:
    mov al, 'C'                ; DO#
    clc
    ret
.re:
    mov al, 'D'                ; RE
    clc
    ret
.re_sharp:
    mov al, 'D'                ; RE#
    clc
    ret
.mi:
    mov al, 'E'                ; MI
    clc
    ret
.fa:
    mov al, 'F'                ; FA
    clc
    ret
.fa_sharp:
    mov al, 'F'                ; FA#
    clc
    ret
.sol:
    mov al, 'G'                ; SOL
    clc
    ret
.sol_sharp:
    mov al, 'G'                ; SOL#
    clc
    ret
.la:
    mov al, 'A'                ; LA
    clc
    ret
.la_sharp:
    mov al, 'A'                ; LA#
    clc
    ret
.si:
    mov al, 'B'                ; SI
    clc
    ret

map_note_to_frequency:
    ; Mapeia a nota para uma frequência
    ; Entrada: AL = nota
    ; Saída: AX = frequência (ou CF = 1 se a nota não for válida)
    cmp al, 'C'                ; DO
    je .do
    cmp al, 'D'                ; RE
    je .re
    cmp al, 'E'                ; MI
    je .mi
    cmp al, 'F'                ; FA
    je .fa
    cmp al, 'G'                ; SOL
    je .sol
    cmp al, 'A'                ; LA
    je .la
    cmp al, 'B'                ; SI
    je .si
    stc                        ; Nota inválida: define CF = 1
    ret

.do:
    mov ax, [note_frequencies + 0] ; DO (262 Hz)
    clc
    ret
.re:
    mov ax, [note_frequencies + 2] ; RE (294 Hz)
    clc
    ret
.mi:
    mov ax, [note_frequencies + 4] ; MI (330 Hz)
    clc
    ret
.fa:
    mov ax, [note_frequencies + 6] ; FA (349 Hz)
    clc
    ret
.sol:
    mov ax, [note_frequencies + 8] ; SOL (392 Hz)
    clc
    ret
.la:
    mov ax, [note_frequencies + 10] ; LA (440 Hz)
    clc
    ret
.si:
    mov ax, [note_frequencies + 12] ; SI (494 Hz)
    clc
    ret

play_sound:
    ; Toca uma nota
    ; Entrada: AX = frequência da nota
    mov bx, ax                 ; BX = frequência
    mov al, 0xB6               ; Configura o speaker
    out 0x43, al               ; Envia comando para o controlador de som
    mov ax, bx                 ; AX = frequência
    out 0x42, al               ; Envia byte baixo da frequência
    mov al, ah                 ; AL = byte alto da frequência
    out 0x42, al               ; Envia byte alto da frequência
    in al, 0x61                ; Lê o estado do speaker
    or al, 0x03                ; Liga o speaker
    out 0x61, al               ; Envia comando para o speaker
    call delay                 ; Espera um pouco
    in al, 0x61                ; Lê o estado do speaker
    and al, 0xFC               ; Desliga o speaker
    out 0x61, al               ; Envia comando para o speaker
    ret

delay:
    ; Função para criar um pequeno atraso
    mov cx, 0xFFFF             ; Contador para o loop de atraso
.delay_loop:
    loop .delay_loop           ; Repete o loop para criar o atraso
    ret

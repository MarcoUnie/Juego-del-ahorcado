section .data
    msg_inicio db "=== JUEGO DEL AHORCADO ===", 10
    msg_inicio_len equ $ - msg_inicio
    win_msg db "GANASTE!", 10
    win_msg_len equ $ - win_msg
    lose_msg db "PERDISTE!", 10
    lose_msg_len equ $ - lose_msg
    restart_msg db "Jugar otra vez? (S/N): "
    restart_msg_len equ $ - restart_msg
    prompt_msg db "Ingresa una letra: "
    prompt_msg_len equ $ - prompt_msg
    attempts_msg db "Intentos restantes: "
    attempts_msg_len equ $ - attempts_msg
    newline db 10

    ; ── Dibujos del ahorcado (estado 6 = vivo, 0 = muerto) ──────────────────
    ; Cada estado es un string completo terminado en 0

    ; 6 intentos — horca vacía
    draw6 db "  +---+", 10
          db "  |   |", 10
          db "  |", 10
          db "  |", 10
          db "  |", 10
          db "  |", 10
          db "======", 10, 0
    draw6_len equ $ - draw6

    ; 5 intentos — cabeza
    draw5 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |", 10
          db "  |", 10
          db "  |", 10
          db "======", 10, 0
    draw5_len equ $ - draw5

    ; 4 intentos — cabeza + cuerpo
    draw4 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |   |", 10
          db "  |", 10
          db "  |", 10
          db "======", 10, 0
    draw4_len equ $ - draw4

    ; 3 intentos — cabeza + cuerpo + brazos
    draw3 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |  /|", 10
          db "  |", 10
          db "  |", 10
          db "======", 10, 0
    draw3_len equ $ - draw3

    ; 2 intentos — cabeza + cuerpo + brazos completos
    draw2 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |  /|\\", 10
          db "  |", 10
          db "  |", 10
          db "======", 10, 0
    draw2_len equ $ - draw2

    ; 1 intento — casi completo, falta una pierna
    draw1 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |  /|\\", 10
          db "  |  /", 10
          db "  |", 10
          db "======", 10, 0
    draw1_len equ $ - draw1

    ; 0 intentos — muñeco completo
    draw0 db "  +---+", 10
          db "  |   |", 10
          db "  |   O", 10
          db "  |  /|\\", 10
          db "  |  / \\", 10
          db "  |", 10
          db "======", 10, 0
    draw0_len equ $ - draw0

    ; Tabla de punteros a cada dibujo (índice = intentos restantes)
    draw_table dd draw0, draw1, draw2, draw3, draw4, draw5, draw6

    ; Tabla de longitudes
    draw_lens  dd draw0_len, draw1_len, draw2_len, draw3_len
               dd draw4_len, draw5_len, draw6_len

    ; ── Palabras ─────────────────────────────────────────────────────────────
    word0  db "GATO",  0,0,0,0
    word1  db "PERRO", 0,0,0
    word2  db "CASA",  0,0,0,0
    word3  db "LUNA",  0,0,0,0
    word4  db "ARBOL", 0,0,0
    word5  db "PATO",  0,0,0,0
    word6  db "LIBRO", 0,0,0
    word7  db "MANO",  0,0,0,0
    word8  db "TREN",  0,0,0,0
    word9  db "FLOR",  0,0,0,0

    words_table dd word0, word1, word2, word3, word4
                dd word5, word6, word7, word8, word9
    word_lens   db 4, 5, 4, 4, 5, 4, 5, 4, 4, 4

section .bss
    masked    resb 9
    attempts  resb 1
    input     resb 2
    found     resb 1
    cur_word  resd 1
    cur_len   resb 1
    rand_seed resd 1

section .text
    global _start

_start:
    mov eax, 13
    xor ebx, ebx
    int 80h
    mov [rand_seed], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_inicio
    mov edx, msg_inicio_len
    int 80h

    call pick_random_word
    call init_game
    jmp game_loop

; ─────────────────────────────────────────────────────────────────────────────
pick_random_word:
    mov eax, [rand_seed]
    imul eax, 1664525
    add  eax, 1013904223
    mov  [rand_seed], eax
    shr  eax, 16
    xor  edx, edx
    mov  ecx, 10
    div  ecx

    mov  eax, edx
    mov  ecx, word_lens
    movzx eax, byte [ecx + eax]
    mov  [cur_len], al

    mov  eax, edx
    mov  ecx, words_table
    mov  eax, [ecx + eax*4]
    mov  [cur_word], eax
    ret

; ─────────────────────────────────────────────────────────────────────────────
init_game:
    mov byte [attempts], 6
    movzx ecx, byte [cur_len]
    mov esi, masked
.fill:
    mov byte [esi], '_'
    inc esi
    loop .fill
    mov byte [esi], 0
    ret

; ─────────────────────────────────────────────────────────────────────────────
game_loop:
    call print_newline
    call draw_hangman      ; ← primero el dibujo
    call print_newline
    call print_masked
    call print_newline
    call print_attempts_num
    call print_newline
    call read_letter
    call check_letter
    call check_win

    movzx eax, byte [attempts]
    cmp eax, 0
    je lose
    jmp game_loop

; ─────────────────────────────────────────────────────────────────────────────
lose:
    call print_newline
    call draw_hangman      ; muestra el muñeco completo al perder
    call print_newline
    mov eax, 4
    mov ebx, 1
    mov ecx, lose_msg
    mov edx, lose_msg_len
    int 80h
    jmp ask_restart

; ─────────────────────────────────────────────────────────────────────────────
ask_restart:
    mov eax, 4
    mov ebx, 1
    mov ecx, restart_msg
    mov edx, restart_msg_len
    int 80h

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 2
    int 80h

    mov al, [input]
    cmp al, 'S'
    je do_restart
    cmp al, 's'
    je do_restart

    mov eax, 1
    mov ebx, 0
    int 80h

do_restart:
    call pick_random_word
    call init_game
    jmp game_loop

; ─────────────────────────────────────────────────────────────────────────────
draw_hangman:
    ; índice en la tabla = intentos restantes (0..6)
    movzx eax, byte [attempts]

    ; puntero al string
    mov ecx, draw_table
    mov ecx, [ecx + eax*4]

    ; longitud
    mov edx, draw_lens
    mov edx, [edx + eax*4]
    dec edx               ; quitamos el null terminator del conteo

    mov eax, 4
    mov ebx, 1
    int 80h
    ret

; ─────────────────────────────────────────────────────────────────────────────
print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 80h
    ret

; ─────────────────────────────────────────────────────────────────────────────
print_masked:
    movzx edx, byte [cur_len]
    mov eax, 4
    mov ebx, 1
    mov ecx, masked
    int 80h
    ret

; ─────────────────────────────────────────────────────────────────────────────
print_attempts_num:
    mov eax, 4
    mov ebx, 1
    mov ecx, attempts_msg
    mov edx, attempts_msg_len
    int 80h

    movzx eax, byte [attempts]
    add al, '0'
    mov [input+1], al
    mov eax, 4
    mov ebx, 1
    mov ecx, input+1
    mov edx, 1
    int 80h
    ret

; ─────────────────────────────────────────────────────────────────────────────
read_letter:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_msg
    mov edx, prompt_msg_len
    int 80h

    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 2
    int 80h

    mov al, [input]
    cmp al, 'a'
    jb .skip
    cmp al, 'z'
    ja .skip
    sub al, 20h
    mov [input], al
.skip:
    ret

; ─────────────────────────────────────────────────────────────────────────────
check_letter:
    mov byte [found], 0
    mov esi, [cur_word]
    mov edi, masked
    movzx ecx, byte [cur_len]
.loop:
    mov al, [esi]
    cmp al, [input]
    jne .next
    mov [edi], al
    mov byte [found], 1
.next:
    inc esi
    inc edi
    loop .loop

    cmp byte [found], 1
    je .end
    dec byte [attempts]
.end:
    ret

; ─────────────────────────────────────────────────────────────────────────────
check_win:
    mov esi, masked
    movzx ecx, byte [cur_len]
.loop:
    mov al, [esi]
    cmp al, '_'
    je .not_win
    inc esi
    loop .loop

    call print_newline
    call draw_hangman
    call print_newline
    mov eax, 4
    mov ebx, 1
    mov ecx, win_msg
    mov edx, win_msg_len
    int 80h
    jmp ask_restart
.not_win:
    ret

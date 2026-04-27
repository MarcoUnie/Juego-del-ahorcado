.model small
.stack 100h

.data
    ; Mensajes
    msg_inicio db "=== JUEGO DEL AHORCADO ===$",13,10
    newline db 13,10,"$"
    win_msg db "GANASTE!$",13,10
    lose_msg db "PERDISTE!$",13,10
    restart_msg db "Jugar otra vez? (S/N): $"

    ; Palabras
    secret db "GATO$"
    masked db "____$"

    ; Variables
    input db ?
    attempts db 6
    found db 0

    ; Letras usadas
    used_letters db 10 dup('$')
    used_index db 0

    ; Dibujos
    head db "  O",13,10,"$"
    body db "  |",13,10,"$"
    arms db " /|\ ",13,10,"$"
    legs db " / \ ",13,10,"$"

.code
main proc
    mov ax, @data
    mov ds, ax

start_game:
    mov attempts, 6

game_loop:

    call print_newline
    call print_masked
    call print_newline
    call print_attempts
    call print_newline

    call read_letter
    call check_letter
    call draw_hangman
    call check_win

    cmp attempts, 0
    je lose

    jmp game_loop

; ---------------------
lose:
    mov dx, offset lose_msg
    mov ah, 09h
    int 21h

restart:
    mov dx, offset restart_msg
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    cmp al, 'S'
    je start_game

    mov ah, 4Ch
    int 21h

; ---------------------
print_newline proc
    mov dx, offset newline
    mov ah, 09h
    int 21h
    ret
print_newline endp

; ---------------------
read_letter proc
    mov ah, 01h
    int 21h

    ; convertir a mayúscula
    cmp al, 'a'
    jb skip_convert
    cmp al, 'z'
    ja skip_convert
    sub al, 20h
skip_convert:

    mov input, al
    ret
read_letter endp

; ---------------------
print_masked proc
    mov dx, offset masked
    mov ah, 09h
    int 21h
    ret
print_masked endp

; ---------------------
print_attempts proc
    mov al, attempts
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    ret
print_attempts endp

; ---------------------
check_letter proc
    mov si, offset secret
    mov di, offset masked
    mov cx, 4

    mov found, 0

compare_loop:
    mov al, [si]
    cmp al, input
    jne skip

    mov [di], al
    mov found, 1

skip:
    inc si
    inc di
    loop compare_loop

    cmp found, 1
    je end_check

    dec attempts

end_check:
    ret
check_letter endp

; ---------------------
draw_hangman proc

    cmp attempts, 5
    jne skip_head
    mov dx, offset head
    mov ah, 09h
    int 21h
skip_head:

    cmp attempts, 4
    jne skip_body
    mov dx, offset body
    mov ah, 09h
    int 21h
skip_body:

    cmp attempts, 3
    jne skip_arms
    mov dx, offset arms
    mov ah, 09h
    int 21h
skip_arms:

    cmp attempts, 2
    jne skip_legs
    mov dx, offset legs
    mov ah, 09h
    int 21h
skip_legs:

    ret
draw_hangman endp

; ---------------------
check_win proc
    mov si, offset masked
    mov cx, 4

win_loop:
    mov al, [si]
    cmp al, '_'
    je not_win
    inc si
    loop win_loop

    mov dx, offset win_msg
    mov ah, 09h
    int 21h

    jmp restart

not_win:
    ret
check_win endp

main endp
end main

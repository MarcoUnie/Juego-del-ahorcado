.model small
.stack 100h

.data
    msg db "Juego del Ahorcado$", 13, 10
    newline db 13,10,"$"
    input db ?
    secret db "GATO$"
    masked db "____$"
    attempts db 6
    found db 0
    body db "  |",13,10,"$"

.code
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
    mov found, 0


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
    print_newline proc
    mov dx, offset newline
    mov ah, 09h
    int 21h
    ret
    print_newline endp
    
    read_letter proc
    mov ah, 01h
    int 21h
    mov input, al
    ret
    read_letter endp

    print_letter proc
    mov dl, input
    mov ah, 02h
    int 21h
    ret
    print_letter endp

    print_masked proc
    mov dx, offset masked
    mov ah, 09h
    int 21h
    ret
    print_masked endp

    print_attempts proc
    mov al, attempts
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    ret
    print_attempts endp

draw_hangman proc
    cmp attempts, 5
    jne no_head

    mov dx, offset head
    mov ah, 09h
    int 21h

no_head:
    cmp attempts, 4
    jne no_body

    mov dx, offset body
    mov ah, 09h
    int 21h

no_body:
    
    ret
draw_hangman endp

main proc
    mov ax, @data
    mov ds, ax

    mov dx, offset msg
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

    call print_masked

main endp
end main

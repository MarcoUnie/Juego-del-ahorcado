.model small
.stack 100h

.data
    msg db "Juego del Ahorcado$", 13, 10
    newline db 13,10,"$"
    input db ?
    

.code
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

main proc
    mov ax, @data
    mov ds, ax

    mov dx, offset msg
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

main endp
end main
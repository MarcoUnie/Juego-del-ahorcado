.model small
.stack 100h

.data
    msg db "Juego del Ahorcado$", 13, 10
    newline db 13,10,"$"
    

.code
main proc
    mov ax, @data
    mov ds, ax

    mov dx, offset msg
    mov ah, 09h
    int 21h

    mov ah, 4Ch
    int 21h

    print_newline proc
    mov dx, offset newline
    mov ah, 09h
    int 21h
    ret
print_newline endp
main endp
end main
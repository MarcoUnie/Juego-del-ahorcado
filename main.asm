.model small
.stack 100h

.data
    msg db "Juego del Ahorcado$", 13, 10

.code
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
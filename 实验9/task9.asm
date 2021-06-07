assume cs:codesg
data segment
    db 'welcome to masm!'
data ends
codesg segment
    start:
    mov ax,0b800h
    mov ds,ax
    mov ax,data
    mov es,ax
    mov si,0
    mov bx,07c0h
    
    mov ah,00000010b;welcome
    mov cx,7
    s0:
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2
    loop s0

    mov ah,00000000b;空格
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2

    mov ah,00100100b;to
    mov cx,2
    s1:
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2
    loop s1

    mov ah,00000000b;空格
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2

    mov ah,01110001b;masm!
    mov cx,5
    s2:
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2
    loop s2

    mov ax, 4c00h
    int 21h
codesg ends
end start

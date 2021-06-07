assume cs:codesg
data segment
    db 'ID: 2019xxxxxx,Name: Ni Cai'
data ends
codesg segment
    start:
    mov ax,0b800h
    mov ds,ax
    mov ax,data
    mov es,ax
    mov si,0
    mov bx,07c0h-16

    mov ah,00000100b;黑底红字
    mov cx,27;data长度
    s2:
    mov al,byte ptr es:[si]
    mov word ptr ds:[bx],ax
    inc si
    add bx,2
    dec cx
    jcxz finish
    jmp short s2
    finish:
    mov ax, 4c00h
    int 21h
codesg ends
end start
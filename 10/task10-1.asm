assume cs:code
data segment
    db 'Welcome to masm!',0
data ends
stack segment
    dw 8 dup (0)
stack ends
code segment
main:
    mov dh,8;行号
    mov dl,3;列号
    mov cl,2;颜色
    mov ax,data
    mov ds,ax
    mov si,0;ds:si指向字符串的首地址
    call show_str

    mov ax, 4c00h
    int 21h
show_str:
    push dx
    push cx;保存相关寄存器

    mov ax,0b800h
    mov es,ax;显存
    mov ax,00a0h
    sub dh,1
    mul dh
    mov bx,ax;es:[bx]
    mov ax,0
    sub dl,1
    mov al,dl
    add bx,ax
    add bx,ax;es:[bx]记录起始位置

    mov di,0
    mov si,0
    mov ah,cl
    mov cx,0
show_str_loop:
    mov cl,byte ptr ds:[di]
    jcxz show_str_ret
    mov al,cl
    mov word ptr es:[bx+si],ax
    inc di
    add si,2
    jmp show_str_loop
show_str_ret:
    pop cx
    pop dx
    ret
code ends
end main
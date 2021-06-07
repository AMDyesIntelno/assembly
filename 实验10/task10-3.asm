assume cs:code
data segment
    db 10 dup (0)
data ends
stack segment
    dw 16 dup (0)
stack ends

code segment
main:
    mov ax,12666
    mov bx,data
    mov ds,bx
    mov bx,stack
    mov ss,bx
    mov sp,32
    mov si,0
    call dtoc

    mov dh,8
    mov dl,3
    mov cl,2
    call show_str
    
    mov ax,4c00h
    int 21h

dtoc:
    push bp
    mov bp,sp
    mov dx,0
    push dx
    mov bx,10
dtoc_loop:
    div bx;ax:商,dx:余数
    add dx,030h;0->'0'
    push dx;ascii入栈
    mov cx,ax
    jcxz dtoc_re
    mov dx,0
    jmp dtoc_loop
dtoc_re:;用栈将ascii倒序
    pop cx
    jcxz dtoc_ret
    mov byte ptr ds:[si],cl;移动到内存区
    inc si
    jmp dtoc_re
dtoc_ret:
    mov sp,bp
    pop bp
    ret

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

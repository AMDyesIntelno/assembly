assume cs:code
stack segment
    dw 16 dup (0)
stack ends
code segment
main:
    mov ax,stack
    mov ss,ax
    mov sp,32
    mov ax,4240h
    mov dx,0fh
    mov cx,0ah
    push ax
    push dx
    push cx
    call divdw
    mov ax, 4c00h
    int 21h
divdw:
    push bp
    mov bp,sp
    mov ax,word ptr ss:[bp+6];高16位
    mov dx,0;dx清零
    div word ptr ss:[bp+4];dx:余数,ax:商
    push ax;结果的高16位
    mov ax,word ptr ss:[bp+8];低16位
    div word ptr ss:[bp+4];dx:余数,ax:商(低16位)
    mov cx,dx;cx存放余数
    mov dx,word ptr ss:[bp-2];结果的高16位
    mov sp,bp
    pop bp
    ret 6
code ends
end main

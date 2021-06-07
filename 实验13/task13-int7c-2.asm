assume cs:code
code segment
main:
    mov ax,cs
    mov ds,ax
    mov si,offset int7c
    
    mov ax,0000h
    mov es,ax
    mov di,0200h

    cld
    mov cx,offset int7c_end-offset int7c
    rep movsb

    mov ax,0000h
    mov es,ax
    mov word ptr es:[7ch*4],0200h
    mov word ptr es:[7ch*4+2],0000h

    mov ax,4c00h
    int 21h
int7c:
    push bp
    mov bp,sp
    dec cx
    jcxz finish
    add ss:[bp+2],bx
finish:
    mov sp,bp
    pop bp
    iret
int7c_end:
    nop
code ends
end main

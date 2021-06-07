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
    mov ax,0b800h
    mov es,ax

    mov ax,160
    mul dh
    xor dh,dh
    add dl,dl
    add ax,dx
    mov di,ax;计算偏移
print:
    mov ch,byte ptr ds:[si]
    cmp ch,0
    je finish
    mov byte ptr es:[di],ch
    mov byte ptr es:[di+1],cl
    inc si
    add di,2
    jmp print
finish:
    iret
int7c_end:
    nop
code ends
end main

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
    jmp short setscreen
    table dw offset sub1-offset int7c+200h,offset sub2-offset int7c+200h,offset sub3-offset int7c+200h,offset sub4-offset int7c+200h;确定各个函数的相对偏移量
setscreen:
    push bx
    cmp ah,3
    ja ah_err
    mov bl,ah
    mov bh,0
    add bx,bx
    ;call word ptr table[bx]
    ;mov ax,offset int7c
    call word ptr cs:table[bx+offset main-offset int7c+200h];call cs:[bx+0202] call word ptr table[bx] == call [bx+002f] offset int7c=002d
ah_err:
    jmp finish

sub1:
    push bx
    push cx
    push es
    mov bx,0b800h
    mov es,bx
    mov bx,0
    mov cx,2000
sub1_loop:
    mov byte ptr es:[bx],' '
    add bx,2
    loop sub1_loop
    pop es
    pop cx
    pop bx
    ret

sub2:
    push bx
    push cx
    push es
    mov bx,0b800h
    mov es,bx
    mov bx,1
    mov cx,2000
sub2_loop:
    and byte ptr es:[bx],11111000b;清除前景色RGB
    or es:[bx],al;设置前景色RGB
    add bx,2
    loop sub2_loop
    pop es
    pop cx
    pop bx
    ret

sub3:
    push bx
    push cx
    push es
    mov cl,4
    shl al,cl;调整背景色位置
    mov bx,0b800h
    mov es,bx
    mov bx,1
    mov cx,2000
sub3_loop:
    and byte ptr es:[bx],10001111b;清除背景色RGB
    or es:[bx],al;设置背景色RGB
    add bx,2
    loop sub3_loop
    pop es
    pop cx
    pop bx
    ret

sub4:
    push cx
    push si
    push di
    push es
    push ds
    mov si,0b800h
    mov es,si
    mov ds,si
    mov si,160
    mov di,0
    cld
    mov cx,24
sub4_loop:
    push cx
    mov cx,160
    rep movsb
    pop cx
    loop sub4_loop
    mov cx,80
    mov si,0
sub4_clear:
    mov byte ptr es:[160*24+si],' '
    add si,2
    loop sub4_clear
    pop ds
    pop es
    pop di
    pop si
    pop cx
    ret
finish:
    pop bx
    iret
int7c_end:
    nop
code ends
end main

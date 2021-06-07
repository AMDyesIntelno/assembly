assume cs:code
code segment
main:
    mov ax,cs
    mov ds,ax
    mov si,offset int7c

    mov ax,0000h
    mov es,ax
    mov di,0200h;将es:di指向内存0000:0200处

    mov cx,offset int7cend-offset int7c;将cx设置为int7c的代码长度

    cld;DF=0,地址自动增量

    rep movsb

    mov ax,0
    mov es,ax;es指向中断向量表
    mov word ptr es:[7ch*4],0200h;低地址字存放偏移地址
    mov word ptr es:[7ch*4+2],0000h;高地址字存放段地址

    mov ax,4c00h
    int 21h

int7c:
    jmp short int7cstart
    db 9,8,7,4,2,0;年月日时分秒
int7cstart:
    mov ax,cs
    mov ds,ax
    mov di,160*12+30*2;di显存输出起始位置
    mov si,0202h;cs:ip 0000:0200 jmp short 两个字节
    mov bx,0b800h
    mov es,bx
    xor ax,ax
    
    call date;年
    mov ax,'/'
    push ax
    call sep

    call date;月
    mov ax,'/'
    push ax
    call sep
    
    call date;日
    mov ax,' '
    push ax
    call sep

    call date;时
    mov ax,':'
    push ax
    call sep

    call date;分
    mov ax,':'
    push ax
    call sep

    call date;秒

    iret

date:
    mov al,byte ptr ds:[si]
    inc si
    out 70h,al
    in al,71h

    mov ah,al
    mov cl,4
    shr ah,cl;保留前4位
    and al,00001111b;保留后4位

    add al,30h
    add ah,30h;BCD码转ascii码
    
    mov byte ptr es:[di],ah
    add di,2
    mov byte ptr es:[di],al
    add di,2
    ret

sep:
    push bp
    mov bp,sp
    mov ax,ss:[bp+4]
    mov byte ptr es:[di],al
    add di,2
    mov sp,bp
    pop bp
    ret 2
int7cend:
    nop

code ends
end main